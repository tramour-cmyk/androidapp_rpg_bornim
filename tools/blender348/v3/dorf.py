# 348.5: Dorf Bornim fuer die Engine mit gemalten Texturen, ganze Karte "village" aus core/.../Story.kt,
# Haeuser wie MapTownIso.kt (Fachwerk, Putz, Bretter, Feldsteinsockel, Stroh, Schindel, Schiefer, Ziegel), Boden wie MapGround.kt.
# Netze: Dorf (Materialien je Textur aus tex.py, Eckfarbe 'albedo' = Toenung), Glas (nachts leuchtend), Wasser, Boden (eigene Maske).
# Ausgabe dorf.glb (Zentimeter, Kachel 116 cm), boden-maske.png (Erde, Pflaster, Schatten je Ort), dorf-info.json.
# Aufruf: OUT=<ordner> python -I dorf.py   (vorher tex.py mit demselben OUT)
import bpy, bmesh, math, os, re, json, random
import numpy as np
from mathutils import Vector, Matrix
from PIL import Image, ImageFilter

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
os.makedirs(OUT, exist_ok=True)
TS = 116.0
src = open(ROOT + '/core/src/main/kotlin/de/bornim/core/Story.kt').read()
i = src.index('id = "village"'); blk = src[i:src.index('npcs = listOf(', i)]
ROWS = re.findall(r'"([^"]{36})"', src[i:src.index('),', src.index('rows = listOf(', i))])
R0, R1, C0, C1 = 0, len(ROWS) - 1, 0, 35
WALK = set('.,f=DoCEh_+kRJgj%e')            # begehbar wie World.kt (Tile(..., true))
def ch(c, r): return ROWS[r][c] if R0 <= r <= R1 and C0 <= c <= C1 else 'T'
def tx(c): return (c - C0) * TS
def ty(r): return -(r - R0) * TS                 # Blender: Norden = +Y; Kachel (c, r) ab (tx, ty) nach +X / -Y

bpy.ops.wm.read_factory_settings(use_empty=True)
rnd = random.Random(348)
def hx(c): return ((c >> 16) & 255) / 255, ((c >> 8) & 255) / 255, (c & 255) / 255
def lin(c):
    return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in hx(c))
def mixc(a, b, t): return tuple(x + (y - x) * t for x, y in zip(a, b))
def sc(a, k): return tuple(min(1.0, x * k) for x in a)
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
             rinde=120, laub=160, stoff=100, heu=120, weiss=100, erde=232)
GRAIN = {'holz', 'balken', 'rinde'}            # Maserung laengs der laengsten Kante
CUR = ['weiss']
class use:
    def __init__(self, m): self.m = m
    def __enter__(self): self.prev = CUR[0]; CUR[0] = self.m
    def __exit__(self, *a): CUR[0] = self.prev

class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.M = []; self.UV = []
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
def blob(P, c, r, col, sub=2, squash=1.0, seed=0):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in bm.verts:
        k = 1 + 0.22 * (vn(v.co.x * 2 + seed, v.co.y * 2 + v.co.z, seed) - 0.5)
        v.co = Vector((v.co.x * r * k, v.co.y * r * k, v.co.z * r * k * squash)) + c
    bm.normal_update()
    for f in bm.faces:
        pts = [v.co.copy() for v in f.verts]
        n0 = len(P.V); P.V += pts; P.F.append(tuple(range(n0, n0 + len(pts))))
        P.C += [col(v.co, f.normal) if callable(col) else col for v in f.verts]
        P.UV.append([proj_uv(p, f.normal, CUR[0]) for p in pts]); P.M.append(CUR[0])
    bm.free()

