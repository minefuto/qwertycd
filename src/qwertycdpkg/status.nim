import os, osproc, strutils

type Status* = ref object
  infoMsg: string
  fileMsg: string

proc newStatus*(): Status =
  var s = new Status
  s.infoMsg = ""
  s.filemsg = ""
  result = s

proc infoMsg*(s: Status): string {.inline.} =
  result = s.infoMsg

proc `infoMsg=`*(s: Status, msg: string) {.inline.}  =
  s.infoMsg = msg

proc clearInfoMsg*(s: Status) =
  s.infoMsg = ""

proc clearStatusMsg*(s: Status) =
  s.infoMsg = ""
  s.fileMsg = ""

proc getStatusMsg*(s: Status): string =
  if s.infoMsg == "":
    result = s.fileMsg
  else:
    result = s.infoMsg

proc updateFileMsg*(s: Status, path: string) =
  if findExe("ls", true) == "":
    s.fileMsg = path
  else:
    let (cmd, _) = execCmdEx("ls -l " & path)
    s.fileMsg = cmd.splitLines[0]
