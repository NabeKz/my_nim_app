import std/asynchttpserver
import std/asyncdispatch
import std/json

import src/server/handler
import src/shared/port/http

import ./usecase


type ShoppingCartListController* = ref object
type ShoppingCartPostController* = ref object


proc run*(_: type ShoppingCartListController, usecase: CartFetchUsecase, req: Request): Future[void] =
  let form = req.body.toJson()
  let data = usecase.invoke(form)
  req.json(Http200, data)



generateUnmarshal(ProductItemInputDto)
proc run*(_: type ShoppingCartPostController, usecase: CartItemAddUsecaseImpl, req: Request): Future[void] =
  let form = req.body.toJson().unmarshal()
  let data = usecase(form)
  req.json(Http200, "data")
