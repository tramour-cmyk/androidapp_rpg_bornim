# Held v3 fuer die Engine: Albedo (mit Abnutzung) in Eckfarben backen, alles zu einem Netz, Skelett mit Gewichten,
# Bewegungen Gehen und Stehen (Fuesse automatisch am Boden), Ausgabe held.glb in Metern (348.6, Modellregel 1; gebaut wird intern in Zentimetern).
# Aufruf: OUT=<ordner> python -I rig.py   (vorher held3.py mit demselben OUT)
import bpy, math, os, json
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
    if n.startswith(('head', 'helm', 'nasal', 'eye', 'lid', 'ear', 'hair', 'tuch', 'hood', 'beard', 'circlet', 'aventail')): RIGID[n] = 'neck-neckTop'   # 348.6 Leute
    elif n.startswith(('shield', 'boss')): RIGID[n] = 'chest-chestTop'
    elif n.startswith(('clasp', 'sun')): RIGID[n] = 'chest-chestTop'
    elif n.startswith(('Cylinder', 'Sphere', 'buckle')): RIGID[n] = 'pelvis-waist'    # Schwert und Scheide an der Huefte
    elif n == 'handR': RIGID[n] = 'foR-wrR'
    elif n == 'handL': RIGID[n] = 'foL-wrL'
TRUNK = ['pelvis-waist', 'waist-belly', 'belly-chest', 'chest-chestTop']
CLOTH = {'tabard': 0.75, 'tabard.001': 0.75, 'cloak': 0.4, 'robe': 0.6, 'apron': 0.6}       # Anteil, den der Stoff den Oberschenkeln folgt
if FIGUR != 'held': CLOTH.update(robe=0.85, apron=0.85)   # Runde 4b: Schuerze geht mit dem Rock (Helfer: steht ab)   # Leute Runde 4 (Helfer: Bein durch den Rock im Gang, Liska, Gwenna)
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
            if FIGUR != 'held' and o.name in ('robe', 'apron'):
                # Runde 4b (Helfer: hinteres Bein ragt im Gang unter dem Saum heraus): unter dem Knie folgt der Rock auch der Wade
                kz = J['knee' + s][0][2]; wc = np.clip((kz - V[:, 2]) / 25.0, 0, 1) * 0.35 * np.clip((side - 0.5) * 2.5, 0, 1)   # 4b-2: nicht in der Mitte (Rock riss vorn)
                put('hip' + s + '-thigh' + s, range(len(V)), w * 0.6 * (1 - wc))
                put('thigh' + s + '-knee' + s, range(len(V)), w * 0.4 * (1 - wc))
                put('knee' + s + '-calf' + s, range(len(V)), w * wc)
            else:
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
# 348.6 Leute Runde 4b (Helfer: „alle stehen gleich“; Abnahmeliste Leute 5; Chef 25.10., 21:33: „Wieso tragen die … NPC nicht
# Objekte“): Armhaltung je Seite aus leute.json "arme" {R, L}: haengen (wie bisher), schulter (Stab, Speer, Hammer aufrecht in der
# Faust vor der Brust, Schaft an der Schulter; dazu "traegt"), huefte (Hand in die Seite), vorn (Haende vor dem Bauch), ruecken
# (Haende hinter dem Ruecken), guertel (Daumen am Guertel), brust (Hand an der Brust). Zwei Knochen, Ziel des Handgelenks in der
# Ruhelage (cm), Ellbogen zur Polrichtung; im Gehen bleiben schulter, vorn, ruecken, die uebrigen schwingen wie bisher.
LP = {} if FIGUR == 'held' else json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'leute.json')))[FIGUR]
ARME = dict(R='haengen', L='haengen'); ARME.update(LP.get('arme', {}))
if LP.get('traegt') and ARME['R'] == 'haengen': ARME['R'] = 'schulter'
def arm_ziel(s, art):
    g = -1 if s == 'R' else 1               # rechts ist x < 0
    sh, el, wr = J['sh' + s][0], J['el' + s][0], J['wr' + s][0]; hp = J['hip' + s][0]; ct = J['chestTop'][0]
    lu, lf = (el - sh).length, (wr - el).length
    bz = hp.z + 0.16 * (ct.z - hp.z)        # Guertelhoehe
    if art == 'schulter': return Vector((sh.x * 0.75, sh.y - 0.35 * lf, sh.z - 0.95 * lu)), Vector((g * 0.4, 0.5, -0.75))
    if art == 'huefte':   return Vector((sh.x * 1.0 + g * 1.0, hp.y + 1.5, bz + 2.0)), Vector((g * 1.0, 0.5, 0.1))   # 4b-2: hp.x steckte im Koerper
    if art == 'vorn':     return Vector((g * 3.0, hp.y - 0.48 * lf, bz - 2.0)), Vector((g * 0.35, 0.45, -0.8))
    if art == 'ruecken':  return Vector((g * 3.5, hp.y + 0.62 * lf, bz - 1.0)), Vector((g * 0.6, 0.2, -0.75))
    if art == 'guertel':  return Vector((hp.x * 0.9, hp.y - 0.45 * lf, bz + 1.0)), Vector((g * 0.9, 0.45, -0.2))
    if art == 'brust':    return Vector((g * 4.0, ct.y - 0.32 * lf, ct.z - 0.95 * lu)), Vector((g * 0.4, 0.3, -0.9))
    return None, None
