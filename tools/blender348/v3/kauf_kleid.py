# 376.1 (Chef 27.10., 15:23): eine Kauffigur in unserer Kleidung. Koerper, Kopf, Haende und Geruest aus Quaternius' Universal Base
# Characters (gekauft, bornim-kaufmodelle; frei Superhero_Male_FullBody als Ersatz), Kleidung aus unserem Helden (held3-rig.blend nach
# rig.py/geruest.py: ein Netz, Kennung 'teil', Gewichte schon auf den UAL-Knochen). Ausgabe in der Ruhelage der Kauffigur (T-Pose),
# damit figurenprobe.gd die UAL-Bewegungen wie bei den anderen q_*-Figuren abspielt.
# Ablauf: (1) Kauffigur in unsere Ruhehaltung drehen (Arme haengend); (2) Kleidung je Knochen auf deren Laengen und Lagen; (3) Rest-
# unterschied der Koerper als Verschiebungsfeld von unserem Koerper auf die Kleidung (Lagen bleiben uebereinander); (4) wo der fremde
# Koerper noch durchsticht, Kleidung hinaus; (5) Koerperflaechen unter der Kleidung weg (sticht in Bewegung nicht durch); (6) Kleidung
# mit der Haltung aus (1) zurueck in deren Ruhelage (umgekehrte Hautbindung).
# Aufruf: OUT=<ordner mit held3-rig.blend> Q=<cc0> [KAUF=<ordner>] [KOPF=Regular_Male_OnlyHead] [HAAR=..] [BART=..] [FORM=rund] [HAUT=mittel] [STOPPELN=1]
#         [KENNUNG=q_tracht] [ZIEL=<ordner>] bl/bin/python -I kauf_kleid.py   -> <ZIEL>/<KENNUNG>.glb, <KENNUNG>.json
import bpy, bmesh, os, json, sys
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from mathutils.kdtree import KDTree

OUT = os.environ.get('OUT', '/home/user/q376/out')
ZIEL = os.environ.get('ZIEL', OUT)
KENNUNG = os.environ.get('KENNUNG', 'q_tracht')
Q = os.environ.get('Q', os.path.expanduser('~/cc0'))
KOERPER = os.environ.get('KOERPER', 'Superhero_Male_FullBody')
KOPF = os.environ.get('KOPF', '')            # leer: Kopf des Koerpers
HAAR = os.environ.get('HAAR', 'Hair_SimpleParted')
BART = os.environ.get('BART', '')
FARBE = os.environ.get('FARBE', 'braun')
FORM = os.environ.get('FORM', '')            # Kopfform (Chef 14:44, 19:40): Vorlage aus kopf.FORMEN und/oder Regler, „rund,nase=0.2“
HAUT = os.environ.get('HAUT', 'mittel')      # kopf.HAUT
STOPPELN = float(os.environ.get('STOPPELN', '1.0'))   # 0: glatt rasiert (Helfer 16:48: „ohne Bart“ mit Stoppeln)
os.makedirs(ZIEL, exist_ok=True)

# Teile unseres Helden, die Kleidung sind (Helm, Schild, Schwert, Scheide nicht: Kleidung, kein Geraet)
KLEID = {'belt', 'buckle', 'boots', 'chain', 'cuff', 'clasp', 'cloak', 'pants', 'sleeves', 'tabard', 'robe'}   # robe: Magier (trachten.json)
# eng anliegend: Gewichte vom fremden Koerper darunter (bewegt sich wie er; mit unseren Gewichten stach er in jeder Haltung ausser
# der Probe durch, pruef_tracht.py); Wappenrock und Umhang behalten unsere (folgen den Oberschenkeln nur zum Teil)
ENG = {'belt', 'buckle', 'boots', 'chain', 'cuff', 'clasp', 'pants', 'sleeves'}
KOERPERTEILE = {'body', 'wristL', 'wristR', 'handL', 'handR'}
RAND = 0.004          # Kleidung mindestens so weit ueber dem fremden Koerper (m)
VERDECKT = float(os.environ.get('VERDECKT', '0.06'))   # Koerperecke, ueber der in dieser Entfernung Kleidung liegt, gilt als verdeckt (m)
WEG_AB = int(os.environ.get('WEG_AB', '1'))             # Flaeche weg ab so vielen verdeckten Ecken (0: alle; 1: Durchstechen halbiert, Tom 15:48)

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
QQ = {}
for wurzel in (Q, os.environ.get('KAUF', '')):
    if not wurzel: continue
    for wo, _, fs in sorted(os.walk(wurzel)):
        for f in sorted(fs):
            # Haare: „Rigged to Head Bone“ (Godot), wie quaternius.py
            if f.endswith('.gltf') and (f[:-5] not in QQ or 'Rigged' in wo and 'Godot' in wo): QQ[f[:-5]] = os.path.join(wo, f)


