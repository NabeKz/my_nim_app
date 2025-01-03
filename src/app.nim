import std/asynchttpserver
import std/asyncdispatch

import src/feature/user/controller
import src/feature/user/controller
import src/shared/db/conn


type App = ref object
  server: AsyncHttpServer


func newApp(db: DbConn): App =
  App(
    server: newAsyncHttpServer(),
    db: db,
  )


proc router(req: Request) {.async.} =
  userController(req, repository(app.db))

  await req.respond(Http404, $Http404)


proc run(self: App) {.async.} =
  self.server.listen(Port 5000)
  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(proc (req: Request): Future[void] = router(req, self))
    else:
      await sleepAsync(500)



let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
