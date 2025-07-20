import std/private/osfiles
import std/strformat
import std/strutils
import std/options
import std/os
import webgen_utils
import claims
import parse

const STATUSES_FILTER = @[MERGED, R4M, R4R, REQ_FIXES, INDEV, UNCLAIMED, DESIGN]
const RELEASES_FILTER = @[DISANE, KACARI, BAEDOOR_CITY]
const IOA_RELEASES_FILTER = @[TUTORIAL, EVROS]

proc generateHeader(page_subtitle: string, depth: Depth = CLAIMS): string =
  result = """
    <!doctype html>
    <head>
        <title> Baedoor - {page_subtitle} </title>
        <link rel="shortcut icon" href="{depth}graphics/banner_baedoor.png">
        <link rel="stylesheet" href="{depth}bcmain.css">
        <meta charset="UTF-8">

        <script src="{depth}import.js"></script>
        <script>
         $(document).ready(function(){
            $('#header').load("{depth}header{number}.html");
         });
        </script>
    </head>
  """
  result = result.replace("{page_subtitle}", page_subtitle)
  result = result.replace("{depth}", $depth)
  result = result.replace("{number}", getDepthHeader(depth))

proc filterHeader(depth: Depth, filter: BrowserEnums | string): string =
  # variables to be used by subprocs
  let depthstr = $depth
  let filteri  = filter

  proc bodyBuilder[T](iter: HSlice[T, T] | seq[T], initial: string, category: string): string =
    var temp_container: string
    for i in iter:
        let link = "\"" & depthstr & fmt"files/claims/bdata/[Lists]/list_{initial}_{parseNameForGeneration(i)}.html" & "\""
        temp_container.add(fmt"<br><a href={link}>{i}</a>")
    temp_container[0..3] = "" # removes first "<br>"
    result = "<p class=\"def\" align=\"center\"> <b>" & category & "</b> <br>" & temp_container & "</p>"

  proc prioritiesBody(): string =
    return bodyBuilder[ClaimPriority](ClaimPriority.low..ClaimPriority.high, "P", "Priorities")

  proc statusesBody(): string =
    return bodyBuilder[ClaimStatus](STATUSES_FILTER, "S", "Statuses")

  proc kindsBody(): string =
    return bodyBuilder[AssetClaimKind](AssetClaimKind.low..AssetClaimKind.high, "K", "Type")

  proc releasesBody(): string =
    return bodyBuilder[B3DReleaseQueue](RELEASES_FILTER, "R", "Release Queues")

  # TODO: for "AND" filters - either one depending on filter already applied (contextual) or all of them (not recommended due to amount of combinations: over 1000)
  proc subfilterBody(): string =
    result.add("""
    <p class="cr_tit"> Subfilter </p>
    """)
    return "" # returns empty string until to do is done

  result.add("""
  <p class="gl_tit"> Asset Browser </p>
  <table class="archives" width="60%" cellpadding="10px" align="center" border="solid 1px">
      <tr>
          <td width="40%">
                <p class="def" align="center"> Baedoor Data is the repository of assets used by From Steam and Magic mod, but will be later repurposed for Baedoor game. </p>
                <p class="def" align="center"> <a href="https://github.com/Toma400/B_Data">                             GitHub Repository </a> |
                                               <a href="https://github.com/Toma400/B_Data/archive/refs/heads/root.zip"> Download          </a> </p>
                <p class="def" align="center"> Below is list of all asset claims that were made for it. It is updated regularly based on <a href="https://docs.google.com/spreadsheets/d/1qCKEiaXCVPrr48Cs_vC7xtMIZoZcmbq3-rhlrjN5FBA">spreadsheet</a>. </p>
          </td>
          <td width="60%">
                <p class="cr_tit"> Filters </p>
                <table align="center">
                    <tr>
                        <td valign="top"> {priorities_body} </td>
                        <td valign="top"> {statuses_body}   </td>
                        <td valign="top"> {kinds_body}      </td>
                        <td valign="top"> {releases_body}   </td>
                    </tr>
                    {subfilter}
                </table>
          </td>
      </tr>
  </table>
  """)
  result = result.replace("{priorities_body}", prioritiesBody())
  result = result.replace("{statuses_body}",   statusesBody())
  result = result.replace("{kinds_body}",      kindsBody())
  result = result.replace("{releases_body}",   releasesBody())
  result = result.replace("{subfilter}",       subfilterBody())

