#!/usr/bin/env python3
"""Compile the manual; optionally refresh its bundled slide snapshots first."""
import argparse
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh-previews", action="store_true",
                        help="rebuild bundled PNGs from docs/examples/slides.typ")
    parser.add_argument("--package-path", type=Path,
                        help="optional isolated Typst package directory")
    parser.add_argument("--output", type=Path, default=ROOT / "docs/manual.pdf")
    args = parser.parse_args()

    def compile(source, output, *options):
        output.parent.mkdir(parents=True, exist_ok=True)
        cmd = ["typst", "compile", "--root", str(ROOT), "--jobs", "1"]
        if args.package_path:
            cmd += ["--package-path", str(args.package_path.resolve())]
        subprocess.run([*cmd, *options, str(source), str(output)], cwd=ROOT, check=True)

    if args.refresh_previews:
        for view, page in (("start", 1), ("cover", 1), ("blocks", 2),
                           ("image", 1), ("roadmap", 1), ("navigation", 2)):
            compile(ROOT / "docs/examples/slides.typ", ROOT / f"docs/previews/{view}.png",
                    "--input", f"view={view}", "--pages", str(page), "--ppi", "144")
    compile(ROOT / "docs/manual.typ", args.output.resolve())
    print(f"Manual: {args.output.resolve()}")


if __name__ == "__main__":
    main()
