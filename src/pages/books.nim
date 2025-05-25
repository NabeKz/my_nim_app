import std/htmlgen

const header = "books"

func index*(): string = 
  htmlgen.div(
    "book"
  )


func input(label: string): string =
  htmlgen.label(
    `for` = label,
    label,
    htmlgen.input(
      id = label
    )
  )


func create*(): string = 
  htmlgen.div(
    htmlgen.form(
      action = "/books",
      `method` = "POST",
      input("title"),
      "<button> submit </button>"
    )
  )
  