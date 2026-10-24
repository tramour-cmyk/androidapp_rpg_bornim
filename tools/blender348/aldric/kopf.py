# Grundkopf mit Reglern (Shape Keys) und drei Maenner daraus. Aufruf: python -I kopf.py <aldric|jorin|osric>
import bpy, bmesh, math, sys, json
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

OUT = '/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/aldric'
WHO = sys.argv[-1]

# Regler: 0 = Durchschnitt, -1..1 (Falten, Bart, Haar, Lider 0..1)
SL = ['nase_laenge', 'nase_breite', 'nase_kruemmung', 'kinn', 'wangen', 'augenabstand', 'brauen', 'falten', 'wangenknochen']
CH = {
    'aldric': dict(nase_laenge=0.8, nase_breite=-0.3, nase_kruemmung=0.9, kinn=0.4, wangen=-1.0, augenabstand=-0.2, brauen=0.9,
                   falten=1.0, wangenknochen=0.9, lider=0.45, bart=1.0, haar=0.8, girth=0.86, stoop=1.0),
    'jorin': dict(nase_laenge=-0.2, nase_breite=0.8, nase_kruemmung=-0.3, kinn=0.9, wangen=0.5, augenabstand=0.3, brauen=0.5,
                  falten=0.25, wangenknochen=0.3, lider=0.15, bart=0.18, haar=0.3, girth=1.2, stoop=0.0),
    'osric': dict(nase_laenge=0.0, nase_breite=0.1, nase_kruemmung=-0.6, kinn=-0.6, wangen=0.9, augenabstand=0.1, brauen=-0.6,
                  falten=0.4, wangenknochen=-0.5, lider=0.3, bart=0.0, haar=0.0, girth=1.05, stoop=0.3),
}[WHO]

def hx(c): return ((c >> 16) & 255, (c >> 8) & 255, c & 255)
def mixh(a, b, t):
    A, B = hx(a), hx(b); return tuple(int(round(A[i] + (B[i] - A[i]) * t)) for i in range(3))
def lin(rgb, k=1.0):
    f = lambda v: (lambda w: w / 12.92 if w <= 0.04045 else ((w + 0.055) / 1.055) ** 2.4)(min(1.0, v / 255 * k))
    return (f(rgb[0]), f(rgb[1]), f(rgb[2]), 1.0)
# Farben aus CharacterArt.npcLooks: elder, guard, priest; SKIN E8B488
SKIN = hx(0xE8B488)
COLS = {
    'aldric': dict(hair=hx(0xE8E8F0), cloth=hx(0x7048A0), dark=hx(0x4A2C70), iris=hx(0x5A6A7A)),
    'jorin': dict(hair=hx(0x403020), cloth=hx(0x3858A8), dark=hx(0x203878), iris=hx(0x4A3A2A)),
    'osric': dict(hair=hx(0xA07850), cloth=hx(0xF0E8D0), dark=hx(0xC8B898), iris=hx(0x5A4A30)),
}[WHO]
SKIN_W = mixh(0xE8B488, 0xC89878, 0.25) if WHO == 'aldric' else SKIN

bpy.ops.wm.read_factory_settings(use_empty=True)
scn = bpy.context.scene
MATS = {}
def make_mat(name, mid, color_fn, ink_attr=None, mid_fn=None):
    m = bpy.data.materials.new(name); nt = m.node_tree if m.node_tree else None
    m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
    out = nt.nodes.new('ShaderNodeOutputMaterial'); out.name = 'M_out'
    col = color_fn(nt)
    diff = nt.nodes.new('ShaderNodeBsdfDiffuse'); diff.name = 'M_light'
    e = {}
    for k in ('albedo', 'normal', 'depth', 'id', 'ink'):
        e[k] = nt.nodes.new('ShaderNodeEmission'); e[k].name = 'M_' + k
    nt.links.new(col, e['albedo'].inputs['Color'])
    geo = nt.nodes.new('ShaderNodeNewGeometry')
    vm = nt.nodes.new('ShaderNodeVectorMath'); vm.operation = 'MULTIPLY_ADD'
    vm.inputs[1].default_value = (.5, .5, .5); vm.inputs[2].default_value = (.5, .5, .5)
    nt.links.new(geo.outputs['Normal'], vm.inputs[0]); nt.links.new(vm.outputs[0], e['normal'].inputs['Color'])
    cam = nt.nodes.new('ShaderNodeCameraData'); nt.links.new(cam.outputs['View Z Depth'], e['depth'].inputs['Strength'])
    if mid_fn: nt.links.new(mid_fn(nt), e['id'].inputs['Strength'])
    else: e['id'].inputs['Strength'].default_value = float(mid)
    if ink_attr:
        at = nt.nodes.new('ShaderNodeAttribute'); at.attribute_name = ink_attr
        nt.links.new(at.outputs['Fac'], e['ink'].inputs['Strength'])
    else:
        e['ink'].inputs['Strength'].default_value = 0.0
    MATS[name] = m; return m
