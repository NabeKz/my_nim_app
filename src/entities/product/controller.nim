import std/sugar
import std/options

import src/entities/product/usecase

import src/shared/handler
import src/shared/port/http

proc newProductListController*(usecase: ProductFetchUsecase): auto =
  let data = usecase.invoke()
  (req: Request) => req.json(Http200, data)


proc newProductListController*(event: ProductFetchListEvent): auto =
  let data = event()
  (req: Request) => req.json(Http200, data)


generateUnmarshal(ProductInputDto)
proc newProductCreateController*(usecase: ProductCreateUsecase): auto =
  proc(req: Request): auto =
    let form = req.body.toJson()
    let errors = usecase.invoke(form.unmarshal())
    if errors.isSome():
      req.json(Http400, $errors.get())
    else:
      req.json(Http201, "ok")


func validate(model: ProductInputDto): seq[string] = 
  @[]

proc newProductCreateController*(event: ProductSaveEvent): auto =
  proc(req: Request): auto =
    let form = req.body.toJson()
    let model = form.unmarshal()
    if (model.validate().len > 0):
      req.json(Http400, "errors")
    else:
      event(model)
      req.json(Http201, "ok")