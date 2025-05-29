import std/asynchttpserver
import std/asyncdispatch

proc router*(req: Request) {.async, gcsafe.} =
   if req.url.path == "/":
      await req.respond(Http200, "Hello")

   await req.respond(Http404, $Http404)
