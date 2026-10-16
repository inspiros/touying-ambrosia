#import "../src/lib.typ": *
#import "../src/lib.typ" as touying
#show: ambrosia-theme.with(flavor: "simple", config-info(title: [Utility tests], author: [Tester]))

== Nested blocks

#ambrosia-block(title: [Outer], shadowed: false)[
  #ambrosia-block(style: "framed", title: [Inner], shadowed: false)[
    Before #pause After nested pause.
    #alert[Before alert pause #pause After alert pause.]
  ]
]

== Context and upstream methods

#context ambrosia-block(title: [Context], shadowed: false)[
  #alert[Context alert.]
  #ambrosia-block(title: [Nested context block], shadowed: false)[Context nested body.]
]

#touying.alert[Upstream alert method.]

== Title variants

#ambrosia-block(title: "String title", background: none, shadowed: false)[String titles work.]
#ambrosia-block(title: heading(level: 3)[Heading title], shadowed: false)[Heading titles keep their structure.]

