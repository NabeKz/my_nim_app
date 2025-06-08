import app/router/context
import src/features/books/repository

proc newContext*(): Context =
  Context(
    books: newBooksRepositoryOnMemory()
  )
