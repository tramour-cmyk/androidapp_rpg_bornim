# 348.12 Runde 2 (Chef 26.10., 16:21 „cc0 nochmal“, Archiv): geduckte Grundhaltung für den Goblin auf dem CC0-Gerüst aus den
# Bewegungen der Universal Animation Library (Quaternius, CC0 1.0): Rumpf und Beine zwischen Sword_Idle und Crouch_Idle_Loop
# (GEDUCKT = Anteil der Hocke), Arme aus Sword_Idle, nach vorn gehoben (ARM_R, ARM_L: Grad um die Querachse der Welt), damit Waffe
# und Schild vor dem Körper stehen wie in der eigenen Lauer (goblin.py LAUER). Schreibt eine Kopie der Bibliothek mit der neuen
# Bewegung „Goblin_Lauer_Loop“ (geruest.py liest sie über CC0=<ziel>, goblin.py mit CC0_RUHE=Goblin_Lauer_Loop).
# Runde 2d (Helfer zu 2a–c: Hocke zu flach, 2a Bein gekreuzt; Crouch_Idle_Loop kniet links vorn, rechts unten): HOCKE=ik (Vorgabe)
# nimmt nur Sword_Idle, senkt das Becken auf BECKEN m, stellt die Füße symmetrisch (BREIT m von der Mitte, Versatz VERSATZ m, links
# vorn) flach auf den Boden und beugt die Knie per IK (Knie leicht nach außen, KNIE_AUS), Rumpf RUMPF Grad vor, Hals hebt den Kopf um
# KOPF_AUF davon wieder; HOCKE=misch wie 2a–c.
# Aufruf: python -I ual_lauer.py <cc0-ordner> <ziel-ordner>
import bpy, sys, os, glob, math, shutil
from mathutils import Quaternion, Vector, Matrix

QUELLE, ZIEL = sys.argv[-2], sys.argv[-1]
GEDUCKT = float(os.environ.get('GEDUCKT', '0.55'))
# Runde 7 (Prüfer r6: Faust vor dem Mund in der Lauer): rechter Arm 90° statt 125° gehoben, die Faust auf Brusthöhe
ARM_VOR = {'r': float(os.environ.get('ARM_R', '90')), 'l': float(os.environ.get('ARM_L', '60'))}
UNTEN = ('root', 'pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head',
         'thigh_l', 'calf_l', 'foot_l', 'ball_l', 'thigh_r', 'calf_r', 'foot_r', 'ball_r')
# 348.12 Kobold (Archiv 17:57: Grak, Kobold aufs CC0-Gerüst; Liste „Kobold“ 5: tiefer geduckt als der Goblin, Schnauze
# vorgestreckt): UAL_ART=Kobold schreibt Kobold_Lauer_Loop, Kobold_Pirsch_Loop, Kobold_Hieb mit eigenen Werten (KOBOLD unten);
# KOPF_DREH dreht Hals und Kopf um die Hochachse (Grad, + nach links), damit die Schnauze im Kampfbild seitlich steht wie in der
# eigenen Lauer (goblin.py KDREH)
UAL_ART = os.environ.get('UAL_ART', 'Goblin')
# HIEB_VERSATZ (m, x y z): die Handziele des Hiebs wandern mit der Schulter (Kobold: Schulter 2 cm innen, 6 cm vor, 10 cm tiefer
# als beim Goblin; sonst erreichte die Hand drei Schlüssel um 3–7 cm nicht)
# Runde 2: der Kobold sticht (KOBOLD_STICH unten, Schlüssel für ihn entworfen, darum ohne Versatz)
KOBOLD = dict(BECKEN='0.50', RUMPF='34', KOPF_AUF='1.25', KOPF_DREH='-30', HIEB_TIEF='0.5', HIEB_VERSATZ='0,0,0')
# Grak (Archiv 27.10., 17:57; Liste „Grak“ 5: aufrecht und gedrillt, beim angekündigten Schlag die Axt über dem Kopf): kein
# Hocken (Becken der Quelle), Füße schulterbreit, Großaxt in beiden Händen (GRAK_HALT unten), eigener Zweihandhieb von oben
# Runde 2 (Prüfer r1: geduckt statt aufrecht): das Becken der Quelle ist Sword_Idles Fechterstand (0,73 m, Knie 70° gebeugt, auf
# Grak übertragen 75° und Fersen 14 cm hoch); jetzt 0,87 m wie Idle_Loop (0,88 m, Knie 18°) etwas gesenkt
GRAK = dict(BECKEN='0.87', RUMPF='4', KOPF_AUF='1.0', BREIT='0.15', VERSATZ='0.07', KNIE_AUS='0.08', KNIE_VOR='0.4',
            SCHRITT='1.0', WIPPEN='1.0', GANG_BREIT='0.0', HIEB_ART='grak')
for k_, v_ in {'Kobold': KOBOLD, 'Grak': GRAK}.get(UAL_ART, {}).items(): os.environ.setdefault(k_, v_)
KOPF_DREH = float(os.environ.get('KOPF_DREH', '0'))
NAME = UAL_ART + '_Lauer_Loop'
HOCKE = os.environ.get('HOCKE', 'ik')
ELLE = {'r': float(os.environ.get('ELLE_R', '65')), 'l': float(os.environ.get('ELLE_L', '40'))}
BECKEN = os.environ.get('BECKEN', '0.58')     # „quelle“: Becken wie in Sword_Idle (unten gesetzt)
BREIT = float(os.environ.get('BREIT', '0.21'))
VERSATZ = float(os.environ.get('VERSATZ', '0.12'))
KNIE_AUS = float(os.environ.get('KNIE_AUS', '0.15'))
RUMPF = float(os.environ.get('RUMPF', '25'))
KNIE_VOR = float(os.environ.get('KNIE_VOR', '0.4'))
KOPF_AUF = float(os.environ.get('KOPF_AUF', '1.0'))

f = sorted(glob.glob(os.path.join(QUELLE, '**', 'UAL1_Standard.glb'), recursive=True))
f = [x for x in f if 'Unreal-Godot' in x] or f
src = f[0]
rel = os.path.relpath(src, QUELLE)
dst = os.path.join(ZIEL, rel)
os.makedirs(os.path.dirname(dst), exist_ok=True)
for lz in glob.glob(os.path.join(os.path.dirname(os.path.dirname(src)), 'License*')):
    shutil.copy(lz, os.path.join(os.path.dirname(os.path.dirname(dst)), os.path.basename(lz)))

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
scn = bpy.context.scene
rig = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
PB = rig.pose.bones
for pb in PB: pb.rotation_mode = 'QUATERNION'
A = bpy.data.actions


def setze(act):
    rig.animation_data.action = act
    if hasattr(act, 'slots') and len(act.slots): rig.animation_data.action_slot = act.slots[0]


