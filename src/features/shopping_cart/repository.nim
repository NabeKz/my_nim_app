import std/sugar

import src/shared/db/conn
import src/features/shopping_cart/model


type
  ShoppingCartQueryServiceSqlite* = ref object
    db: DbConn

  ShoppingCartRepositoryOnMemory* = ref object
    cart: ShoppingCart


func init*(_: type ShoppingCartQueryServiceSqlite,
    db: DbConn): ShoppingCartQueryServiceSqlite =
  ShoppingCartQueryServiceSqlite(db: db)



proc newShoppingCartRepositoryOnMemory*(): ShoppingCartRepositoryOnMemory =
  ShoppingCartRepositoryOnMemory(cart: newShoppingCart())



proc fetchCommand*(self: ShoppingCartRepositoryOnMemory): ShoppingCartFetchEvent =
  () => self.cart


proc saveCommand*(self: ShoppingCartRepositoryOnMemory): ShoppingCartAddEvent =
  (item: ProductItem) => (
    self.cart = self.cart.add(item)
  )
