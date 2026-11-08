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
# Lauf 247 (Prüfer vor dem Versand 03.11., 15:00; nicht versandt), nachgestellt ohne Lauf mit Strahlen durch bild(), deckt sich auf
# den Bildpunkt mit dem Helferbefund (Wasser x 0–228, y 267–372; Tafel Halle x 96–309, y 42–123): schwarze Leerrechtecke = Tafel am
# Ende eines Gangs ohne Boden und Decke, daneben Löcher (Hintergrund); Eingang = Moosbild der Bäume von der Lampe am Mund hell,
# Himmel glow 1; Gangbalken = Kopfhölzer in der Wand, hinteres Joch hinter der Wand. Behoben siehe „Hinter dem Mund“, „Stützbalken“,
# Lochprüfung. Nicht der Ort, sondern Probe und Oberfläche (für alle Kampforte gleich, offen): Ansage des braunen Wolfs ohne Strich,
# Miras Schild vor dem Gesicht; Zugleiste nicht abgeschnitten (Helfer: „…“ gekürzt, Absicht); Tusche an Figuren da (Helfer gemessen).
# Lauf 287 (Prüfer vor dem Versand 08.11., 09:0x; nicht versandt), nachgestellt ohne Bild: Eckfarbe war volle Farbe mal Bild (Boden
# 1 % hell, tests/hoehle_farben_507.gd), jetzt Tönung; Halle, Teich, Lager hinten zu (CaveCam); Joche, Decke, Seitenwand vorn rechts
# nach Strahlen (BLICK); Kegel nie hinter einer Figur; Lager und Pilze aus dem Bestand; draußen und Wasser gemalt; Bildplan (PLAN).
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
    def __init__(self): self.V = []; self.F = []; self.C = []; self.UV = []; self.M = []; self.S = []; self.T = []
P = Part()
CUR = ['feldstein']
class use:
    def __init__(self, m): self.m = m
    def __enter__(self): self.prev = CUR[0]; CUR[0] = self.m
    def __exit__(self, *a): CUR[0] = self.prev
# 507 Lauf 287 (Prüfer: Sichelbogen, Querbalken ohne Pfosten, Kegel aus dem Wolfsrücken): jede Fläche weiß, zu welchem Teil sie
# gehört; der Bildplan am Ende zeigt je Feld des Prüfbilds den vordersten Teil (Strahlen vom Auge, ohne Bild)
TEIL = ['wand']
class teil:
    def __init__(self, t): self.t = t
    def __enter__(self): self.prev = TEIL[0]; TEIL[0] = self.t
    def __exit__(self, *a): TEIL[0] = self.prev
def proj_uv(p, n, m):
    s = SCALE.get(m, 1.0)
    if abs(n.z) > 0.8: return (p.x / s, p.y / s)
    if abs(n.x) > abs(n.y): return (p.y / s, p.z / s)
    return (p.x / s, p.z / s)
def add_face(pts, col, uvs=None, smooth=False):
    n0 = len(P.V); P.V += pts; P.F.append(tuple(range(n0, n0 + len(pts))))
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0]); nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    P.C += [col(p, nrm) if callable(col) else col for p in pts]
    P.UV.append(uvs or [proj_uv(p, nrm, CUR[0]) for p in pts]); P.M.append(CUR[0]); P.S.append(smooth); P.T.append(TEIL[0])
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
            P.F.append((a, b, c, d)); P.M.append(CUR[0]); P.S.append(smooth); P.T.append(TEIL[0])
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
        P.UV.append([proj_uv(v.co, f.normal, CUR[0]) for v in f.verts]); P.M.append(CUR[0]); P.S.append(True); P.T.append(TEIL[0])
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
# Lauf 287 (Prüfer: „Halle wirkt wie ein Durchgang“): die Halle weiter und tiefer als die anderen Orte (CaveScene: weit und hoch)
WEIT = {'eingang': 8.5, 'gang': 5.2, 'halle': 12.5, 'teich': 9.0, 'lager': 8.0}[SPOT]          # m quer bis zur Wand (Kampfmitte)
HINTEN = {'eingang': 9.0, 'gang': 8.0, 'halle': 12.5, 'teich': 10.0, 'lager': 8.5}[SPOT]      # m hinter der Kampfmitte bis zur Rückwand
HOCH = {'eingang': 8.0, 'gang': 6.0, 'halle': 11.0, 'teich': 8.5, 'lager': 7.5}[SPOT]          # Wandhöhe bis zum Überhang
MUND = {'eingang': (-1.2, 3.4, 3.6), 'gang': (0.8, 1.4, 2.5), 'halle': (-1.0, 3.6, 3.8),
        'teich': (3.4, 1.8, 2.3), 'lager': (-0.6, 1.8, 2.3)}[SPOT]
if SPOT == 'gang':      # Lauf 287 (Prüfer: „Gang nicht eng“): Loch so schmal wie alt (CaveCam holeW 1,2 statt 1,4 halb breit)
    MUND = (0.8, 1.15, 2.4)       # Mund in der Rückwand: quer (+ rechts), halbe Breite, Höhe
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
# Figuren wie kampfort.gd _stand (Probe: Held, Söldner, Wolfsrudel zwei vorn, einer hinten mittig, BACK_GAP; dazu die übrigen
# Plätze): Mitte a, b, halbe Länge längs a, halbe Breite, Höhe. Wolf (Kauf) 2,3 m lang, 0,7 breit, mit FOE_SIZE etwa 1,2 hoch
FIGUREN = [(a, b, 0.35, 0.35, 1.9) for a, b in ((-2.4, -0.9), (-2.4, 0.9), (-3.3, -0.1), (-3.3, 1.3), (-2.75, 0.35))] + \
          [(a, b, 1.15, 0.4, 1.25) for a, b in ((1.95, -1.65), (1.4, 1.2), (2.9, -1.2), (2.9, 1.2), (5.3, -1.0), (5.3, -2.0), (2.0, -1.3), (3.9, -1.65))]
def figur_rechteck(f):
    xs = [bild(fight(f[0] + da, f[1] + db, dz)) for da in (-f[2], f[2]) for db in (-f[3], f[3]) for dz in (0, f[4])]
    return min(q[0] for q in xs), max(q[0] for q in xs), min(q[1] for q in xs), max(q[1] for q in xs), min(q[2] for q in xs)
