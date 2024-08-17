import std/[algorithm, strutils, sequtils, dom]

import karax/[kbase, karax, karaxdsl, vdom, jstrutils, kdom]

import ../[packages, context]
import ../components/[package, search]
import ../utils

type
  SortMethod = enum
    smAlphabetical, smCommitAge, smVersionAge
  PageContext = object
    sortMethod: SortMethod = smAlphabetical
    filteredPackages: seq[NimPackage]
    search: kstring

var pgCtx = PageContext()

proc scrollToAnchor(a: string): proc() =
  result = proc() =
    let d = getVNodeById(a)
    scrollIntoView(d.dom)

proc letterlink(activeLinks: seq[char]): VNode = buildHtml:
  tdiv(
    class = "flex flex-wrap md:text-xl text-lg capitalize w-full justify-evenly gap-x-2 md:gap-x-auto"
    ):
    for l in LowercaseLetters:
      tdiv(class = "w-5"):
        if l in activeLinks:
          span(
            class = "link underline decoration-dotted",
            onClick = scrollToAnchor($l)
          ): text l.jss
        else: span(class = "text-ctp-crust"): text l.jss

proc startChar(p: NimPackage): char =
  p.name[0].toLowerAscii

proc alphabeticalPackageList(pkgs: seq[NimPackage]): VNode =
  var charPackages: OrderedTable[char, seq[NimPackage]]
  for pkg in pkgs:
    let c = pkg.startChar
    if c in charPackages:
      charPackages[c].add pkg
    else:
      charPackages[c] = @[pkg]
  result = buildHtml(tdiv):
    letterlink(charPackages.keys.toSeq)
    for c, packages in charPackages:
      tdiv(`id` = c.jss)
      for pkg in packages:
        pkg.card

proc selectSortMethod() =
  let v = getVNodeById("sort-select").getInputText
  pgCtx.sortMethod = SortMethod(parseInt(v))

proc sortSelector(): VNode =
  buildHtml(tdiv(class = "flex items-center")):
    label(`for` = "sort-select"): text "sort:"
    select(class = "bg-ctp-crust rounded p-3", name = "sort",
        `id` = "sort-select", onChange = selectSortMethod):
      for i, msg in ["alphabetical", "recent commit", "recent version"]:
        if i == ord(pgCtx.sortMethod):
          option(value = ($i).cstring, selected = ""): text msg
        else:
          option(value = ($i).cstring): text msg

proc filteredPackagesDom(): VNode =
  if pgCtx.filteredPackages.len == 0:
    return buildHtml(): text "no match...try a different query"
  else:
    case pgCtx.sortMethod:
      of smAlphabetical:
        pgCtx.filteredPackages.sort(sortAlphabetical)
      of smCommitAge:
        pgCtx.filteredPackages.sort(sortCommit, order = Descending)
      of smVersionAge:
        pgCtx.filteredPackages.sort(sortVersion, order = Descending)

    result = buildHtml(tdiv):
      tdiv(class = "text-ctp-surfacetwo"):
        text ($pgCtx.filteredPackages.len & "/" & $ctx.nimpkgs.packages.len) & " packages"
      case pgCtx.sortMethod:
        of smAlphabetical:
          pgCtx.filteredPackages.alphabeticalPackageList
        else:
          for pkg in pgCtx.filteredPackages:
            pkg.card

proc update(pgCtx: var PageContext) =
  pgCtx.filteredPackages = nimpkgsList() 
  pgCtx.search = getSearchFromUri()
  pgCtx.filteredPackages = searchPackages(parseQuery(pgCtx.search))

proc render*(): VNode =
  pgCtx.update
  result =
    buildHtml(tdiv):
      tdiv(class = "flex md:flex-row flex-col md:space-x-5"):
        searchBar(value = pgCtx.search)
        sortSelector()
      filteredPackagesDom()


