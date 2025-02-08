import std/sugar
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
    usecase.invoke(form.unmarshal())
    req.json(Http201, "ok")


proc newProductCreateController*(event: ProductSaveEvent): auto =
  proc(req: Request): auto =
    let form = req.body.toJson()
    let model = form.unmarshal()
    event(model)
    req.json(Http201, "ok")