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
# 376.1 Tracht je Herkunft (Chef 01.11., 11:19 „376.1 wie Sokrates“, Archiv): Mann und Frau gleich; Kettenhemd und lange Robe an den
# Frauenkoerper angepasst (held3.py SEX=w, dann kauf_kleid.py auf den Frauenkoerper); langes Haar unter Kapuze verborgen (Godot).
# Je Tracht und Geschlecht ein Modell (TRACHTEN x M/W); welche Herkunft welche Tracht traegt, steht in held-klassen.json (HERKUENFTE).
# Statur (376.1, wie alt CreateScreen.kt Build: Schlank, Normal, Kraeftig): Formschluessel „statur_schlank“, „statur_kraeftig“ an
# jedem Netz (statur()); Godot waehlt sie (heldfigur.gd).
# Aufruf: OUT=<ordner mit held3-rig.blend> ZIEL=<ordner> Q=<cc0> KAUF=<kaufpakete> [TRACHTEN=WACHE,ROBE] [GESCHLECHT=W] bl/bin/python -I held_klassen.py
#   -> <ZIEL>/held_<TRACHT>_<M|W>.glb, haare.glb (Mann), haare_w.glb (Frau), bewegungen.glb, held-klassen.json
#   FREI=1: ohne Kaufpakete mit dem freien Ersatz (quaternius.ERSATZ, Superhero-Koerper), nur zur Probe am Rechner
import bpy, glob, os, sys, json, subprocess
import numpy as np
from mathutils import Vector

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
os.environ.setdefault('FIGUREN', 'keine')
OUT = os.environ.get('OUT', '/home/user/q376/out')
ZIEL = os.environ.get('ZIEL', os.path.join(OUT, 'klassen'))
os.makedirs(ZIEL, exist_ok=True)
import quaternius as QT
import kopf as KO

FREI = os.environ.get('FREI') == '1'
NUR_G = [s for s in os.environ.get('GESCHLECHT', '').split(',') if s]
NUR = [s for s in os.environ.get('TRACHTEN', '').split(',') if s]
# Koerper und Kopf je Geschlecht (Quaternius Universal Base Characters, Regular; FREI: Superhero, frei)
GESCHLECHTER = {
    'M': {'koerper': 'Regular_Male_FullBody', 'kopf': 'Regular_Male_OnlyHead', 'v': 'Male', 'sex': 'm',
          'fuesse': 'Male_Ranger_Feet_Boots'},
    'W': {'koerper': 'Regular_Female_FullBody', 'kopf': 'Regular_Female_OnlyHead', 'v': 'Female', 'sex': 'w',
          'fuesse': 'Female_Ranger_Feet'},
}
if FREI:
    for g in GESCHLECHTER.values(): g['koerper'] = 'Superhero_%s_FullBody' % g['v']
# Trachten; {v}: Male/Female. Pruefer 376.1 Lauf 1 (29.10.): unsere Stiefel wie Holzpfloecke, im rechten ein Loch: Stiefel aus den Kauftrachten
TRACHTEN = {
    'WACHE': {'tracht': 'unsere', 'fuesse': True},   # Kettenhemd, Wappenrock, Umhang (kauf_kleid.py, Chef 27.10., 18:06 „passt“)
    # Lauf 2: Wizard_Feet schraeg wie Clownsschuhe; Chef 28.10., 23:0x: „trägt keine Robe … Kasperlanzug“: lange Robe aus held3 (trachten.json)
    # 376.1 Urteil Tracht (Chef 01.11., 20:2x: „Knie durch“): die Waldlaeuferstiefel reichen bis unters Knie und stachen im Gehen 3-5 cm
    # vorn durch die Robe (pruef_flecken.py, Strahl von vorn: Stiefel vor der Robe auf 0,40-0,48 m). Unter der Robe nur der Fuss: Schaft ab stiefel_bis (m) weg; Pruefer Film 22:18: Schaft mit Schnallen hinten im Gehen durch die Robe, darum 0,18 statt 0,28
    'ROBE': {'tracht': 'held_wizard', 'fuesse': True, 'stiefel_bis': 0.18},
    'KLOSTER': {'kleid': '{v}_Knight_Cloth', 'ohne': ['Horns'], 'stahl': False,   # Pruefer Lauf 1: Arme mit STAHL schwarz (Bild 0,20/0,13/0,08)
                'sonne': 'Body_Cloth', 'entgruen': ['Legs_Armor', 'Feet_Armor', 'Arms']},   # Lauf 1: Handschuhe gruenlich (118/124/109)
    'WALD': {'kleid': '{v}_Ranger'},   # Kapuze (Head_Hood) bleibt als eigenes Netz: Godot zeigt sie je Herkunft
    'BAUER': {'kleid': '{v}_Peasant'},
}
# Herkunft (Spielsystem 2.0, Entscheidung 68; Archiv 376.1 „Tracht der Heldin“, Stellungnahme Sokrates) -> Tracht; Schuerze fuer den
# Schmiedelehrling gibt es im Bestand nicht (Modular Character Outfits: Knight, Knight_Cloth, Noble, Peasant, Ranger, Wizard)
HERKUENFTE = {
    'WACHSOLDAT': {'tracht': 'WACHE'}, 'ZAUBERLEHRLING': {'tracht': 'ROBE'}, 'KLOSTERSCHUELER': {'tracht': 'KLOSTER'},
    'JAEGERKIND': {'tracht': 'WALD', 'kapuze': True}, 'HERUMTREIBER': {'tracht': 'WALD', 'kapuze': False},
    'KRAEUTERSAMMLER': {'tracht': 'BAUER'}, 'SCHMIEDELEHRLING': {'tracht': 'BAUER'}, 'WANDERER': {'tracht': 'BAUER'},
}
# bis die Erschaffung Herkuenfte kennt (BRS im Spiel): die alte Klasse zeigt die Tracht der Herkunft, zu der sie wird
KLASSE_HERKUNFT = {'FIGHTER': 'WACHSOLDAT', 'WIZARD': 'ZAUBERLEHRLING', 'ROGUE': 'HERUMTREIBER', 'CLERIC': 'KLOSTERSCHUELER'}
# Statur wie die Leute (held3.py BW: Runde 2 „1,1/0,9 sah man nicht“); Faktor quer zum Knochen, der Rumpf in der Breite nur zu 60 %,
# weil die Knochen des Kaufkoerpers bleiben (die Arme haengen am selben Platz neben dem breiteren Rumpf)
STATUR = {'schlank': 0.85, 'kraeftig': 1.2}
# Maennerhaar und Baerte (Hairstyles/Rigged to Head Bone/Male) und Frauenhaar (Female; Chef 29.10., 11:43 „Alle bleiben“, Archiv 376.1
# Frisuren): jede Frisur auf beiden Koepfen, die des anderen Geschlechts umgelegt (umlegen); Baerte nur beim Mann
HAARE_M = ['Hair_SimpleParted', 'Hair_Buzzed', 'Hair_SlickBack', 'Hair_Ponytail', 'Hair_Balding', 'Hair_Dreads', 'Hair_Mohawk']
HAARE_W = ['Hair_Long', 'Hair_LongDreads', 'Hair_Ponytail_2', 'Hair_Bob', 'Hair_Buns']
HAARE = HAARE_M + HAARE_W
BAERTE = ['Hair_Beard', 'Hair_Moustache', 'Hair_MuttonChops']
# 475 Lauf 2 (Chef 04.11., 20:47: „Borin und Bram. Den gleichen Bart“): weitere Bartformen aus dem Vollbart (baerte_mehr); Godot nimmt
# auch mehrere mit Komma (leute.json kauf.bart, z. B. Schnauzer und Kinnbart)
BAERTE_MEHR = ['Bart_Kurz', 'Bart_Kinn', 'Bart_Lang', 'Bart_Breit']
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
    # Haut mit Gesicht: RegularMale…, Female_Regular… (Kaufkopf), Superhero… (frei)
    haut = next(o for o in netze if ('regular' in o.name.lower() or 'superhero' in o.name.lower()) and not o.name.startswith(('Eye', 'Hair')))
    augen = next((o for o in netze if o.name.startswith('Eyes')), None)
    brauen = [o for o in netze if o.name.startswith('Eyebrows')]
    return haut, augen, brauen


KOPFTEILE = ('hood', 'kapuze', 'gugel', 'helm', 'armet', 'tuch', 'scarf', 'schal', 'circlet', 'reif')


