import sys, numpy as np
from PIL import Image
from scipy import ndimage
S=sys.argv[1]; V=sys.argv[2]   # V: Bilder mit magentafarbener Tusche (Shaderkopie: ALPHA = step(0.3, …), ALBEDO magenta)
L = lambda p: np.asarray(Image.open(p).convert('RGB')).astype(float)
for ort in ['kirche','markt','gras']:
  for z in ['nah','grund','weit']:
    out=[]
    for st in ['morgen','abend']:
        f=f'{ort}_{st}_{z}.png'
        a, oh, ot = L(f'{S}/{V}/{f}'), L(f'{S}/bild_ohneheld/{f}'), L(f'{S}/bild_ohnetusche/{f}')
        dh = np.abs(ot - oh).sum(2) > 40
        lab, n = ndimage.label(dh); sizes = ndimage.sum(dh, lab, range(1, n + 1)); held = ndimage.binary_fill_holes(lab == (1 + int(np.argmax(sizes))))
        mag = (a[...,0]-a[...,1]>50)&(a[...,2]-a[...,1]>50)
        ys = np.nonzero(held.any(1))[0]; Lr=[]; Rr=[]
        for y in ys[len(ys)//8: -len(ys)//8]:   # ohne Kopf und Fuesse
            xs = np.nonzero(held[y])[0]; x0, x1 = xs.min(), xs.max()
            k=0
            while x0+k<=x1 and mag[y,x0+k]: k+=1
            Lr.append(k); k=0
            while x1-k>=x0 and mag[y,x1-k]: k+=1
            Rr.append(k)
        out.append(f'{st}: L {np.mean(Lr):.1f} R {np.mean(Rr):.1f}')
    print(ort,z,' | '.join(out))
