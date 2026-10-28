# 348.6: Farbfehler des Abbaus ohne Bild: je Flaeche des abgebauten Netzes (<neu>/held3-rig.blend) die Farbe, die sie aus dem Albedo
# zeigt, gegen die Farbe des vollen Netzes (<voll>/held3-rig.blend, DREIECKE=0) am naechsten Punkt derselben Lage.
# Aufruf: ~/bl/bin/python -I farbfehler.py <neu> <voll> [schwelle] [teile,…]  -> Summe (Flaeche x Abweichung) je Teil, schlimmste Flaechen
import bpy, sys, json, math
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from mathutils.geometry import barycentric_transform
NEU, VOLL = sys.argv[sys.argv.index('--') + 1:][:2] if '--' in sys.argv else sys.argv[1:3]
rest = (sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else sys.argv[1:])[2:]
SCHWELLE = float(rest[0]) if rest else 0.08
NUR = set(rest[1].split(',')) if len(rest) > 1 else None

def netz(pfad):
    with bpy.data.libraries.load(pfad + '/held3-rig.blend') as (a, b): b.objects = ['Held_Netz']
    me = b.objects[0].data.copy(); me.transform(b.objects[0].matrix_world); me.transform(Matrix.Scale(100.0, 4)); me.calc_loop_triangles(); return me   # cm
from PIL import Image
TEX = np.asarray(Image.open(NEU + '/held-albedo.png').convert('RGB'), dtype=np.float32) / 255.0
H, W = TEX.shape[:2]
def farbe(u):
    x = u[0] * W - 0.5; y = (1 - u[1]) * H - 0.5
    x0, y0 = int(math.floor(x)), int(math.floor(y)); fx, fy = x - x0, y - y0
    x0 = min(max(x0, 0), W - 1); y0 = min(max(y0, 0), H - 1); x1 = min(x0 + 1, W - 1); y1 = min(y0 + 1, H - 1)
    return (TEX[y0, x0] * (1 - fx) * (1 - fy) + TEX[y0, x1] * fx * (1 - fy) + TEX[y1, x0] * (1 - fx) * fy + TEX[y1, x1] * fx * fy)
TEILE = json.load(open(NEU + '/teile.json'))
voll = netz(VOLL); neu = netz(NEU)
def teil(me):
    t = [0] * len(me.vertices); me.attributes['teil'].data.foreach_get('value', t); return t
vtl, ntl = teil(voll), teil(neu)
vuv = voll.uv_layers.active.data; nuv = neu.uv_layers.active.data
vco = [v.co.copy() for v in voll.vertices]
jt = {}
for t in voll.loop_triangles:
    if t.area > 1e-8: jt.setdefault(vtl[t.vertices[0]], []).append(t)
baum = {k: (BVHTree.FromPolygons(vco, [t.vertices[:] for t in ts]), ts) for k, ts in jt.items()}
BARY = [(1/3, 1/3, 1/3)] + [(a, b, 1 - a - b) for a, b in ((0.7, 0.15), (0.15, 0.7), (0.15, 0.15), (0.45, 0.45), (0.45, 0.1), (0.1, 0.45))]
erg = []
for t in neu.loop_triangles:
    k = ntl[t.vertices[0]]; name = TEILE[k]
    if NUR and name not in NUR: continue
    if k not in baum: continue
    b, ts = baum[k]
    P = [neu.vertices[i].co for i in t.vertices]; U = [Vector((*nuv[l].uv, 0)) for l in t.loops]
    d = []
    for w in BARY:
        x = P[0] * w[0] + P[1] * w[1] + P[2] * w[2]; u = U[0] * w[0] + U[1] * w[1] + U[2] * w[2]
        h = b.find_nearest(x)
        if h[0] is None: continue
        tv = ts[h[2]]; uv_ = barycentric_transform(h[0], *(vco[i] for i in tv.vertices), *(Vector((*vuv[l].uv, 0)) for l in tv.loops))
        if math.isnan(uv_.x): continue
        d.append(float(np.abs(farbe(u) - farbe(uv_)).mean()))
    if not d: continue
    erg.append((float(np.mean(d)), t.area, name, t.center.copy(), t.index, t.polygon_index))
summe = {}
for e, a, n, c, i, p in erg:
    if e > SCHWELLE: summe[n] = summe.get(n, 0.0) + a * e
print('FARBFEHLER Summe Flaeche x Abweichung ueber', SCHWELLE, '(cm2):', {k: round(v, 2) for k, v in sorted(summe.items(), key=lambda x: -x[1])},
      'gesamt', round(sum(summe.values()), 2))
import os
BOX = [float(x) for x in os.environ['BOX'].split(',')] if os.environ.get('BOX') else None   # x0,x1,y0,y1,z0,z1 (cm): alle Flaechen darin
if BOX: erg = [x for x in erg if BOX[0] <= x[3].x <= BOX[1] and BOX[2] <= x[3].y <= BOX[3] and BOX[4] <= x[3].z <= BOX[5]]
for e, a, n, c, i, p in sorted(erg, key=lambda x: -x[0] * x[1])[:int(os.environ.get('ZEILEN', '25'))]:
    print('  %-10s Abw %.2f Flaeche %.2f cm2 bei (%.1f, %.1f, %.1f) Polygon %d' % (n, e, a, c.x, c.y, c.z, p))
