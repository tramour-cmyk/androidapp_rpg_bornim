# 431 Stufe 1 (Chef 15.11., 12:43 „431g A“; 11:58: „Das kann ja nicht sein, dass wir für jeden Körper alles immer anpassen müssen“):
# Kleiderschrank. Ein Stueck unserer Tracht wird einmal angepasst und von hier auf jeden Volkskoerper aus voelker.py uebertragen
# (kauf_kleid.py mit KOERPER_DATEI, der Koerper bleibt ganz). Erstes Stueck: der Umhang der Wache. Er haengt nicht mehr an Armen und
# Beinen (861: Beule unter dem Schlagarm), sondern an einer eigenen Knochenkette am Ruecken (umhang_<spalte>_<n> unter spine_03), links
# und rechts gespiegelt gewichtet; Godot laesst die Kette federn (umhang.gd, SpringBoneSimulator3D mit Kapseln an Rumpf und Beinen,
# Schild, Rueckenwaffe).
# Aufruf: VOELKER=<ordner mit voelker.json> OUT=<ordner mit tex/, karten.json> ZIEL=<ordner> Q=<cc0> [KAUF=..] [STUECK=umhang]
#         [NUR=mensch_mann,ork_frau] bl/bin/python -I kleiderschrank.py
#   -> <ZIEL>/<stueck>_<volk>_<mann|frau>.glb (Koerper, Stueck, Geruest mit Kette), <ZIEL>/kleiderschrank.json (Messung je Koerper)
# Messung je Koerper (Zeilen SCHRANK): Kette links gegen rechts gespiegelt (cm), Gewichte links gegen rechts (groesster Unterschied),
# Abstand des Stuecks zum Koerper (kleinster, Mittel), Anteil der Ecken an Armen und Beinen (soll 0).
import bpy, bmesh, os, sys, json, subprocess
import numpy as np
from mathutils import Vector
from mathutils.kdtree import KDTree
from mathutils.bvhtree import BVHTree

HIER = os.path.dirname(os.path.abspath(__file__))
VOELKER = os.environ.get('VOELKER', '/tmp/voelker')
OUT = os.environ.get('OUT', '/home/user/rt/out')
ZIEL = os.environ.get('ZIEL', '/tmp/schrank')
STUECK = os.environ.get('STUECK', 'umhang')
NUR = [s for s in os.environ.get('NUR', '').split(',') if s]
os.makedirs(ZIEL, exist_ok=True)

# Stueck -> (Tracht in trachten.json oder „held“, Teile aus teile.json, die mitgehen)
STUECKE = {'umhang': ('held', ['cloak', 'clasp'])}
# Kette: Spalten als Anteil der halben Breite des Umhangs (gespiegelt), Glieder von der Hoehe der Schulterblaetter bis zum Saum
SPALTEN = [('l2', -0.78), ('l1', -0.40), ('m', 0.0), ('r1', 0.40), ('r2', 0.78)]
GLIEDER = int(os.environ.get('GLIEDER', '4'))
OBEN_UNTER = float(os.environ.get('KETTE_OBEN', '0.10'))   # Kettenanfang so weit unter den Schultergelenken (m)
BAND = float(os.environ.get('KETTE_BAND', '0.08'))         # darueber bis so weit unter dem Anfang: Uebergang von den alten Gewichten
GLIED_TIEFE = 0.008                                         # Kette so weit innen unter der Aussenseite des Umhangs (m)


def tracht(figur, sex):
    # wie held_klassen.py held3_tracht: held3.py und rig.py ohne Abbau, Umhang als Gitter
    o = os.path.join(ZIEL, 'roh_%s_%s' % (figur, sex)); os.makedirs(o, exist_ok=True)
    if os.path.exists(os.path.join(o, 'held3-rig.blend')): return o
    if not os.path.exists(os.path.join(o, 'tex')): os.symlink(os.path.join(OUT, 'tex'), os.path.join(o, 'tex'))
    env = dict(os.environ, OUT=o, FIGUR=figur, LEUTE=os.path.join(HIER, 'trachten.json'), SEX=sex, FIGUREN='keine')
    env.setdefault('DREIECKE', '0'); env.setdefault('GITTER', 'cloak,robe,tabard')
    env.setdefault('KARTEN', os.path.join(OUT, 'karten.json'))
    for s in ('held3', 'rig'):
        r = subprocess.run([sys.executable, '-I', os.path.join(HIER, s + '.py')], env=env, capture_output=True, text=True)
        if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('%s.py %s %d' % (s, figur, r.returncode))
    return o


