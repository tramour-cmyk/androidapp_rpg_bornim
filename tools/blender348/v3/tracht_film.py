# 376.1 Tracht je Herkunft: Bilder aus trachtprobe.gd zum Film im Hochformat (1080 x 2340) zusammensetzen: Titel, drei Streifen
# untereinander, unter jeder Figur Herkunft, Statur, Bewegung. Wie voelker_film.py (431).
# Aufruf: python tracht_film.py <ausgabe/trachten> <schrift.ttf> <ziel-ordner>  ->  <ziel>/%04d.png
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

QUELLE, SCHRIFT, ZIEL = sys.argv[1:4]
os.makedirs(ZIEL, exist_ok=True)
lage = json.load(open(os.path.join(QUELLE, 'lage.json')))
ANSICHT = lage.pop('_ansicht', None)   # Spike 01.11. (455.1 Lauf 41321140618): Lage in Ansichtspunkten (3510 x 2340), nicht in Bildpunkten
GOLD, WEISS, GRUND = (212, 174, 92), (237, 230, 214), (10, 9, 8)
f_titel = ImageFont.truetype(SCHRIFT, 32)
f_name = ImageFont.truetype(SCHRIFT, 24)
BREITE, HOEHE, OBEN, UNTER = 1080, 2340, 120, 72   # 463a G1 (Pruefer Lauf 1, 22:4x): Unterlaengen der zweiten Zeile am Rahmen und am Bildrand abgeschnitten
HERKUNFT = {'WACHSOLDAT': 'Wachsoldat', 'ZAUBERLEHRLING': 'Zauberlehrling', 'KLOSTERSCHUELER': 'Klosterschüler', 'JAEGERKIND': 'Jägerkind',
            'HERUMTREIBER': 'Herumtreiber', 'WANDERER': 'Wanderer, Kräutersammler,', 'KRAEUTERSAMMLER': 'Kräutersammler',
            'SCHMIEDELEHRLING': 'Schmiedelehrling'}
STATUR = {'schlank': 'Schlank', 'normal': 'Normal', 'kraeftig': 'Kräftig'}   # 463 (Pruefer 23:03: ohne „Normal“ und „Frau“)
TITEL = {   # 376.1 Urteil Tracht (Chef 01.11., 20:2x): zweite Runde nur Umhang und Robe (trachtprobe.gd)
    'umhang': '463 · Umhang des Wachsoldaten geschlossen: oben Mann, Mitte Frau (Schlank, Normal, Kräftig), unten Gehen',
    'robe': '463 · Robe des Zauberlehrlings geschlossen: oben Mann, Mitte Frau (Schlank, Normal, Kräftig), unten Gehen',
}


def zeilen(e):
    a = [HERKUNFT.get(e['herkunft'], e['herkunft'])]
    if e['herkunft'] == 'WANDERER': a.append('Schmiedelehrling')
    g = {'m': 'Mann', 'w': 'Frau'}.get(str(e.get('geschlecht', '')).lower(), '')
    zu = [x for x in (g, STATUR.get(e['statur'], ''), '' if e['bewegung'] == 'Stehen' else e['bewegung']) if x]
    if zu: a.append(', '.join(zu))
    return a


def streifen(bild, name, h):
    # 463a G1 (Pruefer Film 16:0x: Sohlen an der Beschriftungsleiste angeschnitten): ganzes Bild in den Streifen einpassen statt oben
    # und unten abschneiden; schmaler als BREITE, dann mittig mit Rand
    s = min(BREITE / bild.width, h / bild.height)
    b = bild.resize((int(bild.width * s), int(bild.height * s)))
    x0 = (BREITE - b.width) // 2
    c = Image.new('RGB', (BREITE, h + UNTER), GRUND)
    c.paste(b, (x0, (h - b.height) // 2))
    d = ImageDraw.Draw(c)
    f = b.width / (ANSICHT[0] if ANSICHT else bild.width)   # Pruefer 376.1: Beschriftung falsch
    for p in lage.get(name, []):
        z = zeilen(p['eintrag'])
        for i, t in enumerate(z[:2]):
            d.text((x0 + p['x'] * f, h + 4 + i * 28), t, font=f_name, fill=GOLD if i == 0 else WEISS, anchor='ma')
    d.rectangle([0, 0, c.width - 1, c.height - 1], outline=(110, 90, 50), width=2)
    return c


def seite(titel, teile):
    c = Image.new('RGB', (BREITE, HOEHE), GRUND)
    d = ImageDraw.Draw(c)
    worte, zeile, y = titel.split(), '', 12
    for w in worte:
        if d.textlength(zeile + ' ' + w, font=f_titel) > BREITE - 40:
            d.text((20, y), zeile, font=f_titel, fill=GOLD); y += 38; zeile = w
        else:
            zeile = (zeile + ' ' + w).strip()
    d.text((20, y), zeile, font=f_titel, fill=GOLD)
    h = (HOEHE - OBEN - 6) // len(teile) - UNTER
    y = OBEN
    for bild, name in teile:
        c.paste(streifen(bild, name, h), (0, y)); y += h + UNTER
    return c


def bilder(name):
    o = os.path.join(QUELLE, name)
    return sorted(os.path.join(o, f) for f in os.listdir(o) if f.endswith('.png')) if os.path.isdir(o) else []


nr = 0
for s in TITEL:
    namen = sorted(n for n in lage if n.startswith(s + '_'))
    reihen = [bilder(n) for n in namen]
    for gleich in zip(*reihen):
        seite(TITEL[s], [(Image.open(p).convert('RGB'), n) for p, n in zip(gleich, namen)]).save(os.path.join(ZIEL, '%04d.png' % nr))
        nr += 1
print('TRACHT FILM', nr, 'Bilder')
