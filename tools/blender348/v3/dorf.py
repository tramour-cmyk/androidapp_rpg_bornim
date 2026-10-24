# 348.4: Dorf Bornim fuer die Engine, ganze Karte "village" aus core/.../Story.kt,
# Haeuser wie MapTownIso.kt (Fachwerk, Putz, Bretter, Feldsteinsockel, Stroh mit Moos, Schindel, Schiefer).
# Ein Netz mit Eckfarben 'albedo' (linear), dazu 'Dorf_Glas' (Fenster, Laternen: nachts leuchtend) und Lichtpunkte als Leere.
# Ausgabe dorf.glb (Zentimeter, Kachel 116 cm) und dorf-info.json (begehbare Kacheln, Startpunkt, Lichter).
# Aufruf: OUT=<ordner> python -I dorf.py
import bpy, bmesh, math, os, re, json, random
from mathutils import Vector, Matrix

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
os.makedirs(OUT, exist_ok=True)
R0, R1, C0, C1 = 0, 30, 0, 35          # ganzes Dorf (Karte village)
TS = 116.0
src = open(ROOT + '/core/src/main/kotlin/de/bornim/core/Story.kt').read()
i = src.index('id = "village"'); blk = src[i:src.index('npcs = listOf(', i)]
ROWS = re.findall(r'"([^"]{36})"', src[i:src.index('),', src.index('rows = listOf(', i))])
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
def h1(x, y, s=0):
    n = (int(math.floor(x)) * 374761393 + int(math.floor(y)) * 668265263 + s * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFFFF) / float(0xFFFFFF)
def vn(x, y, s=0):
    ix, iy = math.floor(x), math.floor(y); u, v = x - ix, y - iy
    u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
    a = h1(ix, iy, s) * (1 - u) + h1(ix + 1, iy, s) * u; b = h1(ix, iy + 1, s) * (1 - u) + h1(ix + 1, iy + 1, s) * u
    return a * (1 - v) + b * v

# ---------------------------------------------------------------- Sammler: Teile mit Farbfunktion je Ecke (Weltposition, Normale)
class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []
DORF = Part(); GLAS = Part()
def add_quad(P, a, b, c, d, col):
    n = len(P.V); P.V += [a, b, c, d]; P.F.append((n, n + 1, n + 2, n + 3))
    nrm = (b - a).cross(d - a).normalized()
    P.C += [col(p, nrm) if callable(col) else col for p in (a, b, c, d)]
def grid(P, o, U, V, nu, nv, col):
    for i in range(nu):
        for j in range(nv):
            a = o + U * (i / nu) + V * (j / nv); b = o + U * ((i + 1) / nu) + V * (j / nv)
            c = o + U * ((i + 1) / nu) + V * ((j + 1) / nv); d = o + U * (i / nu) + V * ((j + 1) / nv)
            add_quad(P, a, b, c, d, col)
def box(P, lo, hi, col, sub=(1, 1, 1), M=None):
    lo = Vector(lo); hi = Vector(hi); s = hi - lo
    X, Y, Z = Vector((s.x, 0, 0)), Vector((0, s.y, 0)), Vector((0, 0, s.z))
    faces = [(lo, Y, X, sub[1], sub[0]), (lo + Z, X, Y, sub[0], sub[1]),                  # unten, oben
             (lo, X, Z, sub[0], sub[2]), (lo + Y, Z, X, sub[2], sub[0]),                  # sued, nord
             (lo, Z, Y, sub[2], sub[1]), (lo + X, Y, Z, sub[1], sub[2])]                  # west, ost
    n0 = len(P.V)
    for o, U, V, nu, nv in faces: grid(P, o, U, V, nu, nv, col)
    if M is not None:
        for k in range(n0, len(P.V)): P.V[k] = M @ P.V[k]
def cylinder(P, base, r, h, n, col, cap=True, r2=None):
    r2 = r if r2 is None else r2
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + Vector((math.cos(a0) * r, math.sin(a0) * r, 0)); p1 = base + Vector((math.cos(a1) * r, math.sin(a1) * r, 0))
        q0 = base + Vector((math.cos(a0) * r2, math.sin(a0) * r2, h)); q1 = base + Vector((math.cos(a1) * r2, math.sin(a1) * r2, h))
        add_quad(P, p0, p1, q1, q0, col)
        if cap: add_quad(P, base + Vector((0, 0, h)), q0, q1, base + Vector((0, 0, h)) + (q1 - q0) * 0.0001, col)
