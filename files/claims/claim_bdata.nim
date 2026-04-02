import std/strformat
import std/strutils
import std/options
import std/os
import webgen_utils
import referrer
import claims

proc assetlistBody* (asset_list: seq[AssetClaim], depth: DEPTH, filter: BrowserEnums | string = ""): string =
    var claims_list_str : string # HTML code for table entries
    var backlink        = "<center><a href=\"" & $depth & "projects/fsam.html\" id=\"v\"> Back to main page </a></center>" # only return to FSAM if on main list
    if filter is not string:
        backlink = "<center><a href=\"" & $depth & "files/claims/bdata/list.html\" id=\"v\"> Back to main page </a></center>"
    for claim in orderAssets[AssetClaim](asset_list, $filter == $MERGED):
        if filter is not string: # by default, all options are in | TODO: make the check better so it can work with strings that are not ""
            if not filterClaims(claim, filter): continue # skips adding
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