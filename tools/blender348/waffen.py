# 348.7 (Jerry): Waffen und Schilde für Godot nach der Modellregel (docs/LISTE-UMZUG-348.md, Punkt 4): je Stück eine
# eigene .glb, im Spiel an den Handknochen gehängt (foR-wrR, foL-wrL), Griffpunkt = Ursprung (Mitte der Faust).
# Maße in Metern aus Dress.kt (grip, guard, blade, reach; GRIP_BACK), Farben in Eckfarben (Stahl, Leder, Messing, Holz).
# Ausrichtung: Klinge, Schaft nach glTF +Y (Blender +Z), Schneide quer nach ±X, Fläche nach ±Z;
#              Schild: Vorderseite nach glTF +Z (Blender -Y), Ursprung an der Fessel (Griff innen).
# Aufruf: OUT=<ordner> [WAFFE=longsword] python -I waffen.py  ->  <OUT>/<kennung>.glb, waffen-info.json
import bpy, bmesh, math, os, json
from mathutils import Vector, Matrix

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
CM = 0.01

def lin(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)
STEEL, EDGE, DARK = lin(0x868E98), lin(0xB4BAC2), lin(0x3A3C42)
FULLER = lin(0x6A7078)   # 348.13a Runde 9: Hohlkehle, vorher DARK
LEATHER, BRASS, WOOD = lin(0x3A2A20), lin(0xA8884A), lin(0x6A4A2E)
PAINT, STRIPE, IRON = lin(0x6E2E24), lin(0xC8BCA0), lin(0x4A4C50)

class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []
def face(P, pts, col):
    n0 = len(P.V); P.V += [Vector(p) for p in pts]; P.F.append(tuple(range(n0, n0 + len(pts)))); P.C += [col] * len(pts)

def ring_pts(c, rx, ry, n, z):
    return [Vector((c.x + math.cos(2 * math.pi * k / n) * rx, c.y + math.sin(2 * math.pi * k / n) * ry, z)) for k in range(n)]
def tube(P, z0, z1, r0, r1, col, n=10, cap=True):
    """runder Körper längs Blender Z (Griff, Schaft), Maße in cm"""
    a = ring_pts(Vector((0, 0)), r0 * CM, r0 * CM, n, z0 * CM); b = ring_pts(Vector((0, 0)), r1 * CM, r1 * CM, n, z1 * CM)
    for k in range(n):
        face(P, [a[k], a[(k + 1) % n], b[(k + 1) % n], b[k]], col)
    if cap:
        face(P, list(reversed(a)), col); face(P, b, col)
def ball(P, z, r, col, sq=1.0):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=1, radius=r * CM)
    for v in bm.verts: v.co.z = v.co.z * sq + z * CM
    for f in bm.faces: face(P, [v.co.copy() for v in f.verts], col)
    bm.free()
def guard(P, z, half, rad, col):
    """Parierstange quer nach X"""
    h = rad * CM; w = half * CM; zz = z * CM
    lo = Vector((-w, -h, zz - h)); hi = Vector((w, h, zz + h))
    box(P, lo, hi, col)
