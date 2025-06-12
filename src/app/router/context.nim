import src/features/books/model
import src/features/books/repository
import src/features/books/workflow

type
  Context* = ref object
    books*: model.BookRepository
    getBooks*: GetBooksWorkflow
    getBook*: GetBookWorkflow
    createBook*: CreateBookWorkflow
    deleteBook*: DeleteBookWorkflow

proc newContext*(): Context =
  let repository = newBooksRepositoryOnMemory()
  let onMemory = workflow.createInMemoryRepository()
  Context(
    books: newBooksRepositoryOnMemory(),
    getBooks: GetBooksWorkflow.build(onMemory.getBooks),
    getBook: GetBookWorkflow.build(onMemory.getBook),
    createBook: CreateBookWorkflow.build(onMemory.createBook),
    deleteBook: DeleteBookWorkflow.build(onMemory.deleteBook),
  )
