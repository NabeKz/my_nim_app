import db_connector/db_sqlite
import std/[options, strformat, sequtils]

type
  SqlxConnection* = DbConn

proc openSqlx*(filename: string): SqlxConnection =
  ## Open SQLite database connection
  result = open(filename, "", "", "")

proc closeSqlx*(conn: SqlxConnection) =
  ## Close database connection
  conn.close()

proc execute*(conn: SqlxConnection, query: string, args: varargs[string]): bool =
  ## Execute SQL query with parameters
  try:
    conn.exec(sql(query), args)
    return true
  except:
    return false

proc queryOne*[T](conn: SqlxConnection, query: string, args: varargs[string]): Option[T] =
  ## Query single row and return as Option
  try:
    let row = conn.getRow(sql(query), args)
    if row[0] == "":
      return none(T)
    # Note: This would need proper deserialization based on T
    return some(T.default)
  except:
    return none(T)

proc queryAll*(conn: SqlxConnection, query: string, args: varargs[string]): seq[Row] =
  ## Query multiple rows
  try:
    return conn.getAllRows(sql(query), args)
  except:
    return @[]

proc queryScalar*(conn: SqlxConnection, query: string, args: varargs[string]): string =
  ## Query single scalar value
  try:
    return conn.getValue(sql(query), args)
  except:
    return ""

# Query builder helpers (SQLx-like)
type
  QueryBuilder* = object
    query: string
    params: seq[string]

proc newQuery*(baseQuery: string): QueryBuilder =
  QueryBuilder(query: baseQuery, params: @[])

proc withParam*(qb: QueryBuilder, param: string): QueryBuilder =
  result = qb
  result.params.add(param)

proc fetch*(qb: QueryBuilder, conn: SqlxConnection): seq[Row] =
  return conn.queryAll(qb.query, qb.params)

proc fetchOne*(qb: QueryBuilder, conn: SqlxConnection): Option[Row] =
  let rows = conn.queryAll(qb.query, qb.params)
  if rows.len > 0:
    return some(rows[0])
  return none(Row)

proc fetchScalar*(qb: QueryBuilder, conn: SqlxConnection): string =
  return conn.queryScalar(qb.query, qb.params)

when isMainModule:
  import os
  
  proc runExamples() =
    echo "=== SQLx-style Usage Examples ==="
    
    # データベース接続
    let conn = openSqlx("test.db")
    defer: conn.closeSqlx()
    
    # テーブル作成
    let createTableResult = conn.execute("""
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL
      )
    """)
    echo "Create table: ", createTableResult
    
    # データ挿入
    let insertResult = conn.execute(
      "INSERT OR REPLACE INTO users (name, email) VALUES (?, ?)",
      "John Doe", "john@example.com"
    )
    echo "Insert result: ", insertResult
    
    # クエリビルダー使用例
    echo "\n=== Query Builder Examples ==="
    
    # 全件取得
    let allUsers = newQuery("SELECT * FROM users").fetch(conn)
    echo "All users: ", allUsers.len, " rows"
    for row in allUsers:
      echo "  Row: ", row
    
    # 単一行取得
    let oneUser = newQuery("SELECT * FROM users WHERE email = ?")
      .withParam("john@example.com")
      .fetchOne(conn)
    
    if oneUser.isSome:
      echo "Found user: ", oneUser.get()
    else:
      echo "User not found"
    
    # スカラー値取得
    let userCount = newQuery("SELECT COUNT(*) FROM users")
      .fetchScalar(conn)
    echo "User count: ", userCount
    
    # パラメータ化クエリ
    let usersByName = newQuery("SELECT * FROM users WHERE name LIKE ?")
      .withParam("%John%")
      .fetch(conn)
    echo "Users with 'John' in name: ", usersByName.len
    
    # クリーンアップ
    discard conn.execute("DROP TABLE IF EXISTS users")
    
    # テストファイル削除
    if fileExists("test.db"):
      removeFile("test.db")
  
  runExamples()