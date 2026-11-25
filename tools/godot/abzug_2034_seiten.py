# 2034-Ue14 (Chef 20:04: „beim Licht duenner, abgewandt dicker“; Planer Vera 20:07, DESIGN-STIL A2): Tusche je Seite am Umriss messen
# und zeigen. Aus den Rohbildern von godot/tests/abzug_2034.gd (SIGNATUR=1), Ansicht vorn:
#   Umriss: Rand der Maske (Alpha > 0,5). Aussen-Normale aus der geglaetteten Maske. Richtung zur Sonne im Bild aus der Zeile
#   „LICHT <nr> vorn x y“ des Laufs. Lichtseite: Normale zeigt zur Sonne (cos > 0,5), Schattenseite: von ihr weg (cos < -0,5).
#   Tusche: Bildpunkt mit Tusche um mehr als 0,05 dunkler als ohne (Helligkeit Rec. 709). Je Umrisspunkt nach innen entlang der
#   Normale (bis 16 px) die Breite der Linie (zusammenhaengende Tuschepunkte ab dem Rand) und ihre Tiefe (mit gegen ohne).
#   Je Seite: Deckung (Anteil Umrisspunkte mit Linie), Breite (Mittel in px, nur mit Linie), Tiefe (Mittel).
#   Bild <nr>_licht_schatten.webp: links das Stueck mit Tusche (Stellen gerahmt), rechts je Seite ein Ausschnitt 160 px, 3-fach,
#   oben mit, unten ohne Tusche; Messung im Rand.
# Aufruf: python3 tools/godot/abzug_2034_seiten.py <roh> <Nummer,...> <lauf.log> <ziel> <commit> <messung.json>
import sys, json, os
import numpy as np
from PIL import Image, ImageDraw, ImageFont

R, NUR, LOG, Z, C, AUS = sys.argv[1], sys.argv[2].split(','), sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
F = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
GOLD, BLAU = (212, 175, 106), (120, 160, 230)
A, K = 160, 3   # Ausschnitt px, Vergroesserung

def lum(p):
    a = np.asarray(Image.open(p).convert('RGBA')).astype(float) / 255
    return a[..., :3] @ [0.2126, 0.7152, 0.0722], a[..., 3]
def ero(m, n):
    for _ in range(n):
        m = m & np.roll(m, 1, 0) & np.roll(m, -1, 0) & np.roll(m, 1, 1) & np.roll(m, -1, 1)
    return m
def kasten(x, r):
    c = np.pad(np.pad(x, r).cumsum(0).cumsum(1), ((1, 0), (1, 0)))
    n = 2 * r + 1
    return (c[n:, n:] - c[:-n, n:] - c[n:, :-n] + c[:-n, :-n]) / n / n

licht = {}
for z in open(LOG, errors='ignore'):
    q = z.split()
    if len(q) == 5 and q[0] == 'LICHT': licht[(q[1], q[2])] = (float(q[3]), float(q[4]))
