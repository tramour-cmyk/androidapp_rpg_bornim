# 348.6 Hand am Schild (Helfer: Schildrand schneidet durch die linke Hand): je Bewegung und Bild die Ecken der Haende, die im Schild
# liegen (Strahl nach oben trifft den Schild ungerade oft), und der kleinste Abstand Hand-Schild. Ohne Bild.
# Helfer an HANDNAH (27.10.): die Bahn durch die linke Hand ist nicht der Schild (25 cm weg), sondern roter Stoff: TEIL=tabard, cloak …
# Aufruf: OUT=<figurordner> [TEIL=shield] python -I pruef_schild.py (nach held3.py und rig.py) -> Zeilen SCHILD <teil> <bewegung> {...}
import bpy, os, json
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; sk = bpy.data.objects['Held_Skelett']; me_o = bpy.data.objects['Held_Netz']
tn = json.load(open(OUT + '/teile.json')); ti_ = np.zeros(len(me_o.data.vertices), np.int32)
me_o.data.attributes['teil'].data.foreach_get('value', ti_); TEIL = np.array([tn[i] for i in ti_])
F = [tuple(p.vertices) for p in me_o.data.polygons]
TN = os.environ.get('TEIL', 'shield')
SE = set(np.where(TEIL == TN)[0].tolist()); SF = [f for f in F if all(i in SE for i in f)]
HAND = {s: np.where(TEIL == 'hand' + s)[0] for s in 'LR'}
def netz():
    dg = bpy.context.evaluated_depsgraph_get(); ev = me_o.evaluated_get(dg); m = ev.to_mesh()
    V = np.array([tuple(ev.matrix_world @ v.co) for v in m.vertices]); ev.to_mesh_clear(); return V
def innen(bv, p):
    n, o, d = 0, Vector(p), Vector((0.0123, 0.0071, 1.0)).normalized()
    while True:
        h = bv.ray_cast(o, d, 1.0)
        if h[0] is None: return n % 2 == 1
        n += 1; o = h[0] + d * 1e-5
res = {}
acts = {t.name: t.strips[0].action for t in sk.animation_data.nla_tracks}
for an, act in acts.items():
    for t in sk.animation_data.nla_tracks: t.mute = True
    sk.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    r = {}
    for s, idx in HAND.items():
        drin, wo, dmin = 0, None, 9.0
        for f in range(f0, f1 + 1):
            scn.frame_set(f); V = netz(); bv = BVHTree.FromPolygons([tuple(x) for x in V], SF)
            k = sum(innen(bv, V[i]) for i in idx)
            d = min(bv.find_nearest(Vector(V[i]))[3] for i in idx)
            dmin = min(dmin, d)
            if k > drin: drin, wo = k, f
        r['hand' + s] = dict(drin=drin, von=len(idx), bild=wo, abstand_cm=round(dmin * 100, 1))
    res[an] = r; print('SCHILD', TN, an, json.dumps(r))
json.dump(res, open(OUT + '/pruef_schild_%s.json' % TN, 'w'), indent=1)
