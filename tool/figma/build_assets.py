#!/usr/bin/env python3
"""Build the app's image assets from the Figma exports.

Reads tool/figma/app_assets.json and, for each entry, takes either the 3x
render docs/figma/assets/export/<source>.png (made by `figma_pull.py export`)
or an original image fill docs/figma/assets/fills/<fill> (made by
`figma_pull.py fills`), applies the optional crop (in 3x pixels) or cover-fit
to `size` (in points), and writes Flutter resolution-aware variants:

  assets/img/<out>.webp        1x
  assets/img/<dir>/2.0x/...    2x
  assets/img/<dir>/3.0x/...    3x

Usage: python3 tool/figma/build_assets.py [out ...]   (only the given outputs)
       (the white_to_alpha option needs numpy)
"""
import json
import os
import sys

from PIL import Image, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXPORT = os.path.join(ROOT, "docs", "figma", "assets", "export")
FILLS = os.path.join(ROOT, "docs", "figma", "assets", "fills")
RECIPES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "app_assets.json")


def white_to_alpha(img):
    import numpy as np  # only needed for this option

    rgb = np.asarray(img.convert("RGB"), dtype=np.float32) / 255
    alpha = (1 - rgb).max(axis=2)
    safe = np.where(alpha == 0, 1, alpha)[..., None]
    color = np.clip((rgb - (1 - alpha)[..., None]) / safe, 0, 1)
    out = np.dstack([color, alpha]) * 255
    return Image.fromarray(out.round().astype(np.uint8), "RGBA")


def main():
    with open(RECIPES) as f:
        recipes = json.load(f)
    only = set(sys.argv[1:])
    for r in recipes:
        if only and r["out"] not in only:
            continue
        if "fill" in r:
            img = Image.open(os.path.join(FILLS, r["fill"])).convert("RGBA")
        else:
            img = Image.open(os.path.join(EXPORT, f"{r['source']}.png")).convert("RGBA")
        if r.get("crop3"):
            img = img.crop(tuple(r["crop3"]))
        if r.get("white_to_alpha"):
            # Figma draws some fills with "multiply" so their white
            # background disappears; turn white into transparency instead
            # (GIMP's color-to-alpha), which matches it on light colors.
            img = white_to_alpha(img)
        if r.get("size"):
            # Cover-fit (centered), like a Figma image fill, at 3x.
            img = ImageOps.fit(img, (r["size"][0] * 3, r["size"][1] * 3), Image.LANCZOS)
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
