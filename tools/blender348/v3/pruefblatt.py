# Pruefblatt einer Figur: Ruhehaltung vorn, rechts, hinten, links (45 Grad wie Spielkamera), Kopf nah vorn/seitlich/hinten,
# Gehen seitlich zwei Phasen, Stehen Bild 1. Aufruf: OUT=<figurordner> python -I pruefblatt.py -> <OUT>/pb/*.png
import bpy, os, math, json
from mathutils import Vector
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']
scn.render.engine = 'CYCLES'; scn.cycles.samples = 16; scn.cycles.device = 'CPU'
w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs[0].default_value = (0.30, 0.32, 0.30, 1); scn.world = w
sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); scn.collection.objects.link(sun)
sun.data.energy = 3.2; sun.rotation_euler = (math.radians(40), 0, math.radians(35))
bpy.ops.mesh.primitive_plane_add(size=6)
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); scn.collection.objects.link(cam); scn.camera = cam
cam.data.type = 'ORTHO'
G = json.load(open(OUT + '/gelenke.json'))['J']
# CC0 Runde 3 (Fremdpruefung Runde 2: „Aldric ohne Stabhaltung“, das Blatt zeigte den Stab nicht): getragenes Ding wie leute.gd
# (richte_ding: Griff in der rechten Faust, Schaft aufrecht, oben 0,18 nach hinten und 0,08 nach links); .glb aus WAFFEN=<ordner>
INFO = json.load(open(OUT + '/held-info.json'))
ding = None
_wf = os.path.join(os.environ.get('WAFFEN', os.path.join(OUT, '..', 'waffen')), '%s.glb' % INFO.get('traegt', '-'))
if INFO.get('traegt') and os.path.exists(_wf):
    _vor = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=_wf)
    _neu = [o for o in bpy.data.objects if o not in _vor and o.type == 'MESH']
    for o in _neu: o.parent = None
    bpy.ops.object.select_all(action='DESELECT')
    for o in _neu: o.select_set(True)
    bpy.context.view_layer.objects.active = _neu[0]
    if len(_neu) > 1: bpy.ops.object.join()
    ding = bpy.context.view_layer.objects.active; ding.name = 'Ding'
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    UNTEN = max(0.0, -min(v.co.z for v in ding.data.vertices))   # CC0 Runde 4: wie leute.gd ding_unten (Stab steht auf dem Boden)
STAB_VOR, STAB_SETZ, STAB_SETZ_VOR, STAB_AB, TEMPO = 0.14, 0.22, 0.14, (0.03, 0.03), 1.2   # wie leute.gd
FUSS = [None]   # Gehen: Fuss des Stabs (Figur), aus stab_lauf; None: in Ruhe neben der Faust
def faust():
    return rig.matrix_world @ rig.pose.bones[INFO['knochen_R']].matrix @ Vector(INFO['griff_R'])
# Feinschliff 2 (Fremdpruefung Feinschliff 1: „Fuss springt im Pruefblatt“, die Nachahmung rechnete ihn von der Faust des Bildes aus):
# die Regel von leute.gd ueber drei Gaenge nachlaufen, die Figur geht dabei mit gehen_m_je_s vor (Blender: vorn -Y, ihre Rechte -X);
# das Spiel spielt die Bewegung mit TEMPO, Umsetzen dauert dort STAB_SETZ s, also STAB_SETZ * TEMPO s der Bewegung
def stab_lauf(f0, f1):
    fps = scn.render.fps; v = float(INFO.get('gehen_m_je_s', 1.0)); vorn = Vector((0, -1, 0)); aus = Vector((-1, 0, 0))
    fuss = None; von = nach = None; t = 1.0; aus_ = {}; k = 0; mess = []
    for gang in range(3):
        for f in range(f0, f1):
            scn.frame_set(f); s = v * k / fps; k += 1
            p = faust() + vorn * s; p0 = Vector((p.x, p.y, 0.0))
            ziel = p0 + aus * STAB_AB[0] + vorn * STAB_SETZ_VOR
            if fuss is None: fuss = ziel.copy()
            if t >= 1.0 and (p0 - fuss).dot(vorn) > STAB_VOR: von, t = fuss.copy(), 0.0
            if t < 1.0:
                nach = ziel; t = min(1.0, t + 1.0 / fps / (STAB_SETZ * TEMPO)); u = t * t * (3 - 2 * t)
                fuss = von.lerp(nach, u) + Vector((0, 0, 0.06 * math.sin(math.pi * t)))
            if gang == 2:
                aus_[f] = fuss - vorn * s
                kb = rig.pose.bones.get('Head') or rig.pose.bones.get('head')   # Messung: Neigung (vorn +) und Abstand der Schaftachse ueber der Faust zur Kopfmitte
                if kb:
                    km = rig.matrix_world @ (kb.head + (kb.tail - kb.head).normalized() * 0.1) + vorn * s
                    y = (p - fuss).normalized(); oben = fuss + y * 2 * UNTEN
                    d = min((km - (p + (oben - p) * a / 10)).length for a in range(11))
                    q = fuss + y * ((km.z - fuss.z) / max(y.z, 1e-3))   # Schaft auf Hoehe der Kopfmitte: seitlich und vorn davon
                    mess.append((math.degrees(math.atan2((p - fuss).dot(vorn), (p - fuss).z)), d, abs(q.x - km.x), (q - km).dot(vorn), oben.z - km.z))
    if mess: print('STAB neigung %.0f..%.0f Grad, kopf >= %.2f m, auf Kopfhoehe seitlich %.2f..%.2f, vor der Kopfmitte %.2f..%.2f m, Spitze %.2f..%.2f ueber ihr' % (
        min(m[0] for m in mess), max(m[0] for m in mess), min(m[1] for m in mess), min(m[2] for m in mess), max(m[2] for m in mess),
        min(m[3] for m in mess), max(m[3] for m in mess), min(m[4] for m in mess), max(m[4] for m in mess)))
    return aus_
