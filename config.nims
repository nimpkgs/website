import std/[strutils, strformat]

--backend:js

proc getCommitInfo*(): (string, string) =
  if not dirExists "src/packages":
    echo "cloning nim-lang/packages"
    discard staticExec "git clone https://github.com/nim-lang/packages.git src/packages"
  let output = (staticExec "git -C src/packages show -q --format='%h %H'").split()
  return (output[0], output[1])

task setup, "run atlas init":
  exec "atlas init --deps=.workspace"
  exec "atlas install"

task build, "build":
  let (short,long) = getCommitInfo()
  selfExec fmt"js -o:site/nimpkgs.js -d:packagesHash:{long} -d:packagesHashAbbr:{short} -d:release src/nimpkgs.nim"
  exec "pnpm run build"

task watch, "rebuild on change":
  exec "watchexec -w src nim js -d:packagesHash:master -o:site/nimpkgs.js src/nimpkgs.nim"
