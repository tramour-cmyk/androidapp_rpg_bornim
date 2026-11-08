# 506 Skelett (Wochenziel 03.11. Reihe 2; Kauf 348.12c A, Chef 03.11., 15:40: „506 baut die Untoten aus dem Kauf, nicht auf dem
# CC0-Menschen“): gekaufter Protofactor „Skeleton Knight“ (privates Repo, $KAUF, nie hierher und nie als Artefakt) nach
# `LISTE-FIGUREN.md` „Skelett“ (348.11 b, gebilligt Chef 25.10., 23:33):
#   1 Größe 160–185 cm (hier 176 cm Scheitel, im Kampfort 1,32-fach wie jeder Zweibeiner, kampfort.gd _foe_scale)
#   2 menschlich, nur Knochen, sehr dünn (der Brustpanzer des Kaufs bleibt weg: MonsterKit.kt „the dead keep only helm and weapon“)
#   3 Schädel mit Kiefer und Zahnreihen, schwarze Augenhöhlen mit je einem schwachen Glutpunkt (Eckfarbe mit Alpha 0, toon.gdshader glut)
#   4 vergilbter, fleckiger Knochen; drei Kits, alles rostig: Kurzschwert und Helm; Kurzschwert und Schild; Speer und Helm
#     (MonsterKit.kt skeleton). Der Kauf hat keinen Speer: Speer aus Ankers „Low Poly Medieval Weapons“ (CC0, privat wie Kroggs
#     Morgenstern), längs der Klinge des Kaufschwerts in die rechte Faust gelegt
#   5 aufrecht und steif, Kopf leicht gedreht (kopfdreh.gd über die Knochen „hals“, „kopf“)
# Bemalung wie bei den Kauftieren: aus dem Kaufbild nur die Helligkeit, Farben und Flecken sind unsere.
# Bewegungen unter unseren Namen (figur.gd, Zweibeiner wie Grak und Krogg): Stehen, Gehen, Rennen, Hieb, Treffer, Tod, Abwehr,
# Ausweichen, Ausweichen links, Auferstehen (aus dem Boden, für die Karte); Wurzelweg aus den _RM-Dateien.
# Aufruf: KAUF=<ordner> OUT=<ordner> [KIT=schwert] python -I kaufskelett.py
#         -> <OUT>/skeleton-<kit>.glb, skeleton-info.json
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
from mathutils import Vector, Matrix
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, importiere

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'skeleton'
HOEHE = float(os.environ.get('HOEHE', '1.76'))          # Liste 1: 160–185 cm, Scheitel des Schädels (ohne Helm)
KOERPER_DREIECKE = int(os.environ.get('DREIECKE', '4200'))   # Modellregel 7: ganze Figur unter 6.000 (Kauf: Körper 10.634)
TEX = 1024
FPS = 30
SPEER_M = float(os.environ.get('SPEER_M', '1.75'))      # Speer etwa so lang wie der Träger
SPEER_GRIFF = 0.42                                       # Faust bei 42 % der Länge von hinten
RNG = np.random.default_rng(506)
K = 'SkeletonKnight_ '
HAND_R, HAND_L, KOPF, HALS = K + 'R Hand', K + 'L Hand', K + 'Head', K + 'Neck1'
UMBENENNEN = {HALS: 'hals', KOPF: 'kopf'}               # kopfdreh.gd: Kopf zum Ziel (Liste 5 „Kopf leicht gedreht“)

# Liste 4: drei Kits; Knochenton je Kit etwas anders (Abwechslung), alle vergilbt und fleckig
KITS = {
    'schwert': {'teile': ['SM_Sword', 'SM_Helmet'], 'knochen': (0xB8A57E, 0x4A3E2C, 0x6E5434)},
    'schild': {'teile': ['SM_Sword', 'SM_Shield'], 'knochen': (0xA89C84, 0x423A30, 0x5E4E3A)},
    'speer': {'teile': ['SPEER', 'SM_Helmet'], 'knochen': (0xB09A70, 0x463A28, 0x705030)},
}
WEG_KAUF = ['SK_Armor', 'SM_2HandedSword', 'WEAPON_BONE']     # Brustpanzer (Liste 2), Zweihänder, Knochenkeule
EISEN, ROST, ROST_TIEF = 0x4A4846, 0x7A4424, 0x3A2214
HOLZ = 0x3E2E22
GLUT = 0xC8501C            # Liste 3: schwacher Glutpunkt; leuchtet nur über glut (figur.gd), sonst dunkel

