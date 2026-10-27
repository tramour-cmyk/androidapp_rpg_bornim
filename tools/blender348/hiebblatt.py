# 348.12 Runde 6 (Prüfer 5e: Nachbar in Spalte 2 abgeschnitten, Haltungen fehlten): Blatt eigen / CC0 je Haltung.
# Zeilen = Haltungen, Spalten = die drei Goblins (NAMEN) erst eigen, dann CC0; jedes Bild zeigt einen Goblin allein (probe.gd NUR=gobN).
# Ausschnitt aus „Schirm gobN: Fuß … Kopf …“ im Godot-Log, je Goblin in allen Zeilen gleich (Größen vergleichbar).
# Aufruf: [NAMEN=a;b;c] python3 hiebblatt.py <aus.png> <ordner> "<Zeilentitel>=<name>[!]" …   (Bilder <ordner>/st-<eigen|cc0>-<name>-<n>.png/.log)
# name! = nur CC0 (der eigene Goblin hat keinen Hieb, er schnellt nur vor: figur.gd _play)
import sys, re, os
from PIL import Image, ImageDraw, ImageFont
try:
    SCHRIFT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 17)
except OSError:
    SCHRIFT = None
NAMEN = os.environ.get('NAMEN', 'leder;kappe;helm').split(';')
TW, TH = 178, 230     # Kachel; Ausschnitt 1,4 Figurhöhen breit, 1,8 hoch (ausgeholte Klinge über dem Kopf)
aus, ordner, zeilen = sys.argv[1], sys.argv[2], [a.split('=', 1) for a in sys.argv[3:]]
KOPF = 26
B = Image.new('RGB', (6 * TW + 12, KOPF + len(zeilen) * (TH + 22)), (20, 20, 20)); d = ImageDraw.Draw(B)
for s, m in enumerate(('eigen', 'CC0')):
    d.text((s * (3 * TW + 12) + 4, 4), m, fill=(240, 232, 216), font=SCHRIFT)
for z, (titel, name) in enumerate(zeilen):
    y = KOPF + z * (TH + 22)
    d.text((4, y + 2), titel, fill=(240, 232, 216), font=SCHRIFT)
    for s, m in enumerate(('eigen', 'cc0')):
        if m == 'eigen' and name.endswith('!'):
            d.text((8, y + 20 + TH // 2), 'eigen: kein Hieb (schnellt nur vor)', fill=(200, 192, 176), font=SCHRIFT); continue
        for g in (1, 2, 3):
            f = '%s/st-%s-%s-%d' % (ordner, m, name.rstrip('!'), g)
            x, fu, k = [int(v) for v in re.search(r'Schirm gob%d: Fuß (\d+),(\d+) Kopf \d+,(\d+)' % g, open(f + '.log').read()).groups()]
            h = max(fu - k, 40); w = int(h * 1.4); hh = int(w * TH / TW)
            c = Image.open(f + '.png').convert('RGB').crop((x - w // 2, fu + int(h * 0.1) - hh, x + w // 2, fu + int(h * 0.1))).resize((TW, TH))
            px = s * (3 * TW + 12) + (g - 1) * TW
            B.paste(c, (px, y + 20))
            d.text((px + 4, y + TH), NAMEN[g - 1], fill=(200, 192, 176), font=SCHRIFT)
B.save(aus); print('BLATT', aus, B.size)
