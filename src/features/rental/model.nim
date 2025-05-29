import std/times
import std/options

type
  ExtensionApplyResult*{.pure.} = enum
    InvalidDate
    Approve
    Reject

  CurrentState* = ref object
    loanBegin: DateTime

  CurrentStateInputDto* = ref object
    loanBegin*: string

  RentalRepository* = ref object of RootObj

  ExtensionUsecase* = ref object
    repository: RentalRepository


method find*(self: RentalRepository): CurrentState{.base.} =
  discard

proc parseDate(value: string): Option[DateTime] =
  try:
    let dt = parse(value, "yyyy-MM-dd")
    some(dt)
  except TimeParseError:
    none(DateTime)


proc newCurrentState*(value: string): Option[CurrentState] =
  let dt = parseDate(value)
  if dt.isNone():
    none(CurrentState)
  else:
    let state = CurrentState(loanBegin: dt.get())
    some(state)


proc callback(dt: DateTime): ExtensionApplyResult =
  let currentState = CurrentState(loanBegin: dt)
  let duration = initDuration(weeks = 2)
  let loanLimit = currentState.loanBegin + duration
  let limit = loanLimit + initDuration(weeks = 2)
  if limit > times.now():
    ExtensionApplyResult.Approve
  else:
    ExtensionApplyResult.Reject


proc invoke*(self: ExtensionUsecase, dto: CurrentStateInputDto): ExtensionApplyResult =
  let dt = parseDate(dto.loanBegin)
  if dt.isNone():
    ExtensionApplyResult.InvalidDate
  else:
    dt.map(callback).get()



proc newExtensionUsecase*(repository: RentalRepository): ExtensionUsecase =
  ExtensionUsecase(repository: repository)


when isMainModule:
  import std/unittest
  # let usecase = newExtensionUsecase()
  # let currentState = CurrentState(
  #   loanBegin: parse("2024-02-01", "yyyy-MM-dd")
  # )
  # let dto = CurrentStateInputDto(
  #   loanBegin: "2024-02-02"
  # )
  # let extensionResult = usecase.invoke(dto)

  # check extensionResult == ExtensionApplyResult.Approve
