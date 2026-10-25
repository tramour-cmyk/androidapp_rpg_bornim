# Held (Kaempfer) aus Code: Koerper per Skin-Modifier, Kleidung per Raycast/Schale, Passes fuer Toon-Nachbearbeitung.
# Masse und Farben aus core/.../art/Doll.kt, Dress.kt, CharacterArt.kt, Appearance.kt (Mensch, Mann, mittel, 175 cm).
import bpy, bmesh, math, sys, os, json, time
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from mathutils.bvhtree import BVHTree

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
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
    'skin': hx(0xC98B6B), 'hair': hx(0x5E3C26),
    'tabard': worn(0xC03838, 0.2), 'sleeve': worn(0x802428, 0.45), 'pants': worn(0x484858, 0.3),
    'chain': hx(0x8A9098), 'darkLeather': hx(0x3E2C22), 'leather': hx(0x6A4A32), 'gold': hx(0xB8904A),
    'cloak': worn(0x5A4A3A, 0.3), 'metal': hx(0x868E98), 'shield': worn(0x6E2E24, 0.15), 'stripe': hx(0xC8BCA0),
    'wood': hx(0x6E4A2C), 'eye': hx(0x2A2018), 'lip': hx(0xA8644E),
}
# 348.6 Leute: FIGUR=<kennung> baut statt des Helden eine Figur aus leute.json (Abweichungen vom Helden; ohne FIGUR der Held wie bisher)
FIGUR = os.environ.get('FIGUR', 'held')
FG = dict(sex='m', statur='mittel', groesse=1.0, kind=False, kopf='helm', hemd='kette', rock='wappen', umhang='held', bart=False, lang=False,
          schuerze=None, reif=False, sonne=False, schwert=True, schild=True)
if FIGUR != 'held':
    FG.update(schwert=False, schild=False, umhang=None)
    FG.update(json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'leute.json')))[FIGUR])
    _h = lambda k: int(FG[k], 16)
    COL['skin'] = hx(_h('haut')); COL['hair'] = hx(_h('haar'))
    COL['lip'] = mix(_h('haut'), 0x8A3A34 if FG['sex'] == 'w' else 0x4A2620, 0.4)
    for k_ in ('tabard', 'sleeve', 'pants'): COL[k_] = worn(_h(k_), 0.15)
    if FG['umhang']: COL['cloak'] = worn(_h('umhang'), 0.15)
    COL['tuch'] = worn(_h('tuch') if FG.get('tuch') else _h('tabard'), 0.1)
    COL['apron'] = worn(_h('schuerze'), 0.1) if FG['schuerze'] else COL['tabard']
    # Runde 2 (Helfer: Jorin Gesicht orange, Brauen bei Blonden dunkelbraun): Roete, Augenhoehle, Lippe, Braue aus Haut und Haar wie Doll.face
    COL['rosy'] = mix(_h('haut'), 0xA8402E, 0.3); COL['sock'] = mix(_h('haut'), 0x2A1810, 0.5)
    COL['lipf'] = COL['lip']; COL['brow'] = mix(_h('haar'), 0x18120E, 0.35); COL['blush'] = mix(_h('haut'), 0x9A4434, 0.35)
else:
    COL['tuch'] = COL['tabard']; COL['apron'] = COL['tabard']
    COL['rosy'] = (196, 108, 88); COL['sock'] = (96, 58, 44); COL['lipf'] = (176, 112, 96); COL['brow'] = mix(0x5E3C26, 0x18120E, 0.35); COL['blush'] = hx(0xC87A62)
SKINHEX = (COL['skin'][0] << 16) | (COL['skin'][1] << 8) | COL['skin'][2]

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

WEAR = float(os.environ.get('WEAR', '0.7' if FIGUR == 'held' else str(FG.get('abnutzung', 0.2))))   # Leute (Runde 2): kein Schlamm bis zur Huefte
# grain je Material wie Dress.kt (Mat grain)
GRAIN = {'skin': 0.04, 'chain': 0.45, 'tabard': 0.08, 'sleeve': 0.08, 'pants': 0.08, 'boots': 0.16, 'belt': 0.16, 'cloak': 0.1,
         'wood': 0.14, 'cuff': 0.14, 'grip': 0.14, 'helm': 0.0, 'helmrim': 0.0, 'fit': 0.0, 'steel': 0.0, 'gold': 0.0, 'shield': 0.0, 'skinface': 0.02, 'lid': 0.02}
def _n(nt, t, **kw):
    n = nt.nodes.new(t)
    for a, b in kw.items(): setattr(n, a, b)
    return n
def _m(nt, op, a, b=None):
    n = nt.nodes.new('ShaderNodeMath'); n.operation = op
    for i, x in enumerate((a, b)):
        if x is None: continue
        if isinstance(x, (int, float)): n.inputs[i].default_value = x
        else: nt.links.new(x, n.inputs[i])
    return n.outputs[0]
def _mix(nt, f, a, b):
    n = nt.nodes.new('ShaderNodeMix'); n.data_type = 'RGBA'
    if isinstance(f, (int, float)): n.inputs['Factor'].default_value = f
    else: nt.links.new(f, n.inputs['Factor'])
    nt.links.new(a, n.inputs['A'])
    if isinstance(b, tuple): n.inputs['B'].default_value = b
    else: nt.links.new(b, n.inputs['B'])
    return n.outputs['Result']
def _scale(nt, col, f):
    v = nt.nodes.new('ShaderNodeVectorMath'); v.operation = 'SCALE'
    nt.links.new(col, v.inputs[0]); nt.links.new(f, v.inputs['Scale']) if not isinstance(f, (int, float)) else None
    if isinstance(f, (int, float)): v.inputs['Scale'].default_value = f
    return v.outputs[0]
def _noise(nt, scale, src='Object', detail=2.0):
    tc = nt.nodes.new('ShaderNodeTexCoord'); no = nt.nodes.new('ShaderNodeTexNoise')
    no.inputs['Scale'].default_value = scale; no.inputs['Detail'].default_value = detail
    if src == 'World':
        g = nt.nodes.new('ShaderNodeNewGeometry'); nt.links.new(g.outputs['Position'], no.inputs['Vector'])
    else: nt.links.new(tc.outputs['Object'], no.inputs['Vector'])
    return no.outputs['Fac']
