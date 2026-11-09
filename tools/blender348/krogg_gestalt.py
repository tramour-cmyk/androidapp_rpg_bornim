# 494 Krogg-Figur (Übergabe Jerry 03.11., 16:2x: „Krogg-Figur nach LISTE-FIGUREN“; bis dahin Platzhalterkörper): Krogg der Grobian
# nach LISTE-FIGUREN „Krogg“ (Liste 348.11 b, gebilligt Chef 25.10., 23:33) und Tabelle „Einmalige Monster“. Grundkörper nach 431
# (Chef 01.11., 11:42: „Ork auf Superheld (auch für Grak, Krogg …)“), gebaut wie grak_gestalt.py (348.12).
# Bestand geprüft (LISTE-BESTAND): Quaternius Universal Base Characters [Standard] Superhero_Male_FullBody (CC0 1.0; Körper,
# Hände, Gerüst 65 Knochen), Universal Animation Library [Standard] (CC0; Bewegungen), mit UAL=<Pro> die gekaufte Pro (Rennen,
# Ausweichen, Tod Death02); Janpec Animal Pack Deluxe (gekauft, privat) Braunbär `Bear_Rig.fbx`: nur der Kopf mit Ohren und Kiefer,
# Farbbild `brown_bear_col4_unity.tga`; Anker „Low Poly Medieval Weapons“ (CC0, privat) `Spiked Mace.fbx` als Morgenstern.
# Eigen: Kopf geformt (kurze schwere Schnauze, breite Nase, Ohren hoch), Hauer, Bart, Mähne bis auf die Schultern, Fellbüschel
# (zottig), lange Arme, große Hände, Fellumhang, Lendenschurz, Gürtel mit Schlüssel (neu), Krallennarben, Augen gedämpft rot,
# Morgenstern schwarz von altem Blut (neu), Haltung (Schultern hoch, leicht geduckt). Einmalig: eine Form (DESIGN-STIL „Ausnahme
# einmalige Monster“).
# Aufruf: OUT=<ordner> CC0=<cc0-ordner> KAUF=<ordner mit Kaufpaketen> [UAL=<UAL1.glb der Pro>] python -I krogg_gestalt.py
#         -> <OUT>/krogg-gestalt.glb, krogg-gestalt-info.json (Maße, Quellen, Wurzelweg, Hieb)
import bpy, bmesh, os, sys, json, math, random
import numpy as np
from mathutils import Vector, Matrix, Quaternion
from mathutils.bvhtree import BVHTree
from mathutils.kdtree import KDTree
from PIL import Image, ImageFilter

OUT = os.environ.get('OUT', os.path.expanduser('~/krogg'))
CC0 = os.environ.get('CC0', os.path.expanduser('~/cc0'))
KAUF = os.environ.get('KAUF', os.path.expanduser('~/kauf'))
TEX = int(os.environ.get('TEX', '2048'))
os.makedirs(os.path.join(OUT, 'tex'), exist_ok=True)
random.seed(494)
RNG = np.random.default_rng(494)

HOEHE = 2.12                       # Liste „Krogg“ 1: 212 cm, gut einen Kopf größer als der Held (175); Scheitel ohne Ohren
FELL = 0x8A5530                    # Liste 4 / Tabelle: Fell lohfarben bis rostbraun (einmalig: eine Farbe)
MAEHNE = 0x2A1D15                  # dunkle Mähne, Bart
UMHANG_FELL = 0x4A3424             # Fellumhang dunkler als Kroggs Fell
LEDER = 0x3A271A                   # Lendenschurz, Gürtel
EISEN = 0x7A7268                   # Schlüssel, Gürtelschnalle
ZAHN = 0xCFC2A0                    # Hauer
AUGE = (0.36, 0.08, 0.05)          # Liste 3: kleine Augen, gedämpft rot, nicht grell
KOPF_S = 0.60                      # Bärenkopf auf dem Superheld (Kopfbreite 0,24 m vor dem Skalieren, Mensch 0,16)
SCHNAUZE = 0.72                    # Liste 3: kurze schwere Schnauze (vor den Augen so viel kürzer als beim Bären)
ARM_OBEN, ARM_UNTEN, HAND = 1.10, 1.14, 1.50     # Liste 2: lange Arme, große Hände
QUELLEN = []


def lin(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return np.array([x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c])


def srgb(h):
    return np.array([((h >> s) & 255) / 255.0 for s in (16, 8, 0)])


def finde(name, wo=None):
    for d, _, fs in sorted(os.walk(wo or CC0)):
        if name in fs: return os.path.join(d, name)
    raise SystemExit('fehlt: %s in %s' % (name, wo or CC0))


def importiere(pfad):
    vorher = set(bpy.data.objects)
    if pfad.lower().endswith('.fbx'):
        bpy.ops.import_scene.fbx(filepath=pfad)
    else:
        bpy.ops.import_scene.gltf(filepath=pfad)
    neu = [o for o in bpy.data.objects if o not in vorher]
    for o in list(neu):
        if o.type == 'MESH' and o.name.startswith('Icosphere'):
            neu.remove(o); bpy.data.objects.remove(o)
    QUELLEN.append(os.path.basename(pfad))
    return neu


def welt(o):
    co = np.empty(len(o.data.vertices) * 3); o.data.vertices.foreach_get('co', co)
    M = np.array(o.matrix_world)
    return co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]


def setze(o, W):
    Mi = np.array(o.matrix_world.inverted())
    o.data.vertices.foreach_set('co', (W @ Mi[:3, :3].T + Mi[:3, 3]).ravel()); o.data.update()


def glatt(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def gruppe(o, name):
    return o.vertex_groups.get(name) or o.vertex_groups.new(name=name)


def gewicht_feld(o, namen):
    idx = {o.vertex_groups[n].index for n in namen if n in o.vertex_groups}
    w = np.zeros(len(o.data.vertices))
    for v in o.data.vertices:
        for g in v.groups:
            if g.group in idx: w[v.index] += g.weight
    return w


def an_ruestung(o, arm):
    o.parent = arm
    o.matrix_parent_inverse = arm.matrix_world.inverted()
    mod = next((m for m in o.modifiers if m.type == 'ARMATURE'), None) or o.modifiers.new('Armature', 'ARMATURE')
    mod.object = arm


# ---------------------------------------------------------------- (1) Körper und Gerüst: Superheld (431)
bpy.ops.wm.read_factory_settings(use_empty=True)
teile = importiere(finde('Superhero_Male_FullBody.gltf'))
ARM = next(o for o in teile if o.type == 'ARMATURE'); ARM.name = 'Krogg'
LEIB = next(o for o in teile if o.type == 'MESH' and o.name.startswith('SuperHero'))
for o in teile:
    if o.type == 'MESH' and o is not LEIB: bpy.data.objects.remove(o)
LEIB.name = 'Krogg_Leib'
bpy.context.view_layer.update()
KN0 = {b.name: (ARM.matrix_world @ b.head_local).copy() for b in ARM.data.bones}

# Menschenkopf weg (der Bärenkopf sitzt darauf); Hals bleibt, Mähne und Bart decken den Ansatz
w_kopf = gewicht_feld(LEIB, ('Head',))
V = welt(LEIB)
weg = (w_kopf >= 0.5) & (V[:, 2] > KN0['neck_01'].z + 0.03)
bm = bmesh.new(); bm.from_mesh(LEIB.data); bm.verts.ensure_lookup_table()
bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.nonzero(weg)[0]], context='VERTS')
bm.to_mesh(LEIB.data); bm.free()

# ---------------------------------------------------------------- (2) lange Arme, große Hände (Liste 2), Gerüst mit
# T-Pose: Arme längs ±X. Je Knochen eine feste Abbildung (Oberarm gestreckt, Unterarm verschoben und gestreckt, Hand und Finger
# verschoben und vergrößert), Ecken nach ihren Gewichten gemischt, Knochen gleich
FINGERN = ('thumb', 'index', 'middle', 'ring', 'pinky')


RUMPF_X, RUMPF_Y, GLIED = 1.26, 1.16, 1.15     # Liste 2: massig, breite Schultern (Prüfer r1: „Torso, Beine schlank“)


def rumpf(p):     # Rumpf, Hals, Schlüsselbeine breiter und tiefer (um die Achse x = 0, y = Rückgrat)
    return Vector((p.x * RUMPF_X, KN0['spine_02'].y + (p.y - KN0['spine_02'].y) * RUMPF_Y, p.z))


def dicker(a_, b_, k):     # um die Achse eines Glieds (a_ -> b_) dicker
    ax = (b_ - a_).normalized()

    def f(p):
        q = a_ + ax * (p - a_).dot(ax)
        return q + (p - q) * k
    return f


