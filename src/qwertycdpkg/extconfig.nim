import os, strformat
import illwill, parsetoml

let cacheDir = getEnv("XDG_CACHE_HOME", getHomeDir() / ".cache") / "qwertycd"

type ConfigParams* = object
  dirColor*: ForegroundColor
  symlinkColor*: ForegroundColor

proc initConfigParams(): ConfigParams =
  result.dirColor = fgBlue
  result.symlinkColor = fgMagenta

proc createCacheDir*(): string =
  try:
    createDir(cacheDir)
  except OSError:
    return fmt"'{cacheDir}' cannot be created."
  result = ""

proc writeDirPath*(path: string): string =
  let cacheFile = cacheDir / "cache_dir"
  try:
    var f: File = open(cacheFile, FileMode.fmWrite)
    defer: close(f)
    f.writeLine(path)
  except IOError:
    return fmt"'{cacheFile}' cannot be created."
  result = ""

proc parseColor(color: string): ForegroundColor =
  case color
  of "Black": result = fgBlack
  of "Red": result = fgRed
  of "Green": result = fgGreen
  of "Yellow": result = fgYellow
  of "Blue": result = fgBlue
  of "Magenta": result = fgMagenta
  of "Cyan": result = fgCyan
  of "White": result = fgWhite
  else: result = fgNone

proc parseConfigFile(toml: TomlValueRef): ConfigParams =
  result = initConfigParams()
  if toml.contains("Color"):
    if toml["Color"].contains("dir"):
      result.dirColor = parseColor(toml["Color"]["dir"].getStr())

  if toml.contains("Color"):
    if toml["Color"].contains("symlink"):
      result.symlinkColor = parseColor(toml["Color"]["symlink"].getStr())

proc loadConfigFile*(): ConfigParams =
  let configFile = getConfigDir() / "qwertycd" / "qwertycd.toml"

  if not fileExists(configFile):
    result = initConfigParams()
  else:
    let toml = parsetoml.parseFile(configFile)
    result = parseConfigFile(toml)
