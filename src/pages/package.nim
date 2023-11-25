import std/[algorithm, sugar]
import karax/[karaxdsl, vdom, jstrutils]

import ../[context, packages, style]
import ../components/[tag, package]
import ../utils
import notfound

proc versionTable(pkg: NimPackage): VNode =
  var versions = pkg.versions
  versions.sort((a, b: Version) => cmp(a.time, b.time), order = Descending)

  buildHtml(tdiv(class = "my-5 p-10 bg-ctp-crust rounded")):
    table(class = "table-auto w-full text-center"):
      tr:
        th: text "version"
        th: text "release"
        th: text "hash"
      for version in versions:
        tr:
          td: text version.tag
          td: text version.time.format("yyyy-MM-dd")
          td: text ($version.hash)[0..8]

proc renderAlias(pkg: NimPackage): VNode = buildHtml:
  tdiv:
    text pkg.name & "is alias for "
    a(href = "#/pkg/" & pkg.alias):
      text pkg.alias

proc renderLinks(pkg: NimPackage): VNode = buildHtml(tdiv):
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


proc renderPkgInfo(pkg: NimPackage): VNode =
  buildHtml:
    tdiv(class = "space-y-5 text-2xl"):
      tdiv(class = "md:text-4xl text-xl"):
        text pkg.description
      pkg.renderLinks
      tdiv:
        tdiv: text "license:"
        text pkg.license.jss
      tdiv:
        tdiv: text "tags:"
        pkg.tags.renderTags
      tdiv:
        tdiv: text "usage:"
        tdiv(class = "bg-ctp-surfacezero rounded my-2 mx-3 p-2 w-auto"):
          pre:
            text "nimble install " & pkg.name
          pre:
            text "atlas use " & pkg.name

proc render*(packageName: string): VNode =
  if packageName notin ctx.nimpkgs.packages: return notfound.render()
  let pkg = ctx.nimpkgs.packages[packageName]
  result = buildHtml(tdiv(class = "flex flex-col")):
    if pkg.deleted:
      tdiv(class = "md:text-5xl text-2xl text-ctp-red my-5 "):
        tdiv(class = "flex items-center md:text-5xl text-2xl font-mono-casual font-black"):
          tdiv(class = "i-mdi-alert inline-block")
          span: text "WARNING!"
        text "The provided url for this package is unreachable, it may have been deleted."
    tdiv(class = "bg-ctp-mantle rounded p-5"):
      h2(class = textStyle & "text-3xl md:text-6xl font-bold font-mono-casual my-2"):
        text pkg.name
      if pkg.isAlias: pkg.renderAlias
      else: pkg.renderPkgInfo
    if pkg.versions.len > 0: pkg.versionTable
