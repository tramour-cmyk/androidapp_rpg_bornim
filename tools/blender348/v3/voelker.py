# 431 Runde 3 (Chef 01.11., 11:42, „431 wie Sokrates“, Archiv 431): Grundkoerper je Volk aus den gekauften Universal Base Characters
# (Quaternius): Ork auf Superheld, Mensch, Elf, Zwerg, Huegelvolk auf Regulaer; je Volk Mann und Frau (7 % kleiner). Homers Punkte
# (LISTE-FIGUREN.md „Voelker“, 430) 1 Groesse, 2 Umriss (Kopfanteil, Beinanteil, Schulterbreite) werden gemessen und eingestellt;
# 3 Merkmale (Ohren, Hauer, Bart) fehlen im Bestand (408: erst frei suchen, dann Kauf, Eigenbau zuletzt), 5 Haltung macht Godot.
#
# Verfahren wie cc0.py VOLK (348.12, Probe 25.10.: Fuesse am Boden, keine Risse): je Knochen eine eigene Laenge (entlang) und Dicke
# (quer), ohne dass Kinder die Dicke erben; die Ruhelage der Knochen wird neu gesetzt, das Netz linear mitgezogen; danach das Ganze
# auf die Zielgroesse. Je Volk wird bis zu viermal gemessen und nachgestellt, bis Kopf- und Beinanteil und Schulterbreite stimmen.
#
# Gemessen am Netz in der Ruhelage (T-Pose), Groesse = Scheitel ueber der Sohle:
#   Kopfanteil = (Scheitel - Kinn) / Groesse; Kinn = tiefster Punkt vorn, der am Kopfknochen haengt
#   Beinanteil = Hueftgelenk (Kopf des Oberschenkelknochens) / Groesse (Mensch etwa die Haelfte)
#   Schulter   = Abstand der Schultergelenke (Kopf der Oberarmknochen), absolut und gegen den Menschen
# Aufruf: Q=<cc0> KAUF=<kaufpakete> ZIEL=<ordner> [NUR_VOELKER=elf,zwerg] bl/bin/python -I voelker.py
#   -> <ZIEL>/volk_<volk>_<mann|frau>.glb (ohne Bewegungen, Godot nimmt die der UAL), voelker.json (Masse, Ziele, Einstellungen)
import bpy, os, sys, json
import mathutils

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
os.environ.setdefault('FIGUREN', 'keine')
ZIEL = os.environ.get('ZIEL', '/tmp/voelker')
NUR = [s for s in os.environ.get('NUR_VOELKER', '').split(',') if s]   # nicht VOELKER: so heisst im Ablauf der Ordner (Lauf 41299824753)
os.makedirs(ZIEL, exist_ok=True)
import numpy as np
import quaternius as QT
import merkmale as MK
import kopf as KO

