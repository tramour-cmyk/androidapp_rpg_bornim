# 387 (Jerry; Chef 27.10., 21:27, über Sokrates): gekaufte Tiere schnell prüfen, ob die Bewegungen taugen und unsere Haut draufpasst,
# bevor wieder selbst gebaut wird. Schnellbau wie kaufwolf.py, ohne Feinarbeit: Netz und Bewegungen aus dem Kauf (privates Repo, $KAUF,
# nie hierher), eigene Bemalung (Zeichnung = Helligkeit der Kauftextur, Farben aus unseren Fellen oder, wo wir keine haben, die Farbe
# des Kaufs entsättigt und dunkler), unsere Fellstriche; im Spiel trägt figur.gd Shader und Tusche (Probe ERSATZ=kauf_<tier>).
# Größe wie im Kauf (Janpec in Metern), Bewegungen auf der Stelle (kein Wurzelweg), Augen nicht eigens bemalt.
# Aufruf: TIER=keiler KAUF=<ordner> OUT=<ordner> python -I kauftier.py  ->  <OUT>/kauf_<tier>-<fell>.glb, kauf_<tier>-info.json
# Runde 2 (Chef 27.10., 22:31, Archiv: alle außer Schwein und Gans, mit Nacharbeit; 22:34 „Alles in eins packen“, mit Bewegung über
# den Platz): Boden und Mitte aus dem Stehen (vorher Ruhe mit allen NLA-Spuren: die oberste, der Tod des Keilers, setzte das Maß,
# Keiler 0,44 m hoch und 0,3 m seitlich); Tod des Keilers liegt in der Quelle rückwärts (vom Liegen zum Stehen, gemessen), wird
# gespiegelt (RUECKWAERTS); Hundertfüßer 1,5 m lang (LISTE-FIGUREN 1,4–1,6 m; Kauf 1,24 m), blauschwarz heller; Huhn und
# Kaninchen unsere Felle, gesättigte Stellen (Kamm, Schnabel, Beine) behalten die Farbe des Kaufs (BEHALTEN); Wurzelweg „weg“ für
# Gehen und Rennen im Tempo der Pfoten am Boden und „biss“ wie kaufwolf.py; Pfoten der Vierbeiner heißen wie beim Wolf (vpfoteL …,
# figur.gd Pfotenschatten und Pfotenhalt).
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
from mathutils import Vector, Matrix
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, fellstriche, TEX

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
FPS = 30
# Fell: (Fell, Sattel, Bauch) als Farben; None = Farbe des Kaufs, entsättigt (ENTSAETTIGT) und dunkler (DUNKLER)
ENTSAETTIGT, DUNKLER = 0.35, 0.8
# Bewegungen: unser Name <- Endung der Kaufdatei
TIERE = {
    'keiler': {'rig': 'WildBoar_Rig.fbx', 'anim': 'WildBoar_%s.fbx', 'tex': 'wild_boar_col*',
               'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Hauer': 'Attack', 'Fressen': 'Eat', 'Tod': 'Die'},
               # wildschwein.py COATS (fur, saddle, belly)
               'felle': {'dunkel': (0x3A302A, 0x141010, 0x2E2622), 'grau': (0x5E5248, 0x221C18, 0x4A3E36), 'rost': (0x5A3A26, 0x1E1410, 0x463024)}},
    'hundertfuesser': {'rig': 'skin.FBX', 'anim': '%s.FBX', 'tex': 'centipede*',
               'namen': {'Stehen': 'idle', 'Gehen': 'walk', 'Biss': 'attack', 'Treffer': 'hit', 'Drohen': 'alert', 'Tod': 'die'},
               # LISTE-FIGUREN.md Riesen-Hundertfüßer: rostrot (gelbe Beine), blauschwarz (rote Beine), ocker und schwarz
               # Runde 2 (Prüfer: blauschwarz fast schwarz, Zeichnung unsichtbar): heller
               'felle': {'rost': (0x6A2A1A, 0x2A100C, 0x8A6A2A), 'blauschwarz': (0x3A4258, 0x161A26, 0x8A2E20), 'ocker': (0x7A5A2A, 0x161210, 0x8A7040)},
               'laenge': 1.5,
               # Prüfer: Gehen kaum vom Stehen zu unterscheiden (die Beine schieben 0,05–0,07 m/s): Gehen schneller abgespielt bis zu diesem
               # Tempo, Rennen = Gehen doppelt so schnell (der Kauf hat kein Rennen)
               # Runde 5 (Chef 28.10., 08:09: „vor allem Centipede muss schneller bewegen, da lässt sich ja keiner angreifen bei dem Speed“):
               # Gehen 0,8 statt 0,35 m/s, Rennen 2,5-fach (2,0 statt 0,7 m/s); die Beine bleiben bei höchstens 3,5-fach (tempo_max)
               'tempo_ziel': {'Gehen': 0.8}, 'rennen_aus_gehen': 2.5,
               # Runde 4 (Prüfer r3: wackelt beim Platzwechsel auf der Stelle; gemessen: Gehen lief 7,1-fach, Rennen 14,3-fach, eine Schleife
               # in 4 bzw. 2 Bildern, das Bild springt zwischen Beinstellungen): Bewegung höchstens 3,5-fach (8,6 Bilder je Schleife), den
               # Rest des Tempos trägt der Wurzelweg (die Beine gleiten; bei 30 kurzen Beinen kaum zu sehen)
               'tempo_max': 3.5},
    'rind': {'rig': 'Cattle_Rig.fbx', 'anim': 'Cattle_%s.fbx', 'tex': 'iron_age_cattle_col_unity*',
             'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Stoss': 'Attack', 'Fressen': 'Eat', 'Tod': 'Die'}, 'felle': {'natur': None}},
    'ziege': {'rig': 'Goat_Rig.fbx', 'anim': 'Goat_%s.fbx', 'tex': 'goat_col*',
              'namen': {'Stehen': 'Idle', 'Stehen2': 'Idle02', 'Gehen': 'Walk', 'Rennen': 'Run', 'Stoss': 'Attack', 'Fressen': 'Eat', 'Tod': 'Die'}, 'felle': {'natur': None}},
    'huhn': {'rig': 'Chicken_Rig.fbx', 'anim': 'Chicken_%s.fbx', 'tex': 'chicken_col14*',
             'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Fressen': 'Eat', 'Tod': 'Die'},
             # Runde 2 (Prüfer: reinweiß, Kamm, Schnabel, Auge unsichtbar): braun, hell, schwarz; Kamm und Schnabel aus dem Kauf
             # Runde 5 (Chef 28.10., 08:09: „Hühner etwas größer“, Vorschlag kräftiger braun mit sichtbarem Kamm): 1,2-fach (0,59 -> 0,71 m),
             # braun satter; Kamm, Kehllappen, Schnabel in der Farbe des Kaufs ohne Abdunkeln und kräftiger (kamm)
             'felle': {'braun': (0x8C4A1C, 0x46200A, 0xB4703A), 'hell': (0xC8BCA0, 0x8C806A, 0xDAD2BE), 'schwarz': (0x34322C, 0x181814, 0x4E4A40)},
             'behalten': 0.35, 'groesser': 1.2, 'kamm': 1.35},
    'schwein': {'rig': 'iron_age_pig_rig_exp.FBX', 'anim': 'iron_age_pig_%s_anim.FBX', 'tex': 'iron_age_pig_col_unity*',
                'namen': {'Stehen': 'idle', 'Gehen': 'walk', 'Fressen': 'eat', 'Tod': 'die'}, 'felle': {'natur': None}},
    'gans': {'rig': 'swan_goose_rig_exp.FBX', 'anim': 'swan_goose_%s_anim.FBX', 'tex': 'swan_goose_col*',
             'namen': {'Stehen': 'idle', 'Gehen': 'walk', 'Rennen': 'run', 'Fressen': 'eat', 'Tod': 'die'}, 'felle': {'natur': None}},
    'kaninchen': {'rig': 'WildRabbit_Rig.fbx', 'anim': 'WildRabbit_%s.fbx', 'tex': 'wild_rabbit_col5*',
                  'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Fressen': 'Eat', 'Tod': 'Die'},
                  # Runde 2 (Prüfer: fast schwarz, ohne Zeichnung): Wildkaninchen graubraun, braun, grau mit hellem Bauch
                  'felle': {'graubraun': (0x6E5C46, 0x3A3024, 0xB4A68E), 'braun': (0x7A5A3A, 0x40301E, 0xB09A7A), 'grau': (0x6A6660, 0x34322E, 0xA8A49A)},
                  'behalten': 0.45,
                  # Runde 4 (Prüfer r3: sitzt beim Laufen aufrecht, auch im Anlauf; gemessen in der Quelle: im Rennen hebt sich der Kopf von
                  # 0,19 auf 0,35 m, das Hinterteil sinkt 0,09 m in den Boden): Rennen = Gehen (Hoppeln, Kopf 0,19–0,31 m, über dem Boden) 1,3-fach
                  # Runde 5 (Chef 28.10., 08:09, Vorschlag „eigene Hoppelbewegung“; r4: von hinten aufrecht und gleitend): Rennen aus dem
                  # Rennen des Kaufs (Hinterläufe stoßen gemeinsam ab), Neigung auf ein Drittel gedämpft (Kauf bis 39° Kopf hoch, Hinterteil
                  # 0,11 m im Boden), im Boden gehalten und im Sprung gehoben (Wurzel im Hoch des Kaufs bis 0,07 m höher: in der Luft)
                  'hoppeln': {'neigung': 0.33, 'hub': 0.07},
                  # gemessen 0,58 m/s, langsamer als das Gehen (0,59): schneller abgespielt bis 0,9 m/s (rund vier Sprünge je Sekunde)
                  'tempo_ziel': {'Rennen': 0.9},
                  # Runde 4 (Prüfer r3: kippt im Tod kopfüber und schwebt; gemessen in der Quelle: der Rücken neigt sich 34° nach vorn, der Kopf
                  # liegt 0,26 m unter dem Boden, Boden halten hob alles um 0,32 m): Rücken waagerecht, erst dann den Boden halten
                  'waagerecht': {'Tod': ('ROOTSHJnt', 'Spine_TopSHJnt')}},
}
# Runde 2: Bewegungen, die in der Quelle rückwärts liegen (gemessen: Tod des Keilers beginnt liegend, 0,44 m unter dem Boden, und
# endet stehend)
RUECKWAERTS = {'keiler': ['Tod']}
# Vierbeiner von Janpec: Pfoten wie beim Wolf (kaufwolf.py), für Pfotenschatten und Pfotenhalt in figur.gd
PFOTEN = {'l_FrontLeg_BallSHJnt': 'vpfoteL', 'r_FrontLeg_BallSHJnt': 'vpfoteR', 'l_HindLeg_BallSHJnt': 'hpfoteL', 'r_HindLeg_BallSHJnt': 'hpfoteR'}
TIER = os.environ.get('TIER', 'keiler')
T = TIERE[TIER]
ID = 'kauf_' + TIER


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    t = sorted(glob.glob(os.path.join(KAUF, '**', T['rig']), recursive=True))
    if not t:
        sys.exit('%s nicht gefunden unter %s' % (T['rig'], KAUF))
    d = os.path.dirname(os.path.dirname(t[0]))
    tex = sorted(glob.glob(os.path.join(d, '**', T['tex'] + '.tga'), recursive=True) + glob.glob(os.path.join(d, '**', T['tex'] + '.png'), recursive=True))
    return t[0], d, tex[0] if tex else None


