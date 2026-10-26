import sys, numpy as np
from PIL import Image
from scipy import ndimage
S = sys.argv[1]; V = sys.argv[2] if len(sys.argv) > 2 else 'bild_neu'
L = lambda p: np.asarray(Image.open(p).convert('RGB')).astype(float)
for ort in ['kirche', 'markt', 'gras']:
  for z in ['nah', 'grund', 'weit']:
    row = []
    for st in ['morgen', 'abend']:
        f = f'{ort}_{st}_{z}.png'
        a, oh, ot = L(f'{S}/{V}/{f}'), L(f'{S}/bild_ohneheld/{f}'), L(f'{S}/bild_ohnetusche/{f}')
        dh = np.abs(ot - oh).sum(2) > 40
        lab, n = ndimage.label(dh); sizes = ndimage.sum(dh, lab, range(1, n + 1)); held = ndimage.binary_fill_holes(lab == (1 + int(np.argmax(sizes))))
        ys, xs = np.nonzero(held); cx = xs.mean()
        # nur Umriss gegen den Hintergrund: Randpunkte; Tusche im Band 10 px innen; Breite = Tuschepunkte / Randpunkte, Deckung = mittlere Abdunklung
        rand = held & ~ndimage.binary_erosion(held)
        band = held & ~ndimage.binary_erosion(held, iterations=int(sys.argv[3]) if len(sys.argv) > 3 else 10)
        dark = np.clip(ot.mean(2) - a.mean(2), 0, None)
        ink = dark > 20
        X = np.arange(held.shape[1])[None, :].repeat(held.shape[0], 0)
        res = []
        for side, k in (('L', X < cx), ('R', X >= cx)):
            p = (rand & k).sum(); i = (band & ink & k).sum()
            res.append(f'{side} {i / max(p, 1):.1f}px/{dark[band & ink & k].mean() if i else 0:.0f}')
        row.append(f'{st}: ' + ' '.join(res))
    print(ort, z, ' | '.join(row))
