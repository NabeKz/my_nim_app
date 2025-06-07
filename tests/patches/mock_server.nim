import std/asyncdispatch
import std/httpcore
import std/uri

export httpcore

type
  MockResponse* = ref object
    status*: HttpCode
    headers*: HttpHeaders
    content*: string

  Request* = ref object
    reqMethod*: HttpMethod
    headers*: HttpHeaders
    url*: Uri
    response: MockResponse


proc respond*(req: Request, code: HttpCode, content: string, headers: HttpHeaders = nil){.async.} =
  echo "respond!"
  req.response = MockResponse(
    status: code,
    headers: headers,
    content: content,
  )

func response*(self: Request): MockResponse =
  self.response
