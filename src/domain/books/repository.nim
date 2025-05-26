import ./model

proc newBooksRepositoryOnMemory*(): BookRepository =
  var books: seq[Book] = @[
    newBook(title = "hoge"),
    newBook(title = "fuga")
  ]
  
  newBookRepository(
    list =  proc(): seq[Book] = books
  )
