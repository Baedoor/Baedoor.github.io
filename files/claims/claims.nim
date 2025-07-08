import std/enumutils
import std/strformat
import std/strutils
import std/sequtils
import std/random
import odsreader

randomize()

type
  ClaimPriority* = enum
    CRITICAL = "Critical"
    HIGH     = "High"
    MEDIUM   = "Medium"
    LOW      = "Low"
    UNKNOWN  = "Unknown"

  AssetClaimKind* = enum
    ARCHITECTURE   = "Architecture"
    LANDSCAPE      = "Landscape"
    FLORA          = "Flora"
    CREATURE       = "Creature"
    FURNITURE      = "Furniture"
    CLUTTER        = "Clutter"
    FOOD_ALCH_INCH = "Food/Alch/Inch"
    WEAPON         = "Weapon"
    CLOTH          = "Cloth"
    ARMOUR         = "Armour"
    BOOK           = "Book"
    RACE           = "Race"
    MISC           = "Misc"

  AssetStatus* = enum
    MERGED    = "★ Merged"
    R4M       = "★ Ready for merge"
    R4R       = "☆ Ready for review"
    INREV     = "☆ In review"
    INDEV     = "● In development"
    UNCLAIMED = "○ Unclaimed"
    DESIGN    = "△ Design"
    REQ_FIXES = "▣ Requires Fixes"
    REJECTED  = "▽ Rejected"

  ReleaseQueue* = enum
    DISANE            = "Disane"
    KACARI            = "Kacari"
    BAEDOOR_CITY      = "Baedoor City"
    LIBRARY_OF_WORLDS = "Library of Worlds"

  CARequired* = enum
    CA_NEEDED = "Concept art needed!"
    CA_MORE   = "More concept art needed!"
    CA_NOT    = ""

  BrowserEnums* = ClaimPriority | AssetClaimKind | AssetStatus | ReleaseQueue | CARequired

  AssetClaim* = object
    kind*:     AssetClaimKind
    priority*: ClaimPriority
    name*:     string
    art*:      seq[(string, string, string)] # (URL, author, description)
    art_req*:  CARequired
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    release*:  seq[ReleaseQueue]
    file_raw*: seq[string]
    file_mw*:  seq[string]
    status*:   AssetStatus

#proc assetList(filter: string | None = None, order: string | None = None) = discard

proc getEnums[T: BrowserEnums](id: string): T =
  when T is ClaimPriority:
      case id:
        of "Critical": return CRITICAL
        of "High":     return HIGH
        of "Medium":   return MEDIUM
        of "Low":      return LOW
        of "Unknown":  return UNKNOWN
        else:          return UNKNOWN
  elif T is AssetClaimKind:
      case id:
        of "Architecture":   return ARCHITECTURE
        of "Landscape":      return LANDSCAPE
        of "Flora":          return FLORA
        of "Creature":       return CREATURE
        of "Furniture":      return FURNITURE
        of "Clutter":        return CLUTTER
        of "Food/Alch/Inch": return FOOD_ALCH_INCH
        of "Weapon":         return WEAPON
        of "Armour":         return ARMOUR
        of "Cloth":          return CLOTH
        of "Book":           return BOOK
        of "Race":           return RACE
        of "Misc":           return MISC
        else: discard
  elif T is AssetStatus:
      case id:
        of "Merged":     return MERGED # only use for B3D BData
        of "MergedB":    return MERGED # use for MW's BData | later will be repurposed to indicate differences between MW's BData and B3D BData
        of "R4M":        return R4M
        of "R4R":        return R4R
        of "In Review":  return INREV
        of "Indev":      return INDEV
        of "Unclaimed":  return UNCLAIMED
        of "Design":     return DESIGN
        of "Req. Fixes": return REQ_FIXES
        of "Rejected":   return REJECTED
        else: discard
  elif T is ReleaseQueue:
      case id:
        of "Disane":    return DISANE
        of "Kacari":    return KACARI
        of "BaeC":      return BAEDOOR_CITY
        of "LibWorlds": return LIBRARY_OF_WORLDS
        else: discard
  elif T is CARequired:
      case id:
        of "!": return CA_NEEDED
        of ":": return CA_MORE
        else:   return CA_NOT

proc processSequencedStrings(str: string, sep: string = ", "): seq[string] =
  result = str.split(sep)

proc processArtData* (sqstr: seq[string]): seq[(string, string, string)] =
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

proc processReleasesQueue (sqstr: seq[string]): seq[ReleaseQueue] =
  for entry in sqstr:
    result.add(getEnums[ReleaseQueue](entry))

proc `$`* (ac: AssetClaim): string =
  proc readSeqs(s: seq[string] | seq[ReleaseQueue]): string =
    for si in s:
      result.add(fmt" | {si}")
    if len(result) > 2:
      result[0..2] = "" # removes first '| ' occurence
  var cai = ""
  if len(ac.art) > 0: cai.add("Concept arts:")
  for aa in ac.art: # [0] url, [1] author, [2] descr
    cai.add("\n" & fmt"- {aa[0]} [{aa[1]}] | {aa[2]}")
  result = fmt"""
  Name:     {ac.name}
  Type:     {ac.kind}
  Status:   {ac.status}
  Priority: {ac.priority}
  === References ===
  {cai}
  === Development ===
  Claimants:      {readSeqs(ac.claimant)}
  Reviewers:      {readSeqs(ac.reviewer)}
  Release Queues: {readSeqs(ac.release)}
  === Files ===
  Raw: {readSeqs(ac.file_raw)}
  MW:  {readSeqs(ac.file_mw)}
  === Description ===
  {ac.descr}
  """.unindent()

proc yieldAssetClaims* (doc_path: string): seq[AssetClaim] =
  let assetsDoc = loadOdsAsSeq(doc_path)
  for i, line in assetsDoc:
    if i > 0: # avoids header
      case line[0]:
        of "":  break    # no type text = end of doc
        of "-": continue # visual break
        else  : discard  # actual claim

      var ac: AssetClaim
      for j, col in line:
         if j < 12:
           if col != "":
             case j:
               of 0: ac.kind     = getEnums[AssetClaimKind](col)
               of 1: ac.priority = getEnums[ClaimPriority](col)
               of 2: ac.name     = col
               of 3: ac.art      = processArtData(processSequencedStrings(col, " | "))
               of 4: ac.art_req  = getEnums[CARequired](col)
               of 5: ac.claimant = processSequencedStrings(col)
               of 6: ac.reviewer = processSequencedStrings(col)
               of 7: ac.descr    = col
               of 8: ac.release  = processReleasesQueue(processSequencedStrings(col, " / "))
               of 9: ac.file_raw = processSequencedStrings(col)
               of 10: ac.file_mw = processSequencedStrings(col)
               of 11: ac.status  = getEnums[AssetStatus](col)
               else: discard
           else: # things that work upon empty string
             case j:
               of 4: ac.art_req  = getEnums[CARequired](col)
               else: discard
         else:
           result.add(ac)
           break

#let test = yieldAssetClaims("B3D Asset List.ods")
# echo len(claims_assets)
#echo claims_assets[rand(0..len(claims_assets)-1)]
#echo test[2].art