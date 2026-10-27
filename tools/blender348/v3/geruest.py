# 348.6 Held und Leute auf dem CC0-Geruest (Chef 25.10., 23:33, 348.12; Modellregel 4, 5): Knochen, Namen und Bewegungen aus der
# Universal Animation Library (Quaternius, CC0 1.0, Lizenzdatei im Paket; laedt cc0_laden.sh), die Knochen an unsere Gelenke
# (held3.py, gelenke.json), Netz und Gewichte aus rig.py auf die neuen Namen. Koerper und Kleidung bleiben unsere.
# Gliedmassen folgen der Richtung der fremden Knochen (unsere Arme haengen in Ruhe, die fremden stehen waagerecht ab); Rumpf,
# Hals und Kopf nur deren Drehung gegen die Ruhelage (wer gebeugt gebaut ist, bleibt gebeugt). Ruft rig.py mit GERUEST=cc0.
import bpy, os, glob, math, json
import numpy as np
from mathutils import Vector, Matrix, Quaternion

FPS = 30
QUELLE = 'Quaternius, Universal Animation Library [Standard] (UAL1_Standard.glb), CC0 1.0'
# unser Name <- fremde Bewegung; gerade: in Ruhe eingedreht (Becken und Brust 13 Grad) zum Betrachter zurueck; fackel: linker Arm
# aus der Fackel-Ruhe (relativ zur Brust); kopf: Neigung des Kopfes (Grad, + hebt; fremd ueberall 13-22 Grad gesenkt, Jerry 25.10.)
# Runde 2 (Fremdpruefung Tom 34): eng: Arme und Beine um diesen Anteil von der fremden Spreizung zurueck zu unserer Ruhelage
# (alle standen breitbeinig, Arme abgespreizt, in den Achseln rissen Nadeln auf); Fackel: eigene Haltung wie alt (mit_fackel)
# vor: Anteil der fremden Vorneigung von Rumpf und Hals (fremd im Stehen 16, Gehen 18, Rennen 40 Grad; der Kopf blieb waagerecht und
# lag im Nacken, die senkrecht haengenden Arme scherten die Achseln auf); Arme und Beine folgen Brust und Becken wie in der Quelle
# Runde 4 (Fremdpruefung Runde 3: von hinten Arm ueber dem Schild; dunkle Platten hinten an der Schulter, Borin, Bram, Thessa, Rowena):
# schulter = Anteil der fremden Drehung des Schluesselbeins (Idle zog die Schultern 13 cm nach hinten, den Ellbogen 20 cm); rueck =
# Ellbogen hoechstens so weit hinter der Brustmitte (nur der Held, Schild auf dem Ruecken), der Schwung nach vorn bleibt; im Rennen
# Schluesselbein ganz in Ruhe (0,3: von hinten 8 Ecken der Schulter bis 3,8 cm vor dem Schild, 0: 2 Ecken; Stehen, Gehen 0)
STEHEN = dict(gerade=True, eng_arm=0.65, eng_bein=0.55, vor=0.35, schulter=0.3)
GEHEN = dict(eng_arm=0.45, vor=0.5, schulter=0.3)
# Runde 4c (Fremdpruefung 4b: beim Rennen von hinten Oberarm ueber der oberen Schildecke): der Schild ist 54 cm breit, breiter als die
# Schultern (Gelenke 38 cm), jeder Rueckschwung liegt vor ihm; im Rennen bleibt der Ellbogen 8 cm vor der Brustmitte (pruef_cc0 mit
# Strahlen, Schild aufrechter und weiter ab, held3.py: 2 cm hinter der Brustmitte 8 Ecken 3,9 cm vor dem Schild, 3 cm davor 1 Ecke
# 1,3 cm, 8 cm davor 0)
RENNEN = dict(eng_arm=0.35, vor=0.65, kopf=-8.0, schwung=0.6, schulter=0.0, rueck=-0.08)
_S = dict(rueck=0.02)
HELD = [('Stehen', 'Idle_Loop', dict(STEHEN, **_S)), ('Gehen', 'Walk_Loop', dict(GEHEN, **_S)), ('Rennen', 'Jog_Fwd_Loop', RENNEN),
        ('Stehen_Fackel', 'Idle_Loop', dict(STEHEN, fackel=True, **_S)), ('Gehen_Fackel', 'Walk_Loop', dict(GEHEN, fackel=True, **_S)),
        ('Rennen_Fackel', 'Jog_Fwd_Loop', dict(RENNEN, fackel=True))]
