# 2031 (Chef 25.11., 13:39: „MakeHuman nehmen und testen … Kutte/Robe als Alternative“): ein MakeHuman-Kleidungsstueck (.mhclo/.obj,
# auf dem Grundkoerper hm08) auf den Kaufkoerper (Universal Base Characters) als Schrankteil. Weg S der LISTE-QUELLEN.md „MakeHuman-
# Asset-Packs“; eigener Weg nach kauf_kleid.py (376.1), Quellkoerper hm08 statt held3:
#  (1) Kaufkoerper (held_<TRACHT>_<G>.bin: Leib_*, Kopf, Geruest) in die A-Haltung von hm08 drehen (Arme, Beine nach den hm08-Gelenken)
#  (2) hm08 je Knochen auf den gedrehten Kaufkoerper (Gelenke aus den Gruppen joint-* in base.obj), dann Restunterschied als Feld
#      (naechster Punkt der Kaufhaut, geglaettet ueber das hm08-Netz); Helfer (helper-skirt …) mit dem Feld der naechsten Koerperecke
#  (3) Stueck aus seiner .mhclo-Bindung an den angepassten hm08 (wie MakeHuman: drei Ecken, Gewichte, Versatz mal Massstab)
#  (4) wo der Kaufkoerper durchsticht, Stoff hinaus (RAND ueber der Haut); (5) Gewichte vom Kaufkoerper (naechste Flaeche, ueber das
#      Stueck geglaettet: der Rock folgt beiden Beinen); (6) zurueck in die Ruhelage (T-Haltung) mit diesen Gewichten
#  (7) ausduennen auf ZIEL_DREIECKE, Bild auf hoechstens 1024 px; Netz „Teil_<KENNUNG>“ am Geruest, Datei <ZIEL>/<datei>_<G>.glb
# Koerper unter dem Stoff: im Spiel ueber die Leib-Liste des Schrankteils (heldfigur.gd MH_SCHRANK), nicht hier.
# Aufruf: HELD=<held_KLOSTER_M.bin> HM08=<mpfb/data/3dobjs/base.obj> STUECKE=<a.mhclo>,<b.mhclo> G=M ZIEL=<ordner> [KENNUNG=MH_KUTTE]
#         [DATEI=mh_kutte] [ZIEL_DREIECKE=3000] bl/bin/python -I kleid_mh.py
import bpy, bmesh, os, sys
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from mathutils.kdtree import KDTree

HELD = os.environ['HELD']
HM08 = os.environ['HM08']
STUECKE = [s for s in os.environ['STUECKE'].split(',') if s]
G = os.environ.get('G', 'M')
ZIEL = os.environ.get('ZIEL', '.')
KENNUNG = os.environ.get('KENNUNG', 'MH_KUTTE')
DATEI = os.environ.get('DATEI', 'mh_kutte')
ZIEL_DREIECKE = int(os.environ.get('ZIEL_DREIECKE', '3000'))
BILD = int(os.environ.get('BILD', '1024'))
RAND = float(os.environ.get('RAND', '0.012'))      # Stoff mindestens so weit ueber der Kaufhaut (m)
RAND_KOPF = float(os.environ.get('RAND_KOPF', '0.045'))   # Kapuze ueber dem Kopf weiter (Voelker: Spitzohren, groesserer Kopf; kutte_haut_2031)
RAND_HAND = float(os.environ.get('RAND_HAND', '0.02'))   # Aermel ueber der Hand weiter (groessere Haende von Zwerg und Orkbluetigen)
LAGE = float(os.environ.get('LAGE', '0.008'))       # aeussere Lage nach dem Ausduennen mindestens so weit vom Hauptstueck (m)
NAH = float(os.environ.get('NAH', '0.05'))          # aeussere Lage (Kapuzenkragen, Guertel, Strick) naeher als das am Hauptstueck
GLATT = int(os.environ.get('GLATT', '12'))          # Glaettung der Gewichte ueber das Stueck (Schritte)
os.makedirs(ZIEL, exist_ok=True)


