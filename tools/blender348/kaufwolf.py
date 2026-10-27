# 348.12f (Jerry): Probe gekaufter Wolf (Janpec Animal Pack Deluxe, Chef 27.10., 18:09 „Was ist mit dem Kaufwolf? Den nehmen wir
# nicht? Oder seine Animationen?“): FBX aus dem privaten Repo ($KAUF, nie hierher und nie als Artefakt), eigene Bemalung (Felle
# wie wolf.py), Bewegungen unter unseren Namen, Blick +Z wie wolf.py, Schulter 0,8 m wie unser Wolf; im Spiel trägt figur.gd unseren
# Shader und die Tusche darüber (Probe ERSATZ=kaufwolf, Regeln die des Wolfs).
# Quelle (lokal gemessen 27.10.): ein Netz, 5.612 Dreiecke (unter 6.000, kein Ausdünnen), 42 Knochen, Textur 2048² (Farbe, AO);
# Bewegungen IdleA/B/C, Walk, Run, Attack, Eat, Howl, Die, alle auf der Stelle (keine Wurzelbewegung, keine _RM-Dateien).
# Es fehlen Treffer, Ausweichen, Sprung, Hocke: Hocke, Treffer, Ausweichen aus der Ruhe der Quelle abgeleitet (haltung(): Rumpf
# verschoben, Pfoten bleiben stehen, Läufe neu gebeugt wie kaufratte.py ducken()); Sprung = Biss (Attack).
# Ortswechsel (Chef 27.10., 18:01, Archiv): Wurzelweg „weg“ für Gehen und Rennen aus dem Tempo der Pfoten am Boden (gleiten nicht).
# Aufruf: KAUF=<ordner> OUT=<ordner> [FELL=grau] python -I kaufwolf.py  ->  <OUT>/kaufwolf-<fell>.glb, kaufwolf-info.json
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
from mathutils import Vector, Matrix
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, _zwei_knochen, fellstriche

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'kaufwolf'
TEX = 1024                   # Handy: 1024² statt 2048² (wie kaufratte.py; fellstriche() zeichnet in TEX)
SCHULTER = 0.8               # wolf.py: Schulter 0,8 m (schulterhoehe_m; Knochen, ohne Fell)
# Größe wie unser Wolf am Bild (lokal gemessen 27.10. an wolf-grau.glb): Rücken über der Mitte (Netz mit Fell) 0,94 m, Ohren 1,24 m,
# Nase bis Rute 2,0 m; die Kaufquelle auf „Widerrist 0,8“ geeicht war 20 % kleiner (Rücken 0,77, Ohren 0,97, Länge 1,65 m)
RUECKEN = 0.94
FPS = 30
# Felle aus wolf.py (fur, saddle, belly, eye); Narbe und Ohr dort Eigenbau, hier nicht
COATS = {
    'grau':   (0x6A645E, 0x24201E, 0xB4AA98, 0xF2B428),
    'dunkel': (0x3E3A3C, 0x161214, 0x7A726C, 0xF0C840),
    'rost':   (0x74563E, 0x2A1C16, 0xB8A088, 0xF0A020),
    'asche':  (0x8E8A84, 0x3A3634, 0xCAC4B8, 0xE88A20),
}
W_ = 'Wolf_'
J = lambda n: W_ + n + 'SHJnt'
COM, HALS, NACKEN = J('ROOT'), J('Neck_01'), J('Neck_Top')
# Läufe (oben, Mitte, unten, Pfote) wie ducken() in kaufratte.py: oben und Mitte neu gebeugt, unten und Pfote bleiben in ihrer Lage
BEINE = [(J('%s_FrontLeg_Hip' % s), J('%s_FrontLeg_Knee' % s), J('%s_FrontLeg_Ankle' % s), J('%s_FrontLeg_Ball' % s)) for s in 'lr'] + \
        [(J('%s_HindLeg_Hip' % s), J('%s_HindLeg_Knee1' % s), J('%s_HindLeg_Knee2' % s), J('%s_HindLeg_Ankle' % s)) for s in 'lr']
