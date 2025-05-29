import std/strutils
import std/sequtils
import std/tables


type
  ValidateError* = ref object of ValueError
    errors*: seq[string]

proc parseParams*(params: string): Table[string, string] =
  params
    .split("&")
    .mapIt(it.split("=", 1))
    .mapIt((it[0], it[1]))
    .toTable()

template check*(reqBody: string, build, validate: untyped): untyped =
  let model{.inject.} = parseParams(reqBody).build()
  var errors{.inject.} = newSeqOfCap[string](50)

  validate

  if errors.len > 0:
    raise ValidateError(errors: errors)
  else:
    model
