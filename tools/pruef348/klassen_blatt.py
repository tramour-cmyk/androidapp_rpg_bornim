# 376.1 Blaetter aus figurenprobe.gd --teil=klassen (klassen_lauf.sh): Klassen von vorn und hinten, Aussehen (Koepfe), Erschaffung;
# dazu haut.txt: Gesichtsfarbe je Kopf (Median der Wange, sRGB) gegen den Zielton, ohne Bild anzusehen.
# Aufruf: python3 -I klassen_blatt.py <bilder> <aus>
import os, sys
from PIL import Image
import numpy as np

B, AUS = sys.argv[1:3]
os.makedirs(AUS, exist_ok=True)


def lade(n):
    p = os.path.join(B, n)
    return Image.open(p).convert('RGB') if os.path.exists(p) else None


def stapel(bilder, quer=False, rand=8):
    bilder = [b for b in bilder if b]
    if not bilder: return None
    if quer:
        h = max(b.height for b in bilder); w = sum(b.width for b in bilder) + rand * (len(bilder) - 1)
    else:
        w = max(b.width for b in bilder); h = sum(b.height for b in bilder) + rand * (len(bilder) - 1)
    out = Image.new('RGB', (w, h), (12, 10, 8)); x = y = 0
    for b in bilder:
        out.paste(b, (x, y))
        if quer: x += b.width + rand
        else: y += b.height + rand
    return out


k = stapel([lade('klassen_vorn.png'), lade('klassen_hinten.png')])
if k: k.save(os.path.join(AUS, '3761-klassen.jpg'), quality=88)
koepfe = [lade('aussehen_ak_%d.png' % i) for i in range(20)]
koepfe = [x for x in koepfe if x]
if koepfe:
    reihen = [stapel(koepfe[i:i + 5], quer=True) for i in range(0, len(koepfe), 5)]
    stapel(reihen).save(os.path.join(AUS, '3761-aussehen.jpg'), quality=88)
e = stapel([lade('erschaffung_oben.png'), lade('erschaffung_aussehen.png')], quer=True)
if e: e.save(os.path.join(AUS, '3761-erschaffung.jpg'), quality=88)
# Wange: der Kopf steht in jedem Ausschnitt bei (400, 470) (Kopfknochen + 8 cm); Wange 60-120 Punkte darunter, 40-90 seitlich.
# ak_5 bis ak_8: die vier Hauttoene des Menschen (figurenprobe.gd AUSSEHEN_PROBE) gegen ihr Farbfeld (Appearance.kt); Vorschlag
# Eichung je Kanal (linear, Median der vier), mit der heldfigur.gd HAUT_EICHUNG malnehmen
FELD = {5: 0xEACBAE, 6: 0xD4A27C, 7: 0xA8764F, 8: 0x6E4632}
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
with open(os.path.join(AUS, 'haut.txt'), 'w') as f:
    eich = []
    for i, x in enumerate(koepfe):
        a = np.asarray(x).astype(float)
        w = np.concatenate([a[530:590, 310:350].reshape(-1, 3), a[530:590, 450:490].reshape(-1, 3)])
        m = np.median(w, axis=0)
        # Gegenprobe ohne feste Lage: hautartige Punkte der Mitte (Rot > Gruen > Blau, nicht zu dunkel, kein Haar)
        c = a[380:720, 250:550].reshape(-1, 3); hl = c @ [0.2126, 0.7152, 0.0722]
        hs = c[(c[:, 0] > c[:, 1]) & (c[:, 1] > c[:, 2]) & (hl > 0.5 * np.median(hl)) & (c[:, 0] - c[:, 2] > 12)]
        m2 = np.median(hs, axis=0) if len(hs) > 50 else m
        z = ' mitte %s' % ' '.join('%d' % v for v in m2)
        if i in FELD:
            soll = np.array([(FELD[i] >> 16) & 255, (FELD[i] >> 8) & 255, FELD[i] & 255], float)
            g = lin(soll / 255) / np.maximum(lin(m / 255), 1e-4); eich.append(g)
            z += ' feld %s eichung %s' % (' '.join('%d' % v for v in soll), ' '.join('%.3f' % v for v in g))
        f.write('ak_%d wange %s%s\n' % (i, ' '.join('%d' % v for v in m), z))
    if eich: f.write('EICHUNG %s\n' % ' '.join('%.3f' % v for v in np.median(np.array(eich), axis=0)))
    # Faeuste (probe.txt FAUST <figur> <hand> x y im Bild klassen_vorn.png)
    v = lade('klassen_vorn.png'); pt = os.path.join(B, 'probe.txt')
    if v and os.path.exists(pt):
        a = np.asarray(v).astype(float)
        for z in open(pt):
            t = z.split()
            if len(t) == 5 and t[0] == 'FAUST':
                x, y = int(t[3]), int(t[4])
                if 6 <= x < a.shape[1] - 6 and 6 <= y < a.shape[0] - 6:
                    f.write('faust %s %s %s\n' % (t[1], t[2], ' '.join('%d' % c for c in np.median(a[y - 5:y + 6, x - 5:x + 6].reshape(-1, 3), axis=0))))
print('BLATT', AUS, len(koepfe), 'Koepfe')
