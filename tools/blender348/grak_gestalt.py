# 348.12 Gestalt (Chef 28.10., 08:09: Grak „Welches Modell läuft da? Welche Texturen? Der sieht gar nicht gut aus“; 08:10: erst die
# Gestalt, dann Bewegung): Grak aus freien Quaternius-Teilen (CC0 1.0, Lizenzdatei je Paket, laedt v3/cc0_laden.sh) statt aus
# unserem Eigenbau (held3.py, Eckfarben ohne Textur). Bestand geprueft (LISTE-BESTAND): Universal Base Characters [Standard]
# (Superhero_Male_FullBody: nur Kopf und Hals), Modular Character Outfits Fantasy [Standard] (Male_Ranger: Rumpf, Arme mit Haenden,
# Beine, Stiefel, Guertel, Armschienen, Schulterstueck), Universal Animation Library [Standard] (Idle_Loop als „Stehen“).
# Eigen: Kopf zum Hobgoblin geformt (v3/kopf.py, Tom 376.1, und spitze Ohren), Hauer, Haarknoten mit Zopf, Brustplatte, zweites
# Schulterstueck, Hauptmannsumhang, Farben (Haut rotbraun, Kriegsbemalung, Narbe, Augen bernstein; Gruen der Tracht wird
# Karmin, Leder dunkler), Grossaxt (waffen.py greataxe-grak) in der rechten Hand. Grak nach LISTE-FIGUREN „Grak“.
# Aufruf: OUT=<ordner> CC0=<cc0-ordner> WAFFEN=<ordner mit greataxe-grak.glb> python -I grak_gestalt.py
#         -> <OUT>/grak-gestalt.glb, grak-gestalt-info.json (Masse, Quellen)
import bpy, bmesh, os, sys, json, math, colorsys
import numpy as np
from mathutils import Vector, Matrix, Quaternion
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'v3'))
import kopf as K

OUT = os.environ.get('OUT', os.path.expanduser('~/grakg'))
CC0 = os.environ.get('CC0', os.path.expanduser('~/cc0'))
WAFFEN = os.environ.get('WAFFEN', os.path.expanduser('~/waffen'))
TEX = int(os.environ.get('TEX', '2048'))          # Kantenlaenge der Bilder im Spiel (Quelle 4096 bzw. 2048)
os.makedirs(os.path.join(OUT, 'tex'), exist_ok=True)

HOEHE = 1.86                       # Liste „Grak“ 1: 186 cm (Kauffigur 1,81 m mit Kopf)
# Hobgoblin-Kopf (Liste 3: breites flaches Gesicht, schwere Stirn, platte Nase): Regler wie kopf.FORMEN
FORM = dict(breite=0.10, kiefer=0.30, laenge=0.02, kinn=0.006, nase=-0.30, wangen=0.010, brauen=0.013)
HAUT = 0x7A3A22                    # Liste 4: dunkelorange bis rotbraun (Doll 0x8A3E28, eigener Bau 0x6A3220)
MANTEL = 0x5A1A22                  # Steppmantel dunkelrot (Gruen der Tracht)
LEDER = 0.55                       # Leder der Tracht so viel dunkler
STAHL = 0x6A6E74                   # Brustplatte, Schulterstuecke
UMHANG = 0x6A1A16                  # roter Hauptmannsumhang
HAAR = 0x2A1E16                    # r2 (Prüfer r1: schwarzer Keil am Scheitel): Schwarzbraun statt Schwarz
ZAHN = 0xC8BC98
AUGE = 0xD08A1C                    # bernstein
QUELLEN = []


def lin(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return np.array([x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c])


def srgb(h):
    return np.array([((h >> s) & 255) / 255.0 for s in (16, 8, 0)])


def finde(name):
    for wo, _, fs in sorted(os.walk(CC0)):
        if name in fs: return os.path.join(wo, name)
    raise SystemExit('fehlt in CC0: ' + name)


def importiere(pfad):
    vorher = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=pfad)
    neu = [o for o in bpy.data.objects if o not in vorher]
    for o in list(neu):     # der glTF-Import bringt eine Kugel ohne Material mit (Quaternius-Exporte)
        if o.type == 'MESH' and o.name.startswith('Icosphere'):
            neu.remove(o); bpy.data.objects.remove(o)
    QUELLEN.append(os.path.relpath(pfad, CC0))
    return neu


def welt(o):
    return K._welt(o)


def setze(o, W):
    K._zurueck(o, W)


def gruppe(o, name):
    return o.vertex_groups.get(name) or o.vertex_groups.new(name=name)


def gewicht_feld(o, namen):
    idx = {o.vertex_groups[n].index: n for n in namen if n in o.vertex_groups}
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


