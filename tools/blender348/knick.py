# 348.7 (Jerry 34): harte Kanten (Flächenwinkel über <Grad>) einer .glb, nach Lage gezählt; Aufruf: ~/bl/bin/python -I - -- <datei.glb> <Grad> < knick.py
import bpy, sys, numpy as np, math, bmesh
p = sys.argv[sys.argv.index('--')+1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=p)
ob = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
bm = bmesh.new(); bm.from_mesh(ob.data); bm.normal_update()
M = ob.matrix_world
rows = []
for e in bm.edges:
    if len(e.link_faces) != 2: continue
    a = math.degrees(e.link_faces[0].normal.angle(e.link_faces[1].normal))
    if a > float(sys.argv[-1]):
        c = M @ ((e.verts[0].co + e.verts[1].co) / 2)
        rows.append((a, c.x, c.y, c.z))
rows.sort(reverse=True)
print('Kanten', len(rows))
import collections
g = collections.Counter((round(r[2],1), round(r[3],1)) for r in rows)
for k, n in sorted(g.items(), key=lambda t: -t[1])[:25]: print('y,z', k, n)
for r in rows[:15]: print('%.0f° x%.2f y%.2f z%.2f' % r)
