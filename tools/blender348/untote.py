# 506 (Wochenziel 03.11. Reihe 2, Perikles 488; Spike): Untote im Kampf auf dem CC0-Menschen. ART=skeleton: das Skelett wie
# Doll.kt boneBody („bare bones on the same joints: a skull with its jaw, the spine, a cage of ribs bowed round from the spine to
# the breastbone, collarbones and shoulder blades, the pelvis, and the long bones of arms and legs with knobs at their ends. Bones
# are drawn somewhat thicker than real ones, so they read at a few pixels“) auf dem Gerüst der Universal Base Characters
# (Superhero_Male_FullBody, Quaternius, CC0 1.0, nur die Knochen; laedt v3/cc0_laden.sh); jedes Knochenteil starr an seinem Knochen.
# Bewegungen aus der Universal Animation Library [Standard] (CC0 1.0, gleiche 65 Knochen): Stehen Sword_Idle, Gehen Walk_Loop,
# Hieb Sword_Attack, Treffer Hit_Chest, Tod Death01. Kits wie MonsterKit.kt „skeleton“ (rostig): Kurzschwert und Helm, Kurzschwert
# und Rundschild, Speer und Helm; Waffen aus waffen.py (eigene .glb, figur.gd hängt sie an hand_r/hand_l). Augen glimmen
# (Eckfarbe Alpha 0 wie der Schamane, figur.gd glut). Farben wie Doll.kt Creature.SKELETON (0xB4A684 … 0x968866 je Kit).
# Aufruf: OUT=<ordner> CC0=<cc0-ordner> [KIT=helm|schild|speer] python -I untote.py
#         -> <OUT>/skeleton-<kit>.glb, <OUT>/skeleton-info.json (je Kit: groesse_cm, waffen, geruest cc0, griff_hand_m, handflaeche_m)
import bpy, os, sys, json, math
from mathutils import Vector, Matrix, Quaternion

OUT = os.environ.get('OUT', os.path.expanduser('~/untote'))
CC0 = os.environ.get('CC0', os.path.expanduser('~/cc0'))
ART = os.environ.get('ART', 'skeleton')
assert ART == 'skeleton', 'Zombie und Ghul erst nach 506a (Perikles)'
os.makedirs(OUT, exist_ok=True)
FPS = 24          # UAL-Szene: 24 Bilder je s
# MonsterKit.kt skeleton: (S shortsword, H helmet, rusty) · (S shortsword, O round_shield, rusty, crude) · (S spear, H helmet, rusty)
KITS = {
    'helm': dict(knochen=0xB4A684, waffen=['shortsword', ''], helm=True),
    'schild': dict(knochen=0xA49674, waffen=['shortsword', 'round_shield-grob'], helm=False),
    'speer': dict(knochen=0xBEB294, waffen=['spear-rost', ''], helm=True),
}
# Gang der Toten (FoeArt.kt DEAD_STEP_LIFT, Doll SKELETON: lean 0,7): Bewegungen etwas langsamer als die Quelle
TEMPO = {'Gehen': 0.85, 'Stehen': 0.9}
UAL_ZU = (('Sword_Idle', 'Stehen'), ('Walk_Loop', 'Gehen'), ('Sword_Attack', 'Hieb'), ('Hit_Chest', 'Treffer'), ('Death01', 'Tod'))
QUELLEN = []


def lin(h):
    c = [((h >> s) & 255) / 255.0 for s in (16, 8, 0)]
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)


def finde(name):
    for wo, _, fs in sorted(os.walk(CC0)):
        if name in fs: return os.path.join(wo, name)
    raise SystemExit('fehlt in CC0: ' + name)


def importiere(pfad):
    vorher = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=pfad)
    neu = [o for o in bpy.data.objects if o not in vorher]
    QUELLEN.append(os.path.relpath(pfad, CC0))
    return neu


def binde(o, a):     # wie grak_gestalt.py: Aktion mit ihrem Slot (Blender 5)
    o.animation_data.action = a
    if len(getattr(a, 'slots', [])):
        o.animation_data.action_slot = a.slots[0]