def mh(p):
    """obj in Ecken-Reihenfolge der Datei: Ecken (Blender-Lage, m: x, -z, y; MakeHuman dm), Flaechen, Gruppe je Flaeche"""
    V, F, FG, g = [], [], [], None
    for l in open(p, encoding='utf-8', errors='replace'):
        if l.startswith('v '): V.append([float(x) for x in l.split()[1:4]])
        elif l.startswith('g '): g = l.split()[1]
        elif l.startswith('f '): F.append([int(t.split('/')[0]) - 1 for t in l.split()[1:]]); FG.append(g)
    V = np.array(V) * 0.1
    return np.stack([V[:, 0], -V[:, 2], V[:, 1]], 1), F, FG


def mhclo(p):
    """Bindung je Ecke: (Ecken, Gewichte, Versatz in Blender-Lage, m), Massstab je Achse (a, b, Bezug) und obj-Datei"""
    refs, kopf, verts, d = [], {}, False, os.path.dirname(p)
    for l in open(p, encoding='utf-8', errors='replace'):
        s = l.split()
        if not s or s[0].startswith('#'): continue
        if verts:
            if len(s) == 9:
                i = [int(x) for x in s[:3]]; w = [float(x) for x in s[3:6]]; o = [float(x) for x in s[6:9]]
                refs.append((i, w, [o[0] * 0.1, -o[2] * 0.1, o[1] * 0.1]))
                continue
            if len(s) == 1 and s[0].lstrip('-').isdigit():
                refs.append(([int(s[0])] * 3, [1.0, 0.0, 0.0], [0.0, 0.0, 0.0])); continue
            verts = False
        if s[0] == 'verts': verts = True
        elif s[0] in ('x_scale', 'y_scale', 'z_scale'): kopf[s[0]] = (int(s[1]), int(s[2]), float(s[3]))
        elif s[0] in ('obj_file', 'material', 'name'): kopf[s[0]] = ' '.join(s[1:])
        elif s[0] == 'delete_verts': break
    return refs, kopf, d


# ---------------------------------------------------------------- 1. Kaufkoerper
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=HELD)
arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
_aug = [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith('Eyes')]
AUGEN = (sum((_aug[0].matrix_world @ v.co for v in _aug[0].data.vertices), Vector()) / len(_aug[0].data.vertices)) if _aug else None   # haut_mh.py: Gesicht
AUGEN_LR = []   # haut_mh.py: Mitte jedes Auges
if _aug:
    _p = np.array([_aug[0].matrix_world @ v.co for v in _aug[0].data.vertices])
    AUGEN_LR = [_p[_p[:, 0] > 0].mean(0), _p[_p[:, 0] <= 0].mean(0)]
for o in [o for o in bpy.data.objects if o.type == 'MESH']:
    if not (o.name.startswith('Leib_') or 'Regular' in o.name): bpy.data.objects.remove(o)   # Leib und Kopf (RegularMale, Female_Regular)
koerper = [o for o in bpy.data.objects if o.type == 'MESH']
print('KOERPER', [o.name for o in koerper])
AW = arm.matrix_world.copy()


def gelenk(name):   # Kopf eines Knochens in Weltlage (gedreht)
    pb = arm.pose.bones[name]
    return AW @ pb.head


def knochen(*namen):
    for n in namen:
        if n in arm.pose.bones: return n
    raise KeyError(namen)


# hm08: Gelenke aus den Gruppen joint-* (Mitte der Gelenkwuerfel)
HV, HF, HFG = mh(HM08)
koerper_f = [f for f, g in zip(HF, HFG) if g == 'body']
koerper_e = sorted(set(i for f in koerper_f for i in f))


def hj(n):
    idx = sorted(set(i for f, g in zip(HF, HFG) if g == 'joint-' + n for i in f))
    return Vector(HV[idx].mean(0))


