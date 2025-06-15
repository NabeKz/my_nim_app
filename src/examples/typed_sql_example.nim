## 型安全なSQL使用例
## 
## この例では、コンパイル時にSQLクエリの型安全性を検証する仕組みを示しています。
## 実際のプロジェクトでは以下の手順で使用します：
##
## 1. nimble db_init         # データベース初期化
## 2. nimble schema_gen      # スキーマからNim型を自動生成
## 3. 型安全なクエリを記述   # コンパイル時に検証される

import ../shared/[type_safe_sql, schema_parser]
import db_connector/db_sqlite
import std/options

proc demonstrateTypeSafety*() =
  echo "=== 型安全なSQL使用例 ==="
  
  # 1. コンパイル時検証される正しいクエリ
  echo "\n[✓] 正しいクエリ（コンパイル時に検証済み）:"
  
  let validUserQuery = typedSql("SELECT id, name, email FROM users", Users)
  let validBookQuery = typedSql("SELECT id, title, author FROM books", Books)
  
  echo "  - SELECT id, name, email FROM users  → Users型"
  echo "  - SELECT id, title, author FROM books → Books型"
  
  # 2. コンパイルエラーになるクエリ（コメントアウト）
  echo "\n[✗] 以下のクエリはコンパイルエラーになります:"
  echo "  - 存在しないテーブル: SELECT * FROM nonexistent_table"
  echo "  - 存在しないカラム:   SELECT id, invalid_column FROM users"
  echo "  - 型の不一致:        SELECT id, name FROM users → Books型"
  
  # コンパイルエラーの例（実際には使用時はコメントアウト）
  # let errorQuery1 = typedSql("SELECT * FROM nonexistent_table", Users)
  # let errorQuery2 = typedSql("SELECT id, invalid_column FROM users", Users) 
  # let errorQuery3 = typedSql("SELECT id, name, email FROM users", Books)

proc demonstrateSchemaGeneration*() =
  echo "\n=== スキーマ自動生成の例 ==="
  
  # テスト用のスキーマ
  let sampleSchema = """
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    description TEXT,
    category_id INTEGER,
    in_stock INTEGER DEFAULT 1
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    parent_id INTEGER
);
"""

  echo "SQLiteスキーマ:"
  echo sampleSchema
  
  let dbSchema = parseSchemaFromSqliteOutput(sampleSchema)
  
  echo "生成されるNim型定義:"
  echo generateAllNimTypes(dbSchema)

proc demonstrateWorkflow*() =
  echo "\n=== 実際の開発ワークフロー ==="
  
  echo """
1. データベース設計
   └─ CREATE TABLE文をマイグレーションファイルに記述

2. スキーマ生成
   └─ nimble schema_gen でNim型を自動生成

3. 型安全なクエリ作成
   └─ typedSql マクロでコンパイル時検証

4. スキーマ変更時
   └─ nimble schema_update でデータベースと型を更新

利点:
✓ コンパイル時に存在しないテーブル/カラムを検出
✓ 型の不一致を事前に発見
✓ スキーマ変更時の影響範囲を自動検出
✓ IDEでの補完とリファクタリング支援
"""

when isMainModule:
  demonstrateTypeSafety()
  demonstrateSchemaGeneration() 
  demonstrateWorkflow()
  
  echo "\n=== 実装完了 ==="
  echo "RustのSQLx風の型安全なSQL機能をNimで実現しました！"