def lies(act, ph):
    setze(act); a0, a1 = act.frame_range
    scn.frame_set(int(round(a0 + ph * (a1 - a0)))); bpy.context.view_layer.update()
    return {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB}


sw, cr = A['Sword_Idle'], A['Crouch_Idle_Loop']
if BECKEN == 'quelle':
    lies(sw, 0.0); BECKEN = PB['pelvis'].matrix.translation.z - 0.02
BECKEN = float(BECKEN)
n = int(sw.frame_range[1] - sw.frame_range[0])
frames = []
if HOCKE == 'ik':
    # Ziele und Pole (Blick −Y, links +X); Füße flach wie in Sword_Idle, nur Ort neu
    ziele = {}
    for s_ in 'lr':
        z = bpy.data.objects.new('ziel_' + s_, None); scn.collection.objects.link(z)
        pol = bpy.data.objects.new('pol_' + s_, None); scn.collection.objects.link(pol)
        c = PB['calf_' + s_].constraints.new('IK'); c.target = z; c.pole_target = pol; c.chain_count = 2; c.use_tail = True
        c.pole_angle = math.radians(float(os.environ.get('PA_' + s_.upper(), {'l': '-90', 'r': '-120'}[s_])))
        ziele[s_] = (z, pol, c)
    LR = ('thigh_l', 'calf_l', 'foot_l', 'ball_l', 'thigh_r', 'calf_r', 'foot_r', 'ball_r')
    for i in range(n + 1):
        S = lies(sw, i / n)
        for b, (q, l) in S.items():
            PB[b].rotation_quaternion = q; PB[b].location = l
        bpy.context.view_layer.update()
        fuss = {s_: PB['foot_' + s_].matrix.copy() for s_ in 'lr'}
        pv = PB['pelvis'].matrix.translation.copy()
        # Becken senken (Armaturraum = Welt, Matrix Einheit)
        PB['pelvis'].matrix = Matrix.Translation((0, 0, BECKEN - pv.z)) @ PB['pelvis'].matrix
        bpy.context.view_layer.update()
        mx = PB['pelvis'].matrix.translation.x
        for s_, sx, sy in (('l', 1, -1), ('r', -1, 1)):
            z, pol, c = ziele[s_]
            boden = fuss[s_].translation.z
            z.location = (mx + sx * BREIT, pv.y + sy * VERSATZ, boden)
            pol.location = (mx + sx * (BREIT + KNIE_AUS), pv.y + sy * VERSATZ - KNIE_VOR, BECKEN)
        bpy.context.view_layer.update()
        fertig = {b: PB[b].matrix.copy() for b in LR}
        for s_ in 'lr': ziele[s_][2].mute = True
        bpy.context.view_layer.update()
        for b in ('thigh_l', 'calf_l', 'thigh_r', 'calf_r'):
            PB[b].matrix = fertig[b]; bpy.context.view_layer.update()
        for s_ in 'lr':     # Fuß flach wie in Sword_Idle, am Knöchel
            PB['foot_' + s_].matrix = Matrix.Translation(PB['foot_' + s_].matrix.translation) @ fuss[s_].to_3x3().to_4x4()
            bpy.context.view_layer.update()
        # Rumpf vor um die Querachse am spine_01
        pb = PB['spine_01']; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(RUMPF), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
        # Kopf hebt sich wieder (Blick nach vorn statt zu Boden): Hals zurück um KOPF_AUF des Rumpfwinkels
        pb = PB['neck_01']; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-RUMPF * KOPF_AUF), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
        if KOPF_DREH:   # Hals und Kopf je zur Hälfte um die Hochachse der Welt
            for kb in ('neck_01', 'Head'):
                pb = PB[kb]; h = pb.matrix.translation.copy()
                pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(KOPF_DREH / 2), 4, 'Z') @ Matrix.Translation(-h) @ pb.matrix
                bpy.context.view_layer.update()
        frames.append({pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB})
        for s_ in 'lr': ziele[s_][2].mute = False
    # das erste Bild kam aus dem noch nicht eingeschwungenen IK (Ballen rechts 18 cm hoch); die Schleife endet in derselben Stellung
    frames[0] = frames[-1]
    for s_ in 'lr':
        PB['calf_' + s_].constraints.remove(ziele[s_][2])
        bpy.data.objects.remove(ziele[s_][0]); bpy.data.objects.remove(ziele[s_][1])
else:
    for i in range(n + 1):
        ph = i / n
        S, C = lies(sw, ph), lies(cr, ph)
        frames.append({b: ((S[b][0].slerp(C[b][0], GEDUCKT), S[b][1].lerp(C[b][1], GEDUCKT)) if b in UNTEN else S[b]) for b in S})
def richte(b, ziel):     # Knochen b so drehen, dass er zum Punkt ziel zeigt (kleinste Drehung, Rolle bleibt)
    pb = PB[b]; m = pb.matrix.copy(); h = m.translation.copy()
    q = m.col[1].xyz.normalized().rotation_difference((ziel - h).normalized())
    pb.matrix = Matrix.Translation(h) @ q.to_matrix().to_4x4() @ m.to_3x3().to_4x4()
    bpy.context.view_layer.update()


# Grak: die rechte Faust fasst die Axt unter dem Kopf, die linke AXT_LINKS weiter hinten am Stielende (waffen.py greataxe-grak);
# Griffpunkt wie figur.gd _hold: GRIFF m den Handknochen entlang, HANDFL m nach innen. Arme als zwei Glieder zum Handgelenk, das
# Handgelenk gerade; dann die Hand so gedreht, dass der Stiel in der rechten Faust in Richtung r zeigt (KH: Stiel im Raum der
# Hand, aus dem ersten Bild der Lauer, figur.gd legt die Axt dort in GRAK_HALT[1])
# AXT_MASS: die Bibliothek misst bis zum Scheitel etwa 1,46 m, Grak 1,86 m; Abstände an der Axt hier im Maß der Bibliothek
# Runde 2 (grak_arme.py misst: Graks Hals so hoch wie der der Bibliothek, Verhältnis 1,00; Scheitel der Bibliothek 1,65 m): 1,0;
# mit 0,79 lagen die Fäuste 30 statt 38 cm auseinander, auf Grak bog der linke Arm sich nach hinten
AXT_MASS = float(os.environ.get('AXT_MASS', '1.0'))
AXT_LINKS, GRIFF, HANDFL, AXT_KOPF, AXT_ENDE = 0.38 * AXT_MASS, 0.085 * AXT_MASS, 0.03 * AXT_MASS, 0.80 * AXT_MASS, 0.45 * AXT_MASS
WARN = {'n': 0}