SEITEN = {'l': 'l', 'r': 'r'}
# Kette je Glied: Knochen des Kaufkoerpers, hm08-Gelenk am Kopf, hm08-Gelenk am Ende
KETTEN = []
for s in 'lr':
    KETTEN += [(knochen('upperarm_' + s), s + '-shoulder', s + '-elbow'), (knochen('lowerarm_' + s), s + '-elbow', s + '-hand'),
               (knochen('hand_' + s), s + '-hand', s + '-finger-3-1'),
               (knochen('thigh_' + s), s + '-upper-leg', s + '-knee'), (knochen('calf_' + s), s + '-knee', s + '-ankle'),
               (knochen('foot_' + s), s + '-ankle', s + '-toe-3-1')]
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')
ROT = AW.to_3x3()
for kn, a, b in KETTEN:
    bpy.context.view_layer.update()
    pb = arm.pose.bones[kn]
    ziel = (ROT.inverted() @ (hj(b) - hj(a))).normalized()   # Richtung im Raum des Geruests
    cur = pb.matrix.copy()
    q = cur.to_3x3().col[1].normalized().rotation_difference(ziel)
    pb.matrix = Matrix.Translation(cur.translation) @ q.to_matrix().to_4x4() @ Matrix.Translation(-cur.translation) @ cur
bpy.context.view_layer.update()
bpy.ops.object.mode_set(mode='OBJECT')


def netz_welt(o):
    dg = bpy.context.evaluated_depsgraph_get()
    oe = o.evaluated_get(dg); me = oe.to_mesh()
    V = np.array([oe.matrix_world @ v.co for v in me.vertices])
    T = [list(p.vertices) for p in me.polygons]
    oe.to_mesh_clear()
    return V, T


KV, KT, KO = [], [], []   # gedrehter Kaufkoerper: Ecken, Dreiecke/Flaechen, (Objekt, Ecke)
for o in koerper:
    V, T = netz_welt(o)
    b = len(KV)
    KV += list(V); KT += [[b + i for i in t] for t in T]; KO += [(o, i) for i in range(len(V))]
KV = np.array(KV)
bvh = BVHTree.FromPolygons([Vector(v) for v in KV], KT)
KOPF_F = np.array(['Regular' in KO[t[0]][0].name for t in KT])   # Flaeche des Kopfnetzes
HAND_F = np.array([KO[t[0]][0].name == 'Leib_HAND' for t in KT])
print('KAUFKOERPER gedreht', len(KV), 'Ecken')

# ---------------------------------------------------------------- 2. hm08 auf den gedrehten Kaufkoerper
# Gelenke beider Koerper, Glieder als Strecken
PAARE = {'becken': ('pelvis', 'neck'), 'hals': ('neck', 'head')}
J_u, J_h = {}, {}
J_h['pelvis'] = hj('pelvis'); J_h['neck'] = hj('neck'); J_h['head'] = hj('head')
J_u['pelvis'] = gelenk(knochen('pelvis')); J_u['neck'] = gelenk(knochen('neck_01')); J_u['head'] = gelenk(knochen('Head'))
kopf_oben_u = Vector((0, 0, KV[:, 2].max())); kopf_oben_h = Vector((0, 0, HV[koerper_e, 2].max()))
J_u['top'] = Vector((J_u['head'].x, J_u['head'].y, kopf_oben_u.z)); J_h['top'] = Vector((J_h['head'].x, J_h['head'].y, kopf_oben_h.z))
STRECKEN = [('pelvis', 'neck'), ('neck', 'head'), ('head', 'top')]
for kn, a, b in KETTEN:
    s = a[0]
    J_h[a] = hj(a); J_h[b] = hj(b)
    pb = arm.pose.bones[kn]
    J_u[a] = AW @ pb.head
    if b not in J_u: J_u[b] = AW @ pb.tail if not b.endswith(('finger-3-1', 'toe-3-1')) else None
    STRECKEN.append((a, b))
