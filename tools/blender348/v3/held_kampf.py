# 403 (von Team Tom zu 376.1; Chef 31.10.: nur Modell und Bewegungen): die Kampfbewegungen fuer den Helden je Klasse auf dem
# Kaufkoerper. Der Kaufkoerper ruht in der T-Pose der UAL (bewegungen.glb, held_klassen.py), unsere Kampfbewegungen (kampf.py in
# held.glb: Kampfstehen, Ausholen, Hieb, Stich, Treffer, Ausweichen, Abwehr, Tod) auf unserer Ruhelage mit haengenden Armen. Darum
# hier umgerechnet: jeder Knochen behaelt seine Lage im Raum (Drehung wie in held.glb, beide Gerueste aus der UAL mit denselben
# Knochenachsen: Ruhelagen unterscheiden sich nur durch Schwenk, nie um die eigene Achse, gemessen 31.10.), das Becken seine Hoehe im Verhaeltnis der Beckenhoehen; Knochen, die der Kaufkoerper nicht hat (Scheide, Umhang,
# Rueckenschild), fallen weg. Dazu als Kandidaten aus der gekauften UAL Pro (408: Bestand zuerst; Wahl beim Chef) mit Vorsilbe
# „Pro_“: Sword_Idle, Sword_Attack, Sword_Attack_Standing, Hit_Chest, Hit_Head, Hit_Stomach, Death01, Death02, Dodge_Left, Dodge_Right.
# 406: dazu der gekaufte Satz „Sword & Shield“ (Vorsilbe „SS_“, unten) mit Tempo, Griff und Kontaktzeiten in kampf-bewegungen.json.
# Ergebnis auf dem Geruest der UAL wie bewegungen.glb (Godot uebertraegt beide gleich auf den Helden, figur.gd).
# Pruefung ohne Bild: je Bewegung die groesste Abweichung von Hand, Fuss und Kopf gegen held.glb (auf die Koerpergroesse bezogen).
# Aufruf: SRC=<held.glb aus rig.py> ZIEL=<ordner> KAUF=<kaufpakete> bl/bin/python -I held_kampf.py   -> <ZIEL>/kampf-bewegungen.glb
import bpy, os, sys, json, glob, subprocess, tempfile
from mathutils import Matrix, Quaternion, Vector

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import geruest as GE

SRC = os.environ.get('SRC', os.path.join(os.environ.get('OUT', '/home/user/q376/out'), 'held.glb'))
ZIEL = os.environ.get('ZIEL', os.path.dirname(SRC))
EIGEN = ['Kampfstehen', 'Ausholen', 'Hieb', 'Stich', 'Treffer', 'Ausweichen', 'Abwehr', 'Tod']
PRO = ['Sword_Idle', 'Sword_Attack', 'Sword_Attack_Standing', 'Hit_Chest', 'Hit_Head', 'Hit_Stomach', 'Death01', 'Death02',
       'Dodge_Left', 'Dodge_Right']
PRUEF = ['hand_l', 'hand_r', 'foot_l', 'foot_r', 'Head']

pro = GE.ual_pro()
if not pro: raise SystemExit('UAL Pro fehlt (KAUF): ohne Kaufpakete keine Kampfbewegungen fuer den Kaufkoerper')
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.fps = 30   # wie kampf.py (FPS 30); sonst rechnet der Import die Zeiten in 24 Bilder um
bpy.ops.import_scene.gltf(filepath=pro)
ziel = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in [o for o in bpy.data.objects if o != ziel]: bpy.data.objects.remove(o)
for a in list(bpy.data.actions):
    if a.name in PRO: a.name = 'Pro_' + a.name; a.use_fake_user = True
    else: bpy.data.actions.remove(a)
ziel.name = 'Ziel'
vorher = set(bpy.data.objects)
bpy.ops.import_scene.gltf(filepath=SRC)
quelle = next(o for o in bpy.data.objects if o.type == 'ARMATURE' and o not in vorher)
for o in [o for o in bpy.data.objects if o not in vorher and o != quelle]: bpy.data.objects.remove(o)
quelle.name = 'Quelle'
QW, ZW = quelle.matrix_world.to_3x3(), ziel.matrix_world.to_3x3()


def akt(arm, a):
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]


ZB = ziel.data.bones
REIHE = [b.name for b in ZB if b.name in quelle.data.bones]          # Eltern vor Kindern (Reihenfolge der Knochen)
F = ZB['pelvis'].head_local.z / quelle.data.bones['pelvis'].head_local.z
fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base


