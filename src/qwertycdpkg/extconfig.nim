import deques, os, strformat
import illwill, parsetoml

let homeDir = getHomeDir() / ".qwertycd"

type ConfigParams* = object
  dirColor*: ForegroundColor
  symlinkColor*: ForegroundColor
  historySize*: int

proc initConfigParams(): ConfigParams =
  result.dirColor = fgBlue
  result.symlinkColor = fgMagenta
  result.historySize = 26

proc createHomeDir*(): string =
  try:
    createDir(homeDir)
  except OSError:
    return fmt"'{homeDir}' cannot be created."
  result = ""

proc writeCacheFile*(path: string): string =
  let cacheFile = homeDir / "cache_dir"
  try:
    var f: File = open(cacheFile, FileMode.fmWrite)
    defer: close(f)
    f.writeLine(path)
  except IOError:
    return fmt"Failed to write to '{cacheFile}'."
  result = ""

proc writeHistoryFile*(histories: var Deque[string],
                       path: string, size: int): string =
  let historyFile = homeDir / "history_dir"
  while histories.len >= size: histories.popLast()

  #if histories.len == size: histories.popLast()
  histories.addFirst(path)
  try:
    var f: File = open(historyFile, FileMode.fmWrite)
    defer: close(f)
    for path in histories:
      f.writeLine(path)
  except IOError:
    return fmt"Failed to write to '{historyFile}'."
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

proc parseConfigFile(toml: TomlValueRef):
                     tuple[cfg: ConfigParams, bookmarks: seq[string]] =
  result = (initConfigParams(), newSeq[string]())
  if toml.contains("Color"):
    if toml["Color"].contains("dir"):
      result.cfg.dirColor = parseColor(toml["Color"]["dir"].getStr())

  if toml.contains("Color"):
    if toml["Color"].contains("symlink"):
      result.cfg.symlinkColor = parseColor(toml["Color"]["symlink"].getStr())

  if toml.contains("History"):
    if toml["History"].contains("size"):
      result.cfg.historySize = toml["History"]["size"].getInt()

  if toml.contains("Bookmark"):
    if toml["Bookmark"].contains("path"):
      let paths = toml["Bookmark"]["path"]
      for i in 0 ..< paths.len:
        result.bookmarks.add(paths[i].getStr())

proc loadConfigFile*(): tuple[cfg: ConfigParams, bookmarks: seq[string]] =
  let configFile = homeDir / "qwertycd.toml"

  if not fileExists(configFile):
    result = (initConfigParams(), newSeq[string]())
  else:
    let toml = parsetoml.parseFile(configFile)
    result = parseConfigFile(toml)

proc loadHistoryFile*(): Deque[string] =
  let historyFile = homeDir / "history_dir"
  try:
    var f: File = open(historyFile, FileMode.fmRead)
    defer: close(f)
    result = initDeque[string]()
    while not f.endOfFile:
      result.addLast(f.readLine())
  except IOError:
    result = initDeque[string]()
