import std/asynchttpserver
import std/asyncdispatch
import std/sugar

import src/feature/user/[controller, model, repository]
import src/feature/shopping_cart/[controller, usecase, model, repository]
import src/shared/db/conn
import src/shared/utils

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
  var db = dbConn("db.sqlite3")
  defer: db.close()
  
  self.server.listen(Port 5000)
  echo "server is running at 5000"
  
  
  let fetchShoppingCartController = build(db, ShoppingCartListController, CartFetchUsecaseImpl, ShoppingCartQueryServiceSqlite)
  let postShoppingCartController = build(db, ShoppingCartListController, CartFetchUsecaseImpl, ShoppingCartQueryServiceSqlite)

  proc router(req: Request) {.async.}  =
    userController(req, self.repository.user)

    block cart: 
      if req.url.path == "/cart" and req.reqMethod == HttpGet:
        await fetchShoppingCartController(req)
          

      if req.url.path == "/cart" and req.reqMethod == HttpPost:
        await postShoppingCartController(req)



    await req.respond(Http404, $Http404)

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(router)
    else:
      await sleepAsync(500)


let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
