import std/private/osdirs
import std/algorithm
import std/strformat
import std/strutils
import std/sequtils
import std/options
import std/tables
import parsetoml
import claims

type
  Depth* = enum
    USERS_PAGE      = "../"          # user folders
    CLAIM_MAIN_LIST = "../../../"    # bdata/fsam folders
    CLAIM_SUB_LIST  = "../../../../" # [lists] folders
    CLAIMS          = "../../../../" # [pages] folders
  NoneQueue* = object # used to indicate lacking Queue field in claim object

# this registry being in `users.nim` dependency means that it only checks old .htmls; to link/register users newly generated you might need to do generation twice
let REGISTERED_USERS* = map(toSeq(walkFiles("../../user/*.html")), proc(i: string): string = multiReplace(i, [(".html", ""), ("..\\..\\user\\", "")]))
let ADDITIONAL_USERS* = parseFile("contributors.toml").getTable # requires .getStr() upon access

proc getDepthHeader* (d: Depth): string =
  case d:
   of USERS_PAGE:      return "1"
   of CLAIM_MAIN_LIST: return "3"
   of CLAIM_SUB_LIST:  return "4"
   of CLAIMS:          return "4"

proc orderAssets* [T: BrowserClaims](a: seq[T], merged_in: bool, sort_type: bool = false): seq[T] =
  proc alphSort(x, y: T): int =
      return cmp(x.name, y.name)
  proc statusSort(x, y: T): int =
      return cmp(x.status.ord, y.status.ord)
  proc prioritySort(x, y: T): int =
      return cmp(x.priority.ord, y.priority.ord)
  proc kindSort(x, y: T): int =
      return cmp(x.kind.ord, y.kind.ord)
  # sorts the asset sequence by three sortings
  result = a
  sort(result, alphSort)     # alphabetical sort
  if sort_type:
    sort(result, kindSort)   # type sort
  sort(result, statusSort)   # status sort
  sort(result, prioritySort) # priority sort
  if not merged_in: # take merged files out by default
    result = filter(result, proc(c: T): bool = c.status != MERGED)
  result = filter(result, proc(c: T): bool = c.status != REJECTED) # rejected assets are always out (claim pages are still generated)

proc parseNameForGeneration* (s: string | BrowserEnums): string =
  result = $s
  return result.multireplace([
      ("/", "_"),
      (":", "_"),
      ("|", "_")
  ])

proc linkToPage* (s: string, proj: string, depth: Depth): string =
  return "<a href=\"" & $depth & fmt"files/claims/{proj}/[Pages]/" & parseNameForGeneration(s) & ".html\">" & s & "</a>"

proc authorList* (s: seq[string], depth: Depth): string =
  # parses through list of claimants/reviewers and generates HTML code with optional links
  for i in s:
    # normal registered users with pages
    if i in REGISTERED_USERS:
        result.add(fmt" | <a href={depth}user/{i}.html>{i}</a>")
    # semi-registered, users credited by simple linking
    elif i in ADDITIONAL_USERS:
        let link = ADDITIONAL_USERS[i].getStr("")
        if link != "":
          result.add(fmt" | <a href={link}>{i}</a>")
        else: # if link is not stated, treat as non-registered user
          result.add(fmt" | {i}")
    # non-registered users
    else:
      result.add(fmt" | {i}")
  if len(result) > 3:
    result[0..2] = "" # removes first "| "

proc releaseList* (s: seq[B3DReleaseQueue] | seq[IoAReleaseQueue], depth: Depth, proj: string): string =
  # parses through list of releases and generates HTML code with links to queues
  for i in s:
    let link = "\"" & $depth & fmt"files/claims/{proj}/[Lists]/list_R_{i}.html" & "\""
    result.add(fmt" | <a href={link}>{i}</a>")
  if len(result) > 3:
    result[0..2] = "" # removes first "| "

proc formatStatuses* (s: ClaimStatus): string =
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
    of FOOD_ALCH_INGR:
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
    of RACE:
      item = "🎎 Race"
      col  = "#9c7fd5"
    of BOOK:
      item = "📕 Book"
      col  = "#856749"
    of SOUND:
      item = "🪕 Sound"
      col  = "#bac8d6"
    of GLOB_SCRIPT:
      item = "🕉️ Script"
      col  = "#828877"
    of LEVELED_LIST:
      item = "📄 Leveled List"
      col  = "#C1D498"
    of MISC:
      item = "🎏 Miscellanous"
      col  = "#d4d6ba"
  result = "<font color=\"" & col & "\">" & item & "</font>"

