import std/[algorithm, strutils]

import karax/kbase

import jsony

type
  Package* = object
    name*, url*, `method`*, description*, license*, web*, doc*, alias*: kstring
    tags*: seq[kstring]

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

const
  packagesHash* {.strdefine.} = "master"
  packagesHashAbbr* {.strdefine.} = "master"
  allPackages* = getPackages()

