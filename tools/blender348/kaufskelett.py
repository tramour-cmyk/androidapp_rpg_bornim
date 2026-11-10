# 506 Skelett (Wochenziel 03.11. Reihe 2; Kauf 348.12c A, Chef 03.11., 15:40: „506 baut die Untoten aus dem Kauf, nicht auf dem
# CC0-Menschen“): gekaufter Protofactor „Skeleton Knight“ (privates Repo, $KAUF, nie hierher und nie als Artefakt) nach
# `LISTE-FIGUREN.md` „Skelett“ (348.11 b, gebilligt Chef 25.10., 23:33):
#   1 Größe 160–185 cm (hier 172–179 cm Scheitel je Statur, im Kampfort 1,32-fach wie jeder Zweibeiner, kampfort.gd _foe_scale)
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
from mathutils import Vector, Matrix, Quaternion
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, importiere

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'skeleton'
KOERPER_DREIECKE = int(os.environ.get('DREIECKE', '4200'))   # Modellregel 7: ganze Figur unter 6.000 (Kauf: Körper 10.634)
TEX = 1024
FPS = 30
SPEER_M = float(os.environ.get('SPEER_M', '1.75'))      # Speer etwa so lang wie der Träger
SPEER_GRIFF = 0.42                                       # Faust bei 42 % der Länge von hinten
# Helfer 08.11., 12:55 (Liste 4 „Kits kaum unterscheidbar“): Speer 1–2 px dünn ohne sichtbare Spitze, Schild schmal hochkant. Der
# Speer wird quer zur Achse dicker (Schaft und Spitze), der Schild größer um seine Mitte
SPEER_DICKE = float(os.environ.get('SPEER_DICKE', '1.8'))
SCHILD_GROESSE = float(os.environ.get('SCHILD_GROESSE', '1.3'))
RNG = np.random.default_rng(506)
K = 'SkeletonKnight_ '
HAND_R, HAND_L, KOPF, HALS = K + 'R Hand', K + 'L Hand', K + 'Head', K + 'Neck1'
UMBENENNEN = {HALS: 'hals', KOPF: 'kopf'}               # kopfdreh.gd: Kopf zum Ziel (Liste 5 „Kopf leicht gedreht“)

# Liste 4: drei Kits; Knochenton je Kit etwas anders (Abwechslung), alle vergilbt und fleckig
KITS = {
    'schwert': {'teile': ['SM_Sword', 'SM_Helmet'], 'knochen': (0xB8A57E, 0x4A3E2C, 0x6E5434), 'statur': 'mittel'},
    'schild': {'teile': ['SM_Sword', 'SM_Shield'], 'knochen': (0xA89C84, 0x423A30, 0x5E4E3A), 'statur': 'kraeftig'},
    'speer': {'teile': ['SPEER', 'SM_Helmet'], 'knochen': (0xB09A70, 0x463A28, 0x705030), 'statur': 'schlank'},
}
# LISTE-FIGUREN (348.11 b): jeder Untote zufällig schlank, mittel oder kräftig; hier je Kit eine Statur (wie goblin.py): Knochen
# dicker oder dünner um ihre Achse (Schädel und Hals nicht, der Helm sitzt starr), dazu etwas kleiner oder größer
STATUR = {'schlank': (0.86, 1.79), 'mittel': (1.0, 1.76), 'kraeftig': (1.16, 1.72)}     # (Dicke, Scheitel m)
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
    quer = Matrix.Diagonal((SPEER_DICKE, SPEER_DICKE, 1.0, 1.0))
    sp.matrix_world = Matrix.Translation(Vector(griff.tolist())) @ R @ Matrix.Scale(s, 4) @ quer @ Matrix.Translation((0, 0, -z0))
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
    Q = np.array([(sp.matrix_world @ v.co)[:] for v in sp.data.vertices])
    t = (Q - griff) @ ax
    r = np.linalg.norm((Q - griff) - np.outer(t, ax), axis=1)
    print('SPEER %.2f m, Faust %.2f m von hinten, Achse %s, Schaft %.3f m dick, Spitze %.3f m breit (quer x%.1f)' % (SPEER_M,
          SPEER_M * SPEER_GRIFF, np.round(ax, 2), 2 * float(np.median(r)), 2 * float(r.max()), SPEER_DICKE))
    return sp


