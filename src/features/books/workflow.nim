import std/sugar
import ./model

proc getBooks*(books: seq[Book]): GetBooks =
  () => books

proc onMemory*(): tuple[
  getBooks: GetBooks
] =
  var books = @[
    newBook(id = BookId "1", title = "hoge"),
    newBook(id = BookId "2", title = "fuga")
  ]
  (
    getBooks: getBooks(books)
  )