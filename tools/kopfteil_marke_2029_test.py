#!/usr/bin/env python3
# 2029 Bildherkunft (Auftrag 26.11., 08:59; docs/entwurf/2029-bildherkunft.md): kein Bild aus einem MakeHuman-Paket mit Marke im Spiel.
# Je Paketbild aus Punkt 2 ein Fingerabdruck (dHash 16x16 nach Helligkeitsausgleich, 256 Bit; aus den Paket-Zips am 26.11. gerechnet,
# die Bilder selbst liegen nicht im Repo). Geprüft wird jedes Bild in godot/figuren (png, jpg) und jedes Bild in einer .glb dort:
# Abstand zu einem Paketbild <= GRENZE heißt „stammt aus diesem Bild“ (gemessen 26.11.: Spielbild zum eigenen Paketbild 3 bis 11 Bit,
# zu fremden 104 bis 142; das alte Helmbild 08510eeb4 zu casco.jpg 8).
#   verboten: Marke einer fremden Seite, Herkunft unbelegt -> Fehler
#   frage:    Marke, Entscheid offen (Frage in 2029) -> nur gemeldet
#   ausnahme: Marke geprüft und erlaubt (Grund im Text) -> nur gemeldet
#   frei:     keine Marke gefunden (Ecken angesehen 26.11.)
# Aufruf im Hauptordner: python3 tools/kopfteil_marke_2029_test.py [bild …]  (mit Bildern: nur diese prüfen, etwa als Gegenbeweis)
import io, json, os, struct, sys
import numpy as np
from PIL import Image, ImageOps

GRENZE = 40
PAKET = {
    'casco.jpg (hats02, Helm_Templer)': ('verboten', 'f1e0fde0fe60fe60fd40df80ff00ff00fd80fd80ff10fe00fe00fe90fc90fa90',
                                         'Marke „http://gallery.world/wallpaper/100982.html“ unten links, Herkunft unbelegt'),
    'braid01_diffuse_black.png (hair01, Zopf_Zwergin)': ('ausnahme', 'e52ac9e64b38e52c1b6cdbdcd994d3e8c3a88f12ccb6961cc66947c8d2c0f2c6',
                                         'Marke „(CC0-Zeichen) www.makehuman.org“ oben links; geprüfte Ausnahme (Sokrates 26.11., 16:51, 2029-Ü32 A): CC0 verlangt nichts, Ecke außerhalb jeder Bildkoordinate des Zopfs (0 von 8.491), im Spiel unsichtbar'),
    'diffuse_black.png (hair01, Haar_MH01)': ('frei', '3a613a67144635164936b834987e886b2c6d4d8679803099389a5998191a3974', ''),
    'BeardViking.png (bodyparts05, Bart_Wikinger)': ('frei', 'a05890f988b18171a0f2e6d2c1d2c142c9246166390619962066211620162016', ''),
}
ORDNER = 'godot/figuren'

def dhash(im):
    g = np.asarray(ImageOps.equalize(im.convert('L')).resize((17, 16), Image.LANCZOS), float)
    return (g[:, 1:] > g[:, :-1]).ravel()

def glb_bilder(p):
    d = open(p, 'rb').read()
    n = struct.unpack('<I', d[12:16])[0]
    j = json.loads(d[20:20 + n])
    b = d[20 + n + 8:]
    for i, im in enumerate(j.get('images', [])):
        if 'bufferView' not in im: continue
        bv = j['bufferViews'][im['bufferView']]
        o = bv.get('byteOffset', 0)
        yield '%s#%d' % (p, i), Image.open(io.BytesIO(b[o:o + bv['byteLength']]))

def bilder(pfade):
    for p in pfade:
        if p.endswith('.glb'): yield from glb_bilder(p)
        elif p.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')): yield p, Image.open(p)

def main():
    pfade = sys.argv[1:] or sorted(os.path.join(ORDNER, f) for f in os.listdir(ORDNER))
    ref = {k: (s, np.unpackbits(np.frombuffer(bytes.fromhex(h), np.uint8)).astype(bool), t) for k, (s, h, t) in PAKET.items()}
    fehler = frage = ausnahme = n = 0
    for name, im in bilder(pfade):
        n += 1
        h = dhash(im)
        for k, (s, r, t) in ref.items():
            a = int((h != r).sum())
            if a > GRENZE or s == 'frei': continue
            if s == 'verboten': fehler += 1; print('FALSCH %s stammt aus %s (Abstand %d): %s' % (name, k, a, t))
            elif s == 'ausnahme': ausnahme += 1; print('AUSNAHME %s stammt aus %s (Abstand %d): %s' % (name, k, a, t))
            else: frage += 1; print('FRAGE %s stammt aus %s (Abstand %d): %s' % (name, k, a, t))
    print('KOPFTEILMARKE %d Bilder, %d mit verbotener Marke, %d mit offener Frage, %d geprüfte Ausnahme' % (n, fehler, frage, ausnahme))
    sys.exit(1 if fehler else 0)

if __name__ == '__main__':
    main()
