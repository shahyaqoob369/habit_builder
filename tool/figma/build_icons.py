#!/usr/bin/env python3
"""Build the app's icons from the Figma SVG exports.

Reads every docs/figma/assets/export/ic_*.svg (made by `figma_pull.py export`):

* Brand logos (BRAND) keep their colors and Figma drop shadows (SVG
  filters, which flutter_svg ignores), so they are rasterized with
  rsvg-convert into assets/img/brand/{,2.0x/,3.0x/}<name>.webp on a common
  55x55 pt canvas with the 23x23 pt glyph at (16, 8).
* Every other icon is written to assets/icons/<name>.svg, cleaned up for
  flutter_svg:
  - outlined strokes (Figma exports them as a fill plus a masked stroke)
    become a fill plus a plain stroke; inside strokes are dropped, since the
    fill already covers them;
  - drop-shadow filters are removed (flutter_svg can't draw them);
  - icons in TINTED are tinted at runtime (AppIcon with a color), so their
    opacity attributes are removed too. The others are full-color and drawn
    as exported.

Usage: python3 tool/figma/build_icons.py   (needs rsvg-convert and Pillow)
"""
import glob
import os
import re
import subprocess
import tempfile

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXPORT = os.path.join(ROOT, "docs", "figma", "assets", "export")

# Single-color glyphs, tinted at runtime.
TINTED = {
    "back", "bell_plus", "book_reader", "card", "check", "check_bold",
    "chevron_down", "chevron_left", "chevron_right", "clock", "edit",
    "feedback", "flag", "hand_arrow", "heart", "help", "lock", "mail", "menu",
    "notification", "plus", "repeat", "search", "shield", "user",
}

# Icons exported with their button background: keep only the glyph, at
# this viewBox (x y w h).
GLYPH_ONLY = {"search": "21 22 22 22"}

# name -> top-left of the 23x23 glyph inside the exported SVG, in points.
BRAND = {"google": (8, 4), "facebook": (16, 8)}
CANVAS = 55
GLYPH_AT = (16, 8)


def clean(svg, tinted):
    opening = re.search(r"<svg [^>]*>", svg)
    header = re.sub(r'\s+xmlns:xlink="[^"]*"', "", opening.group(0))
    body = svg[opening.end():svg.rindex("</svg>")]

    # Outlined strokes: <use href=#p fill=…/> plus a masked stroke of #p.
    defs = dict(re.findall(r'<path id="([^"]+)" d="([^"]+)"/>', body))
    masks = dict(re.findall(r'<mask id="([^"]+)"([\s\S]*?)</mask>', body))

    def unmask(m):
        tag = m.group(0)
        mask_id = re.search(r'mask="url\(#([^)]+)\)"', tag).group(1)
        outside = "<rect" in masks.get(mask_id, "")
        if not outside:
            return ""  # inside stroke: hidden under the fill
        return re.sub(r'\s*mask="url\(#[^)]+\)"', "", tag)

    body = re.sub(r"<path\b[^>]*mask=\"url\(#[^)]+\)\"[^>]*/>", unmask, body)
    body = re.sub(r"<mask\b[\s\S]*?</mask>", "", body)
    body = re.sub(
        r'<use xlink:href="#([^"]+)"([^>]*)/>',
        lambda m: f'<path d="{defs[m.group(1)]}"{m.group(2)}/>',
        body,
    )
    body = re.sub(r'<path id="[^"]+" d="[^"]+"/>', "", body)

    # Drop shadows.
    body = re.sub(r'<g filter="url\(#[^)]+\)">([\s\S]*?)</g>', r"\1", body)
    body = re.sub(r"<filter\b[\s\S]*?</filter>", "", body)

    if tinted:
        body = re.sub(r'\s+opacity="[^"]+"', "", body)
        body = re.sub(r'<g>([\s\S]*?)</g>', r"\1", body)

    body = re.sub(r"<defs>\s*</defs>", "", body)
    lines = [line.strip() for line in body.splitlines() if line.strip()]
    return header + "\n" + "\n".join(lines) + "\n</svg>\n"


def build_brand(name, origin):
    out_dir = os.path.join(ROOT, "assets", "img", "brand")
    with tempfile.TemporaryDirectory() as tmp:
        for scale in (1, 2, 3):
            png = os.path.join(tmp, f"{name}@{scale}.png")
            subprocess.run(
                ["rsvg-convert", "-z", str(scale),
                 os.path.join(EXPORT, f"ic_{name}.svg"), "-o", png],
                check=True,
            )
            glyph = Image.open(png).convert("RGBA")
            canvas = Image.new("RGBA", (CANVAS * scale, CANVAS * scale))
            offset = ((GLYPH_AT[0] - origin[0]) * scale,
                      (GLYPH_AT[1] - origin[1]) * scale)
            canvas.alpha_composite(glyph, offset)
            folder = os.path.join(out_dir, "" if scale == 1 else f"{scale}.0x")
            os.makedirs(folder, exist_ok=True)
            canvas.save(os.path.join(folder, f"{name}.webp"),
                        "WEBP", lossless=True, method=6)
    print(f"brand/{name}.webp")


def main():
    icons = os.path.join(ROOT, "assets", "icons")
    os.makedirs(icons, exist_ok=True)
    for path in sorted(glob.glob(os.path.join(EXPORT, "ic_*.svg"))):
        name = os.path.basename(path)[3:-4]
        if name in BRAND:
            continue
        with open(path) as f:
            svg = clean(f.read(), name in TINTED)
        if name in GLYPH_ONLY:
            box = GLYPH_ONLY[name]
            w, h = box.split()[2:]
            svg = re.sub(r"<rect\b[^>]*/>\n", "", svg, count=1)
            svg = re.sub(r'width="[^"]+" height="[^"]+" viewBox="[^"]+"',
                         f'width="{w}" height="{h}" viewBox="{box}"', svg, count=1)
        with open(os.path.join(icons, f"{name}.svg"), "w") as f:
            f.write(svg)
        print(f"icons/{name}.svg" + ("" if name in TINTED else "  (full color)"))
    for name, origin in BRAND.items():
        build_brand(name, origin)


if __name__ == "__main__":
    main()
