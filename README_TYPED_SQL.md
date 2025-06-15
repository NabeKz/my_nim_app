# 型安全な SQL 実装

Rust の SQLx 風のコンパイル時型チェック機能を Nim で実現したプロトタイプです。

## 主要機能

### 1. スキーマパーサー (`src/shared/schema_parser.nim`)

- `sqlite3 db.sqlite3 .schema`の出力をパース
- CREATE TABLE 文からテーブル・カラム情報を抽出
- SQLite 型から Nim 型への自動マッピング

### 2. 型安全 SQL (`src/shared/type_safe_sql.nim`)

- `typedSql`マクロでコンパイル時検証
- テーブル・カラムの存在確認
- 型とスキーマの整合性チェック

### 3. 自動化されたワークフロー

```bash
nimble db_init        # データベース初期化
nimble schema_gen     # スキーマからNim型を生成
nimble schema_update  # DB + 型の更新
```

## 使用例

```nim
# コンパイル時に検証される型安全なクエリ
let users = typedSql("SELECT id, name, email FROM users", Users)
let books = typedSql("SELECT id, title, author FROM books", Books)

# これらはコンパイルエラーになる
# let error1 = typedSql("SELECT * FROM nonexistent", Users)  # テーブルが存在しない
# let error2 = typedSql("SELECT invalid FROM users", Users)  # カラムが存在しない
# let error3 = typedSql("SELECT id, name FROM users", Books) # 型が合わない
```

## 実装された検証

### コンパイル時チェック

- [x] テーブル存在確認
- [x] カラム存在確認
- [x] 型とテーブルの整合性
- [x] SQL 構文の基本チェック

### 自動生成

- [x] SQLite 型 → Nim 型マッピング
- [x] NOT NULL 制約 → Option 型の使い分け
- [x] PRIMARY KEY → 非 Optional 型

### ワークフロー

- [x] スキーマ取得の自動化
- [x] 型定義の自動生成
- [x] nimble タスクとの統合

## 制限事項

- 簡易的な SQL パーサー（SELECT 文の基本形のみ）
- 外部キー制約は未対応
- JOIN クエリの型推論は未実装
- 実行時の型変換エラーハンドリングは基本的なもの

## 拡張可能性

1. **より高度な SQL パーサー**

   - JOIN、サブクエリ対応
   - 複雑な WHERE 条件の解析

2. **マイグレーション統合**

   - スキーマ変更の自動検出
   - マイグレーションファイルとの同期

3. **IDE 統合**

   - Language Server Protocol 対応
   - クエリの補完・検証

4. **その他の DB 対応**
   - PostgreSQL、MySQL 等への拡張

このプロトタイプは、Nim でも型安全なデータベースアクセスが実現可能であることを示しています。
