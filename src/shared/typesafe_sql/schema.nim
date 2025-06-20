const DATABASE_SCHEMA* = block:
  var schema = DatabaseSchema(tables: initTable[string, seq[ColumnInfo]]())
  
  # サンプルスキーマ（実際は外部ファイルから読み込み）
  schema.tables["users"] = @[
    ColumnInfo(name: "id", sqliteType: stInteger, nimType: "int", constraints: {ccPrimaryKey}),
    ColumnInfo(name: "name", sqliteType: stText, nimType: "string", constraints: {ccNotNull}),
    ColumnInfo(name: "email", sqliteType: stText, nimType: "string", constraints: {ccUnique})
  ]
  
  schema