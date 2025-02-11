import std/sugar
import std/json

import src/entities/product/usecase/list
import src/shared/handler


type 
  ProductListController* = Handler


proc newProductListController*(usecase: ProductListUsecase): ProductListController =
  let data = usecase()
  let jsonNode = %* data
  let res = $jsonNode
  
  ProductListController(
    (req: Request) => req.json(Http200, res)
  )