def box(P, lo, hi, col):
    x0, y0, z0 = lo; x1, y1, z1 = hi
    for q in ([(x0, y0, z0), (x0, y1, z0), (x1, y1, z0), (x1, y0, z0)], [(x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)],
              [(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], [(x0, y1, z0), (x0, y1, z1), (x1, y1, z1), (x1, y1, z0)],
              [(x0, y0, z0), (x0, y0, z1), (x0, y1, z1), (x0, y1, z0)], [(x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)]):
        face(P, q, col)
def blade(P, z0, length, w0, w1, t0, tip, fuller=0.0, curve=0.0):
    """Klinge ab z0 (cm) nach +Z: Rauten-Querschnitt (Schneide ±X, Fläche ±Y), verjüngt von w0 auf w1, Spitze tip cm lang;
    curve (cm, Dress.kt): die Klinge biegt sich zur Spitze um curve · (Anteil der Länge)² nach X (Krummsäbel −7)"""
    steps = 10 if curve else 6
    rows = []
    body = length - tip
    for i in range(steps + 1):
        t = i / steps; z = z0 + body * t; w = (w0 + (w1 - w0) * t) * CM; th = t0 * CM * (1 - 0.3 * t)
        cx = curve * (body * t / length) ** 2 * CM
        rows.append([Vector((cx + w, 0, z * CM)), Vector((cx, th, z * CM)), Vector((cx - w, 0, z * CM)), Vector((cx, -th, z * CM))])
    for i in range(steps):
        a, b = rows[i], rows[i + 1]
        for k in range(4):
            col = EDGE if k in (0, 3) else STEEL
            # 348.13a Runde 9 (Helfer: untere Hälfte des Langschwerts schwarz, „ein Speer mit Metallspitze“): die Hohlkehle färbte
            # die ganze Hälfte -X auf fuller der Länge in DARK; von dieser Seite war die Klinge im Kampf ein schwarzer Stab. Jetzt nur
            # etwas dunkler als der Stahl
            if fuller and k in (1, 2) and i < steps * fuller: col = FULLER
            if RUST and k in (1, 2) and (i * 7 + k * 3) % 4 == 1: col = RUST   # Goblin Runde 6: Rostflecken auf der Fläche
            face(P, [a[k], a[(k + 1) % 4], b[(k + 1) % 4], b[k]], col)
    top = Vector((curve * CM, 0, (z0 + length) * CM)); e = rows[-1]
    for k in range(4): face(P, [e[k], e[(k + 1) % 4], top], EDGE if k in (0, 3) else STEEL)
    face(P, list(reversed(rows[0])), STEEL)

def sword(P, back, front, grip_r, pommel_r, gz, ghalf, grad, length, w0, w1, t0, tip, fuller=0.0, curve=0.0):
    tube(P, -back, front, grip_r, grip_r, LEATHER)
    ball(P, -back - pommel_r * 0.8, pommel_r, BRASS, 0.8)
    guard(P, gz, ghalf, grad, BRASS)
    blade(P, gz + grad, length, w0, w1, t0, tip, fuller, curve)

def shield_board(P, outline, thick, face_col, rim=IRON, stripe=None):
    """Brett in der X-Z-Ebene (Blender), Vorderseite nach -Y; outline in cm um die Fessel; eiserner Rand, Buckel"""
    n = len(outline); f = [Vector((x * CM, -thick * CM, z * CM)) for x, z in outline]; b = [Vector((x * CM, 0, z * CM)) for x, z in outline]
    c = sum(f, Vector()) / n
    for k in range(n):
        q = [f[k], f[(k + 1) % n], c]
        col = face_col
        if stripe and abs((f[k].x + f[(k + 1) % n].x) / 2) < stripe * CM: col = STRIPE
        face(P, q, col)
        face(P, [b[(k + 1) % n], b[k], f[k], f[(k + 1) % n]], rim)
    face(P, list(reversed(b)), lin(0x4A3A2A))
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=1, radius=7 * CM)
    for v in bm.verts:
        v.co.y = min(v.co.y, 0) * 0.6 - thick * CM; v.co += Vector((c.x, 0, c.z))
    for fc in bm.faces: face(P, [v.co.copy() for v in fc.verts], IRON)
    bm.free()
    box(P, (-5 * CM, 0, -1.2 * CM), (5 * CM, 3 * CM, 1.2 * CM), LEATHER)   # die Fessel

