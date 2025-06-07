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
  for nimFile in walkDirRec("src"):
    if nimFile.endsWith(".nim"):
      exec "nimpretty --maxLineLen:100 --indent:2 " & nimFile
  for nimFile in walkDirRec("tests"):
    if nimFile.endsWith(".nim"):
      exec "nimpretty --maxLineLen:100 --indent:2 " & nimFile

task db_init, "initialize database":
  rmFile "db.sqlite3"
  exec """nim c -d:migrate -r src/shared/db/conn"""

task db_show, "show database tables":
  exec """sqlite3 db.sqlite3 .tables"""

task db_schema, "parse db schema":
  exec """nim c -r src/shared/db/schema.nim"""

task ut, "run unit test":
  exec """testament p tests/**/*.nim"""

task check, "run static analysis":
  exec """nim check --hints:off --warnings:off src/app.nim"""
  for nimFile in walkDirRec("src"):
    if nimFile.endsWith(".nim"):
      exec "nim check --hints:off --warnings:off " & nimFile

task lint, "run linting (check + format)":
  exec "nimble check"
  exec "nimble format"

task strictcheck, "run strict static analysis with all warnings":
  exec """nim check --warnings:on --hints:on src/app.nim"""
  for nimFile in walkDirRec("src"):
    if nimFile.endsWith(".nim"):
      exec "nim check --warnings:on --hints:on " & nimFile