def zwei(s_, T, pol):
    S = PB['upperarm_' + s_].matrix.translation.copy(); a, b_ = PB['upperarm_' + s_].length, PB['lowerarm_' + s_].length
    if (T - S).length > (a + b_) * 0.995: WARN['n'] += 1; print('GRAK Hand %s nicht erreicht %.3f' % (s_, (T - S).length - a - b_))
    d = min((T - S).length, (a + b_) * 0.995); u = (T - S).normalized()
    x = (a * a - b_ * b_ + d * d) / (2 * d); hh = math.sqrt(max(a * a - x * x, 0.0))
    p = Vector(pol); v = (p - u * p.dot(u)).normalized()
    richte('upperarm_' + s_, S + u * x + v * hh); richte('lowerarm_' + s_, S + u * d)
    pb = PB['hand_' + s_]; pb.matrix = Matrix.Translation(pb.matrix.translation) @ PB['lowerarm_' + s_].matrix.to_3x3().to_4x4()
    bpy.context.view_layer.update()


def griff(s_):     # Griffpunkt der Faust (Welt)
    pb = PB['hand_' + s_]; innen = Vector((1 if s_ == 'r' else -1, 0, 0))
    return pb.matrix.translation + pb.matrix.col[1].xyz.normalized() * GRIFF + innen * HANDFL


def zweihand(R, r, pol_r, pol_l, KH=None):
    r = Vector(r).normalized(); R = Vector(R)
    for _ in range(2):     # Handgelenk so, dass der Griffpunkt auf R liegt
        zwei('r', R - (griff('r') - PB['hand_r'].matrix.translation), pol_r)
    if KH is not None:     # Stiel in der Faust nach r: Unterarm um seine Achse, dann das Handgelenk
        pb = PB['lowerarm_r']; A_ = pb.matrix.col[1].xyz.normalized(); h = pb.matrix.translation.copy()
        N = (PB['hand_r'].matrix.to_3x3() @ KH).normalized(); pn, pt = N - A_ * N.dot(A_), r - A_ * r.dot(A_)
        if pn.length > 1e-4 and pt.length > 1e-4:
            w = pn.angle(pt) * (1 if A_.dot(pn.cross(pt)) >= 0 else -1)
            pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(w, 4, A_) @ Matrix.Translation(-h) @ pb.matrix
            bpy.context.view_layer.update()
        Rm = PB['hand_r'].matrix.to_3x3(); q = (Rm @ KH).normalized().rotation_difference(r)
        PB['hand_r'].matrix = Matrix.Translation(PB['hand_r'].matrix.translation) @ (q.to_matrix() @ Rm).to_4x4()
        bpy.context.view_layer.update()
    L = griff('r') - r * AXT_LINKS
    for _ in range(2):
        zwei('l', L - (griff('l') - PB['hand_l'].matrix.translation), pol_l)
    return (griff('l') - L).length


# Stehen: rechte Faust vor der Brust rechts, der Stiel steil hinab vor den Bauch links (linke Faust dort), der Kopf über der rechten
# Schulter, die Schneide nach vorn (wie Wache); Punkte zum Becken (Blick −Y, links +X)
GRAK_HALT = ((-0.10, -0.34, 0.42), (-0.30, -0.12, 0.95), (-1.0, 0.4, -0.6), (1.0, 0.2, -0.8))

neu = bpy.data.actions.new(NAME); neu.use_fake_user = True
setze(neu)
for i, P in enumerate(frames):
    for b, (q, l) in P.items():
        PB[b].rotation_quaternion = q; PB[b].location = l
    # Arme nach vorn: Oberarm um die Querachse der Welt (Blick −Y), als Drehung im Knochenraum
    bpy.context.view_layer.update()
    for s in 'lr':
        pb = PB['upperarm_' + s]
        h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-ARM_VOR[s]), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
        # Runde 2e (Helfer 2d: Waffe hängt am Boden, Schild vor den Schienbeinen): Ellbogen beugt den Unterarm nach vorn oben
        pb = PB['lowerarm_' + s]; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-ELLE[s]), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()
    if UAL_ART == 'Grak':
        R_, r_, pr_, pl_ = GRAK_HALT
        ab = zweihand(PB['pelvis'].matrix.translation + Vector(R_), r_, pr_, pl_, KH=None if i == 0 else KH_AXT)
        if i == 0:
            KH_AXT = PB['hand_r'].matrix.to_3x3().inverted() @ Vector(r_).normalized()
            print('GRAK Stehen linke Faust %.3f m vom Stiel' % ab)
    for pb in PB:
        pb.keyframe_insert('rotation_quaternion', frame=i + 1); pb.keyframe_insert('location', frame=i + 1)
tr = rig.animation_data.nla_tracks.new(); tr.name = NAME; st = tr.strips.new(NAME, 1, neu)
if hasattr(st, 'action_slot') and len(neu.slots): st.action_slot = neu.slots[0]
# Prüfwerte wie in den Quellen: Becken, Kopf, Hände gegen das Becken
scn.frame_set(1); bpy.context.view_layer.update()
W = lambda b: rig.matrix_world @ PB[b].head
P0 = W('pelvis')
print('LAUER Becken %.2f Kopf %.2f (vor %.2f) Hand_r %s Hand_l %s' % (P0.z, W('Head').z, P0.y - W('Head').y, tuple(round(x, 2) for x in W('hand_r') - P0), tuple(round(x, 2) for x in W('hand_l') - P0)))
B = []
for f in range(1, n + 2, 5):
    scn.frame_set(f); bpy.context.view_layer.update(); B.append((round(W('ball_l').z, 2), round(W('ball_r').z, 2)))
print('LAUER Ballen je 5 Bilder', B)
# Runde 7: Abstand der Fäuste zum Mund quer zur Blickrichtung der Kampfkamera (in der Figur gemessen, probe.gd „Mess Kamera“)
KAM = Vector((0.40, -0.84, 0.37)).normalized()
scn.frame_set(1); bpy.context.view_layer.update()
MUND = W('Head') + Vector((0, -0.12, 0.05))
quer = lambda p: ((p - MUND) - KAM * (p - MUND).dot(KAM)).length
print('LAUER Faust-Mund quer zur Kamera r %.2f l %.2f m' % (quer(W('hand_r')), quer(W('hand_l'))))
scn.frame_set(1); bpy.context.view_layer.update()
print('LAUER Füße l %s r %s, Knie l %s r %s, Ballen z %.3f %.3f' % tuple([tuple(round(x, 2) for x in W(b) - P0) for b in ('foot_l', 'foot_r', 'calf_l', 'calf_r')] + [W('ball_l').z, W('ball_r').z]))

