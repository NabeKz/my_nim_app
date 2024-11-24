import std/asynchttpserver
import std/asyncdispatch
import std/json
import std/macros

proc json*(req: Request, code: HttpCode, content: ref object): Future[void] = 
  let headers = newHttpHeaders({
    "Content-type": "application/json"
  })
  let c = % content
  req.respond(code, $c, headers)


proc text*(req: Request, code: HttpCode): Future[void] =
  let headers = newHttpHeaders({
    "Content-type": "text/plain; charset=utf-8"
  })
  req.respond(code, "", headers)

template router(req: Request, body: untyped): untyped =
  if req.url.path == "/user":
    body
  else:
    await req.respond(Http404, $Http404)


proc router(req: Request) {.async.} =
  if req.url.path == "/users":
    if req.reqMethod == HttpGet:
      await req.respond(Http200, $Http200)
    if req.reqMethod == HttpPost:
      await req.respond(Http201, $Http201)
  else:
    await req.respond(Http404, $Http404)

when isMainModule:
  dumpTree:
    let id = 1