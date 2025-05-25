import std/strutils
import std/tables

import src/pages/books/list
import src/pages/books/create as c
import src/pages/shared

const index* = list.get
const create* = c.get


type CreateParams = ref object
  title: string


func build(params: Table[string, string]): CreateParams =
  CreateParams(
    title: params.getOrDefault("title", "")
  )

proc validate*(body: string): CreateParams{.raises: [ValidateError].} = 
  
  shared.check body, build:
    if model.title.isEmptyOrWhitespace():
      errors.add("title is required")
    if model.title.len > 50:
      errors.add("title must be 50 length")
