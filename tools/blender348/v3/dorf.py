# 348.5: Dorf Bornim fuer die Engine mit gemalten Texturen, ganze Karte "village" aus core/.../Story.kt,
# Haeuser wie MapTownIso.kt (Fachwerk, Putz, Bretter, Feldsteinsockel, Stroh, Schindel, Schiefer, Ziegel), Boden wie MapGround.kt.
# Netze: Dorf (Materialien je Textur aus tex.py, Eckfarbe 'albedo' = Toenung), Glas (nachts leuchtend), Wasser, Boden (eigene Maske).
# Ausgabe dorf.glb (Meter, Kachel 1,16 m; gebaut wird intern in Zentimetern), boden-maske.png (Erde, Pflaster, Schatten je Ort), dorf-info.json.
# Aufruf: OUT=<ordner> python -I dorf.py   (vorher tex.py mit demselben OUT)
import bpy, bmesh, math, os, re, json, random
import numpy as np
from mathutils import Vector, Matrix
from PIL import Image, ImageFilter

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
os.makedirs(OUT, exist_ok=True)
TS = 116.0
# 348.6: Karte aus dem Export von core (./gradlew -p core exportMaps -Pout=...; MapExport.kt), nicht mehr aus Story.kt gelesen
KARTEN = json.load(open(os.environ.get('KARTEN', ROOT + '/godot/daten/karten.json')))
K = KARTEN['karten'][os.environ.get('KARTE', 'village')]
ROWS = K['zeilen']
R0, R1, C0, C1 = 0, len(ROWS) - 1, 0, K['breite'] - 1
WALK = {c for c, t in KARTEN['kacheln'].items() if t['begehbar']} # begehbar wie World.kt (Tile(..., true))
def ch(c, r): return ROWS[r][c] if R0 <= r <= R1 and C0 <= c <= C1 else K['rand']
def tx(c): return (c - C0) * TS
def ty(r): return -(r - R0) * TS                 # Blender: Norden = +Y; Kachel (c, r) ab (tx, ty) nach +X / -Y

bpy.ops.wm.read_factory_settings(use_empty=True)
rnd = random.Random(348)
def hx(c): return ((c >> 16) & 255) / 255, ((c >> 8) & 255) / 255, (c & 255) / 255
def lin(c):
    return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in hx(c))
def mixc(a, b, t): return tuple(x + (y - x) * t for x, y in zip(a, b))
def sc(a, k): return tuple(min(1.0, x * k) for x in a)
def mix_hex(a, b, t): return int(sum(round(((a >> k) & 255) + (((b >> k) & 255) - ((a >> k) & 255)) * t) << k for k in (16, 8, 0)))
def ratio(a, b): return tuple(min(2.0, x / max(1e-4, y)) for x, y in zip(lin(a), lin(b)))
def ss(a, b, x): t = min(1.0, max(0.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def h1(x, y, s=0):
    n = (int(math.floor(x)) * 374761393 + int(math.floor(y)) * 668265263 + s * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFFFF) / float(0xFFFFFF)
def vn(x, y, s=0):
    ix, iy = math.floor(x), math.floor(y); u, v = x - ix, y - iy
    u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
    a = h1(ix, iy, s) * (1 - u) + h1(ix + 1, iy, s) * u; b = h1(ix, iy + 1, s) * (1 - u) + h1(ix + 1, iy + 1, s) * u
    return a * (1 - v) + b * v
W1 = (1.0, 1.0, 1.0)

# ---------------------------------------------------------------- Materialien: Textur und Wiederholung (cm je Bild)
SCALE = dict(putz=200, bretter=200, feldstein=200, stroh=200, schindel=200, schiefer=200, ziegel=200, holz=100, balken=100,
             rinde=120, laub=160, laub_nadel=120, stoff=100, heu=120, weiss=100, erde=232)
GRAIN = {'holz', 'balken', 'rinde'}            # Maserung laengs der laengsten Kante
CUR = ['weiss']
class use:
    def __init__(self, m): self.m = m
    def __enter__(self): self.prev = CUR[0]; CUR[0] = self.m
    def __exit__(self, *a): CUR[0] = self.prev

class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.M = []; self.UV = []; self.S = set()   # S: rund schattierte Flaechen
DORF = Part(); GLAS = Part(); WASSER = Part(); BODEN = Part()
def proj_uv(p, nrm, m):
    s = SCALE.get(m, 100.0)
    if abs(nrm.z) > 0.8: return (p.x / s, p.y / s)
    if abs(nrm.x) > abs(nrm.y): return (p.y / s, p.z / s)
    return (p.x / s, p.z / s)
def add_face(P, pts, col, uvs=None, m=None):
    m = m or CUR[0]
    n0 = len(P.V); P.V += list(pts); P.F.append(tuple(range(n0, n0 + len(pts))))
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0])
    nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    P.C += [col(p, nrm) if callable(col) else col for p in pts]
    P.UV.append(uvs if uvs else [proj_uv(p, nrm, m) for p in pts]); P.M.append(m)
def add_quad(P, a, b, c, d, col, uvs=None): add_face(P, [a, b, c, d], col, uvs)
def grid(P, o, U, V, nu, nv, col):
    for i in range(nu):
        for j in range(nv):
            a = o + U * (i / nu) + V * (j / nv); b = o + U * ((i + 1) / nu) + V * (j / nv)
            c = o + U * ((i + 1) / nu) + V * ((j + 1) / nv); d = o + U * (i / nu) + V * ((j + 1) / nv)
            add_quad(P, a, b, c, d, col)
def box(P, lo, hi, col, sub=(1, 1, 1), M=None):
    """Quader; UV aus den eigenen Achsen (Holz: Maserung laengs der laengsten Kante), dann erst gedreht"""
    lo = Vector(lo); hi = Vector(hi); s = hi - lo
    X, Y, Z = Vector((s.x, 0, 0)), Vector((0, s.y, 0)), Vector((0, 0, s.z))
    faces = [(lo, Y, X, sub[1], sub[0]), (lo + Z, X, Y, sub[0], sub[1]), (lo, X, Z, sub[0], sub[2]),
             (lo + Y, Z, X, sub[2], sub[0]), (lo, Z, Y, sub[2], sub[1]), (lo + X, Y, Z, sub[1], sub[2])]
    m = CUR[0]; sca = SCALE.get(m, 100.0); dims = [s.x, s.y, s.z]; L = max(range(3), key=lambda k: dims[k])
    for o, U, V, nu, nv in faces:
        ax = [k for k in range(3) if (U[k] != 0 or V[k] != 0)]
        if m in GRAIN and L in ax: au, av = L, [k for k in ax if k != L][0]
        else: au, av = (ax[0], ax[1]) if 2 in ax and ax[0] != 2 else (ax[0], ax[1])
        if 2 in ax and m not in GRAIN: au, av = [k for k in ax if k != 2][0], 2
        for i in range(nu):
            for j in range(nv):
                pts = [o + U * (i / nu) + V * (j / nv), o + U * ((i + 1) / nu) + V * (j / nv),
                       o + U * ((i + 1) / nu) + V * ((j + 1) / nv), o + U * (i / nu) + V * ((j + 1) / nv)]
                uvs = [(p[au] / sca, p[av] / sca) for p in pts]
                wp = [M @ p for p in pts] if M is not None else pts
                cols = [col(p, None) if callable(col) else col for p in wp]
                n0 = len(P.V); P.V += wp; P.F.append((n0, n0 + 1, n0 + 2, n0 + 3)); P.C += cols; P.UV.append(uvs); P.M.append(m)
def cylinder(P, base, r, h, n, col, cap=True, r2=None):
    r2 = r if r2 is None else r2; m = CUR[0]; sca = SCALE.get(m, 100.0); circ = 2 * math.pi * r
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + Vector((math.cos(a0) * r, math.sin(a0) * r, 0)); p1 = base + Vector((math.cos(a1) * r, math.sin(a1) * r, 0))
        q0 = base + Vector((math.cos(a0) * r2, math.sin(a0) * r2, h)); q1 = base + Vector((math.cos(a1) * r2, math.sin(a1) * r2, h))
        u0, u1 = circ * k / n / sca, circ * (k + 1) / n / sca
        if m in GRAIN: uvs = [(0, u0), (0, u1), (h / sca, u1), (h / sca, u0)]
        else: uvs = [(u0, 0), (u1, 0), (u1, h / sca), (u0, h / sca)]
        add_face(P, [p0, p1, q1, q0], col, uvs)
        if cap: add_face(P, [base + Vector((0, 0, h)), q0, q1], col)
def blob(P, c, r, col, sub=2, squash=1.0, seed=0, smooth=False, bump=0.22):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in bm.verts:
        k = 1 + bump * (vn(v.co.x * 2 + seed, v.co.y * 2 + v.co.z, seed) - 0.5)
        v.co = Vector((v.co.x * r * k, v.co.y * r * k, v.co.z * r * k * squash)) + c
    bm.normal_update()
    if smooth:                      # 348.6 (Befund 6, Kronen wuerfelig): gemeinsame Ecken, rund schattiert, Farbe nach der Eckennormale
        bm.verts.index_update(); n0 = len(P.V)
        P.V += [v.co.copy() for v in bm.verts]
        P.C += [col(v.co, v.normal) if callable(col) else col for v in bm.verts]
        for f in bm.faces:
            P.S.add(len(P.F)); P.F.append(tuple(n0 + v.index for v in f.verts))
            P.UV.append([proj_uv(v.co, f.normal, CUR[0]) for v in f.verts]); P.M.append(CUR[0])
        bm.free(); return
    for f in bm.faces:
        pts = [v.co.copy() for v in f.verts]
        n0 = len(P.V); P.V += pts; P.F.append(tuple(range(n0, n0 + len(pts))))
        P.C += [col(v.co, f.normal) if callable(col) else col for v in f.verts]
        P.UV.append([proj_uv(p, f.normal, CUR[0]) for p in pts]); P.M.append(CUR[0])
    bm.free()

# ---------------------------------------------------------------- Boden: Netz (Hoehe am Wasser) und Maske 16 px je Kachel
NC, NR = C1 - C0 + 1, R1 - R0 + 1
WATER = set('~h')                    # unter der Bruecke fliesst der Fluss weiter
def hv(ix, iy, s):
    n = (ix * 374761393 + iy * 668265263 + s * 1442695041) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFFFF) / float(0xFFFFFF)
def vnn(X, Y, cell, s):
    fx, fy = X / cell, Y / cell; ix, iy = np.floor(fx).astype(np.int64), np.floor(fy).astype(np.int64)
    u, v = fx - ix, fy - iy; u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
    return (hv(ix, iy, s) * (1 - u) + hv(ix + 1, iy, s) * u) * (1 - v) + (hv(ix, iy + 1, s) * (1 - u) + hv(ix + 1, iy + 1, s) * u) * v
