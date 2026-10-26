# 348.12f (Jerry): Vergleichsblatt eigene Ratte / gekaufte Ratte / Variante: je Zeile die drei Ratten (braun, grau, schwarz)
# aus dem Godot-Bild, Ausschnitt wie vergleichsblatt.py (FIGUR=wolf) aus „Schirm wolfN: Fuß … Kopf …“ im Godot-Log.
# 348.12 Runde 2: FIGUR=gob für Goblins (Ausschnitt hoch statt breit), NAMEN="a;b;c"
# Runde 2 (Helfer 26.10., 20:36: Blatt schnitt die gekauften Ratten ab; Kasten am Fuß reichte nur für die eigene, die gekaufte
# ist mit Rute 3,2 m lang, die Variante 4,0 m): KASTEN="wolf1=l,r,o,u;…" je Platz in Figurhöhen ab dem Fuß (links/rechts waagrecht,
# oben/unten senkrecht, negativ = links bzw. oben), in allen Zeilen gleich, damit die Größen vergleichbar bleiben; in eine Kachel
# mit SEITEN (Höhe/Breite) eingepasst.
# Aufruf: [FIGUR=gob] [NAMEN=…] [KASTEN=…] python3 kaufblatt.py <aus.png> "<Titel>=<bild.png>=<godot.log>" …
import sys, re, os
from PIL import Image, ImageDraw, ImageFont
try:
    SCHRIFT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 20)
except OSError:
    SCHRIFT = None
FIG = os.environ.get('FIGUR', 'wolf')
FELLE = os.environ.get('NAMEN', 'braun;grau;schwarz').split(';')     # wolf1..3 tragen ERSATZ_FELLE der Reihe nach (figur.gd)
BW, BH = (3.0, 0.9) if FIG == 'wolf' else (1.5, 1.25)     # Breite und Höhe des Ausschnitts in Figurhöhen
KASTEN = {k: [float(v) for v in w.split(',')] for k, w in (e.split('=') for e in os.environ.get('KASTEN', '').split(';') if e)}
if KASTEN:
    BH = float(os.environ.get('SEITEN', '0.75'))
zeilen = []
for arg in sys.argv[2:]:
    titel, bild, log = arg.split('=', 2)
    G = Image.open(bild).convert('RGB')
    pos = sorted((n, int(x), int(f), int(k)) for n, x, f, x2, k in re.findall(r'Schirm (%s\d): Fuß' % FIG + r' (\d+),(\d+) Kopf (\d+),(\d+)', open(log).read()))
    teile = []
    for n, x, f, k in pos:
        h = max(f - k, 40)
        if n in KASTEN:     # genau der Kasten (am Bildrand gekappt), eingepasst und dunkel umrandet; größer zöge Nachbarn herein
            l, r, o, u = KASTEN[n]
            box = (max(0, int(x + h * l)), max(0, int(f + h * o)), min(G.width, int(x + h * r)), min(G.height, int(f + h * u)))
            c = G.crop(box); s = min(356 / c.width, 356 * BH / c.height); c = c.resize((int(c.width * s), int(c.height * s)))
            t = Image.new('RGB', (356, int(356 * BH)), (20, 20, 20)); t.paste(c, ((356 - c.width) // 2, (int(356 * BH) - c.height) // 2))
            teile.append((n, t)); continue
        w = int(h * BW); bot = f + int(h * (0.4 if FIG == 'wolf' else 0.12))
        teile.append((n, G.crop((x - w // 2, bot - int(w * BH), x + w // 2, bot)).resize((356, int(356 * BH)))))
    zeilen.append((titel, teile))
H = 28 + int(356 * BH) + 26
B = Image.new('RGB', (1080, H * len(zeilen)), (20, 20, 20)); d = ImageDraw.Draw(B)
for z, (titel, teile) in enumerate(zeilen):
    y = z * H
    d.text((6, y + 3), titel, fill=(240, 232, 216), font=SCHRIFT)
    for i, (n, c) in enumerate(teile):
        B.paste(c, (i * 362, y + 28))
        d.text((i * 362 + 4, y + H - 24), FELLE[int(n[-1]) - 1] if n[-1].isdigit() and int(n[-1]) <= 3 else n, fill=(240, 232, 216), font=SCHRIFT)
B.save(sys.argv[1]); print('BLATT', sys.argv[1], B.size, [(t, len(p)) for t, p in zeilen])
