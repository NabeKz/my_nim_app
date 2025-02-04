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


type 
  CartItemAddUsecase* = proc(dto: ProductItemInputDto) {.gcsafe.}
  ProductItemInputDto* = ref object
    productId*: int
    amount*: int


func to(dto: ProductItemInputDto): ProductItem =
  newProductItem(
    productId = dto.productId.int64,
    amount = dto.amount.uint16
  )

proc init*(_: type CartItemAddUsecase, event: ShoppingCartAddEvent): CartItemAddUsecase = 
  proc(dto: ProductItemInputDto) {.gcsafe.} = 
    event dto.to() 

