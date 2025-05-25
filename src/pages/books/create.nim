import std/htmlgen

func input(label: string): string =
  htmlgen.label(
    `for` = label,
    label,
    htmlgen.input(
      id = label,
      name = label
    )
  )


func get*(message: seq[string]): string = 
  htmlgen.div(
    $message,
    htmlgen.form(
      action = "/books/create",
      `method` = "POST",
      input("title"),
      input("description"),
      "<button> submit </button>"
    )
  )
