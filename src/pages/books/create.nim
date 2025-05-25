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


func get*(): string = 
  htmlgen.div(
    htmlgen.form(
      action = "/books/create",
      `method` = "POST",
      input("title"),
      input("description"),
      "<button> submit </button>"
    )
  )
  
func post*(params: string): string = 
  htmlgen.div(
    htmlgen.form(
      action = "/books",
      `method` = "POST",
      input("title"),
      "<button> submit </button>"
    )
  )
  