def importiere(fbx):
    vorher = {o.name for o in bpy.data.objects}
    bpy.ops.import_scene.fbx(filepath=fbx, use_anim=True, ignore_leaf_bones=True, automatic_bone_orientation=False)
    return [o for o in bpy.data.objects if o.name not in vorher]


def uv_belegt(meshes):
    from PIL import Image, ImageDraw
    bel = Image.new('L', (TEX, TEX), 0); db = ImageDraw.Draw(bel)
    for o in meshes:
        uv = o.data.uv_layers.active.data
        for p in o.data.polygons:
            db.polygon([(uv[i].uv[0] * TEX, (1 - uv[i].uv[1]) * TEX) for i in p.loop_indices], fill=255)
    return np.asarray(bel) > 127


def bemalung(src, fell, farben, bel, striche, behalten=None):
    from PIL import Image, ImageFilter
    s = np.asarray(Image.open(src).convert('RGB').resize((TEX, TEX), Image.LANCZOS)).astype(np.float32) / 255.0
    L = 0.2126 * s[..., 0] + 0.7152 * s[..., 1] + 0.0722 * s[..., 2]
    p5, p95 = np.percentile(L[bel], [5, 95])
    if farben is None:     # Farbe des Kaufs: linear, entsättigt, dunkler
        ln = np.where(s <= 0.04045, s / 12.92, ((s + 0.055) / 1.055) ** 2.4)
        g = (0.2126 * ln[..., 0] + 0.7152 * ln[..., 1] + 0.0722 * ln[..., 2])[..., None]
        farbe = (ln * (1 - ENTSAETTIGT) + g * ENTSAETTIGT) * DUNKLER
    else:
        Lb = np.asarray(Image.fromarray((L * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(TEX / 64))).astype(np.float32) / 255.0
        fein = np.clip(L / np.maximum(Lb, 1e-3), 0.6, 1.5)
        t = np.clip((Lb - p5) / max(p95 - p5, 1e-3), 0, 1)[..., None]
        fu, sa, be = (lin(h) for h in farben)
        farbe = np.where(t < 0.5, sa + (fu - sa) * (t / 0.5), fu + (be - fu) * ((t - 0.5) / 0.5)) * fein[..., None] ** 1.3
    farbe = farbe * np.clip(striche, 0.3, 1.8)[..., None] ** 0.9
    if behalten is not None and farben is not None:     # Kamm, Schnabel, Beine: gesättigte Stellen des Kaufs bleiben (dunkler)
        mx, mn = s.max(-1), s.min(-1)
        sat = (mx - mn) / np.maximum(mx, 1e-3)
        m = (sat > behalten) & (mx > 0.2)
        ln = np.where(s <= 0.04045, s / 12.92, ((s + 0.055) / 1.055) ** 2.4)
        alt = ln * DUNKLER
        if T.get('kamm'):     # Runde 5: Rotes (Kamm, Kehllappen) nicht abgedunkelt, Sättigung kamm-fach
            rot = (s[..., 0] > 0.45) & (s[..., 0] > 1.6 * s[..., 1]) & (s[..., 0] > 1.6 * s[..., 2])
            g = (0.2126 * ln[..., 0] + 0.7152 * ln[..., 1] + 0.0722 * ln[..., 2])[..., None]
            satt = np.clip(g + (ln - g) * T['kamm'], 0.0, 1.0)
            alt = np.where(rot[..., None], satt, alt)
            print('KAMM %s %s: %.1f %% der Fläche rot, kräftiger' % (TIER, fell, 100.0 * float((rot & bel).sum()) / max(int(bel.sum()), 1)))
        farbe = np.where(m[..., None], alt, farbe)
        print('BEHALTEN %s %s: %.1f %% der Fläche in der Farbe des Kaufs' % (TIER, fell, 100.0 * float((m & bel).sum()) / max(int(bel.sum()), 1)))
    farbe = np.where(bel[..., None], farbe, np.median(farbe[bel], axis=0))
    print('BEMALUNG %s %s: Quelle Helligkeit p5 %.3f p95 %.3f, neu Mittel %.3f' % (TIER, fell, p5, p95, float(farbe[bel].mean())))
    p = os.path.join(OUT, '%s-bemalung-%s.png' % (ID, fell))
    Image.fromarray((srgb(farbe) * 255).astype(np.uint8)).save(p)
    return p


def setze(rig, a):
    rig.animation_data.action = a
    if slot(a) is not None: rig.animation_data.action_slot = slot(a)


def kurven(a):
    try:
        return list(a.fcurves)
    except AttributeError:     # Blender 5: Kurven in Ebenen, Streifen, Kanalbündeln
        return [fc for l in a.layers for st in l.strips for cb in st.channelbags for fc in cb.fcurves]


def spiegeln(a):
    """Bewegung zeitlich umkehren (Bild f -> f0 + f1 - f), Griffe mit"""
    f0, f1 = a.frame_range
    for fc in kurven(a):
        for kp in fc.keyframe_points:
            l, r = kp.handle_left.copy(), kp.handle_right.copy()
            kp.co.x = f0 + f1 - kp.co.x
            kp.handle_left = (f0 + f1 - r.x, r.y); kp.handle_right = (f0 + f1 - l.x, l.y)
        fc.update()


def am_boden(rig, a, meshes, beine):
    """Tempo (m/s, Welt) gegen Fußgleiten wie kaufwolf.tempo(): je Bein (Knochen, der in der Schleife den Boden berührt) die Strecke,
    die er am Boden (höchstens 6 cm über seinem tiefsten Stand) nach hinten (+Y, Blick −Y) läuft, durch die Zeit dafür"""
    setze(rig, a); W = rig.matrix_world
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    Y, Z = {b: [] for b in beine}, {b: [] for b in beine}
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f)
        for b in beine:
            p = W @ rig.pose.bones[b].head; Y[b].append(p.y); Z[b].append(p.z)
    v = []
    for b in beine:
        y, z = np.array(Y[b]), np.array(Z[b])
        if z.min() > 0.06:
            continue
        # am Boden: höchstens 6 cm über dem tiefsten Stand (Rennen: die Pfote rollt ab, mit 3 cm fand sich bei Rind und Ziege kein Bild)
        d = np.diff(y); unten = (z[1:] < z.min() + 0.06) & (z[:-1] < z.min() + 0.06) & (d > 0)
        if unten.sum() >= 2:
            v.append(d[unten].mean() * FPS)
    v = np.array(v) if v else np.array([0.0])
    # Median: einzelne Knochen am Boden ohne Schritt (Keiler Gehen 0,07 neben 0,68–0,86 m/s) ziehen das Mittel herunter
    print('TEMPO %s %s: %d Beine am Boden, m/s %s, Median %.3f' % (TIER, a.name, len(v), ' '.join('%.2f' % x for x in v), float(np.median(v))))
    return float(np.median(v))