# unser Name <- Kaufdatei (ohne „SkeletonKnight@“). Hieb: Attack3 holt über den Kopf aus und schlägt vorn in Brusthöhe zu (Spitze
# 1,2 m vor, 1,0–1,2 m hoch, 1,03 s, Ausholen länger als der Schlag); Attack1 und 2 schwingen quer in Hüfthöhe bzw. drehen sich ganz
NAMEN = [('Stehen', 'Idle1Handed'), ('Gehen', '1HandedWalk'), ('Rennen', '1HandedRun'), ('Hieb', '1HandedAttack3'),
         ('Treffer', '1HandedGetHit'), ('Tod', '1HandedDeath'), ('Abwehr', 'ShieldBlock'), ('Ausweichen', '1HandedStrafeR'),
         ('Ausweichen links', '1HandedStrafeL'), ('Auferstehen', 'ComeOutOfTheGround1Handed_A')]
WEGE = [('Gehen', '1HandedWalk'), ('Rennen', '1HandedRun'), ('Ausweichen', '1HandedStrafeR'), ('Ausweichen links', '1HandedStrafeL')]
IM_BODEN_ERLAUBT = ('Auferstehen',)     # steigt aus dem Boden
# Im Tod liegt der Kauf bis 31 cm im Boden (gemessen): gehoben wird nach Körper und Helm; die Waffe fällt mit der Hand und darf
# dabei den Boden berühren (Lauf 1: nach dem Speer gehoben schwebte der Liegende 41 cm hoch); ihre Tiefe steht in „waffe_tief_m“
NUR_KOERPER = ('Tod',)
WAFFEN = ('SM_Sword', 'SM_Shield', 'SPEER')


def finde(name):
    t = sorted(glob.glob(os.path.join(KAUF, '**', name), recursive=True))
    return t[0] if t else None


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    f = finde('SK_SkeletonKnight.FBX')
    if not f:
        sys.exit('SK_SkeletonKnight.FBX nicht gefunden unter %s' % KAUF)
    d = os.path.dirname(f)
    return f, d, os.path.join(os.path.dirname(d), 'Textures')


