# 507 (Jerry, Perikles 03.11., Wochenziel Reihe 3, Orte O10): die Kampforte der Höhle für Godot, nach dem alten CaveScene.kt:
# Eingang (Tageslicht im Mund, Moos und Laub), Gang (eng, Stützbalken, Fackeln), Halle (weit, Säulen aus Tropfstein), Teich (Wasser
# links, Leuchtpilze), Lager (Feuerstelle, Kisten, Sack, Schlaflager, Knochen). Wie dort lebt die Höhle von ihrem Licht: die Lampen
# stehen in hoehle-info-<ort>.json (Godot setzt sie als Punktlichter, kampfort.gd _build_cave), das Netz trägt nur Farbe und Form.
# Rahmen wie kampfort_wald.py: Blender +X = zu den Gegnern (a), -Y = quer nach rechts (b), Ursprung = Mitte des Kampfs; die Kamera
# blickt aus etwa 15 m, Kampflinie 30° nach rechts. Nichts steht auf den Plätzen (a ±5, b ±3,5), der Boden dort ist eben.
# Ausgabe: kampfort-hoehle-<ort>.glb, hoehle-info-<ort>.json (Lampen, Dreiecke)
# Aufruf: OUT=<ordner> SPOT=<ort> python -I kampfort_hoehle.py   (vorher tex.py mit demselben OUT; CC0=<ordner> für Felsen)
# Offen nach Lauf 1 (Lauf 234, Prüfer vor dem Versand 03.11., 11:5x; nicht versandt, 461a). Figuren und Posen in allen fünf Bildern
# gleich (Probe), nur der Ort wechselt. Verstöße: A1 Figuren glatt statt Toon (Wölfe fotoartig, Miras Beinschienen glänzend, Bertrams
# Umhang mit weichem Verlauf); A2 Tusche an den Wölfen olivbraun und heller als der Grund, im Eingang keine; A4 unter jeder Figur eine
# hellgrün leuchtende Scheibe statt eines dunklen Schattens; E3 Bertram: Rot/Rosa sticht durch den Umhang (x 205–225, y 490–565),
# unter dem Saum Lücke, Stiefel wirken getrennt; Schwertgriff leuchtet gelb. Inhalt fehlt: Teich ohne Wasser und Ufer (oben rechts
# ungefüllte orange Linie x 360–540, y 130–180); Lager ohne Feuer, Kisten, Sack, Schlaflager, Knochen (nur Felsen links, Fass am Rand
# abgeschnitten); Halle: Säulen nur als olivfarbene Umrisse auf Schwarz; Leuchtpilze nirgends; Fackeln nur im Gang (298, 152), im
# Eingang fraglich (403, 166), Teich und Lager keine. Licht ohne Quelle: Gang rechte Wand gleichmäßig hell; Halle grünlicher Schimmer
# oben links; Teich grün (x 0–150, y 70–240) und violett (x 230–330); Lager oranges Licht oben links ohne Feuer. Lesbarkeit: Halle und
# Teich fast schwarz, Wölfe und Bertram verschwinden; Lager: Wölfe und Bertram kaum vom roten Boden. Eingang: Ausblick wie ein flaches
# grünes Rechteck mit weißem Zackenrand (x 100–355, y 65–150). Koordinaten im Bild 540×1170 (Artefakt Lauf 41615106648, hoehle/*.png).
import bpy, bmesh, math, os, json, random, glob
from mathutils import Vector

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
TEX = os.path.join(OUT, 'tex')
SPOT = os.environ.get('SPOT', 'halle')
assert SPOT in ('eingang', 'gang', 'halle', 'teich', 'lager'), SPOT
rnd = random.Random({'eingang': 1, 'gang': 2, 'halle': 3, 'teich': 4, 'lager': 5}[SPOT] * 507)

D0 = 15.0
CAM = Vector((-0.866 * D0, -0.5 * D0, 0)); VIEW = Vector((0.866, 0.5, 0)); SIDE = Vector((0.5, -0.866, 0))
def view(p): d = Vector((p.x, p.y, 0)) - CAM; return d.dot(VIEW), d.dot(SIDE)     # Entfernung, seitlich (+ rechts)
def from_view(fwd, lat, z=0.0): return CAM + VIEW * fwd + SIDE * lat + Vector((0, 0, z))
def fight(a, b, z=0.0): return Vector((a, -b, z))

def lin(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)
def mixc(a, b, t): t = min(1.0, max(0.0, t)); return tuple(x + (y - x) * t for x, y in zip(a, b))
def ss(a, b, x): t = min(1.0, max(0.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def h1(x, y, s=0):
    n = math.sin(x * 127.1 + y * 311.7 + s * 74.7) * 43758.5453; return n - math.floor(n)
def vnoise(x, y, s=0):
    ix, iy = math.floor(x), math.floor(y); fx, fy = x - ix, y - iy
    u, v = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a = h1(ix, iy, s) * (1 - u) + h1(ix + 1, iy, s) * u; b = h1(ix, iy + 1, s) * (1 - u) + h1(ix + 1, iy + 1, s) * u
    return a * (1 - v) + b * v
def fbm(x, y, s=0): return vnoise(x, y, s) * 0.55 + vnoise(x * 2.1, y * 2.1, s + 1) * 0.3 + vnoise(x * 4.3, y * 4.3, s + 2) * 0.15

# Farben wie CaveScene (Fels kühl grau-braun, Boden wärmer); Licht und Tusche macht Godot
FELS_D, FELS_H = lin(0x3A3634), lin(0x8A8076)
BODEN_D, BODEN_H = lin(0x4A4038), lin(0x8A7A66)

# ---------------------------------------------------------------- Netze (wie kampfort_wald.py): Eckfarbe, UV je Textur
SCALE = dict(feldstein=1.6, erde=1.4, balken=1.0, holz=0.8, stoff=0.6, heu=0.8, weiss=1.0, rinde=1.0)
class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.UV = []; self.M = []; self.S = []
P = Part()
CUR = ['feldstein']
class use:
    def __init__(self, m): self.m = m
    def __enter__(self): self.prev = CUR[0]; CUR[0] = self.m
    def __exit__(self, *a): CUR[0] = self.prev
def proj_uv(p, n, m):
    s = SCALE.get(m, 1.0)
    if abs(n.z) > 0.8: return (p.x / s, p.y / s)
    if abs(n.x) > abs(n.y): return (p.y / s, p.z / s)
    return (p.x / s, p.z / s)
def add_face(pts, col, uvs=None, smooth=False):
    n0 = len(P.V); P.V += pts; P.F.append(tuple(range(n0, n0 + len(pts))))
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0]); nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    P.C += [col(p, nrm) if callable(col) else col for p in pts]
    P.UV.append(uvs or [proj_uv(p, nrm, CUR[0]) for p in pts]); P.M.append(CUR[0]); P.S.append(smooth)