def arm_ik(s, art):
    """Drehungen (Oberarm, Unterarm) als lokale Quaternionen, damit das Handgelenk der Ruhelage auf arm_ziel liegt."""
    T, pol = arm_ziel(s, art)
    if T is None: return None
    sh, el, wr = J['sh' + s][0], J['el' + s][0], J['wr' + s][0]
    a, b = (el - sh).length, (wr - el).length
    d = T - sh; L = min(d.length, (a + b) * 0.995); dn = d.normalized()
    ca = max(-1.0, min(1.0, (a * a + L * L - b * b) / (2 * a * L)))
    pn = (pol - dn * pol.dot(dn)).normalized()
    E2 = sh + dn * (a * ca) + pn * (a * math.sqrt(max(0.0, 1 - ca * ca)))
    R1 = (el - sh).rotation_difference(E2 - sh).to_matrix()
    R2 = (R1 @ (wr - el)).rotation_difference(sh + dn * L - E2).to_matrix()
    up, fo = 'sh%s-up%s' % (s, s), 'el%s-fo%s' % (s, s)
    M1 = arm.bones[up].matrix_local.to_3x3(); M2 = arm.bones[fo].matrix_local.to_3x3()
    q1 = (M1.inverted() @ R1 @ M1).to_quaternion()
    q2 = (M2.inverted() @ (R1.inverted() @ R2 @ R1) @ M2).to_quaternion()
    return q1, q2
