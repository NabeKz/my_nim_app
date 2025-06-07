import std/asynchttpserver
import std/asyncdispatch

import src/app/router/api
import std/unittest
import ./testing

block:
  let req: Request = testing.get("/")
  waitFor api.router(req)

  check req.response.status == Http200
