#!/usr/bin/env python3
# 376.1: Raster-Film aus figurenprobe.gd (--teil=film): je Feld ein Ausschnitt, nummeriert, Chef je Feld ja/nein.
# Aufruf: python3 -I figuren_film.py <ausgabe von figurenprobe>/film <ziel.mp4> [spalten]
# Zweimal in Echtzeit mit kurzer Pause, dann vierfach langsamer (Leiste oben); Schleifen laufen ohne Naht weiter, Einzelbewegungen halten das Ende.
import os, sys, subprocess, tempfile
from PIL import Image, ImageDraw, ImageFont

FILM, ZIEL = sys.argv[1], sys.argv[2]
SP = int(sys.argv[3]) if len(sys.argv) > 3 else 3
# Helfer Film 14:58: auf 280 px verkleinert verschwand die Tusche (1 Bildpunkt); 0,8-fach, drei Spalten, Hochformat wie das Handy
W, H, KOPF, LEISTE = 448, 720, 44, 40
NAMEN = {'held': 'unser Held (Runde 7)', 'q_held': 'Quaternius Held', 'q_bauer': 'Quaternius Bauer'}
felder = []
zeilen = {l.split(' ')[0]: l.strip() for l in open(os.path.join(FILM, 'felder.txt')) if l.strip()}
for d in sorted(os.listdir(FILM)):
    p = os.path.join(FILM, d)
    if not os.path.isdir(p): continue
    nr, rest = d.split('_', 1)
    fig, bew = rest.rsplit('_', 1)
    bilder = sorted(os.path.join(p, f) for f in os.listdir(p) if f.endswith('.png'))
    schleife = bew in ('Stehen', 'Gehen', 'Rennen', 'Sitzen', 'Gesten', 'Kampfstehen')
    quelle = zeilen.get(nr, '').split(': ', 1)[-1].split(',')[0] if bilder else 'keine Bewegung in der UAL'
    felder.append((nr, fig, bew, bilder, schleife, quelle))
n = max((len(f[3]) for f in felder), default=1)
ZL = (len(felder) + SP - 1) // SP
try:
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 17)
    klein = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 13)
except OSError:
    font = klein = ImageFont.load_default()
tmp = tempfile.mkdtemp()
cache = {}
# Helfer Film 14:58: Schleifen ruckten beim Neubeginn jedes Durchlaufs (Laenge 50, 75, 81 statt 90): Schleifen zaehlen ueber den ganzen
# Film weiter (j), Einzelbewegungen beginnen je Durchlauf neu und halten vorher kurz das Ende; Leiste oben sagt Echtzeit oder Zeitlupe
HALT = 15
folge = []   # (Bild der Einzelbewegung i, Schleifenzaehler in Bildern, Leiste)
for d in range(2):
    folge += [(i, len(folge) + 0.0, 'Echtzeit, Durchlauf %d von 2' % (d + 1)) for i in range(n)]
    folge += [(n - 1, len(folge) + 0.0, 'Echtzeit, Pause') for _ in range(HALT)]
z0 = len(folge)
folge += [(i // 4, z0 + i / 4.0, 'Zeitlupe, vierfach langsamer') for i in range(4 * n)]
for fnr, (i, jz, leiste) in enumerate(folge):
    bild = Image.new('RGB', (SP * W, LEISTE + ZL * (H + KOPF)), (12, 10, 8))
    dr = ImageDraw.Draw(bild)
    dr.text((10, 8), leiste, font=font, fill=(214, 178, 92))
    for j, (nr, fig, bew, bilder, schleife, quelle) in enumerate(felder):
        x, y = (j % SP) * W, LEISTE + (j // SP) * (H + KOPF)
        dr.rectangle([x, y, x + W - 1, y + KOPF - 1], fill=(0, 0, 0))
        dr.text((x + 6, y + 3), '%s  %s' % (int(nr), bew), font=font, fill=(214, 178, 92))
        dr.text((x + 6, y + 24), '%s · %s' % (NAMEN.get(fig, fig), quelle), font=klein, fill=(220, 214, 200))
        if not bilder:
            dr.text((x + 20, y + KOPF + H // 2), 'fehlt', font=font, fill=(160, 60, 50))
            continue
        k = int(jz) % len(bilder) if schleife else min(i, len(bilder) - 1)
        p = bilder[k]
        if p not in cache:
            if len(cache) > 400: cache.clear()
            cache[p] = Image.open(p).convert('RGB').resize((W, H), Image.LANCZOS)
        bild.paste(cache[p], (x, y + KOPF))
        dr.rectangle([x, y + KOPF, x + W - 1, y + KOPF + H - 1], outline=(70, 58, 30))
    bild.save(os.path.join(tmp, 'f%05d.png' % fnr))
# als Bildfolge mit fester Rate (Helfer: concat mit Dauern liess je 6 Bilder eines aus)
subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-framerate', '30', '-i', os.path.join(tmp, 'f%05d.png'), '-vf', 'format=yuv420p',
                '-c:v', 'libx264', '-crf', '18', '-g', '60', '-movflags', '+faststart', ZIEL], check=True)
Image.open(os.path.join(tmp, 'f%05d.png' % (n // 2))).save(ZIEL.rsplit('.', 1)[0] + '_mitte.png')
print('FILM', ZIEL, n, 'Bilder je Durchlauf,', len(felder), 'Felder')
