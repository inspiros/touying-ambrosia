#import "../src/lib.typ": *
#import "../src/touying.typ": config-info as upstream-info
#import "../src/utils/people.typ": presentation-people

#assert.eq(ambrosia.config-info, config-info)
#assert.eq(config-info(), (info: (:)))
#assert.eq(config-info(title: [Talk], author: [Presenter], short-title: auto, date: none),
  upstream-info(title: [Talk], author: [Presenter], short-title: auto, date: none))
#assert.eq(config-info(institutions: auto).info, (institutions: auto))
#assert.eq(config-info(authors: none).info, (authors: none))
#assert.eq(config-info(project-id: "custom", extra: (revision: 2)).info,
  (project-id: "custom", extra: (revision: 2)))

#let collaborators = ambrosia.config-info(
  title: [Collaborator Metadata],
  short-author: auto,
  authors: (
    (name: [First Collaborator], short: [F. Collaborator], affiliations: ("lab", "partner"),
      emails: ("first@example.org", "other@example.org")),
    (name: [Second Collaborator], affiliations: ("partner",), email: "second@example.org"),
  ),
  institutions: (lab: [Example Laboratory], partner: (name: [Partner Institute], address: [Example City])),
  emails: ("team@example.org",),
  affiliation-scope: "collaboration",
)
#let merged = utils.merge-dicts(collaborators, config-info(date: none))
#assert.eq(merged.info.authors, collaborators.info.authors)
#assert.eq(merged.info.institutions, collaborators.info.institutions)
#let people = presentation-people(merged.info)
#assert.eq(people.authors.len(), 2)
#assert.eq(people.authors.first().affiliations, (1, 2))
#assert.eq(people.authors.first().emails.len(), 2)
#assert.eq(people.institutions.last().address, [Example City])
#assert.eq(people.emails, ("team@example.org",))
#assert.eq(presentation-people(config-info(author: [Single Presenter], institution: [Single Institute], email: "single@example.org").info).authors.first().name, [Single Presenter])

// A partial info override must not replace the theme's symbol marker pattern.
#show: ambrosia.theme.with(flavor: "minimal", affiliation-numbering: "*",
  collaborators, ambrosia.config-info(date: none))
#ambrosia.title-slide()
#ambrosia.slide(title: [Linked Collaborators])[
  Presenter#ambrosia.affiliation("partner", scope: "collaboration")
]
