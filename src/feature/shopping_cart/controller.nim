import std/asynchttpserver
import std/asyncdispatch
import src/server/handler
import src/shared/port/http
import std/json

import ./usecase


# template fetchShoppingCart*(req: Request, usecase: CartFetchUsecase): untyped =
#   let form = req.body.toJson()
#   let data = usecase.invoke()
#   await req.json(Http200, data)

proc fetchShoppingCart*(req: Request, usecase: CartFetchUsecase): Future[void] =
  let form = req.body.toJson()
  let data = usecase()
  req.json(Http200, data)

template postShoppingCart*(req: Request, usecase: CartItemAddUsecase): untyped =
  let form = req.body.toJson()
  let data = usecase.invoke(form)
  await req.json(Http200, data)
