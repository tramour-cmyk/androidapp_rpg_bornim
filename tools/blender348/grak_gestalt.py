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
# UAL=<pfad>: dazu die Bewegungen einer zweiten Fassung, z. B. der gekauften Pro (Bestand: UAL1.glb, 120 Bewegungen, CC0) mit Death02
ual = importiere(finde('UAL1_Standard.glb'))
UA = next(o for o in ual if o.type == 'ARMATURE')
if os.environ.get('UAL'):     # nur ihre Bewegungen (gleiche Knochennamen); Gerüst und Netze wieder weg
    for o in importiere(os.environ['UAL']): bpy.data.objects.remove(o)
quelle = bpy.data.actions['Idle_Loop']
UA.animation_data.action = quelle
f0, f1 = [int(round(v)) for v in quelle.frame_range]
reihen = [b.name for b in ARM.data.bones]     # Eltern vor Kindern
eltern = {b.name: (b.parent.name if b.parent else None) for b in ARM.data.bones}
r_uns = {b.name: b.matrix_local.to_quaternion() for b in ARM.data.bones}
r_ual = {b.name: b.matrix_local.to_quaternion() for b in UA.data.bones}
becken_ual = UA.data.bones['pelvis'].head_local.copy()
mass = ARM.data.bones['pelvis'].head_local.z / becken_ual.z
ARM.animation_data_create()
for pb in ARM.pose.bones: pb.rotation_mode = 'QUATERNION'
sc = bpy.context.scene


def binde(o, a):     # Aktion a an o, mit ihrem Slot (Blender 5: eine Aktion aus einer anderen Datei, hier UAL Pro, hat den Slot
    o.animation_data.action = a     # ihres Gerüsts und bewegte UA nicht; Death02 kam so als Stehen an, „Tod stehend“, Prüfer 15:2x)
    if len(getattr(a, 'slots', [])):
        o.animation_data.action_slot = a.slots[0]


def uebertrage(q_name, z_name):     # UAL-Bewegung q_name als z_name auf unser Gerüst (Bild 0 = erstes Bild der Quelle)
    q = bpy.data.actions[q_name]; binde(UA, q)
    a0, a1 = [int(round(v)) for v in q.frame_range]
    a1 = min(a1, a0 + KURZ.get(z_name, a1))
    z = bpy.data.actions.new(z_name); z.use_fake_user = True; ARM.animation_data.action = z
    for f in range(a0, a1 + 1):
        sc.frame_set(f)
        D = {}
        for b in reihen:
            pu = UA.pose.bones.get(b)
            D[b] = (pu.matrix.to_quaternion() @ r_ual[b].inverted()) if pu else Quaternion()
        for b in reihen:
            pb = ARM.pose.bones[b]
            dp = D[eltern[b]] if eltern[b] else Quaternion()
            pb.rotation_quaternion = r_uns[b].inverted() @ (dp.inverted() @ D[b]) @ r_uns[b]
            pb.keyframe_insert('rotation_quaternion', frame=f - a0)
            if b == 'pelvis':
                d_ = UA.pose.bones['pelvis'].matrix.translation - becken_ual
                pb.location = r_uns[b].inverted() @ (d_ * mass)
                pb.keyframe_insert('location', frame=f - a0)
    return z, a1 - a0


# 348.12 Bewegungen (Liste „Grak“ 5; Übergabe 28.10., 11:55: Gehen, Hieb, Treffer, Tod mit der Zweihandhaltung): Gehen aus Walk_Loop,
# Treffer aus Hit_Chest, Tod aus Death01 (UAL, CC0); die Arme stellt (8c) je Bild an die Axt, den Hieb baut (8c) selbst
UAL_ZU = (('Walk_Loop', 'Gehen'), ('Hit_Chest', 'Treffer'), (os.environ.get('TOD_QUELLE', 'Death01'), 'Tod'))
# 348.12 nachbessern (Chef 28.10., 15:23, Archiv: „warum läuft der dann nicht mit einer Animation, sondern wird wieder über den Platz
# geschoben? … Animation beim Bewegen, beim Ausweichen … Oder in unseren 120 plus Fundus was rausnehmen“): mit UAL=<Pro> dazu Rennen
# (Jog_Fwd_Loop), Zurück (Jog_Bwd_Loop), Ausweichen (Jog_Right_Loop) und Ausweichen links (Jog_Left_Loop), je die ersten KURZ Bilder:
# ein Satz zur Seite, aufrecht (Dodge_Left/Right beginnen in tiefer Hocke; mit der Großaxt in beiden Händen fand die Suche keine Haltung
# ohne Stiel in Stiefel und Wade, grak_axtmess.py 250–400 Paare). Den Weg am Boden je Bewegung
# (Wurzelknochen root) liest WEG aus UAL1_RM.glb (dieselben Bewegungen mit Weg; ohne ihn die Füße auf der Stelle); figur.gd geht
# ihn wie bei den Kauftieren (info „weg“), so gleiten die Füße nicht
PRO_ZU = (('Jog_Fwd_Loop', 'Rennen'), ('Jog_Bwd_Loop', 'Zurück'), ('Jog_Right_Loop', 'Ausweichen'), ('Jog_Left_Loop', 'Ausweichen links'))
KURZ = {'Ausweichen': 9, 'Ausweichen links': 9}     # Bilder (24 je s): 0,38 s, 1,25 m bei Graks Maß
if os.environ.get('UAL'):
    UAL_ZU += PRO_ZU