FRAU = 0.93
# Ziele nach Homer (430): Groesse Mann (m), Kopfanteil, Beinanteil (Hueftgelenk), Schulter: ('abs'|'rel', Faktor gegen den Menschen)
# Mensch = Liste „Held“ (175 cm); die Anteile des Menschen sind die des Kaufkoerpers und werden nur gemessen
# Lauf 41299824753 gemessen: Mensch Kopf 1/7,8, Hueftgelenk 0,54 der Groesse. Homers Kopfanteile gelten wie geschrieben; der Ork hat
# den Kopf „wie beim Menschen“ (kein eigenes Ziel); die Beine nach Homers Vergleich: Elf laenger als der Mensch (0,56), Huegelvolk
# „knapp die Haelfte“ (0,49), Zwerg „gut ein Drittel“ (0,36)
ZIELE = {
    'mensch': {'koerper': 'Regular', 'h': 1.75},
    'elf':    {'koerper': 'Regular', 'h': 1.72, 'kopf': 1 / 8, 'bein': 0.56, 'schulter': ('rel', 0.90),
               'dick': 0.90, 'hand': 0.92, 'fuss': 0.92},                                      # schlank, feine Haende und Fuesse
    'zwerg':  {'koerper': 'Regular', 'h': 1.35, 'kopf': 1 / 5, 'bein': 0.36, 'schulter': ('abs', 1.05),
               'dick': 1.35, 'hals': 0.55, 'hand': 1.25, 'fuss': 1.05},                        # gedrungen, kurzer Hals, grosse Haende
    'huegel': {'koerper': 'Regular', 'h': 1.05, 'kopf': 1 / 6, 'bein': 0.49, 'schulter': ('rel', 1.00),
               'dick': 1.15, 'bauch': 1.2, 'hand': 1.0, 'fuss': 1.35},                         # rundlich, nicht breit; grosse Fuesse
    'ork':    {'koerper': 'Superhero', 'h': 1.85, 'schulter': ('abs', 1.20),
               'dick': 1.12, 'hals': 0.75, 'hand': 1.15},                                      # massig, kurzer dicker Hals
}
# 431 Runde 4 (Chef 01.11., 20:3x, Archiv 431; 431b 02.11., 11:17): Merkmale aus merkmale.py (Form und Mass aus goblin.py),
# am gekauften Kopf in der Ruhelage vor dem Formen der Knochen (die Masse dort sind die des Kaufkopfs, danach waechst alles mit)
MERKMALE = {'elf': {'ohr': 'elf'}, 'huegel': {'ohr': 'huegel'}, 'ork': {'ohr': 'ork', 'hauer': 'ork'}}
VOLKSNAME = {'mensch': 'Mensch', 'elf': 'Elf', 'zwerg': 'Zwerg', 'huegel': 'Hügelvolk', 'ork': 'Orkblütiger'}


def koerper_datei(art, frau):
    n = '%s_%s_FullBody' % (art, 'Female' if frau else 'Male')
    kn, kp = QT.datei(n)
    if not kp: raise SystemExit('FEHLT %s (gekauft, KAUF=)' % n)
    return kp


def laden(art, frau):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    objs = QT.importiere(koerper_datei(art, frau))
    arm = next(o for o in objs if o.type == 'ARMATURE')
    alle = [o for o in objs if o.type == 'MESH']
    # Netze vom Geruest loesen (Lage behalten), sonst wirkt das Skalieren unten doppelt; an einen Knochen gehaengte Netze (Augen)
    # bekommen eine Gruppe dieses Knochens, damit sie mit ihm wandern und wachsen
    for o in alle:
        knochen = o.parent_bone if o.parent_type == 'BONE' else ''
        mw = o.matrix_world.copy(); o.parent = None; o.matrix_world = mw
        if knochen and not o.vertex_groups:
            g = o.vertex_groups.new(name=knochen)
            g.add(range(len(o.data.vertices)), 1.0, 'REPLACE')
            mo = o.modifiers.new('Armature', 'ARMATURE'); mo.object = arm
    # Geruest und Netze ohne Drehung/Groesse, damit Ruhelage und Ecken im selben Raum liegen
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + alle: o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    netze = [o for o in alle if o.vertex_groups]
    print('LADEN', os.path.basename(koerper_datei(art, frau)), [(o.name, len(o.data.vertices)) for o in alle])
    return arm, netze, alle


# je Knochen (entlang, quer) aus den Einstellungen e
def mass(n, e):
    if n == 'root': return (1, 1)
    if n == 'Head': return (e['kopf'], e['kopf'])
    if n.startswith('neck'): return (e['hals'], e['dick'])
    if n == 'pelvis': return (e['rumpf'], e['dick'] * e['bauch'])
    if n.startswith('spine'): return (e['rumpf'], e['dick'] * (e['bauch'] if n == 'spine_01' else 1.0))
    if n.startswith('clavicle'): return (e['schulter'], e['dick'])
    if n.startswith(('upperarm', 'lowerarm')): return (e['arm'], e['dick'])
    if n.startswith(('thigh', 'calf')): return (e['bein'], e['dick'])
    if n.startswith(('foot', 'ball')): return (e['fuss'], e['fuss'])
    if n.startswith(('hand', 'thumb', 'index', 'middle', 'ring', 'pinky')): return (e['hand'], e['hand'])
    return (1, 1)


