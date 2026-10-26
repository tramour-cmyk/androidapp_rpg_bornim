# 348.12f (Jerry): Probe gekaufte Riesenratte (Protofactor, Archiv 348.12c b): FBX aus dem privaten Repo ($KAUF, nie hierher
# und nie als Artefakt), unter 6.000 Dreiecke ausgedünnt, eigene Bemalung (Felle wie ratte.py), Bewegungen unter unseren
# Namen, Blick +Z wie vierbeiner.py; im Spiel trägt figur.gd unseren Shader und die Tusche darüber.
# Bemalung: aus der gekauften Farbtextur nur die Helligkeit (Fellzeichnung, Falten); Fell, Haut, Augen je Bildpunkt eingeteilt
# und mit unseren Fellfarben (ratte.py COATS) neu gefärbt, darüber unsere Fellstriche (fellstriche()) in der Wuchsrichtung.
# Aufruf: KAUF=<ordner> OUT=<ordner> [VARIANTE=gross] python -I kaufratte.py  ->  <OUT>/giant_rat-<fell>.glb, giant_rat-info.json
# VARIANTE=gross: 1,25-fach und quer 1,2-fach (Archiv 348.12c Stufe 2: „Variante größer, dicker, Bemalung“), Felle mit Schorf.
# Runde 2 (Chef 26.10., 20:01 „struppiger, mehr Ausdruck, düsterer, tiefer geduckt“): fellstriche(), HELL, HAUT2, Augenhöhle,
# ducken() in allen Bewegungen (TIEFE m, NICKEN Grad).
# Restrunde (Chef 26.10., 21:12 „gekauft“; Folgerungen Chefsache 34812f-kaufratte-r2, Stellungnahme Sokrates): Pfoten und Rute
# wie das Fell, braun wärmer statt dunkler, Ohren kürzer und runder (ohren()), Biss ohne Sprung (verstaerken() mit Faktoren < 1),
# Treffer und Drohen deutlicher (Faktoren > 1), Rute kürzer (RUTE), damit sie im Bild bleibt.
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
from mathutils import Vector, Matrix

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
VARIANTE = os.environ.get('VARIANTE', '')
ID = 'giant_rat'
DREIECKE = 5800              # Chef 26.10., 12:56: unter 6.000 (Modellregel 7)
TEX = 1024                   # Handy: 1024² statt 2048²
# eigene Ratte (ratte.py Runde 11): 0,6 m Schulter; Höhe des ganzen Netzes in Ruhe (Ohren) (giant_rat-braun.glb in Ruhe: 0,67 m)
HOEHE = float(os.environ.get('HOEHE', '0') or 0)
GROSS = (1.25, 1.2) if VARIANTE == 'gross' else (1.0, 1.0)     # (Maßstab, quer)
# Chef 26.10., 20:01 „wenn geht, Haltung tiefer, geduckter“: Rumpf tiefer (m, Quelle), Hals gehoben (Grad)
TIEFE = float(os.environ.get('TIEFE', '0.14'))     # 2b: 0,09 m las der Helfer als „kaum geduckt“
NICKEN = float(os.environ.get('NICKEN', '-12'))
HOCKE = float(os.environ.get('HOCKE', '0.07'))     # Hocke noch so viel tiefer als die geduckte Haltung (m)
STRUPP = float(os.environ.get('STRUPP', '0.02'))     # 2b: Fellrand, Ecken bis so weit nach außen (m, Quelle)
# Bewegungen: unsere Namen (figur.gd) <- Protofactor (Animation List.txt); Hocke ist die Ausholstellung aus jumpBite
# Restrunde: Sprung (kippte kopfüber, Rute senkrecht) entfällt, Biss ist jumpBite gedämpft (q_biss), Treffer und Drohen verstärkt
# Restrunde b (Helfer 21:48): Ausweichen aus dodgeRight (flacher Satz; dodgeLeft drehte kopfüber), Rute in Lefzen, Tod, Ausweichen
# gedämpft (stand senkrecht als Haken, reichte über den Bildrand)
NAMEN = [('Stehen', 'idle', True), ('Gehen', 'walk', True), ('Rennen', 'run', True), ('Biss', 'q_biss', False),
         ('Treffer', 'q_treffer', False), ('Ausweichen', 'q_ausweichen', False),
         ('Tod', 'q_tod', False), ('Lefzen', 'q_lefzen', False), ('Drohen', 'q_drohen', False)]
# Für die Frage des Chefs (21:12, „verschiedene Ausweichbewegungen, Angriffsarten und Todesanimationen“): die übrigen Bewegungen
# der Quelle unter eigenem Namen mit ausgeben (figur.gd spielt sie nicht; Film SCHAU_LISTE)
WEITERE = [('Ausweichen links', 'dodgeLeft'), ('Ausweichen zurück', 'dodgeBackwards'), ('Treffer links', 'getHitLeft'),
           ('Treffer rechts', 'getHitRight'), ('Sprungbiss', 'jumpBite')]
QUELLEN = ['idle', 'walk', 'run', 'jumpBite', 'getHitFront', 'dodgeRight', 'death', 'taunt'] + [q for _, q in WEITERE]
# Faktor je Knochen (Teil des Namens, erster Treffer) auf die Abweichung vom ersten Bild: < 1 dämpft, > 1 verstärkt
BISS = (('Head', 1.0), ('Neck', 1.0), ('Spine1', 0.75), ('Spine', 0.55), ('Pelvis', 0.3), ('Tail', 0.15),     # b: „sehr klein“
        ('Clavicle', 0.5), ('UpperArm', 0.5), ('Forearm', 0.5), ('Hand', 0.5), ('Thigh', 0.3), ('Calf', 0.3),
        ('HorseLink', 0.3), ('Foot', 0.3), ('GIANT_RAT_', 0.3), ('ROOT_', 0.3))