# ---------------------------------------------------------------- (1) Tracht und Gerüst
bpy.ops.wm.read_factory_settings(use_empty=True)
teile = importiere(finde('Male_Ranger.gltf'))
ARM = next(o for o in teile if o.type == 'ARMATURE'); ARM.name = 'Grak'
T = {o.name: o for o in teile if o.type == 'MESH'}
bpy.data.objects.remove(T.pop('Male_Ranger_Head_Hood'))     # Liste 4: kein Helm, barhäuptig mit Haarknoten
LEIB = T['Male_Ranger_Body']

# ---------------------------------------------------------------- (2) Kopf und Hals der Kauffigur
kopfteile = importiere(finde('Superhero_Male_FullBody.gltf'))
KOPF = next(o for o in kopfteile if o.type == 'MESH' and o.name.startswith('SuperHero'))
AUGEN = next(o for o in kopfteile if o.type == 'MESH' and o.name.startswith('Eyes'))
for o in kopfteile:
    if o not in (KOPF, AUGEN): bpy.data.objects.remove(o)
for o in (KOPF, AUGEN):
    an_ruestung(o, ARM)
# Kopf, Hals und Brustansatz behalten (der Ranger-Kragen ist vorn offen, gemessen: bei 1,57 m nur hinten Stoff). Was die Tracht
# deckt (Strahl von der Rumpfachse nach außen trifft sie innerhalb 6 cm), fällt weg; was vom breiteren Kaufkörper durch die Tracht
# stäche, rückt 4 mm unter den Stoff
from mathutils.bvhtree import BVHTree
V = welt(KOPF)
w_kh = gewicht_feld(KOPF, ('Head', 'neck_01'))
stoff_v, stoff_f = [], []
for o in (LEIB, T['Male_Ranger_Arms']):
    W_ = welt(o); n0 = len(stoff_v); stoff_v += [Vector(v) for v in W_]
    stoff_f += [tuple(n0 + i for i in p_.vertices) for p_ in o.data.polygons]
STOFF = BVHTree.FromPolygons(stoff_v, stoff_f)
weg = (V[:, 2] < 1.30) | (np.abs(V[:, 0]) > 0.20)
for i in np.nonzero(~weg & (w_kh < 0.6))[0]:
    p_ = Vector(V[i]); achse = Vector((0.0, 0.03, p_.z))
    r_ = p_ - achse; r_.z = 0.0
    if r_.length < 1e-4: continue
    loc, nor, _, dist = STOFF.find_nearest(p_)
    if loc is not None and (p_ - loc).dot(nor) > -0.004 and dist < 0.03:
        V[i] = loc - nor * 0.004
        p_ = Vector(V[i])
    treffer = STOFF.ray_cast(p_ + r_.normalized() * 0.001, r_.normalized(), 0.06)
    if treffer[0] is not None and p_.z < 1.60: weg[i] = True
setze(KOPF, V)
bm = bmesh.new(); bm.from_mesh(KOPF.data); bm.verts.ensure_lookup_table()
bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.nonzero(weg)[0]], context='VERTS')
bm.to_mesh(KOPF.data); bm.free()
KOPF.name = 'Grak_Kopf'

# ---------------------------------------------------------------- (3) Hobgoblin-Kopf
P = K.forme([KOPF, AUGEN], FORM, haut=KOPF)
V = welt(KOPF)
x, y, z = V[:, 0], V[:, 1], V[:, 2]
glatt = K._glatt
# Nase breiter (platt und breit), Brauenwulst durchgehend über der Nasenwurzel
n = P['nase']
g = np.exp(-(((x) / 0.022) ** 2 + ((y - n[1]) / 0.03) ** 2 + ((z - n[2] - 0.004) / 0.018) ** 2))
V[:, 0] += 0.35 * x * g
g = np.exp(-((x / 0.05) ** 2 + ((y - P['augen_y'] + 0.004) / 0.02) ** 2 + ((z - P['augen_z'] - 0.022) / 0.012) ** 2))
V[:, 1] -= 0.008 * g
# spitze Ohren: das Ohr steht bei 1,65–1,73 m bis 9 cm von der Mitte ab, der Schädel daneben bei 7,0–7,3 cm (am Netz gemessen);
# nur was weiter außen liegt, wird verzogen: der obere Rand nach oben, hinten und außen zur Spitze
ohr = glatt(0.074, 0.080, np.abs(x)) * glatt(-0.015, -0.005, y) * (1 - glatt(0.040, 0.050, y)) * glatt(1.640, 1.650, z) \
    * (1 - glatt(1.730, 1.740, z))
