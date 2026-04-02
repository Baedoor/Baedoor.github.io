import webgen_utils
import std/private/osdirs
import std/strformat
import std/strutils
import std/sequtils
import std/tables
import parsetoml
import claims
import parse
import log
import os

# TODO:
# - create icons for roles, factions and projects
# - figure out why defaults don't work
# - figure out role descriptions and how to show them
# - arrow coming back to user list

const USER_TIERS = {
    0 : (name: "Wanderer",         colour: "#79726c"), # all non-roled members
    1 : (name: "Contributor",      colour: "#1abc9c"), # for non-devs that are contributors, linguists, zin contributors or gear collectors
    2 : (name: "Developer",        colour: "#a7a25b"), # for those with at least one developer badge
    3 : (name: "Reviewer",         colour: "#dac79f"), # for those with at least one reviewer badge
    4 : (name: "Senior Developer", colour: "#d39600"), # for seniors
    5 : (name: "Lead Developer",   colour: "#f1c40f"), # for leads
}.toOrderedTable
const USER_ROLES = {
    # Admin?
    # [release] Lead
    # Senior
    # Section Manager
    # Claim Manager
    # Moderator
    # Reviewer (Code, Asset, Landscape, Interior, Quest, Book, Pixel Art, NPCing, VA)
    # Developer (Code, Asset, Landscape, Interior, Quest, Book, Pixel Art, NPCing, VA, Concept Art, Sound)
    # Zin Contributor
    # Linguist
    # Gear Collector
    # Contributor
    "Landscape Developer" : "Showcase > Needs Review | ...",
}.toOrderedTable
const USER_PROJECTS = {
    # name : link (should be local if it's not outside website)
    "Baedoor Lore" : "https://github.com/Toma400/Baedoor_Encyclopaedia/blob/en_us/Entrance.md",
    "Of Lands"     : "../projects/ol.html",
}.toOrderedTable
let ORD_Roles    = toSeq(USER_ROLES.keys)
let ORD_Projects = toSeq(USER_PROJECTS.keys)
# ideas:
  # - avatar by URL (if not in `av`)
  # - dev/reviewer/senior/lead would be coloured, but be separate label

type
  Claims = object
    bdata : tuple[indev: seq[AssetClaim], r4r: seq[AssetClaim], merged: seq[AssetClaim], reviewer: seq[AssetClaim]]
    # b3d   : seq[B3DClaim]
    ioa   : tuple[indev: seq[IoAClaim], r4r: seq[IoAClaim], merged: seq[IoAClaim], reviewer: seq[IoAClaim]]
    # fsam  : seq[FSAMClaim]
  User = object
    name    : string
    avatar  : string
    website : string
    descr   : string
    faction : string # decor badge
    tier    : int
    roles   : seq[string]
    projs   : seq[string]
    claims  : Claims

proc isReviewer (user: User): bool =
    for r in user.roles:
        if "Reviewer" in r: return true
    return false

proc newUser (name, avatar, website, descr, faction: string, tier: int, roles, projs: seq[string]): User =
    # TODO: might be useful to abstractify later part
    # proc processClaims [T](cseq: seq[T], uclaims: Claims) =
    #   for claim in cseq: # gather claims
    #     if name in claim.claimant:
    #       case claim.status:
    #         of MERGED, R4M:      add(result.claims.bdata.merged, c)
    #         of R4R:              add(result.claims.bdata.r4r, c)
    #         of INREV:            add(result.claims.bdata.r4r, c)
    #         of INDEV, REQ_FIXES: add(result.claims.bdata.indev, c)

    log(LOG, fmt"Creating user: {name}")
    result.name    = name
    result.avatar  = avatar
    result.website = website
    result.descr   = descr
    result.faction = faction
    result.tier    = tier
    result.roles   = roles
    result.projs   = projs
    for c in bdata: # gather BData claims
      if name in c.claimant:
          case c.status:
            of MERGED, R4M:      add(result.claims.bdata.merged, c)
            of R4R:              add(result.claims.bdata.r4r, c)
            of INREV:            add(result.claims.bdata.r4r, c)
            of INDEV, REQ_FIXES: add(result.claims.bdata.indev, c)
            else: discard
      if name in c.reviewer: add(result.claims.bdata.reviewer, c)
    for c in ioa: # gather IoA claims
      if name in c.claimant:
          case c.status:
            of MERGED, R4M:      add(result.claims.ioa.merged, c)
            of R4R:              add(result.claims.ioa.r4r, c)
            of INREV:            add(result.claims.ioa.r4r, c)
            of INDEV, REQ_FIXES: add(result.claims.ioa.indev, c)
            else: discard
      if name in c.reviewer: add(result.claims.ioa.reviewer, c)

proc getUsers (): seq[User] =
    log(LOG, "Creating users...")
    for uf in walkFiles(fmt"users/*.toml"):
        let f = parseFile(uf)
        # single elements that are later worked upon
        let d = f["Description"].getStr("")
        let r = f["Roles"].getElems(newSeq[TomlValueRef]())
        let p = f["Projects"].getElems(newSeq[TomlValueRef]())

        let u = newUser(name    = multiReplace(uf, [(fmt"users\", ""), (".toml", "")]),
                        avatar  = f["Avatar"].getStr(""), # should return "" if URL not found
                        website = f["Website"].getStr(""),
                        descr   = descrParser(d),
                        faction = f["Faction"].getStr(""),
                        tier    = f["Tier"].getInt(0),
                        roles   = map(r, proc(tvr: TomlValueRef): string = tvr.getStr()),
                        projs   = map(p, proc(tvr: TomlValueRef): string = tvr.getStr()),)
        result.add(u)

let USERS* = getUsers()

proc generateUserBody* (user: User): string
    # preset to be used by next proc, but expanded below

proc generateUserPages* (user_list: seq[User], header: proc(subtit: string, depth: Depth): string,
                                               body:   proc(body_subgen: string): string) =
    log(LOG, "Generating users pages...")
    for user in user_list:
        var ufile = open(fmt"..\\..\\user\\{user.name}.html", fmWrite)
        defer: ufile.close()
        # header
        ufile.write(header(fmt"User: {user.name}", USERS_PAGE))
        # body
        ufile.write(body(generateUserBody(user)))

proc generateUserBody* (user: User): string =
    proc generateRoles (u: User): string =
        for rl in ORD_Roles: # ensures the order/hierarchy is kept
          if rl in u.roles:
            if existsFile(fmt"users/roles/{rl}.png"):
                result.add(fmt"<img src='../files/claims/users/roles/{rl}.png' height='64px' title='{rl}'> ")
    proc generateProjects (u: User): string =
        for pj in ORD_Projects: # less needed ensurance but whatever
          if pj in u.projs:
            if existsFile(fmt"users/projects/{pj}.png"):
                result.add(fmt"<a href='{USER_PROJECTS[pj]}'> <img src='../files/claims/users/projects/{pj}.png' height='64px' title='{pj}'> </a> ")
    proc getAvatar (u: User): string =
        var avatar = u.avatar
        # if local files found, overwrite URL `avatar`
        if   existsFile(fmt"users/av/{u.name}.jpg"): avatar = fmt"../files/claims/users/av/{u.name}.jpg"
        elif existsFile(fmt"users/av/{u.name}.png"): avatar = fmt"../files/claims/users/av/{u.name}.png"
        if avatar == "": # no avatar (neither URL nor local), only render frame
            return "<p align='center'> <img src='../graphics/frame.png' height='150px'> </p>"
        return fmt"""
        <div class="u_av_base" height="150px" align="center" valign="center">
          <img class="u_av"       align="center" height="150px" src="{avatar}" />
          <img class="u_av_frame" align="center" height="150px" src="../graphics/frame.png" />
        </div>
        """
    proc getFaction (u: User): string =
        if not existsFile(fmt"users/banners/{u.faction}.png"): return "" # empty string is covered too
        return fmt"<p align='center'> <img src='../files/claims/users/banners/{u.faction}.png' height='64px' title='{u.faction}'> </p>"

    result.add("<p class=\"gl_tit\">" & "Profile details" & "</p>")
    result.add(fmt"""
      <table width="100%" cellpadding="10px">
          <tr>
              <td width="30%" height="700px" valign="top">

                  <table width="100%" class="user">
                      <tr>
                          <td>
                              <p class="gl_tit" align="center"> <b> {user.name} </b> </p>
                              <hr color="#2f0f00"> <!-- unsure about this, but otherwise it'd need some visual aesthetics like ~~~~~~ above and below? -->
                              <p class="u_role" align="center" style="color: {USER_TIERS[user.tier].colour};"> {USER_TIERS[user.tier].name} </p>
                              [[AVATAR]]
                              <p class="u_def" align="center"> <a href="{user.website}"> Website </a> </p>
                              [[BANNER]]
                              <hr color="#2f0f00">
                              <table width="98%" class="user" align="center" border="0px">
                                  <tr><td width="50%" valign="top">
                                      <table width="100%" height="100%" class="user" align="center" border="0px"> <tr><td>
                                          <p class="u_def" align="center"> Roles </p>
                                      </td></tr><tr><td>
                                          <p align="center"> [[ROLES]] </p>
                                      </td></tr> </table>
                                  </td><td width="50%" valign="top">
                                      <table width="100%" height="100%" class="user" align="center" border="0px"> <tr><td>
                                          <p class="u_def" align="center"> Projects </p>
                                      </td></tr><tr><td>
                                          <p align="center"> [[PROJECTS]] </p>
                                      </td></tr> </table>
                                  </td></tr>
                              </table>
                              <!--<hr color="#B6B79D">-->
                          </td>
                      </tr>
                  </table>
                  [[ARROW]]

              </td>

              <td width="70%" valign="top" style="padding-top: 0px; padding-left: 15px; padding-right: 15px; margin-top: 0px">
                  <table width="100%" class="user" align="center">
                      <tr>
                          <td>   </td>
                              <td class="u_tit"> Baedoor Data </td>
                              <td class="u_tit"> Isle of Ansur </td>
                              <td class="u_tit"> Baedoor (3D) </td>
                              <td class="u_tit"> From Steam and Magic </td> </tr>
                      <tr>
                          <td class="u_tit"> ⚒️ In development </td>
                              <td class="u_count"> {len(user.claims.bdata.indev)} </td> <!-- BData -->
                              <td class="u_count"> {len(user.claims.ioa.indev)}   </td> <!-- IoA -->
                              <td class="u_count"> - </td> <!-- B3D -->
                              <td class="u_count"> - </td> <!-- FSAM --> </tr>
                      <tr>
                          <td class="u_tit"> ☀️ Finished </td>
                              <td class="u_count"> {len(user.claims.bdata.r4r)} </td> <!-- BData -->
                              <td class="u_count"> {len(user.claims.ioa.r4r)}   </td> <!-- IoA -->
                              <td class="u_count"> - </td> <!-- B3D -->
                              <td class="u_count"> - </td> <!-- FSAM --> </tr>
                      <tr>
                          <td class="u_tit"> 🌟 Merged </td>
                              <td class="u_count"> {len(user.claims.bdata.merged)} </td> <!-- BData -->
                              <td class="u_count"> {len(user.claims.ioa.merged)}   </td> <!-- IoA -->
                              <td class="u_count"> - </td> <!-- B3D -->
                              <td class="u_count"> - </td> <!-- FSAM --> </tr>
                      [[REV]]

                  </table>
                  {user.descr}
              </td>
          </tr>
      </table>
    """)
    result = replace(result, "[[AVATAR]]", getAvatar(user))
    result = replace(result, "[[BANNER]]", getFaction(user))
    result = replace(result, "[[ROLES]]", generateRoles(user))
    result = replace(result, "[[PROJECTS]]", generateProjects(user))
    if isReviewer(user):
        result = replace(result, "[[REV]]", fmt"""
        <tr>
            <td class="u_tit"> 🔥 Reviews </td>
                <td class="u_count"> {len(user.claims.bdata.reviewer)} </td> <!-- BData -->
                <td class="u_count"> {len(user.claims.ioa.reviewer)}   </td> <!-- IoA -->
                <td class="u_count"> - </td> <!-- B3D -->
                <td class="u_count"> - </td> <!-- FSAM --> </tr>
        """)
    else: result = replace(result, "[[REV]]", "")
    result = replace(result, "[[ARROW]]", "")
    # TODO: [[ARROW]] should go to the user list