import std/json
import std/sugar


import ./model


type 
  CartFetchInputDto* = JsonNode
  CartFetchOutputDto* = JsonNode
  CartFetchUsecase* = proc(dto: CartFetchInputDto): CartFetchOutputDto {.gcsafe.}
  # CartFetchUsecase* = (dto: CartFetchInputDto) -> CartFetchOutputDto {.gcsafe}
  

func init*(_: type CartFetchUsecase, event: ShoppingCartFetchEvent): CartFetchUsecase = 
  (dto: CartFetchInputDto) => dto

# proc invoke*(self: CartFetchUsecaseImpl, dto: CartFetchInputDto): CartFetchOutputDto = 
#   let cart = newShoppingCart()
#   let items = @[
#     newProductItem(productId = 1, amount = 2),
#     newProductItem(productId = 2, amount = 3),
#   ]
#   %* cart.add(items)


type 
  CartItemAddUsecase* = concept x
    x.invoke(JsonNode) is bool
  CartItemAddUsecaseImpl* = proc(dto: ProductItemInputDto) {.gcsafe.}
  ProductItemInputDto* = ref object
    productId*: int
    amount*: int


func to(dto: ProductItemInputDto): ProductItem =
  newProductItem(
    productId = dto.productId.int64,
    amount = dto.amount.uint16
  )

proc init*(_: type CartItemAddUsecaseImpl, event: ShoppingCartAddEvent): CartItemAddUsecaseImpl = 
  proc(dto: ProductItemInputDto) {.gcsafe.} = 
    event dto.to() 

