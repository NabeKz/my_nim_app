import std/json
import std/sugar


import ./model


type
  CartFetchInputDto* = JsonNode
  CartFetchOutputDto* = JsonNode
  CartFetchUsecase* = ((CartFetchInputDto){.gcsafe.} -> CartFetchOutputDto)

  ProductItemInputDto* = ref object
    productId*: int
    amount*: int
  CartAddUsecase* = ((ProductItemInputDto) -> void)


func to(dto: ProductItemInputDto, _: type ProductItem): ProductItem =
  newProductItem(
    productId = dto.productId.int64,
    amount = dto.amount.uint16
  )


proc newCartFetchUsecase*(command: ShoppingCartFetchEvent): CartFetchUsecase =
  (dto: CartFetchInputDto) => %* {}


proc newCartAddUsecase*(event: ShoppingCartAddEvent): CartAddUsecase =
  (dto: ProductItemInputDto) => (
    let data = to(dto, ProductItem)
    event(data)
  )
