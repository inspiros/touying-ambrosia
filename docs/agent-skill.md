# Draft With An Agent

The optional [Ambrosia skill](https://github.com/inspiros/touying-ambrosia/tree/v0.1.0/skills/touying-ambrosia)
helps compatible coding agents create and edit presentations with this theme.
It contains instructions, a complete starter, and metadata/citation recipes.
It targets **Ambrosia 0.1.0** and needs no extra runtime dependencies. Typst and
the theme are installed separately; importing a Universe package does not
install agent skills.

## Install In A Presentation Project

Run this from your future slide project's directory, not from the theme checkout:

```sh
npx skills add inspiros/touying-ambrosia --skill touying-ambrosia --agent codex --copy
```

This uses the third-party [skills CLI](https://github.com/vercel-labs/skills)
to copy the skill into the project's skill directory. `npx` needs Node/npm;
Ambrosia itself is not an npm package. Replace `codex` with another supported
agent, such as `claude-code`, or omit `--agent` to choose interactively.
For Codex, project skills live under `.agents/skills/`; commit that folder
if collaborators should share the same guidance.

Add `--global` to install for your user across projects. For a local theme
checkout, replace `inspiros/touying-ambrosia` with its filesystem path. This also
lets you try an unpublished skill before pushing it.

Without Node, copy the **whole skill folder** from a downloaded or cloned
repository into your presentation project:

```sh
mkdir -p .agents/skills
cp -R /path/to/touying-ambrosia/skills/touying-ambrosia .agents/skills/
```

This is the Codex project layout; other agents may use another discovery
directory. Follow their installation instructions. See the
[Codex skill documentation](https://learn.chatgpt.com/docs/build-skills).

## Use It

In Codex, explicitly invoke the installed skill:

```text
Use $touying-ambrosia to draft an eight-slide research talk from my notes.
Use minimal with the ocean palette, include two authors, and compile the PDF.
```

Or ask it to edit an existing Ambrosia deck; the description allows automatic
selection. If a newly installed skill is missing, start a fresh agent session.
In an agent without skill support, provide `SKILL.md` and its companion files
as context manually. The files remain readable Markdown and Typst.

## Scope

The skill covers Ambrosia configuration, slide helpers, components, citations,
appendices, and compile/layout checks. It preserves existing institutional
wrappers and directs the agent to their documented branding options; a separate
skill for each wrapper is unnecessary. It does not maintain the theme's source
or release it.

[SeaSlides](https://github.com/touying-typ/seaslides) has a wider scope: source
conversion, narrative planning, theme selection, asset tools, and exports.
Ambrosia's skill supplies focused API guidance when this theme is chosen. It
works independently; neither skill is a dependency of the other.

The repository shorthand installs from its default branch. To pin the skill
to this release, use
`https://github.com/inspiros/touying-ambrosia/tree/v0.1.0/skills/touying-ambrosia`
as the installation source instead. Keep a project-local copy for reproducible
guidance and review updates alongside package upgrades.
