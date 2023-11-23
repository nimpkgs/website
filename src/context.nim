import std/[
  asyncjs, jsconsole, jsfetch, sugar, tables
]

import karax/[kbase, karax]
import jsony

import packages, utils

export tables

type
  Context* = object
    nimpkgs*: NimPkgs
    loaded*: bool

let nimpkgsUrl =
  when defined(debug): "http://localhost:8080/nimpkgs.json"
  else: "https://raw.githubusercontent.com/nimpkgs/nimpkgs/main/nimpkgs.json"


proc fetchPackages*(ctx: var Context){.async.} =
  await fetch(nimpkgsUrl.jss)
    .then((r: Response) => r.text())
    .then(proc(txt: kstring) =
      ctx.nimpkgs = fromJson($txt, NimPkgs)
      ctx.loaded = true
      redraw()
    )
    .catch((err: Error) => console.log err
  )
var ctx* = Context()
discard ctx.fetchPackages
