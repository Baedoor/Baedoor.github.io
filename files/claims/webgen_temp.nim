import std/strformat
import std/strutils
import std/options
import std/os
import webgen_utils
import referrer
import claims

proc ioafilterHeader* (depth: Depth, filter: BrowserEnums | string): string =
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

#[ BODY SUBGENERATORS: LISTS ]#
proc listBody* [T: BrowserClaims](claim_list: seq[T], proj: string, depth: DEPTH, filter_header: string, filter: BrowserEnums | string = "", subf: string = ""): string =
  # subf - subfolder in 'projects', set it if the project is categorised in specific category (e.g. _soft or _games)
  var claims_list_str : string # HTML code for table entries
  var backlink        = "<center><a href=\"" & $depth & "projects/" & subf & proj & ".html\" id=\"v\"> Back to main page </a></center>"
                        # ^ only return to project if on main list, else v | IMPORTANT: this assumes page name and project ID are the same
  if filter is not string:
      backlink = "<center><a href=\"" & $depth & "files/claims/" & proj & "/list.html\" id=\"v\"> Back to main page </a></center>"
  for claim in orderAssets[T](claim_list, $filter == $MERGED, sort_type=true):
      if filter is not string: # by default, all options are in | TODO: make the check better so it can work with strings that are not ""
          if not filterEnumField(claim, filter): continue # skips adding
      claims_list_str.add(fmt"""
      <tr>
          <td> {linkToPage(claim.name, proj, depth)} </td>
          <td> {authorList(claim.claimant)}          </td>
          <td> {formatStatuses(claim.status)}        </td>
          <td> {formatPriority(claim.priority)}      </td>
          <td> {formatType(claim.kind)}              </td>
          <td> {checkFiles(claim.files, "🪔")}       </td>
      </tr>
      """)
  result = fmt"""
  {filter_header}

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

proc ioalistBody* (ioa_list: seq[IoAClaim], depth: DEPTH, filter: BrowserEnums | string = ""): string =
  var claims_list_str : string # HTML code for table entries
  var backlink        = "<center><a href=\"" & $depth & "projects/ioa.html\" id=\"v\"> Back to main page </a></center>" # only return to IOA if on main list
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

proc assetlistBody* (asset_list: seq[AssetClaim], depth: DEPTH, filter: BrowserEnums | string = ""): string =
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
          <td> {checkCAReq(claim.art_req, "‼️", "➕")}   </td>
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