def rgbn(nt, rgb, k=1.0):
    n = nt.nodes.new('ShaderNodeRGB'); n.outputs[0].default_value = lin(rgb, k); return n.outputs[0]
def mathn(nt, op, a, b=None):
    n = nt.nodes.new('ShaderNodeMath'); n.operation = op
    for i, x in enumerate((a, b)):
        if x is None: continue
        if isinstance(x, (int, float)): n.inputs[i].default_value = x
        else: nt.links.new(x, n.inputs[i])
    return n.outputs[0]
def mixc(nt, f, a, b):
    n = nt.nodes.new('ShaderNodeMix'); n.data_type = 'RGBA'
    nt.links.new(f, n.inputs['Factor']); nt.links.new(a, n.inputs['A']); nt.links.new(b, n.inputs['B']); return n.outputs['Result']
def attr(nt, name):
    a = nt.nodes.new('ShaderNodeAttribute'); a.attribute_name = name; return a.outputs['Fac']

# Haut: Lippen und Brauen ueber Attribute gefaerbt
def skin_col(nt):
    c = rgbn(nt, SKIN_W)
    c = mixc(nt, attr(nt, 'lip'), c, rgbn(nt, mixh(0xB07A68, 0x8A5A50, 0.5 if WHO == 'aldric' else 0.15)))
    c = mixc(nt, attr(nt, 'brow'), c, rgbn(nt, COLS['hair'], 0.8 if WHO != 'aldric' else 0.92))
    return c
