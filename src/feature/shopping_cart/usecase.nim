import std/json
import std/sugar
import src/entities/product/model
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
  CartItemAddUsecaseImpl* = ref object
    repository: ProductRepository
  ProductItemInputDto* = ref object
    productId*: int
    amount*: int


func init*(_: type CartItemAddUsecaseImpl, queryService: ShoppingCartQueryService): CartItemAddUsecaseImpl = 
  CartItemAddUsecaseImpl(queryService: queryService)

proc invoke*(self: CartItemAddUsecaseImpl, dto: ProductItemInputDto): bool = 
  let item = newProductItem(productId = 1, amount = 2)
  true