# 431 Runde 4 (Pruefer Runde 3: „beim Zwerg die Unterschenkel von der Seite kantig, mit hartem Absatz am Knie“): am Knie folgen
# Ecken mit Gewicht am Oberschenkel dessen Laenge und Dicke, die mit Gewicht am Unterschenkel dessen; wo die Achsen in der Ruhelage
# nicht fluchten, entsteht eine Stufe. Die Verschiebung wird binnen KNIE_R um das Kniegelenk ueber die Nachbarecken geglaettet
KNIE_R = 0.09


def knie_glatt(o, alt, knie, keys):
    if not knie or not o.data.edges: return
    n = len(alt)
    A = [mathutils.Vector(v) for v in alt]
    w = [0.0] * n
    for i, a in enumerate(A):
        d = min((a - k).length for k in knie)
        if d < KNIE_R: w[i] = 1.0 - (d / KNIE_R) ** 2
    if not any(w): return
    nb = [[] for _ in range(n)]
    for ed in o.data.edges:
        a, b = ed.vertices
        nb[a].append(b); nb[b].append(a)
    D = [o.data.vertices[i].co - A[i] for i in range(n)]
    roh = list(D)
    for _ in range(8):
        D2 = list(D)
        for i in range(n):
            if w[i] <= 0 or not nb[i]: continue
            m = sum((D[j] for j in nb[i]), mathutils.Vector()) / len(nb[i])
            D2[i] = D[i].lerp(m, 0.6 * w[i])
        D = D2
    groesst = 0.0
    for i in range(n):
        if w[i] <= 0: continue
        k = D[i] - roh[i]
        groesst = max(groesst, k.length)
        o.data.vertices[i].co += k
        for kb in keys: kb.data[i].co += k
    print('KNIE geglaettet %s: %d Ecken, groesste Aenderung %.1f mm' % (o.name, sum(1 for x in w if x > 0), groesst * 1000))


def knochen_formen(arm, netze, e):
    # cc0.py: neue Ruhelage je Knochen (eigene Laenge und Dicke, Kopf am verschobenen Ende des Elternknochens), Netz linear mitgezogen
    ad = arm.data
    R = {b.name: b.matrix_local.copy() for b in ad.bones}
    M = {}
    for b in ad.bones:   # Eltern vor Kindern
        el, q = mass(b.name, e)
        S = mathutils.Matrix.Diagonal((q, el, q, 1))
        rot = R[b.name].to_3x3().to_4x4()
        h = R[b.name].translation if not b.parent else (M[b.parent.name] @ R[b.parent.name].inverted() @ R[b.name].translation)
        M[b.name] = mathutils.Matrix.Translation(h) @ rot @ S
    D = {n: M[n] @ R[n].inverted() for n in M}
    sohle_alt = min(v.co.z for o in netze for v in o.data.vertices)
    knie = [R[n].translation.copy() for n in ('calf_l', 'calf_r') if n in R]
    for o in netze:
        alt = [v.co.copy() for v in o.data.vertices]
        gname = {g.index: g.name for g in o.vertex_groups}
        keys = list(o.data.shape_keys.key_blocks) if o.data.shape_keys else []   # Formschluessel mitziehen, sonst gilt die alte Basis
        for v in o.data.vertices:
            acc = mathutils.Matrix(((0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0))); w = 0.0
            for g in v.groups:
                n = gname.get(g.group)
                if n in D and g.weight > 0: acc += D[n] * g.weight; w += g.weight
            if w <= 0: continue
            Mv = acc * (1.0 / w)
            v.co = Mv @ v.co
            for kb in keys: kb.data[v.index].co = Mv @ kb.data[v.index].co
        knie_glatt(o, alt, knie, keys)
    # Sohlen zurueck auf den alten Boden: Netz und alle Knochen ausser der Wurzel senken (cc0.py; Lauf 41300277200: ohne das stand die
    # Wurzel tiefer als der Ursprung, die Beckenlage der UAL passte nicht, Zwerg 50 cm im Boden, Elf 9 cm darueber)
    tief = min(v.co.z for o in netze for v in o.data.vertices) - sohle_alt
    for o in netze:
        keys = list(o.data.shape_keys.key_blocks) if o.data.shape_keys else []
        for v in o.data.vertices:
            v.co.z -= tief
            for kb in keys: kb.data[v.index].co.z -= tief
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='EDIT')
    laengen = {eb.name: eb.length for eb in ad.edit_bones}
    for eb in ad.edit_bones: eb.use_connect = False
    for eb in ad.edit_bones:
        el, q = mass(eb.name, e)
        roll = eb.roll
        k = M[eb.name].translation.copy()
        if eb.name != 'root': k.z -= tief
        d = (R[eb.name].to_3x3() @ mathutils.Vector((0, 1, 0))) * (laengen[eb.name] * el)
        eb.head = k; eb.tail = k + d; eb.roll = roll
    bpy.ops.object.mode_set(mode='OBJECT')