for s in 'lr':   # Ende von Hand und Fuss: Laenge wie hm08 mal Massstab des Gliedes davor
    for a, b, v in [(s + '-hand', s + '-finger-3-1', s + '-elbow'), (s + '-ankle', s + '-toe-3-1', s + '-knee')]:
        f = (J_u[a] - J_u[v]).length / (J_h[a] - J_h[v]).length
        d = (arm.matrix_world.to_3x3() @ arm.pose.bones[knochen(('hand_' if 'hand' in a else 'foot_') + s)].matrix.to_3x3().col[1]).normalized()
        J_u[b] = J_u[a] + d * (J_h[b] - J_h[a]).length * f
    STRECKEN += [('neck', s + '-shoulder'), ('pelvis', s + '-upper-leg')]
    J_h[s + '-shoulder'] = hj(s + '-shoulder'); J_h[s + '-upper-leg'] = hj(s + '-upper-leg')


def strecke_T(a, b):
    """Abbildung der hm08-Strecke a-b auf die des Kaufkoerpers: verschieben, drehen, laengs strecken"""
    ha, hb, ua, ub = J_h[a], J_h[b], J_u[a], J_u[b]
    dh, du = hb - ha, ub - ua
    q = dh.normalized().rotation_difference(du.normalized()).to_matrix()
    f = du.length / max(dh.length, 1e-6)
    e = dh.normalized()
    S = Matrix.Identity(3) + (f - 1) * Matrix([[e.x * e.x, e.x * e.y, e.x * e.z], [e.y * e.x, e.y * e.y, e.y * e.z], [e.z * e.x, e.z * e.y, e.z * e.z]])
    A = q @ S
    return np.array(A), np.array(ua - A @ ha), np.array(ha), np.array(hb)


TS = [strecke_T(a, b) for a, b in STRECKEN]


def abbilden(P):
    D = []
    for A, t, ha, hb in TS:
        e = hb - ha; L2 = max(e @ e, 1e-9)
        u = np.clip(((P - ha) @ e) / L2, 0, 1)
        D.append(np.linalg.norm(P - (ha + u[:, None] * e), axis=1))
    D = np.array(D)                      # Strecken x Ecken
    W = np.exp(-((D - D.min(0)) / 0.025) ** 2)
    W /= W.sum(0)
    out = np.zeros_like(P)
    for k, (A, t, _, _) in enumerate(TS): out += W[k][:, None] * (P @ A.T + t)
    return out


HV1 = abbilden(HV)
# Restunterschied als Feld: naechster Punkt der Kaufhaut (Normale passt), geglaettet ueber das hm08-Netz
nb = [set() for _ in range(len(HV))]
for f in koerper_f:
    for i in range(len(f)):
        nb[f[i]].add(f[i - 1]); nb[f[i]].add(f[(i + 1) % len(f)])
me = bpy.data.meshes.new('hm08'); me.from_pydata([tuple(v) for v in HV1], [], koerper_f); me.update()
HN = np.array([v.normal for v in me.vertices])
D0 = np.zeros_like(HV1); C = np.zeros(len(HV1))
for i in koerper_e:
    co, n, _, _ = bvh.find_nearest(Vector(HV1[i]))
    if co is None: continue
    if n.dot(Vector(HN[i])) > 0.3 and (co - Vector(HV1[i])).length < 0.15:
        D0[i] = np.array(co - Vector(HV1[i])); C[i] = 1.0
D = D0.copy()
ke = np.array(koerper_e)
for _ in range(40):
    M = np.array([D[list(nb[i])].mean(0) if nb[i] else D[i] for i in ke])
    D[ke] = (C[ke, None] * D0[ke] + 2.0 * M) / (C[ke, None] + 2.0)
