# 348.6 Held und Leute auf dem CC0-Geruest (Chef 25.10., 23:33, 348.12; Modellregel 4, 5): Knochen, Namen und Bewegungen aus der
# Universal Animation Library (Quaternius, CC0 1.0, Lizenzdatei im Paket; laedt cc0_laden.sh), die Knochen an unsere Gelenke
# (held3.py, gelenke.json), Netz und Gewichte aus rig.py auf die neuen Namen. Koerper und Kleidung bleiben unsere.
# Gliedmassen folgen der Richtung der fremden Knochen (unsere Arme haengen in Ruhe, die fremden stehen waagerecht ab); Rumpf,
# Hals und Kopf nur deren Drehung gegen die Ruhelage (wer gebeugt gebaut ist, bleibt gebeugt). Ruft rig.py mit GERUEST=cc0.
import bpy, os, glob, math, json
import numpy as np
from mathutils import Vector, Matrix

FPS = 30
QUELLE = 'Quaternius, Universal Animation Library [Standard] (UAL1_Standard.glb), CC0 1.0'
# unser Name <- fremde Bewegung; gerade: in Ruhe eingedreht (Becken und Brust 13 Grad) zum Betrachter zurueck; fackel: linker Arm
# aus der Fackel-Ruhe (relativ zur Brust); kopf: Neigung des Kopfes (Grad, + hebt; fremd ueberall 13-22 Grad gesenkt, Jerry 25.10.)
HELD = [('Stehen', 'Idle_Loop', dict(gerade=True)), ('Gehen', 'Walk_Loop', {}), ('Rennen', 'Jog_Fwd_Loop', {}),
        ('Stehen_Fackel', 'Idle_Torch_Loop', dict(gerade=True)), ('Gehen_Fackel', 'Walk_Loop', dict(fackel=True)),
        ('Rennen_Fackel', 'Jog_Fwd_Loop', dict(fackel=True))]
LEUTE = [('Stehen', 'Idle_Loop', dict(gerade=True)), ('Gehen', 'Walk_Loop', {})]
KOPF = -3.0          # Grad: Blick leicht unter die Waagerechte
FACKEL = 'Idle_Torch_Loop'


def ual_datei():
    d = os.environ.get('CC0', os.path.expanduser('~/cc0'))
    f = sorted(glob.glob(os.path.join(d, '**', 'UAL1_Standard.glb'), recursive=True))
    f = [x for x in f if 'Unreal-Godot' in x] or f
    if not f: raise SystemExit('UAL1_Standard.glb fehlt unter %s (tools/blender348/v3/cc0_laden.sh)' % d)
    return f[0]


def gruppen():
    """unsere Gewichtsgruppen (rig.py: <Gelenk>-<Gelenk>, Haende HANDR/HANDL) -> fremde Knochen"""
    m = {'pelvis-waist': 'pelvis', 'waist-belly': 'spine_01', 'belly-chest': 'spine_02', 'chest-chestTop': 'spine_03',
         'chestTop-neck': 'neck_01', 'neck-neckTop': 'Head', 'root': 'pelvis'}
    for s in 'RL':
        x = '_' + s.lower()
        m.update({'chestTop-sh' + s: 'clavicle' + x, 'sh%s-up%s' % (s, s): 'upperarm' + x, 'up%s-el%s' % (s, s): 'upperarm' + x,
                  'el%s-fo%s' % (s, s): 'lowerarm' + x, 'fo%s-wr%s' % (s, s): 'lowerarm' + x, 'HAND' + s: 'hand' + x,
                  'pelvis-hip' + s: 'pelvis', 'hip%s-thigh%s' % (s, s): 'thigh' + x, 'thigh%s-knee%s' % (s, s): 'thigh' + x,
                  'knee%s-calf%s' % (s, s): 'calf' + x, 'calf%s-ankle%s' % (s, s): 'calf' + x,
                  'ankle%s-heel%s' % (s, s): 'foot' + x, 'ankle%s-ball%s' % (s, s): 'foot' + x, 'ball%s-toe%s' % (s, s): 'ball' + x})
    return m


