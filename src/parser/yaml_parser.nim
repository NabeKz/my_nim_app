import std/streams

type DataType = enum
  yString
  yNumber


when isMainModule:
  let values = """
  name:
    type: string
  """
  var s = newStringStream(values)

  for c in s.lines:
    echo c