def bild(pfad, kante=TEX):
    from PIL import Image
    im = Image.open(pfad).convert('RGB')
    if im.size[0] != kante:
        im = im.resize((kante, kante), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def rauschen(n, glatt):
    from PIL import Image, ImageFilter
    r = RNG.random((TEX // n, TEX // n)).astype(np.float32)
    im = Image.fromarray((r * 255).astype(np.uint8)).resize((TEX, TEX), Image.BICUBIC).filter(ImageFilter.GaussianBlur(glatt))
    a = np.asarray(im, np.float32) / 255.0
    return (a - a.min()) / max(a.max() - a.min(), 1e-4)


def knochen_bild(tex_dir, ton):
    """Liste 4: vergilbter, fleckiger Knochen. Helligkeit des Kaufbilds (Risse, Nähte, Höhlen), Farbe unsere."""
    a = bild(os.path.join(tex_dir, 'T_SkeletonKnight_Albedo.jpg'))
    lum = a.mean(2)
    med = float(np.median(lum[lum > 0.03]))
    t = np.clip(lum / max(med, 1e-3), 0.15, 1.6)[..., None]
    hell, tief, fleck = (np.array(lin(c)) for c in ton)
    b = tief + (hell - tief) * np.clip((t - 0.25) / 1.0, 0, 1) ** 1.1
    f = np.clip((rauschen(10, 6) - 0.52) * 3.2, 0, 1)[..., None] * 0.55 + np.clip((rauschen(40, 1.5) - 0.6) * 3, 0, 1)[..., None] * 0.25
    b = b * (1 - f) + fleck * t * f
    return np.clip(srgb(b * (0.92 + 0.12 * rauschen(64, 0.8)[..., None])), 0, 1)


def rost_bild(pfad, holz=False):
    """Liste 4: alles rostig. Helligkeit des Kaufbilds, darüber Eisen mit Rostflecken (Schild: Holz bleibt dunkles Holz)."""
    a = bild(pfad)
    lum = a.mean(2)
    med = float(np.median(lum[lum > 0.03]))
    t = np.clip(lum / max(med, 1e-3), 0.2, 1.7)[..., None]
    sat = (a.max(2) - a.min(2))[..., None]
    eisen = np.array(lin(EISEN)) * t
    m = np.clip((rauschen(12, 4) - 0.35) * 2.2, 0, 1)[..., None] * 0.8 + np.clip((rauschen(48, 1) - 0.55) * 3, 0, 1)[..., None] * 0.3
    rost = (np.array(lin(ROST)) * (1 - 0.5 * rauschen(30, 1)[..., None]) + np.array(lin(ROST_TIEF)) * 0.5 * rauschen(30, 1)[..., None]) * t
    b = eisen * (1 - np.clip(m, 0, 1)) + rost * np.clip(m, 0, 1)
    if holz:     # warme, satte Stellen des Kaufbilds sind Holz: dunkel und alt
        w = np.clip((sat - 0.12) * 5, 0, 1) * (a[..., 0:1] > a[..., 2:3])
        b = b * (1 - w) + np.array(lin(HOLZ)) * t * w
    return np.clip(srgb(b), 0, 1)


def material(o, png, name):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    ti = mat.node_tree.nodes.new('ShaderNodeTexImage')
    ti.image = bpy.data.images.load(png, check_existing=False)
    mat.node_tree.links.new(ti.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = 0.85
    o.data.materials.clear()
    o.data.materials.append(mat)


def speichere(b, name):
    from PIL import Image
    png = os.path.join(OUT, 'tex_skelett_%s.png' % name)
    Image.fromarray((b * 255).astype(np.uint8)).save(png)
    return png


def eckfarbe(o, farbe_je_ecke):
    """Eckfarben (Alpha 0 = glüht, toon.gdshader) als aktive Farbschicht; farbe_je_ecke(i_material) -> (r, g, b, a) linear."""
    ca = o.data.color_attributes.new('Col', 'FLOAT_COLOR', 'CORNER')
    for p in o.data.polygons:
        c = farbe_je_ecke(p.material_index)
        for li in p.loop_indices:
            ca.data[li].color = c
    o.data.color_attributes.active_color = ca


def an_knochen(o, rig, knochen):
    """Starr an einen Knochen hängen, Lage in der Welt bleibt."""
    M = o.matrix_world.copy()
    o.parent = rig
    o.parent_type = 'BONE'
    o.parent_bone = knochen
    bpy.context.view_layer.update()
    o.matrix_world = M


def speer(rig, schwert):
    """Kit 3 (Liste 4 „Speer und Helm“): Ankers Speer (CC0) längs der Klinge des Kaufschwerts, Faust bei SPEER_GRIFF."""
    f = finde('Spear.fbx')
    if not f:
        print('FEHLT Speer (Anker Low Poly Medieval Weapons), Kit speer mit Schwert')
        return None
    teile = importiere(f)
    sp = next(o for o in teile if o.type == 'MESH')
    for o in teile:
        if o is not sp:
            entferne([o])
    sp.parent = None
    bpy.context.view_layer.update()
    # Achse und Faust aus dem Schwert (Ruhelage): Griffende am nächsten zur Hand, Klinge in Richtung der fernsten Ecke
    S = np.array([schwert.matrix_world @ v.co for v in schwert.data.vertices])
    h = np.array(rig.matrix_world @ rig.pose.bones[HAND_R].head)
    d = np.linalg.norm(S - h, axis=1)
    spitze = S[d.argmax()]
    c = S - S.mean(0)
    ax = np.linalg.svd(c, full_matrices=False)[2][0]
    if np.dot(spitze - h, ax) < 0:
        ax = -ax
    proj = (S - h) @ ax
    griff = h + ax * float(np.percentile(proj[proj < np.percentile(proj, 25)], 50))     # Mitte des Hefts
    P = np.array([v.co[:] for v in sp.data.vertices])
    lang = P[:, 2].max() - P[:, 2].min()
    s = SPEER_M / lang
    z0 = P[:, 2].min() + lang * SPEER_GRIFF
    R = Vector((0, 0, 1)).rotation_difference(Vector(ax.tolist())).to_matrix().to_4x4()
    sp.matrix_world = Matrix.Translation(Vector(griff.tolist())) @ R @ Matrix.Scale(s, 4) @ Matrix.Translation((0, 0, -z0))
    bpy.context.view_layer.update()
    bpy.ops.object.select_all(action='DESELECT')
    sp.select_set(True); bpy.context.view_layer.objects.active = sp
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Farben: Spitze Eisen mit Rost, Schaft altes Holz (Material 0 grau = Eisen, 1 braun = Holz; Anker ohne Bild)
    namen = [m.name.lower() for m in sp.data.materials]
    def farbe(i):
        holz = i < len(namen) and 'brown' in namen[i]
        c = lin(HOLZ) * 1.15 if holz else lin(EISEN) * 0.55 + lin(ROST) * 0.45
        return (float(c[0]), float(c[1]), float(c[2]), 1.0)
    eckfarbe(sp, farbe)
    sp.data.materials.clear()
    m = bpy.data.materials.new('Speer'); m.use_nodes = True
    sp.data.materials.append(m)
    sp.name = 'SPEER'
    an_knochen(sp, rig, HAND_R)
    print('SPEER %.2f m, Faust %.2f m von hinten, Achse %s' % (SPEER_M, SPEER_M * SPEER_GRIFF, np.round(ax, 2)))
    return sp


def augen(rig, koerper):
    """Liste 3: schwarze Augenhöhlen mit je einem schwachen Glutpunkt. Lage gemessen am Schädel (Ruhelage): Ecken am Kopf,
    die Höhlen sind die tiefsten Stellen der Vorderseite links und rechts der Mitte in Augenhöhe."""
    gi = koerper.vertex_groups[KOPF].index
    P = []
    for v in koerper.data.vertices:
        if any(g.group == gi and g.weight > 0.6 for g in v.groups):
            P.append((koerper.matrix_world @ v.co)[:])
    P = np.array(P)
    zlo, zhi = P[:, 2].min(), P[:, 2].max()
    hoch = zhi - zlo
    vorn = P[:, 1].min()
    band = P[(P[:, 2] > zlo + 0.45 * hoch) & (P[:, 2] < zlo + 0.75 * hoch) & (P[:, 1] < vorn + 0.06)]
    punkte = []
    for seite in (1, -1):
        q = band[(band[:, 0] * seite > 0.012) & (band[:, 0] * seite < 0.06)]
        if not len(q):
            continue
        # Höhle: im Band die Ecken, die am weitesten hinten liegen, aber noch zur Vorderseite gehören
        tief = q[q[:, 1] > np.percentile(q[:, 1], 70)]
        m = tief.mean(0)
        punkte.append(m)
    if len(punkte) == 2:     # beide Höhlen gleich: Mittel der Beträge (gemessen 3,7 und 3,2 cm neben der Mitte)
        x, y, z = (abs(punkte[0][0]) + abs(punkte[1][0])) / 2, (punkte[0][1] + punkte[1][1]) / 2, (punkte[0][2] + punkte[1][2]) / 2
        punkte = [np.array([x, y, z]), np.array([-x, y, z])]
    obs = []
    for i, m in enumerate(punkte):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=5, radius=0.0075, location=(float(m[0]), float(m[1]) - 0.004, float(m[2])))
        o = bpy.context.active_object
        o.name = 'Glut%d' % i
        c = lin(GLUT)
        eckfarbe(o, lambda _i, c=c: (float(c[0]), float(c[1]), float(c[2]), 0.0))
        mt = bpy.data.materials.new('Glut'); mt.use_nodes = True
        o.data.materials.append(mt)
        an_knochen(o, rig, KOPF)
        obs.append(o)
    print('AUGEN Glutpunkte bei %s (Schädel %.3f–%.3f m hoch, vorn %.3f)' % ([np.round(p, 3).tolist() for p in punkte], zlo, zhi, vorn))
    return obs


def aktionen(d, rig):
    akt = {}
    for nm, q in NAMEN:
        f = os.path.join(d, 'SkeletonKnight@%s.FBX' % q)
        if not os.path.exists(f):
            print('FEHLT Bewegung', q); continue
        neu = importiere(f)
        a = aktion_von(neu)
        if a is None:
            entferne(neu); print('FEHLT Aktion', q); continue
        a.use_fake_user = True
        akt[nm] = a
        entferne(neu)
    return akt


def wurzelweg(d, s):
    """Wurzelweg je Bewegung: Ort des Knochens „root“ aus der _RM-Datei minus dem der Datei ohne Weg, in unseren Metern."""
    wege = {}
    for nm, q in WEGE:
        bahn = []
        for v in (q, q + '_RM'):
            f = os.path.join(d, 'SkeletonKnight@%s.FBX' % v)
            if not os.path.exists(f):
                break
            neu = importiere(f)
            r = next((o for o in neu if o.type == 'ARMATURE'), None)
            a = aktion_von(neu)
            if r is None or a is None or 'root' not in r.pose.bones:
                entferne(neu); break
            pb = r.pose.bones['root']
            pts = []
            for fr in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
                bpy.context.scene.frame_set(fr)
                pts.append((r.matrix_world @ pb.matrix).translation.copy())
            bahn.append(pts)
            entferne(neu)
        if len(bahn) < 2:
            print('WEG fehlt', q); continue
        k = min(len(bahn[0]), len(bahn[1]))
        w = []
        for i in range(k):
            p = (bahn[1][i] - bahn[0][i]) - (bahn[1][0] - bahn[0][0])
            w.append([round(p.x * s, 4), round(-p.y * s, 4)])     # Blender −Y vorn = glTF +Z
        wege[nm] = w
        print('WEG %s (%s): %d Bilder, Ende x %.3f z %.3f m, %.2f m/s' % (
            nm, q, k, w[-1][0], w[-1][1], math.hypot(w[-1][0], w[-1][1]) / max((k - 1) / FPS, 1e-3)))
    return wege


def baue(kit_name):
    kit = KITS[kit_name]
    fbx, d, tex_dir = quelle()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene
    scn.render.fps = FPS
    teile = importiere(fbx)
    rig = next(o for o in teile if o.type == 'ARMATURE')
    netze = {o.name: o for o in teile if o.type == 'MESH'}
    koerper = netze['skeleton_knight']
    INFO = {'waffen': [], 'geruest': 'kauf', 'kit': kit_name}
    # Ausrüstung des Kits; der Rest des Kaufs bleibt weg
    for n, o in list(netze.items()):
        if n == 'skeleton_knight':
            continue
        if n in WEG_KAUF or (n not in kit['teile'] and not (n == 'SM_Sword' and 'SPEER' in kit['teile'])):
            entferne([o]); netze.pop(n)
    if 'SPEER' in kit['teile']:
        sp = speer(rig, netze['SM_Sword'])
        if sp is not None:
            entferne([netze.pop('SM_Sword')])
            netze['SPEER'] = sp
    vorher = tris([koerper])
    if vorher > KOERPER_DREIECKE:
        mod = koerper.modifiers.new('weniger', 'DECIMATE')
        mod.ratio = KOERPER_DREIECKE / vorher
        bpy.context.view_layer.objects.active = koerper
        bpy.ops.object.modifier_apply(modifier=mod.name)
    print('DREIECKE Körper %d -> %d' % (vorher, tris([koerper])))
    # Bemalung
    material(koerper, speichere(knochen_bild(tex_dir, kit['knochen']), 'knochen-' + kit_name), 'Knochen')
    for n, bildname, holz in (('SM_Helmet', 'T_Helmet_Albedo.jpg', False), ('SM_Sword', 'T_1HandedSword_Albedo.jpg', False),
                              ('SM_Shield', 'T_Shield_Albedo.jpg', True)):
        if n in netze:
            material(netze[n], speichere(rost_bild(os.path.join(tex_dir, bildname), holz), n.lower() + '-' + kit_name), n)
    glut = augen(rig, koerper)
    netze.update({o.name: o for o in glut})
    # Bewegungen
    rig.animation_data_create()
    akt = aktionen(d, rig)
    if 'Stehen' not in akt or 'Gehen' not in akt or 'Hieb' not in akt:
        sys.exit('Stehen, Gehen oder Hieb fehlt im Kauf')
    rig.animation_data.action = akt['Stehen']
    if slot(akt['Stehen']) is not None:
        rig.animation_data.action_slot = slot(akt['Stehen'])
    f0 = int(akt['Stehen'].frame_range[0])
    P = welt_netz([koerper], f0)
    lo, hi = P.min(0), P.max(0)
    print('MASS gekauft (Stehen): breit %.3f tief %.3f hoch %.3f, Boden %.3f' % (hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2]))
    s = HOEHE / max(hi[2] - lo[2], 1e-4)
    aussen = bpy.data.objects.new('Skelett', None)
    scn.collection.objects.link(aussen)
    rig.parent = aussen
    bpy.context.view_layer.update()
    aussen.scale = (s, s, s)
    bpy.context.view_layer.update()
    P = welt_netz([koerper], f0)
    lo, hi = P.min(0), P.max(0)
    aussen.location = (-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2])
    bpy.context.view_layer.update()
    P = welt_netz([koerper], f0)
    lo, hi = P.min(0), P.max(0)
    print('MASS neu (Stehen): breit %.3f tief %.3f hoch %.3f, Boden %.3f, Maßstab %.4f' % (hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2], s))
    INFO['groesse_cm'] = round(float(hi[2] - lo[2]) * 100, 1)
    INFO['breite_m'] = round(float(hi[0] - lo[0]), 3)
    INFO['ursprung'] = [round(float(x), 4) for x in aussen.location]
    # Wurzelweg
    wege = wurzelweg(d, s)
    INFO['weg'] = wege
    INFO['fps'] = FPS
    alle = list(netze.values())

    def spur(nm, a):
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'):
            st.action_slot = slot(a2)
        INFO.setdefault('zeiten', {})[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
        return a2
    gespielt = {nm: spur(nm, a) for nm, a in akt.items()}
    for tr in rig.animation_data.nla_tracks:     # beim Messen und Heben nur die eine Bewegung, nicht die Spuren darunter
        tr.mute = True
    # Kein Teil im Boden (figur.gd setzt die Figur auf 0): Ort des Gerüsts je Bild heben, außer beim Auferstehen
    gehoben, tief, waffe_tief = {}, {}, {}
    koerper_teile = [o for n, o in netze.items() if n not in WAFFEN]
    waffen_teile = [o for n, o in netze.items() if n in WAFFEN]
    for nm, a in gespielt.items():
        basis = koerper_teile if nm in NUR_KOERPER else alle
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
        if nm not in IM_BODEN_ERLAUBT:
            rig.location.z = 0.0
            for f in range(r0, r1 + 1):
                rig.keyframe_insert('location', frame=f)
            hoch = 0.0
            for _ in range(4):
                rest = 0.0
                for f in range(r0, r1 + 1):
                    z = float(welt_netz(basis, f)[:, 2].min())
                    if z < -0.002:
                        bpy.context.scene.frame_set(f)
                        rig.location.z = rig.location.z - z / max(s, 1e-6)
                        rig.keyframe_insert('location', frame=f)
                        hoch = max(hoch, rig.location.z * s)
                        rest = min(rest, z)
                if rest > -0.002:
                    break
            if hoch > 0.0:
                gehoben[nm] = round(float(hoch), 3)
        tief[nm] = round(min(float(welt_netz(basis, f)[:, 2].min()) for f in range(r0, r1 + 1)), 3)
        if waffen_teile:
            waffe_tief[nm] = round(min(float(welt_netz(waffen_teile, f)[:, 2].min()) for f in range(r0, r1 + 1)), 3)
    rig.animation_data.action = None
    rig.location.z = 0.0
    INFO['gehoben_m'] = gehoben
    INFO['tiefster_punkt_m'] = tief
    INFO['waffe_tief_m'] = waffe_tief
    print('BODEN gehoben (m): %s; tiefster Punkt je Bewegung: %s; Waffe: %s' % (gehoben, tief, waffe_tief))
    # Aufschlag des Hiebs (figur.gd „hieb“): Bild, in dem die Spitze der Waffe am weitesten vorn ist (vorn = −Y)
    waffe = netze.get('SPEER') or netze.get('SM_Sword')
    if waffe is not None:
        h = rig.matrix_world @ rig.pose.bones[HAND_R].head
        V = [waffe.matrix_world @ v.co for v in waffe.data.vertices]
        ispitze = int(np.argmax([(p - h).length for p in V]))
        a = gespielt['Hieb']
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        best = None
        r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
        for f in range(r0, r1 + 1):
            scn.frame_set(f); bpy.context.view_layer.update()
            kp = waffe.matrix_world @ waffe.data.vertices[ispitze].co
            if best is None or -kp.y > best[1]:
                best = (f, -kp.y, kp)
        f_auf, _, kp = best
        INFO['hieb'] = [round(math.hypot(kp.x, kp.y), 3), round((f_auf - r0) / FPS, 3), round(-math.degrees(math.atan2(kp.x, -kp.y)), 1), round(kp.z, 2)]
        print('HIEB Aufschlag Bild %d (%.2f s von %.2f s): Spitze %.2f m vor dem Ursprung, %.0f Grad, %.2f m hoch' % (
            f_auf, (f_auf - r0) / FPS, (r1 - r0) / FPS, INFO['hieb'][0], -INFO['hieb'][2], INFO['hieb'][3]))
        rig.animation_data.action = None
    for tr in rig.animation_data.nla_tracks:
        tr.mute = False
    # Knochen umbenennen (kopfdreh.gd); Blender zieht die Pfade der Spuren mit
    for alt, neu in UMBENENNEN.items():
        if alt in rig.data.bones:
            rig.data.bones[alt].name = neu
    INFO['dreiecke'] = tris(alle)
    INFO['teile'] = sorted(netze)
    print('DREIECKE gesamt %d (%s)' % (INFO['dreiecke'], ', '.join('%s %d' % (n, tris([o])) for n, o in sorted(netze.items()))))
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, rig] + alle:
        o.select_set(True)
    pfad = os.path.join(OUT, '%s-%s.glb' % (ID, kit_name))
    bpy.ops.export_scene.gltf(filepath=pfad, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False,
                              export_image_format='JPEG', export_jpeg_quality=88, export_vertex_color='ACTIVE',
                              export_all_vertex_colors=False)
    INFO['sekunden_bau'] = round(time.time() - T0, 1)
    print('GLB %s %d Bytes' % (pfad, os.path.getsize(pfad)))
    return INFO


if __name__ == '__main__':
    namen = [os.environ['KIT']] if os.environ.get('KIT') else list(KITS)
    info = {}
    for n in namen:
        info[n] = baue(n)
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1, ensure_ascii=False)
    print('KAUFSKELETT FERTIG %.1f s, Kits %s' % (time.time() - T0, ', '.join(namen)))
