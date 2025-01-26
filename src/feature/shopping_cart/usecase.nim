import std/json
import std/sugar
import ./model


type 
  CartFetchUsecaseImpl*  = ref object
  CartFetchOutputDto = JsonNode
  CartFetchUsecase* = proc(): CartFetchOutputDto{.gcsafe.}
    

proc invoke*(_: type CartFetchUsecaseImpl): CartFetchUsecase = 
  proc(): CartFetchOutputDto =
    let cart = newShoppingCart()
    let items = @[
      newProductItem(productId = 1, amount = 2),
      newProductItem(productId = 2, amount = 3),
    ]
    %* cart.add(items)


type 
  CartItemAddUsecase* = concept x
    x.invoke(JsonNode) is ProductItemOutputDto
  CartItemAddUsecaseImpl* = ref object
  ProductItemOutputDto = JsonNode


proc invoke*(self: CartItemAddUsecaseImpl, jsonNode: JsonNode): ProductItemOutputDto = 
  let cart = newShoppingCart()
  let item = newProductItem(productId = 1, amount = 2)
  %* cart.add(item)
