import std/sequtils
import ./model

type BookRepositoryOnMemory* = ref object of BookRepository
  items: seq[Book]

proc newBooksRepositoryOnMemory*(): BookRepository =
  var books = @[
    newBook(title = "hoge"),
    newBook(title = "fuga")
  ]

  newBookRepository(
    list = proc(): seq[Book] = books,
    save = proc(model: Book): void = books.add(model),
    delete = proc(id: BookId): void = books = books.filterIt(it.id != id)
  )
