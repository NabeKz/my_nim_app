import std/sugar

type 
  Book* = ref object
    title: string

  BookListCommand = ((){.gcsafe.} -> seq[Book])
  BookSaveCommand = ((Book){.gcsafe.} -> void)
  
  BookRepository* = ref object
    list: BookListCommand
    save: BookSaveCommand

func newBook*(title: string): Book =
  Book(title: title)

func title*(self: Book): string =
  self.title

func newBookRepository*(list: BookListCommand): BookRepository =
  BookRepository(
    list: list
  )

proc list*(self: BookRepository): seq[Book] =
  self.list()

# proc invoke*(self: BookRepository): void =
#   self.save()