import std/[times]
import karax/[kbase, karaxdsl, vdom, jstrutils]

import ../[context, style]

const packagesGitUrlBase = "https://github.com/nim-lang/packages/blob/".kstring

proc footerBar*(): VNode =
  var links: seq[(kstring, kstring)]
  if ctx.loaded:
    let packagesAbbr = ($ctx.nimpkgs.packagesHash)[0..8].kstring
    links.add (
      packagesGitUrlBase & ctx.nimpkgs.packagesHash & "/packages.json".kstring,
      "nim-lang/packages:" & packagesAbbr
    )
  links.add ("http://github.com/nimpkgs/website".kstring, "source".kstring)
  result = buildHtml(footer(class = "mt-auto md:mx-10 flex flex-col md:flex-row md:justify-between md:items-center mb-5")):
    if ctx.loaded:
      tdiv(class = "text-xs text-ctp-subtextzero px-1"):
        text "updated: " & ctx.nimpkgs.updated.format("yyyy-MM-ddZZZ")
    tdiv():
      ul(class = "md:flex items-center"):
        for (url, msg) in links:
          li(class = "px-1 hover:bg-ctp-mantle rounded text-sm flex items-center space-x-1"):
            tdiv(class = "i-mdi-github")
            a(href = url, class = accent):
              text msg


