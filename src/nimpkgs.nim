import std/[strutils, sets, sequtils, random]
include karax / prelude

import packages, button

type
  Query = object
    all, name, tag, license = "".kstring

randomize()


var
  filteredPackages: seq[Package] = allPackages
  searchInput: kstring = "".kstring
const
  packagesGitUrl = "https://github.com/nim-lang/packages/blob/" & packagesHash & "/packages.json"
  numPackages = allPackages.len
  numTags = allTags.len
  colors = [
    "flamingo",
    "pink",
    "mauve",
    "red",
    "maroon",
    "peach",
    "yellow",
    "green",
    "teal",
    "sky",
    "sapphire",
    "blue",
    "lavender"
  ]
let
  accent = (" " & colors.sample() & " ").kstring
  textStyle = (" text-ctp-" & accent & " ").kstring
  borderStyle = (" b-ctp-" & accent & " ").kstring
  randomPkgIndices = [
      rand(numPackages-1), rand(numPackages-1), rand(numPackages-1),
      rand(numPackages-1), rand(numPackages-1), rand(numPackages-1),
      rand(numPackages-1), rand(numPackages-1), rand(numPackages-1),
      rand(numPackages-1)]
  randomTagIndices = [
      rand(numTags-1), rand(numTags-1), rand(numTags-1),
      rand(numTags-1), rand(numTags-1), rand(numTags-1)
  ]



proc parseQuery(s: kstring): Query =
  result = Query()
  if ":" notin s:
    result.all = s; return

  let parts = s.split(" ")
  for part in parts:
    if ":" in part:
      let
        subparts = part.split(":")
        k = subparts[0]
        v = subparts[1]
      case k:
        of "name":
          result.name = v
        of "tag":
          result.tag = v
        of "license":
          result.license = v
        else: discard
    else:
      result.all &= part

proc searchPackages(q: Query) =
  filteredPackages = @[]
  if q == Query():
    filteredPackages = allPackages
    return
  for pkg in allPackages:
    let searchStr = ((pkg.name & " " & pkg.description & " " & (pkg.tags).join(" ").kstring))
    if (q.name notin pkg.name) or
    (q.license notin pkg.license) or
    (q.tag != "".kstring and (q.tag notin pkg.tags)): continue

    if q.all in searchStr:

      filteredPackages.add pkg

proc setSearch(v: kstring): proc () =
  result = proc() =
    searchInput = v
    searchPackages(parseQuery(v))
    redraw()

proc fieldToDom(s: kstring): VNode =
  result = buildHtml(tdiv(class = "font-black basis-1/4 sm:basis-1/6 shrink-0")):
    text s & ":"

proc noProtocol(s: kstring): kstring = kstring(($s).replace("http://",
    "").replace("https://", ""))

proc toDom(pkg: Package): VNode =
  result = buildHtml(tdiv(class = "flex flex-col bg-ctp-crust rounded-xl my-5 p-5")):
    h2(class = (textStyle & "font-black md:text-2xl text-lg font-casual").kstring):
      text ("# " & pkg.name).kstring
    if pkg.alias != "":
      tdiv:
        text "alias for: "
        span(onClick = setSearch("name:" & pkg.alias),
            class = "hover:text-ctp-mauve"):
          text pkg.alias
    else:
      text pkg.description
      tdiv(class = "flex flex-col text-xs md:text-lg overflow-x-scroll"):
        tdiv(class = "flex flex-row"):
          fieldToDom("project")
          a(href = pkg.url):
            text pkg.url.noProtocol
        tdiv(class = "flex flex-row"):
          fieldToDom("web")
          a(href = pkg.web): text pkg.web.noProtocol
        if pkg.doc != "":
          tdiv(class = "flex flex-row"):
            fieldToDom("doc")
            a(href = pkg.doc): text pkg.doc.noProtocol
        tdiv(class = "flex flex-row"):
          fieldToDom("license")
          span: text pkg.license
        tdiv(class = "flex flex-row"):
          fieldToDom("tags")
          tdiv():
            for t in pkg.tags:
              span(onClick = setSearch("tag:" & t),
                  class = "hover:text-ctp-mauve"):
                text t
              text "; "

        # tdiv(class="bg-ctp-mantle rounded my-2 p-2"):
        #   text "nimble install " & p.name
        #   br()
        #   text "atlas use " & p.name

proc startChar(p: Package): char = p.name[0].toLowerAscii

