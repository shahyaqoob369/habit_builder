#!/usr/bin/env python3
"""Build the launcher icon sources from the teepee illustration.

The Figma kit has no app icon, so this is a stand-in until the owner has
one (docs/KNOWN_ISSUES.md): the teepee from the congratulation popup on the
app's cream background (AppPalette.cream).

Reads assets/img/habits/3.0x/teepee.webp and writes:

* assets/app_icon/icon.png: 1024x1024, opaque (the App Store rejects
  transparency), teepee over most of the square. iOS rounds the corners.
* assets/app_icon/foreground.png: 1024x1024, transparent, teepee inside
  Android's adaptive-icon safe zone (the middle 66 %), for the launcher's
  mask over the cream background.
* ios/Runner/Assets.xcassets/AppIcon.appiconset/: one 1024 px icon per
  appearance (Xcode scales it): light (icon.png), dark (teepee on
  transparent; iOS draws the dark background) and tinted (grayscale on
  black). Without the dark and tinted ones, iOS 18+ makes its own, which
  look poor.

Then `dart run flutter_launcher_icons` makes the Android sizes (configured
in pubspec.yaml).

Usage: python3 tool/figma/build_app_icon.py   (needs Pillow)
"""
import json
import os

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SOURCE = os.path.join(ROOT, 'assets/img/habits/3.0x/teepee.webp')
OUT = os.path.join(ROOT, 'assets/app_icon')
IOS = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
SIZE = 1024
CREAM = (0xFF, 0xF3, 0xE9, 255)


def teepee(width):
    """The illustration cropped to its visible pixels, `width` px wide."""
    art = Image.open(SOURCE).convert('RGBA')
    art = art.crop(art.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox())
    height = round(art.height * width / art.width)
    return art.resize((width, height), Image.LANCZOS)


def centered(art, background):
    canvas = Image.new('RGBA', (SIZE, SIZE), background)
    canvas.alpha_composite(art, ((SIZE - art.width) // 2, (SIZE - art.height) // 2))
    return canvas


def main():
    os.makedirs(OUT, exist_ok=True)
    icon = centered(teepee(round(SIZE * 0.86)), CREAM).convert('RGB')
    icon.save(os.path.join(OUT, 'icon.png'), optimize=True)
    foreground = centered(teepee(round(SIZE * 0.62)), (0, 0, 0, 0))
    foreground.save(os.path.join(OUT, 'foreground.png'), optimize=True)
    write_ios(icon)
    print('Wrote assets/app_icon/ and the iOS AppIcon set')


def write_ios(icon):
    for name in os.listdir(IOS):
        if name.endswith('.png'):
            os.remove(os.path.join(IOS, name))
    art = teepee(round(SIZE * 0.86))
    dark = centered(art, (0, 0, 0, 0))
    gray = art.convert('LA').convert('RGBA')
    tinted = centered(gray, (0, 0, 0, 255)).convert('RGB')
    images = []
    for appearance, image, filename in [
        (None, icon, 'Icon-App-1024x1024.png'),
        ('dark', dark, 'Icon-App-1024x1024-dark.png'),
        ('tinted', tinted, 'Icon-App-1024x1024-tinted.png'),
    ]:
        image.save(os.path.join(IOS, filename), optimize=True)
        entry = {'filename': filename, 'idiom': 'universal', 'platform': 'ios', 'size': '1024x1024'}
        if appearance:
            entry['appearances'] = [{'appearance': 'luminosity', 'value': appearance}]
        images.append(entry)
    contents = {'images': images, 'info': {'author': 'xcode', 'version': 1}}
    with open(os.path.join(IOS, 'Contents.json'), 'w') as f:
        json.dump(contents, f, indent=2)
        f.write('\n')


if __name__ == '__main__':
    main()
