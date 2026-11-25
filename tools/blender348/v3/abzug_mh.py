# 2034 Teil 0 (Chef 25.11., 17:27; Sokrates 17:29): Abzug aller Stuecke der MakeHuman-Pakete mit Votum ja oder ~ (LISTE-QUELLEN.md
# „MakeHuman-Asset-Packs“), ein Skript fuer alle, kein Handgriff je Stueck. Nur fuer den Abzug, nie ins Spiel, .glb nie einchecken.
# Je Stueck (.mhclo mit .obj und .mhmat): .obj in Metern (MakeHuman rechnet in Dezimetern), Blick +Z, Y oben, nicht ausgeduennt;
# Paketbild aus der .mhmat (diffuseTexture), hoechstens 2048 px. Haar und Bart in Grau wie kopfteil_mh.py (Gamma 0,4, halb gespannt,
# Fehler 431 zopf_431: nie linear aufhellen); alles andere in eigener Farbe, Hell und Dunkel halb gespannt wie der Helm in kopfteil_mh.py.
# Alpha bleibt (glTF MASK, toon „schnitt“). Haeute (nur .mhmat): Bild verkleinert auf 1024 px als PNG, kein Netz (hm08-UV, Weg H erst 2031).
# Ausgabe: <aus>/<Nummer>.glb bzw. <Nummer>_haut.png und <aus>/liste.json (je Stueck Nummer, Paket, Name, Art, Lizenz, Urheber,
# Dreiecke, Bildgroesse, Datei).
# Aufruf: bl/bin/python -I tools/blender348/v3/abzug_mh.py <ordner mit ausgepackten Paketen je Nr. (M27/...)> <aus> [<Nummer,...>]
import sys, os, glob, json, re
import numpy as np
from PIL import Image
import bpy, subprocess, tempfile
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

def oeffne(p):
    # einige Paketbilder liest PIL nicht (Pruefsumme); dann ueber ImageMagick neu geschrieben
    try:
        im = Image.open(p); im.load(); return im
    except Exception:
        t = tempfile.mktemp(suffix='.png'); subprocess.run(['convert', p, t], check=True); return Image.open(t)

PAKETE, AUS = sys.argv[1], sys.argv[2]
NUR = set(sys.argv[3].split(',')) if len(sys.argv) > 3 and sys.argv[3] else None
# Paketnummer aus LISTE-QUELLEN.md -> Paketname; Art fuer Bild und Liste
PAKET = {'M1': 'makehuman_system_assets', 'M15': 'skins01', 'M16': 'skins02', 'M17': 'skins03', 'M20': 'bodyparts05', 'M21': 'dress01',
         'M26': 'gloves01', 'M27': 'hair01', 'M29': 'hats02', 'M31': 'pants01', 'M34': 'skirts01', 'M36': 'suits02', 'M41': 'bodyparts06',
         'M42': 'dress02', 'M43': 'dress03', 'M47': 'hats03', 'M48': 'hats04', 'M49': 'hair02', 'M50': 'hair03', 'M51': 'masks02',
         'M54': 'shirts02', 'M57': 'shoes03'}
ART = {'M1': 'Haar', 'M15': 'Haut', 'M16': 'Haut', 'M17': 'Haut', 'M20': 'Bart', 'M21': 'Kleid', 'M26': 'Handschuhe', 'M27': 'Haar',
       'M29': 'Helm', 'M31': 'Hose', 'M34': 'Rock', 'M36': 'Ganzanzug', 'M41': 'Bart', 'M42': 'Kleid', 'M43': 'Kleid', 'M47': 'Hut',
       'M48': 'Helm', 'M49': 'Haar', 'M50': 'Haar', 'M51': 'Maske', 'M54': 'Oberteil', 'M57': 'Stiefel'}
GRAU = {'Haar', 'Bart'}
PAARE = {'Stiefel', 'Handschuhe'}

def paar_enger(W, F):
    # 2034-Ue6 (Planer 19:01: Stueck fuellt die Hoehe, auch Paare): die Teile links und rechts (zusammenhaengende Netzteile, Mitte
    # links bzw. rechts von x = 0) zur Mitte schieben, bis 2 cm Luft bleiben; nur Abzug, nur Stiefel und Handschuhe
    eltern = list(range(len(W)))
    def wurzel(i):
        while eltern[i] != i:
            eltern[i] = eltern[eltern[i]]; i = eltern[i]
        return i
    for f in F:
        for a, _ in f[1:]: eltern[wurzel(a)] = wurzel(f[0][0])
    r = np.array([wurzel(i) for i in range(len(W))])
    links = np.zeros(len(W), bool)
    for k in np.unique(r): links[r == k] = W[r == k, 0].mean() < 0
    if links.all() or not links.any(): return W
    luft = W[~links, 0].min() - W[links, 0].max()
    if luft <= 0.02: return W
    W = W.copy()
    W[links, 0] += (luft - 0.02) / 2
    W[~links, 0] -= (luft - 0.02) / 2
    print('ABZUG Paar enger: %.3f m Luft -> 0,02 m' % luft)
    return W
