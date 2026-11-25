# 2034 Teil 0 Signatur-Probe: Messung je Stueck aus den Rohbildern von godot/tests/abzug_2034.gd (SIGNATUR=1), Ansicht vorn.
#   Umriss: Rand des Stuecks (maske, Alpha > 0,5; 2 Bildpunkte breit nach innen). Tusche dort, wo das Bild mit Tusche um mehr als
#   0,05 dunkler ist als ohne (Helligkeit Rec. 709). Kanten innen: ebenso, ausserhalb des Umrisses (Zahl Bildpunkte).
#   Tonstufen: Helligkeit des weissen Stuecks (_weiss, Bild weiss: nur Licht) in 50 Klassen; Klassen mit mindestens 3 % der Flaeche,
#   benachbarte zusammengefasst = Zahl der Stufen. Bild gegen Stufen: im Bild ohne Tusche je Stufe Mittel und Streuung; kleinster
#   Abstand benachbarter Stufen geteilt durch mittlere Streuung (ueber 1: Stufen heben sich vom Fotobild ab).
#   Glanzgrenze je Bildpunkt: das weisse, matte Stueck im selben Licht (_weiss); ein Stueck mit Bild (Farbe hoechstens 1) ist ohne Glanz
#   nirgends heller. Gezaehlt: Bildpunkte, die um mehr als 0,02 heller sind (Glanz), und der hellste Bildpunkt.
#   Sichtbarkeit (2034-Ue6, Pruefer 18:42: 55 % Umriss mit Tusche gemeldet, im Bild nichts zu sehen, weil dunkles Stueck auf dunklem
#   Grund): je Umrisspunkt der Kontrast der Linie gegen den Grund daneben (Mittel des Bildes mit Tusche in einem Ring 3-6 px ausserhalb,
#   im Fenster 15 px) und gegen das Stueck daneben (Mittel 4-8 px innen, ebenso); sichtbar, wenn die Linie gegen beide um mindestens
#   SICHT dunkler ist. Gezaehlt nur Umrisspunkte, an denen Grund und Stueck im Fenster vorkommen.
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
SICHT = 0.05   # Helligkeit (0-1, sRGB) wie die Schwelle „dunkler“
def kasten(x, r):
    c = np.pad(np.pad(x, r).cumsum(0).cumsum(1), ((1, 0), (1, 0)))
    n = 2 * r + 1
    return c[n:, n:] - c[:-n, n:] - c[n:, :-n] + c[:-n, :-n]
def nachbar(bild, wo, r=7):
    s, n = kasten(np.where(wo, bild, 0.0), r), kasten(wo.astype(float), r)
    return np.where(n > 0, s / np.maximum(n, 1), np.nan)
def dil(m, n):
    return ~ero(~m, n)
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
    grund = nachbar(mit, dil(m, 6) & ~dil(m, 3))
    stueck = nachbar(mit, ero(m, 4) & ~ero(m, 8))
    ok = rand & ~np.isnan(grund) & ~np.isnan(stueck)
    k_grund, k_stueck = (grund - mit)[ok], (stueck - mit)[ok]
    sichtbar = float(((k_grund >= SICHT) & (k_stueck >= SICHT)).mean()) if ok.any() else 0.0
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
    e = dict(umriss_px=int(rand.sum()), umriss_tusche=round(float(anteil), 3), umriss_sichtbar=round(sichtbar, 3),
             kontrast_grund=round(float(np.median(k_grund)), 3) if ok.any() else 0.0,
             kontrast_stueck=round(float(np.median(k_stueck)), 3) if ok.any() else 0.0,
             grund_hell=round(float(np.nanmedian(grund[ok])), 3) if ok.any() else 0.0, kanten_innen_px=kanten, stufen=len(gruppen),
             stufen_hell=[round(x, 3) for x in mittel], streuung=[round(x, 3) for x in streu], stufen_gegen_bild=round(float(verh), 2),
             hellster=round(hell, 3), glanz_px=glanz, licht_stufen=licht)
    e['satz'] = ('Messung (vorn): Umriss %d px, davon %.0f %% mit Tusche, %.0f %% sichtbar (Linie gegen Grund und Stück je mindestens %.2f dunkler; '
                 'Median Linie gegen Grund %.2f, gegen Stück %.2f, Grund %.2f); Kanten innen %d px Tusche; Tonstufen %d (Helligkeit %s); '
                 'Lichtstufen weiß %s; Stufen gegen Bild %.2f (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel %.3f; '
                 'Pixel über Glanzgrenze (heller als weißes mattes Stück) %d'
                 % (e['umriss_px'], 100 * anteil, 100 * sichtbar, SICHT, e['kontrast_grund'], e['kontrast_stueck'], e['grund_hell'], kanten, e['stufen'], ', '.join('%.2f' % x for x in mittel), ', '.join('%.2f' % x for x in licht), verh, hell, glanz))
    erg[nr] = e
    print('SIGNATUR', nr, json.dumps(e, ensure_ascii=False))
json.dump(erg, open(AUS, 'w'), ensure_ascii=False, indent=1)