def lage_q(pb):   # Drehung des Posenknochens im Raum (Welt), ohne Groesse
    return (QW @ pb.matrix.to_3x3()).normalized()


bericht = {}
ERSTES = {}     # Gelenke im ersten Bild, zum Nachmessen der geschriebenen Datei


def uebertrage(q, a, name, F, pruef=PRUEF, ruhe=False):
    """Bewegung a des Geruests q Bild fuer Bild auf das Ziel: jeder Knochen behaelt seine Lage im Raum, das Becken seinen Ort im
    Verhaeltnis F der Beckenhoehen; schreibt die neue Bewegung „Neu_<name>“ und gibt die groesste Abweichung der Gelenke zurueck"""
    QWq = q.matrix_world.to_3x3()
    akt(q, a)
    if ruhe:     # Quelle ohne Bewegung: Ruhelage
        q.animation_data.action = None
        for pb in q.pose.bones: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0); pb.scale = (1, 1, 1)
    reihe = [b.name for b in ZB if b.name in q.data.bones]
    neu = bpy.data.actions.new('Neu_' + name); neu.use_fake_user = True   # Name erst nach dem Loeschen der Quelle (sonst „Hieb.001“)
    akt(ziel, neu)
    f0, f1 = (1, 2) if ruhe else (int(round(a.frame_range[0])), int(round(a.frame_range[1])))
    weit = 0.0
    for fr in range(f0, f1 + 1):
        bpy.context.scene.frame_set(fr)
        R = {n: (QWq @ q.pose.bones[n].matrix.to_3x3()).normalized() for n in reihe}
        for n in reihe:
            pb = ziel.pose.bones[n]; b = ZB[n]
            Rt = ZW.inverted() @ R[n]                                     # im Raum des Zielgeruests
            if b.parent and b.parent.name in R:
                Lr = b.parent.matrix_local.to_3x3().inverted() @ b.matrix_local.to_3x3()
                Rp = ZW.inverted() @ R[b.parent.name]
                Q = (Lr.inverted() @ Rp.inverted() @ Rt)
            else:
                Q = b.matrix_local.to_3x3().inverted() @ Rt
            pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = Q.to_quaternion(); pb.scale = (1, 1, 1)
            pb.location = (0, 0, 0)
        bpy.context.view_layer.update()
        for n in ('root', 'pelvis'):                                     # Becken: Ort im Verhaeltnis der Beckenhoehen
            if n not in reihe: continue
            t = q.pose.bones[n].matrix.translation * (F if n == 'pelvis' else 1.0)
            pb = ziel.pose.bones[n]; m = pb.matrix.copy(); m.translation = t; pb.matrix = m
            bpy.context.view_layer.update()
        for n in reihe:
            pb = ziel.pose.bones[n]
            pb.keyframe_insert('rotation_quaternion', frame=fr)
            if n in ('root', 'pelvis'): pb.keyframe_insert('location', frame=fr)
        # Pruefung: Gelenke im Raum, auf die Beckenhoehe bezogen, gegen die Quelle (gleiche Groesse)
        for n in pruef:
            qs = QWq @ q.pose.bones[n].head * F; zs = ZW @ ziel.pose.bones[n].head
            weit = max(weit, (qs - zs).length)
        if fr == f0: ERSTES[name] = {n: (ZW @ ziel.pose.bones[n].head).copy() for n in PRUEF}
    bericht[name] = {'bilder': f1 - f0 + 1, 'abweichung_m': round(weit, 3)}
    print('KAMPF UEBERTRAGEN %-18s %3d Bilder, Gelenke hoechstens %.3f m daneben' % (name, f1 - f0 + 1, weit))
    return weit


# „Ruhelage“: unsere Ruhelage (Arme haengend) als ein Bild; figur.gd haengt den Schild in dieser Haltung an, wie kampf.py ihn
# gebaut hat („in der Ruhelage der linken Hand“: Vorderseite nach aussen, oben nach oben)
RUHE = bpy.data.actions.new('Ruhelage'); RUHE.use_fake_user = True
for name in ['Ruhelage'] + EIGEN:
    a = bpy.data.actions.get(name)
    if a is None: print('FEHLT', name); continue
    uebertrage(quelle, a, name, F, ruhe=(name == 'Ruhelage'))


