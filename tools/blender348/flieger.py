# 348.7 (Jerry): Grundmodell Vogel (Flieger) nach der Modellregel (docs/LISTE-UMZUG-348.md, Punkt 4: ein Skelett je Bauart,
# in allen Modellen dieser Bauart gleich benannt). Erstes Modell darauf: die Riesenfledermaus (fledermaus.py); Toms Vögel nutzen
# dasselbe Skelett (Flügel: oberarm, unterarm, hand; Handschwingen an finger3a/b, Armschwingen am unterarm; daumen, finger2,
# finger4, finger5 bleiben beim Vogel ohne Gewicht).
# Rumpf wie vierbeiner.py aus Kugelketten (Metabälle), Flügel als Flughaut zwischen Fingerknochen (Gitterflächen, je Ecke weich
# zwischen den Knochen der beiden Ränder gewichtet), Knochen als dünne Rohre, Kleinteile (Ohren, Zähne, Krallen) als Anbau.
# Eine Art gibt: Gelenke J, Kugelketten BLOBS, Rohre ROHRE, Flughäute HAEUTE, Kiefer, Felle, Färbung, Anbauten, Bewegungen;
# baue(art, fell) macht daraus <OUT>/<art.ID>-<fell>.glb. Ursprung am Boden unter dem Rumpf, Blick +Z (Blender −Y), Meter.
import bpy, math, os, json
import numpy as np
from mathutils import Vector, Matrix
import vierbeiner as vb
from vierbeiner import rgb, seg

OUT = vb.OUT
FPS = vb.FPS

# Knochen (Name, von, nach, Eltern); gleich für alle Flieger
BONES = [
    ('root', 'wurzel', None, None),
    ('becken', 'becken', 'kreuz', 'root'), ('ruecken', 'kreuz', 'brust', 'becken'), ('brust', 'brust', 'widerrist', 'ruecken'),
    ('hals', 'widerrist', 'hals', 'brust'), ('kopf', 'hals', 'kopf', 'hals'), ('schnauze', 'kopf', 'nase', 'kopf'),
    ('kiefer', 'kiefer', 'kinn', 'kopf'),
    ('schwanz0', 'kreuz', 'schwanz1', 'becken'), ('schwanz1', 'schwanz1', 'schwanz2', 'schwanz0'),
    ('ohrL', 'ohrL0', 'ohrL1', 'kopf'), ('ohrR', 'ohrR0', 'ohrR1', 'kopf'),
]
for s in 'LR':
    BONES += [('oberarm' + s, 'schulter' + s, 'ellbogen' + s, 'brust'), ('unterarm' + s, 'ellbogen' + s, 'handgelenk' + s, 'oberarm' + s),
              ('hand' + s, 'handgelenk' + s, 'hand' + s, 'unterarm' + s), ('daumen' + s, 'hand' + s, 'daumen' + s, 'hand' + s)]
    for f in '2345':
        BONES += [('finger%sa%s' % (f, s), 'hand' + s, 'f%sm%s' % (f, s), 'hand' + s),
                  ('finger%sb%s' % (f, s), 'f%sm%s' % (f, s), 'f%st%s' % (f, s), 'finger%sa%s' % (f, s))]
    BONES += [('schenkel' + s, 'huefte' + s, 'knie' + s, 'becken'), ('unterschenkel' + s, 'knie' + s, 'fuss' + s, 'schenkel' + s),
              ('fuss' + s, 'fuss' + s, 'zehe' + s, 'unterschenkel' + s)]


def spiegel(J):
    """Gelenke mit Endung L auf R spiegeln (x gespiegelt); x quer (L positiv), -y vorn, z oben."""
    import re
    for k in list(J):
        m = re.fullmatch(r'(.*)L(\d?)', k)
        if m:
            x, y, z = J[k]; J[m.group(1) + 'R' + m.group(2)] = (-x, y, z)
    return J


