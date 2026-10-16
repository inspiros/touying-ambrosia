#!/usr/bin/env python3
"""Export exact vector thumbnails requested by ambrosia-slide-preview components.

The source must honor --input slide-previews=false to disable reading thumbnail
assets during this pass. See examples/slide-previews.typ for an IDE-friendly setup.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--package-path", type=Path)
    parser.add_argument("--input", action="append", default=[])
    args = parser.parse_args()
    source, root = args.source.resolve(), args.root.resolve()
    output = (args.output_dir or root / "target/slide-previews").resolve()
    if not output.is_relative_to(root):
        parser.error("The output directory must be inside the Typst root so the source can import its previews.")
    options = ["--root", str(root)]
    if args.package_path:
        options += ["--package-path", str(args.package_path.resolve())]
    for value in args.input:
        options += ["--input", value]
    options += ["--input", "slide-previews=false"]

    def typst(command, *rest):
        result = subprocess.run(["typst", command, *options, *map(str, rest)], cwd=root,
                                capture_output=True, text=True)
        if result.returncode:
            raise RuntimeError(result.stderr.strip())
        if result.stderr:
            print(result.stderr, end="")
        return result.stdout

    requests = json.loads(typst("eval", "--in", source, "--format", "json",
                               "query(<ambrosia-slide-preview>).map(it => it.value)"))
    if not requests:
        parser.error("The source contains no slide-preview requests.")
    unique = {}
    for request in requests:
        key = request["key"]
        if key in unique and unique[key]["target"] != request["target"]:
            parser.error(f"Inconsistent slide-preview target for {key}.")
        unique[key] = request
    output.mkdir(parents=True, exist_ok=True)
    files = {}
    for key, request in unique.items():
        name = "slide-" + hashlib.sha256(key.encode()).hexdigest()[:16] + ".svg"
        typst("compile", "--format", "svg", "--pages", request["target"], source, output / name)
        files[key] = name
    manifest = output / "manifest.json"
    manifest.write_text(json.dumps({"source": str(source.relative_to(root)), "files": files}, indent=2) + "\n")
    print(f"Exported {len(files)} SVG slide previews; manifest: {manifest}")


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as error:
        raise SystemExit(str(error))
