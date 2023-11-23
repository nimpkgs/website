import karax/[karaxdsl, vdom]

import ../components/[search, tag, package]
import ../context

proc render*(): VNode =
  result = buildHtml(tdiv(class = "justify-center")):
    tdiv(class = "flex flex-col space-y-5"):
      tdiv(class = "grow md:w-4/5 mx-auto"):
        tdiv(class = "flex flex-col md:flex-row grow"):
          searchBar()
          # ctx.randomPackage()
      tdiv():
        tdiv():
          text "explore tags:"
        ctx.randomTags()
      tdiv():
        tdiv():
          text "recently released versions:"
        ctx.recentPackageVersionList

