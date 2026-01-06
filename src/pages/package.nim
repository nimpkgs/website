import std/[algorithm, sugar]
import karax/[kbase, karax, karaxdsl, kdom, vdom, jstrutils]

import ../[context, packages, style]
import ../components/[tag, package]
import ../lib

proc openLink(link: kstring) {.kcall.} =
  discard open(window, link, "_self")

# TODO: version header?
# links broken for none github sites

proc link(pkg: NimPackage, version: Version): kstring =
  if pkg.canonicalUrl.startsWith("https://codeberg.org"):
    return pkg.canonicalUrl & "/src/tag/" & version.tag.jss

  # this version should work for github and gitlab
  return pkg.canonicalUrl & "/tree/" & version.tag.jss

proc versionTable(pkg: NimPackage): VNode =
  var versions = pkg.meta.versions
  versions.sort((a, b: Version) => cmp(a.time, b.time), order = Descending)
  buildHtml(tdiv(class = "my-5 p-5 bg-ctp-crust rounded")):
    h2(class = textStyle & "text-xl md:text-3xl font-bold font-mono-casual mx-auto mb-2"):
      text "versions"
    table(class = "table-auto w-full text-center"):
      tr:
        th: text "tag"
        th: text "released"
        th: text "hash"
      for version in versions:
        tr(
          onClick = openLink(link(pkg, version)),
          class = "link"
        ):
          td: text version.tag
          td: text version.time.format("yyyy-MM-dd")
          td: text ($version.hash)[0..8]

proc renderAlias(pkg: NimPackage): VNode = buildHtml:
  tdiv:
    text pkg.name & "is alias for "
    a(href = "#/pkg/" & pkg.alias):
      text pkg.alias

proc renderLinks(pkg: NimPackage): VNode =
  buildHtml(tdiv(class = "overflow-auto")):
    tdiv: text "links:"
    tdiv:
      pkg.projectUrl
    if pkg.web != "" and pkg.web != pkg.url:
      tdiv():
        a(href = pkg.web, class = "flex items-center space-x-2"):
          tdiv(class = "i-mdi-web shrink-0")
          span: text pkg.web.noProtocol
    if pkg.doc != "":
      tdiv():
        a(href = pkg.doc, class = "flex items-center space-x-2"):
          tdiv(class = "i-mdi-file-outline shrink-0")
          span: text pkg.doc.noProtocol

proc getTimeSinceCommit(pkg: NimPackage): kstring =
  if pkg.meta.commit.time == fromUnix(0): "unknown".jss
  else:
    let d = getTime() - pkg.meta.commit.time
    d.inDays.jss & " days ago"

proc renderPkgInfo(pkg: NimPackage): VNode =
  buildHtml:
    tdiv(class = "space-y-5 text-lg"):
      tdiv(class = "md:text-3xl"):
        text pkg.description
      pkg.renderLinks
      tdiv:
        tdiv: text "license:"
        text pkg.license.jss
      tdiv:
        tdiv: text "tags:"
        pkg.tags.renderTags
      tdiv:
        tdiv: text "last commit:"
        text pkg.getTimeSinceCommit
      tdiv:
        tdiv: text "usage:"
        tdiv(class = "bg-ctp-surfacezero rounded my-2 mx-3 p-2 w-auto overflow-auto"):
          pre:
            text "nimble install " & pkg.name
          pre:
            text "atlas use " & pkg.name

# TODO: normalize header/sections styling
proc nimbleRequiresView(reqs: seq[NimbleRequire]): VNode = 
  buildHtml(tdiv):
    tdiv: text "requires:"
    ul(class = "pl-2"):
      for r in reqs:
        li(class = "flex flex-row"):
          # TODO: make a nimpkgs link
          p(class = "px-1 text-bold"): text r.name
          p: text r.str

proc nimbleMetadataView(nimble: NimbleDump): VNode =
  buildHtml(tdiv(class = "my-5 p-5 bg-ctp-crust rounded")):
    h2(class = textStyle & "text-xl md:text-3xl font-bold font-mono-casual mx-auto mb-2"):
      text "metadata"
    if nimble.bin.len > 0:
      tdiv:
        tdiv: text "bin:"
        span(class ="pl-2"): text nimble.bin.join(", ")
    if nimble.requires.len > 0:
      nimbleRequiresView(nimble.requires)
    # TODO: make the info good and remove this
    span(class= "text-sm text-ctp-yellow inline-block pt-5"):
      tdiv(class = "i-mdi-alert inline-block")
      text "this info is still experimental, and may have errors!"

proc render*: VNode =
  if ctx.package.name.isNil or not ctx.packageLoaded:
    return buildHtml(tdiv())
  let pkg = ctx.package
  result = buildHtml(tdiv(class = "flex flex-col")):
    if pkg.meta.status in [Unreachable, Deleted]:
      tdiv(class = "md:text-3xl text-2xl text-ctp-red my-5 "):
        tdiv(class = "flex items-center md:text-5xl text-2xl font-mono-casual font-black"):
          tdiv(class = "i-mdi-alert inline-block")
          span: text "WARNING!"
        if pkg.meta.status == Unreachable:
          text "The provided url for this package is unreachable, it may have been deleted."
        elif pkg.meta.status == Deleted:
          text "The package has been marked deleted."
    tdiv(class = "bg-ctp-mantle rounded p-5"):
      h2(class = textStyle & "text-3xl md:text-6xl font-bold font-mono-casual my-2"):
        text pkg.name
      if pkg.isAlias: pkg.renderAlias
      else: pkg.renderPkgInfo
    if pkg.meta.nimble.isSome:
      nimbleMetadataView(pkg.meta.nimble.get())
    if pkg.meta.versions.len > 0: pkg.versionTable

