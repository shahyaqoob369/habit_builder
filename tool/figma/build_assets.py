#!/usr/bin/env python3
"""Build the app's image assets from the Figma exports.

Reads tool/figma/app_assets.json and, for each entry, takes the 3x render in
docs/figma/assets/export/<source>.png (made by `figma_pull.py export`), applies
the optional crop (in 3x pixels) and writes Flutter resolution-aware variants:

  assets/img/<out>.webp        1x
  assets/img/<dir>/2.0x/...    2x
  assets/img/<dir>/3.0x/...    3x

Usage: python3 tool/figma/build_assets.py
"""
import json
import os

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXPORT = os.path.join(ROOT, "docs", "figma", "assets", "export")
RECIPES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "app_assets.json")


def main():
    with open(RECIPES) as f:
        recipes = json.load(f)
    for r in recipes:
        img = Image.open(os.path.join(EXPORT, f"{r['source']}.png")).convert("RGBA")
        if r.get("crop3"):
            img = img.crop(tuple(r["crop3"]))
        # Logical size in points; renders are 3x.
        w, h = round(img.width / 3), round(img.height / 3)
        directory, name = os.path.split(r["out"])
        for scale in (3, 2, 1):
            variant = img if scale == 3 else img.resize((w * scale, h * scale), Image.LANCZOS)
            folder = os.path.join(ROOT, "assets", "img", directory, "" if scale == 1 else f"{scale}.0x")
            os.makedirs(folder, exist_ok=True)
            path = os.path.join(folder, f"{name}.webp")
            variant.save(path, "WEBP", quality=r.get("quality", 90), method=6)
        size = os.path.getsize(os.path.join(ROOT, "assets", "img", directory, "3.0x", f"{name}.webp"))
        print(f"{r['out']}: {w}x{h} pt, 3x = {size // 1024} KB")


if __name__ == "__main__":
    main()
