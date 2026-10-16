#import "../src/lib.typ": *
#show: ambrosia-theme.with(flavor: "not-a-flavor")

// Validation must work even if the presenter does not create a title slide.
== Content
An unsupported flavor should fail at theme initialization.
