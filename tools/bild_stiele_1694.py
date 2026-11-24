#!/usr/bin/env python3
# 1694 (Chef 24.11., 10:30): Vergleichsbild Stiele vorher (73f8af7c4) gegen nachher (dbbc99243), aus den Einzelbildern von
# godot/tests/bild_stiele_1694.gd (gleicher Maßstab, Spielfarbe), beschriftet mit Name und Stieldicke (staffel.json des Baus nachher:
# stiel_roh_cm, stiel_cm); daneben die offene Hand von WACHE_M im selben Maßstab, unten die Großaxt Stufe 1 groß.
# Aufruf: python3 tools/bild_stiele_1694.py <ordner einzelbilder> <staffel.json> <ziel.webp> [GROSS-id]
import json, sys, os
from PIL import Image, ImageDraw, ImageFont

ordner, sj, ziel = sys.argv[1:4]
gross = sys.argv[4] if len(sys.argv) > 4 else 'anker_two_handed_axe'
formen = {k: v for k, v in json.load(open(sj))['formen'].items() if 'stiel_roh_cm' in v}
try:
    F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 10)
    FB = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 13)
except OSError:
    F = FB = ImageFont.load_default()

def lade(n, s=0.5):
    im = Image.open(os.path.join(ordner, n)).convert('RGB')
    return im.resize((round(im.width * s), round(im.height * s)), Image.LANCZOS)   # gerendert 8 px/cm, im Bild 4 px/cm

ids = list(formen)
je_reihe = 6
zelle = lade(ids[0] + '-vorher.png')
cw, ch = zelle.width, zelle.height          # 64 x 136
paar = 2 * cw + 4
kopf, unter = 22, 26
W = 800
reihen = (len(ids) + je_reihe - 1) // je_reihe
gx, gy = lade(gross + '-gross-vorher.png', 1.0), None
hg = max(gx.height, lade('hand-gross-a.png', 1.0).height)
H = kopf + reihen * (ch + unter + 6) + 18 + hg + 30
bild = Image.new('RGB', (W, H), (232, 228, 220))
d = ImageDraw.Draw(bild)
d.text((6, 4), '1694 Stiele je Paar: links vorher (73f8af7c4), rechts nachher (dbbc99243); 4 px = 1 cm', fill=(20, 20, 20), font=FB)
for i, k in enumerate(ids):
    r, c = divmod(i, je_reihe)
    x = 4 + c * (paar + 12)
    y = kopf + r * (ch + unter + 6)
    bild.paste(lade(k + '-vorher.png'), (x, y))
    bild.paste(lade(k + '-nachher.png'), (x + cw + 4, y))
    d.text((x, y + ch + 1), k.replace('_sm_', '_').replace('two_handed', '2h')[:21], fill=(20, 20, 20), font=F)
    d.text((x, y + ch + 13), '%.1f → %.1f cm' % (formen[k]['stiel_roh_cm'], formen[k]['stiel_cm']), fill=(120, 20, 20), font=F)
y0 = kopf + reihen * (ch + unter + 6) + 4
d.text((4, y0), 'Großaxt Stufe 1 groß, 16 px = 1 cm: vorher, nachher, Hand WACHE_M', fill=(20, 20, 20), font=FB)
y0 += 18
x = 4
for n in [gross + '-gross-vorher.png', gross + '-gross-nachher.png', 'hand-gross-a.png']:
    im = lade(n, 1.0)
    bild.paste(im, (x, y0)); x += im.width + 8
d.text((4, y0 + gx.height + 2), '%.1f cm' % formen[gross]['stiel_roh_cm'], fill=(120, 20, 20), font=F)
d.text((4 + gx.width + 8, y0 + gx.height + 2), '%.1f cm' % formen[gross]['stiel_cm'], fill=(120, 20, 20), font=F)
# Hand im Maßstab der Stiele (4 px/cm) rechts neben den Reihen
h = lade('hand-a.png')
bild.paste(h, (x + 20, y0)); d.text((x + 20, y0 + h.height + 2), 'Hand 4 px/cm', fill=(20, 20, 20), font=F)
bild.save(ziel, 'WEBP', quality=70, method=6)
print(ziel, bild.size, os.path.getsize(ziel), 'Bytes')
