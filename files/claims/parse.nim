import std/private/osdirs
import std/strformat
import std/strutils
import std/sequtils
import std/os
import parsetoml
import odsreader
import markdown
import claims

proc getEnums[T: BrowserEnums](id: string): T =
  when T is ClaimPriority:
      case id:
        of "Critical": return CRITICAL
        of "High":     return HIGH
        of "Medium":   return MEDIUM
        of "Low":      return LOW
        of "Unknown":  return UNKNOWN
        else:          return UNKNOWN
  elif T is ClaimStatus:
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
  elif T is AssetClaimKind:
      case id:
        of "Architecture":   return ARCHITECTURE
        of "Landscape":      return LANDSCAPE
        of "Flora":          return FLORA
        of "Creature":       return CREATURE
        of "Furniture":      return FURNITURE
        of "Clutter":        return CLUTTER
        of "Food/Alch/Ingr": return FOOD_ALCH_INGR
        of "Weapon":         return WEAPON
        of "Armour":         return ARMOUR
        of "Cloth":          return CLOTH
        of "Race":           return RACE
        of "Book":           return BOOK
        of "Sound":          return SOUND
        of "Script":         return GLOB_SCRIPT
        of "Leveled List":   return LEVELED_LIST
        of "Misc":           return MISC
        else: discard
  elif T is IoAClaimKind:
      case id:
        of "A": return ART_LOC
        of "B": return LITERATURE
        of "C": return ART_NPC
        of "D": return STATPACK_DATA
        of "I": return ART_IT
        of "L": return LOCATION
        of "N": return NPCING
        of "Q": return QUEST
        of "S": return QUESTLINE
        else: discard
  elif T is B3DClaimKind:
      case id:
        of "I": return INTERIOR
        of "E": return EXTERIOR
        of "Q": return QUEST
        of "L": return QUESTLINE
        of "N": return NPCING
        of "S": return SCRIPT
        else: discard
  elif T is B3DSectionFile:
      case id:
        of "Kacari":     return KACARI
        of "Baedoor":    return BAEDOOR
        of "Dimensions": return DIMENSIONS
  elif T is B3DReleaseQueue:
      case id:
        of "Kacari":    return qKACARI
        of "BaeC":      return qBAEDOOR_CITY
        of "LibWorlds": return qLIBRARY_OF_WORLDS
        of "Other":     return qOTHER
        else:           return qOTHER
  elif T is IoAReleaseQueue:
      case id:
        of "Tutorial": return qTUTORIAL
        of "Evros":    return qEVROS
        of "Fields":   return qFIELDS
        of "Waine":    return qWAINE
        of "Nferth":   return qNFERTH
        else: discard
  elif T is CARequired:
      case id:
        of "!": return CA_NEEDED
        of ":": return CA_MORE
        else:   return CA_NOT

proc processSequencedStrings(str: string, sep: string): seq[string] =
  result = str.split(sep)

proc processSequencedTomlValues[T: string | int | bool](stv: seq[TomlValueRef]): seq[T] =
  for item in stv:
    when T is string: add(result, item.getStr())
    elif T is int:    add(result, item.getBool())
    elif T is bool:   add(result, item.getInt())

proc processReleasesQueue[T: B3DReleaseQueue | IoAReleaseQueue](sqstr: seq[string]): seq[T] =
  for entry in sqstr:
    result.add(getEnums[T](entry))

proc processSectionFile(s: string, sep: string = " ^ "): (B3DSectionFile, string) =
  if s == "" or sep notin s:
    return (NONE, "")
  let sp = s.split(sep)
  result = (getEnums[B3DSectionFile](sp[0]), sp[1])

proc descrParser (s: string): string =
  # parses description to unify some formatting/visual aspects
  result = markdown(s)         # allow Markdown styling
  return result.multireplace([ # ensure consistent style
      ("<ul>", "<ul class='def'>"),
      ("<li>", "<li>"),
      ("<p>",  "<p id='vc'>")
  ])

proc processArtData (sqstr: seq[string]): seq[(string, string, string)] =
  # format = "URL LINK : AUTHOR :: DESCRIPTION"
  const
    AUT = " : "
    DES = " :: "
  var
    url    : string
    author : string = "Unknown"
    descr  : string = ""
  for entry in sqstr:
    if AUT in entry:
        let s1 = entry.split(AUT)
        if DES in entry: # "LINK : AUTHOR :: DESCR"
            let s2 = s1[1].split(DES)
            url    = s1[0]
            author = s2[0]
            descr  = s2[1]
        else:             # "LINK : AUTHOR"
            url    = s1[0]
            author = s1[1]
    elif "::" in entry: # "LINK :: DESCR"
        let s1 = entry.split(DES)
        url   = s1[0]
        descr = s1[1]
    else:               # "LINK"
        url = entry
    result.add((url, author, descr))

proc yieldAssetClaims(doc_path: string): seq[AssetClaim] =
  # reads .ods file with path set in -doc_path- argument and yields list of claims
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
               of 3: ac.imgs     = processArtData(processSequencedStrings(col, "|"))
               of 4: ac.art_req  = getEnums[CARequired](col)
               of 5: ac.claimant = processSequencedStrings(col, " | ")
               of 6: ac.reviewer = processSequencedStrings(col, " | ")
               of 7: ac.descr    = descrParser(col)
               of 8: ac.release  = processReleasesQueue[B3DReleaseQueue](processSequencedStrings(col, " / "))
               of 9: ac.file_raw = processSequencedStrings(col, " | ")
               of 10: ac.file_mw = processSequencedStrings(col, " | ")
               of 11: ac.status  = getEnums[ClaimStatus](col)
               else: discard
           else: # things that work upon empty string
             case j:
               of 4: ac.art_req  = getEnums[CARequired](col)
               else: discard
         else:
           result.add(ac)
           break

