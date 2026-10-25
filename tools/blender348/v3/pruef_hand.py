# 348.6 Leute Runde 4c: Luecke Hand-Aermelende messen (cm entlang des Unterarms ab Handgelenk). Aufruf: OUT=<figurordner> python -I pruef_hand.py (nach held3.py)
import bpy, os, json, numpy as np
O = os.environ['OUT']; bpy.ops.wm.open_mainfile(filepath=O + '/held3.blend')
J = json.load(open(O + '/gelenke.json'))['J']
def V(n):
    o = bpy.data.objects.get(n)
    if not o: return None
    dg = bpy.context.evaluated_depsgraph_get(); e = o.evaluated_get(dg); m = e.to_mesh()
    a = np.array([tuple(o.matrix_world @ v.co) for v in m.vertices]); e.to_mesh_clear(); return a
names = [o.name for o in bpy.data.objects if o.type == 'MESH']
out = []
for s in 'RL':
    wr = np.array(J['wr' + s][0]); fo = np.array(J['fo' + s][0]); d = (wr - fo) / np.linalg.norm(wr - fo)
    h = V('hand' + s); hp = (h - wr) @ d
    res = [os.path.basename(O), s, 'hand oben %.1f' % hp.min()]
    for n in ('sleeves', 'body', 'cloak', 'robe'):
        a = V(n)
        if a is None: continue
        r = np.linalg.norm((a - wr) - np.outer((a - wr) @ d, d), axis=1)
        sel = (r < 7) & (((a - wr) @ d) > -15)
        if sel.any(): res.append('%s unten %.1f' % (n, ((a[sel] - wr) @ d).max()))
    out.append(' '.join(res))
print('HAND', ' | '.join(out))
print('NAMEN', ' '.join(sorted(names)))
