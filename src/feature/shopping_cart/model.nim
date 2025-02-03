import std/sugar

type ProductItem* = ref object 
  productId: int64
  amount: uint16


func productId*(self: ProductItem): int64 = self.productId
func amount*(self: ProductItem): uint16 = self.amount


type 
  ShoppingCart* = ref object of RootObj
    productItems: seq[ProductItem]
 
  ShoppingCartQueryService* = tuple
    fetch: proc(): ShoppingCart{.gcsafe.}
  ShoppingCartAddEvent* = ((ProductItem){.gcsafe.} -> void)


func newProductItem*(productId: int64, amount: uint16): ProductItem =
  ProductItem(
    productId: productId,
    amount: amount,
  )

func newShoppingCart*(): ShoppingCart = 
  ShoppingCart(productItems: @[])


func add*(self: ShoppingCart, item: ProductItem): ShoppingCart = 
  ShoppingCart(
    productItems: self.productItems & item
  )

func add*(self: ShoppingCart, items: seq[ProductItem]): ShoppingCart = 
  ShoppingCart(
    productItems: self.productItems & items
  )

func getItems*(self: ShoppingCart): seq[ProductItem] = 
  self.productItems
