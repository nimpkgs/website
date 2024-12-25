import std/random
import karax/[kbase, jstrutils]

randomize()

const colors = [
    "flamingo",
    "pink",
    "mauve",
    "red",
    "maroon",
    "peach",
    "yellow",
    "green",
    "teal",
    "sky",
    "sapphire",
    "blue",
    "lavender"
  ]
let
  accent* = (colors.sample() & " ").kstring
  textStyle* = (" text-ctp-" & accent & " ").kstring
  headerStyle* = (textStyle & "text-3xl md:text-6xl font-bold font-mono-casual my-2").kstring
  borderStyle* = (" border rounded b-ctp-" & accent & " ").kstring