def uebertragen(e, quelle, teile, kennung):
    roh = os.path.join(ZIEL, 'roh'); os.makedirs(roh, exist_ok=True)
    alle = json.load(open(os.path.join(quelle, 'teile.json')))
    ohne = [t for t in alle if t not in teile]
    env = dict(os.environ, OUT=quelle, ZIEL=roh, KENNUNG=kennung, KOERPER_DATEI=os.path.join(VOELKER, e['datei']), KOERPER=e['koerper'],
               KOPF='', HAAR='', BART='', FARBE='keine', STOPPELN='0', HAUT='mittel', FORM='', OHNE_TEIL=','.join(ohne),
               KOERPER_BLEIBT='1', FIGUREN='keine')
    r = subprocess.run([sys.executable, '-I', os.path.join(HIER, 'kauf_kleid.py')], env=env, capture_output=True, text=True)
    print('\n'.join(l for l in r.stdout.splitlines() if l.startswith(('KAUFKLEID OK', 'UMHANG', 'OHNE', 'LAGEN'))))
    if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('kauf_kleid.py %s %d' % (kennung, r.returncode))
    return os.path.join(roh, kennung + '.blend')


def welt(o):
    co = np.empty(len(o.data.vertices) * 3); o.data.vertices.foreach_get('co', co)
    M = np.array(o.matrix_world)
    return co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]


def dicht(o, namen):
    W = np.zeros((len(o.data.vertices), len(namen))); gi = {g.index: namen.index(g.name) for g in o.vertex_groups if g.name in namen}
    for v in o.data.vertices:
        for g in v.groups:
            j = gi.get(g.group)
            if j is not None: W[v.index, j] += g.weight
    return W


def zelt(x, punkte):
    # lineare Anteile von x zwischen benachbarten Stuetzstellen (aussen ganz an der letzten)
    w = np.zeros(len(punkte))
    if x <= punkte[0]: w[0] = 1.0; return w
    if x >= punkte[-1]: w[-1] = 1.0; return w
    k = int(np.searchsorted(punkte, x)) - 1
    t = (x - punkte[k]) / (punkte[k + 1] - punkte[k]); w[k] = 1 - t; w[k + 1] = t
    return w