# Runde 3 (Chef 26.10., 20:29 „cc0 Gehen nachbessern“; Helfer 2h: in Crouch_Fwd_Loop fällt die Hocke zusammen, gebückt wie alte
# Leute, Klinge hängt wie ein Krückstock, Schild am Knie): „Goblin_Pirsch_Loop“ aus Walk_Loop (aufrecht, flüssig) mit dem Unterbau
# der Lauer: Becken auf BECKEN (Wippen der Quelle mal WIPPEN), Füße per IK an ihren Ort, Schritt SCHRITT-mal so lang, je Seite
# GANG_BREIT weiter außen; Oberkörper (Rumpf, Hals, Kopf, Arme bis zu den Fingern) starr wie in der Lauer.
PIRSCH = UAL_ART + '_Pirsch_Loop'
SCHRITT = float(os.environ.get('SCHRITT', '0.8'))
WIPPEN = float(os.environ.get('WIPPEN', '0.6'))
GANG_BREIT = float(os.environ.get('GANG_BREIT', '0.05'))
ARMKETTE = [pb.name for s_ in 'lr' for pb in [PB['clavicle_' + s_]] + list(PB['clavicle_' + s_].children_recursive)]
ARME = {b: PB[b].rotation_quaternion.copy() for b in ARMKETTE}     # Lauer Bild 1 (oben gesetzt)
# erster Versuch mit Rumpf und Hals der Quelle plus RUMPF: Brust anders gedreht als in Sword_Idle, die linke Hand 27 cm weiter außen
OBEN = {b: PB[b].matrix.copy() for b in ('spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head')}
FUSS_L = {s_: PB['foot_' + s_].matrix.copy() for s_ in 'lr'}     # für den Hieb: Anfang und Ende in der Lauer
wk = A['Walk_Loop']; nw = int(wk.frame_range[1] - wk.frame_range[0])
B_W = [lies(wk, i / nw) for i in range(nw + 1)]
LR = ('thigh_l', 'calf_l', 'foot_l', 'ball_l', 'thigh_r', 'calf_r', 'foot_r', 'ball_r')
rig.animation_data.action = None


def stelle(S):
    for b, (q, l) in S.items():
        PB[b].rotation_quaternion = q; PB[b].location = l
    bpy.context.view_layer.update()


hoehen = []
for S in B_W:
    stelle(S); hoehen.append(PB['pelvis'].matrix.translation.z)
mitte = sum(hoehen[:-1]) / nw
ziele = {}
for s_ in 'lr':
    z = bpy.data.objects.new('ziel_' + s_, None); scn.collection.objects.link(z)
    pol = bpy.data.objects.new('pol_' + s_, None); scn.collection.objects.link(pol)
    c = PB['calf_' + s_].constraints.new('IK'); c.target = z; c.pole_target = pol; c.chain_count = 2; c.use_tail = True
    c.pole_angle = math.radians(float(os.environ.get('PA_' + s_.upper(), {'l': '-90', 'r': '-120'}[s_])))
    ziele[s_] = (z, pol, c)
pf = []
for i, S in enumerate(B_W):
    for s_ in 'lr': ziele[s_][2].mute = True
    stelle(S)
    fuss = {s_: PB['foot_' + s_].matrix.copy() for s_ in 'lr'}
    pv = PB['pelvis'].matrix.translation.copy()
    neu_z = BECKEN + WIPPEN * (pv.z - mitte)
    PB['pelvis'].matrix = Matrix.Translation((0, 0, neu_z - pv.z)) @ PB['pelvis'].matrix
    bpy.context.view_layer.update()
    for s_, sx in (('l', 1), ('r', -1)):
        z, pol, c = ziele[s_]; ft = fuss[s_].translation
        z.location = (ft.x + sx * GANG_BREIT, pv.y + SCHRITT * (ft.y - pv.y), ft.z)
        pol.location = (pv.x + sx * (BREIT + KNIE_AUS), pv.y + SCHRITT * (ft.y - pv.y) - KNIE_VOR, neu_z)
        c.mute = False
    bpy.context.view_layer.update()
    fertig = {b: PB[b].matrix.copy() for b in LR}
    for s_ in 'lr': ziele[s_][2].mute = True
    bpy.context.view_layer.update()
    for b in ('thigh_l', 'calf_l', 'thigh_r', 'calf_r'):
        PB[b].matrix = fertig[b]; bpy.context.view_layer.update()
    for s_ in 'lr':     # Fuß in der Neigung der Quelle (Abrollen), am Knöchel
        PB['foot_' + s_].matrix = Matrix.Translation(PB['foot_' + s_].matrix.translation) @ fuss[s_].to_3x3().to_4x4()
        bpy.context.view_layer.update()
    for b in OBEN:     # Oberkörper in der Lage der Lauer (Armaturraum), die Arme hängen daran wie dort
        PB[b].matrix = Matrix.Translation(PB[b].matrix.translation) @ OBEN[b].to_3x3().to_4x4()
        bpy.context.view_layer.update()
    for b in ARMKETTE: PB[b].rotation_quaternion = ARME[b]
    bpy.context.view_layer.update()
    pf.append({pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB})
pf[0] = pf[-1]     # wie die Lauer: das erste Bild aus dem noch nicht eingeschwungenen IK

# Runde 3 (Archiv 348.12 20:29: Film mit Stehen, Gehen, Hieb; beide Gerüste hatten keinen Hieb, der Goblin schnellte nur vor):
# „Goblin_Hieb“ aus Sword_Attack (Ausfallschritt, Schlag von oben), am Anfang und Ende in der Lauer (Gewicht w: Füße, Rumpf, Arme
# wie dort), dazwischen die Quelle; Becken um BECKEN gegen Sword_Idle gesenkt, die Tiefe des Ausfalls HIEB_TIEF-mal.
HIEB = UAL_ART + '_Hieb'
HIEB_TIEF = float(os.environ.get('HIEB_TIEF', '0.6'))
ha = A['Sword_Attack']; nh = int(round(ha.frame_range[1] - ha.frame_range[0]))
stelle(lies(sw, 0.0)); ruhe_z = PB['pelvis'].matrix.translation.z


def gewicht(ph):     # 1 in der Lauer, 0 im Schlag; Ausholen ab 0,05, Schlag ab 0,2, zurück 0,7 bis 0,85
    k = lambda x: x * x * (3 - 2 * x)
    if ph < 0.05 or ph > 0.85: return 1.0
    if ph < 0.2: return 1.0 - k((ph - 0.05) / 0.15)
    if ph > 0.7: return k((ph - 0.7) / 0.15)
    return 0.0


