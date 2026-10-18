#!/usr/bin/env python3
"""Verify presenter-note exports without requiring a graphical pdfpc session."""
import argparse
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "examples/speaker-notes.typ"
NOTES = ("Explain the motivation", "Emphasize the result", "Ask which assumption")


def check_notes(data):
    assert data["pdfpcFormat"] == 2 and data["duration"] == 12, data
    pages = data["pages"]
    assert len(pages) == 3, pages
    assert [p["idx"] for p in pages] == [0, 1, 2]
    assert [p["label"] for p in pages] == ["1", "1", "2"]
    assert [p["overlay"] for p in pages] == [0, 1, 0]
    assert NOTES[0] in pages[0]["note"] and NOTES[1] not in pages[0]["note"]
    assert all(note in pages[1]["note"] for note in NOTES[:2])
    assert NOTES[2] in pages[2]["note"] and NOTES[0] not in pages[2]["note"]


def pdf_content(path):
    text = subprocess.check_output(["pdftotext", "-layout", str(path), "-"], text=True)
    pages = text.rstrip("\f\n").split("\f")
    assert len(pages) == 3, (path, len(pages))
    info = subprocess.check_output(["pdfinfo", str(path)], text=True)
    size = re.search(r"Page size:\s+([\d.]+) x ([\d.]+)", info)
    assert size, info
    return pages, tuple(map(float, size.groups()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-path", type=Path)
    parser.add_argument("--bundle", action="store_true", help="also verify experimental bundle output")
    args = parser.parse_args()
    output = ROOT / "target/tests/speaker-notes"
    output.mkdir(parents=True, exist_ok=True)
    options = ["--root", str(ROOT)]
    if args.package_path:
        options += ["--package-path", str(args.package_path.resolve())]
    sizes = {}
    for mode in ("audience", "split", "notes"):
        path = output / f"{mode}.pdf"
        inputs = ["--input", f"output={mode}"]
        subprocess.run(["typst", "compile", *options, *inputs, str(SOURCE), str(path)], check=True)
        pages, sizes[mode] = pdf_content(path)
        assert ("The evidence appears" in pages[0]) is False
        assert "The evidence appears" in pages[1]
        if mode == "audience":
            assert not any(note in "".join(pages) for note in NOTES)
        else:
            assert NOTES[0] in pages[0] and NOTES[1] not in pages[0]
            assert all(note in pages[1] for note in NOTES[:2])
            assert NOTES[2] in pages[2]
        data = json.loads(subprocess.check_output(["typst", "eval", *options, *inputs,
            "--in", str(SOURCE), "query(<pdfpc-file>).first().value"], text=True))
        check_notes(data)
        (output / f"{mode}.pdfpc").write_text(json.dumps(data, indent=2) + "\n")
    w, h = sizes["audience"]
    assert all(abs(x - y) < .02 for x, y in zip(sizes["notes"], (w, h)))
    assert all(abs(x - y) < .02 for x, y in zip(sizes["split"], (2 * w, h)))
    # A vertical split has the same semantics and a doubled page height.
    path = output / "bottom.pdf"
    subprocess.run(["typst", "compile", *options, "--input", "output=split", "--input", "notes-side=bottom",
                    str(SOURCE), str(path)], check=True)
    _, size = pdf_content(path)
    assert all(abs(x - y) < .02 for x, y in zip(size, (w, 2 * h)))
    if args.bundle:
        destination = output / "bundle"
        subprocess.run(["typst", "compile", *options, "--features", "bundle", "--format", "bundle",
                        "--input", "bundle=true", "--input", "output=audience", str(SOURCE), str(destination)], check=True)
        check_notes(json.loads((destination / "speaker-notes.pdfpc").read_text()))
        pages, size = pdf_content(destination / "speaker-notes.pdf")
        assert not any(note in "".join(pages) for note in NOTES)
        assert all(abs(x - y) < .02 for x, y in zip(size, (w, h)))
    print("PASS speaker notes: clean audience PDF, overlay-scoped sidecars, typeset split/notes-only pages and dimensions"
          + (", matching bundle exports" if args.bundle else ""))


if __name__ == "__main__":
    main()