HV2 = HV1.copy(); HV2[ke] += D[ke]
# Helfer (Rock, Strumpfhose …) mit dem Feld der naechsten Koerperecke
kd = KDTree(len(ke))
for j, i in enumerate(ke): kd.insert(Vector(HV1[i]), j)
kd.balance()
helfer = np.setdiff1d(np.arange(len(HV)), ke)
for i in helfer:
    _, j, _ = kd.find(Vector(HV1[i]))
    HV2[i] = HV1[i] + D[ke[j]]
print('HM08 angepasst', len(ke), 'Koerperecken, Feld mittel %.3f m' % np.linalg.norm(D[ke], axis=1).mean())

# ---------------------------------------------------------------- 3. Stuecke aus der Bindung
teile = []
for p in STUECKE:
    refs, kopf, d = mhclo(p)
    bpy.ops.wm.obj_import(filepath=os.path.join(d, kopf['obj_file']))
    o = bpy.context.selected_objects[0]
    o.matrix_world = Matrix.Identity(4)   # der Import dreht das Objekt (y oben); die Ecken setzen wir selbst in Blender-Lage
    if len(o.data.vertices) != len(refs): sys.exit('ECKEN %s: obj %d, mhclo %d' % (p, len(o.data.vertices), len(refs)))
    sk = {}
    for ax, k in [(0, 'x_scale'), (2, 'y_scale'), (1, 'z_scale')]:   # MakeHuman x, y, z = Blender x, z, -y
        a, b, _ = kopf[k]
        sk[ax] = abs(HV2[a, ax] - HV2[b, ax]) / max(abs(HV[a, ax] - HV[b, ax]), 1e-6)
    P = np.zeros((len(refs), 3))
    for n, (i, w, off) in enumerate(refs):
        P[n] = w[0] * HV2[i[0]] + w[1] * HV2[i[1]] + w[2] * HV2[i[2]] + np.array([off[0] * sk[0], off[1] * sk[1], off[2] * sk[2]])
    o.data.vertices.foreach_set('co', P.ravel()); o.data.update()
    o.name = os.path.basename(p)[:-6]
    # Material aus der .mhmat: nur das Farbbild (diffuseTexture); Normalbild und Glanz nicht (Signatur: kein Glanz an Stoff)
    bild = None
    for l in open(os.path.join(d, kopf['material']), encoding='utf-8', errors='replace'):
        if l.startswith('diffuseTexture'): bild = os.path.join(d, l.split(None, 1)[1].strip())
    mat = bpy.data.materials.get(kopf['material']) or bpy.data.materials.new(kopf['material'])
    if not mat.node_tree or 'Bild' not in mat.node_tree.nodes:
        mat.use_nodes = True
        tx = mat.node_tree.nodes.new('ShaderNodeTexImage'); tx.name = 'Bild'; tx.image = bpy.data.images.load(bild)
        mat.node_tree.links.new(tx.outputs['Color'], mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
    o.data.materials.clear(); o.data.materials.append(mat)
    teile.append((o, kopf))
    print('STUECK', o.name, len(refs), 'Ecken', len(o.data.polygons), 'Flaechen', kopf.get('material'))
# zu einem Netz
bpy.ops.object.select_all(action='DESELECT')
for o, _ in teile: o.select_set(True)
bpy.context.view_layer.objects.active = teile[0][0]
if len(teile) > 1: bpy.ops.object.join()
kl = bpy.context.view_layer.objects.active
kl.name = 'Teil_' + KENNUNG; kl.data.name = 'Teil_' + KENNUNG
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
# doppelte Ecken an Naehten (Kapuze an Robe nicht: getrennte Stuecke) zusammen, damit das Ausduennen nicht aufreisst
bm = bmesh.new(); bm.from_mesh(kl.data)
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0005)
bm.to_mesh(kl.data); bm.free()