BILD = 2048

def kopf(p):
    # Kopfzeilen der .mhclo/.mhmat: name, author, license, obj_file, material, diffuseTexture
    d = {}
    for z in open(p, errors='ignore'):
        q = z.strip()
        if q.startswith('#'): q = q.lstrip('#').strip()
        m = re.match(r'^(name|author|license|obj_file|material|diffuseTexture)\s+(.*)$', q)
        if m and m.group(1) not in d: d[m.group(1)] = m.group(2).strip()
        if z.startswith('verts'): break
    return d

def lies_obj(p):
    V, VT, F = [], [], []
    for z in open(p, errors='ignore'):
        q = z.split()
        if not q: continue
        if q[0] == 'v': V.append([float(x) for x in q[1:4]])
        elif q[0] == 'vt': VT.append([float(x) for x in q[1:3]])
        elif q[0] == 'f': F.append([tuple(int(i) - 1 if i else -1 for i in (s.split('/') + [''])[:2]) for s in q[1:]])
    return np.array(V), VT, F

def finde(ordner, name):
    # Dateiname aus der .mhclo/.mhmat, relativ zum Ordner oder irgendwo im Paket (Gross/klein egal)
    if not name: return None
    p = os.path.join(ordner, name)
    if os.path.exists(p): return p
    b = os.path.basename(name).lower()
    for w, _, fs in os.walk(ordner):
        for f in fs:
            if f.lower() == b: return os.path.join(w, f)
    return None

def bild(pfad, art, ziel):
    a = np.asarray(oeffne(pfad).convert('RGBA')).astype(float) / 255
    deck = a[..., 3] > 0.5
    if not deck.any(): deck = np.ones(deck.shape, bool)
    if art in GRAU:
        t = (a[..., :3].mean(2) + 0.004) ** 0.4
        t /= t[deck].mean()
        g = np.clip(0.545 * (0.5 + 0.5 * t), 0, 1)
        a = np.dstack([g, g, g, a[..., 3]])
    else:
        l = a[..., :3].mean(2, keepdims=True)
        a[..., :3] = np.clip(a[..., :3] * (0.5 * l[deck].mean() / np.maximum(l, 0.02) + 0.5), 0, 1)
    alpha = bool((a[..., 3] < 0.5).any())
    im = Image.fromarray((a * 255).astype(np.uint8), 'RGBA')
    if not alpha: im = im.convert('RGB')
    f = min(1.0, BILD / max(im.size))
    im = im.resize((max(1, round(im.size[0] * f)), max(1, round(im.size[1] * f))), Image.LANCZOS)
    im.save(ziel)
    return alpha

def glb(nr, V, VT, F, bildpfad, alpha, ziel):
    for o in list(bpy.data.objects): bpy.data.objects.remove(o)
    for m in list(bpy.data.meshes): bpy.data.meshes.remove(m)
    for m in list(bpy.data.materials): bpy.data.materials.remove(m)
    for i in list(bpy.data.images): bpy.data.images.remove(i)
    W = V * 0.1   # Dezimeter -> Meter
    W = paar_enger(W, F) if ART[nr.split('-')[0]] in PAARE else W
    me = bpy.data.meshes.new(nr)
    me.from_pydata([(x, -z, y) for x, y, z in W], [], [[i for i, _ in f] for f in F])   # Blender Z oben, Blick -Y
    # 2034-Ue6 (Pruefer 18:42, Pixelbloecke im Leder M57-09): from_pydata legt Flaechen flach an (je Flaeche eine Normale); im
    # Toon-Licht wurde jedes Viereck ein eigener Tonblock (Beleg docs/entwurf/2034-abzug/probe/M57-09_bloecke.webp). Die .obj der
    # Pakete haben keine Normalen (vn) und keine Glaettgruppen: glatt wie MakeHuman
    me.shade_smooth()
    uv = me.uv_layers.new()
    for poly in me.polygons:
        for li, (_, ti) in zip(poly.loop_indices, F[poly.index]):
            uv.data[li].uv = VT[ti] if 0 <= ti < len(VT) else (0, 0)
    mat = bpy.data.materials.new('Abzug_' + nr)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Roughness'].default_value = 1.0
    bsdf.inputs['Metallic'].default_value = 0.0
    if bildpfad:
        tx = mat.node_tree.nodes.new('ShaderNodeTexImage')
        tx.image = bpy.data.images.load(bildpfad)
        mat.node_tree.links.new(tx.outputs['Color'], bsdf.inputs['Base Color'])
        if alpha:
            ma = mat.node_tree.nodes.new('ShaderNodeMath')
            ma.operation = 'GREATER_THAN'
            ma.inputs[1].default_value = 0.5
            mat.node_tree.links.new(tx.outputs['Alpha'], ma.inputs[0])
            mat.node_tree.links.new(ma.outputs[0], bsdf.inputs['Alpha'])
    me.materials.append(mat)
    ob = bpy.data.objects.new(nr, me)
    bpy.context.scene.collection.objects.link(ob)
    bpy.ops.export_scene.gltf(filepath=ziel, export_format='GLB', export_image_format='AUTO', export_apply=True)
    return W