make_mat('skin', 1, skin_col, ink_attr='ink')
make_mat('lid', 1, lambda nt: rgbn(nt, SKIN_W, 0.95), ink_attr='ink')
def eye_col(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord'); sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    rr = mathn(nt, 'SQRT', mathn(nt, 'ADD', mathn(nt, 'MULTIPLY', sep.outputs['X'], sep.outputs['X']), mathn(nt, 'MULTIPLY', sep.outputs['Z'], sep.outputs['Z'])))
    fr = mathn(nt, 'LESS_THAN', sep.outputs['Y'], 0.0)
    iris = mathn(nt, 'MULTIPLY', mathn(nt, 'LESS_THAN', rr, 0.52), fr)
    pup = mathn(nt, 'MULTIPLY', mathn(nt, 'LESS_THAN', rr, 0.24), fr)
    c = rgbn(nt, (232, 226, 214))
    c = mixc(nt, iris, c, rgbn(nt, COLS['iris']))
    return mixc(nt, pup, c, rgbn(nt, (20, 16, 14)))
make_mat('eye', 30, eye_col)
make_mat('hair', 31, lambda nt: rgbn(nt, COLS['hair']), ink_attr='ink')
make_mat('beard', 32, lambda nt: rgbn(nt, COLS['hair'], 0.97), ink_attr='ink')
make_mat('robe', 3, lambda nt: rgbn(nt, COLS['cloth']), ink_attr='ink')
make_mat('dark', 9, lambda nt: rgbn(nt, COLS['dark'], 0.75 if WHO == 'aldric' else 1.0), ink_attr='ink')
def chain_col(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord'); sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    u = mathn(nt, 'MULTIPLY', mathn(nt, 'ARCTAN2', sep.outputs['X'], sep.outputs['Y']), 15.0)
    cb = nt.nodes.new('ShaderNodeCombineXYZ'); nt.links.new(u, cb.inputs[0]); nt.links.new(sep.outputs['Z'], cb.inputs[1])
    vo = nt.nodes.new('ShaderNodeTexVoronoi'); vo.voronoi_dimensions = '2D'; vo.inputs['Scale'].default_value = 0.62; vo.inputs['Randomness'].default_value = 0.0
    nt.links.new(cb.outputs[0], vo.inputs['Vector'])
    r = mathn(nt, 'MAXIMUM', mathn(nt, 'SUBTRACT', 1.0, mathn(nt, 'MULTIPLY', mathn(nt, 'ABSOLUTE', mathn(nt, 'SUBTRACT', vo.outputs['Distance'], 0.4)), 7.0)), 0.0)
    return mixc(nt, r, rgbn(nt, hx(0x8A9098), 0.42), rgbn(nt, hx(0x8A9098), 1.12))
make_mat('chain', 2, chain_col)
make_mat('helm', 10, lambda nt: rgbn(nt, hx(0xB8C0C8)))
make_mat('helmrim', 11, lambda nt: rgbn(nt, hx(0xB8C0C8), 0.8))
make_mat('wood', 17, lambda nt: rgbn(nt, hx(0x6E4A2C)), ink_attr='ink')
make_mat('gold', 8, lambda nt: rgbn(nt, hx(0xB8904A)))
make_mat('tabard', 4, lambda nt: rgbn(nt, COLS['cloth']))

def obj_from_bm(name, bm, mat, smooth=True):
    me = bpy.data.meshes.new(name); bm.to_mesh(me)
    o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); o.data.materials.append(MATS[mat])
    if smooth:
        for p in me.polygons: p.use_smooth = True
    return o
def set_attr(o, name, vals):
    a = o.data.attributes.get(name) or o.data.attributes.new(name, 'FLOAT', 'POINT'); a.data.foreach_set('value', list(map(float, vals)))
def apply_mods(o):
    dg = bpy.context.evaluated_depsgraph_get(); me = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
    o.modifiers.clear(); o.data = me

# ---------------------------------------------------------------- Kopfform als Funktion der Regler
bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=6, radius=1.0)
U = np.array([tuple(v.co) for v in bm.verts])
G = lambda x: np.exp(-x)
def face(p):
    r, u, f = -U[:, 0], U[:, 2], -U[:, 1]
    pr, pu, pf = r * 7.5, u * (10.4 + 0.6 * np.clip(-u, 0, 1)), f * 9.3
    jaw = np.clip((-pu - 1.5) / 9.0, 0, 1)
    pr = pr * (1 - 0.28 * jaw ** 2 + 0.10 * p['wangen'] * np.exp(-((pu + 4) / 3.5) ** 2))
    pr = pr * (1 + 0.05 * p['wangenknochen'] * np.exp(-((pu + 0.5) / 2.0) ** 2))
    pf = np.where(pf < 0, pf * (1 - 0.45 * np.clip((-pu - 2.5) / 8, 0, 1)), pf * (1 - 0.12 * jaw))
    pf = np.where(pf > 0, pf - 0.8 * np.clip(pf / 9.3, 0, 1) * (1 - np.abs(pr) / 8), pf)
    pu = pu - 1.2 * p['kinn'] * jaw ** 2
    fr = np.clip(pf / 4.0, 0, 1)
    ar = np.abs(pr)
    L = 1 + 0.28 * p['nase_laenge']; W = 1 + 0.35 * p['nase_breite']
    nc = -1.3 * L
    nose = (2.2 + 0.5 * p['nase_laenge']) * G((pr / (W * (0.75 + 0.55 * np.clip((1.2 - pu) / 4, 0, 1)))) ** 2 + ((pu - nc) / (2.4 * L)) ** 2)
    nose = nose * (1 - 0.35 * np.clip((pu - nc + 2.2 * L) / -1.0, 0, 1))
    hook = p['nase_kruemmung'] * 0.55 * G((pr / 0.8) ** 2 + ((pu - 0.0) / 1.1) ** 2)
    wings = 0.55 * W * G(((ar - 1.25 * W) / 0.55) ** 2 + ((pu - (nc - 1.0 * L)) / 0.7) ** 2)
    brow = (0.6 + 0.35 * p['brauen']) * G(((pu - 2.6) / 0.9) ** 2) * np.clip((5.8 - ar) / 1.5, 0, 1)
    ex = 2.9 + 0.35 * p['augenabstand']
    sock = -0.95 * G(((ar - ex) / 1.45) ** 2 + ((pu - 0.9) / 1.15) ** 2)
    cheekb = (0.25 + 0.5 * p['wangenknochen']) * G(((ar - 4.3) / 1.4) ** 2 + ((pu + 0.4) / 1.1) ** 2)
    cheek = 0.55 * p['wangen'] * G(((ar - 4.0) / 1.8) ** 2 + ((pu + 3.8) / 2.0) ** 2)
    chin = (0.55 + 0.45 * p['kinn']) * G((pr / 2.4) ** 2 + ((pu + 9.0) / 1.6) ** 2)
    ul = 0.38 * G((pr / 2.1) ** 2 + ((pu + 4.55) / 0.55) ** 2); ll = 0.42 * G((pr / 1.9) ** 2 + ((pu + 5.65) / 0.6) ** 2)
    mouth = -0.28 * G((pr / 2.2) ** 4 + ((pu + 5.1) / 0.22) ** 2)
    # Falten: Nasolabial, Stirn, Traenensaecke, Kraehenfuesse
    def segd(ax_, ay_, bx_, by_):
        a = np.array([ax_, ay_]); b = np.array([bx_, by_]); q = np.stack([ar, pu], 1)
        t = np.clip(((q - a) @ (b - a)) / ((b - a) @ (b - a)), 0, 1); return np.linalg.norm(q - (a + t[:, None] * (b - a)), axis=1)
    nlab = segd(1.9 * W, nc - 0.9, 2.9, -5.7)
    wr = p['falten']
    fold = -0.30 * wr * G((nlab / 0.35) ** 2) + 0.18 * wr * G(((nlab - 0.5) / 0.4) ** 2)
    fore = -0.10 * wr * sum(G(((pu - h_) / 0.22) ** 2) for h_ in (4.6, 5.6, 6.6)) * np.clip((4.6 - ar) / 1.5, 0, 1)
    bags = 0.22 * wr * G(((ar - ex) / 1.0) ** 2 + ((pu + 0.55) / 0.35) ** 2)
    hollow = -0.4 * max(0, -p['wangen']) * G(((ar - 4.6) / 1.2) ** 2 + ((pu + 2.6) / 1.6) ** 2)
    pf = pf + fr * (nose + hook + wings + brow + sock + cheekb + cheek + chin + ul + ll + mouth + fold + fore + bags + hollow)
    # Ohren-Ansatz bleibt glatt; Ohren eigene Teile
    inkv = np.maximum.reduce([
        G((pr / 2.0) ** 4 + ((pu + 5.1) / 0.16) ** 2) * fr,                                  # Mundlinie
        wr * G((nlab / 0.22) ** 2) * fr * (pu > -6.2),                                        # Nasolabialfalte
        wr * sum(G(((pu - h_) / 0.12) ** 2) for h_ in (4.6, 5.6, 6.6)) * np.clip((4.2 - ar) / 1.5, 0, 1) * fr * 0.9,
        wr * G(((ar - ex) / 0.9) ** 2 + ((pu + 0.25) / 0.12) ** 2) * fr,                      # Traenensack
        wr * sum(G(((ar - (ex + 1.7)) / 0.5) ** 2 + ((pu - 0.9 - k_) / 0.12) ** 2) for k_ in (-0.5, 0, 0.5)) * fr,
    ])
    lipm = (G((pr / 2.0) ** 2 + ((pu + 4.6) / 0.42) ** 2) + G((pr / 1.8) ** 2 + ((pu + 5.6) / 0.42) ** 2)) * fr
    browm = G(((ar - ex - 0.1) / (1.9 + 0.3 * p['brauen'])) ** 2 + ((pu - 2.35 - 0.12 * ar / 3) / (0.38 + 0.14 * p['brauen'])) ** 2) * fr
    V = np.stack([-pr, -pf, pu], 1)
    return V, inkv, lipm, browm, ex
