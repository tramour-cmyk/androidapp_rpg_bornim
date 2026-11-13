# Held v3 fuer die Engine: Albedo (mit Abnutzung) in Eckfarben backen, alles zu einem Netz, Skelett mit Gewichten,
# Bewegungen Gehen und Stehen (Fuesse automatisch am Boden), Ausgabe held.glb in Metern (348.6, Modellregel 1; gebaut wird intern in Zentimetern).
# Aufruf: OUT=<ordner> python -I rig.py   (vorher held3.py mit demselben OUT)
import bpy, math, os, json, re
import numpy as np
from mathutils import Vector, Matrix, Quaternion

FIGUR = os.environ.get('FIGUR', 'held')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3.blend')
G = json.load(open(OUT + '/gelenke.json'))
J = {k: (Vector(v[0]), v[1][0]) for k, v in G['J'].items()}
E = [tuple(e) for e in G['E']]
scn = bpy.context.scene

# ---------------------------------------------------------------- 1. Albedo backen (Material-Ausgang auf die Emission "albedo")
for m in bpy.data.materials:
    if not m.node_tree or 'M_out' not in m.node_tree.nodes: continue
    nt = m.node_tree; out = nt.nodes['M_out']
    for l in list(out.inputs['Surface'].links): nt.links.remove(l)
    nt.links.new(nt.nodes['M_albedo'].outputs[0], out.inputs['Surface'])
scn.render.engine = 'CYCLES'; scn.cycles.samples = 4; scn.cycles.device = 'CPU'
meshes = [o for o in bpy.data.objects if o.type == 'MESH']
# 348.5: Albedo in ein Bild backen (statt Eckfarben): Gewebe, Ringe, Abnutzung und Gesicht bleiben scharf
ATLAS = int(os.environ.get('ATLAS', '2048'))
img = bpy.data.images.new('held_albedo', ATLAS, ATLAS, alpha=False, float_buffer=False)
for o in meshes:
    me = o.data
    if o.modifiers:   # Modifikatoren (Solidify am Schild) vorher anwenden, damit das Netz dem Bild entspricht
        dg = bpy.context.evaluated_depsgraph_get(); new = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
        o.modifiers.clear(); o.data = new; me = new
    while me.uv_layers: me.uv_layers.remove(me.uv_layers[0])
    me.uv_layers.new(name='UVMap')
for m in bpy.data.materials:
    if not m.node_tree or 'M_out' not in m.node_tree.nodes: continue
    nt = m.node_tree; ea = nt.nodes['M_albedo']
    at = next((n for n in nt.nodes if n.type == 'ATTRIBUTE' and n.attribute_name == 'ink'), None)
    if at and ea.inputs['Color'].links:   # Gesichtslinien (Brauen, Lidstrich) als dunkle Tusche ins Albedo
        src = ea.inputs['Color'].links[0].from_socket
        f1 = nt.nodes.new('ShaderNodeMath'); f1.operation = 'MULTIPLY'; f1.use_clamp = True; nt.links.new(at.outputs['Fac'], f1.inputs[0]); f1.inputs[1].default_value = 1.4
        f2 = nt.nodes.new('ShaderNodeMath'); f2.operation = 'MULTIPLY_ADD'; nt.links.new(f1.outputs[0], f2.inputs[0]); f2.inputs[1].default_value = -0.85; f2.inputs[2].default_value = 1.0
        vm = nt.nodes.new('ShaderNodeVectorMath'); vm.operation = 'SCALE'; nt.links.new(src, vm.inputs[0]); nt.links.new(f2.outputs[0], vm.inputs['Scale'])
        nt.links.new(vm.outputs[0], ea.inputs['Color'])
    tn = nt.nodes.new('ShaderNodeTexImage'); tn.image = img; nt.nodes.active = tn
bpy.ops.object.select_all(action='DESELECT')
for o in meshes: o.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.004, scale_to_bounds=False)
# Runde 7 (Pupillen blass, Grau 146-189 statt 80-92): smart_project zerlegte den Augapfel in viele kleine Inseln; in der Nahstufe
# (1,6 px je cm) mischen die Mipmaps die Pupille mit fremden Rändern zu Grau. Augen von vorn projiziert, eine Insel je Halbkugel
bpy.ops.object.mode_set(mode='OBJECT')
for o in meshes:
    if not o.name.startswith('eye'): continue
    me = o.data; uvd = me.uv_layers.active.data; r = max(v.co.length for v in me.vertices)
    for p in me.polygons:
        back = p.center.y > 0   # vorn ist -y
        for li in p.loop_indices:
            co = me.vertices[me.loops[li].vertex_index].co
            uvd[li].uv = (co.x / (2 * r) + 0.5 + (1.2 if back else 0.0), co.z / (2 * r) + 0.5)
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.select_all(action='SELECT'); bpy.ops.uv.average_islands_scale()   # Augeninseln auf die Dichte des Rests
bpy.ops.uv.pack_islands(margin=0.004)
bpy.ops.object.mode_set(mode='OBJECT')
scn.render.bake.target = 'IMAGE_TEXTURES'; scn.render.bake.margin = 6
bpy.ops.object.bake(type='EMIT')
img.filepath_raw = OUT + '/held-albedo.png'; img.file_format = 'PNG'; img.save()
for o in meshes:
    me = o.data
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'POINT')
    c = np.ones(len(me.vertices) * 4, np.float32); ca.data.foreach_set('color', c)
    me.color_attributes.active_color = ca
print('BAKE OK', len(meshes))

# ---------------------------------------------------------------- 2. Skelett neu: je Kante ein Knochen, Wurzel am Boden
old = bpy.data.objects.get('rig')
if old: bpy.data.objects.remove(old)
arm = bpy.data.armatures.new('skelett'); rig = bpy.data.objects.new('Held_Skelett', arm); scn.collection.objects.link(rig)
bpy.context.view_layer.objects.active = rig; bpy.ops.object.mode_set(mode='EDIT')
root = arm.edit_bones.new('root'); root.head = (0, 0, 0); root.tail = (0, 0, 20); root.roll = 0
EB = {}
for a, b in E:
    bn = arm.edit_bones.new(a + '-' + b); bn.head = J[a][0]; bn.tail = J[b][0]; EB[(a, b)] = bn