def richte():
    if ding is None: return
    from mathutils import Matrix
    p = faust()
    if UNTEN > 0.3:   # CC0 Feinschliff, wie leute.gd: Fuss vorn aussen neben dem rechten Fuss, im Gehen steht er, oben durch die Faust
        fuss = FUSS[0] if FUSS[0] is not None else Vector((p.x - STAB_AB[0], p.y - STAB_AB[1], 0.0))
        y = p - fuss; y.z = max(y.z, 0.5); y.normalize()
        x = Vector((1, 0, 0)); x = (x - y * x.dot(y)).normalized(); z = y.cross(x)
        R_ = Matrix((x, z, y)).transposed()   # Schaft (glTF +Y) liegt nach dem Import auf Blender +Z
        ding.matrix_world = Matrix.Translation(fuss + y * UNTEN) @ R_.to_4x4(); return
    y = Vector((-0.08, 1.0, -0.18)).normalized()       # in Godot-Achsen wie leute.gd (Figur blickt nach +Z, ungedreht)
    x = Vector((1, 0, 0)); x = (x - y * x.dot(y)).normalized()
    Bg = Matrix((x, y, x.cross(y))).transposed()
    C = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))       # Godot/glTF -> Blender
    R_ = C @ Bg @ C.inverted()
    ding.matrix_world = Matrix.Translation(p) @ R_.to_4x4()
# CC0 Feinschliff (Fremdpruefung 4c: „Fackel fehlt im Pruefblatt“): Fackel wie held.gd (Stiel 42 cm quer durch die linke Faust, zu
# zwei Dritteln aufgerichtet, Pechkopf, Flamme), nur in den Bildern mit _Fackel
fackel = []
if 'faust_L' in INFO:
    def _teil(prim, farbe, hell, **kw):
        getattr(bpy.ops.mesh, 'primitive_%s_add' % prim)(**kw); o = bpy.context.active_object
        m = bpy.data.materials.new(o.name); m.use_nodes = True; b = m.node_tree.nodes['Principled BSDF']
        b.inputs['Base Color'].default_value = farbe
        if hell: b.inputs['Emission Color'].default_value = farbe; b.inputs['Emission Strength'].default_value = hell
        o.data.materials.append(m); o.hide_render = True; fackel.append(o); return o
    _teil('cylinder', (0.42, 0.28, 0.16, 1), 0, radius=0.019, depth=0.42, vertices=10)
    _teil('uv_sphere', (0.85, 0.32, 0.08, 1), 2.0, radius=0.03, segments=10, ring_count=6)
    _teil('cone', (1.0, 0.62, 0.2, 1), 6.0, radius1=0.05, radius2=0.0, depth=0.2, vertices=12)
def richte_fackel(an):
    for o in fackel: o.hide_render = 'Fackel' not in an
    if not fackel or 'Fackel' not in an: return
    from mathutils import Matrix
    f = INFO['faust_L']; pose = rig.matrix_world @ rig.pose.bones[f['knochen']].matrix
    a = (pose.to_3x3() @ Vector(f['achse'])).normalized()
    if a.z < 0: a = -a
    y = a.lerp(Vector((0, 0, 1)), 0.65).normalized(); p = pose @ Vector(f['griff'])
    R = Vector((0, 0, 1)).rotation_difference(y).to_matrix().to_4x4()
    for o, h in zip(fackel, (0.06, 0.27, 0.40)): o.matrix_world = Matrix.Translation(p + y * h) @ R
