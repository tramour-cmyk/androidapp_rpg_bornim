# 399.1 (Chef 28.10., 12:34: „kein Dorf, in dem ich rumlaufen kann“; Perikles: danach Grundrisse Schenke, Laden, Tempel, Aeltester):
# ein Grundriss aus dem Export von core (karten.json, art INTERIOR) fuer die Engine, erst spielbar, dann fein (LISTE-UMZUG-348.md).
# Wie alt MapRoomIso.kt: Dielenboden, Waende aus Putz mit Balken und Feldsteinsockel; die Wand zum Betrachter (Sueden) nur als
# niedrige Bruestung, damit der Raum frei im Blick steht (43); Moebel je Kachel nach dem Zeichen (MapRoom.kt), gemalte Texturen
# aus tex.py. Licht nur aus Quellen: Kamin, Kerzen, Fenster (Glas leuchtet nachts) in <id>-info.json („lichter“).
# Ausgabe <OUT>/<id>.glb (Meter, Kachel 1,16 m), <id>-info.json wie dorf.py.
# Aufruf: OUT=<ordner mit tex/> KARTE=inn KARTEN=<karten.json> python -I raum.py   (vorher tex.py mit demselben OUT)
import bpy, math, os, json, random
from mathutils import Vector

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
KARTEN = json.load(open(os.environ.get('KARTEN', ROOT + '/godot/daten/karten.json')))
ID = os.environ.get('KARTE', 'inn')
K = KARTEN['karten'][ID]
assert K.get('art') == 'INTERIOR', '%s ist kein Grundriss' % ID
ROWS = K['zeilen']; NR = len(ROWS); NC = K['breite']
TS = 116.0                                           # cm je Kachel wie dorf.py
WAND_H = 260.0                                       # Rueckwand und Seiten
VORN_H = 45.0                                        # Bruestung zum Betrachter
WALK = {c for c, t in KARTEN['kacheln'].items() if t['begehbar']}
rnd = random.Random(sum(map(ord, ID)))
def ch(c, r): return ROWS[r][c] if 0 <= r < NR and 0 <= c < NC else '#'
def tx(c): return c * TS
def ty(r): return -r * TS
def mitte(c, r): return Vector((tx(c) + TS / 2, ty(r) - TS / 2, 0))

bpy.ops.wm.read_factory_settings(use_empty=True)
def hx(c): return ((c >> 16) & 255) / 255, ((c >> 8) & 255) / 255, (c & 255) / 255
def lin(c): return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in hx(c))
SCALE = dict(putz=200, bretter=120, feldstein=160, holz=100, balken=100, stoff=100, weiss=100)
GRAIN = {'holz', 'balken', 'bretter'}
CUR = ['weiss']
class use:
    def __init__(self, m): self.m = m
    def __enter__(self): self.prev = CUR[0]; CUR[0] = self.m
    def __exit__(self, *a): CUR[0] = self.prev
class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.M = []; self.UV = []
RAUM = Part(); GLAS = Part()
LICHTER = []

def add_face(P, pts, col, m=None):
    m = m or CUR[0]; s = SCALE.get(m, 100.0)
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0])
    nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    if abs(nrm.z) > 0.8: uv = [(p.x / s, p.y / s) for p in pts]
    elif abs(nrm.x) > abs(nrm.y): uv = [(p.y / s, p.z / s) for p in pts]
    else: uv = [(p.x / s, p.z / s) for p in pts]
    n0 = len(P.V); P.V += list(pts); P.F.append(tuple(range(n0, n0 + len(pts)))); P.C += [col] * len(pts); P.UV.append(uv); P.M.append(m)

def box(lo, hi, col, P=None):
    """Quader (cm, Blender: z oben); jede Seite nach aussen gewandt"""
    P = P or RAUM
    a = Vector(lo); b = Vector(hi)
    v = [Vector((x, y, z)) for z in (a.z, b.z) for y in (a.y, b.y) for x in (a.x, b.x)]
    for q in ((0, 2, 3, 1), (4, 5, 7, 6), (0, 1, 5, 4), (2, 6, 7, 3), (0, 4, 6, 2), (1, 3, 7, 5)):
        add_face(P, [v[i] for i in q], col)

