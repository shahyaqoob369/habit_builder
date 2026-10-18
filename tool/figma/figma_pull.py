#!/usr/bin/env python3
"""Pull the Figma design into docs/figma/ so it can be read without Figma.

Steps (run in order; see docs/figma/README.md):
  fetch <file-url-or-key>  GET the whole file once        (Figma Tier 1 call)
  index                    list every screen frame         (offline)
  render [--scale N]       PNG of every screen, one batch  (Tier 1 call)
  fills                    download raster image fills     (Tier 2 call)
  spec                     per-screen spec + design tokens (offline)

Files on the Starter plan get only a handful of Tier 1 calls per month, so every
API result is cached under docs/figma/raw/ and never re-requested unless --force.
The token is read from the FIGMA_TOKEN environment variable and is only ever sent
to api.figma.com (never to the image download URLs).
"""
import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FIGMA_DIR = os.path.join(ROOT, "docs", "figma")
RAW = os.path.join(FIGMA_DIR, "raw")
SCREENS = os.path.join(FIGMA_DIR, "screens")
FILLS = os.path.join(FIGMA_DIR, "assets", "fills")
API = "https://api.figma.com/v1"

VECTOR_TYPES = {"VECTOR", "BOOLEAN_OPERATION", "STAR", "LINE", "ELLIPSE", "POLYGON", "REGULAR_POLYGON"}


# ---------------------------------------------------------------- io helpers

def api_get(path):
    tok = os.environ.get("FIGMA_TOKEN")
    if not tok:
        sys.exit("FIGMA_TOKEN is not set")
    req = urllib.request.Request(API + path, headers={"X-Figma-Token": tok})
    endpoint = path.split("?")[0]
    try:
        with urllib.request.urlopen(req, timeout=600) as r:
            limits = {k: v for k, v in r.headers.items() if k.lower() in ("x-figma-plan-tier", "x-figma-rate-limit-type")}
            print(f"GET {endpoint} -> {r.status} {limits}", file=sys.stderr)
            return json.load(r)
    except urllib.error.HTTPError as e:
        hdr = {k: v for k, v in e.headers.items() if k.lower().startswith(("x-figma-plan", "x-figma-rate", "retry-after"))}
        sys.exit(f"GET {endpoint} failed: {e.code} {e.read()[:300]!r} {hdr}")


def download(url, dest):
    # Signed S3 URL: no token header.
    with urllib.request.urlopen(url, timeout=300) as r:
        data = r.read()
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(dest, "wb") as f:
        f.write(data)
    return data


def read_json(path):
    with open(path) as f:
        return json.load(f)


def write_json(path, data, **kw):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, **kw)


