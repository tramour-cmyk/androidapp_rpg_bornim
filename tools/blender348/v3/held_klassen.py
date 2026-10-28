# 376.1 (Chef 28.10., 22:0x: „die vier spielbaren Klassen mal auf das gute Modell mit dem guten Kopf … in der [Charaktererstellung]
# doch auch Einfluss nehmen … die jeweiligen Klassen ihre Standard-Grundausruestung kriegen, sichtbar“): der Held je Klasse auf dem
# gekauften Koerper mit gekauftem Kopf (Quaternius Universal Base Characters, Regular), ohne Bewegungen (Godot nimmt die der UAL).
#   FIGHTER: unsere Tracht (Kettenhemd, Wappenrock, Umhang; kauf_kleid.py, Chef 27.10., 18:06 „passt“)
#   WIZARD, ROGUE, CLERIC: Quaternius' Trachten Wizard, Ranger (ohne Kapuze), Knight_Cloth (ohne Hoerner), Kopf Regular_Male_OnlyHead
# Kopfformen (kopf.FORMEN) als Formschluessel an Haut, Augen, Brauen und an jedem Haar und Bart: Godot waehlt sie (Erschaffung).
# Haare und Baerte liegen einzeln in haare.glb (ohne Geruest, Ruhelage der Bezugsfigur); Godot haengt sie an den Kopfknochen.
# Haut stoppelfrei, Haar und Brauen ungetoent (hellgrau): Godot toent Haut und Haar (toon.gdshader toenung).
# Waffen und Schild nicht hier: Godot haengt die angelegte Ausruestung an (waffen.py).
# Aufruf: OUT=<ordner mit held3-rig.blend> ZIEL=<ordner> Q=<cc0> KAUF=<kaufpakete> [KLASSEN=FIGHTER,WIZARD] bl/bin/python -I held_klassen.py
#   -> <ZIEL>/held_<KLASSE>.glb, haare.glb, held-klassen.json
import bpy, os, sys, json, subprocess
import numpy as np
from mathutils import Vector

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
os.environ.setdefault('FIGUREN', 'keine')
OUT = os.environ.get('OUT', '/home/user/q376/out')
ZIEL = os.environ.get('ZIEL', os.path.join(OUT, 'klassen'))
NUR = [s for s in os.environ.get('KLASSEN', '').split(',') if s]
os.makedirs(ZIEL, exist_ok=True)
import quaternius as QT
import kopf as KO

KOERPER = 'Regular_Male_FullBody'
KOPF = 'Regular_Male_OnlyHead'
KLASSEN = {
    'FIGHTER': {'tracht': 'unsere'},
    'WIZARD': {'kleid': 'Male_Wizard'},
    'ROGUE': {'kleid': 'Male_Ranger', 'ohne': ['Hood']},
    'CLERIC': {'kleid': 'Male_Knight_Cloth', 'ohne': ['Horns'], 'stahl': False},   # Pruefer Lauf 1: Arme mit STAHL schwarz (Bild 0,20/0,13/0,08)
}
# Maennerhaar und Baerte (Hairstyles/Rigged to Head Bone/Male); „Long“, „Bob“ und „Buns“ sitzen nur auf dem Frauenkopf
HAARE = ['Hair_SimpleParted', 'Hair_Buzzed', 'Hair_SlickBack', 'Hair_Ponytail', 'Hair_Balding', 'Hair_Dreads', 'Hair_Mohawk']
BAERTE = ['Hair_Beard', 'Hair_Moustache', 'Hair_MuttonChops']
FORMEN = [k for k, f in KO.FORMEN.items() if f]
# Haare: „Rigged to Head Bone“ (Godot) vor „Origin at 0“ (wie kauf_kleid.py; quaternius.py nimmt die erste nach Namen)
RIGGED = {}
for wurzel in (QT.Q, os.environ.get('KAUF', '')):
    for wo, _, fs in sorted(os.walk(wurzel)) if wurzel else ():
        for f in fs:
            if f.endswith('.gltf') and 'Rigged' in wo and 'Godot' in wo: RIGGED.setdefault(f[:-5], os.path.join(wo, f))


def godot(v):   # Blender (Z oben, Blick -Y) -> glTF/Godot (Y oben)
    return [round(float(v.x), 5), round(float(v.z), 5), round(float(-v.y), 5)]


def kopfnetze(netze):
    haut = next(o for o in netze if o.name.startswith('RegularMale'))
    augen = next((o for o in netze if o.name.startswith('Eyes')), None)
    brauen = [o for o in netze if o.name.startswith('Eyebrows')]
    return haut, augen, brauen


