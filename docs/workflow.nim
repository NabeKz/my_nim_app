import std/sugar
import std/macros

type
  ProductSearchForm = ref object
  ProductList = ref object

  SelectedProduct = ref object
  ProductDetail = ref object

  ShoppingCart = ref object
  ShoppingCartAddedItem = ref object

  Order = ref object
  OrderSearchForm = ref object


  UserRegisterForm = ref object
  User = ref object


  OrderList = ref object

  ReviewComment = ref object
  ProductDetailAddedReview = ref object

  ProductRegisterForm = ref object
  Product = ref object
  

  StockRegisterForm = ref object
  Stock = ref object

  QuestionForm = ref object
  AnsweredQuestion = ref object


  
proc workflow1(input: ProductSearchForm): ProductList =
  ProductList()

proc workflow2(input: SelectedProduct): ProductDetail =
  ProductDetail()

proc workflow3(input: ShoppingCart, product: SelectedProduct): ShoppingCartAddedItem =
  ShoppingCartAddedItem()

proc workflow4(input: ShoppingCart): Order =
  Order()

proc workflow5(input: UserRegisterForm): User =
  User()

proc workflow6(input: OrderSearchForm): OrderList =
  OrderList()

proc workflow7(input: ProductDetail, reviewComment: ReviewComment): ProductDetailAddedReview =
  ProductDetailAddedReview()

proc workflow8(form: ProductRegisterForm): Product =
  Product()

proc workflow9(form: StockRegisterForm): Stock =
  Stock()

proc workflow10(form: QuestionForm): AnsweredQuestion =
  AnsweredQuestion()


macro curry(fn: untyped): untyped = 
  let stmtList = fn.copyNimTree
  let params = fn[3]
  let body = fn[6]
  let returnType = params[0]
  # stmtList[3] = 
  debugEcho returnType.repr

  quote do:
    proc hoge(): `returnType` =
      discard




proc curry2(a: string, b: bool): int {.curry.} = 
  discard

discard hoge()
# StmtList
#   ProcDef
#     Ident "curry2"
#     Empty
#     Empty
#     FormalParams
#       Ident "int"
#       IdentDefs
#         Ident "a"
#         Ident "string"
#         Empty
#       IdentDefs
#         Ident "b"
#         Ident "bool"
#         Empty
#     Empty
#     Empty
#     StmtList
#       DiscardStmt
#         Empty