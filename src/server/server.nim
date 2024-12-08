import std/asynchttpserver
import std/asyncdispatch
import std/cmdline
import std/strutils
import std/httpcore

import ./handler
import ./domain

type Setting = ref object
  port: uint16


func newSetting(params: seq[string]): Setting =
  result = Setting(port: 3000)
  for index, param in params:
    if param == "--port" and params.len >= index + 1:
      result.port = parseInt(params[index + 1]).uint16


proc router(req: Request) {.async.} =
  list "/users":
    await req.respond(Http200, $Http200)
  create "/users":
    let body = req.body
    await req.respond(Http200, body)
  read "/users", id:
    await req.respond(Http200, id)

  await req.respond(Http404, $Http404)


proc main(setting: Setting) {.async.} =
  let server = newAsyncHttpServer()

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
