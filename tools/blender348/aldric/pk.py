# Toon-Nachbearbeitung: Licht in drei Stufen mal Grundfarbe, Tuschelinien aus Tiefe/Normale/Material, Dicke nach Licht.
# Aufruf: python3 post.py <name> <ausgabe.png> [karte]  -> RGBA in Endgroesse (halbe Renderaufloesung)
import sys, json, time
import numpy as np
from PIL import Image

D = '/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/aldric/passes/'
name, outp = sys.argv[1], sys.argv[2]
karte = len(sys.argv) > 3 and sys.argv[3] == 'karte'
t0 = time.time()
ld = lambda m: np.load(D + name + '/' + m + '.npy')
import os
INK = ld('ink')[..., 0] if os.path.exists(D + name + '/ink.npy') else None
light = ld('light'); alb = ld('albedo'); nor = ld('normal'); dep = ld('depth'); idp = ld('id')
meta = json.load(open(D + name + '/meta.json'))
A = idp[..., 3] > 0.5
ID = np.where(A, np.round(idp[..., 0]), 0).astype(int)
Z = np.where(A, dep[..., 0], 1e5)
N = nor[..., :3] * 2 - 1
L = light[..., 0]
Hh, Ww = L.shape

# ---- Licht in drei Stufen (Sonne Staerke 1: voll beleuchtet ~ 1)
lmax = np.percentile(L[A], 99.5) if A.any() else 1
Ln = L / max(lmax, 1e-6)
lev = np.where(Ln > 0.5, 2, np.where(Ln > 0.16, 1, 0))
lev[~A] = 2
def srgb2lin(c): return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
def lin2srgb(c): c = np.clip(c, 0, 1); return np.where(c <= 0.0031308, c * 12.92, 1.055 * c ** (1 / 2.4) - 0.055)
tint = np.array([[0.30, 0.34, 0.46],   # Schatten: kuehles Blauschwarz
                 [0.66, 0.64, 0.66],   # Mitte
                 [1.06, 1.00, 0.90]])  # Licht: warm
col = alb[..., :3] * tint[lev]
# Gold ist der einzige Glanz
ldir = np.array(meta['ldir']); view = np.array(meta['view'])
hv = ldir + view; hv /= np.linalg.norm(hv)
spec = np.clip((N @ hv), 0, 1) ** 30
gold = (ID == 8)
col = np.where((gold & (spec > 0.45) & (lev == 2))[..., None], col * 0.4 + np.array([1.0, 0.86, 0.55]) * 0.9, col)

# ---- Kanten
def nb(a, dy, dx, fill):
    o = np.full_like(a, fill)
    ys = slice(max(dy, 0), Hh + min(dy, 0)); yd = slice(max(-dy, 0), Hh + min(-dy, 0))
    xs = slice(max(dx, 0), Ww + min(dx, 0)); xd = slice(max(-dx, 0), Ww + min(-dx, 0))
    o[yd, xd] = a[ys, xs]
    return o
sil = np.zeros_like(A); inner = np.zeros_like(A); crease = np.zeros_like(A)
zt = 2.5 if not karte else 4.0
for dy, dx in ((0, 1), (1, 0), (0, -1), (-1, 0)):
    An = nb(A, dy, dx, False); IDn = nb(ID, dy, dx, 0); Zn = nb(Z, dy, dx, 1e5); Nn = nb(N, dy, dx, 0.0)
    sil |= A & ~An
    nearer = Z <= Zn
    inner |= A & An & (IDn != ID) & nearer
    # Tiefensprung (zweite Ableitung gegen schraege Flaechen)
    Z2 = nb(Z, -dy, -dx, 1e5)
    jump = (np.abs(Zn + Z2 - 2 * Z) > zt) & (Zn - Z > zt * 0.6)
    inner |= A & An & jump
    crease |= A & An & ((N * Nn).sum(-1) < 0.55) & nearer & (IDn == ID)
# Kettenhemd-Ringe und Gesichtsmalerei geben keine Linien (nur Farbe); Gesichtszuege bekommen eigene feine Linien nicht
s = 2.0  # doppelte Aufloesung
if karte:
    wl = np.array([0.55, 0.75, 1.2]) * s * 0.5
else:
    wl = np.array([0.45, 0.85, 1.35]) * s       # Radius in Renderpixeln: Licht, Mitte, Schatten (Schatten 3x)
wlev = np.array([wl[2], wl[1], wl[0]])[lev]   # lev 2 = Licht -> duenn
rng = np.random.default_rng(7)
g = rng.random((Hh // 24 + 2, Ww // 24 + 2))
wob = np.kron(g, np.ones((24, 24)))[:Hh, :Ww]
# weich glätten
for _ in range(3):
    wob = (wob + nb(wob, 0, 6, 0.5) + nb(wob, 6, 0, 0.5) + nb(wob, 0, -6, 0.5) + nb(wob, -6, 0, 0.5)) / 5
wob = 0.8 + 0.4 * wob
R = np.zeros((Hh, Ww))
R = np.where(crease, wlev * 0.75, R)
if INK is not None:
    R = np.where(A & (INK > 0.45), np.maximum(R, wlev * np.where((ID == 31) | (ID == 32), 0.32, 0.5)), R)
R = np.where(inner, wlev, R)
R = np.where(sil, wlev * 1.3, R)
# duenne Dinge (Klinge, Parierstange) duenn umranden, Gratlinien der Klinge weglassen
thin = (ID == 12) | (ID == 13)
R = np.where(thin & crease & ~sil & ~inner, 0, R)
R = np.where(thin, np.minimum(R, wl[0] * 1.1), R)
R = R * wob * (R > 0)
# variable Dilatation mit weicher Kante
ink = np.zeros((Hh, Ww))
rmax = int(np.ceil(R.max())) + 1
for dy in range(-rmax, rmax + 1):
    for dx in range(-rmax, rmax + 1):
        dd = np.hypot(dx, dy)
        cov = np.clip(R - dd + 0.5, 0, 1)
        cov[R == 0] = 0
        ink = np.maximum(ink, nb(cov, -dy, -dx, 0.0))
inkcol = np.array([0.012, 0.009, 0.008])  # Tusche: warmes Schwarzbraun
col = col * (1 - ink[..., None]) + inkcol * ink[..., None]
alpha = np.maximum(A.astype(float), ink)

# ---- auf Endgroesse (2x2 Mittel, vormultipliziert)
def down(a):
    return a.reshape(Hh // 2, 2, Ww // 2, 2, *a.shape[2:]).mean(axis=(1, 3))
pm = col * alpha[..., None]
pm2 = down(pm); a2 = down(alpha)
c2 = np.where(a2[..., None] > 1e-4, pm2 / np.maximum(a2[..., None], 1e-4), 0)
rgb = lin2srgb(c2)
img = np.dstack([rgb, a2])
Image.fromarray((img * 255 + 0.5).astype(np.uint8), 'RGBA').save(outp)
print('POST OK', outp, img.shape, round(time.time() - t0, 1), 'render', round(meta['secs'], 1))
