#!/usr/bin/env python3
# 2028 (Nora): Tafel alt oben gegen neu unten aus zwei Bildern von godot/tests/bild_2028.gd (Spielkamera 1080x2340, Kamera.NAH).
# Je Zeile: Ausschnitt um die Figur (Handgelenke rot umkreist), rechts je Handgelenk ein Ausschnitt 3-fach.
# Aufruf: python3 tools/godot/bild_2028_tafel.py <aus.webp> <Titel> "<alt.png>|<Zeile BILD2028>|<Beschriftung>" "<neu.png>|<Zeile>|<Beschriftung>"
import sys, re
from PIL import Image, ImageDraw, ImageFont

FENSTER = 40      # halbe Seite des Handgelenk-Ausschnitts in Bildpunkten des Spielbilds
B = 800

def schrift(g):
    for f in ('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'):
        try: return ImageFont.truetype(f, g)
        except OSError: pass
    return ImageFont.load_default()

def zeile(arg):
    datei, z, text = arg.split('|')
    w = dict((m.group(1), (int(m.group(2)), int(m.group(3)))) for m in re.finditer(r'(hand_l|hand_r|Fuss|Scheitel) (-?\d+) (-?\d+)', z))
    im = Image.open(datei).convert('RGB')
    # Ausschnitt um die Figur: Scheitel bis Fuss und etwas Rand, volle Breite bleibt Handybreite (1080)
    oben = max(0, w['Scheitel'][1] - 140); unten = min(im.height, w['Fuss'][1] + 60)
    links = max(0, w['Fuss'][0] - 380); rechts = min(im.width, w['Fuss'][0] + 380)
    aus = im.crop((links, oben, rechts, unten))
    k = 520 / aus.width
    klein = aus.resize((520, int(aus.height * k)), Image.LANCZOS)
    d = ImageDraw.Draw(klein)
    lupen = []
    for h in ('hand_r', 'hand_l'):   # hand_r liegt im Bild links (Figur blickt zur Kamera)
        x, y = w[h]
        cx, cy = (x - links) * k, (y - oben) * k
        r = FENSTER * k
        d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=(230, 30, 30), width=3)
        lu = im.crop((x - FENSTER, y - FENSTER, x + FENSTER, y + FENSTER)).resize((FENSTER * 6, FENSTER * 6), Image.NEAREST)
        ImageDraw.Draw(lu).rectangle((0, 0, lu.width - 1, lu.height - 1), outline=(230, 30, 30), width=3)
        lupen.append((h, lu))
    return text, klein, lupen

def main():
    ziel, titel, *zeilen = sys.argv[1:]
    teile = [zeile(z) for z in zeilen]
    hoehe = 60 + sum(34 + max(t[1].height, 2 * (t[2][0][1].height + 26)) + 16 for t in teile) + 10
    tafel = Image.new('RGB', (B, hoehe), (24, 22, 20))
    d = ImageDraw.Draw(tafel)
    d.text((12, 10), titel, fill=(240, 220, 160), font=schrift(22))
    d.text((12, 38), 'Spielkamera Handy 1080x2340, nächster Zoom, von vorn · rot: Handgelenke · rechts: Ausschnitt 3-fach', fill=(200, 200, 200), font=schrift(13))
    y = 66
    for text, klein, lupen in teile:
        d.text((12, y), text, fill=(255, 255, 255), font=schrift(18))
        y += 30
        tafel.paste(klein, (10, y))
        ly = y
        for h, lu in lupen:
            d.text((548, ly), 'rechtes Handgelenk' if h == 'hand_r' else 'linkes Handgelenk', fill=(220, 220, 220), font=schrift(13))
            tafel.paste(lu, (548, ly + 18))
            ly += lu.height + 26
        y += max(klein.height, ly - y) + 16
    tafel = tafel.crop((0, 0, B, y))
    tafel.save(ziel, quality=80)
    print('TAFEL', ziel, tafel.size)

main()
