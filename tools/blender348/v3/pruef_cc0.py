# 348.6 CC0-Geruest Runde 2: Messungen je Bewegung ohne Bild (Fremdpruefung Tom 34): Nadeln (Dreiecke, die sich gegen die Ruhelage
# stark dehnen), Abstand des Rueckenschilds zum Ruecken, Fackelhand, Kopf (Neigen, Drehen, Kippen), Standbreite, Arme abgespreizt.
# Aufruf: OUT=<figurordner> python -I pruef_cc0.py  -> Zeilen PRUEF <bewegung> {...}
import bpy, os, math, json
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; sk = bpy.data.objects['Held_Skelett']; me_o = bpy.data.objects['Held_Netz']
F = [tuple(p.vertices) for p in me_o.data.polygons]
names = {g.index: g.name for g in me_o.vertex_groups}
haupt = np.array([max(v.groups, key=lambda e: e.weight).group if v.groups else -1 for v in me_o.data.vertices])
def netz():
    dg = bpy.context.evaluated_depsgraph_get(); ev = me_o.evaluated_get(dg); m = ev.to_mesh()
    V = np.array([tuple(ev.matrix_world @ v.co) for v in m.vertices]); ev.to_mesh_clear(); return V
def ruhe():
    for t in sk.animation_data.nla_tracks: t.mute = True
    sk.animation_data.action = None
    for pb in sk.pose.bones: pb.location = (0, 0, 0); pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = (1, 0, 0, 0)
    scn.frame_set(0)
ruhe(); V0 = netz()
print('SCHILD-ECKEN')
E = set()
for f in F:
    for i in range(len(f)): a, b = f[i], f[(i + 1) % len(f)]; E.add((min(a, b), max(a, b)))
E = np.array(sorted(E)); L0 = np.linalg.norm(V0[E[:, 0]] - V0[E[:, 1]], axis=1)
# Schild: starr an einer Gruppe, hinter dem Ruecken (vorn ist -y), oberhalb der Huefte
# (alle Ecken mit derselben Gewichtung: rig.py gibt dem Schild die gemittelten Gewichte des Umhangs, frueher starr an einer Gruppe)
sig = [tuple(sorted((e.group, round(e.weight, 3)) for e in v.groups)) for v in me_o.data.vertices]
kand = [i for i in range(len(V0)) if V0[i, 1] > 0.12 and V0[i, 2] > 0.9]
from collections import Counter
haeuf = Counter(sig[i] for i in kand).most_common(1)
SCH = np.array([i for i in kand if haeuf and sig[i] == haeuf[0][0]] if haeuf and haeuf[0][1] > 200 else [], int)
REST = [f for f in F if not any(i in set(SCH.tolist()) for i in f)]
# CC0 Runde 4 (Fremdpruefung Runde 3: „Held rennt, von hinten Arm ueber dem Schild“): Ecken der Arme, die von hinten gesehen vor dem
# Schild liegen
ARM = np.array([i for i in range(len(V0)) if names.get(int(haupt[i]), '').startswith(('upperarm', 'lowerarm', 'hand'))], int)
def arm_vor_schild(V):   # Kamera hinter dem Helden, 15 und 45 Grad hoch (Blatt, Spiel): Armecke im Umriss (2,5 cm) und naeher an der Kamera
    if len(SCH) < 50 or not len(ARM): return 0, 0.0
    S = V[SCH]; A = V[ARM]; n, tief = 0, 0.0
    for el in (15, 45):
        e = math.radians(el); d = np.array([0, math.cos(e), math.sin(e)]); u = np.array([1.0, 0, 0]); w = np.cross(d, u)
        S2 = np.c_[S @ u, S @ w]; sd = S @ d; m_, t_ = 0, 0.0
        for k, (a2, ad) in enumerate(zip(np.c_[A @ u, A @ w], A @ d)):
            nah_ = np.hypot(*(S2 - a2).T) < 0.025
            if nah_.any() and ad > sd[nah_].max() + 0.005: m_ += 1; t_ = max(t_, (ad - sd[nah_].max()) * 100)
        if m_ > n: n, tief = m_, t_
    return n, tief
