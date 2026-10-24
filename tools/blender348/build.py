# Held (Kaempfer) aus Code: Koerper per Skin-Modifier, Kleidung per Raycast/Schale, Passes fuer Toon-Nachbearbeitung.
# Masse und Farben aus core/.../art/Doll.kt, Dress.kt, CharacterArt.kt, Appearance.kt (Mensch, Mann, mittel, 175 cm).
import bpy, bmesh, math, sys, os, json, time
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

OUT = '/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held'
PASSDIR = OUT + '/passes'
os.makedirs(PASSDIR, exist_ok=True)

# ---------------------------------------------------------------- Masse (Doll.kt)
H = 175.0; hh = H / 7.5
ankleY = 0.045 * H; hipY = 0.51 * H; kneeY = ankleY + (hipY - ankleY) * 0.52
chinY = H - hh * 0.98; shoulderY = chinY - 0.055 * H; shoulderX = 0.105 * H
trunk = shoulderY - hipY; beltY = hipY + 0.22 * trunk; chestDepth = 0.066 * H
headCy = H - hh * 0.5

def P(r, u, f):  # Heldraum (rechts, hoch, vorn) -> Blender (x, y, z); der Held blickt nach -Y
    return Vector((-r, -f, u))

# ---------------------------------------------------------------- Farben (sRGB hex)
def hx(c): return ((c >> 16) & 255, (c >> 8) & 255, c & 255)
def mix(a, b, t):
    A, B = hx(a), hx(b)
    return tuple(int(round(A[i] + (B[i] - A[i]) * t)) for i in range(3))
def worn(c, k=0.38): return mix(c, 0x3A3632, k)
def lin(rgb, k=1.0):
    def f(v):
        v = min(1.0, v / 255.0 * k)
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    return (f(rgb[0]), f(rgb[1]), f(rgb[2]), 1.0)

COL = {
    'skin': hx(0xEACBAE), 'hair': hx(0x5E3C26),
    'tabard': worn(0xC03838, 0.2), 'sleeve': worn(0x802428, 0.45), 'pants': worn(0x484858, 0.3),
    'chain': hx(0x8A9098), 'darkLeather': hx(0x3E2C22), 'leather': hx(0x6A4A32), 'gold': hx(0xB8904A),
    'cloak': worn(0x5A4A3A, 0.3), 'metal': hx(0x868E98), 'shield': worn(0x6E2E24, 0.15), 'stripe': hx(0xC8BCA0),
    'wood': hx(0x6E4A2C), 'eye': hx(0x2A2018), 'lip': hx(0xA8644E),
}

# ---------------------------------------------------------------- Szene leeren
bpy.ops.wm.read_factory_settings(use_empty=True)
scn = bpy.context.scene
root = bpy.data.objects.new('Held', None); scn.collection.objects.link(root)

def link(obj):
    scn.collection.objects.link(obj); obj.parent = root; return obj

def mesh_obj(name, verts, faces, mat=None, smooth=True):
    me = bpy.data.meshes.new(name)
    me.from_pydata([tuple(v) for v in verts], [], [tuple(f) for f in faces])
    me.update()
    if smooth:
        for p in me.polygons: p.use_smooth = True
    o = bpy.data.objects.new(name, me); link(o)
    if mat: o.data.materials.append(mat)
    return o

def apply_mods(o):
    dg = bpy.context.evaluated_depsgraph_get()
    oe = o.evaluated_get(dg)
    me = bpy.data.meshes.new_from_object(oe)
    o.modifiers.clear(); old = o.data; o.data = me
    bpy.data.meshes.remove(old)
    return o

def np_mesh(o):
    me = o.data
    v = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', v); v = v.reshape(-1, 3)
    n = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('normal', n); n = n.reshape(-1, 3)
    return v, n

# ---------------------------------------------------------------- Materialien mit Modus-Weiche
MATS = {}
MODE_NODES = []

def make_mat(name, mid, color_fn, bump_fn=None, mid_fn=None):
    """color_fn(nt) -> Farb-Socket; bump_fn(nt) -> Hoehen-Socket; mid_fn(nt) -> Wert-Socket fuer die Material-ID."""
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree; nt.nodes.clear()
    out = nt.nodes.new('ShaderNodeOutputMaterial')
    col = color_fn(nt)
    diff = nt.nodes.new('ShaderNodeBsdfDiffuse'); diff.inputs['Color'].default_value = (1, 1, 1, 1)
    if bump_fn:
        b = nt.nodes.new('ShaderNodeBump'); b.inputs['Strength'].default_value = 0.5
        b.inputs['Distance'].default_value = 0.25
        nt.links.new(bump_fn(nt), b.inputs['Height']); nt.links.new(b.outputs['Normal'], diff.inputs['Normal'])
    e_alb = nt.nodes.new('ShaderNodeEmission'); nt.links.new(col, e_alb.inputs['Color'])
    geo = nt.nodes.new('ShaderNodeNewGeometry')
    vm = nt.nodes.new('ShaderNodeVectorMath'); vm.operation = 'MULTIPLY_ADD'
    vm.inputs[1].default_value = (0.5, 0.5, 0.5); vm.inputs[2].default_value = (0.5, 0.5, 0.5)
    nt.links.new(geo.outputs['Normal'], vm.inputs[0])
    e_nor = nt.nodes.new('ShaderNodeEmission'); nt.links.new(vm.outputs[0], e_nor.inputs['Color'])
    cam = nt.nodes.new('ShaderNodeCameraData')
    e_dep = nt.nodes.new('ShaderNodeEmission'); nt.links.new(cam.outputs['View Z Depth'], e_dep.inputs['Strength'])
    e_dep.inputs['Color'].default_value = (1, 1, 1, 1)
    e_id = nt.nodes.new('ShaderNodeEmission'); e_id.inputs['Color'].default_value = (1, 1, 1, 1)
    if mid_fn:
        nt.links.new(mid_fn(nt), e_id.inputs['Strength'])
    else:
        e_id.inputs['Strength'].default_value = float(mid)
    m['modes'] = 1
    for k_, v_ in {'light': diff, 'albedo': e_alb, 'normal': e_nor, 'depth': e_dep, 'id': e_id}.items(): v_.name = 'M_' + k_
    out.name = 'M_out'
    MODE_NODES.append((nt, out, {'light': diff, 'albedo': e_alb, 'normal': e_nor, 'depth': e_dep, 'id': e_id}))
    MATS[name] = m
    return m

