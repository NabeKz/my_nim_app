import std/strutils
import std/sugar

type 
  Book* = ref object
    title: string

  BookListCommand = ((){.gcsafe.} -> seq[Book])
  BookSaveCommand = ((Book){.gcsafe.} -> void)
  
  BookRepository* = ref object of RootObj
    list: BookListCommand
    save: BookSaveCommand

func newBook*(title: string): Book{.raises: [ValueError].} =
  if title.isEmptyOrWhitespace():
    raise newException(ValueError, "Title cannot be empty or whitespace")

  Book(title: title)

func title*(self: Book): string =
  self.title

func newBookRepository*(list: BookListCommand, save: BookSaveCommand): BookRepository =
  BookRepository(
    list: list,
    save: save
  )

proc list*(self: BookRepository): seq[Book] =
  self.list()

proc save*(self: BookRepository, model: Book): void =
  self.save(model)