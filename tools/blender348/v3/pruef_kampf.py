# 348.6 Kampf Runde 5 (Tom 27.10.): Pruefung der Kampfbewegungen an den echten Netzen statt an Kapseln und Ebenen. Die Pruefzeilen
# in kampf.py fanden die Befunde der Pruefer 4b nicht (Klinge im Schild bei Stich 0,17-0,23 und Hieb 0,53-0,57: der Schild ist 9 cm
# gewoelbt, gerechnet war eine Platte von 4 cm). Schwert und Schild sitzen wie in kampfblatt.py (figur.gd _hold, faust_R); je Bild
# schneiden sich die Dreiecke (BVH-Ueberlappung): Klinge mit Schild, Klinge mit Koerper (nach Teil), Schild mit Koerper (ohne die
# linke Hand); dazu Schild und Schwert tiefst ueber dem Boden und im Liegen die Lage des Schilds gegen den Boden.
# Aufruf: OUT=<ordner mit held3-rig.blend, teile.json, held-info.json> WAFFEN=<ordner mit longsword.glb, shield.glb>
#         bl/bin/python -I pruef_kampf.py [<blend>]   ->  Zeilen „NETZ <Bewegung> …“, je Befund die Zeiten in s
import bpy, os, sys, math, json
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

OUT = os.environ['OUT']; WAF = os.environ.get('WAFFEN', OUT + '/../waffen')
BLEND = sys.argv[-1] if sys.argv[-1].endswith('.blend') else OUT + '/held3-rig.blend'
bpy.ops.wm.open_mainfile(filepath=BLEND)
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']; ad = rig.animation_data; held = bpy.data.objects['Held_Netz']
INFO = json.load(open(os.path.join(os.path.dirname(BLEND), 'held-info.json')))
TN = json.load(open(os.path.join(os.path.dirname(BLEND), 'teile.json')))
SPRUNG_M = 0.08      # Runde 6: so viel schneller (m je Bild, 2,4 m/s in einem Bild) darf das Netz von einem Bild zum naechsten werden
NAMEN = os.environ.get('BEWEGUNGEN', 'Kampfstehen,Ausholen,Hieb,Stich,Treffer,Ausweichen,Abwehr,Tod').split(',')


def lade(name):
    vor = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(WAF, name + '.glb'))
    neu = [o for o in bpy.data.objects if o not in vor and o.type == 'MESH']
    o = neu[0]
    for x in neu[1:]: x.parent = o
    o.parent = None
    return o


schwert, schild = lade('longsword'), lade('shield')
PB = rig.pose.bones
A = Vector(INFO['faust_R']['achse']); G = Vector(INFO['faust_R']['griff'])
RL = rig.data.bones['hand_l'].matrix_local
cols = [Vector((0, -1, 0)), Vector((-1, 0, 0)), Vector((0, 0, 1))]   # wie kampfblatt.py
SCH0 = Matrix([[cols[j][i] for j in range(3)] for i in range(3)]).to_4x4()
SCH0.translation = (RL @ Vector((0, 0.157 * 0.35, 0))) + Vector((0.04, 0, 0))
SCH_REL = RL.inverted() @ SCH0


def setze_waffen():
    H = rig.matrix_world @ PB['hand_r'].matrix; R = H.to_3x3()
    ax = (R @ A).normalized(); y = R.col[1].normalized(); edge = (y - ax * y.dot(ax)).normalized()
    M = Matrix([[edge[i], ax.cross(edge)[i], ax[i]] for i in range(3)]).to_4x4(); M.translation = H @ G
    schwert.matrix_world = M
    schild.matrix_world = rig.matrix_world @ PB['hand_l'].matrix @ SCH_REL


