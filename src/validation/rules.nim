import std/macros
import std/sequtils

type
  Pragma = object
    name: string
    params: seq[string]
  
  Field = object
    name: string
    pragmas: seq[Pragma]

func newField(node: NimNode): Pragma = 
  if node.kind == nnkSym:
    let name = node[0].repr
    Pragma(name: name, params: @[])
  if node.kind == nnkCall:
    let name = node[0].repr
    let parmas = toSeq(node[1..^1]).mapIt(it.repr)
    Pragma(name: name, params: params)

    
func newField(node: NimNode): seq[Field] = 
  for n in node:
    let name = n[0].repr
    let pragmas = toSeq(n.children).newField()
    result.add Field(name: name, pragmas: pragmas)


macro generateValidation(t: typedesc): untyped =
  let impl = t.getTypeInst()[1].getImpl()
  let recList = impl[2][0][2]
  let fields = toSeq(recList.children).mapIt(newField(it))
  let self = ident("self")
  let t = ident($t)
  quote do:
    func validate*(`self`: `t`): seq[string] =
      @[]