def np_welt(o):
    me = o.data
    co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co)
    co = co.reshape(-1, 3)
    M = np.array(o.matrix_world)
    return co @ M[:3, :3].T + M[:3, 3]


def gewichte(o, namen):
    # dichte Gewichtsmatrix (Ecken x Knochen) ueber die Knochennamen; Gruppen ausser den Knochen fallen weg
    W = np.zeros((len(o.data.vertices), len(namen)))
    gi = {g.index: namen.index(g.name) for g in o.vertex_groups if g.name in namen}
    for v in o.data.vertices:
        for e in v.groups:
            j = gi.get(e.group)
            if j is not None: W[v.index, j] += e.weight
    s = W.sum(1, keepdims=True)
    return W / np.where(s > 0, s, 1)


# ---------------------------------------------------------------- 1. unser Held
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
TEILNAMEN = json.load(open(OUT + '/teile.json'))
held = next(o for o in bpy.data.objects if o.type == 'MESH' and 'teil' in o.data.attributes)
rig = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for a in [o for o in bpy.data.objects if o.type == 'ARMATURE']:
    a.data.pose_position = 'REST'
tl = np.zeros(len(held.data.vertices), dtype=int); held.data.attributes['teil'].data.foreach_get('value', tl)
tname = np.array([TEILNAMEN[i] for i in tl])
ist_kleid = np.isin(tname, list(KLEID)); ist_koerper = np.isin(tname, list(KOERPERTEILE))
print('HELD', held.name, len(tl), 'Ecken; Kleidung', int(ist_kleid.sum()), 'Koerper', int(ist_koerper.sum()))
# nur Kleidung behalten (Koerper fuer das Feld als Punkte mitnehmen)
VH = np.array([held.matrix_world @ v.co for v in held.data.vertices])
R_KN = [b.name for b in rig.data.bones]
WH = gewichte(held, R_KN)
R_MAT = {b.name: rig.matrix_world @ b.matrix_local for b in rig.data.bones}
R_LEN = {b.name: b.length * rig.matrix_world.to_scale()[1] for b in rig.data.bones}
hoehe_h = VH[:, 2].max() - VH[:, 2].min()
# Kleidung als eigenes Objekt: Kopie, Rest weg
bpy.ops.object.select_all(action='DESELECT')
kleid = held.copy(); kleid.data = held.data.copy(); bpy.context.scene.collection.objects.link(kleid); kleid.name = 'Kleid'
bm = bmesh.new(); bm.from_mesh(kleid.data); bm.verts.ensure_lookup_table()
bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.where(~ist_kleid)[0]], context='VERTS')
bm.to_mesh(kleid.data); bm.free()
VK0 = VH[ist_kleid]; WK = WH[ist_kleid]; ENG_K = np.isin(tname[ist_kleid], list(ENG))
VB0 = VH[ist_koerper]; WB = WH[ist_koerper]
for o in [o for o in bpy.data.objects if o not in (kleid,)]: bpy.data.objects.remove(o)

# ---------------------------------------------------------------- 2. Kauffigur
def importiere(p):
    vorher = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=p)
    neu = [o for o in bpy.data.objects if o not in vorher]
    for o in [o for o in neu if o.type == 'MESH' and o.name.startswith('Icosphere')]:
        neu.remove(o); bpy.data.objects.remove(o)
    return neu