def kopfsitz(netze, haut, p, gesicht=None):
    """475 (Prueferbefund 04.11., 06:37; 475a 1, Chef 13:32: „das Gesicht bleibt frei und erkennbar: Visier offen, Tuch auf dem Kopf,
    Kapuze zurueck oder hoeher, nichts scheint durch“): Kopfbedeckungen der Leute auf dem Kaufkopf setzen, mit Zahlen im Protokoll.
    Kopftuch (unser Teil aus held3, fuer unseren Kopf gebaut): so weit hoch, dass es 1,2 cm ueber dem Scheitel liegt (Pruefer: ueber Mund
    und Kinn). Visier des Kaufhelms (Armet): Flaechen vor dem Gesicht zwischen Kinn und 2,5 cm ueber den Augen weg. Dann jede Ecke einer
    Kopfbedeckung, die weniger als 6 mm ueber der Haut liegt (oder darunter), entlang der Hautnormale hinaus (Kapuze scheint durch).
    Gibt die Netze zurueck: sie bekommen die Formschluessel des Kopfs (sonst stiesse das Gesicht der Person durch)."""
    import bmesh
    from mathutils.kdtree import KDTree
    teile = [o for o in netze if o is not haut and any(k in o.name.lower() for k in KOPFTEILE)]
    if not teile: return []
    W = KO._welt(haut)
    me = haut.data; N = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('normal', N)
    N = N.reshape(-1, 3) @ np.array(haut.matrix_world.to_3x3().inverted().transposed()).T
    N /= np.maximum(np.linalg.norm(N, axis=1, keepdims=True), 1e-9)
    # Lauf 2 (Pruefer lokal 21:57: Gruen der Kapuze scheint an Hals und Kinnrand durch): auch der Hals bis 12 cm unter dem Kinn
    kopf = np.where((W[:, 2] > p['kinn_z'] - 0.12) & (np.linalg.norm(W - p['mitte'], axis=1) < 0.24))[0]
    kd = KDTree(len(kopf))
    for j, i in enumerate(kopf): kd.insert(Vector(W[i]), j)
    kd.balance()
    for o in teile:
        n = o.name.lower()
        if 'tuch' in n:
            V = KO._welt(o)
            dz = p['oben'] + 0.012 - float(V[:, 2].max())
            if dz > 0.003:
                KO._zurueck(o, V + np.array([0.0, 0.0, dz])); print('KOPFSITZ', o.name, 'Tuch hoch um %.3f m' % dz)
        if 'tuch' in n or 'hood' in n:   # 475 Lauf 2 (Chef 20:49): Gesicht ganz frei, Stirn bis Kinn, so breit wie das Gesicht
            bm = bmesh.new(); bm.from_mesh(o.data); mw = o.matrix_world; bx = p['augen_x'] / 0.6 * 1.05
            weg = [f for f in bm.faces if (lambda c: c.y < p['mitte'][1] - 0.03 and abs(c.x) < bx and p['kinn_z'] - 0.03 < c.z < p['augen_z'] + 0.03)(mw @ f.calc_center_median())]
            bmesh.ops.delete(bm, geom=weg, context='FACES'); bm.to_mesh(o.data); bm.free(); o.data.update()
            print('KOPFSITZ', o.name, 'Gesicht frei:', len(weg), 'Flaechen weg')
        if 'armet' in n:
            bm = bmesh.new(); bm.from_mesh(o.data); mw = o.matrix_world
            # Lauf 2 (Pruefer 21:26: Wangenklappen bis neben die Mundwinkel): nach der Flaechenmitte, auch die Wangenklappen vor dem Gesicht
            # Pruefer lokal 21:57: graublaues Band quer ueber das Kinn unter der Unterlippe (Kinnschutz): vorn bis 7 cm unter das Kinn
            weg = [f for f in bm.faces if (lambda c: (c.y < p['mitte'][1] - 0.02 and p['kinn_z'] - 0.04 < c.z < p['augen_z'] + 0.025)
                                           or (c.y < p['mitte'][1] - 0.04 and p['kinn_z'] - 0.07 < c.z <= p['kinn_z'] - 0.04))(mw @ f.calc_center_median())]
            bmesh.ops.delete(bm, geom=weg, context='FACES'); bm.to_mesh(o.data); bm.free(); o.data.update()
            print('KOPFSITZ', o.name, 'Visier offen:', len(weg), 'Flaechen weg')
        V = KO._welt(o); durch = 0; tief = 0.0
        for k in range(len(V)):
            q, j, d = kd.find(Vector(V[k]))
            if q is None or d > 0.05: continue
            i = kopf[j]; h = float(np.dot(V[k] - W[i], N[i]))
            if h < 0.006:
                durch += h < 0.0; tief = min(tief, h)
                V[k] = V[k] + N[i] * (0.006 - h)
        KO._zurueck(o, V)
        print('KOPFSITZ', o.name, 'unter der Haut vorher %d Ecken (tiefste %.1f mm), alle jetzt 6 mm darueber' % (durch, -tief * 1000))
        if gesicht: kopfsitz_geformt(o, W, N, kopf, p, gesicht)
    return teile


def kopfsitz_geformt(o, W, N, kopf, p, ge, runden=8):
    """475 Lauf 2 (Pruefer vor dem Versand 04.11., 22:24: Gruen der Kapuze an Hals und Kinnrand bei Garrick und Morwen; Spur (a)): kopfsitz
    mass gegen die ungeformte Haut, Godot mischt aber das Gesicht der Person (Formschluessel, kopf.feld) an Haut und Kopfteil; das Feld
    ist am Kinn steil (Laenge, Kiefer, Kinn), die Haut wandert dort anders als das Kopfteil 6 mm daneben. Hier mit dem Gesicht der Person:
    jede Ecke unter 6 mm ueber der geformten Haut hinaus, bis keine mehr fehlt; Zahlen vorher je Gegend im Protokoll."""
    from mathutils.kdtree import KDTree
    Wg = W + KO.feld(W, p, ge)
    kd = KDTree(len(kopf))
    for j, i in enumerate(kopf): kd.insert(Vector(Wg[i]), j)
    kd.balance()
    vorher = None
    for r in range(runden):
        V = KO._welt(o); Vg = V + KO.feld(V, p, ge); n = 0
        zahl = {'hals': [0, 0], 'kinn': [0, 0], 'wange': [0, 0], 'oben': [0, 0]}
        for k in range(len(V)):
            q, j, d = kd.find(Vector(Vg[k]))
            if q is None or d > 0.05: continue
            i = kopf[j]; h = float(np.dot(Vg[k] - Wg[i], N[i]))
            if h < 0.006:
                z = Vg[k][2]
                g = 'hals' if z < p['kinn_z'] else 'kinn' if z < p['mund_z'] else 'wange' if z < p['augen_z'] else 'oben'
                zahl[g][0] += h < 0.0; zahl[g][1] += h < 0.002
                V[k] = V[k] + N[i] * (0.006 - h); n += 1
        if vorher is None: vorher = zahl
        if not n or r == runden - 1: break   # letzte Runde zaehlt nur (Lauf 10.11.: Jorin nach 4 Runden 24 Ecken zwischen 2 und 6 mm)
        KO._zurueck(o, V)
    print('KOPFSITZ', o.name, 'mit Gesicht der Person vorher unter der Haut/unter 2 mm je Gegend', vorher,
          '; nach %d Runden noch %d Ecken unter 6 mm, davon unter der Haut %d' % (r, n, sum(v[0] for v in zahl.values())))


def kragen_unter_kapuze(o, netze, haut, p, ge, luft=0.004):
    """475 (Chef 10.11., 09:09: Morwens Hals „grün im Schatten“; nachgestellt 10.11. am Rechner: grün-schwarze Flecken unter dem Kinn,
    ohne Kleid glatt): kopf_frei legt den Kragen des Kleids und kopfsitz die Kapuze je 6 mm ueber die Haut; am Hals durchdringen sich
    die groben Dreiecke des Kragens und die Kapuze. Erster Versuch (Kapuze 4 mm ueber die Ecken des Kragens schieben) aenderte nichts:
    die Flaechen schneiden sich zwischen den Ecken. Die Kapuze umhuellt den Hals ohnehin, darum faellt der Kragen darunter weg: jede
    Flaeche des Kleids am Hals, von der eine Ecke nicht mindestens [luft] ueber der naechsten Ecke der Kapuze liegt (gemessen wie in Godot:
    Kapuze mit dem Gesicht der Person, Kleid ohne)."""
    import bmesh
    from mathutils.kdtree import KDTree
    kleid = [k for k in netze if k is not haut and k is not o and 'teil' in k.data.attributes]
    if not kleid: return
    W = KO._welt(haut); Wg = W + KO.feld(W, p, ge or {})
    me = haut.data; N = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('normal', N)
    N = N.reshape(-1, 3) @ np.array(haut.matrix_world.to_3x3().inverted().transposed()).T
    N /= np.maximum(np.linalg.norm(N, axis=1, keepdims=True), 1e-9)
    kopf = np.where((Wg[:, 2] > p['kinn_z'] - 0.12) & (np.linalg.norm(Wg - p['mitte'], axis=1) < 0.24))[0]
    kh = KDTree(len(kopf))
    for j, i in enumerate(kopf): kh.insert(Vector(Wg[i]), j)
    kh.balance()
    V = KO._welt(o); Vg = V + KO.feld(V, p, ge or {})
    kk = KDTree(len(Vg))
    for j, v in enumerate(Vg): kk.insert(Vector(v), j)
    kk.balance()
    for k in kleid:
        bm = bmesh.new(); bm.from_mesh(k.data); mw = k.matrix_world; weg = []
        for f in bm.faces:
            # Lauf 2 am Rechner (nach der Mitte: noch Flecken links unter dem Kinn): jede Ecke der Flaeche, nicht nur die Mitte
            for v in f.verts:
                c = mw @ v.co
                if not (p['kinn_z'] - 0.14 < c.z < p['kinn_z'] + 0.03): continue
                q, j, d = kk.find(c)
                if q is None or d > 0.04: continue
                qs, js, ds = kh.find(c)
                if qs is None or ds > 0.06: continue
                if float(np.dot(np.array(c) - Vg[j], N[kopf[js]])) < luft: weg.append(f); break
        bmesh.ops.delete(bm, geom=weg, context='FACES'); bm.to_mesh(k.data); bm.free(); k.data.update()
        print('KRAGEN UNTER KAPUZE', k.name, len(weg), 'Flaechen weg')