for (a, b), bn in EB.items():
    par = [EB[e] for e in EB if e[1] == a]
    bn.parent = par[0] if par else root
    bn.use_connect = False
bpy.ops.object.mode_set(mode='OBJECT')
BONES = [a + '-' + b for a, b in E]
PARENT = {bn.name: bn.parent.name for bn in arm.bones if bn.parent}

# ---------------------------------------------------------------- 3. Gewichte
def seg_dist(V, a, b):
    A, ra = np.array(J[a][0]), J[a][1]; B, rb = np.array(J[b][0]), J[b][1]
    ab = B - A; t = np.clip(((V - A) @ ab) / max(ab @ ab, 1e-9), 0, 1)
    return np.linalg.norm(V - (A + t[:, None] * ab), axis=1) - (ra + (rb - ra) * t)
RIGID = {}
for o in meshes:
    n = o.name
    if n.startswith(('head', 'helm', 'nasal', 'eye', 'lid', 'ear', 'hair', 'tuch', 'hood', 'beard', 'circlet')): RIGID[n] = 'neck-neckTop'   # 348.6 Leute
    elif n.startswith(('shield', 'boss')): RIGID[n] = 'chest-chestTop'
    elif n.startswith(('clasp', 'sun')): RIGID[n] = 'chest-chestTop'
    elif n.startswith(('Cylinder', 'Sphere', 'buckle')): RIGID[n] = 'pelvis-waist'    # Schwert und Scheide an der Huefte
    elif n == 'handR': RIGID[n] = 'foR-wrR'
    elif n == 'handL': RIGID[n] = 'foL-wrL'
TRUNK = ['pelvis-waist', 'waist-belly', 'belly-chest', 'chest-chestTop']
CLOTH = {'tabard': 0.75, 'tabard.001': 0.75, 'cloak': 0.4, 'robe': 0.6, 'apron': 0.6}       # Anteil, den der Stoff den Oberschenkeln folgt
HZ = J['hipR'][0][2] * 92.0 / 85.0; HR = 30.0 * HZ / 92.0   # 348.6 Leute Runde 2: Huefte aus dem Geruest (Kind, Zwerg), Held wie bisher 92 und 30
for o in meshes:
    me = o.data; V = np.array([o.matrix_world @ v.co for v in me.vertices])
    vg = {}
    def put(bone, idx, w):
        g = vg.get(bone) or o.vertex_groups.new(name=bone); vg[bone] = g
        for i, x in zip(idx, w):
            if x > 1e-3: g.add([int(i)], float(x), 'REPLACE')
    if o.name in RIGID:
        put(RIGID[o.name], range(len(V)), np.ones(len(V))); continue
    if o.name in CLOTH:
        k = CLOTH[o.name]
        D = np.stack([seg_dist(V, *b.split('-')) for b in TRUNK], 1)
        tw = np.zeros(len(V));
        for s in 'RL':
            dl = seg_dist(V, 'hip' + s, 'thigh' + s); dk = seg_dist(V, 'thigh' + s, 'knee' + s)
            if FIGUR == 'held':
                side = (V[:, 0] * (-1 if s == 'R' else 1)) > -3       # P(r,...) -> x = -r: rechts ist x < 0
                prox = 1.0
            else:   # 348.6 Leute: weich ueber die Mitte (Helfer: Saeume kippten hart)
                side = np.clip(0.5 + (V[:, 0] * (-1 if s == 'R' else 1)) / 8.0, 0, 1)
                prox = 1.0
            w = np.clip((HZ - V[:, 2]) / HR, 0, 1) * k * side * prox * (V[:, 2] < HZ)
            put('hip' + s + '-thigh' + s, range(len(V)), w * 0.6)
            put('thigh' + s + '-knee' + s, range(len(V)), w * 0.4)
            tw += w
        nb = np.argmin(D, 1)
        for i, b in enumerate(TRUNK): put(b, np.where(nb == i)[0], (1 - tw)[nb == i])
        continue
    D = np.stack([seg_dist(V, *b.split('-')) for b in BONES], 1)
    b0 = np.argmin(D, 1)
    W = np.zeros_like(D)
    for i in range(len(V)):
        nm = BONES[b0[i]]
        cand = [nm] + ([PARENT[nm]] if PARENT.get(nm) in BONES else []) + [c for c, p in PARENT.items() if p == nm]
        ci = [BONES.index(c) for c in cand]
        d = D[i, ci]; w = np.clip(1 - (d - d.min()) / 3.0, 0, 1) ** 2
        W[i, ci] = w / w.sum()
    for k_, b in enumerate(BONES): put(b, np.where(W[:, k_] > 0)[0], W[W[:, k_] > 0, k_])
print('WEIGHTS OK')

# ---------------------------------------------------------------- 4. ein Netz, ein Material (Farbe aus den Eckfarben)
mat = bpy.data.materials.new('held'); mat.use_nodes = True
nt = mat.node_tree; bsdf = nt.nodes['Principled BSDF']; ti = nt.nodes.new('ShaderNodeTexImage')
ti.image = bpy.data.images.load(OUT + '/held-albedo.png')
nt.links.new(ti.outputs['Color'], bsdf.inputs['Base Color']); bsdf.inputs['Roughness'].default_value = 1.0
for o in meshes:
    o.data.materials.clear(); o.data.materials.append(mat)
    for a in [a.name for a in o.data.attributes if a.name in ('ink', 'lip', 'brow', 'rim')]: o.data.attributes.remove(o.data.attributes[a])
