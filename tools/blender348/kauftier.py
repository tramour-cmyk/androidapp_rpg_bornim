# 387 (Jerry; Chef 27.10., 21:27, über Sokrates): gekaufte Tiere schnell prüfen, ob die Bewegungen taugen und unsere Haut draufpasst,
# bevor wieder selbst gebaut wird. Schnellbau wie kaufwolf.py, ohne Feinarbeit: Netz und Bewegungen aus dem Kauf (privates Repo, $KAUF,
# nie hierher), eigene Bemalung (Zeichnung = Helligkeit der Kauftextur, Farben aus unseren Fellen oder, wo wir keine haben, die Farbe
# des Kaufs entsättigt und dunkler), unsere Fellstriche; im Spiel trägt figur.gd Shader und Tusche (Probe ERSATZ=kauf_<tier>).
# Größe wie im Kauf (Janpec in Metern), Bewegungen auf der Stelle (kein Wurzelweg), Augen nicht eigens bemalt.
# Aufruf: TIER=keiler KAUF=<ordner> OUT=<ordner> python -I kauftier.py  ->  <OUT>/kauf_<tier>-<fell>.glb, kauf_<tier>-info.json
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
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
               'felle': {'rost': (0x6A2A1A, 0x2A100C, 0x8A6A2A), 'blauschwarz': (0x1E2028, 0x0A0A10, 0x5A1A14), 'ocker': (0x7A5A2A, 0x161210, 0x8A7040)}},
    'rind': {'rig': 'Cattle_Rig.fbx', 'anim': 'Cattle_%s.fbx', 'tex': 'iron_age_cattle_col_unity*',
             'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Stoss': 'Attack', 'Fressen': 'Eat', 'Tod': 'Die'}, 'felle': {'natur': None}},
    'ziege': {'rig': 'Goat_Rig.fbx', 'anim': 'Goat_%s.fbx', 'tex': 'goat_col*',
              'namen': {'Stehen': 'Idle', 'Stehen2': 'Idle02', 'Gehen': 'Walk', 'Rennen': 'Run', 'Stoss': 'Attack', 'Fressen': 'Eat', 'Tod': 'Die'}, 'felle': {'natur': None}},
    'huhn': {'rig': 'Chicken_Rig.fbx', 'anim': 'Chicken_%s.fbx', 'tex': 'chicken_col14*',
             'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Fressen': 'Eat', 'Tod': 'Die'}, 'felle': {'natur': None}},
    'schwein': {'rig': 'iron_age_pig_rig_exp.FBX', 'anim': 'iron_age_pig_%s_anim.FBX', 'tex': 'iron_age_pig_col_unity*',
                'namen': {'Stehen': 'idle', 'Gehen': 'walk', 'Fressen': 'eat', 'Tod': 'die'}, 'felle': {'natur': None}},
    'gans': {'rig': 'swan_goose_rig_exp.FBX', 'anim': 'swan_goose_%s_anim.FBX', 'tex': 'swan_goose_col*',
             'namen': {'Stehen': 'idle', 'Gehen': 'walk', 'Rennen': 'run', 'Fressen': 'eat', 'Tod': 'die'}, 'felle': {'natur': None}},
    'kaninchen': {'rig': 'WildRabbit_Rig.fbx', 'anim': 'WildRabbit_%s.fbx', 'tex': 'wild_rabbit_col5*',
                  'namen': {'Stehen': 'Idle', 'Gehen': 'Walk', 'Rennen': 'Run', 'Fressen': 'Eat', 'Tod': 'Die'}, 'felle': {'natur': None}},
}
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


def bemalung(src, fell, farben, bel, striche):
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
    farbe = np.where(bel[..., None], farbe, np.median(farbe[bel], axis=0))
    print('BEMALUNG %s %s: Quelle Helligkeit p5 %.3f p95 %.3f, neu Mittel %.3f' % (TIER, fell, p5, p95, float(farbe[bel].mean())))
    p = os.path.join(OUT, '%s-bemalung-%s.png' % (ID, fell))
    Image.fromarray((srgb(farbe) * 255).astype(np.uint8)).save(p)
    return p


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
    rig.animation_data_create()
    if 'Stehen' in akt:
        rig.animation_data.action = akt['Stehen']
        if slot(akt['Stehen']) is not None: rig.animation_data.action_slot = slot(akt['Stehen'])
    f0 = int(akt['Stehen'].frame_range[0]) if 'Stehen' in akt else 1
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    rig.animation_data.action = None
    # Bemalung
    bel = uv_belegt(meshes)
    farben = T['felle'][fell]
    bild = bpy.data.images.load(bemalung(tex, fell, farben, bel, fellstriche(meshes, np.random.default_rng(23), np.zeros((TEX, TEX), bool))))
    mat = bpy.data.materials.new('%s-%s' % (ID, fell)); mat.use_nodes = True
    bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
    im = mat.node_tree.nodes.new('ShaderNodeTexImage'); im.image = bild
    mat.node_tree.links.new(im.outputs['Color'], bs.inputs['Base Color'])
    for o in meshes:
        o.data.materials.clear(); o.data.materials.append(mat)
    INFO = {'fps': FPS, 'fell': fell, 'dreiecke': tris(meshes), 'knochen': len(rig.data.bones), 'quelle': 'gekauft (387): %s' % os.path.basename(fbx)}
    for nm, a in akt.items():
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'): st.action_slot = slot(a2)
        INFO[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
    # Blick: Kopf zur langen Achse; Janpec und MadeCG schauen nach −Y oder +Y (Blender), gewünscht −Y (glTF +Z)
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
    aussen.location = (-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2])
    bpy.context.view_layer.update()
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    INFO['hoehe_m'] = round(float(hi[2] - lo[2]), 3); INFO['laenge_m'] = round(float(hi[1] - lo[1]), 3); INFO['breite_m'] = round(float(hi[0] - lo[0]), 3)
    print('MASS %s: breit %.2f lang %.2f hoch %.2f m, Drehung %.0f°, Kopfknochen %s' % (TIER, hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], math.degrees(dreh), kb[0].name if kb else '-'))
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, rig] + meshes: o.select_set(True)
    path = os.path.join(OUT, '%s-%s.glb' % (ID, fell))
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False, export_image_format='JPEG', export_jpeg_quality=88)
    print('GLB', path, os.path.getsize(path), INFO)
    return INFO


if __name__ == '__main__':
    info = {f: baue(f) for f in T['felle']}
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1)
    print('KAUFTIER %s FERTIG %.1f s' % (TIER, time.time() - T0))
