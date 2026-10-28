# Zoom-Blatt 348.13: Spalten nah, Grundansicht, weit; Zeilen nach Wahl
import sys, os
from PIL import Image, ImageDraw, ImageFont
src, ziel, art = sys.argv[1], sys.argv[2], sys.argv[3]   # art: "mittag" (Zeilen Orte) oder Ort (Zeilen Sonnenstaende)
W = int(sys.argv[4]) if len(sys.argv) > 4 else 260
zooms = [('nah', 'nah'), ('grund', 'Grundansicht'), ('weit', 'weit')]
if art == 'mittag': rows = [(f'{o}_mittag', o.capitalize()) for o in ('kirche', 'markt', 'gras')]
else: rows = [(f'{art}_{s}', s.capitalize()) for s in ('morgen', 'mittag', 'abend')]
H = int(W * 2340 / 1080); top = 26; left = 0
try: font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 16)
except Exception: font = ImageFont.load_default()
img = Image.new('RGB', (3 * W + 4, top + len(rows) * (H + 22)), (12, 12, 12)); d = ImageDraw.Draw(img)
for j, (_, zl) in enumerate(zooms): d.text((j * (W + 2) + 6, 4), zl, fill=(214, 184, 110), font=font)
for i, (pre, rl) in enumerate(rows):
    y = top + i * (H + 22)
    d.text((6, y), rl, fill=(230, 226, 214), font=font)
    for j, (z, _) in enumerate(zooms):
        t = Image.open(f'{src}/{pre}_{z}.png').convert('RGB').resize((W, H), Image.LANCZOS)
        img.paste(t, (j * (W + 2), y + 20))
img.save(ziel, quality=int(os.environ.get('Q', 70)))
print(ziel, img.size, os.path.getsize(ziel))
