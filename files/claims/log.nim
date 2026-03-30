import std/private/osfiles
import std/strformat
import std/times

type
  LogMessageType* = enum
    INFO
    WARNING
    CRITICAL
  Logger* = object
    msg : seq[tuple[kind: LogMessageType, content: string, date: DateTime]]

proc startLogger* (): Logger =
    result.msg = @[]

proc dumpLogger* (l: Logger, ext: bool = false) =
    # ext = extended info (currently only timestamps)
    if fileExists("log.txt"): removeFile("log.txt")
    let file = open("log.txt", fmWrite)
    for msg in l.msg:
        let mdt = if ext: format(msg.date, "yyyy-MM-dd hh:mm:ss") & " | " else: ""
        file.writeLine(fmt"{mdt}{msg.kind} | {msg.content}")
    file.close()

proc log* (l: var Logger, msg: string, lmtype: LogMessageType = INFO) =
    l.msg.add((kind: lmtype, content: msg, date: now()))

var LOG* = startLogger() # initialises logger variable, so that you can use it by simple import