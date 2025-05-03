import std/osproc
import std/strutils
import std/sequtils

proc parseSchema(filename: string): seq[string] =
  let command = ["sqlite3", filename, ".schema"].join(" ")
  let (output, exitCode) = execCmdEx command
  
  output
    .split(";")
    .filterIt(it != "\n")
    .mapIt(it .replace("\n", ""))
  

let filename = "db.sqlite3"
echo parseSchema(filename)

