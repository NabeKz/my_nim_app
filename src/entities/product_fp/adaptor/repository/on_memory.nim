import src/entities/product/domain/[model, repository]


type
  ProductRepositoryOnMemory* = ref object of ProductRepository
    products: seq[ProductReadModel]


func newProductRepositoryOnMemory(): ProductRepositoryOnMemory =
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


method list*(self: ProductRepositoryOnMemory): seq[ProductReadModel] = 
  self.products


method save*(self: ProductRepositoryOnMemory, model: ProductWriteModel): void = 
  let id = self.products.len + 1
  let product = ProductReadModel(
    id: id,
    name: model.name,
    description: model.description,
    price: model.price,
    stock: model.stock,
  )
  self.products.add(product)


func newProductRepository*(): ProductRepository =
  newProductRepositoryOnMemory()