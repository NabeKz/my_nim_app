import db_connector/db_sqlite
import std/macros
import std/options
import std/strutils

# 型安全なSQL定義のためのマクロ
type
  SqlQuery*[T] = object
    query*: string
    rowType*: typedesc[T]

  # よく使われる型のエイリアス
  User* = object
    id*: int
    name*: string
    email*: string

  Book* = object
    id*: int
    title*: string
    author*: string

# マクロで型安全なSQLクエリを定義
macro sql*(query: static[string], returnType: typedesc): untyped =
  result = quote do:
    SqlQuery[`returnType`](query: `query`, rowType: `returnType`)

# 型安全な実行関数
proc execute*[T](conn: DbConn, sqlQuery: SqlQuery[T]): seq[T] =
  let rows = conn.getAllRows(sql(sqlQuery.query))
  result = @[]
  
  when T is User:
    for row in rows:
      result.add(User(
        id: parseInt(row[0]),
        name: row[1],
        email: row[2]
      ))
  elif T is Book:
    for row in rows:
      result.add(Book(
        id: parseInt(row[0]),
        title: row[1],
        author: row[2]
      ))
  else:
    {.error: "Unsupported type for SQL query".}

proc executeOne*[T](conn: DbConn, sqlQuery: SqlQuery[T]): Option[T] =
  let results = conn.execute(sqlQuery)
  if results.len > 0:
    return some(results[0])
  return none(T)

# パラメータ化クエリのための型安全版
type
  SqlQueryWithParams*[T] = object
    query*: string
    params*: seq[string]

proc withParams*[T](sqlQuery: SqlQuery[T], params: seq[string]): SqlQueryWithParams[T] =
  SqlQueryWithParams[T](
    query: sqlQuery.query,
    params: params
  )

# 便利な単一パラメータ版
proc withParam*[T](sqlQuery: SqlQuery[T], param: string): SqlQueryWithParams[T] =
  sqlQuery.withParams(@[param])

proc execute*[T](conn: DbConn, sqlQuery: SqlQueryWithParams[T]): seq[T] =
  let rows = conn.getAllRows(sql(sqlQuery.query), sqlQuery.params)
  result = @[]
  
  when T is User:
    for row in rows:
      result.add(User(
        id: parseInt(row[0]),
        name: row[1],
        email: row[2]
      ))
  elif T is Book:
    for row in rows:
      result.add(Book(
        id: parseInt(row[0]),
        title: row[1],
        author: row[2]
      ))
  else:
    {.error: "Unsupported type for SQL query".}

proc executeOne*[T](conn: DbConn, sqlQuery: SqlQueryWithParams[T]): Option[T] =
  let results = conn.execute(sqlQuery)
  if results.len > 0:
    return some(results[0])
  return none(T)

# コンパイル時SQLチェック用のマクロ
macro sqlCheck*(query: static[string]): untyped =
  # 基本的なSQL構文チェック
  let q = query.toLowerAscii()
  if not (q.startsWith("select") or q.startsWith("insert") or 
          q.startsWith("update") or q.startsWith("delete")):
    error("Invalid SQL query: must start with SELECT, INSERT, UPDATE, or DELETE")
  
  # パラメータ数チェックなども可能
  result = newLit(query)

when isMainModule:
  echo "=== Type-Safe SQL Examples ==="
  
  let conn = open(":memory:", "", "", "")
  
  # テーブル作成
  conn.exec(sql"""
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL
    )
  """)
  
  conn.exec(sql"""
    CREATE TABLE IF NOT EXISTS books (
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      author TEXT NOT NULL
    )
  """)
  
  # データ挿入
  conn.exec(sql"INSERT OR REPLACE INTO users VALUES (1, 'Alice', 'alice@example.com')")
  conn.exec(sql"INSERT OR REPLACE INTO users VALUES (2, 'Bob', 'bob@example.com')")
  conn.exec(sql"INSERT OR REPLACE INTO books VALUES (1, 'Nim in Action', 'Dominik Picheta')")
  
  # 型安全なクエリ定義（コンパイル時にチェック）
  const getUsersQuery = sql("SELECT id, name, email FROM users", User)
  const getBooksQuery = sql("SELECT id, title, author FROM books", Book)
  const getUserByIdQuery = sql("SELECT id, name, email FROM users WHERE id = ?", User)
  
  # 実行 - 戻り値の型が保証される
  let users: seq[User] = conn.execute(getUsersQuery)
  echo "All users:"
  for user in users:
    echo "  ", user.name, " (", user.email, ")"
  
  let books: seq[Book] = conn.execute(getBooksQuery)
  echo "All books:"
  for book in books:
    echo "  ", book.title, " by ", book.author
  
  # パラメータ付きクエリ
  let specificUser: Option[User] = conn.executeOne(
    getUserByIdQuery.withParam("1")
  )
  
  if specificUser.isSome:
    let user = specificUser.get()
    echo "Found user: ", user.name
  
  # コンパイル時SQLチェック
  const validQuery = sqlCheck("SELECT * FROM users")
  echo "Valid query checked at compile time: ", validQuery
  
  # 以下はコンパイルエラーになる
  # const invalidQuery = sqlCheck("INVALID SQL")
  
  # 型が間違っていればコンパイルエラー
  # let wrongType: seq[Book] = conn.execute(getUsersQuery) # エラー！
  
  conn.close()
  echo "Type safety demonstrated!"