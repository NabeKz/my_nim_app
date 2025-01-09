import std/json
import std/macros
import std/sequtils
import std/strformat
import std/strutils

import src/shared/utils
export json


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
func getVal*(j: JsonNode, _: type int): int = j.getStr().parseInt()

macro generateDeSerialize*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  let fields = recList.mapIt((getNameField(it[0]).repr, it[1].repr))
  let jsonNode = ident("jsonNode")
  result = newStmtList()
  result.add quote do:
    proc deSerialize(`jsonNode`: JsonNode): `t` =
      result = `t`()
  for (key, val) in fields:     
    result[0][^1].add parseStmt &"""
    result.{key} = jsonNode["{key}"].getVal({val})
    """ 

macro generateDeSerialize2*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  debugEcho recList.repr
  
  quote do:
    echo "ok"


when isMainModule:
  import src/shared/port/model
  # let body = """{"name": "a", "age": "1"}"""
  # let jsonNode = body.toJson()

  type User* = ref object of RootObj
    name*{.required.}: string
    age*: int


  type UserRecord* = ref object of User
    id*: int64

  generateDeSerialize2(UserRecord)

  # let f = deSerialize(jsonNode)
  # echo (%* f)

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
