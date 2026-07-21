import claims
import parse
#[ REFERRER
This module is made as a place to expand and/or edit browser subsections
without interfering with less project-specific (and more generator rules-based)
part of the code.
Collecting it in one place also makes it easier to know what parts of code are
not generalistic, thus it will be harder to miss particular proc while making
new or editing already existing browser.
]#
#[ REFERRER OUTSIDE
Functions that would need updating with browsers (or be migrated here)
TODO:
  - webgen_utils
    - `releaseList`
]#
### SHOULD IT BE NAMED "MANAGER"? It kinda functions as one

# filters for webgen generators
const
  STATUSES_FILTER*     = @[MERGED, R4M, R4R, REQ_FIXES, INDEV, UNCLAIMED, DESIGN]
  RELEASES_FILTER*     = @[qDISANE, qKACARI, qBAEDOOR_CITY]
  IOA_RELEASES_FILTER* = @[qTUTORIAL, qEVROS]

# gives you 'yieldClaims' for particular project based on string key
proc PROJ_REPO* [T: BrowserClaims](): seq[T] =
  when T is IoAClaim:   return ioa
  elif T is B3DClaim:   return b3d
  elif T is AssetClaim: return bdata
  elif T is FSAMClaim:  return fsam
#[
const PROJ_REPO* = {
  "ioa"   : var ioa,
  "b3d"   : var b3d,
  "bdata" : var bdata,
  "fsam"  : var fsam
}]#