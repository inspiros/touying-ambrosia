#!/usr/bin/env python3
"""Build the public mdBook from the Markdown guides and real Typst examples."""
import argparse
import hashlib
import html
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
import tomllib
from urllib.parse import quote, unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
SITE = DOCS / "site"
STAGED = ROOT / "target/book-source"
BOOK = ROOT / "target/book"
CACHE = ROOT / "target/site-render"
REPOSITORY = "https://github.com/inspiros/touying-ambrosia"
EXAMPLE = re.compile(r"<!-- ambrosia-example: ([a-z0-9-]+) -->.*?<!-- /ambrosia-example -->", re.S)


def write_changed(path, data):
    data = data.encode() if isinstance(data, str) else data
    if not path.exists() or path.read_bytes() != data:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)


def command(*args):
    result = subprocess.run(list(map(str, args)), cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    return result.stdout.strip()


def excerpt(source):
    match = re.search(r"^// ANCHOR: example\n(.*?)^// ANCHOR_END: example\s*$", source, re.M | re.S)
    if not match:
        raise ValueError("Each website example needs exactly one example anchor pair.")
    if source.count("// ANCHOR: example") != 1 or source.count("// ANCHOR_END: example") != 1:
        raise ValueError("Ambiguous example anchors.")
    return match[1].strip() + "\n"


def digest(paths):
    value = hashlib.sha256()
    for path in sorted(paths):
        value.update(str(path.relative_to(ROOT)).encode())
        value.update(path.read_bytes())
    return value.hexdigest()


def render_examples(examples):
    packages = ROOT / "target/site-packages"
    command("python3", ROOT / "scripts/install.py", "--namespace", "preview", "--link",
            "--data-dir", packages, "--reinstall")
    runtime = [ROOT / "typst.toml", *(ROOT / "src").rglob("*")]
    runtime += [p for p in (ROOT / "assets").rglob("*")
                if not any(part in ("gallery", "samples", "slide-previews") for part in p.parts)
                and p.name not in ("thumbnail.svg", "template-thumbnail.png", "kyklo.webp")]
    runtime += list((SITE / "examples").rglob("*"))
    fingerprint = digest([p for p in runtime if p.is_file()]) + command("typst", "--version")
    CACHE.mkdir(parents=True, exist_ok=True)
    for name, example in examples.items():
        source = SITE / "examples" / example["source"]
        excerpt(source.read_text())
        key = hashlib.sha256((fingerprint + json.dumps(example, sort_keys=True)).encode()).hexdigest()
        image, stamp = CACHE / f"{name}.png", CACHE / f"{name}.sha256"
        if not image.exists() or not stamp.exists() or stamp.read_text() != key:
            image.unlink(missing_ok=True)
            command("typst", "compile", "--root", ROOT, "--package-path", packages / "typst/packages",
                    "--jobs", "1", "--pages", example["page"], "--ppi", "144", source, image)
            if not image.is_file():
                raise RuntimeError(f"Example {name} did not produce page {example['page']}.")
            stamp.write_text(key)
            print(f"Rendered {name}", flush=True)


def example_html(name, example):
    source = excerpt((SITE / "examples" / example["source"]).read_text())
    code = html.escape(source).replace("\n", "&#10;")
    resources = "".join(f' · <a href="examples/{html.escape(file)}" download>{html.escape(file)}</a>'
                        for file in example.get("resources", []))
    caption = html.escape(example.get("caption", ""))
    return f'''
<section class="ambrosia-example" id="example-{name}" aria-label="Typst source and rendered output">
<div class="example-source">
<div class="example-label">Source <span>{html.escape(example['context'])}</span></div>
<pre><code class="nohighlight ambrosia-typst">{code}</code></pre>
<p class="example-downloads"><a href="examples/{example['source']}" download>Full Source</a>{resources}</p>
</div>
<figure class="example-output">
<div class="example-label">Output <button class="example-zoom" data-image="examples/{name}.png" type="button" aria-label="Enlarge output">Enlarge ⤢</button></div>
<a class="example-image" href="examples/{name}.png"><img src="examples/{name}.png"
  alt="{html.escape(example['alt'])}" width="1684" height="947" loading="lazy"></a>
<figcaption>{caption}</figcaption>
</figure>
</section>
'''


def stage_sources():
    package = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    version = package["version"]
    ref = f"v{version}"
    summary = (DOCS / "SUMMARY.md").read_text()
    chapters = set(re.findall(r"\]\(([^)]+\.md)\)", summary))
    assert chapters and all(not p.startswith(("maintainers/", "site/")) for p in chapters)
    examples = tomllib.loads((SITE / "examples.toml").read_text())
    used = set()
    for chapter in chapters:
        used.update(EXAMPLE.findall((DOCS / chapter).read_text()))
    assert used == set(examples), ("Missing or unused example definitions", used ^ set(examples))
    render_examples(examples)
    files = {"SUMMARY.md": summary.encode()}
    for variant in ("touying-ambrosia.svg", "touying-ambrosia-dark.svg"):
        files[f"assets/logos/{variant}"] = (ROOT / "assets/logos" / variant).read_bytes()

    def link(url, chapter, image=False):
        parts = urlsplit(html.unescape(url))
        if parts.scheme or parts.netloc or not parts.path:
            return url
        target = ((DOCS / chapter).parent / unquote(parts.path)).resolve()
        if not target.is_relative_to(ROOT) or not target.exists():
            raise ValueError(f"Missing local link in {chapter}: {url}")
        relative = target.relative_to(DOCS).as_posix() if target.is_relative_to(DOCS) else None
        suffix = ("?" + parts.query if parts.query else "") + ("#" + parts.fragment if parts.fragment else "")
        if relative in chapters:
            return relative + suffix
        if image:
            asset = target.relative_to(ROOT).as_posix()
            files[asset] = target.read_bytes()
            return quote(asset, safe="/") + suffix
        path = target.relative_to(ROOT).as_posix()
        return f"{REPOSITORY}/blob/{ref}/{quote(path, safe='/')}" + suffix

    for chapter in sorted(chapters):
        text = (DOCS / chapter).read_text()
        # Rewrite only prose, not literal paths inside fenced code examples.
        pieces = re.split(r"(^```[^\n]*\n.*?^```[^\n]*$)", text, flags=re.M | re.S)
        for i in range(0, len(pieces), 2):
            text_part = pieces[i]
            text_part = re.sub(r"(!?\[[^\]\n]*\]\()([^\s)]+)(\))",
                lambda m: m[1] + link(m[2], chapter, image=m[1].startswith("!")) + m[3], text_part)
            text_part = re.sub(r'\b(src|srcset)="([^"]+)"',
                lambda m: m[1] + '="' + link(m[2], chapter, image=True) + '"', text_part)
            pieces[i] = text_part
        text = "".join(pieces)
        text = EXAMPLE.sub(lambda m: example_html(m[1], examples[m[1]]), text)
        # A single HTML line prevents blank Typst lines from ending an HTML block.
        # nohighlight defers Typst until our grammar has loaded after mdBook's JS.
        text = re.sub(r"^```typ(?:st)?\n(.*?)^```[ \t]*$",
            lambda m: '<pre><code class="nohighlight ambrosia-typst">'
                + html.escape(m[1]).replace("\n", "&#10;") + '</code></pre>', text, flags=re.M | re.S)
        banner = f'<p class="docs-version">The Ambrosia Guide <span>/</span> {version} <a href="{REPOSITORY}/blob/{ref}/docs/manual.pdf">PDF Manual ↗</a></p>\n\n'
        files[chapter] = (banner + text).encode()
    for name, example in examples.items():
        files[f"examples/{name}.png"] = (CACHE / f"{name}.png").read_bytes()
        files[f"examples/{example['source']}"] = (SITE / "examples" / example["source"]).read_bytes()
        for resource in example.get("resources", []):
            files[f"examples/{resource}"] = (SITE / "examples" / resource).read_bytes()
    files["not-found.md"] = b'# Page Not Found\n\nReturn to the [guide](index.html) or use the search button.\n'
    STAGED.mkdir(parents=True, exist_ok=True)
    for path, data in files.items():
        write_changed(STAGED / path, data)
    for old in STAGED.rglob("*"):
        if old.is_file() and old.relative_to(STAGED).as_posix() not in files:
            old.unlink()
    print(f"Prepared {len(chapters)} public chapters and {len(examples)} compiled examples (API {version}).", flush=True)
    return version


class PageLinks(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids, self.links = set(), []
        self.codes, self.example, self.code = {}, None, None

    def handle_starttag(self, tag, attributes):
        attributes = dict(attributes)
        if "id" in attributes:
            self.ids.add(attributes["id"])
        if tag == "section" and attributes.get("id", "").startswith("example-"):
            self.example = attributes["id"].removeprefix("example-")
        if tag == "code" and self.example:
            self.code = self.example
            self.codes[self.code] = ""
        for key in ("href", "src", "srcset"):
            if attributes.get(key):
                self.links.append(attributes[key])

    def handle_endtag(self, tag):
        if tag == "code":
            self.code = None
        if tag == "section":
            self.example = None

    def handle_data(self, data):
        if self.code:
            self.codes[self.code] += data


def check_book():
    pages = {}
    for path in BOOK.rglob("*.html"):
        page = PageLinks()
        page.feed(path.read_text())
        pages[path.resolve()] = page
    errors = []
    for path, page in pages.items():
        for url in page.links:
            parts = urlsplit(url)
            if parts.scheme or parts.netloc:
                continue
            target = (path.parent / unquote(parts.path)).resolve() if parts.path else path
            if parts.path.startswith("/touying-ambrosia/"):
                target = (BOOK / unquote(parts.path).removeprefix("/touying-ambrosia/")).resolve()
            if target.is_dir():
                target /= "index.html"
            if not target.exists():
                errors.append(f"{path.name}: missing {url}")
            elif parts.fragment and target in pages and unquote(parts.fragment) not in pages[target].ids:
                errors.append(f"{path.name}: missing anchor {url}")
    if errors:
        raise ValueError("Broken website links:\n" + "\n".join(sorted(set(errors))))
    actual = {name: text for page in pages.values() for name, text in page.codes.items()}
    examples = tomllib.loads((SITE / "examples.toml").read_text())
    assert set(actual) == set(examples), "Missing code/output panels"
    for name, example in examples.items():
        expected = excerpt((SITE / "examples" / example["source"]).read_text())
        assert actual[name] == expected, f"Rendered code differs from compiled source: {name}"
    assert not (BOOK / "maintainers").exists()
    assert all('class="nohighlight ambrosia-typst' in (BOOK / file).read_text()
               for file in ("getting-started.html", "configuration.html", "utilities.html"))
    print(f"Validated local links, images, and anchors in {len(pages)} HTML pages.", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mdbook", default=os.environ.get("MDBOOK", "mdbook"), help="mdBook executable (tested with 0.5.4)")
    parser.add_argument("--serve", action="store_true", help="watch the original guides and serve with live reload")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--hostname", default="127.0.0.1")
    parser.add_argument("--pages", action="store_true", help="also prepare root and versioned GitHub Pages copies in target/site")
    args = parser.parse_args()
    if not shutil.which(args.mdbook):
        parser.error("Install mdBook 0.5.4: cargo install mdbook --version 0.5.4 --locked (or use --mdbook PATH).")
    version = stage_sources()
    # mdBook does not remove pages dropped from SUMMARY; avoid shipping stale chapters.
    if BOOK.exists():
        shutil.rmtree(BOOK)
    command(args.mdbook, "build", SITE)
    check_book()
    if args.pages:
        output = ROOT / "target/site"
        if output.exists():
            shutil.rmtree(output)
        shutil.copytree(BOOK, output)
        shutil.copytree(BOOK, output / f"v{version}")
        (output / ".nojekyll").touch()
        print(f"GitHub Pages artifact: {output} (also /v{version}/)", flush=True)
    if not args.serve:
        print(f"Website: {BOOK / 'index.html'}", flush=True)
        return
    print(f"Preview: http://{args.hostname}:{args.port}/ — edit docs/*.md or docs/site/; Ctrl+C stops.", flush=True)
    process = subprocess.Popen([args.mdbook, "serve", str(SITE), "--hostname", args.hostname, "--port", str(args.port)], cwd=ROOT)
    def sources():
        paths = [p for folder in (DOCS, ROOT / "src", ROOT / "assets") for p in folder.rglob("*") if p.is_file()]
        paths += [ROOT / "typst.toml", Path(__file__)]
        return tuple((str(p), p.stat().st_mtime_ns, p.stat().st_size) for p in sorted(paths))
    previous = sources()
    try:
        while process.poll() is None:
            time.sleep(0.7)
            current = sources()
            if current != previous:
                previous = current
                try:
                    stage_sources()
                except (RuntimeError, ValueError, AssertionError) as error:
                    print(f"Preview update failed: {error}", flush=True)
        if process.returncode:
            raise RuntimeError(f"mdBook server exited with status {process.returncode}.")
    except KeyboardInterrupt:
        process.terminate()
        process.wait()


if __name__ == "__main__":
    main()