def set_mode(mode):
    for nt, out, d in MODE_NODES:
        for l in list(out.inputs['Surface'].links): nt.links.remove(l)
        nt.links.new(d[mode].outputs[0], out.inputs['Surface'])

def rgb_node(nt, rgb, k=1.0):
    n = nt.nodes.new('ShaderNodeRGB'); n.outputs[0].default_value = lin(rgb, k); return n.outputs[0]

def flat(name, mid, key, k=1.0):
    return make_mat(name, mid, lambda nt: rgb_node(nt, COL[key], k))

def math_node(nt, op, a, b=None, c=None):
    n = nt.nodes.new('ShaderNodeMath'); n.operation = op
    for i, x in enumerate((a, b, c)):
        if x is None: continue
        if isinstance(x, (int, float)): n.inputs[i].default_value = x
        else: nt.links.new(x, n.inputs[i])
    return n.outputs[0]

def mixc(nt, fac, a, b):
    n = nt.nodes.new('ShaderNodeMix'); n.data_type = 'RGBA'
    nt.links.new(fac, n.inputs['Factor']); nt.links.new(a, n.inputs['A']); nt.links.new(b, n.inputs['B'])
    return n.outputs['Result']

# Kettenhemd: Ringe als Bild (Voronoi auf Zylinderkoordinaten), dazu Relief
def chain_rings(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord')
    sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    ang = math_node(nt, 'ARCTAN2', sep.outputs['X'], sep.outputs['Y'])
    u = math_node(nt, 'MULTIPLY', ang, 15.0)
    # Arme: eigene Achse waere besser; Zylinder um die Hochachse reicht fuer Rumpf und kurze Aermel
    comb = nt.nodes.new('ShaderNodeCombineXYZ')
    nt.links.new(u, comb.inputs[0]); nt.links.new(sep.outputs['Z'], comb.inputs[1])
    vor = nt.nodes.new('ShaderNodeTexVoronoi'); vor.voronoi_dimensions = '2D'
    vor.inputs['Scale'].default_value = 0.62; vor.inputs['Randomness'].default_value = 0.0
    nt.links.new(comb.outputs[0], vor.inputs['Vector'])
    d = vor.outputs['Distance']
    ring = math_node(nt, 'ABSOLUTE', math_node(nt, 'SUBTRACT', d, 0.40))
    # 1 auf dem Ring, 0 im Loch und zwischen den Ringen
    r = math_node(nt, 'SUBTRACT', 1.0, math_node(nt, 'MULTIPLY', ring, 7.0))
    return math_node(nt, 'MAXIMUM', r, 0.0)

def chain_color(nt):
    r = chain_rings(nt)
    hi = rgb_node(nt, COL['chain'], 1.12); lo = rgb_node(nt, COL['chain'], 0.42)
    return mixc(nt, r, lo, hi)

make_mat('skin', 1, lambda nt: rgb_node(nt, COL['skin']))
make_mat('chain', 2, chain_color, bump_fn=chain_rings)
flat('tabard', 3, 'tabard'); flat('sleeve', 4, 'sleeve'); flat('pants', 5, 'pants')
flat('boots', 6, 'darkLeather'); flat('belt', 7, 'darkLeather'); flat('gold', 8, 'gold')
flat('cloak', 9, 'cloak'); flat('helm', 10, 'metal'); flat('helmrim', 11, 'metal', 0.82)
flat('steel', 12, 'metal', 1.16); flat('fit', 13, 'metal', 0.9); flat('grip', 14, 'darkLeather')
flat('cuff', 15, 'darkLeather', 0.8); flat('wood', 17, 'wood')

# Gesicht: Augen, Brauen, Mund, Haar im Nacken aufgemalt (Objektkoordinaten des Kopfs, cm)
def face_color(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord')
    sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    X, Y, Z = sep.outputs['X'], sep.outputs['Y'], sep.outputs['Z']
    ax = math_node(nt, 'ABSOLUTE', X)
    def ell(cx, cz, rx, rz):
        a = math_node(nt, 'DIVIDE', math_node(nt, 'SUBTRACT', ax, cx), rx)
        b = math_node(nt, 'DIVIDE', math_node(nt, 'SUBTRACT', Z, cz), rz)
        s = math_node(nt, 'ADD', math_node(nt, 'MULTIPLY', a, a), math_node(nt, 'MULTIPLY', b, b))
        return math_node(nt, 'LESS_THAN', s, 1.0)
    front = math_node(nt, 'LESS_THAN', Y, -4.5)
    eye = math_node(nt, 'MULTIPLY', ell(2.85, 0.9, 1.3, 0.62), front)
    brow = math_node(nt, 'MULTIPLY', ell(3.0, 2.45, 1.9, 0.48), front)
    mouth = math_node(nt, 'MULTIPLY', ell(0.0, -5.0, 2.0, 0.3), front)
    back = math_node(nt, 'GREATER_THAN', Y, 2.0)
    nape = math_node(nt, 'MULTIPLY', back, math_node(nt, 'GREATER_THAN', Z, -6.5))
    side = math_node(nt, 'MULTIPLY', math_node(nt, 'GREATER_THAN', ax, 6.3), math_node(nt, 'GREATER_THAN', Z, 0.5))
    hair = math_node(nt, 'MAXIMUM', nape, side)
    c = rgb_node(nt, COL['skin'])
    c = mixc(nt, mouth, c, rgb_node(nt, COL['lip']))
    c = mixc(nt, hair, c, rgb_node(nt, COL['hair']))
    c = mixc(nt, brow, c, rgb_node(nt, COL['hair'], 0.8))
    c = mixc(nt, eye, c, rgb_node(nt, COL['eye']))
    return c
make_mat('face', 1, face_color)

# Schild: Farbe, Querstreifen, eiserner Rand (Attribut 'rim' = Abstand zum Umriss)
SH_HT = 0.41 * H; SH_HW = 0.165 * H
def shield_masks(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord')
    sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    at = nt.nodes.new('ShaderNodeAttribute'); at.attribute_name = 'rim'
    rim = math_node(nt, 'LESS_THAN', at.outputs['Fac'], 2.6)
    stripe = math_node(nt, 'LESS_THAN', math_node(nt, 'ABSOLUTE', math_node(nt, 'SUBTRACT', sep.outputs['Y'], SH_HT * 0.08)), 0.016 * H)
    xr = math_node(nt, 'DIVIDE', sep.outputs['X'], SH_HW)
    curve = math_node(nt, 'MULTIPLY', math_node(nt, 'MULTIPLY', xr, xr), 4.5)
    front = math_node(nt, 'GREATER_THAN', math_node(nt, 'ADD', sep.outputs['Z'], curve), -0.6)
    return rim, math_node(nt, 'MULTIPLY', stripe, front), front
def shield_color(nt):
    rim, stripe, front = shield_masks(nt)
    c = rgb_node(nt, COL['shield'])  # beidseitig bemalt (Auftrag Sokrates; Dress.kt: Rueckseite Holz)
    c = mixc(nt, stripe, c, rgb_node(nt, COL['stripe']))
    return mixc(nt, rim, c, rgb_node(nt, COL['metal']))
def shield_id(nt):
    rim, stripe, front = shield_masks(nt)
    v = math_node(nt, 'ADD', 18.0, math_node(nt, 'MULTIPLY', stripe, 1.0))
    v = math_node(nt, 'ADD', v, math_node(nt, 'MULTIPLY', rim, 2.0))
    return math_node(nt, 'ADD', v, math_node(nt, 'MULTIPLY', math_node(nt, 'SUBTRACT', 1.0, front), 4.0))
make_mat('shield', 18, shield_color, mid_fn=shield_id)
ID_NAMES = {1: 'skin', 2: 'chain', 3: 'tabard', 4: 'sleeve', 5: 'pants', 6: 'boots', 7: 'belt', 8: 'gold', 9: 'cloak',
            10: 'helm', 11: 'helmrim', 12: 'steel', 13: 'fit', 14: 'grip', 15: 'cuff', 17: 'wood', 18: 'shield', 19: 'stripe', 20: 'rim', 22: 'shieldback'}

# ---------------------------------------------------------------- Gerüst (Pose: bereit, Schwert vorn, Schild am linken Arm)
J = {}
def j(name, r, u, f, rad):
    J[name] = (P(r, u, f), rad)
j('pelvis', 0, 90, -0.5, (13.0, 10.0))
j('waist', 0, 103, 0, (12.0, 9.2))
j('belly', 0, 116, 0.5, (13.8, 10.0))
j('chest', 0, 128, 1.0, (15.6, 10.6))
j('chestTop', 0, 138, -0.5, (14.0, 9.0))
j('neck', 0, 147, -1.0, (5.4, 5.4))
j('neckTop', 0, 156, -0.2, (5.0, 5.0))
for s, sg in (('R', 1), ('L', -1)):
    j('sh' + s, sg * 16.0, 141.0, -1.0, (6.4, 6.4))
# rechter Arm (Waffe): Hand vorn auf Hueftehoehe
j('upR', 18.8, 127.5, -3.0, (5.3, 5.3)); j('elR', 21.0, 114.0, -5.0, (4.1, 4.1))
j('foR', 21.5, 104.0, 3.5, (4.3, 4.3)); j('wrR', 20.0, 94.5, 13.0, (2.9, 2.9))
# linker Arm (Schild)
j('upL', -19.5, 127.5, -2.0, (5.3, 5.3)); j('elL', -22.0, 114.0, -3.0, (4.1, 4.1))
j('foL', -19.0, 104.5, 6.0, (4.3, 4.3)); j('wrL', -15.5, 95.0, 15.0, (2.9, 2.9))
# Beine: rechter Fuss vorn
for s, sg, ff in (('R', 1, 6.0), ('L', -1, -5.0)):
    j('hip' + s, sg * 8.8, 85.0, 0.0, (9.2, 9.2))
    j('thigh' + s, sg * 9.4, 68.0, ff * 0.35 + 1.0, (7.9, 7.9))
    j('knee' + s, sg * 9.8, 50.5, ff * 0.6 + 1.5, (5.1, 5.1))
    j('calf' + s, sg * 10.0, 37.0, ff * 0.8 + 0.2, (6.1, 6.1))
    j('ankle' + s, sg * 10.3, 9.0, ff, (3.5, 3.5))
    j('heel' + s, sg * 10.3, 3.6, ff - 3.5, (3.6, 3.6))
    j('ball' + s, sg * 10.8, 3.0, ff + 13.0, (4.0, 4.0))
    j('toe' + s, sg * 11.0, 2.6, ff + 18.0, (3.0, 3.0))
E = [('pelvis', 'waist'), ('waist', 'belly'), ('belly', 'chest'), ('chest', 'chestTop'), ('chestTop', 'neck'), ('neck', 'neckTop'),
     ('chestTop', 'shR'), ('chestTop', 'shL')]
for s in 'RL':
    E += [('sh' + s, 'up' + s), ('up' + s, 'el' + s), ('el' + s, 'fo' + s), ('fo' + s, 'wr' + s),
          ('pelvis', 'hip' + s), ('hip' + s, 'thigh' + s), ('thigh' + s, 'knee' + s), ('knee' + s, 'calf' + s),
          ('calf' + s, 'ankle' + s), ('ankle' + s, 'heel' + s), ('ankle' + s, 'ball' + s), ('ball' + s, 'toe' + s)]

names = list(J.keys()); idx = {n: i for i, n in enumerate(names)}
me = bpy.data.meshes.new('body')
me.from_pydata([tuple(J[n][0]) for n in names], [(idx[a], idx[b]) for a, b in E], [])
body = bpy.data.objects.new('body', me); link(body)
sk = body.modifiers.new('skin', 'SKIN'); sk.use_smooth_shade = True; sk.branch_smoothing = 0.6
for n in names:
    me.skin_vertices[0].data[idx[n]].radius = J[n][1]
me.skin_vertices[0].data[idx['pelvis']].use_root = True
sub = body.modifiers.new('sub', 'SUBSURF'); sub.levels = 2; sub.render_levels = 2
apply_mods(body)
body.data.materials.append(MATS['skin'])
for p in body.data.polygons: p.use_smooth = True

# Armatur aus demselben Gelenkgraph (fuer spaetere Animation; hier nur angelegt)
arm = bpy.data.armatures.new('rig'); rig = bpy.data.objects.new('rig', arm); link(rig)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode='EDIT')
for a, b in E:
    bn = arm.edit_bones.new(a + '-' + b); bn.head = J[a][0]; bn.tail = J[b][0]
bpy.ops.object.mode_set(mode='OBJECT')
rig.hide_render = True

# Koerperteile beschriften: naechstes Segment
SEG = [(a, b) for a, b in E]
def label_verts(V):
    best = np.full(len(V), 1e9); lab = np.zeros(len(V), int)
    for k, (a, b) in enumerate(SEG):
        A = np.array(J[a][0]); B = np.array(J[b][0])
        ab = B - A; t = np.clip(((V - A) @ ab) / (ab @ ab), 0, 1)
        q = A + t[:, None] * ab
        ra = J[a][1][0]; rb = J[b][1][0]
        d = np.linalg.norm(V - q, axis=1) - (ra + (rb - ra) * t)
        m = d < best; best[m] = d[m]; lab[m] = k
    return lab
BV, BN = np_mesh(body)
BLAB = label_verts(BV)
SEGNAME = [a + '-' + b for a, b in SEG]

def seg_is(lab, *keys):
    ok = np.zeros(len(lab), bool)
    for k, nm in enumerate(SEGNAME):
        if any(key in nm for key in keys): ok |= (lab == k)
    return ok

def shell(name, mask, off, mat, thick=0.5):
    """Kopie der Koerperflaechen, deren Ecken alle in mask liegen, um off entlang der Normale versetzt, mit Dicke."""
    bm = bmesh.new(); bm.from_mesh(body.data)
    bm.verts.ensure_lookup_table()
    kill = [f for f in bm.faces if not all(mask[v.index] for v in f.verts)]
    bmesh.ops.delete(bm, geom=kill, context='FACES')
    for v in bm.verts: v.co = v.co + v.normal * off
    me2 = bpy.data.meshes.new(name); bm.to_mesh(me2); bm.free()
    o = bpy.data.objects.new(name, me2); link(o); o.data.materials.append(MATS[mat])
    for p in me2.polygons: p.use_smooth = True
    if thick:
        so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick; so.offset = -1; so.use_even_offset = True
        apply_mods(o)
    return o

Z = BV[:, 2]
arms = seg_is(BLAB, 'shR-', 'shL-', 'upR', 'upL', 'elR', 'elL', 'foR', 'foL')
legs = seg_is(BLAB, 'hipR', 'hipL', 'thigh', 'knee', 'calf', 'ankle', 'heel', 'ball')
trunkm = ~arms & ~legs
# Kettenhemd (chain_shirt): Rumpf und Becken, Aermel bis gut halb zum Ellbogen
def frac_along(V, a, b):
    A = np.array(J[a][0]); B = np.array(J[b][0]); ab = B - A
    return ((V - A) @ ab) / (ab @ ab)
upper_part = np.zeros(len(BV), bool)
for s in 'RL':
    t = frac_along(BV, 'sh' + s, 'el' + s)
    side = seg_is(BLAB, 'sh' + s + '-', 'up' + s + '-el', 'up' + s)
    upper_part |= side & (t < 0.55)
HEM = hipY - 0.06 * H
chain_mask = ((trunkm & (Z > 40)) | upper_part | (legs & (Z > HEM - 2) & seg_is(BLAB, 'hip'))) & (Z > HEM) & (Z < 152)
chain_mask |= upper_part
chain = shell('chain', chain_mask, 1.0, 'chain', 0.5)
sleeve = shell('sleeves', arms & (Z > 0) & ~seg_is(BLAB, 'xx'), 0.55, 'sleeve', 0.3)
# Aermel enden am Handgelenk
pants = shell('pants', legs & (Z < HEM + 6) & (Z > 22), 0.5, 'pants', 0.3)
# Stiefel: Fuss und Unterschenkel bis gut ein Drittel, Stulpe oben
boot_top = ankleY + (kneeY - ankleY) * 0.42
boots = shell('boots', legs & (Z < boot_top), 1.0, 'boots', 0.6)
cuff = shell('cuff', legs & (Z < boot_top + 0.5) & (Z > boot_top - 3.5), 1.8, 'cuff', 0.6)

# ---------------------------------------------------------------- Kopf
def head_mesh():
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=5, radius=1.0)
    for v in bm.verts:
        x, y, z = v.co  # x = -rechts, y = -vorn, z = hoch
        r, f, u = -x, -y, z
        pr, pu, pf = r * 7.6, u * 11.4, f * 9.6
        s = lambda a: max(0.0, min(1.0, a))
        # Kiefer schmaler, Hinterkopf unten zum Nacken
        jaw = s((-pu - 1.5) / 9.0)
        pr *= 1.0 - 0.30 * jaw * jaw
        if pf < 0: pf *= 1.0 - 0.45 * s((-pu - 2.5) / 8.0)
        if pf > 0: pf *= 1.0 - 0.12 * jaw
        # Stirn flacher, Gesicht etwas flacher
        if pf > 0: pf -= 0.8 * s(pf / 9.6) * (1 - abs(pr) / 8.0)
        g = lambda a, b, c, d: math.exp(-((a - b) / c) ** 2 - d)
        front = s(pf / 4.0)
        # Nase, Brauenbogen, Augenhoehlen, Kinn, Wangen
        nose = 2.3 * math.exp(-(pr / (1.0 + 0.5 * s((1.0 - pu) / 4.0))) ** 2 - ((pu + 1.3) / 2.5) ** 2)
        brow = 0.6 * math.exp(-((pu - 2.6) / 0.9) ** 2) * s((5.8 - abs(pr)) / 1.5)
        sock = -0.75 * math.exp(-((abs(pr) - 2.9) / 1.4) ** 2 - ((pu - 0.9) / 1.1) ** 2)
        chin = 0.6 * math.exp(-(pr / 2.4) ** 2 - ((pu + 9.0) / 1.6) ** 2)
        cheek = 0.35 * math.exp(-((abs(pr) - 4.2) / 1.6) ** 2 - ((pu + 1.8) / 1.6) ** 2)
        lips = 0.25 * math.exp(-(pr / 2.0) ** 2 - ((pu + 5.0) / 0.7) ** 2)
        pf += front * (nose + brow + sock + chin + cheek + lips)
        v.co = Vector((-pr, -pf, pu))
    me = bpy.data.meshes.new('head'); bm.to_mesh(me); bm.free()
    return me
hme = head_mesh()
head = bpy.data.objects.new('head', hme); link(head)
head.location = P(0, headCy, 0.8)
head.data.materials.append(MATS['face'])
for p in hme.polygons: p.use_smooth = True
# Ohren
for sg in (1, -1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=24, ring_count=12)
    e = bpy.context.active_object; e.name = 'ear'
    e.scale = (0.9, 2.0, 3.0); e.location = head.location + P(sg * 7.0, -0.5, -0.8)
    e.rotation_euler = (0, sg * -0.25, 0)
    e.parent = root; e.data.materials.append(MATS['skin'])
    for p in e.data.polygons: p.use_smooth = True

# Helm (helmet, Dress.kt): Schale ueber dem Schaedel, Rand, Nasal
def head_part(name, keep, off, mat, thick):
    bm = bmesh.new(); bm.from_mesh(hme)
    kill = [f for f in bm.faces if not all(keep(v.co) for v in f.verts)]
    bmesh.ops.delete(bm, geom=kill, context='FACES')
    bm.normal_update()
    for v in bm.verts: v.co = v.co + v.normal * off
    m2 = bpy.data.meshes.new(name); bm.to_mesh(m2); bm.free()
    o = bpy.data.objects.new(name, m2); link(o); o.location = head.location; o.data.materials.append(MATS[mat])
    for p in m2.polygons: p.use_smooth = True
    so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick; so.offset = -1
    apply_mods(o)
    return o
edge_u = lambda co: 0.6 + 0.38 * (-co.y)  # Helmkante: vorn hoeher, hinten tiefer
head_part('helm', lambda co: co.z > edge_u(co) - 0.2, 1.3, 'helm', 0.6)
head_part('helmrim', lambda co: edge_u(co) - 0.2 < co.z < edge_u(co) + 1.5, 1.9, 'helmrim', 0.7)
bpy.ops.mesh.primitive_cube_add(size=1)
nas = bpy.context.active_object; nas.name = 'nasal'; nas.parent = root
nas.scale = (1.5, 0.7, 6.0); nas.location = head.location + P(0, -0.9, 10.6)
nas.rotation_euler = (math.radians(-6), 0, 0)
bv = nas.modifiers.new('bv', 'BEVEL'); bv.width = 0.3; bv.segments = 2
nas.data.materials.append(MATS['helm'])

# ---------------------------------------------------------------- BVH-Hilfen
def world_arrays(objs):
    Vs, Fs, off = [], [], 0
    for o in objs:
        mw = o.matrix_world
        me = o.data
        v = np.array([tuple(mw @ vv.co) for vv in me.vertices])
        Vs.append(v); Fs += [[off + i for i in p.vertices] for p in me.polygons]; off += len(v)
    return np.vstack(Vs), Fs
def bvh(objs):
    bpy.context.view_layer.update()
    V, F = world_arrays(objs)
    return BVHTree.FromPolygons([tuple(v) for v in V], F)

def grid_obj(name, G, mat, thick, closed_u=False):
    nr, nc = G.shape[0], G.shape[1]
    verts = G.reshape(-1, 3); faces = []
    for i in range(nr - 1):
        for k in range(nc - 1):
            a = i * nc + k; faces.append((a, a + 1, a + nc + 1, a + nc))
    o = mesh_obj(name, verts, faces, MATS[mat])
    if thick:
        so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick; so.offset = 0; so.use_even_offset = True
        apply_mods(o)
    return o

# ---------------------------------------------------------------- Wappenrock: Bahn vorn und hinten, haengt ab dem Guertel
trunk_bvh = bvh([body, chain])
half = shoulderX * 0.34
top_t = shoulderY - 0.02 * H; bot_t = kneeY + 0.06 * H
def tabard(side):
    zs = np.linspace(top_t, bot_t, 70); xs = np.linspace(-half, half, 15)
    G = np.zeros((len(zs), len(xs), 3))
    for k, x in enumerate(xs):
        prev = None
        for i, z in enumerate(zs):
            o = Vector((x, -side * 60, z)); d = Vector((0, side, 0))
            hit = trunk_bvh.ray_cast(o, d)
            y = (hit[0].y if hit[0] else 0.0) - side * 1.6
            if z < beltY and prev is not None:
                y = min(y, prev) if side > 0 else max(y, prev)
            # Falten im haengenden Teil
            if z < beltY - 2:
                y += -side * 0.35 * math.cos(x / half * 1.0 * math.pi) * min(1, (beltY - z) / 20)
            prev = y if z >= beltY - 1 else prev
            G[i, k] = (x, y, z)
    return grid_obj('tabard', G, 'tabard', 0.45)
tabF = tabard(1); tabB = tabard(-1)

# ---------------------------------------------------------------- Guertel
belt_bvh = bvh([body, chain, tabF, tabB])
def ring_band(name, zc, hw, off, mat, thick, n=72):
    zs = [zc - hw, zc, zc + hw]
    G = np.zeros((3, n + 1, 3))
    for i, z in enumerate(zs):
        for k in range(n + 1):
            a = 2 * math.pi * k / n; d = Vector((math.sin(a), math.cos(a), 0))
            o = Vector((0, 0, z)) + d * 60
            hit = belt_bvh.ray_cast(o, -d)
            r = (hit[0] - Vector((0, 0, z))).length if hit[0] else 14
            G[i, k] = tuple(Vector((0, 0, z)) + d * (r + off))
    return grid_obj(name, G, mat, thick)
belt = ring_band('belt', beltY, 1.25, 0.4, 'belt', 0.5)
bpy.ops.mesh.primitive_cube_add(size=1)
buckle = bpy.context.active_object; buckle.name = 'buckle'; buckle.parent = root
hb = belt_bvh.ray_cast(Vector((0, -60, beltY)), Vector((0, 1, 0)))
buckle.location = hb[0] + Vector((0, -0.9, 0)); buckle.scale = (4.4, 1.0, 3.4)
bv = buckle.modifiers.new('bv', 'BEVEL'); bv.width = 0.4; bv.segments = 2
buckle.data.materials.append(MATS['gold'])

# ---------------------------------------------------------------- Umhang: haengt von den Schultern, faellt frei ab dem Gesaess
hem = kneeY - 0.05 * H
cloak_bvh = bvh([body, chain, tabB, belt, sleeve])
def cloak():
    nz, nt_ = 60, 49
    zs = np.linspace(149.0, hem, nz)
    G = np.zeros((nz, nt_, 3))
    seatZ = hipY + 0.1 * H - 10
    for k in range(nt_):
        tt = -1 + 2 * k / (nt_ - 1)
        prev = None
        for i, z in enumerate(zs):
            # oben reicht er ueber die Schultern nach vorn, unten bleibt er hinter den Armen
            tmax = 118 if z > 140 else (118 - (140 - z) * 1.4 if z > 120 else 90)
            th = math.radians(tt * tmax)
            d = Vector((math.sin(th), math.cos(th), 0))
            c = Vector((0, 1.5, z))
            hit = cloak_bvh.ray_cast(c + d * 70, -d)
            r = (hit[0] - c).length + 1.3 if hit[0] else (prev or 18)
            if prev is not None and z < 140: r = max(r, prev)
            if z < seatZ: r += 0.10 * (seatZ - z) / nz * 3
            prev = r
            fold = 0.9 * min(1, max(0, (140 - z) / 50)) * math.sin(tt * 7.5 * math.pi)
            G[i, k] = tuple(c + d * (r + fold))
    return grid_obj('cloak', G, 'cloak', 0.6)
cl = cloak()
sm = cl.modifiers.new('sm', 'SMOOTH'); sm.iterations = 4; sm.factor = 0.5; apply_mods(cl)
for p in cl.data.polygons: p.use_smooth = True
# Spangen an den Schultern (Gold)
for sg in (1, -1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=20, ring_count=10)
    e = bpy.context.active_object; e.name = 'clasp'; e.parent = root
    hc = cloak_bvh.ray_cast(P(sg * shoulderX * 0.62, shoulderY + 1, 40), P(0, 0, -1) - P(0, 0, 0))
    e.location = (hc[0] if hc[0] else P(sg * 11, shoulderY, 8)) + P(0, 0, 1.2)
    e.scale = (2.1, 1.2, 2.1); e.data.materials.append(MATS['gold'])
    for p in e.data.polygons: p.use_smooth = True

# ---------------------------------------------------------------- Haende: Faust um einen Griff
def fist(name, wrist, fore_dir, grip_dir, grip_r=1.35):
    """Faust: Handruecken, vier gekruemmte Finger um die Griffachse, Daumen darueber."""
    fd = fore_dir.normalized(); gd = grip_dir.normalized()
    side = fd.cross(gd).normalized()
    center = wrist + fd * 6.0
    objs = []
    # Handballen/Ruecken
    bpy.ops.mesh.primitive_cube_add(size=1)
    pm = bpy.context.active_object; pm.parent = root
    M = Matrix((gd, fd, side)).transposed()
    pm.matrix_basis = Matrix.Translation(wrist + fd * 3.6 - side * 0.4) @ M.to_4x4() @ Matrix.Diagonal((7.4, 6.5, 4.2, 1))
    s2 = pm.modifiers.new('s', 'SUBSURF'); s2.levels = 3
    objs.append(pm)
    # Finger als Ringe um den Griff
    for i in range(4):
        bpy.ops.mesh.primitive_torus_add(major_radius=grip_r + 1.0, minor_radius=1.05 - 0.07 * i, major_segments=24, minor_segments=10)
        t = bpy.context.active_object; t.parent = root
        R = Matrix((side, fd, gd)).transposed()  # Torusachse = Griffachse
        t.matrix_basis = Matrix.Translation(center + gd * (2.9 - i * 2.0)) @ R.to_4x4()
        objs.append(t)
    # Daumen
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=16, ring_count=8)
    th = bpy.context.active_object; th.parent = root
    td = (gd * 0.8 + fd * 0.6).normalized()
    R = Matrix((side, td.cross(side), td)).transposed()
    th.matrix_basis = Matrix.Translation(center + gd * 3.8 - side * 1.6 - fd * 0.8) @ R.to_4x4() @ Matrix.Diagonal((1.15, 1.0, 3.2, 1))
    objs.append(th)
    for o in objs:
        o.data.materials.append(MATS['skin'])
        for p in o.data.polygons: p.use_smooth = True
    return center
