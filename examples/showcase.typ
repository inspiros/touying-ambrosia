#import "@preview/touying-ambrosia:0.1.0" as core

// Fictional branding for examples only. ambrosia-theme itself has no default logos.
#import "../template/logo-data.typ": display-data as _data
#let _logo(name, self, background: auto) = image(bytes(_data(name,
  dark: core.palettes.prefer-light(if background == auto { self.store.at("logo-background", default: self.page.fill) } else { background }))))
#let _header-logo(self) = {
  let flavor = core.extensions.current-flavor(self)
  let background = if flavor.navigation == "tabs" { (flavor.navigation-background)(self) } else { (flavor.header-background)(self) }
  _logo("kyklo-logo", self, background: if background == none { self.page.fill } else { background })
}
#let watermark(fill) = bytes(_data("kyklo-mark").replace(regex("#[A-Fa-f0-9]{6}\\b"), _ => fill.rgb().to-hex()))

#let kyklo-flavor = core.ambrosia-flavor(base: "minimal", name: "kyklo",
  title-background: self => self.colors.surface-alt,
  block-style: "poster",
)

#let kyklo-theme(flavor: kyklo-flavor, palette: "ocean", ..args, body) = {
  let custom-primary = args.named().at("primary-logos", default: auto) != auto
  let options = (
    flavor: if flavor == "kyklo" { kyklo-flavor } else { flavor }, palette: palette, watermark-logo: watermark,
    header-logo: if custom-primary { auto } else { _header-logo },
    logo-focus: if custom-primary { auto } else { self => image(bytes(_data("kyklo-logo", dark: true))) },
    logos: (
      self => _logo("olympus-institute", self),
      self => _logo("helios-polytechnic", self),
      self => _logo("delphi-forum", self),
      self => _logo("nectarion-college", self),
    ),
  ) + args.named()
  show: core.ambrosia-theme.with(..options,
    core.config-info(logo: self => _logo("kyklo-logo", self)),
    ..args.pos())
  body
}