# Knochen unter unseren Namen (kopfdreh.gd BONES, figur.gd PAW_BONES); l liegt bei +X (Blick -Y: links)
UMBENENNEN = {HALS: 'hals', NACKEN: 'kopf', J('l_FrontLeg_Ball'): 'vpfoteL', J('r_FrontLeg_Ball'): 'vpfoteR',
              J('l_HindLeg_Ball'): 'hpfoteL', J('r_HindLeg_Ball'): 'hpfoteR'}
QUELLEN = ['IdleA', 'IdleC', 'Walk', 'Run', 'Attack', 'Die', 'Howl']
# Tod: Die dauert 4,1 s, figur.gd blendet nach FALL_MS + FADE_MS = 1,5 s aus; die Quelle sinkt bei Bild 64–78 -> ab Bild 52
TOD_AB, TOD_BIS = 60, 110     # Prüfer r1 (ab 52): Ausblenden begann noch im Fall, liegend nur 0,4 s; ab 60 fällt er bei 0,13–0,6 s
# Prüfer r1 (Blatt, Wolfspixel eigen/gekauft): grau 62/82, dunkel 44/73, rost 31/70, Unterbeine und Bauch fast weiß (Quelle dort
# hell; Leitbild „nie heller als alt“): Zeichnung nur noch von Sattel bis Fell (TMAX), Bauchfarbe nicht mehr; je Fell HELL
TMAX = float(os.environ.get('TMAX', '0.5'))
HELL = {'grau': 0.9, 'dunkel': 1.0, 'rost': 0.75, 'asche': 0.9}
# Biss nachgemessen (probe.gd SCHAU=ort SCHAU_MESS=1, lokal 27.10.): mit Schnauze am weitesten vorn minus 0,07 m blieb die Nase
# 0,04–0,08 m vor dem Rand der Heldin, zugebissen 0,77–1,03 s, Winkel +2 bis +5°: Abstand −0,06 m (Modell), Zeit, Winkel −4°
BISS_KORR = (-0.03, 0.8, -4.0)     # Prüfer r1: Kopf verschwindet am Rumpf der Heldin; Nase dort 0,01–0,05 m im Rand: 3 cm zurück
KOPF_KNOCHEN = ('neck_top', 'head', 'jaw', 'tongue', 'ear')
# Augen nach Lage im Netz (Ruhe, Quelle): erster Lauf färbte nach Farbe 4,9 % der Textur als Auge (das Fell der Quelle ist braun
# gesättigt); gemessen: Iris um (±0,047, −0,832, 0,890) m, Radius 0,010; darum ein weißer Ring (Lid, bis 0,019), wird dunkel
AUGEN = ((0.047, -0.832, 0.890), (-0.047, -0.832, 0.890))
IRIS, LID = 0.010, 0.019


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    t = sorted(glob.glob(os.path.join(KAUF, '**', 'Wolf_Rig.fbx'), recursive=True))
    if not t:
        sys.exit('Wolf_Rig.fbx nicht gefunden unter %s' % KAUF)
    d = os.path.dirname(os.path.dirname(t[0]))     # .../Animal pack deluxe
    return t[0], os.path.join(d, 'Animations'), os.path.join(d, 'Textures')


def importiere(fbx):
    vorher = {o.name for o in bpy.data.objects}
    bpy.ops.import_scene.fbx(filepath=fbx, use_anim=True, ignore_leaf_bones=True, automatic_bone_orientation=False)
    return [o for o in bpy.data.objects if o.name not in vorher]


def setze(rig, a):
    rig.animation_data.action = a
    if slot(a) is not None: rig.animation_data.action_slot = slot(a)


