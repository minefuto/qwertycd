# Package

version       = "0.1.3"
author        = "minefuto"
description   = "Terminal UI based cd command"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["qwertycd"]



# Dependencies

requires "nim >= 1.4.0"
requires "illwill >= 0.2.0"
requires "parsetoml >= 0.5.0"
when defined(windows):
  requires "regex >= 0.19.0"
