import std/htmlgen

const header = "books"

func get*(): string = 
  htmlgen.div(
    "book"
  )
