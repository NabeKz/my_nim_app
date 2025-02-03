import std/json


import src/shared/utils
import ./model


type 
  CartFetchUsecase* = concept x
    x.invoke(CartFetchInputDto) is CartFetchOutputDto
  CartFetchUsecaseImpl*  = ref object
    queryService: ShoppingCartQueryService
  CartFetchInputDto* = JsonNode
  CartFetchOutputDto* = JsonNode
  

func init*(_: type CartFetchUsecaseImpl, queryService: ShoppingCartQueryService): CartFetchUsecaseImpl = 
  CartFetchUsecaseImpl(queryService: queryService)

proc invoke*(self: CartFetchUsecaseImpl, dto: CartFetchInputDto): CartFetchOutputDto = 
  let cart = newShoppingCart()
  let items = @[
    newProductItem(productId = 1, amount = 2),
    newProductItem(productId = 2, amount = 3),
  ]
  %* cart.add(items)


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