bpy.ops.object.select_all(action='DESELECT')
for o in meshes: o.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
# Runde 5 (1): der Abbau auf 6000 Dreiecke legte die Kugel des Augapfels schief, die Pupille rutschte zur Nase (Held schielt;
# nachgemessen am Riggmodell: links 30 px, rechts 21 px bei 400 px je 16 cm; ohne Abbau mittig). Augaepfel bleiben ganz
# (nur sie: mit Kopfrand blieb Blender ueber 6000, ein zweiter Gang ohne Gruppe zerstoerte Umhang und Helm; so rechts noch 0,6 cm innen, links mittig)
for o in meshes:
    if o.name.startswith('eye'): o.vertex_groups.new(name='fest').add(list(range(len(o.data.vertices))), 1.0, 'REPLACE')
for o in meshes:
    mw = o.matrix_world.copy(); o.parent = None; o.matrix_world = mw
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
bpy.ops.object.join()
held = bpy.context.active_object; held.name = 'Held_Netz'
for p in held.data.polygons: p.use_smooth = True
for x in [o for o in bpy.data.objects if o.type == 'EMPTY']: bpy.data.objects.remove(x)
# Modellregel 7: Figur hoechstens 6000 Dreiecke (DREIECKE=…); Farbe steckt seit 348.5 im Bild, nicht in den Ecken
ziel = int(os.environ.get('DREIECKE', '6000'))
drei = sum(len(p.vertices) - 2 for p in held.data.polygons)
print('DREIECKE vorher', drei)
if ziel > 0 and drei > ziel:
    dec = held.modifiers.new('duenn', 'DECIMATE'); dec.ratio = ziel / drei; dec.use_collapse_triangulate = True
    if 'fest' in held.vertex_groups: dec.vertex_group = 'fest'; dec.invert_vertex_group = True; dec.vertex_group_factor = 1000.0
    bpy.context.view_layer.objects.active = held; bpy.ops.object.modifier_apply(modifier='duenn')
held.parent = rig
md = held.modifiers.new('skelett', 'ARMATURE'); md.object = rig
print('NETZ', len(held.data.vertices), 'Ecken', sum(len(p.vertices) - 2 for p in held.data.polygons), 'Dreiecke')

# ---------------------------------------------------------------- 5. Bewegungen
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode='POSE')
PB = rig.pose.bones
for pb in PB: pb.rotation_mode = 'QUATERNION'
def rot_world(name, axis, deg):
    """Drehung um eine Weltachse als lokale Knochendrehung (alle Ketten drehen um dieselbe Querachse)."""
    M3 = arm.bones[name].matrix_local.to_3x3()
    R = Matrix.Rotation(math.radians(deg), 3, axis)
    return (M3.inverted() @ R @ M3).to_quaternion()
def rot_world2(name, steps):
    M3 = arm.bones[name].matrix_local.to_3x3(); R = Matrix.Identity(3)
    for axis, deg in steps: R = Matrix.Rotation(math.radians(deg), 3, axis) @ R
    return (M3.inverted() @ R @ M3).to_quaternion()
def bump(x, c, w):
    d = (x - c + 0.5) % 1.0 - 0.5
    return math.exp(-(d / w) ** 2)
X = Vector((1, 0, 0)); Y = Vector((0, 1, 0)); Zx = Vector((0, 0, 1))
# 348.6 Leute (Chef 25.10., 17:03: Kind flotter, Dame schreitet, alter Bauer langsam, schleift ein Bein): Gang je Figur
# aus leute.json "gang"; ohne Angabe der Held: takt Bilder je Doppelschritt, schritt Huefte, knie Anheben, arm Schwung,
# vor Grad vorgebeugt, huefte Grad Wiegen, hinken 0..1 auf der Seite "seite" (Fuss schleift, Koerper sackt beim Auftreten)
GANG = dict(takt=32, schritt=1.0, knie=1.0, arm=1.0, vor=0.0, huefte=0.0, hinken=0.0, seite='L')
if FIGUR != 'held':
    GANG.update(json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'leute.json')))[FIGUR].get('gang', {}))
# Vorbeugen = negative Drehung um X (der Held blickt nach -Y)
def leg(ph, lahm=0.0):
    hip = 22 * GANG['schritt'] * (1 - 0.35 * lahm) * math.cos(2 * math.pi * ph) - 3
    knee = 14 * bump(ph, 0.1, 0.07) + 62 * GANG['knie'] * (1 - 0.8 * lahm) * bump(ph, 0.72, 0.11)
    # lahmes Bein: kaum Abdruck, die Fussspitze haengt im Schwung und schleift (Spitze nach unten)
    ank = 9 * bump(ph, 0.38, 0.12) - 16 * (1 - 0.8 * lahm) * bump(ph, 0.6, 0.06) + 6 * bump(ph, 0.85, 0.08) - 18 * lahm * bump(ph, 0.75, 0.12)
    return hip, knee, ank
def pose_walk(ph):
    for s, off in (('R', 0.0), ('L', 0.5)):
        h, k, a = leg((ph + off) % 1, GANG['hinken'] if s == GANG['seite'] else 0.0)
        PB['hip%s-thigh%s' % (s, s)].rotation_quaternion = rot_world('hip%s-thigh%s' % (s, s), X, -h)
        PB['knee%s-calf%s' % (s, s)].rotation_quaternion = rot_world('knee%s-calf%s' % (s, s), X, k)
        for b in ('ankle%s-heel%s' % (s, s), 'ankle%s-ball%s' % (s, s)):
            PB[b].rotation_quaternion = rot_world(b, X, -a)
        sw = -25 * GANG['arm'] * math.cos(2 * math.pi * (ph + off))   # Arm gegen das Bein
        ab = 7 if s == 'R' else -7                                  # Arm etwas abgespreizt: Hand vorbei am Wappenrock
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world2('sh%s-up%s' % (s, s), [(X, -sw), (Y, ab)])
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -(12 + 8 * max(0, math.cos(2 * math.pi * (ph + off + 0.5)))))
    tw = 5 * math.cos(2 * math.pi * ph)
    # Wiegen der Huefte (Seitenneigung um die Blickachse Y) und Einsacken auf dem lahmen Bein (Standphase um 0,25)
    lahm_ph = 0.5 if GANG['seite'] == 'L' else 0.0
    roll = GANG['huefte'] * math.sin(2 * math.pi * ph) + 9 * GANG['hinken'] * bump(ph, lahm_ph + 0.25, 0.14) * (1 if GANG['seite'] == 'L' else -1)
    # Rumpf: positive Drehung um X neigt nach vorn (Blick -Y); der Held bleibt bei -4 wie bisher
    PB['pelvis-waist'].rotation_quaternion = rot_world2('pelvis-waist', [(X, -4 + GANG['vor']), (Y, roll)])
    PB['belly-chest'].rotation_quaternion = rot_world2('belly-chest', [(Zx, -tw), (Y, -0.6 * roll)])
