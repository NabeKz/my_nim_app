import src/domain/books/model

type
  Context* = ref object
    books*: model.BookRepository
