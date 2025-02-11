import std/sugar
import src/entities/product/domain/model

type
  ProductListUsecase* = () -> seq[ProductReadModel]


proc newProductListUsecase*(): ProductListUsecase = 
  let data = @[
    ProductReadModel(name: "name")
  ]
  () => data


proc newProductListUsecase*(event: ProductListCommand): ProductListUsecase = 
  let data = event()
  () => data
