import std/sugar
import std/options
import src/entities/product/model

type
  ProductCreateUsecase* = ref object
    repository: ProductRepository

  ProductInputDto* = ref object
    name*: string
    description*: string
    price*: uint32
    stock*: uint32


func newProductCreateUsecase*(repository: ProductRepository): ProductCreateUsecase =
  ProductCreateUsecase(repository: repository)


proc invoke*(self: ProductCreateUsecase, dto: ProductInputDto): Option[seq[string]] = 
  let model = ProductWriteModel(
    name: dto.name,
    description: dto.description,
    price: dto.price,
    stock: dto.stock,
  )
  let errors = model.validate()
  if errors.len > 0:
    result = some(errors)
  else:
    self.repository.save(model)

