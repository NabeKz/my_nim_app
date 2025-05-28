import std/asynchttpserver
import std/asyncdispatch

import src/shared/db/conn
import src/context
import src/app/router/web

type 
  App = ref object
    server: AsyncHttpServer

func newApp(db: DbConn): App =
  App(
    server: newAsyncHttpServer()
  )  

proc run(self: App) {.async.} =
  var db = dbConn("db.sqlite3")
  defer: db.close()
  
  self.server.listen(Port 5000)
  echo "server is running at http://localhost:5000"
  
  let ctx = newContext()
  let cb = proc(req: Request) {.async.} =
    await web.router(ctx, req)

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(cb)
    else:
      await sleepAsync(500)


let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
