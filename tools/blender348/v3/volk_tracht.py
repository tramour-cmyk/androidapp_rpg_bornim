# 455.2 Groessenfilm (Chef 01.11., 11:21 „einen riesen Ork … und einen kleinen Halbling … Oder brauchen wir da wieder spezielle
# Modelle?“; Archiv 455, Chefsache 455 „Groessen der Voelker“): die fertigen Menschentrachten (held_klassen.py: Kette = Wachsoldat,
# Platte = Ritter, Robe = Zauberlehrling; Mann und Frau) ueber Knochenlaengen auf Hügelvolk und Orkblütigen gebracht, wie voelker.py
# (431) den nackten Grundkoerper formt: Kleidung haengt an denselben Knochen und waechst mit, kein eigenes Netz je Volk.
# Gemessen wird nur am Koerper (Netze des Kaufkoerpers, ohne Kleidung, Helm, Stiefel), Ziele wie voelker.ZIELE; die Sohle ist die der
# ganzen Figur (Stiefel).
# Runde 2 (Chef 01.11., 20:4x, Archiv 455.2: „Hügelvolk passt … Helm Hügelvolk anpassen; Zwerg nachreichen; Ork auf Superheld zeigen“;
# „das eigentlich auf dem sogenannten Superheld bauen, den Ork“):
#   Zwerg dazu (voelker.ZIELE, Regulaerkoerper wie das Hügelvolk).
#   Ork auf dem Superhelden (voelker.ZIELE ork): die Kleidung geht vom Geruest des Regulaerkoerpers auf das des Superhelden (je Knochen
#   dessen Ruhelage, Laenge mit), der Regulaerkoerper der Tracht weicht dem Superhelden; dann wie die anderen ueber Knochenlaengen.
#   Sitz: wo der Koerper durch die Kleidung sticht, rueckt die Kleidung um SITZ nach aussen (Ork: alle Kleidung gegen den Superhelden;
#   alle Voelker: Helm und Kapuze gegen den Kopf). Starre Teile (Helm) haengen ganz am Kopfknochen, damit sie nicht mit dem Hals
#   verzerren (Hügelvolk Platte, Lauf 41324116889: Helm durch beim Rennen, Frau 127 Ecken gegen Mensch 18).
#   Haut unter der Kleidung des Superhelden weg (Strahl entlang der Normale trifft binnen DECKT Kleidung), wie held_klassen SCHRANK=0.
# Aufruf: Z=<klassen, SCHRANK=0 MIT_RITTER=1> ZIEL=<ordner> [TRACHTEN=WACHE,RITTER,ROBE] [VOELKER=huegel,zwerg,ork] Q=<cc0> KAUF=<kauf>
#   bl/bin/python -I volk_tracht.py
#   -> <ZIEL>/volk_<volk>_<tracht>_<M|W>.glb (auch volk_mensch_*), <ZIEL>/volk_tracht.json
import bpy, os, sys, json
import mathutils
from mathutils.bvhtree import BVHTree

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
Z = os.environ['Z']
ZIEL_V = os.environ.get('ZIEL', os.path.join(Z, 'volk'))
os.makedirs(ZIEL_V, exist_ok=True)
os.environ['ZIEL'] = ZIEL_V
import voelker as VO
QT = VO.QT

TRACHTEN = [s for s in os.environ.get('TRACHTEN', 'WACHE,RITTER,ROBE').split(',') if s]
VOELKER = [s for s in os.environ.get('VOELKER', 'huegel,zwerg,ork').split(',') if s]
SITZ = 0.004    # m Abstand der Kleidung ueber der Haut nach dem Sitz
DECKT_WEIT = 0.12
# Leibstuecke wie held_klassen.py LEIB_KNOCHEN (Kopf und Hals gehoeren zu keinem, bleiben)
LEIB_KNOCHEN = {'RUMPF': ('spine', 'clavicle'), 'OBERARM': ('upperarm',), 'UNTERARM': ('lowerarm',),
                'HAND': ('hand', 'thumb', 'index', 'middle', 'ring', 'pinky'), 'BECKEN': ('pelvis', 'root'),
                'OBERSCHENKEL': ('thigh',), 'UNTERSCHENKEL': ('calf',), 'FUSS': ('foot', 'ball')}