PROBE_FIGUREN = FIGUREN[:2] + [FIGUREN[5], FIGUREN[6], FIGUREN[10]]     # Probe (probe.gd): Held, Söldner, drei Wölfe
def deckt_figur(p, r, h, figuren=None):
    """Lauf 287 (Prüfer: „Steinkegel wie aus Wolfsrücken“): ein Kegel bei p (Halbmesser r, Höhe h) läge im Bild hinter einer Figur und
    sähe aus, als wüchse er aus ihr; 10 Punkte Rand"""
    xs = [bild(p + Vector((dx, dy, dz))) for dx in (-r, r) for dy in (-r, r) for dz in (0.0, h)]
    x0 = min(q[0] for q in xs) - 10; x1 = max(q[0] for q in xs) + 10; y0 = min(q[1] for q in xs) - 10; y1 = max(q[1] for q in xs) + 10
    t = min(q[2] for q in xs)
    for f in (figuren or FIGUREN):
        fx0, fx1, fy0, fy1, ft = figur_rechteck(f)
        if x0 < fx1 and fx0 < x1 and y0 < fy1 and fy0 < y1 and t > ft - 0.5: return True
    return False

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
        # Lauf 287 (Prüfer: „Teichwasser flache Fläche ohne Tusche“): das Ufer fiel weich bis unter das Wasser, ohne Kante; jetzt ein
        # Uferrand: steil 0,45 m hinab, das Wasser 0,25 m darunter, der vordere Rand verdeckt es (Tiefensprung, die Tusche zeichnet ihn)
        z -= 0.45 * (1 - ss(0.92, 1.1, im_teich(a, b)))
    return z

def wand_punkt(s, z):
    """Wand um die Kampfmitte: s von -1 (links) über 0 (hinten) bis 1 (rechts), Höhe z; oben neigt sie sich als Decke herein"""
    ang = s * math.radians(105)                     # bis 105° zur Seite: die Seitenwände kommen bis vor die Kämpfer
    a = HINTEN * math.cos(ang); b = WEIT * math.sin(ang)
    if abs(s) > 0.75:                                # vorn laufen die Seitenwände an der Kamera vorbei
        a -= (abs(s) - 0.75) * 14.0
    # Lauf 287 (Strahlen: die rechte Seitenwand vorn verdeckte 5 m hoch oben rechts im Bild Joch und Fackel): vorn rechts, wo sie an
    # der Kamera vorbeiläuft, ist sie niedriger; die Kamera (7 m hoch) sieht über sie hinweg. Links bleibt sie (Bildecke oben links)
    if s > 0: z = z * (1 - 0.5 * ss(0.62, 0.95, s))
    over = ss(0.55, 1.0, z / HOCH) * (2.2 if SPOT == 'gang' else 3.2)     # Überhang: oben herein (Decke über dem hinteren Teil)
    k = 1 - over / max(math.hypot(a, b), 1.0)
    rough = 0.55 * (fbm(s * 9.0, z * 0.45, 11) - 0.5) + 0.2 * (fbm(s * 31.0, z * 1.4, 12) - 0.5)
    p = fight(a * k, b * k, z)
    out = Vector((a, -b, 0)).normalized()
    return p + out * rough * 2.0
# Lauf 287 (Prüfer: „Halle wirkt wie ein Durchgang“): wie alt (CaveCam.inHole) hat nur der Eingang (Ausgang ins Licht) und der Gang
# (er geht weiter) ein Loch in der Rückwand; Halle, Teich und Lager sind hinten zu
MIT_MUND = SPOT in ('eingang', 'gang')
def im_mund(s, z):
    if not MIT_MUND: return False
    lat = view(wand_punkt(s, 0.0))[1]
    cx, hb, hh = MUND
    if view(wand_punkt(s, 0.0))[0] < 17.0: return False
    dx = (lat - cx) / hb; dz = (z - hh * 0.45) / (hh * 0.55)
    return dx * dx + dz * dz < 1.0 + 0.12 * (fbm(s * 7, z, 31) - 0.5)

# Rückwand und Seiten, mit Loch für den Mund. Lauf 287 (Prüfer: „schwarzes Rechteck hinten im Gang“): das Loch fiel aus Rasterzellen
# von 0,9 × 0,5 m, eckig wie eine Tür; jetzt doppelt so fein
with use('feldstein'), teil('wand'):
    S_N, Z_N = (128, 40) if MIT_MUND else (64, 22)
    rows = [[wand_punkt(-1 + 2 * k / (S_N - 1), HOCH * 1.35 * i / (Z_N - 1)) for k in range(S_N)] for i in range(Z_N)]
    col = rock_col()
    n_vor = len(P.F)
    grid(rows, col)
    keep = []
    for idx in range(n_vor, len(P.F)):
        i = (idx - n_vor) // (S_N - 1); k = (idx - n_vor) % (S_N - 1)
        s = -1 + 2 * (k + 0.5) / (S_N - 1); z = HOCH * 1.35 * (i + 0.5) / (Z_N - 1)
        keep.append(not im_mund(s, z))
    for L_ in (P.F, P.M, P.S, P.UV, P.T):
        L_[n_vor:] = [m for m, ok in zip(L_[n_vor:], keep) if ok]
    # Decke: vom oberen Rand der Wand zur Mitte über dem hinteren Teil (die Kamera sieht sie nur am oberen Bildrand)
    # Lauf 287 (Strahlen: im Gang lag die Decke vorn rechts 5 m hoch über den Helden, vor Joch und Fackel): nur über dem hinteren Teil
    top = [p for k, p in enumerate(rows[-1]) if -0.8 < -1 + 2 * k / (S_N - 1) < 0.62]
    mid = [fight(HINTEN * 0.15, 0, HOCH * 1.5) + (p - fight(HINTEN * 0.15, 0, HOCH * 1.5)) * 0.25 for p in top]
    with teil('decke'):
        grid([top, mid], col)

