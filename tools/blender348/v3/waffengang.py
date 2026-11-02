# 417 Runde 4 (Chef 01.11., 12:21: Axt Runde 3 „schwebt“; 348.12c, 12:03: fünf Protofactor-Pakete gekauft): Gehen und Rennen je
# Waffenart aus den Paketen statt Arm von Hand. Je Bewegung zauber385.py (Protofactor-Geruest auf das UAL-Geruest des Kaufkoerpers),
# Ausgabe <OUT>/<Name>.glb (Name wie in bewegungen.bin: Gehen_<art>, Rennen_<art>; held_klassen.py GANG=<OUT> nimmt sie auf).
# Danach Messung ohne Bild: Bilder, Laenge, Tempo ohne Gleiten (wie held_klassen.py schritt_tempo), Beckenhub, Anteil ohne Fuss am Boden;
# dazu die Knochen der Quelle, die nicht abgebildet sind (Waffen-, Prop-Knochen: wo die Waffe in der Hand sitzt).
# Aufruf: KAUF=<kaufpakete> ZIEL=<UAL1.glb oder UAL Pro> OUT=<ordner> BL=<bl/bin/python> bl/bin/python -I waffengang.py
import bpy, glob, json, math, os, subprocess, sys

KAUF = os.environ['KAUF']; ZIEL = os.environ['ZIEL']; OUT = os.environ['OUT']; BL = os.environ.get('BL', sys.executable)
HIER = os.path.dirname(os.path.abspath(__file__))
os.makedirs(OUT, exist_ok=True)
# Art (wie tragen.gd ARTEN): Paket, Gehen, Rennen (Archiv 417, 12:21; Sokrates aus den Dateinamen)
# Rennen (Messung 2b, Lauf 41304653466; Spiel 4,27 m/s): die genannten Run* laufen 1,3-2,7 m/s, im Spiel 1,6- bis 2,65-fach
# (4,8-8,5 Schritte/s, hastig). Genommen die Fassung jedes Pakets, die von selbst etwa im Spieltempo laeuft: Sprint2HandMelee 4,63 m/s
# (0,92-fach, 3,7 Schritte/s), SprintHold1hMelee 5,20 (0,82, 3,9), RunFastNormalS&S 4,07 (1,05, 4,2), RunFastBow 3,98 (1,07, 3,0).
# Gehen wie genannt: 0,7-0,8 m/s, im Spiel (2,13 m/s) 2,6- bis 3,1-fach, 3,8-4,7 Schritte/s (heute UAL Walk_Loop 2,2-fach)
GAENGE = {
    'axt': ('2.HANDED', 'WalkForwardNormal2HandMelee', 'Sprint2HandMelee'),
    'einhand': ('1.HANDED', 'WalkForwardHold1hMelee', 'SprintHold1hMelee'),
    # 417 Runde 5 (Chef 01.11., 20:4x: Schild „beim normalen Gehen … ganz einfach an der Seite tragen … so wie er steht“; WalkForwardS&S
    # ist der Kampfgang, Schild vorn): das entspannte Gehen des Pakets, WalkNormal2S&S (0,79 m/s, Messung 2b; WalkNormal1 18 % ohne Boden)
    'schild': ('SWORD.SHIELD', os.environ.get('SCHILD_GEHEN', 'WalkNormal2S&S'), 'RunFastNormalS&S'),
    'bogen': ('BOW.ARROW', 'WalkBow', 'RunFastBow'),
}
VERGLEICHEN = os.environ.get('VERGLEICH', '') == '1'   # Messung 2: alle Vorwaerts-Bewegungen je Paket dazu
# 417 (Chef 02.11., 14:46: Rennen „deutlich zu viel nach vorne gebeugt“, ausser Bogen): VERGLEICH_WORTE=Run nur die Rennclips je Paket,
# Neigung wie beim Bogen (RunFastBow) gesucht
VERGLEICH_WORTE = tuple(w for w in os.environ.get('VERGLEICH_WORTE', 'Walk,Run,Sprint').split(',') if w)