def rest():
    for t in rig.animation_data.nla_tracks: t.mute = True
    rig.animation_data.action = None
    for pb in rig.pose.bones:
        pb.location = (0, 0, 0); pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = (1, 0, 0, 0); pb.scale = (1, 1, 1)
    scn.frame_set(1)
def shot(name, az, el, mid, scale, rx, ry):
    scn.render.resolution_x = rx; scn.render.resolution_y = ry
    e = math.radians(el); a = math.radians(az)
    d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
    cam.location = mid + d * 6.0
    cam.rotation_euler = (-d).to_track_quat('-Z', 'Y').to_euler()
    cam.data.ortho_scale = scale
    richte()
    scn.render.filepath = OUT + ('/pbt/' if TEILFARBE else '/pb/') + name + '.png'; bpy.ops.render.render(write_still=True)
# Feinschliff 10 (Fremdpruefung: dunkle Scherben an der Flanke, Ursache unklar; pruef_lagen fuehrte in die Irre): TEILFARBE=1 malt jede
# Lage flach in eigener Farbe (Koerper rot, Kittel gruen, Aermel blau, Rock gelb, Schuerze orange, sonst grau), Rueckseiten ein Viertel so hell;
# Bilder nach <OUT>/pbt
TEILFARBE = os.environ.get('TEILFARBE') == '1'
if TEILFARBE:
    _tn = json.load(open(OUT + '/teile.json')); _f = {'body': (1, 0, 0), 'chain': (0, 0.8, 0), 'sleeves': (0, 0.3, 1), 'tabard': (1, 1, 0), 'apron': (1, 0.5, 0)}
    m = bpy.data.materials.new('teile'); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
    o_ = nt.nodes.new('ShaderNodeOutputMaterial'); em = nt.nodes.new('ShaderNodeEmission'); at = nt.nodes.new('ShaderNodeAttribute')
    at.attribute_name = 'teil'; mp = nt.nodes.new('ShaderNodeMath'); mp.operation = 'DIVIDE'; mp.inputs[1].default_value = len(_tn)
    cr = nt.nodes.new('ShaderNodeValToRGB'); cr.color_ramp.interpolation = 'CONSTANT'
    for i, n in enumerate(_tn):
        e_ = cr.color_ramp.elements[0] if i == 0 else cr.color_ramp.elements.new((i - 0.5) / len(_tn))
        e_.color = (*_f.get(n, (0.5, 0.5, 0.5)), 1)
    gm = nt.nodes.new('ShaderNodeNewGeometry'); mx = nt.nodes.new('ShaderNodeMixRGB'); mx.blend_type = 'MULTIPLY'; mx.inputs[2].default_value = (0.25, 0.25, 0.25, 1)
    nt.links.new(at.outputs['Fac'], mp.inputs[0]); nt.links.new(mp.outputs[0], cr.inputs[0])
    nt.links.new(cr.outputs['Color'], mx.inputs[1]); nt.links.new(gm.outputs['Backfacing'], mx.inputs[0])
    _bg = bpy.data.worlds['w'].node_tree.nodes['Background'].inputs[0]; _bg.default_value = (0.02, 0.02, 0.02, 1)   # Hintergrund fast schwarz
    nt.links.new(mx.outputs[0], em.inputs['Color']); nt.links.new(em.outputs[0], o_.inputs['Surface'])
    me_ = bpy.data.objects['Held_Netz']; me_.data.materials.clear(); me_.data.materials.append(m)
    bpy.data.objects['Plane'].hide_render = True
    os.makedirs(OUT + '/pbt', exist_ok=True); scn.view_settings.view_transform = 'Standard'; scn.cycles.samples = 1
    scn.render.filter_size = 0.01   # harte Kanten, reine Farben zum Zaehlen (pruef_farbe.py)
rest()
# Feinschliff 3 (Fremdpruefung: Zeile 1 und Kopfbilder zeigten Aldric in der Bindehaltung, der Stab neben der leeren Hand, „Spiess im
# Ruecken“): wer etwas traegt, steht dort im ersten Bild von Stehen wie im Spiel (leute.gd haelt die Ansicht --leute dort an)
if ding is not None:
    _st = {t.name: t.strips[0].action for t in rig.animation_data.nla_tracks}.get('Stehen')
    if _st: rig.animation_data.action = _st; scn.frame_set(int(_st.frame_range[0]))
