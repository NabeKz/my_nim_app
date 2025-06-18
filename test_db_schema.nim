# Test-generated database schema

import std/tables
import std/options
import src/shared/schema_parser

const TEST_SCHEMA* = block:
  var schema = DatabaseSchema(tables: initTable[string, TableSchema]())
  
  schema.tables["users"] = TableSchema(\n    name: "users",\n    columns: @[\n      ColumnInfo(name: "id", sqliteType: INTEGER, constraints: {ccPrimaryKey, ccAutoIncrement}),\n      ColumnInfo(name: "name", sqliteType: TEXT, constraints: {ccNotNull}),\n      ColumnInfo(name: "email", sqliteType: TEXT, constraints: {ccUnique}),\n      ColumnInfo(name: "age", sqliteType: INTEGER, constraints: {}),\n      ColumnInfo(name: "created_at", sqliteType: TEXT, constraints: {}),\n    ]\n  )\n\n  schema.tables["user_books"] = TableSchema(\n    name: "user_books",\n    columns: @[\n      ColumnInfo(name: "user_id", sqliteType: INTEGER, constraints: {ccNotNull}),\n      ColumnInfo(name: "book_id", sqliteType: INTEGER, constraints: {ccNotNull}),\n      ColumnInfo(name: "borrowed_at", sqliteType: TEXT, constraints: {}),\n      ColumnInfo(name: "returned_at", sqliteType: TEXT, constraints: {}),\n    ]\n  )\n\n  schema.tables["books"] = TableSchema(\n    name: "books",\n    columns: @[\n      ColumnInfo(name: "id", sqliteType: INTEGER, constraints: {ccPrimaryKey}),\n      ColumnInfo(name: "title", sqliteType: TEXT, constraints: {ccNotNull}),\n      ColumnInfo(name: "author", sqliteType: TEXT, constraints: {ccNotNull}),\n      ColumnInfo(name: "isbn", sqliteType: TEXT, constraints: {ccUnique}),\n      ColumnInfo(name: "price", sqliteType: REAL, constraints: {}),\n      ColumnInfo(name: "published_year", sqliteType: INTEGER, constraints: {}),\n    ]\n  )\n\n  schema\n