def arm_abb(s_):
    S = KN0['upperarm_' + s_]; E = KN0['lowerarm_' + s_]; Hd = KN0['hand_' + s_]
    sch = rumpf(S) - S                 # die Schulter rückt mit dem breiteren Rumpf nach außen
    a1 = (E - S).normalized(); a2 = (Hd - E).normalized()
    E2 = S + sch + (E - S) * ARM_OBEN
    H2 = E2 + (Hd - E) * ARM_UNTEN
    d_o, d_u = dicker(S, E, GLIED), dicker(E, Hd, GLIED)

    def streck(p, o_, a, f):     # entlang a ab o_ um f strecken
        d = p - o_; l = d.dot(a)
        return o_ + d + a * l * (f - 1)

    abb = {'upperarm_' + s_: lambda p: streck(d_o(p) + sch, S + sch, a1, ARM_OBEN),
           'lowerarm_' + s_: lambda p: streck(d_u(p) + (E2 - E), E2, a2, ARM_UNTEN),
           'hand_' + s_: lambda p: H2 + (p - Hd) * HAND}
    return abb


ABB = {b: rumpf for b in ('pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01', 'clavicle_l', 'clavicle_r')}
for s_ in 'lr':
    ABB.update(arm_abb(s_))
    hand = ABB['hand_' + s_]
    for b in ARM.data.bones:
        if b.name.endswith('_' + s_) and b.name.split('_')[0] in FINGERN:
            ABB[b.name] = hand
    ABB['thigh_' + s_] = dicker(KN0['thigh_' + s_], KN0['calf_' + s_], GLIED)
    ABB['calf_' + s_] = dicker(KN0['calf_' + s_], KN0['foot_' + s_], GLIED)
gn = {g.index: g.name for g in LEIB.vertex_groups}
V = welt(LEIB)
for v in LEIB.data.vertices:
    p = Vector(V[v.index]); neu = Vector(); sw = 0.0
    for g in v.groups:
        f = ABB.get(gn[g.group])
        neu += (f(p) if f else p) * g.weight; sw += g.weight
    if sw > 0: V[v.index] = np.array(neu / sw)
setze(LEIB, V)
bpy.context.view_layer.objects.active = ARM
bpy.ops.object.mode_set(mode='EDIT')
Mi = ARM.matrix_world.inverted()
for eb in ARM.data.edit_bones:
    f = ABB.get(eb.name)
    if f:
        h = ARM.matrix_world @ eb.head; t = ARM.matrix_world @ eb.tail
        eb.head = Mi @ f(h); eb.tail = Mi @ f(t)
bpy.ops.object.mode_set(mode='OBJECT')
bpy.context.view_layer.update()
KN = {b.name: (ARM.matrix_world @ b.head_local).copy() for b in ARM.data.bones}

# ---------------------------------------------------------------- (3) Bärenkopf (Janpec Braunbär, gekauft): Kopf, Ohren, Kiefer
bteile = importiere(finde('Bear_Rig.fbx', KAUF))
BAER = next(o for o in bteile if o.type == 'MESH')
B_ARM = next(o for o in bteile if o.type == 'ARMATURE')
bpy.context.view_layer.update()
BK = {b.name: (B_ARM.matrix_world @ b.head_local).copy() for b in B_ARM.data.bones}
KOPFKN = ('Bear_Neck_TopSHJnt', 'Bear_Head_JawSHJnt', 'Bear_Head_JawEndSHJnt', 'Bear_Head_TopSHJnt',
          'Bear_l_Ear_01_01SHJnt', 'Bear_l_Ear_01_02SHJnt', 'Bear_r_Ear_01_01SHJnt', 'Bear_r_Ear_01_02SHJnt')
OHRKN = KOPFKN[4:]
Vb = welt(BAER)
w_bk = gewicht_feld(BAER, KOPFKN); w_ohr = gewicht_feld(BAER, OHRKN)
HINTEN_B = -0.90                   # hinter den Ohren (−0,97 bis −1,06) der Hals des Bären: weg
behalt = (w_bk >= 0.5) & (Vb[:, 1] < HINTEN_B)
OHR_B = w_ohr >= 0.5
# Merkpunkte im Bären (am Netz gemessen, erkunde 16:30): Augen ±0,08 / −1,278 / 1,218 (Ring dunkler Ecken), Nasenspitze 0 / −1,49 / 1,05
AUGE_B = Vector((0.080, -1.278, 1.218))
NASE_B = Vector((0.0, -1.490, 1.050))
KIPP = math.radians(-12)           # Schnauze etwas heben: der Bär trägt den Kopf gesenkt, Krogg aufrecht


def baer_zu_krogg(p):
    # Bärenraum -> Kroggs Raum (Superheld, vor dem Skalieren): Schnauze kürzen, kippen, verkleinern, Augen an ihren Ort
    q = Vector(p) - AUGE_B * Vector((0, 1, 1))
    if q.y < 0: q.y *= SCHNAUZE
    q = Matrix.Rotation(KIPP, 3, 'X') @ q
    return Vector((q.x, q.y, q.z)) * KOPF_S + AUGE_K


# Augen Kroggs: etwas vor den Augen des Menschen (Kopf vorgeschoben, geduckt), auf ihrer Höhe
AUGE_K = Vector((0.0, -0.105, 1.700))
bm = bmesh.new(); bm.from_mesh(BAER.data); bm.verts.ensure_lookup_table()
uvl = bm.loops.layers.uv.active
weg_b = [bm.verts[i] for i in np.nonzero(~behalt)[0]]
bmesh.ops.delete(bm, geom=weg_b, context='VERTS')
me = bpy.data.meshes.new('Krogg_Kopf'); bm.to_mesh(me); bm.free()
KOPF = bpy.data.objects.new('Krogg_Kopf', me); bpy.context.scene.collection.objects.link(KOPF)
KOPF.matrix_world = BAER.matrix_world.copy()
OHR_IDX = np.nonzero(OHR_B[behalt])[0]
Vk_b = welt(KOPF)                  # noch Bärenraum
Vk = np.array([baer_zu_krogg(Vector(p)) for p in Vk_b])
# breite schwarze Nase (Liste 3): die Nasenkuppe 30 % breiter; Ohren hoch und rund: 3 cm (Bärenmaß) höher, 15 % größer
nase = np.exp(-(((Vk_b[:, 1] - NASE_B.y) / 0.06) ** 2 + ((Vk_b[:, 2] - NASE_B.z) / 0.07) ** 2))
Vk[:, 0] *= 1 + 0.30 * nase
for i in OHR_IDX:
    Vk[i] = np.array(baer_zu_krogg(Vector(Vk_b[i]) + Vector((0, 0, 0.03)))) * 1.0
oz = Vk[OHR_IDX]
if len(oz):
    for sgn in (-1, 1):
        sel = OHR_IDX[np.sign(Vk[OHR_IDX, 0]) == sgn]
        if len(sel):
            c = Vk[sel].mean(0); Vk[sel] = c + (Vk[sel] - c) * 1.15
KOPF.matrix_world = Matrix.Identity(4)
setze(KOPF, Vk)
KOPF.vertex_groups.clear()
gruppe(KOPF, 'Head').add(range(len(me.vertices)), 1.0, 'REPLACE')
an_ruestung(KOPF, ARM)
for p_ in me.polygons: p_.use_smooth = True
BAER_BILD = finde('brown_bear_col4_unity.tga', KAUF)
for o in bteile: bpy.data.objects.remove(o)
VK = welt(KOPF)
KOPF_UNTEN = float(VK[:, 2].min())
print('KOPF Bär %d Ecken, Breite %.3f m, Länge %.3f m, Kinn %.3f m, Scheitel %.3f m (ohne Ohren %.3f)' % (
    len(VK), np.ptp(VK[:, 0]), np.ptp(VK[:, 1]), KOPF_UNTEN, VK[:, 2].max(),
    np.delete(VK, OHR_IDX, 0)[:, 2].max()))


# ---------------------------------------------------------------- (4) eigene Teile: Hauer, Bart, Mähne, Büschel, Umhang, Schurz
def netz(name, verts, faces, farbe, knochen=None, gewichte=None, eckfarben=None):
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in verts], [], faces); me.update()
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    o['farbe'] = farbe
    if eckfarben is not None: o['eckfarben'] = 1; o.data['eck'] = list(np.asarray(eckfarben).ravel())
    if knochen:
        for kn in set(knochen if isinstance(knochen, (list, tuple)) else [knochen]):
            gruppe(o, kn)
        if gewichte is None:
            gruppe(o, knochen).add(range(len(verts)), 1.0, 'REPLACE')
        else:
            for i, ws in enumerate(gewichte):
                for kn, wt in ws.items():
                    if wt > 0: gruppe(o, kn).add([i], wt, 'REPLACE')
    an_ruestung(o, ARM)
    for p in me.polygons: p.use_smooth = True
    return o


