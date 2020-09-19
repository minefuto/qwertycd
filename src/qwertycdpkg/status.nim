import os, osproc, strutils

type Status* = ref object
  errMsg: string
  fileMsg: string

proc newStatus*(): Status =
  var s = new Status
  s.errMsg = ""
  s.filemsg = ""
  result = s

proc errMsg*(s: Status): string {.inline.} =
  result = s.errMsg

proc `errMsg=`*(s: Status, msg: string) {.inline.}  =
  s.errMsg = msg

proc clearErrMsg*(s: Status) =
  s.errMsg = ""

proc clearStatusMsg*(s: Status) =
  s.errMsg = ""
  s.fileMsg = ""

proc getStatusMsg*(s: Status): string =
  if s.errMsg == "":
    result = s.fileMsg
  else:
    result = s.errMsg

proc updateFileMsg*(s: Status, path: string) =
  if findExe("ls", true) == "":
    s.fileMsg = path
  else:
    let (cmd, _) = execCmdEx("ls -l " & path)
    s.fileMsg = cmd.splitLines[0]