kq = importiere(QQ[KOERPER])
qa = next(o for o in kq if o.type == 'ARMATURE'); qa.name = 'Armature'
qnetze = [o for o in kq if o.type == 'MESH']
qkoerper = max(qnetze, key=lambda o: len(o.data.vertices))
import quaternius as QT_   # nur Hilfen (an_geruest, nur_kopf, toene, kopf_pos); baut beim Import nichts, wenn FIGUREN=keine
for teil, name in [('kopf', KOPF), ('haar', HAAR)] + [('bart', b) for b in BART.split(',')]:   # BART: mehrere mit Komma
    if not name or name not in QQ: continue
    objs = importiere(QQ[name])
    a2 = next((o for o in objs if o.type == 'ARMATURE'), None)
    vs = (QT_.kopf_pos(qa) - QT_.kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
    if teil == 'kopf':   # Kopf tauschen: Kopf und Hals des Koerpers weg
        weg_o = [o for o in qnetze if o.name.startswith(('Eyes', 'Eyebrows'))]   # erst merken: entfernte Objekte sind nicht mehr lesbar
        qnetze = [o for o in qnetze if o not in weg_o]
        for o in weg_o: bpy.data.objects.remove(o)
        g = {vg.index: vg.name for vg in qkoerper.vertex_groups}
        bm = bmesh.new(); bm.from_mesh(qkoerper.data); bm.verts.ensure_lookup_table()
        weg = [bm.verts[v.index] for v in qkoerper.data.vertices if v.groups and g.get(max(v.groups, key=lambda x: x.weight).group) in ('Head',)]
        bmesh.ops.delete(bm, geom=weg, context='VERTS'); bm.to_mesh(qkoerper.data); bm.free()
    neu = [o for o in objs if o.type == 'MESH']
    QT_.an_geruest(objs, qa, vs)
    qnetze += neu
QT_.KOPIEN.clear()
for o in qnetze:
    if o.name.startswith(('Hair_', 'Eyebrows')) and FARBE in QT_.HAAR: QT_.toene(o, lambda n: True, QT_.HAAR[FARBE])   # FARBE=keine: Godot toent (held_klassen.py)
# gekauften Kopf formen (Ruhelage, vor dem Anpassen der Kleidung: der Kragen sitzt am geformten Hals), Haut toenen
import kopf as KO
MERK = KO.forme(qnetze, KO.form_aus(FORM), qkoerper)
KO.toene_haut(qkoerper, MERK, KO.HAUT[HAUT], STOPPELN, mat=lambda n: 'Regular' in n or 'Superhero' in n)
Q_KN = [b.name for b in qa.data.bones]

# ---------------------------------------------------------------- 3. Kauffigur in unsere Ruhehaltung
def kinder_zuerst(arm):
    aus = []
    def geh(b):
        aus.append(b.name)
        for c in b.children: geh(c)
    for b in arm.data.bones:
        if b.parent is None: geh(b)
    return aus

bpy.context.view_layer.objects.active = qa
bpy.ops.object.mode_set(mode='POSE')
for n in kinder_zuerst(qa):
    if n not in R_MAT or n == 'root': continue
    pb = qa.pose.bones[n]
    bpy.context.view_layer.update()
    cur = qa.matrix_world @ pb.matrix
    d_ist = (cur.to_3x3() @ Vector((0, 1, 0))).normalized()
    d_soll = (R_MAT[n].to_3x3() @ Vector((0, 1, 0))).normalized()
    dreh = d_ist.rotation_difference(d_soll).to_matrix().to_4x4()
    neu = Matrix.Translation(cur.translation) @ dreh @ Matrix.Translation(-cur.translation) @ cur
    pb.matrix = qa.matrix_world.inverted() @ neu
bpy.context.view_layer.update()
bpy.ops.object.mode_set(mode='OBJECT')
QP_MAT = {pb.name: qa.matrix_world @ pb.matrix for pb in qa.pose.bones}
QR_MAT = {b.name: qa.matrix_world @ b.matrix_local for b in qa.data.bones}
Q_LEN = {b.name: b.length for b in qa.data.bones}

dg = bpy.context.evaluated_depsgraph_get()
def welt_eval(o):
    oe = o.evaluated_get(dg); me = oe.to_mesh()
    V = np.array([o.matrix_world @ v.co for v in me.vertices]); F = [tuple(p.vertices) for p in me.polygons]
    oe.to_mesh_clear(); return V, F
QV, QF = welt_eval(qkoerper)
WQ = gewichte(qkoerper, Q_KN)   # vor dem Loeschen verdeckter Flaechen (gleiche Ecken wie QV)
qbvh = BVHTree.FromPolygons([Vector(v) for v in QV], QF)
hoehe_q = max(welt_eval(o)[0][:, 2].max() for o in qnetze) - QV[:, 2].min()
k_ganz = hoehe_q / hoehe_h
print('HOEHE held %.3f kauf %.3f -> %.3f' % (hoehe_h, hoehe_q, k_ganz))

# ---------------------------------------------------------------- 4. Kleidung je Knochen auf die Kauffigur (in deren Haltung)
def je_knochen(V, W):
    out = np.zeros_like(V)
    Vh = np.c_[V, np.ones(len(V))]
    for j, n in enumerate(R_KN):
        w = W[:, j]
        if not w.any(): continue
        if n in QP_MAT:
            s = Q_LEN[n] / max(R_LEN[n], 1e-6) if n != 'root' else k_ganz
            s = float(np.clip(s, 0.6 * k_ganz, 1.6 * k_ganz))
            T = QP_MAT[n] @ Matrix.Diagonal((k_ganz, s, k_ganz, 1.0)) @ R_MAT[n].inverted()
        else:   # Knochen nur bei uns (Schild, Scheide): mit dem Elternknochen
            p = rig_eltern.get(n)
            T = QP_MAT[p] @ Matrix.Scale(k_ganz, 4) @ R_MAT[p].inverted() if p in QP_MAT else Matrix.Scale(k_ganz, 4)
        out += w[:, None] * (Vh @ np.array(T).T)[:, :3]
    los = W.sum(1) == 0
    out[los] = V[los] * k_ganz
    return out
rig_eltern = {}
VK1 = je_knochen(VK0, WK); VB1 = je_knochen(VB0, WB)

# ---------------------------------------------------------------- 5. Restunterschied der Koerper als Feld
D = np.zeros_like(VB1)
for i, v in enumerate(VB1):
    c, nrm, _, _ = qbvh.find_nearest(Vector(v))
    if c is not None: D[i] = np.array(c) - v
# glaetten ueber die Nachbarn im Raum (die Koerperteile sind getrennte Netze)
kdb = KDTree(len(VB1))
for i, v in enumerate(VB1): kdb.insert(Vector(v), i)
kdb.balance()
for _ in range(3):
    D2 = D.copy()
    for i, v in enumerate(VB1):
        nb = [j for _, j, _ in kdb.find_n(Vector(v), 12)]
        D2[i] = D[nb].mean(0)
    D = D2
VK2 = np.empty_like(VK1)
for i, v in enumerate(VK1):
    nb = kdb.find_n(Vector(v), 8)
    w = np.array([1.0 / max(d, 0.005) ** 2 for _, _, d in nb]); j = [j for _, j, _ in nb]
    VK2[i] = v + (w[:, None] * D[j]).sum(0) / w.sum()

# Helfer 20:2x (Kragen verdeckt Kinn und Mund, Kinn sticht durch): unser Kettenkragen reicht am Kaufkopf 2-3 cm ueber das Kinn,
# Schritt 7 drueckte dann das Kinn hinter den Kragen. Vorn (zum Kinn hin) weich unter die Kinnunterkante, hinten bleibt er hoch
iH = Q_KN.index('Head'); iN = Q_KN.index('neck_01') if 'neck_01' in Q_KN else iH
hals_y = float(QV[WQ[:, iN] > 0.5][:, 1].mean()) if (WQ[:, iN] > 0.5).any() else 0.0
vk = (WQ[:, iH] > 0.5) & (QV[:, 1] < hals_y - 0.04)
KINN_Z = float(QV[vk][:, 2].min()) if vk.any() else 1e9
# Prueferin 2 (20:33): weiches Abschneiden bei c riss den Kragen (Zacken, Haut durch): statt dessen der ganze Kragen ueber dem
# Halsansatz gleichmaessig gestaucht (Faktor je Ecke nach vorn/hinten), oben vorn KRAGEN_FREI unter dem Kinn. Pruefer 20:49 (Splitter
# auf Kinn und Hals): vor Schritt 6, damit was danach im Hals liegt, hinausgeschoben wird (nicht der Koerper zurueck)
c = KINN_Z - float(os.environ.get('KRAGEN_FREI', '0.015'))
vorn = np.clip((hals_y + 0.01 - VK2[:, 1]) / 0.08, 0, 1); vorn = vorn * vorn * (3 - 2 * vorn)
nahe = np.linalg.norm(VK2[:, :2] - np.array([0.0, hals_y]), axis=1) < 0.13
z = VK2[:, 2]
basis = float(QV[WQ[:, iN] > 0.3][:, 2].min()) if (WQ[:, iN] > 0.3).any() else c - 0.08   # Halsansatz
oben = float(z[nahe & (VK2[:, 1] < hals_y)].max()) if (nahe & (VK2[:, 1] < hals_y)).any() else c
f = 1.0 if oben <= c or os.environ.get('KRAGEN') == '0' else float(np.clip((c - basis) / max(oben - basis, 1e-3), 0.1, 1.0))   # KRAGEN=0: aus
rr = np.clip((np.linalg.norm(VK2[:, :2] - np.array([0.0, hals_y]), axis=1) - 0.09) / 0.06, 0, 1); rr = 1 - rr * rr * (3 - 2 * rr)
fz = 1.0 + vorn * rr * (f - 1.0)
neu_z = np.where(z > basis, basis + (z - basis) * fz, z)
print('KRAGEN gestaucht', int((np.abs(neu_z - z) > 0.002).sum()), 'Ecken, Kinn %.3f, Halsansatz %.3f, oben %.3f, Faktor vorn %.2f' % (KINN_Z, basis, oben, f))
VK2_VOR = VK2.copy()   # 376.1 Halszacken: Lage vor Stauchen und Hinausschieben, zum Messen gekippter Flaechen (unten)
if os.environ.get('KANTE_DBG'):   # 376.1 Halszacken: Stauchen an der Oberkante je Winkel (Stufe bei +-50 Grad, kante.py)
    _w = np.degrees(np.arctan2(VK2[:, 0], -(VK2[:, 1] - hals_y)))
    for a0 in range(-70, 71, 5):
        q = nahe & (np.abs(_w - a0) < 2.5) & (z > basis)
        if q.any():
            i = np.where(q)[0][np.argmax(z[q])]
            print('KANTE_DBG %+d z %.0f -> %.0f mm, vorn %.2f rr %.2f fz %.2f, Abstand %.0f mm' % (a0, (z[i] - basis) * 1000, (neu_z[i] - basis) * 1000, vorn[i], rr[i], fz[i], np.linalg.norm(VK2[i, :2] - np.array([0.0, hals_y])) * 1000))
VK2[:, 2] = neu_z
# ---------------------------------------------------------------- 6. was noch im fremden Koerper liegt, hinaus
raus = 0
for i, v in enumerate(VK2):
    c, nrm, _, _ = qbvh.find_nearest(Vector(v))
    if c is None: continue
    a = (Vector(v) - c).dot(nrm)
    if a < RAND:
        VK2[i] = np.array(c + nrm * RAND); raus += 1
print('KLEIDUNG HINAUS', raus, 'von', len(VK2))


# ---------------------------------------------------------------- 7. Koerper unter der Kleidung weg
kme = kleid.data
KF = [tuple(p.vertices) for p in kme.polygons]
kbvh = BVHTree.FromPolygons([Vector(v) for v in VK2], KF)
# 376.1 Halszacken (Helfer: graue Zacken vorn am Hals, Vorderseiten): Flaechen am Hals, die Stauchen (5) und Hinausschieben (6)
# umgedreht haben (Normale gegen vorher < 0), und solche, deren Ecken mehr als 1 cm auseinander geschoben wurden
def _nrm(P, f): return np.cross(P[f[1]] - P[f[0]], P[f[2]] - P[f[0]])
_hals = [f_ for f_ in KF if len(f_) >= 3 and all(np.linalg.norm(VK2_VOR[j, :2] - np.array([0.0, hals_y])) < 0.13 and VK2_VOR[j, 2] > basis for j in f_)]
_kipp = sum(1 for f_ in _hals if np.dot(_nrm(VK2_VOR, f_), _nrm(VK2, f_)) < 0)
_weit = sum(1 for f_ in _hals if max(np.linalg.norm(VK2[j] - VK2_VOR[j]) for j in f_) - min(np.linalg.norm(VK2[j] - VK2_VOR[j]) for j in f_) > 0.01)
print('KRAGEN GEKIPPT %d von %d Flaechen am Hals, verzogen %d' % (_kipp, len(_hals), _weit))
qn = np.array([v.normal for v in qkoerper.evaluated_get(dg).to_mesh().vertices]); qkoerper.evaluated_get(dg).to_mesh_clear()
# Normalen in Weltlage (Armature-Modifikator dreht sie mit; to_mesh liefert sie schon verformt)
verdeckt = np.zeros(len(QV), dtype=bool)
# sticht eine Ecke schon in dieser Haltung durch (Zehen durch die Stiefelspitze, Brust durch das Kettenhemd; pruef_tracht.py Ruhe):
# verdeckt, und sie geht hinter die Kleidung zurueck (umgerechnet in die Ruhelage mit den Gewichten des Koerpers)
S = {pb.name: np.array((qa.matrix_world @ pb.matrix) @ (qa.matrix_world @ pb.bone.matrix_local).inverted()) for pb in qa.pose.bones}
SA = np.stack([S[n] for n in Q_KN])                    # Knochen x 4 x 4
qmi = np.array(qkoerper.matrix_world.inverted().to_3x3())
rein = 0
for i, v in enumerate(QV):
    n = Vector(qn[i]).normalized()
    hit = kbvh.ray_cast(Vector(v) + n * 0.001, n, VERDECKT)
    if hit[0] is not None: verdeckt[i] = True
    h2 = kbvh.ray_cast(Vector(v) - n * 0.001, -n, 0.04)
    if h2[0] is not None and h2[1].dot(n) > 0:
        verdeckt[i] = True
        d = np.array(h2[0] - n * RAND) - v
        A = np.tensordot(WQ[i], SA, axes=1)[:3, :3]
        qkoerper.data.vertices[i].co += Vector(qmi @ (np.linalg.inv(A) @ d)); rein += 1
print('KOERPER ZURUECK', rein)
# Pruefer 21:17 (Hautsplitter am Oberarm in der Spielansicht), pruef_haut.py: am Oberarm liegt die Haut 0-7 mm auf oder vor Kettenhemd
# und Umhang; kein Strahl trifft, sie blieb und stach in der Bewegung durch. Unter der Kleidung (Rumpf, Oberarm, Oberschenkel) gilt auch
# als verdeckt, was naeher als VERDECKT_NAH an der Kleidung liegt; Kopf, Hals, Haende, Unterarme, Fuesse nicht (Raender von Kragen, Aermel, Stiefel)
NAH = float(os.environ.get('VERDECKT_NAH', '0.012'))
RUMPF = ('upperarm', 'clavicle', 'spine', 'pelvis', 'thigh')
nah = 0
for i, v in enumerate(QV):
    if verdeckt[i] or not any(Q_KN[int(WQ[i].argmax())].lower().startswith(r) for r in RUMPF): continue
    if kbvh.find_nearest(Vector(v), NAH)[0] is not None: verdeckt[i] = True; nah += 1
print('KOERPER NAH VERDECKT', nah)
bm = bmesh.new(); bm.from_mesh(qkoerper.data); bm.faces.ensure_lookup_table()
# Pruefer 21:0x (Vergleich k01-k04): am gestauchten Kragen liegen Halshaut und Kette gleich tief, Flaechen ab einer verdeckten Ecke
# weg gab Zinnen; am Hals (Kopf- und Halsgewicht) darum nur ganz verdeckte Flaechen weg, sonst WEG_AB
am_hals = (WQ[:, iH] + WQ[:, iN] + (WQ[:, Q_KN.index('neck_02')] if 'neck_02' in Q_KN else 0)) > 0.3 if f < 1.0 else np.zeros(len(QV), dtype=bool)
weg = [f_ for f_ in bm.faces if sum(verdeckt[v.index] for v in f_.verts) >= (len(f_.verts) if any(am_hals[v.index] for v in f_.verts) else (WEG_AB or len(f_.verts)))]
bmesh.ops.delete(bm, geom=weg, context='FACES')
bm.to_mesh(qkoerper.data); bm.free()
print('KOERPER VERDECKT', int(verdeckt.sum()), 'von', len(QV), 'Ecken;', len(weg), 'Flaechen weg')
# 376.1 Halszacken: Halshaut, die nach dem Abbau bleibt und naeher als 1/2/4 mm an der Kette liegt (gleich tief: Flackern im Spiel)
_hh = [i for i in range(len(QV)) if am_hals[i] or (WQ[i, iN] > 0.3)]
_d = []
for i in _hh:
    h_ = kbvh.find_nearest(Vector(QV[i]), 0.01)
    if h_[0] is not None: _d.append(h_[3])
_d = np.array(_d) if _d else np.zeros(0)
print('HALS AN KETTE <1mm %d <2mm %d <4mm %d von %d Ecken' % ((_d < 0.001).sum(), (_d < 0.002).sum(), (_d < 0.004).sum(), len(_hh)))

# ---------------------------------------------------------------- 8. Kleidung zurueck in die Ruhelage der Kauffigur
WKq = np.zeros((len(VK2), len(Q_KN)))
for j, n in enumerate(R_KN):
    m = n if n in S else rig_eltern.get(n)
    if m in S: WKq[:, Q_KN.index(m)] += WK[:, j]
for i in np.where(ENG_K)[0]:
    c, _, fi, _ = qbvh.find_nearest(Vector(VK2[i]))
    if fi is None: continue
    ecken = list(QF[fi]); d = np.linalg.norm(QV[ecken] - np.array(c), axis=1)
    w = 1.0 / np.maximum(d, 1e-4); WKq[i] = (w[:, None] * WQ[ecken]).sum(0) / w.sum()
leer = WKq.sum(1) == 0
WKq[leer, Q_KN.index('pelvis')] = 1.0
WKq /= WKq.sum(1, keepdims=True)
# Pruefer 20:49 (Kettensplitter auf Kinn und Hals): die Kragenecken erbten am Kinn Gewichte des Kopfs, drehten mit ihm (UAL, Kopf
# heben in figurenprobe.gd) und stachen ins Gesicht; Kleidung haengt hoechstens am Hals
iKopf = Q_KN.index('Head'); iHals = Q_KN.index('neck_02') if 'neck_02' in Q_KN else Q_KN.index('neck_01')
print('KLEIDUNG AM KOPF', int((WKq[:, iKopf] > 1e-3).sum()), 'Ecken, an den Hals')
WKq[:, iHals] += WKq[:, iKopf]; WKq[:, iKopf] = 0.0
# Helfer 16:48 (hinten Kettenhemd und Rock durch den Mantel; pruef_tracht.py: in jeder Bewegung 17-46 Ecken je Bild): Wappenrock
# und Umhang haben unsere Gewichte, das Kettenhemd die des Koerpers, in Bewegung laufen sie auseinander. Ueber der Huefte folgen sie
# darum der Lage darunter (deren Gewichte an der Stelle, die der Strahl nach innen trifft), darunter gleitend die eigenen (Saum frei)
FOLGT_AB = float(os.environ.get('FOLGT_AB', '0.05')); FOLGT_BREIT = float(os.environ.get('FOLGT_BREIT', '0.17'))
FOLGT = [('tabard', ('chain', 'sleeves')), ('robe', ('chain', 'sleeves')), ('cloak', ('tabard', 'robe', 'chain', 'belt', 'buckle', 'sleeves', 'clasp'))]
LTk = tl[ist_kleid]; TID = {n: i for i, n in enumerate(TEILNAMEN)}
kme.vertices.foreach_set('co', VK2.ravel()); kme.update()
NK2 = np.empty(len(VK2) * 3); kme.vertices.foreach_get('normal', NK2); NK2 = NK2.reshape(-1, 3)
hz = QP_MAT['pelvis'].translation.z
gefolgt = {}
for a_teil, unter in FOLGT:
    ids = [TID[u] for u in unter if u in TID]
    fl = [j for j, f in enumerate(KF) if LTk[f[0]] in ids]
    if a_teil not in TID or not fl: continue
    bv = BVHTree.FromPolygons([Vector(v) for v in VK2], [KF[j] for j in fl])
    n_ok = 0
    for i in np.where(LTk == TID[a_teil])[0]:
        a = float(np.clip((VK2[i, 2] - (hz - FOLGT_AB)) / FOLGT_BREIT, 0, 1)); a = a * a * (3 - 2 * a)
        if a <= 0: continue
        n = Vector(NK2[i])
        h = bv.ray_cast(Vector(VK2[i]) - n * 0.001, -n, 0.06)
        if h[0] is None:
            h = bv.find_nearest(Vector(VK2[i]), 0.04)
            if h[0] is None: continue
        ecken = list(KF[fl[h[2]]]); d = np.linalg.norm(VK2[ecken] - np.array(h[0]), axis=1)
        w = 1.0 / np.maximum(d, 1e-4); neu = (w[:, None] * WKq[ecken]).sum(0) / w.sum()
        WKq[i] = (1 - a) * WKq[i] + a * neu; n_ok += 1
    gefolgt[a_teil] = n_ok
WKq /= WKq.sum(1, keepdims=True)
print('LAGEN FOLGEN', gefolgt)
VK3 = np.empty_like(VK2)
for i, v in enumerate(VK2):
    A = np.tensordot(WKq[i], SA, axes=1)
    VK3[i] = (np.linalg.inv(A) @ np.r_[v, 1.0])[:3]
for pb in qa.pose.bones:
    pb.matrix_basis = Matrix()
bpy.context.view_layer.update()

# Kleidung: Lage, Gruppen auf die Knochen der Kauffigur
kleid.parent = None; kleid.matrix_world = Matrix()
# Lagen in der Ruhelage: wer in der Probehaltung unter einer anderen Lage lag (Strahl entlang der Normale trifft sie binnen 8 cm)
# und in Ruhe vor ihr liegt (Wappenrock unsere Gewichte, Kettenhemd die des Koerpers), geht wieder hinter sie
LT = tl[ist_kleid]
def normalen(V):
    kme.vertices.foreach_set('co', V.ravel()); kme.update()
    n = np.empty(len(V) * 3); kme.vertices.foreach_get('normal', n); return n.reshape(-1, 3)
def je_teil(V):
    return {t: BVHTree.FromPolygons([Vector(v) for v in V], [f for f in KF if LT[f[0]] == t]) for t in set(LT.tolist())}
NP = normalen(VK2); BP = je_teil(VK2)
UNTER = {}
for i in range(len(VK2)):
    best = None
    for t, bv in BP.items():
        if t == LT[i]: continue
        h = bv.ray_cast(Vector(VK2[i] + NP[i] * 0.001), Vector(NP[i]), 0.08)
        if h[0] is not None and (best is None or h[3] < best[1]): best = (t, h[3])
    if best: UNTER[i] = best[0]
zurueck = 0
for _ in range(2):
    NR = normalen(VK3); BR = je_teil(VK3)
    for i, t in UNTER.items():
        n = Vector(NR[i])
        h = BR[t].ray_cast(Vector(VK3[i]) - n * 0.001, -n, 0.03)
        if h[0] is not None and h[1].dot(n) > 0:
            VK3[i] = np.array(h[0] - n * RAND); zurueck += 1
print('LAGEN ZURUECK', zurueck, 'von', len(UNTER), 'bedeckten Ecken')
# Pruefer 21:12 (Vergleich mit/ohne Umhang, ohne Kettenhemd): die Schulterspitzen des Kettenhemds stachen durch den Umhang; Umhang und
# Spangen ueber der Brust UMHANG_AUF m nach aussen (8 mm: weg). OHNE_TEIL=<teil> laesst einen Teil weg (nur zur Ursachensuche)
UA = float(os.environ.get('UMHANG_AUF', '0.008'))
if UA > 0 and 'cloak' in TEILNAMEN:
    NR = normalen(VK3); cz = QR_MAT['spine_03'].translation.z if 'spine_03' in QR_MAT else 1.3
    m = np.isin(LT, [TEILNAMEN.index(t) for t in ('cloak', 'clasp') if t in TEILNAMEN]) & (VK3[:, 2] > cz - 0.05)
    VK3[m] += NR[m] * UA * np.clip((VK3[m, 2:3] - (cz - 0.05)) / 0.1, 0, 1)
    print('UMHANG AUF', int(m.sum()), 'Ecken')
kme.vertices.foreach_set('co', VK3.ravel())
for g in list(kleid.vertex_groups): kleid.vertex_groups.remove(g)
for j, n in enumerate(Q_KN):
    idx = np.where(WKq[:, j] > 1e-3)[0]
    if not len(idx): continue
    g = kleid.vertex_groups.new(name=n)
    for i in idx: g.add([int(i)], float(WKq[i, j]), 'REPLACE')
for m in list(kleid.modifiers): kleid.modifiers.remove(m)
kleid.parent = qa
md = kleid.modifiers.new('Armature', 'ARMATURE'); md.object = qa
# 376.1 Magier: OHNE_TEIL=pants (Liste mit Komma; trachten.json „ohne“): unter der Robe stach die Hose im Lauf durch (pruef_tracht.py Jog 36)
ohne = [t for t in os.environ.get('OHNE_TEIL', '').split(',') if t in TEILNAMEN]
if ohne:
    bm = bmesh.new(); bm.from_mesh(kme); bm.verts.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.where(np.isin(LT, [TEILNAMEN.index(t) for t in ohne]))[0]], context='VERTS')
    bm.to_mesh(kme); bm.free(); print('OHNE', ohne)