def finde(paket, name):
    alle = [p for p in glob.glob(os.path.join(KAUF, '**', '*.fbx'), recursive=True) + glob.glob(os.path.join(KAUF, '**', '*.FBX'), recursive=True)
            if paket.lower() in p.lower().replace('_', '.')]
    genau = [p for p in alle if os.path.basename(p).lower() in ('humanoid@%s.fbx' % name.lower(),)]
    if genau: return genau[0], alle
    teil = sorted([p for p in alle if name.lower() in os.path.basename(p).lower() and '_rm' not in os.path.basename(p).lower()], key=len)
    return (teil[0] if teil else None), alle


# Schweben im Rennen (Pruefer Film 417, 01.11., 23:0x: Fuesse 7-16 Bildpunkte ueber dem Boden). Lauf 41355090887: zauber385 setzte das
# Becken im Verhaeltnis der Beckenhoehen im ersten Bild (Rennen x1,05-1,10), tiefster Ballen Rennen 8,4-10,6 cm, Gehen 3,9-6,0, Stehen
# 1,5; mit BECKEN=bein (wie Jerry im Kampf, 438a) Rennen -0,4 bis 4,0, Gehen 2,8-5,0. Darum BECKEN=bein fuer alle Gaenge (BECKEN= setzt es ab)
os.environ.setdefault('BECKEN', 'bein')
ergebnis = {}
for art, (paket, geh, renn) in GAENGE.items():
    for wort, name in (('Gehen', geh), ('Rennen', renn)):
        q, alle = finde(paket, name)
        print('PAKET %s: %d FBX' % (paket, len(alle)))
        if not q:
            print('FEHLT %s %s (%s); aehnlich: %s' % (art, wort, name, ', '.join(sorted(os.path.basename(p) for p in alle
                  if any(w in os.path.basename(p) for w in ('Walk', 'Run')))[:24])))
            continue
        ziel = os.path.join(OUT, '%s_%s.glb' % (wort, art))
        r = subprocess.run([BL, '-I', os.path.join(HIER, 'zauber385.py')], env=dict(os.environ, QUELLE=q, ZIEL=ZIEL, NAME='%s_%s' % (wort, art), OUT=ziel),
                           capture_output=True, text=True)
        for z in (r.stdout + r.stderr).splitlines():
            if z.startswith(('ABWEICHUNG', 'ZAUBER385', 'Traceback', 'Error', 'KeyError')) or 'Error' in z: print('  ', z[:300])
        ergebnis['%s_%s' % (wort, art)] = {'quelle': os.path.relpath(q, KAUF), 'da': os.path.exists(ziel)}
        print('GANG %s_%s <- %s %s' % (wort, art, os.path.relpath(q, KAUF), 'gut' if os.path.exists(ziel) else 'FEHLER'))

# Messung 2 (Lauf 41303433929: Rennen je Paket 1,6-2,7 m/s, im Spiel 4,27 m/s, also 1,6- bis 2,65-fach, mit Schild 8,5 Schritte/s):
# alle Vorwaerts-Gehen, -Rennen und -Sprints je Paket (ohne Richtungen, Hocken, Wurzelweg) zum Vergleich nach probe/, nicht nach GANG
VERGLEICH = os.path.join(OUT, 'probe')
os.makedirs(VERGLEICH, exist_ok=True)
for art, (paket, geh, renn) in (GAENGE.items() if VERGLEICHEN else []):
    _, alle = finde(paket, geh)
    namen = sorted({os.path.basename(p)[9:-4] for p in alle if os.path.basename(p).startswith('Humanoid@')
                    and any(w in os.path.basename(p) for w in VERGLEICH_WORTE)
                    and not any(w in os.path.basename(p) for w in ('Left', 'Right', 'Backward', 'Crouch', 'Strafe', '_RM', 'Combat', 'Aim', 'Draw'))})
    print('VORWAERTS %s: %s' % (paket, ', '.join(namen)))
    for n in namen:
        if n in (geh, renn): continue
        q = next((p for p in alle if os.path.basename(p).lower() == ('humanoid@%s.fbx' % n).lower()), None)
        if q is None or 'Bazooka' in n: continue   # Lauf 41303965919: beigepacktes Bazooka-Set, Name nicht eindeutig
        ziel = os.path.join(VERGLEICH, '%s__%s.glb' % (art, n))
        subprocess.run([BL, '-I', os.path.join(HIER, 'zauber385.py')], env=dict(os.environ, QUELLE=q, ZIEL=ZIEL, NAME=n, OUT=ziel), capture_output=True, text=True)
        ergebnis['%s__%s' % (art, n)] = {'quelle': os.path.relpath(q, KAUF), 'da': os.path.exists(ziel), 'datei': ziel}