def ecken(netze):
    return [v.co.copy() for o in netze for v in o.data.vertices]


def messen(arm, netze):
    P = ecken(netze)
    sohle = min(p.z for p in P)
    scheitel = max(p.z for p in P)
    H = scheitel - sohle
    kopf = arm.data.bones['Head'].head_local
    kinn = 9.0
    for o in netze:   # vorn (Blick -Y) und am Kopfknochen
        gi = o.vertex_groups.get('Head')
        if gi is None: continue
        for v in o.data.vertices:
            st = max(v.groups, key=lambda x: x.weight) if v.groups else None
            if st and st.group == gi.index and v.co.y < kopf.y - 0.02: kinn = min(kinn, v.co.z)
    huefte = (arm.data.bones['thigh_l'].head_local.z + arm.data.bones['thigh_r'].head_local.z) / 2 - sohle
    schulter = (arm.data.bones['upperarm_l'].head_local - arm.data.bones['upperarm_r'].head_local).length
    return {'h': H, 'kopf': (scheitel - kinn) / H, 'bein': huefte / H, 'schulter': schulter, 'schulter_rel': schulter / H, 'sohle': sohle}


def auf_groesse(arm, alle, h_ist, sohle, h_soll):
    f = h_soll / h_ist
    for o in [arm] + alle:
        o.location.z -= sohle
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + alle: o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)
    for o in [arm] + alle: o.scale = (f, f, f); o.location = o.location * f
    bpy.ops.object.transform_apply(location=True, rotation=False, scale=True)


def merkmale(volk, arm, netze, alle):
    mk = MERKMALE.get(volk, {})
    if not mk: return {}
    haut = next(o for o in alle if ('regular' in o.name.lower() or 'superhero' in o.name.lower()) and not o.name.startswith(('Eye', 'Hair')))
    augen = next((o for o in alle if o.name.startswith('Eyes')), None)
    aus = {}
    if mk.get('ohr'): aus['ohren'] = {('rechts' if s < 0 else 'links'): v for s, v in MK.ohren(haut, augen, mk['ohr']).items()}
    if mk.get('hauer'):
        o, lage = MK.hauer(haut, augen, mk['hauer'], arm)
        netze.append(o); alle.append(o); aus['hauer'] = lage
    return aus


