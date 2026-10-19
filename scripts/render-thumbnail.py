#!/usr/bin/env python3
"""Render the SVG README hero and a WebP of the initialized template cover."""
import argparse
from pathlib import Path
import subprocess
import shutil
import tomllib
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "target/thumbnail"
VARIANTS = (
    ("midnight", "darmstadt", "midnight", "dots"),
    ("forest", "portico", "forest", "sidebar"),
    ("rose", "minimal", "rose", "none"),
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-path", type=Path,
                        help="optional isolated Typst package directory")
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)

    def compile(source, output, *options, document_root=ROOT):
        cmd = ["typst", "compile", "--root", str(document_root), "--jobs", "1", "--ppi", "144"]
        if args.package_path:
            cmd += ["--package-path", str(args.package_path.resolve())]
        subprocess.run([*cmd, *options, str(source), str(output)], cwd=ROOT, check=True)

    # Raster snapshots preserve every color space and keep the thumbnail source
    # instantly usable in an IDE. Full slides are rendered by the real theme.
    for name, flavor, palette, navigation in VARIANTS:
        render = OUTPUT / f"{name}.png"
        compile(ROOT / "examples/gallery.typ", render, "--pages", "1",
                "--input", "view=navigation", "--input", f"flavor={flavor}",
                "--input", f"palette={palette}", "--input", f"navigation={navigation}")
        with Image.open(render) as image:
            image.convert("RGB").save(ROOT / f"assets/gallery/thumbnail-{name}.webp", quality=94)
    compile(ROOT / "docs/maintainers/artwork/hero.typ", ROOT / "assets/thumbnail.svg")

    # Universe thumbnails must depict an initialized template page, not the hero.
    # Initialize it without changing any source or input parameters.
    metadata = tomllib.loads((ROOT / "typst.toml").read_text())
    package = metadata["package"]
    starter = OUTPUT / "starter"
    if starter.exists():
        shutil.rmtree(starter)
    command = ["typst", "init"]
    if args.package_path:
        command += ["--package-path", str(args.package_path.resolve())]
    subprocess.run([*command, f"@preview/{package['name']}:{package['version']}", str(starter)],
                   cwd=ROOT, check=True)
    cover = OUTPUT / "template-thumbnail.png"
    compile(starter / metadata["template"]["entrypoint"], cover, "--pages", "1", document_root=starter)
    # Universe accepts WebP; lossless keeps flat slide artwork exact and smaller.
    with Image.open(cover) as image:
        image.convert("RGB").save(ROOT / metadata["template"]["thumbnail"], lossless=True, method=6)
    print("Updated SVG README hero, three bundled slide renders, and initialized-template WebP.")


if __name__ == "__main__":
    main()