# Schild: Ecken mit Hauptgruppe wie der Schild (Bild: rig.py RIGID shield -> spine_03); hier ueber die Lage hinter dem Ruecken
info = json.load(open(OUT + '/held-info.json'))
acts = {t.name: t.strips[0].action for t in sk.animation_data.nla_tracks}
def bone(n): return sk.matrix_world @ sk.pose.bones[n].matrix
def winkel(v): return math.degrees(math.atan2(v.z, math.hypot(v.x, v.y)))
res = {}
for an, act in acts.items():
    for t in sk.animation_data.nla_tracks: t.mute = True
    sk.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    nad, nadg, kopf, stand, abspr, fackel, schild, rumpf = 0, {}, [], [], [], [], [], []
    avs = []
    for f in range(f0, f1 + 1, 2):
        scn.frame_set(f); V = netz()
        L = np.linalg.norm(V[E[:, 0]] - V[E[:, 1]], axis=1)
        bad = np.where((L > 2.5 * L0 + 0.01) & (L > 0.03))[0]
        nad = max(nad, len(bad))
        for k in bad[:200]:
            for v in E[k]:
                g = names.get(int(haupt[v]), '?'); nadg[g] = nadg.get(g, 0) + 1
        H = bone('Head'); fw = H.to_3x3() @ (sk.data.bones['Head'].matrix_local.to_3x3().inverted() @ Vector((0, -1, 0)))
        up = H.to_3x3() @ (sk.data.bones['Head'].matrix_local.to_3x3().inverted() @ Vector((0, 0, 1)))
        kopf.append((winkel(fw), math.degrees(math.atan2(fw.x, -fw.y)), math.degrees(math.atan2(up.x, up.z))))
        C = bone('spine_03').to_3x3() @ sk.data.bones['spine_03'].matrix_local.to_3x3().inverted()
        P = bone('pelvis').to_3x3() @ sk.data.bones['pelvis'].matrix_local.to_3x3().inverted()
        cf, pf = C @ Vector((0, -1, 0)), P @ Vector((0, -1, 0))
        rumpf.append((winkel(cf), math.degrees(math.atan2(cf.x, -cf.y)), math.degrees(math.atan2(pf.x, -pf.y)), math.degrees(math.atan2(fw.x, -fw.y)) - math.degrees(math.atan2(cf.x, -cf.y)), winkel(fw) - winkel(cf)))
        stand.append((bone('foot_l').translation - bone('foot_r').translation).x)
        for s in 'lr':
            u = bone('upperarm_' + s); d = (bone('lowerarm_' + s).translation - u.translation).normalized()
            abspr.append(abs(math.degrees(math.atan2(d.x, -d.z))))
        if 'Fackel' in an:
            h = bone('hand_l').translation; c = bone('spine_03').translation
            fackel.append((round((h.z - c.z) * 100, 1), round((c.y - h.y) * 100, 1)))
        if len(SCH) > 50:
            bv = BVHTree.FromPolygons([tuple(x) for x in V], REST)
            d = [bv.find_nearest(Vector(V[i]))[3] for i in SCH[::7]]
            nv = np.cross(V[SCH[1]] - V[SCH[0]], V[SCH[2]] - V[SCH[0]])
            schild.append(float(np.percentile(d, 5)) * 100)
            avs.append(arm_vor_schild(V))
    k = np.array(kopf)
    res[an] = dict(nadeln=nad, nadel_gruppen=dict(sorted(nadg.items(), key=lambda x: -x[1])[:6]),
                   kopf_neigen=[round(float(k[:, 0].min()), 1), round(float(k[:, 0].max()), 1)],
                   kopf_drehen=[round(float(k[:, 1].min()), 1), round(float(k[:, 1].max()), 1)],
                   kopf_kippen=[round(float(k[:, 2].min()), 1), round(float(k[:, 2].max()), 1)],
                   stand_cm=round(float(np.mean(stand)) * 100, 1), arm_abgespreizt_grad=round(float(np.mean(abspr)), 1))
    r = np.array(rumpf).mean(0)
    res[an].update(brust_vor_grad=round(-float(r[0]), 1), brust_drehen=round(float(r[1]), 1), becken_drehen=round(float(r[2]), 1),
                   kopf_gegen_brust_drehen=round(float(r[3]), 1), kopf_gegen_brust_heben=round(float(r[4]), 1))
    if schild: res[an]['schild_abstand_cm'] = [round(min(schild), 1), round(max(schild), 1)]
    if avs: res[an]['arm_vor_schild'] = dict(bilder=sum(1 for n_, t_ in avs if n_), ecken=max(n_ for n_, t_ in avs), cm=round(max(t_ for n_, t_ in avs), 1))
    if fackel: res[an]['fackelhand_ueber_brust_vor_cm'] = [fackel[0], fackel[len(fackel) // 2]]
    print('PRUEF', an, json.dumps(res[an], ensure_ascii=False))
ruhe()
json.dump(res, open(OUT + '/pruef_cc0.json', 'w'), indent=1, ensure_ascii=False)
