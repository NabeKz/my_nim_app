import std/osproc
import std/strutils
import std/strformat
import std/sequtils

type
  ColumnType = enum
    INT = "int"
    STRING = "string"

  Column = ref object
    name: string
    columnType: ColumnType

  Table = ref object
    name: string
    columns: seq[Column]

proc to(columnType: string): ColumnType =
  case columnType.toUpper()
  of "TEXT": STRING
  of "INTEGER": INT
  else:
    raise newException(ValueError, columnType & " is invalid")


proc createColumn(line: string): Column =
  let splited = line.split(" ", maxsplit = 2)
  Column(
    name: splited[0],
    columnType: to(splited[1])
  )

func `$`(column: Column): string =
  column.name & ": " & $column.columnType

proc fetchTables(filename: string): seq[string] =
  let command = ["sqlite3", filename, ".tables"].join(" ")
  let (output, _) = execCmdEx(command)

  output
    .split("  ")
    .filterIt(it != " \n")


func pretty(line: string): string =
  if line[^1] == ',':
    line[0..^2]
  else:
    line

proc parseSchema(fileName: string, tableName: string): seq[Column] =
  let command = ["sqlite3", fileName, fmt"'.schema {tableName}'"].join(" ")
  let (output, _) = execCmdEx(command)

  output
    .split("\n")
    .filterIt(not it.startsWith("CREATE"))
    .filterIt(not it.endsWith(";"))
    .filterIt(not it.isEmptyOrWhitespace())
    .mapIt(it.strip().pretty())
    .mapIt(createColumn(it))


when isMainModule:
  let filename = "db.sqlite3"
  let tables = fetchTables(filename)

  for table in tables:
    let columns = parseSchema(filename, table)
    let table = Table(name: table, columns: columns)
    echo table.name
    echo table.columns