p0 = {k: 0.0 for k in SL}
V0, _, _, _, _ = face(p0)
for i, v in enumerate(bm.verts): v.co = V0[i]
head = obj_from_bm('head', bm, 'skin'); bm.free()
# Shape Keys: je Regler die Verschiebung bei Wert 1
head.shape_key_add(name='Basis')
for k in SL:
    pk = dict(p0); pk[k] = 1.0
    Vk = face(pk)[0]
    sk = head.shape_key_add(name=k); sk.slider_min = -1.0; sk.slider_max = 1.0
    sk.data.foreach_set('co', Vk.reshape(-1))
    sk.value = CH[k]
pc = {k: CH[k] for k in SL}
_, inkv, lipm, browm, EX = face(pc)
set_attr(head, 'ink', np.clip(inkv * 1.4, 0, 1)); set_attr(head, 'lip', np.clip(lipm, 0, 1)); set_attr(head, 'brow', (browm > 0.5) * 1.0)

HEADC = Vector((0, 0, 0))
dg = bpy.context.evaluated_depsgraph_get()
he = head.evaluated_get(dg)
HV = np.array([tuple(v.co) for v in he.data.vertices])
HN = np.array([tuple(v.normal) for v in he.data.vertices])
hb = BVHTree.FromPolygons([tuple(v) for v in HV], [tuple(p.vertices) for p in he.data.polygons])