t = glatt(1.682, 1.728, z) ** 1.5
spitze = ohr * t
V[:, 2] += 0.036 * spitze
V[:, 1] += 0.022 * spitze
V[:, 0] += np.sign(x) * 0.014 * spitze
setze(KOPF, V)
OHR_SPITZE = float((V[:, 2] * (spitze > 0.5)).max()) if (spitze > 0.5).any() else 0.0
# Merkpunkte nach dem Formen
P = K.merkpunkte(KOPF, AUGEN)


def netz(name, verts, faces, farbe, knochen=None, gewichte=None):
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in verts], [], faces); me.update()
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    o['farbe'] = farbe
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


def rohr(punkte, radien, n=10):
    # Röhre entlang punkte (Liste Vector) mit Radius je Punkt; Spitze, wenn der letzte Radius 0 ist
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


# Hauer (Liste 3: lange Hauer): aus dem Unterkiefer an den Mundwinkeln vor der Oberlippe nach oben und leicht nach außen; Wurzel
# 3 mm hinter der Haut am Mundwinkel (am geformten Netz gemessen), Spitze 2 cm vor und 4 cm über der Wurzel
for s in (-1, 1):
    m_ = (np.abs(x - s * 0.022) < 0.005) & (np.abs(z - (P['mund_z'] - 0.008)) < 0.006) & (y < P['mitte'][1])
    # r2 (Prüfer r1: ferner Hauer stand neben der Wange in der Luft): Wurzel 6 mm tiefer im Kiefer, kaum nach außen, kürzer
    yb = float(y[m_].min()) + 0.006 if m_.any() else P['kinn_y'] + 0.006
    b = Vector((s * 0.020, yb, P['mund_z'] - 0.012))
    pts = [b + Vector((s * 0.003 * t_ ** 1.5, -0.020 * math.sin(t_ * math.pi / 2), 0.038 * t_)) for t_ in np.linspace(0, 1, 7)]
    vs, fs = rohr(pts, [0.0060, 0.0058, 0.0052, 0.0044, 0.0034, 0.0020, 0.0], n=8)
    netz('Grak_Hauer_%s' % ('l' if s > 0 else 'r'), vs, fs, ZAHN, 'Head')

# Haarknoten mit Kriegerzopf (Liste 3: geschoren bis auf einen Kriegerzopf): Knoten am Hinterkopf oben, Zopf bis in den Nacken
oben = P['oben']
# r2 (Prüfer r1: Kugelkette, schwarzer Keil im Schädel): Knoten auf dem Scheitel hinten, Zopf als eine Röhre mit Flechtwülsten, die
# 1 cm über der Haut des Hinterkopfs (am Netz gemessen) bis in den Nacken läuft
def hinten(zt):     # Hinterkopf: hinterste Ecke nahe der Mitte (am Scheitel ist das Netz dünn, darum breiter suchen)
    for bx, bz in ((0.015, 0.006), (0.03, 0.012), (0.05, 0.02)):
        m_ = (np.abs(x) < bx) & (np.abs(z - zt) < bz) & (y > P['mitte'][1])
        if m_.any(): return float(y[m_].max())
    return P['mitte'][1] + 0.08
zk = oben - 0.022
knoten = Vector((0.0, min(hinten(zk), P['mitte'][1] + 0.06) - 0.010, oben - 0.004))
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=1.0)
for v in bm.verts:
    v.co = Vector((v.co.x * 0.034, v.co.y * 0.036, v.co.z * 0.030)) + knoten
bahn = [Vector((0.0, hinten(zt) + 0.011, zt)) for zt in np.linspace(oben - 0.035, P['mund_z'] - 0.015, 8)]
bahn += [bahn[-1] + Vector((0.0, 0.012 * k, -0.035 * k)) for k in (1, 2, 3)]
fein = []
for i in range(len(bahn) - 1):
    for t_ in np.linspace(0, 1, 4, endpoint=False):
        fein.append(bahn[i].lerp(bahn[i + 1], t_))
fein.append(bahn[-1])
rad = [(0.016 - 0.007 * k / len(fein)) * (1.0 + 0.22 * math.cos(k * math.pi / 2)) for k in range(len(fein))]
rad[-1] = 0.004
vs, fs = rohr(fein, rad, n=10)
v0 = len(bm.verts)
for v in vs: bm.verts.new(v)
bm.verts.ensure_lookup_table()
for f in fs: bm.faces.new([bm.verts[v0 + i] for i in f])
# Flächen nach außen: je Fläche weg vom Knotenmittelpunkt bzw. von der Zopfachse (Strahlprobe: Rückseiten vorn)
bm.verts.index_update(); bm.normal_update()
umdrehen = []
for f in bm.faces:
    c = f.calc_center_median()
    if all(v.index < v0 for v in f.verts): ref = knoten
    else: ref = min(fein, key=lambda q: (q - c).length)
    if f.normal.dot(c - ref) < 0: umdrehen.append(f)
