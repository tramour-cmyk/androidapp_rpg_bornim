# 2034 Teil 0 Signatur-Probe: Messung je Stueck aus den Rohbildern von godot/tests/abzug_2034.gd (SIGNATUR=1), Ansicht vorn.
#   Umriss: Rand des Stuecks (maske, Alpha > 0,5; 2 Bildpunkte breit nach innen). Tusche dort, wo das Bild mit Tusche um mehr als
#   0,05 dunkler ist als ohne (Helligkeit Rec. 709). Kanten innen: ebenso, ausserhalb des Umrisses (Zahl Bildpunkte).
#   Tonstufen: Helligkeit des weissen Stuecks (_weiss, Bild weiss: nur Licht) in 50 Klassen; Klassen mit mindestens 3 % der Flaeche,
#   benachbarte zusammengefasst = Zahl der Stufen. Bild gegen Stufen: im Bild ohne Tusche je Stufe Mittel und Streuung; kleinster
#   Abstand benachbarter Stufen geteilt durch mittlere Streuung (ueber 1: Stufen heben sich vom Fotobild ab).
#   Glanzgrenze je Bildpunkt: das weisse, matte Stueck im selben Licht (_weiss); ein Stueck mit Bild (Farbe hoechstens 1) ist ohne Glanz
#   nirgends heller. Gezaehlt: Bildpunkte, die um mehr als 0,02 heller sind (Glanz), und der hellste Bildpunkt.
# Aufruf: python3 tools/godot/abzug_2034_signatur.py <roh> <Nummer,...> <messung.json>
import sys, json
import numpy as np
from PIL import Image

R, NUR, AUS = sys.argv[1], sys.argv[2].split(','), sys.argv[3]
def lum(p):
    a = np.asarray(Image.open(p).convert('RGBA')).astype(float) / 255
    return a[..., :3] @ [0.2126, 0.7152, 0.0722], a[..., 3]
def ero(m, n):
    for _ in range(n):
        m = m & np.roll(m, 1, 0) & np.roll(m, -1, 0) & np.roll(m, 1, 1) & np.roll(m, -1, 1)
    return m
erg = {}
for nr in NUR:
    _, al = lum('%s/%s_vorn_maske.png' % (R, nr))
    mit, _ = lum('%s/%s_vorn.png' % (R, nr))
    ohne, _ = lum('%s/%s_vorn_ohne.png' % (R, nr))
    weiss, _ = lum('%s/%s_vorn_weiss.png' % (R, nr))
    m = al > 0.5
    rand = m & ~ero(m, 2)
    innen = ero(m, 2)
    dunkler = mit < ohne - 0.05
    anteil = (rand & dunkler).sum() / max(rand.sum(), 1)
    kanten = int((innen & dunkler).sum())
    w = weiss[innen]
    h, _ = np.histogram(w, bins=50, range=(0, 1))
    voll = h >= 0.03 * len(w)
    gruppen, j = [], 0
    while j < 50:
        if voll[j]:
            k = j
            while k + 1 < 50 and voll[k + 1]: k += 1
            gruppen.append((j / 50, (k + 1) / 50)); j = k + 1
        else: j += 1
    mittel, streu = [], []
    for a, b in gruppen:
        s = innen & (weiss >= a) & (weiss < b)
        mittel.append(float(ohne[s].mean())); streu.append(float(ohne[s].std()))
    abst = min((abs(mittel[i + 1] - mittel[i]) for i in range(len(mittel) - 1)), default=0.0)
    verh = abst / max(np.mean(streu), 1e-3) if len(mittel) > 1 else 0.0
    glanz = int((m & (ohne > weiss + 0.02)).sum())
    hell = float(max(ohne[m].max(), mit[m].max()))
    licht = [round(float(weiss[innen & (weiss >= a) & (weiss < b)].mean()), 3) for a, b in gruppen]
    e = dict(umriss_px=int(rand.sum()), umriss_tusche=round(float(anteil), 3), kanten_innen_px=kanten, stufen=len(gruppen),
             stufen_hell=[round(x, 3) for x in mittel], streuung=[round(x, 3) for x in streu], stufen_gegen_bild=round(float(verh), 2),
             hellster=round(hell, 3), glanz_px=glanz, licht_stufen=licht)
    e['satz'] = ('Messung (vorn): Umriss %d px, davon %.0f %% mit Tusche; Kanten innen %d px Tusche; Tonstufen %d (Helligkeit %s); '
                 'Lichtstufen weiß %s; Stufen gegen Bild %.2f (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel %.3f; '
                 'Pixel über Glanzgrenze (heller als weißes mattes Stück) %d'
                 % (e['umriss_px'], 100 * anteil, kanten, e['stufen'], ', '.join('%.2f' % x for x in mittel), ', '.join('%.2f' % x for x in licht), verh, hell, glanz))
    erg[nr] = e
    print('SIGNATUR', nr, json.dumps(e, ensure_ascii=False))
json.dump(erg, open(AUS, 'w'), ensure_ascii=False, indent=1)