def rohr(punkte, radien, n=8):
    verts, faces = [], []
    for i, (p, r) in enumerate(zip(punkte, radien)):
        d = (punkte[min(i + 1, len(punkte) - 1)] - punkte[max(i - 1, 0)]).normalized()
        a = d.orthogonal().normalized(); b = d.cross(a).normalized()
        for k in range(n):
            ang = 2 * math.pi * k / n
            verts.append(p + (a * math.cos(ang) + b * math.sin(ang)) * r)
    for i in range(len(punkte) - 1):
        for k in range(n):
            faces.append((i * n + k, i * n + (k + 1) % n, (i + 1) * n + (k + 1) % n, (i + 1) * n + k))
    verts.append(punkte[0] - (punkte[1] - punkte[0]).normalized() * radien[0] * 0.3)
    faces += [(len(verts) - 1, (k + 1) % n, k) for k in range(n)]
    if radien[-1] > 0:
        verts.append(punkte[-1]); m = len(punkte) - 1
        faces += [(len(verts) - 1, m * n + k, m * n + (k + 1) % n) for k in range(n)]
    return verts, faces


# Hauer (Liste 3: große Hauer): aus dem Unterkiefer vorn neben der Nase vor der Oberlippe nach oben, leicht nach außen und vorn
for s in (-1, 1):
    b = baer_zu_krogg(Vector((s * 0.050, -1.420, 0.985)))
    pts = [b + Vector((s * 0.012 * t_ ** 1.5, -0.016 * math.sin(t_ * math.pi / 2), 0.085 * t_)) for t_ in np.linspace(0, 1, 7)]
    vs, fs = rohr(pts, [0.0115, 0.011, 0.0098, 0.0082, 0.006, 0.0034, 0.0], n=8)
    netz('Krogg_Hauer_%s' % ('l' if s > 0 else 'r'), vs, fs, ZAHN, 'Head')


def bueschel(wurzeln, richtungen, laengen, dicken, farbe, gewichte, name, streu=0.25, n=4, normalen=None, haengen=0.35):
    # je Wurzel ein spitzes, gebogenes Haarbüschel (drei Ringe, Spitze); Farbe je Büschel etwas verschieden. normalen: Richtung
    # mindestens zur Hälfte aus der Haut (Prüfer r2: flach liegende Büschel zeigten ihre Grundfläche als Sechseckplättchen)
    verts, faces, gew, eck = [], [], [], []
    for k_, (w_, d_, l_, r_, g_) in enumerate(zip(wurzeln, richtungen, laengen, dicken, gewichte)):
        d_ = Vector(d_).normalized()
        if normalen is not None:
            nn = Vector(normalen[k_]).normalized()
            if d_.dot(nn) < 0.5:
                t_ = (d_ - nn * d_.dot(nn)); t_ = t_.normalized() if t_.length > 1e-4 else nn.orthogonal().normalized()
                d_ = (nn * 0.5 + t_ * 0.866).normalized()
        knick = (d_ + Vector((random.uniform(-streu, streu), random.uniform(-streu, streu), -haengen))).normalized()
        pts = [Vector(w_) - d_ * r_ * 1.6, Vector(w_) + d_ * l_ * 0.45, Vector(w_) + (d_ * 0.55 + knick * 0.45).normalized() * l_ * 0.8,
               Vector(w_) + (d_ * 0.4 + knick * 0.6).normalized() * l_]
        vs, fs = rohr(pts, [r_, r_ * 0.75, r_ * 0.4, 0.0], n=n)
        o0 = len(verts); verts += vs; faces += [tuple(o0 + i for i in f) for f in fs]
        gew += [g_] * len(vs)
        t = random.uniform(0.75, 1.15); eck += [t] * len(vs)
    return netz(name, verts, faces, farbe, sorted({k for g in gewichte for k in g}), gew, eckfarben=eck)


def gewichte_bei(o, punkte):
    # Gewichte der nächsten Ecke von o (Welt) je Punkt
    Vo = welt(o); kd = KDTree(len(Vo))
    for i, v in enumerate(Vo): kd.insert(v, i)
    kd.balance()
    gno = {g.index: g.name for g in o.vertex_groups}
    aus = []
    for p in punkte:
        _, j, _ = kd.find(Vector(p))
        ws = {gno[g.group]: g.weight for g in o.data.vertices[j].groups if g.weight > 0.02}
        sw = sum(ws.values()) or 1.0
        aus.append({k: w / sw for k, w in ws.items()} or {'spine_03': 1.0})
    return aus


def flaechenpunkte(o, maske, anzahl, abstand):
    # gleichmäßig verteilte Punkte auf den Flächen von o, wo maske(Mitte, Normale) gilt; (Punkt, Normale)
    Vo = welt(o); me = o.data; me.calc_loop_triangles()
    kand = []
    for tri in me.loop_triangles:
        P = Vo[list(tri.vertices)]
        c = P.mean(0); nrm = np.cross(P[1] - P[0], P[2] - P[0]); fl = np.linalg.norm(nrm) / 2
        if fl < 1e-9: continue
        nrm = nrm / (2 * fl)
        if maske(c, nrm): kand.append((c, nrm, fl))
    if not kand: return []
    fl = np.array([k[2] for k in kand]); p = fl / fl.sum()
    aus = []
    for i in RNG.choice(len(kand), size=anzahl * 4, p=p):
        c, nrm, _ = kand[i]
        if all(np.linalg.norm(c - q) > abstand for q, _ in aus):
            aus.append((c, nrm))
        if len(aus) >= anzahl: break
    return aus


# Mähne (Liste 3: Mähne bis zu den Schultern; Tabelle: dunkle Mähne): Büschel auf Hinterkopf, Seiten hinter den Augen, Nacken,
# Schultern und oberem Rücken, nach hinten unten; deckt den Schnitt zwischen Bärenkopf und Hals
aug_y = AUGE_K.y
mk = flaechenpunkte(KOPF, lambda c, n: (c[1] > aug_y + 0.20 or c[2] < AUGE_K.z + 0.02) and c[1] > aug_y + 0.07 and c[2] > KOPF_UNTEN + 0.02 and n[2] > -0.6, 90, 0.018)
ml = flaechenpunkte(LEIB, lambda c, n: (c[2] > KN['spine_03'].z + 0.06 and abs(c[0]) < 0.24 + 0.4 * max(0.0, c[2] - 1.42) and
                                         (c[1] > -0.02 or c[2] > KOPF_UNTEN - 0.04)) and c[2] < 1.70, 150, 0.022)
pkt = [p for p, _ in mk] + [p for p, _ in ml]
ri = [Vector(n) * 0.75 + Vector((0, 0.45, -0.45)) for _, n in mk] + [Vector(n) * 0.5 + Vector((0, 0.15, -0.85)) for _, n in ml]
gw = [{'Head': 1.0}] * len(mk) + gewichte_bei(LEIB, [p for p, _ in ml])
bueschel(pkt, ri, [random.uniform(0.09, 0.15) for _ in pkt], [random.uniform(0.018, 0.026) for _ in pkt], MAEHNE, gw, 'Krogg_Maehne', n=5,
         normalen=[n for _, n in mk] + [n for _, n in ml], haengen=0.8)
# Bart (Liste 3): unter Kinn und Kiefer nach unten
bk = flaechenpunkte(KOPF, lambda c, n: n[2] < -0.25 and aug_y - 0.02 < c[1] < aug_y + 0.09 and c[2] < AUGE_K.z - 0.07, 40, 0.016)
bueschel([p for p, _ in bk], [Vector(n) * 0.3 + Vector((0, 0.1, -1.0)) for _, n in bk], [random.uniform(0.06, 0.11) for _ in bk],
         [random.uniform(0.013, 0.018) for _ in bk], MAEHNE, [{'Head': 1.0}] * len(bk), 'Krogg_Bart', n=5, normalen=[n for _, n in bk], haengen=0.8)
# Fell zottig (Tabelle: zottig): Büschel an Unterarmen, Oberarmen außen, Waden, Oberschenkeln außen, Brust; distal und nach unten
w_ua = gewicht_feld(LEIB, ('lowerarm_l', 'lowerarm_r'))
w_oa = gewicht_feld(LEIB, ('upperarm_l', 'upperarm_r'))
w_wa = gewicht_feld(LEIB, ('calf_l', 'calf_r'))
w_os = gewicht_feld(LEIB, ('thigh_l', 'thigh_r'))
VL = welt(LEIB)
kdL = KDTree(len(VL))
for i, v in enumerate(VL): kdL.insert(v, i)
kdL.balance()


def region(w, minw=0.6):
    def m(c, n):
        _, j, _ = kdL.find(Vector(c)); return w[j] >= minw
    return m


zott = []
for w, anz, dist, rich in ((w_ua, 60, 0.03, 'arm'), (w_oa, 30, 0.035, 'arm'), (w_wa, 40, 0.035, 'unten'), (w_os, 24, 0.045, 'unten')):
    for p, n in flaechenpunkte(LEIB, region(w), anz, dist):
        n = Vector(n)
        if rich == 'arm':     # T-Pose: zur Hand hin (außen) und etwas nach unten
            d = n * 0.55 + Vector((math.copysign(0.75, p[0]), 0, -0.25))
        else:
            if n.y < -0.5 and rich == 'unten' and w is w_os: continue     # vorn auf den Oberschenkeln liegt der Schurz
            d = n * 0.55 + Vector((0, 0, -0.85))
        zott.append((p, d))
