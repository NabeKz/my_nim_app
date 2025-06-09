import app/router/context
import src/features/books/repository

proc newContext*(): Context =
  let repository = newBooksRepositoryOnMemory()
  Context(
    books: newBooksRepositoryOnMemory()
  )