def pose_idle(ph):
    br = math.sin(2 * math.pi * ph)
    PB['belly-chest'].rotation_quaternion = rot_world('belly-chest', X, 1.2 * br)
    PB['chest-chestTop'].rotation_quaternion = rot_world('chest-chestTop', X, -0.8 * br)
    PB['neck-neckTop'].rotation_quaternion = rot_world('neck-neckTop', Zx, 3 * math.sin(2 * math.pi * ph * 1))
    for s in 'RL':
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world('sh%s-up%s' % (s, s), X, 1.5 * br)
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -6)
FOOT = [(s, b, r) for s in 'RL' for b, r in (('ankle%s-heel%s', 'heel%s'), ('ankle%s-ball%s', 'ball%s'), ('ball%s-toe%s', 'toe%s'))]
def ground():
    """Wurzel so heben/senken, dass der tiefere Fuss gerade den Boden beruehrt; liefert Fusspunkte."""
    PB['root'].location = (0, 0, 0); bpy.context.view_layer.update()
    pts = []
    for s, b, r in FOOT:
        pb = PB[b % (s, s)]; p = rig.matrix_world @ pb.tail
        pts.append((s, p, J[r % s][1]))
    low = min(p.z - rr for _, p, rr in pts)
    PB['root'].location = arm.bones['root'].matrix_local.to_3x3().inverted() @ Vector((0, 0, -low))
    bpy.context.view_layer.update()
    return pts, low
def clear():
    for pb in PB: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
INFO = {}
def bake_action(name, n, fn, measure=False):
    act = bpy.data.actions.new(name); act.use_fake_user = True
    rig.animation_data_create(); rig.animation_data.action = act
    ys = []
    for f in range(n + 1):
        clear(); fn((f % n) / n); pts, low = ground()
        if measure:
            lowest = min(pts, key=lambda q: q[1].z - q[2]); ys.append((lowest[0], lowest[1].y))
        for pb in PB:
            pb.keyframe_insert('rotation_quaternion', frame=f + 1); pb.keyframe_insert('location', frame=f + 1)
    tr = rig.animation_data.nla_tracks.new(); tr.name = name; tr.strips.new(name, 1, act)
    rig.animation_data.action = None
    if measure:   # Fussgleiten: wie schnell wandert der Standfuss nach hinten (cm je Bild)
        d = [ys[i + 1][1] - ys[i][1] for i in range(len(ys) - 1) if ys[i][0] == ys[i + 1][0]]
        INFO[name + '_cm_je_bild'] = float(np.median(d))
    return act
FPS = 30; scn.render.fps = FPS
bake_action('Gehen', int(GANG['takt']), pose_walk, measure=True)
bake_action('Stehen', 90, pose_idle)
# 1141 (Chef 13.11., 14:36: Goblins, Schamane „wie Playmobil-Figuren umfallen. Und zwar alle auf die gleiche Seite“): die Goblins
# (goblin.py baut alle vier Arten mit dieser Datei) hatten keine Sterbebewegung, figur.gd kippte sie steif um 80°. Jetzt drei wie
# im alten Spiel (FoeArt.kt deaths): Knie geben nach und vornüber aufs Gesicht, Arme vor sich; vom Schlag zurückgeworfen auf den
# Rücken, Arme weit; herumgerissen aufs Knie und zur Seite. Schlüsselbilder als Zusatz auf Bild 0 der Ruhe (Lauer bei Goblins), so
# behält jede Art ihre Arme; Grad um die Weltachsen (Vorbeugen +X am Rumpf, Bein und Arm nach vorn -X, Y + nach rechts, Zx Hochachse).
# Am Boden hält das Netz selbst (tiefste Ecke auf 0), nicht die Füße: liegend steckte sonst der Rumpf im Boden.
RUHE0 = globals().get('pose_lauer', pose_idle)
GERADE = Quaternion((1, 0, 0, 0))
RUMPF = ['pelvis-waist', 'waist-belly', 'belly-chest', 'chest-chestTop']     # Hals nicht: das Gerüst ist gebeugt gebaut (goblin.py gebeugt), gerade hinge der Kopf auf die Brust
HUEFTE = ['hipR-thighR', 'hipL-thighL', 'thighR-kneeR', 'thighL-kneeL']
KNIE = ['kneeR-calfR', 'kneeL-calfL', 'ankleR-heelR', 'ankleL-heelL', 'ankleR-ballR', 'ankleL-ballL']
def _q(name, d):
    return rot_world2(name, [(X, d[0]), (Y, d[1]), (Zx, d[2])])
def _glatt(u):
    return u * u * (3 - 2 * u)
def beide(d, r, l=None):
    """Knochenname mit S, Werte für rechts (l: links, sonst gespiegelt: Y und Zx umgekehrt)"""
    return {d.replace('S', 'R'): r, d.replace('S', 'L'): l if l is not None else (r[0], -r[1], -r[2])}
ARME = ['shR-upR', 'shL-upL', 'elR-foR', 'elL-foL']
def gerade(f_rumpf, f_huefte, f_knie, f_arme=0.0):
    """Anteil, um den die Ruhe (Lauer: Rumpf 40° vor, Knie 68° gebeugt, Arme vor der Brust) zur geraden Haltung zurückgeht:
    liegend ein Körper, die toten Arme hängen am Leib (1141, Chef 16:17: „Gliedmaßen … schwerkraftmäßig nach unten“)"""
    return dict([(b, f_rumpf) for b in RUMPF] + [(b, f_huefte) for b in HUEFTE] + [(b, f_knie) for b in KNIE] + [(b, f_arme) for b in ARME])
