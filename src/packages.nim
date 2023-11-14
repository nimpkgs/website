import std/[algorithm, strutils, tables]
import karax/kbase

import jsony

type
  Package* = object
    name*, url*, `method`*, description*, license*, web*, doc*, alias*: kstring
    tags*: seq[kstring]
  Tag* = object
    name*: kstring
    packages*: int

proc parseHook*(s: string, i: var int, v: var kstring) =
  var str: string
  parseHook(s, i, str)
  v = cstring(str)

proc cmpPkgs(a, b: Package): int =
  cmp(toLowerAscii($a.name), toLowerAscii($b.name))

proc getPackages(): seq[Package] =
  const packagesJsonStr = slurp "./packages/packages.json"
  result = packagesJsonStr.fromJson(seq[Package])
  result.sort(cmpPkgs)


#[
import strutils, tables, heapqueue, algorithm
iterator topN[T](h: CountTable[T]|Table[T, int], n=10):
    tuple[cnt: int; key: T] =
  var q = initHeapQueue[tuple[cnt: int; key: T]]()
  for key, cnt in h:
    if q.len < n:
      q.push((cnt, key))
    elif cnt > q[0].cnt:  # retain 1st seen on tied cnt
      discard q.replace((cnt, key))
  while q.len > 0:        # q now has top n entries
    yield q.pop
]#

proc getTags(pkgs: seq[Package]): seq[Tag] =
  const minPackageCutoff = 10
  var tags: seq[kstring]
  for pkg in pkgs:
    for tag in pkg.tags:
      tags.add tag
  for key, cnt in tags.toCountTable:
    if cnt > minPackageCutoff:
      result.add Tag(name: key, packages: cnt)

const
  packagesHash* {.strdefine.} = "master"
  packagesHashAbbr* {.strdefine.} = "master"
  allPackages* = getPackages()
  allTags* = allPackages.getTags()