def schluessel(netze, p, augen=None):
    # je Form ein Formschluessel: Verschiebung aus kopf.feld (Augen je Seite als Ganzes, wie kopf.forme)
    for o in netze:
        W = KO._welt(o)
        if not o.data.shape_keys: o.shape_key_add(name='Basis', from_mix=False)
        Mi = np.array(o.matrix_world.inverted())
        for n in FORMEN:
            f = KO.FORMEN[n]
            if o is augen:
                D = np.zeros_like(W)
                for s in (W[:, 0] < 0, W[:, 0] >= 0):
                    if s.any(): D[s] = KO.feld(W[s].mean(0, keepdims=True), p, f)[0]
            else: D = KO.feld(W, p, f)
            sk = o.shape_key_add(name=n, from_mix=False)
            sk.data.foreach_set('co', ((W + D) @ Mi[:3, :3].T + Mi[:3, 3]).ravel())


def dreiecke(netze):
    n = 0
    for o in netze:
        o.data.calc_loop_triangles(); n += len(o.data.loop_triangles)
    return n


def schlank(objs, gross=1024):
    # Godot liest nur das Farbbild (gebiet.gd male): Normalen-, Rauheits- und ORM-Bilder ab, Farbbilder hoechstens gross Punkte
    # (Zauberer mit allen Bildern in voller Groesse 49 MB)
    for m in {m for o in objs if o.type == 'MESH' for m in o.data.materials if m and m.node_tree}:
        nt = m.node_tree
        bsdf = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
        if not bsdf: continue
        for e in bsdf.inputs:
            if e.name not in ('Base Color', 'Alpha'):
                for l in list(e.links): nt.links.remove(l)
        tn = QT.basisbild(m)
        im = tn.image if tn else None
        if im and max(im.size) > gross:
            f = gross / max(im.size)
            im.scale(max(1, int(im.size[0] * f)), max(1, int(im.size[1] * f)))
            im.pack()


def exportiere(p, objs, farbe=False):
    schlank(objs)
    for o in objs:
        if o.type == 'MESH': o.data.name = o.name   # Godot benennt Netze nach den Daten (haare.glb: „Sphere.014_Retopology“)
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=p, export_format='GLB', use_selection=True, export_animations=False, export_apply=False,
                              export_skins=True, export_morph=True, export_morph_normal=True,
                              export_vertex_color='ACTIVE' if farbe else 'NONE')


# Pruefer Lauf 1 (Kaempfer von hinten): Haut unter dem Umhangsaum durch die Hose, weisse Splitter an der Sohle, tuerkis im Schritt
# (Unterwaesche des Kaufkoerpers). Hose, Stiefel und Wappenrock decken Becken und Beine ganz: diese Haut weg (staerkstes Gewicht)
BEINE = {'pelvis', 'thigh_l', 'thigh_r', 'calf_l', 'calf_r', 'foot_l', 'foot_r', 'ball_l', 'ball_r'}


def beine_weg(o):
    import bmesh
    g = {vg.index: vg.name for vg in o.vertex_groups}
    weg = [v.index for v in o.data.vertices if v.groups and g.get(max(v.groups, key=lambda x: x.weight).group, '').split('.')[0] in BEINE]
    bm = bmesh.new(); bm.from_mesh(o.data); bm.verts.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[bm.verts[i] for i in weg], context='VERTS'); bm.to_mesh(o.data); bm.free()
    print('BEINE WEG', len(weg), 'Ecken')


def kaempfer(k):
    # unsere Tracht auf dem Kaufkoerper (kauf_kleid.py), dann Formschluessel am Kopf
    roh = os.path.join(ZIEL, 'roh'); os.makedirs(roh, exist_ok=True)
    env = dict(os.environ, KOERPER=KOERPER, KOPF='', HAAR='', BART='', FARBE='keine', STOPPELN='0', HAUT='mittel', FORM='',
               KENNUNG='held_' + k, ZIEL=roh)
    r = subprocess.run([sys.executable, '-I', os.path.join(HIER, 'kauf_kleid.py')], env=env, capture_output=True, text=True)
    print('\n'.join(l for l in r.stdout.splitlines() if l.startswith(('KAUFKLEID', 'KLEIDUNG', 'HALS', 'UMHANG'))))
    if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('kauf_kleid.py %d' % r.returncode)
    bpy.ops.wm.open_mainfile(filepath=os.path.join(roh, 'held_%s.blend' % k))
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    netze = [o for o in bpy.data.objects if o.type == 'MESH' and any(m.type == 'ARMATURE' and m.object == arm for m in o.modifiers)]
    haut, augen, brauen = kopfnetze(netze)
    beine_weg(haut)
    p = KO.merkpunkte(haut, augen)
    schluessel([haut, augen] + brauen if augen else [haut] + brauen, p, augen)
    exportiere(os.path.join(ZIEL, 'held_%s.glb' % k), [arm] + netze, farbe=True)
    return arm, netze


