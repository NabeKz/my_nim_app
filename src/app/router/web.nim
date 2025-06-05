import std/asynchttpserver
import std/asyncdispatch
import std/strutils
import std/htmlgen
import std/sequtils
import std/re

import src/app/router/context
import src/pages/shared
import src/pages/home
import src/pages/books
import ./cookies

const headers = {
  "Content-Type": "text/html charset=utf8;"
}

template suspend*(body: untyped): untyped =
  try:
    body
  except:
    await req.failure()

proc resp(req: Request, status: HttpCode, content: string): Future[void] =
  req.respond(status, content, headers.newHttpHeaders())

proc resp(req: Request, content: string): Future[void] =
  resp(req, Http200, content)

proc match(req: Request, path: string, reqMethod: HttpMethod): bool{.gcsafe.} =
  if req.reqMethod == HttpPost and reqMethod != HttpPost:
    req.url.path.match(re path & "$") and req.url.query == "_method=" & $reqMethod
  else:
    req.url.path.match(re path & "$") and req.reqMethod == reqMethod

proc redirect(req: Request, path: string, headers: seq[tuple[key: string,
    value: string]]): Future[void] =
  req.respond(Http303, "", @[
    ("Location", path),
  ]
    .concat(headers)
    .newHttpHeaders()
  )

proc success(req: Request, path: string): Future[void] =
  let cookie = cookies.setCookie("success", "ok").string
  req.redirect(path, @[
    ("Set-Cookie", cookie)
  ])

proc failure(req: Request): Future[void] =
  let cookie = cookies
    .deleteCookie("success")
    .setCookie("error", "Something went wrong", req.url.path)
    .string

  req.redirect(req.url.path, @[
    ("Set-Cookie", cookie)
  ])

template build(body: varargs[string]): string =
  ""

proc asideNav(path: string): string =
  htmlgen.li(
    htmlgen.a(
      href = path,
      path
    )
  )

proc layout(body: string): string =
  htmlgen.head(
    htmlgen.style(
      "ul, li { margin: 0 }",
      "label { display: grid; }",
      "form { button { margin-top: 8px; } }",
      ".layout { display: flex; margin:auto; max-width: 1400px; height: 100vh; gap: 24px; padding: 36px; }",
      ".aside { display: flex; }",
    ),
    htmlgen.div(
      class = "layout",
      htmlgen.aside(
        class = "aside",
        htmlgen.ul(
          asideNav("/siginin"),
          asideNav("/books"),
          asideNav("/books/create")
      ),
    ),
      body
    )
  )

proc getCookie(req: Request): seq[string] =
  req.headers.getOrDefault("cookie").toString().split("; ")

proc tail(self: Request): string =
  self.url.path.split("/")[^1]


proc router*(ctx: Context, req: Request) {.async, gcsafe.} =
  try:
    if req.match("/", HttpGet):
      await resp(req, layout home.index())

    if req.match("/books", HttpGet):
      await resp(req, layout books.index(ctx.books))

    if req.match("/books/create", HttpGet):
      let messages = req.getCookie()
      let body = books.create(messages)
      await resp(req, layout body)

    if req.match("/books/create", HttpPost):
      suspend:
        let body = books.validate(req.body)
        books.save(ctx.books, body)
        await req.success("/books")

    if req.match("/books/update/\\d+", HttpGet):
      let id = req.url.path.split("/")[^1]
      suspend:
        let book = books.find(ctx.books, id)
        await req.respond(Http200, $Http200)

    if req.match("/books/update/\\d+", HttpPut):
      let id = req.url.path.split("/")[^1]
      let form = req.body
      suspend:
        let book = books.find(ctx.books, id)
        books.update(ctx.books, book)
        await req.success("/books")

    if req.match("/books/delete/\\d+", HttpDelete):
      let id = req.url.path.split("/")[^1]
      suspend:
        books.delete(ctx.books, id)
        await req.success("/books")

    await req.respond(Http404, $Http404)

  except ValidateError:
    let errors = getCurrentException()
    await req.respond(Http400, $Http400)

  except:
    await req.respond(Http500, $Http500)