# b (Helfer: Körper zuckt kaum, Rute schnellt senkrecht hoch wie ein Skorpion): Rumpf stärker, Rute gedämpft; Beine aus der Quelle
TREFFER = (('Head', 2.5), ('Neck', 2.5), ('Spine1', 2.2), ('Spine', 2.0), ('Tail', 0.3), ('GIANT_RAT_', 2.5))
DROHEN = (('Head', 2.0), ('Neck', 2.0), ('Spine1', 1.8), ('Spine', 1.5), ('Tail', 0.4))
DROHEN_NICKEN, DROHEN_TIEFE = -35.0, 0.04      # b: Drohen „unverändert schwach“: Kopf hoch, Rumpf tiefer (gesträubt, lauernd)
RUTE_RUHIG = (('Tail', 0.4),)                  # Lefzen, Tod, Ausweichen: Rute nicht als Haken hoch
RUTE = float(os.environ.get('RUTE', '0.55'))
RUTE_BODEN = 0.03     # c (Helfer Runde b: im Tod liegt die Rute „wie abgetrennt“, bis 19 cm im Boden): tiefster Rutenpunkt (m, Quelle)       # Rute: 1,6 m in der Quelle, Rumpf mit Kopf 1,4 m; die Rute reichte über den Bildrand
OHR = float(os.environ.get('OHR', '0.45'))          # Ohren so lang wie in der Quelle mal OHR (Prüfer: „spitze Ohren wie Hörner“)
# Felle wie ratte.py COATS: (Fell, Sattel, Bauch, Auge); Haut wie ratte.py HAUT, RUTE
COATS = {
    'braun':   (0x503A28, 0x2E1F16, 0x705A46, 0xE01E14),     # Restrunde: wärmer bei gleicher Helligkeit (war 4A3C34, 2A201C, 6A5C50)
    'grau':    (0x55504C, 0x2A2826, 0x7A726A, 0xF03A20),
    'schwarz': (0x2A2624, 0x121010, 0x4A4240, 0xF04A28),
}
HAUT, NAGEZAHN, MAUL = 0xB49490, 0xE6D8B8, 0x4A2422
# Runde 2 (Chef 26.10., 20:01 „düsterer“; Chefsache 34812f: Pfoten und Rute weiß-rosa wie Socken): Haut gedämpft, graubraun;
# Schorf (ratte.py SCHORF) statt rosa Räude; Augenhöhle dunkel (Ausdruck)
HAUT2, SCHORF = 0x4E423E, 0x2E1E1A     # 2b: Socken und Rost (Helfer) -> näher am Fell, Schorf schwarzbraun
B = 'GIANT_RAT_ '
UMBENENNEN = {B + 'Neck': 'hals', B + 'Head': 'kopf', B + 'L Hand': 'vpfoteL', B + 'R Hand': 'vpfoteR', B + 'L Foot': 'hpfoteL', B + 'R Foot': 'hpfoteR'}
HELL = {'braun': 0.40, 'grau': 0.42, 'schwarz': 0.8}     # Runde 2: düsterer; 2b: Helfer maß grau 100 / braun 57 gegen eigen 64 / 29


def lin(h):
    c = np.array([((h >> s) & 255) / 255.0 for s in (16, 8, 0)])
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def srgb(c):
    c = np.clip(c, 0, 1)
    return np.where(c <= 0.0031308, c * 12.92, 1.055 * c ** (1 / 2.4) - 0.055)


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    t = sorted(glob.glob(os.path.join(KAUF, '**', 'GIANT_RAT.FBX'), recursive=True))
    if not t:
        sys.exit('GIANT_RAT.FBX nicht gefunden unter %s' % KAUF)
    fbx = t[0]; d = os.path.dirname(fbx)
    tex = os.path.join(os.path.dirname(d), 'Textures')
    return fbx, d, tex


def tris(obs):
    return sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in obs)


def neu_objekte(vorher):
    return [o for o in bpy.data.objects if o.name not in vorher]


def biped_flicken():
    """Lauf 114: Blenders FBX-Import gibt dem Biped-Knoten „GIANT_RAT_“ (Typ Root unter ROOT_) und allem darunter kein Skelett:
    find_armatures läuft vor find_fake_bones, das ihn erst zum Knochen macht -> KeyError None beim Binden. Danach neu zuordnen."""
    from io_scene_fbx import import_fbx as I
    H = I.FbxImportHelperNode
    if getattr(H, '_bornim_biped', False):
        return
    alt = H.find_fake_bones

    def neu(self, in_armature=False):
        alt(self, in_armature)
        if self.parent is None:
            def lauf(n):
                if n.is_armature:
                    n.find_armature_bones(n)
                for c in n.children:
                    lauf(c)
            lauf(self)
    H.find_fake_bones = neu; H._bornim_biped = True


def importiere(fbx):
    biped_flicken()
    vorher = {o.name for o in bpy.data.objects}
    bpy.ops.import_scene.fbx(filepath=fbx, use_anim=True, ignore_leaf_bones=True, automatic_bone_orientation=False)
    return neu_objekte(vorher)


def aktion_von(obs):
    for o in obs:
        if o.type == 'ARMATURE' and o.animation_data and o.animation_data.action:
            return o.animation_data.action
    return None


def weg(obs):
    for o in obs:
        d = o.data
        bpy.data.objects.remove(o, do_unlink=True)
        if d is not None and d.users == 0:
            if isinstance(d, bpy.types.Mesh): bpy.data.meshes.remove(d)
            elif isinstance(d, bpy.types.Armature): bpy.data.armatures.remove(d)


def slot(act):
    return act.slots[0] if hasattr(act, 'slots') and len(act.slots) else None


def welt_netz(obs, frame):
    """Ecken aller Netze in Weltkoordinaten bei diesem Bild (mit Skelett)."""
    bpy.context.scene.frame_set(frame)
    dg = bpy.context.evaluated_depsgraph_get(); P = []
    for o in obs:
        e = o.evaluated_get(dg); me = e.to_mesh()
        M = e.matrix_world
        P += [M @ v.co for v in me.vertices]
        e.to_mesh_clear()
    return np.array([p[:] for p in P])


# Lauf 114 lokal: die Quelltextur ist durchweg hell beige (Mittel 0,65/0,53/0,47); nach Farbe allein galten 57 % als Haut
# und das Fell bestand zu großen Teilen aus der leeren schwarzen UV-Fläche (30 %, Helligkeit p50 0). Haut darum nach dem
# Skelett: Flächen, die vor allem an Rute, Pfoten und Zehen hängen; am Kopf (Nase, Ohren) zusätzlich nach Farbe.
HAUT_KNOCHEN = ('tail', 'hand', 'finger', 'foot', 'toe')


def _zwei_knochen(H1, A, H0, K0):
    """Knie für Hüfte H1 und Ziel A (Längen und Beugeebene wie in der Quelle H0, K0, A)."""
    l1, l2 = (K0 - H0).length, (A - K0).length
    D = A - H1; dist = min(max(D.length, 1e-6), (l1 + l2) * 0.999); Dn = D.normalized()
    a = (l1 * l1 - l2 * l2 + dist * dist) / (2 * dist); h = math.sqrt(max(l1 * l1 - a * a, 0.0))
    n = (A - H0).cross(K0 - H0)
    if n.length < 1e-9: return K0 - H0 + H1
    n.normalize()
    seite = 1.0 if n.cross((A - H0).normalized()).dot(K0 - H0) >= 0 else -1.0
    return H1 + Dn * a + n.cross(Dn) * h * seite


