import std/macros

type WriteModel* = concept x
  x.tableName() is string

type ReadModel* = concept x
  x.tableName() is string
  x.id is int64

type ResultKind{.pure.} = enum
  kOk, kErr

type Result*[T] = ref object
  case kind: ResultKind
  of kOk:
    val: T
  of kErr:
    err: seq[string]

macro match*(value, body: untyped): untyped =
  expectLen(body, 2)

  quote do:
    var res = `value`
    template Ok (okName, okBody: untyped): untyped =
      proc okProc (okName: auto) =
        okBody
      if res.kind == ResultKind.kOk:
        okProc(res.ok)
    template Err (errName, errBody: untyped): untyped =
      proc errProc (errName: auto) =
        errBody
      if res.kind == ResultKind.kErr:
        errProc(res.err)
    `body`
