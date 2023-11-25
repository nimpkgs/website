import karax/[karaxdsl, vdom]

import ../components/[search, tag, package]
import ../context

proc render*(): VNode =
  result = buildHtml(tdiv(class = "justify-center")):
    tdiv(class = "flex flex-col space-y-5"):
      tdiv(class = "md:text-4xl text-2xl font-bold font-mono-casual text-center"):
        text "discover Nim's ecosystem of third-party libraries and tools"
      tdiv(class = "grow md:w-4/5 mx-auto"):
        tdiv(class = "flex flex-col md:flex-row grow"):
          searchBar()
      tdiv():
        tdiv():
          text "explore tags:"
        ctx.randomTags()
      tdiv():
        tdiv():
          text "recently released versions:"
        ctx.recentPackageVersionList