bmesh.ops.reverse_faces(bm, faces=umdrehen)
me = bpy.data.meshes.new('Grak_Zopf'); bm.to_mesh(me); bm.free()
o = bpy.data.objects.new('Grak_Zopf', me); bpy.context.scene.collection.objects.link(o); o['farbe'] = HAAR
gruppe(o, 'Head').add(range(len(me.vertices)), 1.0, 'REPLACE'); an_ruestung(o, ARM)
for p_ in me.polygons: p_.use_smooth = True

# ---------------------------------------------------------------- (4) Rüstung und Umhang
# zweites Schulterstück: das der Tracht (links) gespiegelt auf rechts
sl = T['Male_Ranger_Acc_Pauldron']
sr = sl.copy(); sr.data = sl.data.copy(); bpy.context.scene.collection.objects.link(sr); sr.name = 'Grak_Schulter_r'
me = sr.data
for v in me.vertices: v.co.x = -v.co.x
for p_ in me.polygons: p_.flip()
for gname in [g.name for g in sr.vertex_groups]:
    if gname.endswith('_l'):
        gr = sr.vertex_groups[gname]; gr.name = gname[:-2] + '_tmp'
for gname in [g.name for g in sr.vertex_groups]:
    if gname.endswith('_r'):
        sr.vertex_groups[gname].name = gname[:-2] + '_l'
for gname in [g.name for g in sr.vertex_groups]:
    if gname.endswith('_tmp'):
        sr.vertex_groups[gname].name = gname[:-4] + '_r'
an_ruestung(sr, ARM)
T['Grak_Schulter_r'] = sr

# Brustplatte (Liste 4: Halbplatte über dem Steppmantel): Schale über der Vorderseite des Rumpfs, 1,4 cm vor dem Mantel
bm = bmesh.new(); bm.from_mesh(LEIB.data); bm.verts.ensure_lookup_table(); bm.faces.ensure_lookup_table()
Mw = LEIB.matrix_world
behalte = []
for f in bm.faces:
    c = Mw @ f.calc_center_median()
    hoch = max((Mw @ v.co).z for v in f.verts)
    if 1.16 < c.z and hoch < 1.47 and c.y < 0.035 and abs(c.x) < 0.17 + 0.25 * max(0.0, 1.42 - c.z):
        behalte.append(f)
weg_f = [f for f in bm.faces if f not in set(behalte)]
bmesh.ops.delete(bm, geom=weg_f, context='FACES')
bm.normal_update()
for v in bm.verts:
    v.co = v.co + v.normal * 0.014
bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.007)
me = bpy.data.meshes.new('Grak_Brustplatte'); bm.to_mesh(me); bm.free()
pl = bpy.data.objects.new('Grak_Brustplatte', me); bpy.context.scene.collection.objects.link(pl)
pl.matrix_world = LEIB.matrix_world.copy(); pl['farbe'] = STAHL
# Gewichte vom Mantel darunter (nächste Ecke)
from mathutils.kdtree import KDTree
Vl = welt(LEIB); kd = KDTree(len(Vl))
for i, v in enumerate(Vl): kd.insert(v, i)
kd.balance()
gnamen = {g.index: g.name for g in LEIB.vertex_groups}
RUMPF = ('pelvis', 'spine_01', 'spine_02', 'spine_03')     # die Platte ist starr: nur Rumpfknochen (Hals und Schlüsselbein hoben sie)
for v in me.vertices:
    _, j, _ = kd.find(pl.matrix_world @ v.co)
    ws = {gnamen[g_.group]: g_.weight for g_ in LEIB.data.vertices[j].groups if gnamen[g_.group] in RUMPF}
    sw = sum(ws.values()) or 1.0
    if not ws: ws = {'spine_03': 1.0}
    for kn, wt in ws.items():
        gruppe(pl, kn).add([v.index], wt / sw, 'REPLACE')
an_ruestung(pl, ARM)
for p_ in me.polygons: p_.use_smooth = False

