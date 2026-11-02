# 376.1 Kauffigur in unserer Kleidung (kauf_kleid.py): Lagen in der Bewegung ohne Bild. Eine Ecke einer Lage A gilt als bedeckt,
# wenn in Ruhe der Strahl entlang ihrer Normale binnen 8 cm eine andere Lage B trifft; durch: in der Bewegung trifft der Strahl
# gegen die Normale binnen 3 cm eine nach aussen zeigende Wand von B (A liegt jetzt vor B, sticht durch). Koerper der Kauffigur (Haende, Hals, Kopf) wie eine Lage.
# Aufruf: FIG=<ordner/kennung.blend> UAL=<UAL1*.glb> bl/bin/python -I pruef_tracht.py -> Zeilen DURCH <bewegung> {...}
import bpy, os, json
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
FIG = os.environ['FIG']; UAL = os.environ['UAL']
BEW = os.environ.get('BEW', 'Ruhe,Idle_Loop,Walk_Loop,Jog_Fwd_Loop,Idle_Talking_Loop,Sword_Attack,Dodge_Left,Hit_Chest,Death01').split(',')
WEIT = 0.08
DURCH_WEIT = 0.03
bpy.ops.wm.open_mainfile(filepath=FIG)
qa = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
kleid = bpy.data.objects['Kleid']
TEILNAMEN = json.load(open(os.path.join(os.path.dirname(os.environ.get('HELDOUT', '/home/user/q376/out/x')), 'teile.json')))
tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
vorher = set(bpy.data.actions)
bpy.ops.import_scene.gltf(filepath=UAL)
for o in [o for o in bpy.data.objects if o not in (qa, kleid) and o.parent != qa and o != qa and o.type in ('ARMATURE', 'MESH') and o.name not in [c.name for c in qa.children]]:
    bpy.data.objects.remove(o)
AKT = {a.name.split('|')[-1]: a for a in bpy.data.actions if a not in vorher}
netze = [kleid] + [c for c in qa.children if c.type == 'MESH' and c != kleid]
dg = bpy.context.evaluated_depsgraph_get()

def lage():
    dg.update()
    V, F, L, N = [], [], [], []
    for o in netze:
        me = o.evaluated_get(dg).to_mesh(); b = len(V)
        V += [o.matrix_world @ v.co for v in me.vertices]
        N += [(o.matrix_world.to_3x3() @ v.normal).normalized() for v in me.vertices]
        F += [tuple(b + i for i in p.vertices) for p in me.polygons]
        L += list(tl) if o == kleid else [-1] * len(me.vertices)
        o.evaluated_get(dg).to_mesh_clear()
    return V, F, np.array(L), N

def je_lage(V, F, L):
    B = {}
    for t in set(L.tolist()):
        fs = [f for f in F if L[f[0]] == t]
        if fs: B[t] = BVHTree.FromPolygons(V, fs)
    return B

RAND_E = None
def raender(V, L):
    # Ecken an offenen Kanten (Kante nur an einer Flaeche) je Lage, als KDTree
    global RAND_E
    if RAND_E is None:
        from collections import Counter
        c = Counter()
        for f in F0:
            for k in range(len(f)): c[tuple(sorted((f[k], f[(k + 1) % len(f)])))] += 1
        RAND_E = sorted({i for e, n in c.items() if n == 1 for i in e})
    from mathutils.kdtree import KDTree
    out = {}
    for t in set(L.tolist()):
        idx = [i for i in RAND_E if L[i] == t]
        kd = KDTree(max(1, len(idx)))
        for i in idx: kd.insert(V[i], i)
        if not idx: kd.insert(Vector((1e6, 1e6, 1e6)), 0)
        kd.balance(); out[t] = kd
    return out

def name(t): return 'koerper' if t < 0 else TEILNAMEN[t]
qa.animation_data_create(); qa.animation_data.action = None
bpy.context.scene.frame_set(0)
V, F, L, N = lage(); B = je_lage(V, F, L); F0 = F
DECKT = {}   # Ecke -> Lage darueber
for i in range(len(V)):
    best = None
    for t, bv in B.items():
        if t == L[i]: continue
        h = bv.ray_cast(V[i] + N[i] * 0.001, N[i], WEIT)
        if h[0] is not None and (best is None or h[3] < best[1]): best = (t, h[3])
    if best: DECKT[i] = best[0]
print('BEDECKT IN RUHE', len(DECKT), 'von', len(V))
for bn in BEW:
    a = AKT.get(bn)
    if bn == 'Ruhe': qa.animation_data.action = None; f0 = f1 = 0
    elif a is None: print('FEHLT', bn); continue
    else:
        qa.animation_data.action = a
        if hasattr(qa.animation_data, 'action_slot') and a.slots: qa.animation_data.action_slot = a.slots[0]
        f0, f1 = a.frame_range
    zahl = {}
    schlimm = 0
    for f in np.linspace(f0, f1, 8):
        bpy.context.scene.frame_set(int(round(f)))
        V, F, L, N = lage(); B = je_lage(V, F, L); RK = raender(V, L)
        n = 0
        for i, t in DECKT.items():
            h = B[t].ray_cast(V[i] - N[i] * 0.001, -N[i], DURCH_WEIT)
            # die durchstossene Wand zeigt wie wir nach aussen (Gegenwand einer Roehre nicht); mindestens 5 mm durch; nicht am offenen
            # Rand von B (Kragen, Aermel, Saum: darunter darf der Koerper weitergehen)
            if h[0] is not None and h[1].dot(N[i]) > 0 and h[3] > 0.005 and RK[t].find(h[0])[2] > 0.03:
                k = name(L[i]) + '>' + name(t); zahl[k] = zahl.get(k, 0) + 1; n += 1
                if os.environ.get('WO') and bn == os.environ['WO']: print('WO', k, tuple(round(x, 3) for x in V[i]), round(h[3], 3))
        schlimm = max(schlimm, n)
    print('DURCH', bn, 'hoechstens', schlimm, 'Ecken je Bild;', dict(sorted(zahl.items(), key=lambda x: -x[1])[:6]))