# ---------------------------------------------------------------- 4. Durchstich hinaus
def hinaus(o, rand, runden=4, bvh=None):
    bvh = bvh or BVH0
    n_weg = 0
    for r in range(runden):
        V = np.array([v.co for v in o.data.vertices]); K = np.zeros_like(V); hit = np.zeros(len(V), bool)
        for i, v in enumerate(V):
            co, n, fi, _ = bvh.find_nearest(Vector(v))
            if co is None: continue
            t = (Vector(v) - co).dot(n)
            r_ = RAND_KOPF if KOPF_F[fi] else RAND_HAND if HAND_F[fi] else rand
            if t < r_ and (Vector(v) - co).length < 0.25:
                K[i] = np.array(n * (r_ - t)); hit[i] = True
        if r == 0: n_weg = int(hit.sum())
        if not hit.any(): break
        # Verschiebung ueber die Nachbarn verteilen (keine Falten an der Grenze)
        bm = bmesh.new(); bm.from_mesh(o.data); bm.verts.ensure_lookup_table()
        K2 = K.copy()
        for _ in range(2):
            K3 = K2.copy()
            for v in bm.verts:
                ns = [e.other_vert(v).index for e in v.link_edges]
                if ns:
                    m = K2[ns].mean(0)
                    if np.linalg.norm(m) > np.linalg.norm(K3[v.index]): K3[v.index] = 0.5 * (K3[v.index] + m) if not hit[v.index] else K3[v.index]
            K2 = K3
        bm.free()
        o.data.vertices.foreach_set('co', (V + K2).ravel()); o.data.update()
    return n_weg


BVH0 = bvh
print('HINAUS', hinaus(kl, RAND), 'Ecken im Koerper (erste Runde)')

# ---------------------------------------------------------------- 5. Gewichte vom Kaufkoerper
knamen = [b.name for b in arm.data.bones]
KW = np.zeros((len(KV), len(knamen)))
for k, (o, i) in enumerate(KO):
    gi = {g.index: g.name for g in o.vertex_groups}
    for e in o.data.vertices[i].groups:
        n = gi.get(e.group)
        if n in knamen: KW[k, knamen.index(n)] += e.weight
KW /= np.maximum(KW.sum(1, keepdims=True), 1e-9)
V = np.array([v.co for v in kl.data.vertices])
W = np.zeros((len(V), len(knamen)))
for i, v in enumerate(V):
    co, n, fi, _ = bvh.find_nearest(Vector(v))
    t = KT[fi]
    P = KV[t]; dd = np.linalg.norm(P - np.array(co), axis=1); w = 1 / np.maximum(dd, 1e-5); w /= w.sum()
    W[i] = w @ KW[t]
bm = bmesh.new(); bm.from_mesh(kl.data); bm.verts.ensure_lookup_table()
NB = [[e.other_vert(v).index for e in v.link_edges] for v in bm.verts]
bm.free()
# Lagen (zusammenhaengende Stuecke): das groesste (Kutte) nimmt die Gewichte vom Koerper, die anderen (Kapuzenkragen ueber den
# Schultern, Guertel, Strick) dort, wo sie naeher als NAH am Hauptstueck liegen, die des Hauptstuecks darunter: beide Lagen bewegen
# sich gleich und tauschen in Bewegung nicht (Pruefung kutte_haut_2031: Kutte vor dem Kragen an der Schulter, Guertel durch die Kutte)
insel = -np.ones(len(V), int); k = 0
for s0 in range(len(V)):
    if insel[s0] >= 0: continue
    st = [s0]; insel[s0] = k
    while st:
        i = st.pop()
        for j in NB[i]:
            if insel[j] < 0: insel[j] = k; st.append(j)
    k += 1
haupt = np.bincount(insel).argmax()
hk = KDTree(int((insel == haupt).sum()))
hi = np.nonzero(insel == haupt)[0]
for j, i in enumerate(hi): hk.insert(Vector(V[i]), j)
hk.balance()
aussen = 0
for i in np.nonzero(insel != haupt)[0]:
    _, j, d = hk.find(Vector(V[i]))
    if d < NAH: W[i] = W[hi[j]]; aussen += 1
