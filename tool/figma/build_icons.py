#!/usr/bin/env python3
"""Build the app's icons from the Figma SVG exports.

Reads the SVGs in docs/figma/assets/export/ (made by `figma_pull.py export`):

* Single-color UI icons are rewritten as plain one-color SVGs in
  assets/icons/<name>.svg. Figma exports outlined strokes as a fill plus a
  masked stroke and wraps faded icons in an opacity group; flutter_svg can't
  draw the mask, and the app tints icons at runtime, so both are flattened.
* Brand icons keep their colors and Figma drop shadows (SVG filters, which
  flutter_svg ignores), so they are rasterized with rsvg-convert into
  assets/img/brand/{,2.0x/,3.0x/}<name>.webp on a common 55x55 pt canvas with
  the 23x23 pt glyph at (16, 8).

Usage: python3 tool/figma/build_icons.py   (needs rsvg-convert and Pillow)
"""
import os
import re
import subprocess
import tempfile

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXPORT = os.path.join(ROOT, "docs", "figma", "assets", "export")

MONO = ["ic_back", "ic_check", "ic_help", "ic_lock", "ic_mail", "ic_user"]

# name -> top-left of the 23x23 glyph inside the exported SVG, in points.
BRAND = {"ic_google": (8, 4), "ic_facebook": (16, 8)}
CANVAS = 55
GLYPH_AT = (16, 8)

# Tinted at runtime with ColorFilter(srcIn); the source color doesn't matter.
COLOR = "#000000"


def clean_mono(svg):
    header = re.search(r"<svg [^>]*>", svg).group(0)
    header = re.sub(r'\s+xmlns:xlink="[^"]*"', "", header)
    defs = dict(re.findall(r'<path id="([^"]+)" d="([^"]+)"/>', svg))
    paths = []
    for tag in re.findall(r"<(?:path|circle)\b[^>]*/>", svg):
        if " id=" in tag:
            continue  # definitions used through <use>
        if "mask=" in tag:
            # Outside stroke (a centered stroke masked to the outside): the
            # same centered stroke over the filled shape looks identical.
            d = re.search(r' d="([^"]+)"', tag).group(1)
            width = re.search(r'stroke-width="([^"]+)"', tag).group(1)
            tag = (f'<path d="{d}" fill="{COLOR}" stroke="{COLOR}" '
                   f'stroke-width="{width}"/>')
        tag = re.sub(r'(stroke|fill)="#[0-9A-Fa-f]{6}"', rf'\1="{COLOR}"', tag)
        paths.append(tag)
    for ref in re.findall(r'<use xlink:href="#([^"]+)" fill="[^"]+"/>', svg):
        if ref in defs and not any(defs[ref] in p for p in paths):
            paths.append(f'<path d="{defs[ref]}" fill="{COLOR}"/>')
    return header + "\n" + "\n".join(paths) + "\n</svg>\n"


def build_brand(name, origin):
    out_dir = os.path.join(ROOT, "assets", "img", "brand")
    with tempfile.TemporaryDirectory() as tmp:
        for scale in (1, 2, 3):
            png = os.path.join(tmp, f"{name}@{scale}.png")
            subprocess.run(
                ["rsvg-convert", "-z", str(scale),
                 os.path.join(EXPORT, f"{name}.svg"), "-o", png],
                check=True,
            )
            glyph = Image.open(png).convert("RGBA")
            canvas = Image.new("RGBA", (CANVAS * scale, CANVAS * scale))
            offset = ((GLYPH_AT[0] - origin[0]) * scale,
                      (GLYPH_AT[1] - origin[1]) * scale)
            canvas.alpha_composite(glyph, offset)
            folder = os.path.join(out_dir, "" if scale == 1 else f"{scale}.0x")
            os.makedirs(folder, exist_ok=True)
            canvas.save(os.path.join(folder, f"{name[3:]}.webp"),
                        "WEBP", lossless=True, method=6)
    print(f"brand/{name[3:]}.webp")


def main():
    icons = os.path.join(ROOT, "assets", "icons")
    os.makedirs(icons, exist_ok=True)
    for name in MONO:
        with open(os.path.join(EXPORT, f"{name}.svg")) as f:
            svg = clean_mono(f.read())
        with open(os.path.join(icons, f"{name[3:]}.svg"), "w") as f:
            f.write(svg)
        print(f"icons/{name[3:]}.svg")
    for name, origin in BRAND.items():
        build_brand(name, origin)


if __name__ == "__main__":
    main()