def zylinder(base, r, h, n, col, r2=None):
    r2 = r if r2 is None else r2
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + Vector((math.cos(a0) * r, math.sin(a0) * r, 0)); p1 = base + Vector((math.cos(a1) * r, math.sin(a1) * r, 0))
        q0 = base + Vector((math.cos(a0) * r2, math.sin(a0) * r2, h)); q1 = base + Vector((math.cos(a1) * r2, math.sin(a1) * r2, h))
        add_face(RAUM, [p0, p1, q1, q0], col)
        add_face(RAUM, [base + Vector((0, 0, h)), q0, q1], col)

HOLZ = lin(0x8a6a48); DUNKEL = lin(0x5a4330); PUTZ = lin(0xd8ccb4); STEIN = lin(0x9a948a); STOFF_ROT = lin(0x8e3b2c)
STOFF_BLAU = lin(0x3c5270); STOFF_GRUEN = lin(0x4d6a3e); GOLD = lin(0xc9a24a); GLAS_C = lin(0xffd9a0); WEISS = (1, 1, 1)

# ---------------------------------------------------------------- Boden, Waende
for r in range(NR):
    for c in range(NC):
        if ch(c, r) == '#': continue
        x0, y0 = tx(c), ty(r)
        with use('bretter'):
            add_face(RAUM, [Vector((x0, y0 - TS, 0)), Vector((x0 + TS, y0 - TS, 0)), Vector((x0 + TS, y0, 0)), Vector((x0, y0, 0))], HOLZ)
        if ch(c, r) == 'R':   # Teppich
            with use('stoff'): box((x0 + 4, y0 - TS + 4, 0), (x0 + TS - 4, y0 - 4, 1.2), STOFF_ROT)

def wand(c, r, h, fenster=False):
    x0, y0 = tx(c), ty(r)
    with use('feldstein'): box((x0, y0 - TS, 0), (x0 + TS, y0, min(h, 40)), STEIN)
    if h > 40:
        with use('putz'): box((x0, y0 - TS, 40), (x0 + TS, y0, h), PUTZ)
        with use('balken'):
            box((x0, y0 - TS, h - 14), (x0 + TS, y0, h), DUNKEL)
            box((x0, y0 - 14, 40), (x0 + 14, y0, h), DUNKEL)
    if fenster:   # Glas auf der Raumseite der Wand, nachts warm (gebiet.gd „Glas“)
        with use('weiss'):
            if c in (0, NC - 1):   # Seitenwand: Glas in der Ebene x
                xf = x0 + TS + 0.5 if c == 0 else x0 - 0.5
                q = [Vector((xf, y0 - TS + 28, 90)), Vector((xf, y0 - 28, 90)), Vector((xf, y0 - 28, 190)), Vector((xf, y0 - TS + 28, 190))]
                pos = [xf, y0 - TS / 2, 140]
            else:                  # Rueckwand
                yf = y0 - TS - 0.5
                q = [Vector((x0 + 28, yf, 90)), Vector((x0 + TS - 28, yf, 90)), Vector((x0 + TS - 28, yf, 190)), Vector((x0 + 28, yf, 190))]
                pos = [x0 + TS / 2, yf, 140]
            add_face(GLAS, q, GLAS_C)
        LICHTER.append(dict(art='fenster', pos=pos))

for r in range(NR):
    for c in range(NC):
        z = ch(c, r)
        if z not in '#W' and z != 'D': continue
        vorn = r == NR - 1          # Sueden: zum Betrachter
        if z == 'D': continue       # Tuer: offen
        wand(c, r, VORN_H if vorn else WAND_H, fenster=(z == 'W' and not vorn))

# ---------------------------------------------------------------- Moebel (MapRoom.kt Zeichen)
def theke(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - TS / 2, p.y - 30, 0), (p.x + TS / 2, p.y + 30, 100), HOLZ); box((p.x - TS / 2 - 2, p.y - 34, 100), (p.x + TS / 2 + 2, p.y + 34, 106), DUNKEL)
def tisch(c, r):
    p = mitte(c, r)
    with use('holz'):
        box((p.x - 45, p.y - 40, 72), (p.x + 45, p.y + 40, 78), HOLZ)
        for sx in (-38, 38):
            for sy in (-33, 33): box((p.x + sx - 4, p.y + sy - 4, 0), (p.x + sx + 4, p.y + sy + 4, 72), DUNKEL)
        zylinder(p + Vector((15, 5, 78)), 5, 12, 8, DUNKEL, r2=4)   # Krug