# 406 (Chef 01.11., 13:0x, Archiv 406: „haben wir da jetzt nicht extra Animationen eingekauft?“; neu vorlegen mit Sword & Shield,
# 348.12c): die Bewegungen des gekauften Protofactor-Satzes „Sword & Shield“ mit Vorsilbe „SS_“: Kampfhaltung mit erhobenem Schild,
# Abwehr leicht/mittel/schwer, Paraden, Schildstoss, Treffer mit Schild, Gehen und Rennen mit Schild, Schwerthiebe. Je Bewegung
# zauber385.py (Biped auf das Geruest der UAL, Becken nach Beinlaenge wie 438a), dann wie oben auf das Ziel; ohne Paket nichts.
SS = ['IdleCombat', 'BlockLight', 'BlockMedium1', 'BlockMedium2', 'BlockHeavy1', 'BlockHeavy2', 'ParryHigh1', 'ParryHigh2', 'ParryLow',
      'ParryLeft', 'ParryRight', 'ShieldAttack1', 'ShieldAttack2', 'ShieldAttack3', 'GetHitLightFront', 'GetHitHeavyFront',
      'GetHitLightLeft', 'GetHitLightRight', 'WalkForward', 'RunForward', 'WalkBackwards', 'SwordAttack1', 'SwordAttack2',
      'SwordAttack3']
# Handdrall pruefen: Knoechel von Zeige- und Kleinfinger mit (ein verdrehter Schild faellt sonst erst im Bild auf)
PRUEF_SS = PRUEF + ['index_01_l', 'pinky_01_l', 'index_01_r', 'pinky_01_r']
KAUF = os.environ.get('KAUF', '')
tempo, griff, kontakt = {}, {}, {}


def ss_datei(n):
    f = sorted(glob.glob(os.path.join(KAUF, '**', 'Humanoid@%sS&S.fbx' % n), recursive=True)) if KAUF else []
    return f[0] if f else None


def rahmen(h, m, i, k):
    """Handrahmen wie zauber385.py: x Handgelenk zum Mittelfingerknoechel, z quer aus x und Kleinfinger zum Zeigefinger"""
    x = (m - h).normalized(); z = x.cross(i - k).normalized(); return Matrix((x, z.cross(x), z)).transposed()


