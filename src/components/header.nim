import karax/[kbase, karaxdsl, vdom]

import ../lib

const headerLinks = [
  ("/#/search", "search"),
  ("/#/metrics", "metrics"),
  ("/#/about","about"),
]

proc navDropdown: VNode = buildHtml(tdiv(class="flex relative")):
  label(
    `for` = "menu-toggle",
    class = "cursor-pointer lg:hidden items-center px-3 py-2 flex"
    ): text "menu"
  input(class="hidden peer", type = "checkbox", `id` = "menu-toggle")
  tdiv(class = "hidden peer-checked:block absolute right-0 top-full z-50 bg-ctp-base lg:flex lg:static lg:items-center",
      `id` = "menu"):
    nav(class = "flex justify-end rounded-md lg:border-none border border-1 b-ctp-" & accent):
      ul(class = "lg:flex items-center"):
        for (url, msg) in headerLinks:
          li(class = "p-2 hover:bg-ctp-mantle rounded text-sm md:text-lg"):
            a(href = url.kstring, class = accent):
              text msg


proc headerBar*(): VNode =
  result = buildHtml(tdiv(class = "md:m-5 m-1 flex flex-wrap overflow-visible")):
    a(href = "/#", class = " no-underline"):
      img(src = "img/logo-wide.svg", class = "inline md:h-4rem h-3rem px-1")
    tdiv(class = "grow")
    navDropdown()


