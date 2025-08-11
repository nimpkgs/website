import std/[algorithm, sequtils, tables, uri, strutils, times]
import karax/[kbase, karaxdsl, vdom, jstrutils]

import ../[context, packages, style, lib]

type
  Metrics = object
    total: int
    isDeleted: int
    isUnreachable: int
    isAlias: int
    isVersioned: int
    commitMonth: int
    commitYear: int
    tags, domains, authors, license, : seq[(string, int)]


proc sortCounts(x, y: (string, int)): int =
  cmp(x[1], y[1])

proc calculateMetics(ctx: Context): Metrics =
  let currentTime = getTime()
  var
    tags: CountTable[string]
    domains: CountTable[string]
    authors: CountTable[string]
    license: CountTable[string]

  result.total = ctx.nimpkgs.packages.len
  for pkg in ctx.nimpkgs.packages.values():
    let timeSinceLastCommit = (currentTime - pkg.commit.time)

    case pkg.status
    of Deleted: inc result.isDeleted
    of Unreachable: inc result.isUnreachable
    else: discard
    if pkg.versions.len > 0: inc result.isVersioned
    if pkg.isAlias: inc result.isAlias
    if pkg.license != "": license.inc $pkg.license
    if timeSinceLastCommit < initDuration(weeks = 52):
      inc result.commitYear
      if timeSinceLastCommit < initDuration(days = 30):
        inc result.commitMonth
    if pkg.url != "":
      let u = parseUri($pkg.url)
      domains.inc u.hostname
      authors.inc u.path.split("/")[1]
    if pkg.tags.len > 0:
      for tag in pkg.tags:
        tags.inc $tag

  result.tags = tags.pairs.toSeq()
  result.domains = domains.pairs.toSeq()
  result.authors = authors.pairs.toSeq()
  result.license = license.pairs.toSeq()
  result.tags.sort(sortCounts, order = Descending)
  result.domains.sort(sortCounts, order = Descending)
  result.authors.sort(sortCounts, order = Descending)
  result.license.sort(sortCounts, order = Descending)


proc totalsTable(metrics: Metrics): VNode =
  let cellClass = "border md:px-10 px-5" & borderStyle
  buildHtml(tdiv(class = "my-10")):
    tdiv:
      h2(class = "text-2xl"): text "totals"
    table(class = "bg-ctp-mantle"):
      tr:
        th(class = cellClass): text "category"
        th(class = cellClass): text "number"
      for (msg, metric) in [
        ("total", metrics.total),
        ("authors/orgs", metrics.authors.len),
        ("deleted", metrics.isDeleted),
        ("unreachable", metrics.isUnreachable),
        ("alias", metrics.isAlias),
        ("versioned", metrics.isVersioned),
        ("last commit (< 1 year)", metrics.commitYear),
        ("last commit (< 30 days)", metrics.commitMonth),
        ]:
        tr:
          td(class = cellClass): text msg
          td(class = cellClass): text metric.jss


proc blockCountList(itemList: seq[(string, int)], title: string): VNode =
  buildHtml(tdiv(class = "border-t-1 border-dashed my-5 py-5")):
    h2(class = "text-2xl"): text title.jss
    for (item, cnt) in itemList:
      tdiv(class = "inline-block p-2 m-1 border rounded space-x-2" & borderStyle):
        span: text item.kstring & ":"
        span: text kstring($cnt)


proc render*(): VNode =
  let metrics = ctx.calculateMetics()
  result = buildHtml(tdiv):
    h2(class = "text-4xl"):
      text "metrics"
    tdiv(class = "my-1"):
      text "a small collection of metrics from the current nim-lang/packages"
    metrics.totalsTable
    blockCountList(metrics.tags[0..20], title = "tags (top 20)")
    blockCountList(metrics.authors[0..20], title = "authors (top 20)")
    blockCountList(metrics.license[0..20], title = "licenses (top 20)")
    blockCountList(metrics.domains, title = "domains")
