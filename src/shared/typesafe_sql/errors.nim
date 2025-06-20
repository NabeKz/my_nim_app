import std/macros
import std/strutils
import std/tables
import std/sequtils
import std/strformat
import std/options

import db_connector/db_sqlite
import schema_parser

# 宣言的プログラミング用ヘルパー
func orDefault[T](opt: Option[T], default: T): T =
  if opt.isSome: opt.get else: default

func orDefault[T](arr: seq[T], default: seq[T]): seq[T] =
  if arr.len > 0: arr else: default

func getAtOrDefault[T](arr: seq[T], index: int, default: T): T =
  if index < arr.len: arr[index] else: default

# エラーメッセージ生成関数
func tableNotFoundMsg*(table: string): string =
  &"Table '{table}' not found"

func columnNotFoundMsg*(column, table: string): string =
  &"Column '{column}' not found in {table}"

func fieldTypeMismatchMsg*(field, expected, actual: string): string =
  &"Field '{field}': expected {expected}, got {actual}"

func typeTableMismatchMsg*(typeName, table: string): string =
  &"Type '{typeName}' may not match table '{table}'"


# コンパイル時にスキーマを読み込む（実際の実装では外部ファイルから）
const DATABASE_SCHEMA = block:
  var schema = DatabaseSchema(tables: initTable[string, seq[ColumnInfo]]())
  
  # サンプルスキーマ（実際は外部ファイルから読み込み）
  schema.tables["users"] = @[
    ColumnInfo(name: "id", sqliteType: stInteger, nimType: "int", constraints: {ccPrimaryKey}),
    ColumnInfo(name: "name", sqliteType: stText, nimType: "string", constraints: {ccNotNull}),
    ColumnInfo(name: "email", sqliteType: stText, nimType: "string", constraints: {ccUnique})
  ]
  
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
  let parts = cleanQuery.rsplit(" FROM ", maxsplit = 1)
  let selectPart = parts[0][6..^1].strip()  # "SELECT "を除去
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


func validateColumnsExist(columns: seq[string], tableName: string, schema: DatabaseSchema): seq[string] =
  let tableColumns = schema.tables[tableName]
  let schemaColumns = tableColumns.mapIt(it.name.toLowerAscii())
  
  columns.filterIt(it notin schemaColumns)


func extractActualType(resultType: NimNode): NimNode =
  let typeImpl = resultType.getTypeImpl()
  if typeImpl.kind == nnkBracketExpr and typeImpl.len > 1:
    typeImpl[1].getTypeImpl()
  else:
    typeImpl

func extractTypeFields(actualType: NimNode): seq[tuple[name: string, typeName: string]] =
  if actualType.kind != nnkObjectTy or actualType[2].kind != nnkRecList:
    return @[]
  
  var fields: seq[tuple[name: string, typeName: string]] = @[]
  for fieldDef in actualType[2]:
    if fieldDef.kind == nnkIdentDefs:
      let fieldName = fieldDef[0].strVal.toLowerAscii()
      let fieldTypeName = fieldDef[^2].repr
      fields.add((fieldName, fieldTypeName))
  fields

func findSchemaColumn(fieldName: string, columns: seq[ColumnInfo]): Option[ColumnInfo] =
  for col in columns:
    if col.name.toLowerAscii() == fieldName:
      return some(col)
  none(ColumnInfo)

func validateTypeFieldTypeMatch(resultType: NimNode, tableName: string): void =
  if tableName notin DATABASE_SCHEMA.tables:
    return
    
  let columns = DATABASE_SCHEMA.tables[tableName]
  let actualType = extractActualType(resultType)
  let fields = extractTypeFields(actualType)
  
  for field in fields:
    let columnOpt = findSchemaColumn(field.name, columns)
    if columnOpt.isSome and columnOpt.get().nimType != field.typeName:
      let column = columnOpt.get()
      error(fieldTypeMismatchMsg(field.name, column.nimType, field.typeName))

func validateTypeFieldMatch(selectedColumns: seq[string], resultTypeName: string, tableName: string): seq[string] =
  if selectedColumns.len == 0:  # SELECT * の場合はスキップ
    return @[]
  
  # 簡易チェック: 型名とテーブル名が一致する場合のみ厳密チェック
  let expectedTableName = resultTypeName.toLowerAscii()
  if expectedTableName != tableName and expectedTableName != tableName & "s":
    return @[]  # 型名が一致しない場合はスキップ
  
  # テーブルのカラムと選択したカラムを比較
  if tableName in DATABASE_SCHEMA.tables:
    let tableColumns = DATABASE_SCHEMA.tables[tableName].mapIt(it.name.toLowerAscii())
    return selectedColumns.filterIt(it notin tableColumns)
  
  @[]

func validateTableTypeNameMatch(resultTypeName: string, tableName: string): void =
  let expectedTableName = resultTypeName.toLowerAscii()
  if expectedTableName != tableName and expectedTableName != tableName & "s":
    error(typeTableMismatchMsg(resultTypeName, tableName))

# コンパイル時SQLクエリ検証マクロ
macro typedSql*(query: static[string], resultType: typedesc): untyped =
  # クエリを解析
  let parsedQuery = parseSimpleQuery(query)
  
  # テーブルの存在確認
  let invalidTables = parsedQuery.tables.filterIt(it notin DATABASE_SCHEMA.tables)
  for tableName in invalidTables:
    error tableNotFoundMsg(tableName)
  
  let tableName = parsedQuery.tables[0]
  let resultTypeName = resultType.repr
  
  # 各種バリデーション
  let invalidColumns = validateColumnsExist(parsedQuery.columns, tableName, DATABASE_SCHEMA)
  for colName in invalidColumns:
    error columnNotFoundMsg(colName, tableName)
  
  let invalidFields = validateTypeFieldMatch(parsedQuery.columns, resultTypeName, tableName)
  for fieldName in invalidFields:
    error columnNotFoundMsg(fieldName, tableName)
  
  validateTypeFieldTypeMatch(resultType, tableName)
  validateTableTypeNameMatch(resultTypeName, tableName)
  
  # 普通のSQL実行を返す
  result = quote do:
    sql(`query`)


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