proc toDom(pkgs: seq[Package]): VNode =
  var l = 'a'
  result = buildHtml(tdiv):
    if pkgs[0].startChar == l: tdiv(id = ($l).kstring)
    for pkg in pkgs:
      let startC = pkg.name[0].toLowerAscii
      if l != startC:
        while l != startC: inc l
        tdiv(id = ($l).kstring)
      pkg.toDom

proc getSearchInput() =
  searchInput = getVNodeById("search").getInputText
  searchPackages(parseQuery(searchInput))

proc render(t: Tag): VNode =
  result = buildHtml(tdiv(class = "bg-ctp-mantle m-1 p-1 rounded hover:text-ctp-mauve")):
    tdiv(onClick = setSearch("tag:" & t.name)):
      text t.name & "|" & kstring($t.packages)

proc searchBar(): Vnode =
  result = buildHtml(tdiv(class = "flex flex-col md:flex-row md:items-center md:my-5")):
    tdiv(class = "flex flex-row my-2"):
      input(`type` = "text", class = "border-1 bg-ctp-crust rounded mx-3 p-2".kstring & borderStyle, `id` = "search",
            placeholder = "query", value = searchInput,
            onChange = getSearchInput)
      button(`type` = "button", class = "border-1 rounded p-2".kstring &
          borderStyle, onClick = getSearchInput):
        text "search"
    #[
    tdiv(class = "md:mx-5 flex flex-col items-center"):
      tdiv: text "examples: "
      tdiv(class="flex flex-col"):
        for msg in ["tag:database sqlite","license:MIT javascript"]:
          span(class = "bg-ctp-mantle rounded text-ctp-subtextone m-1 p-1 text-xs"):
            text msg 
    ]#
    tdiv(class = "flex flex-col mx-5"):
      tdiv: text "explore tags:"
      tdiv(class = "flex flex-wrap text-sm"):
        for idx in randomTagIndices:
          allTags[idx].render


proc headerBar(): VNode =
  result = buildHtml(tdiv(class = "mt-5 mx-5 flex flex-wrap")):
    tdiv(class = "flex items-center my-3 grow"):
      img(src = "img/logo.svg", class = "inline h-1em md:h-2em px-1")
      span(class = "font-bold md:text-4xl text-lg font-casual"):
        text "pkgs"
    label(`for` = "menu-toggle",
          class = "cursor-pointer lg:hidden flex items-center px-3 py-2"
      ):
      text "menu"
    input(class = "hidden", type = "checkbox", `id` = "menu-toggle")
    tdiv(class = "lg:flex lg:items-center justify-between hidden w-full lg:w-auto",
        `id` = "menu"):
      nav:
        ul(class = "md:flex items-center"):
          for (url, msg) in [
              (packagesGitUrl, "nim-lang/packages:" & packagesHashAbbr),
              ("http://github.com/daylinmorgan/nimpkgs", "source")
              ]:
            li(class = "p-2 hover:bg-ctp-mantle rounded text-sm"):
              a(href = url.kstring, class = accent):
                text msg

proc includedLinks(pkgs: seq[Package]): HashSet[char] =
  pkgs.mapIt(it.startChar).toHashSet

proc letterlink(): VNode =
  let activeLinks = includedLinks(filteredPackages)
  result = buildHtml(tdiv(class = "flex flex-wrap md:text-xl text-lg capitalize w-full justify-evenly gap-x-2 md:gap-x-auto")):
    for l in LowercaseLetters:
      tdiv(class = "w-5"):
        if l in activeLinks:
          a(href = "#" & ($l).kstring):
            text $l
        else:
          span(class = "text-ctp-crust"):
            text $l

proc filteredPackagesDom(): VNode =
  if filteredPackages.len > 0:
    result = filteredPackages.toDom
  else:
    result = buildHtml():
      text "no match...try a different query"


proc createDom(): VNode =
  result = buildHtml(tdiv(class = "md:w-3/4 max-w-[95%] md:mx-auto mx-5 md:text-lg text-sm")):
    headerBar()
    searchBar()
    letterlink()
    tdiv(class = "text-ctp-surfacetwo"):
      text ($filteredPackages.len & "/" & $allPackages.len) & " packages"
    if searchInput == "":
      tdiv():
        for idx in randomPkgIndices:
          allPackages[idx].toDom
        hr()
    filteredPackagesDom()
    scrollToTopButton()

setRenderer createDom