IK = {s: arm_ik(s, ARME[s]) for s in 'RL'}
IM_GANG = ('schulter', 'vorn', 'ruecken')
def arme_setzen(gang=False):
    for s in 'RL':
        if IK[s] is None or (gang and ARME[s] not in IM_GANG): continue
        q1, q2 = IK[s]
        up, fo = 'sh%s-up%s' % (s, s), 'el%s-fo%s' % (s, s)
        PB[up].rotation_quaternion = q1 @ PB[up].rotation_quaternion if gang else q1
        PB[fo].rotation_quaternion = q2
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
        if ARME[s] in IM_GANG: sw *= 0.12   # Runde 4b: getragen oder gehalten schwingt der Arm kaum
        # Arm etwas abgespreizt: Hand vorbei am Wappenrock; Leute naeher am Koerper (Helfer Runde 3: Arme abgespreizt)
        ab = (7 if FIGUR == 'held' else (6 if LP.get('rock') == 'robe' else 3)) * (1 if s == 'R' else -1)   # Runde 4b: Hand stach hinten durch den Rock
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world2('sh%s-up%s' % (s, s), [(X, -sw), (Y, ab)])
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -(12 + 8 * max(0, math.cos(2 * math.pi * (ph + off + 0.5)))))
    tw = 5 * math.cos(2 * math.pi * ph)
    # Wiegen der Huefte (Seitenneigung um die Blickachse Y) und Einsacken auf dem lahmen Bein (Standphase um 0,25)
    lahm_ph = 0.5 if GANG['seite'] == 'L' else 0.0
    roll = GANG['huefte'] * math.sin(2 * math.pi * ph) + 9 * GANG['hinken'] * bump(ph, lahm_ph + 0.25, 0.14) * (1 if GANG['seite'] == 'L' else -1)
    # Rumpf: positive Drehung um X neigt nach vorn (Blick -Y); der Held bleibt bei -4 wie bisher
    PB['pelvis-waist'].rotation_quaternion = rot_world2('pelvis-waist', [(X, -4 + GANG['vor']), (Y, roll)])
    PB['belly-chest'].rotation_quaternion = rot_world2('belly-chest', [(Zx, -tw), (Y, -0.6 * roll)])
    if FIGUR != 'held':
        arme_setzen(gang=True)
        if GANG.get('nicken'): PB['neck-neckTop'].rotation_quaternion = rot_world('neck-neckTop', X, GANG['nicken'])   # Runde 4b (Helfer: Borin Kopf im Nacken)
def pose_idle(ph):
    br = math.sin(2 * math.pi * ph)
    # Helfer Runde 3 (Leute „steif wie Puppen“): Gewicht wandert langsam von Bein zu Bein, Schultern gehen mit
    PB['pelvis-waist'].rotation_quaternion = rot_world('pelvis-waist', Y, 1.6 * math.sin(2 * math.pi * ph + 0.7))
    PB['belly-chest'].rotation_quaternion = rot_world2('belly-chest', [(X, 1.2 * br), (Y, -1.0 * math.sin(2 * math.pi * ph + 0.7))])
    PB['chest-chestTop'].rotation_quaternion = rot_world('chest-chestTop', X, -0.8 * br)
    PB['neck-neckTop'].rotation_quaternion = rot_world('neck-neckTop', Zx, 3 * math.sin(2 * math.pi * ph * 1))
    for s in 'RL':
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world('sh%s-up%s' % (s, s), X, 1.5 * br)
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -6)
    if FIGUR != 'held':
        arme_setzen()
        # Runde 4b: Kopf je Figur etwas anders geneigt und gedreht (leute.json "kopfhaltung": [nicken, drehen, neigen] Grad)
        kn, kd, kt = (LP.get('kopfhaltung') or [0, 0, 0])
        PB['neck-neckTop'].rotation_quaternion = rot_world2('neck-neckTop', [(X, kn), (Zx, kd + 3 * math.sin(2 * math.pi * ph)), (Y, kt)])
# 348.6 Held (Chef 25.10., 18:20: „keine Rennanimation, sondern nur eine … beschleunigte Gehen-Animation“): eigenes Rennen,
# kurzer Bodenkontakt, Knie hoch, Fersen schwingen zum Gesaess, Rumpf vorgeneigt, Arme angewinkelt gegen die Beine
def ring(pts, ph):
    """Catmull-Rom durch (Phase, Wert) im Kreis 0..1"""
    n = len(pts); i = max(k for k in range(n) if pts[k][0] <= ph)
    p0, p1, p2, p3 = (pts[(i + d) % n] for d in (-1, 0, 1, 2))
    t1 = p1[0]; t2 = p2[0] + (1 if i + 1 >= n else 0)
    u = (ph - t1) / (t2 - t1); u2 = u * u; u3 = u2 * u
    return 0.5 * (2 * p1[1] + (-p0[1] + p2[1]) * u + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * u2 + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * u3)
