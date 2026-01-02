import std/[
  asyncjs, jsconsole, jsfetch, sequtils, sugar, tables, strutils
]
import karax/[kbase, karax], jsony
import packages, lib

export tables

type
  Context* = ref object
    nimpkgs*: NimPkgs
    nimpkgsLoaded*: bool
    packageLoaded*: bool
    package*: NimPackage

func loaded*(c: Context): bool =
  c.nimpkgsLoaded and c.packageLoaded

var ctx* = Context()

let nimpkgsUrl =
  when defined(debug): "http://localhost:8555/nimpkgs.json"
  else: "https://nimpkgs.github.io/nimpkgs/nimpkgs.json"

proc fetchPackages*(ctx: Context) {.async.} =
  if ctx.nimpkgsLoaded: return
  await fetch(nimpkgsUrl.jss)
    .then((r: Response) => r.text())
    .then(proc(txt: kstring) =
      ctx.nimpkgs = fromJson($txt, NimPkgs)
      ctx.nimpkgsLoaded = true
      redraw()
    )
    .catch((err: Error) => console.log err
  )

proc setPackage*(ctx: Context, packageName: string) {.async.} =
  echo "getting the 'package info for", packageName
  let uri = "http://localhost:8555/packages/" & packageName & ".json"
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
    if ctx.package.name != packageName:
      ctx.packageLoaded = false
      await ctx.setPackage(packageName)

proc nimpkgsList*(): seq[NimPackage] {.inline.} =
  ctx.nimpkgs.packages.values.toSeq()

proc recentPackagesList*(): seq[NimPackage] {.inline.} =
  ctx.nimpkgs.recent.mapIt(ctx.nimpkgs.packages[$it])

proc getRecentReleases*(): seq[NimPackage] =
  var pkgs: seq[NimPackage]
  for pkg in ctx.nimpkgs.packages.values():
    if pkg.versions.len > 0:
      pkgs.add pkg

  pkgs.sort(sortVersion, order = Descending)
  return pkgs[0..10]


