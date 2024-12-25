import std/json
import std/sequtils
import std/strutils
import std/strformat
import std/macros

import src/validation/[factory, rules]

type UnValidateForm = ref object
  name*{.required.}: string
  age: int


proc toJson*(body: string): JsonNode =
  try: 
    parseJson body
  except:
    parseJson "{}"

# TODO: move put directory
func findChildRec(node: NimNode, kinds: varargs[NimNodeKind]): NimNode =
  result = node
  for kind in kinds:
    result = result.findChild(it.kind == kind)

func getNameField(node: NimNode): NimNode =
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
  let recList = findChildRec(impl, nnkRefTy, nnkObjectTy, nnkRecList)
  let identDefs = toSeq(recList.children)
  let names = identDefs.mapIt(getNameField(it[0]).repr)
  let types = identDefs.mapIt(it[1].repr)
  var stmtList = newStmtList()
  for (key, val) in zip(names, types):
    stmtList.add parseStmt &"""
    if jsonNode.hasKey("{key}"):
      result.{key} = jsonNode["{key}"].getVal({val})
    """
  
  quote do:
    proc unmarshal(jsonNode: JsonNode): `t` =
      result = `t`()
      `stmtList`


when isMainModule:
  let body = """{"name": 1}"""
  let jsonNode = body.toJson()

  generateUnmarshal(UnValidateForm)

  let f = unmarshal(jsonNode)
  echo (%* f)

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