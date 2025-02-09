import src/shared/port/model
import src/shared/port/validation_rules

type ProductWriteModel* = ref object
  name*{.required max(50).}: string
  description*: string
  price*{.between(0, 9_999_999).}: uint32
  stock*{.between(0, 9_999_999).}: uint32


type ProductReadModel* = ref object
  id*: int64
  name*: string
  description*: string
  price*: uint32
  stock*: uint32


generateValidation(ProductWriteModel)


type
  ProductRepository* = tuple
    list: proc(): seq[ProductReadModel]{.gcsafe.}
    save: proc(model: ProductWriteModel): void{.gcsafe.}
    

func newProduct*(name: string, description: string, price: uint32, stock: uint32): ProductWriteModel =
  ProductWriteModel(
    name: name,
    description: description,
    price: price,
    stock: stock
  )
