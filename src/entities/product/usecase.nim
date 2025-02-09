import std/options
import src/entities/product/model

type
  ProductFetchUsecase* = ref object of RootObj
    repository: ProductRepository

  ProductCreateUsecase* = ref object of RootObj
    repository: ProductRepository

  ProductFetchListEvent* = proc(): seq[ProductReadModel]{.gcsafe.}
  ProductSaveEvent* = proc(model: ProductWriteModel): void{.gcsafe.}
  ProductInputDto* = ref object
    name*: string
    description*: string
    price*: uint32
    stock*: uint32


func newProductFetchUsecase*(repository: ProductRepository): ProductFetchUsecase =
  ProductFetchUsecase(repository: repository)

func newProductCreateUsecase*(repository: ProductRepository): ProductCreateUsecase =
  ProductCreateUsecase(repository: repository)



proc invoke*(self: ProductFetchUsecase): seq[ProductReadModel] = 
  self.repository.list()


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

