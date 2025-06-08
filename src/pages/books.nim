import std/strutils
import std/tables

import src/features/books/model
import src/pages/books/list
import src/pages/books/create as c
import src/pages/books/update as u
import src/pages/shared

const index* = list.get
const create* = c.get
const edit* = u.index


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

proc save*(repository: BookRepository, params: CreateParams): void =
  repository.save newBook(params.title)

proc find*(repository: BookRepository, id: string): Book =
  let bookId = BookId(id)
  repository.find bookId

proc update*(repository: BookRepository, model: Book): void =
  repository.update model

proc delete*(repository: BookRepository, id: string): void =
  repository.delete id.BookId
