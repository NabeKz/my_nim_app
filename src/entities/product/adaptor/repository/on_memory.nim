import std/sugar
import src/entities/product/domain/model


type
  ProductRepositoryOnMemory* = ref object
    products: seq[ProductReadModel]


func newProductRepositoryOnMemory*(): ProductRepositoryOnMemory =
  let product = @[
    ProductReadModel(
      id: 1,
      name: "sample",
      description: "aaa",
      price: 1,
      stock: 1
    ),
    ProductReadModel(
      id: 2,
      name: "sample",
      description: "aaa",
      price: 1,
      stock: 1
    ),
  ]
  ProductRepositoryOnMemory(products: product)


proc list(self: ProductRepositoryOnMemory): seq[ProductReadModel] = 
  self.products


proc save(self: ProductRepositoryOnMemory, model: ProductWriteModel): void = 
  let id = self.products.len + 1
  let product = ProductReadModel(
    id: id,
    name: model.name,
    description: model.description,
    price: model.price,
    stock: model.stock,
  )
  self.products.add(product)


proc listCommand*(self: ProductRepositoryOnMemory): ProductListCommand =
  let repository = newProductRepositoryOnMemory()
  () => repository.list()

proc saveCommand*(self: ProductRepositoryOnMemory): ProductCreateCommand =
  let repository = newProductRepositoryOnMemory()
  (model: ProductWriteModel) => repository.save(model)