# Klinge: oberhalb der Parierstange (Ecken mit |x| > 3 cm sind die Stange)
sv = schwert.data.vertices
STANGE = max(v.co.z for v in sv if abs(v.co.x) > 0.03)
KL_V = [v.co.copy() for v in sv]
KL_F = [list(p.vertices) for p in schwert.data.polygons if min(sv[i].co.z for i in p.vertices) > STANGE + 0.005]
SH_V = [v.co.copy() for v in schild.data.vertices]
SH_F = [list(p.vertices) for p in schild.data.polygons]
SH_N = Vector((0, -1, 0))     # Vorderseite (waffen.py: glTF +Z = Blender -Y)

# Koerper: Teil und staerkster Knochen je Ecke; ausgeblendete Teile (Rueckenschild, Griff in der Scheide) weg
me = held.data; n = len(me.vertices)
t = np.zeros(n, np.int32)
if 'teil' in me.attributes: me.attributes['teil'].data.foreach_get('value', t)
teil = [TN[i] if i < len(TN) else '?' for i in t]
gi = {g.index: g.name for g in held.vertex_groups}
kn = [gi[max(v.groups, key=lambda e: e.weight).group] if len(v.groups) else '-' for v in me.vertices]
aus_g = {held.vertex_groups[b].index for b in ('schild_ruecken', 'schwert_griff') if b in held.vertex_groups}
aus = [any(e.group in aus_g and e.weight > 0.5 for e in v.groups) for v in me.vertices]


def gruppe(i):
    tl, k = teil[i], kn[i]
    if tl == 'cloak': return 'Umhang'
    if tl in ('Cylinder', 'Sphere'): return 'Scheide'
    if tl == 'tabard': return 'Wappenrock'
    if k in ('Head', 'neck_01') or tl in ('head', 'helm', 'helmrim', 'ear', 'eye', 'lid'): return 'Kopf'
    if k.startswith(('hand_l', 'lowerarm_l')) or tl in ('handL', 'wristL'): return 'Schildhand'
    if k.startswith(('hand_r', 'lowerarm_r')) or tl in ('handR', 'wristR'): return 'Schwerthand'
    if k.startswith(('upperarm_l', 'clavicle_l')): return 'Schildarm'
    if k.startswith(('upperarm', 'clavicle')): return 'Oberarm'
    if k.startswith(('thigh', 'calf', 'foot', 'ball')): return 'Bein'
    return 'Rumpf'


POLY = [(list(p.vertices), gruppe(p.vertices[0])) for p in me.polygons if not any(aus[i] for i in p.vertices)]
P_F = [f for f, _ in POLY]; P_G = [g for _, g in POLY]


# wie kampfblatt.py (15 Grad von oben), dazu die Spielkamera: kampfort.gd 25 Grad von oben, Kampflinie 30 Grad nach rechts, Helden
# vorn links mit Blick zu den Gegnern: sie sieht den Helden von hinten rechts
SICHT = [('vorn links', 35, 15), ('vorn rechts', -35, 15), ('hinten rechts', -145, 15), ('Spiel', -150, 25)]


def welt(vs, M):
    return [M @ v for v in vs]


def bvh_held():
    dg = bpy.context.evaluated_depsgraph_get(); ev = held.evaluated_get(dg); m = ev.to_mesh()
    M = held.matrix_world; V = [M @ v.co for v in m.vertices]; ev.to_mesh_clear()
    return BVHTree.FromPolygons(V, P_F), V