def write_text(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(text)


def file_key():
    with open(os.path.join(RAW, "file_key.txt")) as f:
        return f.read().strip()


def load_file():
    return read_json(os.path.join(RAW, "file.json"))


def load_index():
    return read_json(os.path.join(RAW, "index.json"))


def slugify(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")[:48] or "screen"


def screen_dir(s):
    return os.path.join(SCREENS, s["slug"])


# ---------------------------------------------------------------- fetch

def cmd_fetch(a):
    m = re.search(r"figma\.com/(?:design|file|proto)/([A-Za-z0-9]+)", a.file)
    key = m.group(1) if m else a.file.strip()
    out = os.path.join(RAW, "file.json")
    if os.path.exists(out) and not a.force:
        sys.exit(f"{out} already cached; pass --force to spend another Tier 1 call")
    data = api_get(f"/files/{key}")
    write_json(out, data)
    write_text(os.path.join(RAW, "file_key.txt"), key)
    pages = [p["name"] for p in data["document"]["children"]]
    print(f"{data['name']} (last modified {data['lastModified']}), {os.path.getsize(out) // 1024} KB, pages: {pages}")


# ---------------------------------------------------------------- index

def is_screen(n):
    bb = n.get("absoluteBoundingBox") or {}
    return (n.get("type") in ("FRAME", "COMPONENT", "INSTANCE")
            and 300 <= bb.get("width", 0) <= 480 and bb.get("height", 0) >= 600)


def find_screens(node, page, out):
    for c in node.get("children", []):
        if c.get("visible") is False:
            continue
        if is_screen(c):
            out.append((page, c))
        elif c.get("type") in ("SECTION", "GROUP", "FRAME"):
            find_screens(c, page, out)


def cmd_index(a):
    doc = load_file()["document"]
    found = []
    for page in doc["children"]:
        screens = []
        find_screens(page, page["name"], screens)
        # Canvas reading order: rows top to bottom, then left to right.
        screens.sort(key=lambda ps: (round(ps[1]["absoluteBoundingBox"]["y"] / 200), ps[1]["absoluteBoundingBox"]["x"]))
        found += screens
    index = []
    for i, (page, n) in enumerate(found, 1):
        bb = n["absoluteBoundingBox"]
        index.append({"n": i, "id": n["id"], "name": n["name"], "page": page,
                      "w": round(bb["width"]), "h": round(bb["height"]),
                      "slug": f"{i:02d}-{slugify(n['name'])}"})
    write_json(os.path.join(RAW, "index.json"), index, indent=1)
    rows = ["| # | Screen | Page | Size | Node id | Files |", "|---|---|---|---|---|---|"]
    for s in index:
        rows.append(f"| {s['n']} | {s['name']} | {s['page']} | {s['w']}×{s['h']} | `{s['id']}` "
                    f"| [png](screens/{s['slug']}/main.png) · [spec](screens/{s['slug']}/spec.txt) |")
    write_text(os.path.join(FIGMA_DIR, "index.md"),
               "# Figma Screen Index\n\n_Generated by `tool/figma/figma_pull.py index`. Do not edit by hand. "
               "The png/spec links are local-only (gitignored); see README.md._\n\n"
               + "\n".join(rows) + "\n")
    for page in doc["children"]:
        count = sum(1 for s in index if s["page"] == page["name"])
        print(f"page {page['name']!r}: {count} screens")
    print(f"{len(index)} screens -> docs/figma/index.md")


# ---------------------------------------------------------------- render

def cmd_render(a):
    index, key = load_index(), file_key()
    only = {int(x) for x in a.only.split(",")} if a.only else None
    todo = [s for s in index
            if (only is None or s["n"] in only)
            and (a.force or not os.path.exists(os.path.join(screen_dir(s), "main.png")))]
    if not todo:
        print("all screens already rendered")
        return
    ids = urllib.parse.quote(",".join(s["id"] for s in todo), safe=",:")
    res = api_get(f"/images/{key}?ids={ids}&format=png&scale={a.scale}")
    failed = []
    for s in todo:
        url = (res.get("images") or {}).get(s["id"])
        if url:
            download(url, os.path.join(screen_dir(s), "main.png"))
        else:
            failed.append(s["n"])
    print(f"rendered {len(todo) - len(failed)}/{len(todo)}" + (f"; failed: {failed}" if failed else ""))


# ---------------------------------------------------------------- fills

def walk(n, fn, depth=0):
    fn(n, depth)
    for c in n.get("children", []):
        walk(c, fn, depth + 1)


def cmd_fills(a):
    key, doc = file_key(), load_file()["document"]
    cache = os.path.join(RAW, "fills.json")
    if os.path.exists(cache) and not a.force:
        res = read_json(cache)
    else:
        res = api_get(f"/files/{key}/images")
        write_json(cache, res)
    users = {}

    def collect(n, _):
        for p in n.get("fills") or []:
            if p.get("type") == "IMAGE" and p.get("imageRef"):
                users.setdefault(p["imageRef"], []).append(n.get("name", ""))
    walk(doc, collect)
    rows = ["| File | Used by (layer names) |", "|---|---|"]
    for ref, url in (res.get("meta", {}).get("images") or {}).items():
        if not url or ref not in users:
            continue
        base = f"{slugify(users[ref][0])}-{ref[:8]}"
        existing = [f for f in os.listdir(FILLS) if f.startswith(base)] if os.path.isdir(FILLS) else []
        if existing:
            name = existing[0]
        else:
            tmp = os.path.join(FILLS, base)
            data = download(url, tmp)
            ext = ".png" if data[:4] == b"\x89PNG" else ".jpg" if data[:2] == b"\xff\xd8" else ".bin"
            os.replace(tmp, tmp + ext)
            name = base + ext
        names = ", ".join(sorted(set(users[ref]))[:6])
        rows.append(f"| [{name}]({name}) | {names} |")
    write_text(os.path.join(FILLS, "index.md"), "# Image fills\n\n" + "\n".join(rows) + "\n")
    print(f"{len(rows) - 2} image fills -> docs/figma/assets/fills/")


# ---------------------------------------------------------------- spec

def hex_color(c, opacity=1.0):
    r, g, b = (round(c[k] * 255) for k in "rgb")
    alpha = c.get("a", 1) * opacity
    s = f"#{r:02X}{g:02X}{b:02X}"
    return s if alpha >= 0.995 else f"{s}@{round(alpha * 100)}%"


def paint(p):
    if p.get("visible") is False:
        return None
    t = p["type"]
    if t == "SOLID":
        return hex_color(p["color"], p.get("opacity", 1))
    if t.startswith("GRADIENT"):
        stops = " → ".join(f"{hex_color(s['color'])} {round(s['position'] * 100)}%" for s in p.get("gradientStops", []))
        return f"{t.lower().replace('gradient_', 'gradient-')}({stops})"
    if t == "IMAGE":
        return f"image:{p.get('imageRef', '')[:8]}"
    return t.lower()


STYLE_WEIGHTS = {"thin": 100, "extralight": 200, "light": 300, "regular": 400, "medium": 500,
                 "semibold": 600, "bold": 700, "extrabold": 800, "black": 900}


def font_weight(st):
    # Variable fonts sometimes report fontWeight 1; the style name is reliable.
    w = st.get("fontWeight")
    if not w or w < 100:
        w = STYLE_WEIGHTS.get((st.get("fontStyle") or "").replace(" ", "").lower(), w)
    return w


def text_style(st):
    s = f"{st.get('fontFamily')} {font_weight(st)} {st.get('fontSize')}"
    if st.get("lineHeightPx"):
        s += f"/{round(st['lineHeightPx'], 1)}"
    if st.get("letterSpacing"):
        s += f" ls{round(st['letterSpacing'], 2)}"
    if st.get("textCase") and st["textCase"] != "ORIGINAL":
        s += f" {st['textCase'].lower()}"
    if st.get("textAlignHorizontal") and st["textAlignHorizontal"] != "LEFT":
        s += f" align-{st['textAlignHorizontal'].lower()}"
    return s


def descendants(n):
    out = []
    walk(n, lambda x, _: out.append(x))
    return out[1:]


class Spec:
    def __init__(self, f):
        self.styles = f.get("styles", {})
        self.components = f.get("components", {})
        self.colors, self.text_colors, self.type_scale = Counter(), Counter(), Counter()
        self.radii, self.shadows, self.named = Counter(), Counter(), {}

    def props(self, n, ox, oy):
        parts = []
        bb = n.get("absoluteBoundingBox")
        if bb:
            parts.append(f"@{round(bb['x'] - ox)},{round(bb['y'] - oy)} {round(bb['width'])}x{round(bb['height'])}")
        fills = [d for d in map(paint, n.get("fills") or []) if d]
        if fills:
            parts.append(("color " if n["type"] == "TEXT" else "fill ") + " + ".join(fills))
            for p in n.get("fills"):
                if p.get("type") == "SOLID" and p.get("visible", True):
                    (self.text_colors if n["type"] == "TEXT" else self.colors)[hex_color(p["color"], p.get("opacity", 1))] += 1
        strokes = [d for d in map(paint, n.get("strokes") or []) if d]
        if strokes and n.get("strokeWeight"):
            parts.append(f"stroke {n['strokeWeight']} {' + '.join(strokes)}")
        if n.get("rectangleCornerRadii") and len(set(n["rectangleCornerRadii"])) > 1:
            parts.append(f"r{[round(r) for r in n['rectangleCornerRadii']]}")
            self.radii[str(n["rectangleCornerRadii"])] += 1
        elif n.get("cornerRadius"):
            parts.append(f"r{round(n['cornerRadius'], 1)}")
            self.radii[round(n["cornerRadius"], 1)] += 1
        for e in n.get("effects") or []:
            if e.get("visible") is False:
                continue
            if e["type"] in ("DROP_SHADOW", "INNER_SHADOW"):
                o = e.get("offset", {})
                sh = (f"{'inner-' if e['type'] == 'INNER_SHADOW' else ''}shadow({round(o.get('x', 0))},{round(o.get('y', 0))} "
                      f"blur{round(e.get('radius', 0))} spread{round(e.get('spread', 0))} {hex_color(e['color'])})")
                parts.append(sh)
                self.shadows[sh] += 1
            else:
                parts.append(f"{e['type'].lower()}({round(e.get('radius', 0))})")
        if n.get("opacity", 1) < 1:
            parts.append(f"opacity{round(n['opacity'] * 100)}%")
        if n.get("layoutMode") in ("HORIZONTAL", "VERTICAL"):
            pad = [round(n.get(k, 0)) for k in ("paddingTop", "paddingRight", "paddingBottom", "paddingLeft")]
            parts.append(f"auto-{n['layoutMode'][0]} gap{round(n.get('itemSpacing', 0))} pad{pad} "
                         f"main:{n.get('primaryAxisAlignItems', 'MIN').lower()} cross:{n.get('counterAxisAlignItems', 'MIN').lower()}")
        if n["type"] == "TEXT":
            st = n.get("style", {})
            parts.append(text_style(st))
            self.type_scale[(st.get("fontFamily"), font_weight(st), st.get("fontSize"), round(st.get("lineHeightPx") or 0, 1))] += 1
        for kind, sid in (n.get("styles") or {}).items():
            if sid in self.styles:
                name = self.styles[sid]["name"]
                parts.append(f"style:{name}")
                if name not in self.named:
                    self.named[name] = (self.styles[sid].get("styleType"), self.style_value(n, kind))
        if n["type"] == "INSTANCE" and n.get("componentId") in self.components:
            parts.append(f"<{self.components[n['componentId']]['name']}>")
        if n.get("exportSettings"):
            parts.append("[export]")
        return " ".join(parts)

    @staticmethod
    def style_value(n, kind):
        if kind in ("fill", "fills"):
            return " + ".join(d for d in map(paint, n.get("fills") or []) if d)
        if kind == "text":
            return text_style(n.get("style", {}))
        if kind in ("stroke", "strokes"):
            return " + ".join(d for d in map(paint, n.get("strokes") or []) if d)
        if kind == "effect":
            return f"{len(n.get('effects') or [])} effect(s)"
        return ""

    def text_runs(self, n):
        """Spans whose style differs from the base text style (e.g. highlighted words)."""
        chars, over, table = n.get("characters", ""), n.get("characterStyleOverrides") or [], n.get("styleOverrideTable") or {}
        if not table:
            return []
        runs, start = [], 0
        ids = list(over) + [0] * (len(chars) - len(over))
        for i in range(1, len(ids) + 1):
            if i == len(ids) or ids[i] != ids[start]:
                oid = ids[start]
                if oid and str(oid) in table:
                    o = table[str(oid)]
                    bits = [f"{k}={o[k]}" for k in ("fontWeight", "fontSize", "fontFamily", "textDecoration") if k in o]
                    bits += [f"color {d}" for d in map(paint, o.get("fills") or []) if d]
                    runs.append(f"{chars[start:i]!r} {' '.join(bits)}")
                start = i
        return runs

    def tree(self, n, ox, oy, depth, lines):
        if n.get("visible") is False:
            return
        pad = "  " * depth
        desc = descendants(n)
        has_text = any(d.get("type") == "TEXT" for d in desc)
        bb = n.get("absoluteBoundingBox") or {}
        small = bb.get("width", 999) <= 48 and bb.get("height", 999) <= 48
        if n["type"] == "TEXT":
            text = n.get("characters", "").replace("\n", "⏎")
            lines.append(f'{pad}TEXT "{text[:240]}" {self.props(n, ox, oy)}')
            for r in self.text_runs(n):
                lines.append(f"{pad}  span {r}")
            return
        if depth > 0 and desc and not has_text and (small or len(desc) > 20):
            kind = "ICON" if small else f"GRAPHIC({len(desc)} layers)"
            inner = sorted({d for x in desc for d in map(paint, (x.get("fills") or []) + (x.get("strokes") or []))
                            if d and d.startswith("#")})
            colors = f" colors {' '.join(inner[:4])}" if inner else ""
            lines.append(f'{pad}{kind} "{n.get("name")}" {self.props(n, ox, oy)}{colors}')
            return
        if n["type"] in VECTOR_TYPES and depth > 0:
            lines.append(f'{pad}{n["type"]} "{n.get("name")}" {self.props(n, ox, oy)}')
            return
        lines.append(f'{pad}{n["type"]} "{n.get("name")}" {self.props(n, ox, oy)}')
        for c in n.get("children", []):
            self.tree(c, ox, oy, depth + 1, lines)


def find_node(n, node_id):
    if n.get("id") == node_id:
        return n
    for c in n.get("children", []):
        hit = find_node(c, node_id)
        if hit:
            return hit
    return None


def cmd_spec(a):
    f, index = load_file(), load_index()
    spec = Spec(f)
    legend = ("# Legend: @x,y WxH relative to the screen · fill/color hex[@alpha] · r=corner radius · "
              "auto-H/V = auto layout (gap, pad[t,r,b,l]) · font: family weight size/lineHeight · "
              "<Component> = instance · span = differently styled words inside one text\n")
    for s in index:
        n = find_node(f["document"], s["id"])
        bb = n["absoluteBoundingBox"]
        lines = [legend, f"# {s['n']:02d} {s['name']}  (page: {s['page']}, node {s['id']})\n"]
        spec.tree(n, bb["x"], bb["y"], 0, lines)
        write_text(os.path.join(screen_dir(s), "spec.txt"), "\n".join(lines) + "\n")

    out = ["# Design Tokens (extracted)", "",
           "_Generated by `tool/figma/figma_pull.py spec` from every screen. Counts = number of layers using the value._", ""]
    if spec.named:
        out += ["## Named styles", "", "| Style | Type | Value |", "|---|---|---|"]
        out += [f"| {k} | {t} | {v} |" for k, (t, v) in sorted(spec.named.items())] + [""]
    out += ["## Fill colors", "", "| Color | Uses |", "|---|---|"] + [f"| `{c}` | {k} |" for c, k in spec.colors.most_common(40)] + [""]
    out += ["## Text colors", "", "| Color | Uses |", "|---|---|"] + [f"| `{c}` | {k} |" for c, k in spec.text_colors.most_common(25)] + [""]
    out += ["## Type scale", "", "| Family | Weight | Size | Line height | Uses |", "|---|---|---|---|---|"]
    out += [f"| {fa} | {w} | {sz} | {lh} | {k} |" for (fa, w, sz, lh), k in
            sorted(spec.type_scale.items(), key=lambda x: (-(x[0][2] or 0), -(x[0][1] or 0)))] + [""]
    out += ["## Corner radii", "", "| Radius | Uses |", "|---|---|"] + [f"| {r} | {k} |" for r, k in spec.radii.most_common(15)] + [""]
    out += ["## Shadows", "", "| Shadow | Uses |", "|---|---|"] + [f"| `{s}` | {k} |" for s, k in spec.shadows.most_common(10)] + [""]
    write_text(os.path.join(FIGMA_DIR, "tokens.md"), "\n".join(out))
    print(f"wrote {len(index)} specs + docs/figma/tokens.md")


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("fetch")
    p.add_argument("file", help="Figma file URL or key")
    p.add_argument("--force", action="store_true")
    sub.add_parser("index")
    p = sub.add_parser("render")
    p.add_argument("--scale", type=float, default=2)
    p.add_argument("--only", help="comma-separated screen numbers")
    p.add_argument("--force", action="store_true")
    p = sub.add_parser("fills")
    p.add_argument("--force", action="store_true")
    sub.add_parser("spec")
    a = ap.parse_args()
    {"fetch": cmd_fetch, "index": cmd_index, "render": cmd_render, "fills": cmd_fills, "spec": cmd_spec}[a.cmd](a)


if __name__ == "__main__":
    main()