BEWEGT = {z_: uebertrage(q_, z_) for q_, z_ in UAL_ZU}
WEG = {}     # je Bewegung, je Bild [x, z] in Graks Metern, Raum des Modells im Spiel (glTF: +Z vorn = Blender −Y)
RM = os.environ.get('UAL_RM') or (os.path.join(os.path.dirname(os.environ['UAL']), 'UAL1_RM.glb') if os.environ.get('UAL') else '')
if RM and os.path.exists(RM):
    alt_ = set(bpy.data.actions)
    rm_ = importiere(RM)
    RA = next(o for o in rm_ if o.type == 'ARMATURE')
    neu_ = {a_.name.split('.')[0]: a_ for a_ in bpy.data.actions if a_ not in alt_}
    for q_, z_ in UAL_ZU:
        if z_ not in ('Gehen',) + tuple(p_[1] for p_ in PRO_ZU) or q_ not in neu_: continue
        binde(RA, neu_[q_])
        a0, a1 = [int(round(v)) for v in neu_[q_].frame_range]
        a1 = min(a1, a0 + KURZ.get(z_, a1))
        sc.frame_set(a0); w0 = (RA.matrix_world @ RA.pose.bones['root'].matrix).translation.copy()
        WEG[z_] = []
        for f in range(a0, a1 + 1):
            sc.frame_set(f); w_ = (RA.matrix_world @ RA.pose.bones['root'].matrix).translation - w0
            WEG[z_].append([round(w_.x * mass, 4), round(-w_.y * mass, 4)])
        print('WEG %s aus %s: %d Bilder, Ende %.2f m seitlich, %.2f m vor' % (z_, q_, len(WEG[z_]), WEG[z_][-1][0], WEG[z_][-1][1]))
    for o in rm_: bpy.data.objects.remove(o)
    for a_ in neu_.values(): bpy.data.actions.remove(a_)
akt, _ = uebertrage('Idle_Loop', 'Stehen')
for o in ual: bpy.data.objects.remove(o)
for a_ in list(bpy.data.actions):
    if a_ is not akt and a_.name not in BEWEGT: bpy.data.actions.remove(a_)
sc.frame_set(0)
bpy.context.view_layer.update()

# ---------------------------------------------------------------- (8b) Großaxt in beiden Händen (Chef 28.10., 10:57: „hält er irgendwie
# komisch und anscheinend geht der Stiel auch durch seine Schulter durch“; Liste „Grak“ 4: Großaxt in beiden Händen; grak_axtmess.py
# Gestalt r2: Arme 566, Brustplatte 42, Körper 46 Paare). Haltung wie ual_lauer.py GRAK_HALT (Wache): rechte Faust vor der Brust
# rechts unter dem Kopf der Axt, der Stiel steil hinab vor den Bauch, die linke Faust 38 cm tiefer am Stiel, die Schneide nach vorn;
# Arme je Bild als zwei Glieder an die Griffe (zwei, griff, zweihand aus ual_lauer.py). ZWEIHAND=0: die alte Haltung (eine Hand)
ZWEIHAND = os.environ.get('ZWEIHAND', '1') != '0'
GRAK_HALT = ((-0.10, -0.34, 0.42), (-0.30, -0.12, 0.95), (-1.0, 0.4, -0.6), (1.0, 0.2, -0.8))
AXT_LINKS, GRIFF, HANDFL = 0.38, 0.085, 0.03
PB = ARM.pose.bones
WARN = []


def richte(b, ziel):     # Knochen b zum Punkt ziel drehen (kleinste Drehung, Rolle bleibt)
    pb = PB[b]; m = pb.matrix.copy(); h = m.translation.copy()
    q = m.col[1].xyz.normalized().rotation_difference((ziel - h).normalized())
    pb.matrix = Matrix.Translation(h) @ q.to_matrix().to_4x4() @ m.to_3x3().to_4x4()
    bpy.context.view_layer.update()


def zwei(s_, T, pol):
    S = PB['upperarm_' + s_].matrix.translation.copy(); a, b_ = PB['upperarm_' + s_].length, PB['lowerarm_' + s_].length
    if (T - S).length > (a + b_) * 0.995: WARN.append('%s %.3f' % (s_, (T - S).length - a - b_))
    d = min((T - S).length, (a + b_) * 0.995); u = (T - S).normalized()
    x = (a * a - b_ * b_ + d * d) / (2 * d); hh = math.sqrt(max(a * a - x * x, 0.0))
    p = Vector(pol); v = (p - u * p.dot(u)).normalized()
    richte('upperarm_' + s_, S + u * x + v * hh); richte('lowerarm_' + s_, S + u * d)
    pb = PB['hand_' + s_]; pb.matrix = Matrix.Translation(pb.matrix.translation) @ PB['lowerarm_' + s_].matrix.to_3x3().to_4x4()
    bpy.context.view_layer.update()


def griff(s_):     # Griffpunkt der Faust (Raum des Gerüsts)
    pb = PB['hand_' + s_]; innen = Vector((1 if s_ == 'r' else -1, 0, 0))
    return pb.matrix.translation + pb.matrix.col[1].xyz.normalized() * GRIFF + innen * HANDFL


ITER = int(os.environ.get('ITER', '5'))     # Durchgänge je Arm: Griffpunkt und Handgelenk gleichen sich an