# Knochen der Quelle, die zauber385 nicht abbildet (einmal je Paket): Waffe, Prop, Griff
for art, (paket, geh, _) in GAENGE.items():
    q, alle = finde(paket, geh)
    if not q: continue
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=q)
    S = next((o for o in bpy.data.objects if o.type == 'ARMATURE'), None)
    if S is None: continue
    frei = [b.name for b in S.data.bones if not any(w in b.name for w in ('Pelvis', 'Spine', 'Neck', 'Head', 'Clavicle', 'UpperArm', 'Forearm', 'Hand',
                                                                          'Thigh', 'Calf', 'Foot', 'Toe', 'Finger'))]
    print('KNOCHEN %s frei: %s' % (paket, ', '.join(frei)[:600]))
    for b in S.data.bones:
        if b.parent and any(w in b.name.lower() for w in ('prop', 'weapon', 'sword', 'shield', 'bow', 'axe')):
            print('  WAFFENKNOCHEN %s an %s, Lage zum Eltern %s' % (b.name, b.parent.name,
                  [round(x, 3) for x in (b.parent.matrix_local.inverted() @ b.matrix_local).translation]))
    props = [os.path.basename(p) for p in alle if 'prop' in os.path.basename(p).lower()]
    print('PROP %s: %s' % (paket, ', '.join(props)))
    # Messung 3: wo sitzt die Waffe in der Hand? Unity-Prefabs und Szenen des Pakets (Text): Eltern der Prop-Objekte, Lage, Drehung
    wurzel = os.path.commonpath([p for p in alle]) if alle else KAUF
    while wurzel != KAUF and os.path.basename(wurzel) != 'Assets' and os.path.dirname(wurzel) != wurzel: wurzel = os.path.dirname(wurzel)
    yaml = [p for p in glob.glob(os.path.join(wurzel, '**', '*'), recursive=True) if p.endswith(('.prefab', '.unity'))]
    print('UNITY %s: %s' % (paket, ', '.join(os.path.relpath(p, wurzel) for p in yaml)[:800]))
    for p in yaml:
        t = open(p, encoding='utf-8', errors='replace').read()
        if 'Prop' not in t: continue
        bloecke = t.split('--- !u!')
        namen = {}
        for b in bloecke:
            kopf = b.split('\n', 1)[0]
            if 'm_Name:' in b and kopf.startswith('1 '): namen[kopf.split('&')[-1].strip()] = b.split('m_Name:')[1].split('\n')[0].strip()
        tf = {}   # Transform-Kennung -> Name des Objekts
        for b in bloecke:
            if b.startswith('4 ') and 'm_GameObject: {fileID:' in b:
                tf[b.split('\n', 1)[0].split('&')[-1].strip()] = namen.get(b.split('m_GameObject: {fileID:')[1].split('}')[0].strip(), '?')
        for b in bloecke:
            if not b.startswith('4 ') or 'm_LocalRotation' not in b: continue
            n = tf.get(b.split('\n', 1)[0].split('&')[-1].strip(), '?')
            if 'Prop' in n or 'Weapon' in n:
                z = lambda k: b.split(k)[1].split('\n')[0].strip() if k in b else '-'
                va = z('m_Father: {fileID:').rstrip('}').strip()
                print('  LAGE %s %s: pos %s rot %s an %s' % (os.path.basename(p), n, z('m_LocalPosition:'), z('m_LocalRotation:'), tf.get(va, va)))


