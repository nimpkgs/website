import std/[algorithm, strutils, sequtils, dom, uri, jsffi]

import karax/[kbase, karax, karaxdsl, vdom, kdom]

import ../lib
import ../components/[package, search]

# TODO: better connect search/query/filters/uri and pgCtx

type
  Filters = object
    bin: bool ## package defines "bins"
    valid: bool = true ## package is not deleted or unreachable
    nimble: bool = true ## nimble correctly parses .nimble file
    alias: bool = true ## alias packages

  PageContext = object
    sortMethod: SortMethod = smAlphabetical
    filteredPackages: seq[NimPackage]
    search: kstring
    filters: Filters

var pgCtx = PageContext()

# TODO: make filters part of Query
proc passFilters(pkg: NimPackage): bool =
  if pgCtx.filters.valid:
    if pkg.meta.status in {Deleted, Unreachable}:
      return false
  if pgCtx.filters.bin:
    if not pkg.meta.hasBin:
      return false
  if pgCtx.filters.nimble:
    if pkg.meta.broken:
      return false
  if not pgCtx.filters.alias:
    if pkg.alias != "":
      return false
  return true

proc searchPackages*(q: Query): seq[NimPackage] =
  console.log pgCtx
  if q == Query():
    return collect:
      for _, pkg in nimpkgsList():
        if pkg.passFilters: pkg
  collect:
    for pkg in ctx.nimpkgs.packages:
      if q ~= pkg and pkg.passFilters:
        pkg

proc scrollToAnchor(a: string) {.kcall.} =
  let d = getVNodeById(a)
  scrollIntoView(d.dom)

proc letterlink(activeLinks: seq[char]): VNode = buildHtml:
  let letters =
    if pgCtx.sortMethod == smAlphabeticalReverse:
      LowerCaseLetters.toSeq().reversed
    else:
      LowerCaseLetters.toSeq()
  tdiv(
      class = "flex flex-wrap md:text-xl text-lg capitalize w-full justify-evenly gap-x-2 md:gap-x-auto"
    ):
    for l in letters:
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

proc sortSelector(): VNode =
  buildHtml(tdiv(class = "flex items-center")):
    label(`for` = "sort-select"): text "sort:"
    select(
      class = "bg-ctp-crust rounded p-3",
      name = "sort",
      `id` = "sort-select",
      onChange = getSearchInput # is this insufficient now?
    ):
      for sortMethod, msg in SortMethodDisplay:
        option(value = ($ord(sortMethod)).cstring, selected = sortMethod == pgCtx.sortMethod):
          text msg

proc filteredPackagesDom(): VNode =
  if pgCtx.filteredPackages.len == 0:
    return buildHtml(): text "no match...try a different query"
  else:
    result = buildHtml(tdiv):
      tdiv(class = "text-ctp-surfacetwo"):
        text ($pgCtx.filteredPackages.len & "/" & $ctx.nimpkgs.packages.len) & " packages"
      case pgCtx.sortMethod:
        of smAlphabetical, smAlphabeticalReverse:
          pgCtx.filteredPackages.alphabeticalPackageList
        else:
          for pkg in pgCtx.filteredPackages:
            pkg.card

proc sortPkgs(pgCtx: var PageContext) =
  case pgCtx.sortMethod:
  of smAlphabetical:
    pgCtx.filteredPackages.sort(sortAlphabetical)
  of smAlphabeticalReverse:
    pgCtx.filteredPackages.sort(sortAlphabetical, order = Descending)
  of smCommitAgeRecent:
    pgCtx.filteredPackages.sort(sortCommit, order = Descending)
  of smCommitAgeOldest:
    pgCtx.filteredPackages.sort(sortCommit)
  of smVersionAgeRecent:
    pgCtx.filteredPackages.sort(sortVersion, order = Descending)
  of smVersionAgeOldest:
    pgCtx.filteredPackages.sort(sortVersion)

proc parseFilterBool(param: var bool, val: string) =
  try:
    param = parseBool(val)
  except:
    console.log("failed to parse parameter value as boolean: ", val)

proc updateCtxFromUri() =
  var sortSet = false
  var url = currentUri()
  for k, v in decodeQuery(url.query):
    if k == "query":
      pgCtx.search = v.jss
    if k == "bin":
      parseFilterBool(pgCtx.filters.bin, v)
    if k == "nimble":
      parseFilterBool(pgCtx.filters.nimble, v)
    if k == "valid":
      parseFilterBool(pgCtx.filters.valid, v)
    if k == "alias":
      parseFilterBool(pgCtx.filters.alias, v)
    if k == "sort":
      try:
        pgCtx.sortMethod = parseEnum[SortMethod](v)
        sortSet = true
      except:
        console.log getCurrentExceptionMsg().jss
  if not sortSet:
    pgCtx.sortMethod = smVersionAgeRecent

proc update(pgCtx: var PageContext) =
  updateCtxFromUri()
  pgCtx.filteredPackages = searchPackages(parseQuery(pgCtx.search))
  sortPkgs pgCtx

proc toggle(x: var bool) =
  x = not x

proc pillClass(enabled: bool): kstring =
  result = "border rounded b-1 p-1 min-w-20 text-center ".jss
  if enabled:
    result &= " text-ctp-base "
    result &= "bg-ctp-".jss & accent
  else:
    result &= "text-ctp-".jss & accent

proc pillFilterButton(name: string, checked: bool, cb: proc() ): VNode =
  buildHtml:
    label(`for`= name, class="px-1 m-1"):
      input(type="checkbox", checked=checked, id = name, class="hidden", onChange = cb)
      tdiv(class = pillClass(checked)):
        text name

proc filterSelector(): VNode =
  # TODO: add a hover effect?
  buildHtml(tdiv(class="flex flex-row items-center")):
    tdiv: text "filters:"
    tdiv(class = "flex flex-wrap"):
      pillFilterButton("bin", pgCtx.filters.bin, () => toggle pgCtx.filters.bin)
      pillFilterButton("valid", pgCtx.filters.valid, () => toggle pgCtx.filters.valid)
      pillFilterButton("nimble", pgCtx.filters.nimble, () => toggle pgCtx.filters.nimble)
      pillFilterButton("alias", pgCtx.filters.alias, () => toggle pgCtx.filters.alias)

proc render*(): VNode =
  pgCtx.update
  result =
    buildHtml(tdiv):
      tdiv(class = "flex flex-col"):
        searchBar(value = pgCtx.search)
        tdiv(class ="flex md:flex-row md:space-x-5 flex-col md:mx-auto"):
          sortSelector()
          filterSelector()
      filteredPackagesDom()

