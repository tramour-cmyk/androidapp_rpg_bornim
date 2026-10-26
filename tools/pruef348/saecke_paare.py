import sys, os, random, numpy as np
from PIL import Image
from scipy import ndimage
S = sys.argv[1]; out = S + '/paare'; os.system(f'rm -rf {out}'); os.makedirs(out)
random.seed(11); key = []; mess = []
L = lambda x: x.mean(2)
for f in sorted(os.listdir(S + '/bild_mag')):
    if 'markt' not in f: continue
    m = np.asarray(Image.open(f'{S}/bild_mag/{f}').convert('RGB')).astype(int)
    r, g, b = m[..., 0], m[..., 1], m[..., 2]
    sack = (r > g + 60) & (b > g + 60)            # magenta Koerper
    ring = (g > r + 50) & (g > b + 50)            # gruener Fussring
    lab, n = ndimage.label(ndimage.binary_dilation(sack, iterations=6))
    A = np.asarray(Image.open(f'{S}/bild_alt/{f}').convert('RGB')).astype(int)
    B = np.asarray(Image.open(f'{S}/bild_neu/{f}').convert('RGB')).astype(int)
    for i, s in enumerate(ndimage.find_objects(lab)):
        if (lab[s] > 0).sum() < 60: continue
        cy, cx = (s[0].start + s[0].stop) // 2, (s[1].start + s[1].stop) // 2
        h = max(s[0].stop - s[0].start, s[1].stop - s[1].start) + 40
        y0, y1, x0, x1 = max(0, cy - h), cy + h, max(0, cx - h), cx + h
        # Hof: Punkte ausserhalb von Sack und Ring bis 14 px Abstand, Helligkeit gegen Boden 20-40 px
        mk = (sack | ring)[y0:y1, x0:x1]; dist = ndimage.distance_transform_edt(~mk)
        nah, fern = (dist > 0) & (dist <= 14), (dist > 20) & (dist <= 40)
        def hof(X):
            l = L(X[y0:y1, x0:x1]); boden = np.median(l[fern])
            band = [(l[(dist > k - 1) & (dist <= k)] < boden * 0.6).mean() for k in range(1, 15)]
            return sum(1 for v in band if v > 0.3), boden
        ha, hb = hof(A), hof(B)
        ringpx = int(ring[y0:y1, x0:x1].sum())
        name = f'{f[:-4]}_{i}'
        mess.append(f'{name}: Hof alt {ha[0]} px, neu {hb[0]} px (dunkler als 60 % des Bodens in >30 % des Saums), Ring sichtbar {ringpx} px')
        ca, cb = Image.fromarray(A[y0:y1, x0:x1].astype(np.uint8)), Image.fromarray(B[y0:y1, x0:x1].astype(np.uint8))
        z = max(1, 360 // ca.width)
        ca, cb = ca.resize((ca.width * z, ca.height * z), Image.LANCZOS), cb.resize((cb.width * z, cb.height * z), Image.LANCZOS)
        na = random.random() < 0.5
        (cb if na else ca).save(f'{out}/{name}_A.png'); (ca if na else cb).save(f'{out}/{name}_B.png')
        key.append(f'{name} neu={"A" if na else "B"} kasten x{x0}-{x1} y{y0}-{y1} {z}x')
open(S + '/schluessel.txt', 'w').write('\n'.join(key) + '\n'); open(S + '/hof.txt', 'w').write('\n'.join(mess) + '\n')
print('\n'.join(mess))
