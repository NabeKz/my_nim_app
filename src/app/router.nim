import std/asynchttpserver
import std/asyncdispatch

proc handle_request*(req: Request) {.async, gcsafe.}  =
  await req.respond(Http200, "ok")