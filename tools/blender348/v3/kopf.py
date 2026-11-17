# 376.1 (Chef 27.10., 18:09 „Ist der Gekaufte nicht modellierbar?“, 19:40 „gekauften Kopf passen wir bitte an … dann Bart dran
# und Farbe ran. Und Haare“): Kopf aus Quaternius' Universal Base Characters (Regular) formen, Haut toenen, Stoppeln weg.
# Das Paket hat keine Formschluessel: weiche Felder um Merkpunkte, die am Netz gemessen werden (Augen, Nase, Kinn, Scheitel);
# ein Feld verschiebt alle Netze am Kopf gleich (Haut, Brauen, Haar, Bart), die Augen als Ganzes (sonst verzerrt).
# Figur in der Ruhelage, Blick nach -Y (glTF-Import), Welt = Ruhe des Geruests. Benutzt von kauf_kleid.py und quaternius.py.
import numpy as np
from mathutils import Vector

# Regler (0 = wie gekauft): breite, kiefer, laenge = Anteil (0,1 = 10 %); kinn (vor), wangen (aussen), brauen (vor) in m; nase Anteil
REGLER = ('breite', 'kiefer', 'laenge', 'kinn', 'nase', 'wangen', 'brauen', 'ohren', 'augen')
# 475 (Chef 04.11., 13:26: „ein Gesicht definiert sich über die Form … unterschiedliche Nasen, Ohren“): ohren Anteil (0,1 = Ohr 5 mm weiter
# ab und 10 % groesser), augen in m je Seite (Abstand der Augen). feld ist linear in jedem Regler: je Regler ein Formschluessel mit
# EINHEIT (held_klassen.py schluessel, „r_<regler>“), Godot setzt Wert / EINHEIT je Person (heldfigur.gd gesicht)
EINHEIT = {'breite': 0.1, 'kiefer': 0.1, 'laenge': 0.1, 'kinn': 0.01, 'nase': 0.1, 'wangen': 0.01, 'brauen': 0.01, 'ohren': 0.1, 'augen': 0.01}
# 475 Lauf 2 (Chef 04.11., 20:47: „die Augen sind gleich, die Nase ist gleich … die Augenbrauen sind gleich“): Form statt Wert.
# Nase: hoecker (m vor, Mitte des Rueckens), nasenbreite (Anteil, Nasenfluegel), spitze (m nach unten, negativ = Stupsnase);
# Augen: augen_gross (Anteil, Augapfel und Lidspalte), augen_schmal (Anteil, Lidspalte niedriger), augen_tief (m zurueck, mit Lidern);
# Brauen (nur am Netz der Brauen, art 'brauen'): bdick (Anteil, Hoehe des Haarstreifens: 1 = doppelt, -0,6 = duenn), bwinkel (m, Innenende
# nach unten: grimmig; negativ: innen hoch, sorgenvoll)
REGLER = REGLER + ('hoecker', 'nasenbreite', 'spitze', 'augen_gross', 'augen_schmal', 'augen_tief', 'bdick', 'bwinkel')
EINHEIT.update({'hoecker': 0.01, 'nasenbreite': 0.1, 'spitze': 0.01, 'augen_gross': 0.1, 'augen_schmal': 0.1, 'augen_tief': 0.01,
                'bdick': 0.1, 'bwinkel': 0.01})
