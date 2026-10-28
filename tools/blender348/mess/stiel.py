# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
# Durchdringung: Ecken des verformten Netzes (ohne Hände und Unterarme) näher als R am Stiel der Axt, je Bewegung und Bild
import bpy, sys, json, numpy as np
from mathutils import Vector
d = sys.argv[-1]
bpy.ops.wm.open_mainfile(filepath=d + '/held3-rig.blend'); I = json.load(open(d + '/held-info.json'))
gR, aR = Vector(I['axt_hand']['griff']), Vector(I['axt_hand']['achse']).normalized()
sk = bpy.data.objects['Held_Skelett']; me_o = next(o for o in bpy.data.objects if o.type == 'MESH' and o.parent == sk)
ad = sk.animation_data; scn = bpy.context.scene
gi = {g.index: g.name for g in me_o.vertex_groups}
frei = np.array([sum(e.weight for e in v.groups if gi[e.group].startswith(('hand', 'lowerarm', 'index', 'middle', 'ring', 'pinky', 'thumb'))) > 0.5 for v in me_o.data.vertices])
mat_ = {}
for p in me_o.data.polygons:
    for i in p.vertices: mat_[i] = me_o.data.materials[p.material_index].name if me_o.data.materials else '?'
teil = {}
for v in me_o.data.vertices:
    w = max(((gi[e.group], e.weight) for e in v.groups if not gi[e.group].startswith('TEIL')), key=lambda x: x[1], default=('?', 0))[0]
    teil[v.index] = w
R = float(sys.argv[-2]) if len(sys.argv) > 2 and sys.argv[-2].replace(".", "").isdigit() else 0.025
for tr in ad.nla_tracks:
    act = tr.strips[0].action; ad.use_nla = False; ad.action = act
    if hasattr(ad, 'action_slot') and act.slots: ad.action_slot = act.slots[0]
    n = int(act.frame_range[1]); zeile = []
    for f in range(0, n + 1):
        scn.frame_set(f); dg = bpy.context.evaluated_depsgraph_get(); ev = me_o.evaluated_get(dg); m = ev.to_mesh()
        P = np.array([tuple(me_o.matrix_world @ v.co) for v in m.vertices]); ev.to_mesh_clear()
        H = sk.matrix_world @ sk.pose.bones['hand_r'].matrix
        G = np.array(H @ gR); r = np.array((H.to_3x3() @ aR).normalized())
        t = np.clip((P - G) @ r, -0.50, 0.80); dist = np.linalg.norm(P - (G + t[:, None] * r), axis=1)
        hit = (dist < R) & ~frei
        if hit.any():
            from collections import Counter
            ru = np.array([tuple(me_o.matrix_world @ me_o.data.vertices[i].co) for i in np.where(hit)[0]]).mean(0)
            zeile.append('%d:%d t%.2f..%.2f ruhe%s %s' % (f, hit.sum(), t[hit].min(), t[hit].max(), ru.round(2), dict(Counter(teil[i] + '/' + mat_.get(i, '?') for i in np.where(hit)[0]).most_common(3))))
    print('STIEL', tr.name, n + 1, 'Bilder;', len(zeile), 'mit Durchdringung', '; '.join(zeile[:40]))
