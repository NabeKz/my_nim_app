import std/asynchttpserver
import std/asyncdispatch


type App = ref object
  server: AsyncHttpServer

type Callback = proc (request: Request): Future[void]{.closure, gcsafe.}

func newApp(): App =
  App(server: newAsyncHttpServer())


proc router(req: Request) {.async.} =
  let headers = newHttpHeaders({
    "Content-Type": "application/json"
  })
  await req.respond(Http200, "ok", headers)

proc run(self: App) {.async.} =
  self.server.listen(Port 5000)

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(router)
    else:
      await sleepAsync(500)

let app = newApp()
waitFor app.run()
