type
  Book* = ref object
    title: string
  BooksRepository* = ref object
    items: seq[Book]

func newBooksRepository()*: BooksRepository =
  BooksRepository(
    items: @[]
  )