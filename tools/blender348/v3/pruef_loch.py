# 348.6 Feinschliff 9: Koerperecken am Oberarm ohne Kleidung darueber (Loecher, dunkles Tuch frei). Aufruf: OUT=<figurordner> python -I pruef_loch.py -> FREI <Seite> von <n> <frei> [((t, Winkelsektor, seg), Anzahl)…]
import bpy, os, json, bmesh, math
from mathutils import Vector
from mathutils.bvhtree import BVHTree
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3.blend')
G = json.load(open(OUT + '/gelenke.json')); J = {k: Vector(v[0]) for k, v in G['J'].items()}; R = {k: v[1][0] for k, v in G['J'].items()}
dg = bpy.context.evaluated_depsgraph_get(); B = {}; body = None
for o in bpy.data.objects:
    if o.type != 'MESH' or o.name.startswith(('hand', 'wrist', 'beard', 'hair', 'head', 'ear', 'lid', 'eye')): continue
    bm = bmesh.new(); bm.from_object(o, dg); bm.transform(o.matrix_world); bm.normal_update()
    if o.name == 'body': body = bm; seg = bm.verts.layers.int.get('seg')
    else: B[o.name] = BVHTree.FromBMesh(bm)
names = None
for s in 'RL':
    a, b = J['sh' + s], J['el' + s]; ab = b - a; u = ab.normalized(); x = Vector((0, 0, 1)).cross(u).normalized(); y = u.cross(x)
    frei = {}; ges = 0
    for v in body.verts:
        d = v.co - a; t = d.dot(ab) / ab.dot(ab); r = (d - ab * t).length
        if not (0.2 < t < 1.0 and r < (R['sh' + s] + R['el' + s]) * 0.9): continue
        ges += 1
        n = v.normal.normalized()
        if any(bt.ray_cast(v.co + n * 0.02, n, 3.0)[0] is not None for bt in B.values()): continue
        w = int((math.degrees(math.atan2(d.dot(y), d.dot(x))) + 180) // 30); k = (round(t, 1), w, v[seg])
        frei[k] = frei.get(k, 0) + 1
    print('FREI', s, 'von', ges, sum(frei.values()), sorted(frei.items())[:40])
