# Package

version       = "0.1.0"
author        = "NabeKz"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["cli_tool"]


# Dependencies

requires "nim >= 2.2.0"

import os
import std/strutils
task cleanup, "cleanup binary":
  for src in walkDirRec("src"):
    let path = src.split(".")
    if path.len == 1:
      rmFile path[0]