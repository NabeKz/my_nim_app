import std/asynchttpserver
import std/asyncdispatch

import src/app/router
import std/unittest
import ./testing

block:
  let req = testing.get("/")
  waitFor router.handle_request(req)

  check req.response.status == Http200