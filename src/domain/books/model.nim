import std/strutils
import std/sugar

type
  BookId* = distinct string
  Book* = ref object
    title: string

  BookListCommand = ((){.gcsafe.} -> seq[Book])
  BookSaveCommand = ((Book){.gcsafe.} -> void)
  BookDeleteCommand = ((BookId){.gcsafe.} -> void)

  BookRepository* = ref object of RootObj
    list: BookListCommand
    save: BookSaveCommand
    delete: BookDeleteCommand

func newBook*(title: string): Book{.raises: [ValueError].} =
  if title.isEmptyOrWhitespace():
    raise newException(ValueError, "title is required")
  if title.len > 50:
    raise newException(ValueError, "title must be 50 length")

  Book(title: title)

func title*(self: Book): string =
  self.title

func newBookRepository*(
  list: BookListCommand,
  save: BookSaveCommand,
  delete: BookDeleteCommand
): BookRepository =
  BookRepository(
    list: list,
    save: save
  )

proc list*(self: BookRepository): seq[Book] =
  self.list()

proc save*(self: BookRepository, model: Book): void =
  self.save(model)

proc delete*(self: BookRepository, id: BookId): void =
  self.delete(id)
