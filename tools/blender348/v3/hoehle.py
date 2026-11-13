# 492 (Perikles, Wochenziel 03.11. Reihe 3: „Blutzahnhöhle begehbar wie alt (Story.kt:731): Grundriss, Krogg, Grak, Lyra, Tor und
# Schlüssel“): die Höhle als Grundriss aus dem Export von core (karten.json, art CAVE) wie alt MapCaveIso.kt / MapCave.kt.
# - Fels steht um den Boden auf, wie alt: an jeder Kante Boden/Fels eine raue Felswand mit Fuß, je Lauf zwei Fassungen wie die
#   Innenräume (raum.py, raumlicht.gd „waende“): hoch hinter dem Boden (alt TALL 2,4 m, dünne Wand zwischen zwei Räumen MID 1 m),
#   niedrig davor (alt RIM 0,4 m), nach der Blickrichtung der Kamera; obenauf ein dunkler Deckel, die Decke verliert sich im Dunkel.
# - Dinge je Zeichen wie MapCaveIso: Fackel (t) an der Wand, Kristalle (G) violett aus der Wand, Leuchtpilze (g), Tropfsteine (i),
#   Geröll (%), Knochen (j), Kisten und Fass (u), Schlaflager (e), Truhe (C), Lagerfeuer (F), Stützbalken (H) quer über dem Gang,
#   Gitter (L) mit zwei Flügeln an Angeln (Gitter_L, Gitter_R: Godot schwenkt sie auf, wenn gate_open), Lichtschacht (*), Teich (~),
#   Ausgang (+) zum Wald mit Tageslicht von draußen.
# - Licht nur aus Quellen wie alt MapLight.sources (CAVE): Fackel FFB060 3,6 Kacheln, Feuer FF9A48 4,4, Leuchtpilz 60E8D8 2,4,
#   Kristall B088FF 2,6, Lichtschacht und Ausgang tags hell, nachts Mond; in cave-info.json „lichter“ (raumlicht.gd).
# Bestand geprüft: nichts davon im Bestand als Höhlenfels (LISTE-BESTAND: Naturbausatz hat Felsbrocken, keine Wand); eigene Formen wie
# alt; Farben aus MapCave.kt (rock 5E564C, rockDark 3E3832, cap 2E8C88, crystal 6A5296, bone A89A7C, plank 5E4C3A, iron 4A4440).
# Ausgabe <OUT>/cave.glb (Meter, Kachel 1,16 m), cave-info.json wie raum.py (innen, lichter, waende).
# Aufruf: OUT=<ordner mit tex/> KARTE=cave KARTEN=<karten.json> python -I hoehle.py   (vorher tex.py mit demselben OUT)
import bpy, bmesh, math, os, json
from mathutils import Vector, Matrix

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
KARTEN = json.load(open(os.environ.get('KARTEN', ROOT + '/godot/daten/karten.json')))
ID = os.environ.get('KARTE', 'cave')
K = KARTEN['karten'][ID]
assert K.get('art') == 'CAVE', '%s ist keine Höhle' % ID
ROWS = K['zeilen']; NR = len(ROWS); NC = K['breite']
TS = 116.0                                           # cm je Kachel wie dorf.py, raum.py
FELS = set('XGt')                                    # alt caveRock: CAVE_WALL, CRYSTAL, TORCH (Fog.kt, MapLight opaque)
TALL = 240.0                                         # alt MapCaveIso TALL 138 / 57 je m
MID = 80.0                                           # alt MID 58 (1 m); Lauf 1 Strahltest: bei 1 m Knie des Helden hinter der Ecke verdeckt
RIM = 38.0                                           # alt RIM 22
MUND = [c for c in range(NC) if ROWS[NR - 1][c] == '+']   # Ausgang am unteren Rand: dort geht der Gang hinaus weiter
WALK = {c for c, t in KARTEN['kacheln'].items() if t['begehbar']}

AUSSEN = 4                                           # alt MapCave MOUTH = 4: der Gang laeuft vier Kacheln hinaus (Abgleich 492)
def ch(c, r):
    if 0 <= r < NR and 0 <= c < NC: return ROWS[r][c]
    if NR <= r < NR + AUSSEN and 0 <= c < NC: return '+' if c in MUND else 'X'
    return 'X'
def fels(c, r): return ch(c, r) in FELS
def tx(c): return c * TS
def ty(r): return -r * TS
def mitte(c, r): return Vector((tx(c) + TS / 2, ty(r) - TS / 2, 0))
def h1(x, y, s=0):
    n = (int(math.floor(x)) * 374761393 + int(math.floor(y)) * 668265263 + s * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFFFF) / float(0xFFFFFF)
def vn(x, y, s=0):
    ix, iy = math.floor(x), math.floor(y); u, v = x - ix, y - iy
    u = u * u * (3 - 2 * u); v = v * v * (3 - 2 * v)
    a = h1(ix, iy, s) * (1 - u) + h1(ix + 1, iy, s) * u; b = h1(ix, iy + 1, s) * (1 - u) + h1(ix + 1, iy + 1, s) * u
    return a * (1 - v) + b * v
def hash_alt(a, b, s):
    """alt MapCaveIso.hash (Kotlin Int, 32 Bit mit Ueberlauf): dieselbe Art je Kachel wie alt (Abgleich 492, Kisten, Truhe, Kristalle)"""
    def i32(n): n &= 0xFFFFFFFF; return n - (1 << 32) if n & 0x80000000 else n
    n = i32(a * 374761393 + b * 668265263 + s * 1442695041)
    n = i32((n ^ ((n & 0xFFFFFFFF) >> 13)) * 1274126177)
    return (n ^ ((n & 0xFFFFFFFF) >> 16)) & 0x7FFFFFFF
def art_alt(c, r): return (hash_alt(c, r, 41) // 7) % 3        # alt MapCaveIso 1071: CHEST, CRATE
def fbm(x, y, s=0): return 0.55 * vn(x, y, s) + 0.3 * vn(x * 2.3, y * 2.3, s + 1) + 0.15 * vn(x * 5.1, y * 5.1, s + 2)
def ss(a, b, x): t = min(1.0, max(0.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def hx(c): return ((c >> 16) & 255) / 255, ((c >> 8) & 255) / 255, (c & 255) / 255
def lin(c): return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in hx(c))
def sc(a, k): return tuple(min(1.0, x * k) for x in a)
def mixc(a, b, t): t = min(1.0, max(0.0, t)); return tuple(x + (y - x) * t for x, y in zip(a, b))
def stueck(c, r): return '%d_%d' % (int(c) // 3, int(r) // 3)

bpy.ops.wm.read_factory_settings(use_empty=True)
SCALE = dict(erde=140, feldstein=160, holz=100, balken=100, stoff=100, weiss=100, bretter=120, stroh=120)

class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.M = []; self.UV = []; self.O = None
PARTS = {}
def part(name):
    if name not in PARTS: PARTS[name] = Part()
    return PARTS[name]
LICHTER = []
WANDLISTE = []
WAND_VON = {}                                        # (Spalte, Zeile, Seite) des Bodens -> hohe Fassung der Wand dort

def add_face(P, pts, col, m, uv=None):
    """Flaeche in P; col eine Farbe (linear) oder Funktion (Punkt, Normale) -> Farbe; uv sonst planar"""
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0])
    nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    if uv is None:
        s = SCALE.get(m, 100.0)
        if abs(nrm.z) > 0.8: uv = [(p.x / s, p.y / s) for p in pts]
        elif abs(nrm.x) > abs(nrm.y): uv = [(p.y / s, p.z / s) for p in pts]
        else: uv = [(p.x / s, p.z / s) for p in pts]
    cols = [col(p, nrm) for p in pts] if callable(col) else [col] * len(pts)
    n0 = len(P.V); P.V += list(pts); P.F.append(tuple(range(n0, n0 + len(pts)))); P.C += cols; P.UV.append(uv); P.M.append(m)
def quad(P, a, b, c, d, col, m, n=None):
    """Viereck, mit n: so gewendet, dass es nach n schaut"""
    q = [a, b, c, d]
    if n is not None and (b - a).cross(d - a).dot(n) < 0: q = q[::-1]
    add_face(P, q, col, m)
def box(P, lo, hi, col, m, M=None):
    a = Vector(lo); b = Vector(hi)
    v = [Vector((x, y, z)) for z in (a.z, b.z) for y in (a.y, b.y) for x in (a.x, b.x)]
    if M is not None: v = [M @ q for q in v]
    for q in ((0, 2, 3, 1), (4, 5, 7, 6), (0, 1, 5, 4), (2, 6, 7, 3), (0, 4, 6, 2), (1, 3, 7, 5)):
        add_face(P, [v[i] for i in q], col, m)
def zylinder(P, base, r, h, n, col, m, r2=None, deckel=True, achse=None):
    """stehender Zylinder (oder Kegelstumpf r -> r2); achse: entlang Vector, base = Mitte der einen Stirn"""
    r2 = r if r2 is None else r2
    if achse is None: e1, e2, e3 = Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1))
    else:
        e3 = achse.normalized(); e1 = e3.cross(Vector((0, 0, 1)) if abs(e3.z) < 0.9 else Vector((1, 0, 0))).normalized(); e2 = e3.cross(e1)
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + (e1 * math.cos(a0) + e2 * math.sin(a0)) * r; p1 = base + (e1 * math.cos(a1) + e2 * math.sin(a1)) * r
        q0 = base + e3 * h + (e1 * math.cos(a0) + e2 * math.sin(a0)) * r2; q1 = base + e3 * h + (e1 * math.cos(a1) + e2 * math.sin(a1)) * r2
        add_face(P, [p0, p1, q1, q0], col, m)
        if deckel:
            add_face(P, [base + e3 * h, q0, q1], col, m)
            add_face(P, [base, p1, p0], col, m)
