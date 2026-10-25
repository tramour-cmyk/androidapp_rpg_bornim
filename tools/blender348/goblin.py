# 348.7 (Jerry): Goblin aus dem Mensch-Grundmodell (Modellregel 4, Arbeitsteilung 2): v3/held3.py baut Körper, Hände und
# Gelenke (schlank, kahl, Haut der Art), dieses Skript macht daraus den Goblin wie Doll.kt (108 cm, 4,2 Köpfe, Beine 0,42,
# Arme 1,16, Hände und Füße 1,3, Kopf nach Doll.goblinHead/goblinFace, barfuß, Lendentuch), legt die Ausrüstung der drei
# Kits aus MonsterKit.kt an (Wams, Fell, Kappe, Helm; Waffen als eigene .glb, Modellregel 4) und lässt v3/rig.py Skelett,
# Gewichte und Bewegungen machen.
# Aufruf: OUT=<ordner> [KIT=leder|kappe|helm] python -I goblin.py  ->  <OUT>/goblin-<kit>.glb, goblin-info.json
# (python = Blender als Modul wie im Workflow; held3.py und rig.py laufen je Kit in <OUT>/_goblin-<kit>/ mit eigener leute.json)
import os, sys, json, shutil, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
V3 = os.path.join(HERE, 'v3')
OUT = os.environ.get('OUT', os.path.join(HERE, 'out'))

# Kits wie MonsterKits "goblin" (Saat 0, 4, 8: Kit = Saat mod 3, Haut = Saat / 3 mod 4, Größe MonsterKits.size 0,91–1,09)
KITS = {
    # Krummsäbel, Rundschild, Lederwams, Fell (crude, pelt)
    'leder': dict(haut=0x5E6838, wams=True, fell=True, kopf=None, groesse=1.0, waffen=['scimitar-rost', 'round_shield-grob']),
    # Handbeil, Lederwams, Lederkappe, Fell
    'kappe': dict(haut=0x4E5C32, wams=True, fell=True, kopf='kappe', groesse=0.95, waffen=['handaxe-rost']),
    # Krummsäbel und Dolch, Helm, nackter Oberkörper
    'helm': dict(haut=0x6C683C, wams=False, fell=False, kopf='helm', groesse=1.05, waffen=['scimitar-rost', 'dagger-rost']),
}
H_GOB = 108.0          # Doll: goblin -> 108 cm
HEADS = 4.2            # Kopflängen
# Gang (rig.py): flink, geduckt, die langen Arme schwingen (FoeArt: „stooped and springing“)
GANG = dict(takt=24, schritt=1.0, knie=1.3, arm=1.3, vor=10)


def treiber():
    py = sys.executable
    os.makedirs(OUT, exist_ok=True)
    kits = [os.environ['KIT']] if os.environ.get('KIT') else list(KITS)
    info = {}
    for kit in kits:
        k = KITS[kit]
        T = os.path.join(OUT, '_goblin-' + kit)
        shutil.rmtree(T, ignore_errors=True); os.makedirs(T)
        for f in ('held3.py', 'rig.py'):
            shutil.copy(os.path.join(V3, f), T)
        fig = 'goblin_' + kit
        # held3.py: Abweichung vom Helden (Felder wie leute.json); Kleidung entfernt nachher dieses Skript
        json.dump({fig: dict(sex='m', statur='schlank', haut='%06X' % k['haut'], haar='24201C', kopf='glatze', hemd='kittel',
                             rock='keiner', tabard='6A4A32', sleeve='4E4232', pants='4E4232', groesse=1.0, beine=0.82,
                             gebeugt=16, gang=GANG)},
                  open(os.path.join(T, 'leute.json'), 'w'))
        env = dict(os.environ, OUT=T, FIGUR=fig, GOBLIN=kit, ATLAS='1024')   # Modellregel 6: höchstens 1024 px
        for step in ([os.path.join(T, 'held3.py')], [os.path.abspath(__file__), '--nach'], [os.path.join(T, 'rig.py')]):
            r = subprocess.run([py, '-I'] + step, env=env, capture_output=True, text=True)
            log = r.stdout + r.stderr
            open(os.path.join(T, os.path.basename(step[0]) + '.log'), 'w').write(log)
            if r.returncode != 0 or ('rig.py' in step[0] and 'GLB OK' not in log):
                print(log[-4000:]); sys.exit('goblin %s: %s fehlgeschlagen' % (kit, os.path.basename(step[0])))
            for line in log.splitlines():
                if line.startswith(('GOBLIN', 'DREIECKE', 'NETZ', 'ANIM', 'GLB')): print(kit, line)
        shutil.copy(os.path.join(T, 'held.glb'), os.path.join(OUT, 'goblin-%s.glb' % kit))
        hi = json.load(open(os.path.join(T, 'held-info.json')))
        gi = json.load(open(os.path.join(T, 'goblin-masse.json')))
        info[kit] = dict(hi, **gi, waffen=k['waffen'])
    json.dump(info, open(os.path.join(OUT, 'goblin-info.json'), 'w'), indent=1)
    print('GOBLIN FERTIG', list(info))


