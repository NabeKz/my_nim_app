import std/json
import std/os
import std/sequtils
import std/strformat
import std/strutils
import db_connector/db_sqlite

type DbConn* = db_sqlite.DbConn

type WriteModel* = concept x
  x.tableName() is string

type ReadModel* = concept x
  x.tableName() is string
  x.id is int64


func dbConn*(filename: string): DbConn =
  open(filename, "", "", "")


func getFields(t: ref object): tuple[keys: seq[string], values: seq[string]] =
  let node = %* t
  for (key, val) in node.pairs:
    result.keys.add(key)
    result.values.add($val)
  
 
proc select*[T: ReadModel](self: DbConn, t: T, limit: uint64 = 100): seq[T] =
  let query = &"""SELECT * FROM {t.tableName()} LIMIT 100"""
  let fields = getFields(t)
  let rows = self.getAllRows(sql query)
  for row in rows:
    result.add to((%* row), typedesc t)


proc save*(self: DbConn, t: WriteModel): int64 =
  let fields = getFields(t)
  let keys = fields.keys.join(",")
  let placeholders = fields.keys.mapIt("?").join(",")
  let query = &"""INSERT INTO {t.tableName()} ({keys}) VALUES ({placeholders})"""
  self.insertID(sql query, fields.values)

when not defined(release):
  import std/os
  import std/algorithm
  import std/sequtils

  export db_sqlite except DbConn
  # export db_sqlite.exec

  proc execDDL(db: DbConn) =
    let ddls = toSeq(walkDirRec("src")).filterIt(it.endsWith(".sql")).sorted()
    for ddl in ddls:
      let query = readFile(ddl)
      echo query
      let success = db.tryExec(sql query)
      if not success:
        echo "exec sql failure " & ddl

  ## use only dev
  template dbSetup*(filename: string, db, op: untyped): untyped =
    let db = dbConn(filename)
    execDDL(db)
    op

  template dbOnMemory*(db, op: untyped): untyped =
    let db = dbConn(":memory:")
    execDDL(db)
    op

when isMainModule:
  import std/os
  import std/algorithm
  import std/sequtils

  let db = dbConn(getCurrentDir() & "/db.sqlite3")
  let ddls = toSeq(walkDirRec("src")).filterIt(it.endsWith(".sql")).sorted()
  for ddl in ddls:
    let query = readFile(ddl)
    echo query
    let success = db.tryExec(sql query)
    if not success:
      echo "exec sql failure " & ddl
    