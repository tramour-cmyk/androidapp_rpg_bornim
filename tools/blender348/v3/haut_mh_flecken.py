# 2031 (Pruefer 25.11., 21:53, Lauf 860a1dced): gebackene MakeHuman-Haut ohne Flecken. Frau: roter Fleck unter Lippe und Kinn
# (Lippen- und Mundinnenrot der hm08-UV am Kinn der Kauf-UV); Mann: Stirn fleckig dunkler (Fotohaut, Stoppeln am Haaransatz).
# Je Bild (ohne Blender, nach haut_mh.py): Ortsmittel der Haut (Gauss ueber die belegten Texel, Hintergrund ausgenommen), dann
#  rot:   Gruen/Rot des Texels unter ROT des Ortsmittels -> Farbe des Ortsmittels in der Helligkeit des Texels
#  dunkel: Helligkeit unter dem Ortsmittel gestaucht (Verhaeltnis hoch DUNKEL), hell bleibt; Zeichnung bleibt, Flecken flacher
# Mittel und Bezug in der .json bleiben (Median des Gesichts aendert sich kaum; kutte_haut_2031 misst den Hautton nach).
#  gross (mit =<kaufbild>, Bild 22:53 Gesicht Orkbluetiger): Helligkeit im Grossen (Ortsmittel) wie die Kaufhaut derselben UV, Mitte gleich
# Aufruf: python3 -I haut_mh_flecken.py <bild.jpg>[=<kaufbild der gleichen UV>] [...]   (ueberschreibt; Bild aus haut_mh.py)
import os, sys
import numpy as np
from PIL import Image

RADIUS = 40        # px bei 1024, rot und dunkel: groesser als ein Fleck (bei 20 blieb der Kinnfleck der Orkfrau, Bild 23:09)
RADIUS_GROSS = 20  # px, Helligkeit der Kaufhaut: Orkstirn wie heute (bei 40 zu weich)
ROT = 0.8
DUNKEL = float(os.environ.get('DUNKEL', '0.4'))
GROSS = 2.5      # Kaufhaut-Helligkeit: Faktor hoechstens 2,5 auf oder ab

def glaetten(p, kauf=None):
    im = Image.open(p).convert('RGB')
    B = np.asarray(im, dtype=np.float32) / 255.0
    lin = np.where(B <= 0.04045, B / 12.92, ((B + 0.055) / 1.055) ** 2.4)
    belegt = (B.sum(2) > 0.06) & ~((B[..., 0] > 0.9) & (B[..., 1] < 0.1) & (B[..., 2] > 0.9))
    def kasten(a, r, ax):   # gleitendes Mittel ueber 2r+1 Texel, Rand wie aussen 0
        c = np.cumsum(np.pad(a, [(r + 1, r) if i == ax else (0, 0) for i in range(2)]), axis=ax)
        return (np.take(c, range(2 * r + 1, c.shape[ax]), axis=ax) - np.take(c, range(0, c.shape[ax] - 2 * r - 1), axis=ax)) / (2 * r + 1)
    def blur(a, r=RADIUS):   # drei Kaesten etwa Gauss mit Radius r
        a = a.astype(np.float64)
        for _ in range(3):
            a = kasten(kasten(a, r // 2, 0), r // 2, 1)
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
    if kauf:   # Bild 22:53: grossflaechige Helligkeit wie die Kaufhaut derselben UV (dort Stirn heller als die Wange, MH-Haut dunkler)
        K = np.asarray(Image.open(kauf).convert('RGB').resize(im.size), dtype=np.float32) / 255.0
        KY = np.where(K <= 0.04045, K / 12.92, ((K + 0.055) / 1.055) ** 2.4) @ np.array([0.2126, 0.7152, 0.0722], np.float32)
        bk = belegt & (K.sum(2) > 0.06)
        wk = np.maximum(blur(bk.astype(np.float32), RADIUS_GROSS), 1e-4)
        Yn = neu @ np.array([0.2126, 0.7152, 0.0722], np.float32)
        r = (blur(KY * bk, RADIUS_GROSS) / wk) / np.maximum(blur(Yn * bk, RADIUS_GROSS) / wk, 1e-4)
        r = np.clip(r / np.median(r[bk]), 1 / GROSS, GROSS)   # Mitte bleibt (Bezug der .json gilt weiter)
        neu = neu * r[..., None]
    neu = np.where(belegt[..., None], neu, lin)
    s = np.where(neu <= 0.0031308, neu * 12.92, 1.055 * np.clip(neu, 0, 1) ** (1 / 2.4) - 0.055)
    Image.fromarray((np.clip(s, 0, 1) * 255 + 0.5).astype(np.uint8)).save(p, quality=90)
    print('FLECKEN', p, 'rot', int(rot.sum()), 'dunkel', int(dunkel.sum()), 'von', int(belegt.sum()))

for a in sys.argv[1:]:
    glaetten(*a.split('='))
