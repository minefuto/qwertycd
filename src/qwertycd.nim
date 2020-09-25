import os
import qwertycdpkg/[dirtable, extconfig, preview, status, ui]

proc main() =
  let (cfg, bookmarks) = loadConfigFile()
  let histories = loadHistoryFile()
  var dt = newDirtable(getCurrentDir(), bookmarks, histories)
  var p = newPreview()
  var s = newStatus()

  s.infoMsg = createCacheDir()
  if s.infoMsg == "":
    s.infoMsg = writeCacheFile(dt.path)
  startUi()

  while true:
    writeUi(dt, p, s, cfg)

when isMainModule:
  main()