# Hinter dem Mund: ein Gang, der sich ins Dunkel verliert (Eingang: kurz, dahinter draußen Himmel, Bäume, Wiese; CaveScene mouth).
# Lauf 247: geschlossener Gang (Boden, Wände, Decke) ab der Wand, nach hinten dunkler; die Prüfung am Ende bricht ab, wenn ein Strahl
# nichts trifft. Lauf 287 (Prüfer: „heller Sichelbogen oben rechts“): der helle Rand am Mund (0x9A8E80) lag im Licht der Lampe am Mund
# als Bogen über dem Loch; ohne ihn bleibt der Gang Fels wie die Wand
cx, hb, hh = MUND
anfang = tief = quer = mitte_mund = None
if MIT_MUND:
    s_mund = min(((abs(view(wand_punkt(k / 200.0, 0.0))[1] - cx), k / 200.0) for k in range(-150, 151)
                  if view(wand_punkt(k / 200.0, 0.0))[0] > 17.0))[1]
    wand_mund = wand_punkt(s_mund, 0.0); wand_mund.z = 0.0
    tief = (wand_mund - CAM); tief.z = 0; tief = tief.normalized()
    quer = Vector((tief.y, -tief.x, 0))
    GANG_L = 2.6 if SPOT == 'eingang' else 7.0
    anfang = wand_mund - tief * 0.9                  # vor der Wand beginnen: die Wand ist rau (±0,5 m) und das Loch grob
    mitte_mund = wand_mund + tief * 1.0              # für Licht und Merkpunkt
    boden_mund = boden_z(anfang.x, -anfang.y) - 0.12
    def gang_punkt(d, th):
        """Querschnitt des Gangs d m hinter dem Anfang: Bogen über dem Boden, th 0 (links) bis pi (rechts); er wird enger und biegt ab"""
        k = d / GANG_L
        w = (hb + 0.9) * (1 - 0.35 * k); h = (hh * 1.3 + 0.5) * (1 - 0.3 * k)
        biege = quer * (0.0 if SPOT == 'eingang' else (hb + 0.9) * 1.4 * k * k)     # biegt so weit ab, dass man das Ende nicht sieht
        rau = 1 + 0.06 * (fbm(d * 0.9, th * 2.0, 41) - 0.5)
        return anfang + tief * d + biege + quer * (-math.cos(th) * w * rau) + Vector((0, 0, boden_mund + math.sin(th) * h * rau))
    def gang_col(hell_d, hell_h, ende):
        base = rock_col(hell_d, hell_h)
        def col(p, n):
            d = (p - anfang).dot(tief)
            # Lauf 287 (Prüfer: „schwarzes Rechteck hinten im Gang“): bis 0,92 zu fast Schwarz las sich das Ende als Tafel; 0,7
            return mixc(base(p, n), ende, ss(1.0, GANG_L, d) ** 0.8 * (0.0 if SPOT == 'eingang' else 0.7))
        return col
    DS = [GANG_L * i / 10 for i in range(11)]
    with use('feldstein'), teil('gang'):
        bogen = [[gang_punkt(d, math.pi * j / 16) for j in range(17)] for d in DS]
        grid(bogen, gang_col(FELS_D, FELS_H, lin(0x0A0908)))
    with use('erde'), teil('gang'):
        grid([[r[0] + (r[-1] - r[0]) * t for t in (0, 0.25, 0.5, 0.75, 1.0)] for r in bogen], gang_col(BODEN_D, BODEN_H, lin(0x0C0A08)))
    if SPOT != 'eingang':
        with use('dunkel'), teil('dunkel'):      # Abschluss tief im Gang, kaum noch zu sehen (der Gang biegt ab)
            e = bogen[-1]
            add_face([e[0] - Vector((0, 0, 0.3)), e[-1] - Vector((0, 0, 0.3)), e[-1] + Vector((0, 0, hh * 2.0)), e[0] + Vector((0, 0, hh * 2.0))],
                     lin(0x060505))
    else:
        # draußen wie CaveScene: blasser Himmel (oben bläulich), Baumreihe mit unruhiger Krone, ein Streifen Wiese.
        # Lauf 287 (Prüfer: „draußen flache Flächen ohne Textur und Tusche“, 457): Wiese, Kronen und Stämme jetzt gemalt (Bilder gras,
        # laub, rinde aus tex.py) und im Toon-Licht der Sonne; Godot hält nur die Lampen der Höhle und den Dunst von ihnen fern
        # (kampfort.gd DRAUSSEN); der Himmel bleibt ein Verlauf ohne Licht
        aus_ = anfang + tief * GANG_L
        weit = 9.0
        with use('draussen_gras'), teil('draussen'):    # Wiese steigt leicht an
            grid([[aus_ + tief * d + quer * q + Vector((0, 0, boden_mund + 0.03 * d * d / weit)) for q in (-9, -6, -3, 0, 3, 6, 9)]
                  for d in (-0.4, 1.0, 2.0, 3.2, 4.5, 5.8, 7.0, weit)],
                 lambda p, n: mixc(lin(0xD8E8B0), lin(0xB0C890), ss(0.0, weit, (p - aus_).dot(tief))))
        def krone(d, n_, ton, hoch_, seed):
            for k in range(n_):
                q = -8.0 + 16.0 * (k + 0.5 * h1(k, seed)) / n_
                f = aus_ + tief * (d + 0.8 * h1(k, seed + 1)) + quer * q
                fz = boden_mund + 0.03 * d * d / weit
                hk = hoch_ * (0.75 + 0.5 * h1(k, seed + 2))
                if d < 6:                            # vordere Reihe: Stämme unter den Kronen
                    with use('draussen_rinde'):
                        cylinder(f + Vector((0, 0, fz - 0.1)), 0.13, hk * 0.55, 6, (0.9, 0.85, 0.8))
                with use('draussen_laub'):
                    blob(f + Vector((0, 0, fz + hk * 0.7)), hk * 0.42, lambda p, n, c=ton: mixc(c, (1.0, 1.0, 1.0), 0.15 + 0.35 * max(0.0, n.z)),
                         sub=2, squash=1.25, seed=k + seed, bump=0.35)
        with teil('draussen'):
            krone(weit - 1.5, 9, mixc((0.62, 0.72, 0.66), (0.86, 0.92, 0.98), 0.35), 4.6, 70)     # hinten, im Dunst
            krone(4.5, 7, (0.55, 0.66, 0.55), 4.0, 80)                                            # vorn, dunkler
        with use('himmel'), teil('himmel'):
            hz = boden_mund + hh * 2.6
            add_face([aus_ + tief * (weit + 1) - quer * 14 + Vector((0, 0, boden_mund - 0.5)), aus_ + tief * (weit + 1) + quer * 14 + Vector((0, 0, boden_mund - 0.5)),
                      aus_ + tief * (weit + 1) + quer * 14 + Vector((0, 0, hz)), aus_ + tief * (weit + 1) - quer * 14 + Vector((0, 0, hz))],
                     lambda p, n: mixc(lin(0xE8F0F0), lin(0xB8D0E4), ss(boden_mund + hh * 0.4, hz, p.z)))

# Boden: eben auf den Plätzen, nach außen buckelig und zur Wand hin ansteigend; Kies, Pfützen (CaveScene floor, gravel, puddles)
with use('erde'), teil('boden'):
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

