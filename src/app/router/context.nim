import src/features/books/model
import src/features/books/repository
import src/features/books/workflow

type
  Context* = ref object
    books*: model.BookRepository
    getBook*: GetBookWorkflow
    getBooks*: GetBooks

proc newContext*(): Context =
  let repository = newBooksRepositoryOnMemory()
  let onMemory = workflow.createInMemoryRepository()
  Context(
    books: newBooksRepositoryOnMemory(),
    getBook: workflow.build(onMemory.getBook),
    getBooks: onMemory.getBooks
  )
