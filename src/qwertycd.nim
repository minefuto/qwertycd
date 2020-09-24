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

  s.infoMsg = createCacheDir()
  if s.infoMsg == "":
    s.infoMsg = writeDirPath(dt.path)
  startUi()

  while true:
    writeUi(dt, p, s, params)

when isMainModule:
  main()
