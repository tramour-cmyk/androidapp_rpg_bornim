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
