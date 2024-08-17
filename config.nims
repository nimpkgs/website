switch("backend","js")

task build, "build":
  selfExec "js -o:site/app.js -d:release src/app.nim"
  exec "pnpm run build"

task watch, "rebuild on change":
  exec (
        "watchexec " &
        "--project-origin . -w src " &
        "nim js -d:packagesHash:master -o:site/app.js src/app.nim"
      )

# begin Nimble config (version 2)
--noNimblePath
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
