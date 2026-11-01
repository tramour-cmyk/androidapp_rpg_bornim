# 455.2 Groessenfilm (Chef 01.11., 11:21 „einen riesen Ork … und einen kleinen Halbling … Oder brauchen wir da wieder spezielle
# Modelle?“; Archiv 455, Chefsache 455 „Groessen der Voelker“): die fertigen Menschentrachten (held_klassen.py: Kette = Wachsoldat,
# Platte = Ritter, Robe = Zauberlehrling; Mann und Frau) ueber Knochenlaengen auf Hügelvolk und Orkblütigen gebracht, wie voelker.py
# (431) den nackten Grundkoerper formt: Kleidung haengt an denselben Knochen und waechst mit, kein eigenes Netz je Volk.
# Gemessen wird nur am Koerper (Netze des Kaufkoerpers, ohne Kleidung, Helm, Stiefel), Ziele wie voelker.ZIELE; die Sohle ist die der
# ganzen Figur (Stiefel). Der Ork steht hier auf dem Regulaerkoerper der Tracht, nicht auf dem Superhelden (431): der Film zeigt, ob
# die Kleidung allein ueber Knochen auf Orkmasse traegt.
# Aufruf: Z=<klassen> ZIEL=<ordner> [TRACHTEN=WACHE,RITTER,ROBE] [VOELKER=huegel,ork] Q=<cc0> bl/bin/python -I volk_tracht.py
#   -> <ZIEL>/volk_<volk>_<tracht>_<M|W>.glb (auch volk_mensch_*), <ZIEL>/volk_tracht.json
import bpy, os, sys, json

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
Z = os.environ['Z']
ZIEL_V = os.environ.get('ZIEL', os.path.join(Z, 'volk'))
os.makedirs(ZIEL_V, exist_ok=True)
os.environ['ZIEL'] = ZIEL_V
import voelker as VO

TRACHTEN = [s for s in os.environ.get('TRACHTEN', 'WACHE,RITTER,ROBE').split(',') if s]
VOELKER = [s for s in os.environ.get('VOELKER', 'huegel,ork').split(',') if s]
KOERPER = ('Regular_', 'Superhero_')   # Netze des Kaufkoerpers (FullBody, OnlyHead)
GESEHEN = set()


def laden(p):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    vorher = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=p)
    objs = [o for o in bpy.data.objects if o not in vorher]
    arm = next(o for o in objs if o.type == 'ARMATURE')
    alle = [o for o in objs if o.type == 'MESH']
    for o in alle:   # wie voelker.laden: vom Geruest loesen, an Knochen gehaengte Netze bekommen dessen Gruppe
        knochen = o.parent_bone if o.parent_type == 'BONE' else ''
        mw = o.matrix_world.copy(); o.parent = None; o.matrix_world = mw
        if knochen and not o.vertex_groups:
            g = o.vertex_groups.new(name=knochen)
            g.add(range(len(o.data.vertices)), 1.0, 'REPLACE')
            mo = o.modifiers.new('Armature', 'ARMATURE'); mo.object = arm
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + alle: o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    netze = [o for o in alle if o.vertex_groups]
    if os.path.basename(p) not in GESEHEN:
        GESEHEN.add(os.path.basename(p))
        print('NETZE', os.path.basename(p), [(o.name, ist_koerper(o)) for o in netze])
    return arm, netze, alle


def ist_koerper(o):
    # Kaufkoerper: Name oder Material (MI_Regular_Male, wie HeldFigur.toene; Lauf 41321140618: Arme der Tracht tragen die Haut der Haende)
    return o.name.startswith(KOERPER) or any(m and ('Regular' in m.name or 'Superhero' in m.name) for m in o.data.materials)


def messen(arm, netze):
    # wie voelker.messen, aber Scheitel und Kinn nur am Koerper (Helm, Kapuze zaehlen nicht), Sohle der ganzen Figur (Stiefel; die Tracht
    # hat unter Hose und Stiefeln keine Beinhaut mehr, held_klassen.beine_weg; Lauf 41323183168: Groesse 0,44 m am Koerper allein)
    k = [o for o in netze if ist_koerper(o)] or netze
    sohle = min(v.co.z for o in netze for v in o.data.vertices)
    scheitel = max(v.co.z for o in k for v in o.data.vertices)
    H = scheitel - sohle
    kopf = arm.data.bones['Head'].head_local
    kinn = 9.0
    for o in k:
        gi = o.vertex_groups.get('Head')
        if gi is None: continue
        for v in o.data.vertices:
            st = max(v.groups, key=lambda x: x.weight) if v.groups else None
            if st and st.group == gi.index and v.co.y < kopf.y - 0.02: kinn = min(kinn, v.co.z)
    huefte = (arm.data.bones['thigh_l'].head_local.z + arm.data.bones['thigh_r'].head_local.z) / 2 - sohle
    schulter = (arm.data.bones['upperarm_l'].head_local - arm.data.bones['upperarm_r'].head_local).length
    return {'h': H, 'kopf': (scheitel - kinn) / H, 'bein': huefte / H, 'schulter': schulter, 'schulter_rel': schulter / H,
            'sohle': sohle, 'sohle_figur': sohle}


