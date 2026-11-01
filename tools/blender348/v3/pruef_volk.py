# 455.2 Durchdringung der Voelkertrachten (volk_tracht.py) in Bewegung, ohne Bild; Verfahren wie pruef_tracht.py (376.1), aber fuer
# jedes glb: jede Netz-Datei ist eine Lage (Koerper, Kleid, Stiefel, Helm …). Eine Ecke einer Lage A gilt als bedeckt, wenn in Ruhe der
# Strahl entlang ihrer Normale binnen 8 cm eine andere Lage B trifft; durch: in der Bewegung trifft der Strahl gegen die Normale binnen
# 3 cm eine nach aussen zeigende Wand von B (mindestens 5 mm, nicht am offenen Rand von B). Gezaehlt nur Koerper durch Kleidung
# (sieht man) und Kleidung durch Kleidung; je Bewegung acht Bilder, hoechstens Ecken je Bild.
# Aufruf: FIGUREN=<ordner mit volk_*.glb> UAL=<UAL1*.glb> bl/bin/python -I pruef_volk.py -> Zeilen DURCH <datei> <bewegung> …, json
import bpy, os, json, glob
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
from mathutils.kdtree import KDTree
from collections import Counter

ORDNER = os.environ['FIGUREN']; UAL = os.environ['UAL']
BEW = os.environ.get('BEW', 'Ruhe,Idle_Loop,Walk_Loop,Jog_Fwd_Loop,Sword_Attack').split(',')
WEIT, DURCH_WEIT = 0.08, 0.03
KOERPER = ('Regular_', 'Superhero_')


def pruefe(p):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=p)
    qa = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    netze = [o for o in bpy.data.objects if o.type == 'MESH' and not o.name.startswith(('Eye', 'Hair'))]
    vorher = set(bpy.data.actions); alt = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=UAL)
    for o in [o for o in bpy.data.objects if o not in alt]: bpy.data.objects.remove(o)
    akt = {a.name.split('|')[-1]: a for a in bpy.data.actions if a not in vorher}
    dg = bpy.context.evaluated_depsgraph_get()
    namen = [('koerper' if o.name.startswith(KOERPER) else o.name) for o in netze]

    def lage():
        dg.update()
        V, F, L, N = [], [], [], []
        for k, o in enumerate(netze):
            me = o.evaluated_get(dg).to_mesh(); b = len(V)
            V += [o.matrix_world @ v.co for v in me.vertices]
            N += [(o.matrix_world.to_3x3() @ v.normal).normalized() for v in me.vertices]
            F += [tuple(b + i for i in q.vertices) for q in me.polygons]
            L += [k] * len(me.vertices)
            o.evaluated_get(dg).to_mesh_clear()
        return V, F, np.array(L), N

    def je_lage(V, F, L):
        return {t: BVHTree.FromPolygons(V, [f for f in F if L[f[0]] == t]) for t in set(L.tolist()) if any(L[f[0]] == t for f in F)}

    qa.animation_data_create(); qa.animation_data.action = None
    bpy.context.scene.frame_set(0)
    V, F, L, N = lage(); B = je_lage(V, F, L)
    c = Counter()
    for f in F:
        for k in range(len(f)): c[tuple(sorted((f[k], f[(k + 1) % len(f)])))] += 1
    rand_e = sorted({i for e, n in c.items() if n == 1 for i in e})
    deckt = {}
    for i in range(len(V)):
        best = None
        for t, bv in B.items():
            if t == L[i]: continue
            h = bv.ray_cast(V[i] + N[i] * 0.001, N[i], WEIT)
            if h[0] is not None and (best is None or h[3] < best[1]): best = (t, h[3])
        if best: deckt[i] = best[0]
    erg = {}
    for bn in BEW:
        a = akt.get(bn)
        if bn == 'Ruhe': qa.animation_data.action = None; f0 = f1 = 0
        elif a is None: print('FEHLT', bn); continue
        else:
            qa.animation_data.action = a
            if hasattr(qa.animation_data, 'action_slot') and a.slots: qa.animation_data.action_slot = a.slots[0]
            f0, f1 = a.frame_range
        zahl = {}; schlimm = 0
        for fr in np.linspace(f0, f1, 8):
            bpy.context.scene.frame_set(int(round(fr)))
            V, F, L, N = lage(); B = je_lage(V, F, L)
            rk = {}
            for t in B:
                idx = [i for i in rand_e if L[i] == t]
                kd = KDTree(max(1, len(idx)))
                for i in idx: kd.insert(V[i], i)
                if not idx: kd.insert(Vector((1e6, 1e6, 1e6)), 0)
                kd.balance(); rk[t] = kd
            n = 0
            for i, t in deckt.items():
                if t not in B: continue
                h = B[t].ray_cast(V[i] - N[i] * 0.001, -N[i], DURCH_WEIT)
                if h[0] is not None and h[1].dot(N[i]) > 0 and h[3] > 0.005 and rk[t].find(h[0])[2] > 0.03:
                    k = namen[L[i]] + '>' + namen[t]; zahl[k] = zahl.get(k, 0) + 1; n += 1
            schlimm = max(schlimm, n)
        erg[bn] = {'hoechstens': schlimm, 'wo': dict(sorted(zahl.items(), key=lambda x: -x[1])[:4])}
        print('DURCH', os.path.basename(p), bn, 'hoechstens', schlimm, 'Ecken je Bild;', erg[bn]['wo'])
    return {'bedeckt': len(deckt), 'ecken': len(V), 'bewegungen': erg}


alle = {}
for p in sorted(glob.glob(os.path.join(ORDNER, 'volk_*.glb'))):
    alle[os.path.basename(p)] = pruefe(p)
json.dump(alle, open(os.path.join(ORDNER, 'durch.json'), 'w'), indent=1, ensure_ascii=False)
print('DURCH OK', len(alle))
