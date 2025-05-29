import app/router/context
import src/domain/books/repository

proc newContext*(): Context =
  Context(
    books:
    newBooksRepositoryOnMemory()
  )
