import std/json
import std/sugar

import src/shared/handler
import src/shared/port/http

import src/features/shopping_cart/usecase


type
  ShoppingCartGetController* = Handler
  ShoppingCartPostController* = Handler


proc newShoppingCartGetController*(usecase: CartFetchUsecase): ShoppingCartGetController =
  (req: Request) => (
    let form = req.body.toJson()
    let data = usecase(form)
    req.json(Http200, data)
  )


generateUnmarshal(ProductItemInputDto)
proc newShoppingCartPostController*(usecase: CartAddUsecase): ShoppingCartPostController =
  (req: Request) => (
    let form = req.body.toJson().unmarshal()
    # usecase(form)
    req.json(Http200)
  )
