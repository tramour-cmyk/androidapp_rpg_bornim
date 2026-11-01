# 376.1 Halszacken (Helfer 28.10.: graue Zacken vorn am Hals bei k01/03/06-10/13/15, nicht bei schmal, kantig, hager): misst ohne Bild
# in der Spielhaltung (UAL Idle_Loop, Kopf um KOPF Grad gehoben wie figurenprobe.gd), ob Halshaut vor der Kette liegt (durchsticht)
# oder naeher als 1 mm an ihr (gleich tief, flackert). Kette = Kleid mit Farbe alpha 0,25-0,7 (toon.gdshader), Hals = Haut zwischen
# Halsansatz und Kinn im Umkreis HALS_R um die Halsachse.
# Aufruf: FIG=<q_kNN.glb> UAL=<UAL1.glb> [KOPF=10] ~/bl/bin/python -I pruef_zacken.py
import bpy, os, math
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

FIG = os.environ['FIG']; UAL = os.environ['UAL']
KOPF = float(os.environ.get('KOPF', '10')); HALS_R = 0.09
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=FIG)
fig = {o.name: o for o in bpy.context.scene.objects}
arm = next(o for o in fig.values() if o.type == 'ARMATURE')
bpy.ops.import_scene.gltf(filepath=UAL)
act = bpy.data.actions.get('Idle_Loop')
arm.animation_data_create(); arm.animation_data.action = act
kleid = next(o for o in fig.values() if o.type == 'MESH' and o.name.startswith('Kleid'))
haut = next(o for o in fig.values() if o.type == 'MESH' and o.name.startswith('RegularMale'))
def maske(ca):
    a = np.array([c.color[3] for c in ca.data])
    if ca.domain == 'POINT': return (a >= 0.25) & (a < 0.7)
    m = np.zeros(len(kleid.data.vertices), dtype=bool)   # Ecke der Schleife -> Punkt
    for li, l in enumerate(kleid.data.loops): m[l.vertex_index] |= bool(0.25 <= a[li] < 0.7)
    return m
# die Farbschicht mit der Teilmaske (der Import benennt COLOR_0/1 nicht verlaesslich)
kette = max((maske(ca) for ca in kleid.data.color_attributes), key=lambda m: m.sum())
print('KETTE', int(kette.sum()), 'Ecken')
head = arm.pose.bones['Head']
dg = bpy.context.evaluated_depsgraph_get()
erg = []
for frame in (0, 15, 30, 45):
    bpy.context.scene.frame_set(frame)
    head.rotation_mode = 'QUATERNION'
    head.rotation_quaternion = head.rotation_quaternion @ Matrix.Rotation(math.radians(-KOPF), 4, 'X').to_quaternion()
    dg.update()
    def welt(o):
        m = o.evaluated_get(dg).to_mesh()
        V = np.array([o.matrix_world @ v.co for v in m.vertices]); F = [tuple(p.vertices) for p in m.polygons]
        o.evaluated_get(dg).to_mesh_clear(); return V, F
    KV, KF = welt(kleid); HV, _ = welt(haut)
    KF = [f for f in KF if all(kette[i] for i in f)]
    bvh = BVHTree.FromPolygons([Vector(v) for v in KV], KF)
    hm = arm.matrix_world @ arm.pose.bones['neck_01'].head; km = arm.matrix_world @ head.head
    ach = np.array(km - hm); L = np.linalg.norm(ach); ach /= L
    rel = HV - np.array(hm); t = rel @ ach; r = np.linalg.norm(rel - np.outer(t, ach), axis=1)
    hals = (t > -0.02) & (t < L + 0.02) & (r < HALS_R)
    vor = nah = 0
    for v in HV[hals]:
        c, n, _, d = bvh.find_nearest(Vector(v), 0.02)
        if c is None: continue
        if d < 0.001: nah += 1
        if (Vector(v) - c).dot(n) > 0.0005: vor += 1
    erg.append((frame, int(hals.sum()), vor, nah))
print('ZACKEN %s Kopf %+.0f Grad: ' % (os.path.basename(FIG), KOPF) + ' | '.join('Bild %d: Hals %d, vor der Kette %d, <1mm %d' % e for e in erg))
