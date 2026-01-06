import std/[
  asyncjs, jsconsole, jsfetch, sequtils, sugar, tables, strutils
]
import karax/[kbase, karax], jsony
import packages, lib

export tables

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
    when defined(debug): "http://localhost:8188/"
    else: "https://nimpkgs.github.io/nimpkgs/"
  nimpkgsUrl = baseUrl & "nimpkgs.json"
  packagesUrl = baseUrl & "packages/"

proc fetchPackages*(ctx: Context) {.async.} =
  if ctx.nimpkgsLoaded: return
  await fetch(nimpkgsUrl.jss)
    .then((r: Response) => r.text())
    .then(proc(txt: kstring) =
      ctx.nimpkgs = fromJson($txt, NimPkgs) # Using hooks otherwise this should probably be JSON.parse
      # ctx.names = ctx.nimpkgs.packages.values().mapIt(it.name)
      ctx.names = ctx.nimpkgs.packages.mapIt(it.name)
      ctx.nimpkgsLoaded = true
      redraw()
    )
    .catch((err: Error) => console.log err
  )

proc setPackage*(ctx: Context, packageName: string) {.async.} =
  let uri = packagesUrl & packageName & ".json"
  await fetch(uri.cstring)
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
  ctx.nimpkgs.recent

proc getRecentReleases*(): seq[NimPackage] =
  var pkgs: seq[NimPackage]
  for pkg in ctx.nimpkgs.packages:
    if pkg.meta.versions.len > 0:
      pkgs.add pkg

  pkgs.sort(sortVersion, order = Descending)
  return pkgs[0..min(10, pkgs.len-1)]


