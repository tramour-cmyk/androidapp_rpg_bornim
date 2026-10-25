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
            if fuller and k in (1, 2) and i < steps * fuller: col = DARK
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
# 348.7 Goblin (MonsterKits): Krummsäbel und Handbeil wie Dress.kt (grip, guard, blade, haft, HEAD_AT)
def build_scimitar(P): sword(P, 5.0, 5.0, 1.3, 1.6, 5.6, 5.0, 0.6, 59.0, 1.8, 2.5, 0.42, 13.0, curve=-7.0)
def build_handaxe(P):
    # Stiel 9 cm hinter, 37 cm vor der Hand; Kopf bei 32 cm: Tülle, Blatt nach +X (Schneide), Nacken nach −X
    tube(P, -9, 37, 1.3, 1.2, WOOD, n=8)
    tube(P, -3, 4, 1.45, 1.45, LEATHER, n=8)
    tube(P, 29, 35, 1.9, 1.9, DARK, n=8)
    th0, th1 = 0.6, 0.12
    prof = [(0.0, -1.1, th0), (9.5, -2.3 - 0.3, th1), (10.0, 0.0, th1), (9.5, 2.3 + 0.2, th1), (0.0, 1.1, th0)]   # (x, z, halbe Dicke)
    prof = [(x - 1.6 * (z / 2.3) ** 2 * (x / 9.5), z, t) for x, z, t in prof]   # Schneide leicht gebogen (curve −1,6)
    F = [Vector(((x + 1.6) * CM, -t * CM, (32 + z) * CM)) for x, z, t in prof]; B = [Vector(((x + 1.6) * CM, t * CM, (32 + z) * CM)) for x, z, t in prof]
    face(P, F, STEEL); face(P, list(reversed(B)), STEEL)
    for k in range(len(prof) - 1): face(P, [F[k + 1], F[k], B[k], B[k + 1]], EDGE if 0 < k < 3 else STEEL)
    face(P, [F[0], F[-1], B[-1], B[0]], DARK)
    box(P, (-4.4 * CM, -1.2 * CM, 30.6 * CM), (-1.6 * CM, 1.2 * CM, 33.4 * CM), DARK)   # Nacken

KINDS = {'dagger': build_dagger, 'shortsword': build_shortsword, 'longsword': build_longsword,
         'quarterstaff': build_quarterstaff, 'shield': build_shield, 'round_shield': build_round_shield,
         'scimitar': build_scimitar, 'handaxe': build_handaxe,
         # Goblins (MonsterKits rusty, crude): altes Eisen braun gefleckt, roher Schild aus grauen Brettern (Dress.kt)
         'scimitar-rost': build_scimitar, 'handaxe-rost': build_handaxe, 'dagger-rost': build_dagger,
         'round_shield-grob': lambda P: build_round_shield(P, 0x5A4632)}
ROST = dict(STEEL=lin(0x6A5444), EDGE=lin(0x7C7A76), DARK=lin(0x3A3028), BRASS=lin(0x4E463C), LEATHER=lin(0x2A1E16), IRON=lin(0x4A3A30))
NEU = dict(STEEL=STEEL, EDGE=EDGE, DARK=DARK, BRASS=BRASS, LEATHER=LEATHER, IRON=IRON)

def export(name):
    for o in list(bpy.data.objects): bpy.data.objects.remove(o)
    globals().update(ROST if name.endswith(('-rost', '-grob')) else NEU)
    P = Part(); KINDS[name](P)
    me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in P.V], [], P.F)
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER')
    for poly in me.polygons:
        poly.use_smooth = False
        for li in poly.loop_indices:
            c = P.C[me.loops[li].vertex_index]; ca.data[li].color = (c[0], c[1], c[2], 1.0)
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
