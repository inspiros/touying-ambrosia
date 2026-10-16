# Navigation Patterns In Beamer

Beamer's named themes compose outer, color, font, and inner themes. Many named
looks reuse the same navigation. This comparison follows the installed Beamer
sources and their upstream [outer themes](https://github.com/josephwright/beamer/tree/main/base/themes/outer)
and [named themes](https://github.com/josephwright/beamer/tree/main/base/themes/theme).

| Beamer family | Representative themes | Behavior | Ambrosia choice |
| --- | --- | --- | --- |
| `miniframes` | Berlin, Dresden, Singapore, Szeged | Section groups with miniature frame markers | `dots` |
| `smoothbars` | Darmstadt, Frankfurt | Miniature-frame navigation with shaded bands | `dots` plus the flavor's band/gradient treatment |
| `sidebar` | Berkeley, PaloAlto, Goettingen, Hannover, Marburg | Left/right outline; options for hiding inactive subsections | `sidebar`, with bounded labels and branch windows |
| `infolines` | CambridgeUS, Madrid, Boadilla, AnnArbor | Current section/subsection and metadata footer | `context` plus the ordinary footer |
| `split` | Copenhagen, Luebeck, Malmoe | Separate section and subsection selectors | `panes`, with two independent bounded lists |
| `tree` / `smoothtree` | Antibes, Montpellier / JuanLesPins | Indented title/section/subsection path | `tree` for stacked strips; `breadcrumbs` for one title line |

These are family-level counterparts, not exact ports. Beamer has more options
for subsection groupings, compression, and marker shapes. Gradients, shadows,
separator lines, and marker shapes usually change the visual treatment while
retaining the navigation model.

## What To Bring To Ambrosia

The missing structural family was **split navigation**, now implemented as
`panes`. Unlike `context`, it offers neighboring sections and subsections to
select, rather than displaying only the current pair. It earns a separate
choice because it changes both the information shown and the space reserved.

Miniature-frame navigation, sidebars, and hierarchical context are already
covered by `dots`, `sidebar`, and `breadcrumbs`. Smooth bars and smooth trees
can be expressed through flavor treatment; adding names for each shaded
variation would make the API harder to choose from.

The tree family is also available as `tree`: thin, progressively indented
strips with branch hooks, a short talk title, and current ancestor links. It
reserves two or three rows rather than replacing the current slide title.
Shading variants can still use the same renderer instead of adding Beamer
names as new navigators.

## Tabs And Segments

`tabs` and `segments` both show the same level-one sections. Tabs are linked
labels with an active state. Segments add a progress track within each section
and default to the footer. Their names describe rendering, not different levels
of a chapter/section hierarchy. Neither requires a new flavor.

The footer uses one compact logo/controls row, then the segmented rail, then
metadata. This keeps the rail attached to the footer strip and avoids a large
logo-sized gap. See [navigation configuration](navigation.md) and the
[editable example](../examples/navigation.typ).
