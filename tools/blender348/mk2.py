s = open('build.py').read()
k = open('aldric/kopf.py').read()
def rep(a, b, cnt=1):
    global s
    assert s.count(a) >= 1, a[:60]
    s = s.replace(a, b) if cnt == 0 else s.replace(a, b, 1)

# --- Abnutzung, Koernung, Tinte-Attribut in jedem Material
rep("# ---------------------------------------------------------------- Materialien mit Modus-Weiche",
'''WEAR = float(os.environ.get('WEAR', '0.7'))
# grain je Material wie Dress.kt (Mat grain)
GRAIN = {'skin': 0.02, 'chain': 0.45, 'tabard': 0.05, 'sleeve': 0.05, 'pants': 0.05, 'boots': 0.05, 'belt': 0.05, 'cloak': 0.05,
         'wood': 0.12, 'cuff': 0.05, 'grip': 0.05, 'helm': 0.0, 'helmrim': 0.0, 'fit': 0.0, 'steel': 0.0, 'gold': 0.0, 'shield': 0.0, 'skinface': 0.02, 'lid': 0.02}
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
    W = WEAR
    if W <= 0: return col
    geo = nt.nodes.new('ShaderNodeNewGeometry')
    z = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(geo.outputs['Position'], z.inputs[0]); Z = z.outputs['Z']
    blot = _noise(nt, 0.09, 'World')
    if name in ('tabard', 'cloak', 'sleeve', 'pants'):
        col = _mix(nt, 0.55 * W, col, lin(hx(0x8A8076)))                      # ausgeblichen
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
        col = _mix(nt, _m(nt, 'MULTIPLY', sc, 0.7 * W), col, lin(hx(0xA89880)))     # Kratzer
    if name in ('boots', 'cuff', 'pants', 'cloak', 'tabard'):
        top = 20 + 55 * W
        mud = _sat(nt, _m(nt, 'ADD', _m(nt, 'DIVIDE', _m(nt, 'SUBTRACT', top, Z), 9.0), _m(nt, 'MULTIPLY', _m(nt, 'SUBTRACT', blot, 0.5), 2.2)))
        col = _mix(nt, _m(nt, 'MULTIPLY', mud, 0.95), col, lin(hx(0x7A6448)))         # Schlamm
    return col
# ---------------------------------------------------------------- Materialien mit Modus-Weiche''')
rep("def make_mat(name, mid, color_fn, bump_fn=None, mid_fn=None):", "def make_mat(name, mid, color_fn, bump_fn=None, mid_fn=None, ink_attr=None):")
rep("    col = color_fn(nt)\n", "    col = finish(nt, color_fn(nt), name)\n")
rep("    m['modes'] = 1\n", """    m['modes'] = 1
    e_ink = nt.nodes.new('ShaderNodeEmission'); e_ink.name = 'M_ink'
    if ink_attr:
        at = nt.nodes.new('ShaderNodeAttribute'); at.attribute_name = ink_attr; nt.links.new(at.outputs['Fac'], e_ink.inputs['Strength'])
    else: e_ink.inputs['Strength'].default_value = 0.0
""")
rep("import bpy, bmesh, math, sys, os, json, time", "import bpy, bmesh, math, sys, os, json, time")
# Haut des Kopfs mit Lippen/Brauen, Lider
rep("make_mat('face', 1, face_color)", """make_mat('face', 1, face_color)
def skinface(nt):
    c = rgb_node(nt, COL['skin'])
    a1 = nt.nodes.new('ShaderNodeAttribute'); a1.attribute_name = 'lip'
    a2 = nt.nodes.new('ShaderNodeAttribute'); a2.attribute_name = 'brow'
    c = mixc(nt, a1.outputs['Fac'], c, rgb_node(nt, (176, 112, 96)))
    return mixc(nt, a2.outputs['Fac'], c, rgb_node(nt, COL['hair'], 0.8))
make_mat('skinface', 1, skinface, ink_attr='ink')
make_mat('lid', 1, lambda nt: rgb_node(nt, COL['skin'], 0.95), ink_attr='ink')
def eye_col(nt):
    tc = nt.nodes.new('ShaderNodeTexCoord'); sep = nt.nodes.new('ShaderNodeSeparateXYZ'); nt.links.new(tc.outputs['Object'], sep.inputs[0])
    X, Y, Zs = sep.outputs['X'], sep.outputs['Y'], sep.outputs['Z']
    rr = math_node(nt, 'SQRT', math_node(nt, 'ADD', math_node(nt, 'MULTIPLY', X, X), math_node(nt, 'MULTIPLY', Zs, Zs)))
    fr = math_node(nt, 'LESS_THAN', Y, 0.0)
    iris = math_node(nt, 'MULTIPLY', math_node(nt, 'LESS_THAN', rr, 0.52), fr); pup = math_node(nt, 'MULTIPLY', math_node(nt, 'LESS_THAN', rr, 0.24), fr)
    c = mixc(nt, iris, rgb_node(nt, (232, 226, 214)), rgb_node(nt, (74, 58, 42)))
    return mixc(nt, pup, c, rgb_node(nt, (20, 16, 14)))
make_mat('eye', 30, eye_col)""")
# Gedrungen: Radien x1.12, Schultern breiter; Arme haengen (Karte wie heute)
rep("""j('upR', 18.8, 127.5, -3.0, (5.3, 5.3)); j('elR', 21.0, 114.0, -5.0, (4.1, 4.1))
j('foR', 21.5, 104.0, 3.5, (4.3, 4.3)); j('wrR', 20.0, 94.5, 13.0, (2.9, 2.9))""",
"""j('upR', 22.5, 127.5, -1.5, (5.3, 5.3)); j('elR', 25.0, 114.0, -1.5, (4.1, 4.1))
j('foR', 25.5, 103.0, 0.5, (4.3, 4.3)); j('wrR', 25.0, 91.0, 2.0, (2.9, 2.9))""")
rep("""j('upL', -19.5, 127.5, -2.0, (5.3, 5.3)); j('elL', -22.0, 114.0, -3.0, (4.1, 4.1))
j('foL', -19.0, 104.5, 6.0, (4.3, 4.3)); j('wrL', -15.5, 95.0, 15.0, (2.9, 2.9))""",
"""j('upL', -22.5, 127.5, -1.5, (5.3, 5.3)); j('elL', -25.0, 114.0, -1.5, (4.1, 4.1))
j('foL', -25.5, 103.0, 0.5, (4.3, 4.3)); j('wrL', -25.0, 91.0, 2.0, (2.9, 2.9))""")
rep("    j('sh' + s, sg * 16.0, 141.0, -1.0, (6.4, 6.4))", "    j('sh' + s, sg * 19.0, 141.0, -1.0, (6.4, 6.4))")
rep("for s, sg, ff in (('R', 1, 6.0), ('L', -1, -5.0)):", "for s, sg, ff in (('R', 1, 2.0), ('L', -1, -2.0)):")
rep("for s, sg, ff in (('R', 1, 2.0), ('L', -1, -2.0)):", "PH = math.radians(float(os.environ.get('PHASE', '-1')))\nWALK = os.environ.get('PHASE') is not None\nfor s, sg, ff in ((('R', 1, 24 * math.cos(PH)), ('L', -1, -24 * math.cos(PH))) if WALK else (('R', 1, 2.0), ('L', -1, -2.0))):")
rep("E = [('pelvis', 'waist')", '''if WALK:
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
E = [('pelvis', 'waist')''')
rep("E = [('pelvis', 'waist')", """for _k in list(J):
    _p, _r = J[_k]
    if not _k.startswith(('neck', 'heel', 'ball', 'toe', 'ankle')): _f = 1.3 if _k in ('pelvis', 'waist', 'belly', 'chest', 'chestTop') else (1.22 if _k[:2] in ('sh', 'up', 'el', 'fo') else 1.15); J[_k] = (_p, (_r[0] * _f, _r[1] * _f))
E = [('pelvis', 'waist')""")
# Kopf aus dem Grundkopf (Regler), Augen mit Lidern
fsrc = k[k.index('G = lambda x: np.exp(-x)\n'):k.index('p0 = {k: 0.0 for k in SL}')]
rep("hme = head_mesh()\n", '''SL = ['nase_laenge', 'nase_breite', 'nase_kruemmung', 'kinn', 'wangen', 'augenabstand', 'brauen', 'falten', 'wangenknochen']
_bm = bmesh.new(); bmesh.ops.create_icosphere(_bm, subdivisions=6, radius=1.0)
U = np.array([tuple(v.co) for v in _bm.verts])
''' + fsrc + '''HP = dict(nase_laenge=0.1, nase_breite=0.4, nase_kruemmung=0.2, kinn=0.7, wangen=0.2, augenabstand=0.1, brauen=0.6, falten=0.25, wangenknochen=0.4)
HV_, INK_, LIP_, BROW_, EX_ = face(HP)
HV_ = HV_ * 1.1
for i, v in enumerate(_bm.verts): v.co = Vector(HV_[i])
hme = bpy.data.meshes.new('head'); _bm.to_mesh(hme); _bm.free()
for nm_, vals_ in (('ink', np.clip(INK_ * 1.4, 0, 1)), ('lip', np.clip(LIP_, 0, 1)), ('brow', (BROW_ > 0.5) * 1.0)):
    a_ = hme.attributes.new(nm_, 'FLOAT', 'POINT'); a_.data.foreach_set('value', list(map(float, vals_)))
''')
rep("head.data.materials.append(MATS['face'])", '''head.data.materials.append(MATS['skinface'])
_hb = BVHTree.FromPolygons([tuple(v.co) for v in hme.vertices], [tuple(p.vertices) for p in hme.polygons])
for sg in (1, -1):
    x = -sg * EX_ * 1.1
    hit = _hb.ray_cast(Vector((x, -40, 1.0)), Vector((0, 1, 0)))
    R = 1.25; c = Vector((x, (hit[0].y if hit[0] else -9) + R - 0.3, 1.0))
    b2 = bmesh.new(); bmesh.ops.create_uvsphere(b2, u_segments=32, v_segments=16, radius=R)
    m2 = bpy.data.meshes.new('eye'); b2.to_mesh(m2); b2.free()
    eo = bpy.data.objects.new('eye', m2); link(eo); eo.location = head.location + c; eo.data.materials.append(MATS['eye'])
    for p in m2.polygons: p.use_smooth = True
    for keep in (lambda el: el > 14, lambda el: el < -26):
        b3 = bmesh.new(); bmesh.ops.create_uvsphere(b3, u_segments=40, v_segments=24, radius=R + 0.16)
        kill = [f_ for f_ in b3.faces if any((not keep(math.degrees(math.asin(max(-1, min(1, v.co.normalized().z)))))) or v.co.normalized().y > 0.55 for v in f_.verts)]
        bmesh.ops.delete(b3, geom=kill, context='FACES')
        m3 = bpy.data.meshes.new('lid'); b3.to_mesh(m3); b3.free()
        lo = bpy.data.objects.new('lid', m3); link(lo); lo.location = head.location + c; lo.data.materials.append(MATS['lid'])
        so = lo.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.3; so.offset = 1
        a_ = m3.attributes.new('ink', 'FLOAT', 'POINT'); a_.data.foreach_set('value', [0.0] * len(m3.vertices))
        for p in m3.polygons: p.use_smooth = True''')
