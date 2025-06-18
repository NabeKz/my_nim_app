#!/usr/bin/env nim
## スキーマ生成機能のテストプログラム
## インメモリデータベースを使用してテストを実行

import std/strformat
import std/strutils
import std/sequtils
import std/tables
import db_connector/db_sqlite
from ../src/shared/schema_parser import parseSchemaFromCreateStatements, generateAllNimTypes, DatabaseSchema, ColumnConstraint, ccPrimaryKey, ccNotNull, ccUnique, ccAutoIncrement

proc testSchemaGeneration*() =
  echo "=== スキーマ生成機能テスト ==="
  
  # テスト用のインメモリデータベースを作成
  let conn = open(":memory:", "", "", "")
  defer: conn.close()
  
  # サンプルテーブルを作成
  conn.exec(sql"""
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE,
      age INTEGER,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  """)
  
  conn.exec(sql"""
    CREATE TABLE books (
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      author TEXT NOT NULL,
      isbn TEXT UNIQUE,
      price REAL,
      published_year INTEGER
    )
  """)
  
  conn.exec(sql"""
    CREATE TABLE user_books (
      user_id INTEGER NOT NULL,
      book_id INTEGER NOT NULL,
      borrowed_at TEXT,
      returned_at TEXT,
      PRIMARY KEY (user_id, book_id),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (book_id) REFERENCES books(id)
    )
  """)
  
  echo "\n✓ テストテーブル作成完了"
  
  # スキーマ情報を取得
  let rows = conn.getAllRows(sql"SELECT sql FROM sqlite_master WHERE type='table' AND sql IS NOT NULL")
  let createStatements = rows.mapIt(it[0])
  
  echo "\n📋 取得したCREATE文:"
  for i, stmt in createStatements:
    echo &"[{i+1}] {stmt.replace(\"\\n\", \" \").strip()}"
  
  # スキーマを解析
  let dbSchema = parseSchemaFromCreateStatements(createStatements)
  
  echo "\n🔍 解析結果:"
  for tableName, tableSchema in dbSchema.tables:
    if tableName != "sqlite_sequence":  # システムテーブルは除外
      echo &"  📊 テーブル: {tableName}"
      for col in tableSchema.columns:
        let constraintStr = if col.constraints.card == 0: "" else: &" {col.constraints}"
        echo &"    - {col.name}: {col.sqliteType}{constraintStr}"
  
  # Nim型定義を生成
  let typeCode = generateAllNimTypes(dbSchema)
  
  echo "\n🏗️  生成されるNim型定義:"
  echo "```nim"
  for line in typeCode.split("\\n"):
    if line.strip().len > 0:
      echo line
  echo "```"
  
  # 実際にファイルに出力してテスト
  writeFile("test_generated_types.nim", typeCode)
  echo "\n💾 test_generated_types.nim に出力完了"
  
  # スキーマ定数ファイルも生成
  var nimCode = """# Test-generated database schema

import std/tables
import std/options
import src/shared/schema_parser

const TEST_SCHEMA* = block:
  var schema = DatabaseSchema(tables: initTable[string, TableSchema]())
  
"""
  
  # システムテーブル以外を追加
  for tableName, tableSchema in dbSchema.tables:
    if tableName != "sqlite_sequence":
      nimCode.add(&"  schema.tables[\"{tableName}\"] = TableSchema(\\n")
      nimCode.add(&"    name: \"{tableName}\",\\n")
      nimCode.add("    columns: @[\\n")
      
      for col in tableSchema.columns:
        let constraintsStr = if col.constraints.card == 0:
          "{}"
        else:
          var parts: seq[string] = @[]
          if ccPrimaryKey in col.constraints: parts.add("ccPrimaryKey")
          if ccNotNull in col.constraints: parts.add("ccNotNull") 
          if ccUnique in col.constraints: parts.add("ccUnique")
          if ccAutoIncrement in col.constraints: parts.add("ccAutoIncrement")
          "{" & parts.join(", ") & "}"
        
        nimCode.add(&"      ColumnInfo(name: \"{col.name}\", sqliteType: {col.sqliteType}, constraints: {constraintsStr}),\\n")
      
      nimCode.add("    ]\\n")
      nimCode.add("  )\\n\\n")
  
  nimCode.add("  schema\\n")
  
  writeFile("test_db_schema.nim", nimCode)
  echo "💾 test_db_schema.nim に出力完了"
  
  echo "\n✅ スキーマ生成テスト完了！"

when isMainModule:
  testSchemaGeneration()