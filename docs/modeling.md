data UserAccount

data UserSecret


data Order


data Coupon = 
  id: uuid4
  discount: number between 1 ~ 100



data  Product = 
  id: uuid4
  name: string 50 degit



data PaymentMethod = 
  Credit
  or BankTransfer
  or PaymentOnDelivery


data CartItem = 
  productId: uuid4
  amount: number 1 between 10

data ShoppingCart = 
  products: product of list