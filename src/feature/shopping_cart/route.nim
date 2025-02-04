import std/asynchttpserver
import std/asyncdispatch

import src/shared/handler
import src/shared/db/conn


import src/feature/shopping_cart/[controller, usecase, model, repository]


func newFetchShoppingCartRoute*(db: DBConn): auto =
  proc (req: Request): auto =
    let q = ShoppingCartQueryServiceSqlite.init(db)
    let u = CartFetchUsecase.init q
    ShoppingCartListController.run(u, req)


func newFetchShoppingCartRoute*(): auto =
  proc (req: Request): auto =
    let q = ShoppingCartRepositoryOnMemory.init()
    let u = CartFetchUsecase.init q
    ShoppingCartListController.run(u, req)


func newPostShoppingCartRoute*(db: DBConn): auto =
  proc (req: Request): auto =
    let r = ShoppingCartRepositoryOnMemory.init()
    let u = CartItemAddUsecaseImpl.init(r.save)
    ShoppingCartPostController.run(u, req)