def gehalten(a, name, n):
    """Kopie von `a`, erstes Bild auf `n` Bilder gehalten (alle Schlüssel gleich), Bildbereich a0 .. a0 + n - 1."""
    h = a.copy(); h.name = name; h.use_fake_user = True
    a0 = h.frame_range[0]
    for lay in h.layers:
        for st in lay.strips:
            for cb in st.channelbags:
                for fc in cb.fcurves:
                    v = fc.evaluate(a0)
                    for kp in fc.keyframe_points:
                        kp.co[1] = v; kp.handle_left[1] = v; kp.handle_right[1] = v
    h.use_frame_range = True; h.frame_start, h.frame_end = a0, a0 + n - 1
    return h


def haltung(rig, a, fn):
    """Je Bild fn(t) -> (Versatz des Rumpfs in Welt-Metern (x links, y hinten, z oben), Nicken des Halses (Grad, + hebt den Kopf),
    Wenden des Halses (Grad, + nach links), Rollen des Rumpfs (Grad)); Pfoten bleiben, wo sie in `a` waren (Läufe neu gebeugt)."""
    setze(rig, a)
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    W = rig.matrix_world; W3i = W.to_3x3().inverted()
    ax = lambda v: (W3i @ Vector(v)).normalized()
    quer, hoch, laengs = ax((1, 0, 0)), ax((0, 0, 1)), ax((0, 1, 0))
    m_je_einheit = 1.0 / W.to_scale()[0]
    pb = rig.pose.bones; vl = bpy.context.view_layer
    com, hals = pb[COM], pb[HALS]
    alle = {n for b in BEINE for n in b}
    q = {}
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f)
        q[f] = {n: pb[n].matrix.copy() for n in alle | {COM, HALS}}
    gross = 0.0
    for f in range(a0, a1 + 1):
        bpy.context.scene.frame_set(f)
        d, nick, wend, roll = fn((f - a0) / max(1, a1 - a0))
        Q = q[f]
        h = Q[HALS].to_translation()
        R = Matrix.Rotation(math.radians(-nick), 4, quer) @ Matrix.Rotation(math.radians(wend), 4, hoch)
        hals.matrix = Matrix.Translation(h) @ R @ Matrix.Translation(-h) @ Q[HALS]
        c = Q[COM].to_translation()
        dv = (W3i @ Vector(d)) * 1.0
        com.matrix = Matrix.Translation(dv) @ Matrix.Translation(c) @ Matrix.Rotation(math.radians(roll), 4, laengs) @ Matrix.Translation(-c) @ Q[COM]
        vl.update()
        for o, m, u, p in BEINE:
            H0, K0, A0 = (Q[n].to_translation() for n in (o, m, u))
            H1 = pb[o].head.copy()
            K1 = _zwei_knochen(H1, A0, H0, K0)
            r = (K0 - H0).rotation_difference(K1 - H1).to_matrix().to_4x4()
            pb[o].matrix = Matrix.Translation(H1) @ r @ Matrix.Translation(-H0) @ Q[o]; vl.update()
            Ak = pb[u].head.copy()
            r = (Ak - K1).rotation_difference(A0 - K1).to_matrix().to_4x4()
            pb[m].matrix = Matrix.Translation(K1) @ r @ Matrix.Translation(-K1) @ pb[m].matrix; vl.update()
            for n in (u, p):
                pb[n].matrix = Q[n]; vl.update()
            gross = max(gross, (pb[p].head - Q[p].to_translation()).length / m_je_einheit)
        for n in alle | {COM, HALS}:
            pb[n].keyframe_insert('location', frame=f); pb[n].keyframe_insert('rotation_quaternion', frame=f)
    print('HALTUNG', a.name, a0, a1, 'Pfote höchstens %.3f m verrückt' % gross)


def stoss(t, an=0.22):
    """0 -> 1 schnell (bis an), dann weich zurück auf 0"""
    if t < an:
        u = t / an; return u * u * (3 - 2 * u)
    u = (t - an) / (1 - an); return 1 - u * u * (3 - 2 * u)


