#import "../src/lib.typ": *
#set heading(numbering: "1.1")
#let mode = sys.inputs.at("mode", default: "long")
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "light"),
  text-size: int(sys.inputs.at("size", default: "18")) * 1pt,
  agenda-style: sys.inputs.at("style", default: "list"),
  watermark: sys.inputs.at("watermark", default: "on") != "off",
  config-common(new-section-slide-fn: if mode == "divider" { section-slide } else { new-section-slide }),
  config-info(title: [Long agendas], short-title: [Agendas], author: [Tester]),
)
#outline-slide(depth: 3, overflow: if mode == "error" { "error" } else { "window" })



= Section 1: a research question

Section introduction.

= Section 2: a research question

Section introduction.

= Section 3: a research question

Section introduction.

= Section 4: a research question

Section introduction.

= Section 5: a research question

Section introduction.

= Section 6: a research question

Section introduction.

= Section 7: a research question

Section introduction.

= Section 8: a research question

Section introduction.

= Section 9: a research question

Section introduction.

= Section 10: a research question

Section introduction.

= Section 11: a research question

Section introduction.

= Section 12: a research question

Section introduction.

= Section 13: a research question

Section introduction.

= Section 14: a research question

Section introduction.

= Section 15: a research question

Section introduction.

= Section 16: a research question

Section introduction.

= Section 17: a research question

Section introduction.

= Section 18: a research question

Current section introduction. #pause Revealed introduction.

== Topic 18.1: a result with supporting evidence

Content.

=== Detail 18.1: assumptions and limitations

== Topic 18.2: a result with supporting evidence

Content.

=== Detail 18.2: assumptions and limitations

== Topic 18.3: a result with supporting evidence

Content.

=== Detail 18.3: assumptions and limitations

== Topic 18.4: a result with supporting evidence

Content.

=== Detail 18.4: assumptions and limitations

== Topic 18.5: a result with supporting evidence

Content.

=== Detail 18.5: assumptions and limitations

== Topic 18.6: a result with supporting evidence

Content.

=== Detail 18.6: assumptions and limitations

== Topic 18.7: a result with supporting evidence

Content.

=== Detail 18.7: assumptions and limitations

== Topic 18.8: a result with supporting evidence

Content.

=== Detail 18.8: assumptions and limitations

== Topic 18.9: a result with supporting evidence

Content.

=== Detail 18.9: assumptions and limitations

== Topic 18.10: a result with supporting evidence

Content.

=== Detail 18.10: assumptions and limitations

== Topic 18.11: a result with supporting evidence

Content.

=== Detail 18.11: assumptions and limitations

== Topic 18.12: a result with supporting evidence

Content.

=== Detail 18.12: assumptions and limitations

== Topic 18.13: a result with supporting evidence

Content.

=== Detail 18.13: assumptions and limitations

== Topic 18.14: a result with supporting evidence

Content.

=== Detail 18.14: assumptions and limitations

== Topic 18.15: a result with supporting evidence

Content.

=== Detail 18.15: assumptions and limitations

== Topic 18.16: a result with supporting evidence

Content.

=== Detail 18.16: assumptions and limitations

== Topic 18.17: a result with supporting evidence

Content.

=== Detail 18.17: assumptions and limitations

== Topic 18.18: a result with supporting evidence

Content.

=== Detail 18.18: assumptions and limitations

== Topic 18.19: a result with supporting evidence

Content.

=== Detail 18.19: assumptions and limitations

== Topic 18.20: a result with supporting evidence

Content.

=== Detail 18.20: assumptions and limitations

== Topic 18.21: a result with supporting evidence

Content.

=== Detail 18.21: assumptions and limitations

== Topic 18.22: a result with supporting evidence

Content.

=== Detail 18.22: assumptions and limitations

== Topic 18.23: a result with supporting evidence

Content.

=== Detail 18.23: assumptions and limitations

== Topic 18.24: a result with supporting evidence

Content.

=== Detail 18.24: assumptions and limitations

== Topic 18.25: a result with supporting evidence

Content.

=== Detail 18.25: assumptions and limitations

== Topic 18.26: a result with supporting evidence

Content.

=== Detail 18.26: assumptions and limitations

== Topic 18.27: a result with supporting evidence

Content.

=== Detail 18.27: assumptions and limitations

== Topic 18.28: a result with supporting evidence

Content.

=== Detail 18.28: assumptions and limitations

== Topic 18.29: a result with supporting evidence

Content.

=== Detail 18.29: assumptions and limitations

== Topic 18.30: a result with supporting evidence

Content.

=== Detail 18.30: assumptions and limitations

= Section 19: a research question

Section introduction.

= Section 20: a research question

Section introduction.

= Section 21: a research question

Section introduction.

= Section 22: a research question

Section introduction.

= Section 23: a research question

Section introduction.

= Section 24: a research question

Section introduction.

= Section 25: a research question

Section introduction.

= Section 26: a research question

Section introduction.

= Section 27: a research question

Section introduction.

= Section 28: a research question

Section introduction.

= Section 29: a research question

Section introduction.

= Section 30: a research question

Section introduction.

= Section 31: a research question

Section introduction.

= Section 32: a research question

Section introduction.

= Section 33: a research question

Section introduction.

= Section 34: a research question

Section introduction.

= Section 35: a research question

Section introduction.

#outline-slide(start: 15, numbered: false)
#ending-slide(title: [End])[Questions?]
#show: appendix.with(numbering: "A.1")
= Backup section
Backup introduction.
== Supporting result
Appendix content.
