# 417 Runde 4 (Chef 01.11., 12:21: Axt Runde 3 „schwebt“; 348.12c, 12:03: fünf Protofactor-Pakete gekauft): Gehen und Rennen je
# Waffenart aus den Paketen statt Arm von Hand. Je Bewegung zauber385.py (Protofactor-Geruest auf das UAL-Geruest des Kaufkoerpers),
# Ausgabe <OUT>/<Name>.glb (Name wie in bewegungen.bin: Gehen_<art>, Rennen_<art>; held_klassen.py GANG=<OUT> nimmt sie auf).
# Danach Messung ohne Bild: Bilder, Laenge, Tempo ohne Gleiten (wie held_klassen.py schritt_tempo), Beckenhub, Anteil ohne Fuss am Boden;
# dazu die Knochen der Quelle, die nicht abgebildet sind (Waffen-, Prop-Knochen: wo die Waffe in der Hand sitzt).
# Aufruf: KAUF=<kaufpakete> ZIEL=<UAL1.glb oder UAL Pro> OUT=<ordner> BL=<bl/bin/python> bl/bin/python -I waffengang.py
import bpy, glob, json, os, subprocess, sys

KAUF = os.environ['KAUF']; ZIEL = os.environ['ZIEL']; OUT = os.environ['OUT']; BL = os.environ.get('BL', sys.executable)
HIER = os.path.dirname(os.path.abspath(__file__))
os.makedirs(OUT, exist_ok=True)
# Art (wie tragen.gd ARTEN): Paket, Gehen, Rennen (Archiv 417, 12:21; Sokrates aus den Dateinamen)
GAENGE = {
    'axt': ('2.HANDED', 'WalkForwardNormal2HandMelee', 'RunNormal2HandMelee'),
    'einhand': ('1.HANDED', 'WalkForwardHold1hMelee', 'RunHold1hMelee'),
    'schild': ('SWORD.SHIELD', 'WalkForwardS&S', 'RunForwardS&S'),
    'bogen': ('BOW.ARROW', 'WalkBow', 'RunBow'),
}


def finde(paket, name):
    alle = [p for p in glob.glob(os.path.join(KAUF, '**', '*.fbx'), recursive=True) + glob.glob(os.path.join(KAUF, '**', '*.FBX'), recursive=True)
            if paket.lower() in p.lower().replace('_', '.')]
    genau = [p for p in alle if os.path.basename(p).lower() in ('humanoid@%s.fbx' % name.lower(),)]
    if genau: return genau[0], alle
    teil = sorted([p for p in alle if name.lower() in os.path.basename(p).lower() and '_rm' not in os.path.basename(p).lower()], key=len)
    return (teil[0] if teil else None), alle


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
for art, (paket, geh, renn) in GAENGE.items():
    _, alle = finde(paket, geh)
    namen = sorted({os.path.basename(p)[9:-4] for p in alle if os.path.basename(p).startswith('Humanoid@')
                    and any(w in os.path.basename(p) for w in ('Walk', 'Run', 'Sprint'))
                    and not any(w in os.path.basename(p) for w in ('Left', 'Right', 'Backward', 'Crouch', 'Strafe', '_RM', 'Combat', 'Aim', 'Draw'))})
    print('VORWAERTS %s: %s' % (paket, ', '.join(namen)))
    for n in namen:
        if n in (geh, renn): continue
        q = next(p for p in alle if os.path.basename(p) == 'Humanoid@%s.fbx' % n)
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


# Messung je fertiger Bewegung auf dem UAL-Geruest (Blick -Y)
def messen(p):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=p)
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    a = next(iter(bpy.data.actions))
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]
    f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
    fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base
    lage = {k: [] for k in ('ball_l', 'ball_r', 'pelvis')}
    for fr in range(f0, f1 + 1):
        bpy.context.scene.frame_set(fr)
        for k in lage: lage[k].append(arm.matrix_world @ arm.pose.bones[k].head)
    vs, luft = [], 0
    for k in ('ball_l', 'ball_r'):
        h = [v.z for v in lage[k]]; tief = min(h)
        for j in range(len(h) - 1):
            if h[j] < tief + 0.03 and h[j + 1] < tief + 0.03: vs.append((lage[k][j].y - lage[k][j + 1].y) * -fps)
    tl = min(v.z for v in lage['ball_l']); tr = min(v.z for v in lage['ball_r'])
    for j in range(len(lage['pelvis'])):
        if lage['ball_l'][j].z > tl + 0.03 and lage['ball_r'][j].z > tr + 0.03: luft += 1
    vs.sort()
    v = max(vs[len(vs) // 2], 0.0) if vs else 0.0
    b = [x.z for x in lage['pelvis']]
    vor = lage['pelvis'][-1].y - lage['pelvis'][0].y
    return {'bilder': f1 - f0 + 1, 's': round((f1 - f0) / fps, 3), 'tempo': round(v, 3), 'hub_cm': round((max(b) - min(b)) * 100, 1),
            'luft_pct': int(100 * luft / len(b)), 'wurzelweg_m': round(-vor, 3)}


RENN = 3.68 * 1.16; GEH = 1.84 * 1.16
for n in sorted(ergebnis):
    p = ergebnis[n].get('datei') or os.path.join(OUT, n + '.glb')
    if not os.path.exists(p): continue
    m = messen(p); ergebnis[n].update(m)
    soll = RENN if (n.startswith('Rennen') or any(w in n.split('__')[-1] for w in ('Run', 'Sprint'))) else GEH
    fach = soll / m['tempo'] if m['tempo'] > 0.01 else 0.0
    sps = 2.0 / m['s'] * fach if m['s'] > 0 else 0.0
    print('MESS %s: %d Bilder, %.2f s, Tempo %.2f m/s (im Spiel %.2f-fach, %.1f Schritte/s), Beckenhub %.1f cm, ohne Boden %d %%, Wurzelweg %.2f m'
          % (n, m['bilder'], m['s'], m['tempo'], fach, sps, m['hub_cm'], m['luft_pct'], m['wurzelweg_m']))
json.dump(ergebnis, open(os.path.join(OUT, 'waffengang.json'), 'w'), indent=1, ensure_ascii=False)
print('WAFFENGANG', sum(1 for e in ergebnis.values() if e.get('da')), 'von', 2 * len(GAENGE))
