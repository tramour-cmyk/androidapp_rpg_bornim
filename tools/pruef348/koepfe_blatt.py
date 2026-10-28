# 376.1 Kopfblatt aus figurenprobe.gd --teil=koepfe: drei Zeilen zu fuenf Koepfen (Form, Bart, Haar und Farbe) mit Beschriftung,
# darunter die letzte Zeile in der Spielansicht nah, auf Wunsch eine Zeile Halsfassungen (Bild=Beschriftung ...).
# Aufruf: koepfe_blatt.py <bilder> <koepfe.txt> <ziel.jpg> [<bild.png>=<text> ...]
import sys, os
from PIL import Image, ImageDraw, ImageFont
A, T, Z = sys.argv[1:4]
EXTRA = [a.split('=', 1) for a in sys.argv[4:]]
FASSUNG = os.environ.get('FASSUNG', '')   # 376.1 Halszacken: kopf_<k>_<FASSUNG>.png aus figurenprobe.gd zacken()
f = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 21)   # Pruefer 20:49: 26 lief ins Nachbarfeld
zeilen = [l.rstrip('\n').split('|') for l in open(T) if l.strip()]   # q_k99 (Hals A) steht nicht in der Liste
W, H, KOPF, SP = 400, 470, 44, 5
reihen = [zeilen[i:i + SP] for i in range(0, len(zeilen), SP)]
spiel = Image.open(os.path.join(A, 'koepfe_spiel.png')).convert('RGB')
spiel = spiel.resize((W * SP, round(spiel.height * W * SP / spiel.width)), Image.LANCZOS)
b = Image.new('RGB', (W * SP, len(reihen) * (H + KOPF) + spiel.height + KOPF + ((H + KOPF) if EXTRA else 0)), (0, 0, 0)); d = ImageDraw.Draw(b)
for r, reihe in enumerate(reihen):
    for c, z in enumerate(reihe):
        im = Image.open(os.path.join(A, 'kopf_%s%s.png' % (z[0], '_' + FASSUNG if FASSUNG else ''))).convert('RGB').resize((W, H), Image.LANCZOS)
        y = r * (H + KOPF)
        b.paste(im, (c * W, y + KOPF)); d.text((c * W + 10, y + 9), z[7], font=f, fill=(214, 178, 92))
y = len(reihen) * (H + KOPF)
d.text((10, y + 9), 'Spielansicht nah: untere Reihe nebeneinander', font=f, fill=(214, 178, 92))
b.paste(spiel, (0, y + KOPF))
y += KOPF + spiel.height
for c, (pf, t) in enumerate(EXTRA):
    b.paste(Image.open(pf).convert('RGB').resize((W, H), Image.LANCZOS), (c * W, y + KOPF)); d.text((c * W + 10, y + 9), t, font=f, fill=(214, 178, 92))
b.save(Z, quality=88)
print('KOPFBLATT OK', Z, b.size)