def _tod_pose(keys, t):
    """keys: [(Zeit s, {Knochen: (x, y, z) Grad}, {Knochen: Anteil gerade}, Anteil zur Mitte[, Anker])]; liefert (Anteil zur Mitte,
    Anker des Abschnitts bis zu diesem Schlüssel: 'fuss' oder 'knie', 1141 r3)"""
    for i in range(len(keys) - 1):
        if t <= keys[i + 1][0] or i == len(keys) - 2: break
    (ta, ka, ga, za), (tb, kb, gb, zb) = keys[i][:4], keys[i + 1][:4]
    anker = keys[i + 1][4] if len(keys[i + 1]) > 4 else 'fuss'
    u = _glatt(min(1.0, max(0.0, (t - ta) / max(tb - ta, 1e-6))))
    for b in set(ka) | set(kb) | set(ga) | set(gb):
        a_, b_ = ka.get(b, (0, 0, 0)), kb.get(b, (0, 0, 0))
        d = tuple(a_[j] + (b_[j] - a_[j]) * u for j in range(3))
        g = ga.get(b, 0.0) + (gb.get(b, 0.0) - ga.get(b, 0.0)) * u
        q0 = PB[b].rotation_quaternion.copy()
        if g > 0: q0 = q0.slerp(GERADE, g)
        PB[b].rotation_quaternion = _q(b, d) @ q0
    return za + (zb - za) * u, anker
def _knie_xy():
    """Mitte der Knie in Weltlage (bei Wurzel am Ursprung)"""
    k = [rig.matrix_world @ PB[b].head for b in ('kneeR-calfR', 'kneeL-calfL')]
    return (k[0].x + k[1].x) / 2, (k[0].y + k[1].y) / 2
def _boden_netz(z, schub=(0.0, 0.0)):
    """tiefste Ecke des Netzes auf den Boden; z: Anteil, um den die Mitte des Netzes über den Ursprung rückt (liegend bleibt der
    Körper, wo er stand, statt eine Körperlänge vor oder hinter seinen Füßen zu liegen); schub: Weg der Wurzel waagerecht (Anker Knie)"""
    PB['root'].location = (0, 0, 0); bpy.context.view_layer.update()
    ev = held.evaluated_get(bpy.context.evaluated_depsgraph_get()); me = ev.to_mesh()
    co = np.empty(len(me.vertices) * 3, np.float32); me.vertices.foreach_get('co', co)
    mw = np.array(ev.matrix_world); W = co.reshape(-1, 3) @ mw[:3, :3].T + mw[:3, 3]
    ev.to_mesh_clear()
    low = float(W[:, 2].min()); cx, cy = float(W[:, 0].mean()), float(W[:, 1].mean())
    PB['root'].location = arm.bones['root'].matrix_local.to_3x3().inverted() @ Vector((-cx * z + schub[0], -cy * z + schub[1], -low))
    return low
KOB_ = FIGUR.startswith('kobold')
KNIE_LIEGT = -45 if KOB_ else -20     # liegend standen die Unterschenkel hoch (Gerüst gebeugt gebaut, goblin.py gebeugt; Kobold dazu kurze Beine, beine 0,5)
def schwanz(a):
    """Kobold: der Schwanz hängt starr an pelvis-hipR (goblin.py); liegend zeigte er auf dem Bauch in den Himmel, auf dem Rücken in
    den Boden (wie alt, Doll.kt: er liegt längs der Beine). Das rechte Bein dreht gegen, es bleibt, wo es war"""
    return {'pelvis-hipR': (a, 0, 0), 'hipR-thighR': (-a, 0, 0)} if KOB_ else {}
def _plus(k, d):
    """Zusatz [d] auf die Schlüsselhaltung [k] (Grad addiert)"""
    k = dict(k)
    for b, v in d.items():
        w = k.get(b, (0, 0, 0)); k[b] = tuple(w[j] + v[j] for j in range(3))
    return k
# 1141 r2 (Chef 16:17 zu den Filmen: „die fallen alle mit Schwerpunkt dahin, wo sie halt standen … als würden ihm die Beine nach
# hinten weggezogen“; „seitlich … Beine breit, Arme abgespreizt“): der Drehpunkt sind die Füße, sie bleiben stehen (keine Mitte mehr,
# Anteil 0); vornüber landet der Kopf eine Körperlänge vorn, rücklings hinten. Die Glieder werden schlaff: Arme hängen am Leib,
# Beine gerade und beieinander, nichts abgespreizt
def tod_vorn():
    """Knie geben ein wenig nach, dann kippt er über die Füße vornüber aufs Gesicht, die Arme schlaff am Leib"""
    k1 = {'pelvis-waist': (-10, 0, 0), 'belly-chest': (-8, 0, 0), 'neck-neckTop': (-16, 0, 0)}
    k2 = {'root': (8, 0, 0), 'pelvis-waist': (6, 0, 0), 'neck-neckTop': (8, 0, 0), **beide('kneeS-calfS', (12, 0, 0))}
    k3 = {'root': (45, 0, 0), 'neck-neckTop': (-8, 0, 10), **beide('shS-upS', (-15, 6, 0))}
    k4 = {'root': (88, 0, 0), 'neck-neckTop': (-14, 0, 40), **beide('kneeS-calfS', (KNIE_LIEGT + 8, 0, 0)),
          **beide('shS-upS', (-6, 10, 0)), **beide('elS-foS', (8, 0, 0))}
    g2, g3, g4 = gerade(0.2, 0.2, 0.0, 0.5), gerade(0.6, 0.6, 0.5, 0.85), gerade(0.95, 0.95, 0.9, 1.0)
    k3, k4 = _plus(k3, schwanz(-30)), _plus(k4, schwanz(-70))
    return [(0.0, {}, {}, 0.0), (0.14, k1, {}, 0.0), (0.45, k2, g2, 0.0), (0.8, k3, g3, 0.0), (1.08, k4, g4, 0.0),
            (1.2, dict(k4, root=(91, 0, 0)), g4, 0.0), (1.38, dict(k4, root=(89, 0, 0)), g4, 0.0), (1.55, dict(k4, root=(89, 0, 0)), g4, 0.0)]
