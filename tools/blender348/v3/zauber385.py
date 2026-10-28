# 385 (Chef 27.10., 21:04 „385 ja“; „jetzt“ 28.10., 10:00): Protofactor-Zauberer-Set (gekauft, Biped-Geruest aus 3ds Max) auf das
# Geruest des Kaufkoerpers (UAL, 65 Knochen, T-Pose). Je Bewegung eine .glb nur mit Geruest und Bewegung, Name wie NAME; Godot
# (figurenprobe.gd --ual2=) legt sie neben die UAL-Bewegungen. Uebertragung in Weltlage: je Knochen die Drehung gegen die eigene
# Ruhelage (Quelle) auf die Ruhelage des Ziels, vorher die Richtung der Ruhelagen angeglichen (Quelle hat keine T-Pose, ihre Ruhelage
# ist das erste Bild); Becken mit der Beckenhoehe skaliert. Drall um die Knochenachse gleicht das nicht an (Befund im Film pruefen).
# Aufruf: QUELLE=<Humanoid@X.fbx> ZIEL=<UAL1.glb> NAME=<Bewegung> OUT=<datei.glb> bl/bin/python -I zauber385.py
import bpy, os
from mathutils import Matrix, Quaternion, Vector

QUELLE = os.environ['QUELLE']; ZIEL = os.environ['ZIEL']; NAME = os.environ['NAME']; OUT = os.environ['OUT']

KARTE = {'pelvis': 'Pelvis', 'spine_01': 'Spine', 'spine_02': 'Spine1', 'spine_03': 'Spine2', 'neck_01': 'Neck', 'Head': 'Head'}
for s, b in (('l', 'L'), ('r', 'R')):
    KARTE.update({'clavicle_' + s: b + ' Clavicle', 'upperarm_' + s: b + ' UpperArm', 'lowerarm_' + s: b + ' Forearm', 'hand_' + s: b + ' Hand',
                  'thigh_' + s: b + ' Thigh', 'calf_' + s: b + ' Calf', 'foot_' + s: b + ' Foot', 'ball_' + s: b + ' Toe0'})
    for f, n in (('thumb', 0), ('index', 1), ('middle', 2), ('ring', 3), ('pinky', 4)):
        for i, x in enumerate(('', '1', '2')):
            KARTE['%s_0%d_%s' % (f, i + 1, s)] = '%s Finger%d%s' % (b, n, x)
KARTE = {k: 'humanoid_ ' + v for k, v in KARTE.items()}

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=ZIEL)
T = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in [o for o in bpy.data.objects if o != T]: bpy.data.objects.remove(o)
for a in list(bpy.data.actions): bpy.data.actions.remove(a)
bpy.ops.import_scene.fbx(filepath=QUELLE)
S = next(o for o in bpy.data.objects if o.type == 'ARMATURE' and o != T)
for o in [o for o in bpy.data.objects if o not in (T, S)]: bpy.data.objects.remove(o)
src = S.animation_data.action
f0, f1 = int(src.frame_range[0]), int(src.frame_range[1])
fps = bpy.context.scene.render.fps

tb = T.data.bones; sb = S.data.bones
TW = T.matrix_world.copy(); SW = S.matrix_world.copy()
def dreh(m): return m.to_3x3().normalized().to_quaternion()   # FBX-Geruest ist auf 0,01 skaliert
Rt0 = {b.name: dreh(TW @ b.matrix_local) for b in tb}
Pt0 = {b.name: TW @ b.head_local for b in tb}
Rs0 = {b.name: dreh(SW @ b.matrix_local) for b in sb}
Ps0 = {b.name: SW @ b.head_local for b in sb}

# Angleichen der Ruhelagen: Richtung zum (ersten abgebildeten) Kind; ohne Kind wie der Elternknochen
def kind(b):
    for c in b.children:
        if c.name in KARTE: return c.name
    return None
A = {}
for b in tb:   # Reihenfolge der Liste: Eltern vor Kindern
    if b.name not in KARTE: continue
    c = kind(b)
    if c and b.name != 'pelvis':
        dt = Pt0[c] - Pt0[b.name]; ds = Ps0[KARTE[c]] - Ps0[KARTE[b.name]]
        A[b.name] = dt.rotation_difference(ds) if dt.length > 1e-4 and ds.length > 1e-4 else Quaternion()
    else:
        p = b.parent
        while p and p.name not in A: p = p.parent
        A[b.name] = A[p.name] if p else Quaternion()

hoehe = Pt0['pelvis'].z / max(Ps0[KARTE['pelvis']].z, 1e-3)
TWq = dreh(TW)
act = bpy.data.actions.new(NAME)
T.animation_data_create(); T.animation_data.action = act
for pb in T.pose.bones: pb.rotation_mode = 'QUATERNION'
for f in range(f0, f1 + 1):
    bpy.context.scene.frame_set(f)
    pose = {}   # Knochen -> Lage im Geruest (4x4), Eltern zuerst
    for b in tb:
        pb = T.pose.bones[b.name]
        rr = (b.parent.matrix_local.inverted() @ b.matrix_local) if b.parent else b.matrix_local
        Mp = (pose[b.parent.name] @ rr) if b.parent else rr
        qb = Quaternion(); loc = Vector()
        if b.name in KARTE and KARTE[b.name] in S.pose.bones:
            s = KARTE[b.name]
            Rs = dreh(SW @ S.pose.bones[s].matrix)
            Q = (Rs @ Rs0[s].inverted()) @ A[b.name] @ Rt0[b.name]
            qa = TWq.inverted() @ Q
            qb = dreh(Mp).inverted() @ qa
            if b.name == 'pelvis':
                P = Pt0['pelvis'] + (SW @ S.pose.bones[s].head - Ps0[s]) * hoehe
                loc = Mp.to_3x3().inverted() @ (TW.inverted() @ P - Mp.translation)
        pb.rotation_quaternion = qb
        pb.location = loc
        pose[b.name] = Mp @ Matrix.Translation(loc) @ qb.to_matrix().to_4x4()
        pb.keyframe_insert('rotation_quaternion', frame=f - f0 + 1)
        if b.name == 'pelvis': pb.keyframe_insert('location', frame=f - f0 + 1)
# Pruefung: Richtung der Knochen Ziel gegen Quelle (Grad, schlimmstes Bild)
import math
schlimm = {}
for f in range(f0, f1 + 1, 5):
    bpy.context.scene.frame_set(f)
    bpy.context.view_layer.update()
    for a, c in (('upperarm_l', 'lowerarm_l'), ('lowerarm_l', 'hand_l'), ('upperarm_r', 'lowerarm_r'), ('lowerarm_r', 'hand_r'), ('thigh_l', 'calf_l'),
                 ('calf_r', 'foot_r'), ('spine_01', 'neck_01'), ('hand_r', 'middle_01_r')):
        t = (TW @ T.pose.bones[c].head) - (TW @ T.pose.bones[a].head)
        q = (SW @ S.pose.bones[KARTE[c]].head) - (SW @ S.pose.bones[KARTE[a]].head)
        schlimm[a] = max(schlimm.get(a, 0.0), math.degrees(t.angle(q)))
print('ABWEICHUNG', ' '.join('%s %.0f' % kv for kv in schlimm.items()))
bpy.data.objects.remove(S)
for a in [a for a in bpy.data.actions if a != act]: bpy.data.actions.remove(a)   # sonst geht die Bewegung der Quelle mit hinaus
bpy.context.scene.frame_start = 1; bpy.context.scene.frame_end = f1 - f0 + 1
for o in bpy.data.objects: o.select_set(o == T)
bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB', use_selection=True, export_animations=True,
                          export_animation_mode='ACTIONS', export_skins=True)
print('ZAUBER385 OK', NAME, 'Bilder', f1 - f0 + 1, 'fps', fps, 'Beckenhoehe x%.2f' % hoehe)
