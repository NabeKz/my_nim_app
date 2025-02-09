import std/sugar
import std/options

import src/entities/product/[usecase, model]

import src/shared/handler
import src/shared/port/http

type ProductPostController* = ref object
  usecase: ProductCreateUsecase


proc newProductListController*(usecase: ProductFetchUsecase): auto =
  let data = usecase.invoke()
  (req: Request) => req.json(Http200, data)


proc newProductListController*(event: ProductFetchListEvent): auto =
  let data = event()
  (req: Request) => req.json(Http200, data)


proc newProductCreateController*(usecase: ProductCreateUsecase): auto =
  ProductPostController(usecase: usecase)
      

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
