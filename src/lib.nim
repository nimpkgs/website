import std/[strutils, uri, macros]
import std/jsffi except `&`
import jsconsole
export jsconsole

import karax/[kbase, karax, vdom, kdom]

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


type
  SortMethod* = enum
    smAlphabetical = "smAlphabetical", smCommitAge = "commit", smVersionAge = "version"

proc setSearchUrl*(
  searchQuery: kstring,
  sortMethod = smAlphabetical
) {.kcall.} =
  var
    url = currentUri()
    params: seq[(string, string)]
  if searchQuery != "":
    params.add ("query", $searchQuery)
  if sortMethod != smAlphabetical:
    params.add ("sort", $sortMethod)
  url.anchor = "/search"
  url = url ? params
  window.history.pushState(js{}, "".jss, url.jss)
  let d = getVNodeById("search")
  let node = d.dom
  scrollIntoView(node)
  redraw()

proc getSearchInput*() =
  let searchInput = getVNodeById("search").getInputText
  let sortNode = getVNodeById("sort-select")
  let sortMethod = SortMethod(
      if sortNode != nil: parseInt($sortNode.getInputText)
      else: 0
    )
  setSearchUrl(searchInput, sortMethod)()

proc setSearchInput*(q: kstring) {.kcall.} =
  let sortNode = getVNodeById("sort-select")
  let sortMethod = SortMethod(
      if sortNode != nil: parseInt($sortNode.getInputText)
      else: 0
    )
  setSearchUrl(q, sortMethod)()