# ---------------------------------------------------------------- Augen mit Lidern
lid_open = 22 - 34 * CH['lider']   # Oberlidkante: Grad ueber der Blickachse
for sg in (1, -1):
    x = -sg * EX
    hit = hb.ray_cast(Vector((x, -40, 0.9)), Vector((0, 1, 0)))
    yS = hit[0].y if hit[0] else -8.0
    R = 1.18
    c = Vector((x, yS + R - 0.25, 0.9))
    b2 = bmesh.new(); bmesh.ops.create_uvsphere(b2, u_segments=32, v_segments=16, radius=R)
    eye = obj_from_bm('eye', b2, 'eye'); b2.free(); eye.location = c
    eye.rotation_euler = (0, 0, math.radians(sg * -4))
    # Oberlid: Kappe ueber der Kante, Unterlid darunter
    for nm, keep in (('upper', lambda el: el > lid_open), ('lower', lambda el: el < -26)):
        b3 = bmesh.new(); bmesh.ops.create_uvsphere(b3, u_segments=40, v_segments=24, radius=R + 0.16)
        kill = []
        for f_ in b3.faces:
            ok = True
            for v in f_.verts:
                d = v.co.normalized(); el = math.degrees(math.asin(max(-1, min(1, d.z))))
                if not keep(el) or d.y > 0.55: ok = False
            if not ok: kill.append(f_)
        bmesh.ops.delete(b3, geom=kill, context='FACES')
        lid = obj_from_bm('lid', b3, 'lid'); b3.free(); lid.location = c
        so = lid.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.28; so.offset = 1
        apply_mods(lid)
        # Lidfalte als Tuschelinie am Oberlid
        if nm == 'upper':
            vals = []
            for v in lid.data.vertices:
                d = v.co.normalized(); el = math.degrees(math.asin(max(-1, min(1, d.z))))
                vals.append(1.0 if abs(el - (lid_open + 20)) < 3.5 and d.y < -0.2 else 0.0)
            set_attr(lid, 'ink', vals)
        else:
            set_attr(lid, 'ink', [0.0] * len(lid.data.vertices))
        for p_ in lid.data.polygons: p_.use_smooth = True
# Ohren
for sg in (1, -1):
    b2 = bmesh.new(); bmesh.ops.create_uvsphere(b2, u_segments=24, v_segments=12, radius=1.0)
    for v in b2.verts:
        v.co = Vector((v.co.x * 0.8, v.co.y * 2.0, v.co.z * 3.2))
        if v.co.x * sg < 0: v.co.x *= 0.3
    ear = obj_from_bm('ear', b2, 'skin'); b2.free(); ear.location = (-sg * 7.0, 1.0, -0.2)
    ear.rotation_euler = (math.radians(-10), 0, math.radians(-sg * 18))
    set_attr(ear, 'ink', [0.0] * len(ear.data.vertices))

# ---------------------------------------------------------------- Bart und Haar: Schalen vom Kopf, Laenge als Shape Key
def head_shell(name, mask, off, mat):
    b = bmesh.new(); b.from_mesh(he.data); b.verts.ensure_lookup_table()
    kill = [f_ for f_ in b.faces if not all(mask[v.index] for v in f_.verts)]
    bmesh.ops.delete(b, geom=kill, context='FACES')
    idx = [v.index for v in b.verts]
    o = obj_from_bm(name, b, mat); b.free()
    return o
