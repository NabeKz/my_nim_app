import src/features/books/model

type
  Context* = ref object
    books*: model.BookRepository
