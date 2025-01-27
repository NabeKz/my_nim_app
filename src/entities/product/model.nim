import src/shared/port/model

type ProductWriteModel* = ref object of RootObj
  name*: string
  description*: string
  price*: uint16
  stock*: uint16


type ProductReadModel* = ref object of RootObj
  id*: int64
  name*: string
  description*: string
  price*: uint16
  stock*: uint16


generateValidation(ProductWriteModel)


type ProductRepository* = tuple
  list: proc(): seq[ProductReadModel]{.gcsafe.}
  save: proc(): void{.gcsafe.}


func newProduct*(name: string, description: string, price: uint16, stock: uint16): ProductWriteModel =
  ProductWriteModel(
    name: name,
    description: description,
    price: price,
    stock: stock
  )
