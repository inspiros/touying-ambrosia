#!/usr/bin/env python3
"""Run bounded release checks; tests/run.py retains the exhaustive matrix."""
import json
from pathlib import Path
import subprocess
import sys

import run as checks

ROOT = Path(__file__).resolve().parents[1]


def main():
    output = ROOT / "target/ci"
    output.mkdir(parents=True, exist_ok=True)
    data = output / "dependencies"
    subprocess.run([sys.executable, str(ROOT / "scripts/install.py"), "--namespace", "preview",
                    "--data-dir", str(data), "--reinstall"], check=True)
    checks.PACKAGE_PATH = data / "typst/packages"
    for fixture in ("unit", "defaults"):
        checks.typst("compile", "--root", ROOT, f"tests/{fixture}.typ", output / f"{fixture}.pdf")
    for flavor in checks.FLAVORS:
        for palette in ("light", "midnight"):
            options = ("--root", ROOT, "--input", f"flavor={flavor}", "--input", f"palette={palette}")
            name = f"{flavor}-{palette}"
            checks.typst("compile", *options, "tests/slides.typ", output / f"{name}.pdf")
            events = json.loads(checks.typst("eval", *options, "--in", "tests/slides.typ", "--format", "json",
                "query(<ambrosia-test>).map(it => it.value)"))
            checks.assert_appendix(events)
            text = "\n".join(checks.pdf_pages(output / f"{name}.pdf"))
            assert "Appendix body must remain visible" in text and "Another appendix body" in text
            print(f"PASS {name}: animations, visible appendix and logical counters", flush=True)
    for check in (checks.assert_info_configuration, checks.assert_appendix_numbering, checks.assert_outline_fill,
                  checks.assert_utilities, checks.assert_installed_template, checks.assert_extensions,
                  checks.assert_typography, checks.assert_sidebar_background, checks.assert_slide_previews):
        check(output)
    checks.assert_new_utilities(output, ("light", "midnight"))
    checks.assert_navigation_combinations(output, choices=("dots", "tree", "sidebar", "segments"))
    subprocess.run([sys.executable, str(ROOT / "tests/check_speaker_notes.py"), "--bundle",
                    "--package-path", str(checks.PACKAGE_PATH)], check=True)
    checks.typst("compile", "--root", ROOT, "docs/manual.typ", output / "manual.pdf")
    print("Bounded CI checks passed. Run tests/run.py for the exhaustive matrix.")


if __name__ == "__main__":
    main()
