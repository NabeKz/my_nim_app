import std/macros
import std/sequtils
import src/shared/utils
import src/validation/rules

export rules

type
  Pragma = object
    name: NimNode
    params: seq[NimNode]

  Field = object
    name: NimNode
    pragmas: seq[Pragma]


func newPragma(node: NimNode): Pragma{.compileTime.} =
  if node.kind == nnkSym:
    result = Pragma(name: node)
  if node.kind == nnkCall:
    let params = node[1..^1]
    result = Pragma(name: node[0], params: params)


func call(node: NimNode, self: Pragma): NimNode =
  node.newCall(self.params)

func call(node: NimNode, lit: NimNode, self: Pragma): NimNode =
  node.newCall(newLit lit.repr).add(self.params)


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

func newField(identDefs: NimNode): Field =
  identDefs.expectKind nnkIdentDefs
  let name = getNameField(identDefs)
  let pragmaNode = findChildRec(identDefs, nnkPragma)
  let pragmas = toSeq(pragmaNode.children).mapIt(newPragma it)
  Field(name: name, pragmas: pragmas)


macro generateValidation*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  let fields = toSeq(recList.children).mapIt(newField(it))

  let self = ident("self")
  result = newStmtList()
  result.add quote do:
    func validate*(`self`: `t`): seq[string] =
      result = newSeqOfCap[string](20)

  for field in fields:
    for pragma in field.pragmas:
      let call = self.chain(field.name, pragma.name).call(pragma)
      let val = ident("ValidationMessage")
      let message = val.chain(pragma.name).call(field.name, pragma)

      result[0][^1].add quote do:
        if not `call`:
          result.add `message`



when isMainModule:
  import std/unittest

  type User = ref object
    name{.required, minmax(1,2).}: string

  func required*(self: User): bool = true
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
