#!/usr/bin/env python3
"""Opt-in checks for the Pergamon recipe; ordinary package tests do not import it."""
import argparse
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-path", type=Path)
    args = parser.parse_args()
    output = ROOT / "target/tests/publications"
    output.mkdir(parents=True, exist_ok=True)
    options = ["--root", str(ROOT), "--jobs", "1"]
    if args.package_path:
        options += ["--package-path", str(args.package_path.resolve())]
    example = output / "example.pdf"
    subprocess.run(["typst", "compile", *options, str(ROOT / "examples/publications.typ"), str(example)], check=True)
    pages = subprocess.check_output(["pdftotext", "-layout", str(example), "-"], text=True).rstrip("\f\n").split("\f")
    assert len(pages) == 2
    assert "An Unrelated Publication" not in "".join(pages)
    assert "Shared Benchmarks" in pages[0] and "Shared Benchmarks" not in pages[1]
    xml = ET.fromstring(subprocess.check_output(["pdftohtml", "-xml", "-hidden", "-i", "-stdout", str(example)]))
    for page, alex, initial in zip(xml.findall("page"), (2, 1), (1, 1), strict=True):
        bold = ["".join(node.itertext()) for node in page.findall(".//b")]
        assert bold.count("Alex Morgan") == alex and bold.count("A. Morgan") == initial, bold
        assert not any("Robin" in value or "Baseline" in value for value in bold), bold
    for palette in ("ocean", "midnight"):
        path = output / f"coexist-{palette}.pdf"
        subprocess.run(["typst", "compile", *options, "--input", f"palette={palette}",
                        str(ROOT / "tests/publications.typ"), str(path)], check=True)
        text = subprocess.check_output(["pdftotext", "-layout", str(path), "-"], text=True)
        pages = text.rstrip("\f\n").split("\f")
        assert len(pages) == 3
        assert "List revealed" not in pages[0] and "List revealed" in pages[1]
        assert "TeXbook" in pages[2] and "Knuth1984" in pages[2]
        assert "TeXbook" not in pages[0] + pages[1]
    assert not any("@preview/pergamon" in source.read_text() for source in (ROOT / "src").rglob("*.typ"))
    print("PASS optional publication recipe: structured identities, aliases, filtering, bold names only, native citations, animations and light/dark palettes")


if __name__ == "__main__":
    main()
