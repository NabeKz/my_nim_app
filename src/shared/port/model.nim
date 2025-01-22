import std/macros
import std/sequtils
import src/shared/utils
import src/shared/port/validation_rules

export validation_rules

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
  

func getObjecty(node: NimNode): NimNode = 
  node.expectKind nnkTypeDef
  if node[2].kind == nnkRefTy:
    node[2][0]
  else:
    node[2]



macro generateValidation*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = getObjecty(impl)[2]
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


macro autoMigrate*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  let fields = recList.mapIt((getNameField(it[0]).repr, it[1].repr))
  
  quote do:
    for f in `fields`:
      echo f[0], " : " & f[1]



when isMainModule:
  import std/unittest

  type User* = object of RootObj
    name{.required.}: string
    age: int

  generateValidation(User)
  check User().validate() == @["name is required"]

# StmtList
#   TypeSection
#     TypeDef
#       Postfix
#         Ident "*"
#         Ident "User"
#       Empty
#       RefTy
#         ObjectTy
#           Empty
#           OfInherit
#             Ident "RootObj"
#           RecList
#             IdentDefs
#               PragmaExpr
#                 Ident "name"
#                 Pragma
#                   Ident "required"
#               Ident "string"
#               Empty
#             IdentDefs
#               Ident "age"
#               Ident "int"
#               Empty
# StmtList
#   TypeSection
#     TypeDef
#       Postfix
#         Ident "*"
#         Ident "User"
#       Empty
#       ObjectTy
#         Empty
#         OfInherit
#           Ident "RootObj"
#         RecList
#           IdentDefs
#             PragmaExpr
#               Ident "name"
#               Pragma
#                 Ident "required"
#             Ident "string"
#             Empty
#           IdentDefs
#             Ident "age"
#             Ident "int"
#             Empty