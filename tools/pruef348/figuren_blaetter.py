# 376.1: Blaetter aus den Standbildern von figurenprobe.gd (reihe), wie die erste Runde: Spalten mit Kopfzeile
import sys, os
from PIL import Image, ImageDraw, ImageFont
A, Z = sys.argv[1], sys.argv[2]
f = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 30)
def spalten(teile, ziel, breite=732, kopf=60):
    ims = [Image.open(os.path.join(A, p)).convert('RGB') for p, _ in teile]
    ims = [im.resize((breite, round(im.height * breite / im.width)), Image.LANCZOS) for im in ims]
    h = max(im.height for im in ims)
    b = Image.new('RGB', (breite * len(ims), h + kopf), (0, 0, 0)); d = ImageDraw.Draw(b)
    for i, (im, (_, t)) in enumerate(zip(ims, teile)):
        b.paste(im, (i * breite, kopf)); d.text((i * breite + 12, 12), t, font=f, fill=(214, 178, 92))
    b.save(ziel, quality=88)
def zeilen(teile, ziel, kopf=44):
    ims = [Image.open(os.path.join(A, p)).convert('RGB') for p, _ in teile]
    b = Image.new('RGB', (max(i.width for i in ims), sum(i.height + kopf for i in ims)), (0, 0, 0)); d = ImageDraw.Draw(b); y = 0
    for im, (_, t) in zip(ims, teile):
        d.text((12, y + 6), t, font=f, fill=(214, 178, 92)); b.paste(im, (0, y + kopf)); y += im.height + kopf
    b.save(ziel, quality=88)
spalten([('reihe_grund.png', 'Tag'), ('reihe_nacht.png', 'Nacht'), ('reihe_weit.png', 'weit')], Z + '-reihe.jpg')
spalten([('reihe_nah_1.png', 'nah 1'), ('reihe_nah_2.png', 'nah 2'), ('reihe_nah_3.png', 'nah 3')], Z + '-nah.jpg')
zeilen([('reihe_menue_1.png', 'Menülicht 1'), ('reihe_menue_2.png', 'Menülicht 2')], Z + '-menue.jpg')
print('BLAETTER OK')