proc ioafilterHeader(depth: Depth, filter: BrowserEnums | string): string =
  # variables to be used by subprocs
  let depthstr = $depth
  let filteri  = filter

  proc bodyBuilder[T](iter: HSlice[T, T] | seq[T], initial: string, category: string): string =
    var temp_container: string
    for i in iter:
        let link = "\"" & depthstr & fmt"files/claims/ioa/[Lists]/list_{initial}_{parseNameForGeneration(i)}.html" & "\""
        temp_container.add(fmt"<br><a href={link}>{i}</a>")
    temp_container[0..3] = "" # removes first "<br>"
    result = "<p class=\"def\" align=\"center\"> <b>" & category & "</b> <br>" & temp_container & "</p>"

  proc prioritiesBody(): string =
    return bodyBuilder[ClaimPriority](ClaimPriority.low..ClaimPriority.high, "P", "Priorities")

  proc statusesBody(): string =
    return bodyBuilder[ClaimStatus](STATUSES_FILTER, "S", "Statuses")

  proc kindsBody(): string =
    return bodyBuilder[IoAClaimKind](IoAClaimKind.low..IoAClaimKind.high, "K", "Type")

  proc releasesBody(): string =
    return bodyBuilder[IoAReleaseQueue](IOA_RELEASES_FILTER, "R", "Release Queues")

  # TODO: for "AND" filters - either one depending on filter already applied (contextual) or all of them (not recommended due to amount of combinations: over 1000)
  proc subfilterBody(): string =
    result.add("""
    <p class="cr_tit"> Subfilter </p>
    """)
    return "" # returns empty string until to do is done

  result.add("""
  <p class="gl_tit"> Isle of Ansur Claim Browser </p>
  <table class="archives" width="60%" cellpadding="10px" align="center" border="solid 1px">
      <tr>
          <td width="40%">
                <p class="def" align="center"> Isle of Ansur claim browser is made as a tool for development of Isle of Ansur game. Anyone can contribute to it by claiming any free claim below. </p>
                <p class="def" align="center"> To set yourself as developer, join Discord server and ask for granting you the claim. </p>
          </td>
          <td width="60%">
                <p class="cr_tit"> Filters </p>
                <table align="center">
                    <tr>
                        <td valign="top"> {priorities_body} </td>
                        <td valign="top"> {statuses_body}   </td>
                        <td valign="top"> {kinds_body}      </td>
                        <td valign="top"> {releases_body}   </td>
                    </tr>
                    {subfilter}
                </table>
          </td>
      </tr>
  </table>
  """)
  result = result.replace("{priorities_body}", prioritiesBody())
  result = result.replace("{statuses_body}",   statusesBody())
  result = result.replace("{kinds_body}",      kindsBody())
  result = result.replace("{releases_body}",   releasesBody())
  result = result.replace("{subfilter}",       subfilterBody())

