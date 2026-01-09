import std/[
  asyncjs, jsconsole, jsfetch, sequtils, sugar, tables,
  strutils, uri, random, macros ,algorithm, times, options
]
import std/jsffi except `&`
import karax/[kbase, karax, vdom, kdom, jstrutils]
import jsony

export algorithm, tables, times, asyncjs, sugar, options, jsconsole

proc jss*[T](arg: T): kstring = ($arg).kstring
proc jss*(arg: kstring): kstring = arg

proc noProtocol*(s: kstring): kstring =
  ($s)
    .replace("http://", "")
    .replace("https://", "")
    .jss

proc currentUri*(): Uri {.inline.} =
  parseUri($window.location.href)

func replace*(c: kstring, sub: string, by = " "): kstring =
  ($c).replace(sub, by).jss

func toLowerAscii*(ks: kstring): kstring {.inline.} = ($ks).toLowerAscii().kstring

macro kcall*(p: typed) =
  ## make procedure return another procedure that takes no arguments
  ##
  ## used for generating more succint callbacks compatible with karax
  runnableExamples:
    proc example(a: string) {.kcall.} =
      echo a
    example("hello world")()

  expectKind p, nnkProcDef
  if p.params[0].kind != nnkEmpty:
    error "proc must return void"
  var updated = copy(p)
  let returnType = nnkProcTy.newTree(nnkFormalParams.newTree(newEmptyNode()), newEmptyNode())
  updated.params = nnkFormalParams
    .newTree(returnType)
    .add(p.params[1 ..^ 1])
  updated.body = nnkStmtList.newTree(
    nnkLambda.newTree(
      newEmptyNode(),
      newEmptyNode(),
      newEmptyNode(),
      nnkFormalParams.newTree(newEmptyNode()),
      newEmptyNode(),
      newEmptyNode(),
      p.body,
    )
  )
  result = nnkStmtList.newTree()
  result.add updated

proc parseHook*(s: string, i: var int, v: var kstring) =
  var str: string
  parseHook(s, i, str)
  v = cstring(str)

type
  Version* = object
    tag*, hash*: kstring
    time*: Time

  NimPackageStatus* = enum # order matters here since ranges are used
    Unknown,
    OutOfDate,
    UpToDate,
    Alias,
    Unreachable,
    Deleted

  Commit* = object
    hash*: string
    time*: Time # unix timestamp

  NimbleVersion* = object
    kind*: kstring # enum?
    ver*: kstring
  NimbleRequire* = object
    name*: kstring
    str*: kstring
    ver*: NimbleVersion
  NimbleDump* = object
    version*: kstring
    requires*: seq[NimbleRequire]
    bin*: seq[kstring]
    srcDir*: kstring
    # paths*: seq[string] # do I actually need these
    # some combo of install and src is probably necessary to determine if it's a library or an executable/hybrid

  NimPackageMeta = object
    nimble*: Option[NimbleDump]
    broken*: bool
    hasBin*: bool
    versions*: seq[Version] # move to meta?
    commitTime*: Time
    commit*: Commit
    status*: NimPackageStatus

  NimPackage* = object
    name*, url*, `method`*, description*,
      license*, web*, doc*, alias*: kstring
    tags*: seq[kstring]
    meta*: NimPackageMeta

type
  RecentPackages = object
    added*: seq[kstring]
    released*: Table[string, kstring] # key must be string for jsony to parse?

  # TODO: rename Index?
  NimPkgs* = object
    updated*: Time
    recent*: RecentPackages
    packagesHash*: kstring
    packages*: seq[NimPackage]

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
  # p.status = Unknown

proc newHook*(nimpkgs: var NimPkgs) =
  nimpkgs.packagesHash = ""

proc parseHook*(s: string, i: var int, v: var Time) =
  var num: int
  parseHook(s, i, num)
  v = fromUnix(num)

proc sortCommit*(a, b: NimPackage): int =
  cmp(a.meta.commitTime, b.meta.commitTime)

proc sortAlphabetical*(a, b: NimPackage): int =
  cmp(a.name.toLowerAscii(), b.name.toLowerAscii())

proc sortVersion*(a, b: NimPackage): int =
  let lengths = (a.meta.versions.len, b.meta.versions.len)
  if lengths[0] > 0 and lengths[1] > 0:
    result = cmp(a.meta.versions[0].time, b.meta.versions[0].time)
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

type
  SortMethod* = enum
    smVersionAgeRecent = "version"
    smVersionAgeOldest = "version-old"
    smCommitAgeRecent = "commit",
    smCommitAgeOldest = "commit-old"
    smAlphabetical = "AtoZ",
    smAlphabeticalReverse = "ZtoA"