print('LAGEN', k, 'Stuecke, Hauptstueck', len(hi), 'Ecken; aussen am Hauptstueck', aussen)
for _ in range(GLATT):
    W = 0.5 * W + 0.5 * np.array([W[n].mean(0) if n else W[i] for i, n in enumerate(NB)])
W[W < 0.02] = 0
W /= np.maximum(W.sum(1, keepdims=True), 1e-9)

# ---------------------------------------------------------------- 6. zurueck in die Ruhelage
PM = np.array([np.array(AW @ arm.pose.bones[n].matrix @ arm.data.bones[n].matrix_local.inverted() @ AW.inverted()) for n in knamen])
Vh = np.c_[V, np.ones(len(V))]
R = np.zeros_like(V)
for i in range(len(V)):
    M = np.tensordot(W[i], PM, 1)
    R[i] = (np.linalg.inv(M) @ Vh[i])[:3]
kl.data.vertices.foreach_set('co', R.ravel()); kl.data.update()
for pb in arm.pose.bones: pb.matrix_basis = Matrix.Identity(4)
bpy.context.view_layer.update()
for j, n in enumerate(knamen):
    idx = np.nonzero(W[:, j])[0]
    if len(idx) == 0: continue
    vg = kl.vertex_groups.new(name=n)
    for i in idx: vg.add([int(i)], float(W[i, j]), 'REPLACE')

# ---------------------------------------------------------------- 7. ausduennen, Bild
vorher = sum(len(p.vertices) - 2 for p in kl.data.polygons)
# Hauptstueck vor dem Ausduennen: Bezug, auf welcher Seite die anderen Lagen liegen
R0 = np.array([v.co for v in kl.data.vertices])
bvh_h0 = BVHTree.FromPolygons([Vector(v) for v in R0], [list(p.vertices) for p in kl.data.polygons if insel[p.vertices[0]] == haupt])
bpy.ops.object.select_all(action='DESELECT'); kl.select_set(True); bpy.context.view_layer.objects.active = kl
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT'); bpy.ops.mesh.quads_convert_to_tris(); bpy.ops.object.mode_set(mode='OBJECT')
dec = kl.modifiers.new('aus', 'DECIMATE'); dec.ratio = min(1.0, ZIEL_DREIECKE / max(vorher, 1)); dec.use_collapse_triangulate = True
bpy.ops.object.modifier_apply(modifier=dec.name)

# 7b. Lagen nach dem Ausduennen wieder auseinander (Pruefung kutte_haut_2031: Guertel und Strick lagen nach dem Ausduennen in der Kutte):
# jede Ecke der anderen Stuecke bleibt auf ihrer Seite des Hauptstuecks (Seite gegen das Hauptstueck vor dem Ausduennen) und mindestens LAGE davon
bm = bmesh.new(); bm.from_mesh(kl.data); bm.verts.ensure_lookup_table()
NB2 = [[e.other_vert(v).index for e in v.link_edges] for v in bm.verts]
bm.free()
V2 = np.array([v.co for v in kl.data.vertices])
ins2 = -np.ones(len(V2), int); k = 0
for s0 in range(len(V2)):
    if ins2[s0] >= 0: continue
    st = [s0]; ins2[s0] = k
    while st:
        i = st.pop()
        for j in NB2[i]:
            if ins2[j] < 0: ins2[j] = k; st.append(j)
    k += 1
h2 = np.bincount(ins2).argmax()
bvh_h = BVHTree.FromPolygons([Vector(v) for v in V2], [list(p.vertices) for p in kl.data.polygons if ins2[p.vertices[0]] == h2])
geschoben = 0
for i in np.nonzero(ins2 != h2)[0]:
    v = Vector(V2[i])
    co0, n0, _, _ = bvh_h0.find_nearest(v)
    co, n, _, _ = bvh_h.find_nearest(v)
    if co is None or co0 is None or (v - co).length > NAH: continue
    s_ = 1.0 if (v - co0).dot(n0) >= 0 else -1.0
    t = (v - co).dot(n) * s_
    if t < LAGE:
        V2[i] = np.array(v + n * s_ * (LAGE - t)); geschoben += 1
