#import "../src/lib.typ": *
#show: ambrosia-theme.with(flavor: "simple", config-info(title: [Layout], author: [Tester]))

#slide(title: [Hidden decorations], header: none, footer: none)[Bare slide body.]
#slide(title: [Custom decorations], header: [Custom header], footer: [Custom footer])[Custom slide body.]
#focus-slide(fill: white)[Readable light focus.]
#title-slide(title: [Title override], date: [Special date], logos: none, logo: none)
