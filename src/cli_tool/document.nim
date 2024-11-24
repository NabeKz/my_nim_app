import std/strutils

type Document = ref object
  title: string

func newDocument*(): Document =
  Document(title: "#画面設計書")


func title*(self: Document): string = self.title


proc addLn(self: var string, str: string) =
  self.add str
  self.add "\n"


func `$`*(self: Document): string =
  result.addLn self.title
  result.addLn "hoge"


when isMainModule:

  let doc = newDocument()
  echo doc
