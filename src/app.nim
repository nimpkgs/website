import std/strutils
import karax/[karax, karaxdsl, vdom]
import components/[header, button, footer]
import pages/pages
import context, lib

proc loader(): VNode =
  buildHtml(tdiv(class = "flex h-50")):
    tdiv(class = "mx-auto my-auto lds-dual-ring")

proc render(data: RouterData): VNode =
  when defined(debug): console.log ctx
  discard check(ctx, data)
  var uri = currentUri()
  result = buildHtml(tdiv(
      class = "lg:w-3/4 max-w-[90%] mx-auto md:text-lg text-sm min-h-screen flex flex-col"
      )
    ):
    headerBar()
    tdiv(class = "mb-5"):
      if uri.path != "/" and not uri.path.startsWith("#"):
        notfound.render()
      elif not ctx.nimpkgsLoaded:
        loader()
      else:
        case data.hashPart
          of "#/index", "": index.render()
          of "#/search": search.render()
          of "#/metrics": metrics.render()
          of "#/about": about.render()
          else:
            if ($data.hashPart).startswith("#/pkg/"):
              package.render(($data.hashPart).replace("#/pkg/", ""))
            else:
              notfound.render()
    footerBar()
    scrollToTopButton()

setRenderer render
