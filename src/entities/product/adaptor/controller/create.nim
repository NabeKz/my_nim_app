import std/options
import std/sugar

import src/entities/product/usecase
import src/shared/handler
import src/shared/port/http

type ProductPostController* = ref object
  usecase: ProductCreateUsecase

type ProductPostControllerEvent* = ProductCreateUsecase -> (string{.gcsafe} -> (HttpCode, string))

      

generateUnmarshal(ProductInputDto)
proc build*(self: ProductPostController, body: string): (HttpCode, string) =
  let form = body.toJson()
  let model = form.unmarshal()
  let errors = self.usecase.invoke(model)
  if errors.isSome():
    let errorMsg = %* errors.get()
    (Http400, $errorMsg)
  else:
    (Http201, "ok")


proc newProductPostControllerEvent*(usecase: ProductCreateUsecase, body: string): (HttpCode, string) = 
  let form = body.toJson()
  let model = form.unmarshal()
  let data = "ok"
  (Http201, data)
