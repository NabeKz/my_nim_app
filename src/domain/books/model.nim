import std/sugar

type 
  Book* = ref object
    title: string

  BookListCommand* = ((){.gcsafe.} -> seq[Book])
  
  BookRepository* = ref object
    list*: BookListCommand


func newBook*(title: string): Book =
  Book(title: title)

func title*(self: Book): string =
  self.title

func newBookRepository*(list: BookListCommand): BookRepository =
  BookRepository(
    list: list
  )
