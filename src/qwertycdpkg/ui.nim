import mimetypes, os, osproc, strutils, strformat
import illwill
import dirtable, extconfig, preview, status

const AppName = "qwertycd v0.1.1"

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc startUi*() =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

proc writeUi*(dt: DirTable, p: Preview, s: Status, isClear: bool, params: ConfigParams) =
  var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  dt.refreshHeight(tb.height - 4)
  p.refreshWidth(tb.width)

  # draw TopLine
  if tb.height > 0 and tb.width > 0:
    tb.setStyle({styleReverse})
    tb.write(0, 0, dt.path)
    if dt.path.len < tb.width - (AppName.len + 5):
      tb.fill(dt.path.len, 0, tb.width - (AppName.len + 1), 0)
      tb.write(tb.width - AppName.len, 0, AppName)
    else:
      tb.fill(dt.path.len, 0, tb.width - 1, 0)
  tb.resetAttributes()

  # draw BottomLine
  if tb.height > 1 and tb.width > 0:
    tb.write(0, tb.height - 1, s.getStatusMsg())

  # draw PageNumber
  if tb.height > 2 and tb.width > 0:
    tb.write(0, 1, "(", $dt.pageNum.cur, "/", $dt.pageNum.all, ")")

  # draw Entries
  for i, entry in dt.calcCurEntries():
    if entry.mark.startsWith('@'):
      tb.setForegroundColor(params.symlinkColor)
    elif entry.mark == "/":
      tb.setForegroundColor(params.dirColor)

    tb.write(3, i + 2, entry.path.splitPath.tail, entry.mark)
    tb.write(1, i + 2, styleBright, dt.getQwerty(i))

    tb.resetAttributes()

  # draw Preview
  if (p.text != "") and tb.height > 3 and tb.width > 0:
    tb.fill(p.x, 1, tb.width - 1, tb.height - 2)
    tb.drawRect(p.x, 1, tb.width, tb.height - 2, doubleStyle = true)
    for i, line in p.readLine():
      if i > tb.height - 5: break
      tb.write(p.x + 1, i + 2, line)

  if isClear:
    tb.clear()

  tb.display()
  sleep(20)

proc isBinary(path: string): bool =
  var p = path.replace(" ", "\\ ")
  if findExe("file", true) == "":
    var m = newMimetypes()
    result = not m.getMimetype(path.splitFile.ext).contains("text")
  else:
    let (cmd, _) = execCmdEx("file --mime " & p)
    result = cmd.contains("charset=binary")

proc keyAction*(dt: DirTable, p: Preview, s: Status, isClear: var bool) =
  let key = getKey()
  case key
  of Key.None: discard
  of Key.Enter: s.errMsg = writeDirPath(dt.path); exitProc()
  of Key.Escape: s.clearStatusMsg(); p.updateTextToClear()
  of Key.QuestionMark: s.clearStatusMsg(); p.updateTextToHelp()
  of Key.GreaterThan: s.errMsg = p.plusX()
  of Key.LessThan: s.errMsg = p.minusX()
  of Key.CtrlN: s.errMsg = dt.plusCurIndex()
  of Key.CtrlP: s.errMsg = dt.minusCurIndex()
  of Key.CtrlL: s.clearErrMsg(); isClear = true
  of Key.Tilde: s.clearErrMsg(); dt.updatePath(getHomeDir().normalizePathEnd())
  of Key.Minus: s.errMsg = dt.updatePathToParentDir()
  of Key.Dot: s.errMsg = dt.toggleShowHidden()
  else:
    let index = dt.getQwertyIndex($key)
    if index != -1:
      var entry: Entry
      try:
        entry = dt.calcCurEntries()[index]
      except IndexError:
        s.errMsg = fmt"'{$key}' does not exist."
        return
      except OSError:
        s.errMsg = fmt"'{entry.path}' cannot be opened."
        return

      if entry.mark == "/" or entry.mark.startsWith("@/"):
        dt.updatePath(entry.path)
        s.clearErrMsg()
      elif entry.path.isBinary:
        s.errMsg = fmt"'{entry.path}' cannot be opened " &
                   "because it is a binary file."
      else:
        s.errMsg = p.updateTextToReadFile(entry.path)
        s.updateFileMsg(entry.path)
    else:
      discard
