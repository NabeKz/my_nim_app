import std/asynchttpserver
import std/asyncdispatch
import std/sugar
import src/entities/product/model
import src/feature/shopping_cart/[controller, usecase, model, repository]

import src/shared/db/conn

type ReadWithDb = DbConn -> Query -> ProductReadModel
# domain
type Query = string
type ReadData = Query -> ProductReadModel
type Usecase = ReadData -> ShoppingCart
type Workflow = string -> auto -> Future[void]



proc run*(_: Workflow, usecase: CartFetchUsecaseImpl) =
  usecase.invoke()



when isMainModule:
  # Workflow.run
