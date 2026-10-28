# 348.7 (Jerry 34): Querschnitte eines Vierbeiners aus der .glb (Ruhelage), je 10° um die Rumpfmitte der äußerste Punkt; Aufruf: ~/bl/bin/python -I - -- <datei.glb> <y> … < schnitt.py
import bpy, sys, math, bmesh
from mathutils import Vector
p = sys.argv[sys.argv.index('--')+1]; ys = [float(v) for v in sys.argv[sys.argv.index('--')+2:]]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=p)
ob = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
bm = bmesh.new(); bm.from_mesh(ob.data); M = ob.matrix_world
for y0 in ys:
    pts = []
    for e in bm.edges:
        a = M @ e.verts[0].co; b = M @ e.verts[1].co
        if (a.y - y0) * (b.y - y0) < 0:
            t = (y0 - a.y) / (b.y - a.y); q = a.lerp(b, t)
            if q.x >= 0 and q.z > 0.3: pts.append((q.x, q.z))
    # Umriss: je 10°-Winkel um die Mitte (0, 0.62) den äußersten Punkt
    best = {}
    for x, z in pts:
        ang = round(math.degrees(math.atan2(z - 0.62, x)) / 10) * 10; r = math.hypot(x, z - 0.62)
        if r > best.get(ang, (0,))[0]: best[ang] = (r, x, z)
    print('y=%.2f' % y0, ' '.join('%d:(%.2f,%.2f)' % (k, v[1], v[2]) for k, v in sorted(best.items())))
