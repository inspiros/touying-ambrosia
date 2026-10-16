"""Exercise real local-package copying and exclusion behavior."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallTests(unittest.TestCase):
    def test_link_copy_roundtrip_preserves_checkout_and_updates_live(self):
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            source = temporary / "checkout"
            source.mkdir()
            (source / "typst.toml").write_text('[package]\nname = "test-theme"\nversion = "0.1.0"\n')
            marker = source / "sentinel"
            marker.write_text("original")
            command = [sys.executable, str(ROOT / "scripts/install.py"), "--root-dir", str(source),
                       "--data-dir", str(temporary / "data"), "--reinstall"]
            installed = temporary / "data/typst/packages/local/test-theme/0.1.0"
            for linked in (True, True, False, True, False):
                subprocess.run([*command, *(["--link"] if linked else [])], check=True, capture_output=True, text=True)
                self.assertEqual(installed.is_symlink(), linked)
                self.assertEqual(marker.read_text(), "original")
            subprocess.run([*command, "--link"], check=True, capture_output=True, text=True)
            marker.write_text("live change")
            self.assertEqual((installed / "sentinel").read_text(), "live change")
            installed.unlink()
            installed.symlink_to(temporary / "missing", target_is_directory=True)
            subprocess.run([*command, "--link"], check=True, capture_output=True, text=True)
            self.assertEqual(marker.read_text(), "live change")

    def test_manifest_paths_and_extra_patterns_are_excluded(self):
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            source = temporary / "checkout"
            source.mkdir()
            (source / "typst.toml").write_text('[package]\nname = "test-theme"\nversion = "0.1.0"\nexclude = ["assets/samples", "*.pdf"]\n[template]\nthumbnail = "assets/template-preview.png"\n')
            keep = ("src/lib.typ", "assets/logos/logo.svg", "template/template.typ")
            omit = ("assets/template-preview.png", "assets/samples/sample.webp", "template/template.pdf", "develop/probe.typ",
                    "target/render.png", ".git/config", ".aws/config", "notes.tmp")
            for filename in (*keep, *omit):
                path = source / filename
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("fixture")
            command = [sys.executable, str(ROOT / "scripts/install.py"), "--root-dir", str(source),
                       "--data-dir", str(temporary / "data"), "--exclude", "*.tmp"]
            subprocess.run(command, check=True, capture_output=True, text=True)
            installed = temporary / "data/typst/packages/local/test-theme/0.1.0"
            self.assertTrue(all((installed / filename).is_file() for filename in keep))
            self.assertTrue(all(not (installed / filename).exists() for filename in omit))
            duplicate = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(duplicate.returncode, 0)
            self.assertTrue((installed / "src/lib.typ").is_file())
            subprocess.run([*command, "--reinstall"], check=True, capture_output=True, text=True)
            self.assertTrue((installed / "src/lib.typ").is_file())
            recursive = subprocess.run([sys.executable, str(ROOT / "scripts/install.py"),
                                       "--root-dir", str(source), "--data-dir", str(source / "inside")],
                                      capture_output=True, text=True)
            self.assertNotEqual(recursive.returncode, 0)
            self.assertFalse((source / "inside").exists())


if __name__ == "__main__":
    unittest.main()
