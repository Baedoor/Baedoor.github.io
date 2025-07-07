import std/strformat
import std/strutils
import webgen_utils
import claims

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
            $('#header').load("{depth}header.html");
         });
        </script>
    </head>
  """
  result = result.replace("{page_subtitle}", page_subtitle)
  result = result.replace("{depth}", $depth)

#[ BODY SUBGENERATORS ]#
proc assetlistBody(): string =
  let claims_assets = yieldAssetClaims("B3D Asset List.ods")
  var claims_list_str: string # HTML code for table entries
  for claim in claims_assets:
      claims_list_str.add(fmt"""
      <tr>
          <td> {linkToPage(claim.name, CLAIM_MAIN_LIST)} </td>
          <td> {authorList(claim.claimant)}              </td>
          <td> {formatStatuses(claim.status)}            </td>
          <td> {checkFiles(claim.file_mw, "🪔")}         </td>
          <td> {checkFiles(claim.file_raw, "🪔")}        </td>
      </tr>
      """)
  result = fmt"""
  <table class="archives" width="60%" cellpadding="10px" align="center" border="solid 1px">
      <tr class="head">
          <td width="40%"> Claim     </td>
          <td width="25%"> Developer </td>
          <td width="15%"> Status    </td>
          <td width="10%"> MW File   </td>
          <td width="10%"> Raw File  </td>
      </tr>
      {claims_list_str}
  </table>
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
                <p id="vc">
                    {a.descr}
                </p>
            </td>

            <td width="25%" valign="top">
                {conceptArtShowcase(a.art)}
            </td>
        </tr>
    <table>
  """)
  result.replace("[[ARROW]]", "<center><a href=\"" & $Depth.CLAIMS & "files/claims/bdata/list.html" & "\" id=\"v\"> <img src=\"" & $Depth.CLAIMS & "graphics/arr_l.png" & "\"> </a></center>")

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
  # TODO: remove all files, so each compilation the list is regenerated (no orphaned files)
  let claims_assets = yieldAssetClaims("B3D Asset List.ods")
  for claim in claims_assets:
      let claim_page = open(fmt"bdata/[Pages]/{parseNameForGeneration(claim.name)}.html", fmWrite)
      defer: claim_page.close()
      claim_page.write(generateHeader(fmt"Asset Browser: {claim.name}", CLAIMS))
      claim_page.write(generateBody(assetclaimBody(claim)))

proc generateAssetLists() =
  const fname = "list.html"

  let main_list = open(fmt"bdata/{fname}", fmWrite)
  defer: main_list.close()
  main_list.write(generateHeader("Asset Browser", CLAIM_MAIN_LIST))
  main_list.write(generateBody(assetlistBody()))

generateAssetPages()
generateAssetLists()