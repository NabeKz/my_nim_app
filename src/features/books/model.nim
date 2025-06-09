import std/options
import std/strutils
import std/sugar

import src/shared/uuid

type
  BookId* = distinct string
  Book* = ref object
    id*: BookId
    title: string
  BookWriteModel* = ref object
    title*: string

  BookSearchParams* = ref object
    title*: Option[string]
    author*: Option[string]

  GetBook* = ((BookId){.gcsafe.} -> Book)
  GetBooks* = ((){.gcsafe.} -> seq[Book])
  CreateBook* = ((BookWriteModel){.gcsafe.} -> void)
  UpdateBook* = (Book{.gcsafe.} -> void)
  DeleteBook* = ((BookId){.gcsafe.} -> void)

  BookError* = enum
    BookNotFound = "Book not found"
    InvalidQuery = "Invalid query parameters"
    DatabaseError = "Database connection failed"
    UnauthorizedAccess = "Unauthorized access"


  BookRepository* = ref object of RootObj
    find*: GetBook
    save*: CreateBook
    update*: UpdateBook
    delete*: DeleteBook

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
    save: CreateBook,
    update: UpdateBook,
    delete: DeleteBook,
): BookRepository =
  BookRepository(
    save: save,
    update: update,
    delete: delete
  )

func id*(self: Book): BookId =
  self.id

func `==`*(self: BookId, other: BookId): bool =
  self.string == other.string

func `!=`*(self: BookId, other: BookId): bool =
  not (self == other)

proc to*(self: BookWriteModel, _: type Book): Book =
  Book(id: BookId generateUuid(), title: self.title)