import std/macros
import std/sequtils
import std/strutils
import std/strformat

type
  Pragma = object
    name: string
    call: string
    params: string
  
  Field = object
    name: string
    pragmas: seq[Pragma]


func newPragma(node: NimNode): Pragma{.compileTime.} = 
  if node.kind == nnkSym:
    let name, call = node.repr
    result = Pragma(name: name, call: call)
  if node.kind == nnkCall:
    let params = node[1..^1].mapIt(it.repr).join(",")
    result = Pragma(name: node[0].repr, call: node.repr, params: params)


func findChildRec(node: seq[NimNode], kind: NimNodeKind): NimNode = 
  for n in node:
    let child = findChild(n, it.kind == kind)
    if not child.isNil:
      return child
    if child.isNil and n.len > 0:
      return findChildRec(toSeq(n.children), kind)


func findChildRec(node: NimNode, kind: NimNodeKind): NimNode = 
  findChildRec(toSeq(node), kind)


func getNameField(n: NimNode): NimNode =
  case n.kind:
  of nnkIdentDefs: 
    getNameField(n[0])
  of nnkIdent:
    n
  of nnkPostfix:
    n[1]
  of nnkPragmaExpr:
    getNameField(n[0])
  else:
    nil

func newField(identDefs: NimNode): Field{.compileTime.}  = 
  let name = getNameField(identDefs)
  let pragmaNode = findChildRec(identDefs, nnkPragma)
  let pragmas = toSeq(pragmaNode.children).mapIt(newPragma it)
  Field(name: name.repr, pragmas: pragmas)


macro generateValidation*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  let fields = toSeq(recList.children).mapIt(newField(it))

  var stmtList = newStmtList()
  for field in fields:
    for pragma in field.pragmas:
      let fn = &"""
      if not self.{field.name}.{pragma.call}:
        result.add ValidationMessage.{pragma.name}("{field.name}", {pragma.params})
      """
      stmtList.add parseStmt(fn)
  let self = ident("self")
  let t = ident($t)
  quote do:
    func validate*(`self`: `t`): seq[string] =
      `stmtList`

when isMainModule:
  import std/unittest
  import src/validation/rules

  type User = ref object
    name{.required, minmax(1, 2).}: string

  generateValidation(User)

  check User().validate() == @["name is required", "name\'s len must be between 1 and 2"]

# StmtList
#   TypeSection
#     TypeDef
#       Ident "User"
#       Empty
#       RefTy
#         ObjectTy
#           Empty
#           Empty
#           RecList
#             IdentDefs
#               PragmaExpr
#                 Postfix
#                   Ident "*"
#                   Ident "name"
#                 Pragma
#                   Ident "required"
#                   Call
#                     Ident "minmax"
#                     IntLit 1
#                     IntLit 2
#               Ident "string"
#               Empty