def ducken(rig, a, tiefe, nicken, beine_aus=None):
    """Chef 26.10., 20:01 „Haltung tiefer, geduckter“: in jeder Bewegung Rumpf (Biped-Wurzel) um `tiefe` m tiefer, Hals um
    `nicken` Grad gehoben (Kopf lauert nach vorn statt zu fressen); Pfoten bleiben, wo sie waren: Ober-/Unterschenkel bzw.
    Ober-/Unterarm neu gebeugt (zwei Knochen, Beugeebene der Quelle), Mittelfuß und Pfote in ihrer Lage aus der Quelle.
    Blenders IK geht hier nicht: die Biped-Knochen zeigen nicht auf ihr Kind (Oberschenkelspitze vorn am Bauch).
    Liegt der Rumpf (Tod, Sturz), läuft das Ducken aus: voll ab 0,40 m Beckenhöhe, keines unter 0,15 m (sonst sänke er ein).
    beine_aus (Restrunde): Beine und Pfoten aus dieser Bewegung statt aus `a` (verstärkter Rumpf, Pfoten bleiben stehen)."""
    rig.animation_data.action = a
    if slot(a) is not None: rig.animation_data.action_slot = slot(a)
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    W = rig.matrix_world; W3i = W.to_3x3().inverted()
    unten = W3i @ Vector((0, 0, -1)); quer = (W3i @ Vector((1, 0, 0))).normalized()
    pb = rig.pose.bones; vl = bpy.context.view_layer
    com, hals = pb[B.strip()], pb[B + 'Neck']
    # (oben, Mitte, unten, Pfote): Hüfte-Knie-Sprunggelenk mit Mittelfuß und Fuß; Schulter-Ellbogen-Handgelenk mit Hand
    beine = [(B + s + ' Thigh', B + s + ' Calf', B + s + ' HorseLink', B + s + ' Foot') for s in ('L', 'R')] + \
            [(B + s + ' UpperArm', B + s + ' Forearm', B + s + ' Hand', None) for s in ('L', 'R')]
    alle = {n for b in beine for n in b if n}
    quelle, fak = {}, {}
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f)
        quelle[f] = {n: pb[n].matrix.copy() for n in alle | {com.name, hals.name}}
        fak[f] = min(1.0, max(0.0, ((W @ pb[B + 'Pelvis'].head).z - 0.15) / 0.25))
    if beine_aus is not None:
        rig.animation_data.action = beine_aus
        if slot(beine_aus) is not None: rig.animation_data.action_slot = slot(beine_aus)
        for f in range(a0, a1 + 1):
            bpy.context.scene.frame_set(f)
            quelle[f].update({n: pb[n].matrix.copy() for n in alle})
        rig.animation_data.action = a
        if slot(a) is not None: rig.animation_data.action_slot = slot(a)
    gross = 0.0
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f)
        q, k = quelle[f], fak[f]
        h = q[hals.name].to_translation()
        hals.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(nicken) * k, 4, quer) @ Matrix.Translation(-h) @ q[hals.name]
        com.matrix = Matrix.Translation(unten * (tiefe * k)) @ q[com.name]     # unten: Welt-Meter in Skelett-Einheiten
        vl.update()
        for o, m, u, p in beine:
            H0, K0, A0 = (q[n].to_translation() for n in (o, m, u))
            H1 = pb[o].head.copy()
            K1 = _zwei_knochen(H1, A0, H0, K0)
            r = (K0 - H0).rotation_difference(K1 - H1).to_matrix().to_4x4()
            pb[o].matrix = Matrix.Translation(H1) @ r @ Matrix.Translation(-H0) @ q[o]; vl.update()
            Ak = pb[u].head.copy()
            r = (Ak - K1).rotation_difference(A0 - K1).to_matrix().to_4x4()
            pb[m].matrix = Matrix.Translation(K1) @ r @ Matrix.Translation(-K1) @ pb[m].matrix; vl.update()
            for n in (u, p):
                if n: pb[n].matrix = q[n]; vl.update()
            Pf = pb[p or u].head
            gross = max(gross, (Pf - q[p or u].to_translation()).length * W.to_scale()[0])
        for n in alle | {com.name, hals.name}:
            pb[n].keyframe_insert('location', frame=f); pb[n].keyframe_insert('rotation_quaternion', frame=f)
    return sum(fak.values()) / len(fak), gross


def _faktor(knochen, faktoren):
    teil = knochen[len(B):] if knochen.startswith(B) else knochen
    for k, f in faktoren:
        if k in teil: return f
    return 1.0


def verstaerken(a, name, faktoren):
    """Restrunde: Kopie von `a`, jede Kurve je Knochen um ihren Wert im ersten Bild mit Faktor gestreckt (< 1 gedämpft, z. B.
    Biss ohne Sprung; > 1 verstärkt, Treffer und Drohen). Blender normalisiert die Quaternionen beim Auswerten."""
    import re
    h = a.copy(); h.name = name; h.use_fake_user = True
    a0 = h.frame_range[0]; n = 0
    for lay in h.layers:
        for st in lay.strips:
            for cb in st.channelbags:
                for fc in cb.fcurves:
                    m = re.match(r'pose\.bones\["(.+)"\]', fc.data_path)
                    f = _faktor(m.group(1), faktoren) if m else 1.0
                    if f == 1.0: continue
                    v0 = fc.evaluate(a0); n += 1
                    for kp in fc.keyframe_points:
                        kp.co[1] = v0 + f * (kp.co[1] - v0)
                        kp.handle_left[1] = v0 + f * (kp.handle_left[1] - v0); kp.handle_right[1] = v0 + f * (kp.handle_right[1] - v0)
    print('VERSTAERKT', name, n, 'Kurven')
    return h


def ohren(meshes, faktor):
    """Restrunde (Prüfer 20:54: „spitze Ohren wie Hörner, eher dämonisch als Ratte“): Ohren kürzer und runder. Kein Ohrknochen:
    Ohr = Kopf-Ecken seitlich (|x| > 9 cm) über der Schädeldecke (z > 0,50 m) hinter den Augen (y > -0,72 m), Ruhelage der Quelle.
    Je Seite längs der Achse Ansatz -> Spitze auf `faktor` gestaucht, quer an der Spitze breiter (rund statt spitz), am Ansatz
    weich auslaufend (2,5 cm)."""
    if faktor >= 1.0: return
    for o in meshes:
        me = o.data; M = o.matrix_world; Mi = M.inverted()
        gname = {g.index: g.name for g in o.vertex_groups}
        for seite in (1, -1):
            idx, P = [], []
            for v in me.vertices:
                w = max(v.groups, key=lambda e: e.weight, default=None)
                if not w or 'Head' not in gname.get(w.group, ''): continue
                p = M @ v.co
                if p.x * seite > 0.08 and p.z > 0.49 and p.y > -0.82:     # b: fernes Ohr blieb spitz
                    idx.append(v.index); P.append(p)
            if len(P) < 10:
                print('OHR nicht gefunden', o.name, seite); continue
            Z = np.array([p.z for p in P])
            basis = sum((p for p, z in zip(P, Z) if z < 0.52), Vector()) / max(1, int((Z < 0.52).sum()))
            spitze = sum((p for p, z in zip(P, Z) if z >= np.percentile(Z, 85)), Vector()) / max(1, int((Z >= np.percentile(Z, 85)).sum()))
            ax = (spitze - basis).normalized(); tmax = max((p - basis).dot(ax) for p in P)
            for i, p in zip(idx, P):
                d = p - basis; t = d.dot(ax); quer = d - ax * t
                if t <= 0: continue
                s = min(1.0, t / tmax); w = min(1.0, t / 0.025); w = w * w * (3 - 2 * w)
                neu = basis + ax * (t * faktor) + quer * (1.0 + 0.35 * s)
                me.vertices[i].co = Mi @ (p + (neu - p) * w)
            print('OHR', 'links' if seite > 0 else 'rechts', len(idx), 'Ecken, Länge %.3f -> %.3f m' % (tmax, tmax * faktor))