def baue(volk, t, g, mensch):
    z = VO.ZIELE[volk]
    frau = g == 'W'
    p = os.path.join(Z, 'held_%s_%s.glb' % (t, g))
    h_soll = z['h'] * (VO.FRAU if frau else 1.0)
    e = VO.einstellung_start(z)
    beste = None
    for runde in range(7):
        arm, netze, alle = laden(p)
        if volk != 'mensch': VO.knochen_formen(arm, netze, e)
        m = messen(arm, netze)
        f = h_soll / m['h']
        abw = []
        if 'kopf' in z: abw.append(abs(m['kopf'] / z['kopf'] - 1))
        if 'bein' in z: abw.append(abs(m['bein'] / z['bein'] - 1))
        s_ziel = None
        if 'schulter' in z and mensch:
            art, k = z['schulter']
            s_ziel = mensch['schulter'] * k if art == 'abs' else mensch['schulter_rel'] * k * h_soll
            abw.append(abs(m['schulter'] * f / s_ziel - 1))
        print('RUNDE %s %s %s %d: Kopf 1/%.2f Bein %.3f Schulter %.3f Abweichung %s' % (volk, t, g, runde, 1 / m['kopf'], m['bein'],
              m['schulter'] * f, ['%.3f' % a for a in abw]))
        if volk == 'mensch': break
        if abw and (beste is None or max(abw) < beste[0]): beste = (max(abw), dict(e))
        if not abw or max(abw) < 0.015: break
        if runde == 6:
            e = beste[1]
            arm, netze, alle = laden(p)
            VO.knochen_formen(arm, netze, e)
            m = messen(arm, netze)
            break
        if 'kopf' in z: e['kopf'] = min(max(e['kopf'] * (z['kopf'] / max(m['kopf'], 1e-3)) ** 1.15, 0.6), 2.2)
        if 'bein' in z: e['bein'] = min(max(e['bein'] * (z['bein'] / max(m['bein'], 1e-3)) ** 1.6, 0.3), 1.6)
        if s_ziel: e['schulter'] = min(max(e['schulter'] * (s_ziel / (m['schulter'] * f)), 0.5), 2.2)
    if volk == 'mensch':
        h_soll = m['h']   # der Mensch bleibt, wie er ist (Bezug)
    VO.auf_groesse(arm, alle, m['h'], m['sohle_figur'], h_soll)
    m2 = messen(arm, netze)
    for o in alle:
        if o.type == 'MESH': o.data.name = o.name
    for o in alle:
        mw = o.matrix_world.copy(); o.parent = arm; o.matrix_world = mw
    name = 'volk_%s_%s_%s' % (volk, t, g)
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + alle: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL_V, name + '.glb'), export_format='GLB', use_selection=True,
                              export_animations=False, export_apply=False, export_skins=True, export_morph=False,
                              export_vertex_color='ACTIVE')
    r = {'datei': name + '.glb', 'volk': VO.VOLKSNAME[volk], 'volk_kurz': volk, 'tracht': t, 'geschlecht': g,
         'groesse_m': round(m2['h'], 3), 'ziel_m': round(h_soll, 3), 'kopf_1_durch': round(1 / m2['kopf'], 2),
         'bein_anteil': round(m2['bein'], 3), 'schulter_m': round(m2['schulter'], 3),
         'einstellung': {k: round(v, 3) for k, v in e.items()} if volk != 'mensch' else {}}
    print('VOLKTRACHT', json.dumps(r, ensure_ascii=False))
    return r, m2


aus = []
for t in TRACHTEN:
    for g in ('M', 'W'):
        if not os.path.exists(os.path.join(Z, 'held_%s_%s.glb' % (t, g))):
            print('FEHLT held_%s_%s.glb' % (t, g)); continue
        r, mensch = baue('mensch', t, g, None)
        aus.append(r)
        for v in VOELKER:
            aus.append(baue(v, t, g, mensch)[0])
json.dump({'figuren': aus}, open(os.path.join(ZIEL_V, 'volk_tracht.json'), 'w'), indent=1, ensure_ascii=False)
print('VOLKTRACHT OK', len(aus))
