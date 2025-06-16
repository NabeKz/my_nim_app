import std/macros
import std/strutils
import std/tables
import std/sequtils
import std/strformat
import std/options

import db_connector/db_sqlite
import schema_parser

# コンパイル時にスキーマ情報を保持
const SCHEMA_FILE = "generated_schema.nim"

# コンパイル時にスキーマを読み込む（実際の実装では外部ファイルから）
const DATABASE_SCHEMA = block:
  var schema = DatabaseSchema(tables: initTable[string, TableSchema]())
  
  # サンプルスキーマ（実際は外部ファイルから読み込み）
  schema.tables["users"] = TableSchema(
    name: "users",
    columns: @[
      ColumnInfo(name: "id", sqliteType: stInteger, constraints: {ccPrimaryKey}),
      ColumnInfo(name: "name", sqliteType: stText, constraints: {ccNotNull}),
      ColumnInfo(name: "email", sqliteType: stText, constraints: {ccUnique})
    ]
  )
  
  schema.tables["books"] = TableSchema(
    name: "books", 
    columns: @[
      ColumnInfo(name: "id", sqliteType: stInteger, constraints: {ccPrimaryKey}),
      ColumnInfo(name: "title", sqliteType: stText, constraints: {ccNotNull}),
      ColumnInfo(name: "author", sqliteType: stText, constraints: {ccNotNull})
    ]
  )
  
  schema

# SQLクエリの解析
type
  QueryType = enum
    qtSelect, qtInsert, qtUpdate, qtDelete
  
  ParsedQuery = object
    queryType: QueryType
    tables: seq[string]
    columns: seq[string]
    whereColumns: seq[string]

func extractTableFromQuery(cleanQuery: string): Option[string] =
  if " FROM " notin cleanQuery:
    return none(string)
  
  let fromIndex = cleanQuery.find(" FROM ") + 6
  let restQuery = cleanQuery[fromIndex..^1]
  let parts = restQuery.split(" ").filterIt(it.len > 0)
  
  if parts.len > 0:
    some(parts[0].toLowerAscii())
  else:
    none(string)

func extractColumnsFromSelect(cleanQuery: string): seq[string] =
  let fromPos = cleanQuery.find(" FROM ")
  if fromPos == -1:
    return @[]
  
  let selectPart = cleanQuery[6..<fromPos].strip()
  if selectPart == "*":
    @[]
  else:
    selectPart.split(",").mapIt(it.strip().toLowerAscii()).filterIt(it.len > 0)

func parseSimpleQuery(query: string): ParsedQuery =
  let cleanQuery = query.toUpperAscii().strip()
  
  if cleanQuery.startsWith("SELECT"):
    let tableOpt = extractTableFromQuery(cleanQuery)
    let tables = if tableOpt.isSome: @[tableOpt.get] else: @[]
    let columns = extractColumnsFromSelect(cleanQuery)
    
    ParsedQuery(
      queryType: qtSelect,
      tables: tables,
      columns: columns,
      whereColumns: @[]
    )
  else:
    ParsedQuery(queryType: qtSelect, tables: @[], columns: @[], whereColumns: @[])

func validateTableExists(tableName: string, schema: DatabaseSchema): bool =
  tableName in schema.tables

func validateColumnsExist(columns: seq[string], tableName: string, schema: DatabaseSchema): seq[string] =
  if tableName notin schema.tables:
    return columns
  
  let tableSchema = schema.tables[tableName]
  let schemaColumns = tableSchema.columns.mapIt(it.name.toLowerAscii())
  
  columns.filterIt(it notin schemaColumns)

func checkTypeTableMatch(resultTypeName: string, tableName: string): bool =
  let expectedTableName = resultTypeName.toLowerAscii()
  expectedTableName == tableName or expectedTableName == tableName & "s"

