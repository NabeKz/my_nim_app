import std/asynchttpserver
import std/uri

func get*(path: string): Request =
  Request(
    reqMethod: HttpGet,
    headers: newHttpHeaders({
      "content-type": "application/json"
    }),
    url: parseUri(path)
  )