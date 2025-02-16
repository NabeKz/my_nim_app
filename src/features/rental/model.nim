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

proc callback(dt: DateTime): ExtensionApplyResult =
  let currentState = CurrentState(loanBegin: dt)
  let duration = initDuration(weeks = 2)
  let loanLimit = currentState.loanBegin + duration
  let limit = loanLimit + initDuration(weeks = 2)
  if limit > times.now():
    ExtensionApplyResult.Approve
  else:
    ExtensionApplyResult.Reject


proc invoke(dto: CurrentStateInputDto): ExtensionApplyResult = 
  let dt = parseDate(dto.loanBegin)
  if dt.isNone():
    ExtensionApplyResult.Invalid
  else:
    dt.map(callback).get()

  

proc newExtensionUsecase*(): ExtensionUsecase = 
  (body: CurrentStateInputDto) => invoke(body)


when isMainModule:
  import std/unittest

  let usecase = newExtensionUsecase()
  let currentState = CurrentState(
    loanBegin: parse("2024-02-01", "yyyy-MM-dd")
  )
  let dto = CurrentStateInputDto(
    loanBegin: "2024-02-02"
  )
  let extensionResult = usecase(dto)

  check extensionResult == ExtensionApplyResult.Approve