def bett(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 48, p.y - 54, 0), (p.x + 48, p.y + 54, 38), HOLZ); box((p.x - 50, p.y + 46, 0), (p.x + 50, p.y + 56, 80), DUNKEL)
    with use('stoff'): box((p.x - 44, p.y - 50, 38), (p.x + 44, p.y + 20, 48), STOFF_BLAU); box((p.x - 36, p.y + 24, 38), (p.x + 36, p.y + 44, 52), WEISS)
def regal(c, r):
    p = mitte(c, r); ry = ty(r) - 8 if ch(c, r - 1) == '#' else p.y + 20
    with use('holz'):
        box((p.x - 52, ry - 34, 0), (p.x + 52, ry, 200), DUNKEL)
        for h in (40, 85, 130, 175):
            box((p.x - 50, ry - 36, h), (p.x + 50, ry, h + 4), HOLZ)
            for k in range(4):
                if rnd.random() < 0.7: box((p.x - 44 + k * 24, ry - 28, h + 4), (p.x - 30 + k * 24, ry - 8, h + 18 + rnd.random() * 12), STOFF_GRUEN if k % 2 else STOFF_ROT)
def altar(c, r):
    p = mitte(c, r)
    with use('feldstein'): box((p.x - TS / 2, p.y - 36, 0), (p.x + TS / 2, p.y + 36, 95), lin(0xb8b0a0))
    with use('stoff'): box((p.x - TS / 2 + 4, p.y - 38, 95), (p.x + TS / 2 - 4, p.y + 38, 99), WEISS)
def kamin(c, r):
    p = mitte(c, r); ry = ty(r)
    with use('feldstein'):
        box((p.x - TS / 2, ry - 60, 0), (p.x + TS / 2, ry, 120), STEIN); box((p.x - TS / 2 - 6, ry - 66, 120), (p.x + TS / 2 + 6, ry, 132), STEIN)
        box((p.x - TS / 2 + 12, ry - 120, 0), (p.x + TS / 2 - 12, ry - 60, 12), lin(0x6a645a))
    with use('weiss'): box((p.x - 30, ry - 62, 12), (p.x + 30, ry - 40, 80), lin(0x14100c))
    LICHTER.append(dict(art='kamin', pos=[p.x, ry - 70, 50], reich=3.2, kraft=1.0))
def kram(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 30 + rnd.random() * 20, p.y - 20, 0), (p.x + 5, p.y + 15, 28), HOLZ)
    with use('stoff'): zylinder(p + Vector((20, -15, 0)), 14, 34, 8, lin(0xa89068), r2=8)
def pult(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 45, p.y - 28, 0), (p.x + 45, p.y + 28, 76), HOLZ); box((p.x - 48, p.y - 32, 76), (p.x + 48, p.y + 32, 82), DUNKEL)
    with use('stoff'): box((p.x - 15, p.y - 10, 82), (p.x + 15, p.y + 10, 86), lin(0xe8dcc0))
def truhe(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 38, p.y - 24, 0), (p.x + 38, p.y + 24, 46), DUNKEL)
    with use('weiss'): box((p.x - 40, p.y - 26, 20), (p.x + 40, p.y + 26, 24), GOLD)
def lehnstuhl(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 30, p.y - 30, 0), (p.x + 30, p.y + 30, 42), DUNKEL); box((p.x - 30, p.y + 20, 42), (p.x + 30, p.y + 30, 110), DUNKEL)
    with use('stoff'): box((p.x - 26, p.y - 26, 42), (p.x + 26, p.y + 18, 50), STOFF_ROT)
def wandtuch(c, r):
    p = mitte(c, r); ry = ty(r) - 4 if ch(c, r - 1) == '#' else p.y
    with use('stoff'): box((p.x - 34, ry - 3, 70), (p.x + 34, ry, 220), STOFF_BLAU)
def gestell(c, r):
    p = mitte(c, r)
    with use('holz'):
        for sx in (-44, 44): box((p.x + sx - 4, p.y - 4, 0), (p.x + sx + 4, p.y + 4, 150), DUNKEL)
        for h in (60, 120): box((p.x - 48, p.y - 3, h), (p.x + 48, p.y + 3, h + 6), HOLZ)
    with use('weiss'):
        for k in range(3): box((p.x - 30 + k * 30, p.y - 2, 70), (p.x - 27 + k * 30, p.y + 2, 140), lin(0x8a8f96))   # Klingen, Speere