def blob(P, c, r, col, sub=2, squash=1.0, seed=0):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in bm.verts:
        k = 1 + 0.18 * (vn(v.co.x * 2 + seed, v.co.y * 2 + v.co.z, seed) - 0.5)
        v.co = Vector((v.co.x * r * k, v.co.y * r * k, v.co.z * r * k * squash)) + c
    for f in bm.faces:
        idx = [len(P.V) + i for i in range(len(f.verts))]
        P.V += [v.co.copy() for v in f.verts]; P.F.append(tuple(idx))
        P.C += [col(v.co, f.normal) if callable(col) else col for v in f.verts]
    bm.free()

# ---------------------------------------------------------------- Farben (sRGB wie MapTownIso.kt, hier linear)
GRASS = [lin(0x5E7A3A), lin(0x6A8442), lin(0x4E6A30)]
def grass_col(p, n):
    t = vn(p.x / 60, p.y / 60, 1) * 0.6 + vn(p.x / 17, p.y / 17, 2) * 0.4
    return mixc(mixc(GRASS[2], GRASS[1], t), GRASS[0], 0.3 * vn(p.x / 200, p.y / 200, 3))
def path_col(p, n):
    t = vn(p.x / 25, p.y / 25, 4)
    return mixc(lin(0x6E5A40), lin(0x8A7458), t)
def cobble_col(p, n):
    # Pflaster: Steine als Zellen (ca. 23 cm), Fugen dunkel
    u, v = p.x / 23.0, p.y / 23.0 + (0.5 if int(math.floor(p.x / 23.0)) % 2 else 0)
    fu, fv = u - math.floor(u), v - math.floor(v)
    edge = min(fu, 1 - fu, fv, 1 - fv)
    base = mixc(lin(0x6E6A62), lin(0x8E887C), h1(math.floor(u), math.floor(v), 5))
    return sc(base, 0.45) if edge < 0.09 else base
def cobble_mark(p, n):
    return mixc(lin(0x6E6A62), lin(0x8E887C), vn(p.x / 90, p.y / 90, 6)) + (0.0,)
def ground_col(c, r):
    t = ch(c, r)
    if t == 'o' or t in 'wmnl': return cobble_mark
    if t in '=D': return path_col
    if t == '~': return lambda p, n: mixc(lin(0x2A4A5A), lin(0x3A6070), vn(p.x / 80, p.y / 40, 7))
    if t == 'h': return lambda p, n: sc(lin(0x6A5038), 0.6) if (p.y / 18.0) % 1 < 0.12 else lin(0x6A5038)
    if t == 'c': return lambda p, n: lin(0x8A7A3A) if (p.y / 29.0) % 1 < 0.6 else lin(0x5A4A2A)
    if t == 'v': return lambda p, n: lin(0x4E6A30) if (p.x / 29.0) % 1 < 0.5 else lin(0x4A3A26)
    if t in 'py': return lambda p, n: mixc(lin(0x6E5A40), lin(0x5E7A3A), vn(p.x / 40, p.y / 40, 8))
    return grass_col
# Boden: je Kachel 6x6 Felder (Pflaster etwas hoeher als Gras)
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        t = ch(c, r); z = 2.0 if t in 'owmnl' else (-12.0 if t == '~' else 0.0)
        grid(DORF, Vector((tx(c), ty(r) - TS, z)), Vector((TS, 0, 0)), Vector((0, TS, 0)), 4, 4, ground_col(c, r))
# Rand: Kanten der Pflasterflaeche
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        if ch(c, r) not in 'owmnl': continue
        for dc, dr in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if ch(c + dc, r + dr) in 'owmnl': continue
            x0, y0 = tx(c), ty(r) - TS
            if dc == 1: a, b = Vector((x0 + TS, y0, 0)), Vector((x0 + TS, y0 + TS, 0))
            elif dc == -1: a, b = Vector((x0, y0 + TS, 0)), Vector((x0, y0, 0))
            elif dr == 1: a, b = Vector((x0, y0, 0)), Vector((x0 + TS, y0, 0))
            else: a, b = Vector((x0 + TS, y0 + TS, 0)), Vector((x0, y0 + TS, 0))
            add_quad(DORF, a, b, b + Vector((0, 0, 2)), a + Vector((0, 0, 2)), lin(0x4A463E))

