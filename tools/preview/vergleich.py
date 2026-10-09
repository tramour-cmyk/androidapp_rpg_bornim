"""Puts before and after pictures of the preview side by side.

vergleich.py <vorher-dir> <nachher-dir> <out-dir> <branch> <compare-ref>

Every PNG in the after directory gets a sheet with the before picture (same name) on the left and
the after picture on the right, labelled and stamped with the time in Berlin. Map overviews
(map_<id>_<day|dusk|night>.png) are also gathered into one sheet per map, the three times of day
from top to bottom.
"""
import os
import re
import sys
from datetime import datetime
from zoneinfo import ZoneInfo

from PIL import Image, ImageDraw, ImageFont

vorher, nachher, out, branch, ref = sys.argv[1:6]
os.makedirs(out, exist_ok=True)
stamp = datetime.now(ZoneInfo("Europe/Berlin")).strftime("%d.%m.%Y, %H:%M")

try:
    font = ImageFont.truetype("DejaVuSans.ttf", 20)
    small = ImageFont.truetype("DejaVuSans.ttf", 15)
except OSError:
    font = small = ImageFont.load_default()

BAR = 34
GAP = 12
BG = (18, 16, 20)
INK = (226, 220, 206)
DIM = (150, 144, 132)
TIMES = {"day": "Tag", "dusk": "Dämmerung", "night": "Nacht"}


def load(d, name):
    p = os.path.join(d, name)
    return Image.open(p).convert("RGB") if os.path.exists(p) else None


def pair(before, after, title):
    w = max(i.width for i in (before, after) if i)
    h = max(i.height for i in (before, after) if i)
    sheet = Image.new("RGB", (w * 2 + GAP, h + BAR), BG)
    d = ImageDraw.Draw(sheet)
    for col, (img, label) in enumerate([(before, f"{title} · vorher"), (after, "nachher")]):
        x = col * (w + GAP)
        d.text((x + 8, 7), label, fill=INK, font=font)
        if img is None:
            d.text((x + 8, BAR + 8), "fehlt", fill=DIM, font=font)
        else:
            sheet.paste(img, (x, BAR))
    return sheet


def footer(img):
    out_img = Image.new("RGB", (img.width, img.height + 24), BG)
    out_img.paste(img, (0, 0))
    ImageDraw.Draw(out_img).text((8, img.height + 4), f"erstellt {stamp} (Berliner Zeit)", fill=DIM, font=small)
    return out_img


if ref == "none":
    # new drafts: nothing to compare with, the pictures go out as they are
    import shutil
    for n in sorted(os.listdir(nachher)):
        if n.endswith(".png"):
            shutil.copy(os.path.join(nachher, n), os.path.join(out, n))
    with open(os.path.join(out, "LIESMICH.txt"), "w") as f:
        f.write(f"Vorschau vom {stamp} (Berliner Zeit), Zweig {branch}, ohne Vergleich.\n")
    sys.exit(0)

names = sorted(n for n in os.listdir(nachher) if n.endswith(".png")) if os.path.isdir(nachher) else []
maps = {}
for n in names:
    m = re.match(r"map_(.+)_(day|dusk|night)\.png$", n)
    title = f"{m.group(1)}, {TIMES[m.group(2)]}" if m else n[:-4]
    sheet = pair(load(vorher, n), load(nachher, n), title)
    footer(sheet).save(os.path.join(out, "vergleich_" + n))
    if m:
        maps.setdefault(m.group(1), {})[m.group(2)] = sheet

for mid, rows in maps.items():
    order = [rows[t] for t in ("day", "dusk", "night") if t in rows]
    w = max(r.width for r in order)
    h = sum(r.height for r in order) + GAP * (len(order) - 1)
    big = Image.new("RGB", (w, h), BG)
    y = 0
    for r in order:
        big.paste(r, (0, y))
        y += r.height + GAP
    footer(big).save(os.path.join(out, f"karte_{mid}.png"))

with open(os.path.join(out, "LIESMICH.txt"), "w") as f:
    f.write(f"Vorschau vom {stamp} (Berliner Zeit), Zweig {branch}, verglichen mit {ref}.\n")
print(f"{len(names)} Vergleiche, {len(maps)} Kartenblätter")