def build_dagger(P): sword(P, 4.5, 4.0, 1.25, 1.5, 4.6, 4.2, 0.6, 23.0, 1.6, 1.0, 0.38, 8.0)
# Goblin Runde 6 (Prüfer Runde 5: Dolch mit der Hand ein schwarzer Klumpen): breiter und länger, eine Parierstange, die vorsteht
def build_dagger_gob(P): sword(P, 4.5, 4.5, 1.4, 1.7, 5.0, 5.5, 0.7, 32.0, 2.4, 1.4, 0.45, 10.0)
# Kobold Runde 3 (Diogenes r2c (e): Dolch wie eine Gabel; Prüfer: die Umrisslinie läuft an beiden Seiten der dünnen Klinge als
# zwei Zinken über die Spitze hinaus): breites, kurzes Schlachtmesser mit dicker, stumpfer Spitze, die Linie schließt sich
# Kobold Runde 3b (Prüfer 3a: der Dolch im Kampfbild Pixelstaub, 3,6 cm Klinge sind dort 6 Bildpunkte): kürzer und breiter, Griff dicker
# Kobold Runde 3c (Prüfer 3b: ein Schlachtmesser, die Liste verlangt einen Dolch): Dolchklinge, die sich zur Spitze verjüngt,
# breit genug, dass die Umrisslinie sich schließt (nicht unter 3 cm an der Wurzel, dick 1 cm), vorstehende Parierstange
def build_dagger_kobold(P): sword(P, 4.0, 4.0, 1.6, 1.9, 4.8, 6.5, 0.9, 22.0, 3.6, 2.2, 1.0, 9.0)
def build_shortsword(P): sword(P, 5.0, 5.0, 1.35, 1.9, 5.6, 6.5, 0.7, 41.0, 2.3, 1.8, 0.4, 8.0, 0.6)
def build_longsword(P): sword(P, 9.0, 5.0, 1.35, 2.2, 5.6, 10.0, 0.75, 69.0, 2.5, 1.5, 0.42, 12.0, 0.65)
def build_quarterstaff(P):
    # Kampfstab: in der Mitte gefasst (buttPart 1,0), 85 cm vor und hinter der Hand, Lederwicklung an der Hand
    tube(P, -85, 85, 1.6, 1.45, WOOD, n=8)
    tube(P, -4, 5, 1.75, 1.75, LEATHER, n=8)
    for z in (-85, 83): tube(P, z, z + 2, 1.7, 1.7, IRON, n=8)
def build_shield(P):
    # Kampfschild (Kämpfer): Dreieckschild 56 × 70 cm, oben gerade, unten spitz; Farbe mit hellem Querstreifen wie held3.py
    pts = []
    for k in range(9): pts.append((-28 + 56 * k / 8, 30))
    for k in range(1, 12):
        t = k / 12; a = math.pi * t / 2
        pts.append((28 * math.cos(a) ** 0.7 * (1 - t * 0.25), 30 - 72 * math.sin(a)))
    pts.append((0, -42))
    pts += [(-x, z) for x, z in reversed(pts[9:-1])]
    shield_board(P, list(reversed(pts)), 2.2, PAINT, stripe=6)
def build_round_shield(P, board=0x7A5634):
    # Rundschild (Kleriker, Goblin, Kobold, Skelett): 60 cm Durchmesser, Holz mit eisernem Rand
    pts = [(math.cos(2 * math.pi * k / 24) * 30, math.sin(2 * math.pi * k / 24) * 30) for k in range(24)]
    shield_board(P, list(reversed(pts)), 2.0, lin(board))
def build_crude_shield_r5(P, board=0x6E5844):   # heller als Dress 0x5A4632: im Kampfbild las er sich schwarz
    # Runde 4 (Prüfer Goblin Runde 3, Chef 21:33: „so schwarz“, von vorn ein Oval ohne Rand und Buckel): wie Dress.kt crude,
    # rohe Bretter mit dunklen Fugen alle 6 cm, ein eisernes Band quer über dem Buckel, eiserner Rand
    build_round_shield(P, board)
    y = -2.0 - 0.06
    for k in range(-4, 5):
        x = k * 6.0 + 3.0
        if abs(x) > 27: continue
        h = math.sqrt(max(0.0, 27.5 ** 2 - x * x)); w = 0.35
        face(P, [Vector(((x - w) * CM, y * CM, -h * CM)), Vector(((x + w) * CM, y * CM, -h * CM)),
                 Vector(((x + w) * CM, y * CM, h * CM)), Vector(((x - w) * CM, y * CM, h * CM))], lin(0x2E241A))
    w = math.sqrt(27.5 ** 2 - 2.0 ** 2)
    face(P, [Vector((-w * CM, (y - 0.05) * CM, 0.6 * CM)), Vector((w * CM, (y - 0.05) * CM, 0.6 * CM)),
             Vector((w * CM, (y - 0.05) * CM, 3.4 * CM)), Vector((-w * CM, (y - 0.05) * CM, 3.4 * CM))], IRON)