def haut_bild(alle):
    # Pruefer Lauf 41430558274 (Haut kreideweiss): Bezug fuer die Toenung in Godot (HeldFigur.toene: Bild / Bezug mal Zielton) aus dem
    # eigenen Hautbild, wie held_klassen.py haare(): Median der Bildfarbe (sRGB) im Gesicht zwischen Kinn und Augen, vorn
    haut = next(o for o in alle if ('regular' in o.name.lower() or 'superhero' in o.name.lower()) and not o.name.startswith(('Eye', 'Hair')))
    augen = next((o for o in alle if o.name.startswith('Eyes')), None)
    p = KO.merkpunkte(haut, augen)
    me = haut.data; uv = me.uv_layers.active.data
    W = KO._welt(haut)
    ok = (W[:, 2] > p['kinn_z'] + 0.02) & (W[:, 2] < p['augen_z']) & (W[:, 1] < p['mitte'][1])
    werte = []
    for m in me.materials:
        tn = QT.basisbild(m) if m else None
        if not tn or not tn.image: continue
        im = tn.image; Wd, Hd = im.size
        px = np.empty(Wd * Hd * 4, dtype=np.float32); im.pixels.foreach_get(px); px = px.reshape(Hd, Wd, 4)
        for l in me.loops:
            if not ok[l.vertex_index]: continue
            u, v = uv[l.index].uv
            werte.append(px[int(v % 1 * Hd) % Hd, int(u % 1 * Wd) % Wd, :3])
        break
    return [round(float(x), 4) for x in np.median(np.array(werte), axis=0)] if werte else [1.0, 1.0, 1.0]


def einstellung_start(z):
    return {'kopf': 1.0, 'hals': z.get('hals', 1.0), 'rumpf': 1.0, 'dick': z.get('dick', 1.0), 'bauch': z.get('bauch', 1.0),
            'schulter': 1.0, 'arm': 1.0, 'bein': 1.0, 'hand': z.get('hand', 1.0), 'fuss': z.get('fuss', 1.0)}


MENSCH = {}


