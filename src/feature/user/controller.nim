import std/asynchttpserver
import std/asyncdispatch

import src/server/handler
import src/feature/user/[port, usecase, model, repository]

template userController*(req: Request, repository: UserRepository): untyped =
  list "/users":
    await req.respond(Http200, $Http200)

  create "/users":
    handleRequest req.body, user:
      # discard create(repository, user)
      await req.json(Http200, user)

  read "/users", id:
    await req.respond(Http200, id)