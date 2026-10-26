# 348.12f (Jerry): Vergleichsblatt eigene Ratte / gekaufte Ratte / Variante: je Zeile die drei Ratten (braun, grau, schwarz)
# aus dem Godot-Bild, Ausschnitt wie vergleichsblatt.py (FIGUR=wolf) aus „Schirm wolfN: Fuß … Kopf …“ im Godot-Log.
# Aufruf: python3 kaufblatt.py <aus.png> "<Titel>=<bild.png>=<godot.log>" …
import sys, re
from PIL import Image, ImageDraw, ImageFont
try:
    SCHRIFT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 20)
except OSError:
    SCHRIFT = None
FELLE = ['braun', 'grau', 'schwarz']     # wolf1..3 tragen ERSATZ_FELLE der Reihe nach (figur.gd)
zeilen = []
for arg in sys.argv[2:]:
    titel, bild, log = arg.split('=', 2)
    G = Image.open(bild).convert('RGB')
    pos = sorted((n, int(x), int(f), int(k)) for n, x, f, x2, k in re.findall(r'Schirm (wolf\d): Fuß (\d+),(\d+) Kopf (\d+),(\d+)', open(log).read()))
    teile = []
    for n, x, f, k in pos:
        h = max(f - k, 40); w = int(h * 3.0); bot = f + int(h * 0.4); top = bot - int(w * 0.9)
        teile.append((n, G.crop((x - w // 2, top, x + w // 2, bot)).resize((356, int(356 * 0.9)))))
    zeilen.append((titel, teile))
H = 28 + 320 + 26
B = Image.new('RGB', (1080, H * len(zeilen)), (20, 20, 20)); d = ImageDraw.Draw(B)
for z, (titel, teile) in enumerate(zeilen):
    y = z * H
    d.text((6, y + 3), titel, fill=(240, 232, 216), font=SCHRIFT)
    for i, (n, c) in enumerate(teile):
        B.paste(c, (i * 362, y + 28))
        d.text((i * 362 + 4, y + 28 + 322), FELLE[int(n[-1]) - 1] if n[-1].isdigit() and int(n[-1]) <= 3 else n, fill=(240, 232, 216), font=SCHRIFT)
B.save(sys.argv[1]); print('BLATT', sys.argv[1], B.size, [(t, len(p)) for t, p in zeilen])
