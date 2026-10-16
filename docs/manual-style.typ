// Tidy is a documentation dependency only. No presentation show rule runs here.
#import "@preview/tidy:0.4.3" as tidy
#import "../src/lib.typ" as core

#let ink = rgb("203448")
#let accent = rgb("386aa3")
#let muted = rgb("637487")
#let paper = rgb("f2f5f8")
#let border = rgb("d7e0e9")
#let repo = "https://github.com/inspiros/touying-ambrosia"

#let release = "v" + toml("../typst.toml").package.version
#let guide(path, title) = link(repo + "/blob/" + release + "/" + path, title)

#let code-panel(body, ..args) = block(width: 100%, fill: paper,
  radius: 0.35em, inset: 0.8em, breakable: false, ..args, body)

#let source(body) = code-panel({
  set text(size: 0.95em)
  if type(body) == str { raw(body, lang: "typst", block: true) } else { body }
})

#let note(body) = block(width: 100%, inset: (left: 0.8em, rest: 0.6em),
  fill: paper, stroke: (left: 0.18em + accent), body)

#let snapshot(name, width: 100%) = block(width: width,
  stroke: 0.04em + border, radius: 0.2em, clip: true,
  image("previews/" + name + ".png", width: 100%))

#let pair(code, name) = block(breakable: false, grid(
  columns: (1.1fr, 1fr), gutter: 0.9em, align: horizon,
  source(code), snapshot(name)))

#let choices(rows, widths: (1.1fr, 2.4fr)) = {
  set text(size: 0.92em)
  table(columns: widths, inset: (x: 0.55em, y: 0.42em),
    stroke: (rest: none, bottom: 0.035em + border),
    ..rows.flatten())
}

// One live example: no Touying page rules or presentation counters are involved.
#let live(code) = tidy.show-example.show-example(code,
  scope: dictionary(core),
  layout: tidy.show-example.default-layout-example.with(
    scale-preview: 100%, ratio: 1.2, col-spacing: 0.8em,
    code-block: block.with(fill: paper, radius: 0.3em),
    preview-block: block.with(stroke: 0.04em + border, radius: 0.3em),
  ))

// Small type labels and compact rows replace Tidy's verbose stock reference.
#let show-type(name, style-args: (:)) = text(size: 0.8em, fill: muted, name)
#let show-outline(..args) = none
#let show-parameter-list(..args) = none
#let show-parameter-block(..args) = none
#let show-reference(target, name, style-args: (:)) = link(target, raw(name))
#let show-example(..args) = tidy.styles.default.show-example(..args)
#let show-variable(..args) = none
#let show-function(fn, options) = {
  block(above: 0.8em, below: 0.6em, sticky: true)[
    #text(weight: "semibold", fill: accent, raw(fn.name + "(…)"))
    #h(0.4em)#text(size: 0.85em, fill: muted)[→ #fn.return-types.join(" | ")]
    #label(options.label-prefix + fn.name + "()")
    #parbreak()
    #tidy.utilities.eval-docstring(fn.description, options)
  ]
  set text(size: 0.87em)
  table(columns: (1.5fr, 1fr, 3fr),
    fill: (x, y) => if y == 0 { paper },
    inset: (x: 0.5em, y: 0.42em),
    stroke: (rest: none, bottom: 0.035em + border),
    table.header([*Parameter / Type*], [*Default*], [*Meaning*]),
    ..fn.args.pairs().map(((name, info)) => {
      assert(info.at("types", default: ()).len() > 0,
        message: "Document the types for " + fn.name + "." + name)
      (
        [#raw(name)#label(options.label-prefix + fn.name + "." + name.trim("."))
          #linebreak()#show-type(info.types.join(" | "))],
        if "default" in info { raw(info.default, lang: "typc") }
        else { text(fill: muted, if name.starts-with("..") { [named / extra] } else { [positional] }) },
        tidy.utilities.eval-docstring(info.at("description", default: ""), options),
      )
    }).flatten(),
  )
}

#let api(path, name) = {
  let module-doc = tidy.parse-module(read("../src/" + path),
    label-prefix: "api-", scope: dictionary(core))
  module-doc.functions = module-doc.functions.filter(it => it.name == name)
  module-doc.variables = ()
  assert(module-doc.functions.len() == 1, message: "Missing public reference: " + name)
  assert(module-doc.functions.first().return-types != none, message: "Document return types for " + name)
  tidy.show-module(module-doc,
    style: (show-outline: show-outline, show-type: show-type,
      show-parameter-list: show-parameter-list, show-parameter-block: show-parameter-block,
      show-function: show-function, show-variable: show-variable,
      show-reference: show-reference, show-example: show-example),
    show-module-name: false, show-outline: false, sort-functions: none,
    enable-tests: false)
}

#let manual(body) = {
  set document(title: "Touying Ambrosia — A Short Manual",
    author: "Hoang-Nhat Tran", description: "A concise guide to Touying Ambrosia 0.1.0")
  set page(paper: "a4", margin: (x: 21mm, top: 19mm, bottom: 18mm),
    header: context if counter(page).get().first() > 1 {
      set text(size: 0.75em, fill: muted)
      [TOUYING AMBROSIA #h(1fr) A SHORT MANUAL]
    },
    footer: context {
      set text(size: 0.75em, fill: muted)
      [0.1.0 · Typst 0.15+ · Touying 0.8.0 #h(1fr) #counter(page).display("1")]
    })
  set text(font: "Inter", size: 10.5pt, fill: ink, lang: "en")
  set par(leading: 0.58em, spacing: 0.7em, justify: false)
  set heading(numbering: none)
  show raw: set text(font: "DejaVu Sans Mono", size: 0.86em)
  set list(indent: 1em, body-indent: 0.5em, spacing: 0.25em)
  show link: set text(fill: accent)
  show heading.where(level: 1): it => block(above: 0em, below: 0.9em, sticky: true)[
    #text(size: 1.8em, weight: "bold", fill: accent, it.body)
  ]
  show heading.where(level: 2): set text(size: 1.1em, weight: "bold")
  body
}