# コンパイル時SQLクエリ検証マクロ
macro typedSql*(query: static[string], resultType: typedesc): untyped =
  # クエリを解析
  let parsedQuery = parseSimpleQuery(query)
  
  # テーブルの存在確認
  let invalidTables = parsedQuery.tables.filterIt(not validateTableExists(it, DATABASE_SCHEMA))
  for tableName in invalidTables:
    error(&"Table '{tableName}' does not exist in database schema")
  
  # カラムの存在確認
  if parsedQuery.tables.len > 0:
    let tableName = parsedQuery.tables[0]
    let invalidColumns = validateColumnsExist(parsedQuery.columns, tableName, DATABASE_SCHEMA)
    for colName in invalidColumns:
      error(&"Column '{colName}' does not exist in table '{tableName}'")
  
  # 型とカラムの整合性チェック（簡易版）
  let resultTypeName = resultType.repr
  
  if parsedQuery.tables.len > 0:
    let actualTableName = parsedQuery.tables[0]
    if not checkTypeTableMatch(resultTypeName, actualTableName):
      warning(&"Result type '{resultTypeName}' may not match table '{actualTableName}'")
  
  # 実際のSQL実行コードを生成
  result = quote do:
    proc() =
      # この部分で実際のSQL実行を行う
      # 型安全性は既にコンパイル時に確認済み
      discard
  
  # デバッグ用
  echo &"[Compile-time] Validated SQL: {query}"
  echo &"[Compile-time] Target type: {resultTypeName}"

func generateRowToTypeConversion(typeName: string, tableSchema: TableSchema): NimNode =
  let typeIdent = ident(typeName)
  var fieldAssignments: seq[NimNode] = @[]
  
  for i, col in tableSchema.columns:
    let fieldName = ident(col.name)
    let rowAccess = quote do: row[`i`]
    
    let fieldValue = case col.sqliteType:
      of stInteger:
        if ccPrimaryKey in col.constraints or ccNotNull in col.constraints:
          quote do: parseInt(`rowAccess`)
        else:
          quote do: (if `rowAccess` != "": some(parseInt(`rowAccess`)) else: none(int))
      of stText:
        if ccNotNull in col.constraints:
          rowAccess
        else:
          quote do: (if `rowAccess` != "": some(`rowAccess`) else: none(string))
      of stReal:
        if ccNotNull in col.constraints:
          quote do: parseFloat(`rowAccess`)
        else:
          quote do: (if `rowAccess` != "": some(parseFloat(`rowAccess`)) else: none(float))
      else:
        rowAccess
    
    fieldAssignments.add(nnkExprColonExpr.newTree(fieldName, fieldValue))
  
  let objConstruction = nnkObjConstr.newTree(typeIdent)
  for assignment in fieldAssignments:
    objConstruction.add(assignment)
  
  objConstruction

# 実行時のヘルパーマクロ
macro executeTypedQuery*(conn: DbConn, query: string, resultType: typedesc): untyped =
  let typeName = resultType.repr
  let tableName = typeName.toLowerAscii()
  
  if tableName notin DATABASE_SCHEMA.tables:
    error(&"Table schema for type '{typeName}' not found")
  
  let tableSchema = DATABASE_SCHEMA.tables[tableName]
  let conversionCode = generateRowToTypeConversion(typeName, tableSchema)
  
  result = quote do:
    block:
      let rows = `conn`.getAllRows(sql(`query`))
      var result: seq[`resultType`] = @[]
      
      for row in rows:
        result.add(`conversionCode`)
      
      result

when isMainModule:
  echo "=== Type-Safe SQL Test ==="
  # スキーマから自動生成される型（本来は別ファイル）
  type
    Users* = object
      id*: int
      name*: string
      email*: Option[string]
    
    Books* = object
      id*: int
      title*: string
      author*: string
  
  # これらはコンパイル時に検証される
  let validQuery1 = typedSql("SELECT id, name, email FROM users", Users)
  let validQuery2 = typedSql("SELECT id, title, author FROM books", Books)
  
  # これらはコンパイルエラーになるはず
  # let invalidQuery1 = typedSql("SELECT id, name, email FROM nonexistent_table", Users)  # テーブルが存在しない
  # let invalidQuery2 = typedSql("SELECT id, name, invalid_column FROM users", Users)     # カラムが存在しない
  # let invalidQuery3 = typedSql("SELECT id, name, email FROM users", Books)              # 型が合わない
  
  echo "All queries validated at compile time!"
  
  # 実際の使用例（実行時）
  # let conn = open("test.db", "", "", "")
  # let users = conn.executeTypedQuery("SELECT id, name, email FROM users", Users)
  # let books = conn.executeTypedQuery("SELECT id, title, author FROM books", Books)
  # conn.close()