r_, u_, f_ = -HV[:, 0], HV[:, 2], -HV[:, 1]
if CH['bart'] > 0.05:
    T = -6.3 + 3.2 * np.clip((np.abs(r_) - 2.0) / 3.5, 0, 1)
    bm_mask = (u_ < T) & (f_ > -2.5)
    # Schnurrbart schmal ueber der Oberlippe, Mund bleibt frei
    must = (u_ < -3.7) & (u_ > -4.35) & (np.abs(r_) < 2.9) & (f_ > 0)
    bm_mask |= must
    beard = head_shell('beard', bm_mask, 0.0, 'beard')
    bv = np.array([tuple(v.co) for v in beard.data.vertices])
    from mathutils.kdtree import KDTree
    kd = KDTree(len(HV))
    for i, v in enumerate(HV): kd.insert(v, i)
    kd.balance()
    nrm = np.array([HN[kd.find(Vector(v))[1]] for v in bv])
    t0 = 0.5 + 0.9 * CH['bart']
    Tb = -6.3 + 3.2 * np.clip((np.abs(-bv[:, 0]) - 2.0) / 3.5, 0, 1)
    taper = np.clip((Tb - bv[:, 2]) / 2.5, 0.15, 1.0)
    taper = np.where((bv[:, 2] > -4.4) & (np.abs(bv[:, 0]) < 3.0), 0.45, taper)
    base = bv + nrm * (t0 * taper)[:, None]
    beard.shape_key_add(name='Basis')
    for i, v in enumerate(beard.data.shape_keys.key_blocks['Basis'].data): v.co = base[i]
    # lang: nach unten gezogen, zur Mitte schmal, vorn ueber die Brust
    w = np.clip((-bv[:, 2] - 5.5) / 5.0, 0, 1) * np.clip((bv[:, 2] + 30) / 30, 0, 1)
    longv = base.copy()
    longv[:, 2] -= 18.0 * w ** 1.3
    longv[:, 0] *= 1 - 0.45 * w
    longv[:, 1] -= 2.5 * w
    k = beard.shape_key_add(name='bart_laenge'); k.data.foreach_set('co', longv.reshape(-1)); k.value = max(0.0, (CH['bart'] - 0.3) / 0.7)
    ang = np.arctan2(bv[:, 0], -bv[:, 1])
    set_attr(beard, 'ink', ((np.abs(np.sin(ang * 6 + np.sin(bv[:, 2] * 0.7))) > 0.98) & (bv[:, 2] < -6.0)) * 1.0)
    so = beard.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.4; so.offset = -1
    sm = beard.modifiers.new('sm', 'SMOOTH'); sm.iterations = 6
if CH['haar'] > 0.05:
    hairline = 4.3 + 2.5 * (1 - CH['haar'])
    hm = ((u_ > hairline + 0.15 * f_) | ((f_ < -1) & (u_ > -7 + 4 * (1 - CH['haar'])))) & ~((np.abs(r_) > 6.3) & (u_ < 1.5) & (f_ > -2.5))
    hair = head_shell('hair', hm, 0, 'hair')
    hv = np.array([tuple(v.co) for v in hair.data.vertices])
    from mathutils.kdtree import KDTree
    kd = KDTree(len(HV))
    for i, v in enumerate(HV): kd.insert(v, i)
    kd.balance()
    nrm = np.array([HN[kd.find(Vector(v))[1]] for v in hv])
    th = 0.4 + 1.1 * CH['haar']
    for i, v in enumerate(hair.data.vertices): v.co = Vector(hv[i] + nrm[i] * th)
    ang = np.arctan2(hv[:, 0], -hv[:, 1])
    set_attr(hair, 'ink', (np.abs(np.sin(ang * 7 + hv[:, 2] * 0.25)) > 0.985) * 1.0)
    so = hair.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.4; so.offset = -1
    sm = hair.modifiers.new('sm', 'SMOOTH'); sm.iterations = 4

# ---------------------------------------------------------------- Oberkoerper (gedrungen: Kopf 23 cm, Schultern breit)
g = CH['girth']; st = CH['stoop']
def P(r, u, f): return Vector((-r, -f, u))
HEAD_TOP = 11.0
# Kopf sitzt bei z=0; Hals darunter
nodes = {
    'neckTop': (P(0, -8.0, -1.0 + st * 1.0), (4.9 * g, 4.9 * g)), 'neck': (P(0, -14, -1.5 - st * 1.0), (5.6 * g, 5.6 * g)),
    'chestTop': (P(0, -21, -2.5 - st * 2.5), (12.0 * g, 8.0 * g)), 'chest': (P(0, -32, -2 - st * 2.0), (13.2 * g, 9.4 * g)),
    'belly': (P(0, -46, -1.5), (12.6 * g, 9.2 * g)), 'waist': (P(0, -60, -1.5), (12 * g, 8.8 * g)),
    'shR': (P(18.5 * g, -24 - st, -3 - st * 2), (6.6 * g, 6.6 * g)), 'shL': (P(-18.5 * g, -24 - st, -3 - st * 2), (6.6 * g, 6.6 * g)),
    'elL': (P(-22 * g, -52, -4), (4.6 * g, 4.6 * g)),
}
edges = [('neckTop', 'neck'), ('neck', 'chestTop'), ('chestTop', 'chest'), ('chest', 'belly'), ('belly', 'waist'), ('chestTop', 'shR'), ('chestTop', 'shL'), ('shL', 'elL')]
if WHO == 'aldric':
    nodes.update({'elR': (P(23 * g, -48, 2), (4.4 * g, 4.4 * g)), 'wrR': (P(14, -38, 20), (3.0, 3.0))})
    edges += [('shR', 'elR'), ('elR', 'wrR')]
