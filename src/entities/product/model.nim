import src/shared/port/model

type Product* = ref object of RootObj
  name*: string
  description*: string
  price*: uint16
  stock*: uint16


type ProductRecord* = ref object of RootObj
  id*: int64
  name*: string
  description*: string
  price*: uint16
  stock*: uint16


generateValidation(Product)


type ProductRepository* = tuple
  list: proc(): seq[Product]
  save: proc(): seq[Product]


func newProduct*(name: string, description: string, price: uint16, stock: uint16): Product =
  Product(
    name: name,
    description: description,
    price: price,
    stock: stock
  )
