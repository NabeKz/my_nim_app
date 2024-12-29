import std/asynchttpserver
import std/asyncdispatch

import src/server/handler
import src/feature/user/port

proc userController*(req: Request) {.async.} =
  list "/users":
    await req.respond(Http200, $Http200)
  create "/users":
    handleRequest req.body, user:
      await req.json(Http200, user)

  read "/users", id:
    await req.respond(Http200, id)

  await req.respond(Http404, $Http404)
