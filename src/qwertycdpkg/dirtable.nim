import algorithm, deques, os, strformat
when defined(windows): import regex

const Qwerty =
  @["Q", "W", "E", "R", "T", "Y", "U", "I",
    "O", "P", "A", "S", "D", "F", "G", "H",
    "J", "K", "L", "Z", "X", "C", "V", "B",
    "N", "M"]

type Mode* = enum
  Normal
  Bookmark
  History

type Entry* = object
  path: string
  mark: string
  isHidden: bool

type DirTable* = ref object
  path: string
  row: int
  entries: seq[Entry]
  curIndex: int
  pageNum: tuple[cur: int, all: int]
  showHidden: bool
  mode: Mode
  bookmarks: seq[string]
  histories*: Deque[string]

proc path*(e: Entry): string {.inline.} =
  result = e.path

proc mark*(e: Entry): string {.inline.} =
  result = e.mark

proc path*(dt: DirTable): string {.inline.} =
  result = dt.path

proc pageNum*(dt: DirTable): tuple[cur: int, all: int] {.inline.} =
  result = dt.pageNum

proc mode*(dt: DirTable): Mode {.inline.} =
  result = dt.mode

proc getMark(path: string): string =
  try:
    let f = getFileInfo(path, followSymlink = false)
    when defined(windows):
      case f.kind
      of pcLinkToDir: result = "@/"
      of pcLinkToFile: result = "@"
      of pcDir: result = "/"
      of pcFile: result = ""
    else:
      case f.kind
      of pcLinkToDir: result = "@/ -> " & expandSymlink(path)
      of pcLinkToFile: result = "@ -> " & expandSymlink(path)
      of pcDir: result = "/"
      of pcFile: result = ""
  except OSError:
    result = ""

proc initEntry(path: string): Entry =
  result.path = path
  result.mark = getMark(path)
  result.isHidden = isHidden(path)

proc pathCmp(x, y: Entry): int =
  if x.path < y.path: -1
  elif x.path == y.path: 0
  else: 1

proc updatePageNum(dt: DirTable) =
  if dt.entries.len == 0 or dt.row == 0:
    dt.pageNum.cur = 0
    dt.pageNum.all = 0
  else:
    dt.pageNum.cur = dt.curIndex div dt.row + 1
    if dt.entries.len mod dt.row == 0:
      dt.pageNum.all = dt.entries.len div dt.row
    else:
      dt.pageNum.all = dt.entries.len div dt.row + 1

proc updateEntries(dt: DirTable) =
  dt.curIndex = 0
  dt.entries = newSeq[Entry]()
  if dt.showHidden:
    for entry in dt.path.walkDir:
      dt.entries.add(entry.path.initEntry)
  else:
    for entry in dt.path.walkDir:
      if entry.path.initEntry.isHidden: continue
      else: dt.entries.add(entry.path.initEntry)
  dt.entries.sort(pathCmp)
  dt.updatePageNum()

proc updateEntries(dt: DirTable, entries: seq[string]) =
  dt.curIndex = 0
  dt.entries = newSeq[Entry]()
  for entry in entries:
    if dirExists(entry) or fileExists(entry):
      dt.entries.add(entry.initEntry)
  dt.updatePageNum()

proc updateEntries(dt: DirTable, entries: Deque[string]) =
  dt.curIndex = 0
  dt.entries = newSeq[Entry]()
  for entry in entries:
    if dirExists(entry) or fileExists(entry):
      dt.entries.add(entry.initEntry)
  dt.updatePageNum()

proc updatePath*(dt: DirTable, path: string) =
  dt.path = path
  dt.updateEntries()
  dt.mode = Normal

proc updatePathToParentDir*(dt: DirTable): string =
  when defined(windows):
    if dt.path.match(re"[A-Z]:$"):
      result = fmt"'{dt.path}' is root directory."
    else:
      dt.updatePath(dt.path.parentDir())
      result = ""
  else:
    if dt.path == "/":
      result = fmt"'{dt.path}' is root directory."
    else:
      dt.updatePath(dt.path.parentDir())
      result = ""

proc newDirTable*(path: string, bookmarks: seq[string],
                  histories: Deque[string]): DirTable =
  var dt = new DirTable
  dt.updatePath(path)
  dt.row = -1
  dt.showHidden = false
  dt.curIndex = 0
  dt.bookmarks = bookmarks
  dt.histories = histories
  result = dt

proc plusCurIndex*(dt: DirTable): string =
  if dt.curIndex + dt.row < dt.entries.len:
    dt.curIndex = dt.curIndex + dt.row
    result = ""
  else:
    result = "Next page does not exist."
  dt.updatePageNum()

proc minusCurIndex*(dt: DirTable): string =
  if dt.curIndex - dt.row < 0:
    dt.curIndex = 0
    result = "Previous page does not exist."
  else:
    dt.curIndex = dt.curIndex - dt.row
    result = ""
  dt.updatePageNum()

proc calcCurEntries*(dt: DirTable): seq[Entry] =
  if dt.row == 0: result = newSeq[Entry](0)
  else:
    result = dt.entries[dt.curIndex..^1]
    if result.len > dt.row:
      let index = dt.curIndex + dt.row - 1
      result = dt.entries[dt.curIndex..index]

proc getQwerty*(dt: DirTable, index: int): string =
  result = Qwerty[index]

proc getQwertyIndex*(dt: DirTable, key: string): int =
  result = -1
  for i, j in Qwerty:
    if j == key:
      result = i
      break

proc calcRow(height: int): int =
  result = Qwerty.len()
  if height < result: result = height
  if height < 0: result = 0

proc refreshHeight*(dt: DirTable, height: int) =
  if dt.row != calcRow(height):
    dt.curIndex = 0
  dt.row = calcRow(height)
  dt.updatePageNum()

proc toggleShowHidden*(dt: DirTable): string =
  dt.showHidden = not dt.showHidden
  dt.updateEntries()
  if dt.showHidden:
    result = "Show hidden: On"
  else:
    result = "Show hidden: Off"

proc toggleMode*(dt: DirTable) =
  if dt.mode == Mode.high:
    dt.mode = Mode.low
  else:
    inc(dt.mode)

  case dt.mode:
  of Normal: dt.updateEntries()
  of Bookmark: dt.updateEntries(dt.bookmarks)
  of History: dt.updateEntries(dt.histories)
