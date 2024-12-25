import std/json


type WriteModel* = concept x
  x.tableName() is string

type ReadModel* = concept x
  x.id is int64
  x.tableName() is string


proc parseJsonBody*(body: string): JsonNode =
  try: 
    parseJson body
  except:
    parseJson "{}"