const
  SortMethodDisplay*: array[SortMethod, string] = [
    smVersionAgeRecent: "version (recent)",
    smVersionAgeOldest: "version (oldest)",
    smCommitAgeRecent: "commit (recent)",
    smCommitAgeOldest: "commit (oldest)",
    smAlphabetical: "A to Z",
    smAlphabeticalReverse: "Z to A"
  ]


proc scrollToTop*() =
  document.body.scrollTop = 0
  document.documentElement.scrollTop = 0

proc setSearchUrl*(
  searchQuery: kstring,
  sortMethod = smVersionAgeRecent
) {.kcall.} =
  var
    url = currentUri()
    params: seq[(string, string)]
  if searchQuery != "":
    params.add ("query", $searchQuery)
  if sortMethod != smVersionAgeRecent:
    params.add ("sort", $sortMethod)
  url.anchor = "/search"
  url = url ? params
  window.history.pushState(js{}, "".jss, url.jss)
  scrollToTop()
  redraw()

# NOTE: is this not also a "setSearch taking state from the 'dom'"
proc getSearchInput*() =
  let searchInput = getVNodeById("search").getInputText
  let sortNode = getVNodeById("sort-select")
  let sortMethod = SortMethod(
      if sortNode != nil: parseInt($sortNode.getInputText)
      else: 0
    )
  setSearchUrl(searchInput, sortMethod)()


# NOTE this doesn't preserve the filter state yet
proc setSearchInput*(q: kstring) {.kcall.} =
  let sortNode = getVNodeById("sort-select")
  let sortMethod = SortMethod(
      if sortNode != nil: parseInt($sortNode.getInputText)
      else: 0
    )
  setSearchUrl(q, sortMethod)()

type
  Context* = ref object
    nimpkgs*: NimPkgs
    names*: seq[kstring]
    nimpkgsLoaded*: bool
    packageLoaded*: bool
    package*: NimPackage

func loaded*(c: Context): bool =
  c.nimpkgsLoaded and c.packageLoaded

var ctx* = Context()

const
  baseUrl =
    when defined(debug): "http://localhost:8189/"
    else: "https://nimpkgs.github.io/nimpkgs/"
  indexUrl = baseUrl & "nimpkgs.json"
  packagesUrl = baseUrl & "packages/"
  nimpkgsUrl* =
    when defined(debug): "http://localhost:8188"
    else: "https://nimpkgs.dayl.in/"

proc fetchPackages*(ctx: Context) {.async.} =
  if ctx.nimpkgsLoaded: return
  await fetch(indexUrl.jss)
    .then((r: Response) => r.text())
    .then(proc(txt: kstring) =
      ctx.nimpkgs = fromJson($txt, NimPkgs) # Using hooks otherwise this should probably be JSON.parse
      ctx.names = ctx.nimpkgs.packages.mapIt(it.name)
      ctx.nimpkgsLoaded = true
      redraw()
    )
    .catch((err: Error) => console.log err
  )

proc pkgPrefix(name: string): string =
  if name.len < 2:
    # one letter .... what a great name for a package >:(
    return (name & "_").toLowerAscii()
  name[0..1].toLowerAscii()

proc setPackage*(ctx: Context, packageName: string) {.async.} =
  let uri = parseUri(packagesUrl) / pkgPrefix(packageName)  / packageName / "pkg.json"
  await fetch(uri.jss)
    .then((r: Response) => r.text())
    .then(proc(txt: kstring) =
      ctx.package = fromJson($txt, NimPackage)
      ctx.packageLoaded = true
      redraw()
    )
    .catch((err: Error) => console.log err)

proc check*(ctx: Context, data: RouterData) {.async.} =
  await ctx.fetchPackages
  if ($data.hashPart).startsWith("#/pkg/"):
    let packageName = $(data.hashPart).replace("#/pkg/", "")
    if ctx.package.name != packageName.kstring:
      ctx.packageLoaded = false
      await ctx.setPackage(packageName)
  else:
    ctx.packageLoaded = false

proc nimpkgsList*(): seq[NimPackage] {.inline.} =
  ctx.nimpkgs.packages

proc recentPackagesList*(): seq[kstring] {.inline.} =
  ctx.nimpkgs.recent.added

proc getRecentReleases*(): seq[NimPackage] =
  var pkgs: seq[NimPackage]
  for pkg in ctx.nimpkgs.packages:
    if pkg.meta.versions.len > 0:
      pkgs.add pkg

  pkgs.sort(sortVersion, order = Descending)
  return pkgs[0..min(10, pkgs.len-1)]


const colors = [
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

randomize()

let
  accent* = (colors.sample() & " ").kstring
  textStyle* = (" text-ctp-" & accent & " ").kstring
  headerStyle* = (textStyle & "text-3xl md:text-6xl font-bold font-mono-casual my-2").kstring
  borderStyle* = (" border rounded b-ctp-" & accent & " ").kstring
