import db_connector/db_sqlite
import std/macros
import std/options
import std/strutils
import std/sequtils

# 型安全なSQL定義のためのマクロ
type
  SqlQuery*[T] = object
    query*: string
    rowType*: typedesc[T]


# マクロで型安全なSQLクエリを定義
macro sql*(query: static[string], returnType: typedesc): untyped =
  result = quote do:
    SqlQuery[`returnType`](query: `query`, rowType: `returnType`)

# 型変換インターフェース（各型で実装する必要がある）
# template fromRow*(t: typedesc[YourType], row: seq[string]): YourType


# 型安全な実行関数（fromRowが実装されている型のみ使用可能）
proc execute*[T](conn: DbConn, sqlQuery: SqlQuery[T]): seq[T] =
  let rows = conn.getAllRows(sql(sqlQuery.query))
  rows.mapIt(T.fromRow(it))

proc executeOne*[T](conn: DbConn, sqlQuery: SqlQuery[T]): Option[T] =
  let results = conn.execute(sqlQuery)
  if results.len == 1:
    some(results[0])
  else:
    none(T)

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
  rows.mapIt(T.fromRow(it))

proc executeOne*[T](conn: DbConn, sqlQuery: SqlQueryWithParams[T]): Option[T] =
  let results = conn.execute(sqlQuery)
  if results.len == 1:
    some(results[0])
  else:
    none(T)

# コンパイル時SQLチェック用のマクロ
macro sqlCheck*(query: static[string]): untyped =
  # 基本的なSQL構文チェック
  let q = query.toLowerAscii()
  if not (q.startsWith("select") or q.startsWith("insert") or 
          q.startsWith("update") or q.startsWith("delete")):
    error("Invalid SQL query: must start with SELECT, INSERT, UPDATE, or DELETE")
  
  # パラメータ数チェックなども可能
  result = newLit(query)

runnableExamples:
  # Define your domain types
  type
    User = object
      id: int
      name: string  
      email: string

  # Implement the fromRow conversion for your types
  template fromRow(t: typedesc[User], row: seq[string]): User =
    User(
      id: parseInt(row[0]),
      name: row[1],
      email: row[2]
    )

  # Setup database
  let conn = open(":memory:", "", "", "")
  conn.exec(sql"CREATE TABLE users (id INTEGER, name TEXT, email TEXT)")
  conn.exec(sql"INSERT INTO users VALUES (1, 'Alice', 'alice@example.com')")
  
  # Type-safe SQL queries
  let usersQuery = sql("SELECT id, name, email FROM users", User)
  let users: seq[User] = conn.execute(usersQuery)
  assert users.len == 1
  assert users[0].name == "Alice"
  
  # Parameterized queries
  let userByIdQuery = sql("SELECT id, name, email FROM users WHERE id = ?", User)
  let alice = conn.executeOne(userByIdQuery.withParam("1"))
  assert alice.isSome
  assert alice.get().name == "Alice"
  
  conn.close()