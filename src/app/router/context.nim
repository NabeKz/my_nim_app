import src/features/books/model
import src/features/books/repository
import src/features/books/workflow

type
  Context* = ref object
    books*: model.BookRepository
    getBooks*: GetBooks

proc newContext*(): Context =
  let repository = newBooksRepositoryOnMemory()
  let onMemory = workflow.createInMemoryRepository()
  Context(
    books: newBooksRepositoryOnMemory(),
    getBooks: onMemory.getBooks
  )
