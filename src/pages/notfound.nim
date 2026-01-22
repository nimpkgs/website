import karax/[karaxdsl, vdom]
import ../lib

proc render*(): VNode =
  setTitle("404")
  result = buildHtml:
    tdiv(class = "mx-auto text-center"):
      span(class = "text-9xl lg:text-[25rem] font-black my-5"):
        text "404"

