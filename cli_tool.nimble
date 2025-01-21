# Package

version       = "0.1.0"
author        = "NabeKz"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["app"]


# Dependencies

requires "nim >= 2.2.0", "db_connector"

import os
import std/strutils
task sweep, "cleanup binary":
  for src in walkDirRec("src"):
    let path = src.split(".")
    if path.len == 1:
      rmFile path[0]


task format, "format":
  exec """nimpretty src/*"""

task db_init, "initialize database":
  rmFile "db.sqlite3"
  exec """nim c -d:migrate -r src/shared/db/conn"""

task db_show, "show database tables":
  exec """sqlite3 db.sqlite3 .tables"""