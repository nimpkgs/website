import std/strutils
import karax/[karax, karaxdsl, vdom]
import components/[header, button, footer, loading]
import pages/pages
import context, lib

proc getPackageName(data: RouterData): string =
  if ($data.hashPart).startswith("#/pkg/"):
    result = ($data.hashPart).replace("#/pkg/", "")

proc render(data: RouterData): VNode =
  when defined(debug): console.log ctx
  discard check(ctx, data)
  var uri = currentUri()
  buildHtml(tdiv(
      class = "lg:w-3/4 max-w-[90%] mx-auto md:text-lg text-sm min-h-screen flex flex-col"
      )
    ):
    headerBar()
    tdiv(class = "mb-5"):
      if uri.path != "/" and not uri.path.startsWith("#"):
        notfound.render()
      elif not ctx.nimpkgsLoaded:
        loading("getting nimpkgs data")
      else:
        # TODO: simplify router logic
        case data.hashPart
          of "#/index", "": index.render()
          of "#/search": search.render()
          of "#/metrics": metrics.render()
          of "#/about": about.render()
          else:
            # either it routes to an existing package or the route is wrong
            let pkgName = getPackageName(data)
            if pkgName == "" or pkgName notin ctx.nimpkgs.packages:
              notfound.render()
            else:
              package.render() # do I need to pass in package?
    footerBar()
    scrollToTopButton()

setRenderer render