# Tropfsteine an der Decke (hängend), erst nach dem, was den Ort ausmacht (stoerer): nie vor einem Merkpunkt, nie auf einer Figur
def tropfsteine():
    n_hang = 26 if SPOT == 'halle' else 16
    for i in range(n_hang):
        s = -0.85 + 1.7 * (i + rnd.random() * 0.8) / n_hang
        p = wand_punkt(s, HOCH * 1.05)
        p = p + (fight(0, 0, p.z) - p) * rnd.uniform(0.05, 0.25)
        L = (1.0 if SPOT == 'halle' else 0.7) + rnd.random() ** 2 * (3.4 if SPOT == 'halle' else 2.2)
        r = 0.22 + 0.25 * rnd.random()
        if abs(p.x) < 5.6 and abs(p.y) < 4.0:
            L = min(L, p.z - 3.8)     # über den Plätzen hängt kein Tropfstein in die erhobene Waffe
        while L > 0.4 and (deckt_figur(p - Vector((0, 0, L)), r, L) or deckt_merk(p - Vector((0, 0, L)), r, L)):
            L *= 0.7                  # Lauf 287 (Prüfer: „Steinkegel wie aus Wolfsrücken“): die Spitze endete im Bild auf einer Figur
        if L <= 0.4: continue
        with use('feldstein'), teil('tropf'):
            cone(p, r, L, 7, rock_col(), seed=i, down=True)

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
            P.F.append(tuple(n0 + i for i in poly.vertices)); P.M.append('feldstein'); P.S.append(True); P.T.append(TEIL[0])
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
    """Tropfsteine an der Decke und am Wandfuß, Felsbrocken an den Seiten, erst nach dem, was den Ort ausmacht: nie davor, nie
    hinter einer Figur (Lauf 287)"""
    tropfsteine()
    with use('feldstein'), teil('tropf'):
        for i in range(10 if SPOT != 'gang' else 6):
            s = rnd.uniform(-0.95, 0.95)
            p = wand_punkt(s, 0.0); p = p + (fight(0, 0) - p) * rnd.uniform(0.04, 0.12); p.z = -0.05
            a, b = p.x, -p.y
            if abs(a) < 6.0 and abs(b) < 4.2: continue
            r, L = 0.25 + 0.3 * rnd.random(), 0.8 + rnd.random() * 2.2
            if deckt_merk(p, r, L) or deckt_figur(p, r, L): continue
            cone(p, r, L, 7, rock_col(), seed=i + 40)
    for i in range(7):
        for _ in range(30):
            r = rnd.uniform(0.45, 1.0)
            a = rnd.uniform(-3, HINTEN - 1); b = rnd.choice((-1, 1)) * rnd.uniform(max(4.6, 3.8 + r), max(WEIT - 0.8, 3.9 + r))
            if all(math.hypot(a - x, -b - y) > 1.6 for x, y, _ in STEINE) and not deckt_merk(fight(a, b), r, r * 2.0) \
                    and not deckt_figur(fight(a, b), r, r * 1.4): break
        else:
            continue
        with teil('stein'):
            brocken(fight(a, b, boden_z(a, b)), r, i)

# ---------------------------------------------------------------- was den Ort ausmacht
LAMPEN = []      # (Blender-Punkt, Farbe 0xRRGGBB, Reichweite m, Stärke, Art)
def lampe(p, c, r, k, art): LAMPEN.append((p, c, r, k, art))
def flamme(p, size, art='fackel'):
    """Flamme als leuchtender Kegel (Godot: unschattiert, flackert); Licht darüber"""
    with use('flamme'), teil('flamme'):
        cone(p, size * 0.35, size * 1.3, 6, lambda q, n: mixc(lin(0xFFC860), lin(0xFF7A20), ss(p.z, p.z + size, q.z)), seed=int(size * 10))
def fackel(s, z):
    p = wand_punkt(s, z); inn = (fight(0, 0, z) - p); inn.z = 0; inn = inn.normalized()
    q = p + inn * 0.35
    with use('balken'), teil('fackel'):
        tube(q - Vector((0, 0, 0.45)) - inn * 0.1, q, 0.05, 6, lin(0x6A4A30))
    with use('feldstein'), teil('fackel'):
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
# Bestand zuerst (377, 408): Dinge aus den freien Bausätzen (Quaternius, CC0, LISTE-BESTAND.md) statt eigener Kästen; ihre eigenen
# Bilder als Textur kit_<bild> (höchstens 1024 px), getönt auf unsere Palette wie raum.py (KIT_TON)
KIT_TON = {'kit_furniture': (0.66, 0.6, 0.56), 'kit_metal': (0.8, 0.78, 0.76), 'kit_cloth': (0.9, 0.86, 0.8), 'kit_props': (0.9, 0.86, 0.82)}
KIT_LESEN = {}
def kit_teil(paket, name, p, hoch, dreh, ton=(1.0, 1.0, 1.0), stoff=None, sinken=0.03, maxtri=500):
    """Teil <name> aus dem Bausatz <paket> (Ordner unter CC0) mit Höhe <hoch> m, Fuß bei p (sinken m in den Boden), um <dreh>
    gedreht; stoff: unser Stoff statt der Bilder des Bausatzes. Fehlt der Bausatz: False (dann baut der Aufrufer selbst)"""
    d = glob.glob(glob.escape(os.path.expanduser(os.environ.get('CC0', '~/cc0'))) + '/%s/**/glTF' % paket, recursive=True)
    f = os.path.join(d[0], name + '.gltf') if d else ''
    if not f or not os.path.exists(f): return False
    if f not in KIT_LESEN:
        vor = set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=f)
        neu = [o for o in bpy.data.objects if o not in vor]
        fl = []
        for o in neu:
            if o.type != 'MESH': continue
            tris = sum(len(q.vertices) - 2 for q in o.data.polygons)
            if tris > maxtri:      # Modellregel 7 (raum.py): kleines Ding wenige Dreiecke
                mo = o.modifiers.new('weniger', 'DECIMATE'); mo.ratio = maxtri / tris
            dg = bpy.context.evaluated_depsgraph_get(); dg.update()
            me = o.evaluated_get(dg).to_mesh(); W = o.matrix_world.copy(); uvl = me.uv_layers.active
            for poly in me.polygons:
                mat = me.materials[poly.material_index] if me.materials else None
                bild = None
                if mat and mat.use_nodes:      # das Farbbild (BaseColor), nicht ORM oder Normalen
                    for nd in mat.node_tree.nodes:
                        if nd.type == 'TEX_IMAGE' and nd.image and 'basecolor' in nd.image.name.lower(): bild = nd.image
                fl.append(([W @ me.vertices[me.loops[li].vertex_index].co for li in poly.loop_indices],
                           [tuple(uvl.data[li].uv) for li in poly.loop_indices] if uvl else None, bild.filepath_from_user() if bild else None))
        for o in neu: bpy.data.objects.remove(o, do_unlink=True)
        KIT_LESEN[f] = fl
    fl = KIT_LESEN[f]
    pts = [q for x in fl for q in x[0]]
    lo = Vector([min(q[i] for q in pts) for i in range(3)]); hi = Vector([max(q[i] for q in pts) for i in range(3)])
    k = hoch / max(hi.z - lo.z, 1e-3); mx = (lo + hi) * 0.5
    ca, sa = math.cos(dreh), math.sin(dreh)
    from PIL import Image
    for q_, uv_, bild in fl:
        m = stoff
        if m is None:
            m = 'kit_' + os.path.basename(bild).replace('T_Trim_', '').replace('_BaseColor', '').split('.')[0].lower() if bild else 'weiss'
            if bild and not os.path.exists(os.path.join(TEX, m + '.png')):
                os.makedirs(TEX, exist_ok=True)
                Image.open(bild).convert('RGB').resize((1024, 1024), Image.LANCZOS).save(os.path.join(TEX, m + '.png'))
        t = KIT_TON.get(m, (1.0, 1.0, 1.0)); t = tuple(a * b for a, b in zip(t, ton))
        w = []
        for q in q_:
            x, y, z = (q.x - mx.x) * k, (q.y - mx.y) * k, (q.z - lo.z) * k - sinken
            w.append(p + Vector((x * ca - y * sa, x * sa + y * ca, z)))
        with use(m):
            add_face(w, t, uvs=uv_ if (stoff is None and uv_) else None, smooth=True)
        if stoff is None: KITSTOFF.add(m)
    return True
