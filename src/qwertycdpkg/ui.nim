import mimetypes, os, osproc, strutils, strformat
import illwill
import dirtable, extconfig, preview, status

const AppName = "qwertycd v0.1.2"

proc isBinary(path: string): bool =
  var p = path.replace(" ", "\\ ")
  if findExe("file", true) == "":
    var m = newMimetypes()
    result = not m.getMimetype(path.splitFile.ext).contains("text")
  else:
    let (cmd, _) = execCmdEx("file --mime " & p)
    result = cmd.contains("charset=binary")

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc exitProc(msg: string) {.noconv.} =
  illwillDeinit()
  showCursor()
  if msg != "": echo msg
  quit(0)

proc startUi*() =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

proc writeUi*(dt: DirTable, p: Preview, s: Status, cfg: ConfigParams) =
  var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  dt.refreshHeight(tb.height - 4)
  p.refreshWidth(tb.width)

  # draw TopLine
  let topInfo: string = case dt.mode
  of Normal: dt.path
  of Bookmark: "Bookmark"
  of History: "History"

  if tb.height > 0 and tb.width > 0:
    tb.setStyle({styleReverse})
    tb.write(0, 0, topInfo)
    if topInfo.len < tb.width - (AppName.len + 5):
      tb.fill(topInfo.len, 0, tb.width - (AppName.len + 1), 0)
      tb.write(tb.width - AppName.len, 0, AppName)
    else:
      tb.fill(topInfo.len, 0, tb.width - 1, 0)
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
      tb.setForegroundColor(cfg.symlinkColor)
    elif entry.mark == "/":
      tb.setForegroundColor(cfg.dirColor)

    if dt.mode == Normal:
      tb.write(3, i + 2, entry.path.splitPath.tail, entry.mark)
    else:
      tb.write(3, i + 2, normalizePathEnd(entry.path))

    tb.write(1, i + 2, styleBright, dt.getQwerty(i))
    tb.resetAttributes()

  # draw Preview
  if (p.text != "") and tb.height > 3 and tb.width > 0:
    tb.fill(p.x, 1, tb.width - 1, tb.height - 2)
    tb.drawRect(p.x, 1, tb.width, tb.height - 2, doubleStyle = true)
    for i, line in p.readLine():
      if i > tb.height - 5: break
      tb.write(p.x + 1, i + 2, line)

  tb.display()
  sleep(20)

  # key Action
  let key = getKey()
  case key
  of Key.None: discard
  of Key.Tab: dt.toggleMode()
  of Key.Enter:
    if dt.mode == Normal:
      s.infoMsg = writeCacheFile(dt.path)
      s.infoMsg = writeHistoryFile(dt.histories, dt.path, cfg.historySize)
      exitProc(s.infoMsg)
    else: discard
  of Key.Escape:
    s.clearStatusMsg()
    p.updateTextToClear()
  of Key.QuestionMark:
    s.clearStatusMsg()
    p.updateTextToHelp()
  of Key.GreaterThan:
    s.infoMsg = p.plusX()
  of Key.LessThan:
    s.infoMsg = p.minusX()
  of Key.CtrlN:
    s.infoMsg = dt.plusCurIndex()
  of Key.CtrlP:
    s.infoMsg = dt.minusCurIndex()
  of Key.CtrlL:
    s.clearInfoMsg(); tb.clear(); tb.display()
  of Key.Tilde:
    if dt.mode == Normal:
      s.clearInfoMsg()
      dt.updatePath(getHomeDir().normalizePathEnd())
    else: discard
  of Key.Minus:
    if dt.mode == Normal:
      s.infoMsg = dt.updatePathToParentDir()
    else: discard
  of Key.Dot:
    if dt.mode == Normal:
      s.infoMsg = dt.toggleShowHidden()
    else: discard
  of Key.Q, Key.W, Key.E, Key.R, Key.T, Key.Y, Key.U, Key.I, Key.O,
     Key.P, Key.A, Key.S, Key.D, Key.F, Key.G, Key.H, Key.J, Key.K,
     Key.L, Key.Z, Key.X, Key.C, Key.V, Key.B, Key.N, Key.M:
    let index = dt.getQwertyIndex($key)
    var entry: Entry
    try:
      entry = dt.calcCurEntries()[index]
    except IndexDefect:
      s.infoMsg = fmt"'{$key}' does not exist."
      return
    except OSError:
      s.infoMsg = fmt"'{entry.path}' cannot be opened."
      return

    if entry.mark == "/" or entry.mark.startsWith("@/"):
      dt.updatePath(entry.path)
      s.clearInfoMsg()
    elif entry.path.isBinary:
      s.infoMsg = fmt"'{entry.path}' cannot be opened " &
                 "because it is a binary file."
    else:
      s.infoMsg = p.updateTextToReadFile(entry.path)
      s.updateFileMsg(entry.path)
  of Key.ShiftQ, Key.ShiftW, Key.ShiftE, Key.ShiftR, Key.ShiftT, Key.ShiftY,
     Key.ShiftU, Key.ShiftI, Key.ShiftO, Key.ShiftP, Key.ShiftA, Key.ShiftS,
     Key.ShiftD, Key.ShiftF, Key.ShiftG, Key.ShiftH, Key.ShiftJ, Key.ShiftK,
     Key.ShiftL, Key.ShiftZ, Key.ShiftX, Key.ShiftC, Key.ShiftV, Key.ShiftB,
     Key.ShiftN, Key.ShiftM:
    let keyStr = $key
    let index = dt.getQwertyIndex($keyStr[^1])
    var entry: Entry
    try:
      entry = dt.calcCurEntries()[index]
    except IndexDefect:
      s.infoMsg = fmt"'{$keyStr[^1]}' does not exist."
      return
    except OSError:
      s.infoMsg = fmt"'{entry.path}' cannot be opened."
      return

    if entry.mark == "/" or entry.mark.startsWith("@/"):
      s.infoMsg = writeCacheFile(entry.path)
      s.infoMsg = writeHistoryFile(dt.histories, entry.path, cfg.historySize)
      exitProc(s.infoMsg)
    elif entry.path.isBinary:
      s.infoMsg = fmt"'{entry.path}' cannot be opened " &
                 "because it is a binary file."
    else:
      let editor = getEnv("EDITOR")
      if editor == "":
        s.infoMsg = "$EDITOR is not set."
      elif findExe(editor, true) == "":
        s.infoMsg = fmt"{editor} is not found."
      else:
        discard execShellCmd(editor & " " & entry.path)
  else:
    discard