DECKT_AB = 0.5
NAH = 0.02      # m: Haut so nah an Kleidung gilt auch als bedeckt
LAGE = 0.03     # m: Ecken der Kleidung so nah beieinander ruecken gemeinsam (Lagen uebereinander)
DECKT = 0.06    # m: Haut des Superhelden gilt als bedeckt, wenn der Strahl entlang ihrer Normale so nah Kleidung trifft
STARR = ('Head_Armet', 'Head_Hood', 'Helm')   # Teile ganz am Kopfknochen
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


def ist_kleid(o):
    return not ist_koerper(o) and not o.name.startswith(('Eye', 'Brow', 'Icosphere'))


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


def _loese(objs, arm):
    # wie laden(): vom Geruest loesen, an Knochen gehaengte Netze bekommen dessen Gruppe, Lage und Groesse anwenden
    for o in objs:
        if o.type != 'MESH': continue
        knochen = o.parent_bone if o.parent_type == 'BONE' else ''
        mw = o.matrix_world.copy(); o.parent = None; o.matrix_world = mw
        if knochen and not o.vertex_groups:
            g = o.vertex_groups.new(name=knochen)
            g.add(range(len(o.data.vertices)), 1.0, 'REPLACE')
            mo = o.modifiers.new('Armature', 'ARMATURE'); mo.object = arm
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs: o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)


def _verschiebe(o, D):
    # je Ecke die nach Gewicht gemischte Matrix der Knochen (wie voelker.knochen_formen), Formschluessel mit
    gname = {g.index: g.name for g in o.vertex_groups}
    keys = list(o.data.shape_keys.key_blocks) if o.data.shape_keys else []
    for v in o.data.vertices:
        acc = mathutils.Matrix(((0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0))); w = 0.0
        for g in v.groups:
            n = gname.get(g.group)
            if n in D and g.weight > 0: acc += D[n] * g.weight; w += g.weight
        if w <= 0: continue
        Mv = acc * (1.0 / w)
        v.co = Mv @ v.co
        for kb in keys: kb.data[v.index].co = Mv @ kb.data[v.index].co


def starr(netze):
    # Helm, Kapuze ganz an den Kopfknochen (verzerren sonst mit dem Hals; Hügelvolk Platte Lauf 41324116889)
    for o in netze:
        if ist_koerper(o) or not any(k in o.name for k in STARR): continue
        for g in list(o.vertex_groups): o.vertex_groups.remove(g)
        g = o.vertex_groups.new(name='Head'); g.add(range(len(o.data.vertices)), 1.0, 'REPLACE')
        print('STARR', o.name)


def auf_superheld(arm, netze, alle, frau):
    """Ork (Archiv 455.2 „Ork auf Superheld“): Kleidung vom Geruest des Regulaerkoerpers auf das des Superhelden; Koerper getauscht."""
    vorher = set(bpy.data.objects)
    objs = QT.importiere(VO.koerper_datei('Superhero', frau))
    sarm = next(o for o in objs if o.type == 'ARMATURE')
    _loese(objs, sarm)
    sm = [o for o in objs if o.type == 'MESH']
    Rt = {b.name: (b.matrix_local.copy(), b.length) for b in arm.data.bones}
    Rs = {b.name: (b.matrix_local.copy(), b.length) for b in sarm.data.bones}
    D = {}
    for n, (mt, lt) in Rt.items():
        if n not in Rs: continue
        ms, ls = Rs[n]
        D[n] = ms @ mathutils.Matrix.Diagonal((1, ls / max(lt, 1e-6), 1, 1)) @ mt.inverted()
    fehlt = [n for n in Rt if n not in Rs]
    if fehlt: print('SUPERHELD ohne Knochen', fehlt)
    weg = [o for o in alle if ist_koerper(o) or o.name.startswith(('Eye', 'Brow'))]
    kleid = [o for o in netze if o not in weg]
    for o in kleid: _verschiebe(o, D)
    for o in weg: bpy.data.objects.remove(o)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='EDIT')
    for eb in arm.data.edit_bones: eb.use_connect = False
    for eb in arm.data.edit_bones:
        if eb.name in Rs:
            eb.matrix = Rs[eb.name][0]; eb.length = Rs[eb.name][1]
    bpy.ops.object.mode_set(mode='OBJECT')
    for o in sm:
        for md in o.modifiers:
            if md.type == 'ARMATURE': md.object = arm
        if not any(md.type == 'ARMATURE' for md in o.modifiers):
            md = o.modifiers.new('Armature', 'ARMATURE'); md.object = arm
    bpy.data.objects.remove(sarm)
    netze = kleid + [o for o in sm if o.vertex_groups]
    alle = kleid + [o for o in alle if o not in weg and o not in kleid and o.name in bpy.data.objects] + sm
    print('SUPERHELD', 'W' if frau else 'M', [o.name for o in sm], len(kleid), 'Kleidungsnetze')
    return netze, alle


