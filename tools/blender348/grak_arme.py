# 348.12 Grak Runde 2 (Prüfer r1: die Axt liegt in keiner Hand, linke Faust 48–68 cm vom Stiel, beim Hieb bleibt die Axt stehen):
# Ursache 1: die Haltung war auf dem Gerüst der Bibliothek entworfen (ual_lauer.py GRAK_HALT, GRAK_HIEB); geruest.py überträgt nur
# Richtungen der Glieder, Grak hat andere Längen und Schultern, Punkte gehen verloren. Ursache 2: leute.json „traegt“ setzt in
# rig.py den rechten Arm auf „schulter“; geruest.py hält ihn dann in jeder Bewegung starr (IM_GANG), auch im Hieb.
# Hier, auf Graks eigenem Gerüst nach der Übertragung: je Bild die Axt aus der Quelle (rechte Faust, Stiel, Schneide; zur Brust,
# im Größenverhältnis k), die rechte Hand so gedreht, dass der Stiel durchs Loch der Faust läuft (GRIFF_R wie geruest.py), beide
# Arme als zwei Glieder an ihre Griffe (rechts am Kopf der Axt, links LINKS m tiefer am Stiel), Ellbogen zur Seite wie in der
# Quelle. Die Lage der Axt zur rechten Hand ist in allen Bewegungen gleich; figur.gd legt sie nach INFO["axt"] (Stehen, Bild 0).
# Aufruf aus geruest.py (goblin.py setzt ihn für ART=hobgoblin_captain ein): res = grak_arme.arme(name, Gs, res, ctx)
import math, os
from mathutils import Vector, Matrix

AXT_MASS = float(os.environ.get('AXT_MASS', '1.0'))   # wie ual_lauer.py (Abstände an der Axt im Maß der Bibliothek)
GRIFF, HANDFL = 0.085 * AXT_MASS, 0.03 * AXT_MASS  # ual_lauer.py griff()
LINKS = 0.38                                      # m: linke Faust hinter der rechten (waffen.py greataxe-grak, für Grak gebaut)
AXT_KOPF, AXT_ENDE = 0.80, 0.50                   # m: Kopf der Axt vor, Stielende hinter der rechten Faust (waffen.py)
HALT_R = Vector((-0.30, -0.12, 0.95)).normalized()  # ual_lauer.py GRAK_HALT[1]: Stiel in Stehen
ST = {}


def _griff_src(G, s):
    m = G['hand_' + s]; innen = Vector((1 if s == 'r' else -1, 0, 0))
    return m.translation + m.col[1].xyz.normalized() * GRIFF + innen * HANDFL


def _pol(G, s):   # Ellbogen quer zur Linie Schulter–Handgelenk (Quelle)
    S, E, W = (G[b + s].translation for b in ('upperarm_', 'lowerarm_', 'hand_'))
    u = (W - S).normalized(); v = E - S
    return v - u * v.dot(u)


def _richte(m, ziel):
    h = m.translation.copy(); d = ziel - h
    if d.length < 1e-6: return m.copy()
    q = m.col[1].xyz.normalized().rotation_difference(d.normalized())
    return Matrix.Translation(h) @ q.to_matrix().to_4x4() @ m.to_3x3().normalized().to_4x4()


def _zwei(PN, RM, s, W, pol, warn):
    up, lo = 'upperarm_' + s, 'lowerarm_' + s
    S = PN[up].translation.copy()
    a = (RM[lo].translation - RM[up].translation).length; b = (RM['hand_' + s].translation - RM[lo].translation).length
    d0 = (W - S).length
    if d0 > (a + b) * 0.999: warn.append('%s %.3f' % (s, d0 - a - b))
    d = max(min(d0, (a + b) * 0.999), abs(a - b) + 1e-3); u = (W - S).normalized()
    x = (a * a - b * b + d * d) / (2 * d); hh = math.sqrt(max(a * a - x * x, 0.0))
    v = pol - u * pol.dot(u)
    v = v.normalized() if v.length > 1e-6 else Vector((0, 0, -1))
    E = S + u * x + v * hh
    PN[up] = _richte(PN[up], E)
    PN[lo] = _richte(Matrix.Translation(E) @ PN[lo].to_3x3().normalized().to_4x4(), S + u * d)


def _gerade(PN, RM, s):   # Hand gerade am Unterarm (Ruhelage zum Unterarm)
    return PN['lowerarm_' + s].to_3x3().normalized() @ (RM['lowerarm_' + s].to_3x3().inverted() @ RM['hand_' + s].to_3x3())


