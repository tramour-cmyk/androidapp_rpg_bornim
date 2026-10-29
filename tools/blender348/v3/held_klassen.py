# 376.1 (Chef 28.10., 22:0x: „die vier spielbaren Klassen mal auf das gute Modell mit dem guten Kopf … in der [Charaktererstellung]
# doch auch Einfluss nehmen … die jeweiligen Klassen ihre Standard-Grundausruestung kriegen, sichtbar“): der Held je Klasse auf dem
# gekauften Koerper mit gekauftem Kopf (Quaternius Universal Base Characters, Regular), ohne Bewegungen (Godot nimmt die der UAL).
#   FIGHTER: unsere Tracht (Kettenhemd, Wappenrock, Umhang; kauf_kleid.py, Chef 27.10., 18:06 „passt“)
#   WIZARD: lange Robe wie im alten Spiel (held3.py mit trachten.json held_wizard, dann kauf_kleid.py wie beim Kaempfer)
#   ROGUE, CLERIC: Quaternius' Trachten Ranger (ohne Kapuze), Knight_Cloth (ohne Hoerner), Kopf Regular_Male_OnlyHead
# Kopfformen (kopf.FORMEN) als Formschluessel an Haut, Augen, Brauen und an jedem Haar und Bart: Godot waehlt sie (Erschaffung).
# Haare und Baerte liegen einzeln in haare.glb (ohne Geruest, Ruhelage der Bezugsfigur); Godot haengt sie an den Kopfknochen.
# Haut stoppelfrei, Haar und Brauen ungetoent (hellgrau): Godot toent Haut und Haar (toon.gdshader toenung).
# Waffen und Schild nicht hier: Godot haengt die angelegte Ausruestung an (waffen.py).
# Aufruf: OUT=<ordner mit held3-rig.blend> ZIEL=<ordner> Q=<cc0> KAUF=<kaufpakete> [KLASSEN=FIGHTER,WIZARD] bl/bin/python -I held_klassen.py
#   -> <ZIEL>/held_<KLASSE>.glb, haare.glb, held-klassen.json
import bpy, os, sys, json, subprocess, shutil
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
    # Pruefer 376.1 Lauf 1 (29.10.): unsere Stiefel wie Holzpfloecke, im rechten ein Loch: Stiefel aus den Kauftrachten
    'FIGHTER': {'tracht': 'unsere', 'fuesse': 'Male_Ranger_Feet_Boots'},
    'WIZARD': {'tracht': 'held_wizard', 'fuesse': 'Male_Ranger_Feet_Boots', 'stiefel_eng': 0.28},   # Lauf 2: Wizard_Feet schraeg wie Clownsschuhe   # Chef 28.10., 23:0x: „trägt keine Robe … Kasperlanzug“: lange Robe aus held3 (trachten.json)
    'ROGUE': {'kleid': 'Male_Ranger', 'ohne': ['Hood']},
    'CLERIC': {'kleid': 'Male_Knight_Cloth', 'ohne': ['Horns'], 'stahl': False,   # Pruefer Lauf 1: Arme mit STAHL schwarz (Bild 0,20/0,13/0,08)
               'sonne': 'Body_Cloth', 'entgruen': ['Legs_Armor', 'Feet_Armor', 'Arms']},   # Lauf 1: Handschuhe gruenlich (118/124/109)
}
# Maennerhaar und Baerte (Hairstyles/Rigged to Head Bone/Male); dazu das Frauenhaar (376.1, Chef 29.10., 10:52: „gibt es noch andere
# Frisuren“), auf den Maennerkopf umgelegt (FRAUENHAAR)
HAARE = ['Hair_SimpleParted', 'Hair_Buzzed', 'Hair_SlickBack', 'Hair_Ponytail', 'Hair_Balding', 'Hair_Dreads', 'Hair_Mohawk',
         'Hair_Long', 'Hair_LongDreads', 'Hair_Ponytail_2', 'Hair_Bob', 'Hair_Buns']