def tod_rueck():
    """vom Schlag zurückgeworfen: richtet sich auf und kippt über die Fersen auf den Rücken, die Arme schlaff zur Seite"""
    k1 = {'root': (-5, 0, 0), 'pelvis-waist': (-20, 0, 0), 'belly-chest': (-14, 0, 0), 'neck-neckTop': (-26, 0, 0)}
    k2 = {'root': (-22, 0, 0), 'pelvis-waist': (-10, 0, 0), 'neck-neckTop': (-12, 0, 0), **beide('kneeS-calfS', (10, 0, 0)),
          **beide('shS-upS', (20, 12, 0))}
    k3 = {'root': (-87, 0, 0), 'neck-neckTop': (-34, 0, -30), 'chestTop-neck': (-10, 0, 0), **beide('kneeS-calfS', (KNIE_LIEGT + 12, 0, 0)),
          **beide('shS-upS', (4, 22, 0)), **beide('elS-foS', (10, 0, 0))}
    g2, g3 = gerade(0.5, 0.3, 0.0, 0.6), gerade(0.95, 0.9, 0.85, 1.0)
    k3 = _plus(k3, schwanz(-40))
    return [(0.0, {}, {}, 0.0), (0.16, k1, gerade(0.3, 0.0, 0.0, 0.2), 0.0), (0.5, k2, g2, 0.0), (1.0, k3, g3, 0.0),
            (1.13, dict(k3, root=(-90, 0, 0)), g3, 0.0), (1.32, dict(k3, root=(-88, 0, 0)), g3, 0.0), (1.5, dict(k3, root=(-88, 0, 0)), g3, 0.0)]
# 1141 r4 (Chef 13.11., 18:25: „Seitlich haben wir genau das gleiche Problem wie vorwärts und rückwärts, nämlich, dass die Beine
# weggezogen werden, weil anscheinend wieder der Nabel auf die Unfallstelle fällt … auch da einfach von den Füßen weg zur Seite
# umkippen“): r3 sackte über den stehenden Füßen auf die Knie (das Becken blieb über dem Standplatz) und kippte dann über die Knie.
# Jetzt wie tod_vorn, nur zur Seite: die Füße bleiben stehen und sind der Drehpunkt, die Knie geben wenig nach, der Körper kippt
# gestreckt zur Seite, der Kopf landet eine Körperlänge neben den Füßen; liegend Beine beieinander, oberer Arm vor dem Leib
def tod_seite():
    """kippt über die stehenden Füße zur Seite (nach links; spiegel(tod_seite()) ergibt Tod4)"""
    k1 = {'root': (0, -3, 0), 'pelvis-waist': (-6, 0, 12), 'neck-neckTop': (-12, 0, 18)}
    k2 = {'root': (3, -10, 4), 'pelvis-waist': (4, -6, 8), 'neck-neckTop': (10, 6, 8), **beide('kneeS-calfS', (14, 0, 0))}
    k3 = {'root': (4, -48, 5), 'neck-neckTop': (6, 10, 6), **beide('kneeS-calfS', (10, 0, 0)), 'shR-upR': (-12, 0, 0)}
    k4 = {'root': (4, -88, 5), 'pelvis-waist': (6, 4, 0), 'neck-neckTop': (4, -12, 6), **beide('kneeS-calfS', (KNIE_LIEGT + 14, 0, 0)),
          **beide('hipS-thighS', (-10, 0, 0)), 'shR-upR': (-30, 0, 0), 'elR-foR': (20, 0, 0), 'shL-upL': (-6, 0, 0), 'elL-foL': (10, 0, 0)}
    g2, g3, g4 = gerade(0.3, 0.2, 0.0, 0.6), gerade(0.7, 0.6, 0.5, 0.9), gerade(0.95, 0.9, 0.85, 1.0)
    return [(0.0, {}, {}, 0.0), (0.14, k1, gerade(0.1, 0.0, 0.0, 0.3), 0.0), (0.45, k2, g2, 0.0), (0.8, k3, g3, 0.0), (1.08, k4, g4, 0.0),
            (1.2, dict(k4, root=(4, -91, 5)), g4, 0.0), (1.38, dict(k4, root=(4, -89, 5)), g4, 0.0), (1.55, dict(k4, root=(4, -89, 5)), g4, 0.0)]
def _spiegel_name(b):
    return re.sub(r'(?<=[a-z])([RL])(?=-|$)', lambda m: 'L' if m.group(1) == 'R' else 'R', b)
def spiegel(keys):
    """dieselbe Bewegung zur anderen Seite: links und rechts getauscht, Drehung um Y (seitwärts) und die Hochachse umgekehrt
    (1141 r3: statt das Modell im Spiel zu spiegeln, das tauschte die Waffenhand, Chef 17:16)"""
    aus = []
    for k in keys:
        rot = {_spiegel_name(b): (v[0], -v[1], -v[2]) for b, v in k[1].items()}
        ger = {_spiegel_name(b): v for b, v in k[2].items()}
        aus.append((k[0], rot, ger) + tuple(k[3:]))
    return aus
