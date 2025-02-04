import std/asynchttpserver
import std/asyncdispatch

import src/shared/handler
import src/shared/db/conn


import src/feature/shopping_cart/[controller, usecase, model, repository]


func newFetchShoppingCartRoute*(): auto =
  proc (req: Request): auto =
    req.respond(Http200, "ok")


func newPostShoppingCartRoute*(db: DBConn): auto =
  proc (req: Request): auto =
    let r = ShoppingCartRepositoryOnMemory.init()
    let u = CartItemAddUsecaseImpl.init(r.save)
    ShoppingCartPostController.run(u, req)
