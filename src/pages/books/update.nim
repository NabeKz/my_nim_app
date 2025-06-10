import std/htmlgen

import src/features/books/workflow

const header = "books"


proc index*(getBook: GetBookWorkflow, id: string): string =
  let book = getBook(id)
  
  htmlgen.div(
    "book",
    htmlgen.span(
      book.id
    ),
    htmlgen.span(
      book.title
    )
  )
