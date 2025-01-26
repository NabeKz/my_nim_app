import ./model


type ShoppingCartQueryServiceSqlite = ref object


func fetch*(): ShoppingCart = 
  let cart = newShoppingCart()
  let items = @[
    newProductItem(productId = 1, amount = 2),
    newProductItem(productId = 2, amount = 3),
  ]
  cart.add(items)


# func toInterface(): ShoppingCartQueryService = 
#   ShoppingCartQueryService(fetch: fetch)

func newShoppingCartQueryService*(self: ShoppingCartQueryServiceSqlite): ShoppingCartQueryService = 
  (fetch: self.fetch)