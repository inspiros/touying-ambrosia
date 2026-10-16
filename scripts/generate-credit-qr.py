#!/usr/bin/env python3
"""Regenerate a static credit QR SVG (development only; requires reportlab)."""
import argparse
from html import escape
from pathlib import Path
from reportlab.graphics.barcode.qrencoder import QRCode, QRErrorCorrectLevel

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='https://github.com/inspiros/touying-ambrosia')
    parser.add_argument('--output', type=Path, default=ROOT / 'assets/qr/repository.svg')
    args = parser.parse_args()
    qr = QRCode(None, QRErrorCorrectLevel.M)
    qr.addData(args.url)
    qr.make()
    # Keep the standard four-module white quiet zone, including on dark slides.
    quiet = 4
    size = len(qr.modules) + 2 * quiet
    path = ''.join(f'M{x + quiet} {y + quiet}h1v1h-1z'
                   for y, row in enumerate(qr.modules) for x, filled in enumerate(row) if filled)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}" shape-rendering="crispEdges">\n'
                          f'  <title>{escape(args.url)}</title>\n'
                          f'  <rect width="{size}" height="{size}" fill="#ffffff"/>\n'
                          f'  <path fill="#000000" d="{path}"/>\n</svg>\n')
    print(f'Generated {args.output}: {args.url}')


if __name__ == '__main__':
    main()
