import src/shared/db/conn
import ./model


type ShoppingCartQueryServiceSqlite* = ref object
  db: DbConn


func fetch*(self: ShoppingCartQueryServiceSqlite): ShoppingCart = 
  let cart = newShoppingCart()
  let items = @[
    newProductItem(productId = 1, amount = 2),
    newProductItem(productId = 2, amount = 3),
  ]
  cart.add(items)


func init*(_: type ShoppingCartQueryServiceSqlite, db: DbConn): ShoppingCartQueryService = 
  let repository = ShoppingCartQueryServiceSqlite(db: db)
  (
    fetch: proc(): ShoppingCart = repository.fetch()
  )


type 
  ShoppingCartRepositoryOnMemory* = ref object
    cart: seq[ProductItem]

func init*(_: type ShoppingCartRepositoryOnMemory): ShoppingCartRepositoryOnMemory =
  ShoppingCartRepositoryOnMemory(
    cart: newSeq[ProductItem]()
  )



proc save*(self: ShoppingCartRepositoryOnMemory, item: ProductItem) =
  self.cart.add(item)
