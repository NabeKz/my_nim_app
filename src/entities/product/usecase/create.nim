import std/sugar
import src/entities/product/domain/model

type
  ProductCreateUsecase* = (dto: ProductInputDto) -> seq[string]
  ProductInputDto* = ref object
    name*: string
    description*: string
    price*: uint32
    stock*: uint32


func validate(self: ProductInputDto): seq[string] =
  if self.name == "":
    result.add("name is required")


func to(self: ProductInputDto, _: type ProductWriteModel): ProductWriteModel =
  ProductWriteModel(
    name: self.name,
    description: self.description,
    price: self.price,
    stock: self.stock,
  )


proc newProductCreateUsecase*(command: ProductCreateCommand): ProductCreateUsecase =
  (dto: ProductInputDto) => (
    let errors = dto.validate()
    if errors.len > 0:
      return errors

    try:
      let model = to(dto, ProductWriteModel)
      command(model)
    except:
      let msg = getCurrentExceptionMsg()
      result.add(msg)
  )
