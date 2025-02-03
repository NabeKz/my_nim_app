type ProductItem* = ref object 
  productId: int64
  amount: uint16


func productId*(self: ProductItem): int64 = self.productId
func amount*(self: ProductItem): uint16 = self.amount


type ShoppingCart* = ref object of RootObj
  productItems: seq[ProductItem]


type 
  ShoppingCartQueryService* = tuple
    fetch: proc(): ShoppingCart{.gcsafe.}
  ShoppingCartRepository* = concept x
    x.save(ProductItem)


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


when isMainModule:
  import std/unittest
  import src/shared/port/model
  
  # let cart1 = newShoppingCart()
  # check cart1.productItems.len == 0

  # let item = ProductItem(productId: 1, amount: 2)
  # let cart2 = cart1.add(item)
  # check cart2.productItems.len == 1
  # check cart1.productItems.len == 0
  
  # echo cart2.getItems()[0].repr

  autoMigrate(ShoppingCart)