proc filterHeader(depth: Depth): string {.deprecated.} =
  result.add("""
    <p class="gl_tit"> Asset Browser </p>
    <p class="def" align="center"> Baedoor Data is the repository of assets used by From Steam and Magic mod, but will be later repurposed for Baedoor game. </p>
    <p class="def" align="center"> <a href="https://github.com/Toma400/B_Data">                             GitHub Repository </a> |
                                   <a href="https://github.com/Toma400/B_Data/archive/refs/heads/root.zip"> Download          </a> </p>
    <p class="def" align="center"> Below is list of all asset claims that were made for it. It is updated regularly based on <a href="https://docs.google.com/spreadsheets/d/1qCKEiaXCVPrr48Cs_vC7xtMIZoZcmbq3-rhlrjN5FBA">spreadsheet</a>. </p>
    <br>
    <p class="cr_tit"> Filters </p>
  """)
  # [ FILTERS ]#
  # Priorities
  var priorities_body = "<p class=\"def\" align=\"center\"> <b>Priorities</b> <br>[[]]</p>"
  var priorities: string
  for p in ClaimPriority.low..ClaimPriority.high:
    let link = "\"" & $depth & fmt"files/claims/bdata/[Lists]/list_P_{p}.html" & "\""
    priorities.add(fmt" | <a href={link}>{p}</a>")
  priorities[0..2] = "" # removes first "| "
  priorities_body  = priorities_body.replace("[[]]", priorities)
  # Statuses
  var statuses_body = "<p class=\"def\" align=\"center\"> <b>Statuses</b> <br>[[]]</p>"
  var statuses: string
  for s in STATUSES_FILTER:
    let link = "\"" & $depth & fmt"files/claims/bdata/[Lists]/list_S_{s}.html" & "\""
    statuses.add(fmt" | <a href={link}>{s}</a>")
  statuses[0..2] = "" # removes first "| "
  statuses_body  = statuses_body.replace("[[]]", statuses)
  # Types
  var kinds_body = "<p class=\"def\" align=\"center\"> <b>Type</b> <br>[[]]</p>"
  var kinds: string
  for k in AssetClaimKind.low..AssetClaimKind.high:
    let link = "\"" & $depth & fmt"files/claims/bdata/[Lists]/list_K_{parseNameForGeneration(k)}.html" & "\""
    kinds.add(fmt" | <a href={link}>{k}</a>")
  kinds[0..2] = "" # removes first "| "
  kinds_body  = kinds_body.replace("[[]]", kinds)
  # Release Queues
  var releases_body = "<p class=\"def\" align=\"center\"> <b>Release Queues</b> <br>[[]]</p>"
  var releases: string
  for r in B3DReleaseQueue.low..B3DReleaseQueue.high:
    let link = "\"" & $depth & fmt"files/claims/bdata/[Lists]/list_R_{r}.html" & "\""
    releases.add(fmt" | <a href={link}>{r}</a>")
  releases[0..2] = "" # removes first "| "
  releases_body  = releases_body.replace("[[]]", releases)

  result.add(priorities_body)
  result.add(statuses_body)
  result.add(kinds_body)
  result.add(releases_body)

#[ BODY SUBGENERATORS ]#
proc assetlistBody(asset_list: seq[AssetClaim], depth: DEPTH, filter: BrowserEnums | string = ""): string =
  var claims_list_str : string # HTML code for table entries
  var backlink        = "<center><a href=\"" & $depth & "projects/fsam.html\" id=\"v\"> Back to main page </a></center>" # only return to FSAM if on main list
  if filter is not string:
      backlink = "<center><a href=\"" & $depth & "files/claims/bdata/list.html\" id=\"v\"> Back to main page </a></center>"
  for claim in orderAssets[AssetClaim](asset_list, $filter == $MERGED):
      if filter is not string: # by default, all options are in | TODO: make the check better so it can work with strings that are not ""
          if not filterEnumField(claim, filter): continue # skips adding
      claims_list_str.add(fmt"""
      <tr>
          <td> {linkToPage(claim.name, "bdata", depth)} </td>
          <td> {authorList(claim.claimant)}             </td>
          <td> {formatStatuses(claim.status)}           </td>
          <td> {formatPriority(claim.priority)}         </td>
          <td> {checkFiles(claim.file_mw, "🪔")}        </td>
          <td> {checkFiles(claim.file_raw, "🪔")}       </td>
          <td> {checkCAReq(claim.art_req, "🏵️", "🌸")}   </td>
      </tr>
      """)
  # PRIORITY - when added, it took 10% from CLAIM (previously 40%)
  result = fmt"""
  {filterHeader(depth, filter)}

  <table class="archives" width="60%" cellpadding="10px" align="center" border="solid 1px">
      <tr class="head">
          <td width="30%"> Claim      </td>
          <td width="25%"> Developer  </td>
          <td width="15%"> Status     </td>
          <td width="10%"> Priority   </td>
          <td width="6%">  MW File    </td>
          <td width="6%">  Raw File   </td>
          <td width="6%">  CA Needed? </td>
      </tr>
      {claims_list_str}
  </table>

  <br><br><br>
  {backlink}
  """

