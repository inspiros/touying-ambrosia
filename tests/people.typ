#import "../src/lib.typ": *
#let authors = (
  (name: [Alexandra Verylongfamilyname], short: [A. Verylongfamilyname],
    affiliations: ("kyklo", "cnrs"), email: "alexandra.verylongfamilyname@unicaen.fr"),
  (name: [Benjamin Anotherlongfamilyname], affiliations: ("kyklo",), email: "benjamin@unicaen.fr"),
  (name: [Charlotte Thirdresearcher], affiliations: ("partner",), email: "charlotte@partner.example"),
  (name: [Daniel Fourthresearcher], affiliations: ("cnrs",), email: "daniel@cnrs.fr"),
  (name: [Emma Fifthresearcher], affiliations: ("kyklo", "partner")),
  (name: [Farid Sixthresearcher], affiliations: ("kyklo",)),
)
#show: ambrosia-theme.with(
  flavor: sys.inputs.at("flavor", default: "minimal"),
  palette: sys.inputs.at("palette", default: "light"),
  text-size: int(sys.inputs.at("size", default: "18")) * 1pt,
  config-store(
    footer-aa: self => [Alexandra Verylongfamilyname, Benjamin Anotherlongfamilyname, Charlotte Thirdresearcher, Daniel Fourthresearcher, Emma Fifthresearcher, and Farid Sixthresearcher],
    footer-ab: self => [A detailed research presentation title that explains the collaboration, all participating institutions, the scientific contributions, the experimental assumptions, the main findings, and the remaining limitations in much more detail than a footer should normally contain],
  ),
  config-info(
    title: [A detailed research presentation title that explains the collaboration and its scientific contributions],
    authors: authors,
    institutions: (
      kyklo: [Kyklo, Olympus Institute],
      cnrs: (name: [Helios], address: [France]),
      partner: [An international university and research partner],
    ),
    emails: ("alexandra.verylongfamilyname@unicaen.fr", "collaboration@research.example"),
    date: [PEOPLE DATE],
  ),
)
#title-slide()
#for index in range(1, int(sys.inputs.at("slides", default: "125")) + 1) {
  slide(title: [Result #index])[Research content #index.]
}
#ending-slide(title: [Questions?])[Contact the collaboration.]
