# Package

version       = "0.1.0"
author        = "NabeKz"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["app"]


# Dependencies

requires "nim >= 2.2.0", "db_connector", "ulid", "norm"

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
  exec "nim c -r src/shared/db/schema.nim"

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

task schema_gen, "generate schema and types from database":
  echo "Generating schema and types from database..."
  
  if not fileExists("db.sqlite3"):
    echo "Database not found. Run 'nimble db_init' first."
    quit(1)
  
  # generate_schema.nimを使用してスキーマと型を生成
  exec "nim c -r generate_schema.nim db.sqlite3"
  
  echo "Generated files:"
  echo "  - db_schema.nim (schema definitions)"
  echo "  - generated_types.nim (type definitions)"
  echo "Schema generation completed!"

task schema_update, "update schema and regenerate types":
  echo "Updating database schema..."
  exec "nimble db_init"  # データベースを再初期化
  exec "nimble schema_gen"  # スキーマを再生成
  echo "Schema update completed!"

task typed_sql_test, "test type-safe SQL functionality":
  echo "Testing type-safe SQL functionality..."
  exec "nim c -r src/shared/typed_sql.nim"
  echo "Type-safe SQL tests completed!"


task typed_sql_full, "full type-safe SQL workflow":
  echo "Running full type-safe SQL workflow..."
  exec "nimble db_init"
  exec "nimble schema_gen" 
  exec "nimble typed_sql_test"
  echo "Full workflow completed!"