def kette(arm, kleid, teilnamen):
    tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
    V = welt(kleid)
    um = tl == teilnamen.index('cloak')
    C = V[um]
    B = {b.name: arm.matrix_world @ b.head_local for b in arm.data.bones}
    zeichen = 1.0 if B['upperarm_l'].x > B['upperarm_r'].x else -1.0   # Spalten „l“ auf der Seite von upperarm_l
    sz = 0.5 * (B['upperarm_l'].z + B['upperarm_r'].z)
    z0 = sz - OBEN_UNTER; z1 = float(C[:, 2].min())
    mx = 0.5 * (B['upperarm_l'].x + B['upperarm_r'].x)

    def halb(z):   # halbe Breite des Umhangs auf Hoehe z (gespiegelt gemittelt)
        s = C[np.abs(C[:, 2] - z) < 0.04]
        if not len(s): s = C[np.argsort(np.abs(C[:, 2] - z))[:40]]
        return max(0.5 * ((s[:, 0] - mx).max() - (s[:, 0] - mx).min()), 0.05)

    def hinten(x, z):   # Aussenseite des Umhangs (y am weitesten hinten, +y) an der Stelle x, z
        d = (C[:, 0] - x) ** 2 + (C[:, 2] - z) ** 2
        n = C[np.argsort(d)[:24]]
        return float(n[:, 1].max()) - GLIED_TIEFE

    zs = [z0 + (z1 - z0) * j / GLIEDER for j in range(GLIEDER + 1)]
    gelenke = {}
    for sp, a in SPALTEN:
        pts = []
        for z in zs:
            x = mx + (zeichen if sp.startswith('l') else -zeichen) * abs(a) * halb(z) if a else mx
            pts.append(Vector((x, 0.0, z)))
        gelenke[sp] = pts
    # Spiegeln: Tiefe aus beiden Seiten gemittelt, damit links und rechts gleich liegen
    for sp, a in SPALTEN:
        for p in gelenke[sp]:
            p.y = 0.5 * (hinten(p.x, p.z) + hinten(2 * mx - p.x, p.z)) if sp != 'm' else hinten(p.x, p.z)
    # Knochen anlegen (Ruhelage), erstes Glied unter spine_03
    bpy.context.view_layer.objects.active = arm
    for o in bpy.context.selected_objects: o.select_set(False)
    arm.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    eb = arm.data.edit_bones
    inv = arm.matrix_world.inverted()
    namen = []
    for sp, a in SPALTEN:
        vor = eb['spine_03']
        for j in range(GLIEDER):
            b = eb.new('umhang_%s_%d' % (sp, j + 1))
            b.head = inv @ gelenke[sp][j]; b.tail = inv @ gelenke[sp][j + 1]
            b.roll = 0.0; b.parent = vor; b.use_connect = j > 0; b.use_deform = True
            vor = b; namen.append(b.name)
    bpy.ops.object.mode_set(mode='OBJECT')
    # Gewichte: unter dem Anfang die Kette (quer zwischen den Spalten, laengs zwischen den Gliedern), im Band weich hinueber
    kn = [b.name for b in arm.data.bones]
    W = dicht(kleid, kn)
    alt_arm_bein = float(((W[um][:, [kn.index(n) for n in kn if n.startswith(('upperarm', 'lowerarm', 'hand', 'thigh', 'calf'))]].sum(1)) > 0.01).mean())
    for i in np.where(um)[0]:
        x, y, z = V[i]
        if z > z0: a = 0.0
        else: a = float(np.clip((z0 - z) / BAND, 0, 1)); a = a * a * (3 - 2 * a)
        if a <= 0: continue
        u = (z0 - z) / max(z0 - z1, 1e-3) * GLIEDER
        lw = zelt(u, [j + 0.5 for j in range(GLIEDER)])
        q = (x - mx) / halb(z) * zeichen   # +: Seite l
        # Stuetzstellen quer: Spalten l bei q > 0
        qs = [(abs(s) if sp.startswith('l') else -abs(s)) for sp, s in SPALTEN]
        ordnung = np.argsort(qs)
        qw = zelt(q, [qs[k] for k in ordnung])
        neu = np.zeros(len(kn))
        for oi, k in enumerate(ordnung):
            if qw[oi] <= 0: continue
            sp = SPALTEN[k][0]
            for j in range(GLIEDER):
                if lw[j] > 0: neu[kn.index('umhang_%s_%d' % (sp, j + 1))] += qw[oi] * lw[j]
        alt = W[i] / max(W[i].sum(), 1e-6)
        W[i] = (1 - a) * alt + a * neu
    W[um] /= np.maximum(W[um].sum(1, keepdims=True), 1e-6)
    # alte Gruppen der Umhangecken ersetzen
    gruppen = {g.name: g for g in kleid.vertex_groups}
    for n in kn:
        if n not in gruppen: gruppen[n] = kleid.vertex_groups.new(name=n)
    idx = [int(i) for i in np.where(um)[0]]
    for g in gruppen.values(): g.remove(idx)
    for j, n in enumerate(kn):
        sel = np.where(um & (W[:, j] > 1e-4))[0]
        for i in sel: gruppen[n].add([int(i)], float(W[i, j]), 'REPLACE')
    # Messung
    m = {'knochen': namen, 'oben_m': round(z0, 3), 'saum_m': round(z1, 3)}
    fehl = 0.0
    for sp, a in SPALTEN:
        if not sp.startswith('l'): continue
        for p, q in zip(gelenke[sp], gelenke['r' + sp[1:]]):
            fehl = max(fehl, (Vector((2 * mx - q.x, q.y, q.z)) - p).length)
    m['kette_spiegel_cm'] = round(fehl * 100, 2)
    kd = KDTree(int(um.sum())); ui = np.where(um)[0]
    for k, i in enumerate(ui): kd.insert(Vector(V[i]), k)
    kd.balance()
    def gegen(n):
        if n.startswith('umhang_l'): return 'umhang_r' + n[8:]
        if n.startswith('umhang_r'): return 'umhang_l' + n[8:]
        if n.endswith('_l'): return n[:-2] + '_r'
        if n.endswith('_r'): return n[:-2] + '_l'
        return n
    perm = [kn.index(gegen(n)) if gegen(n) in kn else j for j, n in enumerate(kn)]
    gw = []
    for k, i in enumerate(ui):
        x, y, z = V[i]
        _, k2, d = kd.find(Vector((2 * mx - x, y, z)))
        if d > 0.01: continue
        gw.append(float(np.abs(W[i] - W[ui[k2]][perm]).max()))
    m['gewicht_spiegel_max'] = round(max(gw), 3) if gw else None
    m['gewicht_spiegel_mittel'] = round(float(np.mean(gw)), 4) if gw else None
    m['gespiegelte_ecken'] = len(gw)
    an = [kn.index(n) for n in kn if n.startswith(('upperarm', 'lowerarm', 'hand', 'thigh', 'calf', 'foot'))]
    m['arm_bein_anteil_vorher'] = round(alt_arm_bein, 3)
    m['arm_bein_anteil'] = round(float((W[um][:, an].sum(1) > 0.01).mean()), 3)
    return m


