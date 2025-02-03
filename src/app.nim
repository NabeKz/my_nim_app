import std/asynchttpserver
import std/asyncdispatch

import src/feature/user/[controller, model, repository]
import src/feature/shopping_cart/route
import src/shared/db/conn
import src/shared/[handler]
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
  
  let fetchShoppingCartController = newFetchShoppingCartRoute(db)
  let postShoppingCartController = newPostShoppingCartRoute(db)

  proc router(req: Request) {.async.}  =
    # userController(req, self.repository.user)

    list "/cart", fetchShoppingCartController(req)
    create "/cart", postShoppingCartController(req)



    await req.respond(Http404, $Http404)

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(router)
    else:
      await sleepAsync(500)


let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
