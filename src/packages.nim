import std/[
  algorithm, asyncjs,
  strutils, sugar, tables, times, uri
]
import karax/[kbase]
import jsony

import ./utils
export algorithm, tables, times, asyncjs, sugar

proc parseHook*(s: string, i: var int, v: var kstring) =
  var str: string
  parseHook(s, i, str)
  v = cstring(str)

type
  Version* = object
    tag*, hash*: kstring
    time*: Time

  NimPackage* = object
    name*, url*, `method`*, description*,
      license*, web*, doc*, alias*: kstring
    lastCommitHash*: kstring
    lastCommitTime*: Time
    versions*: seq[Version]
    tags*: seq[kstring]
    deleted*: bool

  NimPkgs* = object
    updated*: Time
    packagesHash*: kstring
    packages*: OrderedTable[string, NimPackage]

proc newHook*(p: var NimPackage) =
  p.url = ""
  p.alias = ""
  p.`method` = ""
  p.license = ""
  p.web = ""
  p.doc = ""
  p.description = ""
  p.alias = ""
  p.tags = @[]

proc newHook*(nimpkgs: var NimPkgs) =
  nimpkgs.packagesHash = ""

proc parseHook*(s: string, i: var int, v: var Time) =
  var num: int
  parseHook(s, i, num)
  v = fromUnix(num)

proc sortCommit*(a, b: NimPackage): int =
  cmp(a.lastCommitTime, b.lastCommitTime)

proc sortAlphabetical*(a, b: NimPackage): int =
  cmp(a.name, b.name)

proc sortVersion*(a, b: NimPackage): int =
  let lengths = (a.versions.len, b.versions.len)
  if lengths[0] > 0 and lengths[1] > 0:
    result = cmp(a.versions[0].time, b.versions[0].time)
  elif lengths[0] == 0 and lengths[1] == 0:
    result = sortCommit(a, b)
  elif lengths[0] == 0:
    result = -1
  else:
    result = 1


proc isAlias*(p: NimPackage): bool {.inline.} = p.alias != ""

proc canonicalUrl*(p: NimPackage): kstring =
  var uri = parseUri($p.url)
  uri.path = uri.path.replace(".git")
  # NOTE: why do I use this?
  if uri.path[^1] == '/':
    uri.path = uri.path[0..^2]
  uri.query = ""
  return uri.jss