def _baum(objs):
    ecken, flaechen = [], []
    for o in objs:
        b = len(ecken)
        ecken += [v.co.copy() for v in o.data.vertices]
        flaechen += [[b + i for i in p.vertices] for p in o.data.polygons]
    return BVHTree.FromPolygons(ecken, flaechen) if flaechen else None


def sitz(netze, alles):
    # Kleidung, unter deren Ecken die Haut liegt (Seite der Flaechennormale), um SITZ nach aussen; alles=False: nur starre Teile am Kopf.
    # Lagen bleiben Lagen (Messlauf 18.11.: Kette unter dem Umhang, Hemd unter der Robe, je Ecke auf SITZ gerueckt, flimmerten als Flecken
    # am Ruecken): jede Ecke rueckt so weit wie die am weitesten gerueckte Ecke binnen LAGE um sie herum, in deren Richtung
    from mathutils.kdtree import KDTree
    haut = [o for o in netze if ist_koerper(o)]
    baum = _baum(haut)
    if baum is None: return 0
    teile = [o for o in netze if ist_kleid(o) and (alles or any(k in o.name for k in STARR))]
    ecken = [(o, v.index) for o in teile for v in o.data.vertices]
    if not ecken: return 0
    kd = KDTree(len(ecken))
    schub = []
    for i, (o, j) in enumerate(ecken):
        co = o.data.vertices[j].co
        kd.insert(co, i)
        loc, nor, _, _ = baum.find_nearest(co, 0.25)
        tief = (co - loc).dot(nor) if loc is not None else 1.0
        schub.append(nor * (SITZ - tief) if tief < SITZ else None)
    kd.balance()
    n_ges = 0
    zaehl = {}
    for i, (o, j) in enumerate(ecken):
        v = o.data.vertices[j]
        best = None
        for _, k, _ in kd.find_range(v.co, LAGE):
            if schub[k] is not None and (best is None or schub[k].length > best.length): best = schub[k]
        if best is None: continue
        v.co += best
        if o.data.shape_keys:
            for kb in o.data.shape_keys.key_blocks: kb.data[j].co += best
        zaehl[o.name] = zaehl.get(o.name, 0) + 1
        n_ges += 1
    for nm, n in zaehl.items(): print('SITZ %s: %d Ecken nach aussen' % (nm, n))
    return n_ges


