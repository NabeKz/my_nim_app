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
      ColumnInfo(name: "id", sqliteType: stInteger, nimType: "int", constraints: {ccPrimaryKey}),
      ColumnInfo(name: "name", sqliteType: stText, nimType: "string", constraints: {ccNotNull}),
      ColumnInfo(name: "email", sqliteType: stText, nimType: "string", constraints: {ccUnique})
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


func validateTypeFieldMatch(selectedColumns: seq[string], resultTypeName: string, tableName: string): seq[string] =
  if selectedColumns.len == 0:  # SELECT * の場合はスキップ
    return @[]
  
  # 簡易チェック: 型名とテーブル名が一致する場合のみ厳密チェック
  let expectedTableName = resultTypeName.toLowerAscii()
  if expectedTableName != tableName and expectedTableName != tableName & "s":
    return @[]  # 型名が一致しない場合はスキップ
  
  # テーブルのカラムと選択したカラムを比較
  if tableName in DATABASE_SCHEMA.tables:
    let tableColumns = DATABASE_SCHEMA.tables[tableName].columns.mapIt(it.name.toLowerAscii())
    return selectedColumns.filterIt(it notin tableColumns)
  
  @[]

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
  
  # SELECT文のカラムと型フィールドの一致チェック  
  if parsedQuery.tables.len > 0:
    let resultTypeName = resultType.repr
    let tableName = parsedQuery.tables[0]
    let invalidFields = validateTypeFieldMatch(parsedQuery.columns, resultTypeName, tableName)
    for fieldName in invalidFields:
      error(&"Selected column '{fieldName}' not found in table '{tableName}'")
    
    # 型の一致チェック
    if tableName in DATABASE_SCHEMA.tables:
      let tableSchema = DATABASE_SCHEMA.tables[tableName]
      let typeImpl = resultType.getTypeImpl()
      
      # typedesc[T]の場合、T部分を取得
      let actualType = if typeImpl.kind == nnkBracketExpr and typeImpl.len > 1:
        typeImpl[1].getTypeImpl()
      else:
        typeImpl
      
      debugEcho &"Actual type kind: {actualType.kind}"
      if actualType.len > 2:
        debugEcho &"ActualType[2] kind: {actualType[2].kind}"
      
      if actualType.kind == nnkObjectTy and actualType[2].kind == nnkRecList:
        for fieldDef in actualType[2]:
          if fieldDef.kind == nnkIdentDefs:
            let fieldName = fieldDef[0].strVal.toLowerAscii()
            let fieldTypeNode = fieldDef[^2]
            let fieldTypeName = fieldTypeNode.repr
            
            # スキーマから対応するカラムを検索
            for col in tableSchema.columns:
              if col.name.toLowerAscii() == fieldName:
                debugEcho &"Field '{fieldName}': schema='{col.nimType}' vs actual='{fieldTypeName}'"
                if col.nimType != fieldTypeName:
                  error(&"Type mismatch for field '{fieldName}': expected '{col.nimType}' but got '{fieldTypeName}'")
                break
  
  # テーブル名と型名の簡易チェック（warning）
  if parsedQuery.tables.len > 0:
    let resultTypeName = resultType.repr
    let actualTableName = parsedQuery.tables[0]
    let expectedTableName = resultTypeName.toLowerAscii()
    if expectedTableName != actualTableName and expectedTableName != actualTableName & "s":
      error(&"Result type '{resultTypeName}' may not match table '{actualTableName}'")
  
  # 普通のSQL実行を返す
  result = quote do:
    sql(`query`)
  
  # デバッグ用
  debugEcho "[Compile-time] Validated SQL: $1" % [query]
  debugEcho "[Compile-time] Target type: $1" % [resultType.repr]


when isMainModule:
  echo "=== Type-Safe SQL Test ==="
  # スキーマから自動生成される型（本来は別ファイル）
  type
    Users* = object
      name*: string
    
  
  # これらはコンパイル時に検証される
  let validQuery1 = typedSql("SELECT name FROM users", Users)
  # let validQuery2 = typedSql("SELECT id, title, author FROM books", Books)
  
  # これらはコンパイルエラーになるはず
  # let invalidQuery1 = typedSql("SELECT id, name, email FROM nonexistent_table", Users)  # テーブルが存在しない
  # let invalidQuery2 = typedSql("SELECT id, name, invalid_column FROM users", Users)     # カラムが存在しない
  
  echo "All queries validated at compile time!"
  
  # 実際の使用例（実行時）
  # let conn = open("test.db", "", "", "")
  # let rows = conn.getAllRows(validQuery1)
  # conn.close()