def zweihand(R, r, pol_r, pol_l, KH=None):     # KH: Stiel im Raum der rechten Hand; dann dreht die Hand den Stiel nach r (ual_lauer.py)
    r = Vector(r).normalized()
    for _ in range(ITER):
        zwei('r', R - (griff('r') - PB['hand_r'].matrix.translation), pol_r)
    if KH is not None:
        pb = PB['lowerarm_r']; A_ = pb.matrix.col[1].xyz.normalized(); h = pb.matrix.translation.copy()
        N = (PB['hand_r'].matrix.to_3x3() @ KH).normalized(); pn, pt = N - A_ * N.dot(A_), r - A_ * r.dot(A_)
        if pn.length > 1e-4 and pt.length > 1e-4:
            w = pn.angle(pt) * (1 if A_.dot(pn.cross(pt)) >= 0 else -1)
            pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(w, 4, A_) @ Matrix.Translation(-h) @ pb.matrix
            bpy.context.view_layer.update()
        Rm = PB['hand_r'].matrix.to_3x3(); q = (Rm @ KH).normalized().rotation_difference(r)
        PB['hand_r'].matrix = Matrix.Translation(PB['hand_r'].matrix.translation) @ (q.to_matrix() @ Rm).to_4x4()
        bpy.context.view_layer.update()
    L = griff('r') - r * AXT_LINKS
    for _ in range(ITER):
        zwei('l', L - (griff('l') - PB['hand_l'].matrix.translation), pol_l)
    return (griff('l') - L).length


# Prüfer zur Vorlage Zweihand (28.10., 12:00): seitlich bei 2–3 s die linke Hand offen, der Stiel hinter den Fingerspitzen; die
# Finger spielen Idle_Loop weiter. Jetzt halten beide Fäuste die Finger von Bild 0 (dort greifen sie) in jedem Bild jeder Bewegung
FINGER = [pb.name for pb in PB if pb.name.split('_')[0] in ('thumb', 'index', 'middle', 'ring', 'pinky')]
sc.frame_set(0); bpy.context.view_layer.update()
FAUST = {b: PB[b].rotation_quaternion.copy() for b in FINGER}


def faeuste(f, nur=None):
    for b in FINGER:
        if nur and not b.endswith(nur): continue
        PB[b].rotation_quaternion = FAUST[b]; PB[b].keyframe_insert('rotation_quaternion', frame=f)


if ZWEIHAND:
    ARME = [b + s for b in ('upperarm_', 'lowerarm_', 'hand_') for s in 'lr']
    R_, r_, pr_, pl_ = GRAK_HALT
    fehl = 0.0
    for f in range(0, f1 - f0 + 1):
        sc.frame_set(f)
        bpy.context.view_layer.update()
        fehl = max(fehl, zweihand(PB['pelvis'].matrix.translation + Vector(R_), r_, pr_, pl_))
        for b in ARME:
            PB[b].keyframe_insert('rotation_quaternion', frame=f)
        faeuste(f)
    print('ZWEIHAND linke Faust höchstens %.3f m neben dem Stiel, nicht erreicht: %s' % (fehl, ', '.join(sorted(set(WARN))) or 'keine'))
    sc.frame_set(0)
    bpy.context.view_layer.update()
    r = Vector(r_).normalized()
    e = Vector((0, -1, 0)); e = (e - r * e.dot(r)).normalized()     # Schneide nach vorn (Blick −Y)
    M_axt = Matrix.Translation(ARM.matrix_world @ griff('r')) @ Matrix((e, r.cross(e), r)).transposed().to_4x4()
    axt.parent = ARM; axt.parent_type = 'BONE'; axt.parent_bone = 'hand_r'
    bpy.context.view_layer.update()
    axt.matrix_world = M_axt
# Axt an die rechte Hand: Griff (Ursprung der Waffe) in die Faust, Schaft senkrecht in der Haltung von Bild 0
hb = ARM.pose.bones['hand_r']
M_hand = ARM.matrix_world @ hb.matrix
# r2 (Prüfer r1: Faust 2–3 cm neben dem Stiel): Mitte zwischen den mittleren Fingergliedern und dem Daumen, dort liegt der Stiel
pb_ = ARM.pose.bones
faust = sum((ARM.matrix_world @ pb_[k].head for k in ('index_02_r', 'middle_02_r', 'ring_02_r', 'thumb_02_r')), Vector()) / 4
# Griff unter dem Kopf in der Faust, Stiel senkrecht neben dem Bein, Blatt in Schulterhöhe nach außen (+X der Waffe = −X der Welt,
# rechts von Grak); r2: ohne Versatz (Prüfer r1: Faust neben dem Stiel)
# r2 (gemessen: Stielende im Stiefelschaft): unten 8° nach außen gekippt
if not ZWEIHAND:
    M_axt = Matrix.Translation(faust) @ Matrix.Rotation(math.radians(8), 4, 'Y') @ Matrix.Rotation(math.pi, 4, 'Z')
    axt.parent = ARM; axt.parent_type = 'BONE'; axt.parent_bone = 'hand_r'
    bpy.context.view_layer.update()
    axt.matrix_world = M_axt

