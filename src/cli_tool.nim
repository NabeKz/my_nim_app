import std/strutils

import cli_tool/submodule
import cli_tool/document


when isMainModule:
  let str = """
  |no|name|
  |---|---|
  |a|b|
  |c|d|
  """

  for s in str.parse:
    echo s
