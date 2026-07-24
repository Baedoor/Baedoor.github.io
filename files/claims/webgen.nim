import std/private/osfiles
import std/strformat
import std/strutils
import std/options
import std/os
import webgen_utils
import webgen_temp
import claim_bdata
import referrer
import claims
import parse
import users
import log

proc generateHeader(page_subtitle: string, depth: Depth = CLAIMS, header_tags: HeaderTags): string =
  result = """
    <!doctype html>
    <head>
        <title> Baedoor - {prefix}{page_subtitle} </title>
        <link rel="shortcut icon" href="{depth}graphics/banner_baedoor.png">
        <link rel="stylesheet" href="{depth}bcmain.css">
        <meta charset="UTF-8">
        <!-- Open Graph-compatible meta tags (for embed contents) -->
        <meta property="og:title"       content="{prefix}{page_subtitle}" />
        <meta property="og:type"        content="website" />
        <meta property="og:url"         content="https://baedoor.github.io/{sublink}/{url}" />
        {tag_descr}

        <script src="{depth}import.js"></script>
        <script>
         $(document).ready(function(){
            $('#header').load("{depth}header{number}.html");
         });
        </script>
    </head>
  """.dedent()
  result = result.replace("{page_subtitle}", page_subtitle)
  result = result.replace("{depth}", $depth)
  result = result.replace("{number}", getDepthHeader(depth))
  # metatags
  if header_tags.descr != "":
      result = result.replace("{tag_descr}", fmt"""<meta property="og:description" content="{header_tags.descr}" />""")
  else: result = result.replace("{tag_descr}", "")

  if header_tags.sublink != "":
      result = result.replace("{sublink}", header_tags.sublink)
  else: result = result.replace("{sublink}", "")

  if header_tags.chtml != "": # replaces metatag with link with custom HTML if set
      result = result.replace("{url}", header_tags.chtml)
  else: # if not set, rule-based link is used
      result = result.replace("{url}", fmt"{parseNameForGeneration(page_subtitle)}.html")

  if header_tags.prefix != "":
      result = result.replace("{prefix}", header_tags.prefix)
  else: result = result.replace("{prefix}", "")

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
# TODO: Some of those are stored in 'webgen_temp.nim', as this subsection should be abstractified
proc assetclaimBody(a: AssetClaim): string =
  var optional_rev: string
  block optionalsHandling:
    if len(a.reviewer) > 0:
      optional_rev = "<p id=\"vc\" align=\"center\"> Reviewer(s): " & authorList(a.reviewer, Depth.CLAIMS) & "</p>"
  result.add("<p class=\"gl_tit\">" & a.name & "</p>")
  result.add(fmt"""
    <table width="100%" cellpadding="10px">
        <tr>
            <td width="25%" height="700px" valign="top">

                <table width="100%" class="proj">
                    <tr>
                        <td>
                            <p class="gl_tit" align="center"> <b>Asset Lifecycle</b> </p>
                            <p id="vc" align="center"> Developer(s): {authorList(a.claimant, Depth.CLAIMS)}</p>
                            {optional_rev}
                            <p id="vc" align="center"> Status: {formatStatuses(a.status)}</p>
                            <hr color="#B6B79D">
                            <p class="gl_tit" align="center"> <b>Asset Status</b> </p>
                            <p id="vc" align="center"> Release(s): {releaseList(a.release, Depth.CLAIMS, "bdata")} </p>
                            <p id="vc" align="center"> Priority:   {formatPriority(a.priority)}                    </p>
                            <p id="vc" align="center"> Type:       {formatType(a.kind)}                            </p>
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
                {conceptArtShowcase(a.imgs)}
            </td>
        </tr>
    </table>
  """)
  result.replace("[[ARROW]]", "<center><a href=\"" & $Depth.CLAIMS & "files/claims/bdata/list.html" & "\" id=\"v\"> <img src=\"" & $Depth.CLAIMS & "graphics/arr_l.png" & "\"> </a></center>")