hf = []
for i in range(nh + 1):
    ph = i / nh; w = gewicht(ph)
    for s_ in 'lr': ziele[s_][2].mute = True
    stelle(lies(ha, ph))
    fuss = {s_: PB['foot_' + s_].matrix.copy() for s_ in 'lr'}
    pv = PB['pelvis'].matrix.translation.copy()
    neu_z = BECKEN + HIEB_TIEF * (pv.z - ruhe_z) if pv.z < ruhe_z else BECKEN + (pv.z - ruhe_z)
    PB['pelvis'].matrix = Matrix.Translation((0, 0, neu_z - pv.z)) @ PB['pelvis'].matrix
    bpy.context.view_layer.update()
    for s_, sx in (('l', 1), ('r', -1)):
        z, pol, c = ziele[s_]
        z.location = fuss[s_].translation.lerp(FUSS_L[s_].translation, w)
        pol.location = (pv.x + sx * (BREIT + KNIE_AUS), z.location.y - KNIE_VOR, neu_z)
        c.mute = False
    bpy.context.view_layer.update()
    fertig = {b: PB[b].matrix.copy() for b in LR}
    for s_ in 'lr': ziele[s_][2].mute = True
    bpy.context.view_layer.update()
    for b in ('thigh_l', 'calf_l', 'thigh_r', 'calf_r'):
        PB[b].matrix = fertig[b]; bpy.context.view_layer.update()
    for s_ in 'lr':
        q = fuss[s_].to_quaternion().slerp(FUSS_L[s_].to_quaternion(), w)
        PB['foot_' + s_].matrix = Matrix.Translation(PB['foot_' + s_].matrix.translation) @ q.to_matrix().to_4x4()
        bpy.context.view_layer.update()
    pb = PB['spine_01']; h = pb.matrix.translation.copy()
    pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(RUMPF * w), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()
    pb = PB['neck_01']; h = pb.matrix.translation.copy()
    pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-RUMPF * KOPF_AUF * w), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()
    for s in 'lr':     # Arme wie in der Lauer gehoben, im Schlag frei
        pb = PB['upperarm_' + s]; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-ARM_VOR[s] * w), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
        pb = PB['lowerarm_' + s]; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-ELLE[s] * w), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
    hf.append({pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB})
hf[0] = hf[-1]
# Runde 4 (Helfer Lauf 127: Hieb richtet sich auf, Froschhocke, Waffen vom Gegner weg, Schild über dem Kopf, Klinge schleift;
# Ursache: Sword_Attack schlägt quer von hinten rechts nach vorn links auf Beckenhöhe, Becken 0,63 → 0,46): HIEB_ART=lauer
# (Vorgabe) legt nur Rumpf und rechten Arm der Quelle als Unterschied zu Sword_Idle auf die Lauer (je Knochen im eigenen Raum),
# Becken, Beine, linker Arm mit Schild bleiben wie in der Lauer; HIEB_ART=quelle wie Runde 3.
HIEB_ART = os.environ.get('HIEB_ART', 'eigen')
HIEB_ADD = ('spine_01', 'spine_02', 'spine_03', 'clavicle_r', 'upperarm_r', 'lowerarm_r', 'hand_r')
HIEB_STAERKE = float(os.environ.get('HIEB_STAERKE', '1.0'))
if HIEB_ART == 'lauer':
    L0 = lies(neu, 0.0); I0 = lies(sw, 0.0); rig.animation_data.action = None
    hf = []
    for i in range(nh + 1):
        S = lies(ha, i / nh); rig.animation_data.action = None
        P = dict(L0)
        for b in HIEB_ADD:
            d = I0[b][0].inverted() @ S[b][0]
            d = Quaternion().slerp(d, HIEB_STAERKE)
            P[b] = (L0[b][0] @ d, L0[b][1])
        hf.append(P)
    hf[0] = hf[-1] = L0
# Runde 5 (Prüfer zu Runde 4: Sword_Attack ist ein Stoß, holt hinter dem Kopf aus, schlägt tief an den Helden vorbei, Rumpf richtet
# sich auf, Schild über den Kopf, 1,1 s, danach starr; UAL hat sonst nur Punch_*): HIEB_ART=eigen (Vorgabe) baut den Hieb aus
# eigenen Schlüsselbildern auf der Lauer; Becken, Beine und Füße bleiben wie dort, nur Rumpf, Hals und rechter Arm drehen.
# Je Schlüssel: Rumpf um die Hochachse (DREH, + = rechte Schulter vor) und vor (VOR), der Hals hält den Blick; Hand an einen Ort
# (Welt, m, Blick −Y, links +X), Ellbogen zur Seite POL (zwei Knochen gerechnet, nicht Blenders IK); die Klinge (in der Lauer wie
# figur.gd _hold: −innen 0,1, oben 0,6, vorn 0,8) zeigt in KLINGE. Zeiten in s (die Bibliothek hat 24 Bilder je s, geruest.py liest
# nach der Zeit und legt 30 je s ab): Ausholen
# 0,25 s länger als der Schlag 0,14 s, Aufschlag bei 0,42 s (figur.gd: der Goblin ist dann am Ziel und hält bis 0,58 s),
# Halt 0,06 s, zurück bis 0,80 s (DESIGN-ABNAHME: Säbelhieb 0,8 s, schwerer 0,9 s).
HIEB_KLINGE_LAUER = Vector((-0.1, -0.8, 0.6)).normalized()
HIEB_SCHLUESSEL = [     # Zeit, Rumpf DREH, VOR (Grad), Hand, Ellbogen-Pol, Klinge; None = Lauer
    (0.0, None),
    # Runde 7 (Chefsache 34812-goblin-hieb, Chef 27.10., 09:49 „CC0“, Befunde der fremden Prüfung r6): Ausholen höher und neben
    # dem Kopf (Hand 0,47 m über der Schulter, 0,25 m nach außen; r6 hinter dem Kopf, Klinge nach hinten am Schirm senkrecht), Klinge
    # schräg nach hinten oben außen; die Hand bleibt im Schlag über Kopfhöhe, bis die Klinge vorn ist (0,36 s; r6 waagrecht auf
    # Kopfhöhe wie ein Stich); Aufschlag mit gestrecktem Arm vor der Schulter, Klinge zum Gegner, im Spiel gemessen 20° abwärts (r6 37°; geruest.py neigt sie um 12° mehr als hier entworfen)
    (0.20, -20, -8, (-0.36, 0.10, 1.60), (-1.0, 0.2, 0.3), (-0.40, 0.45, 0.80)),
    (0.24, -21, -9, (-0.37, 0.11, 1.61), (-1.0, 0.2, 0.3), (-0.42, 0.47, 0.78)),
    (0.31, -6, 2, (-0.30, -0.18, 1.55), (-1.0, -0.2, 0.2), (-0.35, -0.45, 0.82)),
    (0.36, 2, 6, (-0.20, -0.40, 1.40), (-0.9, -0.1, -0.3), (-0.20, -0.80, 0.56)),
    (0.40, 6, 12, (-0.10, -0.58, 1.02), (-0.7, 0.0, -0.7), (0.0, -0.99, -0.15)),
    (0.46, 7, 13, (-0.09, -0.59, 1.00), (-0.7, 0.0, -0.7), (0.02, -0.98, -0.19)),
    (0.80, None)]