else:
    nodes['elR'] = (P(22 * g, -52, -4), (4.6 * g, 4.6 * g)); edges += [('shR', 'elR')]
names = list(nodes); ix = {n: i for i, n in enumerate(names)}
me = bpy.data.meshes.new('body'); me.from_pydata([tuple(nodes[n][0]) for n in names], [(ix[a], ix[b]) for a, b in edges], [])
body = bpy.data.objects.new('body', me); scn.collection.objects.link(body)
skm = body.modifiers.new('skin', 'SKIN')
for n in names: me.skin_vertices[0].data[ix[n]].radius = nodes[n][1]
me.skin_vertices[0].data[ix['waist']].use_root = True
s2 = body.modifiers.new('sub', 'SUBSURF'); s2.levels = 2
apply_mods(body); body.data.materials.append(MATS['skin'])
for p_ in body.data.polygons: p_.use_smooth = True
set_attr(body, 'ink', [0.0] * len(body.data.vertices))
bpy.context.view_layer.update()
BV = np.array([tuple(v.co) for v in body.data.vertices]); BN = np.array([tuple(v.normal) for v in body.data.vertices])

def body_shell(name, mask, off, mat, thick=0.6, ink=None):
    b = bmesh.new(); b.from_mesh(body.data); b.verts.ensure_lookup_table()
    kill = [f_ for f_ in b.faces if not all(mask[v.index] for v in f_.verts)]
    bmesh.ops.delete(b, geom=kill, context='FACES')
    for v in b.verts: v.co = v.co + v.normal * off
    o = obj_from_bm(name, b, mat); b.free()
    vv = np.array([tuple(v.co) for v in o.data.vertices])
    set_attr(o, 'ink', ink(vv) if ink else [0.0] * len(vv))
    so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick; so.offset = -1
    return o
bz = BV[:, 2]; bx = BV[:, 0]; by = BV[:, 1]
below_neck = bz < -15.5
if WHO == 'aldric':
    # Robe mit Faltenlinien, Kragen offen zum Bart; dunkler Umhang ueber Schultern und Ruecken
    body_shell('robe', below_neck | (bz < -12), 1.0, 'robe', ink=lambda v: ((np.abs(np.sin(v[:, 0] * 0.55)) > 0.985) & (v[:, 2] < -38) & (v[:, 1] < 0)) * 1.0)
    cm = (bz < -13) & ((by > -4) | (np.abs(bx) > 11 * g))
    body_shell('cloak', cm, 3.0, 'dark', thick=0.8, ink=lambda v: ((np.abs(np.sin(v[:, 0] * 0.45 + v[:, 2] * 0.05)) > 0.985) & (v[:, 2] < -36)) * 1.0)
elif WHO == 'jorin':
    body_shell('chain', bz < -13, 1.0, 'chain')
    tm = (bz < -17) & (np.abs(bx) < 7.5 * g) & (by < -3)
    body_shell('tabard', tm, 2.2, 'tabard', thick=0.5)