def boden_halten(rig, a, meshes):
    """Runde 2 (Keiler: liegend steckt er 0,44 m im Boden): je Bild den Hauptknochen so weit heben, dass das Netz nicht unter den Boden
    reicht (Schlüssel je Bild auf seinem Ort)"""
    setze(rig, a)
    wurzel = next(b for b in rig.data.bones if b.parent is None)
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    hub = {f: max(0.0, -float(welt_netz(meshes, f)[:, 2].min())) for f in range(a0, a1 + 1)}
    if max(hub.values()) < 0.01:
        return
    inv = (rig.matrix_world.to_3x3() @ wurzel.matrix_local.to_3x3()).inverted()
    pfad = 'pose.bones["%s"].location' % wurzel.name
    fcs = {fc.array_index: fc for fc in kurven(a) if fc.data_path == pfad}
    if len(fcs) < 3:
        print('BODEN HALTEN: keine Ortskurven am Hauptknochen', wurzel.name); return
    neu = {f: [fcs[i].evaluate(f) + (inv @ Vector((0.0, 0.0, h)))[i] for i in range(3)] for f, h in hub.items()}
    for f, w in neu.items():
        for i in range(3):
            fcs[i].keyframe_points.insert(f, w[i], options={'FAST'})
    for fc in fcs.values():
        fc.update()
    print('BODEN HALTEN %s: bis %.2f m gehoben (Bild %d)' % (a.name, max(hub.values()), max(hub, key=hub.get)))