# im fertigen Goblin (geruest.py überträgt auf sein Gerüst) stand die Klinge in Ausholen und Aufschlag 24–27° weiter gegen den
# Uhrzeigersinn (von oben) als hier entworfen, in der Lauer genau; HIEB_GIER dreht den Entwurf um so viel zurück (gemessen im GLB)
HIEB_GIER = float(os.environ.get('HIEB_GIER', '-25'))
HIEB_VERSATZ = Vector([float(c) for c in os.environ.get('HIEB_VERSATZ', '0,0,0').split(',')])
HIEB_ROLLE = os.environ.get('HIEB_ROLLE', '1') == '1'
HIEB_WEG = {0.0: 'weich', 0.20: 'linear', 0.24: 'an', 0.31: 'linear', 0.36: 'linear', 0.40: 'weich', 0.46: 'weich'}     # Verlauf vom Schlüssel bis zum nächsten
# Kobold Runde 2 (Prüfer r1: beim Aufschlag die Speerspitze im Boden, Film 3,9 s der Speer waagerecht auf Hüfthöhe; nachgerechnet wie
# figur.gd: im Hieb von oben fährt der Speer 0,20–0,47 s durch den Kopf, 12–46 Ecken): Speer und Dolch stechen. Die Hand zieht
# neben die Hüfte zurück (ausgeholt 0,18–0,24 s), stößt vor der Brust nach vorn (0,34 s), hält beim Aufschlag gestreckt (0,43 s);
# der Speer zeigt zum Gegner, die Spitze leicht hoch (der Gegner ist doppelt so groß; im Kobold 7° flacher als entworfen). Hand in der Lauer (-0,27, -0,30, 0,80)
KOBOLD_STICH = [
    (0.0, None),
    (0.18, -8, -2, (-0.30, -0.06, 0.78), (-1.0, 0.3, -0.3), (-0.06, -0.93, 0.36)),
    (0.24, -9, -3, (-0.31, -0.03, 0.79), (-1.0, 0.3, -0.3), (-0.06, -0.93, 0.36)),
    (0.34, 10, 8, (-0.20, -0.62, 0.92), (-0.9, 0.0, -0.4), (-0.02, -0.94, 0.34)),
    (0.43, 12, 10, (-0.18, -0.66, 0.93), (-0.9, 0.0, -0.4), (-0.02, -0.94, 0.33)),
    (0.52, 12, 10, (-0.18, -0.66, 0.93), (-0.9, 0.0, -0.4), (-0.02, -0.94, 0.33)),
    (0.80, None)]
if UAL_ART == 'Kobold':
    HIEB_SCHLUESSEL = KOBOLD_STICH
    HIEB_WEG = {0.0: 'weich', 0.18: 'linear', 0.24: 'an', 0.34: 'weich', 0.43: 'linear', 0.52: 'weich'}


def drehe(b, achse, grad):     # Knochen b um eine Weltachse an seinem Kopf
    pb = PB[b]; h = pb.matrix.translation.copy()
    pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(grad), 4, achse) @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()


def hieb_pose(dreh, vor, hand, pol, klinge):
    stelle(L0)
    drehe('spine_01', 'Z', dreh); drehe('spine_01', 'X', vor)
    drehe('neck_01', 'X', -vor * KOPF_AUF); drehe('neck_01', 'Z', -dreh * 0.7)
    # Runde 5b (Prüfer: der Schild rutscht mit dem Rumpf vor Hüfte und Schritt): der Schildarm behält seine Lage aus der Lauer
    pb = PB['upperarm_l']; pb.matrix = Matrix.Translation(pb.matrix.translation) @ SCHILDARM.to_3x3().to_4x4()
    bpy.context.view_layer.update()
    S = PB['upperarm_r'].matrix.translation.copy(); T = Vector(hand) + HIEB_VERSATZ
    print('HIEB_SCHULTER', tuple(round(c, 2) for c in S), 'Kopf', tuple(round(c, 2) for c in PB['Head'].matrix.translation), 'Arm', round(PB['upperarm_r'].length + PB['lowerarm_r'].length, 2))
    a, b_ = PB['upperarm_r'].length, PB['lowerarm_r'].length
    if (T - S).length > (a + b_) * 0.995: print('HIEB_EIGEN Hand nicht erreicht', round((T - S).length - a - b_, 3))
    d = min((T - S).length, (a + b_) * 0.995); u = (T - S).normalized(); T = S + u * d
    x = (a * a - b_ * b_ + d * d) / (2 * d); hh = math.sqrt(max(a * a - x * x, 0.0))
    p = Vector(pol); v = (p - u * p.dot(u)).normalized()
    richte('upperarm_r', S + u * x + v * hh); richte('lowerarm_r', T)
    # Runde 7 (Knick im Handgelenk bis 80°): der Unterarm dreht sich um seine Achse (Pronation), bis die Klinge ohne Handgelenk in
    # derselben Ebene liegt wie die gewollte; das Handgelenk biegt danach nur noch den Unterschied der Neigung
    ziel = Matrix.Rotation(math.radians(HIEB_GIER), 3, 'Z') @ Vector(klinge).normalized()
    pb = PB['lowerarm_r']; A = pb.matrix.col[1].xyz.normalized(); h = pb.matrix.translation.copy()
    N = (PB['hand_r'].matrix.to_3x3() @ KH).normalized()
    pn, pt = N - A * N.dot(A), ziel - A * ziel.dot(A)
    if pn.length > 1e-4 and pt.length > 1e-4 and HIEB_ROLLE:
        w = pn.angle(pt) * (1 if A.dot(pn.cross(pt)) >= 0 else -1)
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(w, 4, A) @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
    R = PB['hand_r'].matrix.to_3x3()
    q = (R @ KH).normalized().rotation_difference(Matrix.Rotation(math.radians(HIEB_GIER), 3, 'Z') @ Vector(klinge).normalized())
    PB['hand_r'].matrix = Matrix.Translation(PB['hand_r'].matrix.translation) @ (q.to_matrix() @ R).to_4x4()
    bpy.context.view_layer.update()
    return {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB}


