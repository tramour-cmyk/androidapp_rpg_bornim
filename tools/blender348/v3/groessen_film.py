# 455.2 Groessenfilm: Bilder aus groessenprobe.gd zum Film im Hochformat (1080 x 2340): Titel, drei Streifen (Kette, Platte, Robe)
# untereinander, unter jeder Figur Volk, Geschlecht und Groesse. Wie tracht_film.py (376.1).
# Aufruf: python groessen_film.py <ausgabe/groessen> <schrift.ttf> <ziel-ordner>  ->  <ziel>/%04d.png
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

QUELLE, SCHRIFT, ZIEL = sys.argv[1:4]
os.makedirs(ZIEL, exist_ok=True)
lage = json.load(open(os.path.join(QUELLE, 'lage.json')))
GOLD, WEISS, GRUND = (212, 174, 92), (237, 230, 214), (10, 9, 8)
f_titel = ImageFont.truetype(SCHRIFT, 32)
f_reihe = ImageFont.truetype(SCHRIFT, 28)
f_name = ImageFont.truetype(SCHRIFT, 22)
BREITE, HOEHE, OBEN, UNTER = 1080, 2340, 130, 62
REIHEN = [('kette', 'Kette (Wachsoldat: Kettenhemd, Wappenrock, Umhang)'), ('platte', 'Platte (Ritter, gekauft)'),
          ('robe', 'Robe (Zauberlehrling)')]
TITEL = ('455.2 · Größen: Mensch, Hügelvolk, Orkblütiger, links Mann, rechts Frau; Kleidung über Knochenlängen mitgewachsen, '
         'kein eigenes Netz je Volk. Goldlinie = Zielgröße')


def streifen(bild, name, titel, h):
    b = bild.resize((BREITE, int(bild.height * BREITE / bild.width)))
    b = b.crop((0, max(0, (b.height - h) // 2), BREITE, max(0, (b.height - h) // 2) + h))
    c = Image.new('RGB', (BREITE, h + UNTER), GRUND)
    c.paste(b, (0, 0))
    d = ImageDraw.Draw(c)
    d.text((14, 8), titel, font=f_reihe, fill=GOLD)
    f = BREITE / bild.width
    for p in lage.get(name, []):
        e = p['eintrag']
        d.text((p['x'] * f, h + 4), e['volk'], font=f_name, fill=GOLD, anchor='ma')
        d.text((p['x'] * f, h + 30), '%s, %.2f m' % ('Mann' if e['geschlecht'] == 'M' else 'Frau', e['groesse_m']), font=f_name,
               fill=WEISS, anchor='ma')
    d.rectangle([0, 0, c.width - 1, c.height - 1], outline=(110, 90, 50), width=2)
    return c


def seite(teile):
    c = Image.new('RGB', (BREITE, HOEHE), GRUND)
    d = ImageDraw.Draw(c)
    zeile, y = '', 12
    for w in TITEL.split():
        if d.textlength(zeile + ' ' + w, font=f_titel) > BREITE - 40:
            d.text((20, y), zeile, font=f_titel, fill=GOLD); y += 38; zeile = w
        else:
            zeile = (zeile + ' ' + w).strip()
    d.text((20, y), zeile, font=f_titel, fill=GOLD)
    h = (HOEHE - OBEN) // len(teile) - UNTER
    y = OBEN
    for bild, name, titel in teile:
        c.paste(streifen(bild, name, titel, h), (0, y)); y += h + UNTER
    return c


def bilder(name):
    o = os.path.join(QUELLE, name)
    return sorted(os.path.join(o, f) for f in os.listdir(o) if f.endswith('.png')) if os.path.isdir(o) else []


reihen = [(n, t, bilder(n)) for n, t in REIHEN if bilder(n)]
nr = 0
for gleich in zip(*[r[2] for r in reihen]):
    seite([(Image.open(p).convert('RGB'), n, t) for p, (n, t, _) in zip(gleich, reihen)]).save(os.path.join(ZIEL, '%04d.png' % nr))
    nr += 1
print('GROESSEN FILM', nr, 'Bilder')