def statur(rig, koerper, dicke):
    """Jede Ecke um die Achse ihres Hauptknochens (Ruhelage) dicker oder dünner; Kopf und Hals bleiben (Helm, Glutpunkte)."""
    if abs(dicke - 1.0) < 1e-3:
        return
    namen = {g.index: g.name for g in koerper.vertex_groups}
    Mr = rig.matrix_world
    Mk = koerper.matrix_world
    Mi = Mk.inverted()
    n = 0
    for v in koerper.data.vertices:
        if not v.groups:
            continue
        g = max(v.groups, key=lambda g: g.weight)
        b = rig.data.bones.get(namen.get(g.group, ''))
        if b is None or b.name in (KOPF, HALS, K + 'Neck'):
            continue
        h, t = Mr @ b.head_local, Mr @ b.tail_local
        p = Mk @ v.co
        ax = t - h
        u = max(0.0, min(1.0, (p - h).dot(ax) / max(ax.length_squared, 1e-9)))
        q = h + ax * u
        v.co = Mi @ (q + (p - q) * dicke)
        n += 1
    print('STATUR Dicke %.2f an %d Ecken' % (dicke, n))


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


# Helfer 08.11., 12:55 (Liste 3): rechter Schädel ohne dunkle Höhlen; die Bemalung nimmt nur die Helligkeit des Kaufbilds, dort sind
# die Höhlen kaum dunkler als der Knochen. Darum im Bild jede Fläche des Schädels, deren Mitte näher als HOEHLE_R an einem
# Glutpunkt liegt, fast schwarz (zum Rand weich), auf beiden Seiten gleich
HOEHLE_R = 0.024
HOEHLE = 0x0C0A08


def hoehlen_dunkel(koerper, glut, png):
    from PIL import Image, ImageDraw, ImageFilter
    mitten = [o.matrix_world.translation.copy() for o in glut]
    uv = koerper.data.uv_layers.active.data
    im = Image.open(png).convert('RGB')
    maske = Image.new('L', im.size, 0)
    zg = ImageDraw.Draw(maske)
    n = 0
    for p in koerper.data.polygons:
        c = koerper.matrix_world @ p.center
        d = min((c - m).length for m in mitten)
        if d > HOEHLE_R:
            continue
        w = int(255 * min(1.0, 1.25 - d / HOEHLE_R))
        pts = [(uv[li].uv[0] * im.size[0], (1 - uv[li].uv[1]) * im.size[1]) for li in p.loop_indices]
        zg.polygon(pts, fill=max(w, 0))
        n += 1
    maske = maske.filter(ImageFilter.GaussianBlur(2))
    dunkel = Image.new('RGB', im.size, tuple(int(x * 255) for x in srgb(np.array(lin(HOEHLE)))))
    Image.composite(dunkel, im, maske).save(png)
    for img in bpy.data.images:
        if img.filepath and os.path.abspath(bpy.path.abspath(img.filepath)) == os.path.abspath(png):
            img.reload()
    print('HOEHLEN %d Flächen dunkel (Radius %.3f m)' % (n, HOEHLE_R))


def waffe_heben(o, rig, a, scn):
    """E3 (nichts durch etwas): im Tod fällt die Waffe mit der Faust und stach in den Boden (Speer 20 cm, Lauf 2). Je Bild um die
    Faust so wenig wie möglich aufrichten, bis keine Ecke unter dem Boden liegt; als eigene Spur „Tod“ des Teils."""
    rig.animation_data.action = a
    if slot(a) is not None:
        rig.animation_data.action_slot = slot(a)
    o.rotation_mode = 'QUATERNION'
    b0 = o.matrix_basis.copy()
    o.animation_data_create()
    act = bpy.data.actions.new('Tod %s' % o.name)
    act.use_fake_user = True
    o.animation_data.action = act
    pb = rig.pose.bones[HAND_R if o.parent_bone == HAND_R else o.parent_bone]
    r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
    gedreht, rest = 0.0, 0.0
    for f in range(r0, r1 + 1):
        scn.frame_set(f)
        o.matrix_basis = b0
        bpy.context.view_layer.update()
        V = [o.matrix_world @ v.co for v in o.data.vertices]
        if min(p.z for p in V) < 0.003:
            g = (rig.matrix_world @ pb.matrix).translation
            fern = max(V, key=lambda p: (p - g).length)
            ach = (fern - g).cross(Vector((0, 0, 1)))
            if ach.length > 1e-6:
                ach.normalize()
                M0 = o.matrix_world.copy()
                wahl = None
                for w in range(2, 92, 2):
                    for vz in (1, -1):
                        R = Matrix.Translation(g) @ Matrix.Rotation(math.radians(w * vz), 4, ach) @ Matrix.Translation(-g)
                        if min((R @ M0 @ v.co).z for v in o.data.vertices) >= 0.003:
                            wahl = R; break
                    if wahl is not None:
                        gedreht = max(gedreht, w); break
                if wahl is not None:
                    o.matrix_world = wahl @ M0
                    bpy.context.view_layer.update()
        rest = min(rest, min((o.matrix_world @ v.co).z for v in o.data.vertices))
        o.keyframe_insert('location', frame=f)
        o.keyframe_insert('rotation_quaternion', frame=f)
        o.keyframe_insert('scale', frame=f)
    o.animation_data.action = None
    o.matrix_basis = b0
    tr = o.animation_data.nla_tracks.new(); tr.name = 'Tod'
    st = tr.strips.new('Tod', r0, act)
    if slot(act) is not None and hasattr(st, 'action_slot'):
        st.action_slot = slot(act)
    print('TOD %s um die Faust aufgerichtet, höchstens %d Grad, tiefster Punkt %.3f m' % (o.name, gedreht, rest))
    return round(rest, 3)