def baue(volk, frau):
    z = ZIELE[volk]
    h_soll = z['h'] * (FRAU if frau else 1.0)
    e = einstellung_start(z)
    m = None
    beste = None   # (groesste Abweichung, Einstellung): am Ende gilt die beste Runde (Lauf 41300277200: Schulter schwang sich auf)
    for runde in range(7):
        arm, netze, alle = laden(z['koerper'], frau)
        mk = merkmale(volk, arm, netze, alle)
        if runde == 0 and mk: print('MERKMALE', volk, 'frau' if frau else 'mann', json.dumps(mk))
        knochen_formen(arm, netze, e)
        m = messen(arm, netze)
        f = h_soll / m['h']   # nach dem Skalieren gelten die Anteile weiter, die Schulter waechst mit f
        abw = []
        if 'kopf' in z: abw.append(abs(m['kopf'] / z['kopf'] - 1))
        if 'bein' in z: abw.append(abs(m['bein'] / z['bein'] - 1))
        ms = MENSCH.get(frau)
        s_ziel = None
        if 'schulter' in z and ms:
            art, k = z['schulter']
            s_ziel = ms['schulter'] * k if art == 'abs' else ms['schulter_rel'] * k * h_soll
            abw.append(abs(m['schulter'] * f / s_ziel - 1))
        print('RUNDE %s %s %d: Kopf 1/%.2f Bein %.3f Schulter %.3f m (nach Groesse %.3f) Abweichung %s' % (
            volk, 'frau' if frau else 'mann', runde, 1 / m['kopf'], m['bein'], m['schulter'], m['schulter'] * f, ['%.3f' % a for a in abw]))
        if abw and (beste is None or max(abw) < beste[0]): beste = (max(abw), dict(e))
        if not abw or max(abw) < 0.015: break
        if runde == 6:   # nicht eingelaufen: die beste Runde neu bauen
            e = beste[1]
            arm, netze, alle = laden(z['koerper'], frau)
            mk = merkmale(volk, arm, netze, alle)
            knochen_formen(arm, netze, e)
            m = messen(arm, netze)
            print('BESTE %s %s: Abweichung %.3f' % (volk, 'frau' if frau else 'mann', beste[0]))
            break
        # nachstellen: Kopf ueber die Kopfgroesse, Bein ueber die Beinlaenge (der Rumpf gleicht aus), Schulter ueber das Schluesselbein
        if 'kopf' in z:
            e['kopf'] = min(max(e['kopf'] * (z['kopf'] / m['kopf']) ** 1.15, 0.6), 2.2)
        if 'bein' in z:
            e['bein'] = min(max(e['bein'] * (z['bein'] / m['bein']) ** 1.6, 0.3), 1.6)
        if s_ziel:
            # Schulterbreite = Abstand der Oberarmkoepfe, waechst etwa wie die Laenge des Schluesselbeins (Lauf 41300277200: Elf
            # 0,79-fach Schluesselbein gab 0,79-fach Breite; mit Hochzahl 2,5 schwang sie von Runde zu Runde weiter auf): Hochzahl 1
            e['schulter'] *= (s_ziel / (m['schulter'] * f))
            e['schulter'] = min(max(e['schulter'], 0.5), 2.2)
    auf_groesse(arm, alle, m['h'], m['sohle'], h_soll)
    m2 = messen(arm, netze)
    for o in alle:
        if o.type == 'MESH': o.data.name = o.name
    for o in alle:   # zum Export wieder ans Geruest (Lage bleibt, das Geruest liegt im Ursprung ohne Drehung)
        mw = o.matrix_world.copy(); o.parent = arm; o.matrix_world = mw
    name = 'volk_%s_%s' % (volk, 'frau' if frau else 'mann')
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + alle: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, name + '.glb'), export_format='GLB', use_selection=True, export_animations=False,
                              export_apply=False, export_skins=True, export_morph=False)
    ms = MENSCH.get(frau)
    r = {'datei': name + '.glb', 'volk': VOLKSNAME[volk], 'frau': frau, 'koerper': z['koerper'], 'groesse_m': round(m2['h'], 3),
         'kopf_anteil': round(m2['kopf'], 4), 'kopf_1_durch': round(1 / m2['kopf'], 2), 'bein_anteil': round(m2['bein'], 3),
         'schulter_m': round(m2['schulter'], 3),
         'schulter_gegen_mensch': round(m2['schulter'] / ms['schulter'], 3) if ms else 1.0,
         'schulter_rel_gegen_mensch': round(m2['schulter_rel'] / ms['schulter_rel'], 3) if ms else 1.0,
         'becken_m': round(arm.data.bones['pelvis'].head_local.z, 4),
         'ziel': {k: (round(v, 4) if isinstance(v, float) else v) for k, v in z.items()},
         'einstellung': {k: round(v, 3) for k, v in e.items()}, 'merkmale': mk,
         # 431 Runde 4: Kopf gegen den Kaufkopf (Knochen „Head“ e['kopf'], dann das Ganze auf die Groesse): Haare in Godot mitwachsen
         'kopf_skala': round(e['kopf'] * h_soll / m['h'], 4), 'haut_bild': None}
    try:
        r['haut_bild'] = haut_bild(alle)
    except Exception as x:   # ohne Bezug toent Godot wie den Helden (Messzeile HAUTBILD zeigt es)
        print('HAUTBILD FEHLER', volk, repr(x))
    print('VOLK', json.dumps(r, ensure_ascii=False))
    return r, m2


aus = []
for frau in (False, True):
    # der Mensch zuerst: Bezug fuer die Schulter
    r, m = baue('mensch', frau)
    MENSCH[frau] = m
    aus.append(r)
    for v in ('elf', 'zwerg', 'huegel', 'ork'):
        if NUR and v not in NUR: continue
        aus.append(baue(v, frau)[0])
json.dump({'voelker': aus, 'frau': FRAU}, open(os.path.join(ZIEL, 'voelker.json'), 'w'), indent=1, ensure_ascii=False)
print('VOELKER OK', len(aus))