# ---------------------------------------------------------------- Haeuser
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
def stone_col(p, n, k=1.0):
    # Feldsteine: unregelmaessige Zellen
    u, v = (p.x + p.y) / 26.0, p.z / 17.0
    off = 0.5 if int(math.floor(v)) % 2 else 0.0
    fu, fv = (u + off) - math.floor(u + off), v - math.floor(v)
    e = min(fu, 1 - fu, fv, 1 - fv)
    base = mixc(lin(0x5E5A52), lin(0x8A8478), h1(math.floor(u + off), math.floor(v), 9))
    if vn(p.x / 40, p.z / 30, 10) > 0.62: base = mixc(base, lin(0x3E4A26), 0.5)
    return sc(base, 0.4 * k) if e < 0.1 else sc(base, k)
def house(cells, style):
    roof, walls, li = style; lk = LOOKS[li]
    cs = [c for c, _ in cells]; rs = [r for _, r in cells]
    c0, c1, r0, r1 = min(cs), max(cs), min(rs), max(rs)
    x0, x1 = tx(c0) + 6, tx(c1) + TS - 6
    yf = ty(r1) - TS + 18; yb = ty(r0) - 6                     # Vorderseite (Sued) mit Tueren und Fenstern
    W, D = x1 - x0, yb - yf; eave = 260.0; ridge = eave + D / 2 * 1.05
    plaster = lin(lk['plaster']); timber = lin(lk['timber'])
    def wall_col(p, n):
        z = p.z
        if z < 40 or z < lk['stoneTo'] or walls == 'STONE': return stone_col(p, n)
        if walls == 'PLANKS':
            k = math.floor(z / 19.0); t = h1(k, math.floor((p.x + p.y) / 90), 12)
            c = mixc(lin(0x5A4430), lin(0x7A5E40), t)
            return sc(c, 0.55) if (z / 19.0) % 1 < 0.08 else c
        t = vn(p.x / 30 + p.y / 30, z / 30, 13)
        return mixc(sc(plaster, 0.86), plaster, t)
    # Waende (unterteilt fuer Muster)
    nx, nz = max(4, int(W / 15)), int(eave / 10)
    grid(DORF, Vector((x0, yf, 0)), Vector((W, 0, 0)), Vector((0, 0, eave)), nx, nz, wall_col)                 # sued
    grid(DORF, Vector((x1, yb, 0)), Vector((-W, 0, 0)), Vector((0, 0, eave)), nx, nz, wall_col)                # nord
    for xs, sgn in ((x0, -1), (x1, 1)):                                                                       # Giebel
        a = Vector((xs, yf if sgn > 0 else yb, 0)); U = Vector((0, D * sgn, 0))
        grid(DORF, a, U, Vector((0, 0, eave)), max(3, int(D / 15)), nz, wall_col)
        P = DORF; n = len(P.V)
        g0 = Vector((xs, yf, eave)); g1 = Vector((xs, yb, eave)); g2 = Vector((xs, (yf + yb) / 2, ridge))
        tri = [g0, g1, g2] if sgn > 0 else [g1, g0, g2]
        P.V += tri; P.F.append((n, n + 1, n + 2)); gc = lin(lk['timber']) if walls != 'TIMBER' else plaster
        P.C += [wall_col(v, None) if walls != 'TIMBER' else plaster for v in tri]
    # Fachwerk: Balken vor der Wand
    if walls == 'TIMBER':
        bt = timber
        for xs in [x0 + k * (W / round(W / 110)) for k in range(int(round(W / 110)) + 1)]:
            box(DORF, (xs - 6, yf - 4, 40), (xs + 6, yf + 1, eave), bt)
        for zz in (40, 150, eave - 10):
            box(DORF, (x0, yf - 4, zz - 5), (x1, yf + 1, zz + 5), bt)
        for k in range(int(round(W / 110))):
            a = x0 + k * (W / round(W / 110)); b = a + W / round(W / 110)
            # Andreaskreuz-Strebe im Obergeschoss
            M = Matrix.Translation(((a + b) / 2, yf - 1.5, 200)) @ Matrix.Rotation(math.atan2(95, b - a) * (1 if k % 2 else -1), 4, 'Y')
            box(DORF, (-(b - a) / 2 * 1.1, -2.5, -4), ((b - a) / 2 * 1.1, 2.5, 4), bt, M=M)
    # Tueren und Fenster nach der Frontzeile
    for c in range(c0, c1 + 1):
        t = ch(c, r1); cx = tx(c) + TS / 2
        if t == 'D':
            box(DORF, (cx - 42, yf - 10, 0), (cx + 42, yf + 2, 205), lin(0x2E2218))                        # Rahmen
            box(DORF, (cx - 34, yf - 12, 0), (cx + 34, yf - 8, 196), lambda p, n: mixc(lin(0x4A3022), lin(0x665C4A), 0.3 * (int((p.x - cx) / 11) % 2)))
            box(DORF, (cx - 45, yf - 30, 0), (cx + 45, yf, 8), lambda p, n: stone_col(p, n, 0.9))           # Schwelle
        elif t == 'W':
            for zz in (95,) if eave < 200 else (95,):
                box(DORF, (cx - 34, yf - 8, zz - 6), (cx + 34, yf + 2, zz + 76), lin(0x2E2218))
                box(GLAS, (cx - 27, yf - 10, zz), (cx + 27, yf - 6, zz + 70), lin(0x1A2028))
                box(DORF, (cx - 2.5, yf - 12, zz), (cx + 2.5, yf - 9, zz + 70), lin(0x2E2218))
                box(DORF, (cx - 27, yf - 12, zz + 33), (cx + 27, yf - 9, zz + 37), lin(0x2E2218))
                LIGHTS.append(dict(art='fenster', pos=[cx, yf - 30, zz + 40]))
    # Dach (Satteldach, Traufe vorn und hinten, Ueberstand 30 cm)
    o = 30.0; th = 32.0 if roof == 'STRAW' else 10.0
    def roof_col(p, n):
        s = math.hypot(p.y - (yf + yb) / 2, 0)
        if roof == 'STRAW':
            t = vn(p.x / 6, p.z / 40, 20) * 0.6 + vn(p.x / 30, p.z / 12, 21) * 0.4
            c = mixc(sc(lin(lk['thatch']), 0.55), lin(lk['thatch']), t)
            if vn(p.x / 70, p.y / 50 + p.z / 50, 22) < lk['moss'] * 0.55: c = mixc(c, lin(0x4A5A2C), 0.55)
            return c
        if roof == 'SHINGLE':
            k = math.floor(p.z / 14.0); u = (p.x + (k % 2) * 9) / 18.0
            c = mixc(lin(0x5A4430), lin(0x7A5A3E), h1(math.floor(u), k, 23))
            return sc(c, 0.5) if (u % 1) < 0.07 or (p.z / 14.0) % 1 < 0.1 else c
        k = math.floor(p.z / 12.0); u = (p.x + (k % 2) * 13) / 26.0
        c = mixc(lin(0x464A52), lin(0x6A6E76), h1(math.floor(u), k, 24))
        return sc(c, 0.5) if (u % 1) < 0.05 or (p.z / 12.0) % 1 < 0.1 else c
    ym = (yf + yb) / 2; dz = (eave - (ridge - eave) * o / (D / 2))
    for y_e, sgn in ((yf - o, 1), (yb + o, -1)):
        e = Vector((x0 - o, y_e, dz)); rv = Vector((x0 - o, ym, ridge + th * 0.3))
        U = Vector((W + 2 * o, 0, 0)); V = rv - e
        nu, nv = max(4, int((W + 2 * o) / 12)), max(4, int(V.length / 10))
        if sgn > 0: grid(DORF, e + Vector((0, 0, th)), U, V, nu, nv, roof_col)
        else: grid(DORF, e + U + Vector((0, 0, th)), -U, V, nu, nv, roof_col)
        # Traufkante (Dicke)
        add_quad(DORF, e, e + U, e + U + Vector((0, 0, th)), e + Vector((0, 0, th)), sc(roof_col(e, None), 0.6)) if sgn > 0 else \
            add_quad(DORF, e + U, e, e + Vector((0, 0, th)), e + U + Vector((0, 0, th)), sc(roof_col(e, None), 0.6))
    for xs, sgn in ((x0 - o, -1), (x1 + o, 1)):   # Ortgang: Dachdicke an den Giebeln
        for y_e in (yf - o, yb + o):
            a = Vector((xs, y_e, dz)); b = Vector((xs, ym, ridge + th * 0.3))
            q = [a, b, b + Vector((0, 0, th)), a + Vector((0, 0, th))]
            if (sgn > 0) == (y_e < ym): q = q[::-1]
            add_quad(DORF, *q, sc(roof_col(a, None), 0.55))
    box(DORF, (x0 - o, ym - 9, ridge + th * 0.3 - 2), (x1 + o, ym + 9, ridge + th * 0.3 + 12), sc(roof_col(Vector((x0, ym, ridge)), None), 0.7))
    if roof != 'STRAW':  # Schornstein
        cx = x0 + W * 0.72
        box(DORF, (cx - 22, ym + 10, ridge - 60), (cx + 22, ym + 50, ridge + 70), lambda p, n: stone_col(p, n, 0.9), sub=(2, 2, 6))
    return (c0, c1, r0, r1)