def grid(rows, col, smooth=True):
    """Fläche aus Zeilen gleich langer Punktreihen (Wand, Boden); geteilte Ecken, glatt schattiert"""
    n0 = len(P.V)
    for r in rows:
        for p in r:
            P.V.append(p); P.C.append(None)
    w = len(rows[0])
    for i in range(len(rows) - 1):
        for k in range(w - 1):
            a, b, c, d = n0 + i * w + k, n0 + i * w + k + 1, n0 + (i + 1) * w + k + 1, n0 + (i + 1) * w + k
            P.F.append((a, b, c, d)); P.M.append(CUR[0]); P.S.append(smooth)
            pa, pb, pd = P.V[a], P.V[b], P.V[d]
            nrm = (pb - pa).cross(pd - pa); nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
            P.UV.append([proj_uv(P.V[j], nrm, CUR[0]) for j in (a, b, c, d)])
    for i in range(len(rows)):
        for k in range(w):
            j = n0 + i * w + k
            # Eckfarbe nach der Lage (oben heller, Nischen dunkler): Normale aus den Nachbarn
            p = P.V[j]
            q1 = P.V[n0 + i * w + min(k + 1, w - 1)] - P.V[n0 + i * w + max(k - 1, 0)]
            q2 = P.V[n0 + min(i + 1, len(rows) - 1) * w + k] - P.V[n0 + max(i - 1, 0) * w + k]
            nrm = q1.cross(q2); nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
            P.C[j] = col(p, nrm)
def cylinder(base, r, h, n, col, r2=None, lean=Vector((0, 0, 0)), cap=False):
    r2 = r if r2 is None else r2; s = SCALE.get(CUR[0], 1.0); circ = 2 * math.pi * r
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + Vector((math.cos(a0) * r, math.sin(a0) * r, 0)); p1 = base + Vector((math.cos(a1) * r, math.sin(a1) * r, 0))
        q0 = base + lean + Vector((math.cos(a0) * r2, math.sin(a0) * r2, h)); q1 = base + lean + Vector((math.cos(a1) * r2, math.sin(a1) * r2, h))
        u0, u1 = circ * k / n / s, circ * (k + 1) / n / s
        add_face([p0, p1, q1, q0], col, [(0, u0), (0, u1), (h / s, u1), (h / s, u0)], smooth=True)
    if cap and r2 > 0:
        add_face([base + lean + Vector((math.cos(2 * math.pi * k / n) * r2, math.sin(2 * math.pi * k / n) * r2, h)) for k in range(n)], col)
def tube(p0, p1, r, n, col, r1=None):
    """liegender Zylinder von p0 nach p1 (Stamm, Balken, Knochen, Schlafrolle)"""
    r1 = r if r1 is None else r1
    ax = (p1 - p0); L = ax.length; ax = ax.normalized()
    up = Vector((0, 0, 1)) if abs(ax.z) < 0.9 else Vector((1, 0, 0))
    qx = ax.cross(up).normalized(); qy = qx.cross(ax).normalized()
    ring = lambda c, rr: [c + (qx * math.cos(2 * math.pi * k / n) + qy * math.sin(2 * math.pi * k / n)) * rr for k in range(n)]
    a, b = ring(p0, r), ring(p1, r1)
    for k in range(n):
        add_face([a[k], a[(k + 1) % n], b[(k + 1) % n], b[k]], col, smooth=True)
    add_face(list(reversed(a)), col); add_face(b, col)
def box(c, sx, sy, sz, rot, col):
    ca, sa = math.cos(rot), math.sin(rot)
    def P_(x, y, z): return c + Vector((x * ca - y * sa, x * sa + y * ca, z))
    v = [P_(x, y, z) for z in (0, sz) for y in (-sy / 2, sy / 2) for x in (-sx / 2, sx / 2)]
    for f in ((0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)):
        add_face([v[i] for i in f], col)
def blob(c, r, col, sub=2, squash=1.0, seed=0, bump=0.22, stretch=(1.0, 1.0)):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in bm.verts:
        k = 1 + bump * (h1(v.co.x * 2 + seed, v.co.y * 2 + v.co.z, seed) - 0.5)
        v.co = Vector((v.co.x * r * k * stretch[0], v.co.y * r * k * stretch[1], v.co.z * r * k * squash)) + c
    bm.normal_update()
    n0 = len(P.V)
    for v in bm.verts:
        P.V.append(v.co.copy()); P.C.append(col(v.co, v.normal) if callable(col) else col)
    for f in bm.faces:
        P.F.append(tuple(n0 + v.index for v in f.verts))
        P.UV.append([proj_uv(v.co, f.normal, CUR[0]) for v in f.verts]); P.M.append(CUR[0]); P.S.append(True)
    bm.free()