def _drill(PN, RM, s, H):   # Unterarm um seine Achse, bis die Hand nicht mehr gegen ihn verdreht ist (wie ual_lauer.py zweihand)
    lo = 'lowerarm_' + s; Lo = PN[lo].to_3x3().normalized()
    Rr = RM[lo].to_3x3().inverted() @ RM['hand_' + s].to_3x3()
    q = (Lo.inverted() @ H @ Rr.inverted()).to_quaternion()
    tw = Vector((q.w, 0.0, q.y, 0.0))
    if tw.length < 1e-6: return
    tw.normalize(); ang = 2 * math.atan2(tw[2], tw[0])
    PN[lo] = Matrix.Translation(PN[lo].translation) @ (Lo @ Matrix.Rotation(ang, 3, 'Y')).to_4x4()


def _godot(v):   # Blender (Blick −Y, Z oben) -> Godot-Skelett (Blick +Z, Y oben), wie der glTF-Export mit export_yup
    return [round(v.x, 4), round(v.z, 4), round(-v.y, 4)]


def arme(name, Gs, res, C):
    RM, RU, k, INFO, PAR = C['RM'], C['RU'], C['k'], C['INFO'], C['PAR']
    if 'KH' not in ST:
        print('GRAK_ARME Maß k %.3f (Grak zur Bibliothek, Hals)' % k)
        L0 = C['lies'](C['A'][C['ruhe']])[0]
        H0 = L0['hand_r'].to_3x3().normalized()
        e0 = Vector((0, -1, 0)); e0 = (e0 - HALT_R * e0.dot(HALT_R)).normalized()
        ST['KH'], ST['EH'] = H0.inverted() @ HALT_R, H0.inverted() @ e0
        # Griffe in den Handknochen wie geruest.py (Faust rechts: Ding der Leute, links: Fackel)
        alt, J = C['alt'], C['J']
        wr, fo = J['wrR'][0], J['foR'][0]
        ST['gR'] = RM['hand_r'].inverted() @ ((alt.data.bones['foR-wrR'].matrix_local @ Vector((0.0, (wr - fo).length + 4.6, 0.0))) / 100.0)
        ST['aR'] = C['GRIFF_R'].normalized()
        Ma = alt.data.bones['foL-wrL'].matrix_local
        ST['gL'] = RM['hand_l'].inverted() @ ((Ma @ Vector((-1.87, 18.7, 0.72))) / 100.0)
        ST['aL'] = (RM['hand_l'].to_3x3().inverted() @ Ma.to_3x3() @ Vector((-0.358, 0.0, -0.934))).normalized()
    gR, aR, gL, aL = ST['gR'], ST['aR'], ST['gL'], ST['aL']
    out, warn, mess = [], [], []
    for f, ((BA, PN), G) in enumerate(zip(res, Gs)):
        PN = dict(PN); BA = dict(BA)
        Ds = G['spine_03'].to_3x3().normalized() @ RU['spine_03'].to_3x3().normalized().inverted()
        Dg = PN['spine_03'].to_3x3().normalized() @ RM['spine_03'].to_3x3().normalized().inverted()
        Q = Dg @ Ds.inverted()
        Hs = G['hand_r'].to_3x3().normalized()
        r = (Q @ (Hs @ ST['KH'])).normalized()
        e = Q @ (Hs @ ST['EH']); e = (e - r * e.dot(r)).normalized()
        # zur Mitte der Schultergelenke (zur Brust lagen die Fäuste auf Grak 5 cm weiter hinten als in der Quelle, die linke in der Brust)
        sm_g = (PN['upperarm_l'].translation + PN['upperarm_r'].translation) / 2
        sm_s = (G['upperarm_l'].translation + G['upperarm_r'].translation) / 2
        R = sm_g + (Q @ (_griff_src(G, 'r') - sm_s)) * k
        pol = {s: Q @ _pol(G, s) for s in 'lr'}
        A = Matrix((e, r, e.cross(r))).transposed()     # Spalten: Schneide, Stiel (zum Kopf der Axt), quer
        if 'Aloc' not in ST:     # Stehen, Bild 0: die Faust gerade am Unterarm, ihr Loch längs des Stiels; gilt dann für alle Bilder
            H = PN['hand_r'].to_3x3().normalized()
            for _ in range(4):
                _zwei(PN, RM, 'r', R - H @ gR, pol['r'], [])
                Hg = _gerade(PN, RM, 'r'); g = Hg @ aR
                ST.setdefault('sR', 1.0 if g.dot(r) >= 0 else -1.0)
                H = (ST['sR'] * g).rotation_difference(r).to_matrix() @ Hg
            el = (H.inverted() @ e); sa = ST['sR'] * aR; el = (el - sa * el.dot(sa)).normalized()
            ST['Aloc'] = Matrix((el, sa, el.cross(sa))).transposed()
        H = A @ ST['Aloc'].inverted()
        _zwei(PN, RM, 'r', R - H @ gR, pol['r'], warn)
        _drill(PN, RM, 'r', H)
        PN['hand_r'] = Matrix.Translation(PN['lowerarm_r'] @ Vector((0, (RM['hand_r'].translation - RM['lowerarm_r'].translation).length, 0))) @ H.to_4x4()
        # links: Griff LINKS m tiefer am Stiel, die Faust gerade am Unterarm, ihr Loch längs des Stiels (kleinste Drehung)
        L = R - r * LINKS
        Hl = PN['hand_l'].to_3x3().normalized()
        for _ in range(4):
            _zwei(PN, RM, 'l', L - Hl @ gL, pol['l'], [])
            Hg = _gerade(PN, RM, 'l'); g = Hg @ aL
            ST.setdefault('sL', 1.0 if g.dot(r) >= 0 else -1.0)
            Hl = (ST['sL'] * g).rotation_difference(r).to_matrix() @ Hg
        _zwei(PN, RM, 'l', L - Hl @ gL, pol['l'], warn)
        PN['hand_l'] = Matrix.Translation(PN['lowerarm_l'] @ Vector((0, (RM['hand_l'].translation - RM['lowerarm_l'].translation).length, 0))) @ Hl.to_4x4()
        for b in ('upperarm_l', 'lowerarm_l', 'hand_l', 'upperarm_r', 'lowerarm_r', 'hand_r'):
            p = PAR[b]; BA[b] = (PN[p] @ RM[p].inverted() @ RM[b]).inverted() @ PN[b]
        # Prüfwerte: Griffe gegen die Axt, Stiel (Ende bis Kopf) zu Kopf und Brust
        gr = PN['hand_r'] @ gR; gl = PN['hand_l'] @ gL
        kopf = PN['Head'].translation + PN['Head'].col[1].xyz.normalized() * 0.10
        brust = PN['spine_03'].translation

        def nah(p_):
            t = max(-AXT_ENDE, min(AXT_KOPF, (p_ - gr).dot(r))); return (gr + r * t - p_).length
        dl = gl - gr; ent = dl.dot(r)
        mess.append(((gr - R).length, (dl - r * ent).length, -ent, nah(kopf), nah(brust), (gr + r * AXT_KOPF).z))
        if os.environ.get('GRAK_SPUR') == name:
            pv = PN['pelvis'].translation
            print('QUELLE %d R %s Brust %s Q %s' % (f, tuple(round(x, 2) for x in _griff_src(G, 'r') - G['pelvis'].translation), tuple(round(x, 2) for x in G['spine_03'].translation - G['pelvis'].translation), tuple(round(math.degrees(x)) for x in Q.to_euler())))
            print('SPUR %d R %s L %s Schulter_l %s Brust %s Kopf %s' % (f, tuple(round(x, 2) for x in gr - pv), tuple(round(x, 2) for x in gl - pv), tuple(round(x, 2) for x in PN['upperarm_l'].translation - pv), tuple(round(x, 2) for x in brust - pv), tuple(round(x, 2) for x in kopf - pv)))
        out.append((BA, PN))
        if name == 'Stehen' and f == 0:
            INFO['axt'] = {'griff': _godot(gr), 'achse': _godot(r), 'schneide': _godot(e), 'links': _godot(gl)}
            INFO['axt_hand'] = {'griff': [round(x, 4) for x in gR], 'achse': [round(x, 4) for x in ST['sR'] * aR]}   # Blender, hand_r
    print('GRAK_ARME %s: rechte Faust bis %.3f m neben dem Griff, linke bis %.3f m neben dem Stiel, %.2f–%.2f m hinter der rechten '
          '(soll %.2f); Stiel zu Kopf ab %.2f, zu Brust ab %.2f m; Kopf der Axt %.2f–%.2f m hoch; nicht erreicht %s' % (
              name, max(m[0] for m in mess), max(m[1] for m in mess), min(m[2] for m in mess), max(m[2] for m in mess), LINKS,
              min(m[3] for m in mess), min(m[4] for m in mess), min(m[5] for m in mess), max(m[5] for m in mess), warn[:6] or '–'))
    if name == 'Hieb':
        print('GRAK_ARME Hieb je Bild (Stiel zu Kopf, zu Brust, Axtkopf hoch):', [tuple(round(x, 2) for x in m[3:]) for m in mess])
    return out
