# 417 Messung 3d (Pruefer 01.11., 13:3x: Schwert durch Schild, Schild vor dem Gesicht, Bogen im Becken): wo die Pakete ihre Waffe in
# der Hand fuehren, als Rahmen der Hand, den Godot nachbaut (tragen.gd GRIFF). Lage der Props aus den Unity-Prefabs (griff417.py,
# Lauf 41309203353): Knochen, Lage (m), Drehung (x, y, z, w) im Raum des Unity-Knochens. Unity spiegelt FBX an X; hier beide Fassungen
# (gespiegelt, wie gelesen) mit Pruefung: beim Zweihaender muss die linke Faust auf der Griffachse liegen, beim Einhaender die rechte.
# Lauf 41310185397: die Bewegungs-FBX haben andere Knochenachsen als die Figur, an der Unity die Props haengt (SK_Protof-Actor.fbx);
# darum die Lage zuerst an der Figur in Ruhe in den Rahmen ihrer Hand, dann in den Rahmen der Hand je Bild der Bewegung.
# Rahmen der Hand wie zauber385.py (x: Handgelenk -> Mittelfinger, z: x kreuz (Kleinfinger -> Zeigefinger), y: z kreuz x; Ursprung am
# Handgelenk, Laengen durch die Handlaenge), damit gleicht die Uebertragung die Hand Quelle -> Ziel ab.
# Aufruf: KAUF=<kaufpakete> bl/bin/python -I griff417b.py
import bpy, glob, json, math, os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import kaufquelle     # 980: von doppelten Kaufdateien nur, was Blender liest (Binär-FBX)
from mathutils import Matrix, Quaternion, Vector

KAUF = os.environ['KAUF']
# Paket, Gehen, Rennen, [Prop, Seite, Lage, Drehung xyzw, innen (Lage, Drehung) des Prop-Prefabs oder None]
PROPS = {
    'axt': ('2.HANDED', 'WalkForwardNormal2HandMelee', 'Sprint2HandMelee',
            [('SM_2HandedSwordProp', 'R', (-0.094, 0.019, -0.037), (0.07145098, 0.0094069205, -0.9888669, -0.13018614))]),
    'einhand': ('1.HANDED', 'WalkForwardHold1hMelee', 'SprintHold1hMelee',
                [('SM_BludgeonProp', 'R', (-0.1, 0.029, 0.008), (0.70526814, -0.050958876, 0.05095906, 0.7052682))]),
    'schild': ('SWORD.SHIELD', 'WalkForwardS&S', 'RunFastNormalS&S',
               [('SM_1HandedSwordProp', 'R', (-0.103, 0.024, 0.0), (0.49373475, -0.54606485, -0.5061888, 0.44923505)),
                ('SM_ShieldProp', 'L', (0.025, -0.031, 0.0), (-0.00000041723246, 0.00000042840833, 0.66834575, 0.7438508))]),
    'bogen': ('BOW.ARROW', 'WalkBow', 'RunFastBow',
              [('SM_Bow&ArrowsProp', 'L', (-0.128, -0.014, -0.109), (0.52573436, -0.2766444, -0.44483477, 0.6702188))]),
}
INNEN = json.loads(os.environ.get('INNEN', '{}'))   # Prop -> [[x, y, z], [x, y, z, w]] aus dem Prop-Prefab (griff417.py), sonst keins


def fbx(paket, name):
    alle = [p for p in glob.glob(os.path.join(KAUF, '**', '*.fbx'), recursive=True) + glob.glob(os.path.join(KAUF, '**', '*.FBX'), recursive=True)
            if paket.lower() in p.lower().replace('_', '.')]
    genau = [p for p in alle if os.path.basename(p).lower() in ('humanoid@%s.fbx' % name.lower(), '%s.fbx' % name.lower())]
    return genau[0] if genau else None


def rahmen(d, w):
    x = d.normalized(); z = x.cross(w).normalized(); return Matrix((x, z.cross(x), z)).transposed()


