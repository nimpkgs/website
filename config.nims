switch("backend","js")

task setup, "run atlas init":
  exec "atlas init --deps=.workspace"
  exec "atlas install"

task build, "build":
  selfExec "js -o:site/app.js -d:release src/app.nim"
  exec "pnpm run build"

task watch, "rebuild on change":
  exec (
        "watchexec " &
        "--project-origin . -w src " &
        "nim js -d:packagesHash:master -o:site/app.js src/app.nim"
      )