def wange_messen(netze, haut, p, ge):
    # 475 Spur (b) (Pruefer 22:24: Morwen im Halbprofil Wange vom Kapuzenrand verdeckt): Ecken anderer Netze vor dem Ohr zwischen Kinn und
    # Augen binnen 2 cm ueber der geformten Haut seitlich des Gesichts (|x| ueber 60 % der Augenaussenkante); nur Messung, Protokoll WANGE
    from mathutils.kdtree import KDTree
    W = KO._welt(haut); Wg = W + KO.feld(W, p, ge or {})
    kopf = np.where((Wg[:, 2] > p['kinn_z'] - 0.02) & (np.linalg.norm(Wg - p['mitte'], axis=1) < 0.2))[0]
    kd = KDTree(len(kopf))
    for j, i in enumerate(kopf): kd.insert(Vector(Wg[i]), j)
    kd.balance()
    for o in netze:
        if o is haut or o.name.startswith(('Eye', 'Hair')): continue
        V = KO._welt(o)
        m = (V[:, 1] < min(p['ohr_r'][1], p['ohr_l'][1]) - 0.005) & (V[:, 2] > p['kinn_z']) & (V[:, 2] < p['augen_z'] + 0.01) \
            & (np.abs(V[:, 0]) > p['augen_x'])
        nah = sum(1 for v in V[m] if kd.find(Vector(v))[2] < 0.02)
        if m.any(): print('WANGE', o.name, int(m.sum()), 'Ecken vor dem Ohr seitlich am Gesicht,', nah, 'davon binnen 2 cm ueber der Haut')


TUCHTEILE = ('tuch', 'tuch_knoten', 'tuch_zipfel')
KOPF_BLEIBT = ('circlet', 'circlet_stein')   # Reif (Lyra) bleibt, wie gebaut


def tuch_haube(haut, p, t, tn):
    """475 Lauf 2 (Pruefer am Kopfbild 21:26: unser Kopftuch steht am Kaufkopf als Ballon ab, Lappen ueber Wange, Mund und Kinn, Zipfel
    sticht hinten heraus): das Tuch aus der Kopfhaut des Kaufkopfs selbst, 9 mm ueber der Haut: Scheitel und Stirn ab 3 cm ueber den
    Augen, hinten ab der Kopfmitte (Ohren, Hinterkopf) bis 3 cm ueber dem Kinn; Farbe, Bild und Kennung wie unser Tuch, der Knoten
    unseres Tuchs hinten an die Haube, der Zipfel faellt weg. t: unser Tuch (eigenes Netz), wird zur Haube."""
    import bmesh
    lt = np.zeros(len(t.data.vertices), dtype=int); t.data.attributes['teil'].data.foreach_get('value', lt)
    nm = np.array([tn[i] if 0 <= i < len(tn) else '?' for i in lt])
    T = KO._welt(t)
    uv0 = {l.vertex_index: tuple(t.data.uv_layers.active.data[l.index].uv) for l in t.data.loops}
    ti = np.where(nm == 'tuch')[0]
    uv_t = uv0.get(int(ti[len(ti) // 2]), (0.5, 0.5)) if len(ti) else (0.5, 0.5)
    alb = np.zeros((len(T), 4)); t.data.color_attributes['albedo'].data.foreach_get('color', alb.ravel()) if 'albedo' in t.data.color_attributes else None
    farbe = alb[ti].mean(0) if len(ti) and alb.any() else np.array([0.6, 0.55, 0.45, 1.0])
    knoten = T[nm == 'tuch_knoten']
    # Haube: Kopie der Haut, nur die Flaechen des Bereichs
    h = haut.copy(); h.data = haut.data.copy(); h.name = 'tuch'
    for c in haut.users_collection: c.objects.link(h)
    W = KO._welt(h)
    me = h.data; N = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('normal', N)
    N = N.reshape(-1, 3) @ np.array(h.matrix_world.to_3x3().inverted().transposed()).T
    N /= np.maximum(np.linalg.norm(N, axis=1, keepdims=True), 1e-9)
    kopf = (np.linalg.norm(W - p['mitte'], axis=1) < 0.16) & (W[:, 2] > p['kinn_z'])
    # Pruefer lokal 22:16 (Fetzen vor dem Ohr bis zum Kiefer): seitlich nur bis 4,5 cm unter die Augen, bis zum Nacken erst hinter dem Ohr
    drin = kopf & ((W[:, 2] > p['augen_z'] + 0.03) | ((W[:, 1] > p['mitte'][1] + 0.03) & (W[:, 2] > p['kinn_z'] + 0.03))
                   | ((W[:, 1] > p['mitte'][1] + 0.005) & (W[:, 2] > p['augen_z'] - 0.045)))

    bm = bmesh.new(); bm.from_mesh(me); bm.verts.ensure_lookup_table()
    alt = bm.verts.layers.int.new('alt')
    for v in bm.verts: v[alt] = v.index
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if not all(drin[v.index] for v in f.verts)], context='FACES')
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
    bm.verts.ensure_lookup_table(); idx = np.array([v[alt] for v in bm.verts], dtype=int)   # alte Ecke je neuer
    bm.verts.layers.int.remove(alt); bm.to_mesh(me); bm.free()
    # Pruefer lokal 21:57 („glatte Glatzenkappe“): Stoff mit Volumen, oben 9 mm, zum Hinterkopf und Nacken bis 2,2 cm (Tuch faellt locker)
    Wi = W[idx]; hinten = np.clip((Wi[:, 1] - p['mitte'][1]) / 0.08, 0, 1) * np.clip((p['augen_z'] + 0.04 - Wi[:, 2]) / 0.08, 0, 1)
    # Rand der Haube (Pruefer lokal 22:14: Spalten zwischen Tuch und Wange): Ringe ab dem Rand, aussen 2 mm, ab dem dritten Ring voll
    ring = np.full(len(me.vertices), 99)
    nb = [[] for _ in range(len(me.vertices))]; anz = {}
    for e in me.edges:
        a_, b_ = e.vertices; nb[a_].append(b_); nb[b_].append(a_)
    for poly in me.polygons:
        for k in poly.edge_keys: anz[k] = anz.get(k, 0) + 1
    rand = {v for k, n in anz.items() if n == 1 for v in k}
    front = list(rand)
    for v in front: ring[v] = 0
    for r in range(1, 4):
        neu_ = [w for v in front for w in nb[v] if ring[w] > r]
        for w in neu_: ring[w] = r
        front = neu_
    voll = np.clip(ring / 3.0, 0.15, 1.0)
    Wn = Wi + N[idx] * ((0.012 + 0.012 * hinten) * voll)[:, None]
    # Ohr (Pruefer 22:14: Ohrmuschel sticht plastisch durch): um das Ohr auf eine glatte Kugel um die Kopfmitte, Halbmesser Ohrspitze + 1 cm
    c = p['mitte']
    for ok in ('ohr_r', 'ohr_l'):
        oh = np.asarray(p[ok]); R = float(np.linalg.norm(oh - c)) + 0.01
        g = np.exp(-np.sum(((Wn - oh) / np.array([0.03, 0.035, 0.04])) ** 2, axis=1)) * (np.sign(Wn[:, 0]) == np.sign(oh[0]))
        d = Wn - c; r_ = np.linalg.norm(d, axis=1, keepdims=True)
        kugel = c + d / np.maximum(r_, 1e-6) * np.maximum(r_, R)
        Wn = Wn + (kugel - Wn) * (g * voll)[:, None]
    KO._zurueck(h, Wn)
    me.materials.clear(); me.materials.append(t.data.materials[0])
    for u in list(me.uv_layers): me.uv_layers.remove(u)
    uv = me.uv_layers.new(name='UVMap')
    for l in me.loops: uv.data[l.index].uv = uv_t
    for a in [a.name for a in me.color_attributes]: me.color_attributes.remove(me.color_attributes[a])
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'POINT'); ca.data.foreach_set('color', np.tile(farbe, len(me.vertices)).ravel())
    if 'teil' not in me.attributes: me.attributes.new('teil', 'INT', 'POINT')
    me.attributes['teil'].data.foreach_set('value', [tn.index('tuch')] * len(me.vertices))
    if 'custom_normal' in me.attributes: me.attributes.remove(me.attributes['custom_normal'])
    me.update()
    # Knoten unseres Tuchs: hinten an die Haube (Mitte, Augenhoehe), sonst weg
    bm = bmesh.new(); bm.from_mesh(t.data); bm.verts.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.where(nm != 'tuch_knoten')[0]], context='VERTS'); bm.to_mesh(t.data); bm.free()
    if len(knoten) and len(me.vertices):
        H = KO._welt(h); hinten = H[np.argmax(H[:, 1] - 0.5 * np.abs(H[:, 2] - p['augen_z']))]
        KO._zurueck(t, KO._welt(t) + (hinten + np.array([0.0, 0.012, 0.0]) - knoten.mean(0)))
        bpy.ops.object.select_all(action='DESELECT'); t.select_set(True); h.select_set(True); bpy.context.view_layer.objects.active = h
        bpy.ops.object.join()
    else:
        bpy.data.objects.remove(t)
    print('TUCH Haube aus der Kopfhaut', len(h.data.vertices), 'Ecken, Knoten', len(knoten), 'Ecken')
    return h


