import std/enumutils
import std/strformat
import std/strutils
import std/random
import odsreader

randomize()

type
  ClaimPriority = enum
    CRITICAL
    HIGH
    MEDIUM
    LOW
    UNKNOWN

  AssetClaimKind = enum
    ARCHITECTURE   = "Architecture"
    LANDSCAPE      = "Landscape"
    FLORA          = "Flora"
    FURNITURE      = "Furniture"
    CLUTTER        = "Clutter"
    FOOD_ALCH_INCH = "Food/Alch/Inch"
    WEAPON         = "Weapon"
    MISC           = "Misc"

  AssetClaim = object
    kind:     AssetClaimKind
    priority: ClaimPriority
    name:     string
    art:      seq[(string, string, string)] # (URL, author, description)
    claimant: seq[string]
    reviewer: seq[string]
    descr:    string
    release:  seq[string]
    file_raw: seq[string]
    file_mw:  seq[string]

proc processSequencedStrings(str: string, sep: string = ","): seq[string] =
  result = str.split(sep)

proc processArtData(sqstr: seq[string]): seq[(string, string, string)] =
  # format = "URL LINK : AUTHOR :: DESCRIPTION"
  for entry in sqstr:
    let single_data = entry.split(" : ")
    let double_data = entry.split(" :: ")
    var
      url    : string
      author : string = "Unknown"
      descr  : string = ""

    let single_len = len(single_data)
    let double_len = len(double_data)

    if single_len == 1 and double_len == 1:
      discard # author & descr are default
    elif single_len == 2 and double_len == 1:
      # no "::"
      author = single_data[1]
    elif single_len == 2 and double_len == 2:
      author = single_data[1].split(" :: ")[0]
      descr  = double_data[1]
    elif single_len == 1 and double_len == 1:
      # no ":"
      descr  = double_data[1]

    result.add((single_data[0], author, descr))


proc newAssetClaim(data: seq[string]): AssetClaim =
  #result.kind     = AssetClaimKind(data[0])
  #result.priority = ClaimPriority(data[1])
  result.name     = data[2]
  # result.art

proc `$`(ac: AssetClaim): string =
  proc readSeqs(s: seq[string]): string =
    for si in s:
      result.add(fmt" | {si}")
    if len(result) > 2:
      result[0..2] = "" # removes first '| ' occurence
  var cai = ""
  if len(ac.art) > 0: cai.add("Concept arts:")
  for aa in ac.art: # [0] url, [1] author, [2] descr
    cai.add("\n" & fmt"- {aa[0]} [{aa[1]}] | {aa[2]}")
  result = fmt"""
  Name: {ac.name}
  === References ===
  {cai}
  === Development ===
  Claimants:      {readSeqs(ac.claimant)}
  Reviewers:      {readSeqs(ac.reviewer)}
  Release Queues: {readSeqs(ac.release)}
  === Description ===
  {ac.descr}
  """.unindent()

var claims_assets = newSeq[AssetClaim]()

let assetsDoc = loadOdsAsSeq("B3D Asset List.ods")
for i, line in assetsDoc:
  if i > 1: # avoids header
    case line[0]:
      of "":  break    # no type text = end of doc
      of "-": continue # visual break
      else  : discard  # actual claim

    var ac: AssetClaim
    for j, col in line:
       if j < 9:
         if col != "":
           #echo col
           case j:
             #of 0: ac.kind  = AssetClaimKind(col)
             of 2: ac.name     = col
             of 3: ac.art      = processArtData(processSequencedStrings(col, " | "))
             of 4: ac.claimant = processSequencedStrings(col)
             of 5: ac.reviewer = processSequencedStrings(col)
             of 6: ac.descr    = col
             of 7: ac.release  = processSequencedStrings(col, " / ")
             else: discard
       else:
         claims_assets.add(ac)
         echo "---"
         break

echo len(claims_assets)
#echo claims_assets[rand(0..len(claims_assets)-1)]
echo claims_assets[34]