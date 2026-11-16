# 656 (Chef 08.11., 14:52: „Beulen in dem Mantel … vor allem unter dem Schlagarm … eine riesen Beule darunter“): wie weit der Umhang
# dem Arm folgt, ohne Bild. (1) Armanteil der Gewichte je Umhangecke nach Hoehe unter dem Schultergelenk; (2) Verschiebung der
# Umhangecken im Rahmen von spine_03 zwischen haengenden Armen (Idle_Loop) und Bewegungen mit gehobenem Arm (T-Pose der Kauffigur,
# Sword_Attack, wahlweise mehr); gezaehlt, wie viele Ecken unter der Achsel mehr als 5 / 10 cm wandern (Beule).
# Aufruf: FIG=<ordner/kennung.blend> UAL=<UAL1*.glb> TEILE=<teile.json> bl/bin/python -I pruef_umhang_arm.py -> Zeilen UMHANG ARM …
import bpy, os, json
import numpy as np
FIG = os.environ['FIG']; UAL = os.environ['UAL']
BEW = os.environ.get('BEW', 'Ruhe,Sword_Attack,Sword_Idle,Idle_Talking_Loop').split(',')
bpy.ops.wm.open_mainfile(filepath=FIG)
qa = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
kleid = bpy.data.objects['Kleid']
TN = json.load(open(os.environ['TEILE']))
tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
UM = np.where(tl == TN.index('cloak'))[0]
gi = {g.index: g.name for g in kleid.vertex_groups}
ARM = ('upperarm', 'lowerarm', 'hand')
P0 = np.array([tuple(kleid.matrix_world @ kleid.data.vertices[i].co) for i in UM])
armw = np.array([sum(e.weight for e in kleid.data.vertices[i].groups if gi.get(e.group, '').startswith(ARM)) /
                 max(1e-9, sum(e.weight for e in kleid.data.vertices[i].groups if gi.get(e.group, '') in qa.data.bones)) for i in UM])
sh = max((qa.matrix_world @ qa.data.bones[b].head_local).z for b in ('upperarm_l', 'upperarm_r'))
print('UMHANG ARM ECKEN', len(UM), 'Schultergelenk %.3f m' % sh)
for a, b in ((0.0, 0.1), (0.1, 0.2), (0.2, 0.3), (0.3, 0.5), (0.5, 2.0)):
    m = (P0[:, 2] <= sh - a) & (P0[:, 2] > sh - b)
    if m.any(): print('UMHANG ARM GEWICHT %.1f-%.1f m unter der Schulter: %d Ecken, Arm > 10 %%: %d, Mittel %.3f, hoechstens %.2f' % (
        a, b, m.sum(), int((armw[m] > 0.1).sum()), armw[m].mean(), armw[m].max()))
vorher = set(bpy.data.actions)
bpy.ops.import_scene.gltf(filepath=UAL)
for o in [o for o in bpy.data.objects if o not in (qa, kleid) and o.parent != qa and o.type in ('ARMATURE', 'MESH')]:
    bpy.data.objects.remove(o)
AKT = {a.name.split('|')[-1]: a for a in bpy.data.actions if a not in vorher}
qa.animation_data_create()
dg = bpy.context.evaluated_depsgraph_get()

def lage(act, f):
    # Blender 5: eine fremde Bewegung wirkt erst mit ihrem Platz (slot); ohne ihn blieb die Figur stehen, alle Zeilen 0 (Tom 19:08)
    qa.animation_data.action = act
    if act is None:
        for pb in qa.pose.bones: pb.matrix_basis.identity()   # Ruhe = Ruhelage der Kauffigur (T-Pose)
    elif getattr(act, 'slots', None) and qa.animation_data.action_slot is None:
        qa.animation_data.action_slot = act.slots[0]
    bpy.context.scene.frame_set(f); dg.update()
    me = kleid.evaluated_get(dg).to_mesh()
    V = np.array([tuple(kleid.matrix_world @ me.vertices[i].co) for i in UM])
    kleid.evaluated_get(dg).to_mesh_clear()
    M = np.array(qa.matrix_world @ qa.pose.bones['spine_03'].matrix)
    Mi = np.linalg.inv(M)
    return V @ Mi[:3, :3].T + Mi[:3, 3]

idle = AKT.get('Idle_Loop')
R = lage(idle, int(idle.frame_range[0]))
hz = (qa.matrix_world @ qa.data.bones['pelvis'].head_local).z
unter = (P0[:, 2] < sh - 0.12) & (P0[:, 2] > hz)   # unter der Achsel, ueber der Huefte (darunter folgt er den Beinen)
for bn in BEW:
    a = None if bn == 'Ruhe' else AKT.get(bn)
    if bn != 'Ruhe' and a is None: print('UMHANG ARM FEHLT', bn); continue
    fs = [0] if a is None else range(int(a.frame_range[0]), int(a.frame_range[1]) + 1, 3)
    best = None
    for f in fs:
        d = np.linalg.norm(lage(a, f) - R, axis=1)
        n10 = int((d[unter] > 0.10).sum())
        if best is None or n10 > best[1]: best = (f, n10, int((d[unter] > 0.05).sum()), float(d[unter].max()), d)
    f, n10, n5, mx, d = best
    lage(a, f); hd = (qa.matrix_world @ qa.pose.bones['hand_r'].head).z   # Probe, dass die Bewegung wirkt: Hand rechts hoch
    w = unter & (d > 0.10)
    print('UMHANG ARM %s Bild %d: unter der Achsel %d Ecken > 5 cm, %d > 10 cm, hoechstens %.0f cm%s' % (
        bn, f, n5, n10, mx * 100, (' (Hand rechts %.2f m)' % hd) + (', bis %.2f m unter der Schulter, Armgewicht dort im Mittel %.2f' % (sh - P0[w, 2].min(), armw[w].mean())) if w.any() else ''))