def tempo(rig, a):
    """Tempo (m/s, Quelle) gegen Fußgleiten: Strecke, die jede Pfote in der Schleife nach hinten (+Y) läuft, durch die Zeit dafür
    (Stützphase); erster Lauf 27.10.: „am Boden“ nach Höhe fand beim Rennen nur 1 Bild (die Pfote rollt ab)."""
    setze(rig, a); W = rig.matrix_world; pb = rig.pose.bones
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    v = []
    for s_ in 'lr':
        for l in ('FrontLeg', 'HindLeg'):
            y = []
            for f in range(a0, a1 + 1):
                bpy.context.scene.frame_set(f); y.append((W @ pb[J('%s_%s_Ball' % (s_, l))].head).y)
            d = np.diff(np.array(y)); hin = d[d > 0]
            if len(hin): v.append(hin.sum() / len(hin) * FPS)
    v = np.array(v)
    print('TEMPO', a.name, 'je Pfote m/s', ' '.join('%.3f' % x for x in v), 'Mittel %.3f' % v.mean())
    return float(v.mean())


def uv_masken(o):
    """Bildmasken (TEX²) aus UV, Gewichten und Lage: belegt, Kopf, Iris, Lid."""
    from PIL import Image, ImageDraw
    bel, kopf, iris, lid = (Image.new('L', (TEX, TEX), 0) for _ in range(4))
    db, dk, di, dl = (ImageDraw.Draw(m) for m in (bel, kopf, iris, lid))
    M = o.matrix_world; A = [Vector(c) for c in AUGEN]
    me = o.data; uv = me.uv_layers.active.data
    gname = {g.index: g.name.lower() for g in o.vertex_groups}
    kn = []
    for v in me.vertices:
        w = max(v.groups, key=lambda e: e.weight, default=None)
        kn.append(gname.get(w.group, '') if w else '')
    for p in me.polygons:
        pts = [(uv[i].uv[0] * TEX, (1 - uv[i].uv[1]) * TEX) for i in p.loop_indices]
        db.polygon(pts, fill=255)
        if sum(any(h in kn[v] for h in KOPF_KNOCHEN) for v in p.vertices) * 2 > len(p.vertices): dk.polygon(pts, fill=255)
        r = min((M @ p.center - c).length for c in A)
        if r < IRIS: di.polygon(pts, fill=255)
        elif r < LID: dl.polygon(pts, fill=255)
    return tuple(np.asarray(m) > 127 for m in (bel, kopf, iris, lid))