proc assetclaimBody(a: AssetClaim): string =
  var optional_rev: string
  block optionalsHandling:
    if len(a.reviewer) > 0:
      optional_rev = "<p id=\"vc\" align=\"center\"> Reviewer(s): " & authorList(a.reviewer) & "</p>"
  result.add("<p class=\"gl_tit\">" & a.name & "</p>")
  result.add(fmt"""
    <table width="100%" cellpadding="10px">
        <tr>
            <td width="25%" height="700px" valign="top">

                <table width="100%" class="proj">
                    <tr>
                        <td>
                            <p class="gl_tit" align="center"> <b>Asset Lifecycle</b> </p>
                            <p id="vc" align="center"> Developer(s): {authorList(a.claimant)}</p>
                            {optional_rev}
                            <p id="vc" align="center"> Status: {formatStatuses(a.status)}</p>
                            <hr color="#B6B79D">
                            <p class="gl_tit" align="center"> <b>Asset Status</b> </p>
                            <p id="vc" align="center"> Release(s): {releaseList(a.release, Depth.CLAIMS)} </p>
                            <p id="vc" align="center"> Priority:   {formatPriority(a.priority)}           </p>
                            <p id="vc" align="center"> Type:       {formatType(a.kind)}                   </p>
                            <hr color="#B6B79D">
                            <p class="gl_tit" align="center"> <b>Files</b> </p>
                            <p id="vc" align="center"> {checkFiles(a.file_raw, "⭐ Raw")} | {checkFiles(a.file_mw, "⭐ Morrowind")} </p>
                        </td>
                    </tr>
                </table>
                [[ARROW]]

            </td>

            <td width="50%" valign="top" style="padding-top: 0px; padding-left: 15px; padding-right: 15px; margin-top: 0px">
                {a.descr}
            </td>

            <td width="25%" valign="top">
                {conceptArtShowcase(a.art)}
            </td>
        </tr>
    </table>
  """)
  result.replace("[[ARROW]]", "<center><a href=\"" & $Depth.CLAIMS & "files/claims/bdata/list.html" & "\" id=\"v\"> <img src=\"" & $Depth.CLAIMS & "graphics/arr_l.png" & "\"> </a></center>")

proc ioalistBody(ioa_list: seq[IoAClaim], depth: DEPTH, filter: BrowserEnums | string = ""): string =
  var claims_list_str : string # HTML code for table entries
  var backlink        = "<center><a href=\"" & $depth & "projects/ioa.html\" id=\"v\"> Back to main page </a></center>" # only return to FSAM if on main list
  if filter is not string:
      backlink = "<center><a href=\"" & $depth & "files/claims/ioa/list.html\" id=\"v\"> Back to main page </a></center>"
  for claim in orderAssets[IoAClaim](ioa_list, $filter == $MERGED, sort_type=true):
      if filter is not string: # by default, all options are in | TODO: make the check better so it can work with strings that are not ""
          if not filterEnumField(claim, filter): continue # skips adding
      claims_list_str.add(fmt"""
      <tr>
          <td> {linkToPage(claim.name, "ioa", depth)} </td>
          <td> {authorList(claim.claimant)}           </td>
          <td> {formatStatuses(claim.status)}         </td>
          <td> {formatPriority(claim.priority)}       </td>
          <td> {formatType(claim.kind)}               </td>
          <td> {checkFiles(claim.files, "🪔")}        </td>
      </tr>
      """)
  result = fmt"""
  {ioafilterHeader(depth, filter)}

  <table class="archives" width="60%" cellpadding="10px" align="center" border="solid 1px">
      <tr class="head">
          <td width="30%"> Claim      </td>
          <td width="22%"> Developer  </td>
          <td width="15%"> Status     </td>
          <td width="10%"> Priority   </td>
          <td width="15%"> Type       </td>
          <td width="6%">  Files      </td>
      </tr>
      {claims_list_str}
  </table>

  <br><br><br>
  {backlink}
  """

