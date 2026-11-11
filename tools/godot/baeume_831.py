#!/usr/bin/env python3
# 831 (Chef 10.11., 09:10, ueber Sokrates): Bildtafel Baeume aus dem freien Stylized Nature MegaKit (Quaternius, CC0 1.0,
# License_Standard.txt im Paket; cc0_laden.sh). Signatur Farbe: gedaempfte Toene aus unserer Palette statt der grellen Bausatzfarben.
# Die Blattkarten liegen im Paket auch weiss (Leaves_*.png, nur Deckkraft); wir toenen sie mit unserem Laub (dorf.py LEAF_L,
# pine_col) wie unsere Baeume ueber Eckfarben und nehmen die gemalte Zeichnung der bunten Fassung (_C) als Helligkeit. Rinde wie tex.py.
# Schreibt eine Kopie der gewaehlten glTF mit den getoenten Bildern nach <ziel>; das Godot-Probeskript tests/baeume_831.gd laedt sie.
# Aufruf: ~/bl/bin/python -I tools/godot/baeume_831.py [<cc0-ordner>] [<ziel>]
import json, os, shutil, sys
import numpy as np
from PIL import Image

CC0 = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser('~/cc0')
ZIEL = sys.argv[2] if len(sys.argv) > 2 else '/home/user/r831/baeume'
SRC = os.path.join(CC0, 'stylized-nature-megakit', 'glTF')
WAHL = {'CommonTree': (1, 3, 5), 'DeadTree': (1, 3, 5), 'Pine': (1, 3, 5), 'TwistedTree': (1, 3, 5)}
# Blattbild: Mittelwert wie unser Laubbild (tex.py laub 121/138/85, laub_nadel 88/151/105), Zeichnung aus der bunten Fassung;
# die Farbe kommt wie bei unseren Baeumen aus den Eckfarben (dorf.py oak_crown, spruce: dunkel 0,28 bis hell nach Normale und Hoehe)
BLATT = {'Leaves_NormalTree_C.png': (121, 138, 85), 'Leaf_Pine_C.png': (88, 151, 105), 'Leaves_TwistedTree_C.png': (121, 138, 85)}
RINDE = {'Bark_NormalTree.png': (54, 45, 35), 'Bark_DeadTree.png': (50, 46, 42), 'Bark_TwistedTree.png': (50, 44, 38)}   # wie tex.py rinde
LICHT = {'Leaves_NormalTree': (0.16, 0.25, 0.08), 'Leaves_TwistedTree': (0.11, 0.13, 0.065)}   # dorf.py LEAF_L; verdreht duester olivgrau

def blatt(name, col):
    c = np.asarray(Image.open(os.path.join(SRC, name)).convert('RGBA')).astype(np.float32)
    a = c[..., 3]
    lum = c[..., :3] @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    m = a > 128
    rel = np.clip(lum / max(1e-3, float(lum[m].mean())), 0.0, 3.0)
    rel = np.clip(1.0 + (rel - 1.0) * 1.8, 0.3, 1.7)   # Zeichnung kraeftiger, wie die Streuung unseres Laubbilds
    out = np.empty_like(c)
    out[..., :3] = np.clip(np.array(col, np.float32)[None, None, :] * rel[..., None], 0, 255)
    out[..., 3] = a
    Image.fromarray(out.astype(np.uint8), 'RGBA').save(os.path.join(ZIEL, name))
    print('BLATT', name, 'Mittel', out[..., :3][m].mean(0).round().tolist())

def rinde(name, col):
    c = np.asarray(Image.open(os.path.join(SRC, name)).convert('RGB')).astype(np.float32)
    lum = (c @ np.array([0.2126, 0.7152, 0.0722], np.float32))[..., None]
    out = np.clip(np.array(col, np.float32) * lum / float(lum.mean()), 0, 255)
    Image.fromarray(out.astype(np.uint8), 'RGB').save(os.path.join(ZIEL, name))
    print('RINDE', name, 'Mittel', out.reshape(-1, 3).mean(0).round().tolist())

def ss(a, b, x): t = np.clip((x - a) / (b - a), 0, 1); return t * t * (3 - 2 * t)

