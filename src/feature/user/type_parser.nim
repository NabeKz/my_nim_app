import std/sequtils
import std/macros

type Field = object
  name: NimNode
  pragmas: seq[string]
  typeName: NimNode

func findChildRec(node: seq[NimNode], kind: NimNodeKind): NimNode = 
  for n in node:
    let child = findChild(n, it.kind == kind)
    if not child.isNil:
      result = child
    if child.isNil and n.len > 0:
      result = findChildRec(toSeq(n.children), kind)
    if child.isNil and n.len == 0:
      result = nil

func findChildRec(node: NimNode, kind: NimNodeKind): NimNode = 
  result = findChildRec(toSeq(node), kind)
  

func getNameField(n: NimNode): NimNode =
  case n.kind:
  of  nnkIdentDefs: 
    result = getNameField(n[0])
  of nnkIdent:
    result = n
  of nnkPostfix:
    result = n[1]
  of nnkPragmaExpr:
    result = getNameField(n[0])
  else:
    result = nil

func newField(identDefs: NimNode): Field =
  let name = getNameField(identDefs)
  # let pragmas = newPragma(identDefs)
  let typeName = identDefs[1]
  Field(name: name, typeName: typeName)


macro parseType(t: typedesc): untyped =
  let typeDef = getImpl(t)
  let recList = findChildRec(typeDef, nnkRecList)
  let fileds = recList.mapIt(newField(it))
  # debugEcho recList.repr
  debugEcho fileds.repr


when isMainModule:
  import src/validation/rules
  type Form = ref object
    id{.required.}: string
    name: string
    age*: string
    address*{.required.}: string

  parseType(Form)
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