def kopf_frei(netze, haut, p, gesicht, teile):
    """475 Lauf 2 (Chef 04.11., 20:49: „Garrick, Jorin, Liska, Morwen … mit irgendwelchen Verhüllungen im Gesicht … genau der gleiche
    Scheiß“): unsere Kleidung aus held3 (ein Netz „Kleid“, Kennung „teil“ je Ecke) ist fuer unseren Kopf gebaut, nicht fuer den Kaufkopf.
    Was davon im Kopf liegt (ueber dem Kinn, im Umkreis des Kopfs; Ringpanzer am Helm, Kapuzenreste, Kragen), faellt weg; das Kopftuch
    wird ein eigenes Netz „tuch“ (kopfsitz setzt es auf den Scheitel und schneidet das Gesicht frei; vorher lag es im Kleid, kopfsitz sah
    es nie: Lauf 1 ohne Zeile KOPFSITZ fuer Liska). Kragen und Halsteile unter dem Kinn: jede Ecke unter 6 mm ueber der Haut, mit dem
    Gesicht der Person gemessen (Godot mischt es ueber die Formschluessel, das Kleid hat keine), entlang der Hautnormale hinaus.
    Gibt die neuen Netze zurueck (Tuch)."""
    import bmesh
    from mathutils.kdtree import KDTree
    tn = json.load(open(teile)) if os.path.exists(teile) else []
    W = KO._welt(haut); Wg = W + KO.feld(W, p, gesicht or {})
    me = haut.data; N = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('normal', N)
    N = N.reshape(-1, 3) @ np.array(haut.matrix_world.to_3x3().inverted().transposed()).T
    N /= np.maximum(np.linalg.norm(N, axis=1, keepdims=True), 1e-9)
    kopf = np.where((Wg[:, 2] > p['kinn_z'] - 0.12) & (np.linalg.norm(Wg - p['mitte'], axis=1) < 0.24))[0]
    kd = KDTree(len(kopf))
    for j, i in enumerate(kopf): kd.insert(Vector(Wg[i]), j)
    kd.balance()
    neu = []
    for o in [o for o in netze if o is not haut and 'teil' in o.data.attributes]:
        lt = np.zeros(len(o.data.vertices), dtype=int); o.data.attributes['teil'].data.foreach_get('value', lt)
        nm = np.array([tn[i] if 0 <= i < len(tn) else '?' for i in lt])
        V = KO._welt(o)
        im_kopf = (V[:, 2] > p['kinn_z'] + 0.005) & (np.linalg.norm(V - p['mitte'], axis=1) < 0.17) \
            & ((V[:, 1] < p['mitte'][1]) | (V[:, 2] > p['kinn_z'] + 0.045))   # Kragen hinter dem Hals bleibt (wie kauf_kleid.py KOPF_FREI)
        tuch = np.isin(nm, TUCHTEILE)
        weg = im_kopf & ~tuch & ~np.isin(nm, KOPF_BLEIBT)
        reif = np.isin(nm, KOPF_BLEIBT)
        if reif.any():   # Messung (Lauf 10.11., 02:06: Lyras Reif hing vor dem Mund): Lage vorn und hinten gegen Augen und Scheitel
            R = V[reif]; vo = R[:, 1] < p['mitte'][1]
            print('REIF', o.name, 'Ecken', int(reif.sum()), 'vorn z %.3f..%.3f hinten z %.3f..%.3f, Augen %.3f, Scheitel %.3f, Kinn %.3f, Breite x %.3f..%.3f'
                  % (R[vo, 2].min() if vo.any() else 0, R[vo, 2].max() if vo.any() else 0, R[~vo, 2].min() if (~vo).any() else 0,
                     R[~vo, 2].max() if (~vo).any() else 0, p['augen_z'], p['oben'], p['kinn_z'], R[:, 0].min(), R[:, 0].max()))
        for t in sorted(set(nm[weg])): print('KOPFFREI', o.name, t, int((weg & (nm == t)).sum()), 'Ecken im Kopf weg')
        if reif.any(): reif_setzen(o, V, reif, Wg, p, haut)
        if tuch.any():   # Tuch als eigenes Netz (Kopie ohne den Rest)
            t = o.copy(); t.data = o.data.copy(); t.name = 'tuch'
            for c in o.users_collection: c.objects.link(t)
            bm = bmesh.new(); bm.from_mesh(t.data); bm.verts.ensure_lookup_table()
            bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.where(~tuch)[0]], context='VERTS'); bm.to_mesh(t.data); bm.free()
            print('KOPFFREI Tuch eigenes Netz', len(t.data.vertices), 'Ecken')
            neu.append(tuch_haube(haut, p, t, tn))
        # Kragen: unter 6 mm ueber der Haut (Gesicht der Person) hinaus, nur am Hals und unter dem Kinn
        hals = ~weg & ~tuch & (V[:, 2] > p['kinn_z'] - 0.10) & (V[:, 2] < p['kinn_z'] + 0.03)
        raus = 0
        for k in np.where(hals)[0]:
            q, j, d = kd.find(Vector(V[k]))
            if q is None or d > 0.04: continue
            i = kopf[j]; h = float(np.dot(V[k] - Wg[i], N[i]))
            if h < 0.006: V[k] = V[k] + N[i] * (0.006 - h); raus += 1
        KO._zurueck(o, V)
        print('KOPFFREI', o.name, 'Kragen:', raus, 'Ecken auf 6 mm ueber die Haut')
        rest = weg | tuch
        if rest.any():
            bm = bmesh.new(); bm.from_mesh(o.data); bm.verts.ensure_lookup_table()
            bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.where(rest)[0]], context='VERTS'); bm.to_mesh(o.data); bm.free(); o.data.update()
    return neu