FRAUENHAAR = {'Hair_Long', 'Hair_LongDreads', 'Hair_Ponytail_2', 'Hair_Bob', 'Hair_Buns'}
FRAUENKOPF = 'Regular_Female_OnlyHead'
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


def held3_tracht(figur):
    # Tracht einer Klasse aus held3.py und rig.py (FIGUR aus trachten.json) in einem eigenen Ordner; Texturen und Karten aus OUT
    o = os.path.join(ZIEL, 'roh_' + figur); os.makedirs(o, exist_ok=True)
    if not os.path.exists(os.path.join(o, 'tex')): os.symlink(os.path.join(OUT, 'tex'), os.path.join(o, 'tex'))
    env = dict(os.environ, OUT=o, FIGUR=figur, LEUTE=os.path.join(HIER, 'trachten.json'))
    env.setdefault('KARTEN', os.path.join(OUT, 'karten.json'))
    for s in ('held3', 'rig'):
        r = subprocess.run([sys.executable, '-I', os.path.join(HIER, s + '.py')], env=env, capture_output=True, text=True)
        if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('%s.py %s %d' % (s, figur, r.returncode))
    return o


def stiefel_eng(o, ab, f=0.75):
    # Chef 29.10., 11:40 („da schauen witzigerweise seine Knie durch die Robe durch“): die Ranger-Stiefel reichen bis 0,56 m, ueber
    # das Knie; die Robe ist dort grob vernetzt (bei 0,3-0,4 m keine Ecke). Schaft oberhalb ab je Bein zur Beinmitte enger (Ruhelage)
    M = o.matrix_world; Mi = M.inverted()
    W = np.array([tuple(M @ v.co) for v in o.data.vertices])
    for s in (W[:, 0] < 0, W[:, 0] >= 0):
        oben = s & (W[:, 2] > ab)
        if not oben.any(): continue
        mx, my = W[oben, 0].mean(), W[oben, 1].mean()
        t = np.clip((W[:, 2] - ab) / 0.08, 0, 1)   # weich ueber 8 cm
        k = 1 - (1 - f) * t
        W[oben, 0] = mx + (W[oben, 0] - mx) * k[oben]
        W[oben, 1] = my + (W[oben, 1] - my) * k[oben]
    for v, w in zip(o.data.vertices, W): v.co = Mi @ Vector(tuple(w))
    print('STIEFEL ENG ab %.2f m' % ab)


def kaempfer(k, figur='', fuesse='', eng=0.0):
    # unsere Tracht auf dem Kaufkoerper (kauf_kleid.py), dann Formschluessel am Kopf; figur: andere Tracht aus trachten.json;
    # fuesse: Stiefel aus den Kauftrachten statt unserer; eng: Stiefelschaft ab dieser Hoehe enger (unter der Robe)
    roh = os.path.join(ZIEL, 'roh'); os.makedirs(roh, exist_ok=True)
    env = dict(os.environ, KOERPER=KOERPER, KOPF='', HAAR='', BART='', FARBE='keine', STOPPELN='0', HAUT='mittel', FORM='',
               KENNUNG='held_' + k, ZIEL=roh)
    ohne = []
    if figur:
        env['OUT'] = held3_tracht(figur)
        ohne = json.load(open(os.path.join(HIER, 'trachten.json')))[figur].get('ohne', [])
    if fuesse: ohne = ohne + ['boots']
    env['OHNE_TEIL'] = ','.join(ohne)
    r = subprocess.run([sys.executable, '-I', os.path.join(HIER, 'kauf_kleid.py')], env=env, capture_output=True, text=True)
    print('\n'.join(l for l in r.stdout.splitlines() if l.startswith(('KAUFKLEID', 'KLEIDUNG', 'HALS', 'UMHANG'))))
    if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('kauf_kleid.py %d' % r.returncode)
    bpy.ops.wm.open_mainfile(filepath=os.path.join(roh, 'held_%s.blend' % k))
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    netze = [o for o in bpy.data.objects if o.type == 'MESH' and any(m.type == 'ARMATURE' and m.object == arm for m in o.modifiers)]
    if fuesse:
        fn, fp = QT.datei(fuesse)
        if not fp or fn != fuesse: raise SystemExit('FEHLT %s (gekauft, KAUF=)' % fuesse)
        fo = [o for o in QT.importiere(fp)]
        fm = [o for o in fo if o.type == 'MESH']
        QT.an_geruest(fo, arm)   # entfernt das Geruest des Imports
        if eng:
            for o in fm: stiefel_eng(o, eng)
        netze += fm
    haut, augen, brauen = kopfnetze(netze)
    beine_weg(haut)
    p = KO.merkpunkte(haut, augen)
    schluessel([haut, augen] + brauen if augen else [haut] + brauen, p, augen)
    exportiere(os.path.join(ZIEL, 'held_%s.glb' % k), [arm] + netze, farbe=True)
    return arm, netze