proc yieldIoAClaims(): seq[IoAClaim] =
  const statuses = ["Merged", "R4M", "R4R", "In Review", "Indev", "Unclaimed", "Design", "Req. Fixes", "Rejected"]
  for s in statuses:
    if existsDir(fmt"ioa\[Claims]\{s}"):
      for f in toSeq(walkFiles(fmt"ioa\[Claims]\{s}\*.toml")):
        let fn = f.multireplace([(fmt"ioa\[Claims]\{s}\", ""), (".toml", "")])
        let fo = parseFile(f)
        var ic : IoAClaim

        ic.kind     = getEnums[IoAClaimKind]($fn[0])
        ic.priority = getEnums[ClaimPriority](fo["priority"].getStr("Unknown"))
        ic.status   = getEnums[ClaimStatus](s)
        ic.name     = fo["name"].getStr(fn)
        ic.imgs     = processArtData(processSequencedTomlValues[string](fo["imgs"].getElems()))
        ic.claimant = processSequencedTomlValues[string](fo["claimants"].getElems())
        ic.reviewer = processSequencedTomlValues[string](fo["reviewers"].getElems())
        ic.descr    = descrParser(fo["description"].getStr(""))
        ic.release  = processReleasesQueue[IoAReleaseQueue](processSequencedTomlValues[string](fo["releases"].getElems()))
        ic.files    = processSequencedTomlValues[string](fo["files"].getElems())
        add(result, ic)

proc yieldB3DClaims(): seq[B3DClaim] =
  const statuses = ["Merged", "R4M", "R4R", "In Review", "Indev", "Unclaimed", "Design", "Req. Fixes", "Rejected"]
  for s in statuses:
    if existsDir(fmt"b3d\[Claims]\{s}"):
      for f in toSeq(walkFiles(fmt"b3d\[Claims]\{s}\*.toml")):
        let fn = f.multireplace([(fmt"b3d\[Claims]\{s}\", ""), (".toml", "")])
        let fo = parseFile(f)
        var ic : B3DClaim

        ic.kind     = getEnums[B3DClaimKind]($fn[0])
        ic.priority = getEnums[ClaimPriority](fo["priority"].getStr("Unknown"))
        ic.status   = getEnums[ClaimStatus](s)
        ic.name     = fo["name"].getStr(fn)
        ic.imgs     = processArtData(processSequencedTomlValues[string](fo["imgs"].getElems()))
        ic.claimant = processSequencedTomlValues[string](fo["claimants"].getElems())
        ic.reviewer = processSequencedTomlValues[string](fo["reviewers"].getElems())
        ic.descr    = descrParser(fo["description"].getStr(""))
        ic.release  = processReleasesQueue[B3DReleaseQueue](processSequencedTomlValues[string](fo["releases"].getElems()))
        ic.files    = processSequencedTomlValues[string](fo["files"].getElems())
        ic.section  = processSectionFile(fo["section"].getStr(""))
        add(result, ic)

proc yieldFSAMClaims(): seq[FSAMClaim] =
    const statuses = ["Merged", "R4M", "R4R", "In Review", "Indev", "Unclaimed", "Design", "Req. Fixes", "Rejected"]
    for s in statuses:
        if existsDir(fmt"fsam\[Claims]\{s}"):
            for f in toSeq(walkFiles(fmt"fsam\[Claims]\{s}\*.toml")):
                let fn = f.multireplace([(fmt"fsam\[Claims]\{s}\", ""), (".toml", "")])
                let fo = parseFile(f)
                var ic : FSAMClaim

                ic.kind     = getEnums[B3DClaimKind]($fn[0])
                ic.priority = getEnums[ClaimPriority](fo["priority"].getStr("Unknown"))
                ic.status   = getEnums[ClaimStatus](s)
                ic.name     = fo["name"].getStr(fn)
                ic.imgs     = processArtData(processSequencedTomlValues[string](fo["imgs"].getElems()))
                ic.claimant = processSequencedTomlValues[string](fo["claimants"].getElems())
                ic.reviewer = processSequencedTomlValues[string](fo["reviewers"].getElems())
                ic.descr    = descrParser(fo["description"].getStr(""))
                ic.files    = processSequencedTomlValues[string](fo["files"].getElems())
                ic.section  = fo["merge"].getStr("")
                add(result, ic)

# proc yieldFSAMClaims(): seq[FSAMClaim] =
#     for status in StatusFolders.low..StatusFolders.high:
#         if existsOrCreateDir(fmt"fsam\[Claims]\{s}"):
#             for file in toSeq(walkFiles(fmt"fsam\[Claims]\{s}\*.toml")):
#                 let fn = f.multireplace([(fmt"fsam\[Claims]\{s}\", ""), (".toml", "")])
#                 let fo = parseFile(f)
#                 var ic : FSAMClaim

let bdata* = yieldAssetClaims("B3D Asset List.ods")
let ioa*   = yieldIoAClaims()
let b3d*   = yieldB3DClaims()
let fsam*  = yieldFSAMClaims()