def leute_liste(LP):   # leute.json „ruhe“, „geh“: andere fremde Bewegung je Figur; „gang.takt“: Bilder je Doppelschritt (32 wie der Held)
    takt = (LP.get('gang') or {}).get('takt', 32)
    # Runde 3 (Fremdpruefung Runde 2: Unterschenkel durch lange Gewaender, alle sieben): „gang.schritt“ daempft die Beine gegen die
    # Ruhelage (Huefte, Knie, Knoechel), lange Gewaender noch einmal um ROBE_SCHRITT; der fremde Schritt war fuer Hosen gemacht
    schritt = min(1.0, (LP.get('gang') or {}).get('schritt', 1.0)) * (ROBE_SCHRITT if LP.get('rock') == 'robe' else 1.0)
    # Feinschliff (Fremdpruefung 4c: Liska Arme starr im Gehen): gehaltene Arme (IM_GANG) schwingen mit MITSCHWUNG mal gang.arm der
    # fremden Bewegung um die Schulter mit
    mit = MITSCHWUNG * (LP.get('gang') or {}).get('arm', 0.6)
    return [('Stehen', LP.get('ruhe', 'Idle_Loop'), STEHEN), ('Gehen', LP.get('geh', 'Walk_Loop'), dict(GEHEN, takt=takt, schritt=schritt, mitschwung=mit))]