def eigenes_bild(o, gross=1024):
    # eigene Kopie von Material und Bild fuer dieses Netz (das Bild teilen sich alle Teile der Tracht), hoechstens gross Punkte
    m = o.data.materials[0]
    m2 = m.copy(); m2.name = m.name + '_' + o.name; o.data.materials[0] = m2
    tn = QT.basisbild(m2)
    im = tn.image.copy(); im.name = o.name + '_bild'; tn.image = im
    if max(im.size) > gross:
        fk = gross / max(im.size); im.scale(max(1, int(im.size[0] * fk)), max(1, int(im.size[1] * fk)))
    W, H = im.size
    px = np.empty(W * H * 4, dtype=np.float32); im.pixels.foreach_get(px)
    return im, px.reshape(H, W, 4)


def zurueck_ins_bild(im, px):
    im.pixels.foreach_set(px.ravel()); im.update(); im.pack()


def entgruen(o):
    # Pruefer Lauf 2 (Kleriker): Beinplatten mintgruen. Gruenstich (Gruen ueber Rot) zu Stahl: Helligkeit mal STAHL, Stoff bleibt
    im, px = eigenes_bild(o)
    c = px[..., :3]
    l = (0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2])[..., None]
    g = np.clip((np.maximum(c[..., 1], c[..., 2]) - c[..., 0] + 0.005) / 0.035, 0, 1)[..., None]   # Lauf 1: noch mintgruen
    px[..., :3] = c * (1 - g) + l * np.array(QT.STAHL, dtype=np.float32) * 1.15 * g
    zurueck_ins_bild(im, px)
    print('ENTGRUEN', o.name, int((g > 0.5).sum()), 'Punkte')


SONNE_GOLD = np.array((0.72, 0.565, 0.29), dtype=np.float32)   # Gold wie alt (Dress.kt gold B8904A)
SONNE_GROESSE = float(os.environ.get('SONNE_GROESSE', '1.7'))   # Mass von Dress.kt; groesser (Lauf 1: wie Kleeblattkreuz gelesen)