FORMEN = {   # Pruefer 20:2x/20:33: schmal = hager = gekauft, kantig einseitig gebeult: schmal nur eng, hager lang mit hohen Wangen
             # und langer Nase, kantig der Kiefer breit mit Kinn und Brauen vor (Kiefer weicher nach hinten, kopf.feld)
    'gekauft': {},
    'schmal':  {'breite': -0.15, 'kiefer': -0.20, 'laenge': 0.05, 'wangen': -0.004},
    'rund':    {'breite': 0.12, 'kiefer': 0.18, 'laenge': -0.08, 'kinn': -0.006, 'wangen': 0.006, 'nase': -0.15, 'brauen': -0.002},
    # Pruefer Lauf 2 (28.10., 23:1x): „kantig“ beult an der Wange (Kiefer weniger, Kinn mehr), „hager“ wie „oval“ (laenger, schmaler)
    # Lauf 1 (29.10.): „kantig“ noch aufgedunsen, Beule an Mundwinkel und Wange: Kiefer kaum, Kinn und Brauen vor; „hager“ wie
    # „schmal“: noch laenger, Wangen eingefallen
    'kantig':  {'breite': -0.03, 'kiefer': 0.10, 'laenge': 0.04, 'kinn': 0.016, 'brauen': 0.010, 'nase': 0.12},
    'hager':   {'breite': -0.10, 'kiefer': -0.14, 'laenge': 0.32, 'kinn': 0.008, 'wangen': -0.006, 'brauen': 0.007, 'nase': 0.30},
}
# Haut (Faktor auf das Bild): die Textur ist hell-rosig
HAUT = {'hell': (1.22, 1.16, 1.10), 'mittel': (1.0, 1.0, 1.0), 'warm': (0.98, 0.90, 0.80), 'gebraeunt': (0.80, 0.68, 0.56),
        'dunkel': (0.58, 0.46, 0.38), 'blass': (0.98, 0.98, 1.0)}


def form_aus(text):
    # „rund“ oder „breite=0.1,kinn=0.004“ oder „rund,nase=0.2“
    f = {}
    for t in [t for t in (text or '').split(',') if t]:
        if '=' in t:
            k, v = t.split('='); f[k.strip()] = float(v)
        else: f.update(FORMEN[t.strip()])
    return f


def _welt(o):
    co = np.empty(len(o.data.vertices) * 3); o.data.vertices.foreach_get('co', co)
    M = np.array(o.matrix_world)
    return co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]


def _zurueck(o, W):
    Mi = np.array(o.matrix_world.inverted())
    o.data.vertices.foreach_set('co', (W @ Mi[:3, :3].T + Mi[:3, 3]).ravel()); o.data.update()