proc claimBody(a: BrowserClaims, proj: string, files: string, imgs: seq[(string, string, string)]): string =
  # files = {checkFiles(a.file_raw, "⭐ Raw")} | {checkFiles(a.file_mw, "⭐ Morrowind")}
  # imgs = a.art OR a.imgs
  var optional_rev: string
  block optionalsHandling:
    if len(a.reviewer) > 0:
      optional_rev = "<p id=\"vc\" align=\"center\"> Reviewer(s): " & authorList(a.reviewer) & "</p>"
  result.add("<p class=\"gl_tit\">" & a.name & "</p>")
  result.add(fmt"""
    <table width="100%" cellpadding="10px">
        <tr>
            <td width="25%" height="700px" valign="top">

                <table width="100%" class="proj">
                    <tr>
                        <td>
                            <p class="gl_tit" align="center"> <b>Asset Lifecycle</b> </p>
                            <p id="vc" align="center"> Developer(s): {authorList(a.claimant)}</p>
                            {optional_rev}
                            <p id="vc" align="center"> Status: {formatStatuses(a.status)}</p>
                            <hr color="#B6B79D">
                            <p class="gl_tit" align="center"> <b>Asset Status</b> </p>
                            <p id="vc" align="center"> Release(s): {releaseList(a.release, Depth.CLAIMS)} </p>
                            <p id="vc" align="center"> Priority:   {formatPriority(a.priority)}           </p>
                            <p id="vc" align="center"> Type:       {formatType(a.kind)}                   </p>
                            <hr color="#B6B79D">
                            <p class="gl_tit" align="center"> <b>Files</b> </p>
                            <p id="vc" align="center"> {files} </p>
                        </td>
                    </tr>
                </table>
                [[ARROW]]

            </td>

            <td width="50%" valign="top" style="padding-top: 0px; padding-left: 15px; padding-right: 15px; margin-top: 0px">
                {a.descr}
            </td>

            <td width="25%" valign="top">
                {conceptArtShowcase(imgs)}
            </td>
        </tr>
    </table>
  """)
  result.replace("[[ARROW]]", "<center><a href=\"" & $Depth.CLAIMS & fmt"files/claims/{proj}/list.html" & "\" id=\"v\"> <img src=\"" & $Depth.CLAIMS & "graphics/arr_l.png" & "\"> </a></center>")

#[ MAIN BODY GENERATOR ]#
proc generateBody(body_subgenerator: string): string =
  result = fmt"""
    <body>
        <div id="header"></div>

        {body_subgenerator}
    </body>
  """

#[ MAIN FUNCTIONS ]#
proc generateAssetPages() =
  for kind, path in walkDir("bdata/[Pages]/"):
    if kind == pcFile:
       removeFile(path)
  for claim in bdata:
      let claim_page = open(fmt"bdata/[Pages]/{parseNameForGeneration(claim.name)}.html", fmWrite)
      defer: claim_page.close()
      claim_page.write(generateHeader(fmt"Asset Browser: {claim.name}", CLAIMS))
      claim_page.write(generateBody(assetclaimBody(claim)))