os.makedirs(AUS, exist_ok=True)
liste = []
for pn in sorted(PAKET, key=lambda s: int(s[1:])):
    wurzel = os.path.join(PAKETE, pn)
    if not os.path.isdir(wurzel):
        print('ABZUG %s fehlt (%s)' % (pn, PAKET[pn])); continue
    art = ART[pn]
    if art == 'Haut':
        stuecke = sorted(p for p in glob.glob(os.path.join(wurzel, '**', '*.mhmat'), recursive=True) if '/skins/' in p.replace('\\', '/'))
    else:
        stuecke = sorted(glob.glob(os.path.join(wurzel, '**', '*.mhclo'), recursive=True))
        if pn == 'M1':   # nur die Haare des Systempakets (Votum: Augen, Zaehne, Zunge weggelassen, Sokrates 17:21)
            stuecke = [p for p in stuecke if '/hair/' in p.replace('\\', '/')]
    pj = {}
    for j in glob.glob(os.path.join(wurzel, 'packs', '*.json')):
        try: pj.update(json.load(open(j, errors='ignore')))
        except Exception: pass
    for i, p in enumerate(stuecke, 1):
        nr = '%s-%02d' % (pn, i)
        k = kopf(p)
        ordner = os.path.dirname(p)
        e = dict(nummer=nr, paket=PAKET[pn], art=art, datei=os.path.relpath(p, wurzel), name=k.get('name', os.path.splitext(os.path.basename(p))[0]),
                 urheber=k.get('author', ''), lizenz_kopf=k.get('license', ''), dreiecke=0, bild='', alpha=False, glb='', fehler='')
        js = pj.get(os.path.basename(ordner), {}) if isinstance(pj.get(os.path.basename(ordner), {}), dict) else {}
        e['lizenz_json'] = js.get('license', '')
        if js.get('author') and not e['urheber']: e['urheber'] = js['author']
        if NUR and nr not in NUR: liste.append(e); continue
        try:
            if art == 'Haut':
                tp = finde(ordner, k.get('diffuseTexture'))
                if not tp: raise RuntimeError('Hautbild fehlt')
                im = oeffne(tp)
                e['bild'] = '%dx%d' % im.size
                z = os.path.join(AUS, nr + '_haut.png')
                im.convert('RGB').resize((1024, round(1024 * im.size[1] / im.size[0])), Image.LANCZOS).save(z)
                e['glb'] = os.path.basename(z)
            else:
                op = finde(ordner, k.get('obj_file')) or (glob.glob(os.path.join(ordner, '*.obj')) or [None])[0]
                if not op: raise RuntimeError('obj fehlt')
                V, VT, F = lies_obj(op)
                e['dreiecke'] = int(sum(len(f) - 2 for f in F))
                mp = finde(ordner, k.get('material')) or (glob.glob(os.path.join(ordner, '*.mhmat')) or [None])[0]
                mk = kopf(mp) if mp else {}
                if not e['lizenz_kopf'] and mk.get('license'): e['lizenz_kopf'] = mk['license']
                tp = finde(os.path.dirname(mp) if mp else ordner, mk.get('diffuseTexture'))
                bp = None
                if tp:
                    e['bild'] = '%dx%d' % oeffne(tp).size
                    bp = os.path.join(AUS, '_bild_%s.png' % nr)
                    e['alpha'] = bild(tp, art, bp)
                z = os.path.join(AUS, nr + '.glb')
                W = glb(nr, V, VT, F, bp, e['alpha'], z)
                if bp: os.remove(bp)
                e['glb'] = os.path.basename(z)
                e['hoehe_m'] = round(float(np.ptp(W[:, 1])), 3)
        except Exception as x:
            e['fehler'] = str(x)[:200]
        print('ABZUG %s %s %s: %s, Dreiecke %d, Bild %s, Alpha %s %s' % (nr, e['paket'], e['name'], e['art'], e['dreiecke'], e['bild'], e['alpha'], e['fehler']))
        liste.append(e)
json.dump(liste, open(os.path.join(AUS, 'liste.json'), 'w'), ensure_ascii=False, indent=1)
print('ABZUG fertig: %d Stuecke, %d mit Fehler' % (len(liste), sum(1 for e in liste if e['fehler'])))
