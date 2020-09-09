type Status* = ref object
  msg: string

proc newStatus*(): Status =
  var s = new Status
  s.msg = ""
  result = s

proc msg*(s: Status): string {.inline.} =
  result = s.msg

proc `msg=`*(s: Status, msg: string) {.inline.}  =
  s.msg = msg