def reif_setzen(o, V, reif, Wg, p, haut):
    """475 (Lauf 10.11., 02:06: Lyras Stirnreif hing vor dem Mund; gemessen REIF vorn z bis 1,543 bei Kinn 1,538, Breite ±12 cm): der Reif
    aus held3 ist fuer unseren Kopf gebaut, kauf_kleid zog ihn am Kaufkopf zu einem U bis ans Kinn. Neu gesetzt um die geformte Haut der
    Person: je Winkel um die Kopfachse die Mitte des Bands auf Stirnhoehe (vorn 4 cm ueber den Augen, hinten 6 cm), 8 mm ueber der Haut;
    der Querschnitt des Bands (Abweichung von seiner Mitte je Winkel, hoechstens 1 cm hoch, 8 mm tief) bleibt; Gewicht ganz am Kopf."""
    idx = np.where(reif)[0]; R = V[idx]; cy = p['mitte'][1]
    th = np.arctan2(R[:, 0], cy - R[:, 1])                 # 0 = vorn (Blick -Y)
    rad = np.hypot(R[:, 0], R[:, 1] - cy)
    b = np.round(th / (np.pi / 24)).astype(int)
    zm = np.zeros(len(idx)); rm = np.zeros(len(idx))
    for k in set(b): m = b == k; zm[m] = np.median(R[m, 2]); rm[m] = np.median(rad[m])
    dz = np.clip(R[:, 2] - zm, -0.006, 0.006); dr = np.clip(rad - rm, -0.004, 0.004)
    zr = p['augen_z'] + 0.04 + 0.02 * (1 - np.cos(th)) / 2
    # Haut je Winkel per Strahl von aussen zur Kopfachse (die Ecken des Kaufkopfs liegen auf Stirnhoehe zu weit auseinander)
    from mathutils.bvhtree import BVHTree
    bvh = BVHTree.FromPolygons([Vector(v) for v in Wg], [tuple(f.vertices) for f in haut.data.polygons])
    def haut_r(t, z):
        d = Vector((np.sin(t), -np.cos(t), 0.0)); a = Vector((0.0, cy, z))
        hit = bvh.ray_cast(a + d * 0.4, -d, 0.4)
        return (hit[0] - a).length if hit[0] is not None else None
    neu = np.empty_like(R)
    for j in range(len(idx)):
        r0 = haut_r(th[j], zr[j])
        r = (r0 if r0 is not None else float(rm[j])) + 0.008 + 0.004 + dr[j]
        neu[j] = [r * np.sin(th[j]), cy - r * np.cos(th[j]), zr[j] + dz[j]]
    V[idx] = neu
    print('REIF Haut auf Stirnhoehe r vorn %s, seitlich %s/%s, hinten %s' % tuple(
        ('%.3f' % x if x is not None else '-') for x in (haut_r(0, p['augen_z'] + 0.04), haut_r(np.pi / 2, p['augen_z'] + 0.05),
                                                         haut_r(-np.pi / 2, p['augen_z'] + 0.05), haut_r(np.pi, p['augen_z'] + 0.06))))
    kg = next((vg for vg in o.vertex_groups if vg.name.lower() == 'head'), None)
    if kg is None: kg = o.vertex_groups.new(name='Head')   # Knochen „Head“ des Kaufgeruests (heldfigur.gd find_bone)
    if kg:
        for vg in o.vertex_groups:
            if vg != kg: vg.remove([int(i) for i in idx])
        kg.add([int(i) for i in idx], 1.0, 'REPLACE')
    vo = neu[:, 1] < cy
    print('REIF gesetzt vorn z %.3f..%.3f, hinten z %.3f..%.3f, Breite x %.3f..%.3f, Kopf am Gewicht: %s'
          % (neu[vo, 2].min(), neu[vo, 2].max(), neu[~vo, 2].min() if (~vo).any() else 0, neu[~vo, 2].max() if (~vo).any() else 0,
             neu[:, 0].min(), neu[:, 0].max(), 'ja' if kg else 'nein'))


def schluessel(netze, p, augen=None):
    # je Form ein Formschluessel: Verschiebung aus kopf.feld (Augen je Seite als Ganzes, wie kopf.forme)
    for o in netze:
        W = KO._welt(o)
        if not o.data.shape_keys: o.shape_key_add(name='Basis', from_mix=False)
        Mi = np.array(o.matrix_world.inverted())
        # 475 (Chef 04.11., 13:26: Gesichter nicht „wie geklont“): dazu je Regler ein Schluessel „r_<regler>“ mit KO.EINHEIT; feld ist
        # linear, Godot mischt daraus das Gesicht jeder Person (heldfigur.gd gesicht, leute.json kauf.gesicht), auch an Haar und Bart
        for n, f in [(n, KO.FORMEN[n]) for n in FORMEN] + [('r_' + r, {r: KO.EINHEIT[r]}) for r in KO.REGLER]:
            if o is augen:
                D = np.zeros_like(W)
                for s in (W[:, 0] < 0, W[:, 0] >= 0):
                    if s.any(): D[s] = KO.augen_netz_D(W[s], p, f)
            else: D = KO.feld(W, p, f, 'brauen' if o.name.startswith('Eyebrows') else None)
            sk = o.shape_key_add(name=n, from_mix=False)
            sk.data.foreach_set('co', ((W + D) @ Mi[:3, :3].T + Mi[:3, 3]).ravel())


def dreiecke(netze):
    n = 0
    for o in netze:
        o.data.calc_loop_triangles(); n += len(o.data.loop_triangles)
    return n


def statur_faktor(knochen, bw):
    # wie held3.py (Leute): Rumpf bw, Arme und Oberschenkel bw^0,8, Waden bw^0,7, Hals bw^0,6; Kopf, Haende, Fuesse, Schluesselbein 1
    k = knochen.lower()
    if k.startswith(('pelvis', 'spine')): return bw
    if k.startswith(('upperarm', 'lowerarm', 'thigh')): return bw ** 0.8
    if k.startswith('calf'): return bw ** 0.7
    if k.startswith('neck'): return bw ** 0.6
    return 1.0


def statur(arm, netze, nachbarn=12):
    # Formschluessel je Statur an jedem Netz: jede Ecke quer zu ihren Knochen gestreckt (Abstand zur Knochenstrecke mal Faktor), im Rumpf
    # in der Tiefe ganz, in der Breite zu 60 % (Masse sitzt an Brust und Bauch; die Arme haengen am selben Platz). Die Gewichte sind ueber
    # alle Netze geglaettet (Mittel der naechsten Ecken aller Netze): Koerper, Kleidung und Umhang an derselben Stelle gehen gleich mit,
    # weiter aussen weiter, die Lagen bleiben uebereinander
    from mathutils.kdtree import KDTree
    mw = arm.matrix_world
    kn = [b.name for b in arm.data.bones]
    A = np.array([tuple(mw @ b.head_local) for b in arm.data.bones]); B = np.array([tuple(mw @ b.tail_local) for b in arm.data.bones])
    rumpf = np.array([b.lower().startswith(('pelvis', 'spine')) for b in kn])
    alle_W, alle_G, teile = [], [], []
    for o in netze:
        W = KO._welt(o)
        G = np.zeros((len(W), len(kn)), dtype=np.float32)
        gi = {vg.index: (kn.index(vg.name) if vg.name in kn else -1) for vg in o.vertex_groups}
        for v in o.data.vertices:
            for e in v.groups:
                j = gi.get(e.group, -1)
                if j >= 0: G[v.index, j] += e.weight
        sm = G.sum(1, keepdims=True); G = np.where(sm > 0, G / np.maximum(sm, 1e-9), 0)
        teile.append((o, sum(len(x) for x in alle_W), len(W)))
        alle_W.append(W); alle_G.append(G)
    WW = np.concatenate(alle_W); GG = np.concatenate(alle_G)
    kd = KDTree(len(WW))
    for i, w in enumerate(WW): kd.insert(w, i)
    kd.balance()
    GL = np.empty_like(GG)
    for i, w in enumerate(WW):
        idx = [j for _, j, _ in kd.find_n(w, nachbarn)]
        GL[i] = GG[idx].mean(0)
    # Abstand jeder Ecke zu jeder Knochenstrecke (Vektor von der Strecke zur Ecke)
    AB = B - A; L2 = np.maximum((AB * AB).sum(1), 1e-9)
    for name, bw in STATUR.items():
        f = np.array([statur_faktor(n, bw) for n in kn]) - 1.0
        D = np.zeros_like(WW)
        for j in np.nonzero(f)[0]:
            w = GL[:, j]
            m = w > 1e-4
            if not m.any(): continue
            t = np.clip(((WW[m] - A[j]) @ AB[j]) / L2[j], 0, 1)
            R = WW[m] - (A[j] + t[:, None] * AB[j])
            if rumpf[j]: R[:, 0] *= 0.6
            D[m] += w[m, None] * f[j] * R
        for o, a0, n in teile:
            if not o.data.shape_keys: o.shape_key_add(name='Basis', from_mix=False)
            Mi = np.array(o.matrix_world.inverted())
            sk = o.shape_key_add(name='statur_' + name, from_mix=False)
            sk.data.foreach_set('co', ((WW[a0:a0 + n] + D[a0:a0 + n]) @ Mi[:3, :3].T + Mi[:3, 3]).ravel())
        print('STATUR', name, 'groesste Verschiebung %.1f cm' % (100 * float(np.linalg.norm(D, axis=1).max())))


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


# 463 (Aermel sticht 5-25 mm durch den Umhang, drei Formversuche aus): Umhang im zweiten UV-Satz markieren (u = 1); toon.gdshader
# zieht ihn um „vorrang“ Meter zur Kamera, dann gewinnt er die Tiefe gegen den Aermel. Das Farbbild bleibt am ersten Satz
def vorrang_marke(netze, teile):
    if not os.path.exists(teile): return
    tn = json.load(open(teile))
    # 463 (pruef_flecken RUECK „r+n“): dazu die Aermel im zweiten Wert (v = 1), toon.gdshader schiebt sie um „nach“ zurueck
    ic = tn.index('cloak') if 'cloak' in tn else -9
    ia = tn.index('sleeves') if 'sleeves' in tn else -9
    if ic < 0 and ia < 0: return
    for o in netze:
        me = o.data
        if 'teil' not in me.attributes or len(me.uv_layers) != 1: continue
        tl = [0] * len(me.vertices); me.attributes['teil'].data.foreach_get('value', tl)
        aktiv = me.uv_layers[0]
        uv = me.uv_layers.new(name='vorrang')
        n = na = 0
        for l in me.loops:
            ja = tl[l.vertex_index] == ic; ar = tl[l.vertex_index] == ia
            uv.data[l.index].uv = (1.0 if ja else 0.0, 1.0 if ar else 0.0); n += ja; na += ar
        me.uv_layers.active = aktiv; aktiv.active_render = True
        print('VORRANG', o.name, n, 'Ecken Umhang,', na, 'Aermel')


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