def sonne(o, arm):
    # Chef 28.10., 23:0x (Kleriker „wegen seiner Verbundenheit zu seiner Göttin“), Dress.kt tabard: goldene Sonne auf Brust und
    # Ruecken, Scheibe, Ring und acht Strahlen; Mitte bei Guertel + 0,58 (Schulter - Guertel). Ins Bild des Netzes gemalt: je
    # Dreieck vorn bzw. hinten die Bildpunkte, deren Lage auf dem Koerper in der Sonne liegt
    im, px = eigenes_bild(o, 2048)   # Lauf 1: bei 1024 zu grob, Strahlen verschwammen
    H, W = px.shape[:2]
    mw = arm.matrix_world
    gz = (mw @ arm.data.bones['spine_01'].head_local).z
    sz = (mw @ arm.data.bones['upperarm_l'].head_local).z
    mz = gz + (sz - gz) * 0.68   # Lauf 2 (Pruefer): bei 0,58 unten hinter dem Guertel
    h = (mw @ arm.data.bones['Head'].head_local).z / 0.9 * SONNE_GROESSE   # Koerperhoehe (Kopfknochen bei etwa 90 %), mal Mass
    P = KO._welt(o)
    me = o.data; me.calc_loop_triangles()
    uv = me.uv_layers.active.data
    n = 0; F = []; G = []
    for t in me.loop_triangles:
        a, b, c = (P[i] for i in t.vertices)
        mitte = (a + b + c) / 3
        nrm = np.cross(b - a, c - a)
        if abs(mitte[0]) > 0.06 * h or abs(mitte[2] - mz) > 0.06 * h or abs(nrm[1]) < 0.3 * np.linalg.norm(nrm): continue
        U = np.array([uv[l].uv[:] for l in t.loops]) * (W, H)
        x0, y0 = np.floor(U.min(0)).astype(int); x1, y1 = np.ceil(U.max(0)).astype(int)
        xs, ys = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        T = np.array([[U[1, 0] - U[0, 0], U[2, 0] - U[0, 0]], [U[1, 1] - U[0, 1], U[2, 1] - U[0, 1]]])
        if abs(np.linalg.det(T)) < 1e-9: continue
        l12 = np.linalg.solve(T, np.stack([xs.ravel() - U[0, 0], ys.ravel() - U[0, 1]]))
        l0 = 1 - l12[0] - l12[1]
        drin = (l0 >= -0.01) & (l12[0] >= -0.01) & (l12[1] >= -0.01)
        if not drin.any(): continue
        Q = l0[drin, None] * a + l12[0][drin, None] * b + l12[1][drin, None] * c
        dx, dz = Q[:, 0], Q[:, 2] - mz
        rr = np.hypot(dx, dz)
        strahl = np.abs((np.arctan2(dz, dx) / (2 * np.pi) * 8 + 0.5) % 1.0 - 0.5) * rr
        # Lauf 2 (Pruefer: Zahnrad, darueber das rotgoldene Kreuz des Kaufkleids): erst das Feld in Stofffarbe, dann Strahlen laenger
        feld = rr < 0.05 * h
        gold = (rr < 0.012 * h) | (np.abs(rr - 0.021 * h) < 0.0045 * h) | ((rr >= 0.021 * h) & (rr <= 0.044 * h) & (strahl < 0.005 * h))
        X = (xs.ravel()[drin]).astype(int) % W; Y = (ys.ravel()[drin]).astype(int) % H
        F.append((X[feld], Y[feld])); G.append((X[gold], Y[gold]))
    if F:
        fx = np.concatenate([a for a, _ in F]); fy = np.concatenate([b for _, b in F])
        # Stofffarbe: Median des Rings knapp ausserhalb des Felds ist nicht ohne Lage zu haben; Median der Feldpunkte ohne Gold und Rot
        c = px[fy, fx, :3]
        ist = (np.abs(c[:, 0] - c[:, 1]) < 0.06) & (np.abs(c[:, 1] - c[:, 2]) < 0.06)
        stoff = c[ist]
        if len(stoff): px[fy[~ist], fx[~ist], :3] = np.median(stoff, axis=0)   # nur das Zeichen (bunt), Falten des Stoffs bleiben
        print('SONNE FELD', len(fx), 'Punkte, Stoff', len(stoff), np.round(np.median(stoff, axis=0), 3) if len(stoff) else '-')
    for gx, gy in G:
        px[gy, gx, :3] = SONNE_GOLD; n += len(gx)
    zurueck_ins_bild(im, px)
    print('SONNE', o.name, n, 'Punkte, Mitte', round(mz, 3), 'm, Mass', round(h, 3))


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
    for o in netze:
        if any(w in o.name for w in f.get('entgruen', [])): entgruen(o)
        if f.get('sonne') and f['sonne'] in o.name: sonne(o, arm)
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