# Helfer 08.11., 12:55: alle hielten die Waffe im Stehen waagerecht auf Hüfthöhe zur Seite (gemessen 64–79 Grad von senkrecht,
# Kauf Idle1Handed). Ziel je Waffe (Richtung Faust -> Spitze, Blender: −X die rechte Seite der Figur, −Y vorn): Schwert gesenkt
# schräg vor das Bein, Speer aufrecht neben dem Körper, Spitze oben (1,75 m, sonst stäche er in den Boden). Ein fester Ausgleich im
# Raum der Faust, gemessen im ersten Bild, auf jedes Bild der Bewegung: das Atmen und Wiegen des Kaufs bleibt.
ZIEL_RICHTUNG = {'SM_Sword': (-0.30, -0.42, -0.86), 'SPEER': (-0.10, -0.12, 0.99)}
WAFFE_GESENKT = ('Stehen', 'Gehen')


def kurven(a):
    if hasattr(a, 'fcurves'):
        return list(a.fcurves)
    return [fc for l in a.layers for st in l.strips for cb in st.channelbags for fc in cb.fcurves]


# 506 t274.14 (Chef 10.11., 13:16: „völlig hyper, die wackeln ständig mit dem Schwert … zappeln auf der Stelle … viel zu viel
# Bewegung“): Idle1Handed des Kaufs ist eine Schleife von 1,03 s mit kräftigem Wiegen. Jede Spur von „Stehen“ um ihre Mitte auf
# RUHE_AUSSCHLAG gedämpft, gespielt mit RUHE_TEMPO (skeleton-info.json „tempo“, figur.gd): ruhig atmend statt zappelnd
RUHE_AUSSCHLAG = 0.35
RUHE_TEMPO = 0.5


def ruhe_daempfen(akt):
    a = akt.get('Stehen')
    if a is None:
        return
    n = 0
    for c in kurven(a):
        k = c.keyframe_points
        if len(k) < 2:
            continue
        mitte = sum(p.co[1] for p in k) / len(k)
        for p in k:
            for attr in ('co', 'handle_left', 'handle_right'):
                v = getattr(p, attr)
                v[1] = mitte + (v[1] - mitte) * RUHE_AUSSCHLAG
        c.update()
        n += 1
    print('RUHE Stehen: %d Spuren auf %.0f %% gedämpft, Tempo %.2f' % (n, RUHE_AUSSCHLAG * 100, RUHE_TEMPO))