def bake_tod(name, keys):
    act = bpy.data.actions.new(name); act.use_fake_user = True
    rig.animation_data_create()
    for t_ in rig.animation_data.nla_tracks: t_.mute = True
    rig.animation_data.action = act
    n = int(round(keys[-1][0] * FPS)); lows = []; ref = None
    for f in range(n + 1):
        clear(); RUHE0(0.0); z, anker = _tod_pose(keys, f / FPS); schub = (0.0, 0.0)
        if anker == 'knie':     # 1141 r3: die Knie bleiben, wo sie beim ersten Bild dieses Ankers waren (Drehpunkt Knie statt Füße)
            PB['root'].location = (0, 0, 0); bpy.context.view_layer.update(); kx, ky = _knie_xy()
            if ref is None: ref = (kx, ky)
            schub = (ref[0] - kx, ref[1] - ky)
        lows.append(_boden_netz(z, schub))
        for pb in PB:
            pb.keyframe_insert('rotation_quaternion', frame=f + 1); pb.keyframe_insert('location', frame=f + 1)
    for t_ in rig.animation_data.nla_tracks: t_.mute = False
    spur = rig.animation_data.nla_tracks.new(); spur.name = name; spur.strips.new(name, 1, act)   # anders geschrieben als in bake_action: goblin.py sucht dort genau eine Stelle
    rig.animation_data.action = None
    INFO[name + '_s'] = n / FPS; INFO[name + '_gehoben_cm'] = round(-min(lows), 1)     # so weit hob der Boden das Netz höchstens an
if os.environ.get('TOD', '1') != '0':
    for nm_, k_ in (('Tod', tod_vorn()), ('Tod2', tod_rueck()), ('Tod3', tod_seite()), ('Tod4', spiegel(tod_seite()))):
        bake_tod(nm_, k_)
# 844 (aus 709, treffen_709: Goblins und Kobolde „haben keine Angriffsbewegung (nur Gehen, Stehen), gleiten im Stehen 60 % des Wegs
# vor, Treffer ohne Schlag“): figur.gd fand weder „Hieb“ noch einen Wurzelweg und schob den Körper in der Lauer vor. Jetzt ein Hieb je
# Art wie im alten Spiel (FoeArt.kt: Klinge und Beil von oben über die Schulter, Speer und Dolch stoßen, der Schamane schlägt mit dem
# Stab wie mit einer Keule), Schlüsselbilder als Zusatz auf Bild 0 der Lauer wie die Tode (1141), die Füße bleiben stehen (ground);
# Richtwerte DESIGN-ABNAHME „Selbst prüfen“: Hieb 0,8–0,9 s mit kurzem Halt beim Aufschlag, Stich 0,6 s, Ausholen länger als der
# Schlag. Dazu für figur.gd der Wurzelweg „Gehen“ (am Ort gebacken: so weit wandert der Standfuß) und „hieb“ wie bei Grak (Reichweite
# der Faust vor der Wurzel beim Aufschlag m, Zeit des Aufschlags s, Drehung beim Schlag), damit er mit Schritten heran geht und dort
# schlägt; den Stand rechnet figur.gd aus dem Weg der Waffe (_hieb_bahn, hieb_plan).
# Der Späher schießt nur (Mars ranged), er bekommt keinen.
HIEB_ART = None if 'archer' in FIGUR else ('stich' if FIGUR.startswith('kobold') else ('keule' if 'shaman' in FIGUR else 'hieb'))
HIEB_SEITE = 'L' if HIEB_ART == 'keule' else 'R'     # der Schamane hält den Stab links (goblin.py Runde 4, „Hände tauschen“)
def hieb_keys(art):
    """[(Zeit s, {Knochen: Grad}, {}, 0)], Zeit des Aufschlags (s) und Drehung beim Schlag (Grad, wie Grak „hieb“ [2]: + nach links)"""
    if art == 'stich':
        # Speer und Dolch (FoeArt THRUST_W, THRUST_H): Arm und Schulter zurück, dann gerade nach vorn gestoßen, der Rumpf dreht mit
        zur = {'pelvis-waist': (-6, 0, -18), 'belly-chest': (0, 0, -8), 'shR-upR': (38, 6, 0), 'elR-foR': (-28, 0, 0),
               **beide('kneeS-calfS', (4, 0, 0))}
        vor = {'pelvis-waist': (4, 0, 16), 'belly-chest': (2, 0, 8), 'shR-upR': (-58, -4, 0), 'elR-foR': (34, 0, 0), 'foR-wrR': (30, 0, 0),
               'shL-upL': (14, 0, 0), **beide('kneeS-calfS', (10, 0, 0))}
        return [(0.0, {}, {}, 0.0), (0.24, zur, {}, 0.0), (0.30, zur, {}, 0.0), (0.38, vor, {}, 0.0), (0.46, vor, {}, 0.0),
                (0.66, {}, {}, 0.0)], 0.38, 0.0
    if art == 'keule':
        # Schamane, der Stab links, in der Mitte gefasst (goblin.py, figur.gd: der Fuß steht in Ruhe am Boden). Als Keule über die
        # Schulter (FoeArt: „struck with the staff like a club“) fuhr das untere Ende durch Bein und Hüfte (hieb_844: 13–18 cm im
        # eigenen Körper); darum ein Stoß: der Arm zieht zurück, der Schädel neigt sich etwas nach hinten, dann stößt er ihn 45° nach
        # vorn oben zum Gegner (Handgelenk am Bau gesucht: die Hand dreht den Stab so, dass er nicht zur Seite kippt)
        zur = {'pelvis-waist': (-4, 0, 8), 'belly-chest': (0, 0, 4), 'shL-upL': (20, 0, 0), 'elL-foL': (-20, 0, 0), 'foL-wrL': (-15, 0, 15),
               **beide('kneeS-calfS', (4, 0, 0))}
        vor = {'pelvis-waist': (6, 0, -8), 'belly-chest': (2, 0, -4), 'shL-upL': (-45, 0, 0), 'elL-foL': (25, 0, 0), 'foL-wrL': (15, 30, -60),
               **beide('kneeS-calfS', (10, 0, 0))}
        return [(0.0, {}, {}, 0.0), (0.24, zur, {}, 0.0), (0.30, zur, {}, 0.0), (0.40, vor, {}, 0.0), (0.48, vor, {}, 0.0),
                (0.72, {}, {}, 0.0)], 0.40, -20.0
    # Klinge, Beil, Stab (FoeArt CHOP_OVER, CHOP_SWING, CHOP_HIT): aufgerichtet, der Arm hoch über die Schulter zurück, die Waffe
    # hinter dem Kopf; dann über die Schulter nach vorn unten, der Rumpf dreht und beugt sich mit, die Knie geben nach
    aus = {'pelvis-waist': (-10, 0, -22), 'belly-chest': (0, 0, -10), 'shR-upR': (-80, 10, 0), 'elR-foR': (-30, 0, 0),
           'shL-upL': (10, 0, 0), **beide('kneeS-calfS', (4, 0, 0))}
    auf = {'pelvis-waist': (-4, 0, 18), 'belly-chest': (0, 0, 8), 'shR-upR': (-92, 0, 0), 'elR-foR': (50, 0, 0), 'foR-wrR': (90, 0, 0),
           'shL-upL': (-6, 0, 0), **beide('kneeS-calfS', (10, 0, 0))}
    nach = {'pelvis-waist': (4, 0, 22), 'belly-chest': (3, 0, 10), 'shR-upR': (-74, 0, 0), 'elR-foR': (56, 0, 0), 'foR-wrR': (92, 0, 0),
            'shL-upL': (-6, 0, 0), **beide('kneeS-calfS', (11, 0, 0))}
    return [(0.0, {}, {}, 0.0), (0.30, aus, {}, 0.0), (0.38, aus, {}, 0.0), (0.50, auf, {}, 0.0), (0.56, auf, {}, 0.0),
            (0.64, nach, {}, 0.0), (0.95, {}, {}, 0.0)], 0.50, 0.0
