import src/entities/product/adaptor/repository/on_memory
import src/entities/product/adaptor/controller/[list, create]
import src/entities/product/usecase/[list, create]

type 
  Dependency* = ref object
    productListController*: ProductListController
    productPostController*: ProductPostController
  
proc newDependency*(): Dependency =
  let productRepository = newProductRepositoryOnMemory()

  Dependency(
    productListController:
      productRepository.listCommand.
      newProductListUsecase().
      newProductListController(),
    productPostController:
      productRepository.saveCommand.
      newProductCreateUsecase().
      newProductPostController(),
  )