WIND = np.array([[1.0 if ROWS[min(max(r, R0), R1)][min(max(c, C0), C1)] in WATER else 0.0 for c in range(C0, C1 + 1)] for r in range(R0, R1 + 1)])
def wfield(X, Y):
    """348.6 (Befund 4b): Wasser wie MapGround.waterAt: Kacheln zwischen den Mitten weich verbunden (am Rand fortgesetzt),
    plus Rauschen (fbm 48 Bildpunkte = 0,75 Kachel, 3 Lagen, Staerke 0,55); ueber 0,5 ist Wasser. X, Y in Kacheln."""
    X = np.asarray(X, np.float64); Y = np.asarray(Y, np.float64)
    fx, fy = X - 0.5, Y - 0.5; ix, iy = np.floor(fx).astype(int), np.floor(fy).astype(int)
    u, v = fx - ix, fy - iy; u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
    def at(i, j): return WIND[np.clip(j, 0, NR - 1), np.clip(i, 0, NC - 1)]
    f = (at(ix, iy) * (1 - u) + at(ix + 1, iy) * u) * (1 - v) + (at(ix, iy + 1) * (1 - u) + at(ix + 1, iy + 1) * u) * v
    n = (vnn(X, Y, 0.75, 11) + 0.5 * vnn(X, Y, 0.375, 28) + 0.25 * vnn(X, Y, 0.1875, 45)) / 1.75
    return f + (n - 0.5) * 0.55
def vh(X, Y):
    """Hoehe des Bodens: Boeschung zum Flussbett (-34 cm), Wasserspiegel -10 cm liegt bei w = 0,5"""
    return -34.0 * ss(0.4, 0.66, float(wfield(X, Y)))
# am Wasser feiner (Viertelkacheln, Ufer folgt dem Rauschen), sonst halbe Kacheln; flach, wo es grob wird: keine Risse
# 348.6 (Runde 2a: Wasser am Ostrand lag als Platte auf der Wiese): Boden und Wasser 12 Kacheln ueber den Rand; bei 4 stand die
# Kante zur tieferen Wiese als schwarze Stufe im Bild (Kamera sieht weiter als der Waldring)
def chk(c, r): return ROWS[min(max(r, R0), R1)][min(max(c, C0), C1)]     # am Rand fortgesetzt wie wfield
AUS = 12
near = {(c, r) for r in range(R0 - AUS, R1 + AUS + 1) for c in range(C0 - AUS, C1 + AUS + 1)
        if any(chk(c + dc, r + dr) in WATER for dc in (-2, -1, 0, 1, 2) for dr in (-2, -1, 0, 1, 2))}
for r in range(R0 - AUS, R1 + AUS + 1):
    for c in range(C0 - AUS, C1 + AUS + 1):
        n = 4 if (c, r) in near else 2
        for j in range(n):
            for i in range(n):
                pts = []
                for (ex, ey) in ((i, j + 1), (i + 1, j + 1), (i + 1, j), (i, j)):
                    X, Y = c - C0 + ex / n, r - R0 + ey / n
                    pts.append(Vector((tx(C0) + X * TS, ty(R0) - Y * TS, vh(X, Y) if n == 4 else 0.0)))
                add_face(BODEN, pts, W1, [(p.x / (NC * TS), -p.y / (NR * TS)) for p in pts], m='boden')
# Maske
PX = 16; MW, MH = NC * PX, NR * PX
yy, xx = np.mgrid[0:MH, 0:MW].astype(np.float32); X = (xx + 0.5) / PX; Y = (yy + 0.5) / PX          # in Kacheln
def npn(cells, seed):
    rng = np.random.default_rng(seed); g = rng.random((int(NR * cells) + 3, int(NC * cells) + 3)).astype(np.float32)
    u, v = X * cells, Y * cells; i, j = np.floor(u).astype(int), np.floor(v).astype(int); fu, fv = u - i, v - j
    fu = fu * fu * (3 - 2 * fu); fv = fv * fv * (3 - 2 * fv)
    return (g[j, i] * (1 - fu) + g[j, i + 1] * fu) * (1 - fv) + (g[j + 1, i] * (1 - fu) + g[j + 1, i + 1] * fu) * fv
def fbm2(cells, seed): return 0.5 * npn(cells, seed) + 0.3 * npn(cells * 2, seed + 1) + 0.2 * npn(cells * 4, seed + 2)
def tilemask(chars):
    m = np.zeros((NR, NC), np.float32)
    for r in range(NR):
        for c in range(NC):
            if ch(C0 + c, R0 + r) in chars: m[r, c] = 1
    return m
def up(m, blur):
    im = Image.fromarray((m * 255).astype(np.uint8)).resize((MW, MH), Image.NEAREST)
    if blur: im = im.filter(ImageFilter.GaussianBlur(blur))
    return np.asarray(im).astype(np.float32) / 255
def sst(a, b, x): t = np.clip((x - a) / (b - a), 0, 1); return t * t * (3 - 2 * t)
# Weg: Mittelpunkte benachbarter Wegkacheln verbunden, Band halbe Breite 0,52 Kachel, gewellt (MapGround.kt:435)
pathc = [(c + 0.5, r + 0.5) for r in range(NR) for c in range(NC) if ch(C0 + c, R0 + r) in '=hDS!']
pset = set((int(a), int(b)) for a, b in pathc)
dist = np.full((MH, MW), 99.0, np.float32)
for (a, b) in pathc:
    for (dc, dr) in ((1, 0), (0, 1), (0, 0)):
        if dc == dr == 0 or (int(a) + dc, int(b) + dr) in pset:
            ax_, ay_, bx_, by_ = a, b, a + dc, b + dr
            vx, vy = bx_ - ax_, by_ - ay_; L2 = max(vx * vx + vy * vy, 1e-6)
            t = np.clip(((X - ax_) * vx + (Y - ay_) * vy) / L2, 0, 1)
            dist = np.minimum(dist, np.hypot(X - (ax_ + t * vx), Y - (ay_ + t * vy)))
# Tueren bekommen den Weg nicht: D ist Tuer (in der Hauswand); nur der Weg vor der Tuer
wob = (fbm2(1.3, 7) - 0.5) * 0.28
path = 1 - sst(0.46 + wob, 0.56 + wob, dist)
cob = up(tilemask('owmnl'), 0)
cob = sst(0.45, 0.6, up(tilemask('owmnl'), 6) + (fbm2(3.5, 8) - 0.5) * 0.35)
house = up(tilemask('^#DWM'), 0)
yard = sst(0.25, 0.5, up(tilemask('^#DWMpby'), 10) + (fbm2(2.5, 9) - 0.5) * 0.4) * (1 - house)
bare = sst(0.66, 0.78, fbm2(0.7, 10)) * 0.8
field = up(tilemask('cv'), 3)
WF = wfield(X, Y).astype(np.float32)                     # Wasser je Bildpunkt (Alpha der Maske: Tiefe fuer wasser.gdshader)
bank = sst(0.22, 0.4, WF)                                 # alt: Schlamm ab 0,36 (MUD), am Ufer dunkle Erde (Helfer: Gras stiess hart ans Wasser)
earth = np.clip(np.maximum.reduce([path, yard * 0.85, bare, field, bank]), 0, 1) * (1 - cob)
shade = up(tilemask('T'), 14) * 0.6 + 0.25 * sst(0.55, 0.8, fbm2(1.5, 11))
shade = np.maximum(shade, sst(0.3, 0.5, WF) * 0.95)
mask = np.stack([earth, cob, np.clip(shade, 0, 1), np.clip(WF, 0, 1)], 2)
Image.fromarray((mask * 255).astype(np.uint8)).save(OUT + '/boden-maske.png')

# Wasser: Flaeche knapp unter dem Ufer, auch eine Kachel um den Fluss (das Ufer folgt dem Rauschen, der Boden deckt den Rest)
for r in range(R0 - AUS, R1 + AUS + 1):         # Helfer: Fluss lief am Kartenrand spitz aus; jetzt unter dem Waldring weiter
    for c in range(C0 - AUS, C1 + AUS + 1):
        if not any(chk(c + dc, r + dr) in WATER for dc in (-1, 0, 1) for dr in (-1, 0, 1)): continue
        x0, y0 = tx(c) - 2, ty(r) - TS - 2
        add_face(WASSER, [Vector((x0, y0, -10)), Vector((x0 + TS + 4, y0, -10)), Vector((x0 + TS + 4, y0 + TS + 4, -10)), Vector((x0, y0 + TS + 4, -10))],
                 W1, [((x0) / 200, y0 / 200), ((x0 + TS) / 200, y0 / 200), ((x0 + TS) / 200, (y0 + TS) / 200), (x0 / 200, (y0 + TS) / 200)], m='wasser')
