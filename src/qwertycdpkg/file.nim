import os, strformat

let cacheEnv = getEnv("XDG_CACHE_HOME", getHomeDir() / ".cache")
let cacheDir = cacheEnv / "qwertycd"
let cacheFile = cacheDir / "cache_dir"

proc createCacheDir*(path: string): string =
  try:
    createDir(cacheDir)
  except OSError:
    return fmt"'{cacheDir}' cannot be created."
  result = ""


proc writeDirPath*(path: string): string =
  try:
    var f: File = open(cacheFile, FileMode.fmWrite)
    defer: close(f)
    f.writeLine(path)
  except IOError:
    return fmt"'{cacheFile}' cannot be created."
  result = ""
