import std/[dom, sugar]

include karax/prelude
import karax/vstyles

proc showScrollToTop() =
  # TODO: only show button when scrolling up
  let mybtn = document.getElementById("scrollBtn")
  # if document.body.scrollTop > 500 or document.documentElement.scrollTop > 500:
  let show = (document.body.scrollTop > 500) or (
      document.documentElement.scrollTop > 500)
  mybtn.style.display =
    if show: "block"
    else: "none"


proc scrollToTop*() =
  document.body.scrollTop = 0
  document.documentElement.scrollTop = 0

document.addEventListener("scroll", (e: Event) => showScrollToTop())

proc scrollToTopButton*(): VNode =

  result = buildHtml(tdiv):
    button(
      class =
      " absolute fixed md:bottom-10 md:right-10 bottom-2 right-2 " &
      " md:p-5 p-2 cursor-pointer z-99 rounded " &
      " bg-ctp-rosewater hover:bg-ctp-mauve text-ctp-mantle ",
      `id` = "scrollBtn",
      onClick = scrollToTop,
      style = "display:none;".toCss
      ):
      text "Back to top"