def cone(base, r, h, n, col, seed=0, down=False):
    """Tropfstein: Kegel mit Ringen (CaveScene cone), nach unten (hängend) oder oben"""
    rings = 6; pts = []
    for i in range(rings + 1):
        t = i / rings; rr = r * (1 - t) ** 1.25 * (1 + 0.08 * math.sin(i * 2.3 + seed)) + 0.01
        z = (-h if down else h) * t
        off = Vector((0.06 * math.sin(seed + t * 3), 0.06 * math.cos(seed * 1.3 + t * 2), 0)) * h * 0.15
        pts.append([base + off + Vector((math.cos(2 * math.pi * k / n) * rr, math.sin(2 * math.pi * k / n) * rr, z)) for k in range(n)])
    if down: pts = list(reversed(pts))
    grid([r_ + [r_[0]] for r_ in pts], col)
def rock_col(base_d=FELS_D, base_h=FELS_H, moos=0.0):
    def col(v, n):
        t = 0.35 + 0.45 * max(0.0, n.z) + 0.25 * (fbm(v.x * 0.6, v.y * 0.6 + v.z * 0.7, 3) - 0.5)
        c = mixc(base_d, base_h, t)
        if moos > 0 and n.z > 0.3:
            c = mixc(c, lin(0x4E6A30), moos * ss(0.3, 0.8, n.z) * fbm(v.x * 1.3, v.y * 1.3, 9))
        return c
    return col

# ---------------------------------------------------------------- Maße je Ort (CaveScene: Halle weit und hoch, Gang eng)
WEIT = {'eingang': 8.5, 'gang': 5.2, 'halle': 11.0, 'teich': 9.0, 'lager': 8.0}[SPOT]          # m quer bis zur Wand (Kampfmitte)
HINTEN = {'eingang': 9.0, 'gang': 8.0, 'halle': 11.0, 'teich': 10.0, 'lager': 8.5}[SPOT]      # m hinter der Kampfmitte bis zur Rückwand
HOCH = {'eingang': 8.0, 'gang': 6.0, 'halle': 11.0, 'teich': 8.5, 'lager': 7.5}[SPOT]          # Wandhöhe bis zum Überhang
MUND = {'eingang': (-1.2, 3.4, 3.6), 'gang': (0.0, 1.9, 2.4), 'halle': (-1.0, 3.6, 3.8),
        'teich': (3.4, 1.8, 2.3), 'lager': (-0.6, 1.8, 2.3)}[SPOT]       # Mund in der Rückwand: quer (+ rechts), halbe Breite, Höhe
FLACH = lambda a, b: ss(0.0, 1.0, max((abs(a) - 5.0) / 2.0, (abs(b) - 3.6) / 1.6))   # 0 auf den Plätzen, 1 weit weg

# Lauf 234 (Prüfer: Teich, Lager, Pilze fehlen im Bild): die Kampfkamera zeigt hochkant nur einen schmalen Keil, rund ±0,19 der
# Tiefe zur Seite; was am Ort zählt, steht darum dort, wo sie hinsieht (Bildanteil wie CaveScene: Fackeln bei 0,13 und 0,84).
# Kamera wie kampfort.gd _fit_camera im Prüfbild 540×1170 (Szene bis 770, darunter die Tafel): Brennweite, Augenhöhe, Horizont
GW, GH = 540.0, 770.0
GF = GH * 0.32 / math.tan(math.radians(15)) * 1.5
GD0 = GF / (120.0 * GW / 412.0 / 1.75)
GEYE = GD0 * math.tan(math.radians(25))
GHOR = GH * 0.64 - GF * math.tan(math.radians(25))
AUGE = Vector((-0.866 * GD0, -0.5 * GD0, GEYE))
def bild(p):
    """Bildpunkt (x, y in Punkten des Prüfbilds) und Tiefe eines Blender-Punkts in der Kampfkamera"""
    a, b = p.x, -p.y
    X = a * 0.5 + b * 0.866; tiefe = GD0 + a * 0.866 - b * 0.5
    return GW / 2 + GF * X / tiefe, GHOR + GF * (GEYE - p.z) / tiefe, tiefe
MERK = []        # (Name, Blender-Punkt, Halbmesser): was im Bild zu sehen sein muss (Prüfung am Ende); der Strahl beginnt am Rand des Dings
def merk(name, p, r=0.15): MERK.append((name, p.copy(), r))

# Teich (CaveScene lake): Wasser links hinter den Gegnern, wo die Kamera hinsieht; der Boden senkt sich darunter
TEICH = (4.2, -5.7, 3.0, 1.75)     # Mitte a, b, Halbachsen a, b
def im_teich(a, b): return ((a - TEICH[0]) / TEICH[2]) ** 2 + ((b - TEICH[1]) / TEICH[3]) ** 2
def boden_z(a, b):
    f = FLACH(a, b)
    z = f * (0.35 * (fbm(a * 0.4, b * 0.4, 21) - 0.5) + 0.12 * (fbm(a * 1.7, b * 1.7, 22) - 0.5))
    z += 0.004 * (fbm(a * 3, b * 3, 23) - 0.5)
    r_ = (a / HINTEN) ** 2 + (b / WEIT) ** 2
    z += ss(0.7, 1.2, r_) * 1.2 * f   # zur Wand hin steigt der Boden (auf den Plätzen nie)
    if SPOT == 'teich':
        z -= 0.35 * (1 - ss(0.85, 1.35, im_teich(a, b)))
    return z