out = {}
for nm in NAMEN:
    if nm not in bpy.data.actions: print('fehlt', nm); continue
    for tr in ad.nla_tracks: tr.mute = True
    act = bpy.data.actions[nm]; ad.action = act; ad.use_nla = False
    if act.slots: ad.action_slot = act.slots[0]
    nb = int(round(act.frame_range[1] - act.frame_range[0]))
    bef = {}
    sch_z, kl_z, lage = 9.0, 9.0, None
    alt_v, alt_s, schritt = None, None, []   # Runde 6: Weg des Netzes je Bild (Sprung)
    for f in range(nb + 1):
        scn.frame_set(f); setze_waffen(); bpy.context.view_layer.update()
        BH, V = bvh_held()
        KV = welt(KL_V, schwert.matrix_world); SV = welt(SH_V, schild.matrix_world)
        BK = BVHTree.FromPolygons(KV, KL_F); BS = BVHTree.FromPolygons(SV, SH_F)
        s = '%.2f' % (f / 30.0)
        if BK.overlap(BS): bef.setdefault('Klinge im Schild', []).append(s)
        for g in sorted({P_G[j] for _, j in BK.overlap(BH)} - {'Schwerthand'}):
            bef.setdefault('Klinge in ' + g, []).append(s)
        # Klinge in der Hoehlung des Schilds (hinter der gewoelbten Vorderseite, innerhalb des Umrisses): sieht aus wie im Schild
        Mi = schild.matrix_world.inverted(); KL_ = [Mi @ KV[i] for f_ in KL_F for i in f_]
        if any(-0.28 < q.x < 0.28 and -0.42 < q.z < 0.30 and -0.06 < q.y < 0.10 and (q.x / 0.28) ** 2 + (max(q.z, 0) / 0.30) ** 2 < 1.2
               for q in KL_): bef.setdefault('Klinge hinter Schild', []).append(s)
        ab = min((BS.find_nearest(KV[i])[3] for f_ in KL_F for i in f_), default=9.0)
        if ab < 0.03: bef.setdefault('Klinge am Schild', []).append(s)
        # Bild: Teile der Klinge (Mittellinie) hinter Schild oder Koerper, der Rest sichtbar: sieht aus, als steckte sie darin
        Ms = schwert.matrix_world; L = [Ms @ Vector((0, 0, STANGE + (0.75 - STANGE) * i / 14)) for i in range(15)]
        for vn, az, el in SICHT:
            a, e = math.radians(az), math.radians(el)
            d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
            hinter = []
            for q in L:
                h = BS.ray_cast(q + d * 0.004, d, 10.0)
                if h[0] is not None: hinter.append('Schild'); continue
                h = BH.ray_cast(q + d * 0.004, d, 10.0)
                hinter.append(P_G[h[2]] if h[0] is not None else '')
            # Spitze im Bild auf Schild oder Koerper (vor oder hinter ihm): die Klinge endet dort und wirkt, als steckte sie darin
            # (Pruefer 4b: Hieb 0,53-0,57 und Stich 0,17-0,23 vorn rechts, die Klinge zeigt fast zur Kamera und endet am Schild)
            # nur, wenn die Spitze verdeckt ist und die Klinge an der Stange sichtbar, oder die Flaeche hoechstens 6 cm hinter ihr liegt
            T = L[-1]
            for sg in (1, -1):
                h = BS.ray_cast(T + d * sg * 0.004, d * sg, 10.0 if sg > 0 else 0.06); x = 'Schild'
                if h[0] is None:
                    h = BH.ray_cast(T + d * sg * 0.004, d * sg, 10.0 if sg > 0 else 0.06); x = P_G[h[2]] if h[0] is not None else ''
                if h[0] is None and sg < 0 and (L[-1] - L[0]).normalized().dot(d) ** 2 > 1 - 0.55 ** 2:
                    # Klinge zeigt fast zur Kamera (im Bild hoechstens 55 % lang) und endet im Bild auf Schild oder Koerper
                    h = BS.ray_cast(T - d * 0.004, -d, 10.0); x = 'Schild'
                    if h[0] is None:
                        h = BH.ray_cast(T - d * 0.004, -d, 10.0); x = P_G[h[2]] if h[0] is not None else ''
                    if h[0] is not None and x != 'Schwerthand':
                        bef.setdefault('Klinge verkuerzt auf %s (%s)' % (x, vn), []).append(s); break
                if h[0] is None or x == 'Schwerthand' or (sg > 0 and hinter[0]): continue
                bef.setdefault('Spitze %s %s (%s)' % ('hinter' if sg > 0 else 'an', x, vn), []).append(s); break
            # Runde 6 (Pruefer 5, hoch: Hieb „Spiel“ 0,33-0,47 Klinge hinter Koerper und Umhang): mehr als die Haelfte der Klinge
            # verdeckt, ohne die Schwerthand
            vd = sum(1 for x in hinter if x and x != 'Schwerthand') / len(hinter)
            if vd > 0.5: bef.setdefault('Klinge verdeckt (%s)' % vn, []).append(s)
            if os.environ.get('SICHT_DBG') == nm and vn == 'Spiel':
                print('SICHT %s %s %.2f %s Spitze %s' % (nm, s, vd, ''.join((x or '.')[0] for x in hinter), tuple(round(c, 2) for c in L[-1])))
            for g in {x for x in hinter if x and x != 'Schwerthand'}:
                k = hinter.count(g) / len(hinter)
                if 0.1 < k and hinter.count('') > 1: bef.setdefault('Klinge steckt in %s (%s)' % (g, vn), []).append(s)
        for g in sorted({P_G[j] for _, j in BS.overlap(BH)} - {'Schildhand', 'Schildarm'}):
            bef.setdefault('Schild in ' + g, []).append(s)
        sch_z = min(sch_z, min(p.z for p in SV)); kl_z = min(kl_z, min(KV[i].z for f_ in KL_F for i in f_))
        if min(p.z for p in SV) < -0.01: bef.setdefault('Schild im Boden', []).append(s)
        if min(p.z for p in KV) < -0.01: bef.setdefault('Schwert im Boden', []).append(s)
        # Runde 6 (Pruefer 5, gering: Tod 0,27-0,40 Spitze auf Sohlenhoehe): Spitze unter 8 cm, waehrend die Faust noch ueber 35 cm hoch ist
        if L[-1].z < 0.08 and schwert.matrix_world.translation.z > 0.35: bef.setdefault('Spitze am Boden', []).append(s)
        # Runde 6 (Pruefer 5, mittel: Ausweichen 0,00-0,07 Sprung): Weg der Ecken je Bild (Median des Netzes) und dessen Aenderung
        # gegen das vorige Bild; Sprung, wenn das Netz aus dem Stand oder gegen das vorige Bild um mehr als SPRUNG_M je Bild schneller wird
        Vn = np.array(V)
        if alt_v is not None:
            st = float(np.median(np.linalg.norm(Vn - alt_v, axis=1))); schritt.append(st)
            if st - (alt_s or 0.0) > SPRUNG_M: bef.setdefault('Sprung', []).append(s)
            alt_s = st
        alt_v = Vn
        if f == nb:
            nrm = (schild.matrix_world.to_3x3() @ SH_N).normalized()
            ax = (schwert.matrix_world.to_3x3() @ Vector((0, 0, 1))).normalized()
            lage = {'schild_gegen_boden_grad': round(90 - math.degrees(math.asin(min(1.0, abs(nrm.z))))),
                    'klinge_gegen_boden_grad': round(math.degrees(math.asin(min(1.0, abs(ax.z)))))}
    out[nm] = {'schritt_max_m': round(max(schritt, default=0.0), 3), 'befunde': bef, 'schild_tiefst': round(sch_z, 3), 'klinge_tiefst': round(kl_z, 3), 'ende': lage}
    zeit = lambda l: l[0] if len(l) == 1 else '%s-%s (%d)' % (l[0], l[-1], len(l))
    print('NETZ %-11s %s  Schild tiefst %+.3f  Klinge tiefst %+.3f  Netz je Bild bis %.3f m  Ende %s' % (
        nm, '  '.join('%s %s' % (k, zeit(v)) for k, v in bef.items()) or 'sauber', sch_z, kl_z, max(schritt, default=0.0), lage))
    if os.environ.get('SCHRITTE'): print('SCHRITT', nm, ' '.join('%.3f' % x for x in schritt))
json.dump(out, open(os.path.join(os.path.dirname(BLEND), 'pruef_kampf.json'), 'w'), indent=1, ensure_ascii=False)
