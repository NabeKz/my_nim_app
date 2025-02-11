import std/sugar
import src/shared/port/model
import src/shared/port/validation_rules
import src/shared/utils

import std/json
import std/asynchttpserver
import std/asyncdispatch

type ProductWriteModel* = ref object
  name*: string
  description*: string
  price*: uint32
  stock*: uint32


type ProductReadModel* = ref object
  id*: int64
  name*: string
  description*: string
  price*: uint32
  stock*: uint32


func newProduct*(name: string, description: string, price: uint32, stock: uint32): ProductWriteModel =
  ProductWriteModel(
    name: name,
    description: description,
    price: price,
    stock: stock
  )


type
  Handler* = (Request{.gcsafe.} -> Future[void])
  ListQuery* = () -> seq[ProductReadModel]


proc usecase*(): ListQuery = 
  () => @[
    ProductReadModel(name: "name")
  ]


proc invoke*[T](usecase: () -> T): T = usecase()


proc controller*(usecase: ListQuery): Handler = 
  let data = usecase.invoke()
  let jsonNode = % data
  (req: Request) => req.respond(Http200, $jsonNode)