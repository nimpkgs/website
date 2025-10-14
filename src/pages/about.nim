import std/[tables, strformat]
import karax/[karaxdsl, vdom]

import ../[context, packages, style]

template question(q: static string, body: untyped): untyped =
  let node = buildHtml:
    tdiv(class = "py-5"):
      tdiv(class = "text-2xl italic"):
        text q
      tdiv: body
  result.add node

proc kofi(): VNode =
  buildHtml:
    verbatim """<a href='https://ko-fi.com/D1D618R2ZQ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>"""

proc questionsList(): seq[VNode] =
  question("Why does nimpkgs exist?"):
    text "Mainly for fun, I wanted an excuse to use Karax and the JavaScript backend of Nim for something. If it's helpful to you I'm glad."
  question("How do I add my package to nimpkgs?"):
    text "You don't! All packages are taken from the official repository at "
    a(href="https://github.com/nim-lang/packages"): text "nim-lang/packages"
    text "."
  question("How does nimpkgs get version information?"):
    text "In two words, brute force. Every night a github action scrapes packages for (version-like) tags."
  question("Information about my package is incorrect, how do I update it?"):
    text "First, make sure that the entry at nim-lang/packages is accurate and up-to-date, if nimpkgs is showing something different please open an issue at "
    a(href = "https://github.com/nimpkgs/nimpkgs/issues"): text "nimpkgs/nimpkgs"
    text "."

proc statusBadge(workflow: string): VNode = 
  buildHtml:
    a(href=(fmt"https://github.com/nimpkgs/nimpkgs/actions/workflows/{workflow}.yml").cstring, class="flex"):
      img(src = (fmt"https://github.com/nimpkgs/nimpkgs/actions/workflows/{workflow}.yml/badge.svg").cstring, class="object-none")

proc render*(): VNode =
  result = buildHtml(tdiv):
    h2(class = headerStyle):
      text "About"
    tdiv(class = "mt-10"):
      text "Nimpkgs is a web interface to search for modules added to the official "
      a(href = "https://github.com/nim-lang/packages"):
        text "nim-lang/packages"
      text"."
      tdiv(class = "flex flex-col md:flex-row gap-2 my-3"):
        span: text "Status:"
        statusBadge("nightly")
        statusBadge("serve")

    tdiv:
      hr(class="my-5")
      tdiv(class="my-5"):
        for n in questionsList():
          n
      hr(class="my-5")
      kofi()