if HIEB_ART == 'eigen':
    for s_ in 'lr': ziele[s_][2].mute = True
    L0 = lies(neu, 0.0); rig.animation_data.action = None
    stelle(L0)
    KH = PB['hand_r'].matrix.to_3x3().inverted() @ HIEB_KLINGE_LAUER     # Klinge im Raum des Handknochens
    SCHILDARM = PB['upperarm_l'].matrix.copy()
    K = [(k[0], L0 if k[1] is None else hieb_pose(*k[1:])) for k in HIEB_SCHLUESSEL]
    weg = {'weich': lambda s: s * s * (3 - 2 * s), 'linear': lambda s: s, 'an': lambda s: s ** 1.3, 'aus': lambda s: 1 - (1 - s) ** 2}
    hf = []
    FPS_Q = scn.render.fps / scn.render.fps_base
    for i in range(int(round(K[-1][0] * FPS_Q)) + 1):
        t = min(i / FPS_Q, K[-1][0])
        j = max(j for j in range(len(K) - 1) if K[j][0] <= t) if t < K[-1][0] else len(K) - 2
        (f0, P0_), (f1, P1_) = K[j], K[j + 1]
        s = weg[HIEB_WEG[f0]](min(1.0, (t - f0) / (f1 - f0)))
        P = {}
        for b in P0_:
            q0, q1 = P0_[b][0], P1_[b][0]
            if q0.dot(q1) < 0: q1 = -q1
            P[b] = (q0.slerp(q1, s), P0_[b][1].lerp(P1_[b][1], s))
        hf.append(P)
    hf[0] = hf[-1] = L0
    # Prüfwerte je Bild: Hand, Spitze (Säbel 0,52 m am Goblin, hier 1,8/1,08-fach), Spitze über dem Becken, Abstand der Klinge zum
    # Kopf, Knick im Handgelenk gegen den Unterarm
    LANG = 0.65 * 0.8 * 1.8 / 1.08
    for i, P in enumerate(hf):
        stelle(P)
        H = PB['hand_r'].matrix.translation.copy(); kl = (PB['hand_r'].matrix.to_3x3() @ KH).normalized(); sp = H + kl * LANG
        kopf = PB['Head'].matrix.translation + PB['Head'].matrix.col[1].xyz.normalized() * 0.1
        t = max(0.0, min(LANG, (kopf - H).dot(kl))); ab = (H + kl * t - kopf).length
        knick = math.degrees(PB['lowerarm_r'].matrix.col[1].xyz.normalized().angle(PB['hand_r'].matrix.col[1].xyz.normalized()))
        print('HIEB_EIGEN %.2f s Hand %s Spitze %s Klinge %s Kopf %.2f Knick %3.0f Unterarm %s Klinge-Unterarm %3.0f' % (i / FPS_Q,
              tuple(round(c, 2) for c in H), tuple(round(c, 2) for c in sp), tuple(round(c, 2) for c in kl), ab, knick,
              tuple(round(c, 2) for c in PB['lowerarm_r'].matrix.col[1].xyz.normalized()),
              math.degrees(PB['lowerarm_r'].matrix.col[1].xyz.normalized().angle(kl))))
# Grak: Zweihandhieb von oben (DESIGN-ABNAHME: schwerer Hieb 0,9 s): Axt über den Kopf, das Blatt hinter dem Rücken (0,30 s, gehalten
# bis 0,38 s: so steht er beim angekündigten schweren Schlag, Liste „Grak“ 5), über den Kopf nach vorn (0,50 s), Aufschlag vor ihm
# tief (0,58 s), Halt, zurück in die Wache bis 0,90 s. Je Schlüssel: Rumpf DREH, VOR (Grad), rechte Faust zum Becken (m), Stiel r
# (von der rechten Faust zum Kopf der Axt), Ellbogen-Pole rechts, links; None = Stehen
GRAK_HIEB = [
    (0.0, None),
    # erster Lauf: beim Heben und Schlagen strich der Stiel 4–5 cm am Gesicht vorbei, beim Zurück 8 cm an der Brust; die Fäuste
    # gehen darum vor dem Gesicht hoch (0,15 s) und vor ihm hinab (0,54 s), zurück vor der Brust (0,78 s)
    # Runde 2 (auf Graks Gerüst gemessen, stiel.py: beim Heben 0,23–0,27 s der Stiel durch Hinterkopf und Zopf, 165–205 Ecken; beim
    # Schlag 0,47–0,70 s das Stielende 3–9 Ecken in der Brustplatte): ausholen über der rechten Schulter neben dem Kopf, im Schlag die
    # Fäuste weiter vor und der Stiel erst steil, beim Aufschlag die Fäuste auf Hüfthöhe, der Stiel steiler (die linke Faust lag sonst in der Brust)
    (0.15, -4, 0, (-0.14, -0.30, 0.82), (-0.12, -0.05, 0.99), (-1.0, 0.2, -0.2), (1.0, 0.2, -0.4)),
    (0.22, -7, -3, (-0.22, -0.16, 0.98), (-0.10, 0.40, 0.91), (-1.0, 0.1, 0.1), (1.0, 0.1, 0.0)),
    (0.30, -10, -6, (-0.20, 0.02, 1.00), (0.0, 0.75, 0.66), (-1.0, 0.1, 0.3), (1.0, 0.1, 0.3)),
    (0.38, -12, -8, (-0.20, 0.04, 1.02), (0.0, 0.80, 0.60), (-1.0, 0.1, 0.3), (1.0, 0.1, 0.3)),
    # zweiter Lauf (0,46 s Stiel 7 cm durch den Scheitel): der Stiel steht senkrecht erst, wenn die Fäuste vor dem Gesicht sind
    (0.44, -2, 8, (-0.14, -0.36, 0.98), (-0.05, -0.05, 1.0), (-1.0, 0.1, 0.0), (1.0, 0.1, 0.0)),
    (0.50, 0, 10, (-0.07, -0.46, 0.90), (0.0, -0.25, 0.97), (-1.0, 0.0, 0.0), (1.0, 0.0, 0.0)),
    (0.54, 3, 14, (-0.05, -0.62, 0.58), (0.0, -0.80, 0.60), (-1.0, 0.0, -0.2), (1.0, 0.0, -0.2)),
    (0.56, 4, 17, (-0.05, -0.68, 0.36), (0.0, -1.0, 0.0), (-1.0, 0.0, -0.3), (1.0, 0.0, -0.3)),
    (0.58, 6, 20, (-0.05, -0.58, 0.14), (0.0, -0.82, -0.57), (-1.0, 0.0, -0.4), (1.0, 0.0, -0.4)),
    (0.66, 6, 20, (-0.05, -0.58, 0.12), (0.0, -0.80, -0.60), (-1.0, 0.0, -0.4), (1.0, 0.0, -0.4)),
    # Runde 2 (auf Graks Gerüst gemessen, grak_arme.py: beim Zurück 0,71 s der Stiel 2 cm durch die Brust; der Stiel drehte von
    # vorn unten nach oben, das Stielende schwang durch den Rumpf): erst den Stiel vor dem Körper aufrichten, dann die Fäuste zurück
    (0.72, 4, 14, (-0.08, -0.58, 0.36), (-0.1, -0.55, 0.83), (-1.0, 0.1, -0.4), (1.0, 0.1, -0.5)),
    (0.78, 3, 10, (-0.12, -0.50, 0.50), (-0.2, -0.45, 0.87), (-1.0, 0.3, -0.5), (1.0, 0.2, -0.7)),
    (0.90, None)]