alt = json.load(open(AUS)) if os.path.exists(AUS) else {}
for nr in NUR:
    _, al = lum('%s/%s_vorn_maske.png' % (R, nr))
    mit, _ = lum('%s/%s_vorn.png' % (R, nr))
    ohne, _ = lum('%s/%s_vorn_ohne.png' % (R, nr))
    m = al > 0.5
    tief = np.where(m, ohne - mit, 0.0)
    ink = tief > 0.05
    g = kasten(m.astype(float), 4)
    gy, gx = np.gradient(g)
    gl = np.hypot(gx, gy) + 1e-9
    nx, ny = -gx / gl, -gy / gl            # aussen, Bild y nach unten
    lx, ly = licht[(nr, 'vorn')]
    l = np.array([lx, -ly]); l /= np.linalg.norm(l)
    rand = m & ~ero(m, 1)
    ys, xs = np.nonzero(rand)
    d = nx[ys, xs] * l[0] + ny[ys, xs] * l[1]
    hh, ww = m.shape
    breite, tiefe = np.zeros(len(ys)), np.zeros(len(ys))
    for i, (y, x) in enumerate(zip(ys, xs)):
        n, t, start = 0, [], False
        for k in range(16):
            qy, qx = int(round(y - k * ny[y, x])), int(round(x - k * nx[y, x]))
            if not (0 <= qy < hh and 0 <= qx < ww) or not m[qy, qx]: break
            if ink[qy, qx]: n += 1; t.append(tief[qy, qx]); start = True
            elif start or k > 2: break
        breite[i], tiefe[i] = n, (np.mean(t) if t else 0.0)
    erg, wo = {}, {}
    for seite, sel in (('licht', d > 0.5), ('schatten', d < -0.5)):
        mit_l = sel & (breite > 0)
        erg[seite] = dict(punkte=int(sel.sum()), deckung=round(float(mit_l.sum() / max(sel.sum(), 1)), 3),
                          breite_px=round(float(breite[mit_l].mean()) if mit_l.any() else 0.0, 2),
                          tiefe=round(float(tiefe[mit_l].mean()) if mit_l.any() else 0.0, 3))
        # Stelle fuer den Ausschnitt: der Umrisspunkt der Seite (cos ueber 0,8) mit den meisten gleichen Nachbarn im Fenster
        kand = np.zeros(m.shape)
        st = (d > 0.8) if seite == 'licht' else (d < -0.8)
        if not st.any(): st = sel
        kand[ys[st], xs[st]] = 1
        dichte = kasten(kand, 40)
        j = np.argmax(np.where(st, dichte[ys, xs], -1))
        wo[seite] = (int(min(max(xs[j] - A // 2, 0), ww - A)), int(min(max(ys[j] - A // 2, 0), hh - A)))
    e = alt.get(nr, {})
    e['seiten'] = erg
    e['sonne_bild'] = [round(lx, 3), round(ly, 3)]
    L, S = erg['licht'], erg['schatten']
    e['seiten_satz'] = ('Tusche nach Licht (vorn, Umriss; Sonne im Bild %s): Lichtseite %d Punkte, Linie an %.0f %%, Breite %.1f px, Tiefe %.2f; '
                        'Schattenseite %d Punkte, Linie an %.0f %%, Breite %.1f px, Tiefe %.2f; Schatten gegen Licht: Breite %.1f-fach, Tiefe %.1f-fach'
                        % ('rechts oben' if lx > 0 else 'links oben', L['punkte'], 100 * L['deckung'], L['breite_px'], L['tiefe'],
                           S['punkte'], 100 * S['deckung'], S['breite_px'], S['tiefe'],
                           S['breite_px'] / max(L['breite_px'], 0.01), S['tiefe'] / max(L['tiefe'], 0.001)))
    alt[nr] = e
    print('SEITEN', nr, json.dumps(erg))
    # Bild
    bm = Image.open('%s/%s_vorn.png' % (R, nr)).convert('RGB')
    bo = Image.open('%s/%s_vorn_ohne.png' % (R, nr)).convert('RGB')
    can = Image.new('RGB', (2048, 1124), (0, 0, 0))
    ox = (bm.size[0] - 1024) // 2   # Uebersicht: mittlere 1024 px des 2048 breiten Bildes (Stueck mittig, Zuschnitt <= 1024)
    ub = bm.crop((ox, 0, ox + 1024, bm.size[1])); dr = ImageDraw.Draw(ub)
    for seite, farbe in (('licht', GOLD), ('schatten', BLAU)):
        x, y = wo[seite]; dr.rectangle([x - ox - 3, y - 3, x - ox + A + 2, y + A + 2], outline=farbe, width=3)
    can.paste(ub, (0, 0))
    dc = ImageDraw.Draw(can)
    f18, f16 = ImageFont.truetype(F, 18), ImageFont.truetype(F, 16)
    dc.text((12, 930), '%s vorn mit Signatur; Rahmen gold = Lichtseite, blau = Schattenseite' % nr, fill=GOLD, font=f18)
    for spalte, (seite, farbe, name) in enumerate((('licht', GOLD, 'Lichtseite (zur Sonne)'), ('schatten', BLAU, 'Schattenseite'))):
        x, y = wo[seite]
        for zeile, (b, was) in enumerate(((bm, 'mit Tusche'), (bo, 'ohne Tusche'))):
            px, py = 1048 + spalte * 496, 30 + zeile * 514
            can.paste(b.crop((x, y, x + A, y + A)).resize((A * K, A * K), Image.NEAREST), (px, py))
            dc.rectangle([px - 2, py - 2, px + A * K + 1, py + A * K + 1], outline=farbe, width=2)
            dc.text((px, py - 24), '%s, %s, %d-fach' % (name, was, K), fill=farbe, font=f18)
    dc.text((12, 1040), e['seiten_satz'], fill=GOLD, font=f16)
    dc.text((12, 1066), 'Linie: Bildpunkte mit Tusche um mehr als 0,05 dunkler als ohne; Breite nach innen entlang der Normale; Tiefe = mit gegen ohne.', fill=GOLD, font=f16)
    dc.text((12, 1092), 'Stand %s · Spiel-Shader toon + Tusche nach Licht und Sonne wie im Kampfort (kampf/signatur.gd)' % C, fill=GOLD, font=f16)
    can.save('%s/%s_licht_schatten.webp' % (Z, nr), quality=90)
    print('BILD %s/%s_licht_schatten.webp' % (Z, nr))
json.dump(alt, open(AUS, 'w'), ensure_ascii=False, indent=1)