# Messung je fertiger Bewegung auf dem UAL-Geruest (Blick -Y)
def messen(p, aktion=None):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=p)
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    a = bpy.data.actions[aktion] if aktion else next(iter(bpy.data.actions))
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]
    f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
    fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base
    lage = {k: [] for k in ('ball_l', 'ball_r', 'pelvis', 'neck_01')}
    for fr in range(f0, f1 + 1):
        bpy.context.scene.frame_set(fr)
        for k in lage: lage[k].append(arm.matrix_world @ arm.pose.bones[k].head)
    vs, luft, hand = [], 0, []
    for k in ('ball_l', 'ball_r'):
        h = [v.z for v in lage[k]]; tief = min(h)
        for j in range(len(h) - 1):
            if h[j] < tief + 0.03 and h[j + 1] < tief + 0.03: vs.append((lage[k][j].y - lage[k][j + 1].y) * -fps)
    tl = min(v.z for v in lage['ball_l']); tr = min(v.z for v in lage['ball_r'])
    for j in range(len(lage['pelvis'])):
        if lage['ball_l'][j].z > tl + 0.03 and lage['ball_r'][j].z > tr + 0.03: luft += 1
    # Messung 3b (Pruefer 13:3x: Schwert durch Schild, Bogen im Becken): Faeuste je Viertel des Umlaufs, im Koerperraum (vor = -Y,
    # links = +X, hoch = Z, ab Becken), dazu Knoechellinie (Kleinfinger -> Zeigefinger) und Handruecken (Handgelenk -> Mittelfinger)
    def k(v): return '(%+.2f vor %+.2f li %+.2f hoch)' % (-v.y, v.x, v.z)
    for q in range(4):
        fr = f0 + (f1 - f0) * q // 4
        bpy.context.scene.frame_set(fr)
        P = arm.matrix_world @ arm.pose.bones['pelvis'].head
        z, fa = [], []
        for s in ('r', 'l'):
            W = lambda n: arm.matrix_world @ arm.pose.bones[n + '_' + s].head
            faust = (W('index_01') + W('pinky_01')) * 0.5; fa.append(faust)
            z.append('%s Faust %s Knoechel %s Finger %s Unterarm %s' % (s, k(faust - P), k((W('index_01') - W('pinky_01')).normalized()),
                     k((W('middle_01') - W('hand')).normalized()), k((W('hand') - W('lowerarm')).normalized())))
        hand.append('%d/4: %s | %s | Faeuste %.2f m auseinander' % (q, z[0], z[1], (fa[0] - fa[1]).length))
    vs.sort()
    v = max(vs[len(vs) // 2], 0.0) if vs else 0.0
    b = [x.z for x in lage['pelvis']]
    vor = lage['pelvis'][-1].y - lage['pelvis'][0].y
    # Pruefer Film 417 (01.11., 23:0x: „Rennen: die Fuesse kommen nie auf Bodenhoehe … 7 bis 16 Bildpunkte“): tiefster Ballen ueber den Umlauf, cm
    boden = min(min(v.z for v in lage['ball_l']), min(v.z for v in lage['ball_r'])) * 100
    return {'boden_cm': round(boden, 1), 'bilder': f1 - f0 + 1, 's': round((f1 - f0) / fps, 3), 'tempo': round(v, 3), 'hub_cm': round((max(b) - min(b)) * 100, 1),
            'luft_pct': int(100 * luft / len(b)), 'wurzelweg_m': round(-vor, 3), 'hand': hand,
            # Chef 01.11., 13:4x: „der Oberkoerper beim normalen Gehen zum Teil zu weit vorgeneigt“: Becken -> Hals gegen senkrecht, Grad
            # (positiv nach vorn, Blick -Y), Mittel und Hoechstwert ueber den Umlauf
            'neigung': [round(sum(nz) / len(nz), 1), round(max(nz), 1)] if (nz := [math.degrees(math.atan2(-(h - p).y, (h - p).z))
                         for p, h in zip(lage['pelvis'], lage['neck_01'])]) else [0, 0]}


# 417 Neigung (Chef 01.11., 13:4x: „der Oberkoerper beim normalen Gehen zum Teil zu weit vorgeneigt“; Lauf 41311724715: Gehen axt 6,5,
# einhand 7,7, bogen 9,7, schild 13,7 Grad): Gehen je Paket so weit aufrichten (zauber385.py AUFRICHTEN), dass die mittlere Neigung
# dem Stehen (UAL Idle_Loop) plus NEIGUNG_GEHEN Grad gleicht (Lauf 41316709836: UAL Walk_Loop selbst 11,6 Grad, als Ziel zu weit vor;
# Becken -> Hals misst auch die Kruemmung des Rueckens, darum gegen das Stehen); NEIGUNG_ZIEL=<Grad> setzt sie von Hand
NEIGUNG_GEHEN = float(os.environ.get('NEIGUNG_GEHEN', '3'))
try:
    stehen_m = messen(ZIEL, 'Idle_Loop'); stehen_n = stehen_m['neigung'][0]
    print('BODEN Stehen (Idle_Loop): tiefster Ballen %.1f cm' % stehen_m['boden_cm'])
    print('NEIGUNG Stehen (Idle_Loop): %.1f, Gehen ohne Waffe (Walk_Loop): %.1f' % (stehen_n, messen(ZIEL, 'Walk_Loop')['neigung'][0]))
    ziel_n = float(os.environ['NEIGUNG_ZIEL']) if os.environ.get('NEIGUNG_ZIEL') else stehen_n + NEIGUNG_GEHEN
except Exception as e:
    ziel_n = None; print('NEIGUNG Idle_Loop nicht messbar:', e)
print('NEIGUNG Ziel (Stehen + %.1f):' % NEIGUNG_GEHEN, ziel_n)
for art, (paket, geh, _) in GAENGE.items():
    n = 'Gehen_' + art; p = os.path.join(OUT, n + '.glb')
    if ziel_n is None or not os.path.exists(p): continue
    vor = messen(p)['neigung'][0]
    if vor <= ziel_n + 0.5: continue
    q, _ = finde(paket, geh)
    # Lauf 41318025517: 2,7 Grad am starren Ruecken senken Becken -> Hals nur um 2,0 (schild 13,7 auf 11,7, Ziel 11,0);
    # darum nachregeln: Wirkung messen, Winkel um den Rest geteilt durch die Wirkung erhoehen, hoechstens drei Durchgaenge
    winkel, jetzt = vor - ziel_n, vor
    for durchgang in range(3):
        subprocess.run([BL, '-I', os.path.join(HIER, 'zauber385.py')], env=dict(os.environ, QUELLE=q, ZIEL=ZIEL, NAME=n, OUT=p,
                       AUFRICHTEN='%.2f' % winkel), capture_output=True, text=True)
        neu = messen(p)['neigung'][0]
        print('AUFRICHTEN %s: %.1f Grad zurueck, Neigung %.1f -> %.1f (Ziel %.1f)' % (n, winkel, vor, neu, ziel_n))
        if abs(neu - ziel_n) <= 0.3 or vor - neu < 0.1: break
        winkel = min(winkel + (neu - ziel_n) * winkel / (vor - neu), 25.0)
    ergebnis[n]['aufgerichtet'] = round(winkel, 1)

# Gehtempo im Spiel (417 Runde 6, Chef 01.11., 13:4x „schnelles Staxen“): GEHEN_M_S, sonst 1,5 m/s statt 2,13
RENN = 3.68 * 1.16; GEH = float(os.environ.get('GEHEN_M_S', '1.5'))
for n in sorted(ergebnis):
    p = ergebnis[n].get('datei') or os.path.join(OUT, n + '.glb')
    if not os.path.exists(p): continue
    m = messen(p); ergebnis[n].update(m)
    soll = RENN if (n.startswith('Rennen') or any(w in n.split('__')[-1] for w in ('Run', 'Sprint'))) else GEH
    fach = soll / m['tempo'] if m['tempo'] > 0.01 else 0.0
    sps = 2.0 / m['s'] * fach if m['s'] > 0 else 0.0
    print('NEIGUNG %s: Oberkoerper im Mittel %.1f Grad vor, hoechstens %.1f' % (n, m['neigung'][0], m['neigung'][1]))
    print('MESS %s: %d Bilder, %.2f s, Tempo %.2f m/s (im Spiel %.2f-fach, %.1f Schritte/s), Beckenhub %.1f cm, ohne Boden %d %%, Wurzelweg %.2f m'
          % (n, m['bilder'], m['s'], m['tempo'], fach, sps, m['hub_cm'], m['luft_pct'], m['wurzelweg_m']))
    print('BODEN %s: tiefster Ballen %.1f cm' % (n, m['boden_cm']))
    if '__' not in n:
        for h in m['hand']: print('HAND %s %s' % (n, h))
json.dump(ergebnis, open(os.path.join(OUT, 'waffengang.json'), 'w'), indent=1, ensure_ascii=False)
print('WAFFENGANG', sum(1 for e in ergebnis.values() if e.get('da')), 'von', 2 * len(GAENGE))
