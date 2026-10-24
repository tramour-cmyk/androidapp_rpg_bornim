# Setzt die Endbilder zusammen: nah, karte, drehung, vergleich (png + jpg <= 60 KB)
import os, io
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

O = '/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/'
BILD = '/home/user/bornim-main/docs/chefsache/bilder/'
try:
    FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15)
    FONTS = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 12)
except Exception:
    FONT = FONTS = ImageFont.load_default()

def foot_y(fig):
    a = np.array(fig)[..., 3]
    rows = np.where(a.max(1) > 0)[0]
    return rows.max()

def stage(fig, bg_top, bg_bot, pad=(24, 16, 24, 20), shadow=True, scale_shadow=1.0):
    """Figur auf Grund mit Verlauf und weichem Bodenschatten."""
    l, t, r, b = pad
    W, H = fig.width + l + r, fig.height + t + b
    g = np.linspace(0, 1, H)[:, None, None]
    arr = (np.array(bg_top)[None, None] * (1 - g) + np.array(bg_bot)[None, None] * g) * np.ones((H, W, 1))
    img = Image.fromarray(arr.astype(np.uint8), 'RGB').convert('RGBA')
    if shadow:
        fy = foot_y(fig) + t
        sh = Image.new('L', (W, H), 0); d = ImageDraw.Draw(sh)
        cx = l + fig.width // 2; rx = fig.width * 0.32 * scale_shadow; ry = rx * 0.28
        d.ellipse((cx - rx, fy - ry, cx + rx, fy + ry), fill=120)
        sh = sh.filter(ImageFilter.GaussianBlur(max(1, rx * 0.12)))
        dark = Image.new('RGBA', (W, H), (10, 8, 6, 255)); img = Image.composite(dark, img, sh)
    img.alpha_composite(fig, (l, t))
    return img.convert('RGB')

# 1. nah
nah = Image.open(O + 'n.png')
stage(nah, (22, 24, 30), (46, 40, 32)).save(O + 'held-blender-nah.png')

# 2. karte: Grund wie die Gebietskarte, Originalgroesse und zweifach
k = Image.open(O + 'k.png')
grass_t, grass_b = (70, 84, 50), (62, 76, 44)
k1 = stage(k, grass_t, grass_b, pad=(12, 8, 12, 10), scale_shadow=0.9)
k2 = k1.resize((k1.width * 2, k1.height * 2), Image.NEAREST)
W = k1.width + k2.width + 30; H = k2.height + 30
sheet = Image.new('RGB', (W, H), (18, 16, 20)); d = ImageDraw.Draw(sheet)
sheet.paste(k1, (10, 24)); sheet.paste(k2, (k1.width + 20, 24))
d.text((10, 5), 'Originalgröße', fill=(220, 210, 190), font=FONTS)
d.text((k1.width + 20, 5), 'zweifach', fill=(220, 210, 190), font=FONTS)
sheet.save(O + 'held-blender-karte.png')

# 3. drehung: 8 Richtungen
fr = [Image.open(O + 'd%d.png' % y) for y in range(0, 360, 45)]
cells = [stage(f, (22, 24, 30), (46, 40, 32), pad=(4, 4, 4, 22)) for f in fr]
W = sum(c.width for c in cells); H = cells[0].height
strip = Image.new('RGB', (W, H)); x = 0; d = ImageDraw.Draw(strip)
for i, c in enumerate(cells):
    strip.paste(c, (x, 0)); d.text((x + c.width // 2 - 12, H - 18), '%d°' % (i * 45), fill=(200, 180, 120), font=FONTS); x += c.width
strip.save(O + 'drehung.png')

# 4. vergleich: heute (348-1 links), mit Tusche (348-2 rechts), Blender (Karte, zweifach)
a = Image.open(BILD + '348-1-held.jpg').convert('RGB').crop((40, 40, 330, 460))
b = Image.open(BILD + '348-2-held.jpg').convert('RGB').crop((470, 30, 700, 391))
kt = stage(k, grass_t, grass_b, pad=(6, 4, 6, 6), scale_shadow=0.9)
c = kt.resize((kt.width * 2, kt.height * 2), Image.NEAREST)
Hc = 400
def fit(im):
    return im.resize((round(im.width * Hc / im.height), Hc), Image.LANCZOS)
cols = [(fit(a), 'heute'), (fit(b), 'mit Tusche (348.2)'), (fit(c), 'Blender')]
W = sum(i.width for i, _ in cols) + 10 * (len(cols) + 1); H = Hc + 34
v = Image.new('RGB', (W, H), (18, 16, 20)); d = ImageDraw.Draw(v); x = 10
for im, lab in cols:
    v.paste(im, (x, 8))
    tw = d.textlength(lab, font=FONT)
    d.text((x + (im.width - tw) / 2, Hc + 13), lab, fill=(220, 200, 140), font=FONT)
    x += im.width + 10
v.save(O + 'vergleich.png')
for q in range(85, 20, -5):
    buf = io.BytesIO(); v.save(buf, 'JPEG', quality=q, optimize=True)
    if buf.tell() <= 60 * 1024:
        open(O + 'vergleich.jpg', 'wb').write(buf.getvalue()); print('jpg q', q, buf.tell()); break
for f in ['held-blender-nah.png', 'held-blender-karte.png', 'drehung.png', 'vergleich.png', 'vergleich.jpg']:
    im = Image.open(O + f); print(f, im.size, os.path.getsize(O + f))
