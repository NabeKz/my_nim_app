import std/macros
import std/sequtils

func findChildRec(node: seq[NimNode], kind: NimNodeKind): NimNode =
  for i, n in node:
    let child = findChild(n, it.kind == kind)
    if not child.isNil:
      result = child
    if child.isNil and n.len > 0:
      result = findChildRec(toSeq(n.children), kind)
      if result.isNil and i < node.len:
        result = findChildRec(toSeq(node[i..^1]), kind)



func findChildRec*(node: NimNode, kind: NimNodeKind): NimNode =
  findChildRec(toSeq(node), kind)


func chain*(self: NimNode, nodes: varargs[NimNode]): NimNode =
  foldl(nodes, a.newDotExpr(b), self)