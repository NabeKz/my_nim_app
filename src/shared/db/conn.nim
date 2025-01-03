import std/strformat
import std/strutils
import std/sequtils
import std/json
import db_connector/db_sqlite

type DbConn* = db_sqlite.DbConn

type WriteModel* = concept x
  x.tableName() is string


func dbConn*(filename: string): DbConn =
  open(filename, "", "", "")

func getFields(t: ref object): tuple[keys: seq[string], values: seq[string]] =
  let node = %* t
  for (key, val) in node.pairs:
    result.keys.add(key)
    result.values.add($val)
  
 
proc save*(self: DbConn, t: WriteModel): int64 =
  let fields = getFields(t)
  let keys = fields.keys.join(",")
  let placeholders = fields.keys.mapIt("?").join(",")
  let query = &"""INSERT INTO ${t.tableName()} ({keys}) VALUES ({placeholders})"""
  self.insertID(sql query, fields.values)