proc formatType* (s: IoAClaimKind): string =
  # creates a representation of a type in HTML
  var item: string
  var col:  string
  case s:
    of LOCATION:
      item = "🏕️ Location"
      col  = "#bad6c0"
    of QUEST:
      item = "🌿 Quest"
      col  = "#b07ec1"
    of QUESTLINE:
      item = "🌸 Questline"
      col  = "#943fb1"
    of NPCING:
      item = "🎎 NPCing"
      col  = "#68a95a"
    of LITERATURE:
      item = "📖 Literature"
      col  = "#ad9671"
    of STATPACK_DATA:
      item = "📄 Statpack Data"
      col  = "#8665d4"
    of ART_LOC:
      item = "🖼️ Location Art"
      col  = "#8fd0a5"
    of ART_NPC:
      item = "🦋 NPC/Creature Art"
      col  = "#d08fc5"
    of ART_IT:
      item = "⚖️Item Art"
      col  = "#cdd08f"
  result = "<font color=\"" & col & "\">" & item & "</font>"

proc formatType* (s: B3DClaimKind): string =
  # creates a representation of a type in HTML
  var item: string
  var col:  string
  case s:
    of INTERIOR:
      item = "🏕️ Interior"
      col  = "#bad6c0"
    of EXTERIOR:
      item = "🏕️ Exterior"
      col  = "#bad6c0"
    of NPCING:
      item = "🏕️ NPCing"
      col  = "#bad6c0"
    of QUEST:
      item = "🏕️ Quest"
      col  = "#bad6c0"
    of QUESTLINE:
      item = "🏕️ Questline"
      col  = "#bad6c0"
    of SCRIPT:
      item = "🏕️ Script"
      col  = "#bad6c0"
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
    ca_html.add("<img src=\"" & i[0] & "\" width=\"100%\">")                                            # url
    ca_html.add("<p id=\"vc\" align=\"center\"> <b>" & authorList(@[i[1]], Depth.CLAIMS) & "</b> </p>") # author
    ca_html.add("<p id=\"vc\" align=\"center\">    " & i[2]                              & "     </p>") # description
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

proc filterClaims* (a: BrowserClaims, e: BrowserEnums | string): bool =
  # checks if enum field checked against exists in asset claim
  if e is not string:
    when e is ClaimPriority:
      return e == a.priority
    elif e is AssetClaimKind:
      return e == a.kind
    elif e is IoAClaimKind:
      return e == a.kind
    elif e is ClaimStatus:
      return e == a.status
    # 'a' specific, afaik none of these are used in actual code, so may be a bit redundant
    # -- later Toma: is it meant to avoid `no .release field on object X` error? maybe
    elif a is AssetClaim or a is B3DClaim:
      when e is B3DReleaseQueue: return e in a.release
    elif a is IoAClaim:
      when e is IoAReleaseQueue: return e in a.release
  return true # if None (TODO: make check against other fields in -string- type)

#[
proc filterEnumField* (a: AssetClaim, e: BrowserEnums | string): bool {.deprecated.} =
  # checks if enum field checked against exists in asset claim
  if e is not int:
    when e is ClaimPriority:
      return e == a.priority
    elif e is AssetClaimKind:
      return e == a.kind
    elif e is ClaimStatus:
      return e == a.status
    elif e is B3DReleaseQueue:
      return e in a.release
  return true # if None (TODO: make check against other fields in -string- type)

proc filterEnumField* (a: IoAClaim, e: BrowserEnums | string): bool {.deprecated.} =
  # checks if enum field checked against exists in asset claim
  if e is not int:
    when e is ClaimPriority:
      return e == a.priority
    elif e is IoAClaimKind:
      return e == a.kind
    elif e is ClaimStatus:
      return e == a.status
    elif e is IoAReleaseQueue:
      return e in a.release
  return true # if None (TODO: make check against other fields in -string- type)
]#
