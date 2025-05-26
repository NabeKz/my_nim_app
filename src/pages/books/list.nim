import std/htmlgen
import std/sequtils

import src/domain/books/model

const header = "books"

func toLi(items: seq[Book]): string =
  for item in items:
    result.add htmlgen.li(item.title)


proc get*(repository: BookRepository): string = 
  htmlgen.div(
    "book",
    htmlgen.ul(
      repository.list()().toLi()
    )
  )
