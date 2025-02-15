import std/sugar
import std/times
import std/options

type
  
  ExtensionApplyResult*{.pure.} = enum
    Invalid
    Approve
    Reject

  CurrentState* = ref object
    loanBegin: DateTime

  CurrentStateInputDto* = ref object
    loanBegin*: string

  
  ExtensionUsecase* = (CurrentStateInputDto) -> ExtensionApplyResult


proc parseDate(value: string): Option[DateTime] = 
  try:
    let dt = parse(value, "yyyy-MM-dd")
    some(dt)
  except TimeParseError:
    none(DateTime)


proc invoke(dto: CurrentStateInputDto): ExtensionApplyResult = 
  let dt = parseDate(dto.loanBegin)
  if dt.isNone():
    return ExtensionApplyResult.Invalid
  
  let currentState = CurrentState(loanBegin: dt.get())
  let duration = initDuration(weeks = 2)
  let loanLimit = currentState.loanBegin + duration
  let limit = loanLimit + initDuration(weeks = 2)
  if limit > times.now():
    ExtensionApplyResult.Approve
  else:
    ExtensionApplyResult.Reject

  

proc newExtensionUsecase*(): ExtensionUsecase = 
  (body: CurrentStateInputDto) => invoke(body)


when isMainModule:
  import std/unittest

  let usecase = newExtensionUsecase()
  let currentState = CurrentState(
    loanBegin: parse("2024-02-01", "yyyy-MM-dd")
  )
  let dto = CurrentStateInputDto(
    loanBegin*: "2024-02-01"
  )
  let extensionResult = usecase.invoke(dto)

  check extensionResult == ExtensionApplyResult.Approve