# Hauptmannsumhang (Liste 4): von den Schulterblättern bis unter die Knie, am Saum breiter, Falten; hängt am Oberkörper
nu, nv = 18, 14
verts, faces, gew = [], [], []
for j in range(nv):
    tv = j / (nv - 1)
    zz = 1.50 - tv * (1.50 - 0.42)
    breit = 0.20 + 0.15 * tv
    for i in range(nu):
        tu = i / (nu - 1) * 2 - 1
        xx = tu * breit
        # r2 (Prüfer r1: Gürtellasche in Hüfthöhe außen auf dem Umhang, Stiefel durch den Saum): unten 6 cm weiter hinten
        yy = 0.105 + 0.13 * tv + 0.05 * (tu ** 2) * (1 - tv) - 0.03 * (tu ** 2) * tv
        yy += (0.006 + 0.022 * tv) * math.cos(tu * math.pi * 3.0)
        zr = zz + (0.02 * (1 - tu ** 2) if j == 0 else 0.0)
        yy += 0.035 * math.exp(-((zr - 1.12) / 0.12) ** 2)     # über den Gürteln
        if j == 0: yy -= 0.01
        verts.append(Vector((xx, yy, zr)))
        wo = 1 - glatt(0.95, 1.30, zr)
        gew.append({'spine_03': 1 - wo, 'spine_01': wo * 0.6, 'pelvis': wo * 0.4})
for j in range(nv - 1):
    for i in range(nu - 1):
        faces.append((j * nu + i, j * nu + i + 1, (j + 1) * nu + i + 1, (j + 1) * nu + i))
um = netz('Grak_Umhang', verts, faces, UMHANG, ['spine_03', 'spine_01', 'pelvis'], gew)
mo = um.modifiers.new('dicke', 'SOLIDIFY'); mo.thickness = 0.008
bpy.context.view_layer.objects.active = um
um.modifiers.move(len(um.modifiers) - 1, 0)

# ---------------------------------------------------------------- (5) Farben: Bilder neu einfärben
def lade(pfad, kante):
    im = Image.open(pfad).convert('RGB')
    if im.size[0] != kante: im = im.resize((kante, kante), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def hsv(a):
    mx = a.max(2); mn = a.min(2); d = mx - mn
    h = np.zeros_like(mx)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    m = d > 1e-6
    i = m & (mx == r); h[i] = ((g[i] - b[i]) / d[i]) % 6
    i = m & (mx == g) & ~(mx == r); h[i] = (b[i] - r[i]) / d[i] + 2
    i = m & (mx == b) & ~(mx == r) & ~(mx == g); h[i] = (r[i] - g[i]) / d[i] + 4
    return h * 60.0, np.where(mx > 0, d / np.maximum(mx, 1e-6), 0), mx


def speichere(a, name):
    p = os.path.join(OUT, 'tex', name)
    Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8)).save(p)
    return p


def faerbe_tracht(pfad):
    a = lade(pfad, TEX)
    h, s, v = hsv(a)
    gruen = np.clip(1 - np.abs(h - 110) / 50.0, 0, 1) * np.clip((s - 0.10) / 0.12, 0, 1)
    braun = np.clip(1 - np.abs(h - 32) / 22.0, 0, 1) * np.clip((s - 0.12) / 0.1, 0, 1) * (1 - gruen)
    ziel = srgb(MANTEL)
    lum = a.mean(2, keepdims=True)
    mantel = ziel[None, None, :] * np.clip(lum / 0.30, 0.35, 1.8) ** 0.9
    leder = a * LEDER
    grau = a * 0.80
    rest = 1 - gruen[..., None] - braun[..., None]
    b = mantel * gruen[..., None] + leder * braun[..., None] + grau * rest
    return speichere(b, 'grak_tracht.png')


def faerbe_mantel(pfad):
    # r2 (Prüfer r1: Rumpf braun-ledern, Dunkelrot nur am Umhang): am Rumpf und an den Ärmeln wird auch das Braun Karmin, nur Metall
    # (ungesättigt) bleibt grau
    a = lade(pfad, TEX)
    h, s, v = hsv(a)
    farbig = np.clip((s - 0.08) / 0.12, 0, 1)[..., None]
    lum = a.mean(2, keepdims=True)
    mantel = srgb(MANTEL)[None, None, :] * np.clip(lum / 0.30, 0.35, 1.8) ** 0.9
    return speichere(mantel * farbig + a * 0.7 * (1 - farbig), 'grak_mantel.png')


HAUT_Z = srgb(HAUT)


def faerbe_haut(pfad, name, maske=None):
    a = lade(pfad, TEX if 'Superhero' not in pfad else TEX)
    lum = a.mean(2)
    med = float(np.median(lum[lum > 0.15])) if (lum > 0.15).any() else 0.5
    b = HAUT_Z[None, None, :] * np.clip(lum / med, 0.3, 1.6)[..., None]
    # leicht ins Gelbliche in den Lichtern (Haut nicht flach), ins Rote in den Tiefen
    b[..., 1] *= np.clip(0.9 + 0.15 * (lum / med - 1), 0.75, 1.1)
    if maske is not None:
        b = maske(b)
    return speichere(b, name)


def uv_je_ecke(o):
    me = o.data; uv = me.uv_layers.active.data
    vuv = np.zeros((len(me.vertices), 2))
    for l in me.loops: vuv[l.vertex_index] = uv[l.index].uv
    return vuv