wrR = J['wrR'][0]; foR = J['foR'][0]
fore_dirR = (wrR - foR).normalized()
wdir = P(0.06, 0.98, 0.12).normalized()  # Rig.weapon (HeroFigure.kt STAND)
# Griff senkrecht zum Unterarm halten (Handschlag-Griff)
wdir = wdir.normalized()
gripC = fist('handR', wrR, fore_dirR, wdir)
wrL = J['wrL'][0]; foL = J['foL'][0]; fore_dirL = (wrL - foL).normalized()
fist('handL', wrL, fore_dirL, P(0, 1, 0) - fore_dirL * P(0, 1, 0).dot(fore_dirL))

# ---------------------------------------------------------------- Schwert (longsword, Dress.kt)
def cyl(a, b, ra, rb, mat, seg=16):
    bm = bmesh.new()
    d = (b - a); L = d.length; dn = d.normalized()
    tmp = Vector((0, 0, 1)) if abs(dn.z) < 0.9 else Vector((1, 0, 0))
    u = dn.cross(tmp).normalized(); v = dn.cross(u)
    ring = []
    for t, rr in ((0, ra), (1, rb)):
        ring.append([bm.verts.new(a + d * t + (u * math.cos(2 * math.pi * k / seg) + v * math.sin(2 * math.pi * k / seg)) * rr) for k in range(seg)])
    for k in range(seg):
        bm.faces.new((ring[0][k], ring[0][(k + 1) % seg], ring[1][(k + 1) % seg], ring[1][k]))
    bm.faces.new(list(reversed(ring[0]))); bm.faces.new(ring[1])
    m2 = bpy.data.meshes.new('cyl'); bm.to_mesh(m2); bm.free()
    o = mesh_obj('cyl', [], [], None); o.data = m2; o.data.materials.append(MATS[mat])
    for p in m2.polygons: p.use_smooth = True
    return o
