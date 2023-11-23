import std/strutils
import karax/[karax, karaxdsl, vdom]

import components/[header, button, footer]
import pages/pages
import context
import jsconsole

proc render(data: RouterData): VNode =
  console.log ctx
  result = buildHtml(tdiv(class = "lg:w-3/4 max-w-[90%] mx-auto md:text-lg text-sm min-h-screen flex flex-col")):
    headerBar()
    tdiv(class = "mb-5"):
      if not ctx.loaded:
        tdiv(class = "flex h-50"):
          tdiv(class = "mx-auto my-auto lds-dual-ring")
      else:
        case data.hashPart
          of "#/index", "": index.render()
          of "#/search": search.render()
          of "#/metrics": metrics.render()
          else:
            if ($data.hashPart).startswith("#/pkg/"):
              package.render(($data.hashPart).replace("#/pkg/", ""))
            else:
              notfound.render()
    footerBar()
    scrollToTopButton()

setRenderer render