def wand_punkt(s, z):
    """Wand um die Kampfmitte: s von -1 (links) über 0 (hinten) bis 1 (rechts), Höhe z; oben neigt sie sich als Decke herein"""
    ang = s * math.radians(105)                     # bis 105° zur Seite: die Seitenwände kommen bis vor die Kämpfer
    a = HINTEN * math.cos(ang); b = WEIT * math.sin(ang)
    if abs(s) > 0.75:                                # vorn laufen die Seitenwände an der Kamera vorbei
        a -= (abs(s) - 0.75) * 14.0
    over = ss(0.55, 1.0, z / HOCH) * (2.2 if SPOT == 'gang' else 3.2)     # Überhang: oben herein (Decke über dem hinteren Teil)
    k = 1 - over / max(math.hypot(a, b), 1.0)
    rough = 0.55 * (fbm(s * 9.0, z * 0.45, 11) - 0.5) + 0.2 * (fbm(s * 31.0, z * 1.4, 12) - 0.5)
    p = fight(a * k, b * k, z)
    out = Vector((a, -b, 0)).normalized()
    return p + out * rough * 2.0
def im_mund(s, z):
    lat = view(wand_punkt(s, 0.0))[1]
    cx, hb, hh = MUND
    if view(wand_punkt(s, 0.0))[0] < 17.0: return False
    dx = (lat - cx) / hb; dz = (z - hh * 0.45) / (hh * 0.55)
    return dx * dx + dz * dz < 1.0 + 0.12 * (fbm(s * 7, z, 31) - 0.5)

# Rückwand und Seiten, mit Loch für den Mund
with use('feldstein'):
    S_N, Z_N = 64, 22
    rows = [[wand_punkt(-1 + 2 * k / (S_N - 1), HOCH * 1.35 * i / (Z_N - 1)) for k in range(S_N)] for i in range(Z_N)]
    col = rock_col()
    n_vor = len(P.F)
    grid(rows, col)
    # Flächen im Mund fallen weg (dahinter der Gang ins Dunkel oder ins Licht)
    keep = []
    for idx in range(n_vor, len(P.F)):
        f = P.F[idx]; c = sum((P.V[j] for j in f), Vector()) / 4.0
        s = None
        i = (idx - n_vor) // (S_N - 1); k = (idx - n_vor) % (S_N - 1)
        s = -1 + 2 * (k + 0.5) / (S_N - 1); z = HOCH * 1.35 * (i + 0.5) / (Z_N - 1)
        keep.append(not im_mund(s, z))
    P.F[n_vor:] = [f for f, ok in zip(P.F[n_vor:], keep) if ok]
    P.M[n_vor:] = [m for m, ok in zip(P.M[n_vor:], keep) if ok]
    P.S[n_vor:] = [m for m, ok in zip(P.S[n_vor:], keep) if ok]
    P.UV[n_vor:] = [m for m, ok in zip(P.UV[n_vor:], keep) if ok]
    # Decke: vom oberen Rand der Wand zur Mitte über dem hinteren Teil (die Kamera sieht sie nur am oberen Bildrand)
    top = rows[-1]
    mid = [fight(HINTEN * 0.15, 0, HOCH * 1.5) + (p - fight(HINTEN * 0.15, 0, HOCH * 1.5)) * 0.25 for p in top]
    grid([top, mid], col)

# Hinter dem Mund: ein kurzer Gang (Eingang: draußen, Himmel und Wald im Licht; sonst Dunkel)
cx, hb, hh = MUND
mitte_mund = from_view(D0 + HINTEN + 1.0, cx)
tief = (mitte_mund - CAM); tief.z = 0; tief = tief.normalized()
quer = Vector((tief.y, -tief.x, 0))
with use('feldstein'):
    for side in (-1, 1):
        a0 = mitte_mund + quer * side * (hb + 0.3)
        grid([[a0 + tief * d + Vector((0, 0, z)) - quer * side * 0.4 * ss(0, 1, d / 6) for d in (0, 2, 4, 6)] for z in (0, hh * 0.6, hh * 1.1)],
             rock_col(lin(0x221E1C), lin(0x4A4440)))
    back = mitte_mund + tief * 6.0
    if SPOT == 'eingang':
        # draußen: heller Himmel über einer grünen Baumreihe, ein Streifen Wiese (CaveScene mouth daylight)
        with use('himmel'):
            add_face([back - quer * 6 + Vector((0, 0, -0.2)), back + quer * 6 + Vector((0, 0, -0.2)),
                      back + quer * 6 + Vector((0, 0, hh * 1.6)), back - quer * 6 + Vector((0, 0, hh * 1.6))],
                     lambda p, n: mixc(lin(0xD8E4C8), lin(0xF4F6EC), ss(0.0, hh * 1.4, p.z)))
        with use('laub'):
            for k in range(9):
                q = back - tief * 0.6 + quer * (-4 + k) + Vector((0, 0, hh * 0.25 + 0.4 * h1(k, 2)))
                blob(q, 0.9 + 0.4 * h1(k, 3), lambda p, n: mixc(lin(0x4A6A34), lin(0x9CBC5C), 0.4 + 0.4 * n.z), sub=1, squash=1.1, seed=k)
        with use('gras'):
            add_face([mitte_mund + tief * 1.5 - quer * (hb + 1), mitte_mund + tief * 1.5 + quer * (hb + 1),
                      back + quer * (hb + 2), back - quer * (hb + 2)], lin(0x7A9A4A))
    else:
        with use('dunkel'):
            add_face([back - quer * 3, back + quer * 3, back + quer * 3 + Vector((0, 0, hh * 1.4)), back - quer * 3 + Vector((0, 0, hh * 1.4))],
                     lin(0x050506))

# Boden: eben auf den Plätzen, nach außen buckelig und zur Wand hin ansteigend; Kies, Pfützen (CaveScene floor, gravel, puddles)
with use('erde'):
    A_N, B_N = 46, 40
    rows = []
    for i in range(A_N):
        a = -14 + (HINTEN + 16) * i / (A_N - 1)
        row = []
        for k in range(B_N):
            b = -(WEIT + 3) + 2 * (WEIT + 3) * k / (B_N - 1)
            row.append(fight(a, b, boden_z(a, b)))
        rows.append(row)
    def boden_col(p, n):
        a, b = p.x, -p.y
        t = 0.45 + 0.3 * (fbm(a * 0.5, b * 0.5, 25) - 0.5) + 0.25 * max(0.0, n.z - 0.9) * 4
        c = mixc(BODEN_D, BODEN_H, t)
        if SPOT == 'eingang':      # Moos zum Mund hin (mossAndLeaves)
            near = math.exp(-((view(p)[1] - MUND[0]) / 6.0) ** 2 - ((view(p)[0] - D0 - HINTEN) / 5.0) ** 2)
            c = mixc(c, lin(0x5A7A38), near * 0.8 * fbm(a * 1.1, b * 1.1, 26))
        return c
    grid(rows, boden_col)

