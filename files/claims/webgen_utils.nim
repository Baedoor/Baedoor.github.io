import std/strformat
import std/strutils
import std/tables
import claims

type
  Depth* = enum
    CLAIM_MAIN_LIST = "../../../"    # bdata/fsam folders
    CLAIM_SUB_LIST  = "../../../../" # [lists] folders
    CLAIMS          = "../../../../" # [pages] folders

const REGISTERED_AUTHORS* = {
  "Toma400": "https://baedoor.github.io/"
}.toTable()

proc parseNameForGeneration* (s: string): string =
  return s.multireplace([
      ("/", "_")
  ])

proc linkToPage* (s: string, depth: Depth): string =
  return "<a href=\"" & $depth & "files/claims/bdata/[Pages]/" & parseNameForGeneration(s) & ".html\">" & s & "</a>"

proc authorList* (s: seq[string]): string =
  # parses through list of claimants/reviewers and generates HTML code with optional links
  for i in s:
    if i in REGISTERED_AUTHORS:
      let link = "\"" & REGISTERED_AUTHORS[i] & "\""
      result.add(fmt" | <a href={link}>{i}</a>")
    else:
      result.add(fmt" | {i}")
  if len(result) > 3:
    result[0..2] = "" # removes first "| "

proc releaseList* (s: seq[ReleaseQueue], depth: Depth): string =
  # parses through list of releases and generates HTML code with links to queues
  for i in s:
    let link = "" # TODO: release queue link -- "\"" & depth & "files/claims/bdata/[Lists]/" & "\""
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

proc conceptArtShowcase* (s: seq[(string, string, string)]): string =
  # creates a HTML code that will neatly organise itself into claim table
  var ca_html: string
  for i in s:
    ca_html.add("<img src=\"" & i[0] & "\" width=\"100%\">")                              # url
    ca_html.add("<p id=\"vc\" align=\"center\"> <b>" & authorList(@[i[1]]) & "</b> </p>") # author
    ca_html.add("<p id=\"vc\" align=\"center\"> <b>" & i[2]                & "</b> </p>") # description
  if len(s) > 0:
    result.add("""
    <table width="100%" class="proj">
        <tr>
            <td>
                {ca_html}
            </td>
        </tr>
    </table>
    """)