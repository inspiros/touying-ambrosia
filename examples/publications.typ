#import "../src/lib.typ": *
// This optional example alone imports Pergamon; ordinary Ambrosia decks do not.
// Keep its namespace explicit: native cite, footcite and bibliography stay available.
#import "@preview/pergamon:0.8.0" as pergamon

#show: ambrosia-theme.with(flavor: "minimal", palette: "ocean",
  config-info(title: [Selected Publications], author: [Alex Morgan]))

// Explicit aliases avoid guessing identities from a surname or initials.
// Add the spellings actually present in your BibTeX data. Names are compared
// as parsed family/given fields, before any display formatting takes place.
#let presenter-names = (
  (family: "Morgan", given: "Alex"),
  (family: "Morgan", given: "A."),
)
#let is-presenter(name) = presenter-names.any(person =>
  person.pairs().all(((part, value)) => name.at(part, default: "") == value))
#let is-own-work(reference) = {
  let authors = reference.fields.at("parsed-author", default: none)
  authors != none and authors.any(is-presenter)
}

// This hook receives only author records, never titles or venue names.
// Decorate the rendered name while leaving Pergamon in charge of punctuation,
// name order and formatting. Keep all names visible on these short slide lists.
#let highlight-name(body) = text(weight: "bold", body)
#let author-field(default, names, reference, field, options, style) = {
  let rendered = names.map(name => {
    let body = pergamon.format-name(name, name-type: "author", format: options.name-format)
    if is-presenter(name) { highlight-name(body) } else { body }
  })
  pergamon.concatenate-names(rendered, options: options,
    minnames: options.minnames, maxnames: options.maxnames)
}
#let publication-style = pergamon.numeric-style(reference: (
  name-format: "{given} {family}", minnames: 1, maxnames: 99,
  eval-mode: none, // Bibliographic text is displayed literally.
  format-fields: ("parsed-author": author-field),
))
// Read at the call site so relative paths work in both IDE previews and CLI builds.
#let publications = read("publications.bib")

#slide(title: [Selected Publications])[
  #set text(size: 0.85em)
  #pergamon.refsection(style: publication-style)[
    #pergamon.add-bib-resource(publications, local: true)
    #pergamon.print-bibliography(title: none, show-all: true, sorting: "ydnt",
      filter: is-own-work, grid-style: (row-gutter: 0.8em))
  ]
]

// Filter by entry type for journal/conference lists. Here the same local
// resource is intentionally loaded into an independent publication section.
#slide(title: [Journal Publications])[
  #set text(size: 0.85em)
  #pergamon.refsection(style: publication-style)[
    #pergamon.add-bib-resource(publications, local: true)
    #pergamon.print-bibliography(title: none, show-all: true, sorting: "ydnt",
      filter: reference => is-own-work(reference) and reference.entry_type == "article",
      grid-style: (row-gutter: 0.8em))
  ]
]
