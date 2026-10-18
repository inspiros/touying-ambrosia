#!/usr/bin/env python3
"""Compile Typst assertions and check slide/appendix behavior with no Python dependencies."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tomllib
import shutil
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PACKAGE_PATH = None
FLAVORS = ("simple", "cambridge", "darmstadt", "dewdrop", "stargazer", "minimal", "portico")
TEAMS = ()


def typst(*args):
    if PACKAGE_PATH is not None and "--package-path" not in args:
        args = (*args, "--package-path", PACKAGE_PATH)
    result = subprocess.run(["typst", *map(str, args)], cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stderr)
    if result.stderr:
        print(result.stderr, file=sys.stderr, end="")
    return result.stdout


def assert_appendix(events):
    by_id = {}
    for event in events:
        by_id.setdefault(event["id"], []).append(event)
    assert len(by_id["main"]) == 2, "A pause must create two main-slide frames."
    assert len({event["slide"] for event in by_id["main"]}) == 1
    assert all(len(by_id[key]) == 1 for key in ("main-next", "ending", "appendix", "appendix-next", "explicit-backup"))
    total = by_id["ending"][0]["slide"]
    assert all(event["total"] == total for event in events), "Appendix must freeze the denominator."
    appendix = by_id["appendix"][0]
    next_appendix = by_id["appendix-next"][0]
    assert total < appendix["slide"] < next_appendix["slide"], "Appendix slide counters must keep advancing."
    assert by_id["explicit-backup"][0]["slide"] == next_appendix["slide"], "Explicit backup freezes the slide counter."
    assert appendix["heading"] == [0], "Unnumbered appendix headings must follow the counter reset."
    assert all("Backup" not in heading for event in events for heading in event["main-outline"]), "Main outline must exclude appendix headings."
    assert all("Main" not in heading for event in events if event["id"].startswith("appendix")
               for heading in event["current-outline"]), "Appendix outlines must not inherit main sections."


def pdf_pages(path):
    if not shutil.which("pdftotext"):
        raise RuntimeError("Behavioral PDF checks require pdftotext (Poppler).")
    result = subprocess.run(["pdftotext", "-layout", str(path), "-"], check=True, capture_output=True, text=True)
    return result.stdout.rstrip("\f\n").split("\f")


def assert_utilities(output):
    path = output / "header-animations.pdf"
    typst("compile", "--root", ROOT, "tests/header-animations.typ", path)
    headers = pdf_pages(path)
    assert len(headers) == 2 and "Second part" not in headers[0] and "Second part" in headers[1]
    typst("compile", "--root", ROOT, "tests/layout.typ", output / "layout.pdf")
    layout = pdf_pages(output / "layout.pdf")
    assert len(layout) == 4
    assert "Tester" not in layout[0] and "Hidden decorations" not in layout[0]
    assert "Custom header" in layout[1] and "Custom footer" in layout[1]
    assert "Readable light focus" in layout[2]
    assert "Special date" in layout[3] and "Title override" in layout[3]
    typst("compile", "--root", ROOT, "tests/blocks.typ", output / "blocks.pdf")
    blocks = pdf_pages(output / "blocks.pdf")
    assert len(blocks) == 5
    assert "After nested pause" not in blocks[0]
    assert "After nested pause" in blocks[1] and "After alert pause" not in blocks[1]
    assert "After alert pause" in blocks[2]
    assert "Context nested body" in blocks[3] and "Upstream alert method" in blocks[3]
    assert "String titles work" in blocks[4] and "Heading titles keep their structure" in blocks[4]
    for once in ("true", "false"):
        path = output / f"citations-{once}.pdf"
        typst("compile", "--root", ROOT, "--input", f"once={once}", "tests/citations.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 8
        assert "The TeXbook" not in pages[0], "A covered citation must not leak its footnote."
        assert pages[1].count("The TeXbook") == 1 and pages[2].count("The TeXbook") == 1
        assert "Ordinary note2" in " ".join(pages[2].split()), "Duplicate citations must not consume footnote numbers."
        assert ("The TeXbook" in pages[3]) == (once == "false")
        assert "First Scoped Book" in pages[4] and "Second Scoped Book" not in pages[4]
        assert "Second Scoped Book" in pages[5] and "First Scoped Book" not in pages[5]
        assert "Explicit footnote reference a" in pages[4]
        assert ("First Scoped Book" in pages[7]) == (once == "false")
    print("PASS nested/context blocks, animation-aware citations, numbering and multiple bibliographies")
    path = output / "citation-animations.pdf"
    typst("compile", "--root", ROOT, "tests/citation-animations.typ", path)
    pages = pdf_pages(path)
    assert len(pages) == 3
    assert "Attention Is All You Need" not in pages[0] and "Elektrodynamik" not in pages[0]
    assert "Attention Is All You Need" in pages[1] and "Elektrodynamik" in pages[1]
    assert "Attention Is All You Need" in pages[2] and "Elektrodynamik" not in pages[2]
    assert "Revealed footnote reference a" in " ".join(pages[2].split()), "Custom labels must survive uncover and later-frame references."
    count = json.loads(typst("eval", "--root", ROOT, "--format", "json", "--in", "tests/citation-animations.typ",
                             "query(bibliography).len()"))
    assert count == 1, "An animated slide must not instantiate a bibliography on every frame."
    print("PASS citation only/uncover visibility, revealed labels and one bibliography per animated slide")
    for mode in ("notes", "second-screen", "handout"):
        path = output / f"{mode}.pdf"
        typst("compile", "--root", ROOT, "--input", f"mode={mode}", "--input", "aspect-ratio=16-10",
              "tests/slides.typ", path)
        text = "\n".join(pdf_pages(path))
        assert "Appendix body must remain visible" in text
        if mode != "handout":
            assert "Presenter note for the main slide" in text
    print("PASS presenter notes, second screen, handouts and custom aspect ratio")
    path = output / "numbered-appendix.pdf"
    typst("compile", "--root", ROOT, "--input", "appendix-numbering=A.1", "tests/slides.typ", path)
    text = "\n".join(pdf_pages(path))
    assert "A Backup section" in text and "A.1 Backup slide" in text and "A.2 Second backup slide" in text
    assert "0.1 Backup slide" not in text
    print("PASS numbered appendix starts at A and keeps its main-slide denominator")


def assert_new_utilities(output, palettes):
    for mode in ("author-year", "number", "local", "key"):
        path = output / f"citation-markers-{mode}.pdf"
        typst("compile", "--root", ROOT, "--input", f"marker={mode}", "tests/citation-markers.typ", path)
        pages = [" ".join(page.split()) for page in pdf_pages(path)]
        assert len(pages) == 8
        assert "The TeXbook" not in pages[0] and "Ordinary note1" in pages[0]
        assert "The TeXbook" in pages[1] and "The TeXbook" in pages[2] and "The TeXbook" not in pages[3]
        expected_note = "2" if mode == "local" else "1"
        assert f"Ordinary note{expected_note}" in pages[1] and f"Ordinary note{expected_note}" in pages[3]
        assert "Custom reference [ManualKey]" in pages[6] and "Explicit key [knuth84]" in pages[6]
        assert "Native YAML source" in pages[7]
        if mode == "author-year":
            assert "[Knuth1984a]" in pages[1] and "[Knuth1984a]" in pages[2]
            assert "Second work [Knuth1984b]" in pages[3] and "First work again [Knuth1984a]" in pages[3]
            assert "[First2020]" in pages[4] and "[Second2021]" in pages[5] and "[Yaml2026]" in pages[7]
        elif mode == "number":
            assert "Second work [2]" in pages[3] and "First work again [1]" in pages[3]
            assert "[3]" in pages[4] and "[4]" in pages[5] and "[7]" in pages[7]
        elif mode == "key":
            assert "[first:shared]" in pages[4] and "[second:shared]" in pages[5]
        links = json.loads(typst("eval", "--root", ROOT, "--input", f"marker={mode}", "--format", "json",
            "--in", "tests/citation-markers.typ", '{ let entries = query(footnote.entry).filter(e => e.note.body.func() == metadata and e.note.body.value.at("kind", default: none) == "ambrosia-citation").map(e => e.location()); query(link).filter(it => type(it.dest) == location and it.dest in entries).len() }'))
        assert links >= 10, "Citation markers and aliases must link to real footnote entries."
    print("PASS author-year disambiguation, stable IDs, local/key modes, custom aliases, ordinary numbering, links and YAML")
    for palette in palettes:
        path = output / f"block-styles-{palette}.pdf"
        typst("compile", "--root", ROOT, "--input", f"palette={palette}", "tests/block-styles.typ", path)
        pages = pdf_pages(path)
        style_count = len(json.loads(typst("eval", "--root", ROOT, "--format", "json",
            '{ import "src/components/block-styles.typ": block-style-names; block-style-names }')))
        assert len(pages) == 2 * style_count + 2
        for frame in range(0, 2 * style_count, 2):
            assert "Visible before" in pages[frame] and "Nested revealed" not in pages[frame]
            assert "Nested revealed" in pages[frame + 1] and "Visible after" in pages[frame + 1]
        assert "Contrasting text on custom colors" in pages[-1] and "Nested contextual body" in pages[-1]
    print("PASS all block styles across every palette, nested animations, semantic kinds and context")
    path = output / "extra-slides.pdf"
    typst("compile", "--root", ROOT, "tests/extra-slides.typ", path)
    pages = [" ".join(page.split()) for page in pdf_pages(path)]
    assert len(pages) == 7
    assert "Section introduction" in pages[0] and "Revealed badge" not in pages[1] and "Revealed badge" in pages[2]
    assert "A counted transition" in pages[3] and "3/4" in pages[3].replace(" ", "")
    assert "Kyklo laboratory" in pages[4] and "Image credit" in pages[4]
    assert "A Backup section" in pages[5] and "Backup introduction" in pages[5] and "A.1 Supporting result" in pages[6]
    print("PASS section/image slides, automatic dividers, badges/credits, counted transitions and numbered appendix")


def assert_image_captions(output):
    source = "tests/image-captions.typ"
    expression = '''{
      let events(sel) = query(sel).map(it => (page: it.location().page(),
        x: it.location().position().x.pt(), y: it.location().position().y.pt(), ..it.value));
      (images: events(<ambrosia-image-region>), captions: events(<ambrosia-image-caption>),
       links: query(link).filter(it => it.dest == "https://example.org").len())
    }'''
    cases = [("ocean", 18, "slides", "right"), ("midnight", 24, "slides", "right"),
             ("ocean", 18, "handout", "right"), ("ocean", 18, "notes", "right")]
    cases += [("midnight", 18, "second-screen", side) for side in ("left", "right", "top", "bottom")]
    for palette, size, mode, side in cases:
        opts = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}",
                "--input", f"mode={mode}", "--input", f"side={side}")
        path = output / f"image-captions-{palette}-{size}-{mode}-{side}.pdf"
        typst("compile", "--jobs", "1", *opts, source, path)
        info = subprocess.check_output(["pdfinfo", str(path)], text=True)
        pages = int(next(line.split(":", 1)[1] for line in info.splitlines() if line.startswith("Pages:")))
        assert pages == 8, (palette, mode, side)
        data = json.loads(typst("eval", *opts, "--in", source, "--format", "json", expression))
        assert len(data["images"]) == 8 and len(data["captions"]) == 7, data
        assert data["links"] == 6, data
        for c, image in zip(data["captions"], data["images"]):
            assert image["x"] - .01 <= c["x"] and image["y"] - .01 <= c["y"], (c, image)
            assert c["x"] + c["width"] <= image["x"] + image["width"] + .01, (c, image)
            assert c["y"] + c["height"] <= image["y"] + image["height"] + .01, (c, image)
        # Notes-only output has its own projection geometry; ordinary and
        # second-screen output retain original slide coordinates and em sizes.
        if mode != "notes":
            images, caps = data["images"], data["captions"]
            assert abs(caps[0]["y"] + caps[0]["height"] - images[0]["y"] - images[0]["height"]) < .01
            assert abs(caps[1]["y"] - images[1]["y"]) < .01
            assert abs(caps[2]["x"] + caps[2]["width"] - images[2]["x"] - images[2]["width"] + size) < .01
            assert abs(caps[2]["width"] - .42 * (images[2]["width"] - 2 * size)) < .01
            assert abs(caps[3]["x"] - images[3]["x"] - 2 * size) < .01
            assert abs(caps[3]["y"] + caps[3]["height"] - images[3]["y"] - images[3]["height"] + 1.5 * size) < .01
            assert abs(2 * caps[4]["x"] + caps[4]["width"] - 2 * images[4]["x"] - images[4]["width"]) < .01
            assert abs(2 * caps[4]["y"] + caps[4]["height"] - 2 * images[4]["y"] - images[4]["height"]) < .01
        assert data["captions"][5]["text-fill"] == 'rgb("#171b22")', data
    for case, diagnostic in (("position", "caption-position must be"), ("width", "caption-width must fit"),
                             ("height", "Image caption is too tall")):
        try:
            typst("compile", "--root", ROOT, "--input", f"invalid={case}", source, output / "invalid-caption.pdf")
        except RuntimeError as error:
            assert diagnostic in str(error), (case, str(error))
        else:
            raise AssertionError(f"Invalid caption {case} should produce a useful error.")
    svg = output / "caption-links.svg"
    typst("compile", "--root", ROOT, "--format", "svg", "--pages", "1", source, svg)
    fills = {node.get("fill") for node in ET.parse(svg).iter() if node.get("fill")}
    assert "#fbf7f8" in fills and "#0079c2" not in fills, fills
    print("PASS image captions: bands/corners, asymmetric margins, measured bounds, links, colors, notes, handout and diagnostics")


def assert_sankey_recipe(output):
    source = "tests/sankey-recipe.typ"
    for palette, size in (("ocean", 18), ("midnight", 24)):
        opts = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}")
        path = output / f"sankey-{palette}.pdf"
        typst("compile", "--jobs", "1", *opts, source, path)
        assert len(pdf_pages(path)) == 1
        data = json.loads(typst("eval", *opts, "--in", source, "--format", "json", '''{
          let events(sel) = query(sel).map(it => (x: it.location().position().x.pt(),
            y: it.location().position().y.pt(), ..it.value));
          (region: events(<sankey-region>).first(), nodes: events(<sankey-node>), edges: events(<sankey-ribbon>))
        }'''))
        assert len(data["nodes"]) == 5 and len(data["edges"]) == 4
        region = data["region"]
        ratios = [n["height"] / n["capacity"] for n in data["nodes"]]
        ratios += [e["height"] / e["value"] for e in data["edges"]]
        assert max(ratios) - min(ratios) < .001, data
        for n in data["nodes"]:
            assert region["x"] <= n["x"] and n["x"] + n["width"] <= region["x"] + region["width"] + .01
            assert region["y"] <= n["y"] and n["y"] + n["height"] <= region["y"] + region["height"] + .01
        by_id = {n["id"]: n for n in data["nodes"]}
        for e in data["edges"]:
            src, dst = by_id[e["source"]], by_id[e["target"]]
            assert abs(e["x"] - src["x"] - src["width"]) < .01
            assert e["height"] <= min(src["height"], dst["height"]) + .01
    for case, diagnostic in (("empty", "at least one edge"), ("cycle", "acyclic graph"),
                             ("self", "self-loops"), ("weight", "positive and finite"),
                             ("skip", "adjacent columns"), ("unknown", "Unknown Sankey node"), ("small", "too small")):
        try:
            typst("compile", "--root", ROOT, "--input", f"invalid={case}", source, output / "invalid-sankey.pdf")
        except RuntimeError as error:
            assert diagnostic in str(error), (case, str(error))
        else:
            raise AssertionError(f"Invalid Sankey {case} should produce a useful error.")
    print("PASS optional native Sankey: standalone pages, shared weight scale, bounded bars, padding, cycle/weight/column diagnostics")


def assert_path_geometry(events):
    for event in events:
        nodes = event.get("nodes", [])
        if not nodes:
            continue
        spines = event["spines"]
        assert len(spines) == len(nodes) - 1, event
        centers = [(n["x"] + n["radius"], n["y"] + n["radius"]) for n in nodes]
        assert all(abs(x - centers[0][0]) < .01 for x, _ in centers), event
        for node, (_, y) in zip(nodes, centers):
            entry = next(e for e in event["entries"] if e["target"] == node["target"])
            assert abs(y - entry["y"] - node["cap"] / 2) < .01, (event, node, entry)
        for i, spine in enumerate(spines):
            assert abs(spine["x"] - centers[i][0]) < .01, (event, spine)
            assert abs(spine["y"] - nodes[i]["y"] - 2 * nodes[i]["radius"]) < .01, (event, spine)
            assert abs(spine["y"] + spine["length"] - nodes[i + 1]["y"]) < .01, (event, spine)


def assert_agenda_styles(output):
    for style in ('list', 'cards', 'path'):
        for palette, size in (('light',18), ('midnight',24)):
            opts=('--root',ROOT,'--input',f'style={style}','--input',f'palette={palette}','--input',f'size={size}')
            path=output / f'{style}-{palette}.pdf'
            typst('compile',*opts,'tests/agenda-styles.typ',path)
            pages=pdf_pages(path)
            assert len(pages)==20,(style,palette,len(pages))
            events=json.loads(typst('eval',*opts,'--in','tests/agenda-styles.typ','--format','json', '''{
              let entries=query(<ambrosia-agenda-entry>);
              query(<ambrosia-agenda-fit>).map(it => (page: it.location().page(), ..it.value,
                entries: entries.filter(e => e.location().page() == it.location().page()).map(e => (..e.value,
                  x: e.location().position().x.pt(), y: e.location().position().y.pt())),
                nodes: query(<ambrosia-agenda-path-node>).filter(e => e.location().page() == it.location().page()).map(e => (..e.value,
                  x: e.location().position().x.pt(), y: e.location().position().y.pt())),
                spines: query(<ambrosia-agenda-path-spine>).filter(e => e.location().page() == it.location().page()).map(e => (..e.value,
                  x: e.location().position().x.pt(), y: e.location().position().y.pt())),
                active: query(<ambrosia-agenda-card>).filter(e => e.location().page() == it.location().page() and e.value.active).len(),
                links: query(link).filter(e => e.location().page() == it.location().page() and type(e.dest) == location).map(e => e.dest.page())))
            }'''))
            assert_path_geometry(events)
            assert all(e['height']<=e['available']+.01 and .8<=e['scale']<=1 for e in events),(style,palette,events)
            assert all(e['shown']+e['omitted']==e['total'] for e in events)
            assert all(e['style']==style for e in events if e['requested-style']==style)
            assert all(e['entries'] and all(x['target']<=17 for x in e['entries']) for e in events if e['page']<18)
            assert all(e['entries'] and all(x['target']>=18 for x in e['entries']) for e in events if e['page']>=18)
            assert all(x['target'] in e['links'] for e in events for x in e['entries']), 'Every agenda entry needs a native PDF link.'
            assert all(abs(2*e['focus-center']-e['available'])<.01 for e in events if e['kind']=='section')
            if style=='cards':
                assert events[0]['columns']==2 and events[0]['active']==0
                assert all(e['active']==1 for e in events if e['kind']=='section')
            intros=[p for p in pages if 'Section introduction.' in p]
            assert len(intros)==5 and sum('Revealed introduction.' in p for p in intros)==1
            print('PASS short scoped, linked, fitted agenda:',style,palette,flush=True)
        # Empty decks should have a valid empty overview in each style.
        typst('compile','--root',ROOT,'--input',f'style={style}','--input','mode=empty',
                'tests/agenda-styles.typ',output / f'empty-{style}.pdf')
    for mode, font, size in (("wrapped", "DejaVu Sans", 28), ("single", "DejaVu Serif", 20)):
        opts = ("--root", ROOT, "--input", "style=path", "--input", f"mode={mode}",
                "--input", f"font={font}", "--input", f"size={size}")
        path = output / f"path-{mode}.pdf"
        typst("compile", "--jobs", "1", *opts, "tests/agenda-styles.typ", path)
        events = json.loads(typst("eval", *opts, "--in", "tests/agenda-styles.typ", "--format", "json", '''{
          let on-page(sel, p) = query(sel).filter(e => e.location().page() == p).map(e => (..e.value,
            x: e.location().position().x.pt(), y: e.location().position().y.pt()));
          query(<ambrosia-agenda-fit>).map(it => (..it.value,
            entries: on-page(<ambrosia-agenda-entry>, it.location().page()),
            nodes: on-page(<ambrosia-agenda-path-node>, it.location().page()),
            spines: on-page(<ambrosia-agenda-path-spine>, it.location().page())))
        }'''))
        assert_path_geometry(events)
        assert all(e["height"] <= e["available"] + .01 for e in events)
        if mode == "single":
            assert any(len(e["nodes"]) == 1 and not e["spines"] for e in events)
        else:
            assert len(pdf_pages(path)) == 20, "Wrapping must not add overflow pages."
        print("PASS path geometry: aligned caps, centered connectors,", mode, font, size, flush=True)
    # Many heading targets in a small fixture keep fitting tests inexpensive.
    for style in ("cards", "path"):
        opts = ("--root", ROOT, "--input", f"style={style}")
        path = output / f"dense-{style}.pdf"
        typst("compile", "--jobs", "1", *opts, "tests/agenda-density.typ", path)
        events = json.loads(typst("eval", *opts, "--in", "tests/agenda-density.typ", "--format", "json",
            "query(<ambrosia-agenda-fit>).map(it => it.value)"))
        pages = pdf_pages(path)
        assert len(pages) == 6, (style, len(pages))
        assert all(e["shown"] + e["omitted"] == e["total"] and e["height"] <= e["available"] + .01 for e in events)
        assert events[0]["omitted"] > 0
        assert events[0]["style"] == ("list" if style == "cards" else "path")
        assert any(e["omitted"] > 0 for e in events if e["kind"] == "section")
        introductions = [page for page in pages if "Current introduction." in page]
        assert len(introductions) == 2 and "Revealed introduction." not in introductions[0]
        assert "Revealed introduction." in introductions[1]
        print("PASS dense agendas, fallback, fitted windows:", style, flush=True)


def assert_agendas_people_watermarks(output):
    for palette, size in (("light", 18), ("midnight", 24)):
        options = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}")
        path = output / f"agendas-{palette}-{size}.pdf"
        typst("compile", *options, "tests/agendas.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 71, "Long agendas must not add overflow pages."
        events = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/agendas.typ",
                                 "query(<ambrosia-agenda-fit>).map(it => it.value)"))
        assert len(events) == 39
        assert all(event["columns"] == 1 and 0.8 <= event["scale"] <= 1
                   and event["height"] <= event["available"] + 0.01 for event in events)
        assert all(event["shown"] + event["omitted"] == event["total"] for event in events)
        assert events[0]["omitted"] > 0 and events[0]["depth"] == 1
        focused = [event for event in events if event["kind"] == "section"]
        assert all(abs(2 * event["focus-center"] - event["available"]) < 0.01
                   and event["neighbors"] <= 2 for event in focused)
        dense = [event for event in focused if "Section 18" in json.dumps(event["current"])]
        assert len(dense) == 2 and all(event["omitted"] > 0 for event in dense)
        introductions = [page for page in pages if "Current section introduction." in page]
        assert len(introductions) == 2
        assert "Revealed introduction" not in introductions[0] and "Revealed introduction" in introductions[1]
        assert "A Backup section" in pages[-2] and "A.1 Supporting result" in pages[-1]
    print("PASS long one-column agendas, centered branches, linked omissions, introductions and appendix")
    for flavor in FLAVORS:
        options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", "slides=1")
        path = output / f"people-{flavor}.pdf"
        typst("compile", *options, "tests/people.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 3 and "PEOPLE DATE" in pages[0]
        assert all(name in pages[0] for name in ("Verylongfamilyname", "Anotherlongfamilyname",
                                                "Thirdresearcher", "Sixthresearcher", "Helios"))
        contacts = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/people.typ",
                                   'query(link).filter(it => it.location().page() == 1 and type(it.dest) == str and it.dest.starts-with("mailto:")).len()'))
        assert contacts == 5, "Personal/shared emails must be linked without duplicated addresses."
    path = output / "people-long-footer.pdf"
    typst("compile", "--root", ROOT, "tests/people.typ", path)
    pages = pdf_pages(path)
    assert len(pages) == 127 and "127" in pages[-1] and "126" in pages[-2]
    events = json.loads(typst("eval", "--root", ROOT, "--format", "json", "--in", "tests/people.typ",
                             "query(<ambrosia-footer-fit>).map(it => it.value)"))
    assert any(event["overflow"] and not event["complete"] for event in events)
    assert all(not event["overflow"] and event["width"] <= event["available"] + 0.01
               for event in events if event["complete"])
    print("PASS multiple authors/affiliations, linked emails, fitted covers and complete three-digit footers")
    for palette in ("light", "midnight"):
        path = output / f"watermarks-{palette}.pdf"
        options = ("--root", ROOT, "--input", f"palette={palette}")
        typst("compile", *options, "tests/watermarks.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 8 and "Nested content" not in pages[3] and "Nested content" in pages[4]
        assert pages[3].count("The TeXbook") == 1 and pages[4].count("The TeXbook") == 1
        marks = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/watermarks.typ",
                                'query(image).filter(it => type(it.source) == bytes and str(it.source).contains(" opacity=")).map(it => it.location().page())'))
        assert all(page in marks for page in range(1, 7))
        assert 7 not in marks and 8 not in marks, "Per-slide watermark disabling must work."
    print("PASS adaptive page/container watermarks, clipping, animation/citations and per-slide controls")


def assert_panel_shadows_and_footer_labels(output):
    for palette, size in (("light", 18), ("midnight", 24)):
        options = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}")
        path = output / f"block-shadows-{palette}.pdf"
        typst("compile", *options, "tests/block-shadows.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 6
        assert "AFTER REVEAL" not in pages[4] and "The TeXbook" not in pages[4]
        assert "AFTER REVEAL" in pages[5] and pages[5].count("The TeXbook") == 1
        assert pages[4].count("ORDINARY NOTE") == pages[5].count("ORDINARY NOTE") == 1
        shadows = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/block-shadows.typ",
            'query(<shadowed-shadow>).map(it => (page: it.location().page(), hollow: str(it.source).contains("fill=\\\"none\\\""), height: it.height.length.pt()))'))
        by_page = {page: [it for it in shadows if it["page"] == page] for page in range(1, 7)}
        assert len(by_page[1]) == 2 and all(not it["hollow"] for it in by_page[1]), "Poster panels must have independent shadows."
        assert len(by_page[2]) == 1 and by_page[2][0]["hollow"], "An outlined shadow must have an empty interior."
        assert not by_page[3], "Transparent borderless content must not cast a rectangle shadow."
        assert sorted(it["hollow"] for it in by_page[4]) == [False, True]
        assert len(by_page[5]) == len(by_page[6]) == 3
    print("PASS separate poster shadows, hollow transparent shadows, nesting, relative sizes, reveals and footnotes")
    for flavor in FLAVORS:
        for date in ("absent", "present"):
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"date={date}")
            path = output / f"footer-labels-{flavor}-{date}.pdf"
            typst("compile", *options, "tests/footer-labels.typ", path)
            pages = pdf_pages(path)
            assert len(pages) == 3 and "TITLEDATE" in pages[1]
            assert all(("FOOTERDATE" in pages[index]) == (date == "present") for index in (0, 2))
            assert "TITLEDATE" not in pages[2], "Cover date overrides must not mutate footer metadata."
            events = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/footer-labels.typ",
                'query(<ambrosia-footer-fit>).map(it => (page: it.location().page(), ..it.value))'))
            for page in (1, 3):
                fields = [event for event in events if event["page"] == page]
                labels = [event for event in fields if not event["complete"]]
                assert len(labels) == 2 and all(event["overflow"] and event["scale"] == 0.8 for event in labels)
                complete = [event for event in fields if event["complete"]]
                assert len(complete) == (2 if date == "present" else 1)
                assert all(not event["overflow"] and event["width"] <= event["available"] + 0.01 for event in complete)
    print("PASS explicit long short-author/title clipping, absent/configured footer dates, and local cover dates in every flavor")


def assert_installed_template(output):
    data_dir = output / "package-data"
    subprocess.run([sys.executable, str(ROOT / "scripts/install.py"), "--data-dir", str(data_dir),
                    "--namespace", "preview", "--reinstall"], check=True, capture_output=True, text=True)
    package = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    package_dir = data_dir / "typst/packages/preview" / package["name"] / package["version"]
    assert all(not (package_dir / path).exists()
               for path in ("develop", "target", "tests", "docs", "examples", "assets/samples", "assets/gallery", ".git", ".github", ".aws"))
    starter = ROOT / "develop/tests/installed-starter"
    shutil.copytree(package_dir / "template", starter, dirs_exist_ok=True)
    typst("compile", "--root", starter, "--package-path", data_dir / "typst/packages",
          starter / "template.typ", output / "installed-template.pdf")
    print("PASS installed starter, companion branding/bibliography files and package exclusions")


def assert_title_fitting(output):
    scales = []
    for flavor in FLAVORS:
        for size in (16, 18, 24):
            path = output / f"title-{flavor}-{size}.pdf"
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"text-size={size}")
            typst("compile", *options, "tests/title-fitting.typ", path)
            pages = pdf_pages(path)
            assert len(pages) == 3, f"{flavor}/{size}: dense title must remain one physical page."
            assert "SHORT DATE" in pages[0] and "DENSE DATE" in pages[1] and "NEXT SLIDE" in pages[2]
            events = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/title-fitting.typ",
                                      "query(<ambrosia-title-fit>).map(it => it.value)"))
            assert len(events) == 2
            assert events[0]["scale"] == 1, "A short title must not be enlarged or unnecessarily reduced."
            assert all(0.65 <= event["scale"] <= 1 and event["height"] <= event["available"] for event in events)
            scales.append(events[1]["scale"])
    assert min(scales) < 0.95, "The dense fixture must exercise actual shrinking."
    try:
        typst("compile", "--root", ROOT, "--input", "min-scale=full", "--input", "text-size=24",
              "tests/title-fitting.typ", output / "title-overflow.pdf")
    except RuntimeError as error:
        assert "Title slide is too dense" in str(error), error
    else:
        raise AssertionError("A title that cannot fit must explain the problem instead of overflowing.")
    print("PASS dense titles stay on one page across all layouts and 16/18/24pt text; explicit overflow diagnostic")


def assert_tabbed_blocks(output):
    for palette, size in (("light", 18), ("midnight", 24)):
        options = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}")
        path = output / f"tabbed-{palette}.pdf"
        typst("compile", *options, "tests/tabbed-blocks.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 4
        assert "AFTER REVEAL" not in pages[0] and "AFTER REVEAL" in pages[1]
        assert pages[0].count("ORDINARY NOTE") == pages[1].count("ORDINARY NOTE") == 1
        assert pages[1].count("The TeXbook") == 1
        assert "BODY BELOW THE TAB" in pages[2] and "UNTITLED BODY" in pages[3]
        tabs = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/tabbed-blocks.typ",
            'query(<ambrosia-block-tab>).map(it => it.value)'))
        assert len(tabs) == 5 and all(it["width"] <= it["available"] for it in tabs)
    print("PASS tabbed panels: long labels, nesting/reveals, transparent bodies, shadows, watermarks, citations and no title")


def assert_title_layouts(output):
    names = json.loads(typst("eval", "--root", ROOT, "--format", "json",
        '{import "src/title-layouts.typ": title-layout-names; title-layout-names}'))
    offset = len(names)
    for flavor in FLAVORS:
        for palette, size in (("light", 18), ("midnight", 24)):
            options = ("--root", ROOT, "--input", f"flavor={flavor}",
                       "--input", f"palette={palette}", "--input", f"size={size}")
            path = output / f"title-layouts-{flavor}-{palette}.pdf"
            typst("compile", *options, "tests/title-layouts.typ", path)
            pages = [" ".join(page.replace("\u200b", "").split()) for page in pdf_pages(path)]
            assert len(pages) == offset + 7, (flavor, palette, len(pages))
            assert all("TITLE DATE" in page and "alice@example.org" in page for page in pages[:-1])
            assert all("EXPLICITONE" in pages[i] and "DEFAULTPARTNER" not in pages[i] for i in range(offset + 1))
            assert "LOCALONLY" in pages[offset + 1] and "EXPLICITONE" not in pages[offset + 1]
            assert "EXPLICITONE" not in pages[offset + 2] and "MAINLOGO" not in pages[offset + 2]
            assert "EXPLICITONE" not in pages[offset + 4]
            assert "MAINLOGO" in pages[offset + 5] and "DEFAULTPARTNER" in pages[offset + 5]
            assert "AFTER TITLE" in pages[-1]
            data = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/title-layouts.typ",
                '{ let fits = query(<ambrosia-title-fit>).map(it => it.value); let layouts = query(<ambrosia-title-layout>).map(it => it.value); let logos = query(<ambrosia-title-logo>).map(it => it.value + (page: it.location().page(),)); (fits: fits, layouts: layouts, logos: logos) }'))
            assert [it["name"] for it in data["layouts"]] == names + ["theme-header", "header", "header", "wrapped", "hidden", "plain"]
            assert all(0.65 <= it["scale"] <= 1 and it["height"] <= it["available"] + 0.01 for it in data["fits"])
            assert all(it["logo-width"] <= it["width"] + 0.01 and it["logo-height"] <= it["height"] + 0.01 for it in data["logos"])
            assert not any(it["page"] in (offset + 3, offset + 5) for it in data["logos"])
            assert len([it for it in data["logos"] if it["page"] == offset + 4]) == 5
            contacts = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/title-layouts.typ",
                'query(link).filter(it => it.location().page() == 3 and type(it.dest) == str and it.dest.starts-with("mailto:")).len()'))
            assert contacts == 2, "Split titles must retain native author email links."
    for case, diagnostic in (("name", "Title layout 'unknown'"), ("key", "Unknown title layout option"),
                             ("side", "Side logos require"), ("columns", "positive integer"), ("shadow", "Title shadow must be")):
        try:
            typst("compile", "--root", ROOT, "--input", f"case={case}", "tests/title-layout-invalid.typ", output / "invalid-title.pdf")
        except RuntimeError as error:
            assert diagnostic in str(error), error
        else:
            raise AssertionError(f"Invalid title layout {case} should fail.")
    print("PASS independent title layouts across every flavor, dense light/dark covers, equal-role logos, overrides, containment, links and diagnostics")


def assert_branding(output):
    # Check actual repeated artwork and page bounds, not only configuration data.
    for flavor in FLAVORS:
        for palette in ("light", "midnight"):
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"palette={palette}")
            path = output / f"branding-{flavor}-{palette}.pdf"
            typst("compile", *options, "tests/branding.typ", path)
            pages = pdf_pages(path)
            assert len(pages) == 11, (flavor, palette, len(pages))
            assert all("PRIMARYONE" in page and "PRIMARYTWO" in page for page in pages[:10])
            assert all("PARTNERONE" in page and "PARTNERTWO" in page for page in pages[:6])
            assert all("PARTNERONE" not in page and "PARTNERTWO" not in page for page in pages[6:])
            assert "PRIMARYONE" not in pages[-1] and "PRIMARYTWO" not in pages[-1]
            assert "FALLBACK" not in " ".join(pages)
            strips = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/branding.typ",
                'query(<ambrosia-logo-strip>).map(it => it.value)'))
            assert strips and all(it["width"] <= it["limit"] + 0.01 for it in strips)
    for mode in ("none", "auto"):
        path = output / f"branding-{mode}.pdf"
        typst("compile", "--root", ROOT, "--input", f"primary={mode}", "tests/branding.typ", path)
        pages = pdf_pages(path)
        assert "PRIMARYONE" not in " ".join(pages)
        assert ("FALLBACK" in pages[6]) == (mode == "auto")
        assert all("PARTNERONE" in page for page in pages[:6])
    for flavor, navigation in (("minimal", "tabs"), ("cambridge", "dots"), ("darmstadt", "segments")):
        path = output / f"branding-{flavor}-{navigation}.pdf"
        typst("compile", "--root", ROOT, "--input", f"flavor={flavor}", "--input", f"navigation={navigation}",
              "tests/branding.typ", path)
        assert len(pdf_pages(path)) == 11
    print("PASS multiple primary marks, title groups, bounded repeated logos, light/dark flavors, overrides and navigation")


def assert_text_styles(output, palettes):
    def contrast_hex(a, b):
        def luminance(value):
            channels = [int(value[i:i+2], 16) / 255 for i in (1, 3, 5)]
            linear = [c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4 for c in channels]
            return sum(a * b for a, b in zip(linear, (.2126, .7152, .0722)))
        light, dark = sorted((luminance(a), luminance(b)), reverse=True)
        return (light + .05) / (dark + .05)
    cases = [(palette, 18) for palette in palettes]
    cases += [(palette, size) for palette in ("ocean", "midnight") for size in (16, 24)]
    for palette, size in cases:
        for mode in ("styled", "plain"):
            options = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}", "--input", f"mode={mode}")
            path = output / f"text-{palette}-{size}-{mode}.pdf"
            typst("compile", *options, "tests/text-styles.typ", path)
            pages = pdf_pages(path)
            assert len(pages) == 7, (palette, size, mode, len(pages))
            assert "REVEALED TEXT" not in pages[1] and "REVEALED TEXT" in pages[2]
            assert "REVEALED QUOTATION" not in pages[3] and "REVEALED QUOTATION" in pages[4]
            assert pages[3].count("QUOTATION NOTE") == pages[4].count("QUOTATION NOTE") == 1
            assert "ATTRIBUTION" in pages[3] and "ATTRIBUTION" in pages[4]
            data = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/text-styles.typ", '''{
              (probes: query(<ambrosia-text-probe>).map(it => it.value),
               raw: query(raw).map(it => (text: it.text, lang: it.lang, block: it.block, plain-theme: it.theme == none)),
               panels: query(<ambrosia-code-style>).len(),
               links: query(link).filter(it => it.dest == "https://example.org").len())
            }'''))
            probes = {it["role"]: it for it in data["probes"]}
            assert all(abs(it["size"] - size * (1.25 if it["role"] == "large" else 1)) < .01 for it in data["probes"])
            assert probes["large"]["weight"] == "bold"
            assert all(contrast_hex(it["ink"], it["background"]) >= 4.47 for it in data["probes"] if it["role"] != "normal")
            assert data["links"] == 2 and data["panels"] == (2 if mode == "styled" else 0)
            assert [(r["lang"], r["block"]) for r in data["raw"]] == [("python", False), ("python", True), ("text", True)]
            assert data["raw"][-1]["plain-theme"], "An explicit native raw theme override must survive styling."
    print("PASS text emphasis inheritance/contrast across palettes, late contexts, panel/page colors, native code/quotes, reveals, links and footnotes")


def assert_bookends(output):
    for palette, size in (("light", 18), ("midnight", 24)):
        options = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"size={size}")
        path = output / f"author-rows-{palette}.pdf"
        typst("compile", *options, "tests/author-rows.typ", path)
        assert len(pdf_pages(path)) == 4
        authors = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/author-rows.typ",
            'query(<ambrosia-author-layout>).map(it => it.value)'))
        assert [it["authors"] for it in authors] == [4, 5, 8, 12]
        assert authors[0]["columns"] == 2 and authors[0]["rows"] == 2
        assert all(1 <= it["columns"] <= 3 and it["rows"] > 1 for it in authors)
        for flavor in FLAVORS:
            opts = (*options, "--input", f"flavor={flavor}")
            path = output / f"endings-{flavor}-{palette}.pdf"
            typst("compile", *opts, "tests/ending-layouts.typ", path)
            pages = [" ".join(p.replace("\u200b", "").split()) for p in pdf_pages(path)]
            assert len(pages) == 12, (flavor, palette, len(pages))
            for index in range(1, 9, 2):
                assert "BEFORE REVEAL" in pages[index] and "AFTER REVEAL" not in pages[index]
                assert "AFTER REVEAL" in pages[index + 1]
                assert pages[index].count("ORDINARY END NOTE") == pages[index + 1].count("ORDINARY END NOTE") == 1
                assert "The TeXbook" not in pages[index] and pages[index + 1].count("The TeXbook") == 1
                assert "shared@example.org" in pages[index] and "shared@example.org" in pages[index + 1]
            assert "shared@example.org" not in pages[9] and "FULL WIDTH END" in pages[10]
            assert "shared@example.org" not in pages[11] and pages[11].count("local@example.org") == 1
            data = json.loads(typst("eval", *opts, "--format", "json", "--in", "tests/ending-layouts.typ",
                '{ (layouts: query(<ambrosia-ending-layout>).map(it => it.value), bibliographies: query(bibliography).len()) }'))
            assert data["bibliographies"] == 1
            assert [it["name"] for it in data["layouts"]] == ["centered", "centered", "plain", "plain", "split", "split", "cover", "cover", "plain", "split", "cover"]
            assert not data["layouts"][-2]["side"]
    for case, diagnostic in (("name", "Ending layout 'unknown'"), ("key", "Unknown ending layout option"),
                             ("side", "Side logos require"), ("columns", "positive integer"), ("shadow", "Ending shadow must be")):
        try:
            typst("compile", "--root", ROOT, "--input", f"case={case}", "tests/ending-layout-invalid.typ", output / "invalid-ending.pdf")
        except RuntimeError as error:
            assert diagnostic in str(error), error
        else:
            raise AssertionError(f"Invalid ending layout {case} should fail.")
    modes = (("slides", "right"), ("handout", "right"), ("notes", "right"),
             *(("second-screen", side) for side in ("left", "right", "top", "bottom")))
    for mode, side in modes:
        opts = ("--root", ROOT, "--input", f"mode={mode}", "--input", f"side={side}")
        path = output / f"cover-{mode}-{side}.pdf"
        typst("compile", *opts, "tests/bookend-covers.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 2 and "PHOTO OPENING" in pages[0] and "LAST TAKEAWAY" in pages[1]
        if mode in ("notes", "second-screen"):
            assert "PHOTO PRESENTER NOTE" in pages[1]
        marks = json.loads(typst("eval", *opts, "--format", "json", "--in", "tests/bookend-covers.typ",
            'query(<ambrosia-cover-region>).map(it => it.value)'))
        assert len(marks) == 2 and all(it["width"] > it["height"] > 0 for it in marks)
        if mode == "slides":
            contrast = json.loads(typst("eval", *opts, "--format", "json", "--in", "tests/bookend-covers.typ",
                '{ import "/src/palettes.typ" as palettes; let p = palettes.resolve("light"); let note = query(<cover-note-ink>).first().value; (link: palettes.contrast(query(<cover-link-ink>).first().value, p.cover), note: palettes.contrast(note.fill, p.cover), size: note.size) }'))
            assert contrast["link"] >= 4.5 and contrast["note"] >= 4.5 and 0 < contrast["size"] < 14
    print("PASS balanced 4/5/8/12-author covers; ending layouts across all flavors, native footnotes/citations, reveals, contact overrides and photograph output modes")


def assert_typography(output):
    for flavor in ("simple", "stargazer", "minimal"):
        for size in (16, 18, 24):
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"text-size={size}")
            path = output / f"typography-{flavor}-{size}.pdf"
            typst("compile", *options, "tests/typography.typ", path)
            events = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/typography.typ",
                                      "query(<ambrosia-type-test>).map(it => it.value)"))
            actual = {event["role"]: event["size"] for event in events}
            assert all(abs(actual[role] - expected) < 0.001 for role, expected in
                       (("body", size), ("table", size * 0.85), ("caption", size * 0.8)))
            result = subprocess.run(["pdftotext", "-bbox", str(path), "-"], check=True, capture_output=True, text=True)
            root = ET.fromstring(result.stdout)
            namespace = {"x": "http://www.w3.org/1999/xhtml"}
            page = root.find(".//x:page", namespace)
            words = {word.text: word for word in page.findall("x:word", namespace)}
            assert float(words["LeftEdge"].attrib["xMin"]) >= size
            assert float(page.attrib["width"]) - float(words["RightEdge"].attrib["xMax"]) >= size
    print("PASS relative body/table/caption sizes and footer edge spacing at 16/18/24pt")


def assert_extensions(output):
    for quiet in ("false", "true"):
        options = ("--root", ROOT, "--input", f"quiet={quiet}")
        path = output / f"extensions-{quiet}.pdf"
        typst("compile", *options, "tests/extensions.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 4
        assert "CUSTOMTITLE" in pages[0] and "CUSTOMENDING" in pages[-1]
        assert "REVEALED BODY" not in pages[1] and "REVEALED BODY" in pages[2]
        assert ("CUSTOMHEADER" in pages[1]) == (quiet == "false")
        assert ("CUSTOMFOOTER" in pages[1]) == (quiet == "false")
        hooks = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/extensions.typ",
            'query(<ambrosia-extension-test>).map(it => it.value)'))
        assert sorted(it["kind"] for it in hooks) == ["ending", "title"]
        assert all(it["flavor"] == ("quiet" if quiet == "true" else "independent") for it in hooks)
    options = ("--root", ROOT, "--input", "empty=true")
    path = output / "extensions-empty.pdf"
    typst("compile", *options, "tests/extensions.typ", path)
    pages = pdf_pages(path)
    assert len(pages) == 4
    assert "CUSTOMTITLE" not in " ".join(pages) and "CUSTOMENDING" not in " ".join(pages)
    assert "ENDING BODY" in pages[-1]
    assert "POSITIONAL BODY" in pages[1] and "REVEALED BODY" in pages[2]
    for kind, diagnostic in (("key", "Unknown flavor option"), ("renderer", "title-renderer must be")):
        try:
            typst("compile", "--root", ROOT, "--input", f"kind={kind}", "tests/invalid-extension.typ", output / "invalid-extension.pdf")
        except RuntimeError as error:
            assert diagnostic in str(error), error
        else:
            raise AssertionError("Invalid flavor descriptors must produce a diagnostic.")
    print("PASS independent flavors, all renderer hooks, inherited explicit none, nested reveals, and extension diagnostics")


def assert_palette_people_bibliography(output):
    for palette in ("light", "midnight"):
        options = ("--root", ROOT, "--input", f"palette={palette}")
        path = output / f"palette-component-{palette}.pdf"
        typst("compile", *options, "tests/palettes.typ", path)
        assert len(pdf_pages(path)) == 2
        events = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/palettes.typ",
            'query(<ambrosia-palette-showcase>).map(it => it.value)'))
        assert len(events) == 3 and all(e["palette"] == "Fieldwork" for e in events)
        override = events[1]["colors"][0]["color"]
        assert override == "rgb(\"#793767\")", override
    for flavor in FLAVORS:
        for pattern in ("*", "a", "custom"):
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"numbering={pattern}")
            path = output / f"affiliations-{flavor}-{pattern.replace('*', 'symbols')}.pdf"
            typst("compile", *options, "tests/affiliations.typ", path)
            assert len(pdf_pages(path)) == 4
            data = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/affiliations.typ",
                '{ let anchors = query(<ambrosia-institution>); (anchors: anchors.map(it => it.value), links: query(link).filter(it => type(it.dest) == location and anchors.any(a => a.location() == it.dest)).map(it => (from: it.location().page(), to: it.dest.page()))) }'))
            links = data["links"]
            assert [it["marker"] for it in data["anchors"][2:]] == ["I", "II"]
            assert all(it["scope"] == "other" for it in data["anchors"][2:])
            assert len(links) == 8, links
            assert [(it["from"], it["to"]) for it in links] == [(1,1)] * 3 + [(2,1)] + [(3,3)] * 3 + [(4,3)]
    for mode in ("author-year", "native"):
        path = output / f"bibliography-markers-{mode}.pdf"
        typst("compile", "--root", ROOT, "--input", f"marker={mode}", "tests/bibliography-markers.typ", path)
        pages = [" ".join(page.split()) for page in pdf_pages(path)]
        assert len(pages) == 7
        assert "[Knuth1984a]" in pages[0] and "[Knuth1984b]" in pages[0]
        if mode == "author-year":
            assert "[Knuth1984a]" in pages[1] and "[Knuth1984b]" in pages[1]
            assert "[Anonymous study2025]" in pages[1] and "Anonymous study." in pages[1]
            assert "[First2020]" in pages[3] and "[Second2021]" in pages[4] and "[Yaml2026]" in pages[6]
        else:
            assert "[Knuth1984a]" not in pages[1] and "[1]" in pages[1]
        assert "[1]" in pages[5] and "[Knuth1984a]" not in pages[5]
    print("PASS composed palettes/current-color showcase, symbolic/custom linked affiliations, repeated covers, matching CSL bibliography labels and native opt-out")


def assert_native_cites_and_navigation(output):
    for mode in ("author-year", "native"):
        path = output / f"inline-citations-{mode}.pdf"
        options = ("--root", ROOT, "--input", f"marker={mode}")
        typst("compile", *options, "tests/inline-citations.typ", path)
        pages = [" ".join(page.split()) for page in pdf_pages(path)]
        assert len(pages) == 3 and "Second frame" in pages[1]
        if mode == "author-year":
            assert "Normal [Knuth1984a]. Shorthand [Knuth1984a]." in pages[0], pages[0]
            assert "Revealed [Knuth1984b]" not in pages[0] and "Revealed [Knuth1984b]" in pages[1]
        else:
            assert "Normal [1]. Shorthand [1]." in pages[0], pages[0]
        assert "Explicit IEEE [1]" in pages[0] and "Full APA Knuth" in pages[0]
        assert "Native heading Result 1.1" in pages[0]
    cases = [(f, p, "slides", "true") for f in FLAVORS for p in ("light", "midnight")]
    cases += [("minimal", "light", mode, "true") for mode in ("handout", "notes", "second-screen")]
    cases += [("minimal", "light", "slides", "false")]
    for flavor, palette, mode, buttons in cases:
        options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"palette={palette}",
                   "--input", f"mode={mode}", "--input", f"buttons={buttons}")
        path = output / f"navigation-{flavor}-{palette}-{mode}-{buttons}.pdf"
        typst("compile", *options, "tests/navigation.typ", path)
        data = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/navigation.typ",
            '{ let events = query(<ambrosia-navigation-target>); (events: events.map(it => (page: it.location().page(), x: it.location().position().x.pt(), ..it.value)), links: query(link).filter(it => type(it.dest) == location).map(it => (page: it.location().page(), target: it.dest.page()))) }'))
        events = data["events"]
        if mode in ("handout", "notes") or buttons == "false":
            assert events == [], (mode, events)
            continue
        pages = pdf_pages(path)
        assert len(pages) == 11, (flavor, len(pages))
        assert all("FOREGROUND" in page for page in pages)
        for page in (3, 4):
            on_page = {e["action"]: e["target"] for e in events if e["page"] == page}
            assert on_page["previous"] == 2 and on_page["next"] == 5, on_page
        assert not any(e["page"] in (6, 7, 8) for e in events)
        assert not any(e["page"] >= 10 and e["action"] == "section" and e["target"] < 10 for e in events)
        assert all({"page": e["page"], "target": e["target"]} in data["links"] for e in events)
        if mode == "second-screen":
            bbox = subprocess.check_output(["pdftotext", "-bbox", str(path), "-"], text=True)
            width = float(next(e for e in ET.fromstring(bbox).iter() if e.tag.endswith("page")).attrib["width"])
            assert all(e["x"] < width / 2 for e in events), "Controls must stay on the slide half."
    print("PASS native cite/@ labels and overrides, heading refs, logical PDF navigation, appendix, local/immersive hiding, preserved foregrounds and output modes")


def assert_footer_logo_space(output):
    for flavor in ("cambridge", "darmstadt"):
        for size, enabled, navigator in ((16, "auto", "false"), (18, "auto", "true"), (24, "auto", "false"), (18, "false", "true")):
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"size={size}",
                       "--input", f"logo={enabled}", "--input", f"navigation-buttons={navigator}")
            path = output / f"footer-space-{flavor}-{size}-{enabled}-{navigator}.pdf"
            typst("compile", *options, "tests/footer-logos.typ", path)
            assert len(pdf_pages(path)) == 3
            data = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/footer-logos.typ",
                '{ (body: query(<body-region>).map(it => (page: it.location().page(), bottom: it.location().position().y.pt() + it.value.height)), logos: query(<footer-logo-probe>).map(it => (page: it.location().page(), y: it.location().position().y.pt()))) }'))
            if enabled == "false":
                assert data["logos"] == []
            else:
                assert len(data["logos"]) == 1 and data["logos"][0]["page"] == 1
                assert data["body"][0]["bottom"] + 1 < data["logos"][0]["y"], data
            assert data["body"][1]["bottom"] == data["body"][2]["bottom"], data
    print("PASS in-flow footer logos never overlap full-height content, 16/18/24pt sizing, navigation, global/local hiding and absent footers")


def assert_footer_accessories(output):
    for unit in ("em", "pt", "relative"):
        options = ("--root", ROOT, "--input", f"unit={unit}")
        source = "tests/footer-accessories.typ"
        path = output / f"footer-units-{unit}.pdf"
        typst("compile", *options, source, path)
        data = json.loads(typst("eval", *options, "--in", source, "--format", "json", '''{
          let events(sel) = query(sel).map(it => (y:it.location().position().y.pt(), ..it.value));
          (body:events(<accessory-body>), controls:events(<ambrosia-navigation-buttons-region>), rail:events(<ambrosia-segment-region>))
        }'''))
        assert len(pdf_pages(path)) == 1
        assert data["body"][0]["y"] + data["body"][0]["height"] < data["controls"][0]["y"]
        assert data["controls"][0]["y"] + data["controls"][0]["height"] < data["rail"][0]["y"]
    print("PASS shared footer row: em/pt logo heights, relative text size, body clearance and rail order")


def assert_gallery_views(output):
    expected_pages = {"layout": 2, "cover": 1, "title-layout": 1, "ending-layout": 1, "palettes": 1, "blocks": 1, "annotations": 1,
                      "citations": 2, "people": 1, "palette-component": 1, "navigation-buttons": 3, "roadmap": 1, "slides": 6, "navigation": 3, "credits": 1}
    for view, count in expected_pages.items():
        path = output / f"gallery-{view}.pdf"
        typst("compile", "--root", ROOT, "--input", f"view={view}", "examples/gallery.typ", path)
        assert len(pdf_pages(path)) == count, f"Unexpected overflow in gallery view {view}."
    print("PASS all fifteen gallery views and bounded component cards")


def assert_roadmaps(output):
    for palette in ("ocean", "midnight"):
        for case in ("normal", "fractional", "custom-unit", "decimal-ticks", "plain", "empty", "fit", "unfitted", "animated"):
            options = ("--root", ROOT, "--input", f"palette={palette}", "--input", f"case={case}")
            path = output / f"roadmap-{palette}-{case}.pdf"
            typst("compile", *options, "tests/roadmap.typ", path)
            pages = pdf_pages(path)
            assert len(pages) == (2 if case == "animated" else 1), (case, len(pages))
            events = json.loads(typst("eval", *options, "--in", "tests/roadmap.typ", "--format", "json",
                                     "query(<ambrosia-roadmap>).map(it => it.value)"))
            if case == "normal":
                event = events[0]
                assert event["total"] == 14 and event["now"] == 0
                assert event["phases"] == [{"start": 0, "end": 4}, {"start": 6, "end": 14}]
                assert [task["row"] for task in event["tasks"]] == [2, 2, 3, 4, 5]
                assert event["tasks"][2]["end"] == 14, "Plain drawers extend to the end."
                assert event["milestones"] == [4, 14]
                assert all(label in pages[0] for label in ("W12–14", "First Task", "Second Task", "First Drawer", "Second Drawer", "Delivery"))
            elif case == "fractional":
                event = events[0]
                assert event["total"] == 5.5 and event["unit"] == "day" and event["now"] == 1.75
                assert event["tasks"][0]["end"] == event["tasks"][1]["start"] == 1.25
                assert event["tasks"][-1]["start"] == .75 and event["tasks"][-1]["end"] == 5.25
                assert all(time in event["points"] for time in (.25, .75, 1.25, 1.75, 2.75, 5.25, 5.5))
                assert "D0–0.5" in pages[0] and "D5–5.5" in pages[0]
            elif case == "custom-unit":
                assert "sprint 0–1" in pages[0] and "Now: sprint 0.5" in pages[0]
            elif case == "decimal-ticks":
                assert "h0.3–0.4" in pages[0] and "Now: h0.3" in pages[0]
                assert "0000000000" not in pages[0]
            elif case == "plain":
                assert events[0]["headers"] == 1 and events[0]["now"] is None
                assert "No Phases Or Current Marker" in pages[0]
            elif case in ("fit", "unfitted"):
                event = events[0]
                if case == "fit":
                    assert .7 <= event["scale"] < .95
                    assert event["height"] <= event["available"]
                else:
                    assert event["scale"] == 1 and event["height"] > event["available"]
            elif case == "animated":
                assert "Revealed Plan" not in pages[0] and "Revealed Plan" in pages[1]
            if case != "animated":
                # Real PDF positions must remain proportional, including task
                # boundaries between ticks and a shorter final interval.
                ticks = json.loads(typst("eval", *options, "--in", "tests/roadmap.typ", "--format", "json",
                    "query(<ambrosia-roadmap-tick>).map(it => (time: it.value.time, x: it.location().position().x.pt()))"))
                first, last = ticks[0], ticks[-1]
                for tick in ticks:
                    expected = first["x"] + tick["time"] / events[0]["total"] * (last["x"] - first["x"])
                    assert abs(tick["x"] - expected) < .01, (case, tick, expected)
    for case, message in (("overlap", "Use separate tracks"), ("bad-details", "details end"),
                          ("bad-phase", "phases must be ordered"), ("bad-now", "now must be a finite number"),
                          ("zero-duration", "start must be less than"), ("bad-total", "positive finite number"),
                          ("bad-ticks", "positive finite number"), ("excessive-ticks", "too many ticks"),
                          ("too-dense", "too dense to fit")):
        try:
            typst("compile", "--root", ROOT, "--input", f"case={case}", "tests/roadmap.typ", output / f"roadmap-{case}.pdf")
        except RuntimeError as error:
            assert message in str(error), str(error)
        else:
            raise AssertionError(f"Roadmap {case} should produce a useful diagnostic.")
    for palette in ("ocean", "midnight"):
        path = output / f"roadmap-example-{palette}.pdf"
        typst("compile", "--root", ROOT, "--input", f"palette={palette}", "examples/roadmap.typ", path)
        assert len(pdf_pages(path)) == 2
    print("PASS flexible roadmaps: custom units, fractional spans/ticks/markers, proportional PDF geometry, grouped drawers, fitting, reveals and diagnostics")


def assert_structural_navigation(output):
    cases = [("minimal", style, side, palette, "slides", "right")
             for style in ("none", "tabs", "dots", "context", "tree", "panes", "breadcrumbs", "sidebar", "custom", "custom-header")
             for side in (("left", "right") if style == "sidebar" else ("right",))
             for palette in ("ocean", "midnight")]
    cases += [(flavor, choice, "right", "ocean", "slides", "right")
              for flavor in FLAVORS for choice in ("auto", "none")]
    cases += [("portico", "auto", "left", "midnight", "second-screen", side)
              for side in ("left", "right", "top", "bottom")]
    cases += [("portico", "auto", "right", "ocean", mode, "right")
              for mode in ("handout", "notes", "article")]
    cases += [("portico", "auto", side, palette, "slides", "right")
              for side in ("left", "right") for palette in ("light", "midnight")]
    for flavor, choice, side, palette, mode, notes_side in cases:
        options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"navigation={choice}",
                   "--input", f"side={side}", "--input", f"palette={palette}", "--input", f"mode={mode}",
                   "--input", f"notes-side={notes_side}")
        path = output / f"structural-{flavor}-{choice}-{side}-{palette}-{mode}-{notes_side}.pdf"
        typst("compile", *options, "tests/navigation-layout.typ", path)
        data = json.loads(typst("eval", *options, "--in", "tests/navigation-layout.typ", "--format", "json", '''{
          let events(sel) = query(sel).map(it => (page: it.location().page(), x: it.location().position().x.pt(),
            y: it.location().position().y.pt(), ..it.value));
          (body: events(<navigation-body>), regions: events(<ambrosia-navigation-region>),
           fits: events(<ambrosia-sidebar-fit>), entries: events(<ambrosia-sidebar-entry>),
           breadcrumbs: events(<ambrosia-breadcrumb>), progress: events(<ambrosia-section-progress>),
           buttons: events(<ambrosia-navigation-buttons-region>), footer: events(<ambrosia-footer-fit>),
           links: query(link).filter(it => type(it.dest) == location).map(it => (page: it.location().page(), target: it.dest.page())))
        }'''))
        if mode in ("handout", "notes", "article"):
            assert not data["regions"] and not data["progress"] and not data["breadcrumbs"]
            continue
        pages = pdf_pages(path)
        assert len(pages) == 10, (flavor, choice, len(pages))
        assert all("ORIGINAL FOREGROUND" in page for page in pages)
        by_id = {e["id"]: e for e in data["body"]}
        sidebar = choice in ("sidebar", "custom") or (choice == "auto" and flavor == "portico")
        if sidebar:
            assert [r["page"] for r in data["regions"]] == [2, 3, 4, 5, 10]
            for region in data["regions"]:
                if flavor == "portico":
                    assert region["background"] is None and region["padding"] > 0
                    for fit in (f for f in data["fits"] if f["page"] == region["page"]):
                        assert abs(fit["width"] + 2 * region["padding"] - region["width"]) < .02
                        assert fit["available"] + 2 * region["padding"] <= region["height"] + .02
                body = next((b for b in data["body"] if b["page"] == region["page"]), None)
                if body is not None:
                    assert abs(body["width"] - (region["body-right"] - region["body-left"])) < .02
                    if mode != "second-screen" or notes_side != "left":
                        assert abs(body["x"] - region["body-left"]) < .02
                        assert abs(body["x"] + body["width"] - region["body-right"]) < .02
                    assert (region["x"] + region["width"] < body["x"] if side == "left"
                            else body["x"] + body["width"] < region["x"])
            expected = 8 * 18 + .8 * 18 if choice == "custom" else 9 * 18 + .8 * 18
            assert abs(by_id["disabled"]["width"] - by_id["next"]["width"] - expected) < .02
        else:
            assert not data["regions"]
            assert abs(by_id["disabled"]["width"] - by_id["next"]["width"]) < .02
        for buttons in data["buttons"]:
            fields = [f for f in data["footer"] if f["page"] == buttons["page"]]
            if fields:
                assert buttons["y"] + buttons["height"] < min(f["y"] for f in fields), (flavor, buttons, fields)
        for fit in data["fits"]:
            assert fit["height"] <= fit["available"] + .01
        assert not any(e["page"] == 3 and "Revealed" in str(e["body"]) for e in data["entries"])
        assert all(e["target"] >= 10 for e in data["entries"] if e["page"] == 10)
        assert all({"page": e["page"], "target": e["target"]} in data["links"]
                   for e in data["entries"] + data["breadcrumbs"])
        if choice == "breadcrumbs":
            assert data["breadcrumbs"] and not any(e["page"] == 3 and e["target"] > 3 for e in data["breadcrumbs"])
        progress = {e["page"]: e for e in data["progress"]}
        assert progress[3]["current"] == progress[4]["current"] == 1
        assert progress[3]["total"] == progress[4]["total"] == 6
        assert progress[5]["current"] == 2 and progress[10]["current"] == progress[10]["total"] == 1
        assert not any(e["page"] in (1, 7, 8, 9) for e in data["progress"])
        if mode == "second-screen":
            bbox = subprocess.check_output(["pdftotext", "-bbox", str(path), "-"], text=True)
            pdf_page = next(e for e in ET.fromstring(bbox).iter() if e.tag.endswith("page"))
            width, height = float(pdf_page.attrib["width"]), float(pdf_page.attrib["height"])
            for region in data["regions"]:
                if notes_side == "right": assert region["x"] + region["width"] < width / 2
                if notes_side == "left": assert region["x"] > width / 2
                if notes_side == "bottom": assert region["y"] + region["height"] < height / 2
                if notes_side == "top": assert region["y"] > height / 2
    for side in ("left", "right"):
        options = ("--root", ROOT, "--input", f"side={side}")
        path = output / f"navigation-long-{side}.pdf"
        typst("compile", *options, "tests/navigation-long.typ", path)
        assert len(pdf_pages(path)) == 64
        data = json.loads(typst("eval", *options, "--in", "tests/navigation-long.typ", "--format", "json",
                                "query(<ambrosia-sidebar-fit>).map(it => it.value)"))
        assert all(e["height"] <= e["available"] + .01 and e["omitted"] > 0 for e in data)
    for case, message in (("name", "Unknown navigation"), ("placement", "requires a custom renderer"),
                          ("width", "must be a length"), ("too-wide", "too little room")):
        try:
            typst("compile", "--root", ROOT, "--input", f"case={case}", "tests/navigation-invalid.typ", output / f"navigation-invalid-{case}.pdf")
        except RuntimeError as error:
            assert message in str(error), str(error)
        else:
            raise AssertionError(f"Navigation {case} should fail with a useful diagnostic.")
    path = output / "breadcrumb-titles.pdf"
    typst("compile", "--root", ROOT, "tests/breadcrumb-titles.typ", path)
    pages = pdf_pages(path)
    assert len(pages) == 3 and "A Custom Slide Title" in pages[1] and "A Custom Agenda" in pages[2]
    assert "Original Heading" not in pages[1]
    print("PASS structural navigation: choices/defaults, bounded left/right sidebars, restored margins, native links, covered headings, logical section progress, appendix and four second-screen positions")



def assert_sidebar_background(output):
    default = json.loads(typst("eval", "--root", ROOT, "--in", "tests/sidebar-background.typ",
        "--format", "json", 'query(<ambrosia-navigation-region>).first().value.background'))
    assert default is None, "Omitting sidebar-background must leave the sidebar transparent."
    for palette in ("ocean", "midnight"):
        for side in ("left", "right"):
            for background in ("auto", "none", "custom"):
                options = ("--root", ROOT, "--input", f"palette={palette}",
                           "--input", f"side={side}", "--input", f"background={background}")
                path = output / f"sidebar-paint-{palette}-{side}-{background}.pdf"
                typst("compile", *options, "tests/sidebar-background.typ", path)
                assert len(pdf_pages(path)) == 3
                data = json.loads(typst("eval", *options, "--in", "tests/sidebar-background.typ", "--format", "json", '''{
                  import "src/palettes.typ" as palettes;
                  let page-fill = palettes.resolve(sys.inputs.at("palette")).background;
                  (regions: query(<ambrosia-navigation-region>).map(it => {
                    let v = it.value;
                    let surface = if v.background == none { page-fill } else { v.background };
                    (..v, background: if v.background == none { none } else { v.background.to-hex() },
                      ink-contrast: palettes.contrast(v.ink, surface),
                      muted-contrast: palettes.contrast(v.muted, surface))
                  }), widths: query(<sidebar-background-body>).map(it => it.value.width))
                }'''))
                regions = data["regions"]
                assert len(regions) == 3 and len(data["widths"]) == 3
                assert max(data["widths"]) - min(data["widths"]) < .01
                assert max(r["padding"] for r in regions) - min(r["padding"] for r in regions) < .01
                assert regions[1]["background"] is None
                assert regions[2]["background"] == "#e8e2dc"
                assert (regions[0]["background"] is None) == (background == "none")
                assert all(r["ink-contrast"] >= 4.5 and r["muted-contrast"] >= 4.5 for r in regions)
    try:
        typst("compile", "--root", ROOT, "--input", "background=invalid",
              "tests/sidebar-background.typ", output / "invalid-sidebar-paint.pdf")
    except RuntimeError as error:
        assert "Sidebar background must be auto, none, or a color" in str(error)
    else:
        raise AssertionError("Invalid sidebar background should have a useful diagnostic.")
    print("PASS sidebar paint: global/local auto, transparent and custom colors; readable ink, unchanged widths/padding, both sides and light/dark palettes")


def assert_navigation_combinations(output, choices=("none", "tabs", "dots", "context", "tree", "breadcrumbs", "sidebar", "segments", "panes")):
    # Keep each flavor's real slide-level: Cambridge uses three levels.
    for flavor in FLAVORS:
        for choice in choices:
            palette = "midnight" if flavor in ("cambridge", "stargazer", "portico") else "ocean"
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"navigation={choice}",
                       "--input", f"palette={palette}")
            path = output / f"combination-{flavor}-{choice}.pdf"
            source = "tests/navigation-combinations.typ"
            typst("compile", *options, source, path)
            events = json.loads(typst("eval", *options, "--in", source, "--format", "json", '''{
              let positions(sel) = query(sel).map(it => (page: it.location().page(),
                y: it.location().position().y.pt(), ..it.value));
              (panes: positions(<ambrosia-pane-window>), pane_entries: positions(<ambrosia-pane-entry>), headers: positions(<ambrosia-header-region>), body: positions(<navigation-body>), dots: positions(<ambrosia-header-dot>), segments: positions(<ambrosia-segment-region>))
            }'''))
            assert len(pdf_pages(path)) == 12, (flavor, choice)
            for body in events["body"]:
                header = next(h for h in events["headers"] if h["page"] == body["page"])
                assert abs(header["y"]) < .01, (flavor, choice, "Header must meet the top edge", header)
                assert header["y"] + header["height"] <= body["y"] + .01, (flavor, choice, header, body)
            if choice == "panes":
                assert all(e["omitted"] > 0 for e in events["panes"] if e["pane"] == "sections" and e["page"] < 12)
                assert all(sum(e["active"] for e in events["pane_entries"] if e["page"] == page and e["pane"] == "sections") == 1 for page in range(1, 13))
                assert all(e["target"] >= 12 for e in events["pane_entries"] if e["page"] == 12)
            if choice == "segments":
                for body in events["body"]:
                    rail = next(r for r in events["segments"] if r["page"] == body["page"])
                    assert body["y"] + body["height"] <= rail["y"] + .01, (flavor, body, rail)
            if choice == "dots":
                for page in range(1, 13):
                    dots = [d for d in events["dots"] if d["page"] == page]
                    assert sum(d["active"] for d in dots) == 1, (flavor, page, dots)
                    assert all((d["target"] < 12) == (page < 12) for d in dots), (flavor, page, dots)
                first = next(d["target"] for d in events["dots"] if d["page"] == 1 and d["active"])
                second = next(d["target"] for d in events["dots"] if d["page"] == 2 and d["active"])
                assert first == second == 1
            if choice in ("tabs", "dots", "context"):
                bbox = subprocess.check_output(["pdftotext", "-f", "1", "-l", "1", "-bbox", str(path), "-"], text=True)
                words = [e for e in ET.fromstring(bbox).iter() if e.tag.endswith("word")]
                titles = [w for w in words if w.text == "CurrentSlideOne"
                          and float(w.attrib["yMax"]) - float(w.attrib["yMin"]) > 15]
                roots = [w for w in words if w.text == "ChapterOne"]
                assert titles and roots, (flavor, choice, "Header labels must remain visible")
                assert max(float(w.attrib["yMax"]) for w in roots) < min(float(w.attrib["yMin"]) for w in titles), (flavor, choice)
                body_words = [w for w in words if w.text == "BODYMARKER"]
                assert body_words and max(float(w.attrib["yMax"]) for w in titles) < min(float(w.attrib["yMin"]) for w in body_words), (flavor, choice, "Header ink must clear body ink")
        print(f"PASS navigation combinations: {flavor}")
    print(f"PASS all {len(FLAVORS) * len(choices)} flavor/navigation combinations: native heading levels, bounded header labels, body clearance, animations and appendix")


def assert_segment_navigation(output):
    cases = [(placement, flavor, palette, size, "slides", "right")
             for placement in ("footer", "header") for flavor, palette in (("minimal", "ocean"), ("cambridge", "midnight"))
             for size in (16, 18, 24)]
    cases += [("footer", "minimal", "ocean", 18, mode, "right") for mode in ("handout", "notes", "article")]
    cases += [("footer", "minimal", "midnight", 18, "second-screen", side) for side in ("left", "right", "top", "bottom")]
    for placement, flavor, palette, size, mode, side in cases:
        options = ("--root", ROOT, "--input", f"placement={placement}", "--input", f"flavor={flavor}",
                   "--input", f"palette={palette}", "--input", f"size={size}", "--input", f"mode={mode}", "--input", f"notes-side={side}")
        path = output / f"chapters-{placement}-{flavor}-{size}-{mode}-{side}.pdf"
        source = "tests/navigation-segments.typ"
        typst("compile", *options, source, path)
        data = json.loads(typst("eval", *options, "--in", source, "--format", "json", '''{
          let events(sel) = query(sel).map(it => (page: it.location().page(),
            x: it.location().position().x.pt(), y: it.location().position().y.pt(), ..it.value));
          (segments: events(<ambrosia-segment-entry>), regions: events(<ambrosia-segment-region>),
           accessories: events(<ambrosia-footer-accessories>), body: events(<chapter-body>), buttons: events(<ambrosia-navigation-buttons-region>),
           links: query(link).filter(it => type(it.dest) == location).map(it => (page: it.location().page(), target: it.dest.page())))
        }'''))
        if mode in ("handout", "notes", "article"):
            assert not data["segments"] and not data["regions"]
            continue
        assert len(pdf_pages(path)) == 7
        active = {e["page"]: e for e in data["segments"] if e["active"]}
        assert 1 not in active
        assert active[2]["progress"] == active[3]["progress"] == .5
        assert active[4]["progress"] == 1 and active[5]["progress"] == .5
        assert active[7]["progress"] == 1 and active[7]["total"] == 1
        assert all(e["target"] >= 7 for e in data["segments"] if e["page"] == 7)
        assert all({"page": e["page"], "target": e["target"]} in data["links"] for e in data["segments"])
        assert not any(r["page"] == 6 for r in data["regions"])
        body = {e["id"]: e for e in data["body"]}
        assert abs(body["disabled"]["height"] - body["next"]["height"] - 1.35 * size) < .02
        if placement == "footer":
            for accessory in data["accessories"]:
                rail = next((r for r in data["regions"] if r["page"] == accessory["page"]), None)
                if rail is not None:
                    assert accessory["y"] + accessory["height"] <= rail["y"] + .01, (accessory, rail)
            for rail in data["regions"]:
                buttons = next((b for b in data["buttons"] if b["page"] == rail["page"]), None)
                if buttons is not None:
                    assert (buttons["y"] + buttons["height"] < rail["y"] or
                            rail["y"] + rail["height"] < buttons["y"]), (flavor, buttons, rail)
        if mode == "second-screen":
            bbox = subprocess.check_output(["pdftotext", "-bbox", str(path), "-"], text=True)
            page = next(e for e in ET.fromstring(bbox).iter() if e.tag.endswith("page"))
            width, height = float(page.attrib["width"]), float(page.attrib["height"])
            for rail in data["regions"]:
                if side == "right": assert rail["x"] + rail["width"] < width / 2
                if side == "left": assert rail["x"] > width / 2
                if side == "bottom": assert rail["y"] + rail["height"] < height / 2
                if side == "top": assert rail["y"] > height / 2
    for flavor in FLAVORS:
        options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", "navigation=segments")
        data = json.loads(typst("eval", *options, "--in", "tests/navigation-combinations.typ", "--format", "json", '''{
          (windows: query(<ambrosia-segment-window>).map(it=>it.value),
           segments: query(<ambrosia-segment-entry>).map(it=>(page:it.location().page(),..it.value)))
        }'''))
        assert all(e["omitted"] > 0 for e in data["windows"][:-1])
        assert all(sum(e["active"] for e in data["segments"] if e["page"] == page) == 1 for page in range(1, 13))
    print("PASS segmented navigation: header/footer, links and progress, animation/appendix scopes, omitted sections, restored space, buttons/logos, text sizes and notes output")


def assert_panes(output):
    for palette in ("ocean", "midnight"):
        options = ("--root", ROOT, "--input", f"palette={palette}")
        source = "tests/navigation-panes.typ"
        path = output / f"panes-{palette}.pdf"
        typst("compile", *options, source, path)
        assert len(pdf_pages(path)) == 18
        data = json.loads(typst("eval", *options, "--in", source, "--format", "json", '''{
          let events(sel) = query(sel).map(it => (page: it.location().page(), y: it.location().position().y.pt(), ..it.value));
          (entries: events(<ambrosia-pane-entry>), windows: events(<ambrosia-pane-window>), body: events(<pane-body>),
           links: query(link).filter(it=>type(it.dest)==location).map(it=>(page:it.location().page(),target:it.dest.page())))
        }'''))
        assert all({"page": e["page"], "target": e["target"]} in data["links"] for e in data["entries"])
        active = {e["page"]: e["target"] for e in data["entries"] if e["pane"] == "subsections" and e["active"]}
        assert active[1] == active[2] == 1 and active[3] == 3
        assert all(e["omitted"] > 0 and 1 <= e["shown"] <= 3 for e in data["windows"] if e["pane"] == "subsections" and e["page"] <= 14)
        assert not any(e["page"] == 15 for e in data["windows"])
        assert all(e["target"] >= 18 for e in data["entries"] if e["page"] == 18)
        assert all(e["total"] == 0 for e in data["windows"] if e["page"] == 17 and e["pane"] == "subsections")
        by_id = {b["id"]: b for b in data["body"]}
        assert abs(by_id["disabled"]["height"] - by_id["normal"]["height"] - 2.7 * 18) < .02
    for retired in ("sections", "chapters", "split"):
        try:
            typst("compile", "--root", ROOT, "--input", f"navigation={retired}", "tests/navigation-combinations.typ", output / "retired-navigation.pdf")
        except RuntimeError as error:
            assert "Unknown navigation" in str(error)
        else:
            raise AssertionError(f"Retired navigation name {retired} must not silently select a different hierarchy.")
    print("PASS two-pane navigation: independent windows, subsection scope, links, active frames, empty sections, appendix, released space and retired names")


def assert_navigation_footer_contract(output):
    for footer in ("hidden", "managed"):
        for placement in ("footer", "header"):
            options = ("--root", ROOT, "--input", f"footer={footer}", "--input", f"placement={placement}")
            try:
                typst("compile", *options, "tests/navigation-segments.typ", output / f"chapter-contract-{footer}-{placement}.pdf")
            except RuntimeError as error:
                assert (footer, placement) == ("hidden", "footer") and "Footer navigation needs" in str(error), str(error)
            else:
                assert (footer, placement) != ("hidden", "footer"), "A hidden footer must not silently swallow navigation."
                segments = json.loads(typst("eval", *options, "--in", "tests/navigation-segments.typ", "--format", "json",
                                           "query(<ambrosia-segment-entry>).map(it=>it.value)"))
                assert any(s["active"] and s["progress"] == .5 for s in segments)
    print("PASS footer navigation ownership: useful hidden-footer diagnostic, header alternative and managed custom footer")


def assert_navigation_examples(output):
    # Branded helpers and authoring functions must use the same package identity.
    for flavor, choice in (("minimal", "segments"), ("cambridge", "dots"), ("cambridge", "panes"), ("darmstadt", "segments"), ("portico", "auto"), ("stargazer", "tabs")):
        options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"navigation={choice}")
        typst("compile", *options, "examples/navigation.typ", output / f"example-navigation-{flavor}-{choice}.pdf")
        if choice == "segments":
            segments = json.loads(typst("eval", *options, "--in", "examples/navigation.typ", "--format", "json",
                                      "query(<ambrosia-segment-entry>).len()"))
            assert segments > 0, "The installed example must paint section segments."
        if choice == "panes":
            entries = json.loads(typst("eval", *options, "--in", "examples/navigation.typ", "--format", "json",
                                     'query(<ambrosia-pane-entry>).filter(it=>it.value.pane=="subsections").len()'))
            assert entries > 0, "Cambridge's example must include subsection choices."
    typst("compile", "--root", ROOT, "examples/collaboration.typ", output / "example-collaboration.pdf")
    print("PASS installed branded examples: segments, Cambridge/dots, panes, sidebar, tabs, and collaboration")


def assert_slide_previews(output):
    source = ROOT / "examples/slide-previews.typ"
    expression = '{\n      (previews: query(<ambrosia-slide-preview>).map(it => (page: it.location().page(), ..it.value)),\n       bibliographies: query(bibliography).len(), headings: query(heading.where(outlined: true)).len(),\n       slides: query(<touying-metadata>).filter(it => it.value.at("kind", default: none) == "touying-new-slide").len(),\n       links: query(link).filter(it => type(it.dest) == dictionary and "page" in it.dest).map(it => (page: it.location().page(), target: it.dest.page)))\n    }'
    def observations(enabled):
        return json.loads(typst("eval", "--root", ROOT, "--input", f"slide-previews={str(enabled).lower()}",
                               "--input", "slide-preview-directory=../target/slide-previews", "--in", source, "--format", "json", expression))
    before = observations(False)
    assert [p["target"] for p in before["previews"]] == [2, 4]
    assert all(p["placeholder"] for p in before["previews"])
    command = [sys.executable, ROOT / "scripts/render-slide-previews.py", source, "--root", ROOT]
    if PACKAGE_PATH is not None:
        command += ["--package-path", PACKAGE_PATH]
    subprocess.run(list(map(str, command)), check=True, capture_output=True, text=True)
    manifest = json.loads((ROOT / "target/slide-previews/manifest.json").read_text())
    assert len(manifest["files"]) == 2
    for name in manifest["files"].values():
        assert (ROOT / "target/slide-previews" / name).read_text().lstrip().startswith("<svg")
    after = observations(True)
    assert [p["target"] for p in after["previews"]] == [2, 4]
    assert not any(p["placeholder"] for p in after["previews"])
    for key in ("bibliographies", "headings", "slides"):
        assert before[key] == after[key], (key, before[key], after[key])
    assert after["bibliographies"] == 1 and after["headings"] == 4 and after["slides"] == 3
    assert all({"page": p["page"], "target": p["target"]} in after["links"] for p in after["previews"])
    path = output / "slide-previews.pdf"
    typst("compile", "--root", ROOT, "--input", "slide-previews=true",
          "--input", "slide-preview-directory=../target/slide-previews", source, path)
    assert len(pdf_pages(path)) == 4
    # The example must also show real images with no inputs or export step.
    bundled = json.loads(typst("eval", "--root", ROOT, "--in", source, "--format", "json", expression))
    assert not any(p["placeholder"] for p in bundled["previews"])
    typst("compile", "--root", ROOT, source, output / "slide-previews-bundled.pdf")
    # Inspect rendered SVG output too: metadata alone cannot prove an image painted.
    rendered = output / "slide-previews-rendered.svg"
    typst("compile", "--root", ROOT, "--format", "svg", "--pages", "3", source, rendered)
    assert rendered.read_text().count("<image ") >= 2, "Both embedded SVG thumbnails must paint."
    integer = json.loads(typst("eval", "--root", ROOT, "--in", "tests/slide-previews.typ", "--format", "json",
                               "query(<ambrosia-slide-preview>).map(it => it.value)"))
    assert integer[0]["target"] == 2
    for case, message in (("missing", "target was not found"), ("out-of-range", "exceeds the target slide")):
        try:
            typst("compile", "--root", ROOT, "--input", f"case={case}", "tests/slide-previews.typ", output / f"slide-preview-{case}.pdf")
        except RuntimeError as error:
            assert message in str(error), str(error)
        else:
            raise AssertionError(f"Slide preview {case} should fail with a useful diagnostic.")
    print("PASS exact SVG slide previews: forward/back links, last animation frame, preserved bibliography/headings/slide counts, placeholders and native PDF destinations")

def assert_tree_navigation(output):
    cases = [(depth, height, palette, 'slides', 'right')
             for depth in (1, 2) for height in ('auto', 'tall') for palette in ('ocean', 'midnight')]
    cases += [(2, 'auto', 'ocean', mode, 'right') for mode in ('handout', 'notes', 'article')]
    cases += [(2, 'auto', 'midnight', 'second-screen', side) for side in ('left', 'right', 'top', 'bottom')]
    for depth, height, palette, mode, side in cases:
        options = ('--root', ROOT, '--input', f'depth={depth}', '--input', f'height={height}',
                   '--input', f'palette={palette}', '--input', f'mode={mode}', '--input', f'notes-side={side}')
        source = 'tests/tree-navigation.typ'
        path = output / f'tree-{depth}-{height}-{palette}-{mode}-{side}.pdf'
        typst('compile', *options, source, path)
        data = json.loads(typst('eval', *options, '--in', source, '--format', 'json', '''{
          import "src/palettes.typ" as palettes;
          let events(sel) = query(sel).map(it => (page: it.location().page(),
            x: it.location().position().x.pt(), y: it.location().position().y.pt(), ..it.value));
          (regions: events(<ambrosia-tree-region>), body: events(<tree-test-body>),
           entries: query(<ambrosia-tree-entry>).map(it => (page: it.location().page(), ..it.value,
             contrast: palettes.contrast(it.value.fill, it.value.ink))), headers: events(<ambrosia-header-region>),
           links: query(link).filter(it => type(it.dest) == location).map(it => (page: it.location().page(), target: it.dest.page())))
        }'''))
        label = (depth, height, palette, mode, side)
        if mode in ('handout', 'notes', 'article'):
            assert not data['entries'] and not data['regions'], label
            continue
        assert len(pdf_pages(path)) == 6, label
        assert len(data['entries']) == 5 * (depth + 1), (label, data['entries'])
        assert not any(e['page'] == 4 for e in data['entries']), label
        assert all(e['contrast'] >= 4.5 for e in data['entries']), label
        assert all({'page': e['page'], 'target': e['target']} in data['links']
                   for e in data['entries'] if e['target'] is not None), label
        assert all(e['target'] is None for e in data['entries'] if e['page'] == 1 and e['level'] > 0)
        assert all(e['target'] >= 6 for e in data['entries'] if e['page'] == 6), label
        if depth == 2:
            initial = next(e for e in data['entries'] if e['page'] == 2 and e['level'] == 2)
            revealed = next(e for e in data['entries'] if e['page'] == 3 and e['level'] == 2)
            empty = next(e for e in data['entries'] if e['page'] == 5 and e['level'] == 2)
            assert 'Initial Context' in str(initial['body']) and 'Revealed Context' in str(revealed['body'])
            assert empty['target'] is None and empty['body'] is None
        expected_height = 54 if height == 'tall' else (depth + 1) * .75 * 18
        for region in data['regions']:
            assert abs(region['height'] - expected_height) < .01, (label, region)
        for body in data['body']:
            header = next(h for h in data['headers'] if h['page'] == body['page'])
            assert header['y'] + header['height'] < body['y'], (label, header, body)
            expected_y = 473.56 if mode == 'second-screen' and side == 'top' else 0
            assert abs(header['y'] - expected_y) < .01, (label, header)
        if mode == 'slides':
            normal = next(b for b in data['body'] if b['id'] == 'empty')
            hidden = next(b for b in data['body'] if b['id'] == 'disabled')
            assert abs(normal['y'] - hidden['y'] - expected_height) < .01, (label, normal, hidden)
    print('PASS tree navigation: two/three rows, explicit heights, bounded long labels, links, reveal visibility, empty branches, restored margins, appendix and notes modes')


def assert_credit_cards(output):
    palettes = ('light', 'ocean', 'forest', 'sand', 'rose', 'slate', 'nocturne', 'midnight', 'evergreen', 'ember', 'nebula', 'graphite')
    for palette in palettes:
        options = ('--root', ROOT, '--input', f'palette={palette}')
        source = 'tests/credits.typ'
        path = output / f'credits-{palette}.pdf'
        typst('compile', *options, source, path)
        data = json.loads(typst('eval', *options, '--in', source, '--format', 'json', '''{
          let events(sel) = query(sel).map(it => (page: it.location().page(), ..it.value));
          (cards: events(<ambrosia-credit-card>), qr: events(<ambrosia-credit-qr>), logos: events(<ambrosia-credit-logo>),
           links: query(link).filter(it => type(it.dest) == str).map(it => (page: it.location().page(), target: it.dest)))
        }'''))
        assert len(pdf_pages(path)) == 4, (palette, data)
        assert [c['qr'] for c in data['cards']] == [True, False, False, True], (palette, data)
        assert data['cards'][0]['name'] == 'touying-ambrosia'
        assert data['cards'][2]['url'] == 'https://example.org/theme'
        assert [q['page'] for q in data['qr']] == [1, 4], data
        assert all(abs(q['width'] - 81) < .01 and abs(q['height'] - 81) < .01 for q in data['qr']), data
        assert all({'page': c['page'], 'target': c['url']} in data['links'] for c in data['cards']), data
        assert [logo['page'] for logo in data['logos']] == [1, 2, 4], data
    print('PASS opt-in credit cards: twelve palettes, native links, bundled/custom/hidden QR, sized QR artwork, custom identity, scoped API and closing-slide composition')


def assert_info_configuration(output):
    typst("compile", "--root", ROOT, "tests/config-info.typ", output / "config-info.pdf")
    markers = json.loads(typst("eval", "--root", ROOT, "--in", "tests/config-info.typ", "--format", "json",
        'query(<ambrosia-institution>).map(it => (id: it.value.id, marker: it.value.marker))'))
    assert markers == [{"id": "lab", "marker": "*"}, {"id": "partner", "marker": "†"}], markers
    pages = pdf_pages(output / "config-info.pdf")
    assert len(pages) == 2
    assert all(name in pages[0] for name in ("First Collaborator", "Second Collaborator", "Partner Institute"))
    try:
        typst("eval", "--root", ROOT, '{ import "src/lib.typ": ambrosia; ambrosia.config-info([Unexpected]) }')
    except RuntimeError as error:
        assert "Unexpected positional arguments" in str(error), error
    else:
        raise AssertionError("config-info must reject positional arguments like Touying.")
    print("PASS metadata configuration: sparse merging, explicit none/auto, collaborators, emails, symbol markers and positional rejection")


def assert_appendix_numbering(output):
    compact = lambda value: "".join(value.split())
    for pattern, total, expected in (
        ("i", False, ("i", "ii")), ("i", True, ("i / ii", "ii / ii")),
        ("1", False, ("1", "2")), ("1", True, ("1 / 2", "2 / 2")),
        ("S1", False, ("S1", "S2")), ("S1", True, ("S1 / S2", "S2 / S2")),
        ("A", False, ("A", "B")), ("custom", False, ("Extra 1", "Extra 2")),
        ("custom", True, ("Extra 1 of 2", "Extra 2 of 2")),
        ("none", False, ("", "")), ("none", True, ("", "")),
    ):
        path = output / f"appendix-count-{pattern}-{total}.pdf"
        options = ("--root", ROOT, "--input", f"numbering={pattern}", "--input", f"total={str(total).lower()}")
        typst("compile", *options, "tests/appendix-numbering.typ", path)
        pages = pdf_pages(path)
        assert len(pages) == 6, (pattern, total, len(pages))
        lines = [[line.strip() for line in page.splitlines() if line.strip()] for page in pages]
        assert compact(lines[0][-1]) == "1/2" and compact(lines[1][-1]) == "2/2", (pattern, total, lines[:2])
        for index, number in ((2, expected[0]), (3, expected[0]), (4, expected[1]), (5, expected[1])):
            if number:
                assert compact(lines[index][-1]) == compact(number), (pattern, total, index, lines[index])
            else:
                assert any(lines[index][-1].endswith(text) for text in ("Appendix body.", "Another animation frame.", "Retains the previous number.")), (pattern, total, index, lines[index])
    for mode, expected in (("handout", ("1 / 2", "2 / 2", "i", "ii", "ii")),
                           ("local", ("1 / 2", "2 / 2", "i", "i", "S2 / S2", "ii")),
                           ("continuous", ("1 / 4", "2 / 4", "3 / 4", "3 / 4", "4 / 4", "4 / 4"))):
        path = output / f"appendix-count-{mode}.pdf"
        typst("compile", "--root", ROOT, "--input", f"mode={mode}", "tests/appendix-numbering.typ", path)
        lines = [[line.strip() for line in page.splitlines() if line.strip()] for page in pdf_pages(path)]
        assert tuple(compact(page[-1]) for page in lines) == tuple(map(compact, expected)), (mode, lines)
    try:
        typst("compile", "--root", ROOT, "--input", "numbering=invalid", "tests/appendix-numbering.typ", output / "invalid-appendix-count.pdf")
    except RuntimeError as error:
        assert "Appendix numbering must be" in str(error), error
    else:
        raise AssertionError("Invalid appendix numbering must fail clearly.")
    print("PASS appendix numbering: patterns/functions/hidden, appendix-only totals, animations, uncounted backups, handouts and continuous footer override")


def assert_outline_fill(output):
    import re
    for style in ("list", "cards", "path"):
        for fill in ("none", "dots"):
            options = ("--root", ROOT, "--input", f"style={style}", "--input", f"fill={fill}")
            path = output / f"outline-fill-{style}-{fill}.pdf"
            typst("compile", *options, "tests/outline-fill.typ", path)
            pages = pdf_pages(path)
            assert len(pages) == 5, (style, fill, len(pages))
            assert bool(re.search(r"\.{4,}", pages[0])) == (fill == "dots"), (style, fill)
            assert not re.search(r"\.{4,}", pages[1]), (style, fill)
            assert "––––" in pages[2], (style, fill)
            assert bool(re.search(r"\.{4,}", pages[4])) == (fill == "dots"), (style, fill)
            fit = json.loads(typst("eval", *options, "--in", "tests/outline-fill.typ", "--format", "json",
                'query(<ambrosia-agenda-fit>).map(it => it.value)'))
            assert len(fit) == 4 and all(e["height"] <= e["available"] + .01 for e in fit)
    print("PASS outline leaders: theme defaults and local overrides, wrapped labels, list/cards/path, fitted sections and unchanged page counts")


def main():
    global PACKAGE_PATH
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--record-baseline", type=Path, help="Save rendered-page hashes for this checkout.")
    parser.add_argument("--compare-baseline", type=Path, help="Require identical renders and semantic observations.")
    args = parser.parse_args()
    output = ROOT / "target/tests"
    output.mkdir(parents=True, exist_ok=True)
    dependency_data = output / "dependencies"
    subprocess.run([sys.executable, str(ROOT / "scripts/install.py"), "--namespace", "preview",
                    "--data-dir", str(dependency_data), "--reinstall"],
                   check=True, capture_output=True, text=True)
    PACKAGE_PATH = dependency_data / "typst/packages"
    typst("compile", "--root", ROOT, "tests/unit.typ", output / "unit.pdf")
    assert_info_configuration(output)
    assert_appendix_numbering(output)
    assert_outline_fill(output)
    typst("compile", "--root", ROOT, "tests/defaults.typ", output / "defaults.pdf")
    try:
        typst("compile", "--root", ROOT, "tests/invalid-flavor.typ", output / "invalid-flavor.pdf")
    except RuntimeError as error:
        assert "Flavor 'not-a-flavor' is not supported" in str(error), error
    else:
        raise AssertionError("An unsupported flavor must fail before a title slide is created.")
    try:
        typst("compile", "--root", ROOT, "tests/invalid-palette.typ", output / "invalid-palette.pdf")
    except RuntimeError as error:
        assert "Palette 'not-a-palette' is not supported" in str(error), error
    else:
        raise AssertionError("An unsupported palette must fail before a title slide is created.")
    snapshots = {}
    palettes = json.loads(typst("eval", "--root", ROOT, "--format", "json",
                                '{ import "src/palettes.typ": palette-names; palette-names }'))
    cases = [(name, palette, "en", None) for name in FLAVORS for palette in palettes]
    cases += [("simple", "light", "fr", None)]
    for flavor, palette, lang, team in cases:
        name = f"{flavor}-{palette}-{lang}" + (f"-{team}" if team else "")
        options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"palette={palette}", "--input", f"lang={lang}")
        if team:
            options += ("--input", f"team={team}")
        typst("compile", *options, "tests/slides.typ", output / f"{name}.pdf")
        events = json.loads(typst("eval", *options, "--format", "json", "--in", "tests/slides.typ",
                                  "query(<ambrosia-test>).map(it => it.value)"))
        assert_appendix(events)
        text = "\n".join(pdf_pages(output / f"{name}.pdf"))
        assert "Appendix body must remain visible" in text and "Another appendix body" in text
        assert "Section introduction stays on its section slide" in text
        snapshots[name] = {"events": events}
        if args.record_baseline or args.compare_baseline:
            pages = output / name
            pages.mkdir(exist_ok=True)
            for previous in pages.glob("*.png"):
                previous.unlink()
            typst("compile", *options, "--ppi", "72", "tests/slides.typ", pages / "page-{0p}.png")
            snapshots[name]["renders"] = {
                path.name: hashlib.sha256(path.read_bytes()).hexdigest()
                for path in sorted(pages.glob("*.png"))
            }
        print(f"PASS {name}: animations, appendix bodies and counters")
    if args.record_baseline:
        args.record_baseline.parent.mkdir(parents=True, exist_ok=True)
        args.record_baseline.write_text(json.dumps(snapshots, indent=2) + "\n")
    if args.compare_baseline:
        baseline = json.loads(args.compare_baseline.read_text())
        for name, snapshot in snapshots.items():
            assert snapshot == baseline[name], f"Visual or semantic regression in {name}."
        print("PASS all rendered pages match the baseline")
    assert_installed_template(output)
    assert_title_fitting(output)
    assert_title_layouts(output)
    assert_bookends(output)
    assert_branding(output)
    assert_text_styles(output, palettes)
    assert_tabbed_blocks(output)
    assert_typography(output)
    assert_utilities(output)
    assert_new_utilities(output, palettes)
    assert_sankey_recipe(output)
    assert_image_captions(output)
    assert_agenda_styles(output)
    assert_agendas_people_watermarks(output)
    assert_panel_shadows_and_footer_labels(output)
    assert_extensions(output)
    assert_palette_people_bibliography(output)
    assert_native_cites_and_navigation(output)
    assert_footer_logo_space(output)
    assert_footer_accessories(output)
    assert_gallery_views(output)
    assert_roadmaps(output)
    assert_structural_navigation(output)
    assert_sidebar_background(output)
    assert_navigation_combinations(output)
    assert_segment_navigation(output)
    assert_panes(output)
    assert_navigation_footer_contract(output)
    assert_navigation_examples(output)
    assert_tree_navigation(output)
    assert_credit_cards(output)
    assert_slide_previews(output)
    print("All tests passed.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, AssertionError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
