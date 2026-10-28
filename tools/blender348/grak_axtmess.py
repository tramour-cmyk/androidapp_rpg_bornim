# 348.12 (Chef 28.10., 10:57: „anscheinend geht der Stiel auch durch seine Schulter durch“): misst ohne Bild, wo die Axt Graks
# Netze schneidet (BVH-Überschneidung je Netz, je Bild jeder Bewegung); Flächen an Hand- und Fingerknochen zählen nicht (Faust). Stand Gestalt r2 (Bild 0 Stehen): Arme 564 Paare, Brustplatte 30, Körper 46.
# Aufruf: ~/bl/bin/python -I grak_axtmess.py <grak-gestalt.blend> [Bewegung …]
import bpy, bmesh, sys, os
from mathutils.bvhtree import BVHTree

DATEI = [a for a in sys.argv if a.endswith('.blend')][0]
bpy.ops.wm.open_mainfile(filepath=DATEI)
ARM = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
NAMEN = [a for a in sys.argv[sys.argv.index(DATEI) + 1:]] or [a.name for a in bpy.data.actions]


def baum(o, dg):
    e = o.evaluated_get(dg); me = e.to_mesh(); bm = bmesh.new(); bm.from_mesh(me); bm.transform(o.matrix_world)
    t = BVHTree.FromBMesh(bm); bm.free(); e.to_mesh_clear(); return t


HAND = ('hand_', 'thumb_', 'index_', 'middle_', 'ring_', 'pinky_')


def knochen(o):     # je Fläche der Knochen mit dem größten Gewicht an ihrer ersten Ecke
    gn = {g.index: g.name for g in o.vertex_groups}; out = []
    for poly in o.data.polygons:
        v = o.data.vertices[poly.vertices[0]]
        out.append(gn.get(max(v.groups, key=lambda e: e.weight).group, '') if len(v.groups) else '')
    return out


axt = bpy.data.objects['Waffe']
for n in NAMEN:
    a = bpy.data.actions.get(n)
    if a is None: print('FEHLT', n); continue
    ARM.animation_data.action = a
    f0, f1 = [int(round(v)) for v in a.frame_range]
    schlimm = {}
    for f in range(f0, f1 + 1, 2):
        bpy.context.scene.frame_set(f)
        dg = bpy.context.evaluated_depsgraph_get()
        ta = baum(axt, dg)
        for o in bpy.data.objects:
            if o.type != 'MESH' or o is axt: continue
            kn = knochen(o)
            # Netze mit Modifikatoren (Umhang) haben ausgewertet mehr Flächen als im Original: Knochen dort „?“, zählen mit
            paare = [kn[j] if j < len(kn) else '?' for _, j in ta.overlap(baum(o, dg))]
            paare = [k for k in paare if not k.startswith(HAND)]     # an der Faust erlaubt
            if paare: schlimm[o.name] = max(schlimm.get(o.name, (0, 0, '')), (len(paare), f, max(set(paare), key=paare.count)))
    print('AXT %s: %s' % (n, ', '.join('%s %d Paare (Bild %d, meist %s)' % (o, k, f, b) for o, (k, f, b) in sorted(schlimm.items())) or 'frei außer an den Fäusten'))