# Tropfsteine an der Decke (hängend) und am Boden an der Wand, Felsbrocken an den Seiten
with use('feldstein'):
    n_hang = 26 if SPOT == 'halle' else 16
    for i in range(n_hang):
        s = -0.85 + 1.7 * (i + rnd.random() * 0.8) / n_hang
        p = wand_punkt(s, HOCH * 1.05)
        p = p + (fight(0, 0, p.z) - p) * rnd.uniform(0.05, 0.25)
        L = (1.0 if SPOT == 'halle' else 0.7) + rnd.random() ** 2 * (3.4 if SPOT == 'halle' else 2.2)
        if abs(p.x) < 5.6 and abs(p.y) < 4.0:
            L = min(L, p.z - 3.8)     # über den Plätzen hängt kein Tropfstein in die erhobene Waffe
        cone(p, 0.22 + 0.25 * rnd.random(), L, 7, rock_col(), seed=i, down=True)

STEINE = []
def bestand_teil(name, p, r, dreh, farbe):
    """Felsen aus dem Bestand wie kampfort_wald.py (Stylized Nature MegaKit, CC0)"""
    d = glob.glob(glob.escape(os.path.expanduser(os.environ.get('CC0', '~/cc0'))) + '/stylized-nature-megakit/glTF')
    f = os.path.join(d[0], name + '.gltf') if d else ''
    if not f or not os.path.exists(f): return False
    vor = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=f)
    neu = [o for o in bpy.data.objects if o not in vor and o.type == 'MESH']
    for o in neu:
        me = o.data; me.transform(o.matrix_world)
        lo = min(v.co.z for v in me.vertices); hi = max(v.co.z for v in me.vertices)
        rr = max(max(abs(v.co.x), abs(v.co.y)) for v in me.vertices)
        k = r / max(rr, 1e-3)
        ca, sa = math.cos(dreh), math.sin(dreh)
        n0 = len(P.V)
        for v in me.vertices:
            x, y, z = v.co.x * k, v.co.y * k, (v.co.z - lo) * k - (hi - lo) * k * 0.2
            q = p + Vector((x * ca - y * sa, x * sa + y * ca, z))
            P.V.append(q); P.C.append(farbe(q, Vector((0, 0, 1)) if z > (hi - lo) * k * 0.5 else Vector((0.6, 0, 0.4)).normalized()))
        for poly in me.polygons:
            P.F.append(tuple(n0 + i for i in poly.vertices)); P.M.append('feldstein'); P.S.append(True)
            P.UV.append([proj_uv(P.V[n0 + i], poly.normal, 'feldstein') for i in poly.vertices])
        bpy.data.objects.remove(o)
    return True
def brocken(p, r, s):
    STEINE.append((p.x, p.y, r))
    if not bestand_teil('Rock_Medium_%d' % (1 + s % 3), p, r, rnd.uniform(0, 2 * math.pi), rock_col()):
        with use('feldstein'):
            blob(p + Vector((0, 0, r * 0.35)), r, rock_col(), sub=2, squash=0.7, seed=s, bump=0.3)

def deckt_merk(p, r, h):
    """Lauf 234 (Lager: nur Felsen links): ein Stein oder Tropfstein bei p (Halbmesser r, Höhe h) läge im Bild vor etwas, das man sehen muss"""
    xs = [bild(p + Vector((dx, dy, dz)))[:2] for dx in (-r, r) for dy in (-r, r) for dz in (0.0, h)]
    x0 = min(x for x, _ in xs) - 12; x1 = max(x for x, _ in xs) + 12; y0 = min(y for _, y in xs) - 12; y1 = max(y for _, y in xs) + 12
    t = bild(p)[2]
    for _, q, _r in MERK:
        x, y, tq = bild(q)
        if x0 < x < x1 and y0 < y < y1 and t < tq + 0.5: return True
    if SPOT == 'teich' and im_teich(p.x, -p.y) < 1.4: return True
    return False
def stoerer():
    """Tropfsteine am Wandfuß und Felsbrocken an den Seiten, erst nach dem, was den Ort ausmacht: nie davor"""
    with use('feldstein'):
        for i in range(10 if SPOT != 'gang' else 6):
            s = rnd.uniform(-0.95, 0.95)
            p = wand_punkt(s, 0.0); p = p + (fight(0, 0) - p) * rnd.uniform(0.04, 0.12); p.z = -0.05
            a, b = p.x, -p.y
            if abs(a) < 6.0 and abs(b) < 4.2: continue
            r, L = 0.25 + 0.3 * rnd.random(), 0.8 + rnd.random() * 2.2
            if deckt_merk(p, r, L): continue
            cone(p, r, L, 7, rock_col(), seed=i + 40)
    for i in range(7):
        for _ in range(30):
            r = rnd.uniform(0.45, 1.0)
            a = rnd.uniform(-3, HINTEN - 1); b = rnd.choice((-1, 1)) * rnd.uniform(max(4.6, 3.8 + r), max(WEIT - 0.8, 3.9 + r))
            if all(math.hypot(a - x, -b - y) > 1.6 for x, y, _ in STEINE) and not deckt_merk(fight(a, b), r, r * 2.0): break
        else:
            continue
        brocken(fight(a, b, boden_z(a, b)), r, i)

