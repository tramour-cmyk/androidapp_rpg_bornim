# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
# Speer der Kobolde wie figur.gd _hold (Goblin-Zweig): Achse in Stehen Bild 0 fest zur Figur, danach mit der Hand
import bpy, sys, json, numpy as np
from mathutils import Vector
d, kit = sys.argv[-2], sys.argv[-1]
bpy.ops.wm.open_mainfile(filepath=d + '/held3-rig.blend'); I = json.load(open(d + '/held-info.json')); M = json.load(open(d + '/goblin-masse.json'))
sk = bpy.data.objects['Held_Skelett']; o = next(x for x in bpy.data.objects if x.type == 'MESH' and x.parent == sk)
ad = sk.animation_data; scn = bpy.context.scene
gi = {g.index: g.name for g in o.vertex_groups}
kopf = np.array([sum(e.weight for e in v.groups if gi[e.group] in ('Head', 'neck_01')) > 0.5 for v in o.data.vertices])
S = 0.8; HI, VO = 0.40 * S, 0.66 * S
def setze(nm, f):
    ad.use_nla = False; ad.action = ad.nla_tracks[nm].strips[0].action
    if hasattr(ad, 'action_slot') and ad.action.slots: ad.action_slot = ad.action.slots[0]
    scn.frame_set(f); bpy.context.view_layer.update()
    return sk.matrix_world @ sk.pose.bones['hand_r'].matrix
H0 = setze('Stehen', 0)
inward = Vector((1, 0, 0)); ax0 = (-inward * 0.1 + Vector((0, 0, 1)) * 0.6 + Vector((0, -1, 0)) * 0.8).normalized()
loc_ax = H0.to_3x3().inverted() @ ax0
loc_g = Vector((0, M['griff_hand_m'], 0)) + H0.to_3x3().inverted() @ inward * M['handflaeche_m']
for nm in ('Stehen', 'Gehen', 'Hieb'):
    n = int(ad.nla_tracks[nm].strips[0].action.frame_range[1]); z = []
    for f in range(0, n + 1, 2):
        H = setze(nm, f); dg = bpy.context.evaluated_depsgraph_get(); m = o.evaluated_get(dg).to_mesh()
        P = np.array([tuple(o.matrix_world @ v.co) for v in m.vertices])
        g = H @ loc_g; a = (H.to_3x3() @ loc_ax).normalized()
        G, A = np.array(g), np.array(a)
        t = np.clip((P - G) @ A, -HI, VO); dist = np.linalg.norm(P - (G + t[:, None] * A), axis=1)
        spitze = g + a * VO
        import math
        z.append('%d:%s%.0f°/%.2f' % (f, 'K%d ' % (kopf & (dist < 0.015)).sum() if (kopf & (dist < 0.015)).any() else '', math.degrees(math.asin(max(-1, min(1, a.z)))), spitze.z))
    print('SPEER', kit, nm, ' '.join(z))