if ss_datei('IdleCombat'):
    tmp = tempfile.mkdtemp()
    for n in SS:
        src = ss_datei(n)
        if not src: print('FEHLT SS', n); continue
        out = os.path.join(tmp, n + '.glb')
        env = dict(os.environ, QUELLE=src, ZIEL=pro, NAME='SS_' + n, OUT=out, BECKEN='bein')
        r = subprocess.run([sys.executable, '-I', os.path.join(HIER, 'zauber385.py')], env=env, capture_output=True, text=True)
        if r.returncode or not os.path.exists(out):
            print('FEHLER SS', n, r.stdout[-600:], r.stderr[-600:]); raise SystemExit('Sword & Shield: %s nicht uebertragen' % n)
        print('SS', n, ' '.join(l for l in r.stdout.splitlines() if l.startswith(('ZAUBER385', 'ABWEICHUNG'))))
        vorher = set(bpy.data.objects); va = set(bpy.data.actions)
        bpy.ops.import_scene.gltf(filepath=out)
        q = next(o for o in bpy.data.objects if o.type == 'ARMATURE' and o not in vorher)
        for o in [o for o in bpy.data.objects if o not in vorher and o != q]: bpy.data.objects.remove(o)
        a = next(x for x in bpy.data.actions if x not in va)
        F2 = ZB['pelvis'].head_local.z / q.data.bones['pelvis'].head_local.z
        uebertrage(q, a, 'SS_' + n, F2, pruef=PRUEF_SS)
        bpy.data.objects.remove(q); bpy.data.actions.remove(a)
        # Gehen und Rennen am Ort: Tempo aus dem Fuss, der gerade steht (der tiefere), gegen Fussgleiten in figur.gd
        if n.startswith(('Walk', 'Run')):
            akt(ziel, bpy.data.actions['Neu_SS_' + n]); a2 = ziel.animation_data.action
            v, alt = [], None
            for fr in range(int(a2.frame_range[0]), int(a2.frame_range[1]) + 1):
                bpy.context.scene.frame_set(fr)
                fl, fr_ = (ZW @ ziel.pose.bones['foot_l'].head), (ZW @ ziel.pose.bones['foot_r'].head)
                if alt is not None:
                    seite = 'l' if fl.z < fr_.z else 'r'
                    p0 = alt[0] if seite == 'l' else alt[1]; p1 = fl if seite == 'l' else fr_
                    v.append(((p1 - p0).xy).length * fps)
                alt = (fl, fr_)
            v.sort(); tempo['SS_' + n] = round(v[len(v) // 2], 3)
            print('SS TEMPO %-14s %.2f m/s' % (n, tempo['SS_' + n]))
        # Abwehr, Parade, Hieb, Schildstoss: Kontakt (s ab Beginn) = die Hand, die sich am schnellsten bewegt, ist angekommen (nach der
        # hoechsten Geschwindigkeit erstmals unter 30 %); figur.gd laesst den Schild so im Aufschlag des Angriffs stehen
        if n.startswith(('Block', 'Parry', 'SwordAttack', 'ShieldAttack')):
            akt(ziel, bpy.data.actions['Neu_SS_' + n]); a2 = ziel.animation_data.action
            hp = {'l': [], 'r': []}
            for fr in range(int(a2.frame_range[0]), int(a2.frame_range[1]) + 1):
                bpy.context.scene.frame_set(fr)
                for sd in hp: hp[sd].append(ZW @ ziel.pose.bones['hand_' + sd].head)
            sp = {sd: [(hp[sd][i + 1] - hp[sd][i]).length * fps for i in range(len(hp[sd]) - 1)] for sd in hp}
            sd = max(sp, key=lambda x: max(sp[x])); i0 = sp[sd].index(max(sp[sd])); i = i0
            while i < len(sp[sd]) - 1 and sp[sd][i] > 0.3 * sp[sd][i0]: i += 1
            kontakt['SS_' + n] = round((i + 1) / fps, 3)
            print('SS KONTAKT %-14s %.2f s (Hand %s, Laenge %.2f s)' % (n, kontakt['SS_' + n], sd, (len(hp[sd]) - 1) / fps))
    # Griff: wo der Satz Schild und Schwert haelt (Prefab Protof-Actor@Sword&Shield: SM_ShieldProp an der linken Hand, Ort
    # (0,025, -0,031, 0) m, Drehung (w 0,744, z 0,668); SM_1HandedSwordProp an der rechten (-0,103, 0,024, 0), (w 0,449, x 0,494,
    # y -0,546, z -0,506); Unity links-haendig, darum x gespiegelt). Ausgedrueckt im Handrahmen (oben), Laengen in Handlaengen
    # (Handgelenk bis Mittelfingerknoechel); figur.gd baut denselben Rahmen am Kaufkoerper und haengt unsere Schilde so an.
    # Gemessen 01.11.: Brett 3 cm vor dem Handgelenk, Vorderseite nach vorn (in der Kampfhaltung 0,6 bis 0,76 zur Blickrichtung).
    PROP = {'schild': ('SM_ShieldProp.fbx', 'L', (0.025, -0.031, 0.0), (0.7438508, -4.1723246e-07, 4.2840833e-07, 0.66834575)),
            'schwert': ('SM_1HandedSwordProp.fbx', 'R', (-0.103, 0.024, 0.0), (0.44923505, 0.49373475, -0.54606485, -0.5061888))}
    H = 'humanoid_ '
    for k, (datei, s_, pos, rot) in PROP.items():
        vorher = set(bpy.data.objects); va = set(bpy.data.actions)
        bpy.ops.import_scene.fbx(filepath=sorted(glob.glob(os.path.join(KAUF, '**', datei), recursive=True))[0])
        P = next(o for o in bpy.data.objects if o.type == 'MESH' and o not in vorher)
        pv = [v.co.copy() for v in P.data.vertices]
        bpy.ops.import_scene.fbx(filepath=ss_datei('IdleCombat'))
        S = next(o for o in bpy.data.objects if o.type == 'ARMATURE' and o not in vorher)
        w_, x_, y_, z_ = rot
        T = Matrix.Translation(Vector((-pos[0], pos[1], pos[2])) * 100.0) @ Quaternion((w_, x_, -y_, -z_)).to_matrix().to_4x4()
        if k == 'schild':     # Rueckseite des Bretts in der Mitte: Vorderseite +X (vom Arm weg), Rand = aeusserste 15 %
            rmax = max(Vector((0, v.y, v.z)).length for v in pv)
            punkt = Vector((min(v.x for v in pv if Vector((0, v.y, v.z)).length > 0.85 * rmax), 0, 0)); achsen = (Vector((1, 0, 0)),)
        else:                 # Klinge +Z, Schneide +Y (flach ist X)
            punkt = Vector((0, 0, 0)); achsen = (Vector((0, 0, 1)), Vector((0, 1, 0)))
        a = S.animation_data.action; werte = []
        for fr in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1, 3):
            bpy.context.scene.frame_set(fr)
            g = lambda b: S.matrix_world @ S.pose.bones[H + s_ + ' ' + b].head
            Fs = rahmen(g('Hand'), g('Finger2'), g('Finger1'), g('Finger4')); L = (g('Finger2') - g('Hand')).length
            M = S.matrix_world @ S.pose.bones[H + s_ + ' Hand'].matrix @ T
            M3 = M.to_3x3().normalized()
            e = {'griff': Fs.transposed() @ ((M @ punkt) - g('Hand')) / L}
            for nm, ax in zip(('vorn',) if k == 'schild' else ('klinge', 'schneide'), achsen): e[nm] = Fs.transposed() @ (M3 @ ax).normalized()
            if k == 'schild':     # oben: was in der Kampfhaltung im Brett am weitesten oben liegt
                n_ = M3 @ achsen[0]; u = Vector((0, 0, 1)) - n_ * n_.z; e['oben'] = Fs.transposed() @ u.normalized()
            werte.append(e)
        g0 = {nm: sum((e[nm] for e in werte), Vector()) / len(werte) for nm in werte[0]}
        streu = max((e[nm] - g0[nm]).length for e in werte for nm in e if nm != 'oben')
        if k == 'schild':
            v_ = g0['vorn'].normalized(); o_ = (g0['oben'] - v_ * g0['oben'].dot(v_)).normalized(); g0['vorn'], g0['oben'] = v_, o_
        griff[k] = {nm: [round(c, 4) for c in vv] for nm, vv in g0.items()}
        print('SS GRIFF %s %s (Streuung ueber die Bilder %.4f)' % (k, griff[k], streu))
        if streu > 0.01: raise SystemExit('Griff %s nicht fest an der Hand: %.3f' % (k, streu))
        for o in [o for o in bpy.data.objects if o not in vorher]: bpy.data.objects.remove(o)
        for x in [x for x in bpy.data.actions if x not in va]: bpy.data.actions.remove(x)
else:
    print('ohne Sword & Shield (KAUF): keine SS_-Bewegungen')

bpy.data.objects.remove(quelle)
for a in [a for a in bpy.data.actions if not a.name.startswith(('Neu_', 'Pro_'))]: bpy.data.actions.remove(a)
for a in bpy.data.actions:
    if a.name.startswith('Neu_'): a.name = a.name[4:]
if ziel.animation_data: ziel.animation_data.action = None
for pb in ziel.pose.bones: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
bpy.ops.object.select_all(action='DESELECT'); ziel.select_set(True)
os.makedirs(ZIEL, exist_ok=True)
out = os.path.join(ZIEL, 'kampf-bewegungen.glb')
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True, export_animations=True,
                          export_animation_mode='ACTIONS', export_skins=True, export_force_sampling=True)
