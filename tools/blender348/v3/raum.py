# 399.5 (Chef 28.10., 21:5x: „Innenräume wieder genauso mit den Lichtquellen zu gestalten, wie es vorher war. Und auch so schön mit
# Licht und Schatten und viel Liebe in den Details in der Einrichtung … achte darauf, dass die Außendarstellung des Hauses, was die
# Fenster und Öffnungen betrifft, mit dem, wie es innen ist, übereinstimmt“): ein Grundriss aus dem Export von core (karten.json,
# art INTERIOR) wie alt MapRoomIso.kt, an Stelle des groben Baus aus 399.1.
# - Waende aus denselben Bausatzteilen wie das Haus draussen (dorf.py kithaus, medieval-village-megakit, CC0, Massstab S_KIT):
#   Fenster und Tuer an der Kachel 'W'/'D', aus der auch aussen die Oeffnung kommt; der Tempel aus Stein mit Rundbogenfenstern.
# - je Wandstueck zwei Fassungen: hoch (Bausatz, Balken in den Ecken, Wandschmuck) und tief (kniehohe Bruestung mit Fensterbank wie
#   alt 5h.1); raumlicht.gd zeigt hinter dem Raum hoch, vor ihm tief, nach der Blickrichtung der Kamera (auch gedreht).
# - Einrichtung je Zeichen wie MapRoomIso.objects aus dem freien Bausatz Fantasy Props MegaKit (Quaternius, CC0; Moebel, Kerzen,
#   Geschirr, Buecher, Waren) in unseren Toenen; Theke, Altar, Kamin, Teppich, Weihwasser, Brennholz selbst; Kleinkram auf Tischen,
#   Theke, Kaminsims, Regalen; Borins Hocker und Hammer (MapRoomIso 55.2).
# - Licht nur aus Quellen wie MapLight.sources: Kamin, Kerze je Tisch, Theke, Pult, Altar, Kerzenstaender, Truhe; Tageslicht durch
#   Fenster und Tuer, nachts Mond; in <id>-info.json „lichter“ mit den Flammen (raumlicht.gd baut Licht, Flammen, Flackern).
# - Netze in Stuecken zu 3x3 Kacheln (Mobil: hoechstens acht Lichter je Netz), Waende je Stueck und Fassung.
# Ausgabe <OUT>/<id>.glb (Meter, Kachel 1,16 m), <id>-info.json wie dorf.py.
# Aufruf: OUT=<ordner mit tex/> KARTE=inn KARTEN=<karten.json> CC0=<ordner> python -I raum.py   (vorher tex.py mit demselben OUT)
import bpy, math, os, json, random, glob
from mathutils import Vector, Matrix

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../..'))
KARTEN = json.load(open(os.environ.get('KARTEN', ROOT + '/godot/daten/karten.json')))
ID = os.environ.get('KARTE', 'inn')
K = KARTEN['karten'][ID]
assert K.get('art') == 'INTERIOR', '%s ist kein Grundriss' % ID
ROWS = K['zeilen']; NR = len(ROWS); NC = K['breite']
TS = 116.0                                           # cm je Kachel wie dorf.py
CC0 = os.path.expanduser(os.environ.get('CC0') or os.environ.get('Q') or '~/cc0')
VDIR = glob.glob(glob.escape(CC0) + '/medieval-village-megakit/*/glTF')[0]
PDIR = glob.glob(glob.escape(CC0) + '/fantasy-props-megakit/*/glTF')[0]
S_KIT = (4 * TS - 12) / 600.0                        # wie dorf.py kithaus (Gwennas Haus): Bausatz-Meter -> cm
SZ = 1.0                                             # Hoehe: Wand 3,12 m, Tuer 2,32 m (aussen S_KIT: 2,35, 1,75; der Held ist 1,8 m;
                                                     # Pruefer Lauf 1: bei 0,85 die Tuer kaum hoeher als der Held)
WAND_H = 312 * SZ
TIEF_H = 48.0                                        # Bruestung zum Betrachter
TEMPEL = ID.startswith('temple')
LADEN = ID.startswith('shop')
AELTESTER = ID.startswith('elder')
SCHENKE = ID.startswith('inn')
WAENDE = set('#WDZ')
WALK = {c for c, t in KARTEN['kacheln'].items() if t['begehbar']}
rnd = random.Random(sum(map(ord, ID)))
def ch(c, r): return ROWS[r][c] if 0 <= r < NR and 0 <= c < NC else '#'
def drin(c, r): return ch(c, r) not in WAENDE
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
def ss(a, b, x): t = min(1.0, max(0.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def hsh(c, r, s): return int(h1(c * 7.3 + 0.5, r * 3.1 + 0.5, s) * 1000)

bpy.ops.wm.read_factory_settings(use_empty=True)
def hx(c): return ((c >> 16) & 255) / 255, ((c >> 8) & 255) / 255, (c & 255) / 255
def lin(c): return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in hx(c))
def sc(a, k): return tuple(min(1.0, x * k) for x in a)
def mul(a, b): return tuple(x * y for x, y in zip(a, b))
SCALE = dict(putz=200, bretter=120, feldstein=160, pflaster=220, holz=100, balken=100, stoff=100, weiss=100)

class Part:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.M = []; self.UV = []
PARTS = {}
def part(name):
    if name not in PARTS: PARTS[name] = Part(); NAMEN[id(PARTS[name])] = name
    return PARTS[name]
NAMEN = {}
def klein(P):
    """Kleinkram eines Stuecks (Krug, Kerze, Buch …) in eigenes Netz Klein_…: wirft keinen Schatten (raumlicht.gd, spart Schattenlaeufe)"""
    n = NAMEN.get(id(P), '')
    # Herd: Kessel und Kram bleiben im Feuerloch-Netz, das mit seiner Wand geht (Pruefer Lauf 6: gedreht blieb der Kesseldeckel als graue Scheibe)
    return part('Klein_' + n.split('_', 1)[1]) if n.startswith(('Ding_', 'Wand_')) else P
def stueck(c, r): return '%d_%d' % (int(c) // 3, int(r) // 3)
LICHTER = []
WANDLISTE = []
HERD_VON = {}                                        # hohe Fassung -> Netz des Feuerlochs
WAND_VON = {}                                        # (Spalte, Zeile, Seite) -> hohe Fassung der Wand dort

def add_face(P, pts, col, m, uv=None):
    """Flaeche in P; col eine Farbe (linear), eine Liste je Ecke oder eine Funktion (Punkt, Normale) -> Farbe; uv sonst planar"""
    nrm = (pts[1] - pts[0]).cross(pts[-1] - pts[0])
    nrm = nrm.normalized() if nrm.length > 1e-9 else Vector((0, 0, 1))
    if uv is None:
        s = SCALE.get(m, 100.0)
        if abs(nrm.z) > 0.8: uv = [(p.x / s, p.y / s) for p in pts]
        elif abs(nrm.x) > abs(nrm.y): uv = [(p.y / s, p.z / s) for p in pts]
        else: uv = [(p.x / s, p.z / s) for p in pts]
    if callable(col): cols = [col(p, nrm) for p in pts]
    elif isinstance(col, list): cols = col
    else: cols = [col] * len(pts)
    n0 = len(P.V); P.V += list(pts); P.F.append(tuple(range(n0, n0 + len(pts)))); P.C += cols; P.UV.append(uv); P.M.append(m)

def box(P, lo, hi, col, m, M=None):
    """Quader (cm, Blender: z oben); jede Seite nach aussen gewandt; M setzt ihn ein (cm)"""
    a = Vector(lo); b = Vector(hi)
    v = [Vector((x, y, z)) for z in (a.z, b.z) for y in (a.y, b.y) for x in (a.x, b.x)]
    if M is not None: v = [M @ q for q in v]
    for q in ((0, 2, 3, 1), (4, 5, 7, 6), (0, 1, 5, 4), (2, 6, 7, 3), (0, 4, 6, 2), (1, 3, 7, 5)):
        add_face(P, [v[i] for i in q], col, m)

def zylinder(P, base, r, h, n, col, m, r2=None, deckel=True, M=None, achse=None):
    """stehender Zylinder (oder Kegelstumpf r -> r2); achse: liegend entlang Vector (Einheit), base = Mitte der einen Stirn"""
    r2 = r if r2 is None else r2
    if achse is None: e1, e2, e3 = Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1))
    else:
        e3 = achse.normalized(); e1 = e3.cross(Vector((0, 0, 1)) if abs(e3.z) < 0.9 else Vector((1, 0, 0))).normalized(); e2 = e3.cross(e1)
    def W(p): return M @ p if M is not None else p
    for k in range(n):
        a0 = 2 * math.pi * k / n; a1 = 2 * math.pi * (k + 1) / n
        p0 = base + (e1 * math.cos(a0) + e2 * math.sin(a0)) * r; p1 = base + (e1 * math.cos(a1) + e2 * math.sin(a1)) * r
        q0 = base + e3 * h + (e1 * math.cos(a0) + e2 * math.sin(a0)) * r2; q1 = base + e3 * h + (e1 * math.cos(a1) + e2 * math.sin(a1)) * r2
        add_face(P, [W(p0), W(p1), W(q1), W(q0)], col, m)
        if deckel:
            add_face(P, [W(base + e3 * h), W(q0), W(q1)], col, m)
            add_face(P, [W(base), W(p1), W(p0)], col, m)

HOLZ = lin(0x8a6a48); DUNKEL = lin(0x5a4330); STEIN = lin(0x9a948a); STOFF_ROT = lin(0x8e3b2c)
STOFF_BLAU = lin(0x3c5270); GOLD = lin(0xc9a24a); WEISS = (1.0, 1.0, 1.0); RUSS = lin(0x16110d)
PERGAMENT = lin(0xe8dcc0)
W1 = (1.0, 1.0, 1.0)

