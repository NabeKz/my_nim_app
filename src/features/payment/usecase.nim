##  context payment
##  input:
##    - Cart
##  output:
##    - Unit
##    - Error
##  dependency:
##    - PaymentMethod
##  workflow:
##    - getCart
##    - selectDeliveryPoint
##    - selectPaymentMethod
##    - submitPayment
##
type

  Cart = ref object

  DeliveryPoint = ref object
    address: string

  PaymentMethod = enum
    Card
    Bank

  Order = ref object
    items: seq[string]

  PaymentInformation = ref object
    deliveryPoint: DeliveryPoint
    paymentMethod: PaymentMethod
    order: Order

proc getCart(): Cart =
  discard

proc selectDeliveryPoint(cart: Cart, deliveryPoint: DeliveryPoint): Cart =
  discard

proc selectPaymentMethod(cart: Cart, paymentMethod: PaymentMethod): Cart =
  discard

proc submitPayment(cart: Cart, paymentMethod: PaymentMethod): void =
  discard