def waagerecht(rig, a, kw, kv, rest=0.0):
    """Runde 4 (Kaninchen im Tod kopfüber): je Bild den Knochen kw so drehen, dass die Strecke kw -> kv so steil steht wie im ersten Bild
    (Richtung zur Seite bleibt, nur die Neigung nach vorn oder hinten geht weg); Schlüssel je Bild auf Ort und Drehung von kw"""
    setze(rig, a)
    pw = next(b for b in rig.pose.bones if b.name.endswith(kw))
    pv = next(b for b in rig.pose.bones if b.name.endswith(kv))
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    W3 = rig.matrix_world.to_3x3()
    bpy.context.scene.frame_set(a0)
    v0 = W3 @ (pv.head - pw.head)
    st0 = v0.z / v0.length
    neu, wink = {}, []
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f)
        v = W3 @ (pv.head - pw.head)
        fl = Vector((v.x, v.y, 0.0))
        if fl.length < 1e-6:
            continue
        st = st0 + (v.z / v.length - st0) * rest     # Runde 5: rest = Anteil der Neigung, der bleibt (Hoppeln)
        soll = (fl.normalized() * math.sqrt(max(0.0, 1.0 - st * st)) + Vector((0.0, 0.0, st))) * v.length
        q = (W3.inverted() @ v).rotation_difference(W3.inverted() @ soll)     # im Raum des Gerüsts
        h = pw.head.copy()
        M = Matrix.Translation(h) @ q.to_matrix().to_4x4() @ Matrix.Translation(-h) @ pw.matrix
        pw.matrix = M
        bpy.context.view_layer.update()
        neu[f] = pw.matrix_basis.copy()
        wink.append(math.degrees(v.angle(soll)))
    for f, mb in neu.items():
        pw.matrix_basis = mb
        pw.keyframe_insert('location', frame=f)
        pw.keyframe_insert('rotation_quaternion' if pw.rotation_mode == 'QUATERNION' else 'rotation_euler', frame=f)
    print('WAAGERECHT %s %s: Neigung bis %.0f° weggenommen (Bild %d)' % (TIER, a.name, max(wink), a0 + int(np.argmax(wink))))


