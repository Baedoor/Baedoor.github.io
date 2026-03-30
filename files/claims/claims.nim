import std/strformat
import std/strutils
import std/random

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
    SCRIPT         = "Script"
    LEVELED_LIST   = "Leveled List"
    MISC           = "Misc"

  B3DClaimKind* = enum
    INTERIOR  = "Interior"
    EXTERIOR  = "Exterior"
    QUEST     = "Quest"
    QUESTLINE = "Questline"
    NPCING    = "NPCing"
    SCRIPT    = "Script"

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

  B3DReleaseQueue* = enum                    # Section files, respectively:
    qKACARI            = "Kacari"            # Kacari
    qBAEDOOR_CITY      = "Baedoor City"      # Baedoor
    qLIBRARY_OF_WORLDS = "Library of Worlds" # Dimensions
    qOTHER             = "Other"

  B3DSectionFile* = enum
    KACARI     = "Kacari"               # Kacari
    BAEDOOR    = "Baedoor"              # Baedoor
    DIMENSIONS = "Dimensions"           # LoW release & other overarching oververse stuff
    NONE                                # Used for claims that aren't merged
    # section files are rather per-province
    # so they will eventually encompass multiple release queues
    # KAER, ARENNAN, ROSSEVETTE etc. will be added when province work on them starts

  IoAReleaseQueue* = enum
    qTUTORIAL = "Tutorial"
    qEVROS    = "Evros"
    qFIELDS   = "Fields"
    qWAINE    = "Waine"
    qNFERTH   = "Nferth"

  CARequired* = enum
    CA_NEEDED = "Concept art needed!"
    CA_MORE   = "More concept art needed!"
    CA_NOT    = ""

  BrowserEnums* = ClaimPriority | AssetClaimKind | B3DClaimKind | IoAClaimKind | ClaimStatus | B3DReleaseQueue | IoAReleaseQueue | B3DSectionFile | CARequired

  AssetClaim* = object
    kind*:     AssetClaimKind
    priority*: ClaimPriority
    status*:   ClaimStatus
    name*:     string
    imgs*:     seq[(string, string, string)] # (URL, author, description)
    art_req*:  CARequired
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    release*:  seq[B3DReleaseQueue]
    file_raw*: seq[string]
    file_mw*:  seq[string]

  B3DClaim* = object
    kind*:     B3DClaimKind
    priority*: ClaimPriority
    status*:   ClaimStatus
    name*:     string
    imgs*:     seq[(string, string, string)] # (URL, author, description)
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    release*:  seq[B3DReleaseQueue]
    files*:    seq[string]
    section*:  (B3DSectionFile, string) # section file, date of merge

  FSAMClaim* = object
    kind*:     B3DClaimKind
    priority*: ClaimPriority
    status*:   ClaimStatus
    name*:     string
    imgs*:     seq[(string, string, string)] # (URL, author, description)
    claimant*: seq[string]
    reviewer*: seq[string]
    descr*:    string
    files*:    seq[string]
    section*:  string                        # date of merge

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

  BrowserClaims* = AssetClaim | IoAClaim | FSAMClaim | B3DClaim

  StatusFolders* = enum # used to systematise parser by calling enum range
    fMERGED    = "Merged"
    fR4M       = "R4M"
    fR4R       = "R4R"
    fINREVIEW  = "In Review"
    fINDEV     = "Indev"
    fUNCLAIMED = "Unclaimed"
    fDESIGN    = "Design"
    fREQFIXES  = "Req. Fixes"
    fREJECTED  = "Rejected"

proc `$`* (ac: AssetClaim): string =
  proc readSeqs(s: seq[string] | seq[B3DReleaseQueue]): string =
    for si in s:
      result.add(fmt" | {si}")
    if len(result) > 2:
      result[0..2] = "" # removes first '| ' occurence
  var cai = ""
  if len(ac.imgs) > 0: cai.add("Concept arts:")
  for aa in ac.imgs: # [0] url, [1] author, [2] descr
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