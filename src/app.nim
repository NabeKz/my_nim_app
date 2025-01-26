import std/asynchttpserver
import std/asyncdispatch

import src/feature/user/[controller, model, repository]
import src/feature/shopping_cart/[controller, usecase]
import src/shared/db/conn

type 
  Repository = object
    user: UserRepository

  App = ref object
    server: AsyncHttpServer
    repository: Repository

func newApp(db: DbConn): App =
  App(
    server: newAsyncHttpServer(),
    repository: Repository(
      user: newUserRepository(db)
    )
  )


proc run(self: App) {.async.} =
  self.server.listen(Port 5000)
  echo "server is running at 5000"
  

  proc router(req: Request) {.async.}  =
    userController(req, self.repository.user)

    block cart: 
      if req.url.path == "/cart" and req.reqMethod == HttpGet:
        await fetchShoppingCart(req, CartFetchUsecaseImpl.invoke)

      if req.url.path == "/cart" and req.reqMethod == HttpPost:
        postShoppingCart req, CartItemAddUsecaseImpl()



    await req.respond(Http404, $Http404)

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(router)
    else:
      await sleepAsync(500)


let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
