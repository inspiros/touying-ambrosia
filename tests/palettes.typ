#import "../src/lib.typ": *
#let seed = rgb("2b6b51")
#let custom = ambrosia.palette(base: sys.inputs.at("palette", default: "light"), name: "Fieldwork", primary: seed, rotate: 35deg)
#show: ambrosia-theme.with(palette: custom)
#slide(title: [The current palette])[#ambrosia-palette-showcase()]
#slide(title: [Local colors], config: config-colors(primary: rgb("793767")))[
  #ambrosia.palette-showcase(roles: ("primary", "surface", "foreground"), columns: 3, title: [Slide override])
  #ambrosia-block(style: "poster", title: [A nested showcase])[
    #ambrosia-palette-showcase(roles: ("info", "success", "warning", "danger"), codes: false)
  ]
]