def hub(rig, a, h):
    """Runde 5 (Hoppeln): die Wurzel im oberen Teil ihres Wegs um bis zu h (m, Welt) heben, so liegt das Tier im Hoch des Sprungs in der
    Luft; Schlüssel je Bild auf den Ortskurven des Hauptknochens"""
    setze(rig, a)
    wurzel = next(b for b in rig.data.bones if b.parent is None)
    pw = rig.pose.bones[wurzel.name]
    kw = next(b for b in rig.pose.bones if b.name.endswith('ROOTSHJnt'))
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    z = {}
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f); z[f] = (rig.matrix_world @ kw.head).z
    lo, hi = min(z.values()), max(z.values())
    inv = (rig.matrix_world.to_3x3() @ wurzel.matrix_local.to_3x3()).inverted()
    pfad = 'pose.bones["%s"].location' % wurzel.name
    fcs = {fc.array_index: fc for fc in kurven(a) if fc.data_path == pfad}
    if len(fcs) < 3 or hi - lo < 1e-3:
        print('HUB: keine Ortskurven oder kein Weg', wurzel.name); return
    neu = {}
    for f in range(a0, a1 + 1):
        u = ((z[f] - lo) / (hi - lo)) ** 1.5
        neu[f] = [fcs[i].evaluate(f) + (inv @ Vector((0.0, 0.0, h * u)))[i] for i in range(3)]
    for f, w in neu.items():
        for i in range(3):
            fcs[i].keyframe_points.insert(f, w[i], options={'FAST'})
    for fc in fcs.values():
        fc.update()
    print('HUB %s %s: Wurzel %.2f-%.2f m, im Hoch bis %.2f m gehoben' % (TIER, a.name, lo, hi, h))