# Phase 0 Aufsetzen, Stand bis 0,35 (Knie federt ein, Fuss setzt fast unter dem Koerper auf), dann Schwung (Ferse zum Gesaess,
# Knie hoch nach vorn); so bleibt die Huefte in einem Band von wenigen Zentimetern (vorher 23 cm, Rumpf sackte bei jedem Schritt)
# Runde 5b (Helfer: beim Aufsetzen beide Fuesse eng unter dem Koerper, wie ein Hopser): Schwungbein frueher nach vorn, Knie
# vorn hoch, Ferse dicht am Gesaess; Abdruck laenger nach hinten gestreckt
RUN_HIP = [(0.0, 30), (0.17, 6), (0.33, -26), (0.45, -12), (0.6, 24), (0.82, 44)]
RUN_KNEE = [(0.0, 20), (0.15, 40), (0.33, 12), (0.48, 100), (0.6, 115), (0.82, 55), (0.95, 24)]
RUN_ANK = [(0.0, 4), (0.17, 14), (0.33, -24), (0.47, -12), (0.7, 0), (0.9, 6)]
RUN_STAND = 0.33
RUN_NEIG = 25.0  # Grad Rumpfneigung im Rennen (Becken 19, Brust 6); die Arme haengen an der Brust und kippen mit
RUN_FLUG = 6.0   # cm Bogen in der Flugphase (Runde 5, Helfer: „Kopf ohne Auf und Ab“ bei 3 cm)
def run_stance(ph):
    return {s for s, off in (('R', 0.0), ('L', 0.5)) if (ph + off) % 1 < RUN_STAND}
def leg_run(ph):
    return ring(RUN_HIP, ph), ring(RUN_KNEE, ph), ring(RUN_ANK, ph)
def pose_run(ph):
    for s, off in (('R', 0.0), ('L', 0.5)):
        h, k, a = leg_run((ph + off) % 1)
        PB['hip%s-thigh%s' % (s, s)].rotation_quaternion = rot_world('hip%s-thigh%s' % (s, s), X, -h)
        PB['knee%s-calf%s' % (s, s)].rotation_quaternion = rot_world('knee%s-calf%s' % (s, s), X, k)
        for b in ('ankle%s-heel%s' % (s, s), 'ankle%s-ball%s' % (s, s)):
            PB[b].rotation_quaternion = rot_world(b, X, -a)
        c = math.cos(2 * math.pi * (ph + off))   # +1: Arm hinten (positive Drehung um X), -1: vorn
        # Helfer: Unterarm stand vorn waagerecht weg wie abgespreizt; jetzt Ellbogen fest rund 90 Grad, Hand von der Huefte zur Brust
        # Runde 5 (Helfer Runde 3: Unterarm vorn waagerecht aussen, andere Faust klebt an der Huefte): weiter schwingen (vorn 42,
        # hinten 38 Grad), vorn enger gebeugt und zur Koerpermitte (Hand vor die Brust), hinten offener (Hand hinter die Huefte)
        # Runde 5b (Helfer: Faust klebt an der Huefte, vorn Unterarm waagerecht; nachgemessen: der vorgeneigte Rumpf nimmt die
        # Arme 25 Grad mit nach hinten, vorn blieben 17, hinten 63 Grad): Schwung in Weltwinkeln vorn 35, hinten 50, Neigung abgezogen
        ein = (1 if s == 'R' else -1) * (4 + 14 * max(0.0, -c))
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world2('sh%s-up%s' % (s, s), [(X, 42.5 * c + 7.5 - RUN_NEIG), (Y, (1 if s == 'R' else -1) * 3 * max(0.0, -c)), (Zx, ein)])
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -(75 - 15 * c))   # hinten offen (60), vorn 90: Hand von der Huefte bis vor die Brust (Runde 5c, Helfer: vorn „winkt“)
    # Runde 5 (Helfer: „Rumpf kaum geneigt“, aus der Schraegsicht wirkten 14 Grad aufrecht): 19 und Brust 6, Kopf gleicht aus
    PB['pelvis-waist'].rotation_quaternion = rot_world('pelvis-waist', X, RUN_NEIG - 6)
    PB['belly-chest'].rotation_quaternion = rot_world2('belly-chest', [(Zx, -9 * math.cos(2 * math.pi * ph)), (X, 6)])
    PB['neck-neckTop'].rotation_quaternion = rot_world('neck-neckTop', X, -14)           # Blick bleibt nach vorn trotz Neigung
