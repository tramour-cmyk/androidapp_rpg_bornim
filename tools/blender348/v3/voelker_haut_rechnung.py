# 431 Runde 4, B1 (Pruefer Lauf 41439148830: Mensch, Elf, Zwerg, Huegelvolk kreideweiss, Gesicht RGB 240/237/236; Ork blass mint
# 221/233/229; Waesche ausgebleicht) ohne Bild nachrechnen: was der Toon-Shader (godot/shader/toon.gdshader, Zweig toen_hell > 0)
# als ALBEDO aus dem exportierten GLB macht, mit den Werten, die voelkerprobe.gd setzt (HeldFigur.toene, _eigene_haut).
# Liest die GLB selbst (kein Blender, kein Godot): je Primitive mit Hautmaterial (Regular, Superhero) Bild, UV, COLOR_0; Gesicht =
# Ecken im oberen Kopfbereich vorn. Zum Vergleich der Held (held_*.bin), der im Spiel nicht weiss ist.
#   python3 voelker_haut_rechnung.py <voelker-ordner> <godot/daten>
import io, json, struct, sys, glob, os
import numpy as np
from PIL import Image

EICHUNG = np.array([1.145, 0.96, 0.97])   # HeldFigur.HAUT_EICHUNG
FARBE = 0.5                               # HeldFigur.HAUT_FARBE (toen_farbe)
LUM = np.array([0.2126, 0.7152, 0.0722])
ENUM = {"Mensch": "HUMAN", "Elf": "ELF", "Zwerg": "DWARF", "Hügelvolk": "HALFLING", "Orkblütiger": "HALF_ORC"}


def lin(c):
    c = np.asarray(c, dtype=np.float64)
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def srgb(c):
    c = np.clip(np.asarray(c, dtype=np.float64), 0, None)
    return np.where(c <= 0.0031308, c * 12.92, 1.055 * np.power(c, 1 / 2.4) - 0.055)


def glb(pfad):
    d = open(pfad, 'rb').read()
    n = struct.unpack_from('<I', d, 12)[0]
    j = json.loads(d[20:20 + n])
    b = d[20 + n + 8:]
    return j, b


TYP = {5126: ('<f4', 4), 5121: ('<u1', 1), 5123: ('<u2', 2), 5125: ('<u4', 4), 5120: ('<i1', 1), 5122: ('<i2', 2)}
ANZ = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}


def zugriff(j, b, i):
    a = j['accessors'][i]
    bv = j['bufferViews'][a['bufferView']]
    dt, gr = TYP[a['componentType']]
    k = ANZ[a['type']]
    off = bv.get('byteOffset', 0) + a.get('byteOffset', 0)
    st = bv.get('byteStride', 0) or gr * k
    roh = np.frombuffer(b, dtype=np.uint8, count=st * (a['count'] - 1) + gr * k, offset=off)
    x = np.lib.stride_tricks.as_strided(roh, shape=(a['count'], gr * k), strides=(st, 1)).copy().view(dt).reshape(a['count'], k)
    x = x.astype(np.float64)
    if a.get('normalized') or (a['componentType'] in (5121, 5123) and k == 4):
        x /= 255.0 if a['componentType'] == 5121 else 65535.0
    return x


def bild(j, b, mat):
    pb = j['materials'][mat].get('pbrMetallicRoughness', {})
    t = pb.get('baseColorTexture')
    if t is None: return None, pb.get('baseColorFactor')
    im = j['images'][j['textures'][t['index']]['source']]
    bv = j['bufferViews'][im['bufferView']]
    roh = b[bv.get('byteOffset', 0): bv.get('byteOffset', 0) + bv['byteLength']]
    pi = Image.open(io.BytesIO(roh))
    print('  BILDDATEI %s, Modus %s, Format %s, Infos %s, PNG-Kopf Bittiefe %s Farbtyp %s' % (im.get('mimeType'), pi.mode, pi.format,
          sorted(pi.info.keys()), roh[24] if roh[:4] == b'\x89PNG' else '-', roh[25] if roh[:4] == b'\x89PNG' else '-'))
    return np.asarray(pi.convert('RGB'), dtype=np.float64) / 255.0, pb.get('baseColorFactor')


def shader(tex_srgb, col, toenung, toen_bild, toen_hell):
    a = lin(tex_srgb) * col                                  # ALBEDO = texture(tex, UV).rgb * COLOR.rgb (source_color: linear)
    hl = np.maximum(a @ LUM, 0.001)[:, None]
    rel = (a / hl) / np.maximum(toen_bild / toen_hell, 0.001)
    return toenung * hl / toen_hell * (1 - FARBE + FARBE * rel)