hz = G['neckTop'][0][2] * 0.01 + 0.1
# 348.6 Kopf: Helfer widersprechen sich bei Koepfen von 240 Punkten; KOPFPX=720 fuer Kopfproben
KOPFPX = int(os.environ.get('KOPFPX', '240'))
for n, az in (('a_vorn', 0), ('b_rechts', 90), ('c_hinten', 180), ('d_links', 270)):
    shot(n, az, 45, Vector((0, 0, 0.95)), 2.4, 260, 360)
KOPFEL = float(os.environ.get('KOPFEL', '20'))   # 348.6 Kopf: 45 wie die Spielkamera
for n, az in (('e_kopf_vorn', 0), ('f_kopf_seite', 90), ('g_kopf_hinten', 180)):
    shot(n, az, KOPFEL, Vector((0, G['neckTop'][0][1] * 0.01 - 0.03, hz)), 0.6, KOPFPX, KOPFPX)   # Helfer 4c: Gebeugten hing der Kopf aus dem Bild
# Gehen: Aktion aus der NLA
acts = {t.name: t.strips[0].action for t in rig.animation_data.nla_tracks}
for t in rig.animation_data.nla_tracks: t.mute = True
for an, frames in (('Gehen', None), ('Stehen', [1])):
    if an not in acts: continue
    act = acts[an]; rig.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    fs = frames or [f0, f0 + (f1 - f0) // 4, f0 + (f1 - f0) // 2]
    lauf = stab_lauf(f0, f1) if ding is not None and an == 'Gehen' else {}
    for i, f in enumerate(fs):
        scn.frame_set(f); FUSS[0] = lauf.get(f)
        if an == 'Stehen':
            for j, az in enumerate((0, 90, 270)): shot('h_stehen%d' % j, az, 20, Vector((0, 0, 0.95)), 2.2, 220, 320)
        else: shot('h_%s%d' % (an.lower(), i), 90, 15, Vector((0, 0, 0.95)), 2.2, 260, 320)
# CC0-Geruest Runde 2 (Fremdpruefung Tom 34): beim Helden auch Rennen (seitlich, von hinten: Schild) und die Fackel
for an, az, nm in (('Rennen', 90, 'i_rennen'), ('Rennen', 180, 'i_rennen_hinten'), ('Stehen_Fackel', 60, 'j_fackel_stehen'),
                   ('Gehen_Fackel', 90, 'j_fackel_gehen'), ('Rennen_Fackel', 90, 'j_fackel_rennen')):
    if an not in acts: continue
    act = acts[an]; rig.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    for i, f in enumerate((f0, f0 + (f1 - f0) // 3) if nm.startswith('i') else (f0 + (f1 - f0) // 4,)):
        scn.frame_set(f); richte_fackel(an); shot('%s%d' % (nm, i), az, 15, Vector((0, 0, 0.95)), 2.2, 260, 320)
richte_fackel('-'); FUSS[0] = None
# Feinschliff 4 (Helfer: Aermelzacken, Spalt hinter der Schulter sind im ganzen Bild nur wenige Bildpunkte): Schultern nah, Stehen und
# Gehen (Mitte), von hinten links und rechts und seitlich
sz = G['chestTop'][0][2] * 0.01
for an in ('Stehen', 'Gehen'):
    if an not in acts: continue
    act = acts[an]; rig.animation_data.action = act; f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    scn.frame_set(f0 if an == 'Stehen' else f0 + (f1 - f0) // 2)
    for n, az in (('l', 90), ('hl', 135), ('hr', 225), ('r', 270)):
        shot('k_%s_%s' % (an.lower(), n), az, 15, Vector((0, 0, sz)), 0.75, 240, 240)
# 348.6 Haende (Helfer Godot nah: linke Hand Halbmond, Schwerthand „O“-Faust): HANDNAH=1 je Hand im Stehen, 45 Grad wie die
# Spielkamera, von vorn, aussen und hinten
if os.environ.get('HANDNAH') == '1' and 'Stehen' in acts:
    act = acts['Stehen']; rig.animation_data.action = act; scn.frame_set(int(act.frame_range[0]))
    for b, s in (('hand_r', 'r'), ('hand_l', 'l')):
        pb_ = rig.pose.bones[b]; c_ = rig.matrix_world @ ((pb_.head + pb_.tail) * 0.5)
        for n, az in (('vorn', 0), ('aussen', 90 if s == 'r' else 270), ('hinten', 180)):
            shot('m_hand%s_%s' % (s, n), az, 45, c_, 0.32, 360, 360)
print('PB OK')
