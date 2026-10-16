#import "../src/lib.typ": *
#let title-renderer(self: none, ..args) = extensions.render-title-slide(self: self,
  ..(args.named() + (subtitle: [CUSTOMTITLE #metadata((kind: "title", flavor: self.store.flavor))<ambrosia-extension-test>])),
  ..args.pos())
#let ending-renderer(self: none, config: (:), title: none, body) = extensions.render-ending-slide(
  self: self, config: config, title: [CUSTOMENDING],
  body + [#metadata((kind: "ending", flavor: self.store.flavor))<ambrosia-extension-test>])
#let custom = ambrosia-flavor(name: "independent",
  title-renderer: title-renderer, ending-renderer: ending-renderer,
  header-renderer: self => [CUSTOMHEADER],
  footer-renderer: self => [CUSTOMFOOTER],
)
#let quiet = sys.inputs.at("quiet", default: "false") == "true"
#let custom = if quiet { ambrosia-flavor(base: custom, name: "quiet", header-renderer: none, footer-renderer: none) } else { custom }
#let custom = if sys.inputs.at("empty", default: "false") == "true" {
  ambrosia-flavor(base: custom, name: "empty", title-renderer: none, ending-renderer: none, header-renderer: none, footer-renderer: none)
} else { custom }
#show: ambrosia-theme.with(flavor: custom, config-info(title: [Custom institution], author: [Researcher]))
#title-slide()
#slide(title: [Content])[POSITIONAL BODY #pause REVEALED BODY]
#ending-slide(title: [Ignored title])[ENDING BODY]