def build_crude_shield(P):
    # Goblin Runde 6 (Prüfer Runde 5: Schild glatt rund statt roher Bretter): sieben Bretter verschiedener Länge und Farbe mit
    # Fugen, oben und unten ungleich abgesägt, Buckel; kein Rand (der machte ihn rund und sauber)
    # Runde 6b (Prüfer 6a: zwei Bänder quer „wie ein Fass mit Reifen“, Treppenkanten): eine schräge Leiste, engere Fugen
    # Runde 6c (Prüfer 6b: Kiste oder Fass vom Hals bis zu den Knöcheln, Gras in den Fugen, die Leiste wie ein Speer): kleiner
    # und runder (Enden näher am Kreis), dunkle Rückwand hinter den Fugen, keine Leiste
    R, bw, gap, th = 25.0, 6.6, 0.6, 2.0
    shades = (0x5E4A38, 0x6E5844, 0x54402E, 0x665040, 0x5A4634, 0x6A5442, 0x584432)
    jit = (1.2, -0.8, 1.5, 0.3, -1.0, 1.0, -0.5)
    for i in range(7):
        x0 = -3.5 * bw + i * bw + gap / 2; x1 = x0 + bw - gap
        xm = (x0 + x1) / 2; h = math.sqrt(max(0.0, R * R - xm * xm))
        top = h + jit[i]; bot = -h + jit[(i + 3) % 7] * 0.8
        col = lin(shades[i])
        box(P, (x0 * CM, -th * CM, bot * CM), (x1 * CM, 0, top * CM), col)
    w = 3.5 * bw
    face(P, [Vector((math.cos(2 * math.pi * k / 20) * (R - 1.5) * CM, -0.4 * CM, math.sin(2 * math.pi * k / 20) * (R - 1.5) * CM))
             for k in range(20)], lin(0x241A12))   # Rückwand hinter den Fugen
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=1, radius=6.5 * CM)
    for v in bm.verts: v.co.y = min(v.co.y, 0) * 0.6 - th * CM
    for fc in bm.faces: face(P, [v.co.copy() for v in fc.verts], IRON)
    bm.free()
    box(P, (-5 * CM, 0, -1.2 * CM), (5 * CM, 3 * CM, 1.2 * CM), LEATHER)   # die Fessel
