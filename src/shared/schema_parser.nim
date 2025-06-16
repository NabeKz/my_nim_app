import std/strutils
import std/tables
import std/re
import std/options
import std/strformat
import std/sequtils

# SQLite型からNim型へのマッピング
type
  SqliteType* = enum
    stInteger = "INTEGER"
    stText = "TEXT" 
    stReal = "REAL"
    stBlob = "BLOB"
    stNull = "NULL"

  ColumnConstraint* = enum
    ccPrimaryKey = "PRIMARY KEY"
    ccNotNull = "NOT NULL"
    ccUnique = "UNIQUE"
    ccAutoIncrement = "AUTOINCREMENT"

  ColumnInfo* = object
    name*: string
    sqliteType*: SqliteType
    constraints*: set[ColumnConstraint]
    defaultValue*: Option[string]

  TableSchema* = object
    name*: string
    columns*: seq[ColumnInfo]

  DatabaseSchema* = object
    tables*: Table[string, TableSchema]

proc parseColumnType(typeStr: string): SqliteType =
  let upperType = typeStr.toUpperAscii().strip()
  case upperType:
    of "INTEGER", "INT": stInteger
    of "TEXT", "VARCHAR": stText
    of "REAL", "FLOAT", "DOUBLE": stReal
    of "BLOB": stBlob
    else: stText  # デフォルトはTEXT

proc parseConstraints(constraintStr: string): set[ColumnConstraint] =
  result = {}
  let upperStr = constraintStr.toUpperAscii()
  if "PRIMARY KEY" in upperStr:
    result.incl(ccPrimaryKey)
  if "NOT NULL" in upperStr:
    result.incl(ccNotNull)
  if "UNIQUE" in upperStr:
    result.incl(ccUnique)
  if "AUTOINCREMENT" in upperStr:
    result.incl(ccAutoIncrement)

proc parseCreateTableStatement(createSql: string): TableSchema =
  # CREATE TABLE文をパースしてテーブルスキーマを抽出
  let cleanSql = createSql.multiReplace([("\n", " "), ("\t", " ")])
  
  # テーブル名を抽出
  let tableNamePattern = re"CREATE TABLE (?:IF NOT EXISTS )?(\w+)"
  var tableName = ""
  var matches : array[1, string]
  if cleanSql.match(tableNamePattern, matches):
    tableName = matches[0]
  
  result = TableSchema(name: tableName, columns: @[])
  
  # カラム定義部分を抽出
  let columnsPattern = re"\(\s*(.*)\s*\)"
  var columnsPart = ""
  var matches2 = findAll(cleanSql, columnsPattern)
  if matches2.len > 0:
    columnsPart = matches2[0]

  # 各カラム定義を分割（カンマで区切るが、括弧内は無視）
  var columns: seq[string] = @[]
  var current = ""
  var parenDepth = 0
  
  for c in columnsPart:
    case c:
      of '(':
        parenDepth += 1
        current.add(c)
      of ')':
        parenDepth -= 1
        current.add(c)
      of ',':
        if parenDepth == 0:
          columns.add(current.strip())
          current = ""
        else:
          current.add(c)
      else:
        current.add(c)

  if current.strip().len > 0:
    columns.add(current.strip())
  
  # 各カラム定義をパース
  for colDef in columns:
    let parts = colDef.strip().split(re"\s+")
    if parts.len >= 2:
      let colName = parts[0].strip(chars = {'"', '`', '['})
      let colType = parseColumnType(parts[1])
      let constraints = parseConstraints(colDef)
      
      result.columns.add(ColumnInfo(
        name: colName,
        sqliteType: colType,
        constraints: constraints
      ))

proc parseSchemaFromSqliteOutput(schemaOutput: string): DatabaseSchema =
  result = DatabaseSchema(tables: initTable[string, TableSchema]())
  
  # 各CREATE TABLE文を分割
  let statements = schemaOutput.split("CREATE TABLE").filterIt(it.strip().len > 0)
  
  for stmt in statements:  
    let fullStmt = "CREATE TABLE" & stmt
    if "CREATE TABLE" in fullStmt:
      let tableSchema = parseCreateTableStatement(fullStmt)
      if tableSchema.name.len > 0:
        result.tables[tableSchema.name] = tableSchema

# スキーマからNim型定義を生成
proc sqliteTypeToNimType(sqliteType: SqliteType, constraints: set[ColumnConstraint]): string =
  case sqliteType:
    of stInteger:
      if ccPrimaryKey in constraints: "int"
      else: "Option[int]"
    of stText:
      if ccNotNull in constraints: "string"
      else: "Option[string]"
    of stReal:
      if ccNotNull in constraints: "float"
      else: "Option[float]"
    of stBlob:
      if ccNotNull in constraints: "seq[byte]"
      else: "Option[seq[byte]]"
    of stNull:
      "Option[string]"

proc generateNimTypeDefinition(schema: TableSchema): string =
  result = &"type\n  {schema.name.capitalizeAscii()}* = object\n"
  
  for col in schema.columns:
    let nimType = sqliteTypeToNimType(col.sqliteType, col.constraints)
    result.add(&"    {col.name}*: {nimType}\n")

proc generateAllNimTypes(dbSchema: DatabaseSchema): string =
  result = "# Auto-generated from database schema\n\n"
  result.add("import std/options\n\n")
  
  for tableName, tableSchema in dbSchema.tables:
    result.add(generateNimTypeDefinition(tableSchema))
    result.add("\n")

when isMainModule:
  # テスト用のスキーマ
  let testSchema = """
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    age INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
"""

  echo "=== Schema Parser Test ==="
  
  let dbSchema = parseSchemaFromSqliteOutput(testSchema)
  # (tables: {"users": (name: "users", columns: @[]), "user_books": (name: "user_books", columns: @[]), "books": (name: "books", columns: @[])})
  
  # echo "Parsed tables:"
  # for tableName, tableSchema in dbSchema.tables:
  #   echo &"  Table: {tableName}"
  #   for col in tableSchema.columns:
  #     echo &"    {col.name}: {col.sqliteType} {col.constraints}"
  
  # echo "\n=== Generated Nim Types ==="
  # echo generateAllNimTypes(dbSchema)