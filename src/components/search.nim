import std/[strutils]
import karax/[kbase, karax, karaxdsl, vdom, jstrutils]
import ../lib

type
  Query* = object
    all, name, tag, license = "".kstring

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
      of "license":
        result.license = v
      else: discard
    else:
      result.all &= part

proc genericSearchString(p: NimPackage): kstring =
  (@[p.url, p.name, p.description, p.tags.join(" ").kstring].join(" ")).toLowerAscii().kstring

func norm(s: kstring): string =
  ($s).replace("-").replace(" ").normalize()

func `!->`(a, b: kstring): bool =
  norm(a) notin norm(b)

proc hasTag(pkg: NimPackage, tag: string): bool =
  if tag == "": return false
  let normTag = norm(tag)
  for t in pkg.tags:
    if normTag == norm(t):
      return false
  return true

proc `~=`*(q: Query, pkg: NimPackage): bool =
  let searchStr = pkg.genericSearchString()
  if (q.name !-> pkg.name) or (q.license !-> pkg.license) or pkg.hasTag($q.tag):
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

