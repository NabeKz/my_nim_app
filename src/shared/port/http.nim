import std/json
import std/sequtils
import std/strformat
import std/macros

import src/shared/utils
export json

type
  ResultKind* = enum
    kOk, kErr

  Result*[T] = ref object
    case kind*: ResultKind
    of kOk:
      val*: T
    of kErr:
      errors*: seq[string]
      
  ValidateAble* = concept x
    x.validate() is seq[string]

proc toJson*(body: string): JsonNode =
  try:
    parseJson body
  except:
    parseJson "{}"

func getNameField(node: NimNode): NimNode =
  node.expectKind {nnkPragmaExpr, nnkPostfix, nnkIdent}
  if node.kind == nnkPragmaExpr:
    result = getNameField(node[0])
  if node.kind == nnkPostfix:
    result = node[1]
  if node.kind == nnkIdent:
    result = node

func getVal*(j: JsonNode, _: type string): string = j.getStr()
func getVal*(j: JsonNode, _: type int): int = j.getInt()
func getVal*(j: JsonNode, _: type uint16): uint16 = j.getInt().uint16

macro generateUnmarshal*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  let fields = recList.mapIt((getNameField(it[0]).repr, it[1].repr))
  let jsonNode = ident("jsonNode")
  result = newStmtList()
  result.add quote do:
    proc unmarshal(`jsonNode`: JsonNode): `t` =
      result = `t`()
  for (key, val) in fields:     
    result[0][^1].add parseStmt &"""
    if jsonNode.hasKey("{key}"):
      result.{key} = jsonNode["{key}"].getVal({val})
    """


macro match*[T](model: T): untyped =
  let t = getTypeInst(model)
  quote do:
    let errors = `model`.validate()
    if errors.len > 0:
      Result[`t`](kind: kErr, errors: errors)
    else:
      Result[`t`](kind: kOk, val: `model`)


when isMainModule:
  let body = """{"name": 1}"""
  let jsonNode = body.toJson()
  type UnValidateForm = ref object
    name: string
    age: int


  generateUnmarshal(UnValidateForm)

  let f = unmarshal(jsonNode)
  echo ( %* f)

# StmtList
  # TypeSection
    # TypeDef
      # Ident "UnValidateForm"
      # Empty
      # RefTy
        # ObjectTy
          # Empty
          # Empty
          # RecList
            # IdentDefs
              # PragmaExpr
                # Ident "name"
                # Pragma
                  # Ident "required"
                # Ident "string"
                # Empty
              # IdentDefs
                # Postfix
                  # Ident "*"
                  # Ident "age"
                # Ident "int"
                # Empty
