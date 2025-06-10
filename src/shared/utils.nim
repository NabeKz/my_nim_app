import std/macros
import std/sequtils


macro `|>`*(lhs, rhs: untyped): untyped =
  case rhs.kind:
  of nnkIdent:
    result = newCall(lhs, rhs)
  else:
    result = lhs
    result.insert(1, rhs)

type ResultKind = enum
  kOk, kErr

type Result*[T, U] = ref object
  case kind: ResultKind
  of kOk:
    val: T
  of kErr:
    err: U

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


func findChildRec(node: seq[NimNode], kind: NimNodeKind): NimNode =
  for i, n in node:
    let child = findChild(n, it.kind == kind)
    if not child.isNil:
      result = child
    if child.isNil and n.len > 0:
      result = findChildRec(toSeq(n.children), kind)
      if result.isNil and i < node.len:
        result = findChildRec(toSeq(node[(i+1)..^1]), kind)



func findChildRec*(node: NimNode, kind: NimNodeKind): NimNode =
  findChildRec(toSeq(node), kind)


func chain*(self: NimNode, nodes: varargs[NimNode]): NimNode =
  foldl(nodes, a.newDotExpr(b), self)


template build*(db, controller, usecase, repository: untyped): untyped =
  proc(req: Request): Future[void] =
    let u = usecase.init repository.init(db)
    controller.run(u, req)


template findIndexIt*(s, pred: untyped): int =
  ## Returns the index of the first item in sequence `s` that fulfills the
  ## predicate `pred`, or -1 if no item is found.
  ##
  ## The predicate needs to be an expression using the `it` variable
  ## for testing, like: `findIndexIt(@[1, 2, 3], it > 2)`.
  ##
  ## Based on `filterIt` from sequtils.
  var result = -1
  for i in 0..<s.len:
    let it {.inject.} = s[i]
    if pred:
      result = i
      break
  result