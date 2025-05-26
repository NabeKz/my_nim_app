type 
  Book* = ref object
    title: string

  BookListCommand = proc(): seq[Book]
  
  BookRepository* = ref object
    list: BookListCommand


proc newBook*(title: string): Book =
  Book(title: title)


proc newBookRepository*(list: BookListCommand): BookRepository =
  BookRepository(
    list: list
  )

func list*(self: BookRepository): BookListCommand =
  self.list