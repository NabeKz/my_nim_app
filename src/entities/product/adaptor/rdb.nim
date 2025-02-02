import src/shared/db/conn

type ProductRepositoryOnSqlite* = ref object
  db: DbConn


func init*(_: type ProductRepositoryOnSqlite, db: DbConn): ProductRepositoryOnSqlite =
  ProductRepositoryOnSqlite(db: db)

func save*(self: ProductRepositoryOnSqlite): void =
  discard