KITSTOFF = set()        # Stoffe mit Bildern des Bausatzes: deren Eckfarbe ist schon Tönung (nicht durch das Bild teilen)
def pilze(fx, cyan):
    """Leuchtpilze und Kristalle (CaveScene fungi): türkis, mal violett, am Wandfuß; Lauf 234: lagen unter dem ansteigenden Boden"""
    p = am_fuss(fx)
    # Lauf 287 (Prüfer: „grelle weiße Pilze“): weiße Stiele und Hüte, die ganz mit Stärke 1 leuchteten; jetzt der Pilz aus dem
    # Bestand (Stylized Nature MegaKit, Mushroom_Common, CC0), im Licht gezeichnet, nur schwach leuchtend (Stoff pilz, kampfort.gd)
    ton = (0.55, 1.0, 0.95) if cyan else (0.8, 0.65, 1.0)
    with teil('pilz'):
        for m in range(6):
            dx, dy = rnd.uniform(-0.45, 0.45), rnd.uniform(-0.45, 0.45)
            q = fight(p.x + dx, -(p.y + dy), boden_z(p.x + dx, -(p.y + dy)))
            hoch = rnd.uniform(0.14, 0.26)
            if not kit_teil('stylized-nature-megakit', 'Mushroom_Common', q, hoch, rnd.uniform(0, 6.3), ton=ton, stoff='pilz', maxtri=120):
                with use('pilz'):
                    cylinder(q, 0.025, hoch, 5, mixc(lin(0x7AF0E0 if cyan else 0xB890FF), (0.3, 0.3, 0.3), 0.5))
                    blob(q + Vector((0, 0, hoch + 0.01)), rnd.uniform(0.08, 0.15), lin(0x7AF0E0 if cyan else 0xB890FF), sub=1, squash=0.45, seed=m)
    # Lauf 287 (Prüfer: „Teichwände grün-lila“): Reichweite 5 m und Stärke 1 färbten die Wände; jetzt ein Schein am Wandfuß
    lampe(p + Vector((0, 0, 0.4)), 0x7AF0E0 if cyan else 0xB890FF, 3.2, 0.45, 'pilz')
    merk('Pilze', p + Vector((0, 0, 0.15)))
def auf_boden(a, b, dz=0.0): return fight(a, b, boden_z(a, b) + dz)

