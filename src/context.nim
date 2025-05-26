import app/router/context
import domain/books/repository
  
proc newContext*(): Context =
  Context(
    books:
      newBooksRepositoryOnMemory()
  )