import std/sugar
import std/times

type
  RentalApplicationEvent = ref object
  
  Input = string
  Output = string
  Workflow = (Input -> Output) -> void
  ExtensionApplyResult{.pure.} = enum
    Approve
    Reject

  CurrentState = ref object
    loanBegin: DateTime
  
  ExtensionUsecase = (CurrentState) -> ExtensionApplyResult


proc extension(a, b: DateTime): ExtensionApplyResult =
  let limit = a + initDuration(weeks = 2)
  if limit > b:
    ExtensionApplyResult.Approve
  else:
    ExtensionApplyResult.Reject

proc newExtensionUsecase(): ExtensionUsecase = 
  let duration = initDuration(weeks = 2)

  (currentState: CurrentState) => (
    let loanLimit = currentState.loanBegin + duration
    extension(loanLimit, times.now())
  )


when isMainModule:
  import std/unittest

  let usecase = newExtensionUsecase()
  let currentState = CurrentState(
    loanBegin: parse("2024-02-01", "yyyy-MM-dd")
  )
  let loanBegin = parse("2024-02-01", "yyyy-MM-dd")
  let loanLimit = parse("2024-02-01", "yyyy-MM-dd")
  let extensionResult = extension(loanBegin, loanLimit)

  check extensionResult == ExtensionApplyResult.Approve