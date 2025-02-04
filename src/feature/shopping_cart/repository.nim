import std/sugar

import src/shared/db/conn
import ./model


type
  ShoppingCartQueryServiceSqlite* = ref object
    db: DbConn

  ShoppingCartRepositoryOnMemory* = ref object
    cart: seq[ProductItem]


func init*(_: type ShoppingCartQueryServiceSqlite, db: DbConn): ShoppingCartQueryServiceSqlite = 
  ShoppingCartQueryServiceSqlite(db: db)


proc fetch*(self: ShoppingCartQueryServiceSqlite, model: ShoppingCart): ShoppingCart = 
  let jsonNode = self.db.take(ShoppingCart())
  to(jsonNode, ShoppingCart)


proc fetch*(self: ShoppingCartQueryServiceSqlite): ShoppingFetchEvent = 
  (model: ShoppingCart) => self.fetch(model)
  




func init*(_: type ShoppingCartRepositoryOnMemory): ShoppingCartRepositoryOnMemory =
  ShoppingCartRepositoryOnMemory(
    cart: newSeq[ProductItem]()
  )



proc save*(self: ShoppingCartRepositoryOnMemory, item: ProductItem) =
  self.cart.add(item)


proc save*(self: ShoppingCartRepositoryOnMemory): ShoppingCartAddEvent =
  (item: ProductItem) => self.cart.add(item)