JOCHE = []
if SPOT == 'gang':
    # Stützbalken (CaveScene beams: zwei Pfosten, oben ein Querholz, um den Gang ins Dunkel). Lauf 247 (Prüfer: „Gangbalken frei“),
    # nachgestellt mit bild(): von den drei Jochen standen vorn nur Pfosten im Bild (x 139), ihre Kopfhölzer führten in die Wand;
    # das hintere stand 0,2 m hinter der Wand (Wandellipse bei b 2,7 nur bis a 6,84), sein Querbalken steckte im Fels. Jetzt zwei
    # ganze Joche vor dem Mund, quer zum Blick, Pfosten auf dem Boden, Querholz darauf, beide ganz im Bild (Prüfung unten).
    with use('balken'), teil('joch'):
        holz = lambda q, n: tuple(x * (0.75 + 0.25 * n.z + 0.1) for x in lin(0x6A4A30))
        # Lauf 287 (Prüfer: „Querbalken ohne Pfosten rechts“), nachgestellt mit Strahlen: das hintere Joch stand 0,5 m vor der rauen
        # Wand, sein linker Pfosten ganz im Fels; vom vorderen verdeckte die rechte Seitenwand vorn Pfosten oben und Balkenende.
        # Jetzt beide weiter vor der Wand und schmaler (Pfosten neben dem Loch, nicht in der Wand)
        for vor, breit_, hoch_ in ((1.15, hb + 0.25, hh + 0.25), (2.3, hb + 0.45, hh + 1.25)):     # vorn höher: Querhölzer nicht übereinander
            mitte = anfang - tief * (vor - 0.9)
            for side in (-1, 1):
                f = mitte + quer * side * breit_; f.z = boden_z(f.x, -f.y) - 0.1
                cylinder(f, 0.16, hoch_ - f.z + 0.05, 7, holz, r2=0.14)
                JOCHE.append(f.copy()); JOCHE.append(f + Vector((0, 0, hoch_ - f.z + 0.05)))
            tube(mitte - quer * (breit_ + 0.35) + Vector((0, 0, hoch_ + 0.1)), mitte + quer * (breit_ + 0.35) + Vector((0, 0, hoch_ + 0.1)),
                 0.17, 7, lin(0x5A3E28))
            merk('Querholz', mitte + Vector((0, 0, hoch_ + 0.1)), 0.2)
            for side in (-1, 1):
                merk('Querholz Ende', mitte + quer * side * (breit_ + 0.15) + Vector((0, 0, hoch_ + 0.1)), 0.18)
    # Lauf 287 (Prüfer: „Querbalken im Gang ohne Pfosten rechts“): geprüft waren nur die Pfosten des hinteren Jochs; jetzt jeder
    # Pfosten unten, in der Mitte und oben im Blick (nicht hinter Wand oder Figur)
    for j in range(0, len(JOCHE), 2):
        for t_ in (0.15, 0.5, 0.85):
            merk('Pfosten %d%s' % (j // 2 + 1, ' oben' if t_ > 0.8 else ''), JOCHE[j] * (1 - t_) + JOCHE[j + 1] * t_, 0.18)
    fackel(s_bei(0.13, 2.4), 2.4); fackel(s_bei(0.86, 2.2), 2.2)
elif SPOT == 'halle':
    # Säulen, wo Tropfstein und Stalagmit zusammengewachsen sind (CaveScene pillars): schmale Taille, unten und oben breit;
    # Lauf 234: zwei standen rechts außerhalb des Bilds, jetzt links und hinter den Gegnern
    with use('feldstein'), teil('saeule'):
        # Lauf 287: schlanker (vorher 0,8–1,0 m, im Bildplan je ein Viertel der Breite) und weiter hinten
        for (a, b, r) in ((7.2, -6.8, 0.7), (11.0, -1.7, 0.75), (11.6, -4.6, 0.6)):
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
    # Lauf 287 (Prüfer: „Teichwasser flache Fläche ohne Textur und Tusche“, 457): das Wasser hatte kein Bild (tex/wasser.png gibt es
    # nicht) und lag auf der Höhe des sanft abfallenden Ufers. Jetzt gemalt (teichwasser.png unten: dunkles Grün-Blau, Schlieren,
    # helle Glanzstriche wie WaterLife), 0,25 m unter dem Uferrand (boden_z), Kante für die Tusche
    with use('teichwasser'), teil('teich'):
        ring = []
        for k in range(48):
            t = 2 * math.pi * k / 48; w = 1 + 0.07 * math.sin(t * 3 + 1.1)
            ring.append(fight(ca + math.cos(t) * ra * w * 1.04, cb + math.sin(t) * rb * w * 1.04, -0.25))
        mitte_t = fight(ca, cb, -0.25)
        for k in range(48):
            add_face([mitte_t, ring[k], ring[(k + 1) % 48]], lambda q, n: mixc((0.75, 0.8, 0.85), (1.0, 1.0, 1.0), ss(cb + rb, cb - rb, -q.y)))
    with use('feldstein'), teil('teich'):
        for k in range(22):
            t = 2 * math.pi * k / 22
            a, b = ca + math.cos(t) * ra * 1.08, cb + math.sin(t) * rb * 1.08
            if abs(a) < 5.4 and abs(b) < 3.9: continue
            blob(auf_boden(a, b), rnd.uniform(0.1, 0.22), rock_col(), sub=1, squash=0.5, seed=k)
    merk('Wasser', fight(ca, cb, -0.25)); merk('Wasser vorn', fight(ca - ra * 0.6, cb + rb * 0.3, -0.25))
    lampe(fight(ca, cb, 1.2), 0x80B0B8, 5.0, 0.4, 'wasser')
    for k, fx in enumerate((0.04, 0.22, 0.8, 0.94)):      # Lauf 287: bei 0,62 hinter dem hinteren Wolf der Probe
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
    # Kisten, Fass, Sack aus dem Bestand (Fantasy Props MegaKit, CC0; vorher eigene Kästen). Fuß je auf dem tiefsten Punkt darunter
    # (Lauf 287, Prüfer: „schwebende Stäbchen“; der Boden steigt hier zur Wand an)
    def fuss(a, b, r):
        return fight(a, b, min(boden_z(a + da, b + db) for da in (-r, 0, r) for db in (-r, 0, r)))
    BELEGT = [(2.6, -4.9, 1.2), (3.85, -6.2, 1.3)]      # Feuer, Schlaflager
    def frei(a0, b0, r, h, muss=True):
        """Lauf 287: mit dem hinteren Wolf der Probe (5,3, −2,0) standen Kisten und Sack im Bild hinter ihm; nächster Platz bei
        (a0, b0), der im Bild frei ist, außerhalb der Plätze, vor der Wand, nicht auf Feuer oder Lager"""
        best = None; grund = {}
        for i in range(-28, 29):
            for k in range(-28, 29):
                a, b = a0 + i * 0.25, b0 + k * 0.25
                def nein(g): grund[g] = grund.get(g, 0) + 1
                if abs(a) < 5.0 + r * 0.5 and abs(b) < 3.5 + r * 0.5: nein('Platz'); continue
                if (a / HINTEN) ** 2 + (b / WEIT) ** 2 > 0.85: nein('Wand'); continue
                if any(math.hypot(a - x, b - y) < rr + r for x, y, rr in BELEGT): nein('belegt'); continue
                x_, y_, _t = bild(fight(a, b, h * 0.5))
                if not (30 < x_ < GW - 30 and 60 < y_ < GH - 120): nein('Bild'); continue
                if deckt_figur(fight(a, b, boden_z(a, b)), r, h, PROBE_FIGUREN): nein('Figur'); continue
                d = math.hypot(a - a0, b - b0)
                if best is None or d < best[0]: best = (d, a, b)
        if best is None:
            if muss: raise SystemExit('FEHLER 507: kein freier Platz bei %.1f, %.1f %s' % (a0, b0, grund))
            return None
        BELEGT.append((best[1], best[2], r))
        return best[1], best[2]
    ka, kb = frei(6.4, -1.9, 0.6, 1.3); sack = frei(5.9, -3.3, 0.4, 0.6, muss=False) or (ka - 0.2, kb - 0.75)
    sa_, sb_ = sack; fass = frei(ka + 0.4, kb + 0.9, 0.4, 1.0, muss=False)
    with teil('lager'):
        if not (kit_teil('fantasy-props-megakit', 'Crate_Wooden', fuss(ka, kb, 0.4), 0.75, 0.3) and
                kit_teil('fantasy-props-megakit', 'Crate_Wooden', fuss(ka + 0.05, kb - 0.05, 0.4) + Vector((0, 0, 0.72)), 0.55, 0.75) and
                kit_teil('fantasy-props-megakit', 'Bag', fuss(sa_, sb_, 0.35), 0.6, 2.2) and
                (fass is None or kit_teil('fantasy-props-megakit', 'Barrel', fuss(fass[0], fass[1], 0.35), 0.95, -0.2))):
            raise SystemExit('FEHLER 507: Fantasy Props MegaKit fehlt (CC0=…, cc0_laden.sh)')
    print('LAGER Kisten %.2f, %.2f; Sack %.2f, %.2f; Fass %s' % (ka, kb, sa_, sb_, fass))
    merk('Kisten', auf_boden(ka, kb, 0.9), 0.6)
    merk('Sack', auf_boden(sa_, sb_, 0.4), 0.4)
    # Schlaflager (Lauf 287, Prüfer: „kein Schlaflager erkennbar“; vorher eine dunkle Rolle): ein Fell auf dem Boden, am Kopfende
    # die gerollte Decke, ein Strohkissen; das Fell folgt dem Boden
    with teil('lager'):
        sa, sb, sl, sw, sd = 3.85, -6.2, 1.9, 0.8, -0.12        # Mitte, Länge, Breite, Drehung (rad)
        ax = Vector((math.cos(sd), math.sin(sd), 0)); qx = Vector((-ax.y, ax.x, 0))
        def matte(u, v, dz):
            q = fight(sa, sb) + ax * (u * sl / 2) + qx * (v * sw / 2)
            rand = 1 - 0.12 * abs(v) ** 6
            return Vector((q.x, q.y, boden_z(q.x, -q.y) + dz * rand))
        with use('stoff'):
            grid([[matte(u / 6 - 1, v / 3 - 1, 0.05) for v in range(7)] for u in range(13)],
                 lambda q, n: mixc(lin(0x4A3A2C), lin(0x7A6448), 0.35 + 0.4 * fbm(q.x * 3, q.y * 3, 61)))
            kopf = matte(0.78, 0, 0.0)
            tube(kopf - qx * (sw * 0.48) + Vector((0, 0, 0.16)), kopf + qx * (sw * 0.48) + Vector((0, 0, 0.16)), 0.14, 10, lin(0x6A4030))
        with use('heu'):
            blob(matte(0.5, 0.05, 0.0) + Vector((0, 0, 0.1)), 0.2, lin(0xA08A50), sub=2, squash=0.45, seed=62, stretch=(1.0, 1.4))
    merk('Schlaflager', matte(0.0, 0, 0.12), 0.3)
    # Knochen: jedes Ende auf dem Boden (vorher die Mitte; am Hang schwebten die Enden)
    with use('weiss'), teil('lager'):
        for k in range(6):
            a, b = 6.8 + rnd.uniform(-0.5, 0.5), -4.4 + rnd.uniform(-0.5, 0.5)
            d = Vector((math.cos(k * 1.7), math.sin(k * 1.7), 0)) * rnd.uniform(0.18, 0.35)
            e0 = fight(a, b) - d; e1 = fight(a, b) + d
            e0.z = boden_z(e0.x, -e0.y) + 0.025; e1.z = boden_z(e1.x, -e1.y) + 0.025
            tube(e0, e1, 0.03, 6, lin(0xC8BCA0), r1=0.026)
            for e in (e0, e1):     # Gelenkköpfe
                blob(e, 0.045, lin(0xD0C4A8), sub=1, squash=0.8, seed=k)
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
# Lauf 287 (Teichwände grün-lila): in Halle und Teich war es türkis wie die Pilze; jetzt kühl, fast weiß
licht = {'eingang': 0xFFF0E0, 'gang': 0xFFB070, 'halle': 0xC8D4DC, 'teich': 0xC8D4DC, 'lager': 0xFFC890}[SPOT]
# Messlauf 293 (Licht 0,5): in Halle und Teich, ohne Fackel nahe den Gegnern, der vordere Wolf innen 10–11 von 255, im Gang 24
# (Fackeln nah); dort das Licht über dem Kampf stärker
lampe(fight(0.5, 0.0, 4.0), licht, 8.5, 0.9 if SPOT in ('halle', 'teich') else 0.55, 'kampf')
if SPOT == 'eingang':     # Tageslicht aus dem Mund, weit und kühl-hell
    # Lauf 287 (Prüfer: „heller Sichelbogen oben rechts“; Bildplan: der Bogen des kurzen Gangs zieht oben rechts durchs Bild): die
    # Lampe hing oben im Mund und strahlte die Innenseite des Bogens an; jetzt tief am Ausgang, das Licht fällt herein über den Boden
    lampe(anfang + tief * GANG_L + Vector((0, 0, boden_mund + 0.9)), 0xF0F4E8, 13.0, 1.2, 'tag')

# ---------------------------------------------------------------- Netz und Ausgabe
# Bilder, die tex.py nicht malt: draußen (Lauf 287, 457) dieselben wie im Dorf, das Teichwasser hier
import shutil
import numpy as np
from PIL import Image
for ziel, quelle in (('draussen_gras', 'gras'), ('draussen_laub', 'laub'), ('draussen_rinde', 'rinde')):
    if os.path.exists(os.path.join(TEX, quelle + '.png')) and not os.path.exists(os.path.join(TEX, ziel + '.png')):
        shutil.copy(os.path.join(TEX, quelle + '.png'), os.path.join(TEX, ziel + '.png'))
if 'teichwasser' in P.M:
    N = 512; yy, xx = np.mgrid[0:N, 0:N] / N
    def wn(u, v, f, s_):      # kachelbares Rauschen aus Sinusen (wie die Schlieren in WaterLife)
        return sum(np.sin(2 * np.pi * (u * f * a + v * f * b) + s_ * (a + 3 * b)) for a, b in ((1, 0), (0, 1), (1, 1), (1, -1))) / 4
    tief_ = 0.5 + 0.5 * wn(xx, yy, 2, 1.3) * 0.6 + 0.2 * wn(xx, yy, 5, 2.1)
    rand_ = np.array([0x2A, 0x3A, 0x3C]) / 255.0; tief_c = np.array([0x0E, 0x1A, 0x1E]) / 255.0
    bild_ = rand_ * (1 - tief_[..., None]) + tief_c * tief_[..., None]
    streif = np.abs(np.sin(2 * np.pi * (yy * 9 + 0.35 * wn(xx, yy, 3, 0.7))))
    glanz = np.clip((streif - 0.965) / 0.03, 0, 1) * np.clip(wn(xx, yy, 2, 4.0) * 1.5, 0, 1)
    bild_ = bild_ * (1 - 0.45 * glanz[..., None]) + (np.array([0x7A, 0x8E, 0x90]) / 255.0) * 0.45 * glanz[..., None]
    os.makedirs(TEX, exist_ok=True)
    Image.fromarray((np.clip(bild_, 0, 1) * 255).astype(np.uint8)).save(os.path.join(TEX, 'teichwasser.png'))

# Lauf 287 (Prüfer: 44 % fast schwarz; Messlauf 242: Szene p50 0 bei Licht 3; tests/hoehle_farben_507.gd): toon.gdshader rechnet
# Albedo = Bild mal Eckfarbe; die Eckfarben hier waren die ganze Farbe (Fels 0x3A..0x8A, Boden 0x4A..0x8A) und das Bild malte sie
# noch einmal: Boden 0,13 mal 0,09 = 1 % Helligkeit. Wie im Dorf (raum.py KIT_TON) ist die Eckfarbe jetzt Tönung: die gewünschte
# Farbe geteilt durch das Mittel des Bilds (je Kanal, höchstens 1); Stoffe ohne Bild (Flamme, Glut, Pilz, Himmel) bleiben
MITTEL = {}
def bild_mittel(name):
    if name not in MITTEL:
        f = os.path.join(TEX, name + '.png'); MITTEL[name] = None
        if os.path.exists(f) and name not in KITSTOFF and not name.startswith('draussen') and name != 'teichwasser':
            a = np.asarray(Image.open(f).convert('RGB').resize((128, 128)), np.float32) / 255.0
            a = np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
            MITTEL[name] = tuple(max(float(x), 0.02) for x in a.mean(axis=(0, 1)))
    return MITTEL[name]
TOENUNG = {}
# Ist ein Bild heller als die Farbe (Boden: erde.png wie der alte Boden 0x5E5248), läge die Tönung über 1 und das Rauschen der Farbe
# ginge im Abschneiden verloren: dann je Kanal so gedämpft, dass die Tönung im Mittel 0,85 ist
DAEMPFUNG = {}
for k_, m_ in enumerate(P.M):
    bm_ = bild_mittel(m_)
    if not bm_: continue
    d_ = DAEMPFUNG.setdefault(m_, [0.0, 0.0, 0.0, 0])
    for j in P.F[k_]:
        for ch in range(3): d_[ch] += P.C[j][ch] / bm_[ch]
        d_[3] += 1
for m_, d_ in DAEMPFUNG.items():
    DAEMPFUNG[m_] = tuple(min(1.0, 0.85 / max(d_[ch] / d_[3], 1e-3)) for ch in range(3))
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
# Zwei Netze: die Höhle und draußen (Lauf 287): Godot hält von „Draussen“ die Lampen der Höhle fern (eigene Lichtebene) und den
# Dunst, die Sonne zeichnet es im Toon-Licht wie den Wald
def netz(name, nur):
    ks = [k for k in range(len(P.F)) if nur(P.M[k])]
    if not ks: return None
    me = bpy.data.meshes.new(name)
    me.from_pydata([tuple(v) for v in P.V], [], [tuple(P.F[k]) for k in ks])
    names_ = sorted(set(P.M[k] for k in ks)); idx_ = {n: i for i, n in enumerate(names_)}
    for n in names_: me.materials.append(material(n))
    ca_ = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
    for poly, k in zip(me.polygons, ks):
        poly.material_index = idx_[P.M[k]]; poly.use_smooth = P.S[k]
        bm_ = bild_mittel(P.M[k])
        for j, li in enumerate(poly.loop_indices):
            c = P.C[me.loops[li].vertex_index]
            if bm_: c = tuple(min(1.0, x / m_ * f_) for x, m_, f_ in zip(c, bm_, DAEMPFUNG[P.M[k]]))
            t_ = TOENUNG.setdefault(P.M[k], [0.0, 0.0, 0.0, 0]); t_[0] += c[0]; t_[1] += c[1]; t_[2] += c[2]; t_[3] += 1
            ca_.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
    me.validate(); me.update()
    ob = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(ob)
    return ob
DRAUSSEN = lambda m: m.startswith('draussen') or m == 'himmel'
obs = [o for o in (netz('Hoehle', lambda m: not DRAUSSEN(m)), netz('Draussen', DRAUSSEN)) if o]
print('TOENUNG', SPOT, ', '.join('%s %.2f/%.2f/%.2f' % (n, t[0] / t[3], t[1] / t[3], t[2] / t[3]) for n, t in sorted(TOENUNG.items())))
names = sorted(set(P.M))
tris = sum(len(f) - 2 for f in P.F)
bpy.ops.object.select_all(action='DESELECT')
for o in obs: o.select_set(True)
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
blick_fehler = []
for name, q, r in MERK:
    x, y, t = bild(q)
    zum = AUGE - q; dist = zum.length; zum.normalize()
    treffer = bvh.ray_cast(q + zum * r, zum, dist - r - 0.1)
    hinter = [f for f in PROBE_FIGUREN if t > bild(fight(f[0], f[1]))[2] + 0.3 and
              figur_rechteck(f)[0] < x < figur_rechteck(f)[1] and figur_rechteck(f)[2] < y < figur_rechteck(f)[3]]
    stand = 'außerhalb' if not (12 < x < GW - 12 and 40 < y < GH - 10) else ('verdeckt' if treffer[0] is not None else ('hinter Figur' if hinter else 'sichtbar'))
    wo = '' if treffer[0] is None else ' von %s (%s) bei %.1f m (%.1f, %.1f, %.1f)' % (P.M[treffer[2]], P.T[treffer[2]], treffer[3], treffer[0].x, -treffer[0].y, treffer[0].z)
    print('BLICK %s %s: %.0f, %.0f, %.1f m %s%s' % (SPOT, name, x, y, t, stand, wo))
    if stand == 'hinter Figur' and name.startswith('Pfosten') and not name.endswith('oben'): stand = 'sichtbar (unten hinter Figur)'
    if stand == 'verdeckt' and name.startswith(('Pfosten', 'Querholz')) and P.T[treffer[2]] == 'joch': stand = 'sichtbar (hinter dem vorderen Joch)'
    if not stand.startswith('sichtbar'): blick_fehler.append(name + ' ' + stand)
# Lochprüfung (Lauf 247: schwarze Leerrechtecke): Strahlen vom Auge durch jeden 4. Bildpunkt der Szene; trifft einer nichts,
# sähe man dort den schwarzen Hintergrund. Dazu der Anteil je Stoff (dunkel = Abschluss des Gangs, soll kaum zu sehen sein)
VOR, RECHTS, OBEN = Vector((0.866, 0.5, 0)), Vector((0.5, -0.866, 0)), Vector((0, 0, 1))
anteil = {}; leer = []
for y in range(0, int(GH), 4):
    for x in range(0, int(GW), 4):
        d = (VOR + RECHTS * ((x - GW / 2) / GF) - OBEN * ((y - GHOR) / GF)).normalized()
        h = bvh.ray_cast(AUGE, d, 150.0)
        m = 'nichts' if h[0] is None else P.M[h[2]]
        anteil[m] = anteil.get(m, 0) + 1
        if h[0] is None: leer.append((x, y))
n_ = sum(anteil.values())
# Bildplan (Lauf 287): je Feld von 15 Punkten der vorderste Teil, Figuren als @ (Rechteck wie oben), ohne Bild nachzusehen
ZEICHEN = dict(wand='W', decke='D', boden='.', gang='G', dunkel='#', draussen='d', himmel='h', tropf='t', stein='s', fackel='f',
               flamme='F', pilz='p', saeule='S', teich='~', joch='J', lager='L', laub=',')
FR = [figur_rechteck(f) for f in PROBE_FIGUREN]
for y in range(0, int(GH), 15):
    zeile = ''
    for x in range(0, int(GW), 15):
        d = (VOR + RECHTS * ((x - GW / 2) / GF) - OBEN * ((y - GHOR) / GF)).normalized()
        h = bvh.ray_cast(AUGE, d, 150.0)
        c = ' ' if h[0] is None else ZEICHEN.get(P.T[h[2]], '?')
        if any(r[0] < x < r[1] and r[2] < y < r[3] for r in FR): c = '@'
        zeile += c
    print('PLAN %s %3d %s' % (SPOT, y, zeile))
print('LOCH %s %s' % (SPOT, ', '.join('%s %.1f %%' % (m, 100.0 * k / n_) for m, k in sorted(anteil.items(), key=lambda kv: -kv[1]))))
if leer:
    blick_fehler.append('Loch im Bild (%d Strahlen, x %d-%d, y %d-%d)' % (len(leer), min(q[0] for q in leer), max(q[0] for q in leer),
                                                                       min(q[1] for q in leer), max(q[1] for q in leer)))
if anteil.get('dunkel', 0) > 0.003 * n_:
    blick_fehler.append('Abschluss des Gangs zu sehen (%.1f %%)' % (100.0 * anteil['dunkel'] / n_))
for q in JOCHE:     # Lauf 247: Pfosten ohne Querholz; jedes Joch ganz im Bild
    x, y, _t = bild(q)
    if not (8 < x < GW - 8 and 30 < y < GH):
        blick_fehler.append('Joch außerhalb (%.0f, %.0f)' % (x, y))
if blick_fehler:
    print('FEHLER 507: nicht im Bild', blick_fehler)
    raise SystemExit(1)
# Prüfung: nichts auf den Plätzen (a ±5, b ±3,5) zwischen 3 cm und 3,6 m (Platz für Figuren mit erhobener Waffe)
hoch = [v for v in P.V if abs(v.x) < 5.0 and abs(v.y) < 3.5 and 0.03 < v.z < 3.6]
if hoch:
    wer = {P.T[k] for k, f in enumerate(P.F) for j in f if abs(P.V[j].x) < 5.0 and abs(P.V[j].y) < 3.5 and 0.03 < P.V[j].z < 3.6}
    print('PLÄTZE belegt von', wer)
print('HOEHLE', SPOT, 'Dreiecke', tris, 'Lampen', len(LAMPEN), 'Stoffe', names, 'auf den Plätzen', len(hoch))
if hoch:
    print('FEHLER 507: etwas steht auf den Plätzen', hoch[:3])
    raise SystemExit(1)
