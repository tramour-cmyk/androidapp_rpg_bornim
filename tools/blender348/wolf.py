# 348.7 (Jerry): der Wolf für Godot nach der Modellregel (docs/LISTE-UMZUG-348.md): Meter, Blick +Z in glTF (Blender -Y),
# Ursprung am Boden unter dem Schwerpunkt, Skelett „Vierbeiner“, Bewegungen im Skript mit 30 Bildern je Sekunde,
# Farbe in Eckfarben gebacken (Fell, Sattel, Bauch, Augen wie WolfArt.kt), Felle GRAU, DUNKEL, ROST, ASCHE als Schalter.
# Aufruf: OUT=<ordner> FELL=grau|dunkel|rost|asche python -I wolf.py   ->  <OUT>/wolf-<fell>.glb, wolf-info.json
# Ohne FELL: alle vier Felle nacheinander.
import bpy, bmesh, math, os, json, sys
import numpy as np
from mathutils import Vector, Matrix

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
FPS = 30

# Felle aus WolfArt.kt (fur, saddle, belly, eye); Narbe und zerrissenes Ohr wie dort
COATS = {
    'grau':   (0x6A645E, 0x24201E, 0xB4AA98, 0xF2B428, False, False),
    'dunkel': (0x3E3A3C, 0x161214, 0x7A726C, 0xF0C840, False, True),
    'rost':   (0x74563E, 0x2A1C16, 0xB8A088, 0xF0A020, True, False),
    'asche':  (0x8E8A84, 0x3A3634, 0xCAC4B8, 0xE88A20, True, True),
}