bueschel([p for p, _ in zott], [d for _, d in zott], [random.uniform(0.04, 0.075) for _ in zott],
         [random.uniform(0.008, 0.012) for _ in zott], FELL, gewichte_bei(LEIB, [p for p, _ in zott]), 'Krogg_Zotteln', streu=0.3)


def huelle(z):
    # Querschnitt des Leibs in Höhe z: (Mitte x, Mitte y, Halbachse x, Halbachse y) aus den Ecken des Rumpfs
    s = (np.abs(VL[:, 2] - z) < 0.015) & (np.abs(VL[:, 0]) < 0.30)
    P = VL[s]
    return P[:, 0].mean(), (P[:, 1].min() + P[:, 1].max()) / 2, np.abs(P[:, 0]).max(), (P[:, 1].max() - P[:, 1].min()) / 2


# Gürtel (Hüfte) mit Schlüssel (Liste 3: Schlüssel am Gürtel, neu)
ZG = KN['pelvis'].z + 0.02
cx, cy, ax, ay = huelle(ZG)
nu = 28; verts = []; faces = []
for j, dz in enumerate((-0.035, 0.035)):
    for i in range(nu):
        a = 2 * math.pi * i / nu
        verts.append(Vector((cx + (ax + 0.014) * math.cos(a), cy + (ay + 0.014) * math.sin(a), ZG + dz)))
for i in range(nu):
    faces.append((i, (i + 1) % nu, nu + (i + 1) % nu, nu + i))
g = netz('Krogg_Guertel', verts, faces, LEDER, 'pelvis')
mo = g.modifiers.new('dicke', 'SOLIDIFY'); mo.thickness = 0.008; g.modifiers.move(len(g.modifiers) - 1, 0)
# Schlüssel links an der Hüfte: Ring am Gürtel, Schaft nach unten, Bart
a = math.radians(-20)              # links seitlich (x > 0), etwas vorn
pk = Vector((cx + (ax + 0.02) * math.cos(a), cy + (ay + 0.02) * math.sin(a), ZG - 0.03))
verts, faces = [], []
ring = 0.032
for i in range(10):
    t = 2 * math.pi * i / 10
    q = pk + Vector((0, ring * math.cos(t), -ring * math.sin(t)))
    verts.append(q)
schl_v, schl_f = [], []
for i in range(10):
    vs, fs = rohr([verts[i], verts[(i + 1) % 10]], [0.0045, 0.0045], n=5)
    o0 = len(schl_v); schl_v += vs; schl_f += [tuple(o0 + k for k in f) for f in fs]
s0 = pk + Vector((0, 0, -ring))
vs, fs = rohr([s0, s0 + Vector((0, 0, -0.11)), s0 + Vector((0, 0, -0.15))], [0.0075, 0.0075, 0.0075], n=6)
o0 = len(schl_v); schl_v += vs; schl_f += [tuple(o0 + k for k in f) for f in fs]
for dz, l in ((-0.125, 0.032), (-0.145, 0.024)):
    b0 = s0 + Vector((0, 0, dz))
    vs, fs = rohr([b0, b0 + Vector((0, -l, 0))], [0.007, 0.007], n=5)
    o0 = len(schl_v); schl_v += vs; schl_f += [tuple(o0 + k for k in f) for f in fs]
netz('Krogg_Schluessel', schl_v, schl_f, EISEN, 'pelvis')

# Lendenschurz (Liste 4): vorn und hinten ein Lappen vom Gürtel bis über die Knie, unten ausgefranst
for seite in (-1, 1):              # -1 vorn (−Y), +1 hinten
    nu, nv = 9, 8; verts, faces, gew = [], [], []
    for j in range(nv):
        tv = j / (nv - 1)
        z = ZG - 0.02 - tv * 0.40
        breit = 0.10 - 0.035 * tv
        for i in range(nu):
            tu = i / (nu - 1) * 2 - 1
            x = cx + tu * breit
            if j == nv - 1: z += (0.035 if i % 2 else -0.01)     # ausgefranst
            cxz, cyz, axz, ayz = huelle(min(max(z, KN['thigh_l'].z - 0.35), ZG))
            y = cyz + seite * (ayz + 0.018 + 0.05 * tv) * (1 - 0.25 * tu * tu)
            verts.append(Vector((x, y, z)))
            wo = glatt(0.15, 0.8, tv)
            gew.append({'pelvis': 1 - wo * 0.6, ('thigh_l' if x > 0 else 'thigh_r'): wo * 0.6})
    for j in range(nv - 1):
        for i in range(nu - 1):
            faces.append((j * nu + i, j * nu + i + 1, (j + 1) * nu + i + 1, (j + 1) * nu + i))
    sch = netz('Krogg_Schurz_%s' % ('vorn' if seite < 0 else 'hinten'), verts, faces, LEDER, ['pelvis', 'thigh_l', 'thigh_r'], gew)
    mo = sch.modifiers.new('dicke', 'SOLIDIFY'); mo.thickness = 0.006; sch.modifiers.move(len(sch.modifiers) - 1, 0)

# Fellumhang (Liste 4): über den Schultern, den Rücken hinab bis zur Mitte der Oberschenkel, Saum zottig
nu, nv = 18, 13
verts, faces, gew = [], [], []
z_oben = KN['spine_03'].z + 0.17
for j in range(nv):
    tv = j / (nv - 1)
    zz = z_oben - tv * (z_oben - (KN['thigh_l'].z - 0.22))
    breit = 0.25 + 0.12 * tv
    for i in range(nu):
        tu = i / (nu - 1) * 2 - 1
        cxz, cyz, axz, ayz = huelle(max(min(zz, KN['spine_03'].z + 0.12), KN['thigh_l'].z - 0.2))
        xx = tu * breit
        yy = cyz + ayz + 0.03 + 0.10 * tv - 0.06 * (tu ** 2) * (1 - tv) + 0.01 * math.cos(tu * math.pi * 3)
        zr = zz
        if j == nv - 1: zr += random.uniform(-0.04, 0.03)
        verts.append(Vector((xx, yy, zr)))
        wo = 1 - glatt(KN['spine_01'].z, KN['spine_03'].z + 0.05, zr)
        gew.append({'spine_03': 1 - wo, 'spine_01': wo * 0.6, 'pelvis': wo * 0.4})
for j in range(nv - 1):
    for i in range(nu - 1):
        faces.append((j * nu + i, j * nu + i + 1, (j + 1) * nu + i + 1, (j + 1) * nu + i))
um = netz('Krogg_Umhang', verts, faces, UMHANG_FELL, ['spine_03', 'spine_01', 'pelvis'], gew)
mo = um.modifiers.new('dicke', 'SOLIDIFY'); mo.thickness = 0.012; um.modifiers.move(len(um.modifiers) - 1, 0)
# Saum und Kragen des Umhangs zottig
Vu = welt(um)
saum = [(Vector(Vu[(nv - 1) * nu + i]), Vector((0, 0.2, -1))) for i in range(nu)]
saum += [(Vector(Vu[(nv - 2) * nu + i]) + Vector((0, 0.012, 0)), Vector((0, 0.5, -0.8))) for i in range(0, nu, 2)]
bueschel([p for p, _ in saum], [d for _, d in saum], [random.uniform(0.05, 0.09) for _ in saum], [0.013] * len(saum),
         UMHANG_FELL, [gew[(nv - 1) * nu]] * len(saum), 'Krogg_Umhangsaum')
# Prüfer r2: der Umhang las sich wie Stoff oder Leder; Fellbüschel auf der ganzen Außenseite, versetzt
fl = [((nv - 1 - j) * nu + i) for j in range(1, nv - 1) for i in range(j % 2, nu, 2)]
bueschel([Vector(Vu[k]) + Vector((0, 0.010, 0)) for k in fl], [Vector((random.uniform(-0.2, 0.2), 0.5, -0.85)) for _ in fl],
         [random.uniform(0.05, 0.08) for _ in fl], [random.uniform(0.012, 0.016) for _ in fl], UMHANG_FELL, [gew[k] for k in fl],
         'Krogg_Umhangfell', n=4, haengen=0.6)

# drei Krallennarben quer über den Schnauzenrücken (Liste 3): schmale helle Bänder 1,5 mm über der Haut, von rechts oben nach links
# unten; als Netz, weil das Farbbild des Bären links und rechts gespiegelt ist (ein Strich über die Mitte malte sich doppelt, Prüfer
# r3, r4: „nur ein heller Fleck“)
bmk = bmesh.new(); bmk.from_mesh(KOPF.data); bmk.transform(KOPF.matrix_world)
KB = BVHTree.FromBMesh(bmk); bmk.free()
nv_, nf_ = [], []
for k in (-1, 0, 1):
    a0 = baer_zu_krogg(Vector((0.058, -1.335 + 0.040 * k, 1.25))); a1 = baer_zu_krogg(Vector((-0.052, -1.405 + 0.040 * k, 1.25)))
    reihe = []
    for t_ in np.linspace(0, 1, 9):
        p0 = a0.lerp(a1, t_)
        hit = KB.ray_cast(p0 + Vector((0, 0, 0.2)), Vector((0, 0, -1)), 0.5)
        if hit[0] is None: continue
        nrm = hit[1].normalized()
        quer_ = (a1 - a0).cross(nrm).normalized()
        breite = 0.0035 * (1 - abs(2 * t_ - 1) ** 3) + 0.0008
        o0 = len(nv_)
        nv_ += [hit[0] + nrm * 0.0015 + quer_ * breite, hit[0] + nrm * 0.0015 - quer_ * breite]
        reihe.append(o0)
    for i in range(len(reihe) - 1):
        nf_.append((reihe[i], reihe[i] + 1, reihe[i + 1] + 1, reihe[i + 1]))
