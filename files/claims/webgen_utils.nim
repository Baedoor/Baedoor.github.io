import std/strformat
import std/strutils
import std/options
import std/tables
import parsetoml
import claims

type
  Depth* = enum
    CLAIM_MAIN_LIST = "../../../"    # bdata/fsam folders
    CLAIM_SUB_LIST  = "../../../../" # [lists] folders
    CLAIMS          = "../../../../" # [pages] folders

let REGISTERED_AUTHORS* = parsetoml.parseFile("authors.toml")

proc getDepthHeader* (d: Depth): string =
  case d:
   of CLAIM_MAIN_LIST: return "3"
   of CLAIM_SUB_LIST:  return "4"
   of CLAIMS:          return "4"

proc orderAssets* (a: seq[AssetClaim]): seq[AssetClaim] =
  # sorts the asset sequence through [reo2] priority > [reo1] status
  let statusCount   = len(AssetStatus.low..AssetStatus.high)
  let priorityCount = len(ClaimPriority.low..ClaimPriority.high)
  var first_reordering  = newSeq[seq[AssetClaim]](statusCount)
  var second_reordering = newSeq[seq[AssetClaim]](priorityCount * statusCount)
  for i1 in a:
    first_reordering[i1.status.ord].add(i1)
  for i2 in first_reordering:
    for i2i in i2:
      second_reordering[i2i.priority.ord].add(i2i)
  for fin in second_reordering:
    for finn in fin:
      result.add(finn)

proc parseNameForGeneration* (s: string): string =
  return s.multireplace([
      ("/", "_")
  ])

proc linkToPage* (s: string, depth: Depth): string =
  return "<a href=\"" & $depth & "files/claims/bdata/[Pages]/" & parseNameForGeneration(s) & ".html\">" & s & "</a>"

proc authorList* (s: seq[string]): string =
  # parses through list of claimants/reviewers and generates HTML code with optional links
  for i in s:
    if hasKey(REGISTERED_AUTHORS, i):
      let link = "\"" & REGISTERED_AUTHORS[i].getStr() & "\""
      result.add(fmt" | <a href={link}>{i}</a>")
    else:
      result.add(fmt" | {i}")
  if len(result) > 3:
    result[0..2] = "" # removes first "| "

proc releaseList* (s: seq[ReleaseQueue], depth: Depth): string =
  # parses through list of releases and generates HTML code with links to queues
  for i in s:
    let link = "\"" & $depth & fmt"files/claims/bdata/[Lists]/list_R_{i}.html" & "\""
    result.add(fmt" | <a href={link}>{i}</a>")
  if len(result) > 3:
    result[0..2] = "" # removes first "| "

proc formatStatuses* (s: AssetStatus): string =
  # creates a representation of a status in HTML
  var item: string
  var col:  string
  case s:
    of MERGED:
      item = "🌟 Merged"
      col  = "#698c61"
    of R4M:
      item = "❇️ Ready for merge"
      col  = "#4ce129"
    of INREV:
      item = "🔥 In review"
      col  = "#1d47e1"
    of R4R:
      item = "☀️ Ready for review"
      col  = "#3dbb20"
    of INDEV:
      item = "⚒️ In development"
      col  = "#8abb20"
    of UNCLAIMED:
      item = "👁️ Unclaimed"
      col  = "#bba120"
    of DESIGN:
      item = "📝 Design"
      col  = "#20bbbb"
    of REQ_FIXES:
      item = "⚙️ Requires Fixes"
      col  = "#a120bb"
    of REJECTED:
      item = "❌ Rejected"
      col  = "#632723"
  result = "<font color=\"" & col & "\">" & item & "</font>"

proc formatPriority* (s: ClaimPriority): string =
  # creates a representation of a priority in HTML
  var col: string
  case s:
    of CRITICAL: col = "#c81b07"
    of HIGH:     col = "#efc114"
    of MEDIUM:   col = "#bdef14"
    of LOW:      col = "#6fd565"
    of UNKNOWN:  col = "#c2cace"
  result = "<font color=\"" & col & "\">" & $s & "</font>"

proc formatType* (s: AssetClaimKind): string =
  # creates a representation of a type in HTML
  var item: string
  var col:  string
  case s:
    of ARCHITECTURE:
      item = "🏯 Architecture"
      col  = "#cecbc2"
    of LANDSCAPE:
      item = "🏞️ Landscape"
      col  = "#bcccb2"
    of FLORA:
      item = "🌳 Flora"
      col  = "#5e8545"
    of CREATURE:
      item = "🐉 Creature"
      col  = "#804a4b"
    of FURNITURE:
      item = "🪑 Furniture"
      col  = "#907b33"
    of CLUTTER:
      item = "🏺 Clutter"
      col  = "#a57316"
    of FOOD_ALCH_INCH:
      item = "🍵 Food / Alchemy / Ingredient"
      col  = "#9ae76a"
    of WEAPON:
      item = "🗡️ Weapon"
      col  = "#8b7774"
    of CLOTH:
      item = "🥻 Cloth"
      col  = "#7d22b5"
    of ARMOUR:
      item = "🛡️ Armour"
      col  = "#8bc3c6"
    of BOOK:
      item = "📕 Book"
      col  = "#856749"
    of RACE:
      item = "🎎 Race"
      col  = "#9c7fd5"
    of MISC:
      item = "🎏 Miscellanous"
      col  = "#d4d6ba"
  result = "<font color=\"" & col & "\">" & item & "</font>"

proc checkFiles* (s: seq[string], text: string): string =
  # creates a representation of a file in HTML - if entry is empty it returns empty string
  if len(s) == 0: return ""
  else:
    for link in s:
      result.add(fmt"<a href='{link}'> {text} </a>")

proc checkCAReq* (s: CARequired, need: string, more: string): string =
  # creates a HTML text with additional note while hovering
  case s:
    of CA_NOT:    return ""
    of CA_NEEDED: return "<a title=\"" & $s & "\">" & need & "</a>"
    of CA_MORE:   return "<a title=\"" & $s & "\">" & more & "</a>"

proc conceptArtShowcase* (s: seq[(string, string, string)]): string =
  # creates a HTML code that will neatly organise itself into claim table
  var ca_html: string
  for i in s:
    ca_html.add("<img src=\"" & i[0] & "\" width=\"100%\">")                              # url
    ca_html.add("<p id=\"vc\" align=\"center\"> <b>" & authorList(@[i[1]]) & "</b> </p>") # author
    ca_html.add("<p id=\"vc\" align=\"center\"> <b>" & i[2]                & "</b> </p>") # description
  if len(s) > 0:
    result.add(fmt"""
    <table width="100%" class="proj">
        <tr>
            <td>
                {ca_html}
            </td>
        </tr>
    </table>
    """)

proc filterEnumField* (a: AssetClaim, e: BrowserEnums | string): bool =
  # checks if enum field checked against exists in asset claim
  if e is not int:
    when e is ClaimPriority:
      return e == a.priority
    elif e is AssetClaimKind:
      return e == a.kind
    elif e is AssetStatus:
      return e == a.status
    elif e is ReleaseQueue:
      return e in a.release
  return true # if None (TODO: make check against other fields in -string- type)