def rgb(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return np.array([x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c])   # sRGB -> linear

# ---------------------------------------------------------------- Gelenke (Meter; x quer, -y vorn, z oben)
# Schulterhöhe 0,8 m, Rumpf von der Brust bis zur Kruppe 0,95 m, Kopf mit Schnauze 0,3 m vor dem Hals; Kopf wie im alten
# Bild etwas unter der Rückenlinie, Rumpf tief, Läufe kräftig (Prüfer Stand 7: „steht wie ein Reh“)
J = {
    'wurzel': (0, 0, 0),
    'becken': (0, 0.36, 0.74), 'kreuz': (0, 0.12, 0.76), 'brust': (0, -0.20, 0.78), 'widerrist': (0, -0.42, 0.80),
    'hals': (0, -0.60, 0.84), 'kopf': (0, -0.72, 0.82), 'schnauze': (0, -0.92, 0.75), 'nase': (0, -1.00, 0.73),
    'kiefer': (0, -0.76, 0.75), 'kinn': (0, -0.95, 0.68),
    'rute0': (0, 0.46, 0.74), 'rute1': (0, 0.66, 0.58), 'rute2': (0, 0.80, 0.40),
    'ohrL0': (0.07, -0.68, 0.90), 'ohrL1': (0.09, -0.65, 1.00), 'ohrR0': (-0.07, -0.68, 0.90), 'ohrR1': (-0.09, -0.65, 1.00),
}
for s, x in (('L', 0.12), ('R', -0.12)):
    J['schulter' + s] = (x, -0.40, 0.72); J['ellbogen' + s] = (x, -0.36, 0.44); J['vfuss' + s] = (x * 0.9, -0.37, 0.10)
    J['vpfote' + s] = (x * 0.9, -0.43, 0.02)
    J['huefte' + s] = (x, 0.36, 0.70); J['knie' + s] = (x, 0.22, 0.44); J['sprung' + s] = (x * 0.9, 0.42, 0.20)
    J['hpfote' + s] = (x * 0.9, 0.40, 0.02)
J = {k: Vector(v) for k, v in J.items()}
# Knochen: (Name, von, nach, Eltern)
BONES = [
    ('root', 'wurzel', None, None),
    ('becken', 'becken', 'kreuz', 'root'), ('ruecken', 'kreuz', 'brust', 'becken'), ('brust', 'brust', 'widerrist', 'ruecken'),
    ('hals', 'widerrist', 'hals', 'brust'), ('kopf', 'hals', 'kopf', 'hals'), ('schnauze', 'kopf', 'nase', 'kopf'),
    ('kiefer', 'kiefer', 'kinn', 'kopf'),
    ('rute0', 'becken', 'rute1', 'becken'), ('rute1', 'rute1', 'rute2', 'rute0'),
    ('ohrL', 'ohrL0', 'ohrL1', 'kopf'), ('ohrR', 'ohrR0', 'ohrR1', 'kopf'),
]
for s in 'LR':
    BONES += [('oberarm' + s, 'schulter' + s, 'ellbogen' + s, 'brust'), ('unterarm' + s, 'ellbogen' + s, 'vfuss' + s, 'oberarm' + s),
              ('vpfote' + s, 'vfuss' + s, 'vpfote' + s, 'unterarm' + s),
              ('schenkel' + s, 'huefte' + s, 'knie' + s, 'becken'), ('unterschenkel' + s, 'knie' + s, 'sprung' + s, 'schenkel' + s),
              ('hpfote' + s, 'sprung' + s, 'hpfote' + s, 'unterschenkel' + s)]

# Körper als Kugelkette: (Gelenk a, Gelenk b, Radius a, Radius b, Knochen)
BLOBS = [
    ('becken', 'kreuz', 0.15, 0.16, 'becken'), ('kreuz', 'brust', 0.17, 0.21, 'ruecken'), ('brust', 'widerrist', 0.22, 0.18, 'brust'),
    ('widerrist', 'hals', 0.15, 0.11, 'hals'), ('hals', 'kopf', 0.11, 0.10, 'kopf'), ('kopf', 'schnauze', 0.09, 0.05, 'schnauze'),
    ('schnauze', 'nase', 0.045, 0.03, 'schnauze'), ('kiefer', 'kinn', 0.05, 0.025, 'kiefer'),
    ('rute0', 'rute1', 0.06, 0.07, 'rute0'), ('rute1', 'rute2', 0.07, 0.04, 'rute1'),
]
for s in 'LR':
    BLOBS += [('schulter' + s, 'ellbogen' + s, 0.09, 0.06, 'oberarm' + s), ('ellbogen' + s, 'vfuss' + s, 0.055, 0.04, 'unterarm' + s),
              ('vfuss' + s, 'vpfote' + s, 0.04, 0.045, 'vpfote' + s),
              ('huefte' + s, 'knie' + s, 0.12, 0.075, 'schenkel' + s), ('knie' + s, 'sprung' + s, 0.06, 0.038, 'unterschenkel' + s),
              ('sprung' + s, 'hpfote' + s, 0.038, 0.045, 'hpfote' + s)]

def seg(V, a, b, ra, rb):
    A, B = np.array(J[a]), np.array(J[b]); ab = B - A
    t = np.clip(((V - A) @ ab) / max(ab @ ab, 1e-9), 0, 1)
    return np.linalg.norm(V - (A + t[:, None] * ab), axis=1) - (ra + (rb - ra) * t), t

LIFT = 2.2

def build(name):
    fur, saddle, belly, eye, scar, torn = COATS[name]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene; scn.render.fps = FPS
    # ------------------------------------------------ Netz: Kugelketten als Metabälle, glatt verschmolzen, dann Fläche
    mb = bpy.data.metaballs.new('wolf'); mb.resolution = 0.014; mb.render_resolution = 0.014; mb.threshold = 0.6
    mo = bpy.data.objects.new('Wolf_Netz', mb); scn.collection.objects.link(mo)
    def chain(a, b, ra, rb, stiff=2.0):
        A, B = J[a], J[b]; n = max(2, int((B - A).length / (min(ra, rb) * 0.6)) + 1)
        for i in range(n):
            t = i / (n - 1); el = mb.elements.new(type='BALL'); el.co = A.lerp(B, t); el.radius = (ra + (rb - ra) * t) * 1.6
            el.stiffness = stiff
    for a, b, ra, rb, _ in BLOBS: chain(a, b, ra, rb)
    for s in 'LR': chain('ohr%s0' % s, 'ohr%s1' % s, 0.03, 0.008, 3.0)
    bpy.context.view_layer.objects.active = mo; mo.select_set(True)
    bpy.ops.object.convert(target='MESH')
    ob = bpy.context.active_object; ob.name = 'Wolf_Netz'; me = ob.data
    # Pfoten flach auf den Boden
    for v in me.vertices:
        if v.co.z < 0.0: v.co.z = 0.0
    # Modellregel 7: höchstens 6000 Dreiecke (Lauf 13: 8688, weil die Viereck-Flächen gezählt wurden, nicht die Dreiecke)
    tri0 = sum(len(p.vertices) - 2 for p in me.polygons)
    dec = ob.modifiers.new('duenn', 'DECIMATE'); dec.ratio = min(1.0, 5400 / max(1, tri0))
    bpy.ops.object.modifier_apply(modifier='duenn')
    sm = ob.modifiers.new('glatt', 'SMOOTH'); sm.iterations = 3; sm.factor = 0.4
    bpy.ops.object.modifier_apply(modifier='glatt')
    for p in me.polygons: p.use_smooth = True
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    # ------------------------------------------------ Eckfarben: Fell, dunkler Sattel auf dem Rücken, heller Bauch und Kehle,
    # dunkle Nase und Pfoten, gelbe Augen; feine Strähnen als Rauschen
    V = np.array([v.co[:] for v in me.vertices]); N = np.array([v.normal[:] for v in me.vertices])
    rng = np.random.default_rng(7)
    C = np.tile(rgb(fur), (len(V), 1))
    up = N[:, 2]
    back = np.clip((up - 0.35) / 0.4, 0, 1) * np.clip((V[:, 2] - 0.6) / 0.15, 0, 1) * (V[:, 1] > -0.62)
    C = C * (1 - back[:, None] * 0.85) + rgb(saddle) * back[:, None] * 0.85
    low = np.clip((-up - 0.1) / 0.5, 0, 1) * (V[:, 2] > 0.3)
    throat = np.clip(1 - np.linalg.norm((V - np.array(J['kinn']) + np.array([0, -0.10, -0.10])) / np.array([0.08, 0.14, 0.12]), axis=1), 0, 1)
    light = np.maximum(low, throat)
    C = C * (1 - light[:, None] * 0.8) + rgb(belly) * light[:, None] * 0.8
    paws = np.clip((0.12 - V[:, 2]) / 0.08, 0, 1)
    C = C * (1 - paws[:, None] * 0.5) + rgb(saddle) * paws[:, None] * 0.5
    # 348.7: das alte Bild malt das Fell mit hellerem Verlauf (WolfArt Ramp), der Toon-Schatten gibt höchstens 0,75 der
    # Farbe: ×2,2 (linear) bringt den grauen Wolf im Kampfort auf Helligkeit 76 (alt 81), den dunklen auf 28 (alt 31; Lauf 11)
    C = np.minimum(C * LIFT, 1.0)
    if name == 'rost':   # Prüfer Stand 7: im Sonnenlicht zu orange; ein Viertel zum Grau hin
        C = C * 0.75 + C.mean(axis=1, keepdims=True) * 0.25
    nose = np.linalg.norm(V - np.array(J['nase']), axis=1) < 0.045
    C[nose] = rgb(0x141010)
    for s, x in (('L', 0.055), ('R', -0.055)):
        e = np.linalg.norm(V - np.array([x, -0.82, 0.84]), axis=1) < 0.022
        C[e] = rgb(eye)
    tip = np.linalg.norm(V - np.array(J['rute2']), axis=1) < 0.09
    C[tip] = C[tip] * 0.3 + rgb(saddle) * 0.7
    strand = 1 + 0.10 * np.sin(V[:, 1] * 140 + V[:, 2] * 60 + rng.normal(0, 0.8, len(V))) + rng.normal(0, 0.03, len(V))
    C = C * strand[:, None]
    if scar:   # Narbe quer über die Schulter, hell
        sc = np.abs((V[:, 1] + 0.32) + 0.6 * (V[:, 2] - 0.62)) < 0.012
        sc &= (V[:, 2] > 0.5) & (V[:, 2] < 0.75) & (V[:, 0] > 0.05)
        C[sc] = rgb(0x9A8070)
    if torn:   # zerrissenes Ohr links: Spitze fehlt
        cut = (np.linalg.norm(V - np.array(J['ohrL1']), axis=1) < 0.04)
        for i in np.where(cut)[0]: me.vertices[int(i)].co = (Vector(J['ohrL1']) + Vector(J['ohrL0'])) / 2 + (me.vertices[int(i)].co - Vector(J['ohrL1'])) * 0.3
    ca = me.color_attributes.new('farbe', 'FLOAT_COLOR', 'POINT')
    ca.data.foreach_set('color', np.hstack([np.clip(C, 0, 1), np.ones((len(V), 1))]).astype(np.float32).ravel())
    me.color_attributes.active_color = ca
    mat = bpy.data.materials.new('wolf'); mat.use_nodes = True
    bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
    vc = mat.node_tree.nodes.new('ShaderNodeVertexColor'); vc.layer_name = 'farbe'
    mat.node_tree.links.new(vc.outputs['Color'], bs.inputs['Base Color'])
    me.materials.append(mat)
    # ------------------------------------------------ Skelett
    arm = bpy.data.armatures.new('vierbeiner'); rig = bpy.data.objects.new('Wolf_Skelett', arm); scn.collection.objects.link(rig)
    bpy.context.view_layer.objects.active = rig; bpy.ops.object.mode_set(mode='EDIT')
    EB = {}
    for nm, a, b, par in BONES:
        bn = arm.edit_bones.new(nm); bn.head = J[a]; bn.tail = J[b] if b else J[a] + Vector((0, 0, 0.2))
        if par: bn.parent = EB[par]
        bn.use_connect = False; EB[nm] = bn
    bpy.ops.object.mode_set(mode='OBJECT')
    # Gewichte: nächste Kugelkette, weich zur Nachbarkette
    V = np.array([v.co[:] for v in me.vertices])
    D = np.stack([seg(V, a, b, ra, rb)[0] for a, b, ra, rb, _ in BLOBS] +
                 [seg(V, 'ohr%s0' % s, 'ohr%s1' % s, 0.035, 0.006)[0] for s in 'LR'], 1)
    owners = [bn for *_, bn in BLOBS] + ['ohrL', 'ohrR']
    W = np.exp(-(D - D.min(1, keepdims=True)) / 0.02); W[D - D.min(1, keepdims=True) > 0.06] = 0
    W /= W.sum(1, keepdims=True)
    groups = {}
    for j, bn in enumerate(owners):
        g = groups.get(bn) or ob.vertex_groups.new(name=bn); groups[bn] = g
        for i in np.where(W[:, j] > 1e-3)[0]: g.add([int(i)], float(W[i, j]), 'ADD')
    ob.parent = rig; md = ob.modifiers.new('skelett', 'ARMATURE'); md.object = rig
    # ------------------------------------------------ Bewegungen
    bpy.context.view_layer.objects.active = rig; bpy.ops.object.mode_set(mode='POSE')
    PB = rig.pose.bones
    for pb in PB: pb.rotation_mode = 'QUATERNION'
    X = Vector((1, 0, 0)); Zv = Vector((0, 0, 1)); Yv = Vector((0, 1, 0))
    def rot(name, deg, axis=X):
        M3 = arm.bones[name].matrix_local.to_3x3()
        return (M3.inverted() @ Matrix.Rotation(math.radians(deg), 3, axis) @ M3).to_quaternion()
    def setr(name, deg, axis=X):
        PB[name].rotation_quaternion = rot(name, deg, axis)
    def root(dx=0.0, dy=0.0, dz=0.0, pitch=0.0):
        PB['root'].location = arm.bones['root'].matrix_local.to_3x3().inverted() @ Vector((dx, dy, dz))
        PB['root'].rotation_quaternion = rot('root', pitch)
    def clear():
        for pb in PB: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
    # Vorzeichen: positive Drehung um X hebt die Spitze nach vorn-oben (Blick -Y)
    def legs(fl, fr, hl, hr, bend=0.0):
        for s, a in (('L', fl), ('R', fr)):
            setr('oberarm' + s, a); setr('unterarm' + s, -abs(a) * 0.4 - bend); setr('vpfote' + s, abs(a) * 0.3)
        for s, a in (('L', hl), ('R', hr)):
            setr('schenkel' + s, a); setr('unterschenkel' + s, -abs(a) * 0.3 + bend * 0.6); setr('hpfote' + s, bend * 0.3)
    def stehen(p):
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=0.004 * br); setr('brust', 1.2 * br); setr('kopf', 2 * math.sin(2 * math.pi * p * 2) * 0.5)
        setr('rute0', -20 + 4 * br); setr('rute1', -10 + 3 * math.sin(2 * math.pi * (p + 0.2))); setr('kiefer', -4 - 3 * max(0, br))
    def gehen(p):
        clear(); w = 2 * math.pi * p
        legs(22 * math.sin(w), 22 * math.sin(w + math.pi), 20 * math.sin(w + math.pi * 0.5), 20 * math.sin(w + math.pi * 1.5))
        root(dz=0.012 * abs(math.sin(2 * w)) - 0.006); setr('kopf', 3 * math.sin(2 * w)); setr('rute0', -18); setr('rute1', -8)
    def hocke(p):   # Ducken vor dem Sprung (Anspringen angesagt): tief, Hinterläufe gespannt, gehalten
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=-0.16 + 0.006 * br, dy=0.04, pitch=-6); legs(-18, -18, -26, -26, bend=40)
        setr('hals', -18); setr('kopf', 10); setr('kiefer', -10); setr('ohrL', -30); setr('ohrR', -30); setr('rute0', -45)
    def sprung(p):   # aus der Hocke 1,2 m nach vorn, Landung, zurück in den Stand (24 Bilder)
        clear()
        if p < 0.25:
            u = p / 0.25; root(dz=-0.16 * (1 - u), pitch=-6 * (1 - u) + 12 * u, dy=0.04 - 0.3 * u); legs(-18 + 60 * u, -18 + 60 * u, -26 - 30 * u, -26 - 30 * u, bend=40 * (1 - u))
        elif p < 0.6:
            u = (p - 0.25) / 0.35; root(dz=0.35 * math.sin(math.pi * u), dy=-0.3 - 0.9 * u, pitch=12 - 20 * u); legs(50, 46, -60, -56)
        else:
            u = (p - 0.6) / 0.4; root(dz=-0.06 * math.sin(math.pi * u), dy=-1.2 + 1.2 * u * u, pitch=-8 * (1 - u)); legs(10 * (1 - u), 6 * (1 - u), -10 * (1 - u), -8 * (1 - u), bend=20 * math.sin(math.pi * u))
        setr('kiefer', -30 if 0.3 < p < 0.7 else -6); setr('ohrL', -30); setr('ohrR', -30); setr('rute0', -10)
    def biss(p):    # Biss 0,6 s: vor, zuschnappen am Aufschlag (p 0,42), zurück
        clear(); u = math.sin(math.pi * min(1, p / 0.84))
        root(dy=-0.35 * u, dz=-0.03 * u, pitch=-5 * u); legs(18 * u, -8 * u, -14 * u, 8 * u)
        setr('hals', -12 * u); setr('kopf', 8 * u); setr('kiefer', -32 if p < 0.42 else -4); setr('ohrL', -25 * u); setr('ohrR', -25 * u)
    def treffer(p):
        clear(); u = math.sin(math.pi * p); root(dy=0.10 * u, pitch=6 * u); setr('kopf', 14 * u, Zv); setr('kiefer', -18 * u); setr('rute0', -40 * u)
    def ausweichen(p):
        clear(); u = math.sin(math.pi * p); root(dx=0.28 * u, dz=0.05 * u); setr('ruecken', 10 * u, Zv); legs(-10 * u, 12 * u, 10 * u, -10 * u)
    def sturz(p):   # zu Boden, liegend bleibt (Tod), 30 Bilder
        clear(); u = min(1, p * 1.3); u = u * u * (3 - 2 * u)
        root(dz=-0.42 * u, dx=0.05 * u); PB['root'].rotation_quaternion = rot('root', 80 * u, Yv)
        legs(30 * u, 20 * u, -30 * u, -20 * u, bend=30 * u); setr('hals', -20 * u); setr('kiefer', -14 * u); setr('rute0', -50 * u)
    def heulen(p):
        clear(); u = math.sin(math.pi * min(1, p * 1.2)); root(dz=-0.04 * u, pitch=6 * u); setr('hals', 40 * u); setr('kopf', 25 * u)
        setr('kiefer', -26 * u); setr('rute0', -30 * u)
    INFO = {'fps': FPS, 'fell': name, 'dreiecke': tris, 'schulterhoehe_m': 0.8}
    def bake(nm, n, fn, loop):
        act = bpy.data.actions.new(nm); act.use_fake_user = True
        rig.animation_data_create(); rig.animation_data.action = act
        for f in range(n + (1 if loop else 0)):
            fn((f % n) / n if loop else f / (n - 1))
            for pb in PB:
                pb.keyframe_insert('rotation_quaternion', frame=f + 1); pb.keyframe_insert('location', frame=f + 1)
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm; tr.strips.new(nm, 1, act)
        rig.animation_data.action = None
        INFO[nm] = round(n / FPS, 3)
    bake('Stehen', 60, stehen, True)
    bake('Gehen', 24, gehen, True)
    bake('Hocke', 30, hocke, True)
    bake('Sprung', 24, sprung, False)
    bake('Biss', 18, biss, False)          # 0,6 s (DESIGN-ABNAHME.md)
    bake('Treffer', 12, treffer, False)
    bake('Ausweichen', 12, ausweichen, False)
    bake('Tod', 30, sturz, False)
    bake('Heulen', 45, heulen, False)
    # Gehtempo gegen Fußgleiten: 2 Schritte je Schleife, Schrittweite aus dem Schwung der Vorderläufe
    INFO['gehen_m_je_s'] = round(2 * 2 * 0.36 * math.sin(math.radians(22)) / (24 / FPS), 3)
    clear(); bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_all(action='DESELECT'); rig.select_set(True); ob.select_set(True)
    path = os.path.join(OUT, 'wolf-%s.glb' % name)
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_vertex_color='ACTIVE', export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False)
    print('GLB', path, os.path.getsize(path), INFO)
    return INFO

if __name__ == '__main__':
    names = [os.environ['FELL']] if os.environ.get('FELL') else list(COATS)
    info = {n: build(n) for n in names}
    json.dump(info, open(os.path.join(OUT, 'wolf-info.json'), 'w'), indent=1)
