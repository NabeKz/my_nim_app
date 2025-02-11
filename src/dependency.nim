import std/asyncdispatch
import std/asynchttpserver

import src/entities/product/adaptor/controller/[create]
import src/entities/product/adaptor/repository/[on_memory]
import src/entities/product/[usecase, model]


type Dependency* = ref object
  productController: ProductPostController

const productRepository = newProductRepository()

proc inject*(
  productRepository: ProductRepository
): auto = newProductCreateController(
  newProductCreateUsecase(
    productRepository
  )
)