# 348.7 Goblin (MonsterKits): Krummsäbel und Handbeil wie Dress.kt (grip, guard, blade, haft, HEAD_AT)
def build_scimitar(P): sword(P, 5.0, 5.0, 1.3, 1.6, 5.6, 5.0, 0.6, 59.0, 1.8, 2.5, 0.42, 13.0, curve=-7.0)
def build_handaxe(P, s=1.0):
    # Stiel 9 cm hinter, 37 cm vor der Hand; Kopf bei 32 cm: Tülle, Blatt nach +X (Schneide), Nacken nach −X
    # s: Kopf größer (Goblin Runde 6, Prüfer Runde 5: Beilkopf dunkel und klein)
    tube(P, -9, 37, 1.3, 1.2, WOOD, n=8)
    tube(P, -3, 4, 1.45, 1.45, LEATHER, n=8)
    tube(P, 29, 35, 1.9, 1.9, DARK, n=8)
    th0, th1 = 0.6, 0.12
    prof = [(0.0, -1.1, th0), (9.5, -2.3 - 0.3, th1), (10.0, 0.0, th1), (9.5, 2.3 + 0.2, th1), (0.0, 1.1, th0)]   # (x, z, halbe Dicke)
    prof = [(x - 1.6 * (z / 2.3) ** 2 * (x / 9.5), z, t) for x, z, t in prof]   # Schneide leicht gebogen (curve −1,6)
    prof = [(x * s, z * (s if abs(z) > 2 else 1.0), t) for x, z, t in prof]
    F = [Vector(((x + 1.6) * CM, -t * CM, (32 + z) * CM)) for x, z, t in prof]; B = [Vector(((x + 1.6) * CM, t * CM, (32 + z) * CM)) for x, z, t in prof]
    mid = STEEL     # Runde 6b (Prüfer 6a: Beil ganz in Rost „blutig, roter Klumpen“): Stahl, Rost nur als Flecken
    face(P, F, mid); face(P, list(reversed(B)), mid)
    if RUST:
        for side in (-1, 1):
            c0 = Vector((5.0 * s + 1.6, 0, 32 + 0.6 * s)); r_ = 1.6 * s
            q = [Vector(((c0.x + r_ * math.cos(a)) * CM, side * (th0 + 0.05) * CM, (c0.z + r_ * 0.8 * math.sin(a)) * CM)) for a in (0, 2.1, 4.2)]
            face(P, q if side < 0 else list(reversed(q)), RUST)
    for k in range(len(prof) - 1): face(P, [F[k + 1], F[k], B[k], B[k + 1]], EDGE if 0 < k < 3 else STEEL)
    face(P, [F[0], F[-1], B[-1], B[0]], DARK)
    if s > 1.0:   # blank geschliffene Schneide als eigener Streifen vor dem Rost, damit das Blatt sich vom Gras abhebt
        e0 = [(x - 2.2, z * 0.92, t) for x, z, t in prof[1:4]]
        for side in (-1, 1):
            q = [Vector(((x + 1.6) * CM, side * (t + 0.02) * CM, (32 + z) * CM)) for x, z, t in e0]
            q += [Vector(((x + 1.6) * CM, side * (t + 0.02) * CM, (32 + z) * CM)) for x, z, t in reversed(prof[1:4])]
            face(P, q if side < 0 else list(reversed(q)), EDGE)
    box(P, (-4.4 * CM, -1.2 * CM, 30.6 * CM), (-1.6 * CM, 1.2 * CM, 33.4 * CM), DARK)   # Nacken
def build_handaxe_gob(P): build_handaxe(P, 1.8)

# 348.7 Kobold (MonsterKits kobold: „the spear it fights with“, Vorgangsarchiv 55d: etwa 0,9 m, wächst mit dem Träger): Schaft
# 40 cm hinter, 62 cm vor der Hand, Tülle und blattförmige Spitze aus altem Eisen; figur.gd verkleinert Goblinwaffen auf 0,8
def build_spear(P):
    tube(P, -40, 62, 1.25, 1.1, WOOD, n=8)
    tube(P, -4, 5, 1.4, 1.4, LEATHER, n=8)
    tube(P, 60, 66, 1.5, 1.2, DARK, n=8)
    blade(P, 65, 15, 1.6, 2.4, 0.5, 7.0)

