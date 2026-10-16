#import "../src/lib.typ": *
#show: ambrosia-theme.with(navigation: "breadcrumbs", config-common(new-section-slide-fn: none))
= Section
== Original Heading
Original body.
#slide(title: [A Custom Slide Title])[Custom body.]
#outline-slide(title: [A Custom Agenda])
