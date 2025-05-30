import std/htmlgen

import src/domain/books/model

const header = "books"

func toLi(items: seq[Book]): string =
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


proc get*(repository: BookRepository): string =
  htmlgen.div(
    "book",
    htmlgen.ul(
      repository.list().toLi()
    )
  )
