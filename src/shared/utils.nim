import std/macros
import std/sequtils


macro `|>`*(lhs, rhs: untyped): untyped =
  case rhs.kind:
  of nnkIdent:
    result = newCall(rhs, lhs)
  else:
    result = rhs
    result.insert(1, lhs)

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


