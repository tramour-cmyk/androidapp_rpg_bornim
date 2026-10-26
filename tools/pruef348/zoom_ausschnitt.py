import sys, os
from PIL import Image, ImageDraw, ImageFont
import numpy as np
from scipy import ndimage
S = sys.argv[1]; ort = sys.argv[2]; ziel = sys.argv[3]; T = int(sys.argv[4])
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
zooms = [('nah', 3.4, 'nah'), ('grund', 9.0, 'Grundansicht'), ('weit', 14.4, 'weit')]
rows = [('morgen', 'Morgen'), ('abend', 'Abend')]
img = Image.new('RGB', (3 * T + 4, 24 + 2 * (T + 20)), (12, 12, 12)); d = ImageDraw.Draw(img)
for j, (_, _, zl) in enumerate(zooms): d.text((j * (T + 2) + 6, 4), zl, fill=(214, 184, 110), font=font)
for i, (st, rl) in enumerate(rows):
    y = 24 + i * (T + 20); d.text((6, y), rl, fill=(230, 226, 214), font=font)
    for j, (z, m, _) in enumerate(zooms):
        im = Image.open(f'{S}/bild_neu/{ort}_{st}_{z}.png').convert('RGB')
        c = int(1080 * 2.6 / m)    # 2,6 m um den Helden (Lage aus dem Bild ohne Helden)
        ot = np.asarray(Image.open(f'{S}/bild_ohnetusche/{ort}_{st}_{z}.png').convert('RGB')).astype(float)
        oh = np.asarray(Image.open(f'{S}/bild_ohneheld/{ort}_{st}_{z}.png').convert('RGB')).astype(float)
        dh = np.abs(ot - oh).sum(2) > 40; lab, n = ndimage.label(dh); sz = ndimage.sum(dh, lab, range(1, n + 1))
        ys, xs = np.nonzero(lab == 1 + int(np.argmax(sz))); cx, cy = int(np.median(xs)), int((ys.min() + ys.max()) / 2)
        t = im.crop((cx - c // 2, cy - c // 2, cx + c // 2, cy + c // 2)).resize((T, T), Image.LANCZOS)
        img.paste(t, (j * (T + 2), y + 18))
img.save(ziel, quality=int(os.environ.get('Q', 60))); print(ziel, img.size, os.path.getsize(ziel))
