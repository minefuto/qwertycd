import os, strformat, strutils

proc saveDirPath*(path: string): string =
  let cacheEnv = getEnv("XDG_CACHE_HOME", getHomeDir() / ".cache")
  let cacheDir = cacheEnv / "qwertycd"

  try:
    createDir(cacheDir)
  except OSError:
    let err = getCurrentExceptionMsg().splitLines[0]
    return fmt"'{cacheDir}' cannot be created because '{err}'."

  let cacheFile = cacheDir / "cache_dir"
  try:
    var f: File = open(cacheFile, FileMode.fmWrite)
    defer: close(f)
    f.writeLine(path)
  except IOError:
    let err = getCurrentExceptionMsg().splitLines[0]
    return fmt"'{cacheFile}' cannot be created because '{err}'."
  result = ""
