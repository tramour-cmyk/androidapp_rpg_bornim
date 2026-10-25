# 348.7 (Jerry): der Kampfort im Wald (Lichtung) für Godot, nach dem alten ForestCam.kt: Lichtung mit Weg (18° nach rechts,
# 1,7 m breit, leicht geschwungen), Waldrand etwa 7 m hinter den Gegnern (Eichen, Buchen, Fichten, Büsche, Farne), dahinter
# dichter Wald, vorn links eine nahe Eiche als Rahmen. Formen der Bäume wie tools/blender348/v3/dorf.py tree() (Tom),
# Texturen aus tex.py (rinde, laub, gras, erde). Ausgabe:
#   kampfort-wald.glb   Bäume, Büsche, Steine (Meter; Rahmen der Kampflinie: Blender +X = zu den Gegnern, -Y = quer nach rechts;
#                       Ursprung = Mitte des Kampfs; in Godot um 60° gedreht, siehe kampfort.gd _setup_world)
#   wald-maske.png      Bodenmaske wie boden-maske.png (R Erde/Weg, G frei, B Schatten, A Sonnentupfen), 140 m, 6 px je m
#   wald-info.json      Maskengröße, Lage, Zahl der Dreiecke
# Aufruf: OUT=<ordner> python -I kampfort_wald.py   (vorher tex.py mit demselben OUT)
import bpy, bmesh, math, os, json, random
import numpy as np
from mathutils import Vector
from PIL import Image, ImageFilter

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
TEX = os.path.join(OUT, 'tex')
rnd = random.Random(348)

# Kamera wie kampfort.gd (FightCamera.kt): Blick aus etwa 15 m, Kampflinie 30° nach rechts; in diesem Rahmen steht sie bei
# (-0,866·d0, -0,5·d0) und blickt nach (0,866, 0,5). Sichtfeld etwa ±0,2 je Meter Entfernung, Boden ab etwa 10 m sichtbar.
D0 = 15.0
CAM = Vector((-0.866 * D0, -0.5 * D0, 0)); VIEW = Vector((0.866, 0.5, 0)); SIDE = Vector((0.5, -0.866, 0))
def view(p): d = Vector((p.x, p.y, 0)) - CAM; return d.dot(VIEW), d.dot(SIDE)     # Entfernung, seitlich (+ rechts)
def from_view(fwd, lat): return CAM + VIEW * fwd + SIDE * lat

def lin(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)
def mixc(a, b, t): t = min(1.0, max(0.0, t)); return tuple(x + (y - x) * t for x, y in zip(a, b))
def ss(a, b, x): t = min(1.0, max(0.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def h1(x, y, s=0):
    n = math.sin(x * 127.1 + y * 311.7 + s * 74.7) * 43758.5453; return n - math.floor(n)

# ---------------------------------------------------------------- der Weg: Mittellinie in Sichtkoordinaten, durch die Lichtung
# 18° nach rechts gegen die Blickrichtung, leicht geschwungen (ForestCam.kt); unter den Kämpfern hindurch
PATH = []
for k in range(0, 121):
    fwd = -5 + k * 0.75
    lat = (fwd - D0) * math.tan(math.radians(18)) * 0.55 + 1.1 * math.sin((fwd - D0) * 0.11) - 0.4
    PATH.append(from_view(fwd, lat))
def path_dist(p):
    return min((Vector((p.x, p.y, 0)) - q).length for q in PATH[::2])
PATH_W = 1.7

# ---------------------------------------------------------------- Netze: Eckfarbe (Tönung, wie dorf.py), UV je Textur
SCALE = dict(rinde=1.2, laub=1.6, feldstein=1.0)
class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.UV = []; self.M = []
P = Part()
CUR = ['rinde']
def proj_uv(p, n, m):
    s = SCALE.get(m, 1.0)
    if abs(n.z) > 0.8: return (p.x / s, p.y / s)
    if abs(n.x) > abs(n.y): return (p.y / s, p.z / s)
    return (p.x / s, p.z / s)
def add_face(pts, col, uvs=None):
    n0 = len(P.V); P.V += pts; P.F.append(tuple(range(n0, n0 + len(pts))))
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0]); nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    P.C += [col(p, nrm) if callable(col) else col for p in pts]
    P.UV.append(uvs or [proj_uv(p, nrm, CUR[0]) for p in pts]); P.M.append(CUR[0])
