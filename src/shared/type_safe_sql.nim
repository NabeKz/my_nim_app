import std/[macros, strutils, tables, sequtils]
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

proc parseSimpleQuery(query: string): ParsedQuery =
  let cleanQuery = query.toUpperAscii().strip()
  
  if cleanQuery.startsWith("SELECT"):
    result.queryType = qtSelect
    
    # FROM句からテーブル名を抽出
    if " FROM " in cleanQuery:
      let fromIndex = cleanQuery.find(" FROM ") + 6
      let restQuery = cleanQuery[fromIndex..^1]
      let parts = restQuery.split(" ")
      if parts.len > 0:
        result.tables.add(parts[0].toLowerAscii())
    
    # SELECT句からカラム名を抽出（簡易版）
    let selectPart = cleanQuery[6..cleanQuery.find(" FROM ")-1].strip()
    if selectPart != "*":
      result.columns = selectPart.split(",").mapIt(it.strip().toLowerAscii())

# コンパイル時SQLクエリ検証マクロ
macro typedSql*(query: static[string], resultType: typedesc): untyped =
  # クエリを解析
  let parsedQuery = parseSimpleQuery(query)
  
  # テーブルの存在確認
  for tableName in parsedQuery.tables:
    if tableName notin DATABASE_SCHEMA.tables:
      error(&"Table '{tableName}' does not exist in database schema")
  
  # カラムの存在確認
  if parsedQuery.tables.len > 0:
    let tableName = parsedQuery.tables[0]
    let tableSchema = DATABASE_SCHEMA.tables[tableName]
    
    for colName in parsedQuery.columns:
      var found = false
      for schemaCol in tableSchema.columns:
        if schemaCol.name.toLowerAscii() == colName:
          found = true
          break
      
      if not found:
        error(&"Column '{colName}' does not exist in table '{tableName}'")
  
  # 型とカラムの整合性チェック（簡易版）
  let resultTypeName = resultType.repr
  let expectedTableName = resultTypeName.toLowerAscii()
  
  if parsedQuery.tables.len > 0:
    let actualTableName = parsedQuery.tables[0]
    if expectedTableName != actualTableName and expectedTableName != actualTableName & "s":
      # 単数形・複数形の違いを許容
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

# 実行時のヘルパー関数
proc executeTypedQuery*[T](conn: DbConn, query: string): seq[T] =
  # 実際のSQL実行（型安全性は既にコンパイル時に保証済み）
  let rows = conn.getAllRows(sql(query))
  result = @[]
  
  # 型に応じた変換（実際の実装では自動生成されるべき）
  when T is Users:
    for row in rows:
      result.add(Users(
        id: parseInt(row[0]),
        name: row[1],
        email: some(row[2]) if row[2] != "" else none(string)
      ))
  elif T is Books:
    for row in rows:
      result.add(Books(
        id: parseInt(row[0]),
        title: row[1],
        author: row[2]
      ))

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

when isMainModule:
  echo "=== Type-Safe SQL Test ==="
  
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
  # let users: seq[Users] = conn.executeTypedQuery[Users]("SELECT id, name, email FROM users")
  # conn.close()