def rutenspitze(rig, meshes):
    """b (Helfer: Rutenende stumpf, in zwei bis drei Zinken): Ecken am letzten Rutenknochen zur Knochenachse hin, spitz zulaufend."""
    b = rig.data.bones.get(B + 'Tail8')
    if b is None: return
    W = rig.matrix_world; h, t = W @ b.head_local, W @ b.tail_local; ax = (t - h); L = ax.length; ax.normalize()
    for o in meshes:
        M = o.matrix_world; Mi = M.inverted(); gi = {g.index: g.name for g in o.vertex_groups}; n = 0
        for v in o.data.vertices:
            w = max(v.groups, key=lambda e: e.weight, default=None)
            if not w or gi.get(w.group) != B + 'Tail8': continue
            p = M @ v.co; u = max(0.0, min(1.0, (p - h).dot(ax) / L)); a = h + ax * ((p - h).dot(ax))
            v.co = Mi @ (a + (p - a) * (1.0 - 0.85 * u)); n += 1
        print('RUTENSPITZE', n, 'Ecken')


def rute_aus_dem_boden(rig, a):
    """c: je Bild jedes Rutenglied (vom Ansatz zur Spitze) so wenig wie nötig heben (Drehung um seine waagerechte Querachse),
    dass sein Ende über RUTE_BODEN liegt; die Winkel je Glied über ±3 Bilder geglättet (kein Zucken). Glied für Glied, jedes auf
    allen Bildern gesetzt, bevor das nächste drankommt (die Rute bleibt am Boden liegen statt als Bogen hochzustehen)."""
    pb = rig.pose.bones; W = rig.matrix_world; vl = bpy.context.view_layer; Rw = W.to_3x3().normalized()
    rig.animation_data.action = a
    if slot(a) is not None: rig.animation_data.action_slot = slot(a)
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1]); summe = []
    kette = [B + 'Tail'] + [B + 'Tail%d' % i for i in range(1, 9)]
    for i, nm in enumerate(kette):
        p = pb[nm]; roh, wink, achse = {}, {}, {}; nach = pb[kette[i + 1]] if i + 1 < len(kette) else None
        for f in range(a0, a1 + 1):
            bpy.context.scene.frame_set(f); vl.update(); m0 = p.matrix.copy(); roh[f] = m0; ra = m0.to_translation()
            # Ende des Glieds = Kopf des nächsten (p.tail kennt den Maßstab RUTE am Rutenansatz nicht)
            ende = lambda: (W @ nach.head) if nach else (W @ p.head) + ((W @ p.tail) - (W @ p.head)) * RUTE
            d = ende() - (W @ p.head); d.z = 0
            ax = d.cross(Vector((0, 0, 1))); ax = (Rw.inverted() @ ax).normalized() if ax.length > 1e-6 else Vector((1, 0, 0)); achse[f] = ax
            w = 0
            while ende().z < RUTE_BODEN and w < 90:
                w += 3; p.matrix = Matrix.Translation(ra) @ Matrix.Rotation(math.radians(w), 4, ax) @ Matrix.Translation(-ra) @ m0; vl.update()
            wink[f] = w
        for f in range(a0, a1 + 1):
            w = max(wink[g] for g in range(max(a0, f - 3), min(a1, f + 3) + 1))
            bpy.context.scene.frame_set(f); ra = roh[f].to_translation()
            p.matrix = Matrix.Translation(ra) @ Matrix.Rotation(math.radians(w), 4, achse[f]) @ Matrix.Translation(-ra) @ roh[f]
            vl.update(); p.keyframe_insert('rotation_quaternion', frame=f)
        summe.append(max(wink.values()))
    print('RUTE BODEN', a.name, 'größter Winkel je Glied', summe)
    rig.animation_data.action = None


def struppig_rand(meshes, rng):
    """2b (Helfer: „Umriss glatt, ohne Büschel“): Fell-Ecken (nicht Rute, Pfoten, Kopf) einzeln 0–STRUPP m nach außen."""
    if STRUPP <= 0: return
    n = 0
    for o in meshes:
        me = o.data; M3 = o.matrix_world.to_3x3(); Mi = M3.inverted()
        gname = {g.index: g.name.lower() for g in o.vertex_groups}
        for v in me.vertices:
            w = max(v.groups, key=lambda e: e.weight, default=None)
            k = gname.get(w.group, '') if w else ''
            if any(h in k for h in HAUT_KNOCHEN + ('head',)): continue
            nw = (M3 @ v.normal).normalized()
            v.co += Mi @ (nw * (STRUPP * rng.random() ** 2))
            n += 1
    print('STRUPPIG', n, 'Ecken, bis %.3f m' % STRUPP)


def fellstriche(meshes, rng, haut):
    """Chef 26.10., 20:01 „struppige Fellstruktur“: Strähnen im UV-Bild, je Fläche in Wuchsrichtung (zum Schwanz und nach unten,
    in die Fläche gelegt und über die UV-Ableitung ins Bild), gegeneinander verdreht (struppig, nicht gekämmt): dunkler Grund,
    helle Spitze. Ergebnis: Faktor je Bildpunkt um 1 (0,5 … 1,5); Haut (Rute, Pfoten, Nase) bleibt ohne Striche."""
    from PIL import Image, ImageDraw
    img = Image.new('L', (TEX, TEX), 128); dr = ImageDraw.Draw(img)
    wuchs = Vector((0, 1, -0.7)).normalized()          # Kopf liegt bei -Y (Quelle, Welt): Haar zeigt nach hinten und unten
    n = 0
    for o in meshes:
        me = o.data; uv = me.uv_layers.active.data; M = o.matrix_world
        P = [M @ v.co for v in me.vertices]
        for poly in me.polygons:
            li = list(poly.loop_indices); vi = list(poly.vertices)
            U = [Vector((uv[i].uv[0] * TEX, (1 - uv[i].uv[1]) * TEX)) for i in li]
            mx = sum(U, Vector((0, 0))) / len(U)
            if haut[min(TEX - 1, max(0, int(mx.y))), min(TEX - 1, max(0, int(mx.x)))]: continue
            for t in range(1, len(vi) - 1):
                p0, p1, p2 = P[vi[0]], P[vi[t]], P[vi[t + 1]]; u0, u1, u2 = U[0], U[t], U[t + 1]
                e1, e2, f1, f2 = p1 - p0, p2 - p0, u1 - u0, u2 - u0
                det = f1.x * f2.y - f1.y * f2.x; fl = abs(det) / 2
                if fl < 0.5: continue
                # J: dP = J du; J = [e1 e2] @ inv([f1 f2])
                inv = ((f2.y / det, -f2.x / det), (-f1.y / det, f1.x / det))
                Jx = e1 * inv[0][0] + e2 * inv[1][0]; Jy = e1 * inv[0][1] + e2 * inv[1][1]
                nrm = e1.cross(e2)
                if nrm.length < 1e-12: continue
                nrm.normalize(); g = wuchs - nrm * wuchs.dot(nrm)
                if g.length < 0.2: g = (Vector((0, 0, -1)) - nrm * (-nrm.z))
                if g.length < 1e-6: continue
                g.normalize()
                # du aus g: kleinste Quadrate in 2D
                a11, a12, a22 = Jx.dot(Jx), Jx.dot(Jy), Jy.dot(Jy); b1, b2 = Jx.dot(g), Jy.dot(g); dd = a11 * a22 - a12 * a12
                if abs(dd) < 1e-18: continue
                du = Vector(((a22 * b1 - a12 * b2) / dd, (a11 * b2 - a12 * b1) / dd))
                m_je_px = (Jx * du.x + Jy * du.y).length / max(du.length, 1e-12)
                if du.length < 1e-12 or m_je_px <= 0: continue
                du.normalize()
                for _ in range(int(fl / 22) + (1 if rng.random() < (fl / 22) % 1 else 0)):
                    r1, r2 = rng.random(), rng.random()
                    if r1 + r2 > 1: r1, r2 = 1 - r1, 1 - r2
                    q = u0 + f1 * r1 + f2 * r2
                    # 2b (Helfer: „Granit, Salz und Pfeffer“): Büschel aus drei Strähnen, länger und breiter, je Büschel eine Richtung
                    w = rng.normal(0, 0.35)                         # struppig: Büschel stehen kreuz und quer
                    d = Vector((du.x * math.cos(w) - du.y * math.sin(w), du.x * math.sin(w) + du.y * math.cos(w)))
                    s = Vector((-d.y, d.x))
                    L = min(rng.uniform(0.03, 0.06) / m_je_px, 60)
                    for b in (-1, 0, 1):
                        q0 = q + s * (b * 2.5) + d * (abs(b) * L * 0.15); q2 = q0 + d * L * (1 - abs(b) * 0.2)
                        dr.line([tuple(q0), tuple(q2)], fill=int(rng.choice([45, 60, 75])), width=3)
                        dr.line([tuple(q0 + d * L * 0.4 + s), tuple(q2 + s)], fill=int(rng.choice([165, 185])), width=1)
                    n += 1
    print('FELLSTRICHE', n)
    return np.asarray(img).astype(np.float32) / 128.0