def male_flaechen(b, o, gewicht, farbe, staerke=1.0, weich=3.0):
    # Gewicht je Ecke -> Flächen im UV-Bild füllen (Kriegsbemalung, Narbe)
    # r2 (Prüfer r1: Oberkante der Bemalung ein Sägezahn aus Dreiecken): Gewicht im Dreieck zwischen den Ecken verlaufen lassen
    # (vorher je Fläche einfarbig), dann weich
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


# Kopfbild: Haut, Kriegsbemalung (schwarz über den Augen), Narbe (über das linke Auge bis zur Wange)
kopf_mat = KOPF.data.materials[0]
kopf_bild = next(n_.image for n_ in kopf_mat.node_tree.nodes if n_.type == 'TEX_IMAGE' and n_.image and 'Normal' not in n_.image.name and 'Rough' not in n_.image.name)
Vk = welt(KOPF); xk, yk, zk = Vk[:, 0], Vk[:, 1], Vk[:, 2]
vorn = 1 - glatt(P['mitte'][1] - 0.005, P['mitte'][1] + 0.03, yk)
bemalung = vorn * glatt(P['augen_z'] - 0.020, P['augen_z'] - 0.010, zk) * (1 - glatt(P['augen_z'] + 0.020, P['augen_z'] + 0.026, zk)) \
    * (1 - glatt(0.062, 0.075, np.abs(xk)))
bemalung = np.clip(bemalung * 1.6, 0, 1)     # r2: scharfer Rand statt breitem Verlauf
# ausgefranster unterer Rand: drei Streifen laufen über die Wangen nach unten
for sx in (-0.042, 0.0, 0.042):
    bemalung = np.maximum(bemalung, vorn * np.exp(-((xk - sx) / 0.006) ** 2) * glatt(P['nase'][2] - 0.008, P['nase'][2] + 0.004, zk)
                          * (1 - glatt(P['augen_z'] - 0.005, P['augen_z'], zk)) * (0.0 if sx == 0.0 else 1.0))
a0, a1 = np.array([0.047, P['augen_y'] - 0.004, P['augen_z'] + 0.045]), np.array([0.022, P['augen_y'] - 0.010, P['mund_z'] + 0.004])
# r2 (Prüfer r1: Narbe nirgends zu sehen; die Strecke lag bis 1 cm vor der Stirn): Abstand nur in der Ansicht von vorn (x, z)
a0, a1 = a0[[0, 2]], a1[[0, 2]]
seg = a1 - a0; Q = Vk[:, [0, 2]]; tt = np.clip(((Q - a0) @ seg) / (seg @ seg), 0, 1)
abst = np.linalg.norm(Q - (a0 + tt[:, None] * seg), axis=1)
narbe = vorn * np.exp(-(abst / 0.0045) ** 2)
pfad_kopf = bpy.path.abspath(kopf_bild.filepath) if kopf_bild.filepath else None
if not pfad_kopf or not os.path.exists(pfad_kopf):
    pfad_kopf = finde('T_Superhero_Male_Dark.png')


def kopf_masken(b):
    b = male_flaechen(b, KOPF, bemalung, [0.035, 0.03, 0.03], 0.92, 2.0)
    b = male_flaechen(b, KOPF, narbe, [0.78, 0.52, 0.44], 0.95, 1.0)
    return b


kopf_png = faerbe_haut(pfad_kopf, 'grak_kopf.png', kopf_masken)
hand_png = faerbe_haut(finde('T_Regular_Male_Dark_BaseColor.png'), 'grak_haende.png')
tracht_png = faerbe_tracht(finde('T_Ranger_BaseColor.png'))
mantel_png = faerbe_mantel(finde('T_Ranger_BaseColor.png'))
# Augen bernstein: das braune Bild auf Bernstein drehen, Weiß dunkler (gelblich)
a = lade(finde('T_Eye_Brown.png'), 512)
h, s, v = hsv(a)
iris = np.clip((s - 0.15) / 0.15, 0, 1)[..., None]
b = a * (1 - iris) * np.array([0.78, 0.70, 0.52]) + srgb(AUGE)[None, None, :] * (a.mean(2, keepdims=True) / 0.35) * iris
augen_png = speichere(b, 'grak_augen.png')


def bild_setzen(mat, png, ohne_normal=False):
    for n_ in mat.node_tree.nodes:
        if n_.type == 'TEX_IMAGE' and n_.image:
            nm = n_.image.name
            if 'Normal' in nm or 'Rough' in nm or 'ORM' in nm: continue
            n_.image = bpy.data.images.load(png, check_existing=True)


