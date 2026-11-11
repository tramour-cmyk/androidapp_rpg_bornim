# 506 Wiedergänger (Wochenziel 03.11. Reihe 2; Kauf 348.12c A, Chef 03.11., 15:40: „506 baut die Untoten aus dem Kauf“): gekaufter
# RenderHub „Evil Undead“ (wernerkurt; privates Repo, $KAUF, nie hierher und nie als Artefakt) nach `LISTE-FIGUREN.md`
# „Wiedergänger“ (ersetzt den Zombie, 348.12c; Regeln bleiben die des Zombies, Monsters.kt zombie):
#   1 160–185 cm, etwa wie der Held; jeder schlank, mittel oder kräftig (hier je Kit eine Statur, wie kaufskelett.py)
#   2 menschlich, ausgemergelt, überlange Arme mit langen Fingern und schwarzen Nägeln; kriecht und richtet sich auf (Auferstehen)
#   3 Gesicht wie ein Totenschädel, Grinsen ohne Lippen, Rippen frei (im Kauf); Augen matt, auch wo das Modell leuchtet; Erde an
#     Haut und Lumpen
#   4 Haut grabgrau, fahl oder erdbraun, nicht glänzend; Fleischreste gedämpft, kein Gedärm; drei Kits am Umriss verschieden
#     (Lumpen; Leichenhemd; rostiges Kettenhemd), immer Krallen statt Waffe (MonsterKit.kt zombie: Lumpen, Lederwams, Kettenhemd)
#   5 vorgebeugt, Arme hängen, Kopf vorgestoßen (Stehen idle1, Gehen walk2 des Kaufs: gemessen am weitesten vorgebeugt)
# Bemalung wie bei den Kauftieren: aus dem Kaufbild nur die Helligkeit, Farben sind unsere; das Leuchtbild bleibt weg.
# Die Kits sind Hüllen aus dem Körpernetz selbst (Flächen der Rumpf-, Becken-, Arm- und Schenkelknochen, längs der Normalen
# nach außen gesetzt, Saum zerrissen): sie biegen sich mit denselben Knochen, kein eigenes Gerüst.
# Der Kauf läuft auf der Stelle (keine _RM-Dateien): Wurzelweg aus dem Tempo der Füße am Boden (wie kauftier.py).
# Aufruf: KAUF=<ordner> OUT=<ordner> [KIT=lumpen] python -I kaufuntoter.py  ->  <OUT>/zombie-<kit>.glb, zombie-info.json
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import bmesh
import numpy as np
from mathutils import Vector, Matrix
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, importiere
from kaufspinne import male_lage

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'zombie'
TEX = 1024
FPS = 30
# Modellregel 7: ganze Figur unter 6.000 (Kauf: Körper 11.228, Zähne 1.654, Augen 468)
KOERPER_DREIECKE = int(os.environ.get('DREIECKE', '3500'))
ZAEHNE_DREIECKE, AUGEN_DREIECKE = 300, 96
RNG = np.random.default_rng(5061)
UMBENENNEN = {'neck_01': 'hals', 'head': 'kopf'}     # kopfdreh.gd

