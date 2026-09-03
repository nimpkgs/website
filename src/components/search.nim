import std/strutils
import ../lib
import karax/[jstrutils, karax, karaxdsl, kbase, vdom]

type
  Query* = object
    all,author,owner, name, tag, license = "".kstring

proc parseQuery*(s: kstring): Query =
  result = Query()
  if s == nil: return
  if ":" notin s:
    result.all = s; return

  let parts = s.split(" ")
  for part in parts:
    if ":" in part:
      let
        subparts = part.split(":")
        k = subparts[0]
        v = subparts[1]
      case k:
      of "name":
        result.name = v
      of "tag":
        result.tag = v
      of "author":
        result.author = v
      of "owner":
        result.owner = v
      # license data not currently supported in main search
      # of "license":
        # result.license = v
      else: discard
    else:
      result.all &= part

proc genericSearchString(p: NimPackage): kstring =
  (@[p.url, p.name, p.description, p.tags.join(" ").kstring].join(" ")).toLowerAscii().kstring

func norm(s: kstring): string =
  ($s).replace("-").replace(" ").normalize()

proc filterTag(q: Query, pkg: NimPackage): bool =
  if q.tag == "": return false
  let normTag = norm(q.tag)
  for t in pkg.tags:
    if normTag == norm(t):
      return false
  return true

proc filterAuthor*(q: Query, pkg: NimPackage): bool =
  if q.author == "": return false
  let author = norm(pkg.author.kstring)
  if author == "": return true
  norm(q.author) != author and norm(q.owner) != author

proc filterName(q: Query, pkg: NimPackage): bool =
  if q.name == "": return false
  norm(q.name) != norm(pkg.name)

proc `~=`*(q: Query, pkg: NimPackage): bool =
  let searchStr = pkg.genericSearchString()
  if filterName(q, pkg):
    return
  if filterAuthor(q, pkg):
    return
  if filterTag(q, pkg):
    return
  if q.all.toLowerAscii() in searchStr:
    return true

proc searchBar*(value = jss""): Vnode =
  buildHtml(tdiv(class = "flex flex-row my-2 grow")):
    input(
      `type` = "text",
      class = "bg-ctp-crust md:mx-3 mx-1 p-2 grow".kstring & borderStyle,
      `id` = "search",
      placeholder = "query",
      value = value,
      onChange = getSearchInput
    )
    button(
      class = borderStyle & "p-2 flex items-center",
      onClick = getSearchInput
    ):
      tdiv(class = "i-mdi-magnify")
      text "search"

