# Held v3 fuer die Engine: Albedo (mit Abnutzung) in Eckfarben backen, alles zu einem Netz, Skelett mit Gewichten,
# Bewegungen Gehen und Stehen (Fuesse automatisch am Boden), Ausgabe held.glb in Metern (348.6, Modellregel 1; gebaut wird intern in Zentimetern).
# Aufruf: OUT=<ordner> python -I rig.py   (vorher held3.py mit demselben OUT)
import bpy, math, os, json
import numpy as np
from mathutils import Vector, Matrix, Quaternion

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
            side = (V[:, 0] * (-1 if s == 'R' else 1)) > -3       # P(r,...) -> x = -r: rechts ist x < 0
            near = side & (V[:, 2] < HZ)
            w = np.clip((HZ - V[:, 2]) / HR, 0, 1) * k * near
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
# Vorbeugen = negative Drehung um X (der Held blickt nach -Y)
def leg(ph):
    hip = 22 * math.cos(2 * math.pi * ph) - 3
    knee = 14 * bump(ph, 0.1, 0.07) + 62 * bump(ph, 0.72, 0.11)
    ank = 9 * bump(ph, 0.38, 0.12) - 16 * bump(ph, 0.6, 0.06) + 6 * bump(ph, 0.85, 0.08)
    return hip, knee, ank
def pose_walk(ph):
    for s, off in (('R', 0.0), ('L', 0.5)):
        h, k, a = leg((ph + off) % 1)
        PB['hip%s-thigh%s' % (s, s)].rotation_quaternion = rot_world('hip%s-thigh%s' % (s, s), X, -h)
        PB['knee%s-calf%s' % (s, s)].rotation_quaternion = rot_world('knee%s-calf%s' % (s, s), X, k)
        for b in ('ankle%s-heel%s' % (s, s), 'ankle%s-ball%s' % (s, s)):
            PB[b].rotation_quaternion = rot_world(b, X, -a)
        sw = -25 * math.cos(2 * math.pi * (ph + off))              # Arm gegen das Bein
        ab = 7 if s == 'R' else -7                                  # Arm etwas abgespreizt: Hand vorbei am Wappenrock
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world2('sh%s-up%s' % (s, s), [(X, -sw), (Y, ab)])
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -(12 + 8 * max(0, math.cos(2 * math.pi * (ph + off + 0.5)))))
    tw = 5 * math.cos(2 * math.pi * ph)
    PB['pelvis-waist'].rotation_quaternion = rot_world('pelvis-waist', X, -4)       # leicht nach vorn
    PB['belly-chest'].rotation_quaternion = rot_world('belly-chest', Zx, -tw)
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
bake_action('Gehen', 32, pose_walk, measure=True)
bake_action('Stehen', 90, pose_idle)
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