# ---------------------------------------------------------------- was den Ort ausmacht
LAMPEN = []      # (Blender-Punkt, Farbe 0xRRGGBB, Reichweite m, Stärke, Art)
def lampe(p, c, r, k, art): LAMPEN.append((p, c, r, k, art))
def flamme(p, size, art='fackel'):
    """Flamme als leuchtender Kegel (Godot: unschattiert, flackert); Licht darüber"""
    with use('flamme'):
        cone(p, size * 0.35, size * 1.3, 6, lambda q, n: mixc(lin(0xFFC860), lin(0xFF7A20), ss(p.z, p.z + size, q.z)), seed=int(size * 10))
def fackel(s, z):
    p = wand_punkt(s, z); inn = (fight(0, 0, z) - p); inn.z = 0; inn = inn.normalized()
    q = p + inn * 0.35
    with use('balken'):
        tube(q - Vector((0, 0, 0.45)) - inn * 0.1, q, 0.05, 6, lin(0x6A4A30))
    with use('feldstein'):
        tube(p + inn * 0.02 - Vector((0, 0, 0.3)), q - Vector((0, 0, 0.25)), 0.025, 5, lin(0x2A2624))     # Eisenhalter
    flamme(q + Vector((0, 0, 0.02)), 0.32)
    lampe(q + inn * 0.25 + Vector((0, 0, 0.35)), 0xFFA050, 9.0, 1.6, 'fackel')
    merk('Fackel', q + Vector((0, 0, 0.2)), 0.25)
def s_bei(fx, z=0.0):
    """Stelle s der Wand (hinten und an den Seiten, |s| ≤ 0,75), die im Bild beim Anteil fx der Breite liegt (CaveScene fx)"""
    return min((abs(bild(wand_punkt(k / 200.0, z))[0] - fx * GW), k / 200.0) for k in range(-150, 151))[1]
def am_fuss(fx, rein=0.06):
    """Punkt am Wandfuß beim Bildanteil fx, ein Stück herein, auf dem Boden (der Boden steigt zur Wand hin an)"""
    p = wand_punkt(s_bei(fx), 0.0); p = p + (fight(0, 0) - p) * rein
    return fight(p.x, -p.y, boden_z(p.x, -p.y))
def pilze(fx, cyan):
    """Leuchtpilze und Kristalle (CaveScene fungi): türkis, mal violett, am Wandfuß; Lauf 234: lagen unter dem ansteigenden Boden"""
    p = am_fuss(fx)
    with use('pilz'):
        for m in range(6):
            dx, dy = rnd.uniform(-0.45, 0.45), rnd.uniform(-0.45, 0.45)
            q = fight(p.x + dx, -(p.y + dy), boden_z(p.x + dx, -(p.y + dy)) - 0.02)
            hoch = rnd.uniform(0.1, 0.2)
            cylinder(q, 0.025, hoch, 5, lin(0xC8D8D0))
            blob(q + Vector((0, 0, hoch + 0.01)), rnd.uniform(0.08, 0.15), lin(0x7AF0E0 if cyan else 0xB890FF), sub=1, squash=0.45, seed=m)
    lampe(p + Vector((0, 0, 0.5)), 0x7AF0E0 if cyan else 0xB890FF, 5.0, 1.0, 'pilz')
    merk('Pilze', p + Vector((0, 0, 0.15)))
def auf_boden(a, b, dz=0.0): return fight(a, b, boden_z(a, b) + dz)

if SPOT == 'gang':
    # Stützbalken (CaveScene beams): drei Joche quer über den Gang, das hinterste vor dem Mund
    with use('balken'):
        for a in (-1.5, 3.5, 7.0):
            wb = WEIT * 0.82 if a < 6 else MUND[1] + 0.8
            for side in (-1, 1):
                fuss = auf_boden(a, side * wb, -0.1)
                cylinder(fuss, 0.16, 3.7, 7, lambda q, n: tuple(x * (0.75 + 0.25 * n.z + 0.1) for x in lin(0x6A4A30)), r2=0.14)
            if a > 5.5:     # Querbalken nur hinter den Gegnern; vorn tragen die Pfosten ein Kopfholz zur Wand
                tube(fight(a, -wb - 0.3, 3.6), fight(a, wb + 0.3, 3.6), 0.17, 7, lin(0x5A3E28))
            else:
                for side in (-1, 1):
                    tube(fight(a, side * wb, 3.5), fight(a, side * (wb + 1.2), 3.9), 0.15, 7, lin(0x5A3E28))
    merk('Stützbalken', fight(3.5, -WEIT * 0.82, 1.8), 0.3)
    fackel(s_bei(0.13, 2.4), 2.4); fackel(s_bei(0.76, 2.2), 2.2)
elif SPOT == 'halle':
    # Säulen, wo Tropfstein und Stalagmit zusammengewachsen sind (CaveScene pillars): schmale Taille, unten und oben breit;
    # Lauf 234: zwei standen rechts außerhalb des Bilds, jetzt links und hinter den Gegnern
    with use('feldstein'):
        for (a, b, r) in ((6.4, -6.2, 0.9), (9.0, -0.6, 1.0), (10.0, -4.0, 0.8)):
            z0 = boden_z(a, b) - 0.1
            rings = []
            for i in range(12):
                t = i / 11; z = z0 + (HOCH * 1.2) * t
                waist = 1 - 0.45 * math.exp(-((t - 0.55) / 0.18) ** 2)
                flare = 1 + 0.9 * max(t - 0.8, 0) * 5 + 0.6 * max(0.15 - t, 0) * 6
                rr = r * waist * flare
                rings.append([fight(a, b, z) + Vector((math.cos(2 * math.pi * k / 10) * rr * (1 + 0.1 * math.sin(z * 3 + k)),
                                                        math.sin(2 * math.pi * k / 10) * rr, 0)) for k in range(10)])
            grid([r_ + [r_[0]] for r_ in rings], rock_col(moos=0.2))
            merk('Säule', fight(a, b, z0 + 1.6), r * 1.3)
    fackel(s_bei(0.13, 2.6), 2.6)
    for k, fx in enumerate((0.04, 0.47)):
        pilze(fx, k != 1)
