import std/json
import std/os
import std/tables
import std/sequtils
import std/strformat
import std/strutils
import db_connector/db_sqlite

export tables

type DbConn* = db_sqlite.DbConn

type WriteModel* = concept x
  x.tableName() is string

type ReadModel* = concept x
  x.tableName() is string
  x.id is int64

type Fields = ref object
  keys: seq[string]
  values: seq[string]


func joinedKeys*(self: Fields): string = self.keys.join(",")
func placeholders*(self: Fields): string = self.keys.mapIt("?").join(",")

func getVal(jsonNode: JsonNode): string =
  case jsonNode.kind
  of JString:
    jsonNode.getStr()
  of JInt:
    $jsonNode.getInt()
  else:
    raise newException(ValueError, "not supported type")

func dbConn*(filename: string): DbConn =
  open(filename, "", "", "")


func getFields(t: ref object): Fields =
  result = Fields()
  let node = %* t
  for (key, val) in node.pairs:
    result.keys.add(key)
    result.values.add(val.getVal())


iterator select*(self: DbConn, t: ReadModel, limit: uint64 = 100): JsonNode =
  let fields = getFields(t)
  let query = &"""SELECT {fields.joinedKeys()} FROM {t.tableName()} LIMIT 100"""
  when not defined(release):
    debugEcho "sql is: ", query
  for row in self.rows(sql query):
    let table = zip(fields.keys, row).toTable()
    yield (% table)


proc take*(self: DbConn, t: ReadModel): JsonNode =
  let fields = getFields(t)
  let query = &"""SELECT {fields.joinedKeys()} FROM {t.tableName()} LIMIT 1"""
  when not defined(release):
    debugEcho "sql is: ", query
  let rows = self.getRow(sql query)
  % rows[0]


proc save*(self: DbConn, t: WriteModel): int64 =
  let fields = getFields(t)
  let query = &"""INSERT INTO {t.tableName()} ({fields.joinedKeys()}) VALUES ({fields.placeholders()})"""
  debugEcho "debug: sql is ", query, fields.values
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
  ## filenames = db.sqlite3"
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
  import src/feature/user/model

  when defined(migrate):
    let db = dbConn(getCurrentDir() & "/db.sqlite3")
    execDDL(db)
    return
  
  dbOnMemory db:
    for jsonNode in db.select(UserRecord()):
      echo jsonNode

    discard db.save(User(name: "hoge", age: 20))

    for jsonNode in db.select(UserRecord()):
      echo jsonNode
