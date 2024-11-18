import std/[strutils, uri]
import std/jsffi except `&`
import jsconsole
export jsconsole

import karax/[kbase, karax, vdom, kdom]

proc jss*[T](arg: T): kstring = ($arg).kstring
proc jss*(arg: kstring): kstring = arg

proc noProtocol*(s: kstring): kstring =
  ($s)
    .replace("http://", "")
    .replace("https://", "")
    .jss

proc currentUri*(): Uri {.inline.} =
  parseUri($window.location.href)

func replace*(c: kstring, sub: string, by = " "): kstring =
  ($c).replace(sub, by).jss

type
  SortMethod* = enum
    smAlphabetical = "smAlphabetical", smCommitAge = "commit", smVersionAge = "version"

proc setSearchUrl*(searchQuery: kstring, sortMethod = smAlphabetical): proc() =
  proc() =
    var 
      url = currentUri()
      params: seq[(string, string)]
    if searchQuery != "":
      params.add ("query", $searchQuery)
    if sortMethod != smAlphabetical:
      params.add ("sort", $sortMethod)
    url.anchor = "/search"
    url = url ? params
    window.history.pushState(js{}, "".jss, url.jss)
    let d = getVNodeById("search")
    let node = d.dom
    scrollIntoView(node)
    redraw()