# 348.7 Goblin-Späher (MonsterKits goblin_archer): Kurzbogen wie Dress.bow, ungespannt in Ruhe: 0,58 der Größe des Menschen
# (101 cm), Griff am Ursprung, Wurfarme längs +Z, der Rücken des Bogens nach +X (zum Gegner), die Spitzen 9 % der Länge
# zum Schützen (−X), die Sehne gerade zwischen den Spitzen; Holz 0x5E3E24, Lederwicklung am Griff, Sehne aus Darm
def build_shortbow(P):
    # Runde 1b (Prüfer 1a: ein Strich ohne Krümmung): stärker gebogen und dicker, damit er sich in Spielgröße als Bogen liest
    L = 101.0; bend = 0.13 * L; n = 14
    # Späher Runde 2b (Prüfer 2a: der Bogen ein gestrichelter Strich vor den Beinen): Wurfarme dicker, Holz etwas heller
    def thick(t): return (3.4 - 1.8 * abs(t))
    # Späher Runde 3 (Sokrates statt Chef, 362: beide Wurfarme gekrümmt, ohne Streifen; Prüfer 2: oberer Wurfarm gerade, in
    # der Mitte helle Längsstriche): Wurfarme zurückgebogen (die Spitzen wieder nach vorn), rund statt kantig (glatt schattiert)
    def at(t):
        u = abs(t); x = -bend * 1.25 * u * u + bend * 0.55 * u ** 4 + bend * 0.15
        return Vector((x * CM, 0, t * L / 2 * CM))
    wood = lin(0x6E4A2C)
    for k in range(n):
        t0 = -1.0 + 2.0 * k / n; t1 = -1.0 + 2.0 * (k + 1) / n
        a = ring_pts(Vector((at(t0).x, 0)), thick(t0) * CM * 0.8, thick(t0) * CM, 8, at(t0).z)
        b = ring_pts(Vector((at(t1).x, 0)), thick(t1) * CM * 0.8, thick(t1) * CM, 8, at(t1).z)
        for j in range(8): face(P, [a[j], a[(j + 1) % 8], b[(j + 1) % 8], b[j]], wood)
        if k == 0: face(P, list(reversed(a)), wood)
        if k == n - 1: face(P, b, wood)
    # Griff: Lederwicklung (Dress: darkLeather, ±0,12 der Länge)
    g0 = -0.12 * L / 2; g1 = 0.12 * L / 2
    a = ring_pts(Vector((at(0).x, 0)), 2.9 * CM, 3.2 * CM, 6, g0 * CM); b = ring_pts(Vector((at(0).x, 0)), 2.9 * CM, 3.2 * CM, 6, g1 * CM)
    for j in range(6): face(P, [a[j], a[(j + 1) % 6], b[(j + 1) % 6], b[j]], LEATHER)
    face(P, list(reversed(a)), LEATHER); face(P, b, LEATHER)
    # Sehne: dünner Vierkant von Spitze zu Spitze
    sx = at(1.0).x; s = 0.45 * CM
    # Späher Runde 2 (Prüfer 1: gelbe Krümel an der Bogenhand; Diogenes: heller Fleck am Bogenende): Sehne dunkler
    box(P, (sx - s, -s, at(-1.0).z), (sx + s, s, at(1.0).z), lin(0x6E6450))