# ---------------------------------------------------------------- Bausatzteile lesen (einmal je Datei, dann nur Zahlen)
KITC = {}
TEXNAMEN = {}
MAXTRI = 1900                                        # Modellregel 7: Ding hoechstens 2000 Dreiecke
def kit_lesen(d, name, klein_gesetzt=False):
    """Flaechen eines Bausatzteils in Bausatz-Metern: [(Punkte, uv, Farben, Material des Bausatzes, Bild)], unten, oben;
    klein_gesetzt: verkleinert gesetzt (Kiste im Regal), dann wie Kleinkram hoechstens 320 Dreiecke (Laden: 54 Tsd. im Regal)"""
    key = (d, name, klein_gesetzt)
    if key in KITC: return KITC[key]
    vor = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(d, name + '.gltf'))
    neu = [o for o in bpy.data.objects if o not in vor]
    flaechen = []
    for o in neu:
        if o.type != 'MESH' or o.name.startswith('Icosphere'): continue
        tris = sum(len(p.vertices) - 2 for p in o.data.polygons)
        bb = [o.matrix_world @ Vector(v) for v in o.bound_box]
        gross = max(max(q[i] for q in bb) - min(q[i] for q in bb) for i in range(3))
        grenze = MAXTRI if gross > 0.45 and not klein_gesetzt else 320   # Kleinkram (Krug, Flasche, Kerze): aus der Naehe genug, spart Speicher
        if tris > grenze:
            mo = o.modifiers.new('weniger', 'DECIMATE'); mo.ratio = grenze / tris
        dg = bpy.context.evaluated_depsgraph_get(); dg.update()
        oe = o.evaluated_get(dg); me = oe.to_mesh()
        W = o.matrix_world.copy()
        uvl = me.uv_layers.active
        ca = me.color_attributes.active_color if len(me.color_attributes) else None
        for poly in me.polygons:
            mat = me.materials[poly.material_index] if me.materials else None
            mn = mat.name.split('.')[0] if mat else ''
            bild = None
            if mat and mat.use_nodes:
                for nd in mat.node_tree.nodes:
                    if nd.type == 'TEX_IMAGE' and nd.image and 'BaseColor' in nd.image.name: bild = nd.image
            pts = []; uv = []; cols = []
            for li in poly.loop_indices:
                vi = me.loops[li].vertex_index
                pts.append(W @ me.vertices[vi].co)
                uv.append(tuple(uvl.data[li].uv) if uvl else (0.0, 0.0))
                if ca is not None:
                    c = ca.data[li].color if ca.domain == 'CORNER' else ca.data[vi].color
                    cols.append((c[0], c[1], c[2]))
                else: cols.append(W1)
            flaechen.append((pts, uv, cols, mn, bild.filepath if bild else None, poly.use_smooth))
        oe.to_mesh_clear()
    for o in neu: bpy.data.objects.remove(o, do_unlink=True)
    P = [p for f in flaechen for p in f[0]]
    lo = Vector([min(p[i] for p in P) for i in range(3)]); hi = Vector([max(p[i] for p in P) for i in range(3)])
    KITC[key] = (flaechen, lo, hi)
    return KITC[key]

def kit_textur(pfad, kmat):
    """Bild des Bausatzes als unsere Textur kit_<name> (hoechstens 1024 px, Modellregel 6)"""
    from PIL import Image
    name = 'kit_' + os.path.basename(pfad).replace('T_Trim_', '').replace('_BaseColor', '').split('.')[0].lower()
    if name not in TEXNAMEN:
        src = pfad if os.path.isabs(pfad) else os.path.join(PDIR, pfad)
        if not os.path.exists(src): src = os.path.join(os.path.dirname(PDIR.rstrip('/')), '..', 'Textures', os.path.basename(pfad))
        if not os.path.exists(src): src = os.path.join(CC0, 'fantasy-props-megakit', 'Textures', os.path.basename(pfad))
        os.makedirs(os.path.join(OUT, 'tex'), exist_ok=True)
        Image.open(src).convert('RGB').resize((1024, 1024), Image.LANCZOS).save(os.path.join(OUT, 'tex', name + '.png'))
        TEXNAMEN[name] = src
    return name

# Toenung der Bausatzbilder auf unsere Palette (Moebel wie alt dunkle Eiche, MapRoomIso m(0x…))
KIT_TON = {'kit_furniture': (0.66, 0.6, 0.56), 'kit_metal': (0.8, 0.78, 0.76), 'kit_cloth': (0.9, 0.86, 0.8), 'kit_props': (0.9, 0.86, 0.82)}
def stueck_setzen(P, name, M, ton=None, d=None, farbe=None, klein_gesetzt=False):
    """ein Teil des Bausatzes Fantasy Props (d=PDIR) mit M (cm, Bausatz-Meter * 100 vorher) in P, eigene Bilder des Bausatzes"""
    fl, lo, hi = kit_lesen(d or PDIR, name, klein_gesetzt)
    W = M @ Matrix.Scale(100.0, 4)
    for pts, uv, cols, mn, bild, glatt in fl:
        m = kit_textur(bild, mn) if bild else 'weiss'
        t = KIT_TON.get(m, W1)
        if ton: t = mul(t, ton)
        if farbe and m == 'weiss': t = farbe
        if mn == 'MI_Page_Empty': m = 'weiss'; t = PERGAMENT
        add_face(P, [W @ p for p in pts], [mul(c, t) for c in cols], m, uv=list(uv))
    return lo, hi

def stelle(P, name, pos, a=0.0, s=1.0, z=0.0, ton=None, boden=True, farbe=None):
    """Teil auf den Boden (oder z) bei pos (cm), um a Grad gedreht (Front des Bausatzes nach -Y), Massstab s (Zahl oder (x, y, z))"""
    fl, lo, hi = kit_lesen(PDIR, name)
    sv = (s, s, s) if isinstance(s, (int, float)) else s
    kl = max((hi - lo)[i] * 100 * abs(sv[i]) for i in range(3)) < 40
    if kl: P = klein(P)
    M = (Matrix.Translation((pos.x, pos.y, (pos.z if hasattr(pos, 'z') else 0) + z)) @ Matrix.Rotation(math.radians(a), 4, 'Z')
         @ Matrix.Diagonal((sv[0], sv[1], sv[2], 1)) @ Matrix.Translation((0, 0, -lo.z * 100 if boden else 0)))
    stueck_setzen(P, name, M, ton, farbe=farbe, klein_gesetzt=kl)
    return M

def masse(name):
    fl, lo, hi = kit_lesen(PDIR, name)
    return (hi - lo) * 100

def bretter_hoehen(name, x_rand=0.15):
    """Hoehen (Bausatz-cm ueber dem Fuss) der Boeden eines Regals: grosse nach oben gewandte Flaechen innen"""
    fl, lo, hi = kit_lesen(PDIR, name)
    zs = {}
    for pts, *_ in fl:
        n = (pts[1] - pts[0]).cross(pts[-1] - pts[0])
        if n.length < 1e-9 or n.normalized().z < 0.95: continue
        cx = sum(p.x for p in pts) / len(pts)
        if abs(cx) > (hi.x - lo.x) / 2 * (1 - x_rand): continue
        z = round((pts[0].z - lo.z) * 100)
        zs[z] = zs.get(z, 0) + n.length / 2
    return sorted(z for z, a in zs.items() if a > 0.02 and 15 < z < (hi.z - lo.z) * 100 - 15)

def kerze_licht(pos, reich, kraft, flammen, art='kerze', wand=None):
    LICHTER.append(dict(art=art, pos=list(pos), reich=reich, kraft=kraft, flammen=[list(f) for f in flammen], **({'wand': wand} if wand else {})))

def leuchter(P, pos, a=0.0, hoch=None):
    """Kerzenhalter mit brennender Kerze (Bausatz CandleStick + Candle_2); gibt die Dochtspitze zurueck"""
    h = hoch if hoch is not None else 18.0 + (hsh(int(pos.x), int(pos.y), 9) % 10)
    stelle(P, 'CandleStick', pos, a, 0.9)
    s = h / masse('Candle_2').z
    stelle(P, 'Candle_2', pos, a, (0.9, 0.9, s), z=6.0)
    return Vector((pos.x, pos.y, pos.z + 6.0 + h + 2.5))

WACHS = lin(0xf0e6c8); MESSING = lin(0xd8b860)
def stumpf(P, pos, h):
    """Kerzenstumpf ohne Halter, Wachs am Fuss verlaufen (alt candle drips); gibt die Dochtspitze zurueck"""
    P = klein(P)
    zylinder(P, pos, 4.0, 0.6, 10, WACHS, 'weiss', r2=3.0)
    zylinder(P, pos, 2.0, h, 8, WACHS, 'weiss', r2=1.8)
    return Vector((pos.x, pos.y, pos.z + h + 2.0))

