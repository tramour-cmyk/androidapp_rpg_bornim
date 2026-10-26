# 348.6 CC0 Feinschliff: Messungen der Kleidungslagen je Bewegung ohne Bild (Fremdpruefung 4c: Thessa orange Zacken an den Schultern,
# schwarzer Haarkeil im Nacken; Borin, Bram schwarzer Streifen hinter der Schulter im Gehen).
# durch: Ecken einer inneren Lage (Kittel, Koerper, Aermel, Wappenrock), die in Ruhe der Umhang bedeckt (Strahl entlang der
#        Normale trifft ihn binnen 8 cm) und in der Bewegung nicht mehr (sie stossen durch oder liegen frei); haar: wie weit sich das untere Drittel des langen Haars (hairback) von Umhang oder
#        Ruecken abhebt (gegen Ruhe); falten: Dreiecke, deren Normale gegen die Ruhe umklappt (Netz faltet sich, Schatten als Streifen)
# Aufruf: OUT=<figurordner> python -I pruef_lagen.py  -> Zeilen LAGEN <bewegung> {...}
import bpy, os, math, json
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
from mathutils.kdtree import KDTree
OUT = os.environ['OUT']
# Lagen aus held3.blend (getrennte Teile, cm) auf die Ecken des einen Netzes (m) abbilden
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3.blend')
TEILE = {}
for o in bpy.data.objects:
    if o.type != 'MESH': continue
    n = o.name.split('.')[0]
    if o.modifiers:
        dg = bpy.context.evaluated_depsgraph_get(); m = o.evaluated_get(dg).to_mesh()
        P = [tuple(o.matrix_world @ v.co) for v in m.vertices]; o.evaluated_get(dg).to_mesh_clear()
    else: P = [tuple(o.matrix_world @ v.co) for v in o.data.vertices]
    TEILE.setdefault(n, []).extend(P)
NAMEN = sorted(TEILE)
kd = KDTree(sum(len(p) for p in TEILE.values())); TI = []
for t, n in enumerate(NAMEN):
    for p in TEILE[n]: kd.insert(Vector(p) * 0.01, len(TI)); TI.append(t)
kd.balance()
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; sk = bpy.data.objects['Held_Skelett']; me_o = bpy.data.objects['Held_Netz']
F = [tuple(p.vertices) for p in me_o.data.polygons]
names = {g.index: g.name for g in me_o.vertex_groups}
haupt = np.array([max(v.groups, key=lambda e: e.weight).group if v.groups else -1 for v in me_o.data.vertices])
NV = {}
def netz():
    dg = bpy.context.evaluated_depsgraph_get(); ev = me_o.evaluated_get(dg); m = ev.to_mesh()
    V = np.array([tuple(ev.matrix_world @ v.co) for v in m.vertices]); NV['n'] = np.array([tuple(v.normal) for v in m.vertices])
    ev.to_mesh_clear(); return V
def ruhe():
    for t in sk.animation_data.nla_tracks: t.mute = True
    sk.animation_data.action = None
    for pb in sk.pose.bones: pb.location = (0, 0, 0); pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = (1, 0, 0, 0)
    scn.frame_set(0)
ruhe(); V0 = netz()
TEIL = np.array([NAMEN[TI[kd.find(Vector(v))[1]]] for v in V0])
if 'teil' in me_o.data.attributes and os.path.exists(OUT + '/teile.json'):   # Feinschliff 4: Kennung aus rig.py statt geraten
    tn = json.load(open(OUT + '/teile.json')); ti_ = np.zeros(len(me_o.data.vertices), np.int32)
    me_o.data.attributes['teil'].data.foreach_get('value', ti_); TEIL = np.array([tn[i] for i in ti_])
def ecken(*n): return np.where(np.isin(TEIL, n))[0]
def flaechen(idx):
    s = set(idx.tolist()); return [f for f in F if all(i in s for i in f)]