dr = sum(len(o.data.polygons) for o in qnetze + [kleid])
info = {'kennung': KENNUNG, 'koerper': KOERPER, 'kopf': KOPF or KOERPER, 'haar': HAAR, 'bart': BART, 'form': KO.form_aus(FORM), 'haut': HAUT, 'stoppeln': STOPPELN, 'farbe': FARBE,
        'hoehe_m': round(float(hoehe_q), 3), 'kleidung_hinaus': raus, 'koerper_verdeckt': int(verdeckt.sum()), 'flaechen': dr}
json.dump(info, open(os.path.join(ZIEL, KENNUNG + '.json'), 'w'), indent=1, ensure_ascii=False)
bpy.ops.object.select_all(action='DESELECT')
for o in [qa, kleid] + qnetze: o.select_set(True)
bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, KENNUNG + '.glb'), export_format='GLB', use_selection=True,
                          export_animations=False, export_apply=False, export_skins=True, export_vertex_color='ACTIVE')   # 376.1: Kettenmarke (alpha) in COLOR_0 wie rig.py; sonst zweite Schicht, Godot liest COLOR nur aus der ersten
print('KAUFKLEID OK', KENNUNG, info)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ZIEL, KENNUNG + '.blend'))   # fuer pruef_tracht.py (Kennung 'teil')
