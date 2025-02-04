import std/asynchttpserver
import std/asyncdispatch
import std/json

import src/shared/handler
import src/shared/port/http

import ./usecase


type ShoppingCartListController* = ref object
type ShoppingCartPostController* = ref object


proc run*(_: type ShoppingCartListController, usecase: CartFetchUsecase, req: Request): Future[void] =
  let form = req.body.toJson()
  let data = usecase.invoke(form)
  req.json(Http200, data)



generateUnmarshal(ProductItemInputDto)
proc run*(_: type ShoppingCartPostController, usecase: CartItemAddUsecase, req: Request): Future[void] =
  let form = req.body.toJson().unmarshal()
  usecase(form)
  req.json(Http200, "ok")
