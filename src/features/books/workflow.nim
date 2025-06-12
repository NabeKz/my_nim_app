import std/sugar
import std/sequtils
import std/json
import std/options
import std/tables

import ./model
import src/shared/utils


type
  GetBookOutput* = ref object
    id*: string
    title*: string

  QueryParams* = ref object
    title*: Option[string]

  GetBooksWorkflow* = (Table[string, string] -> seq[GetBookOutput])
  GetBookWorkflow* = (string -> GetBookOutput)
  CreateBookWorkflow* = ((book: sink BookWriteModel){.gcsafe.} -> void)
# 依存関数の型定義
type
  Repository* = object
    getBook*: GetBook
    getBooks*: GetBooks
    createBook*: CreateBook
    updateBook*: UpdateBook
    deleteBook*: DeleteBook

proc to(self: Book, _: type GetBookOutput): GetBookOutput =
  GetBookOutput(id: self.id.string, title: self.title)

# ユースケース関数（純粋関数）

proc build*(_: type GetBooksWorkflow, params: Table[string, string], getBooks: GetBooks): seq[GetBookOutput] =
  getBooks()
    .mapIt(it.to(GetBookOutput))

proc build*(self: type GetBooksWorkflow, getBooks: GetBooks): GetBooksWorkflow =
  (params: Table[string, string]) => self.build(params, getBooks)

proc build*(_: type GetBookWorkflow, getBook: GetBook): GetBookWorkflow = 
  (id: string) => getBook(BookId id).to(GetBookOutput)

proc build*(_: type CreateBookWorkflow, createBook: CreateBook): CreateBookWorkflow =
  (book: sink BookWriteModel) => createBook(book)


# repository

type
  OnMemoryStorage = ref object
    books*: seq[Book]

proc getBookOnMemory(self: OnMemoryStorage): GetBook =
  (id: BookId) => self.books.filter(b => b.id == id)[0]

proc getBooksOnMemory(self: OnMemoryStorage): GetBooks =
  () => self.books

proc createBookOnMemory(self: OnMemoryStorage): CreateBook =
  (dto: sink BookWriteModel) => self.books.add dto.to(Book)

proc updateBookOnMemory(self: OnMemoryStorage): UpdateBook =
  (book: Book) => (
    let index = self.books.findIndexIt(it.id == book.id)
    self.books[index] = book
  )

proc deleteBookOnMemory(self: OnMemoryStorage): DeleteBook =
  (id: BookId) => (
    self.books = self.books.filterIt(it.id != id)
  )


# # 検索機能（フィルタリング付き）
# proc searchBooks*(deps: Dependencies, params: BookSearchParams): seq[Book] =
#   let allBooks = deps.getBooks()
#   result = allBooks
  
#   if params.title.isSome:
#     result = result.filter(book => book.title.contains(params.title.get))

# # 複合操作のユースケース
# proc findBooksWithTitleContaining*(deps: Dependencies, keyword: string): seq[Book] =
#   let searchParams = BookSearchParams(title: some(keyword))
#   searchBooks(deps, searchParams)

# Repository factory（メモリ実装）
proc createInMemoryRepository*(): Repository =
  var storage = OnMemoryStorage(
    books: @[
      newBook(id = BookId "1", title = "The Great Gatsby"),
      newBook(id = BookId "2", title = "To Kill a Mockingbird"),
      newBook(id = BookId "3", title = "1984")
    ]
  )
  
  Repository(
    getBook: getBookOnMemory(storage),
    getBooks: getBooksOnMemory(storage),
    createBook: createBookOnMemory(storage),
    updateBook: updateBookOnMemory(storage),
    deleteBook: deleteBookOnMemory(storage)
  )