# ---------------------------------------------------------------- Knochenteile (Rest = T-Haltung, Blick nach −Y, Meter)
class Netz:
    def __init__(self): self.V = []; self.F = []; self.C = []; self.G = []     # Ecken, Flächen, Farbe je Ecke (RGBA), Knochen je Ecke

    def ball(self, c, r, knochen, farbe, n=8, m=6, oben=None):
        """Ellipsoid um c mit Halbachsen r (x, y, z); oben: Matrix der Achsen (Spalten) statt der Weltachsen"""
        A = oben or Matrix.Identity(3)
        i0 = len(self.V)
        for j in range(m + 1):
            th = math.pi * j / m
            for k in range(n):
                ph = 2 * math.pi * k / n
                lok = Vector((math.sin(th) * math.cos(ph) * r[0], math.sin(th) * math.sin(ph) * r[1], math.cos(th) * r[2]))
                p = c + A @ lok
                self.V.append(p); self.G.append(knochen)
                nz = (A @ Vector((lok.x / max(r[0], 1e-6), lok.y / max(r[1], 1e-6), lok.z / max(r[2], 1e-6)))).normalized()
                self.C.append(farbe(p, nz) if callable(farbe) else farbe)
        for j in range(m):
            for k in range(n):
                a = i0 + j * n + k; b = i0 + j * n + (k + 1) % n
                self.F.append((a, a + n, b + n, b) if j not in (0, m - 1) else ((a, a + n, b + n) if j == 0 else (a, a + n, b)))

    def rohr(self, a, b, ra, rb, knochen, farbe, n=7):
        """Kegelstumpf von a nach b, beide Enden zu"""
        ax = (b - a); L = ax.length; ax.normalize()
        q = ax.cross(Vector((0, 0, 1)) if abs(ax.z) < 0.9 else Vector((1, 0, 0))).normalized(); w = ax.cross(q)
        i0 = len(self.V)
        for e, (p, r) in enumerate(((a, ra), (b, rb))):
            for k in range(n):
                t = 2 * math.pi * k / n
                d = q * math.cos(t) + w * math.sin(t)
                self.V.append(p + d * r); self.G.append(knochen)
                self.C.append(farbe(p + d * r, d) if callable(farbe) else farbe)
        for k in range(n):
            self.F.append((i0 + k, i0 + (k + 1) % n, i0 + n + (k + 1) % n, i0 + n + k))
        self.F.append(tuple(i0 + k for k in reversed(range(n)))); self.F.append(tuple(i0 + n + k for k in range(n)))

    def knochen(self, a, b, r, knochen, farbe, knopf=1.6):
        """langer Knochen: Schaft etwas schlanker in der Mitte, an beiden Enden ein Gelenkknopf"""
        m = a.lerp(b, 0.5)
        self.rohr(a, m, r * 1.05, r * 0.85, knochen, farbe); self.rohr(m, b, r * 0.85, r * 1.0, knochen, farbe)
        self.ball(a, (r * knopf,) * 3, knochen, farbe, 7, 5); self.ball(b, (r * knopf * 0.9,) * 3, knochen, farbe, 7, 5)