def waffe_senken(rig, waffe, akt):
    ziel = Vector(ZIEL_RICHTUNG.get(waffe.name, ZIEL_RICHTUNG['SM_Sword'])).normalized()
    pb = rig.pose.bones[HAND_R]
    pfad = 'pose.bones["%s"].rotation_quaternion' % HAND_R
    for nm in WAFFE_GESENKT:
        a = akt.get(nm)
        if a is None:
            continue
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        f0 = int(a.frame_range[0])
        bpy.context.scene.frame_set(f0); bpy.context.view_layer.update()
        h = rig.matrix_world @ pb.head
        V = [waffe.matrix_world @ v.co for v in waffe.data.vertices]
        v = (max(V, key=lambda p: (p - h).length) - h).normalized()
        D = v.rotation_difference(ziel).to_matrix()
        Rw = (rig.matrix_world @ pb.matrix).to_3x3().normalized()
        L = (Rw.inverted() @ D @ Rw).to_quaternion()
        fc = sorted([c for c in kurven(a) if c.data_path == pfad], key=lambda c: c.array_index)
        if len(fc) != 4:
            print('SENKEN %s: Faust ohne Drehspur' % nm); continue
        for i in range(len(fc[0].keyframe_points)):
            q = Quaternion([c.keyframe_points[i].co[1] for c in fc]) @ L
            for c, wq in zip(fc, q):
                c.keyframe_points[i].co[1] = wq
                c.keyframe_points[i].handle_left[1] = wq; c.keyframe_points[i].handle_right[1] = wq
        for c in fc:
            c.update()
        winkel = []
        for f in range(f0, int(a.frame_range[1]) + 1, 5):
            bpy.context.scene.frame_set(f); bpy.context.view_layer.update()
            h = rig.matrix_world @ pb.head
            V = [waffe.matrix_world @ v.co for v in waffe.data.vertices]
            w = (max(V, key=lambda p: (p - h).length) - h).normalized()
            winkel.append(round(math.degrees(w.angle(ziel))))
        print('SENKEN %s %s: Abweichung vom Ziel je 5 Bilder %s Grad' % (waffe.name, nm, winkel))


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
    if 'SM_Shield' in netze and abs(SCHILD_GROESSE - 1.0) > 1e-3:
        sh = netze['SM_Shield']
        c = sum((sh.matrix_world @ v.co for v in sh.data.vertices), Vector()) / len(sh.data.vertices)
        sh.matrix_world = Matrix.Translation(c) @ Matrix.Scale(SCHILD_GROESSE, 4) @ Matrix.Translation(-c) @ sh.matrix_world
        bpy.context.view_layer.update()
        print('SCHILD x%.2f um die Mitte' % SCHILD_GROESSE)
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
    knochen_png = speichere(knochen_bild(tex_dir, kit['knochen']), 'knochen-' + kit_name)
    material(koerper, knochen_png, 'Knochen')
    for n, bildname, holz in (('SM_Helmet', 'T_Helmet_Albedo.jpg', False), ('SM_Sword', 'T_1HandedSword_Albedo.jpg', False),
                              ('SM_Shield', 'T_Shield_Albedo.jpg', True)):
        if n in netze:
            material(netze[n], speichere(rost_bild(os.path.join(tex_dir, bildname), holz), n.lower() + '-' + kit_name), n)
    dicke, hoehe = STATUR[kit['statur']]
    statur(rig, koerper, dicke)
    INFO['statur'] = kit['statur']
    glut = augen(rig, koerper)
    hoehlen_dunkel(koerper, glut, knochen_png)
    netze.update({o.name: o for o in glut})
    # Bewegungen
    rig.animation_data_create()
    akt = aktionen(d, rig)
    if 'Stehen' not in akt or 'Gehen' not in akt or 'Hieb' not in akt:
        sys.exit('Stehen, Gehen oder Hieb fehlt im Kauf')
    waffe = netze.get('SPEER') or netze.get('SM_Sword')
    if waffe is not None:
        waffe_senken(rig, waffe, akt)
    ruhe_daempfen(akt)
    INFO['tempo'] = {'Stehen': RUHE_TEMPO}
    rig.animation_data.action = akt['Stehen']
    if slot(akt['Stehen']) is not None:
        rig.animation_data.action_slot = slot(akt['Stehen'])
    f0 = int(akt['Stehen'].frame_range[0])
    P = welt_netz([koerper], f0)
    lo, hi = P.min(0), P.max(0)
    print('MASS gekauft (Stehen): breit %.3f tief %.3f hoch %.3f, Boden %.3f' % (hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2]))
    s = float(os.environ.get('HOEHE', hoehe)) / max(hi[2] - lo[2], 1e-4)
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
        # jede Bewegung setzt den Ort des Gerüsts selbst (auch auf 0), sonst bliebe der Hub der vorigen stehen
        rig.location.z = 0.0
        for f in range(r0, r1 + 1):
            rig.keyframe_insert('location', frame=f)
        if nm not in IM_BODEN_ERLAUBT:
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
    for o in waffen_teile:
        if waffe_tief.get('Tod', 0.0) < -0.002 and 'Tod' in gespielt:
            waffe_tief['Tod'] = waffe_heben(o, rig, gespielt['Tod'], scn)
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
                              export_optimize_animation_keep_anim_object=True, export_optimize_animation_keep_anim_armature=True,
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