def _glatt(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def merkpunkte(haut, augen=None):
    # haut: Netz mit dem Gesicht (Koerper oder OnlyHead); augen: Netz „Eyes“ oder None
    V = _welt(haut)
    if augen is not None:
        A = _welt(augen); az = float(A[:, 2].mean()); ay = float(A[:, 1].min()); ax = float(np.abs(A[:, 0]).max() * 0.6)
    else:
        az, ay, ax = None, None, 0.033
    mitte = np.abs(V[:, 0]) < 0.012
    oben = float(V[:, 2].max())
    if az is None:   # ohne Augennetz: 70 % der Kopfhoehe ueber dem Kinn (am Kaufkopf 0,68)
        az = oben - 0.12
    # Nase: vorderster Punkt der Mitte zwischen Augen und 12 cm darunter
    m = mitte & (V[:, 2] < az) & (V[:, 2] > az - 0.12)
    n = V[m][np.argmin(V[m][:, 1])]
    if ay is None: ay = float(n[1]) + 0.035
    # Kinn: tiefster Punkt der Mitte, der noch vorn liegt (vor 80 % der Augenvorderkante)
    m = mitte & (V[:, 1] < ay * 0.8) & (V[:, 2] < n[2]) & (V[:, 2] > n[2] - 0.13)
    kz = float(V[m][:, 2].min())
    kv = float(V[m & (V[:, 2] < kz + 0.03)][:, 1].min())
    p = {'augen_z': az, 'augen_y': ay, 'augen_x': ax, 'nase': n.copy(), 'kinn_z': kz, 'kinn_y': kv, 'oben': oben,
         'mund_z': kz + 0.6 * (float(n[2]) - kz), 'hoehe': oben - kz}
    p['mitte'] = np.array([0.0, float(V[(np.abs(V[:, 2] - az) < 0.01)][:, 1].mean()), az])
    # 475: Ohr je Seite: aeusserster Punkt auf Augenhoehe bis 5 cm darunter, nicht vor der Augenmitte (Wange)
    m = (V[:, 2] < az + 0.01) & (V[:, 2] > az - 0.05) & (V[:, 1] > p['mitte'][1] - 0.01) & (V[:, 2] < oben)
    for s, k in ((1.0, 'ohr_r'), (-1.0, 'ohr_l')):
        ms = m & (V[:, 0] * s > 0)
        p[k] = V[ms][np.argmax(V[ms][:, 0] * s)].copy() if ms.any() else np.array([s * 0.075, p['mitte'][1] + 0.02, az - 0.02])
    return p


def augen_mitte(p, s):
    # Mitte des Augapfels je Seite (s +1 rechts, -1 links): 0,72 der Aussenkante, 1 cm hinter der Vorderkante des Augennetzes
    return np.array([s * p['augen_x'] / 0.6 * 0.72, p['augen_y'] + 0.01, p['augen_z']])


def brauen_feld(W, f):
    # 475 Lauf 2: nur am Netz der Brauen. Je Seite die Mittellinie des Haarstreifens (z ueber |x|, quadratisch angepasst); bdick streckt
    # quer zur Linie, bwinkel senkt das Innenende (linear in |x|, aussen 0)
    D = np.zeros_like(W)
    if not (f.get('bdick') or f.get('bwinkel')) or len(W) < 8: return D
    for s in (W[:, 0] < 0, W[:, 0] >= 0):
        if s.sum() < 4: continue
        ax = np.abs(W[s, 0]); z = W[s, 2]
        k = np.polyfit(ax, z, 2) if np.ptp(ax) > 1e-4 else np.array([0.0, 0.0, z.mean()])
        zm = np.polyval(k, ax)
        D[s, 2] += f.get('bdick', 0.0) * (z - zm)
        innen = (ax.max() - ax) / max(np.ptp(ax), 1e-4)
        D[s, 2] -= f.get('bwinkel', 0.0) * innen
    # Pruefer 21:34 (Brauen stehen hakenfoermig ueber die Stirn vor): die Stirn weicht nach oben zurueck, die Braue folgt ihr (etwa 0,35 m
    # zurueck je m nach oben, am Kaufkopf ueber den Augen gemessen)
    D[:, 1] += 0.35 * D[:, 2]
    return D


def augen_netz_D(Ws, p, f):
    # Augapfel einer Seite als Ganzes verschoben (feld an der Mitte), augen_gross zu 60 % gestreckt (die Lider wachsen mit dem Feld nur
    # zu etwa 60 %; voll stiesse der Augapfel vorn durchs Lid)
    m = Ws.mean(0, keepdims=True)
    return feld(m, p, f)[0] + 0.6 * f.get('augen_gross', 0.0) * (Ws - m)


def feld(W, p, f, art=None):
    # Verschiebung je Punkt (Welt) fuer die Form f; ausserhalb des Kopfs 0 (Hals unter dem Kinn, Schultern)
    if not f: return np.zeros_like(W)
    if art == 'brauen': return feld(W, p, {k: v for k, v in f.items() if k not in ('bdick', 'bwinkel')}) + brauen_feld(W, f)
    x, y, z = W[:, 0], W[:, 1], W[:, 2]
    r = np.linalg.norm(W - p['mitte'], axis=1)
    w = _glatt(p['kinn_z'] - 0.025, p['kinn_z'] + 0.02, z) * (1 - _glatt(0.15, 0.21, r))
    D = np.zeros_like(W)
    D[:, 0] += x * f.get('breite', 0.0) * w
    # Kiefer: unter der Nase, vorn und seitlich (hinter dem Ohr nicht)
    wj = (1 - _glatt(p['mund_z'] - 0.01, p['nase'][2], z)) * (1 - _glatt(p['mitte'][1] - 0.02, p['mitte'][1] + 0.07, y))
    D[:, 0] += x * f.get('kiefer', 0.0) * w * wj
    # Laenge: unter den Augen gestreckt
    unter = z < p['augen_z']
    D[unter, 2] += (z[unter] - p['augen_z']) * f.get('laenge', 0.0) * w[unter]
    def gauss(c, rad):
        return np.exp(-np.sum(((W - c) / rad) ** 2, axis=1))
    if f.get('kinn'):
        c = np.array([0.0, p['kinn_y'] + 0.012, p['kinn_z'] + 0.022])
        D[:, 1] -= f['kinn'] * gauss(c, np.array([0.035, 0.04, 0.03]))
    if f.get('nase'):
        n = p['nase']; basis = np.array([0.0, n[1] + 0.03, n[2] + 0.006])
        g = gauss(n + np.array([0.0, 0.012, 0.004]), np.array([0.02, 0.025, 0.025]))
        D += f['nase'] * g[:, None] * (W - basis)
    for s in (-1.0, 1.0):
        if f.get('wangen'):
            c = np.array([s * (p['augen_x'] + 0.012), p['augen_y'] + 0.02, p['augen_z'] - 0.032])
            g = gauss(c, np.array([0.03, 0.035, 0.025]))
            D[:, 0] += s * f['wangen'] * g; D[:, 1] -= 0.4 * f['wangen'] * g
        if f.get('brauen'):
            c = np.array([s * p['augen_x'] * 0.9, p['augen_y'] - 0.006, p['augen_z'] + 0.02])
            D[:, 1] -= f['brauen'] * gauss(c, np.array([0.028, 0.02, 0.014]))
        if f.get('ohren'):
            c = p['ohr_r' if s > 0 else 'ohr_l'] + np.array([-s * 0.012, 0.0, 0.0])
            g = gauss(c, np.array([0.022, 0.03, 0.035])) * (x * s > 0)
            D[:, 0] += s * 0.05 * f['ohren'] * g
            D += 1.0 * f['ohren'] * g[:, None] * (W - c) * np.array([0.0, 1.0, 1.0])
        if f.get('augen'):
            c = np.array([s * p['augen_x'] / 0.6 * 0.72, p['augen_y'] + 0.004, p['augen_z']])   # Augenmitte: 0,72 der Aussenkante
            D[:, 0] += s * f['augen'] * gauss(c, np.array([0.02, 0.025, 0.018])) * (x * s > 0)
        # 475 Lauf 2: Augenform (Lidspalte gross, schmal, tiefliegend); je Seite nur ihre Haelfte
        ce = augen_mitte(p, s); seite = (x * s > 0)
        if f.get('augen_gross'):
            D += f['augen_gross'] * (gauss(ce, np.array([0.022, 0.02, 0.017])) * seite)[:, None] * (W - ce)
        if f.get('augen_schmal'):
            g = gauss(ce, np.array([0.02, 0.02, 0.012])) * seite * (y < ce[1])
            D[:, 2] -= f['augen_schmal'] * g * (z - p['augen_z'])
        if f.get('augen_tief'):
            D[:, 1] += f['augen_tief'] * gauss(ce, np.array([0.02, 0.02, 0.016])) * seite
    # 475 Lauf 2: Nasenform. Ruecken (Hoecker) halb zwischen Augen und Spitze, Fluegel 8 mm unter der Spitze, Spitze nach unten
    n = p['nase']
    if f.get('hoecker'):
        c = np.array([0.0, n[1] + 0.008, 0.5 * (n[2] + p['augen_z'])])
        D[:, 1] -= f['hoecker'] * gauss(c, np.array([0.011, 0.02, 0.011]))
    if f.get('nasenbreite'):
        c = np.array([0.0, n[1] + 0.016, n[2] - 0.008])
        D[:, 0] += f['nasenbreite'] * x * gauss(c, np.array([0.026, 0.022, 0.016]))
    if f.get('spitze'):
        D[:, 2] -= f['spitze'] * gauss(n + np.array([0.0, 0.004, -0.003]), np.array([0.011, 0.012, 0.011]))
    return D


def forme(netze, f, haut=None):
    # alle Netze am Kopf; Augen (Name „Eyes“) je Seite als Ganzes. Gibt die Merkpunkte zurueck (fuer Stoppeln, Pruefung)
    haut = haut or max(netze, key=lambda o: len(o.data.vertices))
    augen = next((o for o in netze if o.name.startswith('Eyes')), None)
    p = merkpunkte(haut, augen)
    if not f: return p
    for o in netze:
        W = _welt(o)
        if o is augen:
            D = np.zeros_like(W)
            for s in (W[:, 0] < 0, W[:, 0] >= 0):
                if s.any(): D[s] = augen_netz_D(W[s], p, f)
        else: D = feld(W, p, f, 'brauen' if o.name.startswith('Eyebrows') else None)
        _zurueck(o, W + D)
    return p


def bart_maske(o, p):
    # Gewicht je Ecke der Haut: Kiefer, Kinn, Oberlippe (Stoppeln), Lippen und Hals frei
    V = _welt(o); x, y, z = V[:, 0], V[:, 1], V[:, 2]
    vorn = 1 - _glatt(p['mitte'][1] - 0.01, p['mitte'][1] + 0.05, y)
    unter = 1 - _glatt(p['nase'][2] - 0.012, p['nase'][2] + 0.008, z)
    kinn = _glatt(p['kinn_z'] - 0.03, p['kinn_z'] - 0.005, z)
    lippe = np.exp(-((x / 0.026) ** 2 + ((z - p['mund_z']) / 0.008) ** 2 + ((y - p['kinn_y'] + 0.01) / 0.03) ** 2))
    return np.clip(vorn * unter * kinn * (1 - 1.6 * lippe), 0.0, 1.0)


def toene_haut(o, p, haut=(1.0, 1.0, 1.0), stoppeln=1.0, mat=lambda n: True):
    # Hautbild des Netzes kopieren: Faktor haut, Stoppeln (0 = glatt rasiert) zur Wangenfarbe hin
    import bpy
    from PIL import Image, ImageDraw, ImageFilter
    if tuple(haut) == (1.0, 1.0, 1.0) and stoppeln >= 1.0: return
    import quaternius as QT
    me = o.data; uv = me.uv_layers.active.data
    vuv = np.zeros((len(me.vertices), 2))
    for l in me.loops: vuv[l.vertex_index] = uv[l.index].uv
    bm = bart_maske(o, p)
    for i, m in enumerate(me.materials):
        if not m or not mat(m.name): continue
        tn0 = QT.basisbild(m)
        if not tn0 or not tn0.image: continue
        m2 = m.copy(); m2.name = m.name + '_haut'
        tn = QT.basisbild(m2); im = tn.image.copy(); im.name = tn.image.name + '_haut'
        Wd, Hd = im.size
        px = np.empty(Wd * Hd * 4, dtype=np.float32); im.pixels.foreach_get(px); px = px.reshape(Hd, Wd, 4)   # Zeile 0 = unten
        if stoppeln < 1.0:
            mk = Image.new('L', (Wd, Hd), 0); dr = ImageDraw.Draw(mk)
            for poly in me.polygons:
                if poly.material_index != i: continue
                g = float(bm[list(poly.vertices)].mean())
                if g < 0.02: continue
                dr.polygon([(uv[li].uv[0] % 1 * Wd, uv[li].uv[1] % 1 * Hd) for li in poly.loop_indices], fill=int(g * 255))
            mk = np.asarray(mk.filter(ImageFilter.GaussianBlur(Wd / 512)), dtype=np.float32) / 255.0   # Zeilen wie px (v nach oben)
            # Wangenfarbe: Ecken vorn auf Hoehe zwischen Nase und Augen
            V = _welt(o)
            wm = (np.abs(np.abs(V[:, 0]) - p['augen_x'] - 0.01) < 0.015) & (V[:, 2] > p['nase'][2]) & (V[:, 2] < p['augen_z'] - 0.015) \
                & (V[:, 1] < p['mitte'][1])
            uvw = vuv[wm]
            wange = px[(uvw[:, 1] % 1 * Hd).astype(int).clip(0, Hd - 1), (uvw[:, 0] % 1 * Wd).astype(int).clip(0, Wd - 1), :3].mean(0)
            a = (mk * (1.0 - stoppeln))[:, :, None]
            px[:, :, :3] = px[:, :, :3] * (1 - a) + wange[None, None, :] * a
        px[:, :, :3] *= np.array(haut, dtype=np.float32)
        im.pixels.foreach_set(np.clip(px, 0, 1).ravel()); im.update(); im.pack()
        tn.image = im
        me.materials[i] = m2
