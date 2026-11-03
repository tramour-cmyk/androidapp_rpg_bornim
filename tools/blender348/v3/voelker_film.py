# 431 Runde 3: Bilder aus voelkerprobe.gd zum Film zusammensetzen (Hochformat 1080 breit): Titel, Bild, darunter je Figur die Zahlen aus
# voelker.json gegen Homers Ziel (430). Aufruf: python voelker_film.py <ausgabe/voelker> <schrift.ttf> <ziel-ordner>  ->  <ziel>/%04d.png
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

QUELLE, SCHRIFT, ZIEL = sys.argv[1:4]
os.makedirs(ZIEL, exist_ok=True)
lage = json.load(open(os.path.join(QUELLE, 'lage.json')))
GOLD, WEISS, GRUND = (212, 174, 92), (237, 230, 214), (10, 9, 8)
f_titel = ImageFont.truetype(SCHRIFT, 34)
f_zahl = ImageFont.truetype(SCHRIFT, 22)
f_feld = ImageFont.truetype(SCHRIFT, 28)


def k(x, n=2):
    return ('%.*f' % (n, x)).replace('.', ',')


def zahlen(e):
    if e.get('volk') == 'Goblin': return ['Goblin', '(Jerry)']
    z = e['ziel']
    t = [e['volk'], '%d cm' % round(e['groesse_m'] * 100)]
    t.append('Kopf 1/%s' % k(e['kopf_1_durch'], 1) + (' (%s)' % k(1 / z['kopf'], 1) if 'kopf' in z else ''))
    t.append('Beine %s' % k(e['bein_anteil']) + (' (%s)' % k(z['bein']) if 'bein' in z else ''))
    if 'schulter' in z:
        art, f = z['schulter']
        ist = e['schulter_gegen_mensch'] if art == 'abs' else e['schulter_rel_gegen_mensch']
        t.append('Schulter %s (%s)%s' % (k(ist), k(f), '' if art == 'abs' else '*'))
    return t


def feld(bild, teil, titel):
    # Bild mit Feldtitel oben links und Zahlen darunter
    h = 175
    c = Image.new('RGB', (bild.width, bild.height + h), GRUND)
    c.paste(bild, (0, 0))
    d = ImageDraw.Draw(c)
    d.text((14, 10), titel, font=f_feld, fill=GOLD, stroke_width=3, stroke_fill=(0, 0, 0))
    for p in lage.get(teil, []):
        for i, z in enumerate(zahlen(p['eintrag'])):
            d.text((p['x'], bild.height + 8 + i * 27), z, font=f_zahl, fill=GOLD if i == 0 else WEISS, anchor='ma')
    d.rectangle([0, 0, c.width - 1, c.height - 1], outline=(110, 90, 50), width=2)
    return c


def seite(titel, felder):
    hoehe = 120 + sum(f.height for f in felder)
    c = Image.new('RGB', (1080, hoehe), GRUND)
    d = ImageDraw.Draw(c)
    # Titel umbrechen
    worte, zeile, y = titel.split(), '', 14
    for w in worte:
        if d.textlength(zeile + ' ' + w, font=f_titel) > 1040:
            d.text((20, y), zeile, font=f_titel, fill=GOLD); y += 42; zeile = w
        else:
            zeile = (zeile + ' ' + w).strip()
    d.text((20, y), zeile, font=f_titel, fill=GOLD)
    y = 120
    for f in felder:
        c.paste(f, (0, y)); y += f.height
    return c


def bilder(teil):
    o = os.path.join(QUELLE, teil)
    return sorted(os.path.join(o, f) for f in os.listdir(o) if f.endswith('.png')) if os.path.isdir(o) else []


nr = 0
GROESSE = None
def raus(c):
    global nr, GROESSE
    if GROESSE is None: GROESSE = c.size
    if c.size != GROESSE:   # alle Bilder gleich gross (ffmpeg)
        n = Image.new('RGB', GROESSE, GRUND); n.paste(c, (0, 0)); c = n
    c.save(os.path.join(ZIEL, '%04d.png' % nr)); nr += 1

T1 = ('431 · Völker Runde 3: Grundkörper je Volk im Spiel (Licht, Tusche), Ork auf Superheld, übrige Regulär; in Klammern Homers Ziel; '
      'Schulter gegen den Menschen, * im Verhältnis zur Größe; Goldstrich = Größe')
m, w = bilder('maenner'), bilder('frauen')
for a, b in zip(m, w):
    raus(seite(T1, [feld(Image.open(a).convert('RGB'), 'maenner', 'Männer'), feld(Image.open(b).convert('RGB'), 'frauen', 'Frauen (7 % kleiner)')]))
T2 = '431 · Hügelvolk neben Goblin (Verwechslung bei gleicher Größe: Kopf, Haltung; Haut noch ungetönt), Mensch als Maßstab'
for a in bilder('huegel'):
    raus(seite(T2, [feld(Image.open(a).convert('RGB'), 'huegel', 'Hügelvolk und Goblin')]))
T3 = '431 · Schattenriss ohne Ausrüstung (Homer: „am Schattenriss erkennbar, welches Volk“): oben von vorn, unten von der Seite'
for a, b in zip(bilder('riss_vorn'), bilder('riss_seite')):
    raus(seite(T3, [feld(Image.open(a).convert('RGB'), 'riss_vorn', 'von vorn'), feld(Image.open(b).convert('RGB'), 'riss_seite', 'von der Seite')]))
print('VOELKER FILM', nr, 'Bilder', GROESSE)
