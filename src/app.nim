import std/asynchttpserver
import std/asyncdispatch
import std/sugar

import src/feature/user/[controller, model, repository]
import src/entities/product/[controller, usecase, model, repository]
import src/entities/product/adaptor/controller/create
import src/feature/shopping_cart/route
import src/shared/db/conn
import src/shared/[handler]
import src/shared/utils
import ./model

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
  
  let productRepository = newProductRepositoryOnMemory().toInterface()
  let productListController = newProductListController newProductFetchUsecase productRepository
  
  let productPostController = newProductPostControllerEvent(newProductCreateUsecase productRepository)
  let fetchShoppingCartController = newFetchShoppingCartRoute()
  let postShoppingCartController = newPostShoppingCartRoute(db)

  let healthCheckController = controller(usecase())

  proc router(req: Request) {.async, closure, gcsafe.}  =
    # userController(req, self.repository.user)
    if req.url.path == "/health-check":
      await healthCheckController(req)


    list "/products", productListController(req)
    
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
