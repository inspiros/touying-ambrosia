#!/usr/bin/env python3
"""Build orthogonal layout/palette comparisons and actual component previews."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import shutil
import subprocess
import sys
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "target/previews"
DATA = OUTPUT / "package-data"
PACKAGES = DATA / "typst/packages"
GALLERY = ROOT / "assets/gallery"
SOURCE = ROOT / "examples/gallery.typ"


def run(*args):
    if args[0] == "typst":
        args = (*args[:2], "--package-path", PACKAGES, *args[2:])
    return subprocess.run(list(map(str, args)), cwd=ROOT, check=True, capture_output=True, text=True).stdout


def webp(source, name):
    Image.open(source).convert("RGB").save(GALLERY / name, quality=92)


def comparison(paths, labels, name):
    """Equal-sized native slide renders; captions sit outside slide geometry."""
    width, caption, gap, margin = 900, 40, 18, 20
    with Image.open(paths[0]) as first:
        height = round(width * first.height / first.width)
    rows = (len(paths) + 1) // 2
    sheet = Image.new("RGB", (2 * width + gap + 2 * margin,
                              rows * (height + caption) + (rows - 1) * gap + 2 * margin), "#e9edf2")
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("DejaVuSans.ttf", 25)
    except OSError:
        font = ImageFont.load_default()
    for index, (path, label) in enumerate(zip(paths, labels, strict=True)):
        x = margin + (index % 2) * (width + gap)
        y = margin + (index // 2) * (height + caption + gap)
        if len(paths) % 2 and index == len(paths) - 1:
            x = margin + (width + gap) // 2
        draw.text((x, y + 2), label, font=font, fill="#263341")
        with Image.open(path) as slide:
            sheet.paste(slide.convert("RGB").resize((width, height), Image.Resampling.LANCZOS), (x, y + caption))
    sheet.save(GALLERY / name, quality=92)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--update-pdfs", action="store_true")
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    GALLERY.mkdir(parents=True, exist_ok=True)
    run(sys.executable, ROOT / "scripts/install.py", "--namespace", "preview", "--data-dir", DATA, "--reinstall")
    names = json.loads(run("typst", "eval", "--root", ROOT, "--format", "json",
                          '{ import "src/theme/flavors.typ": flavor-names; flavor-names }'))
    flavors = ["minimal", *[name for name in names if name != "minimal"]]
    jobs = [(view, flavor, "1", f"{view}-{flavor}", "auto", "right") for view in ("layout", "cover") for flavor in flavors]
    jobs += [("palettes", "minimal", "1", "palettes", "auto", "right")]
    components = ("blocks", "annotations", "citations", "people", "palette-component", "navigation-buttons", "roadmap", "credits")
    jobs += [(name, "minimal", "2" if name == "navigation-buttons" else "1", f"component-{name}", "auto", "right") for name in components]

    navigation_choices = [("none", "none", "right"), ("tabs", "tabs", "right"),
                          ("dots", "dots", "right"), ("context", "context", "right"), ("tree", "tree", "right"), ("panes", "panes", "right"),
                          ("breadcrumbs", "breadcrumbs", "right"), ("segments", "segments", "right"),
                          ("sidebar-left", "sidebar", "left"), ("sidebar-right", "sidebar", "right")]
    jobs += [("navigation", "minimal", "1", f"navigation-{name}", style, side)
             for name, style, side in navigation_choices]

    def render(job):
        view, flavor, page, name, navigation, side = job
        path = OUTPUT / f"{name}.png"
        run("typst", "compile", "--jobs", "1", "--root", ROOT, "--ppi", "144", "--pages", page,
            "--input", f"view={view}", "--input", f"flavor={flavor}",
            "--input", f"navigation={navigation}", "--input", f"side={side}", SOURCE, path)
        return name, path

    with ThreadPoolExecutor(max_workers=3) as pool:
        renders = dict(pool.map(render, jobs))
    for view in ("layout", "cover"):
        comparison([renders[f"{view}-{f}"] for f in flavors], [f.title() for f in flavors],
                   "layouts.webp" if view == "layout" else "covers.webp")
    title_layouts = json.loads(run("typst", "eval", "--root", ROOT, "--format", "json",
        '{import "src/title-layouts.typ": title-layout-names; title-layout-names}'))
    title_paths = []
    for layout in title_layouts:
        path = OUTPUT / f"title-layout-{layout}.png"
        run("typst", "compile", "--root", ROOT, "--ppi", "144", "--pages", "1",
            "--input", "view=title-layout", "--input", f"layout={layout}", SOURCE, path)
        title_paths.append(path)
    comparison(title_paths, [name.title() for name in title_layouts], "title-layouts.webp")
    ending_layouts = json.loads(run("typst", "eval", "--root", ROOT, "--format", "json",
        '{import "src/ending-layouts.typ": ending-layout-names; ending-layout-names}'))
    ending_paths = []
    for layout in ending_layouts:
        path = OUTPUT / f"ending-layout-{layout}.png"
        run("typst", "compile", "--root", ROOT, "--ppi", "144", "--pages", "1",
            "--input", "view=ending-layout", "--input", f"layout={layout}", SOURCE, path)
        ending_paths.append(path)
    comparison(ending_paths, [name.title() for name in ending_layouts], "ending-layouts.webp")
    comparison([renders[f"navigation-{name}"] for name, _, _ in navigation_choices],
               [name.replace("-", " ").title() for name, _, _ in navigation_choices], "navigation.webp")
    tree = OUTPUT / "navigation-tree.png"
    run("typst", "compile", "--jobs", "1", "--root", ROOT, "--ppi", "144", "--pages", "1",
        "--input", "view=navigation", "--input", "flavor=cambridge", "--input", "navigation=tree", SOURCE, tree)
    webp(tree, "navigation-tree.webp")
    agenda_paths = []
    agenda_labels = []
    for style in ("list", "cards", "path"):
        for page, label in (("1", "Overview"), ("5", "Section Transition")):
            path = OUTPUT / f"agenda-{style}-{page}.png"
            run("typst", "compile", "--jobs", "1", "--root", ROOT, "--ppi", "144", "--pages", page,
                "--input", f"style={style}", ROOT / "examples/agendas.typ", path)
            agenda_paths.append(path)
            agenda_labels.append(f"{style.title()} · {label}")
    comparison(agenda_paths, agenda_labels, "agendas.webp")
    image_paths = []
    for page in range(1, 5):
        path = OUTPUT / f"image-caption-{page}.png"
        run("typst", "compile", "--jobs", "1", "--root", ROOT, "--ppi", "144", "--pages", str(page),
            ROOT / "examples/image-slides.typ", path)
        image_paths.append(path)
    comparison(image_paths, ["Bottom Band", "Top Band", "Top Right Card", "Bottom Left Card"], "image-captions.webp")

    webp(renders["palettes"], "palettes.webp")
    for name in components:
        webp(renders[f"component-{name}"], f"component-{name}.webp")
    run(sys.executable, ROOT / "scripts/render-slide-previews.py", ROOT / "examples/slide-previews.typ",
        "--root", ROOT, "--package-path", PACKAGES, "--output-dir", ROOT / "assets/slide-previews")
    run("typst", "compile", "--root", ROOT, "--pages", "3", "--ppi", "144",
        "--input", "slide-previews=true", ROOT / "examples/slide-previews.typ", OUTPUT / "component-slide-preview.png")
    webp(OUTPUT / "component-slide-preview.png", "component-slide-preview.webp")
    run("typst", "compile", "--root", ROOT, "--ppi", "144", "--input", "view=slides", SOURCE, OUTPUT / "slide-type-{p}.png")
    comparison([OUTPUT / f"slide-type-{page}.png" for page in range(1, 7)],
               ["Title", "Outline", "Section", "Focus", "Image", "Ending"], "slide-types.webp")
    print("Updated flavor/title/navigation comparisons, palette cards, nine component previews, and slide helpers.", flush=True)
    # The thumbnail is purpose-built artwork; sample.typ stays a small real deck.
    run(sys.executable, ROOT / "scripts/render-thumbnail.py", "--package-path", PACKAGES)
    if args.update_pdfs:
        run("typst", "compile", "--root", ROOT, "examples/demo.typ", OUTPUT / "demo.pdf")
        shutil.copy2(OUTPUT / "demo.pdf", ROOT / "examples/demo.pdf")
        run("typst", "compile", "--root", ROOT, "--input", "slide-previews=true",
            "examples/slide-previews.typ", ROOT / "examples/slide-previews.pdf")
        run(sys.executable, ROOT / "scripts/render-manual.py", "--package-path", PACKAGES)
        starter = ROOT / "develop/previews/starter"
        shutil.copytree(ROOT / "template", starter, dirs_exist_ok=True)
        run("typst", "compile", "--root", starter, starter / "template.typ", OUTPUT / "template.pdf")
        # The starter check stays under target; don't scaffold a compiled PDF.


if __name__ == "__main__":
    main()