def eckfarben(g, buf, f):
    """COLOR_0 je Ecke wie dorf.py (Blender z oben, y Norden; glTF y oben, z = -y): Laub oak_crown.col, Nadeln pine_col, Rinde
    dunkler am Fuss; haengt die Farben an den Puffer an"""
    acc, bvs = g['accessors'], g['bufferViews']
    def lies(i):
        a = acc[i]; bv = bvs[a['bufferView']]; o = bv.get('byteOffset', 0) + a.get('byteOffset', 0)
        return np.frombuffer(buf, np.float32, a['count'] * 3, o).reshape(-1, 3)
    neu = bytearray(buf)
    for me in g['meshes']:
        for p in me['primitives']:
            mat = g['materials'][p['material']]['name']
            P = lies(p['attributes']['POSITION']); N = lies(p['attributes']['NORMAL'])
            gx, gy, gz = N[:, 0], N[:, 1], N[:, 2]
            if mat.startswith('Leaves_Pine'):
                lit = np.maximum(0, gy) * 0.55 + 0.45 * np.maximum(0, gx * 0.55 + gz * 0.7)
                col = np.array((0.05, 0.075, 0.07)) + (np.array((0.2, 0.26, 0.24)) - np.array((0.05, 0.075, 0.07))) * lit[:, None]
            elif mat.startswith('Leaves'):
                light = np.array(LICHT[mat]); dark = light * 0.28
                y0, y1 = P[:, 1].min(), P[:, 1].max()
                lit = np.maximum(0, gx * 0.55 + gz * 0.2 + gy * 0.7) * 0.75 + 0.25 * ss(y0, y1, P[:, 1])
                col = dark + (light - dark) * lit[:, None]
            else:
                col = np.repeat((0.7 + 0.3 * ss(0.0, 0.6, P[:, 1]))[:, None], 3, 1)
            col = np.clip(col, 0, 1).astype(np.float32)
            while len(neu) % 4: neu.append(0)
            bvs.append(dict(buffer=0, byteOffset=len(neu), byteLength=col.nbytes)); neu += col.tobytes()
            acc.append(dict(bufferView=len(bvs) - 1, componentType=5126, count=len(col), type='VEC3'))
            p['attributes']['COLOR_0'] = len(acc) - 1
    g['buffers'][0]['byteLength'] = len(neu)
    open(os.path.join(ZIEL, f + '.bin'), 'wb').write(bytes(neu))

os.makedirs(ZIEL, exist_ok=True)
for n, col in BLATT.items(): blatt(n, col)
for n, col in RINDE.items(): rinde(n, col)
liste = []
for art, vs in WAHL.items():
    for v in vs:
        f = '%s_%d' % (art, v)
        g = json.load(open(os.path.join(SRC, f + '.gltf')))
        acc = g['accessors']
        tri = sum(acc[p['indices']]['count'] // 3 for m in g['meshes'] for p in m['primitives'])
        lo = [min(acc[p['attributes']['POSITION']]['min'][i] for m in g['meshes'] for p in m['primitives']) for i in range(3)]
        hi = [max(acc[p['attributes']['POSITION']]['max'][i] for m in g['meshes'] for p in m['primitives']) for i in range(3)]
        # Normalenbilder weg: der Spielshader (toon) liest sie nicht, Godot muesste sie nur laden
        for mat in g.get('materials', []): mat.pop('normalTexture', None)
        for im in g.get('images', []):
            if not os.path.exists(os.path.join(ZIEL, im['uri'])): shutil.copy(os.path.join(SRC, im['uri']), ZIEL)
        eckfarben(g, open(os.path.join(SRC, f + '.bin'), 'rb').read(), f)
        json.dump(g, open(os.path.join(ZIEL, f + '.gltf'), 'w'))
        liste.append(dict(datei=f + '.gltf', art=art, variante=v, dreiecke=tri, hoehe=round(hi[1] - lo[1], 2),
                          breite=round(max(hi[0] - lo[0], hi[2] - lo[2]), 2), flaechen=len(g['materials'])))
        print('BAUM', f, tri, 'Dreiecke', liste[-1]['hoehe'], 'm hoch')
json.dump(liste, open(os.path.join(ZIEL, 'baeume.json'), 'w'), indent=1)
