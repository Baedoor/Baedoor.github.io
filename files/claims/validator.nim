import std/strformat
import std/strutils
import parse

const
  BDATA = "BDATA"
  IOA   = "IOA"
  B3D   = "B3D"
  FSAM  = "FSAM"

proc stringChecker(s: string): bool =
  # true means warning
  if "discord" in s:
    return true
  elif startsWith(s, "http") and "baedoor.github.io" notin s:
    return true
  return false

proc err(link: string, name: string, cat: string, sub: string) =
  var linko = link
  if len(link) > 30:
    linko = link[0..30] & "(...)"
  echo fmt"{sub} | Found invalid link: {linko} in claim: {name} ({cat})."

for claim in bdata:
    for ca_data in claim.imgs:
        if stringChecker(ca_data[0]): err(ca_data[0], claim.name, "Concept Art", BDATA)
    for link in claim.file_raw:
        if stringChecker(link): err(link, claim.name, "Raw File", BDATA)
    for link in claim.file_mw:
        if stringChecker(link): err(link, claim.name, "MW File", BDATA)

for claim in ioa:
    for img in claim.imgs:
        if stringChecker(img[0]): err(img[0], claim.name, "Image", IOA)
    for file in claim.files:
        if stringChecker(file): err(file, claim.name, "File", IOA)

for claim in b3d:
    for img in claim.imgs:
        if stringChecker(img[0]): err(img[0], claim.name, "Image", B3D)
    for file in claim.files:
        if stringChecker(file): err(file, claim.name, "File", B3D)

for claim in fsam:
    for img in claim.imgs:
        if stringChecker(img[0]): err(img[0], claim.name, "Image", FSAM)
    for file in claim.files:
        if stringChecker(file): err(file, claim.name, "File", FSAM)

discard readLine(stdin)