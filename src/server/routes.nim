import std/httpcore
import std/asynchttpserver
import std/asyncdispatch
import std/strutils
import std/macros


proc httpGet(self: Request): string =
  if self.reqMethod == HttpMethod.HttpGet:
    result = "this is get request"

proc routes*(req: Request): string =
  case req.reqMethod:
  of HttpMethod.HttpGet: httpGet req
  else: $Http404