m_kopf = kopf_mat.copy(); m_kopf.name = 'Grak_Haut_Kopf'; bild_setzen(m_kopf, kopf_png); KOPF.data.materials[0] = m_kopf
m_aug = AUGEN.data.materials[0].copy(); m_aug.name = 'Grak_Augen'; bild_setzen(m_aug, augen_png); AUGEN.data.materials[0] = m_aug
m_tracht = m_mantel = None
for o in list(T.values()):
    for i, m in enumerate(o.data.materials):
        if m is None: continue
        if m.name.startswith('MI_Regular_Male'):
            mm = bpy.data.materials.get('Grak_Haut_Haende') or m.copy(); mm.name = 'Grak_Haut_Haende'; bild_setzen(mm, hand_png)
        elif m.name.startswith('MI_Ranger') and o.name in ('Male_Ranger_Body', 'Male_Ranger_Arms'):
            if m_mantel is None:
                m_mantel = m.copy(); m_mantel.name = 'Grak_Mantel'; bild_setzen(m_mantel, mantel_png)
            mm = m_mantel
        elif m.name.startswith('MI_Ranger'):
            if m_tracht is None:
                m_tracht = m.copy(); m_tracht.name = 'Grak_Tracht'; bild_setzen(m_tracht, tracht_png)
            mm = m_tracht
        else: continue
        o.data.materials[i] = mm

# nur das Farbbild ins Spiel (der Toon-Shader liest keine Normalen, Rauheit, ORM): die übrigen Bildknoten weg, GLB kleiner
for m in bpy.data.materials:
    if not m.node_tree: continue
    for n_ in list(m.node_tree.nodes):
        if n_.type == 'TEX_IMAGE' and n_.image and any(k in n_.image.name for k in ('Normal', 'Rough', 'ORM')):
            m.node_tree.nodes.remove(n_)

# Eckfarben: Tönung je Teil (Shader: Bild mal Eckfarbe); eigene Teile einfarbig auf weißem Bild
weiss = speichere(np.ones((8, 8, 3), np.float32), 'weiss.png')
# r2 (Prüfer r1: Stiefel mittel- bis hellbraun, Schulterstücke grell weiß): Stiefel fast schwarz, Stahl dunkler
TOENUNG = {'Male_Ranger_Legs': (0.42, 0.40, 0.40), 'Male_Ranger_Feet_Boots': (0.24, 0.22, 0.21),
           'Grak_Schulter_r': (0.50, 0.51, 0.54), 'Male_Ranger_Acc_Pauldron': (0.50, 0.51, 0.54)}
for o in [o for o in bpy.data.objects if o.type == 'MESH']:
    me = o.data
    farbe = o.get('farbe')
    if farbe is not None:
        mat = bpy.data.materials.new('Grak_' + o.name.split('_')[1]); mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get('Principled BSDF')
        ti = mat.node_tree.nodes.new('ShaderNodeTexImage'); ti.image = bpy.data.images.load(weiss, check_existing=True)
        mat.node_tree.links.new(ti.outputs['Color'], bsdf.inputs['Base Color'])
        me.materials.clear(); me.materials.append(mat)
        c = tuple(lin(int(farbe)))
        if not me.uv_layers: me.uv_layers.new()
    else:
        c = TOENUNG.get(o.name, (1.0, 1.0, 1.0))
    ca = me.color_attributes.get('Col') or me.color_attributes.new('Col', 'BYTE_COLOR', 'CORNER')
    for d in ca.data: d.color = (c[0], c[1], c[2], 1.0)

# ---------------------------------------------------------------- (6) Größe: 186 cm (Gerüst und Netze gleich skaliert)
def scheitel():
    zmax = 0.0
    for o in bpy.data.objects:
        if o.type == 'MESH' and not o.name.startswith(('Grak_Zopf', 'Waffe')): zmax = max(zmax, float(welt(o)[:, 2].max()))
    return zmax


s_ = HOEHE / scheitel()
ARM.scale = (s_, s_, s_)
bpy.context.view_layer.update()
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects: o.select_set(True)
bpy.context.view_layer.objects.active = ARM
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# ---------------------------------------------------------------- (7) Großaxt in der rechten Hand (Ruhe: Schaft senkrecht, Blatt oben)
axt_teile = importiere(os.path.join(WAFFEN, 'greataxe-grak.glb'))
QUELLEN.pop()
axt = next(o for o in axt_teile if o.type == 'MESH')
for o in axt_teile:
    if o is not axt and o.type == 'MESH': bpy.data.objects.remove(o)
axt.name = 'Waffe'