def waage(P, pos):
    """Kraemerwaage (alt shopTop 0): Fuss, Saeule, Balken ein wenig schief, zwei Schalen an Schnueren, Gewicht in der einen"""
    # Pruefer Lauf 6: von vorn wie eine Stange (Schalen flach, Schnuere unsichtbar): Brett als Fuss, Saeule mit Knauf, Zeiger nach
    # oben, tiefe Schalen an je drei Ketten, in der einen Schale Muenzen, in der anderen ein Gewicht
    P = klein(P)
    box(P, (pos.x - 16, pos.y - 9, pos.z), (pos.x + 16, pos.y + 9, pos.z + 3), lambda q, n_: sc(lin(0x6a4a30), 0.9 + 0.2 * vn(q.x / 8, 0, 4)), 'holz')
    zylinder(P, pos + Vector((0, 0, 3)), 4.0, 3.0, 12, MESSING, 'weiss', r2=3.0)
    zylinder(P, pos + Vector((0, 0, 3)), 1.6, 38, 8, MESSING, 'weiss')
    zylinder(P, pos + Vector((0, 0, 42)), 3.0, 4, 10, MESSING, 'weiss', r2=1.0)
    links = pos + Vector((-24, 0, 38.5)); rechts = pos + Vector((24, 0, 35.5))
    zylinder(P, links, 1.8, (rechts - links).length, 8, MESSING, 'weiss', achse=rechts - links)   # Lauf 3: als schwarzer Strich gelesen
    zeig = pos + Vector((0.6, 0, 37.0))
    zylinder(P, zeig, 1.0, 14, 4, MESSING, 'weiss', r2=0.3, achse=Vector((0.1, 0, 1)))
    for end, tief, last in ((links, 20.0, 'muenzen'), (rechts, 16.0, 'gewicht')):
        schale = end - Vector((0, 0, tief))
        for k in range(3):
            an = k * 2 * math.pi / 3 + 0.5
            q = schale + Vector((9 * math.cos(an), 9 * math.sin(an), 4.5))
            zylinder(P, q, 0.5, (end - q).length, 4, lin(0x6a5a38), 'weiss', achse=end - q)
        zylinder(P, schale, 5.0, 5.0, 16, MESSING, 'weiss', r2=11.0, deckel=False)
        zylinder(P, schale, 5.0, 0.4, 16, sc(MESSING, 0.7), 'weiss')
        zylinder(P, schale + Vector((0, 0, 4.6)), 11.0, 0.8, 16, sc(MESSING, 1.15), 'weiss', r2=11.6, deckel=False)
        if last == 'muenzen':
            for i in range(5):
                zylinder(P, schale + Vector((-3 + 2 * (i % 3), -2 + 2 * (i // 3), 0.5 + 0.7 * i)), 2.4, 0.6, 10, GOLD, 'weiss')
        else:
            zylinder(P, schale + Vector((0, 0, 0.5)), 3.2, 5.0, 8, lin(0x5a5652), 'weiss', r2=2.4)

def tuchballen(P, pos, s, schere=True):
    """Tuchballen auf der Theke, halb abgerollt, daneben eine eiserne Schere (alt shopTop 2)"""
    P = klein(P)
    col = lin([0x7a3a2e, 0x3c5270, 0x5a6a3a, 0xa08040][s % 4])
    zylinder(P, pos + Vector((-17, 0, 6)), 6.0, 34, 10, col, 'stoff', achse=Vector((1, 0, 0)))
    if schere: box(P, (pos.x + 17, pos.y - 6, 0), (pos.x + 24, pos.y + 6, 0.6), col, 'stoff')
    for d in ((-1, 1) if schere else ()):
        a = Vector((pos.x + 28, pos.y + 14 - 4 * d, 0.5)); b = Vector((pos.x + 40, pos.y + 14 + 4 * d, 0.5))
        zylinder(P, a, 0.6, (b - a).length, 4, lin(0x5a5652), 'weiss', achse=b - a)

def kraeuter(P, p, n, e):
    """Kraeuterbuendel an einem Brett unter der Decke (alt MapRoom.wallThing 0): vier Buendel kopfueber, gruen bis braun"""
    a = p + e * -42 + n * 2 + Vector((0, 0, 194)); b = p + e * 42 + n * 16 + Vector((0, 0, 204))
    box(P, tuple(min(a[i], b[i]) for i in range(3)), tuple(max(a[i], b[i]) for i in range(3)), lambda q, n_: sc(BALKEN_T, 0.8), 'balken')
    for k in range(4):
        q = p + e * (-30 + 20 * k) + n * 12 + Vector((0, 0, 194))
        lang = 22 + (hsh(int(q.x), int(q.y), k) % 10)
        col = [lin(0x8aa060), lin(0x6e8050), lin(0x9a8050), lin(0xa89a5a)][(k + hsh(int(p.x), int(p.y), 3)) % 4]   # Lauf 2: wie Flecken
        zylinder(P, q - Vector((0, 0, 4)), 0.4, 4, 4, lin(0x7a6a4a), 'weiss')
        zylinder(P, q - Vector((0, 0, 4 + lang)), 5.5, lang, 7, lambda q_, n_, c=col: sc(c, 0.8 + 0.4 * vn(q_.x / 3, q_.z / 3, k)), 'weiss', r2=1.4)

# ---------------------------------------------------------------- Boden
def boden_ton(p, n):
    c, r = int(p.x // TS), int(-p.y // TS)
    nah = min([TS] + [abs(p.x - tx(cc)) for cc in (c, c + 1) if not drin(cc + (0 if cc == c + 1 else -1), r)]
              + [abs(-p.y - r * TS) if not drin(c, r - 1) else TS, abs(-p.y - (r + 1) * TS) if not drin(c, r + 1) else TS])
    k = (0.86 + 0.2 * vn(p.x / 90, p.y / 90, 3)) * (0.78 + 0.22 * ss(0, 60, nah))     # an den Waenden dunkler (Staub, kein Tritt)
    return sc(W1, k)

for r in range(NR):
    for c in range(NC):
        z = ch(c, r)
        if z in WAENDE and z != 'D': continue
        if z == 'D' and r != NR - 1 and r != 0 and c != 0 and c != NC - 1: continue
        P = part('Diele_' + stueck(c, r))
        x0, y0 = tx(c), ty(r)
        q = [Vector((x0, y0 - TS, 0)), Vector((x0 + TS, y0 - TS, 0)), Vector((x0 + TS, y0, 0)), Vector((x0, y0, 0))]
        if z == 'D':   # Schwelle: Stein, ausgetreten (alt door: der Schritt hinaus)
            add_face(P, q, lambda p, n: sc(STEIN, 0.7 + 0.2 * vn(p.x / 30, p.y / 30, 5)), 'feldstein')
            continue
        add_face(P, q, boden_ton, 'pflaster' if TEMPEL else 'bretter')

# Teppich: ein Stueck ueber alle 'R', mit Borte und Fransen (alt RUG)
rs = [(c, r) for r in range(NR) for c in range(NC) if ch(c, r) == 'R']
if rs:
    c0, c1 = min(c for c, _ in rs), max(c for c, _ in rs); r0, r1 = min(r for _, r in rs), max(r for _, r in rs)
    P = part('Ding_' + stueck((c0 + c1) / 2, (r0 + r1) / 2))
    x0, x1 = tx(c0) + 12, tx(c1 + 1) - 12; y0, y1 = ty(r1 + 1) + 14, ty(r0) - 14
    # rot mit hellbrauner Borte wie alt MapRoom RUG/RUG_B, auch beim Aeltesten (Pruefer Lauf 1: alt roter Teppich, neu blau)
    grund = lin(0x5e2c24); borte = lin(0x8a7650); raute = lin(0x9a4a36)
    def teppich(p, n):
        rand = min(p.x - x0, x1 - p.x, p.y - y0, y1 - p.y)
        if rand < 15: return sc(borte, (0.8 if rand < 7 else 1.0) * (0.9 + 0.15 * vn(p.x / 20, p.y / 20, 8)))
        return sc(grund, 0.9 + 0.15 * vn(p.x / 40, p.y / 40, 8))
    # oben als Raster zu 5 cm: die Farbe sitzt an den Ecken, mit nur vier Ecken war der ganze Teppich Borte (Pruefer Lauf 3: beige)
    nx = max(1, int((x1 - x0) / 5)); ny = max(1, int((y1 - y0) / 5))
    for i in range(nx):
        for j in range(ny):
            a0, a1 = x0 + (x1 - x0) * i / nx, x0 + (x1 - x0) * (i + 1) / nx
            b0, b1 = y0 + (y1 - y0) * j / ny, y0 + (y1 - y0) * (j + 1) / ny
            add_face(P, [Vector((a0, b0, 1.0)), Vector((a1, b0, 1.0)), Vector((a1, b1, 1.0)), Vector((a0, b1, 1.0))], teppich, 'weiss')
    for q in ([Vector((x0, y0, 0)), Vector((x1, y0, 0)), Vector((x1, y0, 1)), Vector((x0, y0, 1))],
              [Vector((x1, y1, 0)), Vector((x0, y1, 0)), Vector((x0, y1, 1)), Vector((x1, y1, 1))],
              [Vector((x0, y1, 0)), Vector((x0, y0, 0)), Vector((x0, y0, 1)), Vector((x0, y1, 1))],
              [Vector((x1, y0, 0)), Vector((x1, y1, 0)), Vector((x1, y1, 1)), Vector((x1, y0, 1))]):
        add_face(P, q, sc(borte, 0.8), 'weiss')
    # Rauten wie alt MapRoom RUG (je Kachel eine, helles Rot auf dunklem Feld, Mitte in Borte) als eigene Streifen: im 5-cm-Raster
    # traf keine Ecke die schmale Linie (Pruefer Lauf 6: Teppich ohne Muster)
    for (c, r) in rs:
        m_ = mitte(c, r) + Vector((0, 0, 1.3)); rr = 34.0; b2 = 3.5
        ecken = [m_ + Vector(v) * rr for v in ((1, 0, 0), (0, 1, 0), (-1, 0, 0), (0, -1, 0))]
        for i in range(4):
            a_, b_ = ecken[i], ecken[(i + 1) % 4]
            q_ = Vector((-(b_ - a_).y, (b_ - a_).x, 0)).normalized() * b2
            add_face(P, [a_ - q_, b_ - q_, b_ + q_, a_ + q_], raute, 'weiss')
        add_face(P, [m_ + Vector(v) * 7 for v in ((1, 0, 0), (0, 1, 0), (-1, 0, 0), (0, -1, 0))], borte, 'weiss')
    for x in range(int(x0) + 3, int(x1) - 2, 6):   # Fransen an den Schmalseiten
        for y_, d_ in ((y0, -1), (y1, 1)):
            box(P, (x, min(y_, y_ + d_ * 7), 0), (x + 2, max(y_, y_ + d_ * 7), 0.6), lin(0xc8b48c), 'stoff')

# ---------------------------------------------------------------- Waende
SEITEN = {   # Nachbar, Linie, nach innen (Blender), Drehung des Bausatzteils (Front -Y nach aussen, +Y nach innen), entlang
    'N': ((0, -1), lambda c, r: ((tx(c), ty(r)), (tx(c + 1), ty(r))), Vector((0, -1, 0)), 180, Vector((-1, 0, 0))),
    'S': ((0, 1), lambda c, r: ((tx(c), ty(r + 1)), (tx(c + 1), ty(r + 1))), Vector((0, 1, 0)), 0, Vector((1, 0, 0))),
    'W': ((-1, 0), lambda c, r: ((tx(c), ty(r)), (tx(c), ty(r + 1))), Vector((1, 0, 0)), -90, Vector((0, -1, 0))),
    'O': ((1, 0), lambda c, r: ((tx(c + 1), ty(r)), (tx(c + 1), ty(r + 1))), Vector((-1, 0, 0)), 90, Vector((0, 1, 0))),
}
kanten = {}
for r in range(NR):
    for c in range(NC):
        if not drin(c, r) or (ch(c, r) == 'D'): continue
        for s, (d, linie, n, a, e) in SEITEN.items():
            nb = (c + d[0], r + d[1])
            z = ch(*nb)
            if z not in WAENDE: continue
            (ax, ay), (bx, by) = linie(c, r)
            m = Vector(((ax + bx) / 2, (ay + by) / 2, 0))
            schluessel = (s, round(ay if s in 'NS' else ax))
            kanten.setdefault(schluessel, []).append(dict(c=c, r=r, art=z, m=m, nb=nb))

def laeufe():
    """zusammenhaengende Kanten je Seite und Linie: [(Seite, [Kanten])]"""
    out = []
    for (s, _), ks in sorted(kanten.items()):
        e = SEITEN[s][4]
        ks.sort(key=lambda k: k['m'].dot(e))
        lauf = [ks[0]]
        for k in ks[1:]:
            if abs((k['m'] - lauf[-1]['m']).length - TS) < 1: lauf.append(k)
            else: out.append((s, lauf)); lauf = [k]
        out.append((s, lauf))
    return out

KIT_MAT = dict(MI_Plaster='putz', MI_WoodTrim='balken', MI_WoodTrim_Wear='balken', MI_MetalOrnaments='balken', MI_Brick='feldstein',
               MI_RedBrick='feldstein', MI_UnevenBrick='feldstein', MI_RockTrim='feldstein', MI_WindowGlass='glas')
PUTZ_T = lin(0xb8ab92); BALKEN_T = (1.0, 0.95, 0.9)
GRAU = lin(0x9a968e)                                 # Tempel: grauer Quaderstein wie alt ashlar (Pruefer Lauf 1: neu beige)
def putz_ton(p, n):
    """Putz innen wie alt timber(): oben russig, am Sockel feucht, hier und da ausgebessert"""
    k = (0.92 + 0.14 * vn(p.x / 70 + p.y / 70, p.z / 60, 13)) * (1.0 - 0.28 * ss(110, WAND_H, p.z)) * (1.0 - 0.14 * ss(40, 0, p.z))
    if TEMPEL: return sc(GRAU, k * 1.05)
    return sc(PUTZ_T, k)
def stein_ton(p, n):
    return sc(GRAU if TEMPEL else STEIN, (0.8 + 0.25 * vn(p.x / 50 + p.y / 50, p.z / 40, 11)) * (1.0 - 0.2 * ss(130, WAND_H, p.z)))
WTON = dict(putz=putz_ton, balken=lambda p, n: sc(BALKEN_T, 0.85 + 0.15 * vn(p.x / 60 + p.y / 60, p.z / 60, 17)), feldstein=stein_ton)

def kit_wand(P, G, name, M, n_innen):
    """Teil des Dorfbausatzes (M in cm, Bausatz-cm) mit unseren Materialien wie dorf.py kit_teil; Glas innen als Fensterlicht G"""
    fl, lo, hi = kit_lesen(VDIR, name)
    W = M @ Matrix.Scale(100.0, 4)
    for pts, uv, cols, mn, bild, glatt in fl:
        q = [W @ p for p in pts]
        m = KIT_MAT.get(mn, 'putz')
        nn = (q[1] - q[0]).cross(q[-1] - q[0])
        innen = nn.length > 1e-9 and nn.normalized().dot(n_innen) > 0.5
        if m == 'glas':
            if G is not None:   # Scheibe nach innen gewandt: tags hell, nachts Mondschein (raumlicht.gd)
                add_face(G, q[::-1], lin(0xb8c8d8), 'weiss')
            continue
        if TEMPEL and m == 'putz' and innen: m = 'feldstein'   # alt 13q.10: der Tempel ist aus Stein gebaut
        add_face(P, q, WTON[m], m)

def wand_plan(L, oeffnungen):
    """Teile eines Wandstuecks der Laenge L (Bausatz-m, Mitte 0) wie dorf.py wand_plan: Fenster, Tuer (Breite 2), Kamin (eigene
    Breite) an ihrer Stelle, dazwischen glatte Stuecke beliebiger Breite. Liste (mitte, breite, art)"""
    teile = []
    for u, b, k in sorted(oeffnungen):
        b = min(b, L)
        u = max(-L / 2 + b / 2, min(L / 2 - b / 2, u))
        if teile and u - b / 2 < teile[-1][0] + teile[-1][1] / 2 - 1e-6:   # ueberlappt: an das vorige anschliessen
            u = teile[-1][0] + teile[-1][1] / 2 + b / 2
            if u + b / 2 > L / 2 + 1e-6: continue
        teile.append([u, b, k])
    out = []; x = -L / 2
    for m_, b_, k_ in teile + [[L / 2, 0.0, None]]:
        g = (m_ - b_ / 2) - x
        if g > 0.25:
            n = max(1, round(g / 2.0))
            for i in range(n): out.append((x + g * (i + 0.5) / n, g / n, '#'))
        elif g > 0.005 and out: c_, b0, k0 = out[-1]; out[-1] = (c_ + g / 2, b0 + g, k0)
        elif g > 0.005: m_, b_ = m_ - g / 2, b_ + g
        if k_: out.append((m_, b_, k_)); x = m_ + b_ / 2
    return out

PRE = 'Wall_UnevenBrick_' if TEMPEL else 'Wall_Plaster_'
GLATT = PRE + 'Straight' if TEMPEL else PRE + 'Straight_Base'
FENSTER = 'Window_Thin_Round' if TEMPEL else 'Window_Wide_Flat'   # wie draussen (dorf.py kithaus)
HOCH_DINGE = set('QUVBKNs')                          # nichts an die Wand ueber Hohem (alt D1.4)
HERDE = []
for nr_, (s, lauf) in enumerate(laeufe()):
    d, linie, n, a, e = SEITEN[s]
    mitte_l = sum((k['m'] for k in lauf), Vector()) / len(lauf)
    L = len(lauf) * TS; Lk = L / (100 * S_KIT)
    def u_von(p): return (p - mitte_l).dot(e) / (100 * S_KIT)
    hoch = 'Wand_%s_hoch_%d' % (s, nr_); tief = 'Wand_%s_tief_%d' % (s, nr_); glas = 'Fensterlicht_%s_%d' % (s, nr_)
    oeff = []
    zs = [k for k in lauf if k['art'] == 'Z']
    if zs:
        oeff.append((sum(u_von(k['m']) for k in zs) / len(zs), len(zs) * TS / (100 * S_KIT), 'Z'))
        HERDE.append((s, zs, n, e, hoch, tief))
    for k in lauf:
        if k['art'] in 'WD': oeff.append((u_von(k['m']), 2.0 if k['art'] == 'W' else 1.6, k['art']))
    plan = wand_plan(Lk, oeff)
    PH, PT, PG = part(hoch), part(tief), part(glas)
    WANDLISTE.append(dict(hoch=hoch, tief=tief, glas=glas, klein='Klein_' + hoch.split('_', 1)[1], innen=[n.x, -n.y]))   # Kleinkram der Wand mit ihr
    for k in lauf: WAND_VON[(k['c'], k['r'], s)] = hoch
    def at(u, sx):
        p = mitte_l + e * (u * 100 * S_KIT) - n * (31 * S_KIT)
        return Matrix.Translation(p) @ Matrix.Rotation(math.radians(a), 4, 'Z') @ Matrix.Diagonal((S_KIT * sx, S_KIT, SZ, 1))
    for u, b, k in plan:
        if k == 'Z': continue
        if k == 'D':
            kit_wand(PH, None, PRE + 'Door_Round', at(u, b / 2.0), n)
            # Tuerblatt offen in den Raum geschwenkt, an der linken Laibung (von innen gesehen)
            kit_wand(PH, None, 'Door_1_Round', at(u, 1.0) @ Matrix.Translation((-56, 26, 0)) @ Matrix.Rotation(math.radians(-100), 4, 'Z'), n)
        elif k == 'W':
            kit_wand(PH, PG, PRE + FENSTER, at(u, b / 2.0), n)
            kit_wand(PH, PG, FENSTER + '1', at(u, b / 2.0), n)
        else: kit_wand(PH, None, GLATT, at(u, b / 2.0), n)
    # Balken in den Ecken (alt: Pfosten, wo zwei Waende zusammenstossen)
    for k_end, sg in ((lauf[0], -1), (lauf[-1], 1)):
        p = k_end['m'] + e * (sg * TS / 2) + n * 7 - e * (sg * 7)
        box(PH, (p.x - 7, p.y - 7, 0), (p.x + 7, p.y + 7, WAND_H), lambda p_, n_: sc(BALKEN_T, 0.8), 'balken')
    # tief: Bruestung (Feldsteinsockel, Putz, Balken obenauf), an Fenstern eine Fensterbank, an Tuer und Kamin offen
    def bruestung(u0, u1):
        if u1 - u0 < 0.05: return
        p0 = mitte_l + e * (u0 * 100 * S_KIT); p1 = mitte_l + e * (u1 * 100 * S_KIT)
        M = Matrix.Translation(p0) @ Matrix.Rotation(math.radians(a), 4, 'Z')
        Lc = (p1 - p0).length
        sx = -1 if e.dot(Matrix.Rotation(math.radians(a), 3, 'Z') @ Vector((1, 0, 0))) < 0 else 1
        lo_x, hi_x = (0, Lc) if sx > 0 else (-Lc, 0)
        box(PT, (lo_x, -26, 0), (hi_x, 0, 30), stein_ton, 'feldstein', M)
        box(PT, (lo_x, -24, 30), (hi_x, -2, TIEF_H - 6), putz_ton, 'putz', M)
        box(PT, (lo_x, -28, TIEF_H - 6), (hi_x, 2, TIEF_H), lambda p_, n_: sc(BALKEN_T, 0.75), 'balken', M)
    x = -Lk / 2
    for u, b, k in plan:
        if k in ('D', 'Z'):
            bruestung(x, u - b / 2 + (0.0 if k == 'Z' else 0.2)); x = u + b / 2 - (0.0 if k == 'Z' else 0.2)
    bruestung(x, Lk / 2)
    for u, b, k in plan:
        if k == 'W':   # Fensterbank auf dem Stumpf (alt 5h.1)
            p = mitte_l + e * (u * 100 * S_KIT)
            M = Matrix.Translation(p) @ Matrix.Rotation(math.radians(a), 4, 'Z')
            w = b * 100 * S_KIT * 0.42
            box(PT, (-w, 4, TIEF_H), (w, -30, TIEF_H + 5), lambda p_, n_: sc(lin(0xa88a64), 0.9), 'holz', M)
    # Tageslicht durch Fenster und Tuer (MapLight WINDOW 0,55 / DOOR 0,6, nur am Tag), nachts Mond
    for u, b, k in plan:
        if k not in ('W', 'D'): continue
        p = mitte_l + e * (u * 100 * S_KIT)
        aussen = p - n * 160 + Vector((0, 0, 260 if k == 'W' else 210))
        ziel = p + n * (1.4 * TS) + Vector((0, 0, 0))
        LICHTER.append(dict(art='tageslicht' if k == 'W' else 'tuer', pos=list(aussen), ziel=list(ziel), reich=2.6 if k == 'W' else 3.0,
                            kraft=0.55 if k == 'W' else 0.6, wand=hoch))
    # Wandschmuck (alt MapRoom.wallThing): auf glatten Stuecken der hohen Fassung, nicht ueber Hohem, im Tempel nichts
    if not TEMPEL:
        for i, (u, b, k) in enumerate(plan):
            if k != '#' or b < 1.0: continue
            p = mitte_l + e * (u * 100 * S_KIT)
            kz = [kk for kk in lauf if abs(u_von(kk['m']) - u) < 0.8]
            if any(ch(kk['c'], kk['r']) in HOCH_DINGE for kk in kz): continue
            wahl = hsh(int(p.x), int(p.y), 31) % 5
            wand_p = p + Vector((0, 0, 0))
            if wahl == 4 or (LADEN and wahl == 2):   # Pruefer Lauf 1: Kraeuterbuendel fehlten (Laden)
                kraeuter(PH, wand_p, n, e); continue
            ar = a + 180   # Front des Wandteils (-Y) in den Raum
            if SCHENKE:
                [lambda: stelle(PH, 'Shield_Wooden', wand_p, ar, 0.9, z=150, boden=False),
                 lambda: stelle(PH, 'Peg_Rack', wand_p, ar, 0.9, z=160, boden=False),
                 lambda: (stelle(PH, 'Shelf_Simple', wand_p, ar, 0.8, z=150, boden=False),
                          stelle(PH, 'Mug', wand_p + n * 14 - e * 25, ar, 1.0, z=159), stelle(PH, 'Vase_4', wand_p + n * 14 + e * 20, ar, 0.5, z=159)),
                 lambda: stelle(PH, 'Lantern_Wall', wand_p, ar, 0.5, z=120, boden=False)][wahl]()
            elif LADEN:
                [lambda: (stelle(PH, 'Peg_Rack', wand_p, ar, 0.9, z=160, boden=False), stelle(PH, 'Rope_1', wand_p + n * 6, ar - 90, (0.5, 0.5, 2.2), z=118)),
                 lambda: (stelle(PH, 'Shelf_Simple', wand_p, ar, 0.8, z=150, boden=False),
                          stelle(PH, 'Pot_1', wand_p + n * 14 - e * 20, ar, 0.45, z=159), stelle(PH, 'Bottle_1', wand_p + n * 14 + e * 25, ar, 0.8, z=159)),
                 lambda: stelle(PH, 'Shield_Wooden', wand_p, ar, 0.9, z=150, boden=False),
                 lambda: stelle(PH, 'Lantern_Wall', wand_p, ar, 0.5, z=120, boden=False)][wahl]()
            elif AELTESTER:
                [lambda: (stelle(PH, 'Shelf_Simple', wand_p, ar, 0.8, z=150, boden=False),
                          stelle(PH, 'Book_Stack_1', wand_p + n * 14 - e * 20, ar, 0.9, z=159), stelle(PH, 'Scroll_1', wand_p + n * 14 + e * 22, ar, 0.9, z=159)),
                 lambda: stelle(PH, 'Banner_2_Cloth', wand_p, ar, (0.5, 1, 0.45), z=230, boden=False),
                 lambda: stelle(PH, 'Shield_Wooden', wand_p, ar, 0.85, z=150, boden=False),
                 lambda: stelle(PH, 'Lantern_Wall', wand_p, ar, 0.5, z=120, boden=False)][wahl]()

# Kamin in der Wand (alt hearth, firebox): Mantel aus Feldstein ueber die Kamin-Kacheln bis unter die Decke, Feuerloch mit Russ,
# Herdplatte, Feuerboecke, zwei Scheite, Kessel an der Kette, Sims mit Kleinkram; die Flamme setzt raumlicht.gd (lichter „kamin“)
for s, zs, n, e, hoch, tief in HERDE:
    a = SEITEN[s][3]
    mm = sum((k['m'] for k in zs), Vector()) / len(zs)
    W_ = len(zs) * TS - 8
    PH, PT = part(hoch), part(tief)
    PK = part('Herd_' + stueck(zs[0]['c'], zs[0]['r']))
    M = Matrix.Translation(mm) @ Matrix.Rotation(math.radians(a + 180), 4, 'Z')   # lokal: x entlang, -y in den Raum
    mw = 58.0; mh = 88.0; tiefe = 46.0                # Feuerloch
    def russ(p, n_): return sc(RUSS, 0.6 + 0.6 * vn(p.x / 20, p.z / 20, 4))
    # Mantel (Brust) vor der Wand, mit dem Loch: links, rechts, Sturz; hinten Rueckwand und Seiten des Lochs in der Wand
    for Pn, h_ in ((PH, WAND_H), (PT, TIEF_H)):   # Pruefer Lauf 2: gedreht ragte der Mantel ueber die Bruestung
        box(Pn, (-W_ / 2, -34, 0), (-mw / 2, 0, h_), stein_ton, 'feldstein', M)
        box(Pn, (mw / 2, -34, 0), (W_ / 2, 0, h_), stein_ton, 'feldstein', M)
        if h_ > mh: box(Pn, (-mw / 2, -34, mh), (mw / 2, 0, h_), stein_ton, 'feldstein', M)
        box(Pn, (-W_ / 2 - 4, 0, 0), (W_ / 2 + 4, 40, h_), stein_ton, 'feldstein', M)   # in der Wandstaerke
    box(PH, (-W_ / 2 - 8, -46, 118), (W_ / 2 + 8, -26, 130), lambda p_, n_: sc(BALKEN_T, 0.8), 'balken', M)   # Sims
    box(PK, (-mw / 2, -34, 0), (mw / 2, 0, 1.5), russ, 'feldstein', M)                                       # Aschenbett
    box(PK, (-mw / 2 + 0.5, -2, 0), (mw / 2 - 0.5, 0.5, mh - 0.5), russ, 'weiss', M)                          # Rueckwand russig
    for sg in (-1, 1):
        box(PK, (min(sg * mw / 2, sg * (mw / 2 - 0.7)), -34, 0), (max(sg * mw / 2, sg * (mw / 2 - 0.7)), 0, mh), russ, 'weiss', M)
    box(PK, (-W_ / 2 - 10, -70, 0), (W_ / 2 + 10, -34, 4), lambda p_, n_: sc(STEIN, 0.75 + 0.2 * vn(p_.x / 25, p_.y / 25, 6)), 'feldstein', M)   # Herdplatte
    for sg in (-1, 1):   # Feuerboecke
        box(PK, (sg * 16 - 2, -28, 0), (sg * 16 + 2, -8, 14), lin(0x2a2622), 'weiss', M)
    for p0, p1 in (((-22, -12, 9), (20, -22, 5)), ((-18, -24, 5), (22, -10, 10))):   # zwei Scheite, gekreuzt
        P0 = M @ Vector(p0); P1 = M @ Vector(p1)
        zylinder(PK, P0, 5, (P1 - P0).length, 7, lambda p_, n_: sc(lin(0x2a1a10), 0.7 + 0.5 * vn(p_.x / 8, p_.z / 8, 2)), 'weiss', achse=P1 - P0)
    kp = M @ Vector((0, -18, 40))
    box(PK, (kp.x - 0.6, kp.y - 0.6, 44), (kp.x + 0.6, kp.y + 0.6, mh), lin(0x2a2622), 'weiss')   # Kette
    stelle(PK, 'Pot_1_Lid', kp, a, 0.5, z=0)
    # auf dem Sims (alt: ein paar Dinge, manchmal eine Kerze)
    sims = [M @ Vector((x_, -36, 130)) for x_ in (-W_ / 2 + 14, -W_ / 4, W_ / 4, W_ / 2 - 14)]
    stelle(PH, 'Mug', sims[0], a, 1.0, z=0)
    stelle(PH, 'Vase_4', sims[2], a, 0.45, z=0)
    if hsh(zs[0]['c'], zs[0]['r'], 61) % 3 == 1:
        f = leuchter(PH, sims[3], a)
        kerze_licht(f + Vector((0, 0, 10)), 1.4, 0.4, [f], 'kerze', wand=hoch)   # Lauf 2: gedreht brannte die Flamme frei
    else: stelle(PH, 'Book_Stack_2', sims[3], a, 0.8, z=0)
    feuer = M @ Vector((0, -18, 18))
    LICHTER.append(dict(art='kamin', pos=list(M @ Vector((0, -70, 55))), reich=3.6, kraft=1.05, flammen=[list(feuer)], breite=mw * 0.7,
                        wand=hoch))   # Pruefer Lauf 3: gedreht ragte der Feuerkasten ueber die Bruestung; Herd, Feuer, Licht gehen mit der Wand
    HERD_VON[hoch] = 'Herd_' + stueck(zs[0]['c'], zs[0]['r'])

# ---------------------------------------------------------------- Einrichtung (MapRoomIso.objects je Zeichen)
def wand_teil(c, r, s, sonst):
    """Hohes an der Wand (Regal, Gestell, Wandtuch) gehoert zur hohen Fassung seiner Wand: steht die Wand vorn (tief), ist es mit ihr
    weg wie alt 5h.1 (Pruefer Lauf 1: gedreht zeigten Regale an der Vorderwand ihre Rueckseite ueber der Bruestung)"""
    return part(WAND_VON[(c, r, s)]) if (c, r, s) in WAND_VON else part(sonst)
def weg_von_wand(c, r, p, d=18.0):
    """p um d cm von jeder angrenzenden Wand weg (Wandstaerke und Eckbalken ragen in die Kachel; Pruefer Lauf 3), ebenso von Theke
    und Altar daneben; zwischen Wand und Theke bleibt es in der Mitte (Pruefer Lauf 6: Fass in der Ladentheke)"""
    for s in 'NWOS':
        dd, _, n, a, e = SEITEN[s]
        if ch(c + dd[0], r + dd[1]) in WAENDE or ch(c + dd[0], r + dd[1]) in 'KA': p = p + n * d
    return p
def an_wand(c, r):
    """Richtung in den Raum (Blender) von der naechsten Wand: N, W, O, S der Reihe nach"""
    for s in 'NWOS':
        d, _, n, a, e = SEITEN[s]
        if ch(c + d[0], r + d[1]) in WAENDE: return n, s
    return Vector((0, -1, 0)), None
def dreh(n):
    """Drehung, die die Front des Bausatzes (-Y) nach n wendet"""
    return math.degrees(math.atan2(n.x, -n.y))
def lauf_x(c, r, z):
    c0 = c
    while ch(c0 - 1, r) == z: c0 -= 1
    c1 = c
    while ch(c1 + 1, r) == z: c1 += 1
    return c0, c1
def lauf_y(c, r, z):
    r0 = r
    while ch(c, r0 - 1) == z: r0 -= 1
    r1 = r
    while ch(c, r1 + 1) == z: r1 += 1
    return r0, r1
herd_naehe = any(ch(c, r) == 'Z' for r in range(NR) for c in range(NC))
erledigt = set()

def theke(c, r):
    c0, c1 = lauf_x(c, r, 'K')
    if c != c0: return
    P = part('Ding_' + stueck((c0 + c1) / 2, r))
    x0, x1 = tx(c0) + (0 if not drin(c0 - 1, r) else 6), tx(c1 + 1) - (0 if not drin(c1 + 1, r) else 6)
    yc = ty(r) - TS / 2
    # Front zum Gastraum (Sueden), Bretter mit Fugen, ein dunklerer Streifen, wo Haende ruhen, ausgetretener Fuss (alt counter)
    def front(p, n_): return sc(HOLZ, (0.7 + 0.25 * vn(p.x / 9, 0, 5)) * (0.75 if p.z < 12 else 1.0) * (0.85 if p.z > 86 else 1.0))
    box(P, (x0, yc - 30, 0), (x1, yc + 26, 98), front, 'holz')
    for x in range(int(x0) + 16, int(x1) - 4, 19):
        box(P, (x - 1.2, yc - 31, 8), (x + 1.2, yc - 30, 92), lin(0x3a2a1c), 'weiss')
    # Platte Eiche wie alt oakTop (Pruefer Lauf 1: mit Balkenbild und dunklem Ton schwarz)
    box(P, (x0 - 3, yc - 36, 98), (x1 + 3, yc + 30, 105), lambda p, n_: sc(lin(0xa07a54), 0.85 + 0.2 * vn(p.x / 30, p.y / 30, 7)), 'holz')
    box(P, (x0, yc - 33, 0), (x1, yc - 30, 10), lin(0x3a2a1c), 'holz')
    for i, cc in enumerate(range(c0, c1 + 1)):
        p = Vector((tx(cc) + TS / 2, yc - 4, 105))
        w = hsh(cc, r, 2) % 3
        if LADEN:   # alt shopTop: Waage mit Muenzen, Kontobuch mit Feder, Tuchballen mit Schere; je Feld ein Kerzenstumpf
            [lambda: (waage(P, p + Vector((-6, -12, 0))), stelle(P, 'Coin_Pile', p + Vector((42, -20, 0)), 20)),
             lambda: (stelle(P, 'Book_5', p + Vector((-16, 0, 0)), 15), stelle(P, 'Scroll_2', p + Vector((18, 8, 0)), 70)),
             lambda: (tuchballen(P, p + Vector((-12, 4, 0)), hsh(cc, r, 5)), stelle(P, 'Pouch_Large', p + Vector((24, -2, 0)), -30))][w]()
        else:
            [lambda: (stelle(P, 'Mug', p + Vector((-20, 0, 0)), 30), stelle(P, 'Mug', p + Vector((14, 8, 0)), 160)),
             lambda: (stelle(P, 'Bottle_1', p + Vector((-16, 6, 0)), 0), stelle(P, 'Mug', p + Vector((18, -4, 0)), 80)),
             lambda: (stelle(P, 'SmallBottles_1', p + Vector((-10, 8, 0)), 10), stelle(P, 'Table_Plate', p + Vector((18, -2, 0)), 0, 0.8))][w]()
        # alt counter: auf jedem Feld eine Kerze (Pruefer Lauf 1: alt etwa sechs, neu eine), dazu ein Stumpf; Licht je Feld wie
        # MapLight COUNTER
        if LADEN:   # Pruefer Lauf 2: Kerze steckte in der Waage; Kerzen hinten, Waage und Ware vorn
            f = leuchter(P, p + Vector((32, 20, 0)), 0); g = stumpf(P, p + Vector((-34, 24, 0)), 6 + hsh(cc, r, 9) % 6)
        else:
            f = leuchter(P, p + Vector((30 if i % 2 else -30, 16, 0)), 0)
            g = stumpf(P, p + Vector((-4, 20, 0)), 6 + hsh(cc, r, 9) % 6)
        kerze_licht(p + Vector((0, 0, 40)), 1.5 if herd_naehe else 2.4, 0.5 if herd_naehe else 0.45, [f, g])

def tisch(c, r):
    c0, c1 = lauf_x(c, r, 'Y')
    if c != c0: return
    P = part('Ding_' + stueck((c0 + c1) / 2, r))
    L = (c1 - c0 + 1) * TS - 14
    ms = masse('Table_Large')
    pm = Vector(((tx(c0) + tx(c1 + 1)) / 2, ty(r) - TS / 2, 0))
    stelle(P, 'Table_Large', pm, 0, (L / ms.x, 84 / ms.y, 76 / ms.z), ton=(0.9, 0.85, 0.8))
    oben = 76.0
    for cc in range(c0, c1 + 1):   # je Platz Geschirr; mal ein umgekippter Krug, Wuerfel und Muenzen (alt table)
        p = Vector((tx(cc) + TS / 2, ty(r) - TS / 2, oben))
        w = hsh(cc, r, 4) % 4
        stelle(P, 'Table_Plate', p + Vector((-18, -16, 0)), 0, 0.75)
        stelle(P, 'Table_Knife', p + Vector((-2, -16, 0)), 0, 0.75)
        if w == 0: stelle(P, 'Mug', p + Vector((14, 10, 0)), 40); stelle(P, 'Bottle_1', p + Vector((26, -8, 0)), 0, 0.8)
        elif w == 1: stelle(P, 'Mug', p + Vector((16, -6, 0)), 120); stelle(P, 'Coin_Pile', p + Vector((-10, 18, 0)), 10)
        elif w == 2: stelle(P, 'Table_Plate', p + Vector((20, 14, 0)), 0, 0.75); stelle(P, 'Table_Spoon', p + Vector((32, 14, 0)), 0, 0.75)
        else: stelle(P, 'Mug', p + Vector((10, 12, 0)), 200); stelle(P, 'Coin', p + Vector((-24, 14, 0)), 70)
    f = leuchter(P, pm + Vector((0, 8, oben)), 0)
    kerze_licht(pm + Vector((0, 0, oben + 18)), 1.7 if herd_naehe else 2.8, 0.62 if herd_naehe else 0.6, [f])   # Lauf 3: tiefer, Insel am Boden

def bank(c, r):
    c0, c1 = lauf_x(c, r, 'n')
    if c != c0: return
    P = part('Ding_' + stueck((c0 + c1) / 2, r))
    L = (c1 - c0 + 1) * TS - 10
    ms = masse('Bench')
    pm = Vector(((tx(c0) + tx(c1 + 1)) / 2, ty(r) - TS / 2, 0))
    stelle(P, 'Bench', pm, 0, (L / ms.x, 1.0, 0.85), ton=(1.3, 1.3, 1.3))   # Pruefer Lauf 6: nachts fast schwarz
    # Lehne auf der Seite vom Tisch bzw. Altar weg (alt bench back; Pruefer Lauf 1: in der Schenke fehlte sie). Tisch im Norden
    # (Blender +y): Lehne im Sueden, sonst im Norden
    tisch_n = any(ch(cc, r - 1) in 'YA' for cc in range(c0, c1 + 1)) or TEMPEL
    sg_y = -1 if tisch_n else 1
    y_l = pm.y + sg_y * 20
    # Pruefer Lauf 2: Lehne mit DUNKEL fast schwarz, Sitz stach durch die Wangen: Eiche wie die Bank, Wangen aussen am Sitz
    eiche = lambda p, n_: sc(lin(0xb08a60), 0.85 + 0.2 * vn(p.x / 30, p.z / 30, 3))   # Lauf 3: Lehne im Gegenlicht fast schwarz
    box(P, (pm.x - L / 2 + 2, min(y_l, y_l + sg_y * 5), 40), (pm.x + L / 2 - 2, max(y_l, y_l + sg_y * 5), 72), eiche, 'holz')
    for sg in (-1, 1):
        xw = pm.x + sg * (L / 2 + 1)
        box(P, (xw - 3, min(pm.y - sg_y * 20, y_l + sg_y * 7), 0), (xw + 3, max(pm.y - sg_y * 20, y_l + sg_y * 7), 76), eiche, 'holz')

def bett(c, r):
    if (c, r) in erledigt: return
    c0, c1 = lauf_x(c, r, 'B'); r0, r1 = lauf_y(c, r, 'B')
    for cc in range(c0, c1 + 1):
        for rr in range(r0, r1 + 1): erledigt.add((cc, rr))
    P = part('Ding_' + stueck((c0 + c1) / 2, (r0 + r1) / 2))
    w = (c1 - c0 + 1) * TS - 12; d = (r1 - r0 + 1) * TS - 12
    pm = Vector(((tx(c0) + tx(c1 + 1)) / 2, (ty(r0) + ty(r1 + 1)) / 2, 0))
    pm = weg_von_wand(c0, r0, pm, 10.0)   # Pruefer Lauf 3: Kopfteil lag in der Wand
    kopf_n = not drin(c0, r0 - 1)                    # Kopf an der Wand (Bausatz: Kopf bei +Y)
    ms = masse('Bed_Twin1')
    if d >= w:
        a = 0 if kopf_n else 180
        stelle(P, 'Bed_Twin1' if hsh(c0, r0, 4) % 2 else 'Bed_Twin2', pm, a, (w / ms.x, d / ms.y, 0.85), ton=(0.95, 0.9, 0.9))
    else:
        stelle(P, 'Bed_Twin1', pm, 90 if not drin(c1 + 1, r0) else -90, (d / ms.x, w / ms.y, 0.85))
    fuss = pm + Vector((w / 2 - 20, -d / 2 + 14, 0)) if kopf_n else pm + Vector((w / 2 - 20, d / 2 - 14, 0))
    if drin(c1 + 1, r1): stelle(P, 'Bag', fuss + Vector((26, 0, 0)), 70, 0.35)   # ein Beutel am Fussende (alt bed)
    if AELTESTER and kopf_n: himmel(wand_teil(c0, r0, 'N', 'Ding_' + stueck(c0, r0)), pm, w, d)

def himmel(P, pm, w, d):
    """Halber Betthimmel des Aeltesten (alt elderBed 13q.7): zwei hohe Pfosten am Kopfende, ein Rahmen ein Drittel ueber das Bett,
    Tuch darueber, hinten ein Vorhang bis zum Kopfbrett, seitlich Vorhaenge an die Pfosten gebunden (Pruefer Lauf 1: fehlte)"""
    rot = lambda q, n_: sc(lin(0x7a2a24), 0.8 + 0.3 * vn(q.x / 12, q.z / 25 + q.y / 25, 21))
    yk = pm.y + d / 2 - 4; yv = yk - d / 3; H = 214.0
    for sg in (-1, 1):
        x = pm.x + sg * (w / 2 - 4)
        box(P, (x - 5, yk - 5, 0), (x + 5, yk + 5, H + 8), lambda q, n_: sc(HOLZ, 0.8 + 0.2 * vn(q.z / 30, 0, 3)), 'holz')   # Lauf 2: unsichtbar
        box(P, (x - 3, yv - 3, H - 6), (x + 3, yk, H), DUNKEL, 'holz')                              # Rahmen seitlich
        # Vorhang, an den Pfosten gebunden: oben breit, unter der Schleife schmal, unten wieder etwas breiter
        for z0, z1, b in ((H - 6, 150, 22), (150, 132, 7), (132, 60, 15)):
            box(P, (min(x, x - sg * b), yk - 10, z1), (max(x, x - sg * b), yk - 2, z0), rot, 'stoff')
    box(P, (pm.x - w / 2, yv - 3, H - 6), (pm.x + w / 2, yv + 3, H), DUNKEL, 'holz')                # Rahmen vorn
    box(P, (pm.x - w / 2 - 2, yv - 4, H), (pm.x + w / 2 + 2, yk + 4, H + 3), rot, 'stoff')           # Tuch oben
    for k in range(int(w // 24)):                                                                      # Volant vorn
        x = pm.x - w / 2 + 12 + k * 24
        box(P, (x - 11, yv - 6, H - 22 - 4 * (k % 2)), (x + 11, yv - 3, H + 3), rot, 'stoff')
    box(P, (pm.x - w / 2, yk, 80), (pm.x + w / 2, yk + 3, H), rot, 'stoff')                           # Vorhang hinten

def regal(c, r):
    c0, c1 = lauf_x(c, r, 'Q')
    if c != c0: return
    n, s = an_wand(c, r)
    P = wand_teil(c0, r, s, 'Ding_' + stueck((c0 + c1) / 2, r))
    a = dreh(n)
    L = (c1 - c0 + 1) * TS - 8
    pm = Vector(((tx(c0) + tx(c1 + 1)) / 2, ty(r) - TS / 2, 0))
    wand = pm - n * (TS / 2)
    # alle Raeume ein hohes Regal je 1,5 m (alt goodsShelf, bookshelf, shelf): Laden Waren, Aeltester Buecher, Schenke Kruege und
    # Flaschen (Pruefer Lauf 1: alt hohes Regal mit vier, fuenf Brettern voller Kruege und Flaschen, neu nur ein Schrank)
    k = max(1, round(L / 150)); ms = masse('Bookcase_2'); bw = L / k
    hz = bretter_hoehen('Bookcase_2')
    # Pruefer Lauf 7: das Regal verdeckte das Fenster halb (Laden): liegt ein Fenster hinter dem Regal, je Kachel ein Regal und das
    # vor dem Fenster nur bis unter die Fensterbank
    dd = SEITEN[s][0] if s else (0, 0)
    fenster = [ch(cc + dd[0], r + dd[1]) == 'W' for cc in range(c0, c1 + 1)] if abs(n.y) > 0.5 else []
    if any(fenster): k = c1 - c0 + 1; bw = L / k
    for i in range(k):
        q = wand + n * (ms.y / 2 + 2) + Vector((-L / 2 + bw * (i + 0.5), 0, 0)) * (1 if abs(n.y) > 0.5 else 0)
        nieder = bool(fenster) and fenster[i]
        sx = (bw - 4) / ms.x; szz = (100 if nieder else 215) / ms.z
        stelle(P, 'Bookcase_2', q, a, (sx, 0.9, szz), ton=(0.85, 0.8, 0.78))
        for j, h in enumerate(hz):
            if nieder and h * szz > 70: continue
            nt = 3 if AELTESTER else 4   # Laden, Schenke: dicht wie alt (Pruefer Lauf 1: leer; Lauf 2: fuenf kleine wie Schlieren)
            for t in range(nt):
                x_ = -bw / 2 + 20 + t * (bw - 40) / (nt - 1)
                p = q + Vector((x_, 0, h * szz)) if abs(n.y) > 0.5 else q + Vector((0, x_, h * szz))
                w = hsh(i * 7 + t, j, 12) % 8
                if AELTESTER: stelle(P, ['BookGroup_Small_1', 'BookGroup_Small_2', 'BookGroup_Small_3', 'Book_Stack_1', 'BookGroup_Small_2', 'Scroll_2', 'BookGroup_Medium_1', 'Book_Stack_2'][w], p, a, 0.85)
                elif SCHENKE: stelle(P, ['Mug', 'Bottle_1', 'SmallBottles_1', 'Vase_4', 'Bottle_1', 'Mug', 'SmallBottle', 'Bottle_1'][w], p, a,
                                     [1.0, 1.0, 1.1, 0.5, 1.0, 1.0, 1.4, 1.0][w])
                elif w == 6: tuchballen(P, p + n * 4, i + t + j, schere=False)   # Tuchballen (alt bolts of cloth)
                else: stelle(P, ['Potion_2', 'Vase_4', 'Bottle_1', 'Pouch_Large', 'Bag', 'Pot_1', '', 'Crate_Wooden'][w], p, a,
                             [1.2, 0.6, 1.2, 1.2, 0.32, 0.6, 1.0, 0.3][w], farbe=lin(0x9a7a58))

def gestell(c, r):
    n, s = an_wand(c, r); a = dreh(n)
    P = wand_teil(c, r, s, 'Ding_' + stueck(c, r))
    ms = masse('WeaponStand')
    sk = (TS - 14) / ms.x
    p = mitte(c, r) - n * (TS / 2 - ms.y * sk / 2 - 4)
    stelle(P, 'WeaponStand', p, a, sk, ton=(0.85, 0.8, 0.78))
    for i, w in enumerate(('Sword_Bronze', 'Axe_Bronze', 'Sword_Bronze')):
        stelle(P, w, p + Vector((-30 + 30 * i, 0, 0)) if abs(n.y) > 0.5 else p + Vector((0, -30 + 30 * i, 0)), a + 90, 0.9, z=8)

def kram(c, r):
    P = part('Ding_' + stueck(c, r))
    p = weg_von_wand(c, r, mitte(c, r)) + Vector(((hsh(c, r, 5) % 20) - 10, (hsh(c, r, 6) % 20) - 10, 0))
    a = hsh(c, r, 7) % 360
    if AELTESTER:   # ein Wanderstock an der Wand
        n, s = an_wand(c, r)
        q = mitte(c, r) - n * (TS / 2 - 24)
        zylinder(P, q, 2.2, 150, 6, lambda p_, n_: sc(DUNKEL, 0.9), 'holz', achse=Vector((-0.14 * n.x, -0.14 * n.y, 1)))
        return
    am_feuer = any(ch(c + dx, r + dy) == 'Z' for dx in (-1, 0, 1) for dy in (-1, 0))
    am_tisch = any(ch(c + dx, r) == 'Y' for dx in (-1, 1))
    if LADEN: art = [1, 1, 2, 4][hsh(c, r, 56) % 4]
    elif am_feuer: art = 0
    elif am_tisch: art = 3
    else: art = [1, 2, 4, 5][hsh(c, r, 56) % 4]
    if art == 0:   # Brennholz, gestapelt, die Schnittflaechen hell (alt firewood)
        for i in range(3):
            for j in range(3 - i):
                q = p + Vector((-24, -14 + j * 13 + i * 6.5, 6 + i * 11))
                zylinder(P, q, 6, 48, 7, lambda p_, n_: sc(lin(0xc8a878), 0.9) if abs(n_.x) > 0.8 else sc(lin(0x5a4030), 0.8 + 0.3 * vn(p_.y / 6, p_.z / 6, 3)), 'holz', achse=Vector((1, 0, 0)))
    elif art == 1: stelle(P, 'Bag', p, a, 0.45)
    elif art == 2: stelle(P, 'FarmCrate_Apple' if LADEN else 'Bucket_Wooden_1', p, a, 0.9)
    elif art == 3: stelle(P, 'Stool', p, a, 0.85)
    elif art == 4: stelle(P, 'Bucket_Wooden_1', p, a, 0.9)
    else: stelle(P, 'Vase_2', p, a, 0.55)

def fass(c, r):
    P = part('Ding_' + stueck(c, r))
    n_w, s_w = an_wand(c, r)
    p = weg_von_wand(c, r, mitte(c, r))   # Pruefer Lauf 2, 3: Fass steckte im Eckbalken
    w = hsh(c, r, 3) % 3
    stelle(P, 'Barrel_Apples' if (LADEN and w == 0) else 'Barrel', p, hsh(c, r, 8) % 360, 0.85, ton=[(0.95, 0.9, 0.85), (0.8, 0.75, 0.7), (1.0, 1.0, 1.0)][w])
    if w == 1 and not LADEN: stelle(P, 'Mug', p + Vector((8, -6, 0)), 30, 1.0, z=77)

def kisten(c, r):
    P = part('Ding_' + stueck(c, r))
    p = weg_von_wand(c, r, mitte(c, r), 24.0)
    if LADEN:   # Ware (alt produce)
        stelle(P, 'FarmCrate_Carrot', p + Vector((-8, 10, 0)), 10, 0.85)
        stelle(P, 'FarmCrate_Apple', p + Vector((10, -18, 0)), -8, 0.85)
        return
    stelle(P, 'Crate_Wooden', p + Vector((-10, 6, 0)), hsh(c, r, 3) % 30 - 15, 0.62, ton=(0.9, 0.85, 0.8))
    stelle(P, 'Crate_Wooden', p + Vector((22, -22, 0)), 20 + hsh(c, r, 4) % 30, 0.45, ton=(0.8, 0.75, 0.72))
    if hsh(c, r, 5) % 2: stelle(P, 'Crate_Wooden', p + Vector((-10, 6, 0)), 35, 0.4, z=masse('Crate_Wooden').z * 0.62)

def truhe(c, r):
    P = part('Ding_' + stueck(c, r))
    n, s = an_wand(c, r); a = dreh(n)
    ms = masse('Chest_Wood')
    sk = 80 / ms.x
    # Lauf 3: ragte in die Wand; Lauf 7: der offene Deckel kippt nach hinten und lag in der Mauerkante (Aeltester vorn rechts)
    p = weg_von_wand(c, r, mitte(c, r) - n * (TS / 2 - ms.y * sk / 2 - 6), 34.0)
    stelle(P, 'Chest_Wood', p, a, sk, farbe=lin(0xa07a50))   # Pruefer Lauf 1: ohne Bild des Bausatzes weiss
    # kein Leuchter mehr auf der Truhe: der Deckel des Bausatzes steht offen, die Kerze stand auf seiner Kante (Pruefer Lauf 3)

def lehnstuhl(c, r):
    P = part('Ding_' + stueck(c, r))
    p = mitte(c, r)
    zz = [mitte(cc, rr) for rr in range(NR) for cc in range(NC) if ch(cc, rr) == 'Z']
    if zz:   # zum Feuer gewandt
        f = sum(zz, Vector()) / len(zz); d = (f - p); d.z = 0
        a = dreh(d.normalized())
    else: a = dreh(an_wand(c, r)[0])
    stelle(P, 'Chair_1', p, a, 0.95, ton=(0.9, 0.82, 0.8))

def pult(c, r):
    P = part('Ding_' + stueck(c, r))
    n, s = an_wand(c, r); a = dreh(n)
    p = mitte(c, r)
    if TEMPEL:   # Lesepult mit offenem Buch (alt lectern); Pruefer Lauf 1: stand an der Bank, jetzt um eine halbe Kachel zum Altar
        if any(ch(c + dx, r + 1) == 'n' for dx in (-1, 0, 1)): p = p + Vector((0, 0.08 * TS, 0))   # Lauf 2: 0,45 stach in den Altar
        stelle(P, 'BookStand', p, a + 180, 0.75, ton=(0.85, 0.8, 0.78))   # Lauf 3: beruehrte Altar und Bank
        f = leuchter(P, p + Vector((34, 20, 0)), 0, hoch=24)
        kerze_licht(f + Vector((0, 0, 20)), 1.8, 0.6, [f])
        return
    ms = masse('Table_Large')   # Schreibtisch mit Buch, Schriftrolle, Leuchter (alt desk)
    stelle(P, 'Table_Large', p, a, (96 / ms.x, 56 / ms.y, 76 / ms.z), ton=(0.8, 0.75, 0.72))
    stelle(P, 'Book_7', p + Vector((-12, 0, 76)), a + 10, 1.0)
    stelle(P, 'Scroll_1', p + Vector((22, -10, 76)), a + 40, 1.0)
    f = leuchter(P, p + Vector((30, 12, 76)), 0)
    kerze_licht(f + Vector((0, 0, 20)), 1.8, 0.6, [f])

def wandtuch(c, r):
    n, s = an_wand(c, r)
    P = wand_teil(c, r, s, 'Ding_' + stueck(c, r))
    p = mitte(c, r) - n * (TS / 2 - 3)
    stelle(P, 'Banner_1_Cloth', p, dreh(n), (0.85, 1.0, 0.8), z=232, boden=False, ton=(0.55, 0.65, 0.95))

def altar(c, r):
    c0, c1 = lauf_x(c, r, 'A')
    if c != c0: return
    n_a, s_a = an_wand(c, r)
    # Pruefer Lauf 7: gedreht fehlte der ganze Altar; jetzt bleibt er stehen, nur die hohe Sonne auf ihrem Staender geht mit der Wand
    # (Lauf 3: gedreht ragte sie ueber die Bruestung)
    P = part('Ding_' + stueck((c0 + c1) / 2, r))
    PS = wand_teil(c0, r, s_a, 'Ding_' + stueck((c0 + c1) / 2, r))
    x0, x1 = tx(c0) + 6, tx(c1 + 1) - 6
    yc = ty(r) - TS / 2
    def quader(p, n_):   # Werkstein, Fugen alle 30 cm (alt ashlar)
        fuge = (abs(math.sin(p.x / 30 * math.pi)) < 0.06) or (abs(math.sin(p.z / 24 * math.pi)) < 0.08)
        return sc(GRAU, (0.62 if fuge else 0.88 + 0.12 * vn(p.x / 30, p.z / 30, 9)))
    box(P, (x0 + 8, yc - 34, 0), (x1 - 8, yc + 30, 90), quader, 'feldstein')
    box(P, (x0, yc - 40, 90), (x1, yc + 36, 100), quader, 'feldstein')
    box(P, (x0 + 30, yc - 42, 60), (x1 - 30, yc - 40, 101), lin(0xf4eee0), 'stoff')      # Tuch ueber die Front
    box(P, (x0 + 30, yc - 40, 100), (x1 - 30, yc + 30, 101.5), lin(0xf4eee0), 'stoff')
    box(P, ((x0 + x1) / 2 - 14, yc - 42.5, 66), ((x0 + x1) / 2 + 14, yc - 42, 96), GOLD, 'weiss')  # goldenes Zeichen auf dem Tuch
    fl = []
    kf, klo, khi = kit_lesen(PDIR, 'CandleStick_Triple')
    for x_ in (x0 + 26, x1 - 26):
        stelle(P, 'CandleStick_Triple', Vector((x_, yc + 4, 101.5)), 0, 0.9)
        fl += [Vector((x_ + x * 90, yc + 4 + y * 90, 101.5 + (z - klo.z) * 90 + 2)) for x, y, z in dochte(kf, klo, khi)]
    stelle(P, 'Chalice', Vector(((x0 + x1) / 2, yc - 14, 101.5)), 0, 1.0)
    # die Sonne des Morgenlichts auf ihrem Staender hinten in der Mitte (alt altar; Pruefer Lauf 1: fehlte)
    sm = Vector(((x0 + x1) / 2, yc + 22, 101.5))
    zylinder(PS, sm, 7, 2, 10, MESSING, 'weiss', r2=5)
    zylinder(PS, sm, 2.0, 40, 6, MESSING, 'weiss')
    sz = sm + Vector((0, 1, 62))   # Pruefer Lauf 2: viel kleiner als alt; Scheibe 40 cm mit Strahlen
    zylinder(PS, sz, 20, 3.0, 24, lin(0xc9a24a), 'weiss', achse=Vector((0, -1, 0)))
    zylinder(PS, sz + Vector((0, -3, 0)), 9, 1.5, 18, lin(0xe8c870), 'weiss', achse=Vector((0, -1, 0)))
    for k in range(12):
        an = k * math.pi / 6; rv = Vector((math.cos(an), 0, math.sin(an)))
        zylinder(PS, sz + rv * 19 + Vector((0, -1.5, 0)), 2.6, 12 if k % 2 else 18, 4, lin(0xc9a24a), 'weiss', r2=0.4, achse=rv)
    stelle(P, 'Book_7', Vector(((x0 + x1) / 2 + 40, yc - 6, 101.5)), 15, 1.0)
    kerze_licht(Vector(((x0 + x1) / 2, yc - 30, 150)), 3.2, 0.75, fl)

def kerzen(c, r):
    P = part('Ding_' + stueck(c, r))
    p = mitte(c, r)
    stelle(P, 'CandleStick_Stand', p, 0, 0.9)
    fl, lo, hi = kit_lesen(PDIR, 'CandleStick_Stand')
    spitzen = dochte(fl, lo, hi)
    f = [p + Vector((x * 90, y * 90, (z - lo.z) * 90 + 2)) for x, y, z in spitzen] or [p + Vector((0, 0, 125))]
    kerze_licht(p + Vector((0, 0, 140)), 2.2, 0.7, f)

def dochte(fl, lo, hi):
    """Kerzenspitzen eines Leuchters: hoechste Punkte des Wachses (Material Props), nach Ort zusammengefasst (Bausatz-m)"""
    pts = [p for f in fl if 'Props' in f[3] for p in f[0]]
    if not pts: return []
    oben = max(p.z for p in pts)
    gruppen = []
    for p in sorted(pts, key=lambda q: -q.z):
        if p.z < oben - 0.12: break
        g = next((g for g in gruppen if (g[0] - p.x) ** 2 + (g[1] - p.y) ** 2 < 0.03 ** 2), None)
        if g is None: gruppen.append([p.x, p.y, p.z])
    return gruppen[:9]

def weihwasser(c, r):
    P = part('Ding_' + stueck(c, r))
    p = mitte(c, r)
    def st(p_, n_): return sc(lin(0xc8c0b0), 0.8 + 0.2 * vn(p_.x / 20, p_.z / 20, 4))
    zylinder(P, p, 22, 12, 10, st, 'feldstein', r2=16)
    zylinder(P, p + Vector((0, 0, 12)), 12, 58, 10, st, 'feldstein', r2=10)
    zylinder(P, p + Vector((0, 0, 70)), 14, 18, 12, st, 'feldstein', r2=34, deckel=False)
    zylinder(P, p + Vector((0, 0, 70)), 14, 0.5, 12, st, 'feldstein')
    zylinder(P, p + Vector((0, 0, 84)), 30, 0.4, 12, lin(0x8aa4b0), 'weiss')        # Wasser, hell spiegelnd (Pruefer Lauf 1: schwarz)
    if hsh(c, r, 3) % 3 == 2:   # eine Kerze schwimmt (alt font smallFlame)
        f = p + Vector((8, 4, 92))
        zylinder(P, p + Vector((8, 4, 84)), 3, 6, 8, lin(0xf0e6c8), 'weiss')
        kerze_licht(f + Vector((0, 0, 14)), 1.5, 0.45, [f])

MOEBEL = {'K': theke, 'Y': tisch, 'n': bank, 'B': bett, 'Q': regal, 'U': gestell, 'J': kram, 'b': fass, 'u': kisten, 'a': truhe,
          's': lehnstuhl, 'd': pult, 'V': wandtuch, 'A': altar, 'N': kerzen, '&': weihwasser}
for r in range(NR):
    for c in range(NC):
        z = ch(c, r)
        if z in MOEBEL: MOEBEL[z](c, r)
if SCHENKE and ch(8, 4) == 'k':   # Borins Hocker und sein Hammer an der Tischkante (alt 55.2)
    P = part('Ding_' + stueck(8, 4))
    p = mitte(8, 4)
    stelle(P, 'Stool', p + Vector((0, 4, 0)), 0, 0.9)
    q0 = p + Vector((-44, -30, 0)); q1 = p + Vector((-52, -6, 70))
    zylinder(P, q0, 2.5, (q1 - q0).length, 6, lambda p_, n_: sc(DUNKEL, 0.9), 'holz', achse=q1 - q0)
    box(P, (q0.x - 10, q0.y - 7, 0), (q0.x + 10, q0.y + 7, 13), lin(0x4a4a4e), 'weiss')
print('LICHTER', len(LICHTER), 'TEILE', len(PARTS), 'BAUSATZ', len(KITC))

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
DREIECKE = 0
def build(P, name):
    global DREIECKE
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
    if 'breite' in l: q['breite'] = l['breite'] * 0.01
    lichter.append(q)
for w in WANDLISTE:
    if w['hoch'] in HERD_VON: w['herd'] = HERD_VON[w['hoch']]
info = dict(kachel_m=TS / 100.0, spalten=NC, zeilen=NR, ursprung=dict(spalte=0, zeile=0), begehbar=walk, karte=ROWS, innen=True,
            lichter=lichter, waende=WANDLISTE,
            hinweis='Meter; Blender: x = Spalte * Kachel, y = -Zeile * Kachel; in glTF/Godot: x gleich, z = +Zeile * Kachel')
json.dump(info, open(os.path.join(OUT, ID + '-info.json'), 'w'), indent=0)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, ID + '.glb'), export_format='GLB', use_selection=True, export_vertex_color='ACTIVE',
                          export_yup=True, export_image_format='JPEG', export_jpeg_quality=88)
print('GLB OK', ID, os.path.getsize(os.path.join(OUT, ID + '.glb')))
