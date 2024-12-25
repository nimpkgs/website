import karax/[kbase, karaxdsl, vdom]

import ../style

const headerLinks = [
  ("/#/search", "search"),
  ("/#/metrics", "metrics"),
  ("/#/about","about"),
]

proc headerBar*(): VNode =
  result = buildHtml(tdiv(class = "md:m-5 m-1 flex flex-wrap")):
    a(href = "/#", class = " no-underline"):
      img(src = "img/logo-wide.svg", class = "inline md:h-4rem h-3rem px-1")
    tdiv(class = "grow")
    label(`for` = "menu-toggle",
          class = "cursor-pointer lg:hidden flex items-center px-3 py-2"
      ):
      text "menu"
    input(class = "hidden", type = "checkbox", `id` = "menu-toggle")
    tdiv(class = "lg:flex lg:items-center lg:justify-between hidden w-full lg:w-auto justify-end",
        `id` = "menu"):
      nav(class = "flex justify-end"):
        ul(class = "lg:flex items-center"):
          for (url, msg) in headerLinks:
            li(class = "p-2 hover:bg-ctp-mantle rounded text-sm md:text-lg"):
              a(href = url.kstring, class = accent):
                text msg