# 348.6 Held (Chef 25.10., 18:20: „Die Fackel des Helden trägt immer noch hinten“): nachts haelt er sie wie alt (MapFigure.lit,
# Dress.heldTorch) in der linken Hand vor der Schulter, der Arm schwingt nicht; Bewegungen mit Endung _Fackel (held.gd)
def mit_fackel(fn, neig=0.0):
    def f(ph):
        fn(ph)
        # Helfer: Flamme brannte neben dem Ohr; Hand jetzt auf Brusthoehe vor der Schulter (Flamme etwa in Kinnhoehe, 30 cm vor)
        # Runde 5b (Helfer: Fackelarm waagerecht nach vorn-aussen, Ellbogen stand 9 cm ab): Ellbogen am Koerper, Unterarm steigt
        # zur Koerpermitte; im Rennen die Rumpfneigung abgezogen, damit die Fackel vorn bleibt
        # Runde 5c (Helfer: Fackelarm starr waagerecht nach vorn): Oberarm fast senkrecht, Unterarm steigt 40 Grad
        PB['shL-upL'].rotation_quaternion = rot_world2('shL-upL', [(X, -12 - neig), (Y, 2), (Zx, -10)])
        PB['elL-foL'].rotation_quaternion = rot_world('elL-foL', X, -120)
    return f
FOOT = [(s, b, r) for s in 'RL' for b, r in (('ankle%s-heel%s', 'heel%s'), ('ankle%s-ball%s', 'ball%s'), ('ball%s-toe%s', 'toe%s'))]
# Standphase je Bein (leg: Phase 0 Ferse vorn bis 0,56 Zehe hinten, dann Schwung). 348.6 Bram: beim Hinken hing die Zehe des
# lahmen Beins im Schwung tiefer als der Standfuss; der Boden richtete sich nach ihr, Bram stand auf der schleifenden Zehe
# und kam kaum vom Fleck (0,11 m/s); Runde 3 ebenso Pim (0,45) und Borin (0,26) bei groesserem Kopf und Haenden. Bei den Leuten traegt jetzt nur der Standfuss, der Schwungfuss streift hoechstens den Boden;
# beim Helden bleibt es beim tiefsten Fuss (unveraendert).
STAND = 0.56
def stance(ph):
    return {s for s, off in (('R', 0.0), ('L', 0.5)) if (ph + off) % 1 < STAND}
def foot_pts():
    return [(s, rig.matrix_world @ PB[b % (s, s)].tail, J[r % s][1]) for s, b, r in FOOT]
def ground(sides='RL', fest=None):
    """Wurzel so heben/senken, dass der tiefere Fuss der tragenden Seiten gerade den Boden beruehrt; liefert Fusspunkte.
    fest: Hoehe vorgegeben (Flugphase des Rennens, kein Fuss traegt)"""
    PB['root'].location = (0, 0, 0); bpy.context.view_layer.update()
    pts = foot_pts()
    low = fest if fest is not None else min(p.z - rr for s, p, rr in pts if s in sides)
    PB['root'].location = arm.bones['root'].matrix_local.to_3x3().inverted() @ Vector((0, 0, -low))
    bpy.context.view_layer.update()
    # Schwungfuss unter dem Boden: Knie dieses Beins beugen, bis er nur noch streift (hoechstens 10 x 3 Grad)
    for s in 'RL':
        if s in sides: continue
        for _ in range(10):
            if min(p.z - rr for t, p, rr in foot_pts() if t == s) > -0.3: break
            b = 'knee%s-calf%s' % (s, s)
            PB[b].rotation_quaternion = rot_world(b, X, 3) @ PB[b].rotation_quaternion
            bpy.context.view_layer.update()
    return foot_pts(), low
def clear():
    for pb in PB: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