def cylinder(base, r, h, n, col, r2=None, lean=Vector((0, 0, 0))):
    r2 = r if r2 is None else r2; s = SCALE.get(CUR[0], 1.0); circ = 2 * math.pi * r
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + Vector((math.cos(a0) * r, math.sin(a0) * r, 0)); p1 = base + Vector((math.cos(a1) * r, math.sin(a1) * r, 0))
        q0 = base + lean + Vector((math.cos(a0) * r2, math.sin(a0) * r2, h)); q1 = base + lean + Vector((math.cos(a1) * r2, math.sin(a1) * r2, h))
        u0, u1 = circ * k / n / s, circ * (k + 1) / n / s
        add_face([p0, p1, q1, q0], col, [(0, u0), (0, u1), (h / s, u1), (h / s, u0)])
def blob(c, r, col, sub=2, squash=1.0, seed=0):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in bm.verts:
        k = 1 + 0.22 * (h1(v.co.x * 2 + seed, v.co.y * 2 + v.co.z, seed) - 0.5)
        v.co = Vector((v.co.x * r * k, v.co.y * r * k, v.co.z * r * k * squash)) + c
    bm.normal_update()
    for f in bm.faces:
        pts = [v.co.copy() for v in f.verts]
        n0 = len(P.V); P.V += pts; P.F.append(tuple(range(n0, n0 + len(pts))))
        P.C += [col(v.co, f.normal) if callable(col) else col for v in f.verts]
        P.UV.append([proj_uv(p, f.normal, CUR[0]) for p in pts]); P.M.append(CUR[0])
    bm.free()

# Licht kommt wie im Spiel von oben rechts; Tönung nur als Grundhelligkeit, Licht und Tusche macht Godot
def leaf_col(dark, light, cz, r):
    def col(v, n):
        lit = max(0.0, n.x * 0.35 - n.y * 0.45 + n.z * 0.6) * 0.65 + 0.35 * ss(cz - r, cz + r, v.z)
        return mixc(dark, light, lit)
    return col
def bark_col(k):
    return lambda q, n: tuple(x * k * (0.7 + 0.3 * ss(0, 0.6, q.z)) for x in (1.0, 1.0, 1.0))

SHADE = []          # (x, y, r) Schatten unter Kronen für die Maske
def oak(p, size=1.0, far=False, beech=False):
    """Eiche oder Buche: Stamm mit Wurzelanlauf, Krone aus Blattballen (dorf.py tree(), größer: Waldbaum)"""
    h = (4.2 + rnd.uniform(-0.6, 0.8)) * size
    with use('rinde'):
        tint = 1.15 if beech else 0.8
        cylinder(p, 0.42 * size, 0.5, 9, bark_col(tint), r2=0.3 * size)
        cylinder(p + Vector((0, 0, 0.5)), 0.3 * size, h - 0.5, 8, bark_col(tint), r2=0.18 * size,
                 lean=Vector((rnd.uniform(-0.3, 0.3), rnd.uniform(-0.3, 0.3), 0)))
        for k in range(2):                                         # zwei Äste in die Krone
            a = rnd.uniform(0, 2 * math.pi)
            cylinder(p + Vector((0, 0, h * 0.62)), 0.11 * size, 1.6 * size, 5, bark_col(tint), r2=0.05,
                     lean=Vector((math.cos(a) * 1.3, math.sin(a) * 1.3, 0)) * size)
    with use('laub'):
        cen = p + Vector((0, 0, h + 1.3 * size)); R = 2.1 * size
        dark, light = (lin(0x14260F), lin(0x9CC468)) if not beech else (lin(0x1C2A12), lin(0xB0C870))
        for k in range(7 if not far else 4):
            a = rnd.uniform(0, 2 * math.pi); d = rnd.uniform(0.8, 1.7) * size if k else 0
            q = cen + Vector((math.cos(a) * d, math.sin(a) * d, rnd.uniform(-0.9, 0.9) * size))
            rr = (rnd.uniform(1.0, 1.4) if k else 1.8) * size
            blob(q, rr, leaf_col(dark, light, cen.z, R), sub=1 if far else 2, squash=0.8, seed=k + int(p.x * 13 + p.y * 7))
    SHADE.append((p.x + 0.8, p.y + 0.5, 2.6 * size))

