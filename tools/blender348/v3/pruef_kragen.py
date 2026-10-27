# 376.1 (Pruefer 21:17: graue Zacken am Kragenrand mitten am Hals, 11 von 15 Koepfen): Haut am Kettenkragen ohne Bild. Pose wie im
# Kopfblatt (Idle_Loop, Kopf um HEBEN Grad gehoben wie KopfHeben in figurenprobe.gd); gezaehlt werden Ecken der Halshaut im Kragen
# (hoechstens 2 cm unter dessen Oberkante, nahe der Kette), die vor der Kette liegen oder weniger als 1 mm dahinter (Zacken).
# Aufruf: FIG=<ordner/kennung.blend> UAL=<UAL1*.glb> [HEBEN=10] bl/bin/python -I pruef_kragen.py -> Zeile KRAGEN …
import bpy, os, json, math
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
FIG = os.environ['FIG']; UAL = os.environ['UAL']; HEBEN = float(os.environ.get('HEBEN', '10'))
bpy.ops.wm.open_mainfile(filepath=FIG)
qa = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
haut = next(o for o in qa.children if o.type == 'MESH' and any('haut' in m.name for m in o.data.materials))
kleid = bpy.data.objects['Kleid']
TN = json.load(open(os.environ.get('TEILE', '/home/user/q376/out/teile.json')))
tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
vorher = set(bpy.data.actions)
bpy.ops.import_scene.gltf(filepath=UAL)
for o in [o for o in bpy.data.objects if o != qa and o.parent != qa]: bpy.data.objects.remove(o)
AKT = {a.name.split('|')[-1]: a for a in bpy.data.actions if a not in vorher}
qa.animation_data_create(); a = AKT['Idle_Loop']; qa.animation_data.action = a
if hasattr(qa.animation_data, 'action_slot') and a.slots: qa.animation_data.action_slot = a.slots[0]
gr = [g.name for g in haut.vertex_groups]
hals = np.zeros(len(haut.data.vertices), dtype=bool)
for v in haut.data.vertices:
    hals[v.index] = sum(g.weight for g in v.groups if gr[g.group] in ('Head', 'neck_01', 'neck_02')) > 0.3
ergebnis = []
for f in (0, 20, 40):
    bpy.context.scene.frame_set(f)
    pb = qa.pose.bones['Head']
    pb.rotation_mode = 'QUATERNION'
    q0 = pb.rotation_quaternion.copy()
    dg = bpy.context.evaluated_depsgraph_get(); dg.update()
    # Kopf heben: um die Querachse des Kopfs in Weltlage (Kinn hoch), wie KopfHeben
    M = qa.matrix_world @ pb.matrix
    achse = (M.to_3x3() @ Vector((1, 0, 0))).normalized()
    welt = Matrix.Rotation(math.radians(-HEBEN), 3, achse) @ M.to_3x3().normalized()
    eltern = (qa.matrix_world @ pb.parent.matrix).to_3x3().normalized()
    rest = (pb.parent.bone.matrix_local.inverted() @ pb.bone.matrix_local).to_3x3()
    pb.rotation_quaternion = (rest.inverted() @ eltern.inverted() @ welt).to_quaternion()
    dg.update()
    km = kleid.evaluated_get(dg).to_mesh()
    KV = [kleid.matrix_world @ v.co for v in km.vertices]
    KF = [tuple(p.vertices) for p in km.polygons if TN[tl[p.vertices[0]]] == 'chain']
    kleid.evaluated_get(dg).to_mesh_clear()
    bv = BVHTree.FromPolygons(KV, KF)
    oben = max(KV[i][2] for fc in KF for i in fc if abs(KV[i][0]) < 0.12)
    hm = haut.evaluated_get(dg).to_mesh(); HV = [haut.matrix_world @ v.co for v in hm.vertices]; haut.evaluated_get(dg).to_mesh_clear()
    # sichtbar zur Kopfkamera (vorn, leicht von oben) und zur Spielkamera (30 Grad), nichts davor: Haut, die im Kragen zu sehen ist
    alle = []
    for o in [c for c in qa.children if c.type == 'MESH']:
        me = o.evaluated_get(dg).to_mesh(); b0 = sum(len(x[0]) for x in alle)
        alle.append(([o.matrix_world @ v.co for v in me.vertices], [tuple(b0 + i for i in q.vertices) for q in me.polygons]))
        o.evaluated_get(dg).to_mesh_clear()
    bva = BVHTree.FromPolygons([v for x in alle for v in x[0]], [f for x in alle for f in x[1]])
    BL = [Vector((0, -math.cos(math.radians(e)), math.sin(math.radians(e)))) for e in (8, 30)]
    n = 0; vor = 0
    for i in np.where(hals)[0]:
        p = HV[i]
        if p[2] > oben - 0.004: continue
        c, nr, _, d = bv.find_nearest(p, 0.015)
        if c is None: continue
        n += 1
        if any(bva.ray_cast(p + r * 0.001, r, 2.0)[0] is None for r in BL): vor += 1
    # Innenseite der Kette (Normale zum Hals hin) im Kragen, die zur Kamera sichtbar ist (Pruefer 22:3x: graue Zacken = Kragen innen)
    kn = [Vector((0, 0, 0)) for _ in KV]
    for fc in KF:
        nn = (KV[fc[1]] - KV[fc[0]]).cross(KV[fc[2]] - KV[fc[0]])
        for i in fc: kn[i] += nn
    ax = (qa.matrix_world @ qa.pose.bones['neck_01'].head) if 'neck_01' in qa.pose.bones else Vector((0, 0, oben))
    innen = 0
    for fc in KF:
        p = sum((KV[i] for i in fc), Vector()) / len(fc)
        if p[2] < oben - 0.05 or Vector((p[0] - ax[0], p[1] - ax[1], 0)).length > 0.11: continue
        nn = (KV[fc[1]] - KV[fc[0]]).cross(KV[fc[2]] - KV[fc[0]])
        zum = Vector((ax[0] - p[0], ax[1] - p[1], 0))
        if nn.length == 0 or nn.normalized().dot(zum.normalized()) < 0.3: continue
        if any(bva.ray_cast(p + r * 0.002, r, 2.0)[0] is None for r in BL): innen += 1
    ergebnis.append((f, n, vor, innen))
    pb.rotation_quaternion = q0
print('KRAGEN', os.path.basename(FIG), 'gehoben %.0f Grad' % HEBEN, ' '.join('Bild %d: %d von %d Halsecken im Kragen sichtbar, Kragen innen sichtbar %d' % (f, v, n, k) for f, n, v, k in ergebnis))
