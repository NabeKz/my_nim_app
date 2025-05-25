import std/strutils
import std/htmlgen
import std/sequtils

import src/shared/handler
import src/pages/home
import src/pages/books

const headers = { 
  "Content-Type": "text/html charset=utf8;"
}

proc resp(req: Request, status: HttpCode, content: string): Future[void] =
  req.respond(status, content, headers.newHttpHeaders())

proc resp(req: Request, content: string, cookie: string): Future[void] =
  let headers = headers.items.toSeq().concat(@[
    ("Set-Cookie", "hoge=fuga;errors=piyo"),
  ])

  req.respond(Http200, content, headers.newHttpHeaders())

proc resp(req: Request, content: string): Future[void] =
  resp(req, Http200, content)

proc match(req: Request, path: string, reqMethod: HttpMethod): bool =
  req.url.path == path and req.reqMethod == reqMethod
  
proc redirect(req: Request, path: string): Future[void] =
  req.respond(Http303, "", {"location": path}.newHttpHeaders())

proc redirect(req: Request): Future[void] =
  req.redirect(req.url.path)

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


proc router*(req: Request) {.async, gcsafe.}  =
  try:
    if req.match("/", HttpGet):
      await resp(req, layout home.index())

    if req.match("/books", HttpGet):
      await resp(req, layout books.index())
    
    if req.match("/books/create", HttpGet):
      await resp(req, layout books.create())

    if req.match("/books/create", HttpPost):
      let body = books.validate(req.body)

      await req.redirect()

    await req.respond(Http404, $Http404)

  except ValidateError:
    let errors = getCurrentException()
    await req.respond(Http400, $Http400)

  except:
    await req.respond(Http500, $Http500)