else:
    body_shell('robe', bz < -12.5, 1.4, 'robe', ink=lambda v: ((np.abs(np.sin(v[:, 0] * 0.5)) > 0.985) & (v[:, 2] < -40) & (v[:, 1] < 0)) * 1.0)
    # Kapuze liegt im Nacken
    hm2 = (bz < -13) & (bz > -27) & (by > -2)
    body_shell('hood', hm2, 3.2, 'dark', thick=0.8)
    # Sonne auf der Brust (Gold)
    hit = BVHTree.FromPolygons([tuple(v) for v in BV], [tuple(p_.vertices) for p_ in body.data.polygons]).ray_cast(Vector((0, -60, -33)), Vector((0, 1, 0)))
    b2 = bmesh.new(); bmesh.ops.create_circle(b2, cap_ends=True, segments=32, radius=3.2)
    for k_ in range(8):
        a = k_ * math.pi / 4
        bmesh.ops.create_cone(b2, segments=4, radius1=0.7, radius2=0.0, depth=2.6,
            matrix=Matrix.Translation(Vector((math.cos(a) * 4.6, math.sin(a) * 4.6, 0))) @ Matrix.Rotation(a, 4, 'Z') @ Matrix.Rotation(math.pi / 2, 4, 'Y'))
    sun = obj_from_bm('sun', b2, 'gold', smooth=False); b2.free()
    sun.rotation_euler = (math.radians(90), 0, 0); sun.location = hit[0] + Vector((0, -1.9, 0))
    set_attr(sun, 'ink', [0.0] * len(sun.data.vertices))

if WHO == 'jorin':
    # Helm wie beim Helden: Schale ueber dem Schaedel, Rand, Nasal
    hmask = (u_ > 1.6 + 0.38 * f_)
    helm = head_shell('helm', hmask, 0, 'helm')
    hv = np.array([tuple(v.co) for v in helm.data.vertices]); c_ = Vector((0, 0, 0))
    for i, v in enumerate(helm.data.vertices): v.co = v.co + v.co.normalized() * 1.7
    so = helm.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.6; so.offset = -1
    set_attr(helm, 'ink', [0.0] * len(hv))
    rmask = (u_ > 1.6 + 0.38 * f_) & (u_ < 2.9 + 0.38 * f_)
    rim = head_shell('rim', rmask, 0, 'helmrim')
    for v in rim.data.vertices: v.co = v.co + v.co.normalized() * 2.2
    so = rim.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.8; so.offset = -1
    set_attr(rim, 'ink', [0.0] * len(rim.data.vertices))
    bpy.ops.mesh.primitive_cube_add(size=1); nas = bpy.context.active_object
    hit = hb.ray_cast(Vector((0, -40, 1.5)), Vector((0, 1, 0)))
    nas.scale = (1.3, 0.6, 5.2); nas.location = (0, hit[0].y - 1.2, 2.2); nas.data.materials.append(MATS['helm'])
    set_attr(nas, 'ink', [0.0] * len(nas.data.vertices))

if WHO == 'aldric':
    # Stab quer auf der rechten Schulter, vorn von der Hand gehalten
    a = P(13, -40, 22); s_ = P(18.5 * g, -14.0, -4.0); b = s_ + (s_ - a) * 0.9
    d = b - a; L = d.length
    bpy.ops.mesh.primitive_cylinder_add(radius=1.5, depth=L + 30, vertices=16)
    stf = bpy.context.active_object; stf.location = (a + b) / 2 + d.normalized() * 10
    stf.rotation_euler = d.to_track_quat('Z', 'Y').to_euler(); stf.data.materials.append(MATS['wood'])
    set_attr(stf, 'ink', [0.0] * len(stf.data.vertices))
    # Faust um den Stab
    dn = d.normalized(); q = dn.to_track_quat('Z', 'Y').to_matrix().to_4x4()
    for i_ in range(4):
        bpy.ops.mesh.primitive_torus_add(major_radius=2.5, minor_radius=1.0 - 0.06 * i_, major_segments=24, minor_segments=10)
        fi = bpy.context.active_object; fi.matrix_world = Matrix.Translation(a + dn * (-2.6 + 1.95 * i_)) @ q
        fi.data.materials.append(MATS['skin']); set_attr(fi, 'ink', [0.0] * len(fi.data.vertices))
        for p_ in fi.data.polygons: p_.use_smooth = True
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=16, ring_count=8); fi = bpy.context.active_object
    fi.matrix_world = Matrix.Translation(a + dn * 3.6 + Vector((0, 1.6, 0.6))) @ q @ Matrix.Diagonal((1.1, 1.0, 2.6, 1))
    fi.data.materials.append(MATS['skin']); set_attr(fi, 'ink', [0.0] * len(fi.data.vertices))
    # Aermel bis zur Hand
    for o in [o for o in scn.objects if o.name.startswith('robe')]: pass

json.dump({k: CH[k] for k in SL + ['lider', 'bart', 'haar']}, open(OUT + '/%s-regler.json' % WHO, 'w'))
bpy.ops.wm.save_as_mainfile(filepath=OUT + '/%s.blend' % WHO)
print('KOPF OK', WHO, len(scn.objects))