def k(v): return '(%+.2f vor %+.2f li %+.2f hoch)' % (-v.y, v.x, v.z)


def r3(v): return [round(x, 4) for x in v]


def gerade(p, a, q):   # Abstand des Punkts q von der Geraden p + t a, und t
    t = (q - p).dot(a); return (q - p - a * t).length, t


def fbx6_ecken(p):   # Lauf 41310185397: Bogen als FBX 6100, das Blender nicht liest; Ecken aus der Datei selbst (binaer oder Text)
    import re, struct, zlib
    b = open(p, 'rb').read()
    werte = []
    if b.startswith(b'Kaydara FBX Binary'):
        ver = struct.unpack_from('<I', b, 23)[0]; breit = ver >= 7500

        def knoten(o):
            if breit: ende, n, _l = struct.unpack_from('<QQQ', b, o); o += 24
            else: ende, n, _l = struct.unpack_from('<III', b, o); o += 12
            ln = b[o]; name = b[o + 1:o + 1 + ln]; o += 1 + ln
            props = []
            for _ in range(n):
                t = chr(b[o]); o += 1
                if t in 'YCIFDL': g = {'Y': 2, 'C': 1, 'I': 4, 'F': 4, 'D': 8, 'L': 8}[t]; o += g
                elif t in 'fdlib':
                    al, enc, cl = struct.unpack_from('<III', b, o); o += 12
                    roh = b[o:o + cl]; o += cl
                    if t == 'd': props.append(struct.unpack('<%dd' % al, zlib.decompress(roh) if enc else roh))
                elif t in 'SR': ln2 = struct.unpack_from('<I', b, o)[0]; o += 4 + ln2
            return ende, name, props, o
        def lauf(o, tief):
            while o < len(b):
                ende, name, props, o2 = knoten(o)
                if ende == 0: return
                if name == b'Vertices' and props: werte.extend(props[0])
                if o2 < ende: lauf(o2, tief + 1)
                o = ende
        lauf(27, 0)
    else:
        t = b.decode('utf-8', 'replace')
        for m in re.finditer(r'Vertices:\s*(?:\*\d+\s*\{\s*a:)?\s*([-0-9.eE,\s]+)', t):
            werte.extend(float(x) for x in m.group(1).replace('\n', ' ').split(',') if x.strip())
    return [Vector(werte[i:i + 3]) for i in range(0, len(werte) - 2, 3)]


def prop_ecken(pq):   # Ecken im Raum der Prop-Wurzel, Meter (Unity rechnet die Einheit wie Blender in Meter um)
    vorher = set(bpy.data.objects)
    try:
        bpy.ops.import_scene.fbx(filepath=pq)
    except RuntimeError as e:
        pts = [v * 0.01 for v in fbx6_ecken(pq)]   # Protofactor: Zentimeter
        print('PROP %s aus der Datei gelesen (%s): %d Ecken' % (os.path.basename(pq), str(e)[:60], len(pts)))
        return pts
    neu = [o for o in bpy.data.objects if o not in vorher]
    wurzel = [o for o in neu if o.parent is None]
    netze = [o for o in neu if o.type == 'MESH']
    pts = []
    if wurzel and netze:
        W = wurzel[0]; sw = W.matrix_world.to_scale()[0]
        for o in netze:
            L = W.matrix_world.inverted() @ o.matrix_world
            for v in o.data.vertices: pts.append((L @ v.co) * sw)
    for o in neu: bpy.data.objects.remove(o)
    return pts


def hand_rahmen(arm, seite, ruhe=False):   # 4x4: Rahmen-Raum (Handlaengen) -> Welt; dazu die Handlaenge
    def P(n):
        b = 'humanoid_ %s %s' % (seite, n)
        return arm.matrix_world @ (arm.data.bones[b].head_local if ruhe else arm.pose.bones[b].head)
    h = P('Hand'); m_ = P('Finger2')
    F = rahmen(m_ - h, P('Finger1') - P('Finger4')); lh = (m_ - h).length
    return Matrix.Translation(h) @ F.to_4x4() @ Matrix.Scale(lh, 4), lh, (P('Finger1') + P('Finger4')) * 0.5