def held3_tracht(figur, sex='m', liste='trachten.json'):
    # Tracht aus held3.py und rig.py (FIGUR aus trachten.json, „held“: unser Held) in einem eigenen Ordner; Texturen und Karten aus OUT;
    # sex w: dieselbe Tracht auf unserem Frauenkoerper (held3.py SEX); 475: liste leute.json fuer die Leute des Dorfs
    o = os.path.join(ZIEL, 'roh_%s_%s' % (figur, sex)); os.makedirs(o, exist_ok=True)
    if not os.path.exists(os.path.join(o, 'tex')): os.symlink(os.path.join(OUT, 'tex'), os.path.join(o, 'tex'))
    env = dict(os.environ, OUT=o, FIGUR=figur, LEUTE=os.path.join(HIER, liste), SEX=sex)
    # 376.1 Urteil Tracht (Chef 01.11., 20:2x: Farbstreifen durch den Umhang, Flecken in der Robe): rig.py baute auf 6000 Dreiecke fuer die
    # ganze alte Figur ab; der Kauffigur blieben Umhang 418, Robe 500 Dreiecke, die Lagen kreuzten sich (pruef_flecken.py). Hier ohne Abbau,
    # Umhang, Robe und Wappenrock als Gitter ausgeduennt (rig.py GITTER): Umhang 3028, Robe 3600 Dreiecke, Figur 25 000 bis 34 000
    env.setdefault('DREIECKE', '0'); env.setdefault('GITTER', 'cloak,robe,tabard')
    env.setdefault('KARTEN', os.path.join(OUT, 'karten.json'))
    for s in ('held3', 'rig'):
        r = subprocess.run([sys.executable, '-I', os.path.join(HIER, s + '.py')], env=env, capture_output=True, text=True)
        if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('%s.py %s %d' % (s, figur, r.returncode))
    return o


