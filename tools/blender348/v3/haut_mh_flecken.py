# 2031 (Pruefer 25.11., 21:53, Lauf 860a1dced): gebackene MakeHuman-Haut ohne Flecken. Frau: roter Fleck unter Lippe und Kinn
# (Lippen- und Mundinnenrot der hm08-UV am Kinn der Kauf-UV); Mann: Stirn fleckig dunkler (Fotohaut, Stoppeln am Haaransatz).
# Je Bild (ohne Blender, nach haut_mh.py): Ortsmittel der Haut (Gauss ueber die belegten Texel, Hintergrund ausgenommen), dann
#  rot:   Gruen/Rot des Texels unter ROT des Ortsmittels -> Farbe des Ortsmittels in der Helligkeit des Texels
#  dunkel: Helligkeit unter dem Ortsmittel gestaucht (Verhaeltnis hoch DUNKEL), hell bleibt; Zeichnung bleibt, Flecken flacher
# Mittel und Bezug in der .json bleiben (Median des Gesichts aendert sich kaum; kutte_haut_2031 misst den Hautton nach).
# Aufruf: python3 -I haut_mh_flecken.py <bild.jpg> [...]   (ueberschreibt; Bild aus haut_mh.py)
import os, sys
import numpy as np
from PIL import Image

RADIUS = int(os.environ.get('RADIUS', '40'))      # px bei 1024: groesser als ein Fleck, kleiner als ein Gesicht
ROT = 0.8
DUNKEL = float(os.environ.get('DUNKEL', '0.4'))

def glaetten(p):
    im = Image.open(p).convert('RGB')
    B = np.asarray(im, dtype=np.float32) / 255.0
    lin = np.where(B <= 0.04045, B / 12.92, ((B + 0.055) / 1.055) ** 2.4)
    belegt = (B.sum(2) > 0.06) & ~((B[..., 0] > 0.9) & (B[..., 1] < 0.1) & (B[..., 2] > 0.9))
    def kasten(a, r, ax):   # gleitendes Mittel ueber 2r+1 Texel, Rand wie aussen 0
        c = np.cumsum(np.pad(a, [(r + 1, r) if i == ax else (0, 0) for i in range(2)]), axis=ax)
        return (np.take(c, range(2 * r + 1, c.shape[ax]), axis=ax) - np.take(c, range(0, c.shape[ax] - 2 * r - 1), axis=ax)) / (2 * r + 1)
    def blur(a):   # drei Kaesten etwa Gauss mit RADIUS
        a = a.astype(np.float64)
        for _ in range(3):
            a = kasten(kasten(a, RADIUS // 2, 0), RADIUS // 2, 1)
        return a.astype(np.float32)
    w = blur(belegt.astype(np.float32))
    ort = np.stack([blur(lin[..., k] * belegt) for k in range(3)], 2) / np.maximum(w, 1e-4)[..., None]
    Y = lin @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    Yo = np.maximum(ort @ np.array([0.2126, 0.7152, 0.0722], np.float32), 1e-4)
    q = Y / Yo
    rot = belegt & (lin[..., 1] / np.maximum(lin[..., 0], 1e-4) < ROT * ort[..., 1] / np.maximum(ort[..., 0], 1e-4))
    neu = lin.copy()
    neu[rot] = ort[rot] * q[rot][:, None]
    dunkel = belegt & (q < 1.0)
    neu[dunkel] = neu[dunkel] * (q[dunkel] ** (DUNKEL - 1.0))[:, None]   # Helligkeit q -> q^DUNKEL
    neu = np.where(belegt[..., None], neu, lin)
    s = np.where(neu <= 0.0031308, neu * 12.92, 1.055 * np.clip(neu, 0, 1) ** (1 / 2.4) - 0.055)
    Image.fromarray((np.clip(s, 0, 1) * 255 + 0.5).astype(np.uint8)).save(p, quality=90)
    print('FLECKEN', p, 'rot', int(rot.sum()), 'dunkel', int(dunkel.sum()), 'von', int(belegt.sum()))

for p in sys.argv[1:]:
    glaetten(p)