UM = ecken('cloak'); UF = flaechen(UM)
INNEN = ecken('chain', 'body', 'sleeves', 'tabard', 'robe', 'apron', 'belt')
HB = ecken('hairback', 'hairbraid')
TRAG = ecken('cloak', 'body', 'chain', 'tabard', 'robe', 'sleeves')
def bedeckt(V, idx, faces):   # liegt der Umhang ueber der Ecke? Strahl entlang ihrer Normale nach aussen (bis 8 cm)
    bv = BVHTree.FromPolygons([tuple(x) for x in V], faces); N = NV['n']
    return np.array([bv.ray_cast(Vector(V[i]) + Vector(N[i]) * 0.001, Vector(N[i]), 0.08)[0] is not None for i in idx])
N0V = NV['n']
# Feinschliff 4 (Helfer: Jorins blaue Aermelzacken durch das Kettenhemd an der Schulter): Aermelecken, die in Ruhe Kettenhemd oder
# Kittel bedeckt (Strahl entlang der Normale binnen 3 cm), in der Bewegung nicht mehr
KE = ecken('chain'); KEF = flaechen(KE); AE = ecken('sleeves')
def bedeckt_k(V, idx):
    bv = BVHTree.FromPolygons([tuple(x) for x in V], KEF); N = NV['n']
    return np.array([bv.ray_cast(Vector(V[i]) + Vector(N[i]) * 0.001, Vector(N[i]), 0.03)[0] is not None for i in idx])
AE_N = AE[bedeckt_k(V0, AE)] if len(AE) and len(KEF) else np.array([], int)
if len(UM) and len(UF):
    IN_N = INNEN[bedeckt(V0, INNEN, UF)]   # in Ruhe vom Umhang bedeckt
else: IN_N = np.array([], int)
if len(HB):
    z = V0[HB, 2]; HU = HB[z < np.percentile(z, 33)]
    TF = flaechen(np.setdiff1d(TRAG, HB))
    bvt = BVHTree.FromPolygons([tuple(x) for x in V0], TF); H0 = np.array([bvt.find_nearest(Vector(V0[i]))[3] for i in HU])
# abheben (Feinschliff, Borin, Bram): Ecken von Aermel, Kittel, Wappenrock, die in Ruhe bis 3 cm ueber dem Koerper liegen und sich in
# der Bewegung mehr als 1,5 cm weiter von ihm entfernen (die Schale hebt sich ab, man sieht hinein)
SCH = ecken('sleeves', 'chain', 'tabard'); KF = flaechen(ecken('body'))
if len(SCH) and len(KF):
    bvk = BVHTree.FromPolygons([tuple(x) for x in V0], KF); d0 = np.array([bvk.find_nearest(Vector(V0[i]))[3] for i in SCH])
    SCH_N = SCH[d0 < 0.03]; D0 = d0[d0 < 0.03]
else: SCH_N = np.array([], int)
def normalen(V):
    N = []
    for f in F:
        a, b, c = V[f[0]], V[f[1]], V[f[2]]; N.append(np.cross(b - a, c - a))
    N = np.array(N); return N / np.maximum(np.linalg.norm(N, axis=1, keepdims=True), 1e-12)