rep("from mathutils import Vector, Matrix\n", "from mathutils import Vector, Matrix\nfrom mathutils.bvhtree import BVHTree\n")
rep("edge_u = lambda co: 0.6 + 0.38 * (-co.y)", "edge_u = lambda co: 2.2 + 0.38 * (-co.y)")
rep("nas.scale = (1.5, 0.7, 6.0); nas.location = head.location + P(0, -0.9, 10.6)", "nas.scale = (1.5, 0.7, 5.5); nas.location = head.location + P(0, 2.2, 11.4)")
# Haende, Schwert an der Seite, Schild auf dem Ruecken
a0 = s.index("# ---------------------------------------------------------------- Haende")
a1 = s.index("# ---------------------------------------------------------------- Schild (heater")
s = s[:a0] + open('teil2.py').read() + s[a1:]
a2 = s.index("el = J['elL'][0]; wr = J['wrL'][0]")
a3 = s.index("sh.matrix_basis = ")
a4 = s.index("\n", a3)
s = s[:a2] + '''# auf dem Ruecken ueber dem Umhang, Gesicht nach aussen, oben etwas ueber den Schultern
n = Vector((0, 1, 0)); up = Vector((0, -0.16, 0.99)).normalized(); ax = up.cross(n).normalized(); n = ax.cross(up)
hb2 = bvh([cl]).ray_cast(Vector((0, 80, 118)), Vector((0, -1, 0)))
c0 = Vector((0, (hb2[0].y if hb2[0] else 14) + 5.5, shoulderY + 4 - SH_HT * 0.42))
sh.matrix_basis = Matrix.Translation(c0) @ Matrix((ax, up, n)).transposed().to_4x4()''' + s[a4:]
rep("bpy.ops.wm.save_as_mainfile(filepath=OUT + '/held.blend')", open('teil3.py').read() + "bpy.ops.wm.save_as_mainfile(filepath=OUT + '/' + os.environ.get('OUTBLEND', 'held2.blend'))")
open('build2.py', 'w').write(s)
print('ok')