def uv_masken(meshes):
    """Bildmasken (TEX²) aus UV und Gewichten: belegt, Haut (Rute, Pfoten), Kopf."""
    from PIL import Image, ImageDraw
    bel, haut, kopf = (Image.new('L', (TEX, TEX), 0) for _ in range(3))
    db, dh, dk = ImageDraw.Draw(bel), ImageDraw.Draw(haut), ImageDraw.Draw(kopf)
    for o in meshes:
        me = o.data; uv = me.uv_layers.active.data
        gname = {g.index: g.name.lower() for g in o.vertex_groups}
        knochen = []
        for v in me.vertices:
            w = max(v.groups, key=lambda e: e.weight, default=None)
            knochen.append(gname.get(w.group, '') if w else '')
        for p in me.polygons:
            pts = [(uv[i].uv[0] * TEX, (1 - uv[i].uv[1]) * TEX) for i in p.loop_indices]
            ks = [knochen[v] for v in p.vertices]
            db.polygon(pts, fill=255)
            if sum(any(h in k for h in HAUT_KNOCHEN) for k in ks) * 2 > len(ks): dh.polygon(pts, fill=255)
            elif sum('head' in k for k in ks) * 2 > len(ks): dk.polygon(pts, fill=255)
    return tuple(np.asarray(m) > 127 for m in (bel, haut, kopf))


