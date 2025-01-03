import std/asynchttpserver
import std/asyncdispatch

import src/server/handler
import src/feature/user/port
import src/feature/user/usercase
import src/feature/user/model

template userController*(req: Request, repository: UserRepository) =
  list "/users":
    await req.respond(Http200, $Http200)
  create "/users":
    handleRequest req.body, user:
      create(repository, user)
      await req.json(Http200, user)

  read "/users", id:
    await req.respond(Http200, id)