# Liste 4: drei Kits am Umriss verschieden; Hautton je Kit (Liste 4: grabgrau, fahl, erdbraun); Statur je Kit (Liste 1)
# huelle: (Knochenteile, Anteil längs des Knochens von–bis) je Teil; dicke m nach außen; loecher Anteil Flächen, die fehlen
KITS = {
    # Bild 11:51 (eigene Prüfung): Kits kaum zu unterscheiden; Hüllen dicker, Stoff dunkler gegen die Haut, Lumpen mit Fetzen über Brust
    'lumpen': {'haut': (0x6C685E, 0x262420), 'statur': 'schlank', 'stoff': 0x2E2820, 'dicke': 0.018, 'loecher': 0.30,
               'huelle': {'pelvis': (0, 1), 'thigh': (0, 0.45), 'spine_01': (0, 1), 'spine_02': (0, 0.6)}, 'saum': 0.10},
    'hemd': {'haut': (0x9C9486, 0x3A342C), 'statur': 'mittel', 'stoff': 0x5E564A, 'dicke': 0.024, 'loecher': 0.06,
             'huelle': {'pelvis': (0, 1), 'spine': (0, 1), 'clavicle': (0, 1), 'upperarm': (0, 0.75), 'thigh': (0, 0.8)}, 'saum': 0.12},
    'kette': {'haut': (0x5E4C3A, 0x221A12), 'statur': 'kraeftig', 'stoff': 0x3C3A38, 'dicke': 0.03, 'loecher': 0.02,
              'huelle': {'pelvis': (0, 1), 'spine': (0, 1), 'clavicle': (0, 1), 'upperarm': (0, 0.5), 'thigh': (0, 0.4)}, 'saum': 0.05,
              'rost': True},
}
STATUR = {'schlank': (0.88, 1.80), 'mittel': (1.0, 1.75), 'kraeftig': (1.12, 1.71)}     # (Dicke, Scheitel aufrecht m)
FLEISCH, ERDE, NAGEL = 0x4A2C26, 0x3A2E20, 0x141210
ZAHN, AUGE = 0x857A60, 0x56524C     # Zähne vergilbt; Augen milchig matt, nicht leuchtend
ROST, ROST_TIEF = 0x7A4424, 0x3A2214
NAGEL_AB = 0.55

# unser Name <- Kaufdatei (ohne „EvilUndead@“)
NAMEN = [('Stehen', 'idle1'), ('Lauern', 'idle5'), ('Gehen', 'walk2'), ('Rennen', 'run1'), ('Hieb', 'attack2'),
         ('Hieb2', 'attack6'), ('Treffer', 'gethit2'), ('Tod', 'death2'), ('Drohen', 'rage1'), ('Ausweichen', 'straferight'),
         ('Ausweichen links', 'strafeleft'), ('Auferstehen', 'standup'), ('Kriechen', 'crawl')]
TEMPO_AUS = ('Gehen', 'Rennen', 'Kriechen')         # Wurzelweg aus den Füßen am Boden
AUSWEICHEN_M = 0.9
IM_BODEN_ERLAUBT = ('Auferstehen',)                  # steigt aus dem Boden (wird nicht gehoben, nur der tiefste Punkt gemeldet)


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    t = sorted(glob.glob(os.path.join(KAUF, '**', 'Base mesh.fbx'), recursive=True))
    t = [p for p in t if 'Undead' in p] or t
    if not t:
        sys.exit('Base mesh.fbx (Evil Undead) nicht gefunden unter %s (evil.undead.zip und darin Base mesh.zip, Animations.zip, '
                 'Textures.zip entpackt?)' % KAUF)
    stamm = os.path.dirname(os.path.dirname(os.path.dirname(t[0])))
    anim = sorted(glob.glob(os.path.join(stamm, '**', 'EvilUndead@idle1.fbx'), recursive=True))
    tex = sorted(glob.glob(os.path.join(stamm, '**', 'T_EvilUndead_Albedo.tga'), recursive=True))
    if not anim or not tex:
        sys.exit('Bewegungen oder Bilder des Evil Undead fehlen unter %s' % stamm)
    return t[0], os.path.dirname(anim[0]), tex[0]


def auspacken():
    """Der Kauf liegt als evil.undead.zip vor, darin wieder Zips (Base mesh, Animations, Textures); kauf_laden.sh packt nur die
    äußere Ebene aus. Die inneren hier, neben sich (nur auf dem Läufer, nichts davon kommt ins Repo)."""
    import zipfile
    for z in glob.glob(os.path.join(KAUF, '**', 'Evil Undead', '*.zip'), recursive=True):
        if os.path.basename(z) in ('Base mesh.zip', 'Animations.zip', 'Textures.zip') and not os.path.isdir(z[:-4]):
            zipfile.ZipFile(z).extractall(z[:-4])
            print('AUSGEPACKT', os.path.basename(z))


