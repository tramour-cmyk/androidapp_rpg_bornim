# 348.9 (Jerry): Grundmodell Vierbeiner nach der Modellregel (docs/LISTE-UMZUG-348.md, Punkt 4): Skelett mit den Knochennamen
# aus wolf.py, Netz aus Kugelketten (Metabälle), Gewichte, Grundbewegungen, Export in Metern mit Blick +Z (Blender -Y).
# Abgeleitet aus wolf.py (Runden 1–16, Gründe dort); der Wolf selbst bleibt bis zum Wort des Chefs in wolf.py.
# Eine Art (wildschwein.py, ratte.py) gibt: Gelenke J, Kugelketten BLOBS, Knubbel, Ohren, Kiefer, Felle, Färbung, Anbauten
# (Hauer, Borsten) und eigene Bewegungen; baue(art, fell) macht daraus <OUT>/<art.ID>-<fell>.glb.
import bpy, math, os, json
import numpy as np
from mathutils import Vector, Matrix

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
FPS = 30


def rgb(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return np.array([x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c])   # sRGB -> linear


# Knochen wie wolf.py (Modellregel 4: in allen Vierbeinern gleich benannt): (Name, von, nach, Eltern)
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


def beine(J, s, schulter, ellbogen, vfuss, vpfote, huefte, knie, sprung, hpfote, hzehe):
    """Gelenke eines Beinpaars; x ist die halbe Spur (L positiv, R gespiegelt)."""
    sg = 1 if s == 'L' else -1
    for k, v in (('schulter', schulter), ('ellbogen', ellbogen), ('vfuss', vfuss), ('vpfote', vpfote), ('huefte', huefte),
                 ('knie', knie), ('sprung', sprung), ('hpfote', hpfote), ('hzehe', hzehe)):
        J[k + s] = (v[0] * sg, v[1], v[2])


def seg(J, V, a, b, ra, rb):
    A, B = np.array(J[a]), np.array(J[b]); ab = B - A
    t = np.clip(((V - A) @ ab) / max(ab @ ab, 1e-9), 0, 1)
    return np.linalg.norm(V - (A + t[:, None] * ab), axis=1) - (ra + (rb - ra) * t), t


def fell_textur(path, seed=11, laenge=(15, 40), striche=5200, kontrast=1.0):
    """Gemalte, kachelbare Haartextur wie wolf.py (Prüfer Wolf Runde 11: Eckfarben tragen keine Haare): Striche längs."""
    from PIL import Image, ImageDraw
    n = 512; rng = np.random.default_rng(seed)
    img = Image.new('L', (n, n), 214); d = ImageDraw.Draw(img)
    for _ in range(striche):
        x, y = rng.random() * n, rng.random() * n
        L = rng.uniform(*laenge); a = rng.normal(0, 0.18)
        dx, dy = math.cos(a) * L, math.sin(a) * L
        v = int(rng.choice([255, 250, 150, 120, 95], p=[0.3, 0.2, 0.2, 0.18, 0.12]))
        w = int(rng.integers(3, 6))
        for ox in (-n, 0, n):
            for oy in (-n, 0, n):
                d.line([(x + ox, y + oy), (x + ox + dx, y + oy + dy)], fill=v, width=w)
    A = np.asarray(img).astype(np.float32) / 255.0
    A = A.mean() + (A - A.mean()) * kontrast
    Image.fromarray(np.uint8(np.clip(A, 0, 1) * 255)).convert('RGB').save(path)
    return float(A.mean())


def _metanetz(scn, name, ketten, aufloesung):
    """Kugelketten (a, b, ra, rb, Steifheit, Faktor am Ende) und Einzelkugeln (Punkt, r) als Metabälle, dann Fläche."""
    mb = bpy.data.metaballs.new(name); mb.resolution = aufloesung; mb.render_resolution = aufloesung; mb.threshold = 0.6
    mo = bpy.data.objects.new(name, mb); scn.collection.objects.link(mo)
    for k in ketten:
        if len(k) == 2:
            el = mb.elements.new(type='BALL'); el.co = Vector(k[0]); el.radius = k[1] * 1.6; el.stiffness = 2.0
            continue
        A, B, ra, rb, stiff, kb = k
        A, B = Vector(A), Vector(B); n = max(2, int((B - A).length / (max(min(ra, rb), 0.02) * 0.6)) + 1)
        for i in range(n):
            t = i / (n - 1); el = mb.elements.new(type='BALL'); el.co = A.lerp(B, t)
            el.radius = (ra + (rb - ra) * t) * (1.6 + (kb - 1.6) * t); el.stiffness = stiff
    bpy.ops.object.select_all(action='DESELECT')
    bpy.context.view_layer.objects.active = mo; mo.select_set(True)
    bpy.ops.object.convert(target='MESH')
    return bpy.context.active_object


def anbau_rohr(punkte, radien, n=7):
    """Gebogenes, spitz zulaufendes Rohr (Hauer, Borste, Horn) durch Punkte; gibt (Ecken, Flächen)."""
    P = [np.array(p, float) for p in punkte]
    V, F = [], []
    for i, (p, r) in enumerate(zip(P, radien)):
        t = P[min(i + 1, len(P) - 1)] - P[max(i - 1, 0)]; t /= np.linalg.norm(t)
        u = np.cross(t, [0, 0, 1.0]);
        if np.linalg.norm(u) < 1e-3: u = np.cross(t, [1.0, 0, 0])
        u /= np.linalg.norm(u); w = np.cross(t, u)
        for k in range(n):
            a = 2 * math.pi * k / n; V.append(p + r * (math.cos(a) * u + math.sin(a) * w))
    for i in range(len(P) - 1):
        for k in range(n):
            a, b = i * n + k, i * n + (k + 1) % n
            F.append((a, b, b + n, a + n))
    V.append(P[0]); F += [(len(V) - 1, (k + 1) % n, k) for k in range(n)]
    return V, F


def baue(art, fell):
    J = {k: Vector(v) for k, v in art.J.items()}
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene; scn.render.fps = FPS
    # ------------------------------------------------ Netz: Rumpf, Kopf, Läufe, Rute, Ohren, Gelenkknubbel
    ketten = [(J[a], J[b], ra, rb, 2.0, art.KB.get(a, 1.6)) for a, b, ra, rb, _ in art.BLOBS]
    ketten += [(J['ohr%s0' % s], J['ohr%s1' % s], art.OHR[0], art.OHR[1], 3.0, 1.6) for s in 'LR']
    ketten += [(J[g + s] + Vector(off), r) for s in 'LR' for g, r, off in art.KNUBBEL]
    ob = _metanetz(scn, art.ID + '_Netz', ketten, art.AUFLOESUNG)
    # Unterkiefer als eigenes Netz (Wolf Runde 1: sonst kein Maul); Marke „kiefer_netz“ übersteht das Ausdünnen
    ko = _metanetz(scn, 'Kiefer', [(J['kiefer'], J['kinn'], art.KIEFER[0], art.KIEFER[1], 2.0, 1.5)], art.AUFLOESUNG * 0.75)
    kg = ko.vertex_groups.new(name='kiefer_netz'); kg.add(list(range(len(ko.data.vertices))), 1.0, 'REPLACE')
    ob.vertex_groups.new(name='kiefer_netz')
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); ko.select_set(True); bpy.context.view_layer.objects.active = ob
    bpy.ops.object.join(); me = ob.data
    for v in me.vertices:
        if v.co.z < 0.0: v.co.z = 0.0
    if hasattr(art, 'form'): art.form(J, me)      # Art-eigene Verformung (quer schmal, Heck flacher …), Gelenke mit
    tri0 = sum(len(p.vertices) - 2 for p in me.polygons)
    dec = ob.modifiers.new('duenn', 'DECIMATE'); dec.ratio = min(1.0, art.DREIECKE / max(1, tri0))
    bpy.ops.object.modifier_apply(modifier='duenn')
    sm = ob.modifiers.new('glatt', 'SMOOTH'); sm.iterations = 3; sm.factor = 0.4
    bpy.ops.object.modifier_apply(modifier='glatt')
    for p in me.polygons: p.use_smooth = True
    me.update()
    if hasattr(art, 'zottel'): art.zottel(J, me)
    # ------------------------------------------------ Anbauten (Hauer, Borsten): eigene Flächen, je ein Knochen, eine Farbe
    an = art.anbauten(J, fell, np.array([v.co[:] for v in me.vertices])) if hasattr(art, 'anbauten') else []
    n0 = len(me.vertices)
    owner_an, farbe_an = [], []
    if an:
        import bmesh
        bm = bmesh.new(); bm.from_mesh(me)
        for V_, F_, knochen, farbe in an:
            vs = [bm.verts.new(Vector(p)) for p in V_]
            for f in F_:
                try: bm.faces.new([vs[i] for i in f])
                except ValueError: pass
            owner_an += [knochen] * len(vs); farbe_an += [farbe] * len(vs)
        bm.to_mesh(me); bm.free()
        for p in me.polygons[-sum(len(F_) for _, F_, _, _ in an):]: p.use_smooth = False
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    # ------------------------------------------------ UV für die Haartextur: längs am Rumpf, nach unten an den Läufen
    uvl = me.uv_layers.new(name='fell')
    for poly in me.polygons:
        for li in poly.loop_indices:
            c = me.vertices[me.loops[li].vertex_index].co
            uvl.data[li].uv = art.uv(c)
    # ------------------------------------------------ Eckfarben
    V = np.array([v.co[:] for v in me.vertices]); N = np.array([v.normal[:] for v in me.vertices])
    jaw = np.zeros(len(V), bool)
    gi = ob.vertex_groups['kiefer_netz'].index
    for v in me.vertices:
        for g in v.groups:
            if g.group == gi and g.weight > 0.5: jaw[v.index] = True
    C = art.faerbe(J, V, N, jaw, fell, n0)
    for i, f in enumerate(farbe_an): C[n0 + i] = rgb(f) if isinstance(f, int) else f
    ca = me.color_attributes.new('farbe', 'FLOAT_COLOR', 'POINT')
    ca.data.foreach_set('color', np.hstack([np.clip(C, 0, 1), np.ones((len(V), 1))]).astype(np.float32).ravel())
    me.color_attributes.active_color = ca
    mat = bpy.data.materials.new(art.ID); mat.use_nodes = True
    bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
    im = mat.node_tree.nodes.new('ShaderNodeTexImage'); im.image = bpy.data.images.load(art.FELL_PNG)
    mat.node_tree.links.new(im.outputs['Color'], bs.inputs['Base Color'])
    me.materials.append(mat)
    # ------------------------------------------------ Skelett
    arm = bpy.data.armatures.new('vierbeiner'); rig = bpy.data.objects.new(art.ID + '_Skelett', arm); scn.collection.objects.link(rig)
    bpy.context.view_layer.objects.active = rig; bpy.ops.object.mode_set(mode='EDIT')
    EB = {}
    for nm, a, b, par in BONES:
        bn = arm.edit_bones.new(nm); bn.head = J[a]; bn.tail = J[b] if b else J[a] + Vector((0, 0, 0.2))
        if par: bn.parent = EB[par]
        bn.use_connect = False; EB[nm] = bn
    bpy.ops.object.mode_set(mode='OBJECT')
    # Gewichte: nächste Kugelkette, weich zur Nachbarkette; Kiefer und Anbauten fest an ihrem Knochen
    D = np.stack([seg(J, V, a, b, ra, rb)[0] for a, b, ra, rb, _ in art.BLOBS] +
                 [seg(J, V, 'ohr%s0' % s, 'ohr%s1' % s, art.OHR[0], art.OHR[1])[0] for s in 'LR'], 1)
    owners = [bn for *_, bn in art.BLOBS] + ['ohrL', 'ohrR']
    W = np.exp(-(D - D.min(1, keepdims=True)) / 0.02); W[D - D.min(1, keepdims=True) > 0.06] = 0
    W /= W.sum(1, keepdims=True)
    fest = jaw.copy(); fest[n0:] = True
    W = W * ~fest[:, None]
    groups = {}
    def gruppe(bn):
        g = groups.get(bn) or ob.vertex_groups.new(name=bn); groups[bn] = g; return g
    for j, bn in enumerate(owners):
        g = gruppe(bn)
        for i in np.where(W[:, j] > 1e-3)[0]: g.add([int(i)], float(W[i, j]), 'ADD')
    gk = gruppe('kiefer')
    for i in np.where(jaw)[0]: gk.add([int(i)], 1.0, 'REPLACE')
    for i, bn in enumerate(owner_an): gruppe(bn).add([n0 + i], 1.0, 'REPLACE')
    ob.vertex_groups.remove(ob.vertex_groups['kiefer_netz'])
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
        if name == 'kiefer' and axis is X: deg = -deg    # wie wolf.py: negative Werte öffnen nach unten
        PB[name].rotation_quaternion = rot(name, deg, axis)
    def root(dx=0.0, dy=0.0, dz=0.0, pitch=0.0):
        PB['root'].location = arm.bones['root'].matrix_local.to_3x3().inverted() @ Vector((dx, dy, dz))
        PB['root'].rotation_quaternion = rot('root', pitch)
    def clear():
        for pb in PB: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
    def legs(fl, fr, hl, hr, bend=0.0):
        for s, a in (('L', fl), ('R', fr)):
            setr('oberarm' + s, a); setr('unterarm' + s, -abs(a) * 0.4 - bend); setr('vpfote' + s, abs(a) * 0.3)
        for s, a in (('L', hl), ('R', hr)):
            setr('schenkel' + s, a); setr('unterschenkel' + s, -abs(a) * 0.3 + bend * 0.6); setr('hpfote' + s, bend * 0.3)
    K = dict(J=J, PB=PB, rot=rot, setr=setr, root=root, clear=clear, legs=legs, X=X, Yv=Yv, Zv=Zv)
    INFO = {'fps': FPS, 'fell': fell, 'dreiecke': tris, 'schulterhoehe_m': art.SCHULTER}
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
    for nm, n, fn, loop in art.bewegungen(K):
        bake(nm, n, fn, loop)
    # Prüfung: Hufe/Pfoten am Boden in Ruhe und Hocke
    for nm, n, fn, loop in art.bewegungen(K):
        if nm in ('Stehen', 'Hocke'):
            fn(0.0); bpy.context.view_layer.update()
            print('PFOTE', nm, {s: round((rig.matrix_world @ PB[s].tail).z, 3) for s in ('vpfoteL', 'vpfoteR', 'hpfoteL', 'hpfoteR')})
    INFO['gehen_m_je_s'] = art.GEHTEMPO
    clear(); bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.select_all(action='DESELECT'); rig.select_set(True); ob.select_set(True)
    path = os.path.join(OUT, '%s-%s.glb' % (art.ID, fell))
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_vertex_color='ACTIVE', export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False)
    print('GLB', path, os.path.getsize(path), INFO)
    return INFO


def alle(art):
    """Aufruf aus der Art: FELL=<name> baut eines, sonst alle; schreibt <art.ID>-info.json."""
    names = [os.environ['FELL']] if os.environ.get('FELL') else list(art.COATS)
    info = {n: baue(art, n) for n in names}
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % art.ID), 'w'), indent=1)