def kette(J, namen, knochen):
    """Linienzug durch Gelenke mit Knochen je Abschnitt: [(Punkt, {Knochen: Gewicht})], die Ecke zwischen zwei Abschnitten halb."""
    P = [np.array(J[n], float) for n in namen]
    out = []
    for i, p in enumerate(P):
        if i == 0: w = {knochen[0]: 1.0}
        elif i == len(P) - 1: w = {knochen[-1]: 1.0}
        else: w = {knochen[i - 1]: 0.5, knochen[i]: 0.5} if knochen[i - 1] != knochen[i] else {knochen[i]: 1.0}
        out.append((p, w))
    return out


def _abtasten(zug, u):
    """Punkt und Gewichte bei Anteil u (0..1) der Bogenlänge eines Linienzugs aus kette()."""
    P = [p for p, _ in zug]; L = [0.0]
    for a, b in zip(P, P[1:]): L.append(L[-1] + np.linalg.norm(b - a))
    t = u * L[-1]
    for i in range(len(P) - 1):
        if t <= L[i + 1] + 1e-9 or i == len(P) - 2:
            f = 0.0 if L[i + 1] - L[i] < 1e-9 else min(1.0, max(0.0, (t - L[i]) / (L[i + 1] - L[i])))
            w = {}
            for k, v in zug[i][1].items(): w[k] = w.get(k, 0) + v * (1 - f)
            for k, v in zug[i + 1][1].items(): w[k] = w.get(k, 0) + v * f
            return P[i] + (P[i + 1] - P[i]) * f, w
    return P[-1], dict(zug[-1][1])


def haut(A, B, nu, nv, durchhang, bauch, riss=None):
    """Flughaut zwischen den Rändern A (v=0) und B (v=1), beide von u=0 (Ansatz) bis u=1 (Spitzen); der freie Rand bei u=1
    hängt zwischen den Spitzen durch (durchhang, Anteil des Spitzenabstands), die Fläche wölbt sich (bauch, m).
    riss(u, v) -> True lässt die Fläche weg (eingerissener Flügel). Gibt (Ecken, Flächen, Gewichte, uv)."""
    V, W, UV = [], [], []
    for i in range(nu + 1):
        u = i / nu
        pa, wa = _abtasten(A, u); pb, wb = _abtasten(B, u)
        for j in range(nv + 1):
            v = j / nv
            p = pa * (1 - v) + pb * v
            w = {}
            for k, x in wa.items(): w[k] = w.get(k, 0) + x * (1 - v)
            for k, x in wb.items(): w[k] = w.get(k, 0) + x * v
            V.append(p); W.append(w); UV.append((u, v))
    V = np.array(V)
    a1, b1 = _abtasten(A, 1.0)[0], _abtasten(B, 1.0)[0]
    a5, b5 = _abtasten(A, 0.5)[0], _abtasten(B, 0.5)[0]
    innen = (a5 + b5) / 2 - (a1 + b1) / 2; innen /= max(np.linalg.norm(innen), 1e-9)
    n = np.cross(a1 - _abtasten(A, 0.0)[0], b1 - _abtasten(B, 0.0)[0]); n /= max(np.linalg.norm(n), 1e-9)
    weite = np.linalg.norm(a1 - b1)
    for k, (u, v) in enumerate(UV):
        V[k] += innen * durchhang * weite * math.sin(math.pi * v) * u ** 3
        V[k] += n * bauch * math.sin(math.pi * v) * math.sin(math.pi * min(u, 1.0) * 0.9)
    F = []
    for i in range(nu):
        for j in range(nv):
            a = i * (nv + 1) + j
            if riss and riss((i + 0.5) / nu, (j + 0.5) / nv): continue
            q = (a, a + 1, a + nv + 2, a + nv + 1)
            # Ansatz (u=0) fällt bei Fingerfächern in einen Punkt: dort Dreiecke
            if np.linalg.norm(V[q[0]] - V[q[1]]) < 1e-6: F.append((q[1], q[2], q[3]))
            elif np.linalg.norm(V[q[2]] - V[q[3]]) < 1e-6: F.append((q[0], q[1], q[2]))     # Ränder enden im selben Punkt
            else: F.append(q)
    return list(V), F, W, UV