def _sat(nt, x): return _m(nt, 'MINIMUM', _m(nt, 'MAXIMUM', x, 0.0), 1.0)
def finish(nt, col, name):
    g = GRAIN.get(name, 0.03)
    # Koernung (fein) und Farbschwankung je Flaeche (grob)
    if g > 0: col = _scale(nt, col, _m(nt, 'ADD', 1.0, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', _noise(nt, 0.55, detail=4.0), 0.5), 1.6 * g)))
    col = _scale(nt, col, _m(nt, 'ADD', 1.0, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', _noise(nt, 0.06, 'World'), 0.5), 0.35)))
    if name in ('tabard', 'cloak', 'sleeve', 'pants'):                      # 348.5: Gewebe (Faeden etwa 4 mm)
        tc = nt.nodes.new('ShaderNodeTexCoord'); wv = 1.0
        for ax_ in ('X', 'Z'):
            w = nt.nodes.new('ShaderNodeTexWave'); w.wave_type = 'BANDS'; w.bands_direction = ax_
            w.inputs['Scale'].default_value = 2.5; w.inputs['Distortion'].default_value = 0.6
            nt.links.new(tc.outputs['Object'], w.inputs['Vector'])
            wv = _m(nt, 'MULTIPLY', wv, _m(nt, 'ADD', 0.88, _m(nt, 'MULTIPLY', w.outputs['Fac'], 0.24)))
        col = _scale(nt, col, wv)
    if name in ('skin', 'skinface', 'face'):                                # 348.5: Haut lebendig (Roete, Poren)
        col = _mix(nt, _m(nt, 'MULTIPLY', _noise(nt, 0.35, detail=3.0), 0.35), col, lin(COL['blush']))
    if name == 'hair' and FIGUR != 'held':                                  # Runde 2: Straehnen vom Scheitel abwaerts (Doll tufts)
        tc = nt.nodes.new('ShaderNodeTexCoord'); sp = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sp.inputs[0])
        cb = nt.nodes.new('ShaderNodeCombineXYZ')
        nt.links.new(_m(nt, 'MULTIPLY', _m(nt, 'ARCTAN2', sp.outputs['X'], sp.outputs['Y']), 5.0), cb.inputs[0])
        nt.links.new(_m(nt, 'MULTIPLY', sp.outputs['Z'], 0.05), cb.inputs[1])
        no = nt.nodes.new('ShaderNodeTexNoise'); no.inputs['Scale'].default_value = 1.6; no.inputs['Detail'].default_value = 3.0
        nt.links.new(cb.outputs[0], no.inputs['Vector'])
        col = _scale(nt, col, _m(nt, 'ADD', 0.62, _m(nt, 'MULTIPLY', no.outputs['Fac'], 0.75)))
    W = WEAR
    if W <= 0: return col
    geo = nt.nodes.new('ShaderNodeNewGeometry')
    z = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(geo.outputs['Position'], z.inputs[0]); Z = z.outputs['Z']
    blot = _noise(nt, 0.09, 'World')
    if name in ('tabard', 'cloak', 'sleeve', 'pants'):
        col = _mix(nt, 0.22 * W, col, lin(hx(0x8A8076)))                      # ausgeblichen (348.5: lebendiger)
        st = _sat(nt, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', blot, 0.46), 5.0))
        col = _mix(nt, _m(nt, 'MULTIPLY', st, 0.95 * W), col, lin(hx(0x3A2E26)))  # Flecken
    if name == 'chain':
        rs = _sat(nt, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', _noise(nt, 0.11, 'World'), 0.48), 6.0))
        col = _mix(nt, _m(nt, 'MULTIPLY', rs, 0.85 * W), col, lin(hx(0x5E4A3C)))     # Rost (Dress.kt rusty)
        dk = _sat(nt, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', blot, 0.6), 7.0))
        col = _mix(nt, _m(nt, 'MULTIPLY', dk, 0.6 * W), col, lin(hx(0x3A3632)))
    if name in ('helm', 'helmrim', 'fit', 'steel', 'gold', 'belt', 'boots', 'cuff', 'shield', 'grip'):
        pt = geo.outputs['Pointiness']
        edge = _sat(nt, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', pt, 0.53), 14.0))
        col = _mix(nt, _m(nt, 'MULTIPLY', edge, 0.8 * W), col, _scale(nt, col, 1.7))  # Kantenabrieb
        cav = _sat(nt, _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', 0.48, pt), 14.0))
        col = _mix(nt, _m(nt, 'MULTIPLY', cav, 0.6 * W), col, lin(hx(0x2A2420)))
    if name == 'shield':
        tc = nt.nodes.new('ShaderNodeTexCoord'); vo = nt.nodes.new('ShaderNodeTexVoronoi'); vo.feature = 'DISTANCE_TO_EDGE'
        vo.inputs['Scale'].default_value = 0.09; nt.links.new(tc.outputs['Object'], vo.inputs['Vector'])
        sc = _m(nt, 'LESS_THAN', vo.outputs['Distance'], 0.025)
        col = _mix(nt, _m(nt, 'MULTIPLY', sc, 0.25 * W), col, lin(hx(0xA89880)))    # Kratzer
    # Runde 2 (Helfer: Rocksaum braun): bei den Leuten Schlamm nur an Stiefeln und Hose, nicht am Rock
    if name in (('boots', 'cuff', 'pants', 'cloak', 'tabard') if FIGUR == 'held' else ('boots', 'cuff', 'pants')):
        top = 20 + 55 * W
        mud = _sat(nt, _m(nt, 'ADD', _m(nt, 'DIVIDE', _m(nt, 'SUBTRACT', top, Z), 9.0), _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', blot, 0.5), 2.2)))
        col = _mix(nt, _m(nt, 'MULTIPLY', mud, 0.95), col, lin(hx(0x7A6448)))         # Schlamm
    return col
# ---------------------------------------------------------------- Materialien mit Modus-Weiche
MATS = {}
MODE_NODES = []

def make_mat(name, mid, color_fn, bump_fn=None, mid_fn=None, ink_attr=None):
    """color_fn(nt) -> Farb-Socket; bump_fn(nt) -> Hoehen-Socket; mid_fn(nt) -> Wert-Socket fuer die Material-ID."""
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree; nt.nodes.clear()
    out = nt.nodes.new('ShaderNodeOutputMaterial')
    col = finish(nt, color_fn(nt), name)
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
    e_ink = nt.nodes.new('ShaderNodeEmission'); e_ink.name = 'M_ink'
    if ink_attr:
        at = nt.nodes.new('ShaderNodeAttribute'); at.attribute_name = ink_attr; nt.links.new(at.outputs['Fac'], e_ink.inputs['Strength'])
    else: e_ink.inputs['Strength'].default_value = 0.0
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
flat('hair', 23, 'hair'); flat('tuch', 24, 'tuch'); flat('apron', 25, 'apron')   # 348.6 Leute

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
def skinface(nt):
    c = rgb_node(nt, COL['skin'])
    tc = nt.nodes.new('ShaderNodeTexCoord'); sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    X, Y, Z = sep.outputs['X'], sep.outputs['Y'], sep.outputs['Z']
    ax = math_node(nt, 'ABSOLUTE', X)
    def soft(cx, cz, rx, rz):
        a = math_node(nt, 'DIVIDE', math_node(nt, 'SUBTRACT', ax, cx), rx); b = math_node(nt, 'DIVIDE', math_node(nt, 'SUBTRACT', Z, cz), rz)
        s_ = math_node(nt, 'ADD', math_node(nt, 'MULTIPLY', a, a), math_node(nt, 'MULTIPLY', b, b))
        return math_node(nt, 'MAXIMUM', math_node(nt, 'SUBTRACT', 1.0, s_), 0.0)
    front = math_node(nt, 'LESS_THAN', Y, -3.0)
    rosy = math_node(nt, 'MULTIPLY', math_node(nt, 'ADD', soft(3.4, -1.8, 2.4, 2.0), soft(0.0, -0.5, 1.1, 1.8)), front)
    c = mixc(nt, math_node(nt, 'MINIMUM', math_node(nt, 'MULTIPLY', rosy, 0.45), 0.45), c, rgb_node(nt, COL['rosy']))
    # 348.6 (Befund 5, Gesicht flach): Schatten der Augenhoehle unter der Braue wie Doll.face („the socket's shadow“)
    sock = math_node(nt, 'MULTIPLY', soft(3.2, 1.4, 2.0, 1.1), front)
    c = mixc(nt, math_node(nt, 'MINIMUM', math_node(nt, 'MULTIPLY', sock, 0.6), 0.4), c, rgb_node(nt, COL['sock']))
    a1 = nt.nodes.new('ShaderNodeAttribute'); a1.attribute_name = 'lip'
    a2 = nt.nodes.new('ShaderNodeAttribute'); a2.attribute_name = 'brow'
    c = mixc(nt, a1.outputs['Fac'], c, rgb_node(nt, COL['lipf']))
    # 348.6 (Befund 5, Braue ohne Kontrast): wie Doll.face browC = mix(Haar, 0x18120E, 0,35)
    return mixc(nt, a2.outputs['Fac'], c, rgb_node(nt, COL['brow']))
make_mat('skinface', 1, skinface, ink_attr='ink')
make_mat('lid', 1, lambda nt: rgb_node(nt, COL['skin'], 0.95), ink_attr='ink')
# Oberlid schwer und dunkel wie Doll (Schatten der Augenhoehle, „heavy upper lid“), sonst liest sich das Auge als Fleck ohne Lid
make_mat('lidup', 1, lambda nt: rgb_node(nt, mix(SKINHEX, 0x1A100C, 0.6)), ink_attr='ink')
def eye_col(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord'); sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    X, Y, Zs = sep.outputs['X'], sep.outputs['Y'], sep.outputs['Z']
    rr = math_node(nt, 'SQRT', math_node(nt, 'ADD', math_node(nt, 'MULTIPLY', X, X), math_node(nt, 'MULTIPLY', Zs, Zs)))
    fr = math_node(nt, 'LESS_THAN', Y, 0.0)
    # Runde 2b: Iris 0,52 bei R 1,5 ging in 3 Bildpunkten unter (Helfer: Weiss ohne Pupille wirkt blind); wie Doll dunkel innen
    # Runde 7: in der Nahstufe ist das offene Auge 3 x 2 Bildpunkte, die Iris (0,8) traf einen davon; Mipmaps hellten ihn auf Grau 146-189;
    # wie Doll (ein dunkler Punkt, Weiss nur aussen) Iris 0,92 fast so dunkel wie die Pupille (0,5), Weiss bleibt aussen;
    # Helfer: 1,05 braungrau verwaschen, fast ohne Weiss (Knopfaugen)
    iris = math_node(nt, 'MULTIPLY', math_node(nt, 'LESS_THAN', rr, 0.92), fr); pup = math_node(nt, 'MULTIPLY', math_node(nt, 'LESS_THAN', rr, 0.5), fr)
    c = mixc(nt, iris, rgb_node(nt, (232, 226, 214)), rgb_node(nt, (36, 26, 18)))
    return mixc(nt, pup, c, rgb_node(nt, (14, 10, 8)))
make_mat('eye', 30, eye_col)

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
    j('sh' + s, sg * 19.0, 141.0, -1.0, (6.4, 6.4))
# rechter Arm (Waffe): Hand vorn auf Hueftehoehe
j('upR', 22.5, 127.5, -1.5, (5.3, 5.3)); j('elR', 25.0, 114.0, -1.5, (4.1, 4.1))
j('foR', 25.5, 103.0, 0.5, (4.3, 4.3)); j('wrR', 25.0, 91.0, 2.0, (2.9, 2.9))
# linker Arm (Schild)
j('upL', -22.5, 127.5, -1.5, (5.3, 5.3)); j('elL', -25.0, 114.0, -1.5, (4.1, 4.1))
j('foL', -25.5, 103.0, 0.5, (4.3, 4.3)); j('wrL', -25.0, 91.0, 2.0, (2.9, 2.9))
# Beine: rechter Fuss vorn
PH = math.radians(float(os.environ.get('PHASE', '-1')))
WALK = os.environ.get('PHASE') is not None
for s, sg, ff in ((('R', 1, 24 * math.cos(PH)), ('L', -1, -24 * math.cos(PH))) if WALK else (('R', 1, 2.0), ('L', -1, -2.0))):
    j('hip' + s, sg * 8.8, 85.0, 0.0, (9.2, 9.2))
    j('thigh' + s, sg * 9.4, 68.0, ff * 0.35 + 1.0, (7.9, 7.9))
    j('knee' + s, sg * 9.8, 50.5, ff * 0.6 + 1.5, (5.1, 5.1))
    j('calf' + s, sg * 10.0, 37.0, ff * 0.8 + 0.2, (6.1, 6.1))
    j('ankle' + s, sg * 10.3, 9.0, ff, (3.5, 3.5))
    j('heel' + s, sg * 10.3, 3.6, ff - 3.5, (3.6, 3.6))
    j('ball' + s, sg * 10.8, 3.0, ff + 13.0, (4.0, 4.0))
    j('toe' + s, sg * 11.0, 2.6, ff + 18.0, (3.0, 3.0))
if WALK:
    for s_, sg_ in (('R', 1), ('L', -1)):
        lift = max(0.0, math.sin(PH) * sg_) * 16.0
        for k_ in ('ankle', 'heel', 'ball', 'toe'):
            p_, r_ = J[k_ + s_]; J[k_ + s_] = (p_ + Vector((0, 0, lift)), r_)
        p_, r_ = J['knee' + s_]; J['knee' + s_] = (p_ + Vector((0, -lift * 0.9, lift * 0.35)), r_)
        p_, r_ = J['calf' + s_]; J['calf' + s_] = (p_ + Vector((0, -lift * 0.2, lift * 0.6)), r_)
        p_, r_ = J['knee' + s_]; J['knee' + s_] = (p_ + Vector((0, -4.0, -1.0)), r_)
        sw = -sg_ * math.cos(PH)
        for k_, a_ in (('el', 4.0), ('fo', 14.0), ('wr', 26.0)):
            p_, r_ = J[k_ + s_]; J[k_ + s_] = (p_ + Vector((0, -a_ * sw, abs(sw) * a_ * 0.25)), r_)
for _k in list(J):
    _p, _r = J[_k]
    if not _k.startswith(('neck', 'heel', 'ball', 'toe', 'ankle')): _f = 1.3 if _k in ('pelvis', 'waist', 'belly', 'chest', 'chestTop') else (1.22 if _k[:2] in ('sh', 'up', 'el', 'fo') else 1.15); J[_k] = (_p, (_r[0] * _f, _r[1] * _f))
E = [('pelvis', 'waist'), ('waist', 'belly'), ('belly', 'chest'), ('chest', 'chestTop'), ('chestTop', 'neck'), ('neck', 'neckTop'),
     ('chestTop', 'shR'), ('chestTop', 'shL')]
for s in 'RL':
    E += [('sh' + s, 'up' + s), ('up' + s, 'el' + s), ('el' + s, 'fo' + s), ('fo' + s, 'wr' + s),
          ('pelvis', 'hip' + s), ('hip' + s, 'thigh' + s), ('thigh' + s, 'knee' + s), ('knee' + s, 'calf' + s),
          ('calf' + s, 'ankle' + s), ('ankle' + s, 'heel' + s), ('ankle' + s, 'ball' + s), ('ball' + s, 'toe' + s)]
# 348.6 Leute: Statur (Doll Build) und Frau (schmalere Schultern und Taille, breitere Huefte)
BW = {'mittel': 1.0, 'kraeftig': 1.2, 'schlank': 0.84, 'zwerg': 1.5}[FG['statur']]   # Runde 2: 1,1/0,9 sah man nicht; Zwerg wie Doll girth 1,5
FEM = FG['sex'] == 'w'
for _k in list(J):
    _p, _r = J[_k]; _x = 1.0; _f = 1.0
    if _k in ('pelvis', 'waist', 'belly', 'chest', 'chestTop'):
        _f = BW * ({'pelvis': 1.08, 'waist': 0.86, 'belly': 0.9, 'chest': 0.92, 'chestTop': 0.88}[_k] if FEM else 1.0)
    elif _k[:2] in ('sh', 'up', 'el', 'fo', 'wr'):
        _f = BW ** 0.8 * (0.85 if FEM else 1.0); _x = BW ** 0.7 * (0.82 if FEM else 1.0)
    elif _k.startswith(('hip', 'thigh')):
        _f = BW ** 0.8 * (1.08 if FEM else 1.0); _x = BW ** 0.6 * (1.05 if FEM else 1.0)
    elif _k.startswith(('knee', 'calf')):
        _f = BW ** 0.7; _x = BW ** 0.5
    elif _k.startswith('neck'):
        _f = BW ** 0.6 * (0.9 if FEM else 1.0)
    if FG['statur'] == 'zwerg' and _k[:2] in ('sh', 'up', 'el', 'fo', 'wr'): _x *= 1.12   # Doll shoulderK 1,55: breite Schultern
    _y = 0.0
    if _k in ('waist', 'belly', 'chest') and FG.get('bauch'):   # Leute Runde 2 (Helfer: Statur kaum sichtbar): Bauch nach vorn
        _b = FG['bauch'] * {'waist': 0.8, 'belly': 1.0, 'chest': 0.4}[_k]; _f *= 1 + _b; _y = -_b * 40.0
    J[_k] = (Vector((_p.x * _x, _p.y + _y, _p.z)), (_r[0] * _f, _r[1] * _f))
# Runde 2 (Helfer: Arme leicht abgespreizt, Haende im Rock): Haende haengen knapp neben Huefte und Rock, nicht weiter
if FIGUR != 'held':
    _ho = max(abs(J['hipR'][0].x) + J['hipR'][1][0], J['pelvis'][1][0]) + (2.6 if FG['rock'] == 'robe' else 1.0) + 3.4
    for s_, sg_ in (('R', 1), ('L', -1)):
        for _k, _need in (('up', None), ('el', _ho - 1.6), ('fo', _ho - 0.8), ('wr', _ho)):
            _p, _r = J[_k + s_]; _ax = abs(_p.x) * 0.93
            if _need is not None: _ax = max(_ax, _need)
            J[_k + s_] = (Vector((-sg_ * _ax, _p.y, _p.z)), _r)

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
# Runde 3 (1): an Saum und Achsel lagen Fugen zwischen den Schalen, dort schien Haut durch: unter der Kleidung dunkles Tuch
body.data.materials.append(MATS['pants'])
for p in body.data.polygons:
    p.use_smooth = True
    if p.center.z < 146: p.material_index = 1

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
chain = shell('chain', chain_mask, 1.0 + (1.0 if FG['kind'] else 0.0), 'chain' if FG['hemd'] == 'kette' else 'tabard', 0.5)   # Leute: Kittel aus Tuch
sleeve = shell('sleeves', arms & (Z > 0) & ~seg_is(BLAB, 'xx'), 1.4 if FG['kind'] else 0.55, 'sleeve', 0.3)   # Pim: Kittel zu gross
# Aermel enden am Handgelenk
pants = shell('pants', legs & (Z < HEM + 6) & (Z > 22), 0.5, 'pants', 0.3)
# Stiefel: Fuss und Unterschenkel bis gut ein Drittel, Stulpe oben
boot_top = ankleY + (kneeY - ankleY) * 0.35   # Runde 4: wie Dress.legs (Schuhe 0,35); bei 0,42 las sich der Unterschenkel stiefelfarben
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
SL = ['nase_laenge', 'nase_breite', 'nase_kruemmung', 'kinn', 'wangen', 'augenabstand', 'brauen', 'falten', 'wangenknochen']
_bm = bmesh.new(); bmesh.ops.create_icosphere(_bm, subdivisions=6, radius=1.0)
U = np.array([tuple(v.co) for v in _bm.verts])
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
    sock = -0.55 * G(((ar - ex) / 1.45) ** 2 + ((pu - 0.9) / 1.15) ** 2)
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
HP = dict(nase_laenge=0.1, nase_breite=0.4, nase_kruemmung=0.2, kinn=0.7, wangen=0.2, augenabstand=0.1, brauen=0.6, falten=0.25, wangenknochen=0.4)
if FG.get('alt'): HP.update(falten=1.0, wangen=-0.6, wangenknochen=0.8, nase_laenge=0.5)   # Leute: Aldric, Morwen
if FG['sex'] == 'w': HP.update(kinn=0.1, brauen=0.1, nase_breite=0.0, wangenknochen=0.6)
HP.update(FG.get('gesicht', {}))   # Runde 2 (Helfer: Gesichter gleich): je Figur eigene Zuege aus leute.json
HV_, INK_, LIP_, BROW_, EX_ = face(HP)
KF = FG.get('kopfform', [1.0, 1.0, 1.0])   # Breite, Tiefe, Hoehe
HV_ = HV_ * 1.1 * np.array(KF)
for i, v in enumerate(_bm.verts): v.co = Vector(HV_[i])
hme = bpy.data.meshes.new('head'); _bm.to_mesh(hme); _bm.free()
for nm_, vals_ in (('ink', np.clip(INK_ * 1.4, 0, 1)), ('lip', np.clip(LIP_, 0, 1)), ('brow', (BROW_ > 0.5) * 1.0)):
    a_ = hme.attributes.new(nm_, 'FLOAT', 'POINT'); a_.data.foreach_set('value', list(map(float, vals_)))
head = bpy.data.objects.new('head', hme); link(head)
head.location = P(0, headCy, 0.8)
head.data.materials.append(MATS['skinface'])
_hb = BVHTree.FromPolygons([tuple(v.co) for v in hme.vertices], [tuple(p.vertices) for p in hme.polygons])
for sg in (1, -1):
    x = -sg * EX_ * 1.1 * KF[0]
    hit = _hb.ray_cast(Vector((x, -40, 1.0)), Vector((0, 1, 0)))
    # 348.6 (Runde 2b: in der Nahstufe kein Auge zu sehen, nur Haut unter dem Helmrand): von 30 Grad oben verdeckten Braue und
    # Oberlid das tief liegende Auge ganz; wie Doll (Augenweiss nach aussen, dunkle Pupille) groesser, weiter vorn, Lid offener
    R = 1.5; c = Vector((x, (hit[0].y if hit[0] else -9) + R - 0.9, 0.9))
    b2 = bmesh.new(); bmesh.ops.create_uvsphere(b2, u_segments=16, v_segments=10, radius=R)   # Runde 5 (1): bleibt beim Abbau ganz (rig.py), darum grob
    m2 = bpy.data.meshes.new('eye'); b2.to_mesh(m2); b2.free()
    eo = bpy.data.objects.new('eye', m2); link(eo); eo.location = head.location + c; eo.data.materials.append(MATS['eye'])
    eo.rotation_euler = (0, 0, math.radians(-sg * 10))  # Runde 4 (1): Kopf verdeckt die Innenseite des Augapfels, Pupille sass am inneren Rand (schielte); +12 drehte sie noch weiter zur Nase; -10 setzt sie in die Mitte des sichtbaren Weiss (nachgemessen)
    for p in m2.polygons: p.use_smooth = True
    for keep, lmat in ((lambda el: el > 32, 'lidup'), (lambda el: el < -34, 'lid')):
        b3 = bmesh.new(); bmesh.ops.create_uvsphere(b3, u_segments=40, v_segments=24, radius=R + 0.16)
        kill = [f_ for f_ in b3.faces if any((not keep(math.degrees(math.asin(max(-1, min(1, v.co.normalized().z)))))) or v.co.normalized().y > 0.55 for v in f_.verts)]
        bmesh.ops.delete(b3, geom=kill, context='FACES')
        m3 = bpy.data.meshes.new('lid'); b3.to_mesh(m3); b3.free()
        lo = bpy.data.objects.new('lid', m3); link(lo); lo.location = head.location + c; lo.data.materials.append(MATS[lmat])
        so = lo.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.3; so.offset = 1
        a_ = m3.attributes.new('ink', 'FLOAT', 'POINT'); a_.data.foreach_set('value', [0.0] * len(m3.vertices))
        for p in m3.polygons: p.use_smooth = True
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
edge_u = lambda co: 2.2 + 0.38 * (-co.y)  # Helmkante: vorn hoeher, hinten tiefer
if FG['kopf'] == 'helm':
    head_part('helm', lambda co: co.z > edge_u(co) - 0.2, 1.3, 'helm', 0.6)
    head_part('helmrim', lambda co: edge_u(co) - 0.2 < co.z < edge_u(co) + 1.5, 1.9, 'helmrim', 0.7)
    bpy.ops.mesh.primitive_cube_add(size=1)
    nas = bpy.context.active_object; nas.name = 'nasal'; nas.parent = root
    # Runde 3 (1): las sich als Strich durchs Gesicht; wie Dress.kt (halb 0,035 k breit, 0,12 k lang) schmaler, kuerzer, dunkler wie der Rand
    nas.scale = (1.0, 0.6, 4.6); nas.location = head.location + P(0, 2.2, 11.85)
    nas.rotation_euler = (math.radians(-6), 0, 0)
    bv = nas.modifiers.new('bv', 'BEVEL'); bv.width = 0.3; bv.segments = 2
    nas.data.materials.append(MATS['helmrim'])
# 348.6 Leute: Haar, Kopftuch, Kapuze, Bart (Kopf: x = -rechts, y = -vorn, z = hoch; Augen bei z 1, Stirn bis z 5,5)
_cl = lambda a: max(0.0, min(1.0, a))
_fr = lambda co: _cl(-co.y / 8.0); _bk = lambda co: _cl(co.y / 8.0)
from mathutils import noise as _noise3
def hair_volume(o, crown, lumps, locks, seed=0.0):
    """Runde 2 (Helfer: Haar als Kappe ohne Volumen): Haar vom Kopf weg aufbauschen (oben mehr), Bueschel und Straehnen vom Scheitel."""
    for v in o.data.vertices:
        p = v.co; d = p.normalized()
        up = _cl((p.z + 3.0) / 11.0)
        ang = math.atan2(p.x, p.y)
        n = _noise3.noise(p * 0.32 + Vector((seed, 0, 0)))
        lk = math.sin(ang * 9 + 2.0 * _noise3.noise(p * 0.2 + Vector((0, seed, 0)))) * _cl((7.0 - p.z) / 6.0)
        v.co = p + d * (crown * up + lumps * n + locks * lk)
SEED = sum(map(ord, FIGUR)) * 0.37
FRISUR = FG.get('frisur', 'lang' if FG['lang'] else 'kurz')
VOL = {'kurz': (0.7, 0.35, 0.25), 'lang': (1.3, 0.45, 0.4), 'wirr': (1.5, 1.1, 0.5), 'zwerg': (1.0, 0.6, 0.45)}[FRISUR]
if FG['kopf'] == 'haar':
    hr = head_part('hair', lambda co: co.z > 1.0 + 4.6 * _fr(co) - 7.5 * _bk(co) - (2.5 if FG['lang'] else 0.0) * _bk(co), 1.0, 'hair', 2.2)   # Runde 2: las sich als Badekappe
    hair_volume(hr, *VOL, seed=SEED)
elif FG['kopf'] == 'tuch':
    # Runde 2 (Helfer: Liskas Tuch liest sich als Kappe): Haaransatz vorn sichtbar, Tuch gefaltet, Zipfel und Knoten im Nacken
    hr = head_part('hair', lambda co: co.y < -1.0 and abs(co.x) < 7.6 and 1.0 + 4.6 * _fr(co) < co.z < 8.0, 0.9, 'hair', 1.4)
    hair_volume(hr, 0.3, 0.3, 0.25, seed=SEED)
    tu = head_part('tuch', lambda co: co.z > 3.0 + 4.6 * _fr(co) - 7.0 * _bk(co), 2.3, 'tuch', 0.7)
    hair_volume(tu, 0.5, 0.35, 0.0, seed=SEED + 3)
    _hb_ = BVHTree.FromPolygons([tuple(v.co) for v in tu.data.vertices], [tuple(p_.vertices) for p_ in tu.data.polygons])
    nk = _hb_.ray_cast(Vector((0, 40, -3.5)), Vector((0, -1, 0)))
    nk = nk[0] if nk[0] else Vector((0, 9, -3.5))
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=16, ring_count=8)
    kn = bpy.context.active_object; kn.name = 'tuch_knoten'; kn.parent = root
    kn.location = head.location + nk + Vector((0, 1.0, 0)); kn.scale = (2.4, 1.6, 1.7); kn.data.materials.append(MATS['tuch'])
    pts_ = []                                                     # Zipfel: Dreieck vom Knoten ueber den Nacken
    for i in range(6):
        t_ = i / 5; w_ = 4.5 * (1 - t_) + 0.4
        for xs_ in (-w_, 0.0, w_):
            pts_.append(head.location + nk + Vector((xs_, 1.2 + 0.6 * t_ - 0.4 * abs(xs_) / 4.5, -1.0 - 8.5 * t_)))
    me_ = bpy.data.meshes.new('tuch_zipfel'); me_.from_pydata([tuple(q) for q in pts_], [], [(3 * i + k, 3 * i + k + 1, 3 * i + k + 4, 3 * i + k + 3) for i in range(5) for k in range(2)])
    zp = bpy.data.objects.new('tuch_zipfel', me_); link(zp); zp.data.materials.append(MATS['tuch'])
    so = zp.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.5; so.offset = 0; apply_mods(zp)
    for p_ in zp.data.polygons: p_.use_smooth = True
elif FG['kopf'] == 'kapuze':
    head_part('hood', lambda co: not (co.y < -3.0 and abs(co.x) < 6.4 and co.z < 5.2), 1.9, 'cloak', 0.9)
    if FG.get('haar_unter'):   # Morwen: graues Haar unter dem Kapuzenrand
        head_part('hair', lambda co: co.y < -2.0 and abs(co.x) < 6.6 and 2.6 < co.z < 5.8, 0.8, 'hair', 1.2)
if FG['bart']:
    bd = head_part('beard', lambda co: co.y < 3.0 and co.z < (0.5 if abs(co.x) > 6.0 else -2.2)
              and not (abs(co.x) < 2.4 and -6.2 < co.z < -4.5 and co.y < -5.0), 1.0, 'hair', 2.6)
    for v in bd.data.vertices:   # Runde 2: Bart nur ein Fleck; nach unten laenger (Aldric bis auf die Brust)
        if v.co.z < -6: v.co.z -= (-6 - v.co.z) * (2.2 if FG.get('bartlang') else (1.6 if FG['statur'] == 'zwerg' else 0.8)); v.co.y -= 0.6
    hair_volume(bd, 0.0, 0.5, 0.3, seed=SEED + 7)

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
ARMSEG = [k for k, nm in enumerate(SEGNAME) if any(key in nm for key in ('shR-', 'shL-', 'upR', 'upL', 'elR', 'elL', 'foR', 'foL'))]
def bvh_core(objs):
    """Wie bvh, aber ohne Arme (348.6 Leute, Runde 3: Rock und Guertel reichten bis an die Unterarme, gespannte Streifen)."""
    bpy.context.view_layer.update()
    V, F = world_arrays(objs)
    arm_ = np.isin(label_verts(V), ARMSEG)
    F = [f for f in F if not all(arm_[i] for i in f)]
    return BVHTree.FromPolygons([tuple(v) for v in V], F)

def grid_obj(name, G, mat, thick, closed_u=False, even=True):
    nr, nc = G.shape[0], G.shape[1]
    verts = G.reshape(-1, 3); faces = []
    for i in range(nr - 1):
        for k in range(nc - 1):
            a = i * nc + k; faces.append((a, a + 1, a + nc + 1, a + nc))
    o = mesh_obj(name, verts, faces, MATS[mat])
    if thick:
        so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick; so.offset = 0; so.use_even_offset = even
        apply_mods(o)
    return o

# ---------------------------------------------------------------- Wappenrock: Bahn vorn und hinten, haengt ab dem Guertel
trunk_bvh = bvh([body, chain])
half = shoulderX * 0.34
top_t = shoulderY - 0.02 * H; bot_t = kneeY + 0.06 * H
def tabard(side, mat='tabard', top=None, bot=None, hw=None):
    hw = hw or half
    zs = np.linspace(top or top_t, bot or bot_t, 70); xs = np.linspace(-hw, hw, 15)
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
                y += -side * 0.35 * math.cos(x / hw * 1.0 * math.pi) * min(1, (beltY - z) / 20)
            prev = y if z >= beltY - 1 else prev
            G[i, k] = (x, y, z)
    return grid_obj('tabard', G, mat, 0.45)
# 348.6 Leute: langer Rock (Kleid, Robe) vom Guertel bis ueber die Knoechel, nach unten weiter (A-Linie)
def skirt(top=None, bot=None, flare=0.06, name='robe', mat='tabard', span=None, objs=None, off=1.0):
    """Runde 2: auch kurzer Kittel (Pim) und Schuerze vorn (span = halber Winkel um die Front, Grad)."""
    nz, n = 50, 72
    zs = np.linspace(top or beltY + 3, bot or ankleY + 3.5, nz)
    sk_bvh = bvh_core(objs or [body, chain, pants])
    if span is None: AS = [2 * math.pi * k / n for k in range(n + 1)]
    else: AS = [math.pi + math.radians(span) * (-1 + 2 * k / n) for k in range(n + 1)]
    R = np.zeros((nz, n + 1)); prev = [None] * (n + 1)
    for i, z in enumerate(zs):
        c = Vector((0, 0.5, z))
        for k, a in enumerate(AS):
            d = Vector((math.sin(a), math.cos(a), 0))
            hit = sk_bvh.ray_cast(c + d * 70, -d)
            r = ((hit[0] - c).length if hit[0] else (prev[k] or 16)) + off
            if prev[k] is not None: r = max(r, prev[k])
            if z < hipY: r += flare * (zs[i - 1] - z) if i else 0.0
            prev[k] = r; R[i, k] = r
    R = np.maximum(R, R[:, ::-1])   # Runde 2 (Helfer: Saum links schief): links und rechts gleich weit
    G = np.zeros((nz, n + 1, 3))
    for i, z in enumerate(zs):
        c = Vector((0, 0.5, z))
        for k, a in enumerate(AS):
            d = Vector((math.sin(a), math.cos(a), 0))
            fold = 0.5 * min(1, max(0, (hipY - z) / 40)) * math.sin(a * 9)
            G[i, k] = tuple(c + d * (R[i, k] + fold))
    return grid_obj(name, G, mat, 0.5)
robe = skirt() if FG['rock'] == 'robe' else None
if FG['rock'] == 'kittel':   # Pim: Kittel zu gross, bis ueber die Knie, weit
    robe = skirt(beltY + 3, kneeY + 5, 0.16, off=2.2)
tabF = tabB = None
if FG['rock'] == 'wappen':
    tabF = tabard(1); tabB = tabard(-1)
apron = None
if FG['schuerze']:
    # Runde 2 (Helfer: Rowenas Schuerze starr, Achselloecher): Schuerze ab dem Guertel, liegt auf Rock und Beinen, Falten
    apron = skirt(beltY + 1, kneeY - (2 if FG['statur'] == 'zwerg' else 6), 0.08, 'apron', 'apron', span=70,
                  objs=[o for o in (body, chain, pants, robe) if o], off=1.1)
    if FG.get('latz'):   # Borin: Schmiedeschuerze mit Latz
        trunk_bvh = bvh([body, chain]); tabF = tabard(1, 'apron', shoulderY - 9, beltY - 1, shoulderX * 0.42)

# ---------------------------------------------------------------- Guertel
belt_bvh = (bvh if FIGUR == 'held' else bvh_core)([o for o in (body, chain, tabF, tabB, robe, apron) if o])
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
buckle.data.materials.append(MATS['gold' if FIGUR == 'held' else 'fit'])

# ---------------------------------------------------------------- Umhang: haengt von den Schultern, faellt frei ab dem Gesaess
hem = (ankleY + 8) if FG.get('umhang_lang') else kneeY - 0.05 * H
cloak_bvh = bvh([o for o in (body, chain, tabB, belt, sleeve, robe) if o])
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
            r = (hit[0] - c).length + (2.2 if z > 132 else 1.3) if hit[0] else (prev or 18)   # Runde 3 (1): Kettenhemd stach an den Schultern durch
            if prev is not None and z < 140: r = max(r, prev)
            if z < seatZ: r += 0.10 * (seatZ - z) / nz * 3
            prev = r
            fold = 0.9 * min(1, max(0, (140 - z) / 50)) * math.sin(tt * 7.5 * math.pi)
            G[i, k] = tuple(c + d * (r + fold))
    return grid_obj('cloak', G, 'cloak', 0.6)
cl = cloak() if FG['umhang'] else None
if cl:
    sm = cl.modifiers.new('sm', 'SMOOTH'); sm.iterations = 4; sm.factor = 0.5; apply_mods(cl)
    for p in cl.data.polygons: p.use_smooth = True
def fuse(objs, name, voxel=0.3):
    """Teile zu einer geschlossenen Flaeche verschmelzen (Voxel), dann glaetten: keine Naehte zwischen Fingergliedern."""
    for o in objs: apply_mods(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs: o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    bpy.ops.object.join()
    o = bpy.context.active_object; o.name = name
    rm = o.modifiers.new('rm', 'REMESH'); rm.mode = 'VOXEL'; rm.voxel_size = voxel
    sm = o.modifiers.new('sm', 'SMOOTH'); sm.iterations = 6; sm.factor = 0.5
    apply_mods(o)
    for p in o.data.polygons: p.use_smooth = True
    return o
# 348.6 Leute: langes Haar faellt hinter dem Kopf bis unter die Schultern
# Runde 2 (Helfer: Haarlappen im Nacken): beginnt am Hinterkopf auf dem Haar, folgt dem Nacken nach innen, Spitzen ungleich lang
if FG['kopf'] == 'haar' and FG['lang']:
    ZOPF = FG.get('zopf')
    hair_bvh = bvh([o for o in (body, chain, cl, head, bpy.data.objects.get('hair')) if o])
    nz, nt_ = 34, 41; wid = 50 if ZOPF else 72
    G = np.zeros((nz, nt_, 3))
    for k in range(nt_):
        tt = -1 + 2 * k / (nt_ - 1); th = math.radians(tt * wid); d = Vector((math.sin(th), math.cos(th), 0)); prev = None
        bot = (headCy - 13.0 if ZOPF else shoulderY - 3.0 - 2.5 * (1 - abs(tt))) + 1.6 * math.sin(k * 2.3 + SEED)
        bot += 7.0 * abs(tt) ** 2   # an den Seiten kuerzer, faellt hinter die Schultern
        zs = np.linspace(headCy + 2.0, bot, nz)
        for i, z in enumerate(zs):
            c = Vector((0, -1.0, z))
            hit = hair_bvh.ray_cast(c + d * 60, -d)
            r = ((hit[0] - c).length if hit[0] else (prev or 10)) + 0.5
            if prev is not None: r = max(r, prev - 0.45)
            prev = r
            G[i, k] = tuple(c + d * (r + 0.35 * math.sin(tt * 13 * math.pi)))
    hb_ = grid_obj('hairback', G, 'hair', 1.2, even=False)   # gerade Dicke: bei schraegen Spalten schoss sie bis 3 m hoch
    sm = hb_.modifiers.new('sm', 'SMOOTH'); sm.iterations = 3; sm.factor = 0.5; apply_mods(hb_)
    for p in hb_.data.polygons: p.use_smooth = True
    if ZOPF:   # Zopf aus Gliedern statt eines schmalen Lappens, Band am Ende
        zb = bvh([o for o in (body, chain, cl, hb_) if o]); before = set(bpy.data.objects); nb_ = 9
        z0, z1 = headCy - 9.0, shoulderY - 20.0
        for i in range(nb_):
            t_ = i / (nb_ - 1); z = z0 + (z1 - z0) * t_
            hh = zb.ray_cast(Vector((0, 60, z)), Vector((0, -1, 0)))
            y = (hh[0].y if hh[0] else 10.0); rr = 2.5 - 0.9 * t_
            ctr = Vector((0.9 * (1 if i % 2 else -1), y + rr * 0.7, z))
            bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=14, ring_count=8)
            e = bpy.context.active_object; e.location = ctr; e.scale = (rr, rr * 0.8, rr * 1.35); e.rotation_euler = (0, (1 if i % 2 else -1) * 0.5, 0)
            e.data.materials.append(MATS['hair'])
        fuse([o for o in bpy.data.objects if o not in before], 'hairbraid', voxel=0.25)
        bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=1.4, vertices=12)
        e = bpy.context.active_object; e.name = 'hairtie'; e.parent = root
        hh = zb.ray_cast(Vector((0, 60, z1 - 2.4)), Vector((0, -1, 0)))
        e.location = Vector((0, (hh[0].y if hh[0] else 10.0) + 1.4, z1 - 2.4)); e.data.materials.append(MATS['cuff'])
# Lyras Reif (Runde 2: sass bei 0,0,0, die Lage stand im Kommentar): Band um Haar und Kopf, vorn tiefer
if FG['reif']:
    rb_ = bvh([o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith(('head', 'hair'))])
    nr_ = 72; Gr = np.zeros((3, nr_ + 1, 3)); c0 = head.location + Vector((0, 0, 4.0))
    for k in range(nr_ + 1):
        a = 2 * math.pi * k / nr_; d = Vector((math.sin(a), math.cos(a), 0)); dz = 1.4 * math.cos(a)
        for i, h_ in enumerate((-0.45, 0.0, 0.45)):
            c = c0 + Vector((0, 0, dz + h_)); hit = rb_.ray_cast(c + d * 40, -d)
            Gr[i, k] = tuple((hit[0] if hit[0] else c + d * 9) + d * 0.35)
    grid_obj('circlet', Gr, 'gold', 0.35)
# Spangen an den Schultern (Gold)
for sg in ((1, -1) if cl else ()):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=20, ring_count=10)
    e = bpy.context.active_object; e.name = 'clasp'; e.parent = root
    hc = cloak_bvh.ray_cast(P(sg * shoulderX * 0.62, shoulderY + 1, 40), P(0, 0, -1) - P(0, 0, 0))
    e.location = (hc[0] if hc[0] else P(sg * 11, shoulderY, 8)) + P(0, 0, 1.2)
    e.scale = (2.1, 1.2, 2.1); e.data.materials.append(MATS['gold' if FIGUR == 'held' else 'cuff'])
    for p in e.data.polygons: p.use_smooth = True

# ---------------------------------------------------------------- Haende aus Fingergliedern (haengend, locker gekruemmt)
def capsule(a, b, ra, rb, mat):
    d = b - a; L = d.length
    bpy.ops.mesh.primitive_cylinder_add(radius=1, depth=1, vertices=14)
    c = bpy.context.active_object; c.parent = root
    q = d.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
    c.matrix_basis = Matrix.Translation((a + b) / 2) @ q @ Matrix.Diagonal(((ra + rb) / 2, (ra + rb) / 2, L, 1))
    c.data.materials.append(MATS[mat])
    for p in c.data.polygons: p.use_smooth = True
    for pnt, rr in ((a, ra), (b, rb)):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=rr, segments=14, ring_count=8)
        s_ = bpy.context.active_object; s_.parent = root; s_.location = pnt; s_.data.materials.append(MATS[mat])
        for p in s_.data.polygons: p.use_smooth = True
def rot(v, axis, deg): return Matrix.Rotation(math.radians(deg), 3, axis) @ v
def hand(wrist, fore, sg):
    d = fore.normalized()                     # haengt nach unten
    fw = (P(0, 0, 1) - d * P(0, 0, 1).dot(d)).normalized()   # Breite der Hand: vorn-hinten
    palm_n = d.cross(fw).normalized() * sg    # Handflaeche zum Oberschenkel
    if palm_n.dot(P(-sg, 0, 0)) < 0: palm_n = -palm_n
    pc = wrist + d * 3.6
    bpy.ops.mesh.primitive_cube_add(size=1); pm = bpy.context.active_object; pm.parent = root
    pm.matrix_basis = Matrix.Translation(pc) @ Matrix((fw, d, palm_n)).transposed().to_4x4() @ Matrix.Diagonal((7.6, 6.4, 2.6, 1))
    sb = pm.modifiers.new('s', 'SUBSURF'); sb.levels = 3
    pm.data.materials.append(MATS['skin'])
    for p in pm.data.polygons: p.use_smooth = True
    axis = fw  # Kruemmung um die Querachse, zur Handflaeche hin
    # vier getrennte Finger (Luecke 0,4 cm, sonst verschmilzt das Voxelnetz zum Faeustling), leicht gefaechert, locker gekruemmt
    for i, (off, L, fan) in enumerate(((3.1, 4.1, 5), (1.05, 4.6, 1.5), (-1.05, 4.4, -1.5), (-3.1, 3.5, -6))):
        base = pc + d * 2.8 + fw * off * 0.92
        dirv = Matrix.Rotation(math.radians(fan), 3, palm_n) @ d; pnt = base
        for seg, (ln, cu) in enumerate(((L * 0.46, 10), (L * 0.30, 20), (L * 0.24, 16))):
            dirv = (Matrix.Rotation(math.radians(cu), 3, axis) @ dirv)
            nxt = pnt + dirv * ln
            capsule(pnt, nxt, 0.86 - 0.07 * seg, 0.8 - 0.07 * seg, 'skin')
            pnt = nxt
    # Daumen: vorn seitlich an der Hand, locker neben dem Zeigefinger, Spitze leicht zur Handflaeche
    tb = pc - d * 1.4 + fw * 3.3 + palm_n * 0.8
    t1 = tb + (d * 0.75 + fw * 0.35 + palm_n * 0.25).normalized() * 2.6
    t2 = t1 + (d * 0.95 + fw * 0.05 + palm_n * 0.3).normalized() * 2.1
    capsule(tb, t1, 1.15, 0.98, 'skin'); capsule(t1, t2, 0.98, 0.82, 'skin')
for s_, sg in (('R', 1), ('L', -1)):
    w_ = J['wr' + s_][0]; f_ = J['fo' + s_][0]
    before = set(bpy.data.objects)
    hand(w_, w_ - f_, sg)
    hd_ = fuse([o for o in bpy.data.objects if o not in before], 'hand' + s_, voxel=0.17)
    HK = 1.0 if FIGUR == 'held' else (1.3 if FG['statur'] == 'zwerg' else 1.15)   # Runde 2 (Helfer: Haende klein); Doll handK Zwerg 1,2
    for v in hd_.data.vertices: v.co = w_ + (v.co - w_) * HK

# ---------------------------------------------------------------- Schwert in der Scheide an der linken Huefte
def cyl(a, b, ra, rb, mat):
    capsule(a, b, ra, rb, mat)
# Bruder Osric: die Sonne auf der Brust (holy_symbol)
if FG['sonne']:
    hs = bvh([chain]).ray_cast(P(0, shoulderY - 12, 60), Vector((0, 1, 0)))
    bpy.ops.mesh.primitive_cylinder_add(radius=5.0, depth=0.8, vertices=12)
    sn = bpy.context.active_object; sn.name = 'sun'; sn.parent = root
    sn.location = (hs[0] if hs[0] else P(0, shoulderY - 12, 12)) + P(0, 0, 0.5); sn.rotation_euler = (math.radians(90), 0, 0)
    sn.data.materials.append(MATS['gold'])
    for k_ in range(8):   # Runde 2: ohne Strahlen las sie sich als Ei
        a_ = 2 * math.pi * k_ / 8; dv = Vector((math.cos(a_), 0, math.sin(a_)))
        capsule(sn.location + dv * 4.6 + P(0, 0, 0.2), sn.location + dv * 8.2 + P(0, 0, 0.4), 0.9, 0.35, 'gold')
if FG['schwert']:
    top = P(-16.5, 97.0, 5.0); bot = P(-21.5, 44.0, -26.0)   # schraeg nach hinten, endet ueber der Wade
    dd = (bot - top).normalized()
    capsule(top, bot, 2.6, 1.9, 'grip')                    # Scheide, dunkles Leder
    capsule(top - dd * 1.0, top + dd * 6, 2.9, 2.9, 'fit')   # Mundblech
    capsule(bot - dd * 5, bot, 2.1, 1.9, 'fit')            # Ortband
    hilt = -dd
    g0 = top + hilt * 2.0
    e_ = hilt.cross(P(1, 0, 0)).normalized()
    capsule(g0 - e_ * 10.0, g0 + e_ * 10.0, 0.75, 0.75, 'fit')   # Parierstange
    capsule(g0, g0 + hilt * 14.0, 1.35, 1.35, 'grip')
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1, segments=16, ring_count=8); pm_ = bpy.context.active_object; pm_.parent = root
    pm_.location = g0 + hilt * 15.6; pm_.scale = (2.0, 2.0, 2.0); pm_.data.materials.append(MATS['fit'])

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
if FG['schild']:
    sh = shield()
    # auf dem Ruecken ueber dem Umhang, Gesicht nach aussen, oben etwas ueber den Schultern
    n = Vector((0, 1, 0)); up = Vector((0, -0.16, 0.99)).normalized(); ax = up.cross(n).normalized(); n = ax.cross(up)
    hb2 = bvh([cl]).ray_cast(Vector((0, 80, 118)), Vector((0, -1, 0)))
    # Runde 3 (1): ragte 4 cm ueber die Schultern und las sich von vorn als Brett hinter dem Nacken: Oberkante unter der Schulter
    c0 = Vector((0, (hb2[0].y if hb2[0] else 14) + 5.5, shoulderY - 5 - SH_HT * 0.42))
    sh.matrix_basis = Matrix.Translation(c0) @ Matrix((ax, up, n)).transposed().to_4x4()

bpy.context.view_layer.update()
# ---------------------------------------------------------------- Kartenausschnitt (nur mit SCENE=1): Weg, Gras, Baeume, Stein, Laterne
if os.environ.get('SCENE') == '1':
    make_mat('gras', 40, lambda nt: rgb_node(nt, hx(0x3E5A30))); GRAIN['gras'] = 0.3
    make_mat('weg', 41, lambda nt: rgb_node(nt, hx(0x8A7456)))
    make_mat('laub', 42, lambda nt: rgb_node(nt, hx(0x2E5A2A)))
    make_mat('rinde', 43, lambda nt: rgb_node(nt, hx(0x4A3424)))
    make_mat('stein', 44, lambda nt: rgb_node(nt, hx(0x7A7870)))
    def add_obj(o, mat):
        o.data.materials.append(MATS[mat])
        for p in o.data.polygons: p.use_smooth = True
        return o
    bpy.ops.mesh.primitive_plane_add(size=1600, location=(0, 0, -0.3)); add_obj(bpy.context.active_object, 'gras')
    # Weg: geschwungenes Band, leicht erhaben
    pts = []
    for i in range(41):
        t = -1 + 2 * i / 40; x = t * 800; y = 40 * math.sin(t * 2.2) + 10
        w = 75 + 12 * math.sin(t * 7)
        pts.append(((x, y - w, 0.2), (x, y + w, 0.2)))
    vs = [v for p in pts for v in p]; fs = [(2 * i, 2 * i + 2, 2 * i + 3, 2 * i + 1) for i in range(40)]
    me = bpy.data.meshes.new('weg'); me.from_pydata(vs, [], fs); o = bpy.data.objects.new('weg', me); scn.collection.objects.link(o); add_obj(o, 'weg')
    rnd = np.random.default_rng(5)
    for (x, y, s_) in ((-230, 210, 1.1), (210, 260, 1.3), (330, -230, 1.0)):
        bpy.ops.mesh.primitive_cylinder_add(radius=12 * s_, depth=160 * s_, location=(x, y, 80 * s_)); add_obj(bpy.context.active_object, 'rinde')
        for k in range(4):
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=70 * s_ * (0.75 + 0.25 * rnd.random()),
                location=(x + rnd.normal() * 35 * s_, y + rnd.normal() * 35 * s_, (190 + 45 * k) * s_ - k * 25))
            add_obj(bpy.context.active_object, 'laub')
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=28, location=(-170, -150, 6))
    st_ = bpy.context.active_object; st_.scale = (1.4, 1.0, 0.7); add_obj(st_, 'stein')
    # Laterne am Pfahl neben dem Weg
    bpy.ops.mesh.primitive_cylinder_add(radius=4, depth=200, location=(95, -80, 100)); o_ = add_obj(bpy.context.active_object, 'rinde'); o_.visible_shadow = False
    bpy.ops.mesh.primitive_cube_add(size=16, location=(95, -80, 205)); o_ = add_obj(bpy.context.active_object, 'gold'); o_.visible_shadow = False
# 348.6 Leute: Kind mit groesserem Kopf, dann die ganze Figur auf ihre Groesse (Pim 0,62, Borin 0,74)
bpy.context.view_layer.update()
if FG['kind'] or FG['statur'] == 'zwerg':
    N_ = J['neckTop'][0]; M_ = Matrix.Translation(N_) @ Matrix.Scale(1.35 if FG['kind'] else 1.22, 4) @ Matrix.Translation(-N_)
    for o in [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith(('head', 'eye', 'lid', 'ear', 'hair', 'tuch', 'hood', 'beard', 'circlet'))]:
        o.matrix_world = M_ @ o.matrix_world
# Runde 2 (Helfer: Pim und Borin nur verkleinert, Koerper je Gruppe gleich): kurze Beine (Doll legF Zwerg 0,39), gebeugte Alte
KL = float(FG.get('beine', 0.644 if FG['statur'] == 'zwerg' else (0.88 if FG['kind'] else 1.0)))
BEUG = math.radians(float(FG.get('gebeugt', 0.0)))
H0 = hipY; ZP = 103.0 - (1 - KL) * H0
def _smin(a, b, k=6.0):
    h = np.clip(0.5 + 0.5 * (b - a) / k, 0, 1); return b + (a - b) * h - k * h * (1 - h)
def deform(V):
    V = V.copy()
    if KL != 1.0: V[:, 2] = V[:, 2] - (1 - KL) * _smin(np.maximum(V[:, 2], 0.0), H0)
    if BEUG:
        dz = V[:, 2] - ZP; th = BEUG * np.clip(dz / 30.0, 0, 1); up = dz > 0
        y, z_ = V[:, 1].copy(), dz.copy()
        V[up, 1] = y[up] * np.cos(th[up]) - z_[up] * np.sin(th[up]); V[up, 2] = ZP + y[up] * np.sin(th[up]) + z_[up] * np.cos(th[up])
    return V
if FIGUR != 'held' and (KL != 1.0 or BEUG):
    bpy.context.view_layer.update()
    for o in [o for o in bpy.data.objects if o.type == 'MESH']:
        mw = np.array(o.matrix_world); me = o.data
        co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co); co = co.reshape(-1, 3)
        W = co @ mw[:3, :3].T + mw[:3, 3]; W = deform(W)
        co = (W - mw[:3, 3]) @ np.linalg.inv(mw[:3, :3]).T
        me.vertices.foreach_set('co', co.ravel()); me.update()
    JV = deform(np.array([tuple(v[0]) for v in J.values()]))
    J = {k: (Vector(JV[i]), v[1]) for i, (k, v) in enumerate(J.items())}
    if BEUG:   # Kopf schaut wieder nach vorn
        N_ = J['neckTop'][0]; M_ = Matrix.Translation(N_) @ Matrix.Rotation(-0.6 * BEUG, 4, 'X') @ Matrix.Translation(-N_)
        bpy.context.view_layer.update()
        for o in [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith(('head', 'eye', 'lid', 'ear', 'hair', 'tuch', 'hood', 'beard', 'circlet'))
                  and o.name not in ('hairback', 'hairbraid', 'hairtie')]:
            o.matrix_world = M_ @ o.matrix_world
GS = float(FG['groesse'])
if FIGUR != 'held':   # Groesse wie Doll: Mensch 175, Zwerg 135, Frau x 0,93, dazu sizeK und eigene Abweichung (groesse)
    bpy.context.view_layer.update()
    top_ = max(max((o.matrix_world @ v.co).z for v in o.data.vertices) for o in bpy.data.objects if o.type == 'MESH')
    GS = (135.0 if FG['statur'] == 'zwerg' else 175.0) * (0.93 if FEM else 1.0) * GS / top_
if GS != 1.0:
    S_ = Matrix.Scale(GS, 4)
    for o in [o for o in bpy.data.objects if o.parent is None]: o.matrix_world = S_ @ o.matrix_world
    J = {k: (v[0] * GS, (v[1][0] * GS, v[1][1] * GS)) for k, v in J.items()}
json.dump({'J': {k: [list(v[0]), list(v[1])] for k, v in J.items()}, 'E': E}, open(OUT + '/gelenke.json', 'w'))
bpy.ops.wm.save_as_mainfile(filepath=OUT + '/' + os.environ.get('OUTBLEND', 'held3.blend'))
print('MODEL OK', len(bpy.data.objects))
