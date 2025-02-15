import std/asynchttpserver
import std/asyncdispatch
import std/json

import src/shared/port/http
import src/features/rental/model

type
  RentalController = ref object
    usecase: ExtensionUsecase



proc handleRequest(self: RentalController, body: string): (HttpCode, string) =
  let jsonNode = body.toJson()
  let currentState = to(jsonNode, CurrentStateInputDto)
  let res = self.usecase(currentState)
  case res
  of ExtensionApplyResult.Approve:
    (Http200, "ok")
  of ExtensionApplyResult.Invalid:
    (Http400, "ng")
  of ExtensionApplyResult.Reject:
    (Http409, "ng")
  
  
proc newRentalController(usecase: ExtensionUsecase): RentalController =
  RentalController(usecase: usecase)


when isMainModule:
  import std/unittest
  
  
  let controller = newRentalController(
    usecase = newExtensionUsecase()
  )

  let (status, content) = controller.handleRequest(
  """{ 
    "loanBegin": ""
  }"""
  )

  check status == Http409