def lage(J):
    """Kopf und Ende der fremden Knochen an unseren Gelenken (m); nicht genannte (Finger, Wurzel) gehen starr mit dem Elternknochen"""
    P = lambda n: J[n][0] / 100.0
    hm = (P('hipR') + P('hipL')) / 2
    L = {'pelvis': (Vector((0, P('pelvis').y, hm.z)), P('waist')), 'spine_01': (P('waist'), P('belly')),
         'spine_02': (P('belly'), P('chest')), 'spine_03': (P('chest'), P('chestTop')), 'neck_01': (P('chestTop'), P('neck')),
         'Head': (P('neck'), P('neckTop') + Vector((0, 0, 0.08)))}
    for s in 'RL':
        x = '_' + s.lower(); g = 1 if s == 'L' else -1          # links ist x > 0
        L['clavicle' + x] = (P('chestTop') + Vector((g * 0.02, 0, 0)), P('sh' + s))
        L['upperarm' + x] = (P('sh' + s), P('el' + s))
        L['lowerarm' + x] = (P('el' + s), P('wr' + s))
        L['hand' + x] = (P('wr' + s), P('wr' + s) + (P('wr' + s) - P('fo' + s)).normalized() * 0.06)
        L['thigh' + x] = (P('hip' + s), P('knee' + s))
        L['calf' + x] = (P('knee' + s), P('ankle' + s))
        L['foot' + x] = (P('ankle' + s), P('ball' + s))
        L['ball' + x] = (P('ball' + s), P('toe' + s))
    return L


RUMPF = ('pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head')
GLIED = tuple(b + x for b in ('clavicle', 'upperarm', 'lowerarm', 'hand', 'thigh', 'calf', 'foot', 'ball') for x in ('_l', '_r'))


