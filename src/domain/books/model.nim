import std/strutils
import std/sugar

type
  BookId* = distinct string
  Book* = ref object
    id*: BookId
    title: string
  BookWriteModel* = ref object
    title*: string

  BookListCommand = ((){.gcsafe.} -> seq[Book])
  BookSaveCommand = ((BookWriteModel){.gcsafe.} -> void)
  BookDeleteCommand = ((BookId){.gcsafe.} -> void)

  BookRepository* = ref object of RootObj
    list: BookListCommand
    save: BookSaveCommand
    delete: BookDeleteCommand

func newBook*(id: BookId, title: string): Book{.raises: [ValueError].} =
  if title.isEmptyOrWhitespace():
    raise newException(ValueError, "title is required")
  if title.len > 50:
    raise newException(ValueError, "title must be 50 length")

  Book(id: id, title: title)

func newBook*(title: string): BookWriteModel{.raises: [ValueError].} =
  if title.isEmptyOrWhitespace():
    raise newException(ValueError, "title is required")
  if title.len > 50:
    raise newException(ValueError, "title must be 50 length")

  BookWriteModel(title: title)

func title*(self: Book): string =
  self.title

func newBookRepository*(
  list: BookListCommand,
  save: BookSaveCommand,
  delete: BookDeleteCommand
): BookRepository =
  BookRepository(
    list: list,
    save: save,
    delete: delete
  )

func id*(self: Book): BookId =
  self.id

func `==`*(self: BookId, other: BookId): bool =
  self.string == other.string

func `!=`*(self: BookId, other: BookId): bool =
  not (self == other)

proc list*(self: BookRepository): seq[Book] =
  self.list()

proc save*(self: BookRepository, model: BookWriteModel): void =
  self.save(model)

proc delete*(self: BookRepository, id: BookId): void =
  self.delete(id)
