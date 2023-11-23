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


func replace*(c: kstring, sub: string, by = " "): kstring =
  ($c).replace(sub, by).jss

proc setSearchUrl*(searchQuery: kstring): proc() =
  proc() =
    var url = parseUri($window.location.href)
    url.anchor = "/search"
    url = url ? {"query": $searchQuery}
    window.history.pushState(js{}, "".jss, url.jss)
    let d = getVNodeById("search")
    let node = d.dom
    scrollIntoView(node)
    redraw()