def schaedel(netz, kz):
    # Mitte und Masse des Schaedels: Ecken der Kopfhaut ueber dem Kopfknochen (Welt)
    W = np.array([tuple(netz.matrix_world @ v.co) for v in netz.data.vertices])
    W = W[W[:, 2] > kz]
    lo, hi = W.min(0), W.max(0)
    return (lo + hi) / 2, hi - lo


def frauenkopf():
    # Schaedel des Frauenkopfs (Regular_Female_OnlyHead): Frauenhaar sitzt auf ihm; Mitte und Masse fuer das Umlegen
    vorher = set(bpy.data.objects)
    _, p = QT.datei(FRAUENKOPF)
    if not p: return None
    objs = QT.importiere(p)
    arm = next(o for o in objs if o.type == 'ARMATURE')
    netz = next(o for o in objs if o.type == 'MESH' and o.name.startswith('Female_Regular'))
    s = schaedel(netz, QT.kopf_pos(arm).z)
    for o in [o for o in bpy.data.objects if o not in vorher]: bpy.data.objects.remove(o)
    return s


def umlegen(objs, von, nach):
    # Frauenhaar auf den Maennerkopf: je Achse von Schaedelmitte und -mass des Frauenkopfs auf die des Maennerkopfs (Masse fast gleich:
    # 0,178 x 0,225 x 0,215 m gegen 0,182 x 0,221 x 0,21 m; der Kopfknochen allein liess die Stirn 9 mm durch den Pony stechen)
    f = nach[1] / von[1]
    for o in objs:
        if o.type != 'MESH': continue
        M = o.matrix_world; Mi = M.inverted()
        for v in o.data.vertices:
            w = np.array(tuple(M @ v.co))
            v.co = Mi @ Vector(tuple(nach[0] + (w - von[0]) * f))


def haare():
    # Bezugsfigur: Kaufkoerper; jedes Haar und jeder Bart „Rigged to Head Bone“ an ihren Kopf (wie kauf_kleid.py), Formschluessel
    # mit ihren Merkpunkten, dann ohne Geruest in der Ruhelage
    bpy.ops.wm.read_factory_settings(use_empty=True)
    frau = frauenkopf()
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
        if n in FRAUENHAAR:
            if not frau: print('FEHLT', FRAUENKOPF); continue
            bpy.context.view_layer.update()
            umlegen(neu, frau, schaedel(haut, kopf.z)); vs = Vector()
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
    arm, netze = tracht(k, f) if 'kleid' in f else kaempfer(k, '' if f['tracht'] == 'unsere' else f['tracht'], f.get('fuesse', ''),
                                                          f.get('stiefel_eng', 0.0))
    info['klassen'][k] = {'kleid': f.get('kleid') or f['tracht'], 'kopf': godot(QT.kopf_pos(arm)), 'dreiecke': dreiecke(netze),
                          'netze': sorted(o.name for o in netze)}
    print('KLASSE', k, info['klassen'][k]['dreiecke'], 'Dreiecke', info['klassen'][k]['kleid'])
# Scheide fuer Klingen am Guertel (376.1 Wegstecken): Avramania „Weapons & Shields“ Free (CC0, Bestand, Release stufe1), unveraendert
for wurzel in (QT.Q, os.environ.get('KAUF', '')):
    for wo, _, fs in sorted(os.walk(wurzel)) if wurzel else ():
        if 'mdvl_weapons_scabbard_01.glb' in fs and not os.path.exists(os.path.join(ZIEL, 'scheide.glb')):
            shutil.copy(os.path.join(wo, 'mdvl_weapons_scabbard_01.glb'), os.path.join(ZIEL, 'scheide.glb'))
print('SCHEIDE', 'da' if os.path.exists(os.path.join(ZIEL, 'scheide.glb')) else 'FEHLT')
info.update(haare())
info.update(bewegungen())
json.dump(info, open(os.path.join(ZIEL, 'held-klassen.json'), 'w'), indent=1, ensure_ascii=False)
print('HELD KLASSEN OK', list(info['klassen']), len(info['haare']), 'Haare', len(info['baerte']), 'Baerte')