N0 = normalen(V0); A0 = np.array([np.linalg.norm(np.cross(V0[f[1]] - V0[f[0]], V0[f[2]] - V0[f[0]])) for f in F])
FG = np.array([names.get(int(haupt[f[0]]), '?') for f in F]); FT = np.array([TEIL[f[0]] for f in F])
acts = {t.name: t.strips[0].action for t in sk.animation_data.nla_tracks}
res = {}
for an, act in acts.items():
    for t in sk.animation_data.nla_tracks: t.mute = True
    sk.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    durch, durch_t, haar, falt, falt_g, abh, abh_cm, abh_t = 0, {}, 0.0, 0, {}, 0, 0.0, {}
    dk, dk_t = 0, {}
    for f in range(f0, f1 + 1, 2):
        scn.frame_set(f); V = netz()
        if len(IN_N):
            bad = ~bedeckt(V, IN_N, UF)
            if os.environ.get('ORT') and bad.sum() > durch:
                print('ORT', an, f, [tuple(int(round(x * 100)) for x in V0[i]) for i in IN_N[bad]][:40])
            if bad.sum() > durch:
                durch = int(bad.sum()); durch_t = {}
                for i in IN_N[bad]:
                    k = '%s/%s' % (TEIL[i], names.get(int(haupt[i]), '?')); durch_t[k] = durch_t.get(k, 0) + 1
        if len(AE_N):
            bad = ~bedeckt_k(V, AE_N)
            if bad.sum() > dk:
                dk = int(bad.sum()); dk_t = {}
                for i in AE_N[bad]:
                    k = names.get(int(haupt[i]), '?'); dk_t[k] = dk_t.get(k, 0) + 1
                if os.environ.get('ORT'): print('DK', an, f, [tuple(int(round(x * 100)) for x in V0[i]) for i in AE_N[bad]][:30])
        if len(HB):
            bv = BVHTree.FromPolygons([tuple(x) for x in V], TF)
            d = np.array([bv.find_nearest(Vector(V[i]))[3] for i in HU]) - H0
            haar = max(haar, float(np.percentile(d, 95)) * 100)
        if len(SCH_N):
            bvk = BVHTree.FromPolygons([tuple(x) for x in V], KF)
            dd = np.array([bvk.find_nearest(Vector(V[i]))[3] for i in SCH_N]) - D0; ab = dd > 0.015
            if ab.sum() > abh:
                abh = int(ab.sum()); abh_cm = round(float(dd.max()) * 100, 1); abh_t = {}
                for i in SCH_N[ab]:
                    k = '%s/%s' % (TEIL[i], names.get(int(haupt[i]), '?')); abh_t[k] = abh_t.get(k, 0) + 1
                if os.environ.get('ORT'): print('AB', an, f, [tuple(int(round(x * 100)) for x in V0[i]) for i in SCH_N[ab]][:30])
        # Feinschliff 4: gegen die mitgedrehte Ruhenormale des Hauptknochens (eine Hand, die sich mehr als 90 Grad dreht, ist keine Falte;
        # Borin Stehen: 303 Dreiecke an handR/wristR waren nur die gedrehte Hand)
        R = {}
        for pb in sk.pose.bones:
            m = (sk.matrix_world @ pb.matrix @ pb.bone.matrix_local.inverted() @ sk.matrix_world.inverted()).to_3x3()
            R[pb.name] = np.array(m)
        NR = np.array([R[g] @ n if g in R else n for g, n in zip(FG, N0)])
        N = normalen(V); um = (np.einsum('ij,ij->i', N, NR) < 0) & (A0 > 1e-6)
        if um.sum() > falt:
            falt = int(um.sum()); falt_g = {}
            for k in np.where(um)[0]:
                g = '%s/%s' % (FT[k], FG[k]); falt_g[g] = falt_g.get(g, 0) + 1
    res[an] = dict(durch_umhang=durch, durch_wo=dict(sorted(durch_t.items(), key=lambda x: -x[1])[:5]),
                   falten=falt, falten_wo=dict(sorted(falt_g.items(), key=lambda x: -x[1])[:5]))
    if len(HB): res[an]['haar_ab_cm'] = round(haar, 1)
    if len(AE_N): res[an].update(aermel_durch=dk, aermel_von=len(AE_N), aermel_wo=dict(sorted(dk_t.items(), key=lambda x: -x[1])[:4]))
    if len(SCH_N): res[an].update(abheben=abh, abheben_cm=abh_cm, abheben_wo=dict(sorted(abh_t.items(), key=lambda x: -x[1])[:5]))
    print('LAGEN', an, json.dumps(res[an], ensure_ascii=False))
ruhe()
json.dump(res, open(OUT + '/pruef_lagen.json', 'w'), indent=1, ensure_ascii=False)