# ---------------------------------------------------------------- Boden: Netz (Hoehe am Wasser) und Maske 16 px je Kachel
NC, NR = C1 - C0 + 1, R1 - R0 + 1
WATER = set('~')
def vh(gx, gy):
    """Hoehe einer Bodenecke (halbe Kacheln): im Wasser tief, am Ufer Boeschung"""
    tiles = [ch(C0 + (gx + dx) // 2, R0 + (gy + dy) // 2) for dx in (-1, 0) for dy in (-1, 0)]
    return -34.0 if all(t in WATER for t in tiles) else 0.0
for gy in range(NR * 2):
    for gx in range(NC * 2):
        pts = []
        for (ex, ey) in ((gx, gy + 1), (gx + 1, gy + 1), (gx + 1, gy), (gx, gy)):
            pts.append(Vector((tx(C0) + ex * TS / 2, ty(R0) - ey * TS / 2, vh(ex, ey))))
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
bank = sst(0.2, 0.45, up(tilemask('~'), 7)) * (1 - up(tilemask('~'), 0))
earth = np.clip(np.maximum.reduce([path, yard * 0.85, bare, field, bank]), 0, 1) * (1 - cob)
shade = up(tilemask('T'), 14) * 0.6 + 0.25 * sst(0.55, 0.8, fbm2(1.5, 11))
mask = np.stack([earth, cob, np.clip(shade, 0, 1), np.ones_like(earth)], 2)
Image.fromarray((mask * 255).astype(np.uint8)).save(OUT + '/boden-maske.png')

# Wasser: Flaeche knapp unter dem Ufer
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        if ch(c, r) not in WATER: continue
        x0, y0 = tx(c) - 2, ty(r) - TS - 2
        add_face(WASSER, [Vector((x0, y0, -10)), Vector((x0 + TS + 4, y0, -10)), Vector((x0 + TS + 4, y0 + TS + 4, -10)), Vector((x0, y0 + TS + 4, -10))],
                 W1, [((x0) / 200, y0 / 200), ((x0 + TS) / 200, y0 / 200), ((x0 + TS) / 200, (y0 + TS) / 200), (x0 / 200, (y0 + TS) / 200)], m='wasser')

# ---------------------------------------------------------------- Haeuser (MapTownIso.kt)
LOOKS = [dict(plaster=0x8C8270, timber=0x3E2E22, thatch=0x7A6C4E, moss=0.55, stoneTo=0.0),
         dict(plaster=0x82745A, timber=0x2C2018, thatch=0x6A5C42, moss=0.3, stoneTo=0.0),
         dict(plaster=0x86807A, timber=0x3A2C22, thatch=0x5E5644, moss=0.75, stoneTo=120.0)]
STYLE = {}
for k_, (cx_, cy_, rf_, wl_) in enumerate(re.findall(r'\((\d+) to (\d+)\) to HouseStyle\(RoofKind\.(\w+), WallKind\.(\w+)', blk)):
    STYLE[(int(cx_), int(cy_))] = (rf_, wl_, k_ % 3)
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
def house(cells, style):
    roof, walls, li = style; lk = LOOKS[li]
    cs = [c for c, _ in cells]; rs = [r for _, r in cells]
    c0, c1, r0, r1 = min(cs), max(cs), min(rs), max(rs)
    x0, x1 = tx(c0) + 6, tx(c1) + TS - 6
    yf = ty(r1) - TS + 18; yb = ty(r0) - 6                     # Vorderseite (Sued) mit Tueren und Fenstern
    W, D = x1 - x0, yb - yf; eave = 260.0; ridge = eave + D / 2 * (1.25 if roof == 'STRAW' else 1.0)
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
        if t == 'D':
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
    if roof != 'STRAW':  # Schornstein (Feldstein, oben verrusst)
        cx = x0 + W * 0.72
        with use('feldstein'):
            box(DORF, (cx - 22, ym + 10, ridge - 60), (cx + 22, ym + 54, ridge + 72), lambda p, n: sc(W1, 1 - 0.55 * ss(ridge, ridge + 72, p.z)), sub=(1, 1, 3))
        with use('weiss'): box(DORF, (cx - 14, ym + 18, ridge + 72), (cx + 14, ym + 46, ridge + 74), lin(0x0A0806))
        LIGHTS.append(dict(art='rauch', pos=[cx, ym + 32, ridge + 76]))
    # Holzstoss an der Giebelseite
    if (c0 + r0) % 2 == 0:
        with use('holz'):
            for k in range(14):
                yy_ = yf + 20 + (k % 7) * 15; zz_ = 8 + (k // 7) * 15
                cylinder(DORF, Vector((x1 + 10, yy_, zz_)), 7, 0.1, 6, lambda p, n: sc(lin(0x8A6A48), 2.0), cap=False)
                M = Matrix.Translation((x1 + 30, yy_, zz_)) @ Matrix.Rotation(math.radians(90), 4, 'Y')
                box(DORF, (-24, -7, -7), (24, 7, 7), lambda p, n: sc(W1, 0.8 + 0.3 * h1(k, 3, 9)), M=M)
    return (c0, c1, r0, r1)
HOUSES = []
for cells in comps():
    st = next((v for (sx, sy), v in STYLE.items() if (sx, sy) in cells), None) or ('STRAW', 'TIMBER', 0)
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
def lamp(c, r):
    p = tile_c(c, r)
    with use('feldstein'): box(DORF, (p.x - 18, p.y - 18, 0), (p.x + 18, p.y + 18, 22), W1)
    with use('balken'): box(DORF, (p.x - 6, p.y - 6, 22), (p.x + 6, p.y + 6, 260), W1)
    with use('weiss'):
        box(DORF, (p.x - 14, p.y - 14, 252), (p.x + 14, p.y + 14, 256), lin(0x5A5C60))
        box(DORF, (p.x - 15, p.y - 15, 288), (p.x + 15, p.y + 15, 294), lin(0x5A5C60))
        box(DORF, (p.x - 6, p.y - 6, 294), (p.x + 6, p.y + 6, 306), lin(0x5A5C60))
        for sx in (-1, 1):
            for sy in (-1, 1): box(DORF, (p.x + sx * 12 - 1.5, p.y + sy * 12 - 1.5, 256), (p.x + sx * 12 + 1.5, p.y + sy * 12 + 1.5, 288), lin(0x5A5C60))
        box(GLAS, (p.x - 11, p.y - 11, 256), (p.x + 11, p.y + 11, 288), lin(0x8A7450))
    LIGHTS.append(dict(art='laterne', pos=[p.x, p.y, 272]))
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
def tree(c, r):
    p = tile_c(c, r) + Vector((rnd.uniform(-20, 20), rnd.uniform(-20, 20), 0))
    spruce = h1(c, r, 77) < 0.3
    with use('rinde'):
        cylinder(DORF, p, 18, 240 if not spruce else 300, 8, lambda q, n: sc(W1, 0.7 + 0.3 * ss(0, 60, q.z)), r2=10)
    if spruce:
        with use('laub'):
            for k in range(6):
                z = 110 + k * 46; rr = 120 - k * 18
                def col(v, n, k=k): return mixc((0.16, 0.26, 0.2), (0.38, 0.54, 0.38), max(0, n.z) * 0.6 + 0.4 * max(0, n.x * 0.55 - n.y * 0.7))
                cylinder(DORF, p + Vector((0, 0, z)), rr, 70, 10, col, cap=True, r2=8)
        return
    with use('laub'):
        cen = p + Vector((0, 0, 330))
        for k in range(9):
            a = rnd.uniform(0, 2 * math.pi); d = rnd.uniform(25, 70) if k else 0
            q = cen + Vector((math.cos(a) * d, math.sin(a) * d, rnd.uniform(-40, 50)))
            rr = rnd.uniform(48, 70) if k else 85
            def col(v, n, cz=cen.z):
                lit = max(0.0, n.x * 0.55 - n.y * 0.2 + n.z * 0.7) * 0.7 + 0.3 * ss(cz - 90, cz + 90, v.z)
                return mixc((0.16, 0.22, 0.14), (0.52, 0.66, 0.4), lit)
            blob(DORF, q, rr, col, sub=2 if k < 3 else 1, squash=0.85, seed=k + c * 13 + r)
def flowers(c, r):
    p = tile_c(c, r)
    for k in range(14):
        q = p + Vector((rnd.uniform(-50, 50), rnd.uniform(-50, 50), 0))
        with use('weiss'): cylinder(DORF, q, 1.2, 22, 4, lin(0x3E5A2A), cap=False)
        with use('weiss'): blob(DORF, q + Vector((0, 0, 24)), 4.5, lin(rnd.choice([0xD8C050, 0xA84A6A, 0xE8E0D0, 0x8A6AB8, 0xC8603A])), sub=1, seed=k)
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
    p = tile_c(c, r)
    with use('holz'):                                                       # Hackklotz und Karre
        cylinder(DORF, p + Vector((-25, 10, 0)), 20, 40, 10, W1)
        box(DORF, (p.x + 5, p.y - 30, 30), (p.x + 70, p.y + 10, 36), W1)
        for s in (-1, 1): box(DORF, (p.x + 5, p.y - 30 + (40 if s > 0 else 0) - 2, 36), (p.x + 70, p.y - 30 + (40 if s > 0 else 0) + 2, 56), W1)
    with use('weiss'):
        cylinder(DORF, p + Vector((-55, -30, 0)), 12, 22, 10, lin(0x6A5A48), r2=14)    # Eimer
    with use('holz'):
        for k in range(10):
            M = Matrix.Translation((p.x - 20 + rnd.uniform(-20, 20), p.y + 30 + rnd.uniform(-10, 10), 4)) @ Matrix.Rotation(rnd.uniform(0, 3), 4, 'Z')
            box(DORF, (-8, -2, -2), (8, 2, 2), (1.3, 1.2, 1.1), M=M)                # Spaene
def outer_tree(c, r):
    p = tile_c(c, r) + Vector((rnd.uniform(-30, 30), rnd.uniform(-30, 30), 0))
    with use('rinde'): cylinder(DORF, p, 16, 230, 6, (0.6, 0.6, 0.6), cap=False, r2=10)
    with use('laub'):
        cen = p + Vector((0, 0, 320))
        for k in range(4):
            q = cen + Vector((rnd.uniform(-50, 50), rnd.uniform(-50, 50), rnd.uniform(-30, 40)))
            blob(DORF, q, rnd.uniform(70, 95), lambda v, n: mixc((0.13, 0.18, 0.11), (0.42, 0.54, 0.33), max(0.0, n.x * 0.55 + n.z * 0.7) * 0.8), sub=1, squash=0.85, seed=k + c * 7 + r * 3)
for r in range(R0 - 4, R1 + 5):                                              # Waldrand: Baeume um die Karte (Rahmen wie im Spiel)
    for c in range(C0 - 4, C1 + 5):
        if R0 <= r <= R1 and C0 <= c <= C1: continue
        if h1(c, r, 91) < 0.55: outer_tree(c, r)
qq = []
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        t = ch(c, r)
        if t == 'w': well(c, r)
        elif t == 'm' and ch(c - 1, r) != 'm': stall(c, r, c)
        elif t == 'l': lamp(c, r)
        elif t == 'n': bench(c, r)
        elif t == 'b': barrel(c, r)
        elif t == 'T': tree(c, r)
        elif t == 'f': flowers(c, r)
        elif t == 'q': qq.append((c, r))
        elif t == 'S': sign(c, r)
        elif t == '!': notice(c, r)
        elif t == 'y': hay(c, r)
        elif t == 'p': yard(c, r)
if qq: washline(qq)
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
            with use('balken'): box(DORF, (p.x - 58, p.y - 7, 92), (p.x + 58, p.y + 7, 108), W1)
            with use('weiss'):
                for k in range(4): box(DORF, (p.x - 52 + k * 32, p.y - 8, 91), (p.x - 46 + k * 32, p.y + 8, 109), lin(0x2A2622))
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
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in P.V], [], P.F)
    names = sorted(set(P.M)); idx = {n: k for k, n in enumerate(names)}
    for n in names: me.materials.append(material(n))
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
    for k, poly in enumerate(me.polygons):
        poly.material_index = idx[P.M[k]]; poly.use_smooth = False
        for j, li in enumerate(poly.loop_indices):
            vi = me.loops[li].vertex_index; c = P.C[vi]
            ca.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    print('NETZ', name, len(me.polygons), 'Flaechen', names)
    return o
objs = [build(DORF, 'Dorf_Netz'), build(GLAS, 'Dorf_Glas'), build(WASSER, 'Dorf_Wasser'), build(BODEN, 'Dorf_Boden')]

walk = [[1 if ch(c, r) in WALK else 0 for c in range(C0, C1 + 1)] for r in range(R0, R1 + 1)]
info = dict(kachel_cm=TS, spalten=NC, zeilen=NR, ursprung=dict(spalte=C0, zeile=R0), begehbar=walk,
            karte=[ROWS[r][C0:C1 + 1] for r in range(R0, R1 + 1)],
            start=dict(spalte=19 - C0, zeile=13 - R0), lichter=LIGHTS,
            hinweis='Blender: x = Spalte * Kachel, y = -Zeile * Kachel (Norden +Y); in glTF/Godot: x gleich, z = +Zeile * Kachel')
json.dump(info, open(OUT + '/dorf-info.json', 'w'), indent=0)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=OUT + '/dorf.glb', export_format='GLB', use_selection=True, export_vertex_color='ACTIVE',
                          export_yup=True, export_image_format='AUTO')
print('GLB OK', os.path.getsize(OUT + '/dorf.glb'))