def klumpen(P, c, r, col, m, seed=0, squash=1.0, rau=0.25, n=8, lagen=5):
    """runder Brocken (Kugel, gestaucht, Oberflaeche rau), Fuss auf c.z wenn squash < 1"""
    ring = []
    for j in range(lagen + 1):
        th = math.pi * j / lagen
        row = []
        for k in range(n):
            ph = 2 * math.pi * k / n
            d = Vector((math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th)))
            f = 1.0 + rau * (vn(d.x * 2.1 + seed * 0.37, d.y * 2.1 + d.z * 1.7, seed) - 0.5) * 2
            row.append(c + Vector((d.x * r * f, d.y * r * f, d.z * r * f * squash)))
        ring.append(row)
    for j in range(lagen):
        for k in range(n):
            a, b = ring[j][k], ring[j][(k + 1) % n]; cc, d = ring[j + 1][(k + 1) % n], ring[j + 1][k]
            if j == 0: add_face(P, [a, d, cc], col, m)
            elif j == lagen - 1: add_face(P, [a, d, b], col, m)
            else: add_face(P, [a, d, cc, b], col, m)

# Lauf 1 (Pruefer 16:08: fern der Lichter nichts, Truhen nur Linien; gemessen Eckfarbe x Textur rund 1 %): Farben aus MapCave sind
# fertige Bildfarben, hier Albedo eine Stufe heller (wie kampfort_hoehle.py FELS_H 8A8076); auf Texturen nur Toenung nahe Weiss wie raum.py
ROCK = lin(0x8A8076); ROCK_D = lin(0x5E564C); SINTER = lin(0xA89C88); MOOS = lin(0x56643A)
BODEN_T = (0.95, 0.93, 0.92); BODEN_D = (0.62, 0.6, 0.62)        # Toenung auf 'erde'
HOLZ = (0.95, 0.85, 0.72); HOLZ_D = (0.6, 0.52, 0.45); EISEN = lin(0x5A5450); ROST = lin(0x6A4A34)   # Holz: Toenung auf 'bretter', 'holz'
KNOCHEN = lin(0xB8AA8C); KNOCHEN_D = lin(0x8A7C64); FELL = (0.5, 0.44, 0.38); STROH = (1.0, 0.95, 0.8); SACK = (0.92, 0.82, 0.66)
PILZ_STIEL = lin(0x8C9A90); PILZ_HUT = lin(0x2E8C88); KRISTALL = lin(0x6A5296)
VERKOHLT = lin(0x2A2220); GLUT = lin(0xE06A2A)