def bild(pfad, kante=TEX):
    from PIL import Image
    im = Image.open(pfad).convert('RGB')
    if im.size[0] != kante:
        im = im.resize((kante, kante), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def rauschen(n, glatt, kante=TEX):
    from PIL import Image, ImageFilter
    r = RNG.random((kante // n, kante // n)).astype(np.float32)
    im = Image.fromarray((r * 255).astype(np.uint8)).resize((kante, kante), Image.BICUBIC).filter(ImageFilter.GaussianBlur(glatt))
    a = np.asarray(im, np.float32) / 255.0
    return (a - a.min()) / max(a.max() - a.min(), 1e-4)


def haut_bild(albedo, koerper, kit):
    """Helligkeit des Kaufs (Falten, Rippen, Adern), Farbe je Kit; rote Fleischstellen dunkel und gedämpft; Erde an Füßen und
    Unterschenkeln (im Raum: Höhe in der Ruhelage), Flecken überall."""
    a = bild(albedo)
    lum = a.mean(2)
    sat = a.max(2) - a.min(2)
    bel = lum > 0.03
    med = float(np.median(lum[bel]))
    t = np.clip(lum / max(med, 1e-3), 0.15, 1.7)[..., None]
    hell, tief = (np.array(lin(c)) for c in kit['haut'])
    b = tief + (hell - tief) * np.clip((t - 0.3) / 0.95, 0, 1) ** 1.15
    rot = np.clip((a[..., 0] - a[..., 1] * 1.3 - 0.04) * 5, 0, 1) * np.clip((sat - 0.15) * 5, 0, 1)
    b = b * (1 - rot[..., None]) + np.array(lin(FLEISCH)) * (0.6 + 0.5 * t) * rot[..., None]
    fl = np.clip((rauschen(12, 4) - 0.55) * 2.5, 0, 1)[..., None] * 0.5
    b = b * (1 - fl) + np.array(lin(ERDE)) * t * fl
    b *= (0.9 + 0.16 * rauschen(64, 0.8)[..., None])
    P = np.array([(koerper.matrix_world @ v.co)[:] for v in koerper.data.vertices])
    lo, hi = P[:, 2].min(), P[:, 2].max()
    hoch = hi - lo

    def erde(X, grob=False):
        return np.clip((lo + 0.32 * hoch - X[:, 2]) / (0.12 * hoch), 0, 1)
    b = male_lage(b, koerper, erde, lin(ERDE), 0.75, 2.0)
    print('HAUT %s: Fleisch %.1f %%' % (kit['haut'][0], 100 * float((rot > 0.5)[bel].mean())))
    return np.clip(srgb(b), 0, 1)


def stoff_bild(kit):
    """Stoff der Hülle (gleiche UV wie der Körper): Lumpen und Hemd mit Grabflecken und Erde, Kettenhemd Eisen mit Ringen und Rost."""
    s = np.array(lin(kit['stoff']))
    t = 0.75 + 0.5 * rauschen(32, 1.2)[..., None]
    b = s * t
    if kit.get('rost'):
        yy, xx = np.mgrid[0:TEX, 0:TEX]
        ring = (np.sin(xx * 0.9) * np.sin(yy * 0.9 + (xx // 7) % 2 * 1.6)) * 0.5 + 0.5
        b = b * (0.7 + 0.55 * ring[..., None])
        m = np.clip((rauschen(10, 3) - 0.4) * 2.2, 0, 1)[..., None] * 0.85
        rost = np.array(lin(ROST)) * (1 - 0.5 * rauschen(30, 1)[..., None]) + np.array(lin(ROST_TIEF)) * 0.5 * rauschen(30, 1)[..., None]
        b = b * (1 - m) + rost * t * m
    else:
        fl = np.clip((rauschen(8, 5) - 0.45) * 2.0, 0, 1)[..., None] * 0.7
        b = b * (1 - fl) + np.array(lin(ERDE)) * t * fl
    return np.clip(srgb(b), 0, 1)


def speichere(b, name):
    from PIL import Image
    p = os.path.join(OUT, 'tex_untoter_%s.jpg' % name)
    Image.fromarray((b * 255).astype(np.uint8)).save(p, quality=90)
    return p


def material(o, bildpfad=None, name='Stoff', farbe=None):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    if bildpfad:
        ti = mat.node_tree.nodes.new('ShaderNodeTexImage')
        ti.image = bpy.data.images.load(bildpfad, check_existing=False)
        mat.node_tree.links.new(ti.outputs['Color'], bsdf.inputs['Base Color'])
    else:
        c = lin(farbe)
        bsdf.inputs['Base Color'].default_value = (float(c[0]), float(c[1]), float(c[2]), 1.0)
    bsdf.inputs['Roughness'].default_value = 0.9
    o.data.materials.clear()
    o.data.materials.append(mat)


def eckfarbe(o, c):
    ca = o.data.color_attributes.new('Col', 'FLOAT_COLOR', 'CORNER')
    for li in range(len(o.data.loops)):
        ca.data[li].color = (float(c[0]), float(c[1]), float(c[2]), 1.0)
    o.data.color_attributes.active_color = ca


def duenn(o, ziel):
    vorher = tris([o])
    if vorher > ziel:
        mod = o.modifiers.new('weniger', 'DECIMATE')
        mod.ratio = ziel / vorher
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return vorher, tris([o])


def anteil(rig, b, p):
    """Lage einer Ecke längs ihres Knochens (Ruhelage): 0 am Kopf des Knochens, 1 am Ende."""
    h, t = rig.matrix_world @ b.head_local, rig.matrix_world @ b.tail_local
    ax = t - h
    return max(0.0, min(1.0, (p - h).dot(ax) / max(ax.length_squared, 1e-9)))


def huelle(rig, koerper, kit, name):
    """Kit als Hülle aus dem Körpernetz: Flächen, deren Ecken an den Knochen der Hülle hängen (im Anteil längs des Knochens),
    kopiert und längs der Normalen nach außen gesetzt; Löcher und ein zerrissener Saum nach Rauschen im Raum."""
    o = koerper.copy(); o.data = koerper.data.copy(); o.name = 'Kit'
    bpy.context.scene.collection.objects.link(o)
    namen = {g.index: g.name for g in o.vertex_groups}
    Mw = o.matrix_world
    drin = np.zeros(len(o.data.vertices), bool)
    rand = np.zeros(len(o.data.vertices))
    for v in o.data.vertices:
        if not v.groups:
            continue
        g = max(v.groups, key=lambda g: g.weight)
        bn = namen.get(g.group, '')
        b = rig.data.bones.get(bn)
        if b is None:
            continue
        for teil, (u0, u1) in kit['huelle'].items():
            if bn.startswith(teil):
                u = anteil(rig, b, Mw @ v.co)
                if u0 <= u <= u1:
                    drin[v.index] = True
                    rand[v.index] = (u1 - u) if u1 < 1 else 1.0
                break
    bm = bmesh.new(); bm.from_mesh(o.data)
    bm.verts.ensure_lookup_table(); bm.faces.ensure_lookup_table()
    # zerrissener Saum und Löcher: Rauschen im Raum (Ruhelage), damit links und rechts verschieden reißen
    def rausch(p):
        return (math.sin(p.x * 61.0 + 1.3) * math.sin(p.y * 47.0 + 0.7) * math.sin(p.z * 53.0 + 2.1)) * 0.5 + 0.5
    weg = []
    for f in bm.faces:
        if not all(drin[v.index] for v in f.verts):
            weg.append(f); continue
        c = Mw @ f.calc_center_median()
        r = min(rand[v.index] for v in f.verts)
        if r < kit['saum'] and rausch(c) < 0.55:
            weg.append(f); continue
        if RNG.random() < kit['loecher'] * (0.4 + rausch(c)):
            weg.append(f)
    bmesh.ops.delete(bm, geom=weg, context='FACES')
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
    bm.normal_update()
    d = kit['dicke'] / max(Mw.to_scale()[0], 1e-6)
    for v in bm.verts:
        v.co = v.co + v.normal * d
    bm.to_mesh(o.data); bm.free()
    print('KIT %s: %d Flächen, %d Dreiecke, %.3f m nach außen' % (name, len(o.data.polygons), tris([o]), kit['dicke']))
    return o


def statur(rig, netze, dicke):
    """Liste 1: jede Ecke um die Achse ihres Hauptknochens dicker oder dünner; Kopf und Hals bleiben."""
    if abs(dicke - 1.0) < 1e-3:
        return
    Mr = rig.matrix_world
    for o in netze:
        namen = {g.index: g.name for g in o.vertex_groups}
        Mk, Mi = o.matrix_world, o.matrix_world.inverted()
        for v in o.data.vertices:
            if not v.groups:
                continue
            g = max(v.groups, key=lambda g: g.weight)
            b = rig.data.bones.get(namen.get(g.group, ''))
            if b is None or b.name in ('head', 'neck_01', 'jaw1'):
                continue
            h, t = Mr @ b.head_local, Mr @ b.tail_local
            p = Mk @ v.co
            ax = t - h
            u = max(0.0, min(1.0, (p - h).dot(ax) / max(ax.length_squared, 1e-9)))
            q = h + ax * u
            v.co = Mi @ (q + (p - q) * dicke)
    print('STATUR Dicke %.2f' % dicke)


def naegel(rig, koerper):
    """Liste 2: schwarze Nägel. Das Netz hängt nur bis zum zweiten Fingerglied (*_02): Ecken im vorderen Teil dieses Glieds
    (Anteil längs des Knochens über NAGEL_AB) als Eckfarbe dunkel (Bild mal Eckfarbe)."""
    ca = koerper.data.color_attributes.new('Col', 'FLOAT_COLOR', 'CORNER')
    glied = {g.index: g.name for g in koerper.vertex_groups if g.name.endswith(('_02_l', '_02_r')) and not g.name.startswith('thumb')}
    glied.update({g.index: g.name for g in koerper.vertex_groups if g.name.startswith('thumb_02')})
    Mw = koerper.matrix_world
    spitz_ecke = set()
    for v in koerper.data.vertices:
        for g in v.groups:
            if g.group in glied and g.weight > 0.5:
                b = rig.data.bones.get(glied[g.group])
                if b is not None and anteil(rig, b, Mw @ v.co) > NAGEL_AB:
                    spitz_ecke.add(v.index)
    nagel = lin(NAGEL) / np.maximum(lin(0x6C685E), 1e-3)
    n = 0
    for p in koerper.data.polygons:
        spitz = sum(vi in spitz_ecke for vi in p.vertices) >= 2
        c = (float(nagel[0]), float(nagel[1]), float(nagel[2]), 1.0) if spitz else (1.0, 1.0, 1.0, 1.0)
        n += spitz
        for li in p.loop_indices:
            ca.data[li].color = c
    koerper.data.color_attributes.active_color = ca
    print('NAEGEL %d Flächen dunkel' % n)


def uebertrage(rig, anim_rig, a, nm):
    """Die Bewegungsdateien des Kaufs tragen ihr Gerüst in der ersten Haltung als Ruhelage (gemessen: lokale Drehungen fast null,
    auf das Gerüst des Körpers gelegt stand er in der T-Haltung). Darum je Bild die Lage jedes Knochens im Raum des Gerüsts aus der
    Bewegungsdatei nehmen und für unser Gerüst in lokale Werte umrechnen (Blender: Lage = Eltern-Lage · Eltern-Ruhe⁻¹ · Ruhe · lokal)."""
    from mathutils import Quaternion
    setze(anim_rig, a)
    r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
    knochen = [b for b in rig.data.bones if b.name in anim_rig.pose.bones]
    werte = {b.name: [] for b in knochen}
    for f in range(r0, r1 + 1):
        bpy.context.scene.frame_set(f)
        W = rig.matrix_world.inverted() @ anim_rig.matrix_world
        lage = {}
        for b in knochen:     # Eltern vor Kindern (Blender ordnet so)
            ziel = W @ anim_rig.pose.bones[b.name].matrix
            lage[b.name] = ziel
            if b.parent is not None and b.parent.name in lage:
                basis = (lage[b.parent.name] @ b.parent.matrix_local.inverted() @ b.matrix_local).inverted() @ ziel
            else:
                basis = b.matrix_local.inverted() @ ziel
            l, q, sc = basis.decompose()
            werte[b.name].append((l, q, sc))
    neu = bpy.data.actions.new(nm)
    neu.use_fake_user = True
    sl = neu.slots.new('OBJECT', rig.name)
    st = neu.layers.new('Ebene').strips.new(type='KEYFRAME')
    cb = st.channelbag(sl, ensure=True)
    n = r1 - r0 + 1
    for b in knochen:
        reihe = werte[b.name]
        for pfad, k, wahl in (('location', 3, 0), ('rotation_quaternion', 4, 1), ('scale', 3, 2)):
            for i in range(k):
                fc = cb.fcurves.new('pose.bones["%s"].%s' % (b.name, pfad), index=i)
                fc.keyframe_points.add(n)
                co = []
                vorher = None
                for j, w in enumerate(reihe):
                    v = w[wahl]
                    if wahl == 1:     # Vorzeichen der Drehung stetig halten (kein Sprung über die Gegenseite)
                        if vorher is not None and v.dot(vorher) < 0:
                            v = -v
                        vorher = v
                        reihe[j] = (w[0], v, w[2])
                    co += [r0 + j, v[i]]
                fc.keyframe_points.foreach_set('co', co)
                for kp in fc.keyframe_points:
                    kp.interpolation = 'LINEAR'
                fc.update()
    for pb in rig.pose.bones:
        pb.rotation_mode = 'QUATERNION'
    return neu


def aktionen(d, rig):
    akt = {}
    for nm, q in NAMEN:
        f = os.path.join(d, 'EvilUndead@%s.fbx' % q)
        if not os.path.exists(f):
            print('FEHLT Bewegung', q); continue
        neu = importiere(f)
        a = aktion_von(neu)
        ar = next((o for o in neu if o.type == 'ARMATURE'), None)
        if a is None or ar is None:
            entferne(neu); print('FEHLT Aktion', q); continue
        akt[nm] = uebertrage(rig, ar, a, nm + ' Kauf')
        entferne(neu)
        bpy.data.actions.remove(a)
    return akt


def setze(rig, a):
    rig.animation_data.action = a
    if slot(a) is not None:
        rig.animation_data.action_slot = slot(a)


def fuss_tempo(rig, a, s):
    """Tempo aus den Füßen am Boden (m/s in unseren Metern): je Fuß im tiefsten Drittel seiner Höhe die Bewegung nach hinten."""
    setze(rig, a)
    r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
    v = []
    for fuss in ('foot_l', 'foot_r'):
        pts = []
        for f in range(r0, r1 + 1):
            bpy.context.scene.frame_set(f)
            pts.append((rig.matrix_world @ rig.pose.bones[fuss].tail).copy())
        z = np.array([p.z for p in pts]); y = np.array([p.y for p in pts])
        m = z < np.percentile(z, 33)
        dy = np.diff(y) * FPS
        v += list(dy[m[1:]])
    return abs(float(np.median(v))) if v else 0.0


def baue(kit_name):
    kit = KITS[kit_name]
    fbx, d, albedo = quelle()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene
    scn.render.fps = FPS
    teile = importiere(fbx)
    rig = next(o for o in teile if o.type == 'ARMATURE')
    netze = {o.name: o for o in teile if o.type == 'MESH'}
    koerper = netze['body1']
    zaehne = next(o for n, o in netze.items() if n.startswith('teeth'))
    augen = next(o for n, o in netze.items() if n.startswith('eyes'))
    INFO = {'waffen': [], 'geruest': 'kauf', 'kit': kit_name, 'statur': kit['statur']}
    print('DREIECKE Körper %d -> %d, Zähne %d -> %d, Augen %d -> %d' % (*duenn(koerper, KOERPER_DREIECKE),
          *duenn(zaehne, ZAEHNE_DREIECKE), *duenn(augen, AUGEN_DREIECKE)))
    dicke, hoehe = STATUR[kit['statur']]
    statur(rig, [koerper], dicke)
    material(koerper, speichere(haut_bild(albedo, koerper, kit), 'haut-' + kit_name), 'Haut')
    hk = huelle(rig, koerper, kit, kit_name)
    naegel(rig, koerper)
    material(zaehne, None, 'Zahn', ZAHN)
    material(augen, None, 'Auge', AUGE)
    material(hk, speichere(stoff_bild(kit), 'stoff-' + kit_name), 'Stoff')
    eckfarbe(hk, (1.0, 1.0, 1.0))
    alle = [koerper, zaehne, augen, hk]
    # ------------------------------------------------ Größe (Liste 1): Scheitel aufrecht in der Ruhelage
    P = welt_netz(alle, 1)
    s = float(os.environ.get('HOEHE', hoehe)) / max(P[:, 2].max() - P[:, 2].min(), 1e-4)
    rig.animation_data_create()
    akt = aktionen(d, rig)     # vor dem Maßstab: die Lage der Knochen wird im Raum des Gerüsts übertragen
    aussen = bpy.data.objects.new('Wiedergaenger', None)
    scn.collection.objects.link(aussen)
    rig.parent = aussen
    aussen.scale = (s, s, s)
    bpy.context.view_layer.update()
    for nm in ('Stehen', 'Gehen', 'Hieb'):
        if nm not in akt:
            sys.exit('%s fehlt im Kauf' % nm)
    setze(rig, akt['Stehen'])
    f0 = int(akt['Stehen'].frame_range[0])
    P = welt_netz([koerper], f0)
    lo, hi = P.min(0), P.max(0)
    aussen.location = (-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2])
    bpy.context.view_layer.update()
    P = welt_netz([koerper], f0)
    lo, hi = P.min(0), P.max(0)
    INFO['groesse_cm'] = round(float(hi[2] - lo[2]) * 100, 1)
    INFO['aufrecht_cm'] = round(hoehe * 100, 1)
    INFO['breite_m'] = round(float(hi[0] - lo[0]), 3)
    INFO['ursprung'] = [round(float(x), 4) for x in aussen.location]
    kopf = rig.matrix_world @ rig.pose.bones['head'].head
    becken = rig.matrix_world @ rig.pose.bones['pelvis'].head
    hand = min((rig.matrix_world @ rig.pose.bones[h].tail).z for h in ('hand_l', 'hand_r'))
    knie = (rig.matrix_world @ rig.pose.bones['calf_l'].head).z
    print('MASS Stehen: hoch %.3f (aufrecht %.2f), breit %.3f, Kopf %.2f m vor dem Becken, Hand %.2f m hoch, Knie %.2f m, Maßstab %.4f' % (
        hi[2] - lo[2], hoehe, hi[0] - lo[0], becken.y - kopf.y, hand, knie, s))
    # ------------------------------------------------ Wurzelweg aus den Füßen (der Kauf läuft auf der Stelle)
    wege = {}
    for nm in TEMPO_AUS:
        if nm not in akt:
            continue
        v = fuss_tempo(rig, akt[nm], s)
        n = int(akt[nm].frame_range[1] - akt[nm].frame_range[0])
        wege[nm] = [[0.0, round(v * i / FPS, 4)] for i in range(n + 1)]
        print('WEG %s: Füße am Boden %.2f m/s, %d Bilder' % (nm, v, n + 1))
    for nm, vz in (('Ausweichen', 1), ('Ausweichen links', -1)):
        if nm in akt:
            n = int(akt[nm].frame_range[1] - akt[nm].frame_range[0])
            wege[nm] = [[round(vz * AUSWEICHEN_M * (i / n) ** 0.8, 4), 0.0] for i in range(n + 1)]
    INFO['weg'] = wege
    INFO['fps'] = FPS
    # ------------------------------------------------ Spuren
    for nm, a in akt.items():
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'):
            st.action_slot = slot(a2)
        INFO.setdefault('zeiten', {})[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
    for tr in rig.animation_data.nla_tracks:
        tr.mute = True
    gehoben, tief = {}, {}
    for nm in INFO['zeiten']:
        a = bpy.data.actions[nm]
        setze(rig, a)
        r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
        rig.location.z = 0.0
        # Grundlinie: der tiefste Punkt der ganzen Bewegung auf den Boden (Ausweichen schwebte 4 cm, Kriechen lag 30 cm im Boden)
        if nm not in IM_BODEN_ERLAUBT:
            rig.location.z = -min(float(welt_netz(alle, f)[:, 2].min()) for f in range(r0, r1 + 1)) / max(s, 1e-6)
        for f in range(r0, r1 + 1):
            rig.keyframe_insert('location', frame=f)
        if nm not in IM_BODEN_ERLAUBT:
            hoch = 0.0
            for _ in range(4):
                rest = 0.0
                for f in range(r0, r1 + 1):
                    z = float(welt_netz(alle, f)[:, 2].min())
                    if z < -0.002:
                        scn.frame_set(f)
                        rig.location.z = rig.location.z - z / max(s, 1e-6)
                        rig.keyframe_insert('location', frame=f)
                        hoch = max(hoch, rig.location.z * s)
                        rest = min(rest, z)
                if rest > -0.002:
                    break
            if hoch > 0.0:
                gehoben[nm] = round(float(hoch), 3)
        tief[nm] = round(min(float(welt_netz(alle, f)[:, 2].min()) for f in range(r0, r1 + 1)), 3)
    INFO['gehoben_m'] = gehoben
    INFO['tiefster_punkt_m'] = tief
    print('BODEN gehoben (m): %s; tiefster Punkt je Bewegung: %s' % (gehoben, tief))
    # Aufschlag des Hiebs (figur.gd „hieb“): Bild, in dem eine Hand (Fingerspitze) am weitesten vorn ist
    a = bpy.data.actions['Hieb']
    setze(rig, a)
    r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
    best = None
    for f in range(r0, r1 + 1):
        scn.frame_set(f); bpy.context.view_layer.update()
        for h in ('middle_02_r', 'middle_02_l', 'hand_r', 'hand_l'):
            if h not in rig.pose.bones:
                continue
            kp = rig.matrix_world @ rig.pose.bones[h].tail
            if best is None or -kp.y > best[1]:
                best = (f, -kp.y, kp)
    f_auf, _, kp = best
    INFO['hieb'] = [round(math.hypot(kp.x, kp.y), 3), round((f_auf - r0) / FPS, 3), round(-math.degrees(math.atan2(kp.x, -kp.y)), 1), round(kp.z, 2)]
    print('HIEB Aufschlag Bild %d (%.2f s von %.2f s): Krallen %.2f m vor dem Ursprung, %.0f Grad, %.2f m hoch' % (
        f_auf, (f_auf - r0) / FPS, (r1 - r0) / FPS, INFO['hieb'][0], -INFO['hieb'][2], INFO['hieb'][3]))
    rig.animation_data.action = None
    rig.location.z = 0.0
    for tr in rig.animation_data.nla_tracks:
        tr.mute = False
    for alt, neu in UMBENENNEN.items():
        if alt in rig.data.bones:
            rig.data.bones[alt].name = neu
    INFO['dreiecke'] = tris(alle)
    print('DREIECKE gesamt %d (Körper %d, Kit %d, Zähne %d, Augen %d)' % (INFO['dreiecke'], tris([koerper]), tris([hk]), tris([zaehne]), tris([augen])))
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, rig] + alle:
        o.select_set(True)
    pfad = os.path.join(OUT, '%s-%s.glb' % (ID, kit_name))
    bpy.ops.export_scene.gltf(filepath=pfad, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False,
                              export_image_format='JPEG', export_jpeg_quality=88, export_vertex_color='ACTIVE',
                              export_all_vertex_colors=False,
                              export_optimize_animation_keep_anim_object=True, export_optimize_animation_keep_anim_armature=True)
    INFO['sekunden_bau'] = round(time.time() - T0, 1)
    print('GLB %s %d Bytes' % (pfad, os.path.getsize(pfad)))
    return INFO


if __name__ == '__main__':
    auspacken()
    namen = [os.environ['KIT']] if os.environ.get('KIT') else list(KITS)
    info = {}
    for n in namen:
        info[n] = baue(n)
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1, ensure_ascii=False)
    print('KAUFUNTOTER FERTIG %.1f s, Kits %s' % (time.time() - T0, ', '.join(namen)))
