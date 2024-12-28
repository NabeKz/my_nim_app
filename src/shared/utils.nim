import std/macros
import std/sequtils

func findChildRec(node: seq[NimNode], kind: NimNodeKind): NimNode =
  for n in node:
    let child = findChild(n, it.kind == kind)
    if not child.isNil:
      return child
    if child.isNil and n.len > 0:
      return findChildRec(toSeq(n.children), kind)


func findChildRec*(node: NimNode, kind: NimNodeKind): NimNode =
  findChildRec(toSeq(node), kind)


func chain*(self: NimNode, nodes: varargs[NimNode]): NimNode =
  foldl(nodes, a.newDotExpr(b), self)