import std/[strutils, uri]

import karax/[kbase, karax, karaxdsl, vdom, jstrutils]

import ../[packages, style, context]
import ../lib

type
  Query* = object
    all, name, tag, license = "".kstring

proc parseQuery*(s: kstring): Query =
  result = Query()
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
        result.tag = v.replace("-")
      of "license":
        result.license = v
      else: discard
    else:
      result.all &= part

proc toLowerAscii(ks: kstring): kstring {.inline.} = ($ks).toLowerAscii().kstring

proc genericSearchString(p: NimPackage): kstring =
  (@[p.url, p.name, p.description, p.tags.join(" ").kstring].join(" ").kstring).toLowerAscii()

proc `~=`(q: Query, pkg: NimPackage): bool = 
  let searchStr = pkg.genericSearchString()
  if (q.name notin pkg.name) or (q.license notin pkg.license) or
      (q.tag != "".kstring and (q.tag notin pkg.tags)):
    return

  if q.all.toLowerAscii() in searchStr:
    return true

proc searchPackages*(q: Query): seq[NimPackage] =
  if q == Query(): return nimpkgsList()

  collect:
    for _, pkg in ctx.nimpkgs.packages:
      if q ~= pkg: pkg

proc getSearchFromUri*(): kstring =
  result = ""
  var url = currentUri()
  if url.query == "": return
  for k, v in decodeQuery(url.query):
    if k == "query":
      return v.kstring

proc searchBar*(value = jss""): Vnode =
  buildHtml(tdiv(class = "flex flex-row my-2 grow")):
    input(`type` = "text", class = "bg-ctp-crust md:mx-3 mx-1 p-2 grow".kstring & borderStyle, `id` = "search",
          placeholder = "query", value = value,
          onChange = getSearchInput)
    button(`type` = "button", class = borderStyle & "p-2 flex items-center",
        onClick = getSearchInput):
      tdiv(class = "i-mdi-magnify")
      text "search"