def spruce(p, size=1.0, far=False):
    """Fichte: dunkle Nadelstufen (dorf.py tree(), spruce), höher"""
    h = (6.0 + rnd.uniform(-0.8, 1.5)) * size
    with use('rinde'): cylinder(p, 0.24 * size, h, 7, bark_col(0.7), r2=0.06)
    with use('laub'):
        n = 7 if not far else 5
        for k in range(n):
            z = 1.1 * size + k * (h - 1.6 * size) / n
            rr = (1.9 - k * 1.6 / n) * size
            col = leaf_col(lin(0x0A160E), lin(0x46723E), z + 0.4, 0.8)
            cylinder(p + Vector((0, 0, z)), rr, 1.0 * size, 9 if not far else 7, col, r2=0.12 * size)
    SHADE.append((p.x + 0.5, p.y + 0.3, 1.9 * size))

def dead(p, size=1.0):
    """toter Baum: kahler Stamm mit drei Aststummeln"""
    h = 3.6 * size
    with use('rinde'):
        cylinder(p, 0.32 * size, h, 7, bark_col(0.95), r2=0.12 * size, lean=Vector((0.3, -0.2, 0)) * size)
        for k in range(3):
            a = rnd.uniform(0, 2 * math.pi); z = h * rnd.uniform(0.45, 0.85)
            cylinder(p + Vector((0, 0, z)), 0.08 * size, 1.2 * size, 5, bark_col(0.95), r2=0.03,
                     lean=Vector((math.cos(a), math.sin(a), 0.4)) * size)

def bush(p, size=1.0, fern=False):
    """Busch oder Farn am Waldrand"""
    with use('laub'):
        dark, light = (lin(0x1A3016), lin(0x76983E)) if fern else (lin(0x14260F), lin(0x86A85A))
        for k in range(4 if not fern else 3):
            q = p + Vector((rnd.uniform(-0.5, 0.5), rnd.uniform(-0.5, 0.5), (0.45 if not fern else 0.25) * size))
            blob(q, rnd.uniform(0.45, 0.7) * size * (0.7 if fern else 1.0), leaf_col(dark, light, p.z + 0.5, 0.6),
                 sub=1, squash=0.7 if not fern else 0.45, seed=k + int(p.x * 5 + p.y * 3))

def stone(p, size=1.0):
    with use('feldstein'):
        blob(p + Vector((0, 0, 0.08 * size)), 0.28 * size, lambda v, n: mixc(lin(0x4A4844), lin(0xCAC8BC), 0.4 + 0.5 * max(0.0, n.z)),
             sub=1, squash=0.55, seed=int(p.x * 11))

def stump(p):
    with use('rinde'):
        cylinder(p, 0.36, 0.45, 9, bark_col(0.85), r2=0.3)
        add_face([p + Vector((math.cos(a) * 0.3, math.sin(a) * 0.3, 0.45)) for a in [2 * math.pi * k / 9 for k in range(9)]],
                 lin(0x8E7A60))

class use:
    def __init__(self, m): self.m = m
    def __enter__(self): self.prev = CUR[0]; CUR[0] = self.m
    def __exit__(self, *a): CUR[0] = self.prev

# ---------------------------------------------------------------- Aufstellung
def clearing(p):
    """innerhalb der Lichtung (Kampf von a = -4,5 bis 4,5, quer ±3), gewellt"""
    a, b = p.x, -p.y
    wob = 1.0 + 0.12 * math.sin(math.atan2(b, a) * 5 + 1.3)
    return (a / 7.0) ** 2 + (b / 4.8) ** 2 < wob
