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

  ClaimStatus* = enum
    MERGED    = "★ Merged"
    R4M       = "★ Ready for merge"
    R4R       = "☆ Ready for review"
    INREV     = "☆ In review"
    INDEV     = "● In development"
    UNCLAIMED = "○ Unclaimed"
    DESIGN    = "△ Design"
    REQ_FIXES = "▣ Requires Fixes"
    REJECTED  = "▽ Rejected"

  AssetClaimKind* = enum
    ARCHITECTURE   = "Architecture"
    LANDSCAPE      = "Landscape"
    FLORA          = "Flora"
    CREATURE       = "Creature"
    FURNITURE      = "Furniture"
    CLUTTER        = "Clutter"
    FOOD_ALCH_INGR = "Food/Alch/Ingr"
    WEAPON         = "Weapon"
    CLOTH          = "Cloth"
    ARMOUR         = "Armour"
    RACE           = "Race"
    BOOK           = "Book"
    SOUND          = "Sound"
    MISC           = "Misc"

  IoAClaimKind* = enum
    LOCATION      = "Location"
    QUEST         = "Quest"
    QUESTLINE     = "Questline"
    NPCING        = "NPCing"
    LITERATURE    = "Literature"
    STATPACK_DATA = "Statpack Data"
    ART_LOC       = "Location Art"
    ART_NPC       = "NPC/Creature Art"
    ART_IT        = "Item Art"

  B3DReleaseQueue* = enum
    DISANE            = "Disane"
    KACARI            = "Kacari"
    BAEDOOR_CITY      = "Baedoor City"
    LIBRARY_OF_WORLDS = "Library of Worlds"
    OTHER             = "Other"

  IoAReleaseQueue* = enum
    TUTORIAL = "Tutorial"
    EVROS    = "Evros"
    FIELDS   = "Fields"
    WAINE    = "Waine"
    NFERTH   = "Nferth"

  CARequired* = enum
    CA_NEEDED = "Concept art needed!"
    CA_MORE   = "More concept art needed!"
    CA_NOT    = ""

  BrowserEnums* = ClaimPriority | AssetClaimKind | ClaimStatus | B3DReleaseQueue | IoAReleaseQueue | CARequired | IoAClaimKind

  AssetClaim* = object
    kind*:     AssetClaimKind
    priority*: ClaimPriority
    name*:     string
    art*:      seq[(string, string, string)] # (URL, author, description)
    art_req*:  CARequired
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    release*:  seq[B3DReleaseQueue]
    file_raw*: seq[string]
    file_mw*:  seq[string]
    status*:   ClaimStatus

  IoAClaim* = object
    kind*:     IoAClaimKind
    priority*: ClaimPriority
    status*:   ClaimStatus
    name*:     string
    imgs*:     seq[(string, string, string)] # (URL, author, description)
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    release*:  seq[IoAReleaseQueue]
    files*:    seq[string]

  BrowserClaims* = AssetClaim | IoAClaim

  #[ FUTURE BROWSER PREPARATIONS
  FSAMClaim* = object
    kind*:     FSAMClaimKind
    priority*: ClaimPriority
    name*:     string
    imgs*:     seq[(string, string)] # (URL, description)
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    release*:  seq[ReleaseQueue]
    files*:    seq[string]
    status*:   ClaimStatus
  ]#

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

proc `$`* (ac: AssetClaim): string =
  proc readSeqs(s: seq[string] | seq[B3DReleaseQueue]): string =
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