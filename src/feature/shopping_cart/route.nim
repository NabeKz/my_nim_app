import std/asynchttpserver
import std/asyncdispatch

import src/server/handler
import src/shared/db/conn
import src/shared/utils
import src/entities/product/[model, adaptor/rdb]
import src/feature/shopping_cart/[controller, usecase, model, repository]


func newFetchShoppingCartRoute*(db: DBConn): proc(req: Request): Future[void]{.gcsafe.} =
  proc (req: Request): Future[void]{.gcsafe.} =
    let q = ShoppingCartQueryServiceSqlite.init(db)
    let u = CartFetchUsecaseImpl.init(q)
    ShoppingCartListController.run(u, req)


func newPostShoppingCartRoute*(db: DBConn): proc(req: Request): Future[void]{.gcsafe.} =
  proc (req: Request): Future[void]{.gcsafe.} =
    let r = ProductRepositoryOnSqlite.init(db)
    let u = CartItemAddUsecaseImpl.init(r)
    ShoppingCartPostController.run(u, req)