# 348.7 Goblin-Schamane (MonsterKits goblin_shaman, Liste „Goblin-Schamane“, Dress.kt staff mit fetish): knorriger Stab mit
# einem kleinen Tierschädel oben, die Augenhöhlen glimmen grün (Eckfarbe mit Alpha 0, toon.gdshader glut), darunter Federn und
# ein Knochen an Schnüren. Für einen Goblin von 108 cm gebaut: 130 cm vom Fuß bis zum Schädel; der Ursprung (Faust) 70 cm über
# dem Fuß, figur.gd schiebt den Stab in der Faust, bis der Fuß am Boden steht
GLOW = lin(0x40D020)     # Runde 1c (Prüfer 1b: glimmt gelb statt grün): satteres Grün
def build_staff_shaman(P):
    # Runde 1b (Prüfer 1a: „dicker schwarzer Pfahl, fast doppelt so hoch wie der Goblin, Schädel winzig“): Holz heller, dünner,
    # 100 cm Schaft (Schädel knapp über dem Kopf), Schädel anderthalbmal so groß
    # Runde 2 (Prüfer, Diogenes 1: Schädel braun „wie ein Ball oder Kürbis“, glimmt nicht): Knochen grauer, Schädel länglich,
    # kurze Hörner nach hinten, die Glut in den Höhlen größer
    wood, dark, bone = lin(0x6E5236), lin(0x4A3626), lin(0xA49C86)
    base, top, n = -60.0, 40.0, 8
    def at(t):   # knorrig: der Schaft schlingert ein wenig
        return Vector((0.9 * math.sin(t * 17.0) * CM, 0.7 * math.cos(t * 11.0) * CM, (base + (top - base) * t) * CM))
    for k in range(n):
        t0, t1 = k / n, (k + 1) / n
        a = ring_pts(at(t0), (1.0 + 0.3 * t0) * CM, (1.0 + 0.3 * t0) * CM, 7, at(t0).z)
        b = ring_pts(at(t1), (1.0 + 0.3 * t1) * CM, (1.0 + 0.3 * t1) * CM, 7, at(t1).z)
        for j in range(7): face(P, [a[j], a[(j + 1) % 7], b[(j + 1) % 7], b[j]], wood if k % 3 else dark)
        if k == 0: face(P, list(reversed(a)), wood)
    # Knoten unter dem Schädel und drei geschnitzte Klauen, die ihn halten
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=1, radius=2.6 * CM)
    for v in bm.verts: v.co.z *= 1.3; v.co += at(1.0)
    for f in bm.faces: face(P, [v.co.copy() for v in f.verts], wood)
    bm.free()
    # Schädel: Hirnschale, Schnauze zum Gegner (+X wie der Bogenrücken; figur.gd dreht +X nach vorn), zwei Augenhöhlen, die glimmen
    U = 1.5
    sk = at(1.0) + Vector((0, 0, 6.5 * U * CM))
    for c_, r_, col in ((sk, (5.6, 3.8, 3.9), bone), (sk + Vector((4.8 * U * CM, 0, -1.6 * U * CM)), (4.0, 2.5, 2.3), bone),
                        (sk + Vector((8.0 * U * CM, 0, -2.4 * U * CM)), (1.8, 1.7, 1.3), bone)):
        bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=2, radius=1.0)
        for v in bm.verts: v.co = Vector((v.co.x * r_[0] * U * CM, v.co.y * r_[1] * U * CM, v.co.z * r_[2] * U * CM)) + c_
        for f in bm.faces: face(P, [v.co.copy() for v in f.verts], col)
        bm.free()
    for sd in (-1, 1):
        # Höhle: dunkler Rand, darin der glimmende Punkt (Alpha 0)
        # Runde 2b (Prüfer 2a: zwei große grelle Glotzaugen, heller als die Augen des Schamanen): kleinere Glut tief in der Höhle
        # Runde 2c (Prüfer 2b: glimmt gar nicht mehr): etwas größer, weiter vorn
        for c_, r_, col in ((sk + Vector((3.9 * U * CM, sd * 2.1 * U * CM, 0.4 * U * CM)), 1.5 * U, lin(0x140C0A)),
                            (sk + Vector((4.4 * U * CM, sd * 2.1 * U * CM, 0.4 * U * CM)), 1.15 * U, GLOW + (0.0,))):
            bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=1, radius=r_ * CM)
            for v in bm.verts: v.co += c_
            for f in bm.faces: face(P, [v.co.copy() for v in f.verts], col)
            bm.free()
        # Runde 1c (Prüfer 1b: Hörner und Federn „wie eine Eule auf dem Stock“): keine Hörner am Stabschädel
        # Runde 2 (Sokrates statt Chef, 362: kurze Hörner nach hinten): flach nach hinten, kaum zur Seite, nicht nach oben
        h0 = sk + Vector((-1.5 * CM, sd * 2.8 * CM, 1.6 * CM)) * U; h1 = sk + Vector((-7.0 * CM, sd * 3.6 * CM, 2.4 * CM)) * U
        dv = h1 - h0; q = dv.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
        bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=6, radius1=1.3 * CM, radius2=0.25 * CM, depth=1.0)
        M4 = Matrix.Translation((h0 + h1) / 2) @ q @ Matrix.Diagonal((1, 1, dv.length, 1))
        for v in bm.verts: v.co = M4 @ v.co
        for f in bm.faces: face(P, [v.co.copy() for v in f.verts], dark)
        bm.free()
    # Federn und ein Knochen hängen an Schnüren unter dem Knoten
    for f_, (dx, dy, L, col) in enumerate(((-1.6, 1.2, 15.0, dark), (0.4, -1.8, 11.0, bone), (1.8, 1.4, 17.0, lin(0x3A2E2A)))):
        a_ = at(0.97) + Vector((dx * CM, dy * CM, 0)); b_ = a_ + Vector((dx * 0.5 * CM, dy * 0.5 * CM, -L * CM))
        w_ = (1.6 if col is not bone else 0.8) * CM
        side = Vector((dy, -dx, 0)).normalized() * w_
        face(P, [a_ - side * 0.3, a_ + side * 0.3, b_ + side, b_ - side], col)
        face(P, [a_ + side * 0.3, a_ - side * 0.3, b_ - side, b_ + side], col)