def _faust_vor():
    """wie weit die Faust der Waffenhand vor der Wurzel steht (m; vorn ist −Y)"""
    bpy.context.view_layer.update()
    return -(rig.matrix_world @ PB['fo%s-wr%s' % (HIEB_SEITE, HIEB_SEITE)].tail).y / 100.0
def bake_hieb(name, keys, t_auf, dreh):
    act = bpy.data.actions.new(name); act.use_fake_user = True
    rig.animation_data_create()
    for t_ in rig.animation_data.nla_tracks: t_.mute = True
    rig.animation_data.action = act
    n = int(round(keys[-1][0] * FPS)); f_auf = int(round(t_auf * FPS)); reich = 0.0
    for f in range(n + 1):
        clear(); RUHE0(0.0); _tod_pose(keys, f / FPS); ground()
        if f == f_auf: reich = _faust_vor()
        for pb in PB:
            pb.keyframe_insert('rotation_quaternion', frame=f + 1); pb.keyframe_insert('location', frame=f + 1)
    for t_ in rig.animation_data.nla_tracks: t_.mute = False
    spur = rig.animation_data.nla_tracks.new(); spur.name = name; spur.strips.new(name, 1, act)
    rig.animation_data.action = None
    INFO[name + '_s'] = n / FPS
    INFO['hieb'] = [round(reich, 3), round(f_auf / FPS, 3), dreh]
if HIEB_ART and os.environ.get('HIEB', '1') != '0':
    bake_hieb('Hieb', *hieb_keys(HIEB_ART))
    # Wurzelweg „Gehen“ in Metern (Blick +Z in Godot): am Ort gebacken, so weit trägt der Standfuß je Bild
    _gn = int(GANG['takt']); _d = INFO['Gehen_cm_je_bild'] / 100.0
    INFO['weg'] = {'Gehen': [[0.0, round(i * _d, 4)] for i in range(_gn + 1)]}
    # ohne Wurzelweg ging er mit WALK_MPS (1,4 m/s) bei gleitenden Füßen; jetzt im Tempo seiner Schritte, darum der Gang schneller
    # gespielt (Goblin 0,67 m/s → 1,4; Kobold 0,47 → 1,03, höchstens 2,2-fach), so bleibt der Kampf so flott wie vorher
    INFO['tempo'] = {'Gehen': round(min(2.2, max(1.0, 1.4 / (INFO['Gehen_cm_je_bild'] * FPS / 100.0))), 2)}
clear(); bpy.ops.object.mode_set(mode='OBJECT')
INFO['gehen_m_je_s'] = INFO['Gehen_cm_je_bild'] * FPS / 100.0
INFO['fps'] = FPS; INFO['ecken'] = len(held.data.vertices)
json.dump(INFO, open(OUT + '/held-info.json', 'w'), indent=1)
print('ANIM', INFO)

# ---------------------------------------------------------------- 6. Ausgabe in Metern (Modellregel 1)
def to_meters(k=0.01):
    """Skelett und Netz um k verkleinern und anwenden; Verschiebungen in den Bewegungen mitnehmen."""
    bpy.context.view_layer.objects.active = rig
    if bpy.context.object.mode != 'OBJECT': bpy.ops.object.mode_set(mode='OBJECT')
    if held.parent == rig:
        mw = held.matrix_world.copy(); held.parent = None; held.matrix_world = mw
    for o in (rig, held):
        o.matrix_world = Matrix.Scale(k, 4) @ o.matrix_world
        bpy.ops.object.select_all(action='DESELECT'); o.select_set(True); bpy.context.view_layer.objects.active = o
        bpy.ops.object.transform_apply(location=True, rotation=False, scale=True)
    held.parent = rig; held.matrix_parent_inverse = rig.matrix_world.inverted()
    for act in bpy.data.actions:
        for fc in act.fcurves if hasattr(act, 'fcurves') else [c for l in act.layers for s in l.strips for b in s.channelbags for c in b.fcurves]:
            if fc.data_path.endswith('.location'):
                for kp in fc.keyframe_points:
                    kp.co.y *= k; kp.handle_left.y *= k; kp.handle_right.y *= k
                fc.update()
to_meters()
bpy.ops.object.select_all(action='DESELECT'); rig.select_set(True); held.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT + '/held.glb', export_format='GLB', use_selection=True, export_animations=True,
                          export_skins=True, export_vertex_color='ACTIVE', export_animation_mode='NLA_TRACKS',
                          export_yup=True, export_apply=False)
bpy.ops.wm.save_as_mainfile(filepath=OUT + '/held3-rig.blend')
print('GLB OK', os.path.getsize(OUT + '/held.glb'))
