#import "../src/lib.typ": *
#import "../examples/publications.typ" as recipe

#assert(recipe.is-presenter((family: "Morgan", given: "Alex")))
#assert(recipe.is-presenter((family: "Morgan", given: "A.")))
#assert(not recipe.is-presenter((family: "Morgan", given: "Robin")))
#assert(not recipe.is-presenter((family: "Morgan")))
#assert(not recipe.is-presenter((family: "Morgan", given: "Alexander")))

#show: ambrosia-theme.with(flavor: "minimal", palette: sys.inputs.at("palette", default: "ocean"))
#slide(title: [Selected Publications])[
  #set text(size: 0.85em)
  #recipe.pergamon.refsection(style: recipe.publication-style)[
    #recipe.pergamon.add-bib-resource(recipe.publications, local: true)
    #recipe.pergamon.print-bibliography(title: none, show-all: true,
      sorting: "ydnt", filter: recipe.is-own-work)
  ]
  #pause
  List revealed without changing native reference routing.
]
#slide(title: [Native References Still Work])[
  A normal citation #footcite(<knuth84>).
  #hidden-bibliography("../examples/bibliography.bib")
]
