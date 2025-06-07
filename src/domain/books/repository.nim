import std/sequtils

import src/shared/uuid
import ./model

type BookRepositoryOnMemory* = ref object of BookRepository
  items: seq[Book]


proc save(
  books: var seq[Book],
  model: BookWriteModel
): void =
  let book = newBook(
    id = BookId generateUuid(),
    title = model.title
  )
  books.add(book)

proc update(
  books: var seq[Book],
  model: Book
): void =
  for i, book in books:
    if book.id == model.id:
      books[i] = model
      return
  raise newException(ValueError, "Book not found")

proc newBooksRepositoryOnMemory*(): BookRepository =
  var books = @[
    newBook(id = BookId "1", title = "hoge"), 
    newBook(id = BookId "2", title = "fuga")
  ]

  newBookRepository(
    list = proc(): seq[Book] = books,
    delete = proc(id: BookId): void = books = books.filterIt(it.id != id),
    save = proc(model: BookWriteModel): void = save(books, model),
    update = proc(model: Book): void = update(books, model)
  )
