# Your First Presentation

Ambrosia builds on [Touying](https://touying-typ.github.io/) and Typst's ordinary
markup. You need **Typst 0.15+**; the package imports **Touying 0.8.0** itself.

## Start In Your Editor

Use [the template on Typst Universe](https://typst.app/universe/package/touying-ambrosia)
in the browser, or initialize a project with the CLI:

```sh
typst init @preview/touying-ambrosia:0.1.0 my-slides
```

Open `template.typ` in your editor and start its preview. The starter includes
Ambrosia's project logo and a bibliography. Edit its metadata and the `flavor`
and `palette` values near the top. No command-line options are needed to try a
different design.

To start without branding, create a new Typst file with this complete example:

<!-- ambrosia-example: first-deck -->
[Editable source](site/examples/first-deck.typ).
<!-- /ambrosia-example -->

The source and output panels show the same example. Copy buttons copy plain Typst
source. The full source download includes any setup omitted from a short snippet.
Previews are compiled during documentation builds; this website does not execute
your code. Paste it into your own Typst project to experiment.

## Add Content And Reveals

Level-one headings (`=`) begin sections. Most flavors use level-two headings
(`==`) for slides; Cambridge uses level three (`===`). `#slide(...)` works in
every flavor and is useful when you want explicit control.

<!-- ambrosia-example: reveals -->
[Editable source](site/examples/reveals.typ).
<!-- /ambrosia-example -->

Each `#pause` adds an animation frame. The output above shows the final frame.
Two positional slide bodies make two columns; native `grid`, `figure`, and
`table` also work inside a slide.

## Close The Talk And Keep Backup Material

```typst
#ending-slide(title: [Questions?])[]

#show: appendix
== Supporting Evidence
Additional detail, without increasing the main slide total.
```

Appendix numbering defaults to Roman numerals. [People and footer settings](people.md)
describe other numbering policies and short labels for dense footers.

Continue with [configuration](configuration.md), compare the [flavors](flavors.md)
and [palettes](palettes.md), or browse the [public API](api.md). The concise
[PDF manual](manual.pdf) remains available for offline reading.
