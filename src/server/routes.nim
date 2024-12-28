import std/asynchttpserver
import std/asyncdispatch

import ./handler

proc router*(req: Request) {.async.} =
  list "/users":
    await req.respond(Http200, $Http200)
  create "/users":
    let body = req.body
    await req.respond(Http200, body)
  read "/users", id:
    await req.respond(Http200, id)

  await req.respond(Http404, $Http404)
