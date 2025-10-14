import std/[
  asyncjs, jsconsole, jsfetch, sequtils, sugar, tables
]
import karax/[kbase, karax], jsony
import packages, lib

export tables

type
  Context* = ref object
    nimpkgs*: NimPkgs
    loaded*: bool

var ctx* = Context()

let nimpkgsUrl =
  when defined(debug): "http://localhost:8080/nimpkgs.json"
  else: "https://nimpkgs.github.io/nimpkgs/nimpkgs.json"

proc fetchPackages*(ctx: Context){.async.} =
  await fetch(nimpkgsUrl.jss)
    .then((r: Response) => r.text())
    .then(proc(txt: kstring) =
      ctx.nimpkgs = fromJson($txt, NimPkgs)
      ctx.loaded = true
      redraw()
    )
    .catch((err: Error) => console.log err
  )

discard ctx.fetchPackages

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


