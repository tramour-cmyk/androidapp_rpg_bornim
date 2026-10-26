# 348.6 Feinschliff 10: zaehlt in den Teilfarben-Bildern (pruefblatt.py TEILFARBE=1, <OUT>/pbt) je Bild die Pixel je Lage, vorn und
# Rueckseite (Blick in die Schale). In den Schulterbildern k_* sind Koerper (Loch in der Kleidung) und jede Rueckseite Fehler.
# Aufruf: python3 pruef_farbe.py <figurordner>…  -> FARBE <figur> <bild> {lage: n, lage_innen: n}
import sys, os, json
import numpy as np
from PIL import Image
def srgb(c): c = np.clip(c, 0, 1); return np.where(c <= 0.0031308, 12.92 * c, 1.055 * c ** (1 / 2.4) - 0.055) * 255
F = {'koerper': (1, 0, 0), 'kittel': (0, 0.8, 0), 'aermel': (0, 0.3, 1), 'rock': (1, 1, 0), 'schuerze': (1, 0.5, 0), 'sonst': (0.5, 0.5, 0.5)}
NAM, REF = ['grund'], [srgb(np.array((0.02, 0.02, 0.02)))]
for n, c in F.items():
    for suf, k in (('', 1.0), ('_innen', 0.25)): NAM.append(n + suf); REF.append(srgb(np.array(c) * k))
REF = np.array(REF)
for d in sys.argv[1:]:
    ges = {}
    for f in sorted(os.listdir(d + '/pbt')):
        if not f.startswith(('k_', 'h_')): continue
        a = np.array(Image.open(d + '/pbt/' + f).convert('RGB')).reshape(-1, 3).astype(float)
        k = np.argmin(((a[:, None, :] - REF[None]) ** 2).sum(2), 1); n = np.bincount(k, minlength=len(NAM))
        z = {NAM[i]: int(n[i]) for i in range(1, len(NAM)) if n[i] and (NAM[i] == 'koerper' or NAM[i].endswith('_innen'))}
        for kk, v in z.items(): ges[kk] = ges.get(kk, 0) + v if f.startswith('k_') else ges.get(kk, 0)
        print('FARBE', os.path.basename(d), f[:-4], json.dumps(z))
    print('FARBE', os.path.basename(d), 'SUMME k_*', json.dumps(ges))
