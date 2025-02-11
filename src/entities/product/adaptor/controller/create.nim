import std/sugar

import src/entities/product/usecase/create
import src/shared/handler

type ProductPostController* = Handler

proc newProductPostController*(usecase: ProductCreateUsecase): ProductPostController = 
  ProductPostController (
    (req: Request) => (
      req.json(Http201)
    )
  )
