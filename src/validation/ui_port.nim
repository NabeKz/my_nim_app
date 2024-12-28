import std/json
import std/sequtils
import std/strutils
import std/strformat
import std/macros

import src/shared/utils


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

func getVal(j: JsonNode, _: type string): string = j.getStr()
func getVal(j: JsonNode, _: type int): int = j.getInt()

macro generateUnmarshal*(t: typedesc): untyped =
  let impl = getImpl(t)
  let recList = findChildRec(impl, nnkRecList)
  let fields = recList.mapIt((getNameField(it[0]).repr, it[1].repr))
  result = newStmtList()
  result.add quote do:
    proc unmarshal(jsonNode: JsonNode): `t` =
      result = `t`()
  for (key, val) in fields:     
    result[0][^1].add parseStmt &"""
    if jsonNode.hasKey("{key}"):
      result.{key} = jsonNode["{key}"].getVal({val})
    """


when isMainModule:
  let body = """{"name": 1}"""
  let jsonNode = body.toJson()
  type UnValidateForm = ref object
    name*: string
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