# ---------------------------------------------------------------- (8c) Gehen, Hieb, Treffer, Tod mit der Axt in beiden Händen
# Gehen, Treffer, Tod (aus (8)): Faust und Stiel folgen der Brust (spine_03) wie in Bild 0 von Stehen, die Arme je Bild als zwei
# Glieder, die Hand dreht den Stiel (KH: Stiel im Raum der rechten Hand, seit die Axt dort hängt). Tod (Vorgabe Death01; mit
# UAL=<Pro> TOD_QUELLE=Death02): erst die linke (TOD_LOS), dann die rechte Hand (TOD_LOS_R, Anteil der Bewegung) lässt los und geht
# in TOD_WEICH s in die Quelle über; die Axt fällt in TOD_FALL s und liegt flach neben ihm. Hieb: eigener Zweihandhieb von oben aus
# ual_lauer.py GRAK_HIEB (dort auf der Bibliothek entworfen und gemessen), hier auf Graks Gerüst gestellt.
# 348.12 nachbessern (grak_axtmess.py: mit 0,08/0,12 fiel die Axt durch den knienden Oberschenkel, Bild 10, 147 Paare; Fallweg geprüft:
# 0,35 900, 0,5 1668 Paare): beide Hände lassen beim tödlichen Schlag gleich los, die Axt fällt, bevor er in die Knie geht (0 Paare)
TOD_LOS, TOD_WEICH = float(os.environ.get('TOD_LOS', '0.03')), 0.25
TOD_LOS_R = float(os.environ.get('TOD_LOS_R', '0.03'))
TOD_FALL = float(os.environ.get('TOD_FALL', '0.4'))
FPS = sc.render.fps / sc.render.fps_base
GRAK_HIEB = [
    (0.0, None),
    (0.15, -4, 0, (-0.14, -0.30, 0.82), (-0.12, -0.05, 0.99), (-1.0, 0.2, -0.2), (1.0, 0.2, -0.4)),
    (0.22, -7, -3, (-0.22, -0.16, 0.98), (-0.10, 0.40, 0.91), (-1.0, 0.1, 0.1), (1.0, 0.1, 0.0)),
    (0.30, -10, -6, (-0.20, 0.02, 1.00), (0.0, 0.75, 0.66), (-1.0, 0.1, 0.3), (1.0, 0.1, 0.3)),
    (0.38, -12, -8, (-0.20, 0.04, 1.02), (0.0, 0.80, 0.60), (-1.0, 0.1, 0.3), (1.0, 0.1, 0.3)),
    (0.44, -2, 8, (-0.14, -0.36, 0.98), (-0.05, -0.05, 1.0), (-1.0, 0.1, 0.0), (1.0, 0.1, 0.0)),
    (0.50, 0, 10, (-0.07, -0.46, 0.90), (0.0, -0.25, 0.97), (-1.0, 0.0, 0.0), (1.0, 0.0, 0.0)),
    (0.54, 3, 14, (-0.05, -0.62, 0.58), (0.0, -0.80, 0.60), (-1.0, 0.0, -0.2), (1.0, 0.0, -0.2)),
    (0.56, 4, 17, (-0.05, -0.68, 0.36), (0.0, -1.0, 0.0), (-1.0, 0.0, -0.3), (1.0, 0.0, -0.3)),
    # auf Graks Gerüst (grak_axtmess.py: beim Aufschlag 0,58–0,67 s das Stielende 157 Paare in der Brustplatte, 47 im Körper; mit
    # 0,51 m Stiel hinter der rechten Faust und 0,51 m Arm liegt das Ende bei jedem Schlag gerade nach vorn in der Brust): Aufschlag
    # schräg von rechts oben nach links vorn unten, Rumpf 15° nach links gedreht; gefunden mit SUCHE (unten), frei außer an den Fäusten
    (0.58, 15, 11, (-0.14, -0.58, 0.37), (0.46, -0.75, -0.48), (-1.0, 0.0, -0.4), (1.0, 0.0, -0.4)),
    (0.66, 15, 11, (-0.14, -0.58, 0.35), (0.46, -0.74, -0.50), (-1.0, 0.0, -0.4), (1.0, 0.0, -0.4)),
    (0.72, 4, 14, (-0.08, -0.58, 0.36), (-0.1, -0.55, 0.83), (-1.0, 0.1, -0.4), (1.0, 0.1, -0.5)),
    (0.78, 3, 10, (-0.12, -0.50, 0.50), (-0.2, -0.45, 0.87), (-1.0, 0.3, -0.5), (1.0, 0.2, -0.7)),
    (0.90, None)]
GRAK_WEG = {0.0: 'weich', 0.15: 'linear', 0.22: 'linear', 0.30: 'linear', 0.38: 'an', 0.44: 'linear', 0.50: 'linear',
            0.54: 'linear', 0.56: 'linear', 0.58: 'weich', 0.66: 'weich', 0.72: 'linear', 0.78: 'weich'}


def drehe(b, achse, grad):     # Knochen b um eine Weltachse an seinem Kopf
    pb = PB[b]; h = pb.matrix.translation.copy()
    pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(grad), 4, achse) @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()


def key_alle(f):
    for pb in PB:
        pb.keyframe_insert('rotation_quaternion', frame=f); pb.keyframe_insert('location', frame=f)


AXT_KOPF = 0.80     # Kopf der Axt so weit vor der rechten Faust den Stiel entlang (waffen.py greataxe-grak)
MESS = {}


def miss(nm, f):     # Prüfwerte je Bild: linke Faust zum Stiel, Kopf der Axt über dem Boden (Welt)
    G = griff('r'); r = (PB['hand_r'].matrix.to_3x3() @ KH).normalized()
    m = MESS.setdefault(nm, {'faust': 0.0, 'axt_z': 9.0})
    m['axt_z'] = min(m['axt_z'], (ARM.matrix_world @ (G + r * AXT_KOPF)).z)
    return G, r


