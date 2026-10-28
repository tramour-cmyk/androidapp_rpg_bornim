# 348.6 Leute Runde 4c: Bein durch den Rock zaehlen. Aufruf: OUT=<figurordner> python -I pruef_rock.py (nach rig.py)
# Bein durch den Rock: je Gehen-Bild die Ecken des Unterschenkels (Gewicht >= 0,95 auf Wade/Knoechel/Fuss) ueber dem Saum,
# die waagerecht nach aussen keine Rockflaeche vor sich haben
import bpy, os, numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
O = os.environ['OUT']; bpy.ops.wm.open_mainfile(filepath=O + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']; net = bpy.data.objects['Held_Netz']
gi = {g.index: g.name for g in net.vertex_groups}
TR = ('pelvis-waist', 'waist-belly', 'belly-chest', 'chest-chestTop')
n = len(net.data.vertices); legw = np.zeros(n); trw = np.zeros(n); thw = np.zeros(n)
for v in net.data.vertices:
    for e in v.groups:
        nm = gi[e.group]
        if nm.startswith(('knee', 'calf', 'ankle', 'ball', 'foot')): legw[v.index] += e.weight   # CC0 (Runde 3): calf_l, foot_l, ball_l
        if nm in TR or nm in ('pelvis', 'spine_01', 'spine_02', 'spine_03'): trw[v.index] += e.weight
        if nm.startswith(('hip', 'thigh')) and not nm.startswith('hip-'): thw[v.index] += e.weight
R0 = np.array([tuple(v.co) for v in net.data.vertices])
rock = (trw > 0.02) & (thw > 0.02)
leg = legw >= 0.95
if not rock.any(): print('ROCK', os.path.basename(O), 'kein Rock'); raise SystemExit
sc = 100.0 if R0[:, 2].max() < 5 else 1.0
saum = R0[rock, 2].min()
faces = [tuple(p.vertices) for p in net.data.polygons if all(rock[k] for k in p.vertices)]
acts = {t.name: t.strips[0].action for t in rig.animation_data.nla_tracks}
for t in rig.animation_data.nla_tracks: t.mute = True
act = acts['Gehen']; rig.animation_data.action = act
f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
res = []
for f in range(f0, f1, 2):
    scn.frame_set(f)
    dg = bpy.context.evaluated_depsgraph_get(); e = net.evaluated_get(dg); m = e.to_mesh()
    V = np.array([tuple(v.co) for v in m.vertices]); e.to_mesh_clear()
    bv = BVHTree.FromPolygons([tuple(x) for x in V], faces)
    cnt = 0
    for i in np.where(leg & (R0[:, 2] > saum + 3 / sc))[0]:
        p = Vector(V[i]); d = Vector((p.x, p.y, 0))
        if d.length < 1e-6: continue
        d.normalize()
        if bv.ray_cast(p, d)[0] is None: cnt += 1
    res.append(cnt)
print('ROCK', os.path.basename(O), 'Ecken %d, frei je Bild max %d summe %d' % ((leg & (R0[:, 2] > saum + 3 / sc)).sum(), max(res), sum(res)), res)
