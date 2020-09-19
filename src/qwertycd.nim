import os
import qwertycdpkg/dirtable
import qwertycdpkg/file
import qwertycdpkg/preview
import qwertycdpkg/status
import qwertycdpkg/ui

proc main() =
  var dt = newDirtable(getCurrentDir())
  var p = newPreview()
  var s = newStatus()
  var isClear = false

  s.errMsg = createCacheDir(dt.path)
  if s.errMsg == "":
    s.errMsg = writeDirPath(dt.path)
  startUi()

  while true:
    writeUi(dt, p, s, isClear)
    if isClear:
      isClear = false
    keyAction(dt, p, s, isClear)

when isMainModule:
  main()