HOUSES = []
for cells in comps():
    cs = [c for c, _ in cells]; rs = [r for _, r in cells]
    st = next((v for (sx, sy), v in STYLE.items() if (sx, sy) in cells), None) or ('STRAW', 'TIMBER', 0)
    if st[0] == 'BLUE': st = ('SLATE', st[1], st[2])
    HOUSES.append(house(cells, st))

# ---------------------------------------------------------------- Dinge auf dem Platz
WOOD = lin(0x5A4430); WOODD = lin(0x3A2A1C); IRON = lin(0x2A2A2C)
def tile_c(c, r): return Vector((tx(c) + TS / 2, ty(r) - TS / 2, 2))
def well(c, r):
    p = tile_c(c, r)
    cylinder(DORF, p, 62, 72, 18, lambda q, n: stone_col(q, n))
    cylinder(DORF, p + Vector((0, 0, 72)), 64, 8, 18, lambda q, n: stone_col(q, n, 1.1))
    cylinder(DORF, p + Vector((0, 0, 60)), 50, 1, 18, lin(0x10181C), cap=True)                         # Wasser tief unten
    for s in (-1, 1):
        box(DORF, (p.x + s * 58 - 6, p.y - 6, 70), (p.x + s * 58 + 6, p.y + 6, 220), WOOD)
    box(DORF, (p.x - 60, p.y - 3, 168), (p.x + 60, p.y + 3, 174), WOODD)                              # Haspel
    for s in (-1, 1):
        M = Matrix.Translation((p.x, p.y + s * 30, 232)) @ Matrix.Rotation(math.radians(32 * s), 4, 'X')
        box(DORF, (-80, -36, -3), (80, 36, 4), lambda q, n: mixc(lin(0x5A4430), lin(0x7A5A3E), h1(q.x // 16, 0, 30)), M=M)
    box(DORF, (p.x - 4, p.y - 4, 120), (p.x + 4, p.y + 4, 168), lin(0x8A7A5A))                         # Seil
    box(DORF, (p.x - 12, p.y - 12, 100), (p.x + 12, p.y + 12, 122), WOODD)                             # Eimer
CLOTH = [(0xA83A2A, 0xD8CCA8), (0x3E6A3A, 0xD8CCA8), (0x2E4A7A, 0xD8CCA8)]
def stall(c, r, k):
    p = tile_c(c, r) + Vector((TS / 2, 0, 0))                                                          # zwei Kacheln breit
    w, d = 100, 45
    box(DORF, (p.x - w, p.y - d, 70), (p.x + w, p.y + d, 80), WOOD)
    box(DORF, (p.x - w + 5, p.y - d + 5, 0), (p.x + w - 5, p.y + d - 5, 70), lin(0x7A5E40))
    for sx in (-1, 1):
        for sy in (-1, 1):
            box(DORF, (p.x + sx * (w - 4) - 4, p.y + sy * (d + 10) - 4, 0), (p.x + sx * (w - 4) + 4, p.y + sy * (d + 10) + 4, 205 + 25 * sy), WOOD)
    a, b = CLOTH[k % 3]
    M = Matrix.Translation((p.x, p.y, 218)) @ Matrix.Rotation(math.radians(-14), 4, 'X')
    ns = 9; sw_ = (2 * w + 30) / ns
    for k_ in range(ns):
        box(DORF, (-w - 15 + k_ * sw_, -d - 25, 0), (-w - 15 + (k_ + 1) * sw_, d + 25, 3), lin(a) if k_ % 2 else lin(b), M=M)
    for i in range(7):                                                                                  # Ware: Aepfel, Kohl, Kisten
        x = p.x - w + 22 + i * 27
        if i % 3 == 2: box(DORF, (x - 12, p.y - 20, 80), (x + 12, p.y + 20, 100), lin(0x7A5E40))
        else: blob(DORF, Vector((x, p.y - 15 + 10 * (i % 2), 92)), 11, lin(0x9A2A1A) if k % 2 else lin(0x6A8A3A), sub=1, seed=i)
def lamp(c, r):
    p = tile_c(c, r)
    box(DORF, (p.x - 16, p.y - 16, 0), (p.x + 16, p.y + 16, 20), lambda q, n: stone_col(q, n))
    box(DORF, (p.x - 5, p.y - 5, 20), (p.x + 5, p.y + 5, 250), IRON)
    box(DORF, (p.x - 14, p.y - 14, 250), (p.x + 14, p.y + 14, 254), IRON)
    box(GLAS, (p.x - 11, p.y - 11, 254), (p.x + 11, p.y + 11, 286), lin(0x3A3024))
    box(DORF, (p.x - 15, p.y - 15, 286), (p.x + 15, p.y + 15, 292), IRON)
    box(DORF, (p.x - 6, p.y - 6, 292), (p.x + 6, p.y + 6, 304), IRON)
    LIGHTS.append(dict(art='laterne', pos=[p.x, p.y, 270]))
def bench(c, r):
    p = tile_c(c, r)
    box(DORF, (p.x - 55, p.y - 16, 40), (p.x + 55, p.y + 16, 46), WOOD)
    for s in (-1, 1): box(DORF, (p.x + s * 45 - 5, p.y - 14, 0), (p.x + s * 45 + 5, p.y + 14, 40), WOODD)
def barrel(c, r):
    p = tile_c(c, r)
    cylinder(DORF, p, 30, 90, 12, lambda q, n: sc(WOOD, 0.6) if abs(q.z - 18) < 4 or abs(q.z - 72) < 4 else WOOD, r2=30)
def tree(c, r):
    p = tile_c(c, r) + Vector((rnd.uniform(-15, 15), rnd.uniform(-15, 15), 0))
    cylinder(DORF, p, 16, 220, 8, lin(0x4A3A2A), r2=10)
    for k in range(2):
        q = p + Vector((rnd.uniform(-35, 35), rnd.uniform(-35, 35), 270 + k * 70))
        blob(DORF, q, 95 - k * 18, lambda v, n: mixc(lin(0x2E4A22), lin(0x4E6A30), max(0, n.z) * 0.8 + 0.2 * vn(v.x / 30, v.y / 30, 40)), sub=2, squash=0.85, seed=k + c)
def flowers(c, r):
    p = tile_c(c, r)
    for k in range(9):
        q = p + Vector((rnd.uniform(-45, 45), rnd.uniform(-45, 45), 0))
        cylinder(DORF, q, 1.5, 18, 4, lin(0x3E5A2A), cap=False)
        blob(DORF, q + Vector((0, 0, 20)), 4.5, lin(rnd.choice([0xC8B040, 0xA84A6A, 0xD8D8C8, 0x7A5AA8])), sub=1, seed=k)
def washline(cells):
    for c, r in cells:
        p = tile_c(c, r)
        box(DORF, (p.x - 58, p.y - 3, 0), (p.x - 52, p.y + 3, 175), WOOD)
    a = tile_c(*cells[0]); b = tile_c(*cells[-1])
    box(DORF, (a.x - 58, a.y - 1, 170), (b.x + 58, b.y + 1, 172), lin(0x8A7A5A))
    for k, col in enumerate((0xD8CCA8, 0x7A8AA8, 0xA86A4A, 0xD8CCA8)):
        x = a.x - 30 + k * 85
        box(DORF, (x, a.y - 1.5, 105), (x + 55, a.y + 1.5, 170), lin(col))
def sign(c, r):
    p = tile_c(c, r)
    box(DORF, (p.x - 5, p.y - 5, 0), (p.x + 5, p.y + 5, 160), WOOD)
    box(DORF, (p.x - 38, p.y - 7, 115), (p.x + 38, p.y - 3, 160), lin(0x7A5E40))
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
        elif t in 'S!': sign(c, r)
if qq: washline(qq)
for r in range(R0, R1 + 1):
    for c in range(C0, C1 + 1):
        t = ch(c, r); p = tile_c(c, r)
        if t == 'x':
            box(DORF, (p.x - 5, p.y - 5, 0), (p.x + 5, p.y + 5, 100), WOOD)
            if ch(c + 1, r) == 'x': box(DORF, (p.x, p.y - 3, 55), (p.x + TS, p.y + 3, 65), WOOD); box(DORF, (p.x, p.y - 3, 85), (p.x + TS, p.y + 3, 93), WOOD)
            if ch(c, r + 1) == 'x': box(DORF, (p.x - 3, p.y - TS, 55), (p.x + 3, p.y, 65), WOOD); box(DORF, (p.x - 3, p.y - TS, 85), (p.x + 3, p.y, 93), WOOD)
        elif t == 'y': blob(DORF, p + Vector((0, 0, 30)), 55, lambda v, n: mixc(lin(0x9A8A4A), lin(0xB8A860), vn(v.x / 10, v.z / 10, 50)), sub=2, squash=0.7, seed=c)
        elif t == 'z': box(DORF, (p.x - 58, p.y - 6, 85), (p.x + 58, p.y + 6, 97), lambda v, n: lin(0xA83A2A) if int(v.x / 29) % 2 else lin(0xD8CCA8), sub=(4, 1, 1))

# ---------------------------------------------------------------- Netze bauen
def build(P, name, smooth=False):
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in P.V], [], P.F)
    me.validate(); ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER')
    for poly in me.polygons:
        for li in poly.loop_indices:
            vi = me.loops[li].vertex_index; c = P.C[vi]; ca.data[li].color = (c[0], c[1], c[2], c[3] if len(c) > 3 else 1.0)
        poly.use_smooth = smooth
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name); me.materials.append(m)
    return o