kl.data.vertices.foreach_set('co', V2.ravel()); kl.data.update()
print('LAGEN NACH AUSDUENNEN', k, 'Stuecke,', geschoben, 'Ecken auf Abstand', LAGE)
# nach dem Ausduennen noch einmal hinaus, gegen den Kaufkoerper in der Ruhelage (Flaechen sind gleich, KOPF_F/HAND_F gelten)
KR = []
for o in koerper:
    V_, _ = netz_welt(o); KR += list(V_)
print('HINAUS RUHELAGE', hinaus(kl, RAND, 3, BVHTree.FromPolygons([Vector(v) for v in KR], KT)), 'Ecken')
# Kapuze weiter um die Kopfmitte, nach dem Kopfgewicht (glatt, ohne Falten): Spitzohren der Elfen, Ork- und Zwergenkopf sind
# groesser als der Kaufkopf des Menschen, an dem die Kapuze sitzt (kutte_haut_2031: je 1 Ecke durch die Kapuze)
KAPUZE_WEIT = float(os.environ.get('KAPUZE_WEIT', '1.18'))
vg = kl.vertex_groups.get('Head'); vn = kl.vertex_groups.get('neck_01')   # Hals mit: Kinn von Zwerg, Halbling, Ork am Kragen
if vg:
    c = AW @ arm.data.bones['Head'].head_local + Vector((0, 0, 0.06))
    V3 = np.array([v.co for v in kl.data.vertices])
    for v in kl.data.vertices:
        w_ = min(1.0, sum(g.weight for g in v.groups if g.group in (vg.index, vn.index if vn else -1)))
        if w_ > 0: V3[v.index] = np.array(c + (v.co - c) * (1 + (KAPUZE_WEIT - 1) * w_))
    kl.data.vertices.foreach_set('co', V3.ravel()); kl.data.update()
nachher = len(kl.data.polygons)
kl.data.shade_smooth()   # Bild am Rechner: flach schattierte Dreiecke gaben dunkle Rauten im Rock (obj ohne Glaettung)
for mat in kl.data.materials:
    if not mat or not mat.use_nodes: continue
    for nd in mat.node_tree.nodes:
        if nd.type == 'TEX_IMAGE' and nd.image:
            im = nd.image
            if max(im.size) > BILD: im.scale(BILD, BILD * im.size[1] // im.size[0])
            im.filepath_raw = os.path.join(ZIEL, '%s_%s.png' % (DATEI, G)); im.file_format = 'PNG'; im.save()
        if nd.type == 'BSDF_PRINCIPLED':
            nd.inputs['Roughness'].default_value = 1.0
            for k in ('Specular IOR Level', 'Specular'):
                if k in nd.inputs: nd.inputs[k].default_value = 0.0
            nd.inputs['Metallic'].default_value = 0.0
            for l in list(mat.node_tree.links):   # Normalbild weg (kein Glanz, Tusche aus dem Shader)
                if l.to_socket == nd.inputs.get('Normal'): mat.node_tree.links.remove(l)
mod = kl.modifiers.new('Armature', 'ARMATURE'); mod.object = arm
kl.parent = arm; kl.matrix_parent_inverse = arm.matrix_world.inverted()
for o in koerper: bpy.data.objects.remove(o)
bpy.ops.object.select_all(action='DESELECT'); kl.select_set(True); arm.select_set(True)
p = os.path.join(ZIEL, '%s_%s.glb' % (DATEI, G))
bpy.ops.export_scene.gltf(filepath=p, export_format='GLB', use_selection=True, export_animations=False, export_apply=False, export_skins=True)
print('KLEID_MH OK', KENNUNG, G, 'Dreiecke vorher', vorher, 'nachher', nachher, 'Datei', p, os.path.getsize(p))
