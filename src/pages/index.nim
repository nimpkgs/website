import std/[sequtils, strutils, strformat]
import karax/[karaxdsl, vdom]
import ../components/[search, tag, package]
import ../lib

# TODO: add more "fun" facts?
proc getFact(): string =
  let nPackages  = nimpkgsList().filterIt("nim" in toLowerAscii($it.name)).len()
  result = fmt"Currently {nPackages} packages use the word nim!"

proc funFact(): VNode =
  buildHtml(tdiv):
    span(class = "font-bold"): text "Fun Fact"
    text ": "
    text getFact()


proc render*(): VNode =
  result = buildHtml(tdiv(class = "justify-center")):
    tdiv(class = "flex flex-col space-y-5"):
      tdiv(class = "text-center"):
        tdiv(class = "md:text-4xl text-2xl font-bold font-mono-casual my-1"):
          text "discover Nim's ecosystem of third-party libraries and tools"
        funFact()
      tdiv(class = "grow md:w-4/5 mx-auto"):
        tdiv(class = "flex flex-col md:flex-row grow"):
          searchBar()
      tdiv():
        tdiv(): text "explore tags:"
        randomTags()
      tdiv():
        tdiv(): text "recently added packages:"
        recentAddedPackagesList()
      tdiv():
        tdiv(): text "recently released versions:"
        recentPackageVersionsList()