KINDS = {'dagger': build_dagger, 'shortsword': build_shortsword, 'longsword': build_longsword,
         'quarterstaff': build_quarterstaff, 'shield': build_shield, 'round_shield': build_round_shield,
         'scimitar': build_scimitar, 'handaxe': build_handaxe,
         # Goblins (MonsterKits rusty, crude): altes Eisen braun gefleckt, roher Schild aus grauen Brettern (Dress.kt)
         'scimitar-rost': build_scimitar, 'handaxe-rost': build_handaxe_gob, 'dagger-rost': build_dagger_gob, 'dagger-kobold': build_dagger_kobold,
         'round_shield-grob': build_crude_shield, 'shortbow': build_shortbow, 'staff-schamane': build_staff_shaman,
         'spear-rost': build_spear}
# Runde 3 (Prüfer Goblin Runde 2: Klingen schwarz, nicht als Metall lesbar): Rost heller, Schneide blank geschliffen
# Runde 6 (Prüfer Goblin Runde 5: Klinge mit der Linie ganz schwarz, Rost kaum): Stahl heller, Schneide blanker, Rost als Flecken
ROST = dict(STEEL=lin(0x847A70), EDGE=lin(0xA8A49A), DARK=lin(0x3A3028), BRASS=lin(0x4E463C), LEATHER=lin(0x2A1E16), IRON=lin(0x4A3A30),
            RUST=lin(0x5A4430))
NEU = dict(STEEL=STEEL, EDGE=EDGE, DARK=DARK, BRASS=BRASS, LEATHER=LEATHER, IRON=IRON, RUST=None)
RUST = None

def export(name):
    for o in list(bpy.data.objects): bpy.data.objects.remove(o)
    globals().update(ROST if name.endswith(('-rost', '-grob', '-kobold')) else NEU)
    P = Part(); KINDS[name](P)
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in P.V], [], P.F)
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER')
    for poly in me.polygons:
        poly.use_smooth = name == 'shortbow'     # Späher Runde 3: Kanten des Bogens lasen sich als Streifen
        for li in poly.loop_indices:
            c = P.C[me.loops[li].vertex_index]; ca.data[li].color = (c[0], c[1], c[2], c[3] if len(c) > 3 else 1.0)   # Alpha 0: glimmt
    mat = bpy.data.materials.get('waffe') or bpy.data.materials.new('waffe')
    me.materials.append(mat)
    ob = bpy.data.objects.new(name, me); bpy.context.scene.collection.objects.link(ob)
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True)
    path = os.path.join(OUT, name + '.glb')
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_vertex_color='ACTIVE', export_yup=True)
    tris = sum(len(f) - 2 for f in P.F)
    print('GLB', path, os.path.getsize(path), tris, 'Dreiecke')
    assert tris <= 800, name + ': mehr als 800 Dreiecke (Modellregel 7)'
    return dict(dreiecke=tris)

if __name__ == '__main__':
    names = [os.environ['WAFFE']] if os.environ.get('WAFFE') else list(KINDS)
    json.dump({n: export(n) for n in names}, open(os.path.join(OUT, 'waffen-info.json'), 'w'), indent=1)