netz('Krogg_Narben', nv_, nf_, 0xC79A86, 'Head')
print('NARBEN %d Bänder, %d Ecken' % (3, len(nv_)))

# ---------------------------------------------------------------- (5) Farben
def lade(pfad, kante):
    im = Image.open(pfad).convert('RGB')
    if im.size[0] != kante: im = im.resize((kante, kante), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def speichere(a, name):
    p = os.path.join(OUT, 'tex', name)
    Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8)).save(p)
    return p


FELL_Z = srgb(FELL)


def fellbild(a, med=None, maske=None):
    # Farbbild -> Kroggs Fell: Helligkeit bleibt, Ton lohfarben bis rostbraun; feine Strähnen (gerichtetes Rauschen), nicht glatt
    lum = a.mean(2)
    med = med or float(np.median(lum[lum > 0.08]))
    b = FELL_Z[None, None, :] * np.clip(lum / med, 0.25, 1.7)[..., None]
    h, w = lum.shape
    r = RNG.random((h // 4, w // 4)).astype(np.float32)
    st = Image.fromarray((r * 255).astype(np.uint8)).resize((w, h), Image.BILINEAR).filter(ImageFilter.GaussianBlur(1.2))
    st = Image.fromarray(np.asarray(st)).resize((w // 8, h), Image.BILINEAR).resize((w, h), Image.BILINEAR)
    s = np.asarray(st, np.float32) / 255.0
    b *= (0.82 + 0.36 * s)[..., None]
    # Rost in den Tiefen, Falb in den Lichtern (lohfarben bis rostbraun)
    b[..., 0] *= np.clip(1.0 + 0.10 * (1 - lum / med), 0.9, 1.15)
    b[..., 2] *= np.clip(0.95 + 0.10 * (lum / med - 1), 0.8, 1.1)
    if maske is not None: b = maske(b)
    return b


def uv_je_ecke(o):
    me = o.data; uv = me.uv_layers.active.data
    vuv = np.zeros((len(me.vertices), 2))
    for l in me.loops: vuv[l.vertex_index] = uv[l.index].uv
    return vuv


def male_flaechen(b, o, gewicht, farbe, staerke=1.0, weich=3.0):
    # Gewicht je Ecke -> Flächen im UV-Bild füllen (wie grak_gestalt.py)
    Hh, Ww = b.shape[:2]
    mk = np.zeros((Hh, Ww), np.float32)
    me = o.data; uv = me.uv_layers.active.data
    me.calc_loop_triangles()
    for tri in me.loop_triangles:
        g3 = gewicht[list(tri.vertices)]
        if g3.max() < 0.03: continue
        q = np.array([(uv[li].uv[0] % 1 * Ww, (1 - uv[li].uv[1] % 1) * Hh) for li in tri.loops])
        x0, y0 = np.floor(q.min(0)).astype(int); x1, y1 = np.ceil(q.max(0)).astype(int) + 1
        x0, y0 = max(x0, 0), max(y0, 0); x1, y1 = min(x1, Ww), min(y1, Hh)
        if x1 <= x0 or y1 <= y0: continue
        gx, gy = np.meshgrid(np.arange(x0, x1) + 0.5, np.arange(y0, y1) + 0.5)
        d = (q[1, 1] - q[2, 1]) * (q[0, 0] - q[2, 0]) + (q[2, 0] - q[1, 0]) * (q[0, 1] - q[2, 1])
        if abs(d) < 1e-9: continue
        l0 = ((q[1, 1] - q[2, 1]) * (gx - q[2, 0]) + (q[2, 0] - q[1, 0]) * (gy - q[2, 1])) / d
        l1 = ((q[2, 1] - q[0, 1]) * (gx - q[2, 0]) + (q[0, 0] - q[2, 0]) * (gy - q[2, 1])) / d
        l2 = 1 - l0 - l1
        drin = (l0 >= -0.02) & (l1 >= -0.02) & (l2 >= -0.02)
        w = np.clip(l0 * g3[0] + l1 * g3[1] + l2 * g3[2], 0, 1)
        mk[y0:y1, x0:x1] = np.where(drin, np.maximum(mk[y0:y1, x0:x1], w), mk[y0:y1, x0:x1])
    mk = Image.fromarray((mk * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(weich * Ww / 2048))
    mk = np.asarray(mk, dtype=np.float32)[..., None] / 255.0 * staerke
    return b * (1 - mk) + np.array(farbe)[None, None, :] * mk


# Kopf: Fell des Bären auf Kroggs Ton (Nase, Lippen und Augenring bleiben dunkel), Augen gedämpft rot, drei Krallennarben quer über
# den Schnauzenrücken (von rechts oben nach links unten), Mähnenansatz dunkler
a = lade(BAER_BILD, 2048)
lum_b = a.mean(2)
dunkel = np.clip((0.16 - lum_b) / 0.08, 0, 1)[..., None]     # Nase, Lefzen, Augen: bleiben, wie sie sind
kopf_fell = fellbild(a)
kopf_fell = kopf_fell * (1 - dunkel) + a * 0.8 * dunkel
Vb_k = Vk_b                        # Bärenraum je Ecke des Kopfs (gleiche Reihenfolge)
auge_w = np.zeros(len(Vb_k))
for sgn in (-1, 1):
    c = np.array([sgn * AUGE_B.x, AUGE_B.y, AUGE_B.z])
    auge_w = np.maximum(auge_w, np.exp(-(np.linalg.norm(Vb_k - c, axis=1) / 0.011) ** 2))
mae_w = glatt(-1.10, -0.97, Vb_k[:, 1]) * 0.7
kopf_bild = male_flaechen(kopf_fell, KOPF, mae_w, srgb(MAEHNE), 0.8, 6.0)
kopf_bild = male_flaechen(kopf_bild, KOPF, auge_w, AUGE, 0.95, 1.0)
kopf_png = speichere(kopf_bild, 'krogg_kopf.png')

# Leib: Haut des Superhelden zu Fell; Hände und Fußsohlen dunkler (Ballen)
leib_mat = LEIB.data.materials[0]
leib_bild = next(n_.image for n_ in leib_mat.node_tree.nodes if n_.type == 'TEX_IMAGE' and n_.image and
                 not any(k in n_.image.name for k in ('Normal', 'Rough', 'ORM')))
pfad_leib = bpy.path.abspath(leib_bild.filepath) if leib_bild.filepath else ''
if not os.path.exists(pfad_leib):
    pfad_leib = finde('T_Superhero_Male_Dark.png')
QUELLEN.append(os.path.basename(pfad_leib))
a = lade(pfad_leib, TEX)
w_hand = gewicht_feld(LEIB, [b.name for b in ARM.data.bones if b.name.startswith(('hand_',) + FINGERN)])
leib_bild = male_flaechen(fellbild(a), LEIB, np.clip(w_hand, 0, 1) * 0.55, srgb(0x3A2418), 0.6, 4.0)
leib_png = speichere(leib_bild, 'krogg_leib.png')


def bild_material(name, png):
    mat = bpy.data.materials.new(name); mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    ti = mat.node_tree.nodes.new('ShaderNodeTexImage'); ti.image = bpy.data.images.load(png, check_existing=True)
    mat.node_tree.links.new(ti.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = 0.95
    return mat


LEIB.data.materials.clear(); LEIB.data.materials.append(bild_material('Krogg_Fell', leib_png))
KOPF.data.materials.clear(); KOPF.data.materials.append(bild_material('Krogg_Kopf', kopf_png))
weiss = speichere(np.ones((8, 8, 3), np.float32), 'weiss.png')
for o in [o for o in bpy.data.objects if o.type == 'MESH']:
    me = o.data
    farbe = o.get('farbe')
    if farbe is not None:
        mat = bild_material('Krogg_' + o.name.split('_')[1], weiss)
        me.materials.clear(); me.materials.append(mat)
        c = lin(int(farbe))
        if not me.uv_layers: me.uv_layers.new()
    else:
        c = (1.0, 1.0, 1.0)
    ca = me.color_attributes.get('Col') or me.color_attributes.new('Col', 'BYTE_COLOR', 'CORNER')
    eck = me.get('eck')
    for lp, d in zip(me.loops, ca.data):
        t = eck[lp.vertex_index] if eck is not None else 1.0
        d.color = (min(1, c[0] * t), min(1, c[1] * t), min(1, c[2] * t), 1.0)
    if eck is not None: del me['eck']


# ---------------------------------------------------------------- (6) Größe: 212 cm bis zum Scheitel (ohne Ohren, Mähne)
def scheitel():
    zk = float(np.delete(welt(KOPF), OHR_IDX, 0)[:, 2].max())
    return max(zk, float(welt(LEIB)[:, 2].max()))


s_ = HOEHE / scheitel()
ARM.scale = (s_, s_, s_)
bpy.context.view_layer.update()
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects: o.select_set(True)
bpy.context.view_layer.objects.active = ARM
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
bpy.context.view_layer.update()

# ---------------------------------------------------------------- (7) Morgenstern (Anker „Spiked Mace“, CC0): Liste 4 dunkles Eisen,
# schwarz von altem Blut; eine Hand (rechts), Länge 0,92 m (für Krogg; das Modell 1,27 m)
mteile = importiere(finde('Spiked Mace.fbx', KAUF))
WAFFE = next(o for o in mteile if o.type == 'MESH')
for o in mteile:
    if o is not WAFFE: bpy.data.objects.remove(o)
bpy.context.view_layer.objects.active = WAFFE
bpy.ops.object.select_all(action='DESELECT'); WAFFE.select_set(True)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
Vw = welt(WAFFE)
LW = 0.92 / float(Vw[:, 2].max() - Vw[:, 2].min())
Vw = (Vw - np.array([0, 0, Vw[:, 2].min()])) * LW
setze(WAFFE, Vw)
WAFFE.name = 'Waffe'
mw = WAFFE.data
w_eisen = []
for p in mw.polygons:
    w_eisen.append(mw.materials[p.material_index].name.startswith('Dark') if mw.materials else True)
mat = bild_material('Krogg_Morgenstern', weiss)
mw.materials.clear(); mw.materials.append(mat)
ca = mw.color_attributes.new('Col', 'BYTE_COLOR', 'CORNER')
if not mw.uv_layers: mw.uv_layers.new()
for p in mw.polygons:
    for li in p.loop_indices:
        v = Vw[mw.loops[li].vertex_index]
        if w_eisen[p.index]:
            blut = 0.5 + 0.5 * math.sin(v[0] * 61 + v[1] * 47 + v[2] * 83)     # Flecken alten Bluts auf dem Eisen
            c = lin(0x2A2624) * (1 - 0.55 * blut) + lin(0x2A0C08) * 0.55 * blut
        else:
            c = lin(0x3A2416) * (0.8 if v[2] > 0.55 else 1.0)
        ca.data[li].color = (c[0], c[1], c[2], 1.0)
GRIFF_Z = 0.10                     # Faust 10 cm über dem Stielende

# ---------------------------------------------------------------- (8) Bewegungen aus der UAL, auf Kroggs Gerüst
ual = importiere(finde('UAL1_Standard.glb'))
UA = next(o for o in ual if o.type == 'ARMATURE')
if os.environ.get('UAL'):
    for o in importiere(os.environ['UAL']): bpy.data.objects.remove(o)
reihen = [b.name for b in ARM.data.bones]
eltern = {b.name: (b.parent.name if b.parent else None) for b in ARM.data.bones}
r_uns = {b.name: b.matrix_local.to_quaternion() for b in ARM.data.bones}
r_ual = {b.name: b.matrix_local.to_quaternion() for b in UA.data.bones}
becken_ual = UA.data.bones['pelvis'].head_local.copy()
mass = ARM.data.bones['pelvis'].head_local.z / becken_ual.z
ARM.animation_data_create()
for pb in ARM.pose.bones: pb.rotation_mode = 'QUATERNION'
sc = bpy.context.scene
FPS = sc.render.fps / sc.render.fps_base
PB = ARM.pose.bones


def binde(o, a):
    o.animation_data.action = a
    if len(getattr(a, 'slots', [])):
        o.animation_data.action_slot = a.slots[0]


# Haltung (Liste 5: Schultern hochgezogen, leicht geduckt): je Bild Rumpf vor, Hals und Kopf zurück (Blick bleibt vorn),
# Schlüsselbeine hoch; Drehung um die Achsen der Ruhelage (Welt X quer, Y vorn/hinten)
HALTUNG = (('spine_01', 'X', 5), ('spine_02', 'X', 6), ('spine_03', 'X', 4), ('neck_01', 'X', -9), ('Head', 'X', -6),
           ('clavicle_l', 'Y', -14), ('clavicle_r', 'Y', 14))


def haltung_q(b, achse, grad):
    ax = r_uns[b].inverted() @ Vector({'X': (1, 0, 0), 'Y': (0, 1, 0), 'Z': (0, 0, 1)}[achse])
    return Quaternion(ax, math.radians(grad))


HALT_Q = [(b, haltung_q(b, a, g)) for b, a, g in HALTUNG if b in r_uns]
FAUST = {}                         # rechte Faust um den Stiel: Finger aus Sword_Idle Bild 0


def lokal(q_name, tempo=1.0, halt=False):
    # Bewegung q_name als lokale Drehungen je Bild und Knochen auf Kroggs Gerüst (ohne Schlüssel)
    q = bpy.data.actions[q_name]; binde(UA, q)
    a0, a1 = q.frame_range
    n = int(round((a1 - a0) / tempo))
    bilder = []
    for f in range(0, n + 1):
        t = a0 + f * tempo
        sc.frame_set(int(t), subframe=t % 1)
        D = {}
        for b in reihen:
            pu = UA.pose.bones.get(b)
            D[b] = (pu.matrix.to_quaternion() @ r_ual[b].inverted()) if pu else Quaternion()
        R = {}
        for b in reihen:
            dp = D[eltern[b]] if eltern[b] else Quaternion()
            R[b] = r_uns[b].inverted() @ (dp.inverted() @ D[b]) @ r_uns[b]
        d_ = UA.pose.bones['pelvis'].matrix.translation - becken_ual
        R['_becken'] = r_uns['pelvis'].inverted() @ (d_ * mass)
        bilder.append(R)
    return bilder


def seite(s_):     # Arm einer Seite mit Hand und Fingern
    return [b for b in reihen if b.endswith('_' + s_) and b.split('_')[0] in ('clavicle', 'upperarm', 'lowerarm', 'hand') + FINGERN]


ARM_R, ARM_L = seite('r'), seite('l')


def uebertrage(q_name, z_name, tempo=1.0, kurz=None, halt=True, arme=()):
    # arme: [(Knochen, Bilder einer anderen Bewegung)], z. B. der Waffenarm aus Sword_Idle (Bild f mod Länge)
    bilder = lokal(q_name, tempo)
    if kurz: bilder = bilder[:kurz + 1]
    z = bpy.data.actions.new(z_name); z.use_fake_user = True; ARM.animation_data.action = z
    for f, R in enumerate(bilder):
        for kn, quelle in arme:
            for b in kn:
                R[b] = quelle[f % len(quelle)][b]
        for b in reihen:
            PB[b].rotation_quaternion = R[b]
        PB['pelvis'].location = R['_becken']; PB['pelvis'].keyframe_insert('location', frame=f)
        if halt:
            for b, hq in HALT_Q:
                PB[b].rotation_quaternion = PB[b].rotation_quaternion @ hq
        for b, qf in FAUST.items():
            PB[b].rotation_quaternion = qf
        for b in reihen:
            PB[b].keyframe_insert('rotation_quaternion', frame=f)
    return z, len(bilder) - 1


SWORD = lokal('Sword_Idle')
IDLE = lokal('Idle_Loop')
FAUST = {b: SWORD[0][b].copy() for b in ARM_R if b.split('_')[0] in FINGERN}
# Prüfer r1 (Sword_Idle als Stehen: tief geduckt, Knie weit gebeugt, nur gut 10 cm über dem Helden): Stehen aufrecht aus Idle_Loop,
# nur der Waffenarm aus Sword_Idle (Morgenstern kampfbereit vor dem Körper); so auch beim Gehen, Rennen, Ausweichen.
# Hieb (Prüfer r1: Ausfallschritt wie ein Krebs, freie Hand wie im Ballett, Stiel im Oberschenkel): mit der Pro Sword_Attack_Standing
# (im Stand), die linke Hand hängt wie in Idle_Loop
WA = [(ARM_R, SWORD)]
HIEB_Q = 'Sword_Attack_Standing' if os.environ.get('UAL') and 'Sword_Attack_Standing' in bpy.data.actions else 'Sword_Attack'
ZU = [('Idle_Loop', 'Stehen', 1.0, None, WA), ('Walk_Loop', 'Gehen', 1.0, None, WA), ('Hit_Chest', 'Treffer', 1.0, None, ()),
      (os.environ.get('TOD_QUELLE', 'Death01'), 'Tod', 1.0, None, ()), (HIEB_Q, 'Hieb', float(os.environ.get('HIEB_TEMPO', '1.35')), None, [(ARM_L, IDLE)])]
if os.environ.get('UAL'):
    ZU += [('Jog_Fwd_Loop', 'Rennen', 1.0, None, WA), ('Jog_Bwd_Loop', 'Zurück', 1.0, None, WA), ('Jog_Right_Loop', 'Ausweichen', 1.0, 9, WA),
           ('Jog_Left_Loop', 'Ausweichen links', 1.0, 9, WA)]
BEWEGT = {z_: uebertrage(q_, z_, t_, k_, arme=a_, halt=z_ != 'Tod') for q_, z_, t_, k_, a_ in ZU}
print('BEWEGUNG Hieb aus %s' % HIEB_Q)
WEG = {}
RM = os.environ.get('UAL_RM') or (os.path.join(os.path.dirname(os.environ['UAL']), 'UAL1_RM.glb') if os.environ.get('UAL') else '')
if RM and os.path.exists(RM):
    alt_ = set(bpy.data.actions)
    rm_ = importiere(RM)
    RA = next(o for o in rm_ if o.type == 'ARMATURE')
    neu_ = {a_.name.split('.')[0]: a_ for a_ in bpy.data.actions if a_ not in alt_}
    for q_, z_, t_, k_, _ in ZU:
        if z_ not in ('Gehen', 'Rennen', 'Zurück', 'Ausweichen', 'Ausweichen links') or q_ not in neu_: continue
        binde(RA, neu_[q_])
        a0, a1 = [int(round(v)) for v in neu_[q_].frame_range]
        if k_: a1 = min(a1, a0 + k_)
        sc.frame_set(a0); w0 = (RA.matrix_world @ RA.pose.bones['root'].matrix).translation.copy()
        WEG[z_] = []
        for f in range(a0, a1 + 1):
            sc.frame_set(f); w_ = (RA.matrix_world @ RA.pose.bones['root'].matrix).translation - w0
            WEG[z_].append([round(w_.x * mass, 4), round(-w_.y * mass, 4)])
        print('WEG %s aus %s: %d Bilder, Ende %.2f m seitlich, %.2f m vor' % (z_, q_, len(WEG[z_]), WEG[z_][-1][0], WEG[z_][-1][1]))
    for o in rm_: bpy.data.objects.remove(o)
    for a_ in neu_.values(): bpy.data.actions.remove(a_)
for o in ual: bpy.data.objects.remove(o)
for a_ in list(bpy.data.actions):
    if a_.name not in BEWEGT: bpy.data.actions.remove(a_)
STEHEN = BEWEGT['Stehen'][0]
ARM.animation_data.action = STEHEN
sc.frame_set(0); bpy.context.view_layer.update()

# Morgenstern in die rechte Faust (Stehen, Bild 0): Stiel durch die Faust längs der Knöchel (vom kleinen zum Zeigefinger), zum
# Unterarm hin gekippt (STIEL_KIPP; Prüfer r1: der Stiel zeigte waagerecht nach vorn auf Gürtelhöhe), Kopf auf der Daumenseite
STIEL_KIPP = math.radians(float(os.environ.get('STIEL_KIPP', '30')))     # 35, 40, 50 gemessen: 40 und 50 im Tod und Treffer in der Mähne
pb_ = ARM.pose.bones
AW = ARM.matrix_world.copy()
faust = sum((AW @ pb_[k].head for k in ('index_02_r', 'middle_02_r', 'ring_02_r', 'thumb_02_r')), Vector()) / 4
achse = ((AW @ pb_['index_01_r'].head) - (AW @ pb_['pinky_01_r'].head)).normalized()
hand_y = (AW.to_3x3() @ pb_['hand_r'].matrix.col[1].xyz).normalized()
hand_y = (hand_y - achse * hand_y.dot(achse)).normalized()
achse = (achse * math.cos(STIEL_KIPP) - hand_y * math.sin(STIEL_KIPP)).normalized()
quer = hand_y.cross(achse).normalized(); hand_y = achse.cross(quer).normalized()     # rechtshändig (sonst Skala −1 am Knochen)
R_w = Matrix((quer, hand_y, achse)).transposed()     # Waffe: Z = Stiel (zum Kopf)
M_w = Matrix.Translation(faust) @ R_w.to_4x4() @ Matrix.Translation((0, 0, -GRIFF_Z))
# eigener Knochen „waffe“ (Kind von root) wie Graks „axt“: je Bild dorthin, wo die Faust ihn hält; im Tod lässt die Faust los
H_w = (AW @ PB['hand_r'].matrix).inverted() @ M_w
bpy.context.view_layer.objects.active = ARM; bpy.ops.object.mode_set(mode='EDIT')
eb = ARM.data.edit_bones.new('waffe'); eb.head = (0, 0, 0); eb.tail = (0, 0.1, 0); eb.parent = ARM.data.edit_bones['root']
bpy.ops.object.mode_set(mode='OBJECT')
PB = ARM.pose.bones; PB['waffe'].rotation_mode = 'QUATERNION'
WAFFE.parent = ARM; WAFFE.parent_type = 'BONE'; WAFFE.parent_bone = 'waffe'
bpy.context.view_layer.update()
WAFFE.matrix_world = M_w
bpy.context.view_layer.update()
K_w = (AW @ PB['waffe'].matrix).inverted() @ WAFFE.matrix_world


def waffe_nach(M, f):
    pb = PB['waffe']; pb.matrix = AW.inverted() @ M @ K_w.inverted(); bpy.context.view_layer.update()
    pb.scale = (1, 1, 1)
    pb.keyframe_insert('rotation_quaternion', frame=f); pb.keyframe_insert('location', frame=f)


def waffe_hand(f):
    waffe_nach(AW @ PB['hand_r'].matrix @ H_w, f)


# ---------------------------------------------------------------- (9) Prüfen mit Zahlen: Morgenstern gegen Kroggs Netze (ohne Hand
# und Finger), tiefster Punkt, Aufschlag des Hiebs
HANDK = ('hand_', 'thumb_', 'index_', 'middle_', 'ring_', 'pinky_')
NETZE = [o for o in bpy.data.objects if o.type == 'MESH' and o is not WAFFE]


def knoten(o):
    gno = {g.index: g.name for g in o.vertex_groups}
    return [gno.get(max(o.data.vertices[p.vertices[0]].groups, key=lambda e: e.weight).group, '')
            if len(o.data.vertices[p.vertices[0]].groups) else '' for p in o.data.polygons]


KNO = {o.name: knoten(o) for o in NETZE}


def baum_(o, dg):
    e = o.evaluated_get(dg); me = e.to_mesh(); bm = bmesh.new(); bm.from_mesh(me); bm.transform(o.matrix_world)
    t = BVHTree.FromBMesh(bm); bm.free(); e.to_mesh_clear(); return t


def treffer_():
    dg = bpy.context.evaluated_depsgraph_get(); ta = baum_(WAFFE, dg); n_ = 0; wo = {}
    for o in NETZE:
        kn = KNO[o.name]
        for _, j in ta.overlap(baum_(o, dg)):
            if j < len(kn) and kn[j].startswith(HANDK): continue
            n_ += 1; wo[o.name] = wo.get(o.name, 0) + 1
    return n_, wo


def tiefst(nur=None):
    dg = bpy.context.evaluated_depsgraph_get(); z_ = 9.0
    for o in (nur or NETZE + [WAFFE]):
        e = o.evaluated_get(dg); me = e.to_mesh()
        if len(me.vertices):
            v_ = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', v_)
            z_ = min(z_, float((np.array(o.matrix_world) @ np.c_[v_.reshape(-1, 3), np.ones(len(me.vertices))].T)[2].min()))
        e.to_mesh_clear()
    return z_


def tiefst_ohne_arme():
    v_ = welt_eval(LEIB)
    return min(float(v_[~ARMECKEN, 2].min()), float(welt_eval(KOPF)[:, 2].min()))


def welt_eval(o):
    dg = bpy.context.evaluated_depsgraph_get(); e = o.evaluated_get(dg); me = e.to_mesh()
    v_ = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', v_); e.to_mesh_clear()
    M = np.array(o.matrix_world); return v_.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]


def waffe_tief():
    dg = bpy.context.evaluated_depsgraph_get(); e = WAFFE.evaluated_get(dg); me = e.to_mesh()
    z_ = min((WAFFE.matrix_world @ v.co).z for v in me.vertices); e.to_mesh_clear(); return z_


TOD_LOS = float(os.environ.get('TOD_LOS', '0.08'))     # Anteil der Todesbewegung, dann lässt die Faust den Morgenstern los
TOD_FALL = float(os.environ.get('TOD_FALL', '0.4'))    # s, bis er flach neben Krogg liegt
BODEN_ABST = 0.02
ARMECKEN = gewicht_feld(LEIB, [b for b in reihen if b.split('_')[0] in ('lowerarm', 'hand') + FINGERN]) > 0.5
MESS = {}
for nm, (z, n) in BEWEGT.items():
    ARM.animation_data.action = z
    los = int(TOD_LOS * n) if nm == 'Tod' else n + 1
    gehoben = 0
    for f in range(0, n + 1):
        sc.frame_set(f); bpy.context.view_layer.update()
        if nm == 'Tod':                # wie Grak: liegend nicht im Boden (Becken heben)
            z_ = tiefst_ohne_arme() + 0.01     # Büschel dürfen sich ins Gras legen; Prüfer r3: die langen Arme hoben ihn in die Luft
            if z_ < 0.0:
                pb = PB['pelvis']; pb.matrix = Matrix.Translation((0, 0, -z_)) @ pb.matrix; bpy.context.view_layer.update()
                pb.keyframe_insert('location', frame=f)
        if f <= los:
            waffe_hand(f)
        if nm != 'Tod' and waffe_tief() < BODEN_ABST:     # Erstlauf: Hieb schlug 11 cm in den Boden; Unterarm heben, bis er frei ist
            for _ in range(15):
                if waffe_tief() >= BODEN_ABST: break
                pb = PB['lowerarm_r']; h = pb.matrix.translation.copy()
                d = pb.matrix.col[1].xyz.normalized(); ax = d.cross(Vector((0, 0, 1)))
                if ax.length < 1e-3: break
                pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-3), 4, ax.normalized()) @ Matrix.Translation(-h) @ pb.matrix
                bpy.context.view_layer.update(); waffe_hand(f)
                if waffe_tief() < BODEN_ABST:     # falsche Richtung: zurück und andersherum
                    pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(6), 4, ax.normalized()) @ Matrix.Translation(-h) @ pb.matrix
                    bpy.context.view_layer.update(); waffe_hand(f)
            PB['lowerarm_r'].keyframe_insert('rotation_quaternion', frame=f); gehoben += 1
    if nm == 'Tod':     # der Morgenstern fällt ab dem Loslassen in TOD_FALL s flach zu Boden neben Krogg (wie Graks Axt)
        sc.frame_set(los); bpy.context.view_layer.update()
        M0 = WAFFE.matrix_world.copy()
        nf = max(1, int(round(TOD_FALL * FPS)))
        sc.frame_set(n); bpy.context.view_layer.update()
        becken = AW @ PB['pelvis'].matrix.translation; kopf_ = AW @ PB['Head'].matrix.translation
        lang = Vector((kopf_.x - becken.x, kopf_.y - becken.y, 0.0)).normalized()
        querv = Vector((0, 0, 1)).cross(lang).normalized()
        if querv.dot(Vector((M0.translation.x - becken.x, M0.translation.y - becken.y, 0.0))) < 0: querv = -querv
        mitte = Vector((becken.x, becken.y, 0.0)) + lang * 0.3
        proben = list(range(los + nf, n + 1, 3)) + [n]
        best = None
        for sei in (1, -1):
            for ab_ in (0.6, 0.85, 1.1, 1.35):
                for winkel in (0, 35, -35):
                    zs = Quaternion((0, 0, 1), math.radians(winkel)) @ lang
                    R1 = Matrix((Vector((0, 0, 1)).cross(zs).normalized(), Vector((0, 0, 1)), zs)).transposed()
                    M1 = Matrix.Translation(mitte + querv * sei * ab_) @ R1.to_4x4()
                    waffe_nach(M1, n); M1 = Matrix.Translation((0, 0, 0.004 - waffe_tief())) @ M1
                    t_ = 0
                    for f in proben:
                        sc.frame_set(f); bpy.context.view_layer.update(); waffe_nach(M1, f); t_ += treffer_()[0]
                    for i in range(1, nf):
                        if los + i > n: break
                        fall = (i / nf) ** 2
                        M = Matrix.Translation(M0.translation.lerp(M1.translation, fall)) @ M0.to_quaternion().slerp(M1.to_quaternion(), fall).to_matrix().to_4x4()
                        sc.frame_set(los + i); bpy.context.view_layer.update(); waffe_nach(M, los + i); t_ += treffer_()[0]
                    wert = (t_, sei != 1, ab_)
                    if best is None or wert < best[0]: best = (wert, M1)
        M1 = best[1]
        for i in range(0, nf + 1):
            if los + i > n: break
            fall = (i / nf) ** 2
            M = Matrix.Translation(M0.translation.lerp(M1.translation, fall)) @ M0.to_quaternion().slerp(M1.to_quaternion(), fall).to_matrix().to_4x4()
            sc.frame_set(los + i); bpy.context.view_layer.update(); waffe_nach(M, los + i)
            if waffe_tief() < 0.004: waffe_nach(Matrix.Translation((0, 0, 0.004 - waffe_tief())) @ M, los + i)
        for f in range(los + nf + 1, n + 1):
            sc.frame_set(f); bpy.context.view_layer.update(); waffe_nach(M1, f)
        print('TOD Morgenstern fällt ab Bild %d in %d Bildern, liegt %.2f m vom Becken' % (los, nf, (M1.translation - becken).length))
    t_ges = 0; wo_ges = {}; tief = 9.0
    for f in range(0, n + 1):
        sc.frame_set(f); bpy.context.view_layer.update()
        t_, wo = treffer_(); t_ges += t_
        for k, v in wo.items(): wo_ges[k] = wo_ges.get(k, 0) + v
        tief = min(tief, tiefst())
    MESS[nm] = (t_ges, wo_ges, tief)
    print('BEWEGUNG %s %d Bilder: Morgenstern %d Paare in Netzen %s, tiefster Punkt %.3f m, Unterarm gehoben in %d Bildern' % (
        nm, n + 1, t_ges, wo_ges, tief, gehoben))
# Aufschlag des Hiebs: Bild, in dem der Kopf des Morgensterns am weitesten vor Krogg ist (Raum des Modells: vorn = −Y)
hieb, nh = BEWEGT['Hieb']
ARM.animation_data.action = hieb
best = None
for f in range(0, nh + 1):
    sc.frame_set(f); bpy.context.view_layer.update()
    kp = WAFFE.matrix_world @ Vector((0, 0, 0.92 - 0.12))
    if best is None or -kp.y > best[1]: best = (f, -kp.y, kp)
f_auf, vor, kp = best
HIEB = [round(math.hypot(kp.x, kp.y), 3), round(f_auf / FPS, 3), round(-math.degrees(math.atan2(kp.x, -kp.y)), 1), round(kp.z, 2)]
print('HIEB Aufschlag Bild %d (%.2f s von %.2f s): Kopf %.2f m vor dem Ursprung, %.0f Grad, %.2f m hoch' % (
    f_auf, f_auf / FPS, nh / FPS, HIEB[0], -HIEB[2], HIEB[3]))
ARM.animation_data.action = STEHEN
sc.frame_set(0); bpy.context.view_layer.update()
st = WAFFE.matrix_world.to_3x3() @ Vector((0, 0, 1)); kk = WAFFE.matrix_world @ Vector((0, 0, 0.80))
print('STEHEN Scheitel %.2f m (Kopf ohne Ohren)' % float(np.delete(welt_eval(KOPF), OHR_IDX, 0)[:, 2].max()))
print('STEHEN Stiel %.0f Grad über der Waagerechten, Richtung vor %.2f seitlich %.2f; Kopf %.2f m hoch, %.2f m vor' % (
    math.degrees(math.asin(max(-1, min(1, st.z)))), -st.y, st.x, kk.z, -kk.y))

# ---------------------------------------------------------------- (10) Ausgabe
info = {'hoehe': round(scheitel(), 3), 'quellen': sorted(set(QUELLEN)),
        'lizenz': 'Quaternius CC0 1.0 (Körper, Bewegungen), Anker CC0 (Morgenstern), Janpec Animal Pack Deluxe gekauft (Bärenkopf)',
        'masse': {'kopf_breite_m': round(float(np.ptp(welt(KOPF)[:, 0])), 3), 'hand_r_m': round(float((KN['hand_r'] - KN['lowerarm_r']).length * s_), 3)},
        'pruefung': {k: {'paare': v[0], 'netze': v[1], 'tief_m': round(v[2], 3)} for k, v in MESS.items()},
        'spiel': {'weg': WEG, 'fps': FPS, 'hieb': HIEB}}
ecken = sum(len(o.data.vertices) for o in bpy.data.objects if o.type == 'MESH')
dreiecke = 0
for o in bpy.data.objects:
    if o.type == 'MESH':
        o.data.calc_loop_triangles(); dreiecke += len(o.data.loop_triangles)
info['ecken'] = ecken; info['dreiecke'] = dreiecke
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, 'krogg-gestalt.glb'), export_format='GLB', export_animations=True,
                          export_animation_mode='ACTIONS', export_skins=True, export_apply=False, export_yup=True,
                          export_image_format='AUTO', export_vertex_color='ACTIVE', export_all_vertex_colors=False)
if os.environ.get('BLEND'):
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, 'krogg-gestalt.blend'))
json.dump(info, open(os.path.join(OUT, 'krogg-gestalt-info.json'), 'w'), indent=1, ensure_ascii=False)
print('FERTIG', json.dumps({k: v for k, v in info.items() if k != 'spiel'}, ensure_ascii=False))