def kerzen(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 40, p.y - 22, 0), (p.x + 40, p.y + 22, 70), DUNKEL)
    with use('weiss'):
        for k in range(5): zylinder(p + Vector((-30 + k * 15, rnd.uniform(-10, 10), 70)), 2.5, 10 + rnd.random() * 12, 6, lin(0xf0e6c8))
    LICHTER.append(dict(art='kerze', pos=[p.x, p.y, 95], reich=1.8, kraft=0.6))
def weihwasser(c, r):
    p = mitte(c, r)
    with use('feldstein'): zylinder(p, 18, 70, 10, lin(0xb8b0a0), r2=12); zylinder(p + Vector((0, 0, 70)), 30, 12, 12, lin(0xb8b0a0))
def kisten(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - 40, p.y - 35, 0), (p.x + 10, p.y + 15, 50), HOLZ); box((p.x - 10, p.y - 10, 0), (p.x + 38, p.y + 36, 40), HOLZ)
def bank(c, r):
    p = mitte(c, r)
    with use('holz'): box((p.x - TS / 2 + 4, p.y - 16, 40), (p.x + TS / 2 - 4, p.y + 16, 46), HOLZ); box((p.x - 50, p.y - 12, 0), (p.x - 42, p.y + 12, 40), DUNKEL); box((p.x + 42, p.y - 12, 0), (p.x + 50, p.y + 12, 40), DUNKEL)
def fass(c, r):
    p = mitte(c, r)
    with use('holz'): zylinder(p, 30, 80, 12, HOLZ, r2=30); zylinder(p + Vector((0, 0, 30)), 33, 20, 12, DUNKEL)

MOEBEL = {'K': theke, 'Y': tisch, 'B': bett, 'Q': regal, 'A': altar, 'Z': kamin, 'J': kram, 'd': pult, 'a': truhe, 's': lehnstuhl,
          'V': wandtuch, 'U': gestell, 'N': kerzen, '&': weihwasser, 'u': kisten, 'n': bank, 'b': fass}
erledigt = set()
for r in range(NR):
    for c in range(NC):
        z = ch(c, r)
        if z == 'Z' and (c - 1, r) in erledigt and ch(c - 1, r) == 'Z': continue   # zwei Kacheln Kamin: einer
        if z in MOEBEL:
            MOEBEL[z](c, r); erledigt.add((c, r))
print('MOEBEL', len(erledigt), 'LICHTER', len(LICHTER))

# ---------------------------------------------------------------- Netze, Ausgabe wie dorf.py
TEX = os.path.join(OUT, 'tex')
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
def build(P, name):
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v * 0.01) for v in P.V], [], P.F)
    names = sorted(set(P.M)); idx = {n: k for k, n in enumerate(names)}
    for n in names: me.materials.append(material(n))
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
    for k, poly in enumerate(me.polygons):
        poly.material_index = idx[P.M[k]]
        for j, li in enumerate(poly.loop_indices):
            c = P.C[me.loops[li].vertex_index]
            ca.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    print('NETZ', name, len(me.polygons), 'Flaechen', names)
    return o
build(RAUM, 'Raum_Netz')
if GLAS.F: build(GLAS, 'Raum_Glas')
walk = [[1 if ch(c, r) in WALK else 0 for c in range(NC)] for r in range(NR)]
info = dict(kachel_m=TS / 100.0, spalten=NC, zeilen=NR, ursprung=dict(spalte=0, zeile=0), begehbar=walk, karte=ROWS, innen=True,
            lichter=[dict(l, pos=[x * 0.01 for x in l['pos']]) for l in LICHTER],
            hinweis='Meter; Blender: x = Spalte * Kachel, y = -Zeile * Kachel; in glTF/Godot: x gleich, z = +Zeile * Kachel')
json.dump(info, open(os.path.join(OUT, ID + '-info.json'), 'w'), indent=0)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, ID + '.glb'), export_format='GLB', use_selection=True, export_vertex_color='ACTIVE',
                          export_yup=True, export_image_format='AUTO')
print('GLB OK', ID, os.path.getsize(os.path.join(OUT, ID + '.glb')))