def in_view(fwd, lat, margin=2.0):
    return 7 < fwd < 90 and abs(lat) < 0.22 * fwd + margin
placed = []
def free(p, d):
    return all((p - q).length > d for q in placed) and path_dist(p) > PATH_W * 0.5 + 0.6
def put(fn, p, d, *a, **k):
    placed.append(p); fn(p, *a, **k)

# vorn links die nahe Eiche als Rahmen (ForestCam.kt)
put(oak, from_view(11.5, -3.6), 2.0, size=1.15)
# Waldrand etwa 7 m hinter den Gegnern und an den Seiten der Lichtung: dicht, gewellt
for k in range(260):
    fwd = rnd.uniform(9, 85); lat = rnd.uniform(-0.24 * fwd - 3, 0.24 * fwd + 3)
    p = from_view(fwd, lat)
    if clearing(p) or not in_view(fwd, lat, 3): continue
    if fwd < D0 + 4 and abs(lat) < 0.2 * fwd - 0.6: continue           # nichts vor den Kämpfern
    far = fwd > 40
    if not free(p, 2.2 if not far else 2.8): continue
    r = rnd.random()
    if r < 0.42: put(oak, p, 0, size=rnd.uniform(0.85, 1.2), far=far, beech=rnd.random() < 0.35)
    elif r < 0.82: put(spruce, p, 0, size=rnd.uniform(0.85, 1.25), far=far)
    elif r < 0.88 and not far: put(dead, p, 0, size=rnd.uniform(0.8, 1.1))
    else: placed.append(p)
# Unterholz am Rand der Lichtung, Steine, ein Stumpf
for k in range(140):
    fwd = rnd.uniform(9, 45); lat = rnd.uniform(-0.24 * fwd - 2, 0.24 * fwd + 2)
    p = from_view(fwd, lat)
    if clearing(p) or not in_view(fwd, lat, 2): continue
    if fwd < D0 + 3 and abs(lat) < 0.2 * fwd - 0.8: continue
    if path_dist(p) < PATH_W * 0.5 + 0.3: continue
    bush(p, rnd.uniform(0.8, 1.3), fern=rnd.random() < 0.4)
for k in range(10):
    a = rnd.uniform(-5.5, 6.5); b = rnd.uniform(-4.5, 4.5)
    p = Vector((a, -b, 0))
    if path_dist(p) < PATH_W * 0.5 and rnd.random() < 0.7: continue
    if abs(a) < 4.0 and abs(b) < 2.2: continue                             # nicht unter den Füßen
    stone(p, rnd.uniform(0.6, 1.4))
stump(Vector((5.6, 3.1, 0)))

# ---------------------------------------------------------------- Netz und Ausgabe
def material(name):
    m = bpy.data.materials.get(name)
    if m: return m
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree; bsdf = nt.nodes['Principled BSDF']; bsdf.inputs['Roughness'].default_value = 1.0
    path = os.path.join(TEX, name + '.png')
    if os.path.exists(path):
        im = bpy.data.images.load(path); tn = nt.nodes.new('ShaderNodeTexImage'); tn.image = im
        nt.links.new(tn.outputs['Color'], bsdf.inputs['Base Color'])
    return m
me = bpy.data.meshes.new('Wald'); me.from_pydata([tuple(v) for v in P.V], [], P.F)
names = sorted(set(P.M)); idx = {n: k for k, n in enumerate(names)}
for n in names: me.materials.append(material(n))
ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
for k, poly in enumerate(me.polygons):
    poly.material_index = idx[P.M[k]]; poly.use_smooth = False
    for j, li in enumerate(poly.loop_indices):
        vi = me.loops[li].vertex_index; c = P.C[vi]
        ca.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
ob = bpy.data.objects.new('Wald', me); bpy.context.scene.collection.objects.link(ob)
tris = sum(len(f) - 2 for f in P.F)
print('NETZ Wald', len(P.F), 'Flaechen', tris, 'Dreiecke', names)
bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT + '/kampfort-wald.glb', export_format='GLB', use_selection=True,
                          export_vertex_color='ACTIVE', export_yup=True, export_image_format='AUTO')
