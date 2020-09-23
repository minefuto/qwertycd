import os
import qwertycdpkg/dirtable
import qwertycdpkg/extconfig
import qwertycdpkg/preview
import qwertycdpkg/status
import qwertycdpkg/ui

proc main() =
  let params = loadConfigFile()
  var dt = newDirtable(getCurrentDir())
  var p = newPreview()
  var s = newStatus()
  var isClear = false

  s.errMsg = createCacheDir()
  if s.errMsg == "":
    s.errMsg = writeDirPath(dt.path)
  startUi()

  while true:
    writeUi(dt, p, s, isClear, params)
    if isClear:
      isClear = false
    keyAction(dt, p, s, isClear)

when isMainModule:
  main()
