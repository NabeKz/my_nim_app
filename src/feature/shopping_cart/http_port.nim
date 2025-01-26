import std/asynchttpserver
import std/asyncdispatch
import src/server/handler
import src/shared/port/http
import std/json

import ./usecase


proc fetchShoppingCart*(usecase: CartFetchUsecase, req: Request): Future[void] =
  let form = req.body.toJson()
  let data = usecase.invoke()
  req.json(Http200, data)

proc postShoppingCart*(usecase: CartItemAddUsecase, req: Request): Future[void] =
  let form = req.body.toJson()
  let data = usecase.invoke(form)
  req.json(Http200, data)

