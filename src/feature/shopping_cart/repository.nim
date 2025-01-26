import ./model


type ShoppingCartQueryServiceSqlite* = ref object


func fetch*(self: ShoppingCartQueryServiceSqlite): ShoppingCart = 
  let cart = newShoppingCart()
  let items = @[
    newProductItem(productId = 1, amount = 2),
    newProductItem(productId = 2, amount = 3),
  ]
  cart.add(items)


func init*(_: type ShoppingCartQueryServiceSqlite): ShoppingCartQueryService = 
  (
    fetch: proc(): ShoppingCart = ShoppingCartQueryServiceSqlite().fetch()
  )
  