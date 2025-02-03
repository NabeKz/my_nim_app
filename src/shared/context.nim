import src/shared/db/conn
import std/asynchttpserver

type Context = ref object
  db: DbConn
  server: AsyncHttpServer


var ctx: Context

proc newContext*(db: DbConn, server: AsyncHttpServer): Context = 
  Context(
    db: db, 
    server: server
  )

proc newContext*(): Context = 
  ctx


func db*(self: Context): DbConn = 
  self.db


proc getContext*(): Context =
  ctx