INFO = {}
def bake_action(name, n, fn, measure=False, sides=None, flug=0.0):
    act = bpy.data.actions.new(name); act.use_fake_user = True
    # 348.6 (Chef 25.10., 18:20: „egal wer steht, so circa im 3 bis 4 Sekunden Takt glitscht dann die Figur und zuckt“): beim
    # ersten Bild jeder Bewegung ausser der ersten ueberschrieb die Auswertung der fertigen Spuren (NLA) die Pose; Stehen begann
    # mit den Beinen in Schrittstellung des Gehens, einmal je Durchlauf (3 s). Beim Backen jetzt ohne NLA (nachgemessen in Godot)
    rig.animation_data_create(); rig.animation_data.action = act; rig.animation_data.use_nla = False
    ys = []
    # Flugphase (sides leer): Hoehe zwischen den Bildern davor und danach, dazu ein Bogen von flug cm
    lows = {}
    if sides:
        for f in range(n):
            if sides(f / n): clear(); fn(f / n); lows[f] = ground(sides(f / n))[1]
    def fest(f):
        if f % n in lows: return None
        a = max((g for g in lows if g < f % n), default=max(lows) - n); b = min((g for g in lows if g > f % n), default=min(lows) + n)
        u = (f % n - a) / (b - a)
        return lows[a % n] * (1 - u) + lows[b % n] * u - flug * math.sin(math.pi * u)
    for f in range(n + 1):
        ph = (f % n) / n
        clear(); fn(ph); pts, low = ground(sides(ph) if sides else 'RL', fest(f) if sides else None)
        if measure:   # tiefster Fusspunkt je tragender Seite (ohne Standphase: der tiefste ueberhaupt, wie bisher)
            tr = sides(ph) if sides else min(pts, key=lambda q: q[1].z - q[2])[0]
            ys.append({s: min((q for q in pts if q[0] == s), key=lambda q: q[1].z - q[2])[1].y for s in tr})
        for pb in PB:
            pb.keyframe_insert('rotation_quaternion', frame=f); pb.keyframe_insert('location', frame=f)
    # ab Bild 0 und Szene ab 0: der Export legte sonst ein doppeltes Bild ans Ende (Stehen 3,03 statt 3 s)
    tr = rig.animation_data.nla_tracks.new(); tr.name = name; tr.strips.new(name, 0, act)
    rig.animation_data.action = None; rig.animation_data.use_nla = True
    if measure:   # Fussgleiten: wie schnell wandert der Standfuss nach hinten (cm je Bild), nur solange er traegt
        d = [ys[i + 1][s] - ys[i][s] for i in range(len(ys) - 1) for s in ys[i] if s in ys[i + 1]]
        INFO[name + '_cm_je_bild'] = float(np.median(d))
    return act
FPS = 30; scn.render.fps = FPS; scn.frame_start = 0
bake_action('Gehen', int(GANG['takt']), pose_walk, measure=True, sides=None if FIGUR == 'held' else stance)
bake_action('Stehen', 90, pose_idle)
if FIGUR == 'held':
    bake_action('Rennen', 20, pose_run, measure=True, sides=run_stance, flug=RUN_FLUG)
    bake_action('Gehen_Fackel', int(GANG['takt']), mit_fackel(pose_walk))
    bake_action('Stehen_Fackel', 90, mit_fackel(pose_idle))
    bake_action('Rennen_Fackel', 20, mit_fackel(pose_run, RUN_NEIG), sides=run_stance, flug=RUN_FLUG)
    INFO['rennen_m_je_s'] = INFO['Rennen_cm_je_bild'] * FPS / 100.0
clear(); bpy.ops.object.mode_set(mode='OBJECT')
INFO['gehen_m_je_s'] = INFO['Gehen_cm_je_bild'] * FPS / 100.0
INFO['fps'] = FPS; INFO['ecken'] = len(held.data.vertices)
if LP.get('traegt'):   # Runde 4b: getragenes Ding (leute.gd haengt es an die rechte Faust), Griff im Knochenraum foR-wrR in m
    INFO['traegt'] = LP['traegt']
    INFO['griff_R'] = [0.0, ((J['wrR'][0] - J['foR'][0]).length + 4.6) / 100.0, 0.0]
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
