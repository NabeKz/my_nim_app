import std/json
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



proc invoke*(self: ProductFetchUsecase): seq[ProductReadModel] = 
  self.repository.list()


proc invoke*(self: ProductCreateUsecase, dto: ProductInputDto): void = 
  let model = dto
  self.repository.save(dto)
