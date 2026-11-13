# 492 Strahltest ohne Bild: <ablage>/out/cave.glb und cave-info.json; Aufruf: ~/bl/bin/python -I tools/godot/hoehle_verdeckt.py -- cave.glb cave-info.json
# 492: fuer jede begehbare Kachel und vier Kamerarichtungen: verdeckt eine sichtbare Wand den Helden (Knie 0,45 m, Brust 1,2 m)?
import bpy, json, sys, math
from mathutils import Vector
from mathutils.bvhtree import BVHTree
glb, info = sys.argv[-2:]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb)
I = json.load(open(info))
art = {w['hoch']: (w['innen'], 'hoch') for w in I['waende']}; art.update({w['tief']: (w['innen'], 'tief') for w in I['waende']})
dg = bpy.context.evaluated_depsgraph_get()
B = [(o.name, BVHTree.FromObject(o, dg)) for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith('Wand_')]
TS = 1.16; walk = I['begehbar']
def b(g): return Vector((g[0], -g[2], g[1]))
for yaw in (0, 90, 180, 270):
    a = math.radians(yaw); off = Vector((24.5 * math.cos(a) - 24.5 * math.sin(a), 20, 24.5 * math.sin(a) + 24.5 * math.cos(a)))
    off = Vector((24.5 * math.cos(a) + 24.5 * math.sin(a), 20, -24.5 * math.sin(a) + 24.5 * math.cos(a)))
    blick = Vector((-off.x, 0, -off.z)).normalized()
    sicht = lambda n: (Vector((art[n][0][0], 0, art[n][0][1])).dot(blick) < 0.3) == (art[n][1] == 'hoch')
    vis = [(n, t) for n, t in B if sicht(n)]
    knie = []; brust = []
    for r, row in enumerate(walk):
        for c, w in enumerate(row):
            if not w: continue
            h = Vector(((c + 0.5) * TS, 0, (r + 0.5) * TS))
            for hz, lst in ((0.45, knie), (1.2, brust)):
                z = b(h) + Vector((0, 0, hz)); cam = b(h + off); d = z - cam; L = d.length; d.normalize()
                if any(t.ray_cast(cam, d, L - 0.05)[0] is not None for n, t in vis): lst.append((c, r))
    print('DREHUNG %d: Knie verdeckt %d %s | Brust verdeckt %d %s' % (yaw, len(knie), knie[:12], len(brust), brust[:12]))