def bemalung(texdir, fell, masken, striche):
    """Eigene Bemalung: Helligkeit der gekauften Textur (mit AO) als Zeichnung, Sattel/Fell/Bauch in unseren Farben (wolf.py),
    Augen in unserer Augenfarbe, darüber unsere Fellstriche."""
    from PIL import Image, ImageFilter
    col = sorted(glob.glob(os.path.join(texdir, 'common_wolf_col*.tga')))[0]
    s = np.asarray(Image.open(col).convert('RGB').resize((TEX, TEX), Image.LANCZOS)).astype(np.float32) / 255.0
    ao = sorted(glob.glob(os.path.join(texdir, 'common_wolf_AO*.tga')))
    ao = np.asarray(Image.open(ao[0]).convert('L').resize((TEX, TEX), Image.LANCZOS)).astype(np.float32) / 255.0 if ao else np.ones((TEX, TEX), np.float32)
    bel, kopf, iris, lid = masken
    r, g, b = s[..., 0], s[..., 1], s[..., 2]
    mx, mn = s.max(-1), s.min(-1); sat = (mx - mn) / np.maximum(mx, 1e-4)
    L = 0.2126 * r + 0.7152 * g + 0.0722 * b
    # Iris in unserer Augenfarbe (Pupille: dunkel in der Quelle bleibt dunkel), Lid und Nase/Lefzen (am Kopf dunkel) fast schwarz
    auge = iris
    maul = lid & ~iris
    nase = kopf & ~iris & ~lid & (L < 0.18)
    fellm = bel & ~(auge | maul | nase)
    fl = L[fellm]
    p5, p50, p95 = np.percentile(fl, [5, 50, 95])
    print('BEMALUNG %s Quelle: Fell %.1f%% Iris %.3f%% Lid %.3f%% Nase %.3f%%, Helligkeit p5 %.3f p50 %.3f p95 %.3f' % (
        fell, 100 * fellm.sum() / bel.sum(), 100 * (auge & bel).sum() / bel.sum(), 100 * (maul & bel).sum() / bel.sum(),
        100 * (nase & bel).sum() / bel.sum(), p5, p50, p95))
    Lb = np.asarray(Image.fromarray((L * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(TEX / 64))).astype(np.float32) / 255.0
    fein = np.clip(L / np.maximum(Lb, 1e-3), 0.6, 1.5)
    grob = np.clip((Lb - p5) / max(p95 - p5, 1e-3), 0, 1)
    fu, sa, be, au = (lin(h) for h in COATS[fell])
    t = grob[..., None] * TMAX
    farbe = np.where(t < 0.5, sa + (fu - sa) * (t / 0.5), fu + (be - fu) * ((t - 0.5) / 0.5))
    farbe = farbe * fein[..., None] ** 1.3 * (0.35 + 0.65 * ao[..., None]) * HELL[fell] * float(os.environ.get('HELL', '1'))
    farbe = farbe * np.clip(striche, 0.3, 1.8)[..., None] ** 0.9
    weich = lambda m, rr: np.asarray(Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(rr))).astype(np.float32)[..., None] / 255.0
    if auge.any():     # Augenhöhle dunkel, weich auslaufend (wie kaufratte.py)
        ring = weich(np.asarray(Image.fromarray((auge * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(7))) > 127, 5)
        farbe = farbe * (1 - 0.5 * np.clip(ring * 1.6, 0, 1))
    farbe = np.where(nase[..., None], lin(0x161214) * np.clip(L / max(np.median(L[nase]) if nase.any() else 0.08, 1e-3), 0.6, 1.4)[..., None], farbe)
    farbe = np.where(maul[..., None], lin(0x161214), farbe)
    farbe = np.where(auge[..., None], au * np.clip(L / max(np.median(L[auge]) if auge.any() else 0.4, 1e-3), 0.1, 1.3)[..., None], farbe)
    farbe = np.where(bel[..., None], farbe, np.median(farbe[fellm], axis=0))     # Rand außerhalb der UV-Inseln (Mipmaps)
    out = (srgb(farbe) * 255).astype(np.uint8)
    p = os.path.join(OUT, '%s-bemalung-%s.png' % (ID, fell))
    Image.fromarray(out).save(p)
    return p


def baue(fell):
    fbx, adir, texdir = quelle()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene; scn.render.fps = FPS
    obs = importiere(fbx)
    rig = next(o for o in obs if o.type == 'ARMATURE')
    meshes = [o for o in obs if o.type == 'MESH']
    print('IMPORT', os.path.basename(fbx), 'Objekte', [(o.name, o.type) for o in obs], 'Knochen', len(rig.data.bones))
    tri0 = tris(meshes)
    akt = {}
    for q in QUELLEN:
        f = os.path.join(adir, 'Wolf_%s.fbx' % q)
        if not os.path.exists(f):
            print('FEHLT', f); continue
        n = importiere(f); a = aktion_von(n)
        if a is None:
            print('KEINE BEWEGUNG in', os.path.basename(f)); entferne(n); continue
        a.use_fake_user = True; a.name = 'q_' + q; akt[q] = a
        entferne(n)
        print('BEWEGUNG', q, 'Bilder', tuple(round(x, 1) for x in a.frame_range))
    rig.animation_data_create()
    # ------------------------------------------------ Maße aus der Ruhe der Quelle (Welt, Meter)
    setze(rig, akt['IdleA'])
    f0 = int(akt['IdleA'].frame_range[0])
    P = welt_netz(meshes, f0); lo, hi = P.min(0), P.max(0)
    pb = rig.pose.bones; Wr = rig.matrix_world
    ys = (Wr @ pb[J('Spine_02')].head).y
    widerrist = float(P[np.abs(P[:, 1] - ys) < 0.15][:, 2].max())     # Rücken über der Mitte, wie an wolf-grau.glb gemessen
    s = RUECKEN / widerrist
    pf = [(Wr @ pb[J('%s_%s_Ball' % (a_, l))].head) for a_ in 'lr' for l in ('FrontLeg', 'HindLeg')]
    rumpf_y = sum(p.y for p in pf) / 4
    print('MASS Quelle (Welt, Stehen): x %.3f y %.3f z %.3f, Rücken %.3f m, Pfoten Mitte y %.3f, Maßstab %.4f' % (
        hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], widerrist, rumpf_y, s))
    # ------------------------------------------------ Tempo der Pfoten (vor dem Ableiten), Biss: Zeitpunkt und Reichweite
    v_geh, v_renn = tempo(rig, akt['Walk']), tempo(rig, akt['Run'])
    setze(rig, akt['Attack'])
    a0, a1 = int(akt['Attack'].frame_range[0]), int(akt['Attack'].frame_range[1])
    zb = []
    for f in range(a0, a1 + 1):
        scn.frame_set(f); zb.append((Wr @ pb[J('Head_JawEnd')].head)[:])
    zb = np.array(zb); fb = int(np.argmin(zb[:, 1]))
    # ------------------------------------------------ abgeleitete Bewegungen aus der Ruhe (die Quelle hat keine)
    idle = akt['IdleA']
    akt['Hocke'] = gehalten(idle, 'Hocke', 31)     # Schleife 1 s: lauernd, Kopf tief vor
    haltung(rig, akt['Hocke'], lambda t: ((0, 0.04, -0.11), -14.0, 0.0, 0.0))
    akt['Treffer'] = gehalten(idle, 'Treffer', 15)     # 0,5 s: Ruck zurück, Kopf hoch und zur Seite
    haltung(rig, akt['Treffer'], lambda t: ((0, 0.07 * stoss(t), -0.04 * stoss(t)), 18.0 * stoss(t), -12.0 * stoss(t), 6.0 * stoss(t)))
    akt['Ausweichen'] = gehalten(idle, 'Ausweichen', 13)     # 0,4 s wie wolf.py: Rumpf zur Seite und tief, Kopf weg
    haltung(rig, akt['Ausweichen'], lambda t: ((0.15 * stoss(t, 0.35), 0.03 * stoss(t, 0.35), -0.07 * stoss(t, 0.35)), 6.0 * stoss(t, 0.35), 18.0 * stoss(t, 0.35), -10.0 * stoss(t, 0.35)))
    rig.animation_data.action = None
    # ------------------------------------------------ Bemalung: unsere Textur statt der gekauften
    ob = meshes[0]
    masken = uv_masken(ob)
    bild = bpy.data.images.load(bemalung(texdir, fell, masken, fellstriche(meshes, np.random.default_rng(23), np.zeros((TEX, TEX), bool))))
    mat = bpy.data.materials.new('%s-%s' % (ID, fell)); mat.use_nodes = True
    bs = mat.node_tree.nodes['Principled BSDF']; bs.inputs['Roughness'].default_value = 1.0
    im = mat.node_tree.nodes.new('ShaderNodeTexImage'); im.image = bild
    mat.node_tree.links.new(im.outputs['Color'], bs.inputs['Base Color'])
    for o in meshes:
        o.data.materials.clear(); o.data.materials.append(mat)
    # ------------------------------------------------ NLA-Spuren unter unseren Namen
    INFO = {'fps': FPS, 'fell': fell, 'dreiecke': tris(meshes), 'dreiecke_gekauft': tri0, 'quelle': 'Janpec Animal Pack Deluxe, Wolf (gekauft, 348.12f)'}
    def spur(nm, a, start=None, ende=None):
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'): st.action_slot = slot(a2)
        if start is not None:
            st.action_frame_start, st.action_frame_end = start, ende
        INFO[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
    for nm, q in (('Stehen', 'IdleA'), ('Gehen', 'Walk'), ('Rennen', 'Run'), ('Biss', 'Attack'), ('Sprung', 'Attack'),
                  ('Heulen', 'Howl'), ('Lefzen', 'IdleC'), ('Hocke', 'Hocke'), ('Treffer', 'Treffer'), ('Ausweichen', 'Ausweichen')):
        if q in akt: spur(nm, akt[q], *((akt[q].frame_start, akt[q].frame_end) if akt[q].use_frame_range else ()))
    if 'Die' in akt: spur('Tod', akt['Die'], TOD_AB, TOD_BIS)
    # ------------------------------------------------ Größe, Boden, Ursprung zwischen den Pfoten wie wolf.py (Blick ist schon -Y = glTF +Z);
    # so gelten Bodenschatten (Rumpfmitte 0,15 m vor dem Ursprung), Kopfhöhe und Grasfleck des Wolfs in figur.gd
    aussen = bpy.data.objects.new('Kaufwolf', None); scn.collection.objects.link(aussen)
    rig.parent = aussen
    aussen.scale = (s, s, s)
    aussen.location = (-(lo[0] + hi[0]) / 2 * s, -rumpf_y * s, -lo[2] * s)
    bpy.context.view_layer.update()
    setze(rig, idle)
    P = welt_netz(meshes, f0); lo2, hi2 = P.min(0), P.max(0)
    rig.animation_data.action = None
    INFO['hoehe_m'] = round(float(hi2[2] - lo2[2]), 3); INFO['laenge_m'] = round(float(hi2[1] - lo2[1]), 3)
    INFO['schulterhoehe_m'] = SCHULTER
    INFO['rumpf_vor_m'] = round(float(-(rumpf_y * s + aussen.location[1])), 3)     # Mitte der Pfoten vor dem Ursprung (glTF +Z)
    # Biss: Schnauze am weitesten vorn (Welt nach dem Maßstab); figur.gd BITE: Abstand Ursprung–Rand des Ziels (Schnauze 0,07 m im
    # Rand), Zeitpunkt, Drehung des Körpers (Grad, + links), damit die Schnauze aufs Ziel zeigt
    jx, jy = zb[fb, 0] * s + aussen.location[0], zb[fb, 1] * s + aussen.location[1]
    INFO['biss'] = [round(float(-jy - 0.07 + BISS_KORR[0]), 3), BISS_KORR[1], round(-math.degrees(math.atan2(jx, -jy)) + BISS_KORR[2], 1)]
    print('BISS Quelle: Schnauze vorn bei %.2f s' % (fb / FPS))
    # Wurzelweg je Bild [x, z] (Modellmeter, +Z vorn): gerade, im Tempo der Pfoten
    INFO['weg'] = {nm: [[0.0, round(v * s * i / FPS, 4)] for i in range(int(round(INFO[nm] * FPS)) + 1)] for nm, v in (('Gehen', v_geh), ('Rennen', v_renn))}
    print('MASS neu: breit %.3f lang %.3f hoch %.3f, Boden %.3f, Rumpf vor %.3f m; Gehen %.2f m/s, Rennen %.2f m/s; Biss %s' % (
        hi2[0] - lo2[0], hi2[1] - lo2[1], hi2[2] - lo2[2], lo2[2], INFO['rumpf_vor_m'], v_geh * s, v_renn * s, INFO['biss']))
    for alt, neu in UMBENENNEN.items():
        if alt in rig.data.bones: rig.data.bones[alt].name = neu
        else: print('FEHLT Knochen', alt)
    # ------------------------------------------------ Export
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, rig] + meshes: o.select_set(True)
    path = os.path.join(OUT, '%s-%s.glb' % (ID, fell))
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False, export_image_format='JPEG',
                              export_jpeg_quality=88)
    INFO['sekunden_bau'] = round(time.time() - T0, 1)
    print('GLB', path, os.path.getsize(path), {k: v for k, v in INFO.items() if k != 'weg'})
    return INFO


if __name__ == '__main__':
    names = [os.environ['FELL']] if os.environ.get('FELL') else list(COATS)
    info = {n: baue(n) for n in names}
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1)
    print('KAUFWOLF FERTIG %.1f s' % (time.time() - T0))
