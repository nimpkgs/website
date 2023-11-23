import std/[algorithm, strutils, sequtils, jsconsole, uri, random]

import karax/[kbase, karax, karaxdsl, vdom, jstrutils, ]

import ../[packages, style, context]
import ../components/tag
import ../utils

randomize()
proc authorRepo(uri: Uri, hostname = false): kstring =
  var name =
    if hostname: uri.hostname & uri.path.replace(".git")
    else: uri.path[1..^1].replace(".git")
  if name[^1] == '/':
    name = name[0..^2]
  return name.jss

proc projectUrl*(pkg: NimPackage): VNode =
  let uri = parseUri($pkg.url)
  let icon =
    case uri.hostname:
      of "github.com": "i-mdi-github"
      of "gitlab.com": "i-mdi-gitlab"
      of "git.sr.ht": "i-simple-icons-sourcehut"
      of "codeberg.org": "i-simple-icons-codeberg"
      of "bitbucket.org": "i-simple-icons-bitbucket"
      else: "i-mdi-git"
  let repoName = uri.authorRepo(hostname = (icon == "i-mdi-git"))

  buildHtml:
    tdiv(class = "flex items-center space-x-2"):
      tdiv(class = icon.jss)
      a(href = pkg.url, class = if pkg.deleted: "line-through text-ctp-red" else: ""):
        text repoName.jss


proc card*(pkg: NimPackage): VNode =
  result = buildHtml(tdiv(class = "flex flex-col bg-ctp-crust rounded-xl my-5 p-5")):
    tdiv(class = "flex flex-col md:flex-row md:justify-between"):
      a(href = "/#/pkg/" & pkg.name):
        h2(class = (textStyle & "font-black md:text-2xl text-lg font-casual").kstring):
          text pkg.name
      if not pkg.isAlias:
        pkg.projectUrl
    if pkg.isAlias:
      tdiv:
        text "alias for: "
        span(onClick = setSearchUrl("name:" & pkg.alias),
            class = "link"):
          text pkg.alias
    else:
      span(class = "md:text-xl my-2"): text pkg.description
      tdiv(class = "flex flex-col text-xs md:text-lg overflow-x-scroll"):
        tdiv(class = "flex flex-wrap"):
          for t in pkg.tags:
            tdiv(
              onClick = setSearchUrl("tag:" & t.replace(" ", "-")),
                class = "link"):
              t.renderTag

proc getRecentReleases(ctx: Context): seq[NimPackage] =
  var pkgs: seq[NimPackage]
  for pkg in ctx.nimpkgs.packages.values():
    if pkg.versions.len > 0:
      pkgs.add pkg

  pkgs.sort(sortVersion, order = Descending)
  return pkgs[0..20]

proc recentPackageVersionList*(ctx: Context): VNode =
  let pkgs = ctx.getRecentReleases
  result = buildHtml(tdiv(class = "flex flex-wrap")):
    for pkg in pkgs:
      a(class = borderStyle & "p-2 m-1 space-x-1 no-underline text-ctp-text",
          href = "/#/pkg/" & pkg.name):
        span(class = textStyle & "font-bold font-mono-casual"): text pkg.name
        span(class = "italic"): text pkg.versions[0].tag
        span:
          text " (" & (getTime() - pkg.versions[0].time).inDays.jss & " days ago)"

proc randomPackage*(ctx: Context): VNode =
  let pkgName = ctx.nimpkgs.packages.keys().toSeq().sample()
  console.log pkgName.jss
  result = buildHtml(tdiv(class = borderStyle & "my-2 m-1 p-2")):
    a(href = "/#/pkg/" & pkgName.jss, class = "flex items-center text-ctp-text no-underline"):
      tdiv(class = "i-mdi-dice-6")
      span(class = "font-ctp-text"): text "random"