elif SPOT == 'teich':
    # Wasser links hinter den Gegnern (CaveScene lake), Ufer mit Kies; Lauf 234: lag 6 cm unter dem Boden der Plätze
    ca, cb, ra, rb = TEICH
    with use('wasser'):
        ring = []
        for k in range(32):
            t = 2 * math.pi * k / 32; w = 1 + 0.07 * math.sin(t * 3 + 1.1)
            ring.append(fight(ca + math.cos(t) * ra * w, cb + math.sin(t) * rb * w, -0.1))
        add_face(ring, lambda q, n: mixc(lin(0x14303A), lin(0x2A5058), ss(cb + rb, cb - rb, -q.y)))
    with use('feldstein'):
        for k in range(22):
            t = 2 * math.pi * k / 22
            a, b = ca + math.cos(t) * ra * 1.08, cb + math.sin(t) * rb * 1.08
            if abs(a) < 5.4 and abs(b) < 3.9: continue
            blob(auf_boden(a, b), rnd.uniform(0.1, 0.22), rock_col(), sub=1, squash=0.5, seed=k)
    merk('Wasser', fight(ca, cb, -0.1)); merk('Wasser vorn', fight(ca - ra * 0.7, cb + rb * 0.3, -0.1))
    lampe(fight(ca, cb, 1.2), 0x60C8D0, 7.0, 0.6, 'wasser')
    for k, fx in enumerate((0.04, 0.22, 0.62, 0.9)):
        pilze(fx, k != 2)
elif SPOT == 'lager':
    # Feuerstelle links (CaveScene camp): Steinkranz, Scheite, Glut; Kisten, Sack, Schlaflager, Knochen
    # Lauf 234: Kisten, Sack, Knochen lagen rechts außerhalb des Bilds, das Feuer hinter Felsen; jetzt im Blick der Kamera
    fc = auf_boden(2.6, -4.9)
    with use('feldstein'):
        for k in range(9):
            t = 2 * math.pi * k / 9
            blob(fc + Vector((math.cos(t) * 0.75, math.sin(t) * 0.75, 0.05)), 0.17, rock_col(), sub=1, squash=0.6, seed=k)
    with use('rinde'):
        for k in range(4):
            t = 2 * math.pi * k / 4 + 0.4
            tube(fc + Vector((math.cos(t) * 0.55, math.sin(t) * 0.55, 0.06)), fc + Vector((math.cos(t) * 0.1, math.sin(t) * 0.1, 0.32)), 0.07, 6, lin(0x3A2A1C))
    with use('glut'):
        blob(fc + Vector((0, 0, 0.03)), 0.35, lambda q, n: lin(0xC84A10), sub=1, squash=0.25, seed=3)
    flamme(fc + Vector((0, 0, 0.12)), 0.6, 'feuer')
    lampe(fc + Vector((0, 0, 0.9)), 0xFF9440, 11.0, 2.2, 'feuer')
    merk('Feuer', fc + Vector((0, 0, 0.45)))
    with use('balken'):
        box(auf_boden(6.4, -1.9, -0.05), 0.8, 0.7, 0.7, 0.3, lin(0x7A5634))
        box(auf_boden(6.5, -1.95, 0.65), 0.6, 0.55, 0.5, 0.5, lin(0x6A4A2C))
        box(auf_boden(6.9, -0.9, -0.05), 0.7, 0.7, 0.6, -0.2, lin(0x7A5634))
    merk('Kisten', auf_boden(6.4, -1.9, 0.9), 0.6)
    with use('stoff'):
        blob(auf_boden(5.9, -3.3, 0.3), 0.38, lambda q, n: mixc(lin(0x5A4A34), lin(0x9A8460), 0.3 + 0.5 * n.z), sub=2, squash=1.2, seed=7)
        merk('Sack', auf_boden(5.9, -3.3, 0.45), 0.5)
        tube(auf_boden(3.1, -6.1, 0.16), auf_boden(4.6, -6.3, 0.16), 0.2, 8, lin(0x5A3A2A))     # Schlaflager
        merk('Schlaflager', auf_boden(3.85, -6.2, 0.36), 0.3)
    with use('weiss'):
        for k in range(5):
            a, b = 6.8 + rnd.uniform(-0.5, 0.5), -4.4 + rnd.uniform(-0.5, 0.5)
            q = auf_boden(a, b, 0.04)
            d = Vector((math.cos(k * 1.7), math.sin(k * 1.7), 0)) * rnd.uniform(0.2, 0.4)
            tube(q - d, q + d, 0.035, 5, lin(0xC8BCA0))
        merk('Knochen', auf_boden(6.8, -4.4, 0.06))
else:     # eingang: Laub und Moos zum Mund hin, Licht von draußen
    with use('laub'):
        for k in range(40):
            a = rnd.uniform(2, HINTEN - 0.5); b = rnd.uniform(-WEIT + 1, WEIT - 1)
            if abs(a) < 5.2 and abs(b) < 3.8: continue
            q = auf_boden(a, b, 0.02)
            r = rnd.uniform(0.06, 0.12); t = rnd.uniform(0, math.pi)
            add_face([q + Vector((math.cos(t + j * math.pi / 2) * r, math.sin(t + j * math.pi / 2) * r, 0.005 * j)) for j in range(4)],
                     [lin(0x8A5A26), lin(0xA87A30), lin(0x6A4A22)][k % 3])
    merk('Ausgang', mitte_mund + Vector((0, 0, MUND[2] * 0.45)))
    fackel(s_bei(0.84, 2.4), 2.4)

stoerer()

