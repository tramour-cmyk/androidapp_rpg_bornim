# 348.6 Leute: Vergleichsblatt alt/neu. Je Figur: alt vorn, neu vorn, alt hinten, neu hinten (gleiche Höhe), Name darüber.
# Aufruf: python leute_vgl.py <alt-ordner (leute_alt_<id>_vorn.png)> <neu-wurzel (<id>/blatt/vorn.png)> <ausgabe.png> id1 id2 ...
import sys
from PIL import Image, ImageDraw, ImageFont
alt, neu, aus, ids = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
H = 260; LAB = 26; COLS = 4
def fit(p):
    im = Image.open(p).convert('RGB')
    return im.resize((round(im.width * H / im.height), H), Image.LANCZOS)
tiles = []
for i in ids:
    ims = [fit(f'{alt}/leute_alt_{i}_vorn.png'), fit(f'{neu}/{i}/blatt/vorn.png'), fit(f'{alt}/leute_alt_{i}_hinten.png'), fit(f'{neu}/{i}/blatt/hinten.png')]
    t = Image.new('RGB', (sum(m.width for m in ims) + 12, H + LAB), (24, 22, 20))
    x = 0
    for k, m in enumerate(ims):
        t.paste(m, (x, LAB)); x += m.width + (12 if k == 1 else 0)
    d = ImageDraw.Draw(t)
    try: f = ImageFont.truetype('DejaVuSans-Bold.ttf', 18)
    except OSError: f = ImageFont.load_default()
    d.text((6, 3), f'{i.capitalize()}   alt | neu  vorn       alt | neu  hinten', fill=(232, 220, 192), font=f)
    tiles.append(t)
rows = [tiles[k:k + COLS] for k in range(0, len(tiles), COLS)]
W = max(sum(t.width for t in r) + 8 * (len(r) - 1) for r in rows)
sheet = Image.new('RGB', (W, len(rows) * (H + LAB + 8)), (24, 22, 20))
y = 0
for r in rows:
    x = 0
    for t in r: sheet.paste(t, (x, y)); x += t.width + 8
    y += H + LAB + 8
sheet.save(aus)
print('VGL OK', sheet.size)
