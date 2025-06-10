import std/sugar
import std/sequtils
import std/json
import std/options
import ./model


type
  GetBookOutout* = ref object
    id*: string
    title*: string

  QueryParams* = ref object
    title*: Option[string]

  GetBookWorkflow* = (string -> GetBookOutout)
  GetBooksWorkflow* = (JsonNode -> seq[GetBookOutout])
# 依存関数の型定義
type
  Repository* = object
    getBook*: GetBook
    getBooks*: GetBooks
    createBook*: CreateBook
    # updateBook*: UpdateBook
    deleteBook*: DeleteBook

proc to(self: Book, _: type GetBookOutout): GetBookOutout =
  GetBookOutout(id: self.id.string, title: self.title)

# ユースケース関数（純粋関数）
proc build*(_: type GetBookWorkflow, getBook: GetBook): GetBookWorkflow = 
  (id: string) => getBook(BookId id).to(GetBookOutout)

proc build*(_: type GetBooksWorkflow, params: QueryParams, getBooks: GetBooks): seq[GetBookOutout] =
  getBooks()
    .filterIt(it.title == title.getOrDefault(""))
    .mapIt(it.to(GetBookOutout))

proc build*(_: type GetBooksWorkflow, getBooks: GetBooks): seq[GetBookOutout] =
  (params: QueryParams) => GetBooksWorkflow.build(params, getBooks)


# repository

type
  OnMemoryStorage = ref object
    books*: seq[Book]

proc getBookOnMemory(self: OnMemoryStorage): GetBook =
  (id: BookId) => self.books.filter(b => b.id == id)[0]

proc getBooksOnMemory(self: OnMemoryStorage): GetBooks =
  () => self.books

proc createBookOnMemory(self: OnMemoryStorage): CreateBook =
  (dto: BookWriteModel) => self.books.add dto.to(Book)

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
    deleteBook: deleteBookOnMemory(storage)
  )