# Licht, das jeder Ort hat: weich über dem Kampf (CaveScene fightLight), damit Gegner und Held nie im Schwarzen stehen;
# Lauf 234 (Gang: rechte Wand gleichmäßig hell ohne Quelle): Reichweite nur bis zu den Plätzen, die Wände leuchten Fackel und Pilz
licht = {'eingang': 0xFFF0E0, 'gang': 0xFFB070, 'halle': 0x60C8D0, 'teich': 0x60C8D0, 'lager': 0xFFC890}[SPOT]
lampe(fight(0.5, 0.0, 4.0), licht, 8.5, 0.55, 'kampf')
if SPOT == 'eingang':     # Tageslicht aus dem Mund, weit und kühl-hell
    lampe(mitte_mund + Vector((0, 0, hh * 0.6)) - tief * 1.0, 0xF0F4E8, 16.0, 1.8, 'tag')

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
me = bpy.data.meshes.new('Hoehle'); me.from_pydata([tuple(v) for v in P.V], [], [tuple(f) for f in P.F])
names = sorted(set(P.M)); idx = {n: k for k, n in enumerate(names)}
for n in names: me.materials.append(material(n))
ca_ = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
for k, poly in enumerate(me.polygons):
    poly.material_index = idx[P.M[k]]; poly.use_smooth = P.S[k]
    for j, li in enumerate(poly.loop_indices):
        c = P.C[me.loops[li].vertex_index]
        ca_.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
ob = bpy.data.objects.new('Hoehle', me); bpy.context.scene.collection.objects.link(ob)
tris = sum(len(f) - 2 for f in P.F)
bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT + '/kampfort-hoehle-%s.glb' % SPOT, export_format='GLB', use_selection=True,
                          export_vertex_color='ACTIVE', export_yup=True, export_image_format='AUTO')
# Lampen in Godot-örtlich (Höhlen-Knoten wie der Wald-Knoten): x = Blender x, y = Blender z, z = -Blender y
info = dict(ort=SPOT, dreiecke=tris, stoffe=names,
            lampen=[dict(pos=[round(p.x, 3), round(p.z, 3), round(-p.y, 3)], farbe='%06X' % c, reichweite=r, staerke=k, art=a)
                    for (p, c, r, k, a) in LAMPEN],
            merk=[dict(name=n, pos=[round(q.x, 3), round(q.z, 3), round(-q.y, 3)]) for (n, q, _r) in MERK],
            hinweis='507: Lampen als OmniLight3D (kampfort.gd _build_cave); fackel und feuer flackern; Stoffe flamme, glut, himmel, pilz leuchten')
json.dump(info, open(OUT + '/hoehle-info-%s.json' % SPOT, 'w'), indent=1)
# Blickprüfung (Lauf 234, Prüfer: Teich, Lager, Pilze fehlen im Bild): jeder Merkpunkt im Bild der Kampfkamera, nicht hinter
# Fels, Wand oder Boden (Strahl vom Auge), nicht hinter den Figuren (Rechteck je Platz wie kampfort.gd _stand, Wolf 1,2 m, Mensch 1,9 m)
from mathutils.bvhtree import BVHTree
bvh = BVHTree.FromPolygons([tuple(v) for v in P.V], P.F)
FIGUREN = [(a, b, 0.45, 1.9) for a, b in ((-2.4, -0.9), (-2.4, 0.9), (-3.3, -0.1), (-3.3, 1.3), (-2.75, 0.35))] + \
          [(a, b, 1.2, 1.2) for a, b in ((1.95, -1.65), (1.4, 1.2), (2.9, -1.2), (2.9, 1.2), (5.3, -1.0), (2.0, -1.3), (3.9, -1.65))]
blick_fehler = []
for name, q, r in MERK:
    x, y, t = bild(q)
    zum = AUGE - q; dist = zum.length; zum.normalize()
    treffer = bvh.ray_cast(q + zum * r, zum, dist - r - 0.1)
    hinter = [f for f in FIGUREN if t > bild(fight(f[0], f[1]))[2] + 0.3 and
              min(bild(fight(f[0] + da, f[1] + db, dz))[0] for da in (-f[2], f[2]) for db in (-f[2], f[2]) for dz in (0, f[3])) < x <
              max(bild(fight(f[0] + da, f[1] + db, dz))[0] for da in (-f[2], f[2]) for db in (-f[2], f[2]) for dz in (0, f[3])) and
              bild(fight(f[0], f[1], f[3]))[1] < y < bild(fight(f[0], f[1]))[1]]
    stand = 'außerhalb' if not (12 < x < GW - 12 and 40 < y < GH - 10) else ('verdeckt' if treffer[0] is not None else ('hinter Figur' if hinter else 'sichtbar'))
    wo = '' if treffer[0] is None else ' von %s bei %.1f m (%.1f, %.1f, %.1f)' % (P.M[treffer[2]], treffer[3], treffer[0].x, -treffer[0].y, treffer[0].z)
    print('BLICK %s %s: %.0f, %.0f, %.1f m %s%s' % (SPOT, name, x, y, t, stand, wo))
    if stand != 'sichtbar': blick_fehler.append(name + ' ' + stand)
if blick_fehler:
    print('FEHLER 507: nicht im Bild', blick_fehler)
    raise SystemExit(1)
# Prüfung: nichts auf den Plätzen (a ±5, b ±3,5) zwischen 3 cm und 3,6 m (Platz für Figuren mit erhobener Waffe)
hoch = [v for v in P.V if abs(v.x) < 5.0 and abs(v.y) < 3.5 and 0.03 < v.z < 3.6]
print('HOEHLE', SPOT, 'Dreiecke', tris, 'Lampen', len(LAMPEN), 'Stoffe', names, 'auf den Plätzen', len(hoch))
if hoch:
    print('FEHLER 507: etwas steht auf den Plätzen', hoch[:3])
    raise SystemExit(1)