def aufs_cc0(held, alt, J, FIGUR, LP, OUT):
    """held: Netz (cm) mit Gewichten auf alt (unser Skelett, cm). Baut das fremde Skelett an J, backt die Bewegungen, schreibt
    held.glb (m) und held-info.json."""
    scn = bpy.context.scene
    scn.render.fps = FPS; scn.frame_start = 0
    # ---------------------------------------------------------------- Netz in Metern, Gruppen auf die fremden Namen
    mw = held.matrix_world.copy(); held.parent = None; held.matrix_world = Matrix.Scale(0.01, 4) @ mw
    for m in list(held.modifiers):
        if m.type == 'ARMATURE': held.modifiers.remove(m)
    bpy.ops.object.select_all(action='DESELECT'); held.select_set(True); bpy.context.view_layer.objects.active = held
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    G = gruppen(); me = held.data
    alt_name = {g.index: g.name for g in held.vertex_groups}
    W = {}
    for v in me.vertices:
        for e in v.groups:
            n = G.get(alt_name[e.group])
            if n is None or e.weight <= 0: continue
            W.setdefault(n, {}); W[n][v.index] = W[n].get(v.index, 0.0) + e.weight
    fremd = [n for n in alt_name.values() if n not in G and n != 'fest']
    if fremd: print('GRUPPEN OHNE ZIEL', fremd)
    for g in list(held.vertex_groups): held.vertex_groups.remove(g)
    for n, d in W.items():
        g = held.vertex_groups.new(name=n)
        for i, w in d.items(): g.add([i], min(1.0, w), 'REPLACE')
    # ---------------------------------------------------------------- fremdes Skelett laden
    vor = set(bpy.data.objects); vor_a = set(bpy.data.actions)
    bpy.ops.import_scene.gltf(filepath=ual_datei())
    neu = [o for o in bpy.data.objects if o not in vor]
    ual = next(o for o in neu if o.type == 'ARMATURE')
    for o in neu:
        if o is not ual: bpy.data.objects.remove(o, do_unlink=True)
    uad = ual.animation_data_create()
    for t in list(uad.nla_tracks): uad.nla_tracks.remove(t)
    UB = ual.data.bones; UP = ual.pose.bones
    REIHE = []
    def rein(b):
        REIHE.append(b.name)
        for c in b.children: rein(c)
    for b in UB:
        if b.parent is None: rein(b)
    RU = {n: UB[n].matrix_local.copy() for n in REIHE}
    # ---------------------------------------------------------------- unser Skelett mit den fremden Namen an unseren Gelenken
    L = lage(J)
    k = L['Head'][0].z / RU['Head'].translation.z           # Finger und Blaetter starr mit, im Groessenverhaeltnis
    alt.name = 'Altes_Skelett'                               # der Name gehoert dem neuen (pruefblatt.py, blatt.py)
    arm = bpy.data.armatures.new('Skelett'); sk = bpy.data.objects.new('Held_Skelett', arm); scn.collection.objects.link(sk)
    bpy.context.view_layer.objects.active = sk; bpy.ops.object.mode_set(mode='EDIT')
    RN = {}
    for n in REIHE:
        b = UB[n]
        if n in L:
            h, t = L[n]; Ru = RU[n].to_3x3()
            q = Ru.col[1].rotation_difference((t - h).normalized())
            RN[n] = (Matrix.Translation(h) @ (q.to_matrix() @ Ru).to_4x4(), (t - h).length)
        else:
            p = b.parent.name if b.parent else None
            rel = RU[p].inverted() @ RU[n] if p else RU[n].copy()
            rel.translation = rel.translation * k
            RN[n] = (RN[p][0] @ rel if p else rel, b.length * k)
        eb = arm.edit_bones.new(n); eb.head = (0, 0, 0); eb.tail = (0, 1, 0)
        eb.matrix = RN[n][0]; eb.length = RN[n][1]
        if b.parent: eb.parent = arm.edit_bones[b.parent.name]
        eb.use_connect = False
    bpy.ops.object.mode_set(mode='OBJECT')
    RM = {n: arm.bones[n].matrix_local.copy() for n in REIHE}
    PAR = {n: (UB[n].parent.name if UB[n].parent else None) for n in REIHE}
    held.parent = sk
    md = held.modifiers.new('skelett', 'ARMATURE'); md.object = sk
    # Sohlenpunkte (rig.py ground): Ferse, Ballen am Fuss, Zehe am Ballen; Hoehe minus Gelenkradius
    SOHLE = [(s, kn, J[j + S][0] / 100.0, J[j + S][1] / 100.0, j) for S, s in (('R', 'r'), ('L', 'l'))
             for j, kn in (('heel', 'foot_'), ('ball', 'foot_'), ('toe', 'ball_'))]
    kbein = L['thigh_l'][0].z / RU['thigh_l'].translation.z
    # Blickrichtung des Kopfes in unserer Ruhelage (der Held blickt nach -Y)
    vorn_kopf = RM['Head'].to_3x3().inverted() @ Vector((0, -1, 0))
    kn, kd = ((LP.get('kopfhaltung') or [0, 0, 0]) + [0, 0])[:2]   # 348.6 Leute: Kopf je Figur etwas anders (nicken + senkt, drehen)

    def setze(act):
        uad.action = act
        if hasattr(uad, 'action_slot') and act.slots: uad.action_slot = act.slots[0]

    def lies(act):
        """Posen der fremden Bewegung je Bild (Armatur-Raum, m), Bild 0..n (n = Ende, Schleife: n wie 0)"""
        setze(act); r0, r1 = act.frame_range; n = int(round(r1 - r0))
        out = []
        for f in range(n + 1):
            scn.frame_set(int(r0) + f)
            out.append({b: UP[b].matrix.copy() for b in REIHE} | {'_basis': {b: UP[b].matrix_basis.copy() for b in REIHE}})
        return out

    def gier(Gf, b):
        v = Gf[b].to_3x3() @ (RU[b].to_3x3().inverted() @ Vector((0, -1, 0)))
        return math.degrees(math.atan2(v.x, -v.y))

    def posen(Gs, gerade=False, fackel=None, korr=None, boden=0.0):
        """Posen unseres Skeletts je Bild: (Ruhe->Pose je Knochen als Basis, Armatur-Matrizen)"""
        W = Matrix.Identity(4)
        if gerade:   # in Ruhe eingedreht: Becken und Brust um 70 % zurueck zum Betrachter
            W = Matrix.Rotation(math.radians(-0.7 * float(np.mean([gier(Gf, 'spine_03') for Gf in Gs]))), 4, 'Z')
        res = []
        for f, Gf in enumerate(Gs):
            Go = {b: W @ Gf[b] for b in REIHE}; Bq = Gf['_basis']
            if fackel:   # linker Arm samt Fingern wie in der Fackel-Ruhe, relativ zur Brust
                Tf = fackel[f % (len(fackel) - 1)]
                rel = Go['spine_03'] @ (W @ Tf['spine_03']).inverted()
                for b in REIHE:
                    if b.endswith('_l') and not b.startswith(('thigh', 'calf', 'foot', 'ball')): Go[b] = rel @ W @ Tf[b]
                Bq = {b: (Tf['_basis'][b] if b.endswith('_l') else Bq[b]) for b in REIHE}
            PN, BA = {}, {}
            for b in REIHE:
                p = PAR[b]
                kette = PN[p] @ RM[p].inverted() @ RM[b] if p else RM[b].copy()
                if b in GLIED: rot = Go[b].to_3x3()
                elif b in RUMPF: rot = Go[b].to_3x3() @ RU[b].to_3x3().inverted() @ RM[b].to_3x3()
                else: rot = kette.to_3x3() @ Bq[b].to_3x3()
                if korr and b in korr: rot = korr[b] @ rot
                kopf = kette.translation.copy()
                if b == 'pelvis':
                    ru = Go['root'] @ RU['root'].inverted() @ RU['pelvis']
                    kopf = kopf + (Go['pelvis'].translation - ru.translation) * kbein + Vector((0, 0, boden))
                soll = Matrix.Translation(kopf) @ rot.to_4x4()
                BA[b] = kette.inverted() @ soll; PN[b] = soll
            res.append((BA, PN))
        return res

    def sohle(PN):
        pts = [(s, PN[kn + s] @ RM[kn + s].inverted() @ p, r) for s, kn, p, r, j in SOHLE]
        return min(((s, q.z - r, q) for s, q, r in pts), key=lambda x: x[1])

    def ballen(PN):   # je Fuss der Ballen (traegt im Gehen und Rennen am laengsten): (Hoehe der Sohle, Punkt)
        return {s: (q.z - r, q) for s, kn, p, r, j in SOHLE if j == 'ball' for q in [PN[kn + s] @ RM[kn + s].inverted() @ p]}

    def kopf_korr(res):
        """Kopf (und zu 40 % der Hals) auf KOPF Grad Neigung und die Drehung der Figur (leute.json kopfhaltung)"""
        ni, dr = [], []
        for BA, PN in res:
            v = PN['Head'].to_3x3() @ vorn_kopf
            ni.append(math.degrees(math.atan2(v.z, math.hypot(v.x, v.y)))); dr.append(math.degrees(math.atan2(v.x, -v.y)))
        dn = KOPF - 0.7 * kn - float(np.mean(ni)); dd = kd - float(np.mean(dr))
        def R(a):
            return Matrix.Rotation(math.radians(a * dd), 3, 'Z') @ Matrix.Rotation(math.radians(-a * dn), 3, 'X')
        return {'neck_01': R(0.4), 'Head': R(1.0)}, round(dn, 1), round(dd, 1)

    ad = sk.animation_data_create()
    INFO = {}
    tor = lies(bpy.data.actions[FACKEL]) if FIGUR == 'held' else None
    for name, quelle, opt in (HELD if FIGUR == 'held' else LEUTE):
        Gs = lies(bpy.data.actions[quelle])
        fk = tor if opt.get('fackel') else None
        res = posen(Gs, opt.get('gerade', False), fk)
        korr, dn, dd = kopf_korr(res)
        res = posen(Gs, opt.get('gerade', False), fk, korr)
        boden = -float(np.percentile([sohle(PN)[1] for BA, PN in res], 10))   # Standfuss auf den Boden (unsere Beine sind kuerzer; Rennen: ohne Flugbilder)
        res = posen(Gs, opt.get('gerade', False), fk, korr, boden)
        tief = [sohle(PN) for BA, PN in res]
        # Fussgleiten: wie schnell wandert der Ballen des Standfusses (am Boden, hoechstens 1,5 cm) nach hinten
        bl = [ballen(PN) for BA, PN in res]
        v = [abs(b[s][1].y - a[s][1].y) * FPS for a, b in zip(bl, bl[1:]) for s in 'lr' if a[s][0] < 0.015 and b[s][0] < 0.015]
        if os.environ.get('SPUR'): print('SPUR', name, [(round(b['l'][0] * 100, 1), round(b['l'][1].y * 100, 1)) for b in bl])
        act = bpy.data.actions.new(name); act.use_fake_user = True
        ad.action = act; ad.use_nla = False
        for pb in sk.pose.bones: pb.rotation_mode = 'QUATERNION'
        for f, (BA, PN) in enumerate(res):
            for b in REIHE:
                pb = sk.pose.bones[b]
                pb.rotation_quaternion = BA[b].to_quaternion(); pb.location = BA[b].translation
                pb.keyframe_insert('rotation_quaternion', frame=f); pb.keyframe_insert('location', frame=f)
        tr = ad.nla_tracks.new(); tr.name = name; tr.strips.new(name, 0, act)
        ad.action = None; ad.use_nla = True
        INFO.setdefault('bewegungen', {})[name] = {'quelle': quelle, 'bilder': len(res) - 1, 'kopf_grad': [dn, dd],
                                                   'boden_cm': [round(min(t[1] for t in tief) * 100, 1), round(max(t[1] for t in tief) * 100, 1)]}
        if name in ('Gehen', 'Rennen') and v: INFO[('gehen' if name == 'Gehen' else 'rennen') + '_m_je_s'] = round(float(np.median(v)), 3)
        print('BEWEGUNG', name, INFO['bewegungen'][name], len(v))
    for pb in sk.pose.bones: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
    # ---------------------------------------------------------------- Griffe im Handknochen (m): Fackel links (held.gd), Ding rechts (leute.gd)
    def im_knochen(alt_bone, p_cm, neu_bone):
        Ma = alt.data.bones[alt_bone].matrix_local
        q = Ma @ Vector(p_cm)                               # cm, Armatur unseres alten Skeletts (am Ursprung, ungedreht)
        return list(RM[neu_bone].inverted() @ (q / 100.0)), RM[neu_bone].to_3x3().inverted() @ Ma.to_3x3()
    g, R = im_knochen('foL-wrL', (-1.87, 18.7, 0.72), 'hand_l')     # held.gd FAUST_GRIFF (Runde 5c, in Godot nachgemessen)
    INFO['faust_L'] = {'knochen': 'hand_l', 'griff': [round(x, 4) for x in g], 'achse': [round(x, 4) for x in (R @ Vector((-0.358, 0.0, -0.934)))]}
    if LP.get('traegt'):
        wr, fo = J['wrR'][0], J['foR'][0]
        g, R = im_knochen('foR-wrR', (0.0, (wr - fo).length + 4.6, 0.0), 'hand_r')
        INFO['traegt'] = LP['traegt']; INFO['knochen_R'] = 'hand_r'; INFO['griff_R'] = [round(x, 4) for x in g]
    INFO['fps'] = FPS; INFO['ecken'] = len(held.data.vertices); INFO['geruest'] = 'cc0'; INFO['quelle'] = QUELLE
    INFO['dreiecke'] = sum(len(p.vertices) - 2 for p in held.data.polygons)
    json.dump(INFO, open(OUT + '/held-info.json', 'w'), indent=1, ensure_ascii=False)
    print('ANIM', json.dumps(INFO, ensure_ascii=False))
    # ---------------------------------------------------------------- Ausgabe in Metern (Modellregel 1)
    bpy.data.objects.remove(ual, do_unlink=True)
    if alt.name in bpy.data.objects: bpy.data.objects.remove(alt, do_unlink=True)
    bpy.ops.object.select_all(action='DESELECT'); sk.select_set(True); held.select_set(True)
    bpy.ops.export_scene.gltf(filepath=OUT + '/held.glb', export_format='GLB', use_selection=True, export_animations=True,
                              export_skins=True, export_vertex_color='ACTIVE', export_animation_mode='NLA_TRACKS',
                              export_yup=True, export_apply=False)
    bpy.ops.wm.save_as_mainfile(filepath=OUT + '/held3-rig.blend')
    print('GLB OK', os.path.getsize(OUT + '/held.glb'))