def zeile(name, x):
    m = np.median(x, axis=0)
    return '%s lin %s sRGB %s' % (name, np.round(m, 3).tolist(), np.round(srgb(m) * 255).astype(int).tolist())


def pruefe(pfad, toen_srgb, bezug_srgb, titel):
    j, b = glb(pfad)
    tb = lin(bezug_srgb)
    th = max(0.01, float(tb @ LUM))
    tz = lin(toen_srgb) * EICHUNG
    print('RECHNUNG %s (%s): Zielton %s, Bezug %s (toen_hell %.3f)' % (titel, os.path.basename(pfad), toen_srgb.tolist() if hasattr(toen_srgb, 'tolist') else toen_srgb, bezug_srgb, th))
    for me in j.get('meshes', []):
        for p in me['primitives']:
            mi = p.get('material')
            mn = j['materials'][mi].get('name', '') if mi is not None else ''
            if not ('Regular' in mn or 'Superhero' in mn) or mn.startswith(('Eye', 'Hair')): continue
            at = p['attributes']
            print('  NETZ %s Material %s: Attribute %s' % (me.get('name'), mn, sorted(at)))
            pos = zugriff(j, b, at['POSITION'])
            uv = zugriff(j, b, at['TEXCOORD_0']) if 'TEXCOORD_0' in at else None
            col = zugriff(j, b, at['COLOR_0'])[:, :3] if 'COLOR_0' in at else np.ones((len(pos), 3))
            tex, fak = bild(j, b, mi)
            print('  BILD %s, baseColorFactor %s, UV %s' % (None if tex is None else tex.shape, fak,
                  'fehlt' if uv is None else 'u %.3f-%.3f v %.3f-%.3f, verschieden %d' % (uv[:, 0].min(), uv[:, 0].max(), uv[:, 1].min(), uv[:, 1].max(), len(np.unique(np.round(uv, 4), axis=0)))))
            if 'COLOR_0' in at: print('  ' + zeile('COLOR_0 (alle Ecken)', col))
            if tex is None or uv is None: continue
            H, W = tex.shape[:2]
            px = tex[(np.mod(uv[:, 1], 1) * H).astype(int) % H, (np.mod(uv[:, 0], 1) * W).astype(int) % W]
            h = pos[:, 1]
            hmax, hmin = h.max(), h.min()
            # Gesicht: oberste 9 % bis 4 % der Hoehe (Kinn bis Augen etwa), vorn (+Z, Blickrichtung im glTF)
            kopf = (h > hmax - 0.09 * (hmax - hmin)) & (h < hmax - 0.04 * (hmax - hmin))
            vorn = pos[:, 2] > np.median(pos[kopf, 2]) if kopf.any() else np.zeros(len(pos), bool)
            ges = kopf & vorn
            # Becken: Waesche (Hoehe 45-55 %)
            bec = (h > hmin + 0.45 * (hmax - hmin)) & (h < hmin + 0.55 * (hmax - hmin))
            for nm, sel in (('Gesicht', ges), ('Becken', bec)):
                if not sel.any(): print('  %s: keine Ecken' % nm); continue
                print('  %s (%d Ecken): %s | %s | %s' % (nm, sel.sum(), zeile('Bild', lin(px[sel])), zeile('Bild*COLOR', lin(px[sel]) * col[sel]),
                      zeile('ALBEDO', shader(px[sel], col[sel], tz, tb, th))))


def main():
    vd, dd = sys.argv[1], sys.argv[2]
    held = json.load(open(os.path.join(dd, 'held.json')))
    hk = json.load(open(os.path.join(dd, 'held-klassen.json')))
    v = json.load(open(os.path.join(vd, 'voelker.json')))
    def ton(volk, i): return np.array(Image.new('RGB', (1, 1), '#' + held['voelker'][volk]['haut'][i]['rgb']).getpixel((0, 0))) / 255.0
    def gi(g): return hk.get('geschlechter', {}).get(g.upper(), hk)   # HeldFigur.geschlecht_info
    for e in v['voelker']:
        g = 'w' if e['frau'] else 'm'
        bezug = e.get('haut_bild') or gi(g).get('haut_bild') or [1, 1, 1]
        pruefe(os.path.join(vd, e['datei']), ton(ENUM[e['volk']], 0), bezug, '%s %s Hautton 0' % (e['volk'], g))
    for f in sorted(glob.glob(os.path.join(dd, 'held_*.bin')))[:1]:
        bezug = gi('m').get('haut_bild') or [1, 1, 1]
        pruefe(f, ton('HUMAN', 1), bezug, 'Held Mensch m Hautton 1')
    print('SCHLUESSEL held-klassen.json:', list(hk)[:12])


main()
