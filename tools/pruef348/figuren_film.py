#!/usr/bin/env python3
# 376.1: Raster-Film aus figurenprobe.gd (--teil=film): je Feld ein Ausschnitt, nummeriert, Chef je Feld ja/nein.
# Aufruf: python3 -I figuren_film.py <ausgabe von figurenprobe>/film <ziel.mp4> [spalten]
# Einmal in Echtzeit (zweimal hintereinander), dann vierfach langsamer; Schleifen laufen weiter, Einzelbewegungen halten das Ende.
import os, sys, subprocess, tempfile
from PIL import Image, ImageDraw, ImageFont

FILM, ZIEL = sys.argv[1], sys.argv[2]
SP = int(sys.argv[3]) if len(sys.argv) > 3 else 5
W, H, KOPF = 280, 380, 44
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
for i in range(n):
    bild = Image.new('RGB', (SP * W, ZL * (H + KOPF)), (12, 10, 8))
    dr = ImageDraw.Draw(bild)
    for j, (nr, fig, bew, bilder, schleife, quelle) in enumerate(felder):
        x, y = (j % SP) * W, (j // SP) * (H + KOPF)
        dr.rectangle([x, y, x + W - 1, y + KOPF - 1], fill=(0, 0, 0))
        dr.text((x + 6, y + 3), '%s  %s' % (int(nr), bew), font=font, fill=(214, 178, 92))
        dr.text((x + 6, y + 24), '%s · %s' % (NAMEN.get(fig, fig), quelle), font=klein, fill=(220, 214, 200))
        if not bilder:
            dr.text((x + 20, y + KOPF + H // 2), 'fehlt', font=font, fill=(160, 60, 50))
            continue
        k = i % len(bilder) if schleife else min(i, len(bilder) - 1)
        p = bilder[k]
        if p not in cache:
            if len(cache) > 400: cache.clear()
            cache[p] = Image.open(p).convert('RGB').resize((W, H), Image.LANCZOS)
        bild.paste(cache[p], (x, y + KOPF))
        dr.rectangle([x, y + KOPF, x + W - 1, y + KOPF + H - 1], outline=(70, 58, 30))
    bild.save(os.path.join(tmp, '%04d.png' % i))
# Echtzeit zweimal, dann vierfach langsamer; als Bildfolge mit fester Rate (Helfer: concat mit Dauern liess je 6 Bilder eines aus)
folge = [i for _ in range(2) for i in range(n)] + [i for i in range(n) for _ in range(4)]
for j, i in enumerate(folge): os.symlink(os.path.join(tmp, '%04d.png' % i), os.path.join(tmp, 'f%05d.png' % j))
subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-framerate', '30', '-i', os.path.join(tmp, 'f%05d.png'), '-vf', 'format=yuv420p',
                '-c:v', 'libx264', '-crf', '18', '-g', '60', '-movflags', '+faststart', ZIEL], check=True)
Image.open(os.path.join(tmp, '%04d.png' % (n // 2))).save(ZIEL.rsplit('.', 1)[0] + '_mitte.png')
print('FILM', ZIEL, n, 'Bilder je Durchlauf,', len(felder), 'Felder')
