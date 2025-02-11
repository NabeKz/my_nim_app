import std/asynchttpserver
import std/asyncdispatch

import src/feature/shopping_cart/route
import src/shared/db/conn
import src/shared/[handler]
import src/dependency

type 
  App = ref object
    server: AsyncHttpServer

func newApp(db: DbConn): App =
  App(
    server: newAsyncHttpServer()
  )  

proc run(self: App) {.async.} =
  var db = dbConn("db.sqlite3")
  defer: db.close()
  
  self.server.listen(Port 5000)
  echo "server is running at 5000"
  
  let fetchShoppingCartController = newFetchShoppingCartRoute()
  let postShoppingCartController = newPostShoppingCartRoute(db)
  let deps = newDependency()

  proc router(req: Request) {.async, closure, gcsafe.}  =

    if req.url.path == "/products" and req.reqMethod == HttpGet:
      await deps.productListController(req)
    if req.url.path == "/products" and req.reqMethod == HttpPost:
      await deps.productPostController(req)
    
    # if req.url.path == "/products" and req.reqMethod == HttpPost:
      # let (code, content) = productPostController.build(req.body)
      # let (code, content) = productPostController(req)
      # await req.json(code, content)

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