def hauptachsen(pts, o):
    mitte = sum(pts, Vector()) / len(pts)
    C = Matrix(((0, 0, 0), (0, 0, 0), (0, 0, 0)))
    for p in pts:
        d = p - mitte
        for i in range(3):
            for j in range(3): C[i][j] += d[i] * d[j]
    ax = Vector((0.3, 0.5, 0.8))
    for _ in range(80): ax = (C @ ax).normalized()
    ts = [(p - o).dot(ax) for p in pts]
    if abs(min(ts)) > abs(max(ts)): ax = -ax; ts = [-t for t in ts]
    ax2 = Vector((0.7, -0.2, 0.4))
    for _ in range(80): ax2 = C @ ax2; ax2 = (ax2 - ax * ax2.dot(ax)).normalized()
    return ax, ax2, mitte, min(ts), max(ts)


# die Figur, an der Unity die Props haengt: Lage der Props im Rahmen ihrer Hand (Ruhe)
sk = kaufquelle.alle(KAUF, 'SK_Protof-Actor.fbx', 'GRIFF')
RUHE = True
SK = None
for versuch in ({}, {'ignore_leaf_bones': True}, {'use_anim': False, 'ignore_leaf_bones': True}):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    try:
        bpy.ops.import_scene.fbx(filepath=sk[0], **versuch)
        SK = next(o for o in bpy.data.objects if o.type == 'ARMATURE'); print('FIGUR SK_Protof-Actor', versuch); break
    except (RuntimeError, StopIteration) as e:
        print('FIGUR SK_Protof-Actor nicht lesbar', versuch, str(e).splitlines()[-1][:120])
if SK is None:   # Lauf 41310507896: Blender liest die Figur nicht (KeyError in link_hierarchy); dann die Zweihaender-Bewegung, deren
    # Knochenachsen zur Figur passen (Lauf 41310185397: linke Faust 2 cm auf der Griffachse), im ersten Bild
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=fbx('2.HANDED', 'WalkForwardNormal2HandMelee'))
    SK = next(o for o in bpy.data.objects if o.type == 'ARMATURE'); RUHE = False
    bpy.context.scene.frame_set(int(SK.animation_data.action.frame_range[0]))
    print('FIGUR ersatzweise Zweihaender-Bewegung, Bild 1')
sc_k = SK.matrix_world.to_scale()[0]


def knochen_im_rahmen(arm, seite, ruhe):   # Drehung des Handknochens im Rahmen der Hand: gleich, wenn die Knochenachsen gleich sind
    A, lh, _f = hand_rahmen(arm, seite, ruhe)
    B = arm.matrix_world @ (arm.data.bones['humanoid_ %s Hand' % seite].matrix_local if ruhe else arm.pose.bones['humanoid_ %s Hand' % seite].matrix)
    q = (A.to_3x3().normalized().inverted() @ B.to_3x3().normalized()).to_quaternion()
    return '(%.3f %.3f %.3f %.3f)' % tuple(q)


print('KNOCHEN IM RAHMEN Figur: R %s L %s' % (knochen_im_rahmen(SK, 'R', RUHE), knochen_im_rahmen(SK, 'L', RUHE)))
REL, ECKEN = {}, {}
for art, (paket, geh, renn, props) in PROPS.items():
    for (pn, seite, lage, dreh) in props:
        if pn not in ECKEN:
            pq = fbx(paket, pn)
            ECKEN[pn] = prop_ecken(pq) if pq else []
            pts = ECKEN[pn]
            if pts:
                lo = Vector([min(p[i] for p in pts) for i in range(3)]); hi = Vector([max(p[i] for p in pts) for i in range(3)])
                print('PROP %s: %d Ecken, Masse %s (m), von %s bis %s' % (pn, len(pts), r3(hi - lo), r3(lo), r3(hi)))
        if not ECKEN[pn]: print('FEHLT PROP', pn); continue
        A, lh, _f = hand_rahmen(SK, seite, ruhe=RUHE)
        H = SK.matrix_world @ (SK.data.bones['humanoid_ %s Hand' % seite].matrix_local if RUHE else SK.pose.bones['humanoid_ %s Hand' % seite].matrix) \
            @ Matrix.Scale(1.0 / sc_k, 4)
        for fassung in ('gespiegelt', 'wie gelesen'):
            M = Matrix.Diagonal((-1.0, 1.0, 1.0, 1.0)) if fassung == 'gespiegelt' else Matrix.Identity(4)
            Tu = Matrix.Translation(Vector(lage)) @ Quaternion((dreh[3], dreh[0], dreh[1], dreh[2])).to_matrix().to_4x4()
            REL[(pn, fassung)] = A.inverted() @ H @ (M @ Tu @ M)   # Prop (m) -> Rahmen der Hand (Handlaengen)

