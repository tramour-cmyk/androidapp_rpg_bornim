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
    pc = wrist + d * 4.2
    bpy.ops.mesh.primitive_cube_add(size=1); pm = bpy.context.active_object; pm.parent = root
    pm.matrix_basis = Matrix.Translation(pc) @ Matrix((fw, d, palm_n)).transposed().to_4x4() @ Matrix.Diagonal((8.6, 8.2, 3.4, 1))
    sb = pm.modifiers.new('s', 'SUBSURF'); sb.levels = 3
    pm.data.materials.append(MATS['skin'])
    for p in pm.data.polygons: p.use_smooth = True
    axis = fw  # Kruemmung um die Querachse, zur Handflaeche hin
    for i, (off, L) in enumerate(((2.6, 4.0), (0.9, 4.4), (-0.9, 4.2), (-2.6, 3.4))):
        base = pc + d * 3.4 + fw * off
        dirv = d.copy(); pnt = base
        for seg, (ln, cu) in enumerate(((L * 0.48, 12), (L * 0.3, 28), (L * 0.24, 26))):
            dirv = (Matrix.Rotation(math.radians(cu), 3, axis) @ dirv)
            if dirv.dot(palm_n) < (Matrix.Rotation(math.radians(-cu), 3, axis) @ dirv).dot(palm_n): pass
            nxt = pnt + dirv * ln
            capsule(pnt, nxt, 1.08 - 0.1 * seg, 1.0 - 0.1 * seg, 'skin')
            pnt = nxt
    # Daumen: vorn an der Hand, zur Handflaeche
    tb = pc - d * 1.2 + fw * 3.6 + palm_n * 1.0
    t1 = tb + (d * 0.7 + fw * 0.4 + palm_n * 0.3).normalized() * 3.4
    t2 = t1 + (d * 0.9 + palm_n * 0.4).normalized() * 2.6
    capsule(tb, t1, 1.15, 1.0, 'skin'); capsule(t1, t2, 1.0, 0.85, 'skin')
for s_, sg in (('R', 1), ('L', -1)):
    w_ = J['wr' + s_][0]; f_ = J['fo' + s_][0]
    hand(w_, w_ - f_, sg)

# ---------------------------------------------------------------- Schwert in der Scheide an der linken Huefte
def cyl(a, b, ra, rb, mat):
    capsule(a, b, ra, rb, mat)
top = P(-16.5, 97.0, 5.0); bot = P(-19.0, 28.0, -16.0)
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