print('GLB OK', os.path.getsize(OUT + '/kampfort-wald.glb'))

# Bodenmaske: Pixel (u, v) <- Godot-örtlich x = Blender x, z = -Blender y; Mitte = Kampfmitte
S = 140.0; PX = 6; N = int(S * PX)
yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
X = (xx + 0.5) / PX - S / 2; Z = (yy + 0.5) / PX - S / 2; BY = -Z
d = np.full((N, N), 1e9, np.float32)
for q in PATH:
    d = np.minimum(d, (X - q.x) ** 2 + (BY - q.y) ** 2)
d = np.sqrt(d)
rng = np.random.default_rng(348)
def noise(cells, seed):
    g = np.random.default_rng(seed).random((cells + 2, cells + 2)).astype(np.float32)
    u, v = xx / N * cells, yy / N * cells; i, j = u.astype(int), v.astype(int); fu, fv = u - i, v - j
    fu = fu * fu * (3 - 2 * fu); fv = fv * fv * (3 - 2 * fv)
    a = g[j, i] * (1 - fu) + g[j, i + 1] * fu; b = g[j + 1, i] * (1 - fu) + g[j + 1, i + 1] * fu
    return a * (1 - fv) + b * fv
nz = noise(60, 1) * 0.6 + noise(160, 2) * 0.4
R = np.clip(1.0 - (d - PATH_W * 0.5 * (0.85 + 0.3 * nz)) / 0.55, 0, 1)          # Weg mit weichem Rand
# Waldboden außerhalb der Lichtung: kahle, dunkle Erde in Flecken (Laub), Schatten
A_ = X; B_ = -BY
wob = 1.0 + 0.12 * np.sin(np.arctan2(B_, A_) * 5 + 1.3)
inside = (A_ / 7.0) ** 2 + (B_ / 4.8) ** 2
edge = np.clip((inside - wob) / 1.2, 0, 1)                                     # 0 Lichtung, 1 Wald
R = np.maximum(R, edge * np.clip((noise(40, 3) - 0.35) * 2.0, 0, 0.75))
B = edge * 0.55
for (sx, sy, sr) in SHADE:
    B = np.maximum(B, np.clip(1.0 - np.sqrt((X - sx) ** 2 + (BY - sy) ** 2) / sr, 0, 1) * 0.75)
B = np.clip(B * (0.85 + 0.3 * noise(90, 4)), 0, 1)
# Sonnentupfen: auf der Lichtung und Lücken im Wald (ForestCam: Lichtlücken #D8E4A0)
A = np.zeros((N, N), np.float32)
for k in range(70):
    cx, cy = rng.uniform(-8, 9), rng.uniform(-6, 6)
    if rng.random() < 0.35: cx, cy = rng.uniform(-20, 40), rng.uniform(-25, 25)
    r = rng.uniform(0.25, 0.9)
    A = np.maximum(A, np.clip(1.0 - np.sqrt(((X - cx) / 1.6) ** 2 + (Z - cy) ** 2) / r, 0, 1) ** 0.6)
A *= np.clip(1.0 - B * 1.2, 0, 1)
img = np.stack([R, np.zeros_like(R), B, A], 2)
Image.fromarray((img * 255 + 0.5).astype(np.uint8), 'RGBA').filter(ImageFilter.GaussianBlur(1.2)).save(OUT + '/wald-maske.png')
json.dump(dict(groesse_m=S, px_je_m=PX, dreiecke=tris, baeume=len(SHADE),
               hinweis='Maske: u = (x + S/2) / S, v = (z + S/2) / S in Godot-örtlich (Wald-Knoten); R Weg, B Schatten, A Sonnentupfen'),
          open(OUT + '/wald-info.json', 'w'), indent=1)
print('MASKE OK', N, 'px; Baeume', len(SHADE), 'Dreiecke', tris)