ausgabe = {}
for art, (paket, geh, renn, props) in PROPS.items():
    for wort, name in (('Gehen', geh), ('Rennen', renn)):
        q = fbx(paket, name)
        if not q: print('FEHLT', art, wort, name); continue
        bpy.ops.wm.read_factory_settings(use_empty=True)
        bpy.ops.import_scene.fbx(filepath=q)
        S = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
        a = S.animation_data.action
        f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
        bpy.context.scene.frame_set(f0)
        print('KNOCHEN IM RAHMEN %s %s: R %s L %s' % (art, wort, knochen_im_rahmen(S, 'R', False), knochen_im_rahmen(S, 'L', False)))
        for (pn, seite, lage, dreh) in props:
            if not ECKEN.get(pn): continue
            for fassung in ('gespiegelt', 'wie gelesen'):
                R = REL[(pn, fassung)]
                zeilen = []
                for ph in range(4):
                    bpy.context.scene.frame_set(f0 + (f1 - f0) * ph // 4)
                    A, lh, faust = hand_rahmen(S, seite)
                    welt = [A @ R @ p for p in ECKEN[pn]]
                    o = A @ R @ Vector()
                    ax, ax2, mitte, t0, t1 = hauptachsen(welt, o)
                    fr = hand_rahmen(S, 'R')[2]; fl = hand_rahmen(S, 'L')[2]
                    dr, tr = gerade(o, ax, fr); dl, tl = gerade(o, ax, fl)
                    becken = S.matrix_world @ S.pose.bones['humanoid_ Pelvis'].head
                    zeilen.append('%d/4 Achse %s Laenge %.2f, Mitte %s ab Becken; Faust R %.3f m neben der Achse bei %.2f, L %.3f bei %.2f; Ursprung-Faust %.3f'
                                  % (ph, k(ax), t1 - t0, k(mitte - becken), dr, tr, dl, tl, (o - faust).length))
                    if ph == 0 and wort == 'Gehen':
                        Ai = A.inverted(); Fi = A.to_3x3().normalized().inverted()
                        griff = o + ax * (faust - o).dot(ax)
                        ausgabe.setdefault(art, {})['%s:%s' % (pn, fassung)] = {
                            'seite': seite.lower(), 'achse': r3(Fi @ ax), 'quer': r3(Fi @ ax2), 'duenn': r3(Fi @ ax.cross(ax2).normalized()),
                            'griff': r3(Ai @ griff), 'ursprung': r3(Ai @ o), 'faust': r3(Ai @ faust), 'mitte': r3(Ai @ mitte),
                            'oben': r3(Fi @ Vector((0, 0, 1))), 'vorn': r3(Fi @ Vector((0, -1, 0))), 'handlaenge': round(lh, 4),
                            'spitze_m': round(t1, 3), 'ende_m': round(t0, 3)}
                for z in zeilen: print('GRIFF %s %s %s %s: %s' % (art, wort, pn, fassung, z))
json.dump(ausgabe, open(os.environ.get('OUT', 'griff417.json'), 'w'), indent=1)
print('GRIFF417B', json.dumps(ausgabe))
