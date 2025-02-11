import src/entities/product/adaptor/repository/on_memory
import src/entities/product/adaptor/controller/[list, create]
import src/entities/product/usecase/[list, create]

import src/features/shopping_cart/[usecase, controller, repository]

type 
  Dependency* = ref object
    productListController*: ProductListController
    productPostController*: ProductPostController
    shoppingCartGetController*: ShoppingCartGetController
    shoppingCartPostController*: ShoppingCartPostController
  
proc newDependency*(): Dependency =
  let productRepository = newProductRepositoryOnMemory()
  let shoppingCartRepository = newShoppingCartRepositoryOnMemory()

  Dependency(
    productListController:
      productRepository.listCommand().
      newProductListUsecase().
      newProductListController(),
    
    productPostController:
      productRepository.saveCommand().
      newProductCreateUsecase().
      newProductPostController(),
    
    shoppingCartGetController:
      shoppingCartRepository.fetchCommand().
      newCartFetchUsecase().
      newShoppingCartGetController(),

    shoppingCartPostController:
      shoppingCartRepository.saveCommand().
      newCartAddUsecase().
      newShoppingCartPostController(),
  )