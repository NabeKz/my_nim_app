import std/htmlgen
import std/tables

import src/features/books/workflow

const header = "books"

func toLi(items: seq[GetBookOutput]): string =
  for item in items:
    result.add htmlgen.li(item.title)
    result.add htmlgen.form(
      `method` = "POST",
      action = "/books/delete/" & item.id.string & "?_method=DELETE",
      class = "delete",
      button(
        type = "submit",
        "delete"
      )
    )


proc query*(query: Table[string, string], getBooks: sink GetBooksWorkflow): string =
  let books = getBooks query

  htmlgen.div(
    "book",
    htmlgen.ul(
      books.toLi()
    )
  )
