import src/entities/product/adaptor/repository/on_memory
import src/entities/product/adaptor/controller/[list, create]
import src/entities/product/usecase/[list, create]

import src/features/shopping_cart/[usecase, controller, repository]
import src/features/information/[list, adaptor/repository/on_memory]
import src/features/rental/model
import src/features/rental/infrastructure/[http/rental_controller,
    repository/on_memory]

type
  Dependency* = ref object
    productListController*: ProductListController
    productPostController*: ProductPostController
    shoppingCartGetController*: ShoppingCartGetController
    shoppingCartPostController*: ShoppingCartPostController
    informationListController*: InformationListController
    rentalController*: RentalController

proc newDependency*(): Dependency =
  let productRepository = newProductRepositoryOnMemory()
  let shoppingCartRepository = newShoppingCartRepositoryOnMemory()
  let informationRepository = newInformationRepositoryOnMemory()
  let rentalRepositoryOnMemory = newRentalRepositoryOnMemory()

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

    informationListController:
    informationRepository.listCommand().
    newInformationFetchListUsecase().
    newInformationListController(),

    rentalController:
    newRentalRepositoryOnMemory().
    newExtensionUsecase().
    newRentalController(),
  )