# Nachmessen: die geschriebene Datei neu laden (Lauf 31.10.: gleichnamige Quelle „Hieb“ statt „Hieb.001“ exportiert, Arme in T-Pose)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.fps = 30
bpy.ops.import_scene.gltf(filepath=out)
neu = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
fehl = 0.0
for name, soll in ERSTES.items():
    akt(neu, bpy.data.actions[name]); bpy.context.scene.frame_set(int(round(bpy.data.actions[name].frame_range[0])))
    for n, v in soll.items(): fehl = max(fehl, (neu.matrix_world @ neu.pose.bones[n].head - v).length)
print('KAMPF NACHGEMESSEN Datei gegen Rechnung hoechstens %.3f m' % fehl)
if fehl > 0.01: raise SystemExit('kampf-bewegungen.glb weicht ab: %.3f m' % fehl)
json.dump({'bewegungen': sorted(a.name for a in bpy.data.actions), 'uebertragen': bericht, 'becken_faktor': round(F, 4),
           'tempo': tempo, 'griff': griff, 'kontakt': kontakt,
           'ual': os.path.basename(pro)}, open(os.path.join(ZIEL, 'kampf-bewegungen.json'), 'w'), indent=1, ensure_ascii=False)
print('KAMPF BEWEGUNGEN OK', out, os.path.getsize(out))
