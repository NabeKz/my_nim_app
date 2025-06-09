import src/features/books/model

type
  BookUsecase* = tuple[
    repository: model.BookRepository
  ]

type
  Context* = ref object
    books*: model.BookRepository
    book_usecase: BookUsecase
