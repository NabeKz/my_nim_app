import std/options
import src/entities/product/model

type
  ProductFetchUsecase* = ref object of RootObj
    repository: ProductRepository

  ProductCreateUsecase* = ref object of RootObj
    repository: ProductRepository

  ProductFetchListEvent* = proc(): seq[ProductReadModel]{.gcsafe.}
  ProductSaveEvent* = proc(model: ProductWriteModel): void{.gcsafe.}
  ProductInputDto* = ProductWriteModel


func newProductFetchUsecase*(repository: ProductRepository): ProductFetchUsecase =
  ProductFetchUsecase(repository: repository)

func newProductCreateUsecase*(repository: ProductRepository): ProductCreateUsecase =
  ProductCreateUsecase(repository: repository)



proc invoke*(self: ProductFetchUsecase): seq[ProductReadModel] = 
  self.repository.list()


proc invoke*(self: ProductCreateUsecase, dto: ProductInputDto): Option[seq[string]] = 
  let errors = dto.validate()
  if errors.len > 0:
    result = some(errors)
  else:
    self.repository.save(dto)
