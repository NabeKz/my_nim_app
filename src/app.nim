import std/asynchttpserver
import std/asyncdispatch

import src/shared/db/conn
import src/shared/handler
import src/dependency
import src/app/router/api

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
  echo "server is running at 5000"
  
  let deps = newDependency()

  while true:
    if self.server.shouldAcceptRequest():
      await self.server.acceptRequest(api.router)
    else:
      await sleepAsync(500)


let db = dbConn("db.sqlite3")
let app = newApp(db)
waitFor app.run()
