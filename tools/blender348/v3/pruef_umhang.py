# 348.6 Achselkerbe: Strahlen von aussen waagerecht zur Achse aufs gerigte Netz (Stehen, Gehen Mitte); gezaehlt, wo die erste Flaeche
# die Innenlage des Umhangs von hinten ist (sie sticht durch die aeussere). Aufruf: B=<OUT>/held3-rig.blend ~/bl/bin/python -I pruef_umhang.py
import bpy, math, os, json
from mathutils import Vector
from mathutils.bvhtree import BVHTree
bpy.ops.wm.open_mainfile(filepath=os.environ['B'])
tn = json.load(open(os.path.dirname(os.environ['B']) + '/teile.json')); ic = tn.index('cloak')
ob = bpy.data.objects['Held_Netz']; me0 = ob.data
tl = [0] * len(me0.vertices); me0.attributes['teil'].data.foreach_get('value', tl)
ib = tn.index('body')
kt = BVHTree.FromPolygons([v.co for v in me0.vertices], [tuple(p.vertices) for p in me0.polygons if all(tl[i] == ib for i in p.vertices)])
inner = {v.index for v in me0.vertices if tl[v.index] == ic and v.normal.dot(kt.find_nearest(v.co)[1]) < 0}
print('inner', len(inner), 'von', sum(1 for t in tl if t == ic))
rig = [o for o in bpy.data.objects if o.type == 'ARMATURE'][0]
acts = {t.name: t.strips[0].action for t in rig.animation_data.nla_tracks}
for t in rig.animation_data.nla_tracks: t.mute = True
scn = bpy.context.scene
def test(lbl):
    dg = bpy.context.evaluated_depsgraph_get(); oe = ob.evaluated_get(dg); me = oe.to_mesh(); mw = ob.matrix_world
    vs = [mw @ v.co for v in me.vertices]
    fs = list(me.polygons)
    kind = [all(tl[i] == ic for i in p.vertices) and sum(i in inner for i in p.vertices) * 2 > len(p.vertices) for p in fs]
    tr = BVHTree.FromPolygons(vs, [tuple(p.vertices) for p in fs])
    zs = [v.z for v in vs]; zmax = max(zs)
    bad = {}
    for zi in range(0, 60):
        z = zmax * (0.98 - zi * 0.01)
        for th in range(-180, 180, 4):
            t = math.radians(th); d = Vector((math.sin(t), math.cos(t), 0)); c = Vector((0, 0, z))
            loc, nor, idx, dist = tr.ray_cast(c + d * 2.0 * (zmax / 1.6), -d)
            if loc is not None and kind[idx] and nor.dot(d) < 0: bad.setdefault(round(z / zmax, 2), []).append(th)
    print(lbl, 'innen zuerst:', sum(len(v) for v in bad.values()))
    for z in sorted(bad, reverse=True): print('  z/H=%.2f' % z, bad[z])
    oe.to_mesh_clear()
for an in ('Stehen', 'Gehen'):
    act = acts[an]; rig.animation_data.action = act; f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    scn.frame_set(f0 if an == 'Stehen' else f0 + (f1 - f0) // 2); test(an)
