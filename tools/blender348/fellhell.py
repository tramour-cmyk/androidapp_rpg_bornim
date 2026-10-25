# 348.9 (Jerry): Helligkeit je Fell alt gegen neu: alt = Bildpunkte ungleich Hintergrund je Zeile des Entwurfs, neu = Bildpunkte, die mit GLUEH=1 roter werden.
# Aufruf: python3 fellhell.py <alt.png> <neu.png> <neu-GLUEH.png>  (Lagen der Ratten fest wie im Wolfsrudel)
import sys, numpy as np
from PIL import Image
alt, neu, gl = sys.argv[1:4]
L = lambda a: (0.299*a[...,0]+0.587*a[...,1]+0.114*a[...,2])
A = np.asarray(Image.open(alt).convert('RGB')).astype(float)
bg = np.array([0x3A,0x3E,0x36])
for i, n in enumerate(['braun','grau','schwarz']):
    sub = A[i*250:(i+1)*250, :]
    m = np.abs(sub-bg).sum(-1) > 12
    m[:20] = False
    px = sub[m]; print('alt', n, 'Median', round(float(np.median(L(px))),1), 'Mittel', round(float(L(px).mean()),1), 'Sätt', round(float((px.max(1)-px.min(1)).mean()),1))
N = np.asarray(Image.open(neu).convert('RGB')).astype(float); G = np.asarray(Image.open(gl).convert('RGB')).astype(float)
m = (G[...,0]-N[...,0]) > 25
for n, x, f, k in [('braun',781,674,576),('grau',840,946,821),('schwarz',469,814,702)]:
    h=f-k; box = np.zeros_like(m); box[f-int(h*1.6):f+5, x-int(h*1.6):x+int(h*1.6)] = True
    mm = m & box; px = N[mm]
    print('neu', n, 'Punkte', int(mm.sum()), 'Median', round(float(np.median(L(px))),1), 'Mittel', round(float(L(px).mean()),1), 'Sätt', round(float((px.max(1)-px.min(1)).mean()),1))