fwd = (P(0, 0, 1) - P(1, 0, 0) * 0.9).normalized()
e = (fwd - wdir * fwd.dot(wdir)).normalized()   # Schneide nach vorn
nflat = wdir.cross(e).normalized()
at = lambda t: gripC + wdir * t
cyl(at(-9.0), at(5.0), 1.35, 1.35, 'grip')
bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=20, ring_count=10)
pm = bpy.context.active_object; pm.parent = root
pm.matrix_basis = Matrix.Translation(at(-10.6)) @ Matrix((e, wdir, nflat)).transposed().to_4x4() @ Matrix.Diagonal((2.6, 1.5, 1.6, 1))
pm.data.materials.append(MATS['fit'])
for p in pm.data.polygons: p.use_smooth = True
cyl(at(5.6) - e * 10.0, at(5.6) + e * 10.0, 0.75, 0.75, 'fit')
for sg in (1, -1):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.0, segments=12, ring_count=6)
    q = bpy.context.active_object; q.parent = root; q.location = at(5.6) + e * sg * 10.0; q.data.materials.append(MATS['fit'])
def blade():
    bm = bmesh.new(); L = 69.0; tip = 12.0
    secs = []
    st = [0, 10, 20, 30, 40, 50, L - tip, L - tip * 0.6, L - tip * 0.25]
    for s in st:
        w = 2.5 + (1.5 - 2.5) * s / L
        if s > L - tip: w *= 1 - (s - (L - tip)) / tip * 0.85
        th = 0.42 + (0.26 - 0.42) * s / L
        c = at(6.0 + s)
        secs.append([bm.verts.new(c + e * w), bm.verts.new(c + nflat * th), bm.verts.new(c - e * w), bm.verts.new(c - nflat * th)])
    tipv = bm.verts.new(at(6.0 + L))
    for a, b in zip(secs, secs[1:]):
        for k in range(4): bm.faces.new((a[k], a[(k + 1) % 4], b[(k + 1) % 4], b[k]))
    for k in range(4): bm.faces.new((secs[-1][k], secs[-1][(k + 1) % 4], tipv))
    bm.faces.new(list(reversed(secs[0])))
    m2 = bpy.data.meshes.new('blade'); bm.to_mesh(m2); bm.free()
    o = mesh_obj('blade', [], [], None, smooth=False); o.data = m2; o.data.materials.append(MATS['steel'])