def baue(kit):
    k = KITS[kit]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    teile = importiere(finde('Superhero_Male_FullBody.gltf'))
    ARM = next(o for o in teile if o.type == 'ARMATURE'); ARM.name = 'Skelett'
    for o in teile:
        if o.type == 'MESH': bpy.data.objects.remove(o)     # nur das Gerüst; der Körper sind die Knochen unten
    B = {b.name: (ARM.matrix_world @ b.head_local, ARM.matrix_world @ b.tail_local) for b in ARM.data.bones}
    H = lambda n: B[n][0].copy()
    T = lambda n: B[n][1].copy()
    hell = lin(k['knochen'])
    dunkel = tuple(x * 0.45 for x in hell)

    def bein(p, n):     # Licht von oben: Fugen und Unterseiten dunkler (Grundhelligkeit; Licht und Tusche macht Godot)
        t = 0.62 + 0.38 * max(0.0, n.z * 0.7 + 0.3)
        return tuple(x * t for x in hell) + (1.0,)
    N = Netz()
    b = 0.009 * 1.85 * 1.25          # Doll b = 0,009·h, für das Bild etwas dicker (Doll: „somewhat thicker than real ones“)
    # Schädel mit Kiefer, Augenhöhlen und glimmenden Augen (Kopfknochen „Head“)
    kopf = H('Head'); scheitel = kopf + Vector((0, 0, 0.21))
    sch = kopf + Vector((0, -0.015, 0.115))
    N.ball(sch, (0.078, 0.092, 0.095), 'Head', bein, 12, 9)
    N.ball(sch + Vector((0, -0.055, -0.07)), (0.06, 0.05, 0.045), 'Head', bein, 10, 6)                # Oberkiefer, Wangen
    N.ball(sch + Vector((0, -0.045, -0.115)), (0.05, 0.045, 0.028), 'Head', bein, 10, 5)              # Unterkiefer
    for s in (-1, 1):
        N.ball(sch + Vector((s * 0.032, -0.082, -0.005)), (0.022, 0.012, 0.02), 'Head', dunkel + (1.0,), 8, 5)   # Augenhöhle
        N.ball(sch + Vector((s * 0.032, -0.088, -0.005)), (0.008, 0.005, 0.008), 'Head', (0.9, 0.95, 0.55, 0.0), 6, 4)  # Glimmen
    N.ball(sch + Vector((0, -0.092, -0.045)), (0.01, 0.006, 0.014), 'Head', dunkel + (1.0,), 6, 4)        # Nasenloch
    for i in range(6):     # Zahnreihe als helle Knöpfe
        x = (i - 2.5) * 0.012
        N.ball(sch + Vector((x, -0.088, -0.092)), (0.006, 0.005, 0.008), 'Head', bein, 5, 3)
    # Wirbelsäule: eine Reihe Knöpfe vom Becken bis zum Schädel, je nach Höhe am passenden Knochen
    sp = ['pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01']
    unten, oben = H('spine_01'), H('Head')
    for i in range(14):
        t = i / 13
        p = unten.lerp(oben, t) + Vector((0, 0.035 * math.sin(t * math.pi) + 0.02, 0))
        kn = next(n for n in reversed(sp) if H(n).z <= p.z + 1e-6)
        N.ball(p, (b * 1.3, b * 1.15, b * 0.85), kn, bein, 7, 5)
    # Rippenkorb: je Rippe vom Rückgrat nach außen und vorn zum Brustbein, die unteren kürzer (Doll: 7 Paare)
    s3, s2 = H('spine_03'), H('spine_02')
    schulter_x = abs(H('upperarm_l').x)
    for j in range(7):
        t = j / 6
        z = H('upperarm_l').z - 0.05 - t * 0.24     # Doll: shoulderY − 0,1·Rumpf − t·0,42·Rumpf
        weit = schulter_x * 0.62 * (0.78 + 0.3 * math.sin((t * 0.8 + 0.15) * math.pi))
        vorn = 0.10 * (0.95 - 0.25 * t)
        kn = 'spine_03' if z > s2.z + 0.08 else 'spine_02'
        for s in (-1, 1):
            pts = [Vector((s * 0.02, 0.06, z + 0.02)), Vector((s * weit * 0.75, 0.055, z + 0.015)), Vector((s * weit, 0.0, z)),
                   Vector((s * weit * 0.8, -vorn * 0.7, z - 0.03)), Vector((s * weit * 0.3 * (1 - t * 0.5), -vorn, z - 0.045))]
            for q in range(4):
                N.rohr(pts[q], pts[q + 1], b * 0.7, b * 0.65, kn, bein, 6)
    N.rohr(Vector((0, -0.10, H('upperarm_l').z - 0.06)), Vector((0, -0.085, H('upperarm_l').z - 0.27)), b * 1.0, b * 0.8, 'spine_03', bein, 6)   # Brustbein
    # Schlüsselbeine und Schulterblätter
    for s, sd in (('l', 1), ('r', -1)):
        N.rohr(H('clavicle_' + s) + Vector((0, -0.05, 0)), H('upperarm_' + s) + Vector((-sd * 0.01, -0.02, 0.025)), b * 0.8, b * 0.8, 'clavicle_' + s, bein, 6)
        N.ball(H('upperarm_' + s).lerp(s3, 0.45) + Vector((0, 0.075, -0.06)), (0.055, 0.012, 0.07), 'clavicle_' + s, bein, 8, 5)
    # Becken: zwei Schaufeln und der Ring vorn
    pv = H('pelvis')
    for sd in (-1, 1):
        N.ball(pv + Vector((sd * 0.09, 0.01, 0.03)), (0.07, 0.035, 0.065), 'pelvis', bein, 9, 6)
        N.rohr(pv + Vector((sd * 0.11, -0.01, -0.03)), pv + Vector((sd * 0.03, -0.06, -0.06)), b * 1.0, b * 0.9, 'pelvis', bein, 6)
    N.ball(pv + Vector((0, 0.05, 0.0)), (0.035, 0.03, 0.05), 'pelvis', bein, 8, 5)     # Kreuzbein
    # Arme: Oberarm, Unterarm aus Elle und Speiche, Hand mit Fingergliedern
    for s, sd in (('l', 1), ('r', -1)):
        N.knochen(H('upperarm_' + s), T('upperarm_' + s), b * 1.15, 'upperarm_' + s, bein)
        a, e = H('lowerarm_' + s), T('lowerarm_' + s)
        for dy in (-0.012, 0.012):
            N.rohr(a + Vector((0, dy, 0)), e + Vector((0, dy * 0.8, 0)), b * 0.75, b * 0.65, 'lowerarm_' + s, bein, 6)
        N.ball(a, (b * 1.5,) * 3, 'lowerarm_' + s, bein, 7, 5)
        N.ball(H('hand_' + s).lerp(T('hand_' + s), 0.5) + Vector((sd * 0.01, 0.02, 0)), (0.035, 0.035, 0.012), 'hand_' + s, bein, 8, 5)
        for f in ('index', 'middle', 'ring', 'pinky', 'thumb'):
            for g in ('01', '02', '03'):
                n_ = '%s_%s_%s' % (f, g, s)
                N.rohr(H(n_), T(n_), b * 0.45, b * 0.4, n_, bein, 5)
    # Beine: Oberschenkel, Schienbein und Wadenbein, Kniescheibe, Fuß und Zehen
    for s in ('l', 'r'):
        N.knochen(H('thigh_' + s), T('thigh_' + s), b * 1.35, 'thigh_' + s, bein)
        N.ball(T('thigh_' + s) + Vector((0, -0.04, 0)), (0.028, 0.015, 0.03), 'calf_' + s, bein, 7, 5)    # Kniescheibe
        a, e = H('calf_' + s), T('calf_' + s)
        N.rohr(a + Vector((0, -0.01, 0)), e, b * 1.05, b * 0.85, 'calf_' + s, bein, 7)
        N.rohr(a + Vector((0.02, 0.015, -0.02)), e + Vector((0.015, 0.01, 0.02)), b * 0.55, b * 0.5, 'calf_' + s, bein, 5)
        N.ball(e, (b * 1.7, b * 1.5, b * 1.4), 'foot_' + s, bein, 7, 5)                                     # Knöchel
        N.ball(H('foot_' + s).lerp(T('foot_' + s), 0.55) + Vector((0, 0, 0.01)), (0.04, 0.07, 0.022), 'foot_' + s, bein, 8, 5)
        for dx in (-0.03, -0.012, 0.006, 0.022):
            N.rohr(H('ball_' + s) + Vector((dx, 0, 0)), T('ball_' + s) + Vector((dx * 1.1, 0.01, -0.003)), b * 0.45, b * 0.35, 'ball_' + s, bein, 5)
    # Helm (MonsterKit H helmet, rostig): Kappe mit Rand, starr am Kopf
    if k['helm']:
        rost = lambda p, n: tuple(x * (0.6 + 0.4 * max(0.0, n.z)) for x in lin(0x6A4A32)) + (1.0,)
        N.ball(sch + Vector((0, 0.0, 0.03)), (0.092, 0.104, 0.085), 'Head', rost, 12, 8)
        N.rohr(sch + Vector((0, 0, -0.005)), sch + Vector((0, 0, 0.005)), 0.11, 0.11, 'Head', rost, 14)
    # ---- Netz mit Gruppen, starr je Knochen
    me = bpy.data.meshes.new('Knochen')
    me.from_pydata([tuple(v) for v in N.V], [], N.F)
    me.update()
    ob = bpy.data.objects.new('Knochen', me); bpy.context.scene.collection.objects.link(ob)
    ca = me.color_attributes.new('Col', 'FLOAT_COLOR', 'POINT')
    for i, c in enumerate(N.C): ca.data[i].color = c
    me.color_attributes.active_color = ca
    for p in me.polygons: p.use_smooth = True
    for i, g in enumerate(N.G):
        (ob.vertex_groups.get(g) or ob.vertex_groups.new(name=g)).add([i], 1.0, 'REPLACE')
    mat = bpy.data.materials.new('knochen')
    me.materials.append(mat)
    ob.parent = ARM
    mod = ob.modifiers.new('Armature', 'ARMATURE'); mod.object = ARM
    print('KNOCHEN %s: %d Ecken, %d Flächen, %d Knochen' % (kit, len(N.V), len(N.F), len(set(N.G))))
    # ---- Bewegungen aus der UAL (gleiche Knochen; Übertragung über die Ruhelagen wie grak_gestalt.py uebertrage)
    ual = importiere(finde('UAL1_Standard.glb'))
    UA = next(o for o in ual if o.type == 'ARMATURE')
    for o in ual:
        if o.type == 'MESH': bpy.data.objects.remove(o)
    reihen = [x.name for x in ARM.data.bones]
    eltern = {x.name: (x.parent.name if x.parent else None) for x in ARM.data.bones}
    r_uns = {x.name: x.matrix_local.to_quaternion() for x in ARM.data.bones}
    r_ual = {x.name: x.matrix_local.to_quaternion() for x in UA.data.bones}
    becken_ual = UA.data.bones['pelvis'].head_local.copy()
    mass = ARM.data.bones['pelvis'].head_local.z / becken_ual.z
    ARM.animation_data_create(); UA.animation_data_create()
    for pb in ARM.pose.bones: pb.rotation_mode = 'QUATERNION'
    sc = bpy.context.scene
    print('BILDER je s', sc.render.fps)
    neu = {}
    for q_name, z_name in UAL_ZU:
        q = bpy.data.actions.get(q_name) or bpy.data.actions.get(q_name + '_Loop')
        assert q, 'UAL: %s fehlt (%s)' % (q_name, [a.name for a in bpy.data.actions][:60])
        binde(UA, q)
        a0, a1 = [int(round(v)) for v in q.frame_range]
        z = bpy.data.actions.new(z_name); z.use_fake_user = True; ARM.animation_data.action = z
        tempo = TEMPO.get(z_name, 1.0)
        n_bilder = int(round((a1 - a0) / tempo))
        for f in range(n_bilder + 1):
            sc.frame_set(a0 + int(round(f * tempo)))
            D = {}
            for x in reihen:
                pu = UA.pose.bones.get(x)
                D[x] = (pu.matrix.to_quaternion() @ r_ual[x].inverted()) if pu else Quaternion()
            for x in reihen:
                pb = ARM.pose.bones[x]
                dp = D[eltern[x]] if eltern[x] else Quaternion()
                pb.rotation_quaternion = r_uns[x].inverted() @ (dp.inverted() @ D[x]) @ r_uns[x]
                pb.keyframe_insert('rotation_quaternion', frame=f)
                if x == 'pelvis':
                    d_ = UA.pose.bones['pelvis'].matrix.translation - becken_ual
                    if z_name in ('Stehen', 'Gehen', 'Hieb', 'Treffer'):
                        d_ = Vector((0, 0, d_.z))     # auf der Stelle (figur.gd schiebt die Figur); der Tod fällt wie die Quelle
                    pb.location = r_uns[x].inverted() @ (d_ * mass)
                    pb.keyframe_insert('location', frame=f)
        neu[z_name] = n_bilder
        print('BEWEGUNG %s aus %s: %d Bilder' % (z_name, q.name, n_bilder + 1))
    for o in [o for o in bpy.data.objects if o.name != ARM.name and o.name != ob.name]: bpy.data.objects.remove(o)
    for a_ in list(bpy.data.actions):
        if a_.name not in neu: bpy.data.actions.remove(a_)
    binde(ARM, bpy.data.actions['Stehen'])
    sc.frame_set(0); bpy.context.view_layer.update()
    for o in [o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith('Icosphere')]:
        bpy.data.objects.remove(o)
    hoehe = max(v.z for v in N.V)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, 'skeleton-%s.glb' % kit), export_format='GLB', export_animations=True,
                              export_animation_mode='ACTIONS', export_skins=True, export_apply=False, export_yup=True,
                              export_vertex_color='ACTIVE', export_all_vertex_colors=False)
    # Hand: Ursprung des Knochens am Handgelenk, Griff in der Mitte der Faust (wie goblin.py GERUEST=cc0 griff_hand_m)
    hand = (H('hand_r') - H('middle_01_r')).length
    return dict(groesse_cm=round(hoehe * 100), koerper_cm=round(hoehe * 100), waffen=k['waffen'], geruest='cc0',
                griff_hand_m=round(hand * 0.75, 3), handflaeche_m=0.03, bewegungen=sorted(neu), fps=FPS)


info = {}
for kit in ([os.environ['KIT']] if os.environ.get('KIT') else list(KITS)):
    info[kit] = baue(kit)
info['quellen'] = sorted(set(QUELLEN)); info['lizenz'] = 'Quaternius, CC0 1.0 (License_Standard.txt je Paket)'
json.dump(info, open(os.path.join(OUT, 'skeleton-info.json'), 'w'), indent=1, ensure_ascii=False)
print('FERTIG', json.dumps({k_: v for k_, v in info.items() if k_ in KITS}, ensure_ascii=False))