def haut_weg(netze, alle):
    # Superheld: Haut, ueber der binnen DECKT Kleidung liegt, weg (sonst sticht sie in Bewegung durch; held_klassen SCHRANK=0 tut es am
    # Regulaerkoerper schon); Flaechen nur, wenn alle ihre Ecken bedeckt sind
    kleid = [o for o in netze if ist_kleid(o)]
    baum = _baum(kleid)
    if baum is None: return
    import bmesh
    for o in [o for o in netze if ist_koerper(o)]:
        me = o.data
        me.calc_normals_split() if hasattr(me, 'calc_normals_split') else None
        bedeckt = []
        gname = {g.index: g.name for g in o.vertex_groups}
        for v in me.vertices:
            st = gname.get(max(v.groups, key=lambda x: x.weight).group, '') if v.groups else ''
            # Rumpf und Glieder unter weiter Kleidung (Robe): in Bewegung kommt die Haut bis DECKT_WEIT an den Stoff (Messlauf 18.11. (3):
            # Schulterblatt des Superhelden durch die Robe im Stehen); Kopf, Hals, Haende nur DECKT (Kinn ueber dem Kragen bleibt)
            weit = DECKT if st.startswith(('Head', 'neck', 'hand', 'thumb', 'index', 'middle', 'ring', 'pinky')) else DECKT_WEIT
            h = baum.ray_cast(v.co + v.normal * 0.001, v.normal, weit)
            # Haut zwischen den Ecken der Kleidung schon aussen (Muskeln des Superhelden, Messlauf 18.11.: Flecken am Ruecken): darunter liegt
            # Kleidung, also auch weg
            if h[0] is None: h = baum.ray_cast(v.co - v.normal * 0.001, -v.normal, 0.03)
            if h[0] is None: h = baum.find_nearest(v.co, NAH)   # Messlauf 18.11. (2): Haut am Schulterblatt unter der Robe blieb
            bedeckt.append(h[0] is not None)
        # wie im Spiel (held_klassen LEIB_KNOCHEN, DECKT_AB; heldfigur.gd kleide): ein Leibstueck, das zur Haelfte bedeckt ist, faellt ganz
        # weg (Messlauf 18.11. (4): ohne das blieb am Schulterblatt des Superhelden Haut, die im Stehen durch die Robe stach)
        stueck = []
        for v in me.vertices:
            st = gname.get(max(v.groups, key=lambda x: x.weight).group, '') if v.groups else ''
            stueck.append(next((k for k, kn in LEIB_KNOCHEN.items() if st.startswith(kn)), ''))
        for k in LEIB_KNOCHEN:
            ix = [i for i, x in enumerate(stueck) if x == k]
            if ix and sum(bedeckt[i] for i in ix) >= DECKT_AB * len(ix):
                for i in ix: bedeckt[i] = True
                print('LEIB WEG %s %s: %d von %d Ecken bedeckt' % (o.name, k, sum(bedeckt[i] for i in ix), len(ix)))
        bm = bmesh.new(); bm.from_mesh(me)
        bm.verts.ensure_lookup_table()
        fl = [f for f in bm.faces if all(bedeckt[x.index] for x in f.verts)]
        n = len(fl)
        bmesh.ops.delete(bm, geom=fl, context='FACES_ONLY')
        lose = [x for x in bm.verts if not x.link_faces]
        bmesh.ops.delete(bm, geom=lose, context='VERTS')
        bm.to_mesh(me); bm.free()
        print('HAUT WEG %s: %d Flaechen' % (o.name, n))


def vorbereiten(volk, p, frau):
    arm, netze, alle = laden(p)
    starr(netze)
    if VO.ZIELE[volk]['koerper'] == 'Superhero':
        netze, alle = auf_superheld(arm, netze, alle, frau)
    return arm, netze, alle


def baue(volk, t, g, mensch):
    z = VO.ZIELE[volk]
    frau = g == 'W'
    p = os.path.join(Z, 'held_%s_%s.glb' % (t, g))
    h_soll = z['h'] * (VO.FRAU if frau else 1.0)
    e = VO.einstellung_start(z)
    beste = None
    for runde in range(7):
        arm, netze, alle = vorbereiten(volk, p, frau)
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
            arm, netze, alle = vorbereiten(volk, p, frau)
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
    n_sitz = sitz(netze, volk == 'ork')
    if volk == 'ork': haut_weg(netze, alle)
    alle = [o for o in alle if o.name in bpy.data.objects]
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
         'einstellung': {k: round(v, 3) for k, v in e.items()} if volk != 'mensch' else {},
         'koerper': VO.ZIELE[volk]['koerper'], 'sitz_ecken': n_sitz}
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
