import std/sugar

type
  ProductWriteModel* = ref object
    name*: string
    description*: string
    price*: uint32
    stock*: uint32

  ProductReadModel* = ref object
    id*: int64
    name*: string
    description*: string
    price*: uint32
    stock*: uint32

  ProductListCommand* = () -> seq[ProductReadModel]
  ProductCreateCommand* = (model: ProductWriteModel) -> void


func newProduct*(name: string, description: string, price: uint32,
    stock: uint32): ProductWriteModel =
  ProductWriteModel(
    name: name,
    description: description,
    price: price,
    stock: stock
  )