GRAK_WEG = {0.0: 'weich', 0.15: 'linear', 0.22: 'linear', 0.30: 'linear', 0.38: 'an', 0.44: 'linear', 0.50: 'linear', 0.54: 'linear', 0.56: 'linear', 0.58: 'weich', 0.66: 'weich', 0.72: 'linear', 0.78: 'weich'}
if HIEB_ART == 'grak':
    for s_ in 'lr': ziele[s_][2].mute = True
    L0 = lies(neu, 0.0); rig.animation_data.action = None

    def grak_pose(dreh, vor, R, r, pol_r, pol_l):
        stelle(L0)
        drehe('spine_01', 'Z', dreh); drehe('spine_01', 'X', vor)
        drehe('neck_01', 'X', -vor * KOPF_AUF); drehe('neck_01', 'Z', -dreh * 0.7)
        ab = zweihand(PB['pelvis'].matrix.translation + Vector(R), r, pol_r, pol_l, KH=KH_AXT)
        if ab > 0.03: print('GRAK linke Faust %.3f m vom Stiel' % ab)
        return {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB}
    # Zwischenbilder aus den gemischten Werten der Schlüssel neu gestellt (erst gemischte Glieder: die linke Faust bis 26 cm vom
    # Stiel); Stehen = GRAK_HALT ohne Drehung
    ST = (0, 0) + GRAK_HALT
    K = [(k[0], ST if k[1] is None else k[1:]) for k in GRAK_HIEB]
    weg = {'weich': lambda s: s * s * (3 - 2 * s), 'linear': lambda s: s, 'an': lambda s: s ** 1.3}
    FPS_Q = scn.render.fps / scn.render.fps_base
    hf = []
    for i in range(int(round(K[-1][0] * FPS_Q)) + 1):
        t = min(i / FPS_Q, K[-1][0])
        j = max(j for j in range(len(K) - 1) if K[j][0] <= t) if t < K[-1][0] else len(K) - 2
        (f0, A0), (f1, A1) = K[j], K[j + 1]
        s = weg[GRAK_WEG[f0]](min(1.0, (t - f0) / (f1 - f0)))
        m = [a0 + (a1 - a0) * s for a0, a1 in zip(A0[:2], A1[:2])] + [Vector(a0).lerp(Vector(a1), s) for a0, a1 in zip(A0[2:], A1[2:])]
        m[3] = Vector(A0[3]).normalized().slerp(Vector(A1[3]).normalized(), s) if Vector(A0[3]).normalized().dot(Vector(A1[3]).normalized()) > -0.99 else m[3]
        hf.append(grak_pose(*m))
    hf[0] = hf[-1] = L0
    # Prüfwerte je Bild: Abstand der linken Faust zum Stiel (die Glieder sind zwischen den Schlüsseln gemischt), Kopf der Axt
    # (0,80 m vor der rechten Faust) über dem Boden und vor dem Becken, kleinster Abstand des Stiels zum Kopf
    for i, P in enumerate(hf):
        stelle(P)
        G = griff('r'); r = (PB['hand_r'].matrix.to_3x3() @ KH_AXT).normalized(); L = G - r * AXT_LINKS
        kp = G + r * AXT_KOPF

        def nah(p_):     # kleinster Abstand des Stiels (Ende bis Kopf der Axt) zum Punkt p_
            t = max(-AXT_ENDE, min(AXT_KOPF, (p_ - G).dot(r))); return (G + r * t - p_).length
        kopf = PB['Head'].matrix.translation + PB['Head'].matrix.col[1].xyz.normalized() * 0.08
        brust = PB['spine_03'].matrix.translation
        print('GRAK_HIEB %.2f s Faust links %.3f Axtkopf z %.2f vor %.2f; Stiel zu Kopf %.2f, zu Brust %.2f' % (i / FPS_Q, (griff('l') - L).length, kp.z, PB['pelvis'].matrix.translation.y - kp.y, nah(kopf), nah(brust)))
for s_ in 'lr':
    PB['calf_' + s_].constraints.remove(ziele[s_][2])
    bpy.data.objects.remove(ziele[s_][0]); bpy.data.objects.remove(ziele[s_][1])
for NM, FR in ((PIRSCH, pf), (HIEB, hf)):
    pa = bpy.data.actions.new(NM); pa.use_fake_user = True
    setze(pa)
    for i, P in enumerate(FR):
        for b, (q, l) in P.items():
            PB[b].rotation_quaternion = q; PB[b].location = l
            PB[b].keyframe_insert('rotation_quaternion', frame=i + 1); PB[b].keyframe_insert('location', frame=i + 1)
    tr = rig.animation_data.nla_tracks.new(); tr.name = NM; st = tr.strips.new(NM, 1, pa)
    if hasattr(st, 'action_slot') and len(pa.slots): st.action_slot = pa.slots[0]
setze(bpy.data.actions[HIEB])
B = []
for f in range(1, nh + 2, 3):
    scn.frame_set(f); bpy.context.view_layer.update()
    B.append((round(W('pelvis').z, 2), round(W('ball_l').z, 2), round(W('ball_r').z, 2), tuple(round(x, 2) for x in W('hand_r') - W('pelvis'))))
print('HIEB je 3 Bilder (Becken, Ballen l, r, Hand_r gegen Becken)', B)
setze(bpy.data.actions[PIRSCH])
B = []
for f in range(1, nw + 2, 4):
    scn.frame_set(f); bpy.context.view_layer.update()
    B.append((round(W('pelvis').z, 2), round(W('ball_l').z, 2), round(W('ball_r').z, 2), round(W('ball_l').y - W('ball_r').y, 2)))
print('PIRSCH je 4 Bilder (Becken, Ballen l, r, Schritt)', B)
scn.frame_set(1); bpy.context.view_layer.update(); P0 = W('pelvis')
K = []
for f in range(1, nw + 2, 8):
    scn.frame_set(f); bpy.context.view_layer.update()
    K.append(tuple(round((W('calf_' + s_) - (W('thigh_' + s_) + W('foot_' + s_)) / 2).y, 2) for s_ in 'lr'))
print('PIRSCH Knie vor der Linie Hüfte-Knöchel (−y = vorn) je 8 Bilder', K)
scn.frame_set(1); bpy.context.view_layer.update()
print('PIRSCH Kopf %.2f (vor %.2f) Hand_r %s Hand_l %s' % (W('Head').z, P0.y - W('Head').y, tuple(round(x, 2) for x in W('hand_r') - P0), tuple(round(x, 2) for x in W('hand_l') - P0)))
# übrige Bewegungen wieder als NLA-Spuren (so liest sie geruest.py wie aus der Quelle)
rig.animation_data.action = None
for a in list(A):
    if a.name in (NAME, PIRSCH, HIEB) or any(t.name == a.name for t in rig.animation_data.nla_tracks): continue
    t = rig.animation_data.nla_tracks.new(); t.name = a.name; s_ = t.strips.new(a.name, int(a.frame_range[0]), a)
    if hasattr(s_, 'action_slot') and len(a.slots): s_.action_slot = a.slots[0]
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_animations=True, export_animation_mode='NLA_TRACKS', export_skins=True)
print('UAL', dst, os.path.getsize(dst))
