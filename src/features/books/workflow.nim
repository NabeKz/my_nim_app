import std/sugar
import std/sequtils
import ./model


type
  GetBookOutout* = ref object
    id*: string
    title*: string

  GetBookWorkflow* = (string -> GetBookOutout)
# 依存関数の型定義
type
  Repository* = object
    getBook*: GetBook
    getBooks*: GetBooks
    createBook*: CreateBook
    # updateBook*: UpdateBook
    # deleteBook*: DeleteBook

proc to(self: Book, _: type GetBookOutout): GetBookOutout =
  GetBookOutout(id: self.id.string, title: self.title)

# ユースケース関数（純粋関数）
proc build*(getBook: GetBook): GetBookWorkflow = 
  (id: string) => getBook(BookId id).to(GetBookOutout)

proc listAllBooks*(f: GetBooks): seq[Book] =
  f()


# repository

proc getBookOnMemory(books: seq[Book]): GetBook =
  (id: BookId) => books.filter(b => b.id == id)[0]

proc getBooksOnMemory(books: seq[Book]): GetBooks =
  () => books

proc createBookOnMemory(books: ref seq[Book]): CreateBook =
  (dto: BookWriteModel) => books[].add dto.to(Book)


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
  var books = @[
    newBook(id = BookId "1", title = "The Great Gatsby"),
    newBook(id = BookId "2", title = "To Kill a Mockingbird"),
    newBook(id = BookId "3", title = "1984")
  ]
  Repository(
    getBook: getBookOnMemory(books),
    getBooks: getBooksOnMemory(books),
    createBook: createBookOnMemory(new seq[Book]),
  )