# ---------------------------------------------------------------- (8) Stehen aus der UAL (Idle_Loop), auf unser Gerüst übertragen
ual = importiere(finde('UAL1_Standard.glb'))
UA = next(o for o in ual if o.type == 'ARMATURE')
quelle = bpy.data.actions['Idle_Loop']
UA.animation_data.action = quelle
f0, f1 = [int(round(v)) for v in quelle.frame_range]
reihen = [b.name for b in ARM.data.bones]     # Eltern vor Kindern
eltern = {b.name: (b.parent.name if b.parent else None) for b in ARM.data.bones}
r_uns = {b.name: b.matrix_local.to_quaternion() for b in ARM.data.bones}
r_ual = {b.name: b.matrix_local.to_quaternion() for b in UA.data.bones}
becken_ual = UA.data.bones['pelvis'].head_local.copy()
mass = ARM.data.bones['pelvis'].head_local.z / becken_ual.z
akt = bpy.data.actions.new('Stehen')
ARM.animation_data_create(); ARM.animation_data.action = akt
for pb in ARM.pose.bones: pb.rotation_mode = 'QUATERNION'
sc = bpy.context.scene
for f in range(f0, f1 + 1):
    sc.frame_set(f)
    D = {}
    for b in reihen:
        pu = UA.pose.bones.get(b)
        D[b] = (pu.matrix.to_quaternion() @ r_ual[b].inverted()) if pu else Quaternion()
    for b in reihen:
        pb = ARM.pose.bones[b]
        dp = D[eltern[b]] if eltern[b] else Quaternion()
        pb.rotation_quaternion = r_uns[b].inverted() @ (dp.inverted() @ D[b]) @ r_uns[b]
        pb.keyframe_insert('rotation_quaternion', frame=f - f0)
        if b == 'pelvis':
            d_ = UA.pose.bones['pelvis'].matrix.translation - becken_ual
            pb.location = r_uns[b].inverted() @ (d_ * mass)
            pb.keyframe_insert('location', frame=f - f0)
for o in ual: bpy.data.objects.remove(o)
for a_ in list(bpy.data.actions):
    if a_ is not akt: bpy.data.actions.remove(a_)
sc.frame_set(0)
bpy.context.view_layer.update()
# Axt an die rechte Hand: Griff (Ursprung der Waffe) in die Faust, Schaft senkrecht in der Haltung von Bild 0
hb = ARM.pose.bones['hand_r']
M_hand = ARM.matrix_world @ hb.matrix
# r2 (Prüfer r1: Faust 2–3 cm neben dem Stiel): Mitte zwischen den mittleren Fingergliedern und dem Daumen, dort liegt der Stiel
pb_ = ARM.pose.bones
faust = sum((ARM.matrix_world @ pb_[k].head for k in ('index_02_r', 'middle_02_r', 'ring_02_r', 'thumb_02_r')), Vector()) / 4
# Griff unter dem Kopf in der Faust, Stiel senkrecht neben dem Bein, Blatt in Schulterhöhe nach außen (+X der Waffe = −X der Welt,
# rechts von Grak); r2: ohne Versatz (Prüfer r1: Faust neben dem Stiel)
# r2 (gemessen: Stielende im Stiefelschaft): unten 8° nach außen gekippt
M_axt = Matrix.Translation(faust) @ Matrix.Rotation(math.radians(8), 4, 'Y') @ Matrix.Rotation(math.pi, 4, 'Z')
axt.parent = ARM; axt.parent_type = 'BONE'; axt.parent_bone = 'hand_r'
bpy.context.view_layer.update()
axt.matrix_world = M_axt

# ---------------------------------------------------------------- (9) Prüfen mit Zahlen und Ausgabe
info = {'hoehe': round(scheitel(), 3), 'ohr_spitze': round(OHR_SPITZE * s_, 3), 'quellen': sorted(set(QUELLEN)),
        'lizenz': 'Quaternius, CC0 1.0 (License_Standard.txt je Paket)', 'texturen': {}}
for o in bpy.data.objects:
    if o.type != 'MESH': continue
    imgs = []
    for m in o.data.materials:
        if m and m.node_tree:
            imgs += [n_.image.name for n_ in m.node_tree.nodes if n_.type == 'TEX_IMAGE' and n_.image]
    info['texturen'][o.name] = sorted(set(imgs))
for o in [o for o in bpy.data.objects if o.name.startswith('Icosphere')]:
    bpy.data.objects.remove(o)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, 'grak-gestalt.glb'), export_format='GLB', export_animations=True,
                          export_animation_mode='ACTIONS', export_skins=True, export_apply=False, export_yup=True,
                          export_image_format='AUTO', export_vertex_color='ACTIVE', export_all_vertex_colors=False)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, 'grak-gestalt.blend'))
json.dump(info, open(os.path.join(OUT, 'grak-gestalt-info.json'), 'w'), indent=1, ensure_ascii=False)
print('FERTIG', json.dumps(info, ensure_ascii=False))
