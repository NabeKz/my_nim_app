import std/asynchttpserver
import std/asyncdispatch

import src/shared/handler
import src/shared/db/conn


import src/feature/shopping_cart/[controller, usecase, model, repository]


func newFetchShoppingCartRoute*(): auto =
  let r = ShoppingCartRepositoryOnMemory.init()
  let u = CartFetchUsecase.init(r.fetch)
  proc (req: Request): auto =
    req.json(Http200, "ok")


func newPostShoppingCartRoute*(db: DBConn): auto =
  let r = ShoppingCartRepositoryOnMemory.init()
  let u = CartItemAddUsecase.init(r.save)
  proc (req: Request): auto =
    ShoppingCartPostController.run(u, req)
