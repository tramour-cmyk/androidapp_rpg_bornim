# 431 Runde 3 und 4: Bilder aus voelkerprobe.gd zum Film zusammensetzen (Hochformat 1080 breit): Titel, Bild, darunter je Figur die Zahlen aus
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
    if e.get('volk') in ('Goblin', 'Grak'): return [e['volk'], '(Jerry)']
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
    # Pruefer Runde 3 und Lauf 41430558274 (G1: nur „Mensch“ lesbar, nicht unter seiner Figur, der Rest rechts aus dem Bild): Godot
    # misst unproject_position in einem anderen Massstab als das gespeicherte Bild (Mitte der Reihe bei 1755 statt 540). Die Kamera
    # steht auf der Mitte der Reihe, also liegt deren Mittel in der Bildmitte: Massstab = Bildbreite / (2 x Mittel)
    ps = lage.get(teil, [])
    mx = sum(p['x'] for p in ps) / len(ps) if ps else bild.width / 2
    sx = bild.width / (2 * mx) if mx > 0 else 1.0
    for p in ps:
        for i, z in enumerate(zahlen(p['eintrag'])):
            d.text((p['x'] * sx, bild.height + 8 + i * 27), z, font=f_zahl, fill=GOLD if i == 0 else WEISS, anchor='ma')
    d.rectangle([0, 0, c.width - 1, c.height - 1], outline=(110, 90, 50), width=2)
    return c


KOPF = 160   # Pruefer Lauf 41430558274 (G1: dritte Titelzeile vom Bild verdeckt): Platz fuer drei Zeilen (14 + 3 x 42)


def seite(titel, felder):
    hoehe = KOPF + sum(f.height for f in felder)
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
    y = KOPF
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

T1 = ('431 · Völker Runde 4: Ohren, Hauer, Hautfarbe, Haltung, Bart und Zöpfe des Zwergs, im Spiel (Licht, Tusche); in Klammern '
      'Homers Ziel; Schulter gegen den Menschen, * im Verhältnis zur Größe; Goldstrich = Größe')
m, w = bilder('maenner'), bilder('frauen')
for a, b in zip(m, w):
    raus(seite(T1, [feld(Image.open(a).convert('RGB'), 'maenner', 'Männer'), feld(Image.open(b).convert('RGB'), 'frauen', 'Frauen (7 % kleiner)')]))
T2 = '431 · Hügelvolk neben Goblin (Verwechslung bei gleicher Größe: Kopf, Haltung, Haut), Mensch als Maßstab'
for a in bilder('huegel'):
    raus(seite(T2, [feld(Image.open(a).convert('RGB'), 'huegel', 'Hügelvolk und Goblin')]))
T4 = '431b · Ohren und Hauer als ein Teil: Elf, Hügelvolk, Orkblütiger neben Goblin und Grak (Jerry)'
for a in bilder('familie'):
    raus(seite(T4, [feld(Image.open(a).convert('RGB'), 'familie', 'Familie und Unterschied')]))
T3 = '431 · Schattenriss ohne Ausrüstung (Homer: „am Schattenriss erkennbar, welches Volk“): oben von vorn, unten von der Seite'
for a, b in zip(bilder('riss_vorn'), bilder('riss_seite')):
    raus(seite(T3, [feld(Image.open(a).convert('RGB'), 'riss_vorn', 'von vorn'), feld(Image.open(b).convert('RGB'), 'riss_seite', 'von der Seite')]))
print('VOELKER FILM', nr, 'Bilder', GROESSE)