def rohr(zug, radien, n=6):
    """Rohr (Fingerknochen, Arm) durch einen Linienzug aus kette(): Ecken, Flächen, Gewichte je Ecke."""
    P = [p for p, _ in zug]
    V, F, W = [], [], []
    for i, ((p, w), r) in enumerate(zip(zug, radien)):
        t = P[min(i + 1, len(P) - 1)] - P[max(i - 1, 0)]; t = t / max(np.linalg.norm(t), 1e-9)
        u = np.cross(t, [0, 0, 1.0])
        if np.linalg.norm(u) < 1e-3: u = np.cross(t, [1.0, 0, 0])
        u /= np.linalg.norm(u); v = np.cross(t, u)
        for k in range(n):
            a = 2 * math.pi * k / n; V.append(p + r * (math.cos(a) * u + math.sin(a) * v)); W.append(dict(w))
    for i in range(len(P) - 1):
        for k in range(n):
            a, b = i * n + k, i * n + (k + 1) % n
            F.append((a, b, b + n, a + n))
    V.append(P[-1]); W.append(dict(zug[-1][1])); m = len(V) - 1
    F += [((len(P) - 1) * n + k, (len(P) - 1) * n + (k + 1) % n, m) for k in range(n)]
    return V, F, W


def baue(art, fell):
    J = {k: Vector(v) for k, v in art.J.items()}
    Jn = {k: np.array(v, float) for k, v in art.J.items()}
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene; scn.render.fps = FPS
    # ------------------------------------------------ Rumpf, Kopf, Beine aus Kugelketten; Unterkiefer eigenes Netz
    ketten = [(J[a], J[b], ra, rb, 2.0, art.KB.get(a, 1.6)) for a, b, ra, rb, _ in art.BLOBS]
    ketten += [(J[g] + Vector(off), r) for g, r, off in art.KNUBBEL]
    ob = vb._metanetz(scn, art.ID + '_Netz', ketten, art.AUFLOESUNG)
    ko = vb._metanetz(scn, 'Kiefer', [(J['kiefer'], J['kinn'], art.KIEFER[0], art.KIEFER[1], 2.0, 1.5)], art.AUFLOESUNG * 0.75)
    kg = ko.vertex_groups.new(name='kiefer_netz'); kg.add(list(range(len(ko.data.vertices))), 1.0, 'REPLACE')
    ob.vertex_groups.new(name='kiefer_netz')
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); ko.select_set(True); bpy.context.view_layer.objects.active = ob
    bpy.ops.object.join(); me = ob.data
    if hasattr(art, 'form'): art.form(J, me)
    tri0 = sum(len(p.vertices) - 2 for p in me.polygons)
    dec = ob.modifiers.new('duenn', 'DECIMATE'); dec.ratio = min(1.0, art.DREIECKE / max(1, tri0))
    bpy.ops.object.modifier_apply(modifier='duenn')
    sm = ob.modifiers.new('glatt', 'SMOOTH'); sm.iterations, sm.factor = getattr(art, 'GLAETTEN', (3, 0.4))
    bpy.ops.object.modifier_apply(modifier='glatt')
    for p in me.polygons: p.use_smooth = True
    me.update()
    if hasattr(art, 'zottel'): art.zottel(J, me)
    gi0 = ob.vertex_groups['kiefer_netz'].index
    jaw = np.array([any(g.group == gi0 and g.weight > 0.5 for g in v.groups) for v in me.vertices])
    n0 = len(me.vertices)
    # ------------------------------------------------ Teile: Flughäute, Knochenrohre, Anbauten (je Ecke Gewichte, Farbe, glatt)
    teile = []    # (V, F, W, farbe je Ecke oder eine, flach)
    for zugA, zugB, nu, nv, dh, bauch, farbe, riss in art.haeute(Jn, fell):
        V_, F_, W_, UV_ = haut(zugA, zugB, nu, nv, dh, bauch, riss)
        teile.append((V_, F_, W_, farbe(UV_) if callable(farbe) else farbe, False))
    for zug, radien, farbe in art.rohre(Jn, fell):
        V_, F_, W_ = rohr(zug, radien)
        teile.append((V_, F_, W_, farbe, True))
    for V_, F_, knochen, farbe in art.anbauten(Jn, fell):
        W_ = knochen if isinstance(knochen, list) else [{knochen: 1.0}] * len(V_)
        W_ = [w if isinstance(w, dict) else {w: 1.0} for w in W_]
        teile.append((V_, F_, W_, farbe, True))
    import bmesh
    bm = bmesh.new(); bm.from_mesh(me)
    W_teile, C_teile, flach = [], [], []
    for V_, F_, W_, farbe, fl in teile:
        vs = [bm.verts.new(Vector(tuple(p))) for p in V_]
        for f in F_:
            try: bm.faces.new([vs[i] for i in f])
            except ValueError: pass
        W_teile += W_
        C_teile += farbe if isinstance(farbe, list) else [farbe] * len(vs)
        flach += [fl] * len(F_)
    bm.to_mesh(me); bm.free()
    nf = sum(len(t[1]) for t in teile)
    for p, fl in zip(me.polygons[len(me.polygons) - nf:], flach): p.use_smooth = not fl
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    # ------------------------------------------------ UV: Fell am Rumpf, glattes Feld für Haut, Knochen, Anbauten
    uvl = me.uv_layers.new(name='fell')
    for poly in me.polygons:
        glatt = any(v >= n0 for v in poly.vertices)
        for li in poly.loop_indices:
            c = me.vertices[me.loops[li].vertex_index].co
            uvl.data[li].uv = art.PLAIN_UV if glatt else art.uv(c)
    # ------------------------------------------------ Eckfarben
    V = np.array([v.co[:] for v in me.vertices]); N = np.array([v.normal[:] for v in me.vertices])
    C = np.zeros((len(V), 3))
    C[:n0] = art.faerbe(Jn, V[:n0], N[:n0], jaw, fell)
    # Teile: Zahl = Bildfarbe (art.zeige), sonst schon fertige Eckfarbe
    for i, f in enumerate(C_teile): C[n0 + i] = art.zeige(f) if isinstance(f, (int, np.integer)) else f
    if os.environ.get('MASKE'):     # Messlauf: je Fell eine reine Farbe (rot, blau, magenta), um die Figur im Kampfbild zu finden
        C[:] = {0: (1, 0, 0), 1: (0, 0, 1), 2: (1, 0, 1)}[list(art.COATS).index(fell)]
    ca = me.color_attributes.new('farbe', 'FLOAT_COLOR', 'POINT')
    ca.data.foreach_set('color', np.hstack([np.clip(C, 0, 1), np.ones((len(V), 1))]).astype(np.float32).ravel())
    me.color_attributes.active_color = ca
    mat = bpy.data.materials.new(art.ID); mat.use_nodes = True
    bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
    im = mat.node_tree.nodes.new('ShaderNodeTexImage'); im.image = bpy.data.images.load(art.FELL_PNG)
    mat.node_tree.links.new(im.outputs['Color'], bs.inputs['Base Color'])
    me.materials.append(mat)
    # ------------------------------------------------ Skelett
    arm = bpy.data.armatures.new('flieger'); rig = bpy.data.objects.new(art.ID + '_Skelett', arm); scn.collection.objects.link(rig)
    bpy.context.view_layer.objects.active = rig; bpy.ops.object.mode_set(mode='EDIT')
    EB = {}
    for nm, a, b, par in BONES:
        bn = arm.edit_bones.new(nm); bn.head = J[a]; bn.tail = J[b] if b else J[a] + Vector((0, 0, 0.2))
        if (bn.tail - bn.head).length < 1e-4: bn.tail = bn.head + Vector((0, 0, 0.02))
        if par: bn.parent = EB[par]
        bn.use_connect = False; EB[nm] = bn
    bpy.ops.object.mode_set(mode='OBJECT')
    # Gewichte: Rumpf nach der nächsten Kugelkette, weich zur Nachbarkette; Kiefer fest; Teile nach ihren Gewichten
    D = np.stack([seg(J, V[:n0], a, b, ra, rb)[0] for a, b, ra, rb, _ in art.BLOBS], 1)
    owners = [bn for *_, bn in art.BLOBS]
    Wb = np.exp(-(D - D.min(1, keepdims=True)) / 0.02); Wb[D - D.min(1, keepdims=True) > 0.06] = 0
    Wb /= Wb.sum(1, keepdims=True); Wb = Wb * ~jaw[:, None]
    groups = {}
    def gruppe(bn):
        g = groups.get(bn) or ob.vertex_groups.new(name=bn); groups[bn] = g; return g
    for j, bn in enumerate(owners):
        g = gruppe(bn)
        for i in np.where(Wb[:, j] > 1e-3)[0]: g.add([int(i)], float(Wb[i, j]), 'ADD')
    gk = gruppe('kiefer')
    for i in np.where(jaw)[0]: gk.add([int(i)], 1.0, 'REPLACE')
    for i, w in enumerate(W_teile):
        s = sum(w.values())
        for bn, x in w.items():
            if x > 1e-4: gruppe(bn).add([n0 + i], x / s, 'ADD')
    ob.vertex_groups.remove(ob.vertex_groups['kiefer_netz'])
    ob.parent = rig; md = ob.modifiers.new('skelett', 'ARMATURE'); md.object = rig
    # ------------------------------------------------ Bewegungen
    bpy.context.view_layer.objects.active = rig; bpy.ops.object.mode_set(mode='POSE')
    PB = rig.pose.bones
    for pb in PB: pb.rotation_mode = 'QUATERNION'
    X = Vector((1, 0, 0)); Yv = Vector((0, 1, 0)); Zv = Vector((0, 0, 1))
    def rot(name, deg, axis=X):
        M3 = arm.bones[name].matrix_local.to_3x3()
        return (M3.inverted() @ Matrix.Rotation(math.radians(deg), 3, axis) @ M3).to_quaternion()
    def setr(name, deg, axis=X):
        if name == 'kiefer' and axis is X: deg = -deg    # wie vierbeiner.py: negative Werte öffnen nach unten
        PB[name].rotation_quaternion = rot(name, deg, axis)
    def addr(name, deg, axis=X):
        PB[name].rotation_quaternion = PB[name].rotation_quaternion @ rot(name, deg if not (name == 'kiefer' and axis is X) else -deg, axis)
    def root(dx=0.0, dy=0.0, dz=0.0, pitch=0.0, roll=0.0):
        PB['root'].location = arm.bones['root'].matrix_local.to_3x3().inverted() @ Vector((dx, dy, dz))
        PB['root'].rotation_quaternion = rot('root', pitch) @ rot('root', roll, Yv)
    def clear():
        for pb in PB: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
    def fluegel(auf, falte=0.0, vor=0.0):
        """Flügelschlag: auf +1 oben, −1 unten (Grad aus art.SCHLAG); falte 0 offen, 1 angelegt; vor dreht die Flügel nach vorn."""
        for s, sg in (('L', 1), ('R', -1)):
            a = art.SCHLAG * auf
            addr('oberarm' + s, -a * sg, Yv); addr('oberarm' + s, vor * sg, Zv)
            addr('unterarm' + s, -0.35 * a * sg, Yv); addr('unterarm' + s, -40 * falte * sg, Zv)     # Handgelenk nach vorn innen
            addr('hand' + s, -0.25 * a * sg, Yv); addr('hand' + s, 50 * falte * sg, Zv)             # Finger nach hinten an den Arm
            for f, k in (('2', 0.6), ('3', 0.8), ('4', 1.0), ('5', 1.1)):
                addr('finger%sa%s' % (f, s), k * 25 * falte * sg, Zv); addr('finger%sb%s' % (f, s), -0.15 * a * sg, Yv)
    K = dict(J=Jn, PB=PB, rot=rot, setr=setr, addr=addr, root=root, clear=clear, fluegel=fluegel, X=X, Yv=Yv, Zv=Zv)
    G = getattr(art, 'GROESSE', {}).get(fell, 1.0) if isinstance(getattr(art, 'GROESSE', 1.0), dict) else getattr(art, 'GROESSE', 1.0)
    INFO = {'fps': FPS, 'fell': fell, 'dreiecke': tris, 'spannweite_m': round(art.SPANNWEITE * G, 3), 'kopf_m': round(art.KOPF * G, 3)}
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
    INFO['gehen_m_je_s'] = round(art.GEHTEMPO * G, 3)
    clear(); bpy.ops.object.mode_set(mode='OBJECT')
    rig.scale = (G,) * 3
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
