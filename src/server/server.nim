import std/asynchttpserver
import std/asyncdispatch
import std/cmdline
import std/strutils
import std/httpcore
import std/macros
import std/re

import ./handler
import ./domain
  
type Setting = ref object
  port: uint16


func newSetting(params: seq[string]): Setting =
  result = Setting(port: 3000)
  for index, param in params:
    if param == "--port" and params.len >= index + 1:
      result.port = parseInt(params[index + 1]).uint16


macro get(p: string, body: untyped): untyped =
  let req = newIdentNode("req")
  quote do:
    if `req`.reqMethod == HttpGet and `req`.url.path == `p`:
      `body`
    
macro read(p: typed, body: untyped): untyped =
  let req = ident "req"
  result = newStmtList()
  var str = "h"
  
  let name = ident $str
  result.add quote do:
    let `name` = 1


  # quote do:
  #   let prefix = rsplit(`p`, "/", 1)[0]
  #   let `id` = 1
  #   if `req`.reqMethod == HttpGet and `req`.url.path.match(re prefix & "/.*" ):
  #     `body`

proc main(setting: Setting) {.async.} =
  var server = newAsyncHttpServer()

  proc router(req: Request) {.async.} =
    get "/users":
      await req.respond(Http200, $Http200)
    read "/hoge":
      echo "id: ", ho
      await req.respond(Http200, $Http200)

    await req.respond(Http404, $Http404)

  server.listen(Port(setting.port))
  let port = server.getPort
  echo "test this with: curl localhost:" & $port.uint16 & "/"
  
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(router)
    else:
      # too many concurrent connections, `maxFDs` exceeded
      # wait 500ms for FDs to be closed
      await sleepAsync(500)

let params = commandLineParams()
let setting = newSetting(params)
waitFor main(setting)