proc generateAssetLists() =
  for kind, path in walkDir("bdata/[Lists]/"):
    if kind == pcFile:
       removeFile(path)

  const fname   = "list.html"

  let main_list = open(fmt"bdata/{fname}", fmWrite)
  defer: main_list.close()
  main_list.write(generateHeader("Asset Browser", CLAIM_MAIN_LIST))
  main_list.write(generateBody(assetlistBody(bdata, CLAIM_MAIN_LIST)))

  for r in B3DReleaseQueue.low..B3DReleaseQueue.high: # not using RELEASES_FILTER so hidden releases can still be reached
    let release_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_R_{r}.html"), fmWrite)
    defer: release_list.close()
    release_list.write(generateHeader(fmt"Asset Browser: {r}", CLAIM_SUB_LIST))
    release_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, r)))

  for s in STATUSES_FILTER:
    let status_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_S_{s}.html"), fmWrite)
    defer: status_list.close()
    status_list.write(generateHeader(fmt"Asset Browser: {s}", CLAIM_SUB_LIST))
    status_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, s)))

  for p in ClaimPriority.low..ClaimPriority.high:
    let priority_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_P_{p}.html"), fmWrite)
    defer: priority_list.close()
    priority_list.write(generateHeader(fmt"Asset Browser: {p}", CLAIM_SUB_LIST))
    priority_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, p)))

  for k in AssetClaimKind.low..AssetClaimKind.high:
    let kind_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_K_{parseNameForGeneration(k)}.html"), fmWrite)
    defer: kind_list.close()
    kind_list.write(generateHeader(fmt"Asset Browser: {k}", CLAIM_SUB_LIST))
    kind_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, k)))

proc generatePages(proj: string, title: string) =
  # TODO: issues related to abstracting:
    # - `for claim in ioa`
    # - claimBody would need to abstract checkFiles and claim.imgs
    # - claim.imgs is (string, string), whereas assets use tuple of three strings (it is also used in CA art showcase proc)
  for kind, path in walkDir(fmt"{proj}/[Pages]/"):
    if kind == pcFile:
       removeFile(path)
  for claim in ioa:
      let claim_page = open(fmt"{proj}/[Pages]/{parseNameForGeneration(claim.name)}.html", fmWrite)
      defer: claim_page.close()
      claim_page.write(generateHeader(fmt"{title}: {claim.name}", CLAIMS))
      claim_page.write(generateBody(claimBody(claim, proj, checkFiles(claim.files, "⭐ File"), claim.imgs)))

proc generateLists[REL, KIND](proj: string, title: string, status_filter: seq[ClaimStatus]) =
  for kind, path in walkDir(fmt"{proj}/[Lists]/"):
    if kind == pcFile:
       removeFile(path)

  const fname   = "list.html"

  let main_list = open(fmt"{proj}/{fname}", fmWrite)
  defer: main_list.close()
  main_list.write(generateHeader(title, CLAIM_MAIN_LIST))
  main_list.write(generateBody(ioalistBody(ioa, CLAIM_MAIN_LIST)))

  for r in REL.low..REL.high: # not using RELEASES_FILTER so hidden releases can still be reached
    let release_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_R_{r}.html"), fmWrite)
    defer: release_list.close()
    release_list.write(generateHeader(fmt"{title}: {r}", CLAIM_SUB_LIST))
    release_list.write(generateBody(ioalistBody(ioa, CLAIM_SUB_LIST, r)))

  for s in status_filter:
    let status_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_S_{s}.html"), fmWrite)
    defer: status_list.close()
    status_list.write(generateHeader(fmt"{title}: {s}", CLAIM_SUB_LIST))
    status_list.write(generateBody(ioalistBody(ioa, CLAIM_SUB_LIST, s)))

  for p in ClaimPriority.low..ClaimPriority.high:
    let priority_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_P_{p}.html"), fmWrite)
    defer: priority_list.close()
    priority_list.write(generateHeader(fmt"{title}: {p}", CLAIM_SUB_LIST))
    priority_list.write(generateBody(ioalistBody(ioa, CLAIM_SUB_LIST, p)))

  for k in KIND.low..KIND.high:
    let kind_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_K_{parseNameForGeneration(k)}.html"), fmWrite)
    defer: kind_list.close()
    kind_list.write(generateHeader(fmt"{title}: {k}", CLAIM_SUB_LIST))
    kind_list.write(generateBody(ioalistBody(ioa, CLAIM_SUB_LIST, k)))


generateAssetPages()
generateAssetLists()
generatePages("ioa", "Isle of Ansur")
generateLists[IoAReleaseQueue, IoAClaimKind]("ioa", "Isle of Ansur", @[MERGED, R4M, R4R, REQ_FIXES, INDEV, UNCLAIMED, DESIGN])