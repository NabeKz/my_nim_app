const TEMPLATE = """
Bounded content: Order-Taking

Workflow: "Place Order"
  triggered by:
    "Order form received" event (when Quote is not checked)
  primary input:
    An Order form
  other events:
    "Order Placed" event
  side-effects:
    An acknowledgement is sent to the customer,
    along with the placed order

data Order =
  CustomerInfo
  AND ShippingAddress
  AND BillingAddress
  AND list of OrderLines
  AND AmountToBill
"""

when isMainModule:
  echo TEMPLATE
