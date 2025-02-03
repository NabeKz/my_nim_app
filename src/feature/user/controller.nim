import src/feature/user/[port, usecase, model]
import src/shared/handler

template userController*(req, repository: untyped): untyped =
  list "/users":
    let users = list(repository)
    await req.json(Http200, users)

  create "/users":
    handleRequest req.body, user:
      discard create(repository, user)
      await req.json(Http200, user)

  read "/users", id:
    await req.respond(Http200, id)