blade()

# ---------------------------------------------------------------- Schild (heater, Dress.kt), am linken Unterarm
def heater_d(x, y, hw, ht):
    top = ht * 0.42; bottom = top - ht
    rr = (hw * hw + (top - bottom) ** 2) / (2 * hw)
    dl = math.hypot(x - (hw - rr), y - top) - rr
    dr = math.hypot(x + (hw - rr), y - top) - rr
    return max(dl, dr, y - top)
def shield():
    hw, ht = SH_HW, SH_HT
    top = ht * 0.42
    # Umriss abtasten (vom Mittelpunkt aus sternfoermig)
    n = 160; outline = []
    for k in range(n):
        a = 2 * math.pi * k / n; d = (math.cos(a), math.sin(a))
        lo, hi = 0.0, 80.0
        for _ in range(30):
            mid = (lo + hi) / 2
            if heater_d(d[0] * mid, d[1] * mid, hw, ht) < 0: lo = mid
            else: hi = mid
        outline.append((d[0] * lo, d[1] * lo, lo))
    insets = [0, 0.6, 1.3, 2.0, 2.6, 3.2, 4.0, 5.5, 8, 11, 15, 20, 26, 33, 40]
    verts, faces, rim = [], [], []
    sag = 4.5
    for di in insets:
        for (x, y, R) in outline:
            s = max(0.0, 1 - di / R)
            X, Y = x * s, y * s
            verts.append((X, Y, -sag * (X / hw) ** 2)); rim.append(di)
    verts.append((0, 0, 0)); rim.append(50)
    for i in range(len(insets) - 1):
        for k in range(n):
            a = i * n + k; b = i * n + (k + 1) % n
            faces.append((a, b, b + n, a + n))
    c = len(verts) - 1; last = (len(insets) - 1) * n
    for k in range(n): faces.append((last + k, last + (k + 1) % n, c))
    o = mesh_obj('shield', verts, faces, MATS['shield'])
    at_ = o.data.attributes.new('rim', 'FLOAT', 'POINT'); at_.data.foreach_set('value', rim)
    so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = 2.0; so.offset = -1
    # Buckel
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=24, ring_count=12)
    boss = bpy.context.active_object; boss.name = 'boss'
    boss.scale = (0.035 * H, 0.035 * H, 0.022 * H * 0.8); boss.location = (0, 0, 0.3)
    boss.data.materials.append(MATS['fit'])
    for p in boss.data.polygons: p.use_smooth = True
    boss.parent = o
    return o
sh = shield()
el = J['elL'][0]; wr = J['wrL'][0]
n = P(-0.5, 0.0, 1.0).normalized()  # Rig.shieldFace
fore = (wr - el).normalized()
up = n.cross(fore)
if up.z < 0: up = -up
up = (up + Vector((0, 0, 4.0)) - n * (n.z * 4.0)).normalized()
ax = up.cross(n).normalized()
center = el.lerp(wr, 0.55) + n * (0.02 * H)
strapY = SH_HT * 0.42 - SH_HT / 3
c0 = center - up * strapY + n * 2.5 + ax * 2.0
# die Faust bleibt hinter dem Brett
fistP = wr + fore * 6.0
need = (fistP - c0).dot(n) + 6.0
if need > 0: c0 = c0 + n * need
sh.matrix_basis = Matrix.Translation(c0) @ Matrix((ax, up, n)).transposed().to_4x4()

bpy.context.view_layer.update()
bpy.ops.wm.save_as_mainfile(filepath=OUT + '/held.blend')
print('MODEL OK', len(bpy.data.objects))
