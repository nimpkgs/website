import std/[dom, sugar]
import karax/[karax, karaxdsl, vdom, vstyles]

import ../lib

proc showScrollToTop() =
  # TODO: only show button when scrolling up
  let mybtn = document.getElementById("scrollBtn")
  # if document.body.scrollTop > 500 or document.documentElement.scrollTop > 500:
  let show = (document.body.scrollTop > 500) or (
      document.documentElement.scrollTop > 500)
  mybtn.style.display =
    if show: "block"
    else: "none"

document.addEventListener("scroll", (e: dom.Event) => showScrollToTop())

proc scrollToTopButton*(): VNode =

  result = buildHtml(tdiv):
    button(
      class =
      " absolute fixed md:bottom-10 right-10 bottom-2 " &
      " md:p-5 p-2 cursor-pointer z-99 rounded " &
      " bg-ctp-rosewater hover:bg-ctp-mauve text-ctp-mantle ",
      `id` = "scrollBtn",
      onClick = scrollToTop,
      style = "display:none;".toCss
      ):
      text "Back to top"