def baue(fell):
    fbx, d, tex = quelle()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene; scn.render.fps = FPS
    obs = importiere(fbx)
    rig = next(o for o in obs if o.type == 'ARMATURE')
    meshes = [o for o in obs if o.type == 'MESH']
    for o in [o for o in obs if o.type not in ('ARMATURE', 'MESH')]:
        bpy.data.objects.remove(o, do_unlink=True)
    if rig.animation_data: rig.animation_data.action = None
    print('IMPORT', TIER, os.path.basename(fbx), 'Netze', len(meshes), 'Dreiecke', tris(meshes), 'Knochen', len(rig.data.bones), 'Textur', tex and os.path.basename(tex))
    akt = {}
    for nm, q in T['namen'].items():
        f = sorted(glob.glob(os.path.join(d, '**', T['anim'] % q), recursive=True))
        if not f:
            print('FEHLT', nm, q); continue
        n = importiere(f[0]); a = aktion_von(n)
        entferne(n)
        if a is None:
            print('KEINE BEWEGUNG', nm, os.path.basename(f[0])); continue
        a.use_fake_user = True; a.name = 'q_' + nm; akt[nm] = a
        print('BEWEGUNG', nm, '<-', os.path.basename(f[0]), 'Bilder', tuple(round(x, 1) for x in a.frame_range))
    for nm in RUECKWAERTS.get(TIER, []):
        if nm in akt:
            spiegeln(akt[nm]); print('RUECKWAERTS', nm, 'gespiegelt')
    rig.animation_data_create()
    if 'Stehen' in akt:
        setze(rig, akt['Stehen'])
    f0 = int(akt['Stehen'].frame_range[0]) if 'Stehen' in akt else 1
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    # Bemalung
    bel = uv_belegt(meshes)
    farben = T['felle'][fell]
    INFO = {'fps': FPS, 'fell': fell, 'dreiecke': tris(meshes), 'knochen': len(rig.data.bones), 'quelle': 'gekauft (387): %s' % os.path.basename(fbx)}
    bild = bpy.data.images.load(bemalung(tex, fell, farben, bel, fellstriche(meshes, np.random.default_rng(23), np.zeros((TEX, TEX), bool)), T.get('behalten')))
    mat = bpy.data.materials.new('%s-%s' % (ID, fell)); mat.use_nodes = True
    bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
    im = mat.node_tree.nodes.new('ShaderNodeTexImage'); im.image = bild
    mat.node_tree.links.new(im.outputs['Color'], bs.inputs['Base Color'])
    for o in meshes:
        o.data.materials.clear(); o.data.materials.append(mat)
    # Blick: Kopf zur langen Achse; Janpec und MadeCG schauen nach −Y oder +Y (Blender), gewünscht −Y (glTF +Z). Runde 2: Maß, Boden
    # und Mitte im Stehen, vor den NLA-Spuren (sonst zählt die oberste Spur)
    kb = [b for b in rig.pose.bones if 'head' in b.name.lower()]
    lang = 0 if (hi - lo)[0] > (hi - lo)[1] else 1
    vor = np.sign((rig.matrix_world @ kb[0].head)[lang] - (lo + hi)[lang] / 2) if kb else -1.0
    blick = [0.0, 0.0]; blick[lang] = vor
    dreh = math.atan2(blick[0], -blick[1])     # Drehung um Z, die blick auf (0, −1) bringt
    aussen = bpy.data.objects.new('Kauftier', None); scn.collection.objects.link(aussen)
    rig.parent = aussen
    aussen.rotation_euler = (0, 0, dreh)
    bpy.context.view_layer.update()
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    k = (T['laenge'] / float(hi[1] - lo[1]) if 'laenge' in T else 1.0) * T.get('groesser', 1.0)
    aussen.scale = (k, k, k)
    aussen.location = (-(lo[0] + hi[0]) / 2 * k, -(lo[1] + hi[1]) / 2 * k, -lo[2] * k)
    bpy.context.view_layer.update()
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    INFO['hoehe_m'] = round(float(hi[2] - lo[2]), 3); INFO['laenge_m'] = round(float(hi[1] - lo[1]), 3); INFO['breite_m'] = round(float(hi[0] - lo[0]), 3)
    print('MASS %s: breit %.2f lang %.2f hoch %.2f m, Boden %.3f, Maßstab %.2f, Drehung %.0f°, Kopfknochen %s' % (TIER, hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2], k, math.degrees(dreh), kb[0].name if kb else '-'))
    for nm, (kw, kv) in T.get('waagerecht', {}).items():
        if nm in akt:
            waagerecht(rig, akt[nm], kw, kv)
    if 'Tod' in akt:
        boden_halten(rig, akt['Tod'], meshes)
    if 'hoppeln' in T and 'Rennen' in akt:     # Runde 5: eigenes Hoppeln aus dem Rennen des Kaufs
        hp = T['hoppeln']; kw, kv = T['waagerecht']['Tod']
        waagerecht(rig, akt['Rennen'], kw, kv, hp['neigung'])
        boden_halten(rig, akt['Rennen'], meshes)
        hub(rig, akt['Rennen'], hp['hub'])
        setze(rig, akt['Rennen']); a0, a1 = (int(x) for x in akt['Rennen'].frame_range)
        pk = next(b for b in rig.pose.bones if b.name.endswith(kv)); pr = next(b for b in rig.pose.bones if b.name.endswith(kw))
        zeile = []
        for f in range(a0, a1 + 1):
            bpy.context.scene.frame_set(f); v = rig.matrix_world.to_3x3() @ (pk.head - pr.head)
            zeile.append('%d %.0f° %.3f' % (f, math.degrees(math.atan2(v.z, Vector((v.x, v.y)).length)), welt_netz(meshes, f)[:, 2].min()))
        print('HOPPELN %s: Bild Neigung Boden | %s' % (TIER, ' | '.join(zeile)))
    for nm in ('Tod', 'Gehen', 'Rennen'):     # Prüfwert: Boden je Bewegung (Tod: Anfang und Ende)
        if nm in akt:
            setze(rig, akt[nm]); a0, a1 = (int(x) for x in akt[nm].frame_range)
            print('BODEN %s %s: Bild %d %.3f m, Bild %d %.3f m' % (TIER, nm, a0, welt_netz(meshes, a0)[:, 2].min(), a1, welt_netz(meshes, a1)[:, 2].min()))
    # Wurzelweg (Modellmeter, +Z vorn): gerade im Tempo der Pfoten; Beine = Knochen, die in Gehen den Boden berühren
    beine = [b.name for b in rig.pose.bones if b.parent is not None and not b.children and 'tail' not in b.name.lower()]
    roh = {}       # Runde 4: Tempo vor der Grenze tempo_max
    tempo = {}     # figur.gd spielt diese Bewegungen so viel schneller (der Weg ist für Tempo 1)
    if 'rennen_aus_gehen' in T and 'Gehen' in akt:     # Runde 4: auch, wenn der Kauf ein Rennen hat (Kaninchen)
        akt['Rennen'] = akt['Gehen']
    for nm in ('Gehen', 'Rennen'):
        if nm in akt:
            v = am_boden(rig, akt[nm], meshes, beine)
            if nm in T.get('tempo_ziel', {}) and v > 0.0:
                tempo[nm] = round(max(1.0, T['tempo_ziel'][nm] / v), 2)
            if nm == 'Rennen' and akt['Rennen'] is akt.get('Gehen'):
                tempo[nm] = round(roh.get('Gehen', 1.0) * T['rennen_aus_gehen'], 2)
            roh[nm] = tempo.get(nm, 1.0)
            # Runde 4: Wurzelweg je Tempo 1 so, dass Weg mal Tempo das gewünschte Tempo gibt, das Tempo der Bewegung höchstens tempo_max
            soll = v * tempo.get(nm, 1.0)
            if nm in tempo and 'tempo_max' in T and tempo[nm] > T['tempo_max']:
                tempo[nm] = T['tempo_max']; v = soll / tempo[nm]
                print('TEMPO %s %s: Bewegung %.1f-fach, Wurzelweg %.3f m/s (Welt %.2f m/s)' % (TIER, nm, tempo[nm], v, soll))
            if v > 0.03:
                INFO.setdefault('weg', {})[nm] = [[0.0, round(v * i / FPS, 4)] for i in range(int(round(akt[nm].frame_range[1] - akt[nm].frame_range[0])) + 1)]
    if tempo:
        INFO['tempo'] = tempo; print('TEMPO %s abgespielt mal %s' % (TIER, tempo))
    # Biss (Kampftiere): Netz am weitesten vorn in der Angriffsbewegung; figur.gd BITE: Abstand Ursprung–Rand des Ziels (Schnauze
    # 0,07 m im Rand), Zeitpunkt (s), Drehung des Körpers (Grad, + links), damit die Schnauze aufs Ziel zeigt
    for nm in ('Hauer', 'Biss'):
        if nm in akt:
            setze(rig, akt[nm]); a0, a1 = (int(x) for x in akt[nm].frame_range)
            # Zeitpunkt: der größte Satz nach vorn (Hundertfüßer: bäumt sich auf, Vorderende bis 0,13 m hinter den Ursprung, schlägt dann in
            # einem Bild 0,36 m vor); ohne solchen Satz der Kopf am weitesten aus der Ruhe (Keiler: Hauer schlägt hoch, vorn ist er im ersten Bild)
            vorn, aus, k0 = [], [], None
            for f in range(a0, a1 + 1):
                P = welt_netz(meshes, f); i = int(P[:, 1].argmin()); vorn.append((f, P[i, 1], P[i, 0]))
                kk = np.array((rig.matrix_world @ kb[0].head)[:]) if kb else np.zeros(3)
                k0 = kk if k0 is None else k0
                aus.append(float(np.linalg.norm(kk - k0)))
            satz = np.diff([v[1] for v in vorn])
            j = int(satz.argmin()) + 1 if satz.min() < -0.05 else int(np.argmax(aus))
            best = vorn[j]
            INFO['biss'] = [round(float(-best[1] - 0.07), 3), round((best[0] - a0) / FPS, 3), round(-math.degrees(math.atan2(best[2], -best[1])), 1)]
            print('BISS %s %s: vorn %.2f m bei %.2f s, seitlich %.2f m -> %s' % (TIER, nm, -best[1], (best[0] - a0) / FPS, best[2], INFO['biss']))
            break
    rig.animation_data.action = None
    for nm, a in akt.items():
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'): st.action_slot = slot(a2)
        INFO[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
    for b in list(rig.data.bones):
        for alt, neu in PFOTEN.items():
            if b.name.endswith('_' + alt):
                b.name = neu
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, rig] + meshes: o.select_set(True)
    path = os.path.join(OUT, '%s-%s.glb' % (ID, fell))
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False, export_image_format='JPEG', export_jpeg_quality=88)
    # Prüfer r2: Rind überschlägt sich im Tod kopfüber, Ziege auf dem Rücken, Keiler dreht in einem Bild um 90°; im GLB lagen Drehschlüssel mit
    # wechselndem Vorzeichen (Keiler in jeder Bewegung 2–3 Knochen), Godot blendet sie über den langen Weg (wie 348.12 Grak)
    from glbquat import quat_stetig
    quat_stetig(path)
    print('GLB', path, os.path.getsize(path), {k: v for k, v in INFO.items() if k != 'weg'}, 'Weg', {k: len(v) for k, v in INFO.get('weg', {}).items()})
    return INFO


if __name__ == '__main__':
    info = {f: baue(f) for f in T['felle']}
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1)
    print('KAUFTIER %s FERTIG %.1f s' % (TIER, time.time() - T0))
