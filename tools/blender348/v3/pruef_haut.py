# 376.1 (Pruefer 21:17: hautfarbene Splitter am Oberarm in der Spielansicht): sichtbare Haut der Kauffigur ohne Bild. Je Bewegung und
# Bild: jede Ecke des Koerpers, deren Strahl zur Spielkamera (30 Grad von oben, Blick von vorn und je 45 Grad seitlich) nichts trifft,
# ist sichtbar; gezaehlt nur Haut, die nicht Kopf, Hals oder Hand ist (die soll man sehen), je staerkstem Knochen.
# Aufruf: FIG=<ordner/kennung.blend> UAL=<UAL1*.glb> [BEW=Idle_Loop,…] [WO=1] bl/bin/python -I pruef_haut.py -> Zeilen HAUT <bewegung> …
import bpy, os, math
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
FIG = os.environ['FIG']; UAL = os.environ['UAL']
BEW = os.environ.get('BEW', 'Ruhe,Idle_Loop,Walk_Loop,Idle_Talking_Loop').split(',')
FREI = ('head', 'neck', 'hand', 'thumb', 'index', 'middle', 'ring', 'pinky')   # Knochen, deren Haut sichtbar sein darf
bpy.ops.wm.open_mainfile(filepath=FIG)
qa = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
haut = next(o for o in qa.children if o.type == 'MESH' and any('haut' in m.name for m in o.data.materials))
vorher = set(bpy.data.actions)
bpy.ops.import_scene.gltf(filepath=UAL)
for o in [o for o in bpy.data.objects if o != qa and o.parent != qa]: bpy.data.objects.remove(o)
AKT = {a.name.split('|')[-1]: a for a in bpy.data.actions if a not in vorher}
netze = [c for c in qa.children if c.type == 'MESH']
gruppen = [g.name for g in haut.vertex_groups]
W = np.zeros((len(haut.data.vertices), len(gruppen)))
for v in haut.data.vertices:
    for g in v.groups: W[v.index, g.group] = g.weight
knochen = [gruppen[j] for j in W.argmax(1)]
zaehlt = np.array([not any(f in k.lower() for f in FREI) for k in knochen])
dg = bpy.context.evaluated_depsgraph_get()
# Figur blickt nach -Y; Kamera vorn oben (30 Grad), dazu 45 Grad links und rechts
BLICKE = [Vector((math.sin(math.radians(a)) * math.cos(math.radians(30)), -math.cos(math.radians(a)) * math.cos(math.radians(30)),
                  math.sin(math.radians(30)))) for a in (-45, 0, 45)]

def lage():
    dg.update()
    V, F, H = [], [], None
    for o in netze:
        me = o.evaluated_get(dg).to_mesh(); b = len(V)
        if o == haut: H = (b, len(me.vertices))
        V += [o.matrix_world @ v.co for v in me.vertices]
        F += [tuple(b + i for i in p.vertices) for p in me.polygons]
        o.evaluated_get(dg).to_mesh_clear()
    return V, F, H

qa.animation_data_create()
for bn in BEW:
    a = AKT.get(bn)
    if bn == 'Ruhe': qa.animation_data.action = None; f0 = f1 = 0
    elif a is None: print('FEHLT', bn); continue
    else:
        qa.animation_data.action = a
        if hasattr(qa.animation_data, 'action_slot') and a.slots: qa.animation_data.action_slot = a.slots[0]
        f0, f1 = a.frame_range
    je, hoch = {}, 0
    for f in np.linspace(f0, f1, 6):
        bpy.context.scene.frame_set(int(round(f)))
        V, F, (b, n) = lage(); bv = BVHTree.FromPolygons(V, F)
        sicht = set()
        for i in range(n):
            if not zaehlt[i] or i in sicht: continue
            p = V[b + i]
            for d in BLICKE:
                if bv.ray_cast(p + d * 0.002, d, 3.0)[0] is None: sicht.add(i); break
        hoch = max(hoch, len(sicht))
        for i in sicht:
            je[knochen[i]] = je.get(knochen[i], 0) + 1
            if os.environ.get('WO') and bn == os.environ.get('WO_BEW', bn): print('WO', bn, int(round(f)), knochen[i], tuple(round(x, 3) for x in V[b + i]))
    print('HAUT', bn, 'hoechstens', hoch, 'Ecken je Bild;', dict(sorted(je.items(), key=lambda x: -x[1])[:8]))
