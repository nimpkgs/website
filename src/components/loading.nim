import karax/[kbase, karaxdsl, vdom]

proc loading*(msg: kstring = ""): VNode =
  buildHtml(tdiv(class = "flex h-50")):
    tdiv(class = "mx-auto my-auto flex flex-col"):
      tdiv(class = "mx-auto lds-dual-ring")
      if msg != "":
        tdiv():
          text msg

