import src/shared/db/conn
import src/entities/product/domain/[model, repository]


type ProductRepositoryOnSqlite* = ref object of ProductRepository
  db: DbConn


func newProductRepositoryOnSqlite(db: DbConn): ProductRepositoryOnSqlite =
  ProductRepositoryOnSqlite(db: db)

method list*(self: ProductRepositoryOnSqlite): void =
  discard

method save*(self: ProductRepositoryOnSqlite, model: ProductWriteModel): void =
  discard


func newProductRepository*(db: DbConn): ProductRepositoryOnSqlite =
  newProductRepositoryOnSqlite(db)