# Schilf wie MapWoodIso.reeds/objects (D6.3, 27.5): am fernen Ufer (Land im Westen oder Norden), drei von vier Kacheln, nicht an der Bruecke;
# Halme dunkel unten, oliv, Spitzen strohfarben, Art 1 mit Rohrkolben; Material 'bluete_…': ohne Tusche wie die Blueten (sonst schwarze Striche)
REED_G = (lin(0x5A6E3A), lin(0x6A7440)); REED_STRAW = lin(0xA89A62); REED_DARK = lin(0x2A3420)
def reeds(c, r):
    west, north = ch(c - 1, r) != '~', ch(c, r - 1) != '~'
    v = int(h1(c, r, 40) * 6); kind = v % 3; rr = random.Random(1020 + v * 37 + c * 7 + r)
    ci = -0.82 if west else -0.3 - h1(c, r, 41) * 0.4; cj = -0.82 if north else -0.3 - h1(c, r, 42) * 0.4
    base = Vector((tx(c) + (1 + ci) * TS, ty(r) - (1 + cj) * TS, -10))
    with use('bluete_schilf'):
        for b in range(26 + (v // 3) * 10 + kind * 4):
            rad = math.sqrt(rr.random()) * 0.14 * TS; a = rr.random() * 2 * math.pi
            p0 = base + Vector((math.cos(a) * rad, -math.sin(a) * rad * 0.8, 0))
            hgt = 80 + rr.random() * 70; lean = (0.03 + rr.random() * 0.12) * TS; la = a + (rr.random() - 0.5) * 0.8
            d = Vector((math.cos(la), -math.sin(la), 0)); side = Vector((-d.y, d.x, 0)) * 1.0
            pts = [p0 + d * lean * f * f + Vector((0, 0, f * hgt)) for f in (0.0, 0.35, 0.7, 1.0)]
            ws = (1.0, 0.8, 0.55, 0.0)
            for k in range(3):
                f0, f1 = k / 3, (k + 1) / 3
                c0 = mixc(mixc(REED_DARK, REED_G[kind == 2], min(1.0, f0 * 2.2)), REED_STRAW, min(0.8, max(0.0, (f0 - 0.6) * 2)))
                c1 = mixc(mixc(REED_DARK, REED_G[kind == 2], min(1.0, f1 * 2.2)), REED_STRAW, min(0.8, max(0.0, (f1 - 0.6) * 2)))
                q = [pts[k] - side * ws[k], pts[k] + side * ws[k], pts[k + 1] + side * ws[k + 1], pts[k + 1] - side * ws[k + 1]]
                n0 = len(DORF.V); DORF.V += q; DORF.F.append((n0, n0 + 1, n0 + 2, n0 + 3)); DORF.C += [c0, c0, c1, c1]
                DORF.UV.append([(0, 0)] * 4); DORF.M.append(CUR[0])
            if kind == 1 and b % 4 == 0:                                       # Rohrkolben: brauner Kolben unter der Spitze
                cylinder(DORF, p0 + d * lean * 0.5 + Vector((0, 0, hgt * 0.7)), 1.6, 12, 5, lin(0x5A3A22))
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        if ch(c, r) != '~' or h1(c, r, 39) < 0.25: continue
        if not (ch(c - 1, r) != '~' or ch(c, r - 1) != '~'): continue
        if any(ch(c + d, r) == 'h' or ch(c, r + d) == 'h' for d in (-1, 0, 1)): continue
        reeds(c, r)

# ---------------------------------------------------------------- Haeuser (MapTownIso.kt)
LOOKS = [dict(plaster=0x8C8270, timber=0x3E2E22, thatch=0x7A6C4E, moss=0.55, stoneTo=0.0),
         dict(plaster=0x82745A, timber=0x2C2018, thatch=0x6A5C42, moss=0.3, stoneTo=0.0),
         dict(plaster=0x86807A, timber=0x3A2C22, thatch=0x5E5644, moss=0.75, stoneTo=120.0)]
STYLE = {}
for k_, h_ in enumerate(K['haeuser']):
    STYLE[(h_['x'], h_['y'])] = (h_['dach'], h_['wand'], k_ % 3, h_.get('merkmal', 'NONE'))
def comps():
    seen = set(); out = []
    for r in range(R0, R1 + 1):
        for c in range(C0, C1 + 1):
            if ch(c, r) not in '^#DWM' or (c, r) in seen: continue
            st = [(c, r)]; seen.add((c, r)); cells = []
            while st:
                q = st.pop(); cells.append(q)
                for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    n = (q[0] + d[0], q[1] + d[1])
                    if n not in seen and ch(*n) in '^#DWM': seen.add(n); st.append(n)
            out.append(cells)
    return out
LIGHTS = []
def stone_tint(p, n, k=1.0):
    """Feldstein: am Fuss Moos und Feuchte"""
    g = ss(35, 0, p.z) * (0.4 + 0.6 * vn(p.x / 40 + p.y / 40, p.z / 20, 10))
    return sc(mixc(W1, (0.75, 0.95, 0.55), g * 0.8), k * (0.8 + 0.2 * ss(0, 60, p.z)))
def arch_pts(cx, hw, z0, spring, rise, n=12):
    """Rundbogen (Rechteck, oben Halbellipse) in (x, z), gegen den Uhrzeigersinn von Sueden gesehen; konvex"""
    return [(cx - hw, z0), (cx + hw, z0)] + [(cx + hw * math.cos(math.pi * k / n), spring + rise * math.sin(math.pi * k / n)) for k in range(n + 1)]
def clip(poly, cp):
    """Vieleck an einem konvexen Vieleck beschneiden (Sutherland-Hodgman), beide in (x, z)"""
    out = list(poly)
    for i in range(len(cp)):
        if not out: break
        a, b = cp[i], cp[(i + 1) % len(cp)]
        def sd(p): return (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0])
        inp, out = out, []
        for j in range(len(inp)):
            p, q = inp[j], inp[(j + 1) % len(inp)]
            dp, dq = sd(p), sd(q)
            if (dp >= 0) != (dq >= 0):
                t = dp / (dp - dq); out.append((p[0] + (q[0] - p[0]) * t, p[1] + (q[1] - p[1]) * t))
            if dq >= 0: out.append(q)
    return out
def front_face(P, pts, y, col):
    """Flaeche in der Ebene y (Front nach Sueden), pts in (x, z) gegen den Uhrzeigersinn"""
    if len(pts) >= 3: add_face(P, [Vector((x, y, z)) for x, z in pts], col)
U = 1.733                                                   # cm je Hoeheneinheit in MapTownIso.kt (Traufe 150 = 2,6 m)
def arch_window(cx, yf, c):
    """Kirchenfenster wie MapTownIso.archWindow: tiefe Laibung unter Rundbogen, Bleiglas in Rauten (nachts Kerzenlicht)"""
    hw, z0, spring, rise = 0.16 * TS, 46 * U, 104 * U, 22 * U
    inner = arch_pts(cx, hw - 0.04 * TS, 51 * U, spring, rise - 5 * U)
    with use('weiss'): front_face(DORF, arch_pts(cx, hw, z0, spring, rise), yf - 1, lin(0x18161A))     # Laibung, dahinter Blei
    with use('feldstein'): box(DORF, (cx - hw - 6, yf - 10, z0 - 9), (cx + hw + 6, yf, z0), lambda p, n: sc(W1, 0.9))  # Sohlbank
    with use('weiss'):
        for i in range(-4, 8):
            for j in range(-6, 6):
                e = 0.09                                                                # Bleisteg (alt 0,05: am Handy Krümel)
                uv = [(i + e, j + e), (i + e, j + 1 - e), (i + 1 - e, j + 1 - e), (i + 1 - e, j + e)]   # (u, v) -> (a, b) spiegelt
                pts = [(cx + (u + v) / 2 * TS / 9, (90 + 22 * (u - v) / 2) * U) for u, v in uv]
                pane = clip(pts, inner)
                if len(pane) < 3: continue
                k = 0.9 + 0.2 * h1(i, j, 71)
                front_face(GLAS, pane, yf - 3, lambda p, n, k=k: sc(mixc(lin(0x1A2028), lin(0x4A5666), min(1.0, max(0.0, (p.z / U - 51) / 90)) * 0.7), k))
    LIGHTS.append(dict(art='fenster', pos=[cx, yf - 30, spring - 20]))
def facing(pts, want):
    """Flaeche so herum, dass ihre Normale zu want zeigt (Licht im Toon-Shader)"""
    n = (pts[1] - pts[0]).cross(pts[-1] - pts[0])
    return pts if n.dot(want) >= 0 else pts[::-1]
def arch_door(cx, yf, c):
    """Kirchentuer wie MapTownIso.archDoor: zwei Fluegel aus dunkler Eiche unter einem Rundbogen aus Stein, zwei Eisenbaender;
    der Bogen steht 10 cm vor der Wand (Laibung), damit die Tusche ihn umreisst"""
    hw, spring, rise, dy = 0.3 * TS, 92 * U, 34 * U, 10.0
    outer = arch_pts(cx, hw, 0, spring, rise); inner = arch_pts(cx, hw - 0.05 * TS, 0, spring, rise - 8 * U)
    po = [outer[1]] + outer[2:] + [outer[0]]; pi = [inner[1]] + inner[2:] + [inner[0]]   # rechts unten, Bogen, links unten
    def V(q, y): return Vector((q[0], y, q[1]))
    def ctr(q): return Vector((q[0] - cx, 0, q[1] - spring * 0.6))
    def stein(k, f): return lambda p, n: sc(lin(0x6A665E), f * (0.8 + 0.3 * h1(k, 3, 81)))      # Bogensteine wie alt 0x4A4640, je Stein heller/dunkler
    with use('weiss'):
        for k in range(len(po) - 1):
            add_face(DORF, facing([V(po[k], yf - dy), V(po[k + 1], yf - dy), V(pi[k + 1], yf - dy), V(pi[k], yf - dy)], Vector((0, -1, 0))), stein(k, 1.0))
            add_face(DORF, facing([V(po[k], yf), V(po[k + 1], yf), V(po[k + 1], yf - dy), V(po[k], yf - dy)], ctr(po[k])), stein(k, 0.85))
            add_face(DORF, facing([V(pi[k], yf), V(pi[k + 1], yf), V(pi[k + 1], yf - dy), V(pi[k], yf - dy)], -ctr(pi[k])), stein(k, 0.6))
    with use('weiss'): front_face(DORF, inner, yf - 1, lin(0x0E0A08))                                  # Fugen und Spalt (alt 0x0E0A08)
    # 348.6 (Helfer 25.10.: Tuer fast schwarz): Farbe auf weisser Flaeche wie alt mix(0x120C08, 0x4A3426), etwas heller
    # fuers Handy; je Fluegel 5 Bretter, Spalt in der Mitte
    with use('weiss'):
        hi = hw - 0.05 * TS; nb = 5; w = hi / nb
        for s_ in (-1, 1):
            for k in range(nb):
                a, b = cx + s_ * (1.4 + k * w), cx + s_ * (1.4 + (k + 1) * w - 0.9)
                pl = clip([(min(a, b), 0), (max(a, b), 0), (max(a, b), 400), (min(a, b), 400)], inner)
                v = 0.55 + (h1(k * s_, 0, 5) - 0.5) * 0.4
                front_face(DORF, pl, yf - 2, mixc(lin(0x3A2A1E), lin(0x7A5E46), v))
    with use('weiss'):
        for zz in (34 * U, 92 * U):
            band = clip([(cx - hw, zz - 2.5 * U), (cx + hw, zz - 2.5 * U), (cx + hw, zz + 2.5 * U), (cx - hw, zz + 2.5 * U)], inner)
            front_face(DORF, band, yf - 4, lin(0x24201C))
    with use('feldstein'): box(DORF, (cx - hw - 4, yf - 30, 0), (cx + hw + 4, yf, 9), lambda p, n: sc(W1, 0.95))         # Schwelle
    LIGHTS.append(dict(art='tuer', pos=[cx, yf - 60, 0]))
def house(cells, style):
    roof, walls, li, feat = style; lk = LOOKS[li]
    temple = feat == 'BELL_TOWER'                               # Kirche (MapTownIso.kt 5g): hoehere Traufe, Glockenturm
    cs = [c for c, _ in cells]; rs = [r for _, r in cells]
    c0, c1, r0, r1 = min(cs), max(cs), min(rs), max(rs)
    x0, x1 = tx(c0) + 6, tx(c1) + TS - 6
    yf = ty(r1) - TS + 18; yb = ty(r0) - 6                     # Vorderseite (Sued) mit Tueren und Fenstern
    W, D = x1 - x0, yb - yf; eave = 305.0 if temple else 260.0; ridge = eave + D / 2 * (1.25 if roof == 'STRAW' else 1.0)
    ptint = ratio(lk['plaster'], 0x8C8270); ttint = ratio(lk['timber'], 0x3E2E22)
    sto = max(lk['stoneTo'], 40.0)
    def wall_mat(): return 'feldstein' if walls == 'STONE' else ('bretter' if walls == 'PLANKS' else 'putz')
    def wall_tint(p, n):
        ao = 0.72 + 0.28 * ss(0, 90, p.z)                       # Feuchte am Fuss
        top = 1 - 0.18 * ss(eave - 40, eave, p.z)               # Schatten unter der Traufe
        if walls == 'STONE': return sc(stone_tint(p, n), top)
        if walls == 'PLANKS': return sc(mixc(W1, (0.8, 0.85, 0.7), ss(40, 0, p.z) * 0.6), ao * top)
        return sc(ptint, ao * top * (0.94 + 0.12 * vn(p.x / 80 + p.y / 80, p.z / 80, 13)))
    def wall(o, U, nu):
        # Sockel aus Feldstein, darueber die Wand
        with use('feldstein'): grid(DORF, o, U, Vector((0, 0, sto)), nu, 2, stone_tint)
        with use(wall_mat()): grid(DORF, o + Vector((0, 0, sto)), U, Vector((0, 0, eave - sto)), nu, 4, wall_tint)
    nx = max(2, int(W / 60))
    wall(Vector((x0, yf, 0)), Vector((W, 0, 0)), nx)
    wall(Vector((x1, yb, 0)), Vector((-W, 0, 0)), nx)
    for xs, sgn in ((x0, -1), (x1, 1)):                                                                       # Giebel
        a = Vector((xs, yf if sgn > 0 else yb, 0)); U = Vector((0, D * sgn, 0))
        wall(a, U, max(2, int(D / 60)))
        g0 = Vector((xs, yf, eave)); g1 = Vector((xs, yb, eave)); g2 = Vector((xs, (yf + yb) / 2, ridge))
        tri = [g0, g1, g2] if sgn > 0 else [g1, g0, g2]
        with use('bretter' if walls != 'STONE' else 'feldstein'): add_face(DORF, tri, wall_tint if walls == 'STONE' else sc(ttint, 1.6))
    # Fachwerk: Balken vor der Wand
    if walls == 'TIMBER':
        with use('balken'):
            nb = max(1, int(round(W / 110)))
            for xs in [x0 + k * (W / nb) for k in range(nb + 1)]:
                box(DORF, (xs - 7, yf - 5, sto), (xs + 7, yf + 1, eave), ttint)
            for zz in (sto + 4, 150, eave - 8):
                box(DORF, (x0 - 4, yf - 5, zz - 6), (x1 + 4, yf + 1, zz + 6), ttint)
            for k in range(nb):
                if k % 3 == 2: continue
                a = x0 + k * (W / nb); b = a + W / nb
                ln = math.hypot(b - a - 14, eave - 158)
                M = Matrix.Translation(((a + b) / 2, yf - 2, (150 + eave) / 2 + 2)) @ Matrix.Rotation(math.atan2(eave - 158, b - a - 14) * (1 if k % 2 else -1), 4, 'Y')
                box(DORF, (-ln / 2, -2.5, -5), (ln / 2, 2.5, 5), ttint, M=M)
            for xs in (x0, x1):                                             # Eckpfosten hinten
                box(DORF, (xs - 7, yb - 1, sto), (xs + 7, yb + 5, eave), ttint)
    # Tueren und Fenster nach der Frontzeile
    for c in range(c0, c1 + 1):
        t = ch(c, r1); cx = tx(c) + TS / 2
        if temple and t in 'DW':
            (arch_door if t == 'D' else arch_window)(cx, yf, c)
        elif t == 'D':
            with use('balken'): box(DORF, (cx - 44, yf - 9, 0), (cx + 44, yf + 2, 212), ttint)                               # Rahmen
            with use('bretter'):
                box(DORF, (cx - 35, yf - 11, 0), (cx + 35, yf - 7, 200), lambda p, n: sc(lin(0x7A5A42), 2.2))
            with use('weiss'):
                for zz in (50, 150):
                    box(DORF, (cx - 33, yf - 13, zz - 4), (cx + 22, yf - 10, zz + 4), lin(0x2A2622))                     # Eisenbaender
                box(DORF, (cx + 22, yf - 15, 100), (cx + 28, yf - 10, 110), lin(0x6A6050))                                # Riegel
            with use('feldstein'): box(DORF, (cx - 48, yf - 30, 0), (cx + 48, yf, 9), lambda p, n: sc(W1, 0.95))           # Schwelle
            LIGHTS.append(dict(art='tuer', pos=[cx, yf - 60, 0]))
        elif t == 'W':
            zz = 100
            with use('balken'):
                box(DORF, (cx - 36, yf - 9, zz - 8), (cx + 36, yf + 2, zz + 80), ttint)
                box(DORF, (cx - 40, yf - 16, zz - 12), (cx + 40, yf - 5, zz - 6), ttint)                                   # Fensterbank
            with use('weiss'): box(GLAS, (cx - 28, yf - 10, zz), (cx + 28, yf - 6, zz + 72), lin(0x1A2028))
            with use('balken'):
                box(DORF, (cx - 2.5, yf - 13, zz), (cx + 2.5, yf - 9, zz + 72), ttint)
                box(DORF, (cx - 28, yf - 13, zz + 34), (cx + 28, yf - 9, zz + 38), ttint)
            with use('bretter'):                                                                                           # offene Laeden
                for s in (-1, 1):
                    box(DORF, (cx + s * 38 - (0 if s > 0 else 30), yf - 12, zz - 2), (cx + s * 38 + (30 if s > 0 else 0), yf - 9, zz + 74), lambda p, n: sc(lin(0x5A4636), 2.6))
            if (c * 7 + r1) % 3 == 0:                                                                                      # Blumenkasten
                with use('holz'): box(DORF, (cx - 32, yf - 26, zz - 22), (cx + 32, yf - 9, zz - 8), W1)
                with use('laub'):
                    for k in range(5):
                        blob(DORF, Vector((cx - 24 + k * 12, yf - 18, zz - 4)), 7, (0.7, 1.0, 0.6), sub=1, seed=k + c)
                with use('weiss'):
                    for k in range(6):
                        blob(DORF, Vector((cx - 26 + k * 10.5, yf - 22 + (k % 2) * 6, zz + 2)), 3.2, lin([0xC83A3A, 0xE8D8B0, 0xD8A030][k % 3]), sub=1, seed=k)
            LIGHTS.append(dict(art='fenster', pos=[cx, yf - 30, zz + 40]))
    # Dach (Satteldach, Traufe vorn und hinten, Ueberstand 32 cm)
    o = 32.0; th = 34.0 if roof == 'STRAW' else 10.0
    rm = dict(STRAW='stroh', SHINGLE='schindel', SLATE='schiefer', BLUE='schiefer', RED='ziegel')[roof]
    def roof_tint(p, n):
        lowh = ss(ridge - 30, eave, p.z)                          # unten feuchter (Moos)
        mo = lk['moss'] * lowh * ss(0.45, 0.7, vn(p.x / 70, p.y / 50 + p.z / 40, 22))
        if roof == 'STRAW':
            base = ratio(lk['thatch'], 0x6A5C42)
            base = mixc(base, (0.95, 0.95, 0.92), ss(eave + 40, ridge, p.z) * 0.35)          # zum First grau
            return mixc(base, (0.6, 0.85, 0.4), mo * 0.7)
        if roof == 'BLUE': return mixc((0.93, 0.96, 1.02), (0.8, 0.95, 0.6), mo * 0.5)
        return mixc(W1, (0.75, 0.95, 0.55), mo * 0.5)
    ym = (yf + yb) / 2; dz = (eave - (ridge - eave) * o / (D / 2))
    with use(rm):
        for y_e, sgn in ((yf - o, 1), (yb + o, -1)):
            e = Vector((x0 - o, y_e, dz)); rv = Vector((x0 - o, ym, ridge + th * 0.3))
            U = Vector((W + 2 * o, 0, 0)); V = rv - e
            nu, nv = max(4, int((W + 2 * o) / 40)), max(4, int(V.length / 30))
            # UV laengs der Dachschraege (Reihen parallel zur Traufe)
            for i in range(nu):
                for j in range(nv):
                    a = e + U * (i / nu) + V * (j / nv) + Vector((0, 0, th)); b = e + U * ((i + 1) / nu) + V * (j / nv) + Vector((0, 0, th))
                    c_ = e + U * ((i + 1) / nu) + V * ((j + 1) / nv) + Vector((0, 0, th)); d = e + U * (i / nu) + V * ((j + 1) / nv) + Vector((0, 0, th))
                    q = [a, b, c_, d] if sgn > 0 else [b, a, d, c_]
                    uvs = [((p.x) / 200, ((p - e - Vector((0, 0, th))).project(V).length) / 200) for p in q]
                    add_face(DORF, q, roof_tint, uvs)
            # Traufkante (Dicke), zerzaust beim Stroh
            q = [e, e + U, e + U + Vector((0, 0, th)), e + Vector((0, 0, th))]
            if sgn < 0: q = [e + U, e, e + Vector((0, 0, th)), e + U + Vector((0, 0, th))]
            add_face(DORF, q, lambda p, n: sc(roof_tint(p, n), 0.55), [(p.x / 200, p.z / 60) for p in q])
        for xs, sgn in ((x0 - o, -1), (x1 + o, 1)):   # Ortgang: Dachdicke an den Giebeln
            for y_e in (yf - o, yb + o):
                a = Vector((xs, y_e, dz)); b = Vector((xs, ym, ridge + th * 0.3))
                q = [a, b, b + Vector((0, 0, th)), a + Vector((0, 0, th))]
                if (sgn > 0) == (y_e < ym): q = q[::-1]
                add_face(DORF, q, lambda p, n: sc(roof_tint(p, n), 0.5))
        box(DORF, (x0 - o, ym - 12, ridge + th * 0.3 - 4), (x1 + o, ym + 12, ridge + th * 0.3 + 14), lambda p, n: sc(roof_tint(p, n), 0.75))
    if roof != 'STRAW' and not temple:  # Schornstein (Kirche ohne, MapTownIso.kt) (Feldstein, oben verrusst)
        cx = x0 + W * 0.72
        with use('feldstein'):
            box(DORF, (cx - 22, ym + 10, ridge - 60), (cx + 22, ym + 54, ridge + 72), lambda p, n: sc(W1, 1 - 0.55 * ss(ridge, ridge + 72, p.z)), sub=(1, 1, 3))
        with use('weiss'): box(DORF, (cx - 14, ym + 18, ridge + 72), (cx + 14, ym + 46, ridge + 74), lin(0x0A0806))
        LIGHTS.append(dict(art='rauch', pos=[cx, ym + 32, ridge + 76]))
    if temple:
        # Glockenturm wie MapTownIso.kt: quadratisch aus Feldstein, 1,125 Kacheln vom Ostende auf dem First,
        # oben Schallloecher, Gesims, spitze Haube aus Schiefer (Turm 1,6 m ueber dem First, Haube 0,9 m)
        tcx = x1 + 6 - 1.125 * TS; hw = 0.525 * TS; top = ridge + 160
        with use('feldstein'):
            box(DORF, (tcx - hw, ym - hw, eave - 20), (tcx + hw, ym + hw, top), lambda p, n: sc(stone_tint(p, n), 1.05), sub=(2, 2, 6))
            box(DORF, (tcx - hw - 7, ym - hw - 7, top - 7), (tcx + hw + 7, ym + hw + 7, top + 3), lambda p, n: sc(W1, 0.7))
            # Kragen am Turmfuss: Stufe ueber dem First, damit die Tusche dort eine Kante findet (Helfer 25.10.: Linie fehlte)
            box(DORF, (tcx - hw - 4, ym - hw - 4, ridge - hw), (tcx + hw + 4, ym + hw + 4, ridge + 14), lambda p, n: sc(stone_tint(p, n), 0.85))
        with use('weiss'):
            for (ax_, sgn) in ((0, -1), (0, 1), (1, -1), (1, 1)):
                lo, hi = [tcx - 0.24 * 2 * hw, ym - 0.24 * 2 * hw, top - 100], [tcx + 0.24 * 2 * hw, ym + 0.24 * 2 * hw, top - 38]
                f = (ym if ax_ == 0 else tcx) + sgn * hw
                lo[1 - ax_], hi[1 - ax_] = (f - 2, f + 2)
                box(DORF, tuple(lo), tuple(hi), lin(0x0C0A0A))
                # Schalllaeden: vier Holzlatten vor dem Dunkel, Sohlbank aus Stein darunter (Helfer 25.10.: nur schwarze Quadrate)
                for j in range(4):
                    z0 = lo[2] + 6 + j * 14
                    sl, sh_ = list(lo), list(hi); sl[2], sh_[2] = z0, z0 + 7
                    sl[1 - ax_], sh_[1 - ax_] = sorted((f, f + sgn * 4))
                    box(DORF, tuple(sl), tuple(sh_), lin(0x3A2C20))
                bl, bh = list(lo), list(hi); bl[2], bh[2] = lo[2] - 7, lo[2]
                bl[ax_] -= 4; bh[ax_] += 4
                bl[1 - ax_], bh[1 - ax_] = sorted((f, f + sgn * 6))
                box(DORF, tuple(bl), tuple(bh), lin(0x5E5A52))   # Sohlbank grau (weisses Material: sonst grell)
        with use('schiefer'):
            cs_ = [Vector((tcx - hw - 7, ym - hw - 7, top + 3)), Vector((tcx + hw + 7, ym - hw - 7, top + 3)),
                   Vector((tcx + hw + 7, ym + hw + 7, top + 3)), Vector((tcx - hw - 7, ym + hw + 7, top + 3))]
            ap = Vector((tcx, ym, top + 130))   # spitzer als alt (50 Einheiten): die Kamera staucht Hoehen
            for k in range(4): add_face(DORF, [cs_[k], cs_[(k + 1) % 4], ap], lambda p, n: sc(lin(0x585C62), 2.4))
    if feat == 'AWNING':
        # Markise des Ladens wie MapTownIso.kt: gestreiftes Tuch (0,15 Kachel von den Ecken) 0,7 Kacheln vor der Front,
        # vorn 45 cm tiefer, ausgefranster Saum, zwei Stangen (Masse alt * 1,73 cm)
        a0, a1, out = x0 + 0.15 * TS, x1 - 0.15 * TS, 0.7 * TS
        ns = max(4, int((a1 - a0) / TS * 4))
        with use('stoff'):
            for k in range(ns):
                xa = a0 + (a1 - a0) * k / ns; xb = a0 + (a1 - a0) * (k + 1) / ns
                col = sc(lin(0x5A3A2A if k % 2 == 0 else 0x7A6E58), 2.2)
                add_face(DORF, [Vector((xa, yf, 222)), Vector((xa, yf - out, 177)), Vector((xb, yf - out, 177)), Vector((xb, yf, 222))], col)
                for j in range(3):                                                        # Saum
                    xm = xa + (xb - xa) * j / 3; xn = xa + (xb - xa) * (j + 1) / 3; dz = 10 + 8 * h1(k * 3 + j, 4, 62)
                    add_face(DORF, [Vector((xm, yf - out, 177)), Vector((xm, yf - out, 177 - dz)), Vector((xn, yf - out, 177 - dz)), Vector((xn, yf - out, 177))], sc(col, 0.8))
        with use('holz'):
            for xs in (a0 + 6, a1 - 6): box(DORF, (xs - 3, yf - out - 3, 0), (xs + 3, yf - out + 3, 180), lin(0x2E2218))
    if feat == 'INN_SIGN':
        # Wirtshausschild wie MapTownIso.kt: Eisenarm aus der Front 1,15 Kacheln rechts der Tuer, Brett mit Krug darunter
        dc = next((c for c in range(c0, c1 + 1) if ch(c, r1) == 'D'), c0)
        sx = tx(dc) + 1.15 * TS
        with use('weiss'):
            box(DORF, (sx - 2, yf - 0.62 * TS, 220), (sx + 2, yf, 226), lin(0x1E1C1A))
            for yy_ in (yf - 0.16 * TS, yf - 0.5 * TS): box(DORF, (sx - 1, yy_ - 1, 214), (sx + 1, yy_ + 1, 220), lin(0x1E1C1A))
        with use('bretter'):
            box(DORF, (sx - 2.5, yf - 0.54 * TS, 173), (sx + 2.5, yf - 0.12 * TS, 214), sc(lin(0x5A4430), 2.0))
        with use('weiss'):
            for sgn in (-1, 1):                                   # Krug auf beiden Seiten, hell auf dunklem Brett (Helfer 25.10.: Krug nicht zu sehen)
                xa, xb = sorted((sx + sgn * 2.5, sx + sgn * 4.5))
                box(DORF, (xa, yf - 0.40 * TS, 181), (xb, yf - 0.25 * TS, 205), lin(0xC8B07A))
                box(DORF, (xa, yf - 0.25 * TS, 186), (xb, yf - 0.20 * TS, 200), lin(0xC8B07A))
                box(DORF, (xa, yf - 0.42 * TS, 203), (xb, yf - 0.23 * TS, 207), lin(0xE8E0C8))
    # Holzstoss an der Giebelseite
    if not temple and (c0 + r0) % 2 == 0:
        with use('holz'):
            for k in range(14):
                yy_ = yf + 20 + (k % 7) * 15; zz_ = 8 + (k // 7) * 15
                cylinder(DORF, Vector((x1 + 10, yy_, zz_)), 7, 0.1, 6, lambda p, n: sc(lin(0x8A6A48), 2.0), cap=False)
                M = Matrix.Translation((x1 + 30, yy_, zz_)) @ Matrix.Rotation(math.radians(90), 4, 'Y')
                box(DORF, (-24, -7, -7), (24, 7, 7), lambda p, n: sc(W1, 0.8 + 0.3 * h1(k, 3, 9)), M=M)
    return (c0, c1, r0, r1)
HOUSES = []
for cells in comps():
    st = next((v for (sx, sy), v in STYLE.items() if (sx, sy) in cells), None) or ('STRAW', 'TIMBER', 0, 'NONE')
    HOUSES.append(house(cells, st))

# ---------------------------------------------------------------- Dinge auf dem Platz
def tile_c(c, r): return Vector((tx(c) + TS / 2, ty(r) - TS / 2, 0))
def well(c, r):
    p = tile_c(c, r)
    with use('feldstein'):
        cylinder(DORF, p, 62, 74, 20, lambda q, n: stone_tint(q, n))
        cylinder(DORF, p + Vector((0, 0, 74)), 66, 9, 20, lambda q, n: sc(W1, 1.1))
    with use('weiss'): cylinder(DORF, p + Vector((0, 0, 60)), 52, 1, 20, lin(0x0A1214), cap=True)
    with use('balken'):
        for s in (-1, 1): box(DORF, (p.x + s * 58 - 7, p.y - 7, 70), (p.x + s * 58 + 7, p.y + 7, 232), W1)
        box(DORF, (p.x - 64, p.y - 4, 168), (p.x + 64, p.y + 4, 176), W1)
    with use('schindel'):
        for s in (-1, 1):
            M = Matrix.Translation((p.x, p.y + s * 32, 244)) @ Matrix.Rotation(math.radians(32 * s), 4, 'X')
            box(DORF, (-84, -40, -3), (84, 40, 4), W1, M=M)
    with use('weiss'): box(DORF, (p.x - 1.5, p.y - 1.5, 112), (p.x + 1.5, p.y + 1.5, 170), lin(0x8A7A5A))
    with use('holz'): cylinder(DORF, p + Vector((0, 0, 92)), 12, 22, 10, lambda q, n: sc(W1, 0.9 if abs(q.z - 100) > 3 else 0.4))
    LIGHTS.append(dict(art='brunnen', pos=[p.x, p.y, 0]))
CLOTH = [(0x5A3A2A, 0x7A6E58), (0x3E4A3A, 0x6E6A52), (0x4A3A4E, 0x7A7060)]
def stall(c, r, k):
    p = tile_c(c, r) + Vector((TS / 2, 0, 0))
    w, d = 100, 45
    with use('bretter'):
        box(DORF, (p.x - w, p.y - d, 74), (p.x + w, p.y + d, 82), W1)
        box(DORF, (p.x - w + 5, p.y - d + 5, 0), (p.x + w - 5, p.y + d - 5, 74), (0.8, 0.8, 0.8))
    with use('holz'):
        for sx in (-1, 1):
            for sy in (-1, 1):
                box(DORF, (p.x + sx * (w - 4) - 4, p.y + sy * (d + 10) - 4, 0), (p.x + sx * (w - 4) + 4, p.y + sy * (d + 10) + 4, 210 + 25 * sy), W1)
    a, b = CLOTH[k % 3]
    M = Matrix.Translation((p.x, p.y, 222)) @ Matrix.Rotation(math.radians(-14), 4, 'X')
    ns = 9; sw_ = (2 * w + 30) / ns
    with use('stoff'):
        for k_ in range(ns):
            col = sc(lin(a if k_ % 2 else b), 3.0)
            box(DORF, (-w - 15 + k_ * sw_, -d - 25, 0), (-w - 15 + (k_ + 1) * sw_, d + 25, 3), col, M=M)
            hem = Matrix.Translation((p.x, p.y, 222)) @ Matrix.Rotation(math.radians(-14), 4, 'X')
            box(DORF, (-w - 15 + k_ * sw_ + 2, -d - 25, -14 - 6 * h1(k_, k, 3)), (-w - 15 + (k_ + 1) * sw_ - 2, -d - 23, 0), col, M=hem)
    ware = k % 3
    with use('weiss'):
        for i in range(8):
            x = p.x - w + 20 + i * 24
            if ware == 0:
                for j in range(5): blob(DORF, Vector((x + (j % 3) * 7 - 7, p.y - 18 + (j // 3) * 12, 90 + 5 * (j // 3))), 6.5, lin(0x9A2A1A) if (i + j) % 3 else lin(0x7A9A3A), sub=1, seed=i * 7 + j)
            elif ware == 1:
                blob(DORF, Vector((x, p.y - 8, 92)), 11, lin(0xB08A50), sub=1, squash=0.6, seed=i)
            else:
                cylinder(DORF, Vector((x, p.y - 10, 82)), 9, 16, 8, lin(0x8A4A2E), r2=7)
    with use('stoff'):
        for s in (-1, 1): blob(DORF, Vector((p.x + s * (w + 14), p.y + d - 10, 28)), 24, sc(lin(0x8A7A5A), 1.1), sub=2, squash=1.15, seed=s + 5)   # Saecke
def lamp(c, r, p=None, eiche=False, reich=2.6, kraft=0.95):
    p = p or tile_c(c, r)
    if not eiche:
        with use('feldstein'): box(DORF, (p.x - 18, p.y - 18, 0), (p.x + 18, p.y + 18, 22), W1)
    with use('balken'): box(DORF, (p.x - 6, p.y - 6, -34 if eiche else 22), (p.x + 6, p.y + 6, 260), ratio(0x3E2E22, 0x5A4430) if eiche else W1)
    with use('weiss'):
        box(DORF, (p.x - 14, p.y - 14, 252), (p.x + 14, p.y + 14, 256), lin(0x5A5C60))
        box(DORF, (p.x - 15, p.y - 15, 288), (p.x + 15, p.y + 15, 294), lin(0x5A5C60))
        box(DORF, (p.x - 6, p.y - 6, 294), (p.x + 6, p.y + 6, 306), lin(0x5A5C60))
        for sx in (-1, 1):
            for sy in (-1, 1): box(DORF, (p.x + sx * 12 - 1.5, p.y + sy * 12 - 1.5, 256), (p.x + sx * 12 + 1.5, p.y + sy * 12 + 1.5, 288), lin(0x5A5C60))
        box(GLAS, (p.x - 11, p.y - 11, 256), (p.x + 11, p.y + 11, 288), lin(0x8A7450))
    LIGHTS.append(dict(art='laterne', pos=[p.x, p.y, 272], reich=reich, kraft=kraft))
def kael_lantern(c, r):
    """80/80a: Kaels Handlaterne neben seiner Tuer auf kniehohem Feldsteinsockel (Familienzeichen vorn: Raute mit Balken),
    Eisenrahmen, Hornscheiben braun und verrusst, oben ein Ring; nachts nur schwach bernsteinfarben (MapLight CANDLE)"""
    p = Vector((tx(c) + 6 / 32 * TS, ty(r) - 6 / 32 * TS, 0))
    with use('feldstein'): box(DORF, (p.x - 16, p.y - 16, 0), (p.x + 16, p.y + 16, 45), W1)
    with use('weiss'):
        mk = lin(0x2A2622)
        for k in range(4):                                  # Raute aus vier Strichen, waagrechter Balken hindurch
            a = math.pi / 4 + k * math.pi / 2; cx, cz = p.x + math.cos(a) * 5, 24 + math.sin(a) * 5
            box(DORF, (cx - 1.5, p.y - 16.6, cz - 1.5), (cx + 1.5, p.y - 16.0, cz + 1.5), mk)
        box(DORF, (p.x - 9, p.y - 16.6, 23), (p.x + 9, p.y - 16.0, 25), mk)
        iron = lin(0x262422)
        box(DORF, (p.x - 8, p.y - 8, 45), (p.x + 8, p.y + 8, 47), iron); box(DORF, (p.x - 8, p.y - 8, 65), (p.x + 8, p.y + 8, 68), iron)
        for sx in (-1, 1):
            for sy in (-1, 1): box(DORF, (p.x + sx * 7 - 1, p.y + sy * 7 - 1, 47), (p.x + sx * 7 + 1, p.y + sy * 7 + 1, 65), iron)
        box(DORF, (p.x - 7, p.y - 0.5, 68), (p.x - 5, p.y + 0.5, 74), iron); box(DORF, (p.x + 5, p.y - 0.5, 68), (p.x + 7, p.y + 0.5, 74), iron)
        box(DORF, (p.x - 7, p.y - 0.5, 74), (p.x + 7, p.y + 0.5, 76), iron)
        box(GLAS, (p.x - 6, p.y - 6, 47), (p.x + 6, p.y + 6, 65), lin(0x4A3420))
        box(DORF, (p.x - 7.2, p.y - 7.2, 50), (p.x - 6.2, p.y + 7.2, 64), lin(0x14100C))          # eine Seite schwarz verrusst
    LIGHTS.append(dict(art='laterne', pos=[p.x, p.y, 56], reich=1.2, kraft=0.3, kerze=True))
def bench(c, r):
    p = tile_c(c, r)
    with use('holz'):
        box(DORF, (p.x - 58, p.y - 18, 40), (p.x + 58, p.y + 18, 47), W1)
        box(DORF, (p.x - 58, p.y + 14, 47), (p.x + 58, p.y + 20, 90), W1)
        for s in (-1, 1): box(DORF, (p.x + s * 46 - 6, p.y - 16, 0), (p.x + s * 46 + 6, p.y + 16, 40), (0.7, 0.7, 0.7))
def barrel(c, r, p=None):
    p = p or tile_c(c, r)
    with use('holz'):
        for k in range(4):
            z0, z1 = k * 22, (k + 1) * 22
            rr0 = 28 + 4 * math.sin(math.pi * z0 / 88); rr1 = 28 + 4 * math.sin(math.pi * z1 / 88)
            cylinder(DORF, p + Vector((0, 0, z0)), rr0, 22, 14, W1, cap=(k == 3), r2=rr1)
    with use('weiss'):
        for z in (14, 70):
            cylinder(DORF, p + Vector((0, 0, z)), 31.5, 5, 14, lin(0x3A3430), cap=False)
# 348.6 (Befund 6: Kronen wuerfelig, Fichten flache gleich hohe Stufen, Laub und Fichte gleiches Lindgruen, Helligkeit 97-118
# statt 77): wie MapTree.kt. Fichte in haengenden Stufen (spruce: 6 Stufen, jede ueber der unteren, unten Spitzen), eigene
# Nadeltextur blaugruen (PINE); Eiche aus vielen runden Ballen um einen Kern (crown), dunkler und gelbgruen (LEAF, LEAF_OLIVE).
def pine_col(v, n): return mixc((0.05, 0.075, 0.07), (0.2, 0.26, 0.24), max(0.0, n.z) * 0.55 + 0.45 * max(0.0, n.x * 0.55 - n.y * 0.7))
def spruce(P, p, R, seed, tiers=6):
    """Fichte wie MapTree.spruce: Hoehe 3,5 R; Stufe k von 0,42 R aufwaerts, Breite R * (1 - 0,72 f), Hoehe R * (0,95 - 0,25 f)"""
    with use('rinde'): cylinder(P, p, R * 0.12, R * 2.2, 6, (0.55, 0.55, 0.55), cap=False, r2=R * 0.04)
    with use('laub_nadel'):
        for k in range(tiers):
            f = k / (tiers - 1.0)
            z0 = R * (0.42 + f * 2.38) * (1 + 0.1 * (h1(seed, k, 41) - 0.5))
            half = R * (1.0 - f * 0.62) * (0.92 + 0.16 * h1(seed, k, 42))   # Spitze breiter, nicht wie ein Pfahl
            hh = R * (1.25 - f * 0.35) * (0.85 + 0.3 * h1(seed, k, 46))      # Befund Lauf 14: Stufen flach, gleich hoch
            n = 9 if k < 3 else 7; a0 = h1(seed, k, 43) * 6.3
            top = p + Vector((0, 0, z0 + hh)); mid = p + Vector((0, 0, z0 + hh * 0.3))
            ring = []
            for j in range(2 * n):                                          # Spitzen haengen tiefer und weiter hinaus
                a = a0 + math.pi * j / n; tip = j % 2 == 0
                rr = half * ((1.0 + 0.12 * (h1(seed, k * 31 + j, 44) - 0.5)) if tip else 0.72)
                dz = -R * 0.34 * (0.5 + h1(seed, k * 31 + j, 45)) if tip else R * 0.1
                ring.append(p + Vector((math.cos(a) * rr, math.sin(a) * rr, z0 + dz)))
            for j in range(2 * n):
                a, b = ring[j], ring[(j + 1) % (2 * n)]
                add_face(P, [a, b, top], pine_col)
                add_face(P, [b, a, mid], lambda v, nn: sc(pine_col(v, nn), 0.45))     # unter der Stufe Schatten
def oak_crown(P, cen, r, light, seed, squash=0.8, clumps=10, sub=1):
    """Eichenkrone wie MapTree.crown: Kern und Ballen auf der Aussenseite, damit der Umriss rund und gelappt bleibt"""
    dark = sc(light, 0.28)
    def col(v, n, cz=cen.z):
        lit = max(0.0, n.x * 0.55 - n.y * 0.2 + n.z * 0.7) * 0.75 + 0.25 * ss(cz - r, cz + r, v.z)
        return mixc(dark, light, lit)
    with use('laub'):
        blob(P, cen, r * 0.8, col, sub=2, squash=squash, seed=seed, smooth=True)
        for k in range(clumps):
            a = 2 * math.pi * (k + 0.4 * h1(seed, k, 51)) / clumps; e = (h1(seed, k, 52) - 0.5) * 1.3
            d = Vector((math.cos(a) * math.cos(e), math.sin(a) * math.cos(e), math.sin(e) * squash))
            blob(P, cen + d * r * 0.62, r * (0.36 + 0.12 * h1(seed, k, 53)), col, sub=sub, squash=0.9, seed=seed + k, smooth=True, bump=0.3)
LEAF_L = (0.16, 0.25, 0.08); LEAF_OL = (0.2, 0.24, 0.08)               # Lauf 14: zu hell und gelb              # Licht der Eiche (alt LEAF 0x6C8040, LEAF_OLIVE 0x6C7A3A)
def tree(c, r):
    p = tile_c(c, r) + Vector((rnd.uniform(-20, 20), rnd.uniform(-20, 20), 0))
    if h1(c, r, 77) < 0.3:
        spruce(DORF, p, 85 + 15 * h1(c, r, 78), c * 37 + r); return     # Lauf 16: nicht hoeher als die Eichen
    g = 0.9 + 0.25 * h1(c, r, 79)
    with use('rinde'):
        cylinder(DORF, p, 18 * g, 240 * g, 8, lambda q, n: sc(W1, 0.7 + 0.3 * ss(0, 60, q.z)), r2=10 * g)
    oak_crown(DORF, p + Vector((0, 0, 250 * g)), 115 * g, LEAF_OL if h1(c, r, 80) < 0.25 else LEAF_L, c * 13 + r, squash=0.74 + 0.07 * int(h1(c, r, 81) * 3), clumps=8, sub=2)
def flowers(c, r):
    p = tile_c(c, r)
    for k in range(14):
        q = p + Vector((rnd.uniform(-50, 50), rnd.uniform(-50, 50), 0))
        with use('bluete'): cylinder(DORF, q, 1.2, 22, 4, lin(0x3E5A2A), cap=False)     # eigenes Material: Godot nimmt Blueten von der Tusche aus (Probe Build 12)
        with use('bluete'): blob(DORF, q + Vector((0, 0, 24)), 4.5, lin(rnd.choice([0xD8C050, 0xA84A6A, 0xE8E0D0, 0x8A6AB8, 0xC8603A])), sub=1, seed=k)
    LIGHTS.append(dict(art='blumen', pos=[p.x, p.y, 0]))
def washline(cells):
    a = tile_c(*cells[0]); b = tile_c(*cells[-1])
    with use('holz'):
        for x in (a.x - 54, b.x + 54): box(DORF, (x - 4, a.y - 4, 0), (x + 4, a.y + 4, 180), W1)
    with use('weiss'):
        n = 12
        for k in range(n):
            x0 = a.x - 54 + (b.x - a.x + 108) * k / n; x1 = a.x - 54 + (b.x - a.x + 108) * (k + 1) / n
            z0 = 174 - 18 * math.sin(math.pi * k / n); z1 = 174 - 18 * math.sin(math.pi * (k + 1) / n)
            add_face(DORF, [Vector((x0, a.y, z0)), Vector((x1, a.y, z1)), Vector((x1, a.y, z1 + 1.5)), Vector((x0, a.y, z0 + 1.5))], lin(0x9A9280))
    cols = (0xC8C0AC, 0x8A9AA8, 0xB09A6A, 0x8A5A44, 0xD0CCBE, 0x6A7A5A)
    with use('stoff'):
        for k, col in enumerate(cols):
            x = a.x - 40 + k * (b.x - a.x + 80) / len(cols)
            t = (x - (a.x - 54)) / (b.x - a.x + 108); z = 174 - 18 * math.sin(math.pi * t)
            box(DORF, (x, a.y - 1, z - 50 - 12 * h1(k, 1, 2)), (x + 42, a.y + 1, z), sc(lin(col), 1.25))
def sign(c, r):
    p = tile_c(c, r)
    with use('balken'): box(DORF, (p.x - 6, p.y - 6, 0), (p.x + 6, p.y + 6, 170), W1)
    with use('bretter'): box(DORF, (p.x - 40, p.y - 8, 118), (p.x + 40, p.y - 3, 162), (1.6, 1.5, 1.4))
    with use('weiss'):                                          # 348.6 (Befund 7): eingebrannte Schrift in zwei Zeilen wie MapTownIso.signpost
        for row, zc in ((0, 148), (1, 132)):
            for k in range(26):
                u = k / 26
                if 0.12 <= u <= 0.88 and int(h1(k, row, c * 31 + r) * 4) != 0:
                    x0 = p.x - 40 + u * 80
                    box(DORF, (x0, p.y - 9, zc - 3.5), (x0 + 80 / 26 * 0.7, p.y - 7.5, zc + 3.5), lin(0x150E0A))
def notice(c, r):
    p = tile_c(c, r)
    with use('balken'):
        for s in (-1, 1): box(DORF, (p.x + s * 50 - 6, p.y - 6, 0), (p.x + s * 50 + 6, p.y + 6, 200), W1)
    with use('bretter'): box(DORF, (p.x - 56, p.y - 6, 90), (p.x + 56, p.y - 1, 190), (1.5, 1.4, 1.3))
    with use('stoff'):
        for k in range(5): box(DORF, (p.x - 46 + k * 19, p.y - 8, 110 + 30 * (k % 2)), (p.x - 32 + k * 19, p.y - 6, 140 + 30 * (k % 2)), (1.05, 1.0, 0.85))
    with use('schindel'):
        for s in (-1, 1):
            M = Matrix.Translation((p.x, p.y + s * 14, 208)) @ Matrix.Rotation(math.radians(35 * s), 4, 'X')
            box(DORF, (-64, -18, -2), (64, 18, 3), W1, M=M)
def hay(c, r):
    p = tile_c(c, r)
    with use('heu'):
        blob(DORF, p + Vector((0, 0, 20)), 52, lambda v, n: mixc(W1, (0.85, 0.85, 0.82), ss(40, 90, v.z) * 0.5), sub=2, squash=1.0, seed=c)
    with use('holz'): box(DORF, (p.x - 2, p.y - 2, 60), (p.x + 2, p.y + 2, 140), W1)
    LIGHTS.append(dict(art='heu', pos=[p.x, p.y, 0]))
def yard(c, r):
    """D29.3 wie MapTownIso.yardKind/yard: am Ufer ein Netz (3), an einem Haus ein Holzstapel (0), an Waescheleine oder
    Brunnen Eimer (2), sonst eine Handkarre (1); je drei Ansichten. Masse in Kachel (-1..0 ab der Suedostecke) und U."""
    around = [ch(c - 1, r), ch(c + 1, r), ch(c, r - 1), ch(c, r + 1)]
    kind = 3 if '~' in around else 0 if any(t in '#W^' for t in around) else 2 if any(t in 'qw' for t in around) else 1
    v = int(h1(c, r, 77) * 3)
    def P(i, j, z=0.0): return Vector((tx(c) + (1 + i) * TS, ty(r) - (1 + j) * TS, z * U))
    def B(i0, j0, i1, j1, z0, z1, col, m, M=None):
        with use(m): box(DORF, (tx(c) + (1 + i0) * TS, ty(r) - (1 + j1) * TS, z0 * U), (tx(c) + (1 + i1) * TS, ty(r) - (1 + j0) * TS, z1 * U), col)
    wood = ratio(0x5A4430, 0x5A4430); dark = ratio(0x3A2C20, 0x5A4430)
    if kind == 0:                                            # Holzstapel an der Wand, Stirnseiten zum Betrachter; Hackklotz mit Axt
        top = 40 + 4 * v; d = 10.0; rows = int(top / d)
        B(-0.96, -0.78, -0.04, -0.45, 0, (rows - 1.2) * d, lin(0x140E0A), 'weiss')
        for row in range(rows):
            n = int(0.98 * 66 / d) - (row % 2)
            for col in range(n):
                ci = -0.99 + ((row % 2) * 0.5 + col + 0.5) * d / 66; rr_ = d / 2 * (0.82 + 0.16 * h1(col, row, 11 + c)) / 66
                je = -0.4 + (h1(col, row, 12 + r) - 0.5) * 0.06
                zc = (row + 0.5) * d * U; R_ = rr_ * TS; y0, y1 = ty(r) - (1 - 0.78) * TS, ty(r) - (1 + je) * TS
                xc = tx(c) + (1 + ci) * TS
                ring = [(xc + math.cos(k * math.pi / 4) * R_, zc + math.sin(k * math.pi / 4) * R_) for k in range(8)]
                with use('rinde'):
                    for k in range(8):
                        (x0_, z0_), (x1_, z1_) = ring[k], ring[(k + 1) % 8]
                        add_face(DORF, [Vector((x0_, y0, z0_)), Vector((x1_, y0, z1_)), Vector((x1_, y1, z1_)), Vector((x0_, y1, z0_))], W1)
                end = lin(mix_hex(0x8A6A44, 0xC8A672, 0.3 + 0.5 * h1(col, row, 13)))     # helle Stirnseite (Helfer: las sich als Platte)
                with use('weiss'): add_face(DORF, [Vector((x, y1, z)) for x, z in ring], end)
        with use('holz'): cylinder(DORF, P(-0.3, -0.2), 0.11 * TS, 20 * U, 10, W1)
        B(-0.31, -0.21, -0.29, -0.19, 24, 50, W1, 'holz'); B(-0.34, -0.24, -0.26, -0.16, 20, 24, lin(0x3A3836), 'weiss')
    elif kind == 1:                                          # Handkarre, Deichseln am Boden; leer, Saecke, Heu
        i0, i1, j0, j1, z0, z1 = -0.72, -0.16, -0.68, -0.32, 30, 52
        B(i0, j0, i1, j1, z0, z0 + 4, dark, 'bretter')
        for (a0, b0, a1, b1) in ((i0, j0, i1, j0 + 0.03), (i0, j1 - 0.03, i1, j1), (i0, j0, i0 + 0.03, j1), (i1 - 0.03, j0, i1, j1)):
            B(a0, b0, a1, b1, z0 + 4, z1, wood, 'bretter')
        for jj in (j0 - 0.03, j1 + 0.01):                    # Raeder: Felge aus acht Stuecken, Nabe, Speichen
            # Runde 2f: Rad so gross wie der Kasten, das vordere verdeckte ihn; alt r = 0,26 Kachel quer (30 cm), Nabe in Radhoehe
            ci = (i0 + i1) / 2; RW = 0.26 * TS; ZN = RW / U
            for k in range(10):
                a = k * math.pi / 5; q = P(ci, jj + 0.01, ZN) + Vector((math.cos(a) * (RW - 3), 0, math.sin(a) * (RW - 3)))
                M = Matrix.Translation(q) @ Matrix.Rotation(-a, 4, 'Y')
                with use('holz'): box(DORF, (-3.5, -2.5, -RW * 0.33), (3.5, 2.5, RW * 0.33), lin(0x8A6844), M=M)   # alt: Felge 0x4A3624, hier im Schatten des Kastens fast schwarz: heller
                M2 = Matrix.Translation(P(ci, jj + 0.01, ZN)) @ Matrix.Rotation(-a, 4, 'Y')
                if k < 5:
                    with use('holz'): box(DORF, (-2.6, -2.0, -(RW - 4)), (2.6, 2.0, RW - 4), lin(0xA4845C), M=M2)   # Runde 3 (3): Speichen kaum zu sehen: breiter, heller
            B(ci - 0.035, jj, ci + 0.035, jj + 0.02, ZN - 3, ZN + 3, lin(0x3A2C20), 'weiss')
        for jj in (j0 + 0.04, j1 - 0.07):                    # Deichseln vom Boden zur Ladeflaeche
            a_, b_ = P(-1.0, jj, 4), P(i0, jj, z0 + 2); L = (b_ - a_).length; ang = math.atan2(b_.z - a_.z, b_.x - a_.x)
            M = Matrix.Translation((a_ + b_) / 2) @ Matrix.Rotation(-ang, 4, 'Y')
            with use('holz'): box(DORF, (-L / 2, -3, -3), (L / 2, 3, 3), lin(0x7A5E40), M=M)     # Runde 2f: Deichseln nicht zu sehen; dicker, heller
        if v == 1:
            for k in range(2):
                with use('stoff'): blob(DORF, P(i0 + 0.16 + k * 0.26, (j0 + j1) / 2, z1 + 6), 0.12 * TS, lin(0x9A8A68), sub=1, squash=0.6, seed=c + k)
        elif v == 2:
            with use('heu'): blob(DORF, P((i0 + i1) / 2, (j0 + j1) / 2, z1), 0.3 * TS, W1, sub=2, squash=0.45, seed=c * 3 + r)
    elif kind == 2:                                          # Eimer mit Eisenreifen; voll und umgedreht, zwei, Eimer und Waschzuber
        def bucket(i, j, rr_, h, full, turned):
            with use('holz'): cylinder(DORF, P(i, j), rr_ * TS, h * U, 10, wood, r2=rr_ * TS * 1.12, cap=turned)
            with use('weiss'):
                for zz in (0.18, 0.82): cylinder(DORF, P(i, j, h * zz - 1.2), rr_ * TS * (1.01 + 0.12 * zz), 2.4 * U, 10, lin(0x2A2826), cap=False)
                if not turned: cylinder(DORF, P(i, j, h * 0.85 if full else h * 0.3), rr_ * TS * 1.08, 0.5, 10, lin(0x2A363C if full else 0x1A120C))
        if v == 0: bucket(-0.62, -0.5, 0.09, 24, True, False); bucket(-0.35, -0.42, 0.09, 24, False, True)
        elif v == 1: bucket(-0.62, -0.5, 0.09, 24, True, False); bucket(-0.38, -0.55, 0.085, 22, False, False)
        else: bucket(-0.3, -0.3, 0.085, 22, True, False); bucket(-0.62, -0.58, 0.24, 18, True, False)
    else:                                                    # Netz zum Trocknen am Ufer zwischen zwei Stangen, durchhaengend, Korken am Fuss
        # Runde 3 (4): das Ufer aus wfield reicht in den Hof (22/27 stand eine Stange im Wasser): Reihe und Lage im Trockenen suchen
        def dry(i, j): return float(wfield(c + 1 + i, r + 1 + j)) < 0.2
        i0, i1, j = -0.86, -0.14, -0.5
        for jj in (-0.5, -0.4, -0.6, -0.3, -0.7, -0.2):
            hit = next(((a, a + L) for L in (0.72, 0.6) for a in (-0.86, -0.8, -0.74, -0.68, -0.62)
                        if a + L <= -0.08 and all(dry(a + L * k / 6, jj + dj) for k in range(7) for dj in (-0.08, 0.08))), None)
            if hit: i0, i1 = hit; j = jj; break
        bar = 64.0 if v == 1 else 122.0
        for i in (i0, i1): B(i - 0.025, j - 0.025, i + 0.025, j + 0.025, 0, bar + 6, W1, 'holz')
        B(i0 - 0.04, j - 0.015, i1 + 0.04, j + 0.015, bar, bar + 3, W1, 'holz')
        net = lin(0x3A3630); n = 12                         # Helfer: braune Tafel; jetzt Maschen aus Schnur, Korken am Fuss
        def at(u, w):                                       # u laengs, w 0 Fuss .. 1 Stange; Fuss haengt durch
            foot = (0.12 if v == 1 else 0.2) - 0.12 * math.sin(math.pi * u) + (0.1 * u if v == 2 else 0.0)
            return P(i0 + (i1 - i0) * u, j, bar * (foot + (1 - foot) * w))
        um = 0.5 if v == 2 else 1.0
        with use('weiss'):
            for k in range(n + 1):
                u = um * k / n; a_, b_ = at(u, 0), at(u, 1)
                box(DORF, (a_.x - 0.4, a_.y - 0.4, a_.z), (a_.x + 0.4, a_.y + 0.4, b_.z), net)
                box(DORF, (a_.x - 2, a_.y - 2, a_.z - 2), (a_.x + 2, a_.y + 2, a_.z + 2), lin(0xA88A5A))
            for q in range(1, 8):
                for k in range(n):
                    a_, b_ = at(um * k / n, q / 8), at(um * (k + 1) / n, q / 8)
                    box(DORF, (min(a_.x, b_.x), a_.y - 0.4, min(a_.z, b_.z) - 0.4), (max(a_.x, b_.x), a_.y + 0.4, max(a_.z, b_.z) + 0.4), net)
        kj = next((k for k in (-0.76, -0.24, j - 0.3, j + 0.3) if -0.85 <= k <= -0.15 and abs(k - j) > 0.2 and dry(-0.3, k)), -0.76)
        if v == 1:
            with use('holz'): cylinder(DORF, P(-0.3, kj), 0.1 * TS, 12 * U, 10, wood, r2=0.12 * TS)
        if v == 2:
            with use('weiss'): cylinder(DORF, P(-0.3, kj), 0.1 * TS, 5 * U, 10, lin(0x8A7A56))
def outer_tree(c, r, at=None):
    """Baum im Waldring; 348.6 (Befund 6: Klumpen, Staemme in Reihe): wie MapFlora.objects ein Drittel Fichten, Eichen in
    drei Groessen, in der Kachel um 0,35 versetzt"""
    p = (at if at is not None else tile_c(c, r)) + Vector((rnd.uniform(-0.35, 0.35) * TS, rnd.uniform(-0.35, 0.35) * TS, 0))
    k0 = 13 if at is not None else 0
    g = (0.82, 1.0, 1.15)[int(h1(c, r, 3 + k0) * 3)]
    if h1(c, r, 2 + k0) < 0.3:
        spruce(DORF, p, 82 * g, c * 41 + r * 7 + k0); return          # Lauf 15: Spitzen stachen aus den Eichenkronen
    with use('rinde'): cylinder(DORF, p, 16 * g, 230 * g, 6, (0.6, 0.6, 0.6), cap=False, r2=10 * g)
    oak_crown(DORF, p + Vector((0, 0, 240 * g)), 110 * g, sc(LEAF_OL if h1(c, r, 4 + k0) < 0.25 else LEAF_L, 0.9), c * 7 + r * 3 + k0,
              squash=0.74 + 0.07 * int(h1(c, r, 5 + k0) * 3), clumps=7)
def bush(c, r):
    """niedriger Busch wie MapWoodIso.bushObj: am Suedrand der Kachel, etwas versetzt"""
    p = tile_c(c, r) + Vector(((h1(c, r, 22) - 0.5) * TS * 0.5, -TS * 0.35, 0))
    with use('laub'):
        for k in range(3):
            q = p + Vector(((k - 1) * 18 + rnd.uniform(-6, 6), rnd.uniform(-8, 8), 32 + rnd.uniform(-6, 10)))
            blob(DORF, q, rnd.uniform(26, 34) if k != 1 else 38, lambda v, n: mixc((0.15, 0.22, 0.13), (0.45, 0.6, 0.36), max(0.0, n.x * 0.55 + n.z * 0.7) * 0.8), sub=1, squash=0.8, seed=k + c * 5 + r * 11)
def young(c, r, k):
    """junge Fichte wie MapFlora.spruce(young): etwas groesser als ein Mensch, im Sueden der Kachel"""
    p = tile_c(c, r) + Vector(((h1(c, r, 18 + k) - 0.5) * TS * 0.6, -TS * (h1(c, r, 20 + k) * 0.3 - 0.05), 0))
    hh = 190 + 50 * h1(c, r, 6 + k)
    spruce(DORF, p, hh / 3.5, c * 53 + r * 5 + k, tiers=4)
def low(c, r, art):
    if art == 'busch': bush(c, r)
    else:
        for k in range(2 if art == 'jung2' else 1): young(c, r, k)
# 348.6 (Befund 4, Fluss an der Kirche unter Kronen): Bewuchs und Waldring wie das alte Spiel aus dem Export
# (MapFlora.shades: niedrig, wo eine hohe Krone Wichtiges verdeckt; MapEdge.spot: frei vor Wegen und Wasser, Hecke vor Feldern)
LOW = {(x, y): a for x, y, a in K.get('bewuchs', [])}
for x, y, art in K.get('ring', []):                                         # Waldrand: Baeume um die Karte (Rahmen wie im Spiel)
    if art.startswith('baum'):
        d = max(C0 - x, x - C1, R0 - y, y - R1)
        if d > 4: continue                                                      # weiter draussen sieht die Kamera nicht hin
        outer_tree(x, y)
        if art == 'baum2' and d <= 2:                                                      # dichter als innen: zweiter Baum, halbe Kachel versetzt (nur vorn: Dreiecke)
            p0 = tile_c(x, y); outer_tree(x, y, p0 + Vector((-TS / 2, TS / 2, 0)))
    else: low(x, y, art)
qq = []
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        t = ch(c, r)
        if t == 'w': well(c, r)
        elif t == 'm' and ch(c - 1, r) != 'm': stall(c, r, c)
        elif t == 'l': lamp(c, r)
        elif t == 'n': bench(c, r)
        elif t == 'b': barrel(c, r)
        elif t == 'T': low(c, r, LOW[(c, r)]) if (c, r) in LOW else tree(c, r)
        elif t == 'f': flowers(c, r)
        elif t == 'q': qq.append((c, r))
        elif t == 'S': sign(c, r)
        elif t == '!': notice(c, r)
        elif t == 'y': hay(c, r)
        elif t == 'p': yard(c, r)
if qq: washline(qq)
# Sonderlaternen (MapTownIso.BRIDGE_LANTERN, KAEL_LANTERN; Licht wie MapLight.kt:104-105)
if os.environ.get('KARTE', 'village') == 'village':
    lamp(19, 27, Vector((tx(19) + 0.16 * TS, ty(27) - 0.86 * TS, 0)), eiche=True, reich=2.4, kraft=0.8)
    kael_lantern(24, 6)
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        t = ch(c, r); p = tile_c(c, r)
        if t == 'x':
            with use('holz'):
                box(DORF, (p.x - 6, p.y - 6, 0), (p.x + 6, p.y + 6, 105), W1)
                for zz in (36, 78):
                    if ch(c + 1, r) == 'x': box(DORF, (p.x, p.y - 3, zz - 4), (p.x + TS, p.y + 3, zz + 4), W1)
                    if ch(c, r + 1) == 'x': box(DORF, (p.x - 3, p.y - TS, zz - 4), (p.x + 3, p.y, zz + 4), W1)
        elif t == 'z':
            # 348.6 (Befund 7): wie MapTownIso.barrier: Eichenbalken in Hufthoehe ueber zwei Kacheln, im Westen auf dem Drehpfosten
            # mit Eisenkappe und Bolzen, im Osten in der Gabel; Eisenbaender an den Enden (Masse in Kachel -1..0, Hoehe in U)
            def B(i0, j0, i1, j1, z0, z1, col, m):
                with use(m): box(DORF, (tx(c) + (i0 + 1) * TS, ty(r) - (j1 + 1) * TS, z0 * U), (tx(c) + (i1 + 1) * TS, ty(r) - (j0 + 1) * TS, z1 * U), col)
            iron = lin(0x262422); oak = ratio(0x6A5238, 0x5A4430); post = ratio(0x463424, 0x5A4430)
            if ch(c - 1, r) != 'z':
                B(-0.86, -0.6, -0.74, -0.48, 0, 84, post, 'holz'); B(-0.87, -0.61, -0.73, -0.47, 84, 86, iron, 'weiss')
                B(-0.73, -0.55, 0.0, -0.45, 54, 66, oak, 'holz'); B(-0.74, -0.57, -0.64, -0.43, 53.3, 66.7, iron, 'weiss')
            else:
                B(-0.35, -0.62, -0.25, -0.56, 0, 70, post, 'holz'); B(-0.35, -0.58, -0.25, -0.42, 0, 54, post, 'holz')
                B(-0.35, -0.44, -0.25, -0.38, 0, 70, post, 'holz')
                B(-1.0, -0.55, -0.16, -0.45, 54, 66, oak, 'holz'); B(-0.26, -0.56, -0.2, -0.44, 53.3, 66.7, iron, 'weiss')
        elif t == 'h':
            with use('bretter'): box(DORF, (p.x - TS / 2 - 1, p.y - TS / 2 - 1, -6), (p.x + TS / 2 + 1, p.y + TS / 2 + 1, 4), W1)
            with use('holz'):
                for s in (-1, 1):
                    if ch(c + s, r) != 'h':
                        box(DORF, (p.x + s * 54 - 4, p.y - TS / 2, 4), (p.x + s * 54 + 4, p.y + TS / 2, 10), W1)
                        for zz in (42, 80): box(DORF, (p.x + s * 54 - 3, p.y - TS / 2, zz), (p.x + s * 54 + 3, p.y + TS / 2, zz + 6), W1)
                        box(DORF, (p.x + s * 54 - 5, p.y - 5, 4), (p.x + s * 54 + 5, p.y + 5, 90), W1)
        elif t == 'v':
            with use('erde'):
                for k in range(3):
                    y0 = p.y - TS / 2 + 8 + k * 36
                    box(DORF, (p.x - TS / 2, y0, 0), (p.x + TS / 2, y0 + 22, 10), (0.7, 0.65, 0.6))
            with use('laub'):
                for k in range(3):
                    for j in range(3):
                        blob(DORF, Vector((p.x - 38 + j * 38, p.y - TS / 2 + 19 + k * 36, 22)), 15, (0.75, 1.2, 0.7), sub=1, squash=0.8, seed=k * 3 + j + c)
        elif t == 'c':
            LIGHTS.append(dict(art='korn', pos=[p.x, p.y, 0]))

# ---------------------------------------------------------------- Netze bauen: je Teil ein Netz, je Textur ein Material
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
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v * 0.01) for v in P.V], [], P.F)   # Modellregel 1: Ausgabe in Metern
    names = sorted(set(P.M)); idx = {n: k for k, n in enumerate(names)}
    for n in names: me.materials.append(material(n))
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
    for k, poly in enumerate(me.polygons):
        poly.material_index = idx[P.M[k]]; poly.use_smooth = k in P.S
        for j, li in enumerate(poly.loop_indices):
            vi = me.loops[li].vertex_index; c = P.C[vi]
            ca.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    print('NETZ', name, len(me.polygons), 'Flaechen', names)
    return o
objs = [build(DORF, 'Dorf_Netz'), build(GLAS, 'Dorf_Glas'), build(WASSER, 'Dorf_Wasser'), build(BODEN, 'Dorf_Boden')]

walk = [[1 if ch(c, r) in WALK else 0 for c in range(C0, C1 + 1)] for r in range(R0, R1 + 1)]
LICHTER_M = [dict(l, pos=[x * 0.01 for x in l['pos']]) for l in LIGHTS]
info = dict(kachel_m=TS / 100.0, spalten=NC, zeilen=NR, ursprung=dict(spalte=C0, zeile=R0), begehbar=walk,
            karte=[ROWS[r][C0:C1 + 1] for r in range(R0, R1 + 1)], lichter=LICHTER_M,
            hinweis='Meter; Blender: x = Spalte * Kachel, y = -Zeile * Kachel (Norden +Y); in glTF/Godot: x gleich, z = +Zeile * Kachel')
json.dump(info, open(OUT + '/dorf-info.json', 'w'), indent=0)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=OUT + '/dorf.glb', export_format='GLB', use_selection=True, export_vertex_color='ACTIVE',
                          export_yup=True, export_image_format='AUTO')
print('GLB OK', os.path.getsize(OUT + '/dorf.glb'))
