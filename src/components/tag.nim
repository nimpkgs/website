import std/[uri, tables, random]
import karax/[kbase, karaxdsl, vdom, jstrutils]

import ../lib

randomize()

proc renderTag*(tag: kstring): VNode =
  buildHtml:
    tdiv(class = "link md:p-2 p-1 m-1" & borderStyle):
      text tag

proc renderTags*(tags: seq[kstring]): VNode =
  buildHtml:
    tdiv(class = "flex flex-wrap"):
      for i, tag in tags:
        let query = encodeQuery({"query": $("tag:" & tag)})
        a(
          href = ("/?" & query & "#/search").jss,
          class = "no-underline"
        ):
          tag.renderTag

proc selectRandomTags*(ctx: Context): seq[kstring] =
  var tagCounts: CountTable[kstring]
  for pkg in ctx.nimpkgs.packages:
    for tag in pkg.tags:
      tagCounts.inc tag

  var tags: seq[kstring]
  for tag, cnt in tagCounts:
    if cnt > 3: tags.add tag

  while result.len < 10:
    let tag = tags.sample()
    if tag notin result:
      result.add tag

proc randomTags*(): VNode =
  let tags = ctx.selectRandomTags()
  buildHtml(tdiv):
    tags.renderTags