proc claimBody(a: BrowserClaims, proj: string, files: string): string =
  # TODO: Things to adjust for all browsers to use this:
  # files = {checkFiles(a.file_raw, "⭐ Raw")} | {checkFiles(a.file_mw, "⭐ Morrowind")}
  var optional_rev: string
  var optional_rel: string
  var optional_sct: string
  block optionalsHandling:
      if len(a.reviewer) > 0:
        optional_rev = "<p id=\"vc\" align=\"center\"> Reviewer(s): " & authorList(a.reviewer, Depth.CLAIMS) & "</p>"
      when not (a is FSAMClaim):
        optional_rel = "<p id=\"vc\" align=\"center\"> Release(s): " & releaseList(a.release, Depth.CLAIMS, proj) & "</p>"
      block optionalsSection:
          when a is B3DClaim:
            if a.section[0] != NONE:
              optional_rel = "<p id=\"vc\" align=\"center\"> Section: " & fmt"{a.section[0]} [{a.section[1]}]" & "</p>"
          elif a is FSAMClaim:
            if a.section != "":
              optional_rel = "<p id=\"vc\" align=\"center\"> Merged on: " & a.section & "</p>"
  result.add("<p class=\"gl_tit\">" & a.name & "</p>")
  result.add(fmt"""
    <table width="100%" cellpadding="10px">
        <tr>
            <td width="25%" height="700px" valign="top">

                <table width="100%" class="proj">
                    <tr>
                        <td>
                            <p class="gl_tit" align="center"> <b>Claim Lifecycle</b> </p>
                            <p id="vc" align="center"> Developer(s): {authorList(a.claimant)}</p>
                            {optional_rev}
                            <p id="vc" align="center"> Status: {formatStatuses(a.status)}</p>
                            <hr color="#B6B79D">
                            <p class="gl_tit" align="center"> <b>Claim Status</b> </p>
                            {optional_rel}
                            <p id="vc" align="center"> Priority:   {formatPriority(a.priority)}           </p>
                            <p id="vc" align="center"> Type:       {formatType(a.kind)}                   </p>
                            {optional_sct}
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
                {conceptArtShowcase(a.imgs)}
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
  log(LOG, "Clearing asset pages...")

  for kind, path in walkDir("bdata/[Pages]/"):
    if kind == pcFile:
       removeFile(path)
       log(LOG, "Cleared: " & $path)

  log(LOG, "Creating asset pages...")
  for claim in bdata:
      let utags = buildTags(
          descr   = fmt"Status: {claim.status} || Priority: {claim.priority} || Description: {pruneHTML(claim.descr)}",
          sublink = fmt"files/claims/bdata/[Pages]",
          pfix    = "Asset Browser: "
      )
      let claim_page = open(fmt"bdata/[Pages]/{parseNameForGeneration(claim.name)}.html", fmWrite)
      defer: claim_page.close()
      claim_page.write(generateHeader(claim.name, CLAIMS, utags))
      claim_page.write(generateBody(assetclaimBody(claim)))

proc generateAssetLists() =
  for kind, path in walkDir("bdata/[Lists]/"):
    if kind == pcFile:
       removeFile(path)

  const fname   = "list.html"

  let main_list = open(fmt"bdata/{fname}", fmWrite)
  let mutags = buildTags(
      descr   = "",
      sublink = "files/claims/bdata"
  )
  defer: main_list.close()
  main_list.write(generateHeader("Asset Browser", CLAIM_MAIN_LIST, mutags))
  main_list.write(generateBody(assetlistBody(bdata, CLAIM_MAIN_LIST)))

  for r in B3DReleaseQueue.low..B3DReleaseQueue.high: # not using RELEASES_FILTER so hidden releases can still be reached
    let release_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_R_{r}.html"), fmWrite)
    let utags = buildTags(
        descr       = "",
        sublink     = "files/claims/bdata/[Lists]",
        custom_html = fname.replace(".html", fmt"_R_{r}.html")
    )
    defer: release_list.close()
    release_list.write(generateHeader(fmt"Asset Browser: {r}", CLAIM_SUB_LIST, utags))
    release_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, r)))

  for s in STATUSES_FILTER:
    let status_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_S_{s}.html"), fmWrite)
    let utags = buildTags(
        descr       = "",
        sublink     = "files/claims/bdata/[Lists]",
        custom_html = fname.replace(".html", fmt"_S_{s}.html")
    )
    defer: status_list.close()
    status_list.write(generateHeader(fmt"Asset Browser: {s}", CLAIM_SUB_LIST, utags))
    status_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, s)))

  for p in ClaimPriority.low..ClaimPriority.high:
    let priority_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_P_{p}.html"), fmWrite)
    let utags = buildTags(
        descr       = "",
        sublink     = "files/claims/bdata/[Lists]",
        custom_html = fname.replace(".html", fmt"_P_{p}.html")
    )
    defer: priority_list.close()
    priority_list.write(generateHeader(fmt"Asset Browser: {p}", CLAIM_SUB_LIST, utags))
    priority_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, p)))

  for k in AssetClaimKind.low..AssetClaimKind.high:
    let kind_list = open(fmt"bdata/[Lists]/{fname}".replace(".html", fmt"_K_{parseNameForGeneration(k)}.html"), fmWrite)
    let utags = buildTags(
        descr       = "",
        sublink     = "files/claims/bdata/[Lists]",
        custom_html = fname.replace(".html", fmt"_K_{parseNameForGeneration(k)}.html")
    )
    defer: kind_list.close()
    kind_list.write(generateHeader(fmt"Asset Browser: {k}", CLAIM_SUB_LIST, utags))
    kind_list.write(generateBody(assetlistBody(bdata, CLAIM_SUB_LIST, k)))

proc generatePages[T](proj: string, title: string) =
  # T = claim object (used by repo)
  # TODO: issues related to abstracting:
    # - claimBody would need to abstract checkFiles
  for kind, path in walkDir(fmt"{proj}/[Pages]/"):
    if kind == pcFile:
       removeFile(path)
  for claim in PROJ_REPO[T]():
      let claim_page = open(fmt"{proj}/[Pages]/{parseNameForGeneration(claim.name)}.html", fmWrite)
      defer: claim_page.close()
      claim_page.write(generateHeader(fmt"{title}: {claim.name}", CLAIMS, emptyTags()))
      claim_page.write(generateBody(claimBody(claim, proj, checkFiles(claim.files, "⭐ File"))))

proc generateLists[REL, CL_OBJ, KIND](proj          : string,
                                      title         : string,
                                      cl_seq        : seq[CL_OBJ],
                                      filter_proc   : proc(depth: Depth, filter: BrowserEnums | string): string,
                                      proj_subf     : string,
                                      status_filter : seq[ClaimStatus]) =
  # REL    = ReleaseQueue
  # CL_OBJ = claim object
  # KIND   = kind enum for CL_OBJ

  # cl_seq     - the data object that this particular list is based on
  # filter_str - unique 'string' that differentiates between projects
  # subf       - subfolder for project page (see `listBody` for clearer reference)
  for kind, path in walkDir(fmt"{proj}/[Lists]/"):
    if kind == pcFile:
       removeFile(path)

  const fname   = "list.html"

  let main_list = open(fmt"{proj}/{fname}", fmWrite)
  defer: main_list.close()
  main_list.write(generateHeader(title, CLAIM_MAIN_LIST, emptyTags()))
  main_list.write(generateBody(
                      listBody[CL_OBJ](cl_seq, proj, CLAIM_MAIN_LIST, filter_proc(CLAIM_MAIN_LIST, ""), subf=proj_subf)))
  #
  # when not (REL is NoneQueue):  # checking if CL_OBJ contains release field
  #   for r in REL.low..REL.high: # not using RELEASES_FILTER so hidden releases can still be reached
  #     let release_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_R_{r}.html"), fmWrite)
  #     defer: release_list.close()
  #     release_list.write(generateHeader(fmt"{title}: {r}", CLAIM_SUB_LIST))
  #     release_list.write(generateBody(
  #                           listBody[CL_OBJ](cl_seq, proj, CLAIM_SUB_LIST, filter_proc(CLAIM_SUB_LIST, r), r, subf=proj_subf)))
  #
  # for s in status_filter:
  #   let status_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_S_{s}.html"), fmWrite)
  #   defer: status_list.close()
  #   status_list.write(generateHeader(fmt"{title}: {s}", CLAIM_SUB_LIST))
  #   status_list.write(generateBody(
  #                         listBody[CL_OBJ](cl_seq, proj, CLAIM_SUB_LIST, filter_proc(CLAIM_SUB_LIST, s), s, subf=proj_subf)))
  #
  # for p in ClaimPriority.low..ClaimPriority.high:
  #   let priority_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_P_{p}.html"), fmWrite)
  #   defer: priority_list.close()
  #   priority_list.write(generateHeader(fmt"{title}: {p}", CLAIM_SUB_LIST))
  #   priority_list.write(generateBody(
  #                           listBody[CL_OBJ](cl_seq, proj, CLAIM_SUB_LIST, filter_proc(CLAIM_SUB_LIST, p), p, subf=proj_subf)))
  #
  # for k in KIND.low..KIND.high:
  #   let kind_list = open(fmt"{proj}/[Lists]/{fname}".replace(".html", fmt"_K_{parseNameForGeneration(k)}.html"), fmWrite)
  #   defer: kind_list.close()
  #   kind_list.write(generateHeader(fmt"{title}: {k}", CLAIM_SUB_LIST))
  #   kind_list.write(generateBody(
  #                       listBody[CL_OBJ](cl_seq, proj, CLAIM_SUB_LIST, filter_proc(CLAIM_SUB_LIST, k), k, subf=proj_subf)))

try:
    generateAssetPages()
    generateAssetLists()
    # generatePages[IoAClaim]("ioa",  "Isle of Ansur")
    # generateLists[IoAReleaseQueue, IoAClaim, IoAClaimKind]("ioa", "Isle of Ansur",
    #                                                        cl_seq        = ioa,
    #                                                        filter_proc   = ioafilterHeader,
    #                                                        proj_subf     = "",
    #                                                        status_filter = @[MERGED, R4M, R4R, REQ_FIXES, INDEV, UNCLAIMED, DESIGN])
    generateUserPages(USERS, generateHeader, generateBody)
finally:
    dumpLogger(LOG)
# TODO
# generatePages[B3DClaim]("b3d",  "Baedoor")
# generatePages[FSAMClaim]("fsam", "From Steam and Magic")

# TODO:
# generateLists[B3DReleaseQueue, B3DClaimKind]("b3d", "Baedoor",
#                                              status_filter = @[MERGED, R4M, R4R, REQ_FIXES, INDEV, UNCLAIMED, DESIGN])
# generateLists[NoneQueue,       B3DClaimKind]("fsam", "From Steam and Magic",
#                                              status_filter = @[MERGED, R4M, R4R, REQ_FIXES, INDEV, UNCLAIMED, DESIGN])