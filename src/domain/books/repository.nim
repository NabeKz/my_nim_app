import std/sequtils
import ./model

type BookRepositoryOnMemory* = ref object of BookRepository
  items: seq[Book]

proc newBooksRepositoryOnMemory*(): BookRepository =
  var books = @[
    newBook(id = BookId "1", title = "hoge"),
    newBook(id = BookId "2", title = "fuga")
  ]
  var id = books.len + 1

  newBookRepository(
    list = proc(): seq[Book] = books,
    delete = proc(id: BookId): void = books = books.filterIt(it.id != id),
    save = proc(model: BookWriteModel): void =
    let book = newBook(
      id = BookId $id,
      title = model.title
    )
    books.add(book)
    id.inc()
  )