def tracht(k, f):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    kn, kp = QT.datei(f['kleid'])
    if not kp or kn != f['kleid']: raise SystemExit('FEHLT %s (gekauft, KAUF=)' % f['kleid'])
    objs = QT.importiere(kp)
    arm = next(o for o in objs if o.type == 'ARMATURE'); arm.name = 'Armature'
    netze = [o for o in objs if o.type == 'MESH']
    hn, hp = QT.datei(KOPF)
    if not hp or hn != KOPF: raise SystemExit('FEHLT %s (gekauft, KAUF=)' % KOPF)
    ko = QT.importiere(hp)
    a2 = next((o for o in ko if o.type == 'ARMATURE'), None)
    vs = (QT.kopf_pos(arm) - QT.kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
    neu = [o for o in ko if o.type == 'MESH']
    QT.an_geruest(ko, arm, vs)
    netze += neu
    for o in [o for o in netze if any(w in o.name for w in f.get('ohne', []))]:
        netze.remove(o); bpy.data.objects.remove(o)
    QT.KOPIEN.clear()
    for o in netze:   # wie quaternius.py: Schulterstueck Leder, Ritterplatten Stahl (Helfer 13:45)
        if 'Pauldron' in o.name: QT.toene(o, lambda n: True, QT.LEDER)
        elif o.name.startswith(('Male_Knight', 'Female_Knight')) and f.get('stahl', True): QT.toene(o, lambda n: n.startswith('MI_Knight'), QT.STAHL)
    haut, augen, brauen = kopfnetze(netze)
    p = KO.merkpunkte(haut, augen)
    KO.toene_haut(haut, p, (1.0, 1.0, 1.0), 0.0, mat=lambda n: 'Regular' in n)   # glatt rasiert; Bart als Netz (haare.glb)
    schluessel([haut, augen] + brauen if augen else [haut] + brauen, p, augen)
    exportiere(os.path.join(ZIEL, 'held_%s.glb' % k), [arm] + netze)
    return arm, netze


def bildfarbe(netze, wahl=lambda o, W: np.ones(len(W), bool)):
    # Median der Bildfarbe (sRGB 0-1) an den Ecken der Netze, wo wahl gilt; Godot toent damit auf den Zielton (heldfigur.gd)
    werte = []
    for o in netze:
        me = o.data; uv = me.uv_layers.active.data
        W = KO._welt(o); ok = wahl(o, W)
        for m in me.materials:
            tn = QT.basisbild(m)
            if not tn or not tn.image: continue
            im = tn.image; Wd, Hd = im.size
            px = np.empty(Wd * Hd * 4, dtype=np.float32); im.pixels.foreach_get(px); px = px.reshape(Hd, Wd, 4)
            for l in me.loops:
                if not ok[l.vertex_index]: continue
                u, v = uv[l.index].uv
                werte.append(px[int(v % 1 * Hd) % Hd, int(u % 1 * Wd) % Wd, :3])
            break
    return [round(float(x), 4) for x in np.median(np.array(werte), axis=0)] if werte else [1.0, 1.0, 1.0]


def haare():
    # Bezugsfigur: Kaufkoerper; jedes Haar und jeder Bart „Rigged to Head Bone“ an ihren Kopf (wie kauf_kleid.py), Formschluessel
    # mit ihren Merkpunkten, dann ohne Geruest in der Ruhelage
    bpy.ops.wm.read_factory_settings(use_empty=True)
    kn, kp = QT.datei(KOERPER)
    objs = QT.importiere(kp)
    arm = next(o for o in objs if o.type == 'ARMATURE')
    haut, augen, brauen = kopfnetze([o for o in objs if o.type == 'MESH'])
    p = KO.merkpunkte(haut, augen)
    kopf = QT.kopf_pos(arm)
    # Hautton: Gesicht zwischen Kinn und Augen, vorn
    haut_ref = bildfarbe([haut], lambda o, W: (W[:, 2] > p['kinn_z'] + 0.02) & (W[:, 2] < p['augen_z']) & (W[:, 1] < p['mitte'][1]))
    alle = []
    for n in HAARE + BAERTE:
        hp = RIGGED.get(n)
        if not hp: print('FEHLT', n); continue
        ho = QT.importiere(hp)
        a2 = next((o for o in ho if o.type == 'ARMATURE'), None)
        vs = (kopf - QT.kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
        neu = [o for o in ho if o.type == 'MESH']
        QT.an_geruest(ho, arm, vs)
        for o in neu:
            o.name = n
            mw = o.matrix_world.copy(); o.parent = None; o.matrix_world = mw
            for m in list(o.modifiers): o.modifiers.remove(m)
            for g in list(o.vertex_groups): o.vertex_groups.remove(g)
            bpy.context.view_layer.objects.active = o
            bpy.ops.object.select_all(action='DESELECT'); o.select_set(True)
            bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        schluessel(neu, p)
        alle += neu
    haar_ref = bildfarbe([o for o in alle if o.name in HAARE])
    exportiere(os.path.join(ZIEL, 'haare.glb'), alle)
    return {'kopf': godot(kopf), 'haut_bild': haut_ref, 'haar_bild': haar_ref, 'haare': [n for n in HAARE if any(o.name == n for o in alle)],
            'baerte': [n for n in BAERTE if any(o.name == n for o in alle)], 'dreiecke': {o.name: dreiecke([o]) for o in alle}}


# Bewegungen fuer held.gd (Namen wie held.bin): aus der UAL (gekauft Pro, sonst Standard), nur Geruest und diese Bewegungen. Die von
# rig.py (held.bin) passen nicht: sie sind auf unsere Ruhelage (Arme haengend) umgerechnet, der Kaufkoerper ruht in der T-Pose
BEWEGUNGEN = [('Stehen', 'Idle_Loop'), ('Gehen', 'Walk_Loop'), ('Rennen', 'Jog_Fwd_Loop'), ('Stehen_2', 'Idle_LookAround_Loop'),
              ('Stehen_3', 'Idle_Tired_Loop'), ('Sitzen', 'Sitting_Idle_Loop'), ('Gesten', 'Idle_Talking_Loop')]


def schritt_tempo(arm, a):
    # wie figurenprobe.gd schritt_tempo: der Standfuss gleitet auf der Stelle mit dem Tempo zurueck, mit dem der Koerper vorankaeme;
    # je Fuss die Rueckwaertsgeschwindigkeit in den Bildern hoechstens 2 cm ueber seinem Tiefstand, Median (Blick -Y)
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]
    f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
    fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base
    vs = []
    for fu in ('foot_l', 'foot_r'):
        d, h = [], []
        for fr in range(f0, f1 + 1):
            bpy.context.scene.frame_set(fr)
            p = arm.matrix_world @ arm.pose.bones[fu].head
            d.append(-p.y); h.append(p.z)
        tief = min(h)
        for j in range(len(d) - 1):
            if h[j] < tief + 0.02 and h[j + 1] < tief + 0.02: vs.append((d[j] - d[j + 1]) * fps)
    vs.sort()
    return round(max(vs[len(vs) // 2], 0.0), 3) if vs else 0.0


def bewegungen():
    import geruest as GE
    pro = GE.ual_pro()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=pro or GE.ual_datei())
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    for o in [o for o in bpy.data.objects if o != arm]: bpy.data.objects.remove(o)
    namen = dict((q, n) for n, q in BEWEGUNGEN)
    for a in list(bpy.data.actions):
        if a.name in namen: a.name = namen[a.name]; a.use_fake_user = True
        else: bpy.data.actions.remove(a)
    tempo = {n: schritt_tempo(arm, bpy.data.actions[n]) for n in ('Gehen', 'Rennen') if n in bpy.data.actions}
    if arm.animation_data: arm.animation_data.action = None
    bpy.ops.object.select_all(action='DESELECT'); arm.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, 'bewegungen.glb'), export_format='GLB', use_selection=True, export_animations=True,
                              export_animation_mode='ACTIONS', export_skins=True, export_force_sampling=True)
    return {'gehen_m_je_s': tempo.get('Gehen', 0.0), 'rennen_m_je_s': tempo.get('Rennen', 0.0), 'becken_m': round(arm.data.bones['pelvis'].head_local.z, 4),
            'bewegungen': sorted(a.name for a in bpy.data.actions), 'ual': os.path.basename(pro) if pro else 'UAL1_Standard.glb', 'gekauft': bool(pro)}


info = {'formen': FORMEN, 'haut': {k: list(v) for k, v in KO.HAUT.items()}, 'haarfarben': {k: list(v) for k, v in QT.HAAR.items()},
        'klassen': {}}
for k, f in KLASSEN.items():
    if NUR and k not in NUR: continue
    arm, netze = kaempfer(k) if f.get('tracht') == 'unsere' else tracht(k, f)
    info['klassen'][k] = {'kleid': f.get('kleid', 'unsere'), 'kopf': godot(QT.kopf_pos(arm)), 'dreiecke': dreiecke(netze),
                          'netze': sorted(o.name for o in netze)}
    print('KLASSE', k, info['klassen'][k]['dreiecke'], 'Dreiecke', info['klassen'][k]['kleid'])
info.update(haare())
info.update(bewegungen())
json.dump(info, open(os.path.join(ZIEL, 'held-klassen.json'), 'w'), indent=1, ensure_ascii=False)
print('HELD KLASSEN OK', list(info['klassen']), len(info['haare']), 'Haare', len(info['baerte']), 'Baerte')