def kaempfer(k, g, figur='', fuesse='', stiefel_bis=0.0, liste='trachten.json', kopfteile=()):
    # unsere Tracht auf dem Kaufkoerper (kauf_kleid.py), dann Formschluessel am Kopf; figur: andere Tracht aus trachten.json;
    # fuesse: Stiefel aus den Kauftrachten statt unserer; g: Geschlecht (GESCHLECHTER)
    # 475: liste leute.json (Leute des Dorfs, Kleidung und Kopfbedeckung aus held3 mit uebertragen, LEUTE_KLEID); kopfteile: Teile der
    # Kauftrachten (Helm, Kapuze, Schal) statt unserer, wenn im Bestand
    G = GESCHLECHTER[g]
    roh = os.path.join(ZIEL, 'roh'); os.makedirs(roh, exist_ok=True)
    env = dict(os.environ, KOERPER=G['koerper'], KOPF='', HAAR='', BART='', FARBE='keine', STOPPELN='0', HAUT='mittel', FORM='',
               KENNUNG='held_' + k, ZIEL=roh)
    ohne = []
    kauf_kopf = []
    for t in kopfteile:   # 475: Kaufteil je Geschlecht (Male_…_Head_Hood); fehlt es, bleibt unser Teil aus held3
        n = sorted(x for x in QT.DATEIEN if x.startswith(G['v'] + '_') and x.endswith(t['kauf']))
        if n: kauf_kopf.append(n[0]); ohne += t['statt']
        else: print('FEHLT', G['v'], t['kauf'], '(bleibt', t['statt'], ')')
    if liste != 'trachten.json':
        env['OUT'] = held3_tracht(figur, G['sex'], liste)
        env['KLEID_MEHR'] = ','.join(LEUTE_KLEID)
        env['KOPF_FREI'] = '1'   # 475 Lauf 2: unsere Kopfteile weg, bevor sie die Gesichtshaut wegnehmen (kauf_kleid.py)
        # 1090 (Vorentscheid Sokrates 13.11., 02:46, „1090 A“): unter der Robe keine Hose, wie beim Helden im Zaubergewand (376.1,
        # trachten.json „ohne“); gemessen an Lyra: die Hose lag bis 4 cm am Bein, die Robe 15 bis 30 cm aussen, im Stand stiess sie
        # zwischen den Schienbeinen und an den Knien durch (dunkle Flecken, 1044)
        if json.load(open(os.path.join(HIER, liste))).get(figur, {}).get('rock') == 'robe': ohne = ohne + ['pants']
    elif figur:
        env['OUT'] = held3_tracht(figur, G['sex'])
        ohne = json.load(open(os.path.join(HIER, 'trachten.json')))[figur].get('ohne', [])
    else:
        env['OUT'] = held3_tracht('held', G['sex'])   # unser Held (Frau: auf dem Frauenkoerper); 376.1: auch der Mann eigens, ohne Abbau
    if fuesse: ohne = ohne + ['boots']
    env['OHNE_TEIL'] = ','.join(ohne)
    r = subprocess.run([sys.executable, '-I', os.path.join(HIER, 'kauf_kleid.py')], env=env, capture_output=True, text=True)
    print('\n'.join(l for l in r.stdout.splitlines() if l.startswith(('KAUFKLEID', 'KLEIDUNG', 'HALS', 'UMHANG', 'SCHALE', 'RUECKBAHN', 'LAGEN', 'UNTER WEG'))))
    if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('kauf_kleid.py %d' % r.returncode)
    bpy.ops.wm.open_mainfile(filepath=os.path.join(roh, 'held_%s.blend' % k))
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    netze = [o for o in bpy.data.objects if o.type == 'MESH' and any(m.type == 'ARMATURE' and m.object == arm for m in o.modifiers)]
    if fuesse:
        fn, fp = QT.datei(fuesse)
        if not fp or (fn != fuesse and not FREI): raise SystemExit('FEHLT %s (gekauft, KAUF=)' % fuesse)
        fo = [o for o in QT.importiere(fp)]
        fm = [o for o in fo if o.type == 'MESH']
        QT.an_geruest(fo, arm)   # entfernt das Geruest des Imports
        if stiefel_bis > 0:
            import bmesh
            for o in fm:
                bm = bmesh.new(); bm.from_mesh(o.data); mw = o.matrix_world
                weg = [v for v in bm.verts if (mw @ v.co).z > stiefel_bis]
                bmesh.ops.delete(bm, geom=weg, context='VERTS'); bm.to_mesh(o.data); bm.free()
                print('STIEFEL BIS', stiefel_bis, 'm,', len(weg), 'Ecken weg')
        netze += fm
    for kt in kauf_kopf:   # 475: Helm, Kapuze, Schal aus den Kauftrachten
        kn, kp = QT.datei(kt)
        ko = [o for o in QT.importiere(kp)]
        km = [o for o in ko if o.type == 'MESH']
        a2 = next((o for o in ko if o.type == 'ARMATURE'), None)
        vs = (QT.kopf_pos(arm) - QT.kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
        QT.an_geruest(ko, arm, vs)
        netze += km
        print('KOPFTEIL', k, kt, len(km), 'Netze')
    haut, augen, brauen = kopfnetze(netze)
    beine_weg(haut)
    p = KO.merkpunkte(haut, augen)
    ge = {}
    if liste != 'trachten.json':   # 475 Lauf 2: Kleid aus dem Kopf, Tuch eigenes Netz, Kragen ueber der Haut (kopf_frei)
        ge = json.load(open(os.path.join(HIER, liste))).get(figur, {}).get('kauf', {}).get('gesicht', {})
        netze += kopf_frei(netze, haut, p, ge, os.path.join(env['OUT'], 'teile.json'))
    kopfteile = kopfsitz(netze, haut, p, ge) if liste != 'trachten.json' else []
    for o in kopfteile:
        if 'hood' in o.name.lower(): kragen_unter_kapuze(o, netze, haut, p, ge)
    if liste != 'trachten.json': wange_messen(netze, haut, p, ge)
    schluessel(([haut, augen] if augen else [haut]) + brauen + kopfteile, p, augen)
    statur(arm, netze)
    vorrang_marke(netze, os.path.join(env['OUT'], 'teile.json'))
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


def tracht(k, g, f):
    G = GESCHLECHTER[g]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    kleid = f['kleid'].format(v=G['v'])
    kn, kp = QT.datei(kleid)
    if not kp and FREI: kn, kp = QT.datei('%s_Peasant' % G['v'])   # frei gibt es nur Bauer und Waldlaeufer
    if not kp or (kn != kleid and not FREI): raise SystemExit('FEHLT %s (gekauft, KAUF=)' % kleid)
    objs = QT.importiere(kp)
    arm = next(o for o in objs if o.type == 'ARMATURE'); arm.name = 'Armature'
    netze = [o for o in objs if o.type == 'MESH']
    hn, hp = QT.datei(G['kopf'])
    if not hp or (hn != G['kopf'] and not FREI): raise SystemExit('FEHLT %s (gekauft, KAUF=)' % G['kopf'])
    ko = QT.importiere(hp)
    a2 = next((o for o in ko if o.type == 'ARMATURE'), None)
    vs = (QT.kopf_pos(arm) - QT.kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
    neu = [o for o in ko if o.type == 'MESH']
    if hn != G['kopf']:   # FREI: Superhero-Koerper als Kopf, nur Kopf und Hals
        for o in neu:
            if not o.name.startswith(('Eye', 'Hair')): QT.nur_kopf(o)
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
    statur(arm, netze)
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


def baerte_mehr(voll, haut, p):
    """475 Lauf 2: aus dem Vollbart (Hair_Beard, Welt in der Ruhelage der Bezugsfigur) vier weitere Formen, je Mann eine eigene:
    Bart_Kurz  kurz geschnitten: Abstand zur Haut 40 %, nichts haengt unter das Kinn (Jaeger)
    Bart_Kinn  Kinn- und Spitzbart: nur die Mitte (|x| < 2,4 cm) unter dem Mund, unter dem Kinn spitz zulaufend und 1,8-mal laenger
    Bart_Lang  langer Greisenbart: unter dem Kinn 4-mal laenger, nach unten schmaler, vor die Brust
    Bart_Breit Zwergenvollbart: Abstand zur Haut 1,8-mal, 15 % breiter, unter dem Kinn 2,6-mal laenger, vor die Brust"""
    import bmesh
    from mathutils.kdtree import KDTree
    H = KO._welt(haut)
    kd = KDTree(len(H))
    for i, v in enumerate(H): kd.insert(Vector(v), i)
    kd.balance()
    W0 = KO._welt(voll)
    S = np.array([tuple(kd.find(Vector(v))[0]) for v in W0])   # naechster Hautpunkt je Ecke
    kz, mz = p['kinn_z'], p['mund_z']
    def kopie(name):
        o = voll.copy(); o.data = voll.data.copy(); o.name = name
        for c in voll.users_collection: c.objects.link(o)
        return o
    def weg(o, maske):
        bm = bmesh.new(); bm.from_mesh(o.data); bm.verts.ensure_lookup_table()
        bmesh.ops.delete(bm, geom=[bm.verts[i] for i in np.where(maske)[0]], context='VERTS'); bm.to_mesh(o.data); bm.free(); o.data.update()
    def haengen(W, faktor, schmal, vor):
        # unter dem Kinn: laenger (faktor), nach unten schmaler (schmal: Anteil weniger Breite je 10 cm), nach vorn (vor m je m nach unten)
        W = W.copy(); t = np.clip(kz - W[:, 2], 0.0, None)
        dz = t * (faktor - 1.0)
        W[:, 2] -= dz
        W[:, 0] *= np.clip(1.0 - schmal * (t + dz) / 0.1, 0.25, 1.0)
        W[:, 1] -= vor * dz
        return W
    neu = []
    o = kopie('Bart_Kurz'); W = S + (W0 - S) * 0.4
    KO._zurueck(o, W); weg(o, W0[:, 2] < kz - 0.012); neu.append(o)
    o = kopie('Bart_Kinn'); m = (np.abs(W0[:, 0]) < 0.024) & (W0[:, 2] < mz - 0.004)
    KO._zurueck(o, haengen(W0, 1.4, 0.45, 0.12)); weg(o, ~m); neu.append(o)   # Pruefer lokal 21:57: Zapfen schwebte vor dem Kragen
    o = kopie('Bart_Lang'); KO._zurueck(o, haengen(W0, 4.0, 0.22, 0.45)); neu.append(o)
    o = kopie('Bart_Breit'); W = S + (W0 - S) * 1.8; W[:, 0] *= np.where(W0[:, 2] < mz, 1.15, 1.0)
    KO._zurueck(o, haengen(W, 2.6, 0.05, 0.5)); neu.append(o)
    for o in neu: print('BART', o.name, len(o.data.vertices), 'Ecken')
    return neu


def schaedel(netz, kz):
    # Mitte und Masse des Schaedels: Ecken der Kopfhaut ueber dem Kopfknochen (Welt)
    W = KO._welt(netz)
    W = W[W[:, 2] > kz]
    lo, hi = W.min(0), W.max(0)
    return (lo + hi) / 2, hi - lo


def kopf_masse(g):
    # Schaedel des Kopfs eines Geschlechts (OnlyHead, FREI: Kopf des Superhero-Koerpers); fuer das Umlegen des Haars
    vorher = set(bpy.data.objects)
    _, p = QT.datei(GESCHLECHTER[g]['kopf'])
    if not p: return None
    objs = QT.importiere(p)
    arm = next(o for o in objs if o.type == 'ARMATURE')
    haut, _, _ = kopfnetze([o for o in objs if o.type == 'MESH'])
    s = schaedel(haut, QT.kopf_pos(arm).z)
    for o in [o for o in bpy.data.objects if o not in vorher]: bpy.data.objects.remove(o)
    return s


def umlegen(objs, von, nach):
    # Haar des anderen Geschlechts auf diesen Kopf (Tom 29.10., a6d0858aa): je Achse von Schaedelmitte und -mass des einen auf die des
    # anderen (Masse fast gleich; der Kopfknochen allein liess die Stirn 9 mm durch den Pony stechen)
    f = nach[1] / von[1]
    for o in objs:
        if o.type != 'MESH': continue
        M = o.matrix_world; Mi = M.inverted()
        for v in o.data.vertices:
            w = np.array(tuple(M @ v.co))
            v.co = Mi @ Vector(tuple(nach[0] + (w - von[0]) * f))


def haare(g):
    # Bezugsfigur: Kaufkoerper des Geschlechts; jedes Haar und jeder Bart „Rigged to Head Bone“ an ihren Kopf (wie kauf_kleid.py),
    # Formschluessel mit ihren Merkpunkten, dann ohne Geruest in der Ruhelage. Haar des anderen Geschlechts umgelegt; Baerte nur Mann
    G = GESCHLECHTER[g]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    anders = kopf_masse('W' if g == 'M' else 'M')
    kn, kp = QT.datei(G['koerper'])
    objs = QT.importiere(kp)
    arm = next(o for o in objs if o.type == 'ARMATURE')
    haut, augen, brauen = kopfnetze([o for o in objs if o.type == 'MESH'])
    p = KO.merkpunkte(haut, augen)
    kopf = QT.kopf_pos(arm)
    bpy.context.view_layer.update()
    hier = schaedel(haut, kopf.z)
    eigen = HAARE_M if g == 'M' else HAARE_W
    # Hautton: Gesicht zwischen Kinn und Augen, vorn
    haut_ref = bildfarbe([haut], lambda o, W: (W[:, 2] > p['kinn_z'] + 0.02) & (W[:, 2] < p['augen_z']) & (W[:, 1] < p['mitte'][1]))
    alle = []
    for n in HAARE + (BAERTE if g == 'M' else []):
        hp = RIGGED.get(n)
        if not hp: print('FEHLT', n); continue
        ho = QT.importiere(hp)
        a2 = next((o for o in ho if o.type == 'ARMATURE'), None)
        vs = (kopf - QT.kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
        neu = [o for o in ho if o.type == 'MESH']
        if n in HAARE and n not in eigen:
            if not anders: print('FEHLT Kopf zum Umlegen', n); continue
            bpy.context.view_layer.update()
            umlegen(neu, anders, hier); vs = Vector()
        QT.an_geruest(ho, arm, vs)
        for o in neu:
            o.name = n
            mw = o.matrix_world.copy(); o.parent = None; o.matrix_world = mw
            for m in list(o.modifiers): o.modifiers.remove(m)
            for vg in list(o.vertex_groups): o.vertex_groups.remove(vg)
            bpy.context.view_layer.objects.active = o
            bpy.ops.object.select_all(action='DESELECT'); o.select_set(True)
            bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        if n == 'Hair_Beard' and neu: neu += baerte_mehr(neu[0], haut, p)
        schluessel(neu, p)
        alle += neu
    haar_ref = bildfarbe([o for o in alle if o.name in HAARE])
    exportiere(os.path.join(ZIEL, 'haare.glb' if g == 'M' else 'haare_%s.glb' % g.lower()), alle)
    return {'kopf': godot(kopf), 'haut_bild': haut_ref, 'haar_bild': haar_ref, 'haare': [n for n in HAARE if any(o.name == n for o in alle)],
            'baerte': [n for n in BAERTE if any(o.name == n for o in alle)], 'dreiecke': {o.name: dreiecke([o]) for o in alle}}


# Bewegungen fuer held.gd (Namen wie held.bin): aus der UAL (gekauft Pro, sonst Standard), nur Geruest und diese Bewegungen. Die von
# rig.py (held.bin) passen nicht: sie sind auf unsere Ruhelage (Arme haengend) umgerechnet, der Kaufkoerper ruht in der T-Pose
BEWEGUNGEN = [('Stehen', 'Idle_Loop'), ('Gehen', 'Walk_Loop'), ('Rennen', 'Jog_Fwd_Loop'), ('Stehen_2', 'Idle_LookAround_Loop'),
              ('Stehen_3', 'Idle_Tired_Loop'), ('Sitzen', 'Sitting_Idle_Loop'), ('Gesten', 'Idle_Talking_Loop'),
              # 1044 zurueck (Chef 13.11., 09:35): Ruhebewegungen je Person (heldfigur.gd RUHE_JE), alle aus der UAL Pro
              ('Ruhe_Tresen', 'Counter_Idle_Loop'), ('Ruhe_Trinken', 'Drink'), ('Ruhe_Weinen', 'Crying'),
              ('Ruhe_Greifen', 'Interact')]


def schritt_tempo(arm, a, fuesse=('foot_l', 'foot_r'), toleranz=0.02):
    # 417 Runde 4 (Lauf 41305428768: SprintHold1hMelee 0 m/s, der Knoechel lag nie zwei Bilder in 2 cm): Paketbewegungen am Ballen, 3 cm
    # wie figurenprobe.gd schritt_tempo: der Standfuss gleitet auf der Stelle mit dem Tempo zurueck, mit dem der Koerper vorankaeme;
    # je Fuss die Rueckwaertsgeschwindigkeit in den Bildern hoechstens 2 cm ueber seinem Tiefstand, Median (Blick -Y)
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]
    f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
    fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base
    vs = []
    for fu in fuesse:
        d, h = [], []
        for fr in range(f0, f1 + 1):
            bpy.context.scene.frame_set(fr)
            p = arm.matrix_world @ arm.pose.bones[fu].head
            d.append(-p.y); h.append(p.z)
        tief = min(h)
        for j in range(len(d) - 1):
            if h[j] < tief + toleranz and h[j + 1] < tief + toleranz: vs.append((d[j] - d[j + 1]) * fps)
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
    # 417 Runde 4 (Chef 01.11., 12:21; 348.12c): Gehen und Rennen je Waffenart aus den Protofactor-Paketen (waffengang.py, GANG=<ordner>
    # mit Gehen_<art>.glb, Rennen_<art>.glb auf demselben UAL-Geruest), Name wie die Datei
    gang = sorted(glob.glob(os.path.join(os.environ.get('GANG', ''), '*_*.glb'))) if os.environ.get('GANG') else []
    for p in gang:
        n = os.path.basename(p)[:-4]
        vorher = set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=p)
        neu = [a for a in bpy.data.actions if a.name not in namen.values() and not a.use_fake_user]
        for o in [o for o in bpy.data.objects if o not in vorher]: bpy.data.objects.remove(o)
        if neu: neu[0].name = n; neu[0].use_fake_user = True
        for a in neu[1:]: bpy.data.actions.remove(a)
        print('GANG', n, 'aufgenommen' if neu else 'FEHLT')
    tempo = {n: schritt_tempo(arm, bpy.data.actions[n]) for n in ('Gehen', 'Rennen') if n in bpy.data.actions}
    for a in bpy.data.actions:
        if a.name.startswith(('Gehen_', 'Rennen_')): tempo[a.name] = schritt_tempo(arm, a, ('ball_l', 'ball_r'), 0.03)
    if arm.animation_data: arm.animation_data.action = None
    bpy.ops.object.select_all(action='DESELECT'); arm.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, 'bewegungen.glb'), export_format='GLB', use_selection=True, export_animations=True,
                              export_animation_mode='ACTIONS', export_skins=True, export_force_sampling=True)
    arten = sorted({n.split('_', 1)[1] for n in tempo if '_' in n})
    return {'gang': {k: {'gehen_m_je_s': tempo.get('Gehen_' + k, 0.0), 'rennen_m_je_s': tempo.get('Rennen_' + k, 0.0)} for k in arten},
            'gehen_m_je_s': tempo.get('Gehen', 0.0), 'rennen_m_je_s': tempo.get('Rennen', 0.0), 'becken_m': round(arm.data.bones['pelvis'].head_local.z, 4),
            'bewegungen': sorted(a.name for a in bpy.data.actions), 'ual': os.path.basename(pro) if pro else 'UAL1_Standard.glb', 'gekauft': bool(pro)}


