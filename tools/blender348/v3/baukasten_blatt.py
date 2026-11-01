# 455.1 Probeblatt Baukasten: Streifen aus baukastenprobe.gd zu einem Blatt (2 x 2 Netze, je Netz Mann oben, Frau unten, sechs Spalten
# Material x Zeichen) mit Titel und Namen; dazu eine kleine Fassung fuer die Chefsache (JPG, hoechstens 800 px breit und 60 KB).
# Aufruf: python baukasten_blatt.py <ausgabe/baukasten> <schrift.ttf> <blatt.png> [<klein.jpg>]
import io, json, os, sys
from PIL import Image, ImageDraw, ImageFont

QUELLE, SCHRIFT, ZIEL = sys.argv[1:4]
KLEIN = sys.argv[4] if len(sys.argv) > 4 else ''
daten = json.load(open(os.path.join(QUELLE, 'lage.json')))
lage, info = daten['lage'], daten['info']
WORT = info.get('worte', {})
GOLD, WEISS, GRAU, GRUND = (212, 174, 92), (237, 230, 214), (150, 140, 120), (10, 9, 8)
f_titel = ImageFont.truetype(SCHRIFT, 40)
f_netz = ImageFont.truetype(SCHRIFT, 34)
f_name = ImageFont.truetype(SCHRIFT, 24)
ZELLE_B = 300           # Breite je Figur im Blatt
KOPF, FUSS = 40, 24     # Bildpunkte ueber dem Kopf, unter dem Fuss
QUELLE_WORT = {'robe': 'lange Robe des Zauberlehrlings (unser Netz, 376.1)', 'umhang': 'Umhang des Wachsoldaten (unser Netz), von hinten',
               'beine': 'Beine und Stiefel des Waldläufers (Quaternius, gekauft)', 'arme': 'Arme des Waldläufers (Quaternius, gekauft)'}


def streifen(name):
    p = os.path.join(QUELLE, name + '.png')
    if not os.path.exists(p) or name not in lage: return None
    b = Image.open(p).convert('RGB')
    l = lage[name]
    oben = max(0, int(min(e['kopf_y'] for e in l)) - KOPF)
    unten = min(b.height, int(max(e['boden_y'] for e in l)) + FUSS)
    zellen = []
    for i, e in enumerate(l):   # je Figur die Spalte zwischen den Mitten der Nachbarn
        links = (l[i - 1]['x'] + e['x']) / 2 if i else e['x'] - (l[1]['x'] - l[0]['x']) / 2 if len(l) > 1 else 0
        rechts = (l[i + 1]['x'] + e['x']) / 2 if i + 1 < len(l) else e['x'] + (e['x'] - links)
        z = b.crop((int(links), oben, int(rechts), unten))
        f = ZELLE_B / z.width
        zellen.append(z.resize((ZELLE_B, int(z.height * f)), Image.LANCZOS))
    h = max(z.height for z in zellen)
    c = Image.new('RGB', (ZELLE_B * len(zellen), h), GRUND)
    for i, z in enumerate(zellen): c.paste(z, (i * ZELLE_B, h - z.height))
    return c, l


def block(netz):
    teile = [(g, streifen('%s_%s' % (netz['netz'], g))) for g in ('M', 'W')]
    teile = [(g, s) for g, s in teile if s]
    if not teile: return None
    breite = max(s[0].width for _, s in teile)
    hoehe = 56 + 64 + sum(s[0].height + 8 for _, s in teile)
    c = Image.new('RGB', (breite, hoehe), GRUND)
    d = ImageDraw.Draw(c)
    d.text((16, 8), '%s: %s' % (netz['name'], QUELLE_WORT.get(netz['netz'], '')), font=f_netz, fill=GOLD)
    l = teile[0][1][1]
    for i, e in enumerate(l):   # Spaltenkopf: Material (gold), Zeichen (weiss)
        x = i * ZELLE_B + ZELLE_B // 2
        d.text((x, 60), WORT.get(e['mat'], e['mat']), font=f_name, fill=GOLD, anchor='ma')
        d.text((x, 88), WORT.get(e['zeichen'], e['zeichen']), font=f_name, fill=WEISS, anchor='ma')
    y = 120
    for g, (s, _) in teile:
        c.paste(s, (0, y))
        d.text((12, y + 8), 'Mann' if g == 'M' else 'Frau', font=f_name, fill=WEISS)
        y += s.height + 8
    d.rectangle([0, 0, c.width - 1, c.height - 1], outline=(110, 90, 50), width=2)
    return c


bloecke = [b for b in (block(n) for n in info['netze']) if b]
if not bloecke: raise SystemExit('BLATT: keine Streifen')
SP = 2
zeilen = [bloecke[i:i + SP] for i in range(0, len(bloecke), SP)]
breite = max(sum(b.width for b in z) + 16 * (len(z) + 1) for z in zeilen)
titel = ['455.1 · Baukasten: je ein vorhandenes Netz in drei Materialien × zwei Zeichen, Mann und Frau, wie im Spiel gezeichnet',
         'Nur das Farbbild wechselt, das Netz bleibt. Zeichen: Farbe mit Borte, oder Runen in Gold mit schwachem Glimmen (verzaubert). '
         'Ohne Waffen.']
hoehe = 30 + 52 * len(titel) + sum(max(b.height for b in z) + 16 for z in zeilen) + 16
c = Image.new('RGB', (breite, hoehe), GRUND)
d = ImageDraw.Draw(c)
y = 16
for i, t in enumerate(titel):
    d.text((16, y), t, font=f_titel if i == 0 else f_name, fill=GOLD if i == 0 else GRAU); y += 52
y += 14
for z in zeilen:
    x = 16
    for b in z:
        c.paste(b, (x, y)); x += b.width + 16
    y += max(b.height for b in z) + 16
c.save(ZIEL, optimize=True)
print('BLATT', ZIEL, c.size)
if KLEIN:
    k = c.resize((800, int(c.height * 800 / c.width)), Image.LANCZOS)
    for q in range(85, 20, -5):
        buf = io.BytesIO(); k.save(buf, 'JPEG', quality=q, optimize=True)
        if buf.tell() <= 60000: break
    open(KLEIN, 'wb').write(buf.getvalue())
    print('KLEIN', KLEIN, k.size, buf.tell(), 'Bytes, Guete', q)
