import strformat, strutils

const HelpMsg = """
Enter  : Change directory
Esc    : Close preview window
a-z    : Move to select directory/preview select file
Ctrl-C : Exit qwertycd
Ctrl-N : Move to next page
Ctrl-P : Move to previous page
Ctrl-L : Refresh screen
-      : Move to parent directory
~      : Move to home directory
.      : Toggle show hidden directory/file
?      : Open help window
""" 

type Preview* = ref object
  text: string
  width: int
  x: int
  move: int

proc text*(p: Preview): string {.inline.} =
  result = p.text

proc x*(p: Preview): int {.inline.} =
  result = p.x

proc newPreview*(): Preview =
  var p = new Preview
  p.text = HelpMsg
  p.width = -1
  p.x = p.width div 2
  p.move = 2
  result = p

proc plusX*(p: Preview): string =
  if p.x + p.move <= p.width:
    p.x += p.move
    result = ""
  else:
    p.x = p.width
    result = "Preview window size cannot be changed anymore."
 
proc minusX*(p: Preview): string =
  if p.x - p.move >= 0:
    p.x = p.x - p.move
    result = ""
  else:
    p.x = 0
    result = "Preview window size cannot be changed anymore."

proc updateTextToClear*(p: Preview) =
  p.text = ""

proc updateTextToHelp*(p: Preview) =
  p.text = HelpMsg

proc updateTextToReadFile*(p: Preview, path: string): string =
  try:
    var f = open(path, FileMode.fmRead)
    defer: close(f)
    p.text = f.readAll()
    result = ""
  except IOError:
    result = fmt"'{path}' cannot be opened."

proc refreshWidth*(p: Preview, width: int) =
  if p.width != width and width != 0:
    p.x = width div 2
  p.width = width

iterator readLine*(p: Preview): (int, string) =
  var res = p.text.splitLines
  var i = 0
  while i < res.len:
    yield (i, res[i])
    inc(i)
