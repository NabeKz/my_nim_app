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
    let params = toSeq(node[1..^1]).mapIt(it.repr).join(",")
    result = Pragma(name: node[0].repr, call: node.repr, params: params)

template findChildRec(node: NimNode, kinds: varargs[NimNodeKind]): untyped =
  var child = node
  for kind in kinds:
    child = findChild(child, it.kind == kind)
  child

func getName(n: NimNode): NimNode = 
  if n.kind == nnkPostfix:
    result = n[1]
  if n.kind == nnkIdent:
    result = n

func newField(identDefs: NimNode): Field{.compileTime.}  = 
  let pragmaExpr = findChildRec(identDefs, nnkPragmaExpr)
  let name = getName(pragmaExpr[0])
  let pragmaNode = findChild(pragmaExpr, it.kind == nnkPragma)
  let pragmas = toSeq(pragmaNode.children).mapIt(newPragma it)
  Field(name: name.repr, pragmas: pragmas)


macro generateValidation*(t: typedesc): untyped =
  let impl = getTypeInst(t)[1].getImpl()
  let recList = findChildRec(impl, nnkRefTy, nnkObjectTy, nnkRecList)
  let fields = toSeq(recList.children).mapIt(newField(it))
  debugEcho fields.repr

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
  import ./rules

  type User = ref object
    name{.required, minmax(1, 2).}: string

  generateValidation(User)

  echo User().validate()

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
