# 348.6 Faust: Durchblick durch die geballte Hand (Helfer: Dreiecksloch in der Faust). Aufruf: OUT=<figurordner> python -I pruef_faust.py
# -> FAUST <Seite> <Blickrichtung> loch <cm2> (Bildpunkte 0,05 cm, frei, aber ringsum von Hand umschlossen; Projektion entlang der Achse)
import bpy, os, json, bmesh, numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
OUT = os.environ['OUT']; bpy.ops.wm.open_mainfile(filepath=OUT + '/held3.blend')
J = json.load(open(OUT + '/gelenke.json'))['J']; dg = bpy.context.evaluated_depsgraph_get()
def loecher(m):
    # frei und nicht vom Rand her erreichbar (Flutung ueber 4er-Nachbarn)
    h, w = m.shape; seen = np.zeros_like(m); st = [(y, x) for y in range(h) for x in (0, w - 1)] + [(y, x) for x in range(w) for y in (0, h - 1)]
    while st:
        y, x = st.pop()
        if y < 0 or x < 0 or y >= h or x >= w or seen[y, x] or m[y, x]: continue
        seen[y, x] = True; st += [(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)]
    return (~m) & (~seen)
for s in 'RL':
    o = bpy.data.objects.get('hand' + s)
    bm = bmesh.new(); bm.from_object(o, dg); bm.transform(o.matrix_world); bt = BVHTree.FromBMesh(bm)
    wr = Vector(J['wr' + s][0]); d = (wr - Vector(J['fo' + s][0])).normalized()
    fw = (Vector((0, 0, 1)) - d * d.dot(Vector((0, 0, 1)))).normalized(); pn = d.cross(fw).normalized()
    c = sum((v.co for v in bm.verts), Vector()) / len(bm.verts); res = []
    for name, ax, u, v in (('quer', fw, d, pn), ('handruecken', pn, d, fw), ('laengs', d, fw, pn)):
        n = 200; st = 0.05; m = np.zeros((n, n), bool)
        for i in range(n):
            for k in range(n):
                p = c + u * ((i - n / 2) * st) + v * ((k - n / 2) * st) - ax * 8
                m[i, k] = bt.ray_cast(p, ax, 16)[0] is not None
        L = loecher(m); res.append('%s loch %.2f' % (name, L.sum() * st * st))
    # Hohlraum: Punkt ausserhalb der Hand, in der Kruemmungsebene (d, Handflaeche) nach allen acht Seiten binnen 3 cm Hand
    hohl = 0; st = 0.1; rr = np.arange(-40, 41) * st
    dirs = [(d * a + pn * b).normalized() for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1))]
    for a in rr:
        for b in rr:
            for e in rr:
                p = c + d * a + pn * b + fw * e
                q = bt.find_nearest(p)
                if q[0] is None or q[3] > 2.5 or (p - q[0]).dot(q[1]) < 0: continue   # innen oder weit weg
                if all(bt.ray_cast(p, r_, 3.0)[0] is not None for r_ in dirs): hohl += 1
    res.append('hohl %.2f cm3' % (hohl * st ** 3))
    print('FAUST', s, ' | '.join(res))