MITSCHWUNG = 0.5
MIT_WIPPEN = 22.0   # Grad je mitschwung: gefaltete Haende (vorn, ruecken) wippen im Schritt (Liska 0,22: 5 Grad, Hand 5 cm)
UM_NAH, UM_ARM = 0.05, 0.10   # m: Umhang auf der Unterlage (Feinschliff)
ACHSEL_TIEF = float(os.environ.get('ACHSEL_TIEF', 0.04))   # m unter dem Schultergelenk: darunter nehmen Schalen nur Gewichte derselben Art (Feinschliff 2)
ROBE_SCHRITT = 0.8   # Gwenna, Osric: Unterschenkel frei je Bild 66/88 -> 25/26 Ecken (pruef_rock.py), mit Rock 16 cm und Wade 0,5 (rig.py)
KOPF = -3.0          # Grad: Blick leicht unter die Waagerechte
FACKEL = 'Idle_Torch_Loop'
IM_GANG = ('schulter', 'stab', 'vorn', 'ruecken')   # wie rig.py: diese Armhaltungen bleiben auch im Gehen


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
    TEILM = {t: np.array([any(alt_name[e.group] == t and e.weight > 0.5 for e in v.groups) for v in me.vertices])
             for t in ('TEIL_umhang', 'TEIL_koerper', 'TEIL_schale') if t in alt_name.values()}
    fremd = [n for n in alt_name.values() if n not in G and n != 'fest' and not n.startswith('TEIL_')]
    if fremd: print('GRUPPEN OHNE ZIEL', fremd)
    # Runde 2 (Fremdpruefung Tom 34: Nadeln an Achseln und Schultern, Bram, Jorin): um die Schultergelenke (12 cm) die Gewichte ueber
    # die Kanten glaetten; die fremden Bewegungen drehen Brust, Bauch und Schluesselbein staerker gegeneinander als unsere (15 cm, 20 Gaenge)
    NG = sorted(W); gi = {n: i for i, n in enumerate(NG)}
    M = np.zeros((len(me.vertices), len(NG)))
    for n, d in W.items():
        for i, w in d.items(): M[i, gi[n]] = w
    P = np.array([tuple(v.co) for v in me.vertices]); EG = np.array([tuple(e.vertices) for e in me.edges])
    # Runde 3 (Fremdpruefung Runde 2: Nadeln an den Achseln, Jorin, Bram, Pim): Bereich 0,8 Oberarmlaengen statt 15 cm; bei den
    # Kraeftigen liegt die Achsel 15 cm unter dem Schultergelenk, am Rand des Bereichs (Jorin Stehen 6 -> 2 Nadeln, Pim 3 -> 1)
    sh = [J['sh' + x][0] / 100.0 for x in 'RL']
    rn = 0.8 * (J['shR'][0] - J['elR'][0]).length / 100.0
    nah = np.min([np.linalg.norm(P - np.array(tuple(q)), axis=1) for q in sh], 0) < rn
    # Runde 4 (Fremdpruefung Runde 3: Held rennt, von hinten Arm ueber dem Schild): das Netz ist hier schon auf 6000 Dreiecke abgebaut,
    # am Aermel laufen Kanten 20 cm vom Oberarm zum Unterarm; ueber sie floss das Gewicht des Unterarms bis an die Schulter (0,66 hinten
    # am Oberarm, die Schulter schwang mit dem Unterarm nach hinten ueber den Schild). Geglaettet werden nur Rumpf, Schluesselbein und
    # Oberarm; Unterarm und Hand behalten ihr Gewicht, die geglaetteten teilen sich den Rest
    fest = np.array([n.startswith(('lowerarm', 'hand')) for n in NG])
    rest = 1.0 - M[:, fest].sum(1)
    for _ in range(20):
        S = np.zeros_like(M); C = np.zeros(len(M))
        np.add.at(S, EG[:, 0], M[EG[:, 1]]); np.add.at(S, EG[:, 1], M[EG[:, 0]]); np.add.at(C, EG.ravel(), 1)
        Mn = 0.5 * M + 0.5 * S / np.maximum(C, 1)[:, None]
        m_ = nah & (C > 0)
        Mn[:, fest] = M[:, fest]
        g_ = Mn[:, ~fest]; g_ *= (rest / np.maximum(g_.sum(1), 1e-9))[:, None]; Mn[:, ~fest] = g_
        M[m_] = Mn[m_]
    M /= np.maximum(M.sum(1, keepdims=True), 1e-9)
    # Feinschliff (Fremdpruefung 4c: Borin, Bram schwarzer Streifen hinter der Schulter, Thessa orange Zacken an den Schultern): das
    # Glaetten laeuft je Flaeche ueber deren eigene Kanten; Aermel und Kittel bekamen an der Schulter andere Gewichte als der Koerper
    # darunter, der Aermel hob sich beim Gehen hinten ab (von innen gesehen schwarz, teile.py: Aermel), der Kittel stach durch den
    # Umhang. Schalen (Aermel, Kittel) und Umhang nehmen, wo sie aufliegen (bis UM_NAH), die Gewichte der naechsten Ecken darunter
    # (abheben, pruef_lagen: Bram 38 -> 18 Ecken; ein Strahl zur Koerperstelle darunter war schlechter: 28); Armgewichte am Umhang
    # nur bis UM_ARM unter der Schulter, darunter haengt er frei
    from mathutils.kdtree import KDTree
    # Feinschliff 2 (Fremdpruefung Feinschliff 1: Osric dunkler Keil unter der Achsel, Haende auf dem Ruecken): unter der Achsel lag die
    # Innenseite des Oberarms naeher als die Rumpfseite darunter, der Kittel nahm dort Armgewichte, folgte dem Arm nach hinten und gab
    # den Koerper frei. Schalen nehmen unter der Achsel (ACHSEL_TIEF unter dem Schultergelenk) nur Ecken derselben Art (Arm oder Rumpf,
    # nach dem eigenen Gewicht); an der Schulter mischen sie weiter
    def auflegen(ziel, quelle, nah_, arm_bis=None, gleich=False):
        armsp = np.array([n.startswith(('upperarm', 'lowerarm', 'hand')) for n in NG]); shz_ = float(min(q.z for q in sh))
        arm_ = M[:, armsp].sum(1) > 0.5; kds = {}
        for art_ in (None, False, True) if gleich else (None,):
            iq = np.where(quelle & ((arm_ == art_) if art_ is not None else True))[0]
            if not len(iq): continue
            kd_ = KDTree(len(iq))
            for k_, i in enumerate(iq): kd_.insert(P[i], k_)
            kd_.balance(); kds[art_] = (kd_, iq)
        if None not in kds or not ziel.any(): return 0
        n_ = 0
        for i in np.where(ziel)[0]:
            a_art = bool(arm_[i]) if gleich and P[i][2] < shz_ - ACHSEL_TIEF else None
            kd_, iq = kds.get(a_art, kds[None])
            nb = kd_.find_n(P[i], 3)
            if not nb or nb[0][2] > nah_: continue
            wt = np.mean([M[iq[k_]] for _, k_, _ in nb], 0); dist = nb[0][2]
            a_ = min(1.0, (nah_ - dist) / max(nah_ - 0.01, 1e-3))
            if arm_bis is not None: wt[armsp] *= min(1.0, max(0.0, (P[i][2] - (shz_ - arm_bis - 0.06)) / 0.06))
            M[i] = (1 - a_) * M[i] + a_ * wt / max(wt.sum(), 1e-9); n_ += 1
        return n_
    Z0 = np.zeros(len(M), bool)
    if 'TEIL_schale' in TEILM and 'TEIL_koerper' in TEILM:
        print('SCHALEN AUF DEM KOERPER', auflegen(TEILM['TEIL_schale'], TEILM['TEIL_koerper'], UM_NAH,
              gleich='ruecken' in (LP.get('arme') or {}).values()))
    if 'TEIL_umhang' in TEILM:
        print('UMHANG AUF DER UNTERLAGE', auflegen(TEILM['TEIL_umhang'], TEILM.get('TEIL_koerper', Z0) | TEILM.get('TEIL_schale', Z0), UM_NAH, UM_ARM),
              'von', int(TEILM['TEIL_umhang'].sum()))
    # 348.6 Achselkerbe (rig.py UMHANG_SPALT): die Innenlage des Umhangs nimmt die Gewichte der Aussenlage an ihrer Stelle (drei naechste
    # Ecken nach Abstand), sonst bewegen sich die Lagen verschieden und die innere sticht durch
    if 'TEIL_umhanginnen' in alt_name.values() and 'TEIL_umhang' in TEILM:
        inn = np.array([any(alt_name[e.group] == 'TEIL_umhanginnen' and e.weight > 0.5 for e in v.groups) for v in me.vertices])
        iq = np.where(TEILM['TEIL_umhang'] & ~inn)[0]
        if len(iq) and inn.any():
            kd_ = KDTree(len(iq))
            for k_, i in enumerate(iq): kd_.insert(P[i], k_)
            kd_.balance()
            for i in np.where(inn)[0]:
                nb = kd_.find_n(P[i], 3); g_ = np.array([1.0 / max(d_, 1e-4) for _, _, d_ in nb])
                wt = sum(g * M[iq[k_]] for g, (_, k_, _) in zip(g_, nb)); M[i] = wt / max(wt.sum(), 1e-9)
            print('UMHANG INNEN WIE AUSSEN', int(inn.sum()), 'Ecken')
    W = {n: {int(i): float(M[i, gi[n]]) for i in np.where(M[:, gi[n]] > 1e-3)[0]} for n in NG}
    for g in list(held.vertex_groups): held.vertex_groups.remove(g)
    for n, d in W.items():
        g = held.vertex_groups.new(name=n)
        for i, w in d.items(): g.add([i], min(1.0, w), 'REPLACE')
    # Runde 2 (Fremdpruefung Tom 34: Jorins schwarze Nadeln aus beiden Achseln): wo ein Hemd Rumpf und Innenseite des Aermels unter der
    # Achsel zu einer Haut verbindet (Kettenhemd), rissen diese Dreiecke auf, sobald der Arm sich gegen den Rumpf bewegt. Unter der
    # Achsel (3 cm unter dem Schultergelenk) fallen Flaechen weg, deren Ecken teils am Arm, teils am Rumpf haengen. Nur mit ACHSEL=1:
    # Fremdpruefung Runde 2: die Oeffnung zeigt sich beim Gehen als schwarzes Loch hinten an der Schulter (Borin, Bram, Jorin, Pim …)
    import bmesh
    ARM = {g.index for g in held.vertex_groups if g.name.startswith(('upperarm', 'lowerarm', 'hand'))}
    TR = {g.index for g in held.vertex_groups if g.name in ('spine_01', 'spine_02', 'spine_03', 'pelvis')}
    shz = min(J['shR'][0].z, J['shL'][0].z) / 100.0 - 0.03
    bm = bmesh.new(); bm.from_mesh(me); dl = bm.verts.layers.deform.active
    def art(v):
        d = v[dl]
        if not d: return None
        g = max(d.items(), key=lambda x: x[1])[0]
        return 'a' if g in ARM else ('t' if g in TR else None)
    weg = [f for f in bm.faces if os.environ.get('ACHSEL') == '1' and f.calc_center_median().z < shz and {art(v) for v in f.verts} >= {'a', 't'}]
    bmesh.ops.delete(bm, geom=weg, context='FACES')   # mit Kanten und Ecken, die sonst niemand nutzt
    bm.to_mesh(me); bm.free(); me.update()
    print('ACHSEL', len(weg), 'Flaechen weg')
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

    def lies(act, takt=None):
        """Posen der fremden Bewegung je Bild (Armatur-Raum, m), Bild 0..n (n = Ende, Schleife: n wie 0); takt: auf n*takt/32
        Bilder gestreckt (Runde 2: jede Figur in ihrem Takt, alle gingen im Gleichschritt)"""
        setze(act); r0, r1 = act.frame_range; n = int(round(r1 - r0))
        m = n if not takt else max(8, int(round(n * takt / 32.0)))
        out = []
        for f in range(m + 1):
            t = r0 + f * n / m
            scn.frame_set(int(math.floor(t)), subframe=t - math.floor(t))
            out.append({b: UP[b].matrix.copy() for b in REIHE} | {'_basis': {b: UP[b].matrix_basis.copy() for b in REIHE}})
        return out

    def gier(Gf, b):
        v = Gf[b].to_3x3() @ (RU[b].to_3x3().inverted() @ Vector((0, -1, 0)))
        return math.degrees(math.atan2(v.x, -v.y))

    def posen(Gs, gerade=False, fackel=None, korr=None, boden=0.0, eng_arm=0.0, eng_bein=0.0, gehen=False, vor=1.0, schritt=1.0, schwung=1.0, schulter=None, rueck=None, mitschwung=0.0):
        """Posen unseres Skeletts je Bild: (Ruhe->Pose je Knochen als Basis, Armatur-Matrizen)"""
        W = Matrix.Identity(4)
        MS = {}   # mitschwung: je Seite und Bild die Drehung des fremden Oberarms gegen die Brust, um ihr Mittel, gedaempft
        if gehen and mitschwung > 0:
            for s_ in 'lr':
                qs = [((Gf['spine_03'].to_3x3() @ RU['spine_03'].to_3x3().inverted()).inverted() @ Gf['upperarm_' + s_].to_3x3()
                       @ RU['upperarm_' + s_].to_3x3().inverted()).to_quaternion() for Gf in Gs]
                qs = [q if q.dot(qs[0]) >= 0 else -q for q in qs]
                qm = Quaternion(np.mean([tuple(q) for q in qs], 0)).normalized()
                MS[s_] = [Quaternion().slerp(q @ qm.inverted(), mitschwung).to_matrix() for q in qs]
                if (ARMH.get(s_.upper()) or ('',))[0] in ('vorn', 'ruecken'):   # Haende gefaltet: beide wippen gleich im Schritt (gegenlaeufig loesten sie sich)
                    n_ = max(1, len(Gs) - 1)
                    MS[s_] = [Matrix.Rotation(math.radians(MIT_WIPPEN * mitschwung * math.sin(4 * math.pi * f_ / n_)), 3, 'X') for f_ in range(len(Gs))]
        if gerade:   # in Ruhe eingedreht: Becken und Brust zurueck zum Betrachter (Runde 2: 70 % liessen ihn seitlich eingedreht)
            W = Matrix.Rotation(math.radians(-float(np.mean([gier(Gf, 'spine_03') for Gf in Gs]))), 4, 'Z')
        res = []
        for f, Gf in enumerate(Gs):
            Go = {b: W @ Gf[b] for b in REIHE}; Bq = Gf['_basis']
            if fackel:   # Finger der linken Hand wie in der Fackel-Ruhe (Griff um den Schaft); Arm unten (eigene Haltung)
                Tf = fackel[f % (len(fackel) - 1)]
                Bq = {b: (Tf['_basis'][b] if b.endswith('_l') else Bq[b]) for b in REIHE}
            PN, BA, ENG, SW = {}, {}, {}, {}
            for b in REIHE:
                p = PAR[b]
                kette = PN[p] @ RM[p].inverted() @ RM[b] if p else RM[b].copy()
                if b in GLIED and b.startswith(('thigh', 'calf', 'foot', 'ball')): rot = Go[b].to_3x3()   # Beine wie die Quelle (Boden, Schritt)
                elif b in GLIED:   # Arme gegen die Brust wie in der Quelle, darueber unsere (gedaempfte) Lage der Brust
                    rot = DELTA(PN, 'spine_03') @ (Go['spine_03'].to_3x3() @ RU['spine_03'].to_3x3().inverted()).inverted() @ Go[b].to_3x3()
                elif b in RUMPF:
                    e_ = (Go[b].to_3x3() @ RU[b].to_3x3().inverted()).to_euler('YZX'); e_.x *= vor
                    rot = e_.to_matrix() @ RM[b].to_3x3()
                else: rot = kette.to_3x3() @ Bq[b].to_3x3()
                if korr and b in korr: rot = korr[b] @ rot
                if (schwung < 1.0 or schulter is not None or rueck is not None) and p and b.startswith(('clavicle', 'upperarm', 'lowerarm', 'hand')):
                    # Armschwung: Schluesselbein und Oberarm gegen die Ruhelage zum Elternknochen, Unterarm und Hand gehen mit
                    org = rot
                    if b[-1] in SW: rot = SW[b[-1]] @ rot
                    if b.startswith(('clavicle', 'upperarm')):
                        Pr = PN[p].to_3x3(); r0 = (RM[p].to_3x3().inverted() @ RM[b].to_3x3()).to_quaternion()
                        rot = Pr @ r0.slerp((Pr.inverted() @ rot).to_quaternion(), schulter if schulter is not None and b[0] == 'c' else schwung).to_matrix()
                    if rueck is not None and b.startswith('upperarm'):
                        # Ellbogen hoechstens rueck (m) hinter der Brustmitte: der Arm schwingt neben dem Schild, nicht ueber ihn
                        Rc = DELTA(PN, 'spine_03'); X_, Y_, Z_ = (Rc @ Vector(a_) for a_ in ((1, 0, 0), (0, 1, 0), (0, 0, 1)))
                        sh_ = kette.translation; v_ = rot @ (RM[b].inverted() @ RM['lowerarm' + b[-2:]]).translation
                        ue = (sh_ + v_ - PN['spine_03'].translation).dot(Y_) - rueck
                        if ue > 0:
                            vy, vz = v_.dot(Y_), v_.dot(Z_); r_ = math.hypot(vy, vz)
                            d_ = math.asin(max(-1.0, min(1.0, (vy - ue) / r_))) - math.atan2(vy, -vz)
                            rot = Matrix.Rotation(d_, 3, X_) @ rot
                    SW[b[-1]] = rot @ org.inverted()
                if schritt < 1.0 and p and b.startswith(('thigh', 'calf', 'foot')):   # Schritt gegen die Ruhelage zum Elternknochen
                    Pr = PN[p].to_3x3(); r0 = (RM[p].to_3x3().inverted() @ RM[b].to_3x3()).to_quaternion()
                    rot = Pr @ r0.slerp((Pr.inverted() @ rot).to_quaternion(), schritt).to_matrix()
                s_ = b[-1]
                if b in ('upperarm_l', 'upperarm_r', 'thigh_l', 'thigh_r'):   # eng: seitliche Spreizung zurueck zur Ruhelage
                    k_ = eng_arm if b[0] == 'u' else eng_bein
                    if k_:
                        Rt = DELTA(PN, 'spine_03' if b[0] == 'u' else 'pelvis')
                        dl = Rt.inverted() @ rot.col[1]; rl = RM[b].to_3x3().col[1]
                        d_ = (math.atan2(rl.x, -rl.z) - math.atan2(dl.x, -dl.z)) * k_
                        ENG[s_ + b[0]] = Matrix.Rotation(-d_, 3, Rt @ Vector((0, 1, 0)))
                key = s_ + ('u' if b.startswith(('upperarm', 'lowerarm', 'hand')) else 't' if b.startswith(('thigh', 'calf', 'foot', 'ball')) else '')
                if b in GLIED and key in ENG: rot = ENG[key] @ rot
                art = ARMH.get(s_.upper()) if b.startswith(('clavicle', 'upperarm', 'lowerarm', 'hand')) else None
                if art and (not gehen or art[0] in IM_GANG):   # leute.json „arme“: Haltung aus rig.py, Brust darueber, Hand starr am Unterarm
                    Rc = DELTA(PN, 'spine_03'); R1, R21 = art[1]
                    rot = Rc @ ({'c': Matrix.Identity(3), 'u': R1}.get(b[0], R21)) @ RM[b].to_3x3()
                    if s_ in MS and b[0] != 'c': rot = Rc @ MS[s_][f] @ Rc.inverted() @ rot
                    if art[0] == 'stab' and b == 'hand_r':   # erst um den Unterarm drehen
                        d_ = rot.col[1].normalized(); a_ = rot @ GRIFF_R
                        pa = a_ - d_ * a_.dot(d_); pu = Vector((0, 0, 1)) - d_ * d_.z
                        if pa.length > 1e-4 and pu.length > 1e-4:
                            pa.normalize(); pu.normalize()
                            if pa.dot(pu) < 0: pa = -pa   # ein Loch hat zwei Enden: kleinste Drehung
                            rot = Matrix.Rotation(math.atan2(pa.cross(pu).dot(d_), pa.dot(pu)), 3, d_) @ rot
                        a_ = rot @ GRIFF_R   # der Unterarm steigt (Faust vor der Brust): den Rest knickt das Handgelenk
                        if a_.z < 0: a_ = -a_
                        rot = a_.rotation_difference(Vector((0, 0, 1))).to_matrix() @ rot
                if fackel and b in ('clavicle_l', 'upperarm_l', 'lowerarm_l', 'hand_l'):
                    # wie alt (rig.py mit_fackel, Runde 5c): Oberarm fast senkrecht, Unterarm steigt 40 Grad, Fackel vor der Schulter;
                    # nur die Drehung der Brust um die Hochachse, damit die Fackel im Rennen nicht mit dem Rumpf nach vorn kippt
                    Rc = DELTA(PN, 'spine_03'); fv = Rc @ Vector((0, -1, 0)); Ry = Matrix.Rotation(math.atan2(fv.x, -fv.y), 3, 'Z')
                    Ru = Matrix.Rotation(math.radians(-10), 3, 'Z') @ Matrix.Rotation(math.radians(2), 3, 'Y') @ Matrix.Rotation(math.radians(-12), 3, 'X')
                    rot = {'clavicle_l': Rc, 'upperarm_l': Ry @ Ru}.get(b, Ry @ Ru @ Matrix.Rotation(math.radians(-120), 3, 'X')) @ RM[b].to_3x3()
                kopf = kette.translation.copy()
                if b == 'pelvis':
                    ru = Go['root'] @ RU['root'].inverted() @ RU['pelvis']
                    kopf = kopf + (Go['pelvis'].translation - ru.translation) * kbein + Vector((0, 0, boden))
                soll = Matrix.Translation(kopf) @ rot.to_4x4()
                BA[b] = kette.inverted() @ soll; PN[b] = soll
            res.append((BA, PN))
        return res

    def DELTA(PN, b):   # Drehung des Knochens gegen unsere Ruhelage (Weltlage)
        return PN[b].to_3x3() @ RM[b].to_3x3().inverted()

    ARMH = {s: v for s, v in (LP.get('_arme') or {}).items()}
    # Feinschliff 3 (Fremdpruefung: beim Wanderstab lag die Hand flach am Stab, die Finger ragten vor ihn): Loch der rechten Faust im
    # Knochen hand_r, wie faust_L (held.gd) gespiegelt; die Faust dreht um den Unterarm, bis es senkrecht steht
    _aL = alt.data.bones['foL-wrL'].matrix_local.to_3x3() @ Vector((-0.358, 0.0, -0.934))
    GRIFF_R = (RM['hand_r'].to_3x3().inverted() @ Vector((-_aL.x, _aL.y, _aL.z))).normalized()

    def sohle(PN):
        pts = [(s, PN[kn + s] @ RM[kn + s].inverted() @ p, r) for s, kn, p, r, j in SOHLE]
        return min(((s, q.z - r, q) for s, q, r in pts), key=lambda x: x[1])

    def ballen(PN):   # je Fuss der Ballen (traegt im Gehen und Rennen am laengsten): (Hoehe der Sohle, Punkt)
        return {s: (q.z - r, q) for s, kn, p, r, j in SOHLE if j == 'ball' for q in [PN[kn + s] @ RM[kn + s].inverted() @ p]}

    def kopf_korr(res, KOPF=KOPF):
        """Kopf (und zu 40 % der Hals) auf KOPF Grad Neigung und die Drehung der Figur (leute.json kopfhaltung)"""
        ni, dr = [], []
        for BA, PN in res:
            v = PN['Head'].to_3x3() @ vorn_kopf
            ni.append(math.degrees(math.atan2(v.z, math.hypot(v.x, v.y)))); dr.append(math.degrees(math.atan2(v.x, -v.y)))
        dn = KOPF - 0.35 * kn - float(np.mean(ni)); dd = kd - float(np.mean(dr))   # Runde 2: 0,7 senkte Liska, Pim, Gwenna den Blick zum Boden
        def R(a):
            return Matrix.Rotation(math.radians(a * dd), 3, 'Z') @ Matrix.Rotation(math.radians(-a * dn), 3, 'X')
        return {'neck_01': R(0.4), 'Head': R(1.0)}, round(dn, 1), round(dd, 1)

    ad = sk.animation_data_create()
    INFO = dict(LP.get('_masse', {}))   # rig.py: Bildmass der Kette
    tor = lies(bpy.data.actions[FACKEL]) if FIGUR == 'held' else None
    for name, quelle, opt in (HELD if FIGUR == 'held' else leute_liste(LP)):
        Gs = lies(bpy.data.actions[quelle], opt.get('takt'))
        fk = tor if opt.get('fackel') else None
        ka = dict(eng_arm=opt.get('eng_arm', 0.0), eng_bein=opt.get('eng_bein', 0.0), gehen=name.startswith(('Gehen', 'Rennen')), vor=opt.get('vor', 1.0), schritt=opt.get('schritt', 1.0), schwung=opt.get('schwung', 1.0), schulter=opt.get('schulter'), rueck=opt.get('rueck'), mitschwung=opt.get('mitschwung', 0.0))
        res = posen(Gs, opt.get('gerade', False), fk, **ka)
        korr, dn, dd = kopf_korr(res, opt.get('kopf', KOPF))
        res = posen(Gs, opt.get('gerade', False), fk, korr, **ka)
        boden = -float(np.percentile([sohle(PN)[1] for BA, PN in res], 10))   # Standfuss auf den Boden (unsere Beine sind kuerzer; Rennen: ohne Flugbilder)
        res = posen(Gs, opt.get('gerade', False), fk, korr, boden, **ka)
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
        INFO['traegt'] = LP['traegt']; INFO['knochen_R'] = 'hand_r'; INFO['griff_R'] = [round(x, 4) for x in g]; INFO['achse_R'] = [round(x, 4) for x in GRIFF_R]
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
