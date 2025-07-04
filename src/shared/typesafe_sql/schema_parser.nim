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
    nimType*: string
    constraints*: set[ColumnConstraint]
    defaultValue*: Option[string]

  DatabaseSchema* = object
    tables*: Table[string, seq[ColumnInfo]]

func parseColumnType(typeStr: string): SqliteType =
  let upperType = typeStr.toUpperAscii().strip()
  case upperType:
    of "INTEGER", "INT": stInteger
    of "TEXT", "VARCHAR": stText
    of "REAL", "FLOAT", "DOUBLE": stReal
    of "BLOB": stBlob
    else: stText  # デフォルトはTEXT

func parseConstraints(constraintStr: string): set[ColumnConstraint] =
  let upperStr = constraintStr.toUpperAscii()
  if "PRIMARY KEY" in upperStr:
    result.incl(ccPrimaryKey)
  if "NOT NULL" in upperStr:
    result.incl(ccNotNull)
  if "UNIQUE" in upperStr:
    result.incl(ccUnique)
  if "AUTOINCREMENT" in upperStr:
    result.incl(ccAutoIncrement)

func getAtOrDefault[T](s: seq[T], index: int, default: T): T =
  if index < s.len: s[index] else: default

func isColumnDefinition(colDef: string): bool =
  let parts = colDef.strip().split(re"\s+")
  let hasEnoughParts = parts.len >= 2
  let firstPart = parts.getAtOrDefault(0, "").toUpperAscii()
  let isNotTableConstraint = firstPart notin ["PRIMARY", "FOREIGN", "UNIQUE", "CHECK", "CONSTRAINT"]
  
  return hasEnoughParts and isNotTableConstraint

func parseColumnDef(colDef: string): ColumnInfo =
  let parts = colDef.strip().split(re"\s+")
  let colName = parts[0].strip(chars = {'"', '`', '['})
  let colType = parseColumnType(parts[1])
  let constraints = parseConstraints(colDef)
  ColumnInfo(name: colName, sqliteType: colType, constraints: constraints)

proc parseCreateTableStatement(createSql: string): (string, seq[ColumnInfo]) =
  # CREATE TABLE文をパースしてテーブルスキーマを抽出
  let cleanSql = createSql.multiReplace([("\n", " "), ("\t", " ")])
  
  # テーブル名を抽出
  let tableNamePattern = re"CREATE TABLE (?:IF NOT EXISTS )?(\w+)"
  var tableName = ""
  var matches : array[1, string]
  if cleanSql.match(tableNamePattern, matches):
    tableName = matches[0]
  
  # カラム定義部分を抽出（括弧内の内容）
  let startIdx = cleanSql.find('(')
  let endIdx = cleanSql.rfind(')')
  let hasValidParens = startIdx != -1 and endIdx != -1 and startIdx < endIdx
  let columns = if hasValidParens:
    cleanSql[startIdx + 1 ..< endIdx].strip().split(",").mapIt(it.strip()).filterIt(it.len > 0)
  else:
    @[]
  
  # 各カラム定義をパース
  let parsedColumns = columns.filterIt(isColumnDefinition(it)).mapIt(parseColumnDef(it))
  (tableName, parsedColumns)


# ヘルパー関数: 有効なテーブルかチェック
func isValidTable(tablePair: (string, seq[ColumnInfo])): bool =
  tablePair[0].len > 0

# sqlite_masterクエリ結果から直接解析（関数型スタイル）
proc parseSchemaFromCreateStatements*(createStatements: seq[string]): DatabaseSchema =
  let tables = createStatements
    .filterIt(it.strip().len > 0)
    .mapIt(parseCreateTableStatement(it))
    .filterIt(isValidTable(it))
    .toTable
  
  DatabaseSchema(tables: tables)


# スキーマからNim型定義を生成
const sqliteToNimTypeMap = {
  stInteger: "int",
  stText: "string", 
  stReal: "float",
  stBlob: "seq[byte]",
  stNull: "string"
}.toTable

func sqliteTypeToNimType(sqliteType: SqliteType, constraints: set[ColumnConstraint]): string =
  let isNotNull = ccNotNull in constraints or ccPrimaryKey in constraints
  let baseType = sqliteToNimTypeMap[sqliteType]
  
  if isNotNull or sqliteType == stNull:
    baseType
  else:
    "Option[" & baseType & "]"

func generateNimTypeDefinition(tableName: string, columns: seq[ColumnInfo]): string =
  result = &"type\n  {tableName.capitalizeAscii()}* = ref object\n"
  
  for col in columns:
    let nimType = sqliteTypeToNimType(col.sqliteType, col.constraints)
    result.add(&"    {col.name}*: {nimType}\n")

func generateAllNimTypes*(dbSchema: DatabaseSchema): string =
  result = "# Auto-generated from database schema\n\n"
  result.add("import std/options\n\n")
  
  for tableName, columns in dbSchema.tables:
    result.add(generateNimTypeDefinition(tableName, columns))
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

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    isbn TEXT UNIQUE,
    price REAL
);

CREATE TABLE user_books (
    user_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    borrowed_at TEXT,
    PRIMARY KEY (user_id, book_id)
);
"""

  echo "=== Schema Parser Test ==="
  
  let dbSchema = parseSchemaFromCreateStatements(@[testSchema])
  
  echo "Parsed tables:"
  for tableName, columns in dbSchema.tables:
    echo &"  Table: {tableName}"
    for col in columns:
      echo &"    {col.name}: {col.sqliteType} {col.constraints}"
  
  echo "\n=== Generated Nim Types ==="
  echo generateAllNimTypes(dbSchema)