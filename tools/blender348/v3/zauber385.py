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
# 438a: liegt die Quelle im ersten Bild (Aufstehen, Knien, Sitzen), ist ihre Ruhelage nicht stehend und die Uebertragung beginnt
# stehend (Becken stieg bis 11 m). RUHE=<Humanoid@….fbx desselben Geruests, erstes Bild stehend> gibt dann Ruhelage und Angleichen.
RUHE = os.environ.get('RUHE', '')
if RUHE:
    bpy.ops.import_scene.fbx(filepath=RUHE)
    R = next(o for o in bpy.data.objects if o.type == 'ARMATURE' and o != T)
    RW = R.matrix_world.copy()
    Rs0r = {b.name: (RW @ b.matrix_local).to_3x3().normalized().to_quaternion() for b in R.data.bones}
    Ps0r = {b.name: RW @ b.head_local for b in R.data.bones}
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
if RUHE: Rs0, Ps0 = Rs0r, Ps0r

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
# Lauf 2 (Pruefer Lauf 1: Handgelenke in Ruhe nach aussen abgeknickt): Hand auch im Drall angleichen, zweite Achse quer ueber die
# Knoechel (Zeigefinger zum kleinen Finger), Rahmen aus beiden Achsen
def rahmen(d, w):
    x = d.normalized(); z = x.cross(w).normalized(); return Matrix((x, z.cross(x), z)).transposed()
for s in ('l', 'r'):
    h, m, i, k = 'hand_' + s, 'middle_01_' + s, 'index_01_' + s, 'pinky_01_' + s
    if all(n in Pt0 and KARTE[n] in Ps0 for n in (h, m, i, k)):
        Ft = rahmen(Pt0[m] - Pt0[h], Pt0[i] - Pt0[k]); Fs = rahmen(Ps0[KARTE[m]] - Ps0[KARTE[h]], Ps0[KARTE[i]] - Ps0[KARTE[k]])
        A[h] = (Fs @ Ft.inverted()).to_quaternion()

hoehe = Pt0['pelvis'].z / max(Ps0[KARTE['pelvis']].z, 1e-3)
# 417 (Chef 01.11., 13:4x: „der Oberkoerper beim normalen Gehen zum Teil zu weit vorgeneigt“): AUFRICHTEN=<Grad> dreht den Oberkoerper
# starr um den Kopf von spine_01 zurueck (alle Knochen darueber, Arme und Waffe mit), Achse quer zum Blick (-Y), Schwung bleibt
import math
AUF = Quaternion((1.0, 0.0, 0.0), -math.radians(float(os.environ.get('AUFRICHTEN', '0') or 0)))
oben = set()
for b in tb:   # Eltern vor Kindern
    if b.name == 'spine_01' or (b.parent and b.parent.name in oben): oben.add(b.name)
# 438a (Messung: Fuesse im Stand 0,18 m ueber dem Boden): steht die Quelle in der Ruhelage mit gebeugten Knien (Schwert & Schild 0,86 m
# Becken), hob „Ruhelage auf Ruhelage“ den Helden um die Beugung an. BECKEN=bein: Hoehe ueber dem Boden wie die Quelle, im Verhaeltnis
# der Beinlaengen (Oberschenkel, Wade, Knoechel), waagerecht wie bisher.
BEIN = os.environ.get('BECKEN', '') == 'bein'
if BEIN:
    def bein(P, k):
        return (P[k('thigh_l')] - P[k('calf_l')]).length + (P[k('calf_l')] - P[k('foot_l')]).length + P[k('foot_l')].z
    hoehe = bein(Pt0, lambda n: n) / max(bein(Ps0, lambda n: KARTE[n]), 1e-3)
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
            if b.name in oben: Q = AUF @ Q
            qa = TWq.inverted() @ Q
            qb = dreh(Mp).inverted() @ qa
            if b.name == 'pelvis':
                P = Pt0['pelvis'] + (SW @ S.pose.bones[s].head - Ps0[s]) * hoehe
                if BEIN: P.z = (SW @ S.pose.bones[s].head).z * hoehe
                loc = Mp.to_3x3().inverted() @ (TW.inverted() @ P - Mp.translation)
        pb.rotation_quaternion = qb
        pb.location = loc
        pose[b.name] = Mp @ Matrix.Translation(loc) @ qb.to_matrix().to_4x4()
        pb.keyframe_insert('rotation_quaternion', frame=f - f0 + 1)
        if b.name == 'pelvis': pb.keyframe_insert('location', frame=f - f0 + 1)
# Pruefung: Richtung der Knochen Ziel gegen Quelle (Grad, schlimmstes Bild; mit AUFRICHTEN am Ruecken um so viel mehr)
schlimm = {}
for f in range(f0, f1 + 1, 5):
    bpy.context.scene.frame_set(f)
    bpy.context.view_layer.update()
    for a, c in (('upperarm_l', 'lowerarm_l'), ('lowerarm_l', 'hand_l'), ('upperarm_r', 'lowerarm_r'), ('lowerarm_r', 'hand_r'), ('thigh_l', 'calf_l'),
                 ('calf_r', 'foot_r'), ('spine_01', 'neck_01'), ('hand_r', 'middle_01_r'), ('pinky_01_r', 'index_01_r'), ('pinky_01_l', 'index_01_l')):
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