# gleiche Ecken zusammenfuehren (je Teil getrennt erzeugt), Farben bleiben je Ecke
o1 = build(DORF, 'Dorf_Netz'); o2 = build(GLAS, 'Dorf_Glas')
for o in (o1, o2):
    bm = bmesh.new(); bm.from_mesh(o.data); bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.01); bm.to_mesh(o.data); bm.free()
print('DORF', len(o1.data.vertices), 'Ecken', len(o1.data.polygons), 'Flaechen')

walk = [[1 if ch(c, r) in WALK else 0 for c in range(C0, C1 + 1)] for r in range(R0, R1 + 1)]
info = dict(kachel_cm=TS, spalten=C1 - C0 + 1, zeilen=R1 - R0 + 1, ursprung=dict(spalte=C0, zeile=R0), begehbar=walk,
            start=dict(spalte=19 - C0, zeile=13 - R0), lichter=LIGHTS,
            hinweis='Blender: x = Spalte * Kachel, y = -Zeile * Kachel (Norden +Y); in glTF/Godot: x gleich, z = +Zeile * Kachel')
json.dump(info, open(OUT + '/dorf-info.json', 'w'), indent=0)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=OUT + '/dorf.glb', export_format='GLB', use_selection=True, export_vertex_color='ACTIVE', export_yup=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT + '/dorf.blend')
print('GLB OK', os.path.getsize(OUT + '/dorf.glb'))