# ---------------------------------------------------------------- Nachbearbeitung in Blender (aus dem Treiber mit --nach)
def nach():
    import bpy, bmesh, math
    import numpy as np
    from mathutils import Vector, Matrix
    from mathutils import noise
    T = os.environ['OUT']; kit = os.environ['GOBLIN']; K = KITS[kit]
    bpy.ops.wm.open_mainfile(filepath=T + '/held3.blend')
    G = json.load(open(T + '/gelenke.json'))
    J = {k: [Vector(v[0]), list(v[1])] for k, v in G['J'].items()}
    E = [tuple(e) for e in G['E']]
    scn = bpy.context.scene
    root = next(o for o in bpy.data.objects if o.type == 'EMPTY')
    meshes = lambda: [o for o in bpy.data.objects if o.type == 'MESH']

    def hx(c): return ((c >> 16) & 255, (c >> 8) & 255, c & 255)
    def lin(c, k=1.0):
        def f(v):
            v = min(1.0, v / 255.0 * k)
            return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
        r, g, b = hx(c); return (f(r), f(g), f(b), 1.0)
    def mixh(a, b, t):
        A, B = hx(a), hx(b); r = [int(round(A[i] + (B[i] - A[i]) * t)) for i in range(3)]
        return (r[0] << 16) | (r[1] << 8) | r[2]

    # ---- Material wie held3.make_mat, soweit rig.py es braucht: Emission „M_albedo“ an „M_out“ (gebacken), Körnung, Flecken
    def mat(name, rgb, grain=0.15, blot=0.3, ink=False, scar=None, streak=None):
        m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
        out = nt.nodes.new('ShaderNodeOutputMaterial'); out.name = 'M_out'
        em = nt.nodes.new('ShaderNodeEmission'); em.name = 'M_albedo'
        def noise_(scale, src='Object', detail=3.0):
            n = nt.nodes.new('ShaderNodeTexNoise')
            n.inputs['Scale'].default_value = scale; n.inputs['Detail'].default_value = detail
            if src == 'World':
                g = nt.nodes.new('ShaderNodeNewGeometry'); nt.links.new(g.outputs['Position'], n.inputs['Vector'])
            else:
                tc = nt.nodes.new('ShaderNodeTexCoord'); nt.links.new(tc.outputs[src], n.inputs['Vector'])
            return n.outputs['Fac']
        def mul_col(col, fac_socket, lo, hi):
            mr = nt.nodes.new('ShaderNodeMapRange'); mr.inputs['To Min'].default_value = lo; mr.inputs['To Max'].default_value = hi
            nt.links.new(fac_socket, mr.inputs['Value'])
            vm = nt.nodes.new('ShaderNodeVectorMath'); vm.operation = 'SCALE'
            nt.links.new(col, vm.inputs[0]); nt.links.new(mr.outputs[0], vm.inputs['Scale']); return vm.outputs[0]
        c = nt.nodes.new('ShaderNodeRGB'); c.outputs[0].default_value = lin(rgb); col = c.outputs[0]
        if grain: col = mul_col(col, noise_(0.55, detail=4.0), 1 - 0.8 * grain, 1 + 0.8 * grain)
        if blot: col = mul_col(col, noise_(0.06, 'World', 2.0), 1 - 0.5 * blot, 1 + 0.5 * blot)
        if streak:   # Fell: Strähnen längs (hell und dunkel wie Dress.furMantle)
            tc = nt.nodes.new('ShaderNodeTexCoord'); w = nt.nodes.new('ShaderNodeTexWave'); w.wave_type = 'BANDS'
            w.bands_direction = 'Z'; w.inputs['Scale'].default_value = streak; w.inputs['Distortion'].default_value = 8.0
            w.inputs['Detail'].default_value = 4.0; nt.links.new(tc.outputs['Object'], w.inputs['Vector'])
            col = mul_col(col, w.outputs['Fac'], 0.7, 1.45)
        if scar:   # Narbe (Attribut „narbe“): blasser
            a = nt.nodes.new('ShaderNodeAttribute'); a.attribute_name = 'narbe'
            mx = nt.nodes.new('ShaderNodeMix'); mx.data_type = 'RGBA'
            rgba = lambda socks, n: next(x for x in socks if x.name == n and x.type == 'RGBA')
            nt.links.new(a.outputs['Fac'], mx.inputs['Factor']); nt.links.new(col, rgba(mx.inputs, 'A'))
            rgba(mx.inputs, 'B').default_value = lin(scar); col = rgba(mx.outputs, 'Result')
        nt.links.new(col, em.inputs['Color'])
        if ink:   # rig.py dunkelt mit dem Attribut „ink“ ab (Mundlinie, Augenhöhle)
            a = nt.nodes.new('ShaderNodeAttribute'); a.attribute_name = 'ink'
        nt.links.new(em.outputs[0], out.inputs['Surface'])
        return m

    SKIN = K['haut']
    M = {
        'haut': bpy.data.materials['skin'],
        'gesicht': mat('gface', SKIN, grain=0.14, blot=0.35, ink=True, scar=mixh(SKIN, 0xC09A80, 0.5)),
        'auge': mat('geye', 0xE8B828, grain=0, blot=0),
        'pupille': mat('gpupil', 0x1A0C04, grain=0, blot=0),
        'zahn': mat('gzahn', 0xC8B880, grain=0.2, blot=0.2),
        'haar': mat('ghaar', 0x24201C, grain=0.22, blot=0.2),
        'lappen': mat('glappen', 0x4E4232, grain=0.25, blot=0.5),
        'fell': mat('gfell', 0x2E2620, grain=0.7, blot=0.3, streak=0.9),
        'leder': mat('gleder', 0x6A4A32, grain=0.07, blot=0.6),
        'rost': mat('grost', 0x6A5444, grain=0.55, blot=0.6),
        'rostrand': mat('grostrand', mixh(0x6A5444, 0x000000, 0.12), grain=0.55, blot=0.6),
    }
    # Wams: der Kittel aus held3 (Material „tabard“) wird Leder, roh
    for nm, rgb in (('tabard', 0x6A4A32),):
        if nm in bpy.data.materials:
            for n in bpy.data.materials[nm].node_tree.nodes:
                if n.type == 'RGB': n.outputs[0].default_value = lin(rgb)

    def world_apply(objs, fn):
        """fn(Nx3 Weltpunkte) -> Nx3; auf die Ecken der Objekte anwenden (wie held3.deform)."""
        bpy.context.view_layer.update()
        for o in objs:
            mw = np.array(o.matrix_world); me = o.data
            co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co); co = co.reshape(-1, 3)
            W = co @ mw[:3, :3].T + mw[:3, 3]; W = fn(W)
            co = (W - mw[:3, 3]) @ np.linalg.inv(mw[:3, :3]).T
            me.vertices.foreach_set('co', co.ravel()); me.update()

    def seg_dist(V, a, b):
        A, ra = np.array(J[a][0]), J[a][1][0]; B, rb = np.array(J[b][0]), J[b][1][0]
        ab = B - A; t = np.clip(((V - A) @ ab) / max(ab @ ab, 1e-9), 0, 1)
        return np.linalg.norm(V - (A + t[:, None] * ab), axis=1) - (ra + (rb - ra) * t)

    # ---- 1. Menschliches weg: Kopf, Augen, Lider, Ohren, Haar, Ärmel, Hose, Stiefel, Gürtel (der Goblin geht barfuß, halb nackt)
    for o in list(meshes()):
        if o.name.startswith(('head', 'eye', 'lid', 'ear', 'hair', 'helm', 'nasal', 'beard', 'sleeves', 'pants', 'boots', 'cuff', 'buckle')):
            bpy.data.objects.remove(o)
    if not K['wams'] and 'chain' in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects['chain'])
    body = bpy.data.objects['body']
    for p in body.data.polygons: p.material_index = 0       # Haut überall (held3: unter der Kleidung dunkles Tuch)

    # ---- 2. Maße wie Doll (goblin): Arme 1,16, Hände 1,3, Füße 1,3; Ziel in Zentimetern, am Ende auf H_GOB skaliert
    ARM = 1.16
    for s in 'RL':
        sh = J['sh' + s][0].copy()
        arm_bones = [('sh' + s, 'up' + s), ('up' + s, 'el' + s), ('el' + s, 'fo' + s), ('fo' + s, 'wr' + s)]
        all_b = [(a, b) for a, b in E if a != 'chestTop' or b in ('shR', 'shL')]
        def arm_fn(V, sh=sh, arm_bones=arm_bones, all_b=all_b):
            D = np.stack([seg_dist(V, a, b) for a, b in all_b], 1)
            near = np.argmin(D, 1)
            isarm = np.isin(near, [all_b.index(b) for b in arm_bones])
            # weich ab der Schulter: unter der Schulter wächst der Abstand nach unten um ARM
            dz = np.clip(sh.z - V[:, 2], 0, None)
            V = V.copy(); V[isarm, 2] = V[isarm, 2] - dz[isarm] * (ARM - 1)
            return V
        objs = [o for o in meshes() if o.name in ('body', 'chain')]
        world_apply(objs, arm_fn)
        wr_old = J['wr' + s][0].copy()
        for k_ in ('up', 'el', 'fo', 'wr'):
            p = J[k_ + s][0]; J[k_ + s][0] = Vector((p.x, p.y, p.z - max(0.0, sh.z - p.z) * (ARM - 1)))
        d = J['wr' + s][0] - wr_old
        hand = bpy.data.objects['hand' + s]
        HK = 1.3 / 1.15                                    # held3 macht Leute-Hände 1,15
        w_ = J['wr' + s][0]
        world_apply([hand], lambda V, d=d, w_=w_: (V + np.array(d) - np.array(w_)) * HK + np.array(w_))
        # Füße: länger und breiter um 1,3 (um das Fußgelenk), Zehen mit
        an = J['ankle' + s][0].copy()
        foot_b = [('ankle' + s, 'heel' + s), ('ankle' + s, 'ball' + s), ('ball' + s, 'toe' + s)]
        def foot_fn(V, an=an, foot_b=foot_b):
            D = np.stack([seg_dist(V, a, b) for a, b in E], 1); near = np.argmin(D, 1)
            isf = np.isin(near, [E.index(b) for b in foot_b]) & (V[:, 2] < an.z + 3)
            V = V.copy(); A = np.array(an)
            V[isf, :2] = A[:2] + (V[isf, :2] - A[:2]) * 1.3
            return V
        world_apply([body], foot_fn)
        for k_ in ('heel', 'ball', 'toe'):
            p = J[k_ + s][0]; J[k_ + s][0] = Vector((an.x + (p.x - an.x) * 1.3, an.y + (p.y - an.y) * 1.3, p.z))

    # ---- 3. Maßstab: Schulter des Goblins bei 0,734 der Größe (Doll: chinY − 0,033 H), Kopf 1/4,2 der Größe
    Hg = H_GOB * K['groesse']
    sh_z = J['shR'][0].z
    F = 0.734 * Hg / sh_z                    # Zentimeter je Einheit jetzt → Goblin
    k = Hg / HEADS / F                       # Kopflänge in heutigen Einheiten
    nt_ = J['neckTop'][0]
    C = Vector((nt_.x, nt_.y - 0.1 * k, nt_.z + 0.40 * k))     # Kopfmitte (Doll headC), etwas vor dem Hals
    def D(x, y, z):   # Doll-Kopfraum (rechts, hoch, vorn) in Vielfachen von k -> Blender (der Goblin blickt nach −Y)
        return C + Vector((-x * k, -z * k, y * k))

    # ---- 4. Kopf nach Doll.goblinHead: breiter flacher Schädel, vorgeschobener Kiefer, tiefe Braue, lange Hakennase
    parts = []
    def ell(c, r):
        bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=4, radius=1.0)
        for v in bm.verts: v.co = D(c[0] + v.co.x * r[0], c[1] + v.co.z * r[1], c[2] - v.co.y * r[2])
        me = bpy.data.meshes.new('gk'); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new('gk', me); scn.collection.objects.link(o); parts.append(o)
    def cone(a, b, ra, rb, n=8):
        for i in range(n + 1):
            t = i / n; c = [a[j] + (b[j] - a[j]) * t for j in range(3)]; r = ra + (rb - ra) * t
            ell(c, (r, r, r))
    ell((0.0, 0.08, -0.06), (0.4, 0.4, 0.44))          # Schädel
    ell((0.0, -0.2, 0.1), (0.33, 0.25, 0.33))          # Wangen und breiter Kiefer
    ell((0.0, -0.3, 0.2), (0.25, 0.12, 0.22))          # Unterkiefer vorgeschoben (Unterbiss)
    ell((0.0, 0.07, 0.32), (0.3, 0.07, 0.11))          # Brauenwulst tief über den Augen
    cone((0.0, 0.03, 0.38), (0.0, -0.12, 0.66), 0.085, 0.065)   # lange Nase …
    cone((0.0, -0.12, 0.66), (0.0, -0.22, 0.6), 0.065, 0.035)   # … vorn nach unten gehakt
    bpy.ops.object.select_all(action='DESELECT')
    for o in parts: o.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]; bpy.ops.object.join()
    head = bpy.context.active_object; head.name = 'head'
    rm = head.modifiers.new('vox', 'REMESH'); rm.mode = 'VOXEL'; rm.voxel_size = 0.018 * k
    sm = head.modifiers.new('glatt', 'SMOOTH'); sm.factor = 0.6; sm.iterations = 6
    bpy.ops.object.modifier_apply(modifier='vox'); bpy.ops.object.modifier_apply(modifier='glatt')
    # Haut: Runzeln und Warzen (Höhe entlang der Normale), Mund als Kerbe
    hv = head.data
    bm = bmesh.new(); bm.from_mesh(hv); bm.normal_update()
    inv = lambda p: ((-(p.x - C.x)) / k, (p.z - C.z) / k, (-(p.y - C.y)) / k)     # Blender -> Doll-Kopfraum
    INK = []; SCAR = []
    for v in bm.verts:
        x, y, z = inv(v.co)
        front = max(0.0, min(1.0, (z - 0.15) / 0.12))
        # Runzeln quer über die Stirn, Warzen
        wr = 0.006 * math.sin(y * 60.0) * max(0.0, min(1.0, (y - 0.12) / 0.05)) * front
        wart = 0.012 * max(0.0, noise.noise(v.co * (6.0 / k)) - 0.45) * 4.0
        # Mund: breite grimmige Kerbe (Doll goblinFace: Linie bei y −0,28, Breite ±0,2)
        mouth = math.exp(-((y + 0.285) / 0.022) ** 2) * max(0.0, 1 - (abs(x) / 0.21) ** 4) * front
        v.co = v.co + v.normal * (k * (wr + wart - 0.03 * mouth))
        # Tusche: Mundlinie, Schatten der tiefen Augenhöhlen unter der Braue
        sock = sum(math.exp(-(((x - sd * 0.17) / 0.09) ** 2 + ((y - 0.0) / 0.05) ** 2)) for sd in (-1, 1)) * front
        INK.append(min(1.0, 1.2 * mouth + 0.55 * sock))
        # alte Narbe schräg über das linke Auge (Doll: von (−0,2; 0,16) nach (−0,1; −0,12))
        ax, ay, bx, by = -0.2, 0.16, -0.1, -0.12
        t = max(0.0, min(1.0, ((x - ax) * (bx - ax) + (y - ay) * (by - ay)) / ((bx - ax) ** 2 + (by - ay) ** 2)))
        dd = math.hypot(x - (ax + t * (bx - ax)), y - (ay + t * (by - ay)))
        SCAR.append(math.exp(-(dd / 0.012) ** 2) * front)
    bm.to_mesh(hv); bm.free()
    for nm, vals in (('ink', INK), ('narbe', SCAR)):
        a = hv.attributes.new(nm, 'FLOAT', 'POINT'); a.data.foreach_set('value', vals)
    hv.materials.append(M['gesicht'])
    for p in hv.polygons: p.use_smooth = True
    head.parent = root; head.matrix_parent_inverse = root.matrix_world.inverted()

    def mesh_from(name, verts, faces, m, parent=True):
        me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in verts], [], faces); me.update()
        o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
        for p in me.polygons: p.use_smooth = True
        if parent: o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        return o

    # Ohren: weit zur Seite und nach oben hinten zur Spitze (Doll), flach wie ein Blatt, zum Gesicht hin gewölbt
    # (rund wie bei Doll lasen sie sich in 3D als Hörner: Ratte, Prüfer Runde 6)
    for sd in (-1, 1):
        base = (sd * 0.33, -0.02, -0.04); tip = (sd * 0.98, 0.32, -0.22)
        n_u, n_v = 14, 7
        V_ = []; F_ = []
        for i in range(n_u + 1):
            t = i / n_u
            cx = base[0] + (tip[0] - base[0]) * t; cy = base[1] + (tip[1] - base[1]) * t + 0.05 * math.sin(math.pi * t)
            cz = base[2] + (tip[2] - base[2]) * t
            w = 0.16 * (1 - t) ** 0.8 * (0.55 + 0.45 * math.sin(math.pi * min(1.0, t * 1.6) / 2 + 0.6)) + 0.004
            for j in range(n_v + 1):
                s_ = j / n_v * 2 - 1                       # über die Breite: unten (−1) bis oben (+1)
                cup = 0.035 * (1 - s_ * s_) * (1 - t)      # Mulde zur Vorderseite
                # Breite senkrecht zur Ohrachse, in der Ebene hoch/hinten; Kerben am unteren Rand (zerfranst)
                nick = 0.02 * (1 if (i % 4 == 2 and s_ < -0.6) else 0)
                V_.append(D(cx, cy + s_ * w * 0.8 + nick, cz + s_ * w * 0.35 + cup))
        for i in range(n_u):
            for j in range(n_v):
                a = i * (n_v + 1) + j; F_.append((a, a + 1, a + n_v + 2, a + n_v + 1) if sd > 0 else (a, a + n_v + 1, a + n_v + 2, a + 1))
        e = mesh_from('ear', V_, F_, M['haut'])
        so = e.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.045 * k; so.offset = 0
        sb = e.modifiers.new('sb', 'SUBSURF'); sb.levels = 1
        bpy.context.view_layer.objects.active = e
        for md in list(e.modifiers): bpy.ops.object.modifier_apply(modifier=md.name)
    # zwei untere Hauer über der Oberlippe, eine Reihe schiefer gelber Zähne im Mundspalt
    def tooth(a, b, ra, rb, name='head_zahn'):
        bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=ra * k, radius2=rb * k, depth=1.0)
        A, B = D(*a), D(*b); d = B - A
        q = d.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
        M4 = Matrix.Translation((A + B) / 2) @ q @ Matrix.Diagonal((1, 1, d.length, 1))
        for v in bm.verts: v.co = M4 @ v.co
        me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(M['zahn'])
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
    for sd in (-1, 1):
        tooth((sd * 0.13, -0.36, 0.37), (sd * 0.15, -0.21, 0.42), 0.032, 0.006)
    for t_ in range(-3, 4):
        if t_ in (-3, 3): continue
        tooth((t_ * 0.045, -0.3, 0.39), (t_ * 0.045 + 0.004 * t_, -0.268, 0.41), 0.016, 0.011)
    # Augen: klein, gelb, tief unter der Braue, mit dunklem Schlitz (Doll goblinFace)
    for sd in (-1, 1):
        bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=10, radius=1.0)
        for v in bm.verts: v.co = D(sd * 0.155 + v.co.x * 0.07, -0.005 + v.co.z * 0.035, 0.335 - v.co.y * 0.045)
        me = bpy.data.meshes.new('eye'); bm.to_mesh(me); bm.free()
        eo = bpy.data.objects.new('eye', me); scn.collection.objects.link(eo); me.materials.append(M['auge'])
        eo.parent = root; eo.matrix_parent_inverse = root.matrix_world.inverted()
        for p in me.polygons: p.use_smooth = True
        bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=1.0)
        for v in bm.verts: v.co = D(sd * 0.155 + v.co.x * 0.012, -0.005 + v.co.z * 0.03, 0.372 - v.co.y * 0.012)
        me = bpy.data.meshes.new('eye_pupille'); bm.to_mesh(me); bm.free()
        po = bpy.data.objects.new('eye_pupille', me); scn.collection.objects.link(po); me.materials.append(M['pupille'])
        po.parent = root; po.matrix_parent_inverse = root.matrix_world.inverted()
    # ein paar strähnige Haare oben auf dem Schädel (Doll: „a few lank strands“)
    for i, (ox, oz) in enumerate(((0.0, -0.1), (0.07, -0.05), (-0.06, -0.14))):
        pts = [D(ox + 0.02 * t, 0.47 - 0.1 * t * t, oz - 0.32 * t) for t in (0.0, 0.25, 0.5, 0.75, 1.0)]
        V_ = []; F_ = []
        for j, p in enumerate(pts):
            w = 0.028 * k * (1 - 0.8 * j / 4)
            V_ += [p + Vector((w, 0, 0)), p + Vector((-w, 0, 0))]
        for j in range(len(pts) - 1): F_.append((2 * j, 2 * j + 1, 2 * j + 3, 2 * j + 2))
        hs = mesh_from('hair_straehne', V_, F_, M['haar'])
        so = hs.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.012 * k; so.offset = 0
        bpy.context.view_layer.objects.active = hs; bpy.ops.object.modifier_apply(modifier='so')

    # Kopfbedeckung: Schale über dem Schädel (Doll: leather_cap 0,05 k, helmet 0,07 k mit Nasal und Rand)
    def kalotte(name, off, edge_y, tilt, m, thick):
        bm = bmesh.new(); bm.from_mesh(hv)
        kill = [f for f in bm.faces if not all(inv(v.co)[1] > edge_y + tilt * inv(v.co)[2] for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.normal_update()
        for v in bm.verts: v.co = v.co + v.normal * off * k
        me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
        for a in list(me.attributes):
            if a.name in ('ink', 'narbe'): me.attributes.remove(a)
        o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        for p in me.polygons: p.use_smooth = True
        so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick * k; so.offset = -1
        bpy.context.view_layer.objects.active = o; bpy.ops.object.modifier_apply(modifier='so')
        return o
    if K['kopf'] == 'kappe':
        kalotte('helm_kappe', 0.035, 0.1, 0.35, M['leder'], 0.03)
    elif K['kopf'] == 'helm':
        kalotte('helm', 0.05, 0.08, 0.3, M['rost'], 0.035)
        kalotte('helm_rand', 0.075, 0.08, 0.3, M['rostrand'], 0.03).data  # Rand: ein schmaler Ring
        rnd = bpy.data.objects['helm_rand']
        bm = bmesh.new(); bm.from_mesh(rnd.data)
        kill = [f for f in bm.faces if not all(inv(v.co)[1] < 0.08 + 0.3 * inv(v.co)[2] + 0.07 for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.to_mesh(rnd.data); bm.free()
        # Nasal
        bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts: v.co = D(v.co.x * 0.07, -0.02 + v.co.z * 0.24, 0.47 + v.co.y * 0.04)
        me = bpy.data.meshes.new('helm_nasal'); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new('helm_nasal', me); scn.collection.objects.link(o); me.materials.append(M['rostrand'])
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()

    # ---- 5. Lendentuch: Band um die Hüfte und zwei zerfranste Lappen vorn und hinten (Doll: „a rag round its loins“)
    bpy.context.view_layer.update()
    BV = np.array([body.matrix_world @ v.co for v in body.data.vertices])
    hipz = J['hipR'][0].z; pel = J['pelvis'][0]
    band = (BV[:, 2] > hipz - 0.10 * k * 0 - 9.0) & (BV[:, 2] < hipz + 6.0)
    near_trunk = np.minimum.reduce([seg_dist(BV, a, b) for a, b in (('pelvis', 'waist'), ('pelvis', 'hipR'), ('pelvis', 'hipL'), ('hipR', 'thighR'), ('hipL', 'thighL'))]) < 3.0
    mask = band & near_trunk
    bm = bmesh.new(); bm.from_mesh(body.data); bm.verts.ensure_lookup_table()
    kill = [f for f in bm.faces if not all(mask[v.index] for v in f.verts)]
    bmesh.ops.delete(bm, geom=kill, context='FACES')
    for v in bm.verts: v.co = v.co + v.normal * 0.8
    me = bpy.data.meshes.new('loin'); bm.to_mesh(me); bm.free()
    lo = bpy.data.objects.new('loin', me); scn.collection.objects.link(lo); me.materials.append(M['lappen'])
    lo.matrix_world = body.matrix_world.copy(); lo.parent = root; lo.matrix_parent_inverse = root.matrix_world.inverted()
    so = lo.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.5; so.offset = -1
    bpy.context.view_layer.objects.active = lo; bpy.ops.object.modifier_apply(modifier='so')
    for p in me.polygons: p.use_smooth = True
    for side, nm in ((-1, 'tabard'), (1, 'tabard.001')):     # rig.py: Stoff folgt den Oberschenkeln (CLOTH)
        # Lappen hängt vom Band bis knapp über die Knie, vorn (−Y) bzw. hinten (+Y), unten zerfranst
        yb = pel.y + side * (J['pelvis'][1][1] + 2.0)
        top = hipz + 4.0; bot = J['kneeR'][0].z + (J['hipR'][0].z - J['kneeR'][0].z) * (0.45 if side < 0 else 0.35)
        n_u, n_v = 6, 8; V_ = []; F_ = []
        for i in range(n_u + 1):
            for jj in range(n_v + 1):
                u = i / n_u * 2 - 1; t = jj / n_v
                hw = (7.5 if side < 0 else 9.0) * (1 - 0.25 * t)
                rag = (2.5 * (0.5 + 0.5 * math.sin(u * 9.0 + side))) * (t ** 6)
                z = top - (top - bot) * t + rag
                y = yb + side * (1.5 * t + 1.2 * (1 - u * u) * t)
                V_.append(Vector((u * hw, y, z)))
        for i in range(n_u):
            for jj in range(n_v):
                a = i * (n_v + 1) + jj; F_.append((a, a + n_v + 1, a + n_v + 2, a + 1))
        fl = mesh_from(nm, V_, F_, M['lappen'])
        so = fl.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.4; so.offset = 0
        bpy.context.view_layer.objects.active = fl; bpy.ops.object.modifier_apply(modifier='so')

    # ---- 6. Fell über den Schultern (Dress.furMantle): Schale über Brust und Rücken bis 0,42 des Rumpfs, unten zerfranst
    if K['fell']:
        src = bpy.data.objects['chain'] if 'chain' in bpy.data.objects else body
        SV = np.array([src.matrix_world @ v.co for v in src.data.vertices])
        shz = J['shR'][0].z; trunk = shz - hipz
        ang = np.arctan2(SV[:, 0], SV[:, 1])
        edge = shz - 0.42 * trunk + 2.0 * np.sin(ang * 7.0) + 1.5 * np.sin(ang * 13.0 + 1.0)
        armd = np.minimum.reduce([seg_dist(SV, 'el' + s, 'fo' + s) for s in 'RL'])
        m2 = (SV[:, 2] > edge) & (armd > 2.0) & (SV[:, 2] < J['neckTop'][0].z - 2.0)
        bm = bmesh.new(); bm.from_mesh(src.data); bm.verts.ensure_lookup_table()
        kill = [f for f in bm.faces if not all(m2[v.index] for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.normal_update()
        for v in bm.verts:
            v.co = v.co + v.normal * (1.6 + 0.8 * noise.noise(v.co * 0.4))
        me = bpy.data.meshes.new('fell'); bm.to_mesh(me); bm.free()
        fo = bpy.data.objects.new('fell', me); scn.collection.objects.link(fo); me.materials.append(M['fell'])
        fo.matrix_world = src.matrix_world.copy(); fo.parent = root; fo.matrix_parent_inverse = root.matrix_world.inverted()
        so = fo.modifiers.new('so', 'SOLIDIFY'); so.thickness = 1.2; so.offset = -1
        bpy.context.view_layer.objects.active = fo; bpy.ops.object.modifier_apply(modifier='so')
        for p in me.polygons: p.use_smooth = True

    # ---- 7. Auf Goblingröße (Zentimeter wie held3; rig.py macht Meter daraus)
    bpy.context.view_layer.update()
    S_ = Matrix.Scale(F, 4)
    for o in [o for o in bpy.data.objects if o.parent is None]: o.matrix_world = S_ @ o.matrix_world
    J = {kk: [v[0] * F, [v[1][0] * F, v[1][1] * F]] for kk, v in J.items()}
    bpy.context.view_layer.update()
    top = max(max((o.matrix_world @ v.co).z for v in o.data.vertices) for o in meshes() if not o.name.startswith('ear'))
    json.dump({'J': {kk: [list(v[0]), list(v[1])] for kk, v in J.items()}, 'E': E}, open(T + '/gelenke.json', 'w'))
    # Griff für figur.gd (_hold): vom Unterarmgelenk bis zur Handmitte (held3: 3,6 cm hinter dem Handgelenk, Hände 1,3) und
    # die halbe Handdicke nach innen (Held 2,4 cm), in Metern
    grip = ((J['wrR'][0] - J['foR'][0]).length + 3.6 * 1.3 * F) / 100.0
    json.dump({'groesse_cm': round(top, 1), 'kopf_cm': round(k * F, 1), 'schulter_cm': round(J['shR'][0].z, 1),
               'griff_m': round(grip, 4), 'handflaeche_m': round(2.4 * 1.3 * F / 100.0, 4)},
              open(T + '/goblin-masse.json', 'w'))
    bpy.ops.wm.save_as_mainfile(filepath=T + '/held3.blend')
    print('GOBLIN', kit, 'Groesse %.1f cm, Kopf %.1f cm, Schulter %.1f cm, Objekte %d' % (top, k * F, J['shR'][0].z, len(meshes())))


if __name__ == '__main__':
    nach() if '--nach' in sys.argv else treiber()
