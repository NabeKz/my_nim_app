import std/strutils
import std/sequtils
import std/tables

import src/pages/books/list
import src/pages/books/create as c

const index* = list.get
const create* = c.get


type CreateParams = ref object
  title: string

type ValidateError* = ref object of ValueError
  errors*: seq[string]

func build(params: Table[string, string]): CreateParams =
  CreateParams(
    title: params.getOrDefault("title", "")
  )

proc parseParams(params: string): Table[string, string] =
  params
    .split("&")
    .mapIt(it.split("=", 1))
    .mapIt((it[0], it[1]))
    .toTable()

proc validate*(body: string): CreateParams{.raises: [ValidateError].} = 
  var errors = newSeqOfCap[string](50)
  let params = parseParams(body).build()
  if params.title.isEmptyOrWhitespace():
    errors.add("title is required")
  if params.title.len > 50:
    errors.add("title must be 50 length")
  
  if errors.len > 0:
    raise ValidateError(errors: errors)
  else:
    params