def bemalung(src_png, fell, rng, masken=None, striche=None):
    """Eigene Bemalung: Helligkeit der gekauften Textur, Einteilung Fell/Haut/Auge, unsere Farben, unsere Fellstriche."""
    from PIL import Image, ImageFilter
    im = Image.open(src_png).convert('RGB').resize((TEX, TEX), Image.LANCZOS)
    s = np.asarray(im).astype(np.float32) / 255.0
    r, g, b = s[..., 0], s[..., 1], s[..., 2]
    mx, mn = s.max(-1), s.min(-1); sat = (mx - mn) / np.maximum(mx, 1e-4)
    L = 0.2126 * r + 0.7152 * g + 0.0722 * b
    auge = (r > 0.3) & (r > 2.0 * g) & (r > 2.0 * b) & (sat > 0.55)
    haut = ~auge & (r > 1.12 * g) & (r > 1.02 * b) & (sat > 0.16) & (sat < 0.62) & (mx > 0.32) & (b > 0.85 * g)
    zahn = ~auge & ~haut & (mx > 0.62) & (r > b * 1.1) & (g > b * 1.05) & (sat < 0.45) & (sat > 0.12)
    maul = np.zeros_like(auge)
    if masken is not None:
        bel, mhaut, mkopf = masken
        auge &= mkopf; zahn &= mkopf
        # Helfer 18:51: der ganze Kopf war Haut (die Quelle ist dort so beige wie der Rumpf); am Kopf nur deutlich Rötliches
        # (Nase, Ohren innen; rot = (r-g)/L, Kopf p50 0,21, p90 0,59). Rot an Lippen und Nase ist kein Auge: Auge nur, was an
        # die Leuchtkarte (Illum) grenzt; das übrige Rot wird Maul (dunkel), statt wie Blut zu wirken.
        rot = (r - g) / np.maximum(L, 1e-3)
        haut = (mhaut | (mkopf & (rot > 0.6))) & ~auge & ~zahn     # 2b: 0,42 machte den Kopf kahl (Helfer)
        ill = sorted(glob.glob(os.path.join(os.path.dirname(src_png), '*Illum*')))
        if ill:
            keim = np.asarray(Image.open(ill[0]).convert('L').resize((TEX, TEX))) > 25
            erlaubt = np.asarray(Image.fromarray((auge * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))) > 127
            a = keim & erlaubt
            for _ in range(TEX // 16):
                b2 = np.asarray(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3))) > 127
                b2 &= erlaubt
                if (b2 == a).all(): break
                a = b2
            maul = auge & ~a; auge = auge & a
        # Helfer 18:56: helle Sprenkel auf Stirn und Wangen waren als Zahn gefärbt; Zähne nur am Maul (bis ~12 px daneben)
        nah = np.asarray(Image.fromarray((maul * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(25))) > 127
        zahn &= nah
    else:
        bel = np.ones_like(auge)
    fellm = ~(auge | haut | zahn | maul)
    fl = L[fellm & bel] if (fellm & bel).any() else L.ravel()
    p5, p50, p95 = np.percentile(fl, [5, 50, 95])
    print('BEMALUNG %s Quelle: Fell %.0f%% Haut %.0f%% Auge %.2f%% Maul %.2f%% Zahn %.2f%%, Helligkeit p5 %.3f p50 %.3f p95 %.3f' % (
        fell, 100 * (fellm & bel).sum() / bel.sum(), 100 * (haut & bel).sum() / bel.sum(), 100 * (auge & bel).sum() / bel.sum(),
        100 * (maul & bel).sum() / bel.sum(), 100 * (zahn & bel).sum() / bel.sum(), p5, p50, p95))
    # Feinzeichnung (Strähnen, Falten) gegen die grobe Helligkeit (Sattel dunkel, Bauch hell)
    Lb = np.asarray(Image.fromarray((L * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(TEX / 64))).astype(np.float32) / 255.0
    fein = np.clip(L / np.maximum(Lb, 1e-3), 0.6, 1.5)
    grob = np.clip((Lb - p5) / max(p95 - p5, 1e-3), 0, 1)
    fu, sa, be, au = (lin(h) for h in COATS[fell])
    # Sattel (dunkel) -> Fell -> Bauch (hell) über die grobe Helligkeit, mal Feinzeichnung
    t = grob[..., None]
    farbe = np.where(t < 0.5, sa + (fu - sa) * (t / 0.5), fu + (be - fu) * ((t - 0.5) / 0.5))
    farbe = farbe * fein[..., None] ** 1.3 * HELL[fell]
    if striche is not None:
        farbe = farbe * np.clip(striche, 0.3, 1.8)[..., None] ** 0.9
    # Ausdruck: Augenhöhle dunkel, nach außen weich auslaufend (~14 px)
    if auge.any():
        ring = np.asarray(Image.fromarray((auge * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.GaussianBlur(7))).astype(np.float32) / 255.0
        farbe = farbe * (1 - 0.6 * np.clip(ring * 1.6, 0, 1))[..., None]
    hl = L / max(np.median(L[haut]) if haut.any() else 0.5, 1e-3)
    # Helfer 18:51: harte, gezackte Kanten Haut/Fell an Hals, Rutenansatz, Pfoten (Flächengrenzen): Übergang weich, ~6 px
    wh = np.asarray(Image.fromarray((haut * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(TEX / 64))).astype(np.float32) / 255.0     # 2b: harte Naht an Hals und Handgelenk (Helfer)
    wh = np.where(auge | zahn | maul, 0.0, wh)[..., None]
    # 2c (Helfer zu 2b: Pfoten hell wie Socken, Rute oben dunkel, unten hell mit harter Kante): Haut dunkler, Schattierung flacher
    # Restrunde (Prüfer: Pfoten und Rute weiter heller als der Körper): an Rute und Pfoten das Mittel des Fells, etwas dunkler;
    # Nase und Ohren innen behalten HAUT2
    hz = lin(HAUT2) * 0.7
    if masken is not None and (fellm & bel).any():
        fm = np.median(farbe[fellm & bel], axis=0)
        kb = np.asarray(Image.fromarray((mhaut * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(TEX / 64))).astype(np.float32)[..., None] / 255.0
        kb = np.maximum(kb, mhaut[..., None].astype(np.float32))     # b: kleine Inseln (Vorderpfoten) blieben grau-mauve
        hz = (fm * 0.9 * 0.6 + hz * 0.4) * (1 - kb) + fm * 0.8 * kb     # b: Ohr innen dunkel wie ein Loch -> näher am Fell
    farbe = farbe * (1 - wh) + hz * np.clip(hl, 0.8, 1.1)[..., None] * wh
    farbe = np.where(maul[..., None], lin(MAUL) * np.clip(L / max(np.median(L[maul]) if maul.any() else 0.3, 1e-3), 0.6, 1.3)[..., None], farbe)
    farbe = np.where(zahn[..., None], lin(NAGEZAHN) * np.clip(L / max(np.median(L[zahn]) if zahn.any() else 0.7, 1e-3), 0.7, 1.2)[..., None], farbe)
    farbe = np.where(auge[..., None], au * np.clip(L / max(np.median(L[auge]) if auge.any() else 0.3, 1e-3), 0.6, 1.4)[..., None], farbe)
    # Räude (VARIANTE=gross), Runde 2 als Schorf (Chefsache 34812f: „weiße Tupfen, gemustert statt verschorft“): wenige
    # unregelmäßige Stellen aus zwei Rauschgrößen, dunkel verkrustet mit kahlem Rand, Fellstriche darin abgeschwächt
    if VARIANTE == 'gross':
        def rausch(k):
            return np.asarray(Image.fromarray((rng.random((k, k)) * 255).astype(np.uint8)).resize((TEX, TEX), Image.BICUBIC)).astype(np.float32) / 255.0
        n = rausch(TEX // 64) * 0.65 + rausch(TEX // 12) * 0.35
        kern = fellm & (n > 0.74); rand = fellm & (n > 0.70) & ~kern     # 2b: weniger Stellen (Helfer: „Tarnmuster“)
        print('SCHORF %.1f%% des Fells' % (100 * kern.sum() / max(1, fellm.sum())))
        weich = lambda m, r: np.asarray(Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(r))).astype(np.float32)[..., None] / 255.0
        wr, wk = weich(rand | kern, 3), weich(kern, 2)     # 2b: Kanten weich (Helfer: „harte Kanten, aufgemalt“)
        farbe = farbe * (1 - wr) + farbe * 0.85 * wr     # b: kahler Rand in Fellfarbe (HAUT2 hellte schwarz über die eigene auf)
        farbe = farbe * (1 - wk) + lin(SCHORF) * np.clip(fein, 0.6, 1.5)[..., None] ** 2 * wk
    if masken is not None:     # 2c: Rand außerhalb der UV-Inseln (Helfer: heller Lichthof um Pfoten und Rute, blutet mit Mipmaps)
        farbe = np.where(bel[..., None], farbe, np.median(farbe[fellm & bel], axis=0))
    out = (srgb(farbe) * 255).astype(np.uint8)
    p = os.path.join(OUT, '%s-kauf-%s.png' % (ID, fell))
    Image.fromarray(out).save(p)
    return p


def baue(fell):
    fbx, d, texdir = quelle()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene
    obs = importiere(fbx)
    rig = next(o for o in obs if o.type == 'ARMATURE')
    meshes = [o for o in obs if o.type == 'MESH']
    print('IMPORT', os.path.basename(fbx), 'fps', scn.render.fps, 'Objekte', [(o.name, o.type) for o in obs])
    print('KNOCHEN', len(rig.data.bones), [b.name for b in rig.data.bones])
    for o in meshes:
        print('NETZ', o.name, 'Dreiecke', tris([o]), 'Material', [(m.name, [n.image.name for n in m.node_tree.nodes if n.type == 'TEX_IMAGE' and n.image]) for m in o.data.materials if m and m.node_tree],
              'Formschlüssel', bool(o.data.shape_keys), 'Gruppen', len(o.vertex_groups))
    print('RIG Lage', tuple(round(x, 3) for x in rig.location), 'Drehung', tuple(round(math.degrees(x), 1) for x in rig.rotation_euler), 'Maßstab', tuple(round(x, 4) for x in rig.scale))
    # Fellkarten mit Alpha (T_GiantRatFur) trägt unser Shader nicht (deckend): weg
    for o in list(meshes):
        imgs = [n.image.name.lower() for m in o.data.materials if m and m.node_tree for n in m.node_tree.nodes if n.type == 'TEX_IMAGE' and n.image]
        if any('fur' in i for i in imgs) and not any('basecolor' in i for i in imgs):
            print('FELLKARTEN weg', o.name); meshes.remove(o); weg([o])
    # Lauf 114 lokal: die Fellkarten (Material GAINT_RAT_FUR, 964 Dreiecke) hängen im selben Netz wie der Körper; sie bekämen
    # sonst unsere Körpertextur und stünden als Platten ab. Ihre Flächen weg.
    import bmesh
    for o in meshes:
        fur = [i for i, m in enumerate(o.data.materials) if m and 'fur' in m.name.lower()]
        if not fur or len(fur) == len(o.data.materials): continue
        bm = bmesh.new(); bm.from_mesh(o.data)
        f = [x for x in bm.faces if x.material_index in fur]
        bmesh.ops.delete(bm, geom=f, context='FACES'); bm.to_mesh(o.data); bm.free()
        print('FELLKARTEN weg', o.name, len(f), 'Flächen')
    tri0 = tris(meshes)
    # ------------------------------------------------ Bewegungen aus den Einzeldateien
    akt = {}
    for q in QUELLEN:
        if q in akt: continue
        f = os.path.join(d, 'GIANT_RAT@%s.FBX' % q)
        if not os.path.exists(f):
            print('FEHLT', f); continue
        n = importiere(f); a = aktion_von(n)
        if a is None:
            print('KEINE BEWEGUNG in', os.path.basename(f), [(o.name, o.type) for o in n]); weg(n); continue
        a.use_fake_user = True; a.name = 'q_' + q
        akt[q] = a
        weg(n)
        print('BEWEGUNG', q, 'Bilder', tuple(round(x, 1) for x in a.frame_range), 'Kurven', len(a.fcurves) if hasattr(a, 'fcurves') else '-')
    if rig.animation_data and rig.animation_data.action:
        rig.animation_data.action = None
    # ------------------------------------------------ geduckt (Chef 26.10., 20:01): alle Bewegungen tiefer, Kopf lauernd
    # Größe aus der ungeduckten Quelle (sonst wüchse die geduckte Ratte auf die alte Höhe zurück)
    rig.animation_data_create()
    if 'idle' in akt:
        rig.animation_data.action = akt['idle']
        if slot(akt['idle']) is not None: rig.animation_data.action_slot = slot(akt['idle'])
    Pq = welt_netz(meshes, int(akt['idle'].frame_range[0]) if 'idle' in akt else 1)
    hoch_quelle = float(Pq[:, 2].max() - Pq[:, 2].min())
    rig.animation_data.action = None
    ohren(meshes, OHR)     # nach der Größe aus der Quelle (die Ohren sind ihr höchster Punkt; sonst wüchse die Ratte)
    if 'jumpBite' in akt: akt['q_biss'] = verstaerken(akt['jumpBite'], 'q_biss', BISS)
    if 'getHitFront' in akt: akt['q_treffer'] = verstaerken(akt['getHitFront'], 'q_treffer', TREFFER)
    if 'taunt' in akt: akt['q_drohen'] = verstaerken(akt['taunt'], 'q_drohen', DROHEN)
    if 'taunt' in akt: akt['q_lefzen'] = verstaerken(akt['taunt'], 'q_lefzen', RUTE_RUHIG)
    if 'death' in akt: akt['q_tod'] = verstaerken(akt['death'], 'q_tod', (('Tail', 0.9),))     # 0,4 und 0,65: Spitze am Ende im Boden
    if 'dodgeRight' in akt: akt['q_ausweichen'] = verstaerken(akt['dodgeRight'], 'q_ausweichen', RUTE_RUHIG)
    rutenspitze(rig, meshes)
    if TIEFE > 0:
        beine = {'q_treffer': akt.get('getHitFront'), 'q_drohen': akt.get('taunt')}
        quelle_akt = {q: a.copy() for q, a in beine.items() if q in akt and a is not None}     # vor dem Ducken der Quelle
        for q, a in akt.items():
            dr = q == 'q_drohen'
            k, g = ducken(rig, a, TIEFE + (DROHEN_TIEFE if dr else 0), NICKEN + (DROHEN_NICKEN if dr else 0), quelle_akt.get(q))
            print('GEDUCKT', q, 'um %.2f m, Anteil %.2f, Pfote höchstens %.3f m verrückt' % (TIEFE, k, g))
        rig.animation_data.action = None
    # Rute kürzer (und dünner) in jeder Bewegung: Maßstab am ersten Rutenknochen
    if RUTE != 1.0 and B + 'Tail' in rig.pose.bones:
        pt = rig.pose.bones[B + 'Tail']
        for q, a in akt.items():
            rig.animation_data.action = a
            if slot(a) is not None: rig.animation_data.action_slot = slot(a)
            pt.scale = (RUTE, RUTE, RUTE); pt.keyframe_insert('scale', frame=int(a.frame_range[0]))
        pt.scale = (1, 1, 1); rig.animation_data.action = None
        print('RUTE', RUTE)
    for q in ('q_tod', 'q_treffer'):
        if q in akt and B + 'Tail' in rig.pose.bones: rute_aus_dem_boden(rig, akt[q])
    # Messung je Bewegung (Welt, Quelle): Becken, Neigung, Pfoten, Rutenspitze, Kopfweg
    W = rig.matrix_world; pb = rig.pose.bones
    for q in ('jumpBite', 'q_biss', 'getHitFront', 'q_treffer', 'taunt', 'q_drohen', 'q_lefzen', 'death', 'q_tod', 'dodgeRight', 'q_ausweichen', 'idle'):
        if q not in akt: continue
        a = akt[q]; rig.animation_data.action = a
        if slot(a) is not None: rig.animation_data.action_slot = slot(a)
        R = []
        for f in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
            bpy.context.scene.frame_set(f)
            h = W @ pb[B + 'Head'].tail; c = W @ pb[B + 'Pelvis'].head; nk = W @ pb[B + 'Neck'].head
            R.append((h.x, h.y, h.z, c.z, math.degrees(math.atan2(nk.z - c.z, -(nk.y - c.y))),
                      min((W @ pb[B + s].head).z for s in ('L Hand', 'R Hand', 'L Foot', 'R Foot')), (W @ pb[B + 'Tail8'].head + (W @ pb[B + 'Tail8'].tail - W @ pb[B + 'Tail8'].head) * RUTE).z,
                      min((W @ pb[B + 'Tail%s' % i].head + (W @ pb[B + 'Tail%s' % i].tail - W @ pb[B + 'Tail%s' % i].head) * RUTE).z for i in ('', 1, 2, 3, 4, 5, 6, 7, 8))))
        R = np.array(R); dh = np.sqrt(((R[:, :3] - R[0, :3]) ** 2).sum(1))
        print('BAHN %-12s Nasenweg %.3f m (Bild +%d), Becken z %.2f..%.2f, Neigung %.0f..%.0f°, Pfoten z min %.3f, Rutenspitze z max %.2f, am Ende %.2f, Rute tiefster Punkt %.3f' % (
            q, dh.max(), dh.argmax(), R[:, 3].min(), R[:, 3].max(), R[:, 4].min(), R[:, 4].max(), R[:, 5].min(), R[:, 6].max(), R[-1, 6], R[:, 7].min()))
    rig.animation_data.action = None
    # ------------------------------------------------ Ausdünnen (vor dem Skelett im Stapel; Gewichte und UV bleiben)
    for o in meshes:
        if o.data.shape_keys:
            o.shape_key_clear()
        bpy.ops.object.select_all(action='DESELECT'); o.select_set(True); bpy.context.view_layer.objects.active = o
        m = o.modifiers.new('duenn', 'DECIMATE'); m.ratio = min(1.0, DREIECKE / max(1, tri0))
        bpy.ops.object.modifier_move_to_index(modifier='duenn', index=0)
        bpy.ops.object.modifier_apply(modifier='duenn')
    tri1 = tris(meshes)
    struppig_rand(meshes, np.random.default_rng(31))
    # ------------------------------------------------ Bemalung: je Netz unsere Textur statt der gekauften
    rng = np.random.default_rng(17)
    src = sorted(glob.glob(os.path.join(texdir, '*BaseColor*')))
    if not src:
        sys.exit('BaseColor fehlt in %s' % texdir)
    masken = uv_masken(meshes)
    bild = bpy.data.images.load(bemalung(src[0], fell, rng, masken, fellstriche(meshes, np.random.default_rng(23), masken[1])))
    for o in meshes:
        mat = bpy.data.materials.new('%s-%s' % (ID, fell)); mat.use_nodes = True
        bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
        im = mat.node_tree.nodes.new('ShaderNodeTexImage'); im.image = bild
        mat.node_tree.links.new(im.outputs['Color'], bs.inputs['Base Color'])
        o.data.materials.clear(); o.data.materials.append(mat)
    # ------------------------------------------------ NLA-Spuren unter unseren Namen; Hocke = Ausholstellung aus jumpBite
    rig.animation_data_create()
    INFO = {'fps': scn.render.fps, 'fell': fell, 'dreiecke': tri1, 'dreiecke_gekauft': tri0, 'quelle': 'Protofactor Giant Rat (gekauft, 348.12c)'}
    def spur(nm, a, start=None, ende=None):
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'): st.action_slot = slot(a2)
        if start is not None:
            st.action_frame_start, st.action_frame_end = start, ende
        INFO[nm] = round((st.action_frame_end - st.action_frame_start) / scn.render.fps, 3)
        return st
    for nm, q, _ in NAMEN:
        if q in akt: spur(nm, akt[q])
    for nm, q in WEITERE:
        if q in akt: spur(nm, akt[q])
    # ------------------------------------------------ Größe, Blick, Boden: zwei Hüllen um das Skelett (Drehung innen, Maßstab außen in Weltachsen)
    rig.animation_data.action = akt.get('idle');
    if slot(akt.get('idle')) is not None: rig.animation_data.action_slot = slot(akt['idle'])
    f0 = int(akt['idle'].frame_range[0]) if 'idle' in akt else 1
    P = welt_netz(meshes, f0)
    lo, hi = P.min(0), P.max(0)
    print('MASS gekauft (Welt, Stehen): x %.3f y %.3f z %.3f, Boden %.3f' % tuple(list(hi - lo) + [lo[2]]))
    # Kopf: Knochen mit „head“ im Namen; Blick = von der Mitte zum Kopf längs der langen waagerechten Achse
    kb = [b for b in rig.pose.bones if 'head' in b.name.lower()]
    lang = 0 if (hi - lo)[0] > (hi - lo)[1] else 1
    mitte = (lo + hi) / 2
    if kb:
        kp = rig.matrix_world @ kb[0].head
        vor = np.sign(kp[lang] - mitte[lang]) or 1.0
    else:
        vor = 1.0; print('KOPF nicht gefunden (Knochen „head“)')
    # gewünscht: Kopf nach -Y (glTF +Z)
    blick = Vector((vor, 0, 0)) if lang == 0 else Vector((0, vor, 0))
    dreh = blick.to_2d().angle_signed(Vector((0, -1))) if blick.length else 0.0
    innen = bpy.data.objects.new('Ratte_Blick', None); scn.collection.objects.link(innen)
    aussen = bpy.data.objects.new('Ratte', None); scn.collection.objects.link(aussen)
    innen.parent = aussen
    innen.rotation_euler = (0, 0, -dreh)
    rig.parent = innen
    bpy.context.view_layer.update()
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    ziel = HOEHE if HOEHE > 0 else 0.67
    s = ziel / max(hoch_quelle, 1e-4) * GROSS[0]
    aussen.scale = (s * GROSS[1], s, s)
    aussen.location = (-(lo[0] + hi[0]) / 2 * s * GROSS[1], -(lo[1] + hi[1]) / 2 * s, -lo[2] * s)
    bpy.context.view_layer.update()
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    kp = rig.matrix_world @ kb[0].head if kb else None
    print('MASS neu: breit %.3f lang %.3f hoch %.3f, Boden %.3f, Kopf %s, Drehung %.0f°, Maßstab %.4f' % (
        hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2], tuple(round(x, 2) for x in kp) if kp else '-', math.degrees(dreh), s))
    INFO['hoehe_m'] = round(float(hi[2] - lo[2]), 3); INFO['laenge_m'] = round(float(hi[1] - lo[1]), 3)
    # Hocke: Kampfort zeigt sie vor dem Anspringen, in Schleife (figur.gd). Bis Runde 2: Bild 1–2 aus jumpBite, die Quelle steigt
    # dort schon (Becken 0,52 -> 0,95 m) -> in Schleife zitterte die Ratte 30-mal je Sekunde (Chef 20:15, Lauf 118: „springt es
    # bei der Kaufratte beim Hocken“). Jetzt: erstes Bild von jumpBite festgehalten (alle Schlüssel gleich, 1 s) und HOCKE m tiefer.
    if 'jumpBite' in akt:
        h = akt['jumpBite'].copy(); h.name = 'q_hocke'; h.use_fake_user = True
        a0 = h.frame_range[0]
        for lay in h.layers:
            for st in lay.strips:
                for cb in st.channelbags:
                    for fc in cb.fcurves:
                        v = fc.evaluate(a0)
                        for kp in fc.keyframe_points:
                            kp.co[1] = v; kp.handle_left[1] = v; kp.handle_right[1] = v
        rig.animation_data.action = h
        if slot(h) is not None: rig.animation_data.action_slot = slot(h)
        h0 = welt_netz(meshes, int(a0))[:, 2].max()
        if HOCKE > 0: ducken(rig, h, HOCKE, 0.0)
        rig.animation_data.action = h
        h1 = welt_netz(meshes, int(a0))[:, 2].max(); h2 = welt_netz(meshes, int(a0) + 15)[:, 2].max()
        print('HOCKE gehalten, Höhe %.3f -> %.3f (Bild +15: %.3f), Stehen %.3f' % (h0, h1, h2, hi[2]))
        spur('Hocke', h, int(a0), int(a0) + 30)
    rig.animation_data.action = None
    # Gehtempo aus walk_RM (Wurzelweg je Sekunde), sonst wie ratte.py
    INFO['gehen_m_je_s'] = None
    # Knochen unter unseren Namen (kopfdreh.gd BONES, figur.gd PAW_BONES); Blender zieht Gruppen und NLA-Spuren mit
    for alt, neu in UMBENENNEN.items():
        if alt in rig.data.bones: rig.data.bones[alt].name = neu
        else: print('FEHLT Knochen', alt)
    bpy.context.view_layer.update()
    print('UMBENANNT', {n: (round((rig.matrix_world @ rig.data.bones[n].head_local).z, 3), round((rig.matrix_world @ rig.data.bones[n].tail_local).z, 3),
                            round(rig.data.bones[n].length * s, 3)) for n in UMBENENNEN.values() if n in rig.data.bones})
    # ------------------------------------------------ Export
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, innen, rig] + meshes: o.select_set(True)
    path = os.path.join(OUT, '%s-%s.glb' % (ID, fell))
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False, export_image_format='JPEG',
                              export_jpeg_quality=88)
    INFO['sekunden_bau'] = round(time.time() - T0, 1)
    print('GLB', path, os.path.getsize(path), INFO)
    return INFO


if __name__ == '__main__':
    names = [os.environ['FELL']] if os.environ.get('FELL') else list(COATS)
    info = {}
    for n in names:
        info[n] = baue(n)
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1)
    print('KAUFRATTE FERTIG %.1f s' % (time.time() - T0))
