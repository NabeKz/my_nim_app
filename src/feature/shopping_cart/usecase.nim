import std/json
import ./model


type 
  CartFetchUsecase* = concept x
    x.invoke() is CartFetchOutputDto
  CartFetchUsecaseImpl*  = ref object
  CartFetchOutputDto = JsonNode
    

proc invoke*(self: CartFetchUsecaseImpl): CartFetchOutputDto = 
    let cart = newShoppingCart()
    let items = @[
      newProductItem(productId = 1, amount = 2),
      newProductItem(productId = 2, amount = 3),
    ]
    %* cart.add(items)


type CartItemAddUsecase* = concept x
  x.invoke(jsonNode: JsonNode) is ShoppingCart

type CartItemAddUsecaseImpl* = ref object


type ProductItemOutputDto = ref object
  productId: int64
  amount: uint16


type ShoppingCartOutputDto = ref object
  items: seq[ProductItemOutputDto]




func invoke*(self: CartItemAddUsecaseImpl, jsonNode: JsonNode): ShoppingCart = 
  let cart = newShoppingCart()
  let item = newProductItem(productId = 1, amount = 2)
  cart.add(item)