def abstand(koerper, kleid, teilnamen):
    tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
    V = welt(kleid)[tl == teilnamen.index('cloak')]
    dg = bpy.context.evaluated_depsgraph_get()
    bv = BVHTree.FromObject(koerper, dg)
    mw = koerper.matrix_world.inverted()
    d = []
    for v in V[::3]:
        h = bv.find_nearest(mw @ Vector(v), 0.5)
        if h[0] is not None: d.append(h[3])
    d = np.array(d)
    return {'abstand_min_cm': round(float(d.min()) * 100, 1), 'abstand_mittel_cm': round(float(d.mean()) * 100, 1)}


figur, teile = STUECKE[STUECK]
liste = json.load(open(os.path.join(VOELKER, 'voelker.json')))['voelker']
aus = []
for e in liste:
    name = e['datei'][len('volk_'):-4]
    if NUR and name not in NUR: continue
    quelle = tracht(figur, 'w' if e['frau'] else 'm')
    kennung = '%s_%s' % (STUECK, name)
    blend = uebertragen(e, quelle, teile, kennung)
    bpy.ops.wm.open_mainfile(filepath=blend)
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    arm.data.pose_position = 'REST'
    kleid = bpy.data.objects['Kleid']
    tn = json.load(open(os.path.join(quelle, 'teile.json')))
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    koerper = max([o for o in netze if o is not kleid], key=lambda o: len(o.data.vertices))
    m = kette(arm, kleid, tn)
    m.update(abstand(koerper, kleid, tn))
    m.update({'volk': e['volk'], 'frau': e['frau'], 'datei': kennung + '.glb', 'groesse_m': e['groesse_m']})
    print('SCHRANK', json.dumps(m, ensure_ascii=False))
    for o in netze: o.data.name = o.name
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + netze: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, kennung + '.glb'), export_format='GLB', use_selection=True, export_animations=False,
                              export_apply=False, export_skins=True, export_vertex_color='ACTIVE')
    aus.append(m)
json.dump({'stueck': STUECK, 'koerper': aus}, open(os.path.join(ZIEL, 'kleiderschrank.json'), 'w'), indent=1, ensure_ascii=False)
print('SCHRANK OK', STUECK, len(aus))