# 475 (Chef 03.11., 07:45/07:47): die Leute des Dorfs auf dem Kaufkoerper, je Person ihre Kleidung aus held3 (leute.json) und ein
# eigenes Gesicht (Godot: heldfigur.gd person); LEUTE_KAUF=alle oder Kennungen mit Komma -> <ZIEL>/held_L_<id>_<M|W>.glb, leute-kauf.json
# (nur trachten; Haare und Bewegungen kommen aus dem Heldenlauf). Uebertragen werden ausser der Kleidung des Helden (kauf_kleid KLEID):
LEUTE_KLEID = ['apron', 'schal', 'latz', 'sun', 'sun_grund', 'sun_strahl', 'circlet', 'circlet_stein', 'tuch', 'tuch_zipfel',
               'tuch_knoten', 'helm', 'helmrim', 'nasal', 'hood', 'kapuze', 'gugel']
# Kopfbedeckung aus dem Bestand (LISTE-BESTAND, Modular Character Outfits): Kaufteil (Ende des Namens) statt unserer Teile
LEUTE_KOPF = {'helm': {'kauf': 'Knight_Head_Armet', 'statt': ['helm', 'helmrim', 'nasal']},
              'kapuze': {'kauf': 'Ranger_Head_Hood', 'statt': ['hood', 'kapuze', 'gugel']}}
LEUTE_KAUF = [s for s in os.environ.get('LEUTE_KAUF', '').split(',') if s]
if LEUTE_KAUF:
    L = json.load(open(os.path.join(HIER, 'leute.json')))
    ids = [i for i in L if i != '_liesmich'] if LEUTE_KAUF == ['alle'] else LEUTE_KAUF
    lk = {'trachten': {}}
    for i in ids:
        f = L[i]
        g = 'W' if f.get('sex') == 'w' else 'M'
        k = 'L_%s_%s' % (i, g)
        robe = f.get('rock') == 'robe'
        kt = [LEUTE_KOPF[f['kopf']]] if f.get('kopf') in LEUTE_KOPF else []
        try:
            arm, netze = kaempfer(k, g, i, GESCHLECHTER[g]['fuesse'], 0.18 if robe else 0.0, 'leute.json', kt)
        except SystemExit as e:
            print('LEUTE FEHLER', i, e); continue
        lk['trachten'][k] = {'kleid': 'leute:' + i, 'geschlecht': g, 'kopf': godot(QT.kopf_pos(arm)), 'dreiecke': dreiecke(netze),
                             'netze': sorted(o.name for o in netze)}
        print('LEUTE', k, lk['trachten'][k]['dreiecke'], 'Dreiecke')
    json.dump(lk, open(os.path.join(ZIEL, 'leute-kauf.json'), 'w'), indent=1, ensure_ascii=False)
    print('LEUTE KAUF OK', sorted(lk['trachten']))
    raise SystemExit(0)

info = {'formen': FORMEN, 'statur': list(STATUR), 'haut': {k: list(v) for k, v in KO.HAUT.items()},
        'haarfarben': {k: list(v) for k, v in QT.HAAR.items()}, 'herkuenfte': HERKUENFTE, 'klasse_herkunft': KLASSE_HERKUNFT,
        'trachten': {}, 'geschlechter': {}}
for t, f in TRACHTEN.items():
    if NUR and t not in NUR: continue
    for g in GESCHLECHTER:
        if NUR_G and g not in NUR_G: continue
        k = '%s_%s' % (t, g)
        fu = GESCHLECHTER[g]['fuesse'] if f.get('fuesse') else ''
        arm, netze = tracht(k, g, f) if 'kleid' in f else kaempfer(k, g, '' if f['tracht'] == 'unsere' else f['tracht'], fu, f.get('stiefel_bis', 0.0))
        info['trachten'][k] = {'kleid': (f.get('kleid') or f['tracht']).format(v=GESCHLECHTER[g]['v']), 'geschlecht': g,
                               'kopf': godot(QT.kopf_pos(arm)), 'dreiecke': dreiecke(netze), 'netze': sorted(o.name for o in netze)}
        print('TRACHT', k, info['trachten'][k]['dreiecke'], 'Dreiecke', info['trachten'][k]['kleid'])
for g in GESCHLECHTER:
    if NUR_G and g not in NUR_G: continue
    info['geschlechter'][g] = haare(g)
info.update(info['geschlechter'].get('M', {}))   # Mann wie bisher oben (haare.glb)
info.update(bewegungen())
json.dump(info, open(os.path.join(ZIEL, 'held-klassen.json'), 'w'), indent=1, ensure_ascii=False)
print('HELD TRACHTEN OK', list(info['trachten']), {g: len(v['haare']) for g, v in info['geschlechter'].items()}, 'Haare')
