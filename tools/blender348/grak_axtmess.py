# 348.12 (Chef 28.10., 10:57: „anscheinend geht der Stiel auch durch seine Schulter durch“): misst ohne Bild, wo die Axt Graks
# Netze schneidet (BVH-Überschneidung je Netz, je Bild jeder Bewegung). Ziel: 0 außer an den Fäusten (Male_Ranger_Arms nur
# Hand- und Fingerknochen). Stand Gestalt r2 (Bild 0 Stehen): Arme 564 Paare, Brustplatte 30, Körper 46.
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
            k = len(ta.overlap(baum(o, dg)))
            if k: schlimm[o.name] = max(schlimm.get(o.name, (0, 0)), (k, f))
    print('AXT %s: %s' % (n, ', '.join('%s %d Paare (Bild %d)' % (o, k, f) for o, (k, f) in sorted(schlimm.items())) or 'frei'))