# ---------------------------------------------------------------- Boden
def wand_naehe(p):
    """Abstand (cm) zur naechsten Felskante, hoechstens eine Kachel"""
    c, r = int(p.x // TS), int(-p.y // TS)
    d = TS
    for dc, dr in ((-1, 0), (1, 0), (0, -1), (0, 1)):
        if fels(c + dc, r + dr):
            if dc: d = min(d, abs(p.x - tx(c + (1 if dc > 0 else 0))))
            else: d = min(d, abs(-p.y - (r + (1 if dr > 0 else 0)) * TS))
    return d
def mund_naehe(p):
    """0 tief drin, 1 draussen: vom Mund (Zeile NR - 3) bis zum Ende des Gangs (alt MapCave 944: Erde und Moos vom Wald herein)"""
    return ss(NR - 3, NR + AUSSEN - 0.5, -p.y / TS) if MUND else 0.0
def nass(p):
    """Naesse (alt MapCave 930): am Teich, unter dem Lichtspalt, in Flecken"""
    w = 0.6 * ss(0.55, 0.8, fbm(p.x / 160, p.y / 160, 33))
    for (c, r) in TEICH | SCHACHT:
        d = (Vector((p.x, p.y, 0)) - mitte(c, r)).length
        w = max(w, 1.0 - ss(TS * 0.3, TS * 1.6, d))
    return w
def boden_ton(p, n):
    k = (0.78 + 0.22 * fbm(p.x / 90, p.y / 90, 3)) * (0.75 + 0.25 * ss(0, 70, wand_naehe(p)))    # an der Wand dunkler, feucht
    c = mixc(BODEN_D, BODEN_T, 0.4 + 0.6 * vn(p.x / 40, p.y / 40, 4))
    w = nass(p)
    c = mixc(c, sc(BODEN_D, 0.55), 0.5 * w)                                                     # nasser Stein dunkler
    pf = fbm(p.x / 44, p.y / 44, 9) * 0.8 + vn(p.x / 12, p.y / 12, 10) * 0.2 + w * 0.28          # alt puddle(): flache Pfuetzen
    c = mixc(c, sc(BODEN_D, 0.45), 0.6 * ss(0.62, 0.74, pf) * (1 - mund_naehe(p)))           # Lauf 1 (Pruefer: schwarze Wellenstreifen)
    c = mixc(c, MOOS, 0.55 * ss(0.5, 0.8, vn(p.x / 30, p.y / 30, 34)) * max(w, ss(0, 40, 70 - wand_naehe(p)) * 0.5))
    m = mund_naehe(p)                                                                           # Walderde, Moos, heller nach aussen
    c = mixc(c, mixc(lin(0x5A4A30), lin(0x56643A), vn(p.x / 25, p.y / 25, 35)), 0.8 * m)
    return sc(c, k * (1 + 0.6 * m))
def boden_z(x, y): return 2.5 * fbm(x / 60, y / 60, 9)                                      # kaum uneben, die Fuesse stehen

TEICH = {(c, r) for r in range(NR) for c in range(NC) if ch(c, r) == '~'}
SCHACHT = {(c, r) for r in range(NR) for c in range(NC) if ch(c, r) == '*'}
for r in range(NR + AUSSEN):
    for c in range(NC):
        z = ch(c, r)
        if z in FELS or z == '~': continue
        P = part('Grund_' + stueck(c, min(r, NR - 1)))
        n = 5                                        # Abgleich: Pfuetzen und Moos brauchen feinere Ecken (3 -> 5)
        for i in range(n):
            for j in range(n):
                x0 = tx(c) + TS * i / n; x1 = tx(c) + TS * (i + 1) / n; y0 = ty(r) - TS * j / n; y1 = ty(r) - TS * (j + 1) / n
                q = [Vector((x0, y1, 0)), Vector((x1, y1, 0)), Vector((x1, y0, 0)), Vector((x0, y0, 0))]
                for v in q: v.z = boden_z(v.x, v.y)
                add_face(P, q, boden_ton, 'erde')

# Teich (alt WATER in der Hoehle): Wasser eine Handbreit unter dem Boden, Rand aus Sinter
for (c, r) in TEICH:
    P = part('Ding_' + stueck(c, r))
    w = -9.0
    q = [Vector((tx(c), ty(r + 1), w)), Vector((tx(c + 1), ty(r + 1), w)), Vector((tx(c + 1), ty(r), w)), Vector((tx(c), ty(r), w))]
    # Abgleich (Pruefer Lauf 2: Teich ein schwarzes Loch): Wasser mit Glanz und Stroemung wie im Wald (wasser.gdshader, Maske)
    add_face(part('Wasser_Teich'), q, lambda p, n: sc(lin(0x0C161C), 0.8 + 0.4 * vn(p.x / 50, p.y / 50, 7)), 'weiss')
    for dc, dr, a, b in ((0, -1, (0, 0), (1, 0)), (0, 1, (0, 1), (1, 1)), (-1, 0, (0, 0), (0, 1)), (1, 0, (1, 0), (1, 1))):
        if (c + dc, r + dr) in TEICH or fels(c + dc, r + dr): continue
        pa = Vector((tx(c + a[0]), ty(r + a[1]), 0)); pb = Vector((tx(c + b[0]), ty(r + b[1]), 0))
        quad(P, pa + Vector((0, 0, w - 2)), pb + Vector((0, 0, w - 2)), pb, pa, lambda p, n: sc(SINTER, 0.6), 'weiss', Vector((-dc, dr, 0)))
        for k in range(4):                                                                  # Sinterwulst am Ufer
            t = (k + 0.5) / 4
            q0 = pa + (pb - pa) * t + Vector((dc, -dr, 0)) * 6
            klumpen(P, q0, 9 + 6 * h1(c * 4 + k, r, 31), lambda p, n: sc(SINTER, 0.75 + 0.3 * vn(p.x / 9, p.y / 9, 3)), 'weiss', seed=c + k, squash=0.45)

# ---------------------------------------------------------------- Waende
SEITEN = {   # Nachbar, Linie (von, nach), nach innen (Blender)
    'N': ((0, -1), lambda c, r: (Vector((tx(c), ty(r), 0)), Vector((tx(c + 1), ty(r), 0))), Vector((0, -1, 0))),
    'S': ((0, 1), lambda c, r: (Vector((tx(c), ty(r + 1), 0)), Vector((tx(c + 1), ty(r + 1), 0))), Vector((0, 1, 0))),
    'W': ((-1, 0), lambda c, r: (Vector((tx(c), ty(r), 0)), Vector((tx(c), ty(r + 1), 0))), Vector((1, 0, 0))),
    'O': ((1, 0), lambda c, r: (Vector((tx(c + 1), ty(r), 0)), Vector((tx(c + 1), ty(r + 1), 0))), Vector((-1, 0, 0))),
}
kanten = {}
for r in range(NR + AUSSEN):
    for c in range(NC):
        if fels(c, r): continue
        for s, (d, linie, n) in SEITEN.items():
            nb = (c + d[0], r + d[1])
            if not fels(*nb): continue
            a, b = linie(c, r)
            # alt MapCaveIso.capCell MID: Boden auch jenseits der Felskachel (bis zwei Kacheln, seitlich und schraeg: „a wall two
            # tiles thick between two rooms counts as thin“) -> etwa ein Meter. Lauf 1 (Pruefer 16:08, Strahltest): nur senkrecht
            # gemessen stand 2 Kacheln neben dem Gang eine 2,4-m-Wand zur Kamera und verdeckte den Helden ganz
            duenn = any(0 <= nb[0] + a_ < NC and 0 <= nb[1] + b_ < NR and not fels(nb[0] + a_, nb[1] + b_) and a_ * d[0] + b_ * d[1] >= 0
                        and (a_, b_) != (-d[0], -d[1]) for a_ in range(-2, 3) for b_ in range(-2, 3) if (a_, b_) != (0, 0))
            schluessel = (s, round(a.y if s in 'NS' else a.x))
            kanten.setdefault(schluessel, []).append(dict(c=c, r=r, a=a, b=b, nb=nb, hoch=MID if duenn else TALL))

def laeufe():
    out = []
    for (s, _), ks in sorted(kanten.items()):
        e = (ks[0]['b'] - ks[0]['a']).normalized()
        ks.sort(key=lambda k: k['a'].dot(e))
        lauf = [ks[0]]
        for k in ks[1:]:
            if (k['a'] - lauf[-1]['b']).length < 1: lauf.append(k)
            else: out.append((s, lauf)); lauf = [k]
        out.append((s, lauf))
    return out

# 492 (Chef 04.11., 19:20 zur Hoehle: „Wie eine Betonwanne“; Pruefer 19:07: Fels glatt, hell bis zur Kante, darueber der schwarze
# Deckel): wie alt MapCaveIso.relief der Kopf der Wand im Dunkel der Decke verloren (ab 45 % bis 85 % der hohen Wand fast schwarz), der
# Fuss im Staub dunkler, Mulden zwischen den Buckeln halten das Dunkel, Risse laufen herab, nasse Bahnen; der Deckel im selben Ton,
# so gibt es oben keine harte Kante hell gegen schwarz mehr
def fels_ton(dunkel=1.0):
    def f(p, n):
        w = (p.x + p.y) / TS                                                                        # entlang der Wand, Kacheln
        k = (0.72 + 0.4 * fbm(p.x / 45 + p.y / 45, p.z / 38, 21)) * dunkel
        b0 = 0.62 * vn(w * 2.6 + p.z / 70, p.z / 70, 26) + 0.28 * vn(w * 7 + p.z / 28, p.z / 28, 27) + 0.1 * vn(w * 20 + p.z / 10, p.z / 10, 28)
        k *= 1.0 - 0.5 * ss(0.42, 0.18, b0)                                                         # Mulden (alt: 0,4 - b0)
        k *= 1.0 - 0.45 * ss(0.035, 0.0, abs(vn(w * 2.4 + p.z / 300, p.z / 90, 29) - 0.5))           # Risse herab
        k *= 1.0 - 0.12 * ss(0.72, 0.78, vn(w * 9, p.z / 200, 30))                                  # nasse Bahnen
        k *= 1.0 - 0.3 * ss(24, 0, p.z)                                                             # Fuss im Staub
        k *= 1.0 - 0.88 * ss(TALL * 0.45, TALL * 0.85, p.z)                                         # Kopf im Dunkel der Decke
        c = mixc(ROCK_D, ROCK, 0.35 + 0.65 * vn(p.x / 30 + p.y / 30, p.z / 22, 22))
        c = mixc(c, SINTER, 0.5 * ss(0.62, 0.8, vn(p.x / 70 + p.y / 70, p.z / 90, 23)))               # helle Sinterbahnen
        c = mixc(c, MOOS, 0.7 * ss(30, 0, p.z) * ss(0.55, 0.75, vn(p.x / 35 + p.y / 35, 0, 24)))    # Moos am feuchten Fuss
        return sc(c, k)
    return f
_fels_oben = fels_ton()
def deckel_ton(p, n): return sc(_fels_oben(p, n), 0.75 + 0.2 * vn(p.x / 40, p.y / 40, 25))     # wie die Wand in dieser Hoehe, etwas dunkler

def tiefe(u, z, L, seed, hn=TALL):
    """wie weit die Felsflaeche hinter der Kachelkante liegt (cm, + in den Fels): Fuss wulstet in den Raum, oben zurueck.
    492 (Betonwanne): wie alt MapCaveIso.heights steil vom Fuss, oben gerundet (alt 0,16 Kachel bei (h/Kappe)^(1/0,45)), statt
    gleichmaessig schraeg; Buckel tiefer (alt: grosse ein Drittel Kachel)"""
    rand = ss(0, 26, u) * ss(0, 26, L - u)                  # an den Enden genau auf der Kante: Ecken schliessen
    fuss = -(4 + 10 * vn(u / 35, 0.5, seed)) * (1 - ss(0, 45, z))
    rund = 24 * min(1.2, max(0.0, z / hn)) ** 2.2
    rau = ss(0, 50, z) * (10 + 32 * fbm(u / 40, z / 34, seed + 1) + 7 * (0.5 + 0.5 * math.sin(z / 21 + 3 * fbm(u / 80, 0.3, seed + 2)))) + rund   # Lauf 1: Waende wie Kaesten
    return rand * (fuss + rau)

def flaeche(P, a, e, n, L, hoehen, ton, seed, deckel=True):
    """raue Felswand von a entlang e (Laenge L), Hoehe je Kachel aus hoehen (sanft uebergeblendet), nach n gewandt"""
    nu = max(2, round(L / 14)); nz = max(2, round(max(hoehen) / 16))   # 492: feiner fuer die Buckel (vorher 20 und 24 cm)
    def nenn(u):
        i = min(len(hoehen) - 1, int(u // TS)); f = u - i * TS
        h = hoehen[i]
        if f < 25 and i > 0: h = hoehen[i - 1] + (h - hoehen[i - 1]) * ss(-25, 25, f)
        if f > TS - 25 and i < len(hoehen) - 1: h = h + (hoehen[i + 1] - h) * ss(TS - 25, TS + 25, f)
        return h
    def H(u):
        # 492 (Betonwanne): Knubbel obenauf wie alt (0,8 + 0,28 x Rauschen mit 1,7 und 4,5 je Kachel), damit keine Kante gerade
        # laeuft; nach dem Ort in der Welt, so treffen sich zwei Laeufe an der Ecke in derselben Hoehe (vorher 0,93-1,05 je Lauf)
        q = a + e * u
        return nenn(u) * (0.8 + 0.28 * (0.75 * vn(q.x / 68, q.y / 68, 31) + 0.25 * vn(q.x / 26, q.y / 26, 32)))
    pts = []
    for i in range(nu + 1):
        u = L * i / nu; hu = H(u); hn = nenn(u)
        col = []
        for j in range(nz + 1):
            z = hu * j / nz
            col.append(a + e * u - n * tiefe(u, z, L, seed, hn) + Vector((0, 0, z)))
        pts.append(col)
    for i in range(nu):
        for j in range(nz):
            quad(P, pts[i][j], pts[i + 1][j], pts[i + 1][j + 1], pts[i][j + 1], ton, 'weiss', n)
    dom = 0.0   # Strahltest: gewoelbte Deckel verdeckten Knie an 2 Kacheln mehr; flach wie Lauf 1
    if deckel:                                               # dunkler Deckel ueber dem Fels dahinter (die Decke liegt im Dunkel)
        for i in range(nu):
            p0, p1 = pts[i][nz], pts[i + 1][nz]
            q0 = p0 - n * (TS * 0.95); q1 = p1 - n * (TS * 0.95)
            add = Vector((0, 0, 6 * vn(i * 0.7, 1.1, seed + 9)))
            mi0 = p0 * 0.55 + q0 * 0.45 + Vector((0, 0, (10 + 14 * vn(i * 0.5, 2.3, seed + 8)) * dom))   # Lauf 1: flache Oberseiten, jetzt gewoelbt (nur hohe Waende)
            mi1 = p1 * 0.55 + q1 * 0.45 + Vector((0, 0, (10 + 14 * vn((i + 1) * 0.5, 2.3, seed + 8)) * dom))
            quad(P, p0, p1, mi1, mi0, deckel_ton, 'weiss', Vector((0, 0, 1)))
            quad(P, mi0, mi1, q1 + add, q0 + add, deckel_ton, 'weiss', Vector((0, 0, 1)))
    return pts

for nr_, (s, lauf) in enumerate(laeufe()):
    d, linie, n = SEITEN[s]
    a = lauf[0]['a']; e = (lauf[0]['b'] - lauf[0]['a']).normalized(); L = len(lauf) * TS
    hoch = 'Wand_%s_hoch_%d' % (s, nr_); tief = 'Wand_%s_tief_%d' % (s, nr_)
    flaeche(part(hoch), a, e, n, L, [k['hoch'] for k in lauf], fels_ton(), nr_ * 7 + 1)
    flaeche(part(tief), a, e, n, L, [RIM] * len(lauf), fels_ton(1.05), nr_ * 7 + 1)
    WANDLISTE.append(dict(hoch=hoch, tief=tief, glas='-', innen=[n.x, -n.y]))
    for k in lauf: WAND_VON[(k['c'], k['r'], s)] = (hoch, k, a, e, L, nr_ * 7 + 1)

def an_der_wand(c, r):
    """fuer Fackel und Kristall (Felskachel): Boden davor, bevorzugt zur Kamera (Sueden), dann Seiten, zuletzt Norden"""
    for s, (dc, dr) in (('N', (0, 1)), ('O', (-1, 0)), ('W', (1, 0)), ('S', (0, -1))):
        f = (c + dc, r + dr)
        if (f[0], f[1], s) in WAND_VON: return f, s
    return None, None

def wandpunkt(f, s, t, z):
    """Punkt auf der Felsflaeche vor Kachel f (Seite s), t 0..1 entlang der Kante, Hoehe z; dazu Normale in den Raum"""
    hoch, k, a, e, L, seed = WAND_VON[(f[0], f[1], s)]
    n = SEITEN[s][2]
    u = (k['a'] - a).dot(e) + TS * t
    return a + e * u - n * tiefe(u, z, L, seed, k['hoch']) + Vector((0, 0, z)), n, hoch

def schatten(p, rx, ry=None, k=0.35):
    """weicher Fussschatten (alt MapCave 896, 1015): flache Scheibe knapp ueber dem Boden, innen dunkel, am Rand Bodenfarbe"""
    ry = rx if ry is None else ry
    c, r = int(p.x // TS), int(-p.y // TS)
    P = part('Grund_' + stueck(c, min(max(r, 0), NR - 1)))
    n = 14; m = Vector((p.x, p.y, boden_z(p.x, p.y) + 0.6))
    for ring, (f0, f1) in enumerate(((0.0, 0.55), (0.55, 1.0))):
        for i in range(n):
            a0 = 2 * math.pi * i / n; a1 = 2 * math.pi * (i + 1) / n
            pts = [m + Vector((math.cos(a) * rx * f, math.sin(a) * ry * f, 0)) for a, f in ((a0, f0), (a1, f0), (a1, f1), (a0, f1))]
            def ton(q, nn, m=m):
                d = math.hypot((q.x - m.x) / rx, (q.y - m.y) / ry)
                return sc(boden_ton(q, nn), k + (1 - k) * ss(0.35, 1.0, d))
            add_face(P, (pts if ring else pts[1:])[::-1], ton, 'erde')                         # nach oben gewandt

# ---------------------------------------------------------------- Dinge an der Wand
def fackel(c, r):
    """Fackel (TORCH) im Eisenhalter an der Wand, Flamme und Licht in raumlicht.gd (lichter „fackel“), geht mit der hohen Wand"""
    f, s = an_der_wand(c, r)
    if f is None: return
    p, n, hoch = wandpunkt(f, s, 0.5, 150)
    P = part(hoch)
    e = n.cross(Vector((0, 0, 1)))
    box(P, (-5, -5, -12), (5, 5, 12), EISEN, 'weiss', M=Matrix.Translation(p - n * 2))
    fuss = p + n * 4; kopf = p + n * 22 + Vector((0, 0, 30))
    zylinder(P, fuss, 2.6, (kopf - fuss).length, 6, lambda q, nn: sc(HOLZ_D, 0.9), 'holz', r2=3.4, achse=kopf - fuss)
    zylinder(P, fuss + n * 9 + Vector((0, 0, 12)), 4.2, 6, 8, EISEN, 'weiss', achse=kopf - fuss)               # Ring des Halters
    klumpen(P, kopf, 5.5, VERKOHLT, 'weiss', seed=c + r, squash=1.2)                                            # gewickelter Kopf, verkohlt
    LICHTER.append(dict(art='fackel', pos=list(kopf + n * 4 + Vector((0, 0, 12))), reich=3.6, kraft=1.15, flammen=[list(kopf + Vector((0, 0, 2)))], wand=hoch))

def kristalle(c, r):
    """Kristalle (CRYSTAL) wachsen violett vom Fuss der Wand auf, leuchten schwach (lichter „schein“), gehen mit der hohen Wand.
    492 Abgleich (Pruefer 03.11., 23:3x: „flache Splitter an der Wand; alt hohe lila Saeulen“): wie alt MapCaveIso.crystals
    vom Fuss der Felsflaeche zum Boden, meist aufrecht, etwas in den Raum und zur Seite geneigt; sechsseitige Prismen mit Spitze,
    drei Arten: 7 mit einer grossen (167 cm, alt 95 Einheiten bei 57 je m), 4 eng mit einer grossen, 9 kleinere (x0,7);
    die kleinen 56-126 cm, Radius alt 0,06-0,1 x TILE_Z (8-14 cm), die grosse 17 cm; Lichtseite heller, Spitzen fast weiss"""
    f, s = an_der_wand(c, r)
    if f is None: return
    v = hash_alt(c, r, 47) % 3                                  # alt MapCaveIso 1114
    n_ = (7, 4, 9)[v]
    dunkel = lin(0x3E2E5E); glanz = lin(0xD8C8FF)
    def ton(q, nn):                                              # alt: lit, wenn die Flaeche nach rechts im Bild zeigt
        k = max(0.0, min(1.0, (nn.x - nn.y) * 0.707 + 0.1 + 0.4 * max(0.0, nn.z)))
        return mixc(dunkel, sc(KRISTALL, 1.25), 0.3 + 0.7 * k)
    for k in range(n_):
        t = (0.3 + k * 0.14 + (h1(k, c, 41) - 0.5) * 0.1) if v == 1 else (0.1 + (k + h1(k, c, 41)) / n_ * 0.8)
        p, n, hoch = wandpunkt(f, s, t, 0)
        e = n.cross(Vector((0, 0, 1)))
        aus = 0.12 + 0.3 * h1(k, r, 42); seite = (h1(c + k, r, 43) - 0.5) * 0.6
        ax = (n * aus + e * seite + Vector((0, 0, 1))).normalized()
        gross = (k == 1) if v == 1 else (k == 0)
        L_ = (167.0 if gross else 56 + 70 * h1(c + k, r, 45)) * (0.7 if v == 2 else 1.0)
        rr = 17.0 if gross else 8.4 + 5.6 * h1(c, k, 46)
        base = p - n * 4 + Vector((0, 0, -4))
        zylinder(part(hoch), base, rr, L_ * 0.78, 6, ton, 'leucht_kristall', r2=rr * 0.92, deckel=False, achse=ax)
        zylinder(part(hoch), base + ax * L_ * 0.78, rr * 0.92, L_ * 0.22, 6, lambda q, nn: mixc(sc(KRISTALL, 1.3), glanz, 0.45), 'leucht_kristall', r2=0.6, achse=ax)
    for k in range(4):                                           # Geroell und Staub am Fuss (alt MapCave 525)
        p, n, hoch = wandpunkt(f, s, 0.2 + 0.6 * h1(c, k, 47), 0)
        klumpen(part(hoch), p + n * (6 + 10 * h1(k, r, 48)), 7 + 6 * h1(c + k, r, 49), lambda q, nn: sc(ROCK_D, 0.9), 'weiss', seed=k, squash=0.5, rau=0.35)
    p, n, hoch = wandpunkt(f, s, 0.5, 90)
    LICHTER.append(dict(art='schein', farbe='B088FF', pos=list(p + n * 30), reich=2.6, kraft=0.85, wand=hoch))

# ---------------------------------------------------------------- Dinge auf dem Boden
def tropfstein(c, r):
    """Tropfsteine (STALAGMITE): ein grosser, ein, zwei kleine, rau und gerieft"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r)
    for k in range(1 + int(h1(c, r, 51) * 2.5)):
        gross = k == 0
        p = m + Vector(((h1(c, r + k, 52) - 0.5) * (20 if gross else 70), (h1(c + k, r, 53) - 0.5) * (20 if gross else 70), -2))
        rb = (34 + 10 * h1(c, r, 54)) if gross else (12 + 8 * h1(c + k, r, 55)); hh = (150 + 50 * h1(c, r, 56)) if gross else (40 + 40 * h1(c, k, 57))
        lagen = 6; seg = 9
        ring = []
        for j in range(lagen + 1):
            t = j / lagen; rad = rb * (1 - t) ** 1.25 + 1.5
            row = []
            for i in range(seg):
                a = 2 * math.pi * i / seg + 0.3 * j
                f = 1 + 0.18 * (vn(i * 0.9 + k, j * 0.8, 58) - 0.5) * 2
                row.append(p + Vector((math.cos(a) * rad * f + (h1(c, j, 59) - 0.5) * 6 * t, math.sin(a) * rad * f, hh * t)))
            ring.append(row)
        ton = lambda q, nn: sc(mixc(SINTER, ROCK, 0.5 + 0.5 * vn(q.z / 18, q.x / 30, 60)), (0.75 + 0.35 * ss(0, 160, q.z)))
        for j in range(lagen):
            for i in range(seg):
                add_face(P, [ring[j][i], ring[j][(i + 1) % seg], ring[j + 1][(i + 1) % seg], ring[j + 1][i]], ton, 'weiss')
        klumpen(P, p, rb * 1.2, lambda q, nn: sc(SINTER, 0.6), 'weiss', seed=c * 3 + k, squash=0.18)   # Sinterfuss
        if gross: schatten(p, rb * 2.0, rb * 1.6)

def geroell(c, r):
    """Geroell (RUBBLE): acht bis zwoelf runde Steine, der groesste kniehoch"""
    P = part('Ding_' + stueck(c, r))
    for k in range(8 + int(h1(c, r, 61) * 5)):
        g = 6 + 20 * h1(c * 13 + k, r, 62) ** 2 * (1.6 if k == 0 else 1.0)
        p = mitte(c, r) + Vector(((h1(c, r * 7 + k, 63) - 0.5) * 95, (h1(c * 7 + k, r, 64) - 0.5) * 95, 0))
        klumpen(P, p, g, lambda q, nn: sc(mixc(ROCK_D, SINTER, vn(q.x / 12, q.y / 12, 65)), 0.95), 'weiss', seed=c * 31 + r + k, squash=0.6, rau=0.35)
        if g > 14: schatten(p, g * 1.6, g * 1.3, 0.45)

def fels_brocken(c, r):
    """Felsbrocken (ROCK, alt MapCave boulder 3 Looks): einer rund, einer vom Frost gespalten, eine Platte von der Decke auf einem Stein"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r); v = int(h1(c, r, 66) * 3)
    ton = lambda q, nn: sc(mixc(ROCK_D, ROCK, 0.3 + 0.7 * vn(q.x / 20, q.z / 16, 67)), 0.8 + 0.3 * max(0.0, nn.z))
    if v == 0:
        klumpen(P, m, 48, ton, 'weiss', seed=c + r, squash=0.75, rau=0.3, n=11, lagen=7)
        klumpen(P, m + Vector((40, -24, 0)), 18, ton, 'weiss', seed=c, squash=0.6, rau=0.35)
    elif v == 1:
        for sg in (-1, 1): klumpen(P, m + Vector((sg * 22, 0, 0)), 38, ton, 'weiss', seed=c + sg, squash=0.8, rau=0.3, n=10, lagen=6)
    else:
        klumpen(P, m + Vector((10, 4, 0)), 26, ton, 'weiss', seed=r, squash=0.7, rau=0.3)
        box(P, (-50, -34, 36), (50, 34, 52), ton, 'weiss', M=Matrix.Translation(m) @ Matrix.Rotation(0.22, 4, 'Y') @ Matrix.Rotation(0.4, 4, 'Z'))
    schatten(m, 62, 52)

def knochen(c, r):
    """Knochen (BONES): lange Knochen kreuz und quer, Rippen, ein Schaedel"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r)
    ton = lambda q, nn: sc(mixc(KNOCHEN_D, KNOCHEN, 0.5 + 0.5 * max(0.0, nn.z)), 0.95)
    for k in range(3 + int(h1(c, r, 71) * 3)):
        a = h1(c, r + k, 72) * math.pi
        p = m + Vector(((h1(c + k, r, 73) - 0.5) * 70, (h1(c, r + k * 3, 74) - 0.5) * 70, 3))
        d = Vector((math.cos(a), math.sin(a), 0)); L_ = 26 + 18 * h1(k, c, 75)
        zylinder(P, p - d * L_ / 2, 2.4, L_, 6, ton, 'weiss', achse=d)
        for sg in (-1, 1): klumpen(P, p + d * sg * L_ / 2 + Vector((0, 0, 0.5)), 4.2, ton, 'weiss', seed=k + sg, squash=0.8, n=6, lagen=4)
    v = int(h1(c, r, 76) * 3)                                    # Abgleich: drei Looks wie alt (MapCaveIso 757)
    def schaedel(sp, k=1.0, s_=0):
        klumpen(P, sp, 10 * k, ton, 'weiss', seed=c + r + s_, squash=0.85, rau=0.1)
        klumpen(P, sp + Vector((0, -6 * k, -5 * k)), 6 * k, ton, 'weiss', seed=s_ + 3, squash=0.5, rau=0.1)            # Kiefer
        for sg in (-1, 1): klumpen(P, sp + Vector((sg * 4 * k, -8 * k, 1)), 2.8 * k, lin(0x14100C), 'weiss', seed=sg, n=6, lagen=4)   # Augenhoehlen
    if v == 0:                                                   # Haufen zusammengeschoben: lange Knochen, drei Schaedel oben
        for k in range(3): schaedel(m + Vector(((k - 1) * 16, (h1(k, c, 77) - 0.5) * 14, 14 + 4 * (k % 2))), 0.9, k)
    elif v == 1:                                                 # was Aasfresser von einem Tier liessen: Wirbelsaeule, Rippen, Schaedel
        a = h1(c, r, 78) * math.pi; d = Vector((math.cos(a), math.sin(a), 0)); e = Vector((-d.y, d.x, 0))
        for k in range(9): klumpen(P, m + d * (k - 4) * 8 + e * 3 * math.sin(k * 0.7), 3.6, ton, 'weiss', seed=k, squash=0.8, n=6, lagen=4)
        for k in range(6):
            for sg in (-1, 1):
                q0 = m + d * (k - 2) * 9 + Vector((0, 0, 2)); q1 = q0 + e * sg * (20 - 2 * k) + d * 6 + Vector((0, 0, 7 - k))
                zylinder(P, q0, 1.4, (q1 - q0).length, 4, ton, 'weiss', achse=q1 - q0)
        schaedel(m + d * 46 + e * 10 + Vector((0, 0, 6)), 1.3, 9)
    else:                                                        # was von einem Goblin blieb: kleiner Schaedel, verbeulte Eisenkappe, Klinge
        schaedel(m + Vector((-18, 8, 7)), 0.75, 5)
        klumpen(P, m + Vector((14, -10, 2)), 11, lambda q, nn: sc(EISEN, 0.8 + 0.3 * max(0.0, nn.z)), 'weiss', seed=7, squash=0.55, rau=0.2)
        M = Matrix.Translation(m + Vector((4, 18, 1.5))) @ Matrix.Rotation(0.7, 4, 'Z')
        box(P, (-22, -1.6, 0), (14, 1.6, 0.8), lin(0x6A6660), 'weiss', M=M)
        box(P, (14, -4, 0), (24, 4, 2.4), lin(0x3A2A1E), 'weiss', M=M)

def kisten(c, r):
    """Kisten und Fass (CRATE, 13e.2): zwei gestapelt, eine zerschlagen mit Sack, oder ein Fass"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r); v = art_alt(c, r)
    def kiste_(lo, hi, a, seed):
        M = Matrix.Translation(m) @ Matrix.Rotation(a, 4, 'Z')
        box(P, lo, hi, lambda q, nn: sc(HOLZ, 0.75 + 0.35 * vn(q.x / 9 + q.z / 9, q.y / 9, seed)), 'bretter', M=M)
        for z in (lo[2] + 4, hi[2] - 4):                                                   # Leisten
            box(P, (lo[0] - 1, lo[1] - 1, z - 2.5), (hi[0] + 1, hi[1] + 1, z + 2.5), HOLZ_D, 'holz', M=M)
    a = (h1(c, r, 82) - 0.5) * 0.6
    schatten(m, 52, 46)
    if v == 0:
        kiste_((-34, -30, 0), (34, 30, 56), a, 1); kiste_((-22, -20, 56), (22, 20, 92), a + 0.3, 2)
    elif v == 1:
        kiste_((-34, -30, 0), (34, 30, 30), a, 3)
        klumpen(P, m + Vector((24, -26, 24)), 26, lambda q, nn: sc(SACK, 0.8 + 0.3 * vn(q.x / 8, q.z / 8, 4)), 'stoff', seed=c, squash=0.95, rau=0.15)
    else:
        zylinder(P, m, 30, 78, 10, lambda q, nn: sc(HOLZ, 0.7 + 0.3 * math.sin(q.z / 78 * math.pi)), 'holz')
        for z in (12, 64): zylinder(P, m + Vector((0, 0, z)), 31, 5, 10, EISEN, 'weiss', deckel=False)
        box(P, (-26, -26, 78), (26, 26, 82), HOLZ_D, 'holz', M=Matrix.Translation(m + Vector((6, 4, 3))) @ Matrix.Rotation(0.2, 4, 'X'))

def schlaflager(c, r):
    """Schlafplatz eines Goblins (BEDROLL): Lumpen, Wolfsfell auf Stroh oder Decke halb aufgerollt"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r); a = (h1(c, r, 91) - 0.5) * 0.8
    M = Matrix.Translation(m) @ Matrix.Rotation(a, 4, 'Z')
    schatten(m, 66, 48, 0.55)
    box(P, (-52, -36, 0), (52, 36, 5), lambda q, nn: sc(STROH, 0.8 + 0.4 * vn(q.x / 10, q.y / 10, 92)), 'stroh', M=M)
    box(P, (-40, -28, 5), (34, 26, 9), lambda q, nn: sc(FELL, 0.8 + 0.4 * vn(q.x / 14, q.y / 14, 93)), 'stoff', M=M)
    zylinder(P, M @ Vector((40, -24, 10)), 9, 50, 8, lambda q, nn: sc(SACK, 0.9), 'stoff', achse=(M.to_3x3() @ Vector((0, 1, 0))))

def truhe(c, r):
    """Truhe (CHEST) steht schraeg; 492 Abgleich (Pruefer 03.11., 23:3x: „Truhe schlicht, alt mit Schaedel, Nieten“): drei Arten wie
    alt MapCaveIso.chest: 0 Bretter mit Eisenbaendern rundum und ueber den Deckel, Eckband, verbogenes Schlossblech mit Loch;
    1 dunkles Holz ohne Eisen, ein Strick um die Truhe, wo das Schloss aufgebrochen ist; 2 Eisen, rote Hand vorn, Schaedel auf dem Deckel"""
    P = part('Ding_' + stueck(c, r))
    v = art_alt(c, r)
    a = math.radians(-14 + 28 * h1(c, r, 101))
    M = Matrix.Translation(mitte(c, r)) @ Matrix.Rotation(a, 4, 'Z')
    schatten(mitte(c, r), 56, 42, 0.25)                         # alt: weit um die Kiste, damit sie sich vom dunklen Boden abhebt
    hz = 1.0 if v != 1 else 0.7
    box(P, (-36, -23, 0), (36, 23, 30), lambda q, nn: sc(HOLZ, 1.2 * hz * (0.85 + 0.3 * vn(q.x / 7, q.z / 3, 103))), 'bretter', M=M)
    box(P, (-37, -24, 30), (37, 24, 36), lambda q, nn: sc(HOLZ, 1.3 * hz), 'bretter', M=M)               # Rand des Deckels
    box(P, (-36, -20, 36), (36, 20, 43), lambda q, nn: sc(HOLZ, 1.3 * hz * (0.85 + 0.3 * vn(q.x / 7, q.y / 3, 104))), 'bretter', M=M)
    for z in (10, 20): box(P, (-36.6, -23.6, z - 0.6), (36.6, 23.6, z + 0.6), sc(HOLZ_D, 0.7 * hz), 'holz', M=M)   # Fugen der Bretter
    if v != 1:
        for x in (-26, 22):                                      # Eisenbaender rundum und ueber den Deckel, mit Nieten
            box(P, (x, -24.5, -0.5), (x + 4, 24.5, 36.6), EISEN, 'weiss', M=M)
            box(P, (x, -20.6, 36), (x + 4, 20.6, 43.8), EISEN, 'weiss', M=M)
            for z in (6, 16, 26):
                klumpen(P, M @ Vector((x + 2, -24.8, z)), 1.3, lambda q, nn: sc(EISEN, 1.4), 'weiss', seed=z, n=6, lagen=3)
        box(P, (35.5, -24.5, -0.5), (37.2, -18, 36.6), EISEN, 'weiss', M=M)                           # Eckband
        box(P, (-5, -25.5, 22), (5, -24, 34), sc(ROST, 1.1), 'weiss', M=M)                             # Schlossblech, verbogen
        box(P, (-1.2, -25.9, 25), (1.2, -25.4, 28), lin(0x0C0A08), 'weiss', M=M)                       # Loch
    else:
        for x in (-14, 14):                                      # Strick statt Schloss
            box(P, (x - 1.2, -24.6, -0.4), (x + 1.2, -23.8, 36.4), lin(0x8A7450), 'stoff', M=M)
            box(P, (x - 1.2, -24.6, 36), (x + 1.2, 20.6, 43.6), lin(0x8A7450), 'stoff', M=M)
        klumpen(P, M @ Vector((0, -25, 33)), 3.4, lambda q, nn: sc(lin(0x8A7450), 0.9), 'stoff', seed=5, squash=0.8)
        for sg in (-1, 1): zylinder(P, M @ Vector((sg * 1.5, -25.4, 31)), 0.9, 10, 4, lin(0x7A6646), 'stoff', achse=Vector((sg * 0.25, 0, -1)))
    if v == 2:
        for k in range(5):                                       # rote Hand auf der Vorderseite
            dx = (-1.5 + k) * 2.4; h = 4 if k else 2.5
            box(P, (-26 + dx - 0.9, -24.2, 15 - (0 if k else 2)), (-26 + dx + 0.9, -23.8, 15 + h + (1 if k in (2, 3) else 0)), lin(0x7A1E14), 'weiss', M=M)
        box(P, (-30, -24.2, 9), (-20, -23.8, 15.5), lin(0x7A1E14), 'weiss', M=M)
        sp = M @ Vector((10, 2, 52))                             # Schaedel auf dem Deckel
        ton = lambda q, nn: sc(mixc(KNOCHEN_D, KNOCHEN, 0.5 + 0.5 * max(0.0, nn.z)), 0.95)
        klumpen(P, sp, 9, ton, 'weiss', seed=c + r, squash=0.85, rau=0.1)
        klumpen(P, sp + Vector((0, -5.5, -5)), 5.4, ton, 'weiss', seed=3, squash=0.5, rau=0.1)
        for sg in (-1, 1): klumpen(P, sp + Vector((sg * 3.6, -7.2, 1)), 2.5, lin(0x14100C), 'weiss', seed=sg, n=6, lagen=4)
    for k in range(4):                                           # Schleifspuren, wo sie hereingezogen wurde
        q = mitte(c, r) + M.to_3x3() @ Vector((-28 + k * 18, -34, 0))
        schatten(q, 7, 2.5, 0.75)

def pilze(c, r):
    """Leuchtpilze (GLOWSHROOM): drei bis sechs, Huete tuerkis leuchtend (lichter „schein“ 60E8D8)"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r); v = int(h1(c, r, 110) * 3)                 # Abgleich: drei Looks wie alt (MapCaveIso 848)
    if v == 2:                                                   # morscher Stumpf, Schwaemme daran
        zylinder(P, m, 20, 44, 9, lambda q, nn: sc(HOLZ_D, 0.55 + 0.25 * vn(q.z / 8, q.x / 8, 116)), 'holz', r2=17)
        for k in range(5):
            a = 2 * math.pi * h1(c, k, 117); z = 12 + 28 * h1(k, r, 118)
            klumpen(P, m + Vector((math.cos(a) * 21, math.sin(a) * 21, z)), 8 + 4 * h1(c + k, r, 119), lambda q, nn: sc(PILZ_HUT, 1.2), 'leucht_pilz', seed=k, squash=0.3, rau=0.15, n=8, lagen=3)
        schatten(m, 40, 34)
    for k in range(3 + int(h1(c, r, 111) * 4) if v < 2 else 3):
        p = m + Vector(((h1(c + k, r, 112) - 0.5) * 80, (h1(c, r + k, 113) - 0.5) * 80, 0))
        hh = (8 + 18 * h1(c, k, 114)) * (2.2 if v == 1 else 1.0); rr = 5 + 8 * h1(k, r, 115)
        zylinder(P, p, 1.6 + rr * 0.12, hh, 6, PILZ_STIEL, 'weiss', r2=1.2 + rr * 0.1)
        klumpen(P, p + Vector((0, 0, hh)), rr, lambda q, nn: sc(PILZ_HUT, 1.2), 'leucht_pilz', seed=c * 5 + k, squash=0.45, rau=0.1, n=8, lagen=4)
    LICHTER.append(dict(art='schein', farbe='60E8D8', pos=list(m + Vector((0, 0, 35))), reich=2.4, kraft=0.8))
    LICHTER.append(dict(art='sporen', pos=list(m + Vector((0, 0, 40)))))               # alt WorldScreen 2202: Sporen steigen

def lagerfeuer(c, r):
    """Lagerfeuer im Lager (CAMPFIRE): Steinkranz, Asche, Scheite als Zelt, Glut; Flammen und Licht raumlicht.gd („kamin“)"""
    P = part('Ding_' + stueck(c, r))
    p = mitte(c, r)
    klumpen(P, p + Vector((0, 0, 1)), 34, lambda q, nn: sc(lin(0x3A3632), 0.8 + 0.3 * vn(q.x / 9, q.y / 9, 121)), 'weiss', seed=c + r, squash=0.06, rau=0.1)
    for k in range(9):
        a = 2 * math.pi * k / 9 + 0.3 * h1(c, k, 122)
        klumpen(P, p + Vector((math.cos(a) * 42, math.sin(a) * 42, 0)), 11 + 4 * h1(c, k, 123), lambda q, nn: sc(ROCK, 0.7 + 0.45 * max(0.0, nn.z)), 'weiss', seed=k, squash=0.7, rau=0.3, n=11, lagen=6)   # Pruefer Lauf 2: flache Vierecke
    for k in range(4):
        a = 2 * math.pi * (k + 0.2 * h1(r, k, 124)) / 4
        q0 = p + Vector((math.cos(a) * 30, math.sin(a) * 30, 2)); q1 = p + Vector((math.cos(a) * 3, math.sin(a) * 3, 36))
        zylinder(P, q0, 4.5, (q1 - q0).length, 6, lambda q, nn: mixc(VERKOHLT, lin(0x5A4430), ss(4, 30, q.z)), 'weiss', r2=3.0, achse=q1 - q0)
    for k in range(6):
        klumpen(P, p + Vector(((h1(c, k, 125) - 0.5) * 30, (h1(r, k, 126) - 0.5) * 30, 3)), 5 + 3 * h1(c, r + k, 127), GLUT, 'glut', seed=k, squash=0.6, n=6, lagen=4)
    LICHTER.append(dict(art='kamin', pos=list(p + Vector((0, 0, 40))), reich=4.4, kraft=0.75, flammen=[list(p + Vector((0, 0, 6)))]))
    LICHTER.append(dict(art='rauch', pos=list(p + Vector((0, 0, 50)))))                # alt WorldScreen 2150: Rauch des Lagerfeuers

def stuetze():
    """Stuetzbalken (SUPPORT) quer ueber dem Gang: je Lauf von H zwei Pfosten an den Waenden und ein Sturz darueber"""
    gesehen = set()
    for r in range(NR):
        for c in range(NC):
            if ch(c, r) != 'H' or (c, r) in gesehen: continue
            c1 = c
            while ch(c1 + 1, r) == 'H': c1 += 1
            for cc in range(c, c1 + 1): gesehen.add((cc, r))
            P = part('Ding_' + stueck(c, r))
            y = ty(r) - TS / 2
            ton = lambda q, nn: sc(HOLZ, 0.7 + 0.3 * vn(q.z / 30, q.x / 20, 131))
            for x in (tx(c) + 9, tx(c1 + 1) - 9):
                box(P, (x - 9, y - 10, 0), (x + 9, y + 10, 222), ton, 'balken')
                schatten(Vector((x, y, 0)), 22, 20, 0.45)
            box(P, (tx(c) - 8, y - 11, 210), (tx(c1 + 1) + 8, y + 11, 232), ton, 'balken')
            for x in (tx(c) + 22, tx(c1 + 1) - 22):                                          # Kopfband schraeg
                d = Vector((1 if x < tx(c1) else -1, 0, 0))
                q0 = Vector((x - d.x * 13, y, 168)); q1 = Vector((x + d.x * 20, y, 212))
                zylinder(P, q0, 4, (q1 - q0).length, 4, ton, 'balken', achse=q1 - q0)

def gitter():
    """Gitter (GATE) quer im Gang: Pfosten fest; zwei Fluegel an Angeln (Gitter_L, Gitter_R, Ursprung = Angel), Godot schwenkt sie auf"""
    ls = [(c, r) for r in range(NR) for c in range(NC) if ch(c, r) == 'L']
    if not ls: return
    r = ls[0][1]; c0 = min(c for c, _ in ls); c1 = max(c for c, _ in ls)
    y = ty(r) - TS / 2
    P = part('Ding_' + stueck(c0, r))
    # 492 Abgleich (Pruefer 03.11., 23:3x: „ein dickes Feld, keine zwei Fluegel erkennbar“): wie alt MapCaveIso.gate je Kachel fuenf
    # Staebe (23 cm Abstand statt 15), 5,8 cm stark, 204 cm hoch mit Spitze 18 cm (alt 116 + 10 Einheiten bei 57 je m), zwei Baender
    # (alt 24, 92: 42 und 161 cm), Steinpfosten (alt 132: 232 cm) statt Eisen; zwischen den Fluegeln ein Spalt von 16 cm
    for x in (tx(c0) + 8, tx(c1 + 1) - 8):
        box(P, (x - 9, y - 11, 0), (x + 9, y + 11, 232), lambda q, nn: sc(ROCK, 0.7 + 0.35 * vn(q.x / 6, q.z / 9, 140)), 'weiss')
        klumpen(P, Vector((x, y, 232)), 10, lambda q, nn: sc(ROCK, 0.8), 'weiss', seed=int(x), squash=0.5, rau=0.3)
    breite = (tx(c1 + 1) - tx(c0) - 34) / 2 - 8
    for name, angel, sg in (('Gitter_L', tx(c0) + 17, 1), ('Gitter_R', tx(c1 + 1) - 17, -1)):
        G = part(name); G.O = Vector((angel, y, 0))
        ton = lambda q, nn: mixc(EISEN, ROST, vn(q.x / 20, q.z / 25, 141))
        n = max(2, int(round(breite / 23.0)))
        for k in range(n + 1):
            x = angel + sg * (3 + (breite - 6) * k / n)
            box(G, (x - 2.9, y - 2.9, 2), (x + 2.9, y + 2.9, 204), ton, 'weiss')
            zylinder(G, Vector((x, y, 204)), 2.9, 18, 4, ton, 'weiss', r2=0.4)                            # Spitze
        for z in (42, 161):
            x0, x1 = sorted((angel, angel + sg * breite))
            box(G, (x0, y - 3.4, z), (x1, y + 3.4, z + 10), ton, 'weiss')
        x = angel + sg * (breite - 8)                                                         # Schloss am freien Ende
        box(G, (x - 8, y - 6, 95), (x + 8, y + 6, 122), lin(0x2A2622), 'weiss')

def lichtschacht(c, r):
    """Lichtschacht (SKYLIGHT, 27o): durch einen Spalt im Fels faellt tags Licht, nachts schwach der Mond; Moos und Laub darunter"""
    P = part('Ding_' + stueck(c, r))
    m = mitte(c, r)
    for k in range(5):
        p = m + Vector(((h1(c, k, 151) - 0.5) * 80, (h1(r, k, 152) - 0.5) * 80, 0))
        klumpen(P, p, 14 + 10 * h1(c + k, r, 153), lambda q, nn: sc(MOOS, 0.9 + 0.4 * vn(q.x / 6, q.y / 6, 154)), 'weiss', seed=k, squash=0.12, rau=0.3)
    LICHTER.append(dict(art='tageslicht', pos=list(m + Vector((25, 40, 650))), ziel=list(m), kraft=0.7))
    # Lauf 1 (Pruefer: kein Spalt, kein Tageslicht von oben zu sehen): Lichtsaeule aus dem Dunkel bis zum Boden (Strahl_…, gebiet.gd:
    # durchscheinend, leuchtet tags); oben ein heller Spalt
    S = part('Strahl_' + stueck(c, r))
    # Abgleich (Pruefer Lauf 2: wie ein weisser Steinpfeiler): schraeg wie alt (WorldScreen 2315, vier Lagen), oben und unten
    # ausgeblendet (additiv: dunkel = durchsichtig), am Boden ein weicher Fleck; Staub im Strahl (gebiet.gd „staub“)
    # 492 Abgleich (Pruefer 03.11., 23:3x: „blasser Balken mit gerader Oberkante; alt breiter weicher Kegel“): ein Zylinder hatte nur
    # Farben an Fuss und Kopf, dazwischen linear, oben bei 40 % hart abgeschnitten. Jetzt wie alt drawCaveShaft: vier Lagen, unten
    # breit (alt 19 Bildpunkte bei 32 je Kachel = 69 cm), oben schmal (7 = 25 cm), Helligkeit in Stufen der Hoehe: oben im Dunkel 0,
    # 0,15 bei drei Vierteln, 0,6 bei gut der Haelfte, am staerksten tief unten, zum Boden hin weg in den Fleck (alt 0.1.667)
    H_ = 300.0                                                   # sichtbare Hoehe (alt top 120 bei 57 je m ≈ 2,1 m, hier ueber der Wand 2,4 m)
    oben = m + Vector((25, 40, 520))
    def glanz_(z):
        u = 1.0 - min(1.0, max(0.0, z / H_))                     # 0 oben, 1 am Boden
        for (u0, g0), (u1, g1) in zip(((0, 0.0), (0.25, 0.15), (0.55, 0.6), (0.8, 1.0)), ((0.25, 0.15), (0.55, 0.6), (0.8, 1.0), (1.0, 0.0))):
            if u <= u1: return g0 + (g1 - g0) * ss(u0, u1, u) if u1 > u0 else g1
        return 0.0
    for k in range(4):
        w = 1.0 - k * 0.2
        fuss = m + Vector((5 * k - 8, 3 * k - 6, 0))
        ax = oben - fuss; L_ = ax.length; ax = ax.normalized()
        e1 = ax.cross(Vector((0, 0, 1))).normalized(); e2 = ax.cross(e1)
        ringe = []
        for j in range(11):                                      # in Stufen, damit die Farbe der Hoehe folgt
            t = L_ * (j / 10) ** 1.4                             # unten dichter
            r_ = (69 - 44 * min(1.0, t / H_)) * w
            ringe.append([fuss + ax * t + (e1 * math.cos(2 * math.pi * i / 14) + e2 * math.sin(2 * math.pi * i / 14)) * r_ for i in range(14)])
        for j in range(10):
            for i in range(14):
                a_, b_ = ringe[j][i], ringe[j][(i + 1) % 14]; c_, d_ = ringe[j + 1][(i + 1) % 14], ringe[j + 1][i]
                add_face(S, [a_, b_, c_, d_], lambda q, nn: sc((1.0, 0.97, 0.88), glanz_(q.z)), 'weiss')
    for i in range(16):
        a0 = 2 * math.pi * i / 16; a1 = 2 * math.pi * (i + 1) / 16
        pts = [m + Vector((0, 0, 1.5)), m + Vector((math.cos(a1) * 75, math.sin(a1) * 60, 1.5)), m + Vector((math.cos(a0) * 75, math.sin(a0) * 60, 1.5))]
        add_face(S, pts, lambda q, nn: sc((1.0, 0.97, 0.88), 1.6 * (1 - ss(0, 75, (q - m).length))), 'weiss')
    LICHTER.append(dict(art='staub', pos=list(m + Vector((10, 15, 220)))))
    H = part('Himmel_Spalt')                                   # Lauf 1 (Pruefer: harte weisse Ellipse): schmaler Riss, gedaempft
    for k in range(5):
        klumpen(H, m + Vector((25 + (k - 2) * 9, 40 + (k - 2) * 5, 525)), 7 - abs(k - 2), (0.12, 0.13, 0.14), 'weiss', seed=c + k, squash=0.25, rau=0.5, n=6, lagen=3)

def ausgang():
    """Ausgang (CAVE_EXIT) zum Wald: Tageslicht faellt von draussen herein (alt EXIT FFF4D8 3,4 Kacheln), nachts Mond"""
    if not MUND: return
    x = (tx(min(MUND)) + tx(max(MUND) + 1)) / 2
    # Lauf 1 (Pruefer: Lichtfleck ohne Quelle, Ausgang nicht zu sehen): Licht mit Schatten (faellt nicht durch den Fels in andere
    # Raeume), dazu draussen hell der Ausblick: Himmel_… leuchtet tags (gebiet.gd), nachts nur schwach
    # Abgleich (alt EXIT 3,4 Kacheln; Pruefer Lauf 2: Weisse Waende in Teich und Westfluegel): Reichweite wie alt, Kegel enger
    LICHTER.append(dict(art='tageslicht', pos=[x, ty(NR + AUSSEN - 1), 300], ziel=[x, ty(NR - 2), 0], kraft=0.8, reich=6.5, winkel=26))
    # Ausblick am Ende des Gangs (alt MapEdge: draussen bleibt es hell): Lauf 2 stand er mit dem Ruecken zur Kamera (unsichtbar)
    # Lauf 1 (Pruefer: grosse hellgruene Flaeche ohne Quelle): kein stehender Ausblick mehr; draussen liegt der Boden im Tageslicht
    # (alt: goldener Boden am Ausgang, EXIT FFF4D8), eine Handbreit ueber dem Grund, leuchtet von selbst, nach aussen heller
    H = part('Himmel_Ausgang')
    for r in range(NR + 1, NR + AUSSEN):
        for c in MUND:
            for i in range(4):
                for j in range(4):
                    x0 = tx(c) + TS * i / 4; x1 = x0 + TS / 4; y0 = ty(r) - TS * j / 4; y1 = y0 - TS / 4
                    q = [Vector((x0, y1, 1.2)), Vector((x1, y1, 1.2)), Vector((x1, y0, 1.2)), Vector((x0, y0, 1.2))]
                    # 505 (Pruefer 16:01: „hart umrandetes Rechteck mit fleckigem Muster, wie eine kaputte Textur“): ohne Rauschen, nach
                    # aussen gleichmaessig heller, zu den Seiten weich ins Dunkel (keine Kante an den Waenden des Gangs)
                    add_face(H, q, lambda p, n: sc(mixc(lin(0x8A7A50), lin(0xFFF4D8), mund_naehe(p)), (0.012 + 0.07 * mund_naehe(p) ** 1.5)
                                                  * (1.0 - ss(0.35, 1.0, abs(p.x - x) / (TS * len(MUND) / 2)))), 'weiss')
    P = part('Ding_' + stueck(MUND[0], NR - 1))
    for k in range(40 * len(MUND)):                                                           # Laub, vom Wind hereingeweht (alt 40 je Kachel)
        p = Vector((x + (h1(k, 1, 161) - 0.5) * TS * len(MUND), ty(NR - 2) - TS * (AUSSEN + 1.6) * h1(k, 2, 162) ** 0.7, 0.8))
        klumpen(P, p, 5 + 4 * h1(k, 3, 163), lambda q, nn: mixc(lin(0x5A4A20), lin(0x56643A), vn(q.x / 7, q.y / 7, 164)), 'weiss', seed=k, squash=0.1, n=6, lagen=3)

DINGE = {'t': fackel, 'G': kristalle, 'i': tropfstein, '%': geroell, 'j': knochen, 'u': kisten, 'e': schlaflager, 'C': truhe,
         'g': pilze, 'F': lagerfeuer, '*': lichtschacht, 'r': fels_brocken}
for r in range(NR):
    for c in range(NC):
        z = ch(c, r)
        if z in DINGE: DINGE[z](c, r)
stuetze(); gitter(); ausgang()
print('LICHTER', len(LICHTER), 'TEILE', len(PARTS), 'WAENDE', len(WANDLISTE))

# ---------------------------------------------------------------- Netze, Ausgabe wie raum.py
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
DREIECKE = 0
KANTE_WEICH = float(os.environ.get('KANTE_WEICH', '50'))   # 492: Fels weich schattiert bis zu diesem Knick (Grad)
def build(P, name):
    global DREIECKE
    o_ = P.O if P.O is not None else Vector((0, 0, 0))
    me = bpy.data.meshes.new(name); me.from_pydata([tuple((v - o_) * 0.01) for v in P.V], [], P.F)
    names = sorted(set(P.M)); idx = {n: k for k, n in enumerate(names)}
    for n in names: me.materials.append(material(n))
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER'); uv = me.uv_layers.new(name='UVMap')
    for k, poly in enumerate(me.polygons):
        poly.material_index = idx[P.M[k]]
        for j, li in enumerate(poly.loop_indices):
            c = P.C[me.loops[li].vertex_index]
            ca.data[li].color = (c[0], c[1], c[2], 1.0); uv.data[li].uv = P.UV[k][j]
    if name.startswith('Wand_'):
        # 492 (Pruefer 08.11., 19:29: Wandstuecke „grob gerastert“ in Halle, bei Krogg, Westfluegel): jedes Viereck hatte eigene Ecken, also
        # flach schattiert; gemessen Knick zwischen Nachbarn im Mittel 14 Grad, 35 % ueber 15 Grad: unter der Fackel ein Schachbrett.
        # Alt (MapCaveIso.kt relief) malte das Relief weich; jetzt Ecken verschmolzen und weich schattiert, nur Kanten ueber
        # KANTE_WEICH Grad (Fels zum Deckel) bleiben hart. Farbe und UV haengen an den Schleifen und bleiben.
        bm = bmesh.new(); bm.from_mesh(me)
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
        bm.to_mesh(me); bm.free()
        for p_ in me.polygons: p_.use_smooth = True
        me.set_sharp_from_angle(angle=math.radians(KANTE_WEICH))
    o = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(o)
    o.location = o_ * 0.01
    DREIECKE += sum(len(p.vertices) - 2 for p in me.polygons)
    return o
for name, P in sorted(PARTS.items()):
    if P.F: build(P, name)
print('NETZE', len([p for p in PARTS.values() if p.F]), 'DREIECKE', DREIECKE)
walk = [[1 if ch(c, r) in WALK else 0 for c in range(NC)] for r in range(NR)]
def m3(p): return [x * 0.01 for x in p]
lichter = []
for l in LICHTER:
    q = dict(l, pos=m3(l['pos']))
    if 'ziel' in l: q['ziel'] = m3(l['ziel'])
    if 'flammen' in l: q['flammen'] = [m3(f) for f in l['flammen']]
    lichter.append(q)
info = dict(kachel_m=TS / 100.0, spalten=NC, zeilen=NR, ursprung=dict(spalte=0, zeile=0), begehbar=walk, karte=ROWS, innen=True, hoehle=True,
            lichter=lichter, waende=WANDLISTE,
            hinweis='Meter; Blender: x = Spalte * Kachel, y = -Zeile * Kachel; in glTF/Godot: x gleich, z = +Zeile * Kachel')
json.dump(info, open(os.path.join(OUT, ID + '-info.json'), 'w'), indent=0)
PX = 16                                                                                      # Bildpunkte je Kachel
img = bpy.data.images.new('maske', NC * PX, NR * PX, alpha=True)
pix = [0.0] * (NC * PX * NR * PX * 4)
for y in range(NR * PX):
    for x in range(NC * PX):
        c, r = x // PX, y // PX
        if (c, r) not in TEICH: continue
        d = min(min(x % PX, PX - 1 - x % PX) if any((c + dc, r) not in TEICH for dc in (-1, 1)) else PX,
                min(y % PX, PX - 1 - y % PX) if any((c, r + dr) not in TEICH for dr in (-1, 1)) else PX)
        i = ((NR * PX - 1 - y) * NC * PX + x) * 4                                             # Blender: Zeile 0 unten
        pix[i + 3] = 0.5 + 0.5 * min(1.0, d / (PX * 0.6))
img.pixels = pix
img.filepath_raw = os.path.join(OUT, ID + '-boden-maske.png'); img.file_format = 'PNG'; img.save()
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, ID + '.glb'), export_format='GLB', use_selection=True, export_vertex_color='ACTIVE',
                          export_yup=True, export_image_format='JPEG', export_jpeg_quality=88)
print('GLB OK', ID, os.path.getsize(os.path.join(OUT, ID + '.glb')))