if ZWEIHAND:
    sc.frame_set(0); bpy.context.view_layer.update()
    KH = PB['hand_r'].matrix.to_3x3().inverted() @ Vector(r_).normalized()
    B0 = PB['spine_03'].matrix.copy(); B0i = B0.to_3x3().inverted()
    R0 = PB['pelvis'].matrix.translation + Vector(R_)
    L0 = {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB}
    LINKS = ('upperarm_l', 'lowerarm_l', 'hand_l')
    # Axt gegen Graks Netze ohne Bild (wie grak_axtmess.py; Flächen an Hand und Fingern zählen nicht): für Tod und SUCHE
    HANDK = ('hand_', 'thumb_', 'index_', 'middle_', 'ring_', 'pinky_')
    NETZE = [o for o in bpy.data.objects if o.type == 'MESH' and o is not axt]

    def knoten(o):
        gn = {g.index: g.name for g in o.vertex_groups}
        return [gn.get(max(o.data.vertices[p.vertices[0]].groups, key=lambda e: e.weight).group, '')
                if len(o.data.vertices[p.vertices[0]].groups) else '' for p in o.data.polygons]
    KN = {o.name: knoten(o) for o in NETZE}

    def baum_(o, dg):
        e = o.evaluated_get(dg); me = e.to_mesh(); bm = bmesh.new(); bm.from_mesh(me); bm.transform(o.matrix_world)
        t = BVHTree.FromBMesh(bm); bm.free(); e.to_mesh_clear(); return t

    def treffer_():
        dg = bpy.context.evaluated_depsgraph_get(); ta = baum_(axt, dg); n_ = 0
        for o in NETZE:
            kn = KN[o.name]
            n_ += sum(1 for _, j in ta.overlap(baum_(o, dg)) if not (j < len(kn) and kn[j].startswith(HANDK)))
        e = axt.evaluated_get(dg); me = e.to_mesh()     # dazu jede Ecke der Axt unter dem Boden (Tod: bis 53 cm im Boden)
        n_ += sum(1 for v in me.vertices if (axt.matrix_world @ v.co).z < 0.0); e.to_mesh_clear()
        return n_
    # Axt an einem eigenen Knochen „axt“ (Kind von root) statt an hand_r: in jeder Bewegung je Bild dorthin, wo die rechte Faust sie
    # hält (H: Axt im Raum der Hand aus Bild 0 von Stehen); im Tod lässt die Faust sie los, sie fällt und liegt flach am Boden
    # (Death02 auf Graks Maß: die Faust steckte liegend bis 14 cm im Boden, die Axt bis 53 cm)
    AW = ARM.matrix_world.copy()
    H = (AW @ PB['hand_r'].matrix).inverted() @ axt.matrix_world
    M_axt0 = axt.matrix_world.copy()
    bpy.context.view_layer.objects.active = ARM; bpy.ops.object.mode_set(mode='EDIT')
    eb = ARM.data.edit_bones.new('axt'); eb.head = (0, 0, 0); eb.tail = (0, 0.1, 0); eb.parent = ARM.data.edit_bones['root']
    bpy.ops.object.mode_set(mode='POSE')
    bpy.ops.object.mode_set(mode='OBJECT')
    PB = ARM.pose.bones; PB['axt'].rotation_mode = 'QUATERNION'
    axt.parent = ARM; axt.parent_type = 'BONE'; axt.parent_bone = 'axt'
    bpy.context.view_layer.update()
    axt.matrix_world = M_axt0
    bpy.context.view_layer.update()
    K_axt = (AW @ PB['axt'].matrix).inverted() @ axt.matrix_world     # Axt im Raum des Knochens axt (fest)

    def axt_nach(M, f):     # Knochen axt so, dass die Axt in der Welt bei M liegt; Schlüssel in Bild f
        pb = PB['axt']; pb.matrix = AW.inverted() @ M @ K_axt.inverted(); bpy.context.view_layer.update()
        pb.keyframe_insert('rotation_quaternion', frame=f); pb.keyframe_insert('location', frame=f)

    def axt_hand(f):
        axt_nach(AW @ PB['hand_r'].matrix @ H, f)

    ARM.animation_data.action = akt     # Stehen: die Axt folgt der Faust
    for f in range(0, f1 - f0 + 1):
        sc.frame_set(f); bpy.context.view_layer.update(); axt_hand(f)

    def tiefst():     # tiefster Punkt von Graks Netzen ohne Axt (Welt)
        dg = bpy.context.evaluated_depsgraph_get(); z_ = 9.0
        for o in NETZE:
            e = o.evaluated_get(dg); me = e.to_mesh()
            if len(me.vertices):
                v_ = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', v_)
                z_ = min(z_, float((np.array(o.matrix_world) @ np.c_[v_.reshape(-1, 3), np.ones(len(me.vertices))].T)[2].min()))
            e.to_mesh_clear()
        return z_

    def axt_tief():
        dg = bpy.context.evaluated_depsgraph_get(); e = axt.evaluated_get(dg); me = e.to_mesh()
        z_ = min((axt.matrix_world @ v.co).z for v in me.vertices); e.to_mesh_clear(); return z_

    # 348.12 nachbessern (grak_axtmess.py nach dem Bau mit UAL Pro: Rennen, Zurück, Ausweichen das Stielende 70–224 Paare in den
    # Oberschenkeln, die Knie heben sich bis an den Stiel): in diesen Bewegungen trägt er die Axt höher und schräger (TRAGE: rechte Faust
    # so viel höher, vor, Stiel); gefunden mit SUCHE_TRAGE=<Bewegung,…> (Axt gegen die Netze wie treffer_(), jedes Bild)
    # SUCHE_TRAGE: 0 Paare, linke Faust am Stiel (vorher Rennen 94, Zurück 135 Paare); der Stiel schräger nach links, das Ende weg von
    # den Knien; Ausweichen (Seitenlauf) ebenso
    TRAGE = {'Rennen': ((0, 0, 0), (-0.6, -0.2, 0.77)), 'Zurück': ((0, 0, 0), (-0.6, -0.2, 0.77)),
             'Ausweichen': ((0, 0, 0), (-0.6, -0.2, 0.77)), 'Ausweichen links': ((0, 0, 0), (-0.6, -0.2, 0.77))}

    def trage_treffer(z, n, dR, rT):     # Paare über jedes Bild und wie weit die linke Faust höchstens vom Stiel bleibt
        z = z.copy(); ARM.animation_data.action = z; t_ = 0; ab_ = 0.0     # auf einer Kopie: die Schlüssel der Suche bleiben nicht im Bau
        for f in range(0, n + 1):
            sc.frame_set(f); bpy.context.view_layer.update()
            B = PB['spine_03'].matrix.copy(); D = B.to_3x3() @ B0i
            ab_ = max(ab_, zweihand(B.translation + D @ (R0 + Vector(dR) - B0.translation), D @ Vector(rT), D @ Vector(pr_), D @ Vector(pl_), KH=KH))
            faeuste(f)     # wie unten im Bau: Arme und Finger mit Schlüssel (ohne zählte die Suche Arme der Quelle; Ausweichen 0 statt 283 Paare)
            for b in ARME + FINGER: PB[b].keyframe_insert('rotation_quaternion', frame=f)
            axt_hand(f); t_ += treffer_()
        bpy.data.actions.remove(z)
        return round(ab_, 2) > 0.02, t_, round(ab_, 3)
    for nm, (z, n) in BEWEGT.items():
        ARM.animation_data.action = z
        dR, rT = TRAGE.get(nm, ((0, 0, 0), r_))
        los, los_r = (TOD_LOS * n, TOD_LOS_R * n) if nm == 'Tod' else (n + 1, n + 1)
        for f in range(0, n + 1):
            sc.frame_set(f); bpy.context.view_layer.update()
            if nm == 'Tod':     # Death02 auf Graks Maß: Körper bis 20 cm im Boden; Becken so weit heben
                z_ = tiefst()
                if z_ < 0.0:
                    pb = PB['pelvis']; pb.matrix = Matrix.Translation((0, 0, -z_)) @ pb.matrix; bpy.context.view_layer.update()
                    pb.keyframe_insert('location', frame=f)
            quelle = {b: PB[b].rotation_quaternion.copy() for b in ARME + FINGER}
            B = PB['spine_03'].matrix.copy(); D = B.to_3x3() @ B0i
            ab = zweihand(B.translation + D @ (R0 + Vector(dR) - B0.translation), D @ Vector(rT), D @ Vector(pr_), D @ Vector(pl_), KH=KH)
            faeuste(f)
            for los_, seite in ((los, '_l'), (los_r, '_r')):     # Tod: erst die linke, dann die rechte Hand lässt los
                w = 0.0 if f <= los_ else min(1.0, (f - los_) / (TOD_WEICH * FPS)); w = w * w * (3 - 2 * w)
                if w > 0.0:
                    for b in ARME + FINGER:
                        if b.endswith(seite): PB[b].rotation_quaternion = PB[b].rotation_quaternion.slerp(quelle[b], w)
                    bpy.context.view_layer.update()
            for b in ARME + FINGER: PB[b].keyframe_insert('rotation_quaternion', frame=f)
            if f <= los_r:
                axt_hand(f); miss(nm, f)
            if f <= los: MESS[nm]['faust'] = max(MESS[nm]['faust'], ab)
        if nm == 'Tod':     # die Axt fällt ab dem Loslassen der Rechten in TOD_FALL s (beschleunigt) flach zu Boden, neben Grak
            fl = int(math.floor(los_r)); sc.frame_set(fl); bpy.context.view_layer.update()
            M0 = axt.matrix_world.copy()
            nf = max(1, int(round(TOD_FALL * FPS)))
            sc.frame_set(n); bpy.context.view_layer.update()
            becken = AW @ PB['pelvis'].matrix.translation; kopf = AW @ PB['Head'].matrix.translation
            lang = Vector((kopf.x - becken.x, kopf.y - becken.y, 0.0)).normalized()     # liegend: Körperachse am Boden
            quer = Vector((0, 0, 1)).cross(lang).normalized()
            if quer.dot(Vector((M0.translation.x - becken.x, M0.translation.y - becken.y, 0.0))) < 0: quer = -quer     # Seite der Axt
            mitte = Vector((becken.x, becken.y, 0.0)) + lang * 0.3
            proben = list(range(fl + nf, n + 1, 3)) + [n]
            best = None
            for seite in (1, -1):     # liegend neben ihm, Stiel längs oder schräg; frei über alle Bilder nach dem Aufschlag
                for ab_ in (0.55, 0.8, 1.05):
                    for winkel in (0, 35, -35):
                        zs = Quaternion((0, 0, 1), math.radians(winkel)) @ lang
                        R1 = Matrix((Vector((0, 0, 1)).cross(zs).normalized(), Vector((0, 0, 1)), zs)).transposed()
                        M1 = Matrix.Translation(mitte + quer * seite * ab_) @ R1.to_4x4()
                        axt_nach(M1, n); M1 = Matrix.Translation((0, 0, 0.004 - axt_tief())) @ M1
                        t_ = 0
                        for f in proben:
                            sc.frame_set(f); bpy.context.view_layer.update(); axt_nach(M1, f); t_ += treffer_()
                        # 348.12 nachbessern (grak_axtmess.py: Tod Bild 12, die fallende Axt 98 Paare im knienden Oberschenkel): auch im Fall
                        for i in range(1, nf):
                            if fl + i > n: break
                            fall = (i / nf) ** 2
                            M = Matrix.Translation(M0.translation.lerp(M1.translation, fall)) @ M0.to_quaternion().slerp(M1.to_quaternion(), fall).to_matrix().to_4x4()
                            sc.frame_set(fl + i); bpy.context.view_layer.update(); axt_nach(M, fl + i); t_ += treffer_()
                        wert = (t_, seite != 1, ab_)
                        if best is None or wert < best[0]: best = (wert, M1)
            M1 = best[1]
            for i in range(0, nf + 1):
                fall = (i / nf) ** 2
                M = Matrix.Translation(M0.translation.lerp(M1.translation, fall)) @ M0.to_quaternion().slerp(M1.to_quaternion(), fall).to_matrix().to_4x4()
                if fl + i > n: break
                sc.frame_set(fl + i); bpy.context.view_layer.update(); axt_nach(M, fl + i)
                if axt_tief() < 0.004: axt_nach(Matrix.Translation((0, 0, 0.004 - axt_tief())) @ M, fl + i)
            for f in range(fl + nf + 1, n + 1):
                sc.frame_set(f); bpy.context.view_layer.update(); axt_nach(M1, f)
            print('TOD Axt fällt ab Bild %d in %d Bildern, liegt %.2f m vom Becken, Treffer liegend %d' % (fl, nf, (M1.translation - becken).length, best[0][0]))
    if os.environ.get('SUCHE_TRAGE'):     # nach dem Bau (davor zählte treffer_ im selben Bild 0 statt 244 Paare)
        for nm in os.environ['SUCHE_TRAGE'].split(','):
            z, n = BEWEGT[nm]; erg = []
            for hoch in (0.0, 0.12, 0.24, 0.36):
                for vor in (0.0, 0.1, 0.2):
                    for rT in (r_, (-0.6, -0.2, 0.77), (-0.3, 0.3, 0.9), (-0.6, 0.3, 0.75), (-0.45, 0.15, 0.88), (-0.9, -0.1, 0.4), (0.0, 0.0, 1.0)):
                        erg.append(trage_treffer(z, n, (0, -vor, hoch), rT) + (hoch, vor, tuple(round(c, 2) for c in rT)))
            for e_ in sorted(erg)[:5]:
                print('SUCHE_TRAGE %s Faust weg %s Paare %d Faust %.3f m hoch %.2f vor %.2f Stiel %s' % ((nm,) + e_))
    # Hieb aus Bild 0 von Stehen: Rumpf DREH, VOR, Hals gleicht den Blick aus, Fäuste und Stiel je Schlüssel, Zwischenbilder gemischt
    hieb = bpy.data.actions.new('Hieb'); hieb.use_fake_user = True; ARM.animation_data.action = hieb
    ST = (0, 0) + GRAK_HALT
    HK = [(k[0], ST if k[1] is None else k[1:]) for k in GRAK_HIEB]
    weg_ = {'weich': lambda s: s * s * (3 - 2 * s), 'linear': lambda s: s, 'an': lambda s: s ** 1.3}
    nh = int(round(HK[-1][0] * FPS))
    for i in range(nh + 1):
        t = min(i / FPS, HK[-1][0])
        j = max(j for j in range(len(HK) - 1) if HK[j][0] <= t) if t < HK[-1][0] else len(HK) - 2
        (k0, A0), (k1, A1) = HK[j], HK[j + 1]
        s = weg_[GRAK_WEG[k0]](min(1.0, (t - k0) / (k1 - k0)))
        m = [a0 + (a1 - a0) * s for a0, a1 in zip(A0[:2], A1[:2])] + [Vector(a0).lerp(Vector(a1), s) for a0, a1 in zip(A0[2:], A1[2:])]
        if Vector(A0[3]).normalized().dot(Vector(A1[3]).normalized()) > -0.99:
            m[3] = Vector(A0[3]).normalized().slerp(Vector(A1[3]).normalized(), s)
        for b, (q, l) in L0.items():
            PB[b].rotation_quaternion = q; PB[b].location = l
        bpy.context.view_layer.update()
        dreh, vor, R, r, pol_r, pol_l = m
        drehe('spine_01', 'Z', dreh); drehe('spine_01', 'X', vor)
        drehe('neck_01', 'X', -vor); drehe('neck_01', 'Z', -dreh * 0.7)
        ab = zweihand(PB['pelvis'].matrix.translation + Vector(R), r, pol_r, pol_l, KH=KH)
        key_alle(i); faeuste(i); axt_hand(i)
        miss('Hieb', i); MESS['Hieb']['faust'] = max(MESS['Hieb']['faust'], ab)
        if ab > 0.02:
            Sl = PB['upperarm_l'].matrix.translation; Lz = griff('r') - (PB['hand_r'].matrix.to_3x3() @ KH).normalized() * AXT_LINKS
            print('HIEB %.2f s linke Faust %.3f m neben dem Stiel, Schulter zum Griff %.2f m, Arm %.2f m' % (i / FPS, ab, (Lz - Sl).length, PB['upperarm_l'].length + PB['lowerarm_l'].length))
    BEWEGT['Hieb'] = (hieb, nh)
    # 348.12 nachbessern (Chef 15:23: „Der Axthieb trifft auch nicht“; figur.gd schob ihn 0,6 der Strecke vor): Kopf der Axt beim
    # Aufschlag (GRAK_HIEB 0,58 s) im Raum des Modells im Spiel; figur.gd stellt ihn so weit vor das Ziel und dreht ihn so, dass er
    # dort auf dessen Rand trifft. HIEB = [Abstand Ursprung–Kopf (m), Zeit (s), Drehung (Grad, + links), Höhe (m)]
    T_AUF = 0.58
    sc.frame_set(int(round(T_AUF * FPS))); bpy.context.view_layer.update()
    # die Ecke der Axt am weitesten vor ihm (die Schneide; Messung grak_348.gd: mit dem Kopf der Axt am Rand lag die Schneide 0,28 m darin)
    dg_ = bpy.context.evaluated_depsgraph_get(); e_ = axt.evaluated_get(dg_); me_ = e_.to_mesh()
    kp = max((axt.matrix_world @ v.co for v in me_.vertices), key=lambda w: math.hypot(w.x, w.y)); e_.to_mesh_clear()
    HIEB = [round(math.hypot(kp.x, kp.y), 3), T_AUF, round(-math.degrees(math.atan2(kp.x, -kp.y)), 1), round(kp.z, 2)]
    print('HIEB Aufschlag: Schneide %.2f m vor dem Ursprung, %.0f Grad, %.2f m hoch' % (HIEB[0], -HIEB[2], HIEB[3]))
    if os.environ.get('SUCHE'):     # Aufschlag suchen: Haltungen ohne Bild durchprobieren, Axt gegen Netze wie grak_axtmess.py
        import random
        random.seed(int(os.environ['SUCHE']))
        ERG = []
        for _ in range(int(os.environ.get('SUCHE_N', '200'))):
            vor = random.uniform(0, 30); dreh = random.uniform(-25, 25)
            R = (random.uniform(-0.30, 0.15), random.uniform(-0.62, -0.35), random.uniform(0.0, 0.55))
            az, el = math.radians(random.uniform(-20, 60)), math.radians(random.uniform(0, 70))     # az > 0: nach links
            r = (math.sin(az) * math.cos(el), -math.cos(az) * math.cos(el), -math.sin(el))
            for b, (q, l) in L0.items():
                PB[b].rotation_quaternion = q; PB[b].location = l
            bpy.context.view_layer.update()
            drehe('spine_01', 'Z', dreh); drehe('spine_01', 'X', vor); drehe('neck_01', 'X', -vor); drehe('neck_01', 'Z', -dreh * 0.7)
            ab = zweihand(PB['pelvis'].matrix.translation + Vector(R), r, (-1.0, 0.0, -0.4), (1.0, 0.0, -0.4), KH=KH)
            G = griff('r'); rr = (PB['hand_r'].matrix.to_3x3() @ KH).normalized(); kp = ARM.matrix_world @ (G + rr * 0.9)
            n_ = treffer_() if ab < 0.01 else 999
            ERG.append((n_, round(ab, 3), round(vor), round(dreh), tuple(round(c, 2) for c in R), tuple(round(c, 2) for c in r),
                        round(kp.z, 2), round(-kp.y, 2)))
        for e_ in sorted(ERG)[:15]:
            print('SUCHE Paare %d Faust %.3f VOR %d DREH %d R %s r %s Axtkopf z %.2f vor %.2f' % e_)
    for nm, m in MESS.items():
        print('BEWEGUNG %s %d Bilder: linke Faust höchstens %.3f m neben dem Stiel, Kopf der Axt tiefstens %.2f m über dem Boden'
              % (nm, BEWEGT[nm][1] + 1, m['faust'], m['axt_z']))
    print('BEWEGUNG Hand mehr als 1 cm nicht erreicht: %s' % (', '.join(sorted(w_ for w_ in set(WARN) if float(w_.split()[1]) > 0.01)) or 'keine'))
    ARM.animation_data.action = akt
    sc.frame_set(0); bpy.context.view_layer.update()

# ---------------------------------------------------------------- (9) Prüfen mit Zahlen und Ausgabe
info = {'hoehe': round(scheitel(), 3), 'ohr_spitze': round(OHR_SPITZE * s_, 3), 'quellen': sorted(set(QUELLEN)),
        'lizenz': 'Quaternius, CC0 1.0 (License_Standard.txt je Paket)', 'texturen': {}}
# fürs Spiel (godot-kampf.yml legt es in hobgoblin_captain-info.json): Wurzelweg je Bewegung, Bilder je Sekunde, Aufschlag des Hiebs
info['spiel'] = {'weg': WEG, 'fps': FPS}
if ZWEIHAND:
    info['spiel']['hieb'] = HIEB
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
