# 348.6 Kampfbewegungen des Helden (von Jerry 27.10.; Vorrang Perikles 338.1): Kampfstehen, Ausholen, Hieb, Stich, Treffer,
# Ausweichen, Abwehr aus eigenen Schluesselbildern auf unserem Skelett; Tod aus Death01 (geruest.py HELD, hier nur der Anfang aus
# Kampfstehen). Die Bibliothek hat dafuer nichts Brauchbares (Sword_Attack ist ein Stoss von hinter dem Kopf, Jerry Runde 4;
# Hit_Chest 0,3 s nur der Kopf; kein Stich, kein Ausweichen, keine Abwehr).
# Waffe in der rechten Faust laengs des Faustlochs (faust_R in held-info.json, gespiegelt wie faust_L); die Schneide liegt in der
# Ebene aus Klinge und Knochenrichtung der Hand. Schild am linken Unterarm wie figur.gd _hold (Ruhelage: Vorderseite nach aussen,
# oben nach oben). Kampfstehen = Stehen mit dem Schwertarm in Bereitschaft (Unterarm vor, Klinge schraeg nach oben vorn wie die alte
# Bereitschaft, nie waagerecht nach vorn auf Hueftehoehe, DESIGN-ABNAHME); alle Bewegungen beginnen in dessen erstem Bild; Hieb, Stich,
# Treffer, Ausweichen enden dort, Ausholen und Abwehr bleiben stehen (gehaltene Haltungen, DESIGN-ABNAHME). Zeiten wie
# DESIGN-ABNAHME und figur.gd: Hieb 0,8 s (am Ziel bei 0,42, Halt bis 0,68, dann geht figur.gd rueckwaerts), Stich 0,6 s.
# Runde 2 (Fremdpruefung Runde 1): Klinge rechts am Kopf vorbei, Hieb endet vor der linken Huefte mit der Spitze zum Boden, Stich mit
# dem Ellbogen unten, Treffer und Ausweichen weiter, Abwehr und Ausweichen mit der Klinge aussen; Tod liegend mit Armen und Schild am
# Boden; Rueckenschild und Griff in der Scheide im Kampf weg (geruest.py verstecke_knochen); Pruefung mit dem Kopf aus dem Netz.
# Koordinaten: Armatur in Metern, Blick -Y, links +X, oben +Z. Aufruf aus geruest.py (FIGUR=held) oder zum Probieren allein:
# bl/bin/python -I kampf.py <held3-rig.blend> <ausgabe.glb>
import bpy, math, os, sys
from mathutils import Vector, Matrix, Quaternion

FPS = 30
KNICK_MAX = 50.0     # Grad: Handgelenk gegen den Unterarm, darueber meldet der Bau
VERDREH_MAX = 100.0  # Grad: Unterarm um seine Achse gegen die Ruhelage (Stoss mit der Handflaeche nach unten: um 90)
VERDREH = 0.4        # Gewicht der Verdrehung gegen den Knick bei der Wahl der Handdrehung
POL_KOSTEN = 0.15    # je Grad, das der Ellbogen von der gewuenschten Seite abweicht
KEGEL_KOSTEN = 0.5   # je Grad, das die Klinge (der Schild) von der gewuenschten Richtung abweicht


def _upd():
    bpy.context.view_layer.update()


class Puppe:
    def __init__(self, sk, achse_r, schild_n):
        self.sk = sk; self.PB = sk.pose.bones
        self.A = achse_r          # Faustloch rechts im Raum des Handknochens
        self.N = schild_n         # Vorderseite des Schilds im Raum des linken Handknochens
        self.REIHE = [b.name for b in sk.data.bones]

    def stelle(self, P):
        for b, (q, l) in P.items():
            self.PB[b].rotation_quaternion = q; self.PB[b].location = l
        _upd()

    def merke(self):
        return {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in self.PB}

    def W(self, b):
        return self.PB[b].matrix.copy()

    def setze(self, b, R3, kopf=None):
        pb = self.PB[b]; h = pb.matrix.translation.copy() if kopf is None else kopf
        pb.matrix = Matrix.Translation(h) @ R3.to_4x4(); _upd()

    def drehe(self, b, achse, grad):     # Knochen b um eine Weltachse an seinem Kopf
        pb = self.PB[b]; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(grad), 4, achse) @ Matrix.Translation(-h) @ pb.matrix
        _upd()

    def schiebe(self, b, d):
        pb = self.PB[b]; pb.matrix = Matrix.Translation(Vector(d)) @ pb.matrix; _upd()

    def richte(self, b, ziel):           # kleinste Drehung, bis der Knochen zum Punkt zeigt
        m = self.W(b); h = m.translation.copy()
        q = m.col[1].xyz.normalized().rotation_difference((ziel - h).normalized())
        self.setze(b, q.to_matrix() @ m.to_3x3(), h)

    def zwei(self, b1, b2, ziel, pol):
        """zwei Knochen (Oberarm, Unterarm oder Oberschenkel, Unterschenkel) bis ziel, Gelenk zur Seite pol; gibt den Rest (m)"""
        S = self.W(b1).translation.copy(); T = Vector(ziel)
        a = (self.W(b2).translation - S).length; b_ = self.PB[b2].length if not b2.startswith('calf') else \
            (self.PB['foot' + b2[4:]].matrix.translation - self.W(b2).translation).length
        rest = max(0.0, (T - S).length - (a + b_) * 0.995)
        d = min((T - S).length, (a + b_) * 0.995); u = (T - S).normalized(); T = S + u * d
        x = (a * a - b_ * b_ + d * d) / (2 * d); hh = math.sqrt(max(a * a - x * x, 0.0))
        p = Vector(pol); v = (p - u * p.dot(u)).normalized()
        self.richte(b1, S + u * x + v * hh); self.richte(b2, T)
        return rest

    def faust(self, s, achse, ziel_dir, nur_kosten=False, kegel=0):
        """Hand s so drehen, dass ihre achse (lokal) nach ziel_dir zeigt; um diese Richtung so gedreht, dass Knick gegen den
        Unterarm und Verdrehung um ihn zusammen am kleinsten sind (Verdrehung zaehlt VERDREH-fach); die Verdrehung uebernimmt der
        Unterarm (sonst verwringt das Handgelenk). Gibt Knick und Verdrehung (Grad)."""
        h, lo = 'hand_' + s, 'lowerarm_' + s
        kz = Vector(ziel_dir).normalized()
        R0 = self.W(h).to_3x3()
        Rl = self.W(lo).to_3x3(); d = Rl.col[1].normalized()
        # Ellbogen als Scharnier: die Achse (Oberarm x Unterarm) der Ruhelage, im Unterarm festgehalten, soll in jeder Pose wieder
        # die Scharnierachse sein; der Winkel dazwischen um den Unterarm ist die Drehung des Unterarms (Pronation) gegen die Ruhelage
        Ru = self.W('upperarm_' + s).to_3x3(); B = self.sk.data.bones
        RuR, RlR = B['upperarm_' + s].matrix_local.to_3x3(), B[lo].matrix_local.to_3x3()
        h0 = RlR.inverted() @ RuR.col[1].cross(RlR.col[1]).normalized()
        hs = Ru.col[1].cross(d)
        def twist(M):    # Drehung um die eigene Achse (lokal Y), Grad
            q = M.to_quaternion(); t_ = Quaternion((q.w, 0.0, q.y, 0.0)).normalized()
            a_ = 2 * math.atan2(t_.y, t_.w); return (a_ + math.pi) % (2 * math.pi) - math.pi
        best = None
        # die Achse darf bis KEGEL Grad von ziel_dir abweichen (jedes Grad kostet KEGEL_KOSTEN), wenn das Handgelenk so natuerlicher steht
        o1 = kz.orthogonal().normalized(); o2 = kz.cross(o1)
        rich = [(0.0, kz)] + [(k_, (kz * math.cos(math.radians(k_)) + (o1 * math.cos(math.radians(a_)) + o2 * math.sin(math.radians(a_))) * math.sin(math.radians(k_))).normalized())
                              for k_ in range(8, kegel + 1, 8) for a_ in range(0, 360, 45)] if kegel else [(0.0, kz)]
        for ab, kz_ in rich:
          R1 = (R0 @ achse).normalized().rotation_difference(kz_).to_matrix() @ R0
          for p in range(0, 360, 6):
            R = Matrix.Rotation(math.radians(p), 3, kz_) @ R1
            tau = twist(Rl.inverted() @ R)                       # Hand gegen Unterarm: geht an den Unterarm
            Rl_ = Matrix.Rotation(tau, 3, d) @ Rl
            if hs.length < 0.17: ell = 0.0                       # Arm fast gestreckt: kein Scharnier zu sehen
            else:
                a_ = Rl_ @ h0; a_ = (a_ - d * a_.dot(d)).normalized(); b_ = hs.normalized()
                ell = math.atan2(a_.cross(b_).dot(d), a_.dot(b_))
            kn = R.col[1].angle(d)
            c = math.degrees(kn) + VERDREH * abs(math.degrees(ell)) + KEGEL_KOSTEN * ab
            c += 5 * max(0.0, math.degrees(kn) - KNICK_MAX) + 5 * max(0.0, abs(math.degrees(ell)) - VERDREH_MAX)   # ueber die Grenzen teuer
            if best is None or c < best[0]: best = (c, R, kn, tau, ell)
        c, R, kn, tau, ell = best
        if nur_kosten: return c, math.degrees(kn), math.degrees(ell)
        self.setze(lo, Matrix.Rotation(tau, 3, d) @ Rl)
        self.setze(h, R)
        return math.degrees(kn), math.degrees(ell)

    def klinge(self):
        return (self.W('hand_r').to_3x3() @ self.A).normalized()

    def schild(self):
        return (self.W('hand_l').to_3x3() @ self.N).normalized()


KLINGE_M = 0.75      # Langschwert: Griffpunkt bis Spitze (longsword.glb 0,753 m)
# Schild wie figur.gd _hold (kampfblatt.py): in der Ruhelage der linken Hand Breite laengs -Y, Hoehe +Z, Vorderseite +X; Griff 0,35 der
# Handknochenlaenge (15,7 cm), 4 cm nach aussen; Umriss aus shield.glb (Breite 0,56, oben 0,30, Spitze unten 0,42)
SCHILD_UMRISS = [(-0.28, 0.30), (0.28, 0.30), (-0.28, 0.0), (0.28, 0.0), (0.0, -0.42), (-0.2, -0.25), (0.2, -0.25)]
# Ansichten fuer „Klinge vor dem Gesicht“: Kontaktblatt vorn links und vorn rechts (15 Grad), Spielkamera schraeg (45 Grad)
SICHTEN = [('vorn links', 35, 15), ('vorn rechts', -35, 15), ('vorn', 0, 45)]


def _strecke(p, a, b):    # Abstand Punkt p zur Strecke a-b
    ab = b - a; t = max(0.0, min(1.0, (p - a).dot(ab) / max(ab.dot(ab), 1e-9))); return (a + ab * t - p).length


def _strecken(a0, a1, b0, b1, n=12):   # kleinster Abstand zweier Strecken (abgetastet)
    return min(_strecke(a0 + (a1 - a0) * (i / n), b0, b1) for i in range(n + 1))


def schild_punkte(pu):
    """Umrisspunkte des Schilds in der Welt (figur.gd _hold, siehe SCHILD_UMRISS)"""
    Rl = pu.sk.data.bones['hand_l'].matrix_local
    mitte = (Rl @ Vector((0, 0.157 * 0.35, 0))) + Vector((0.04, 0, 0))
    M = pu.W('hand_l') @ Rl.inverted()
    return [M @ (mitte + Vector((0, -b, h))) for b, h in SCHILD_UMRISS]


def gesicht_verdeckt(kopf, r, g0, sp):
    """Ansichten, in denen die Klinge (Parierstange bis Spitze) vor dem Gesicht liegt: im Bild naeher als r an der Kopfmitte und
    naeher an der Kamera als die Kopfmitte"""
    out = []
    for nm, az, el in SICHTEN:
        a, e = math.radians(az), math.radians(el)
        d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
        for i in range(13):
            p = g0 + (sp - g0) * (i / 12); q = p - kopf
            if q.dot(d) > 0.02 and (q - d * q.dot(d)).length < r:
                out.append(nm); break
    return out


def pruefen(pu, lies, namen, log=print):
    """je Bewegung und Bild: Knick im Handgelenk, Drehung des Unterarms, Klinge zu Kopf, Rumpf, Beinen und Schildarm (Luft in m,
    negativ = hinein), Sprung der Klingenspitze je Bild (m), tiefster Punkt der Sohlen und der Spitze (m); Klinge vor dem Gesicht
    (Bilder), waagerecht vor der Huefte (Bilder), Ellbogen ueber der Linie Schulter-Hand (m), Schild tiefst (m)"""
    out = {}
    for nm in namen:
        if nm not in bpy.data.actions: continue
        act = bpy.data.actions[nm]; n = int(round(act.frame_range[1] - act.frame_range[0]))
        kn_, tw_, luft, wo, spr, boden, spitze_z = 0, 0, 9.0, '', 0.0, 9.0, 9.0
        gesicht, waag, ell, schild_z = {}, [], 0.0, 9.0
        alt = None
        for f in range(n + 1):
            pu.stelle(lies(act, f)); W = lambda b: pu.W(b).translation
            H = W('hand_r'); kl = pu.klinge(); sp = H + kl * KLINGE_M; g0 = H + kl * 0.12   # ab der Parierstange
            d = pu.W('lowerarm_r').col[1].xyz.normalized()
            kn_ = max(kn_, math.degrees(pu.W('hand_r').col[1].xyz.normalized().angle(d)))
            kopf = pu.W('Head') @ pu.KOPF[0]
            for v in gesicht_verdeckt(kopf, pu.KOPF[1] * 0.8, g0, sp): gesicht.setdefault(v, []).append(f)
            vorn = (pu.W('pelvis').to_3x3() @ pu.sk.data.bones['pelvis'].matrix_local.to_3x3().inverted()) @ Vector((0, -1, 0))
            if abs(math.degrees(math.asin(max(-1.0, min(1.0, kl.z))))) < 20 and kl.dot(vorn) > 0.5 and 0.6 < H.z < 1.12 and W('pelvis').z > 0.6:
                waag.append(f)
            S_ = W('upperarm_r'); E_ = W('lowerarm_r'); u_ = (H - S_).normalized(); e_ = (E_ - S_) - u_ * (E_ - S_).dot(u_)
            un = Vector((0, 0, -1)) - u_ * (-u_.z)     # Ellbogen als Winkel um die Linie Schulter-Hand: 0 unten, 90 seitlich, 180 oben
            if e_.length > 0.03 and un.length > 0.2 and W('pelvis').z > 0.6: ell = max(ell, math.degrees(e_.angle(un)))
            schild_z = min(schild_z, min(p.z for p in schild_punkte(pu)))
            koerper = {'Kopf': (kopf, None, pu.KOPF[1]),
                       'Rumpf': (W('pelvis'), W('neck_01'), 0.15),
                       'Bein links': (W('thigh_l'), W('foot_l'), 0.08), 'Bein rechts': (W('thigh_r'), W('foot_r'), 0.08),
                       'Schildarm': (W('lowerarm_l'), W('hand_l'), 0.06)}
            for k, (a, b, r) in koerper.items():
                l_ = (_strecke(a, g0, sp) if b is None else _strecken(g0, sp, a, b)) - r
                if l_ < luft: luft, wo = l_, '%s Bild %d' % (k, f)
            if alt is not None: spr = max(spr, (sp - alt).length)
            alt = sp
            boden = min(boden, min(pu.W(b_).translation.z for b_ in ('ball_l', 'ball_r', 'Head', 'pelvis', 'spine_03', 'hand_r', 'hand_l')))
            spitze_z = min(spitze_z, sp.z)
        out[nm] = {'knick': round(kn_), 'luft_m': round(luft, 3), 'wo': wo, 'sprung_m': round(spr, 3), 'gelenk_z': round(boden, 3),
                   'spitze_z': round(spitze_z, 2), 'gesicht': {k: len(v) for k, v in gesicht.items()}, 'waagerecht': len(waag),
                   'ellbogen_grad': round(ell), 'schild_z': round(schild_z, 3)}
        log('PRUEF %-12s Knick %3d  Klinge Luft %+.3f m (%s)  Spitze je Bild bis %.2f m  Gelenk tiefst %+.3f  Spitze tiefst %.2f  '
            'vor Gesicht %s  waagerecht %s  Ellbogen %3d Grad von unten  Schild tiefst %+.3f' % (
            nm, kn_, luft, wo, spr, boden, spitze_z, {k: '%d-%d' % (v[0], v[-1]) for k, v in gesicht.items()} or '-', waag or '-', ell, schild_z))
    return out


def ease(s, art):
    return {'weich': s * s * (3 - 2 * s), 'linear': s, 'an': s * s, 'aus': 1 - (1 - s) ** 2}[art]


def mische(P0, P1, s):
    out = {}
    for b in P0:
        q0, q1 = P0[b][0], P1[b][0]
        if q0.dot(q1) < 0: q1 = -q1
        out[b] = (q0.slerp(q1, s), P0[b][1].lerp(P1[b][1], s))
    return out


def bauen(sk, INFO, stehen='Stehen', tod='Tod', log=print):
    scn = bpy.context.scene; ad = sk.animation_data
    REIHE = [b.name for b in sk.data.bones]
    RL = lambda b: sk.data.bones[b].matrix_local.to_3x3()
    # Faustloch rechts: faust_L (held-info.json, im Knochen hand_l) in die Welt der Ruhelage, gespiegelt (x -> -x), in hand_r
    aL = RL('hand_l') @ Vector(INFO['faust_L']['achse']); gL = sk.data.bones['hand_l'].matrix_local @ Vector(INFO['faust_L']['griff'])
    A = (RL('hand_r').inverted() @ Vector((-aL.x, aL.y, aL.z))).normalized()
    G = sk.data.bones['hand_r'].matrix_local.inverted() @ Vector((-gL.x, gL.y, gL.z))
    # die Klinge zeigt vom Daumen weg: in der Ruhelage (Arm haengt, Faust vorn) nach vorn (-Y)
    if (RL('hand_r') @ A).y > 0: A = -A
    N = RL('hand_l').inverted() @ Vector((1, 0, 0))      # figur.gd: Vorderseite des Schilds nach aussen (links +X) in der Ruhelage
    INFO['faust_R'] = {'knochen': 'hand_r', 'griff': [round(x, 4) for x in G], 'achse': [round(x, 4) for x in A],
                       'schneide': 'Ebene aus achse und Knochenrichtung (lokal Y)'}
    pu = Puppe(sk, A, N)
    # Kopf aus dem Netz (Ecken am Kopfknochen, mit Helm): Mitte im Knochen, Halbmesser (Pruefer Runde 1: Kopfkugel zu klein; sie sass
    # 10 cm zu tief und 2 cm zu eng)
    NETZ = next((o for o in bpy.data.objects if o.type == 'MESH' and any(m.type == 'ARMATURE' and m.object == sk for m in o.modifiers)), None)
    kv = []
    if NETZ:
        gi = {g.index: g.name for g in NETZ.vertex_groups}
        kv = [NETZ.matrix_world @ v.co for v in NETZ.data.vertices if any(gi.get(e.group) == 'Head' and e.weight > 0.5 for e in v.groups)]
    if kv:
        lo = Vector([min(q[i] for q in kv) for i in range(3)]); hi = Vector([max(q[i] for q in kv) for i in range(3)]); c = (lo + hi) / 2
        pu.KOPF = (sk.data.bones['Head'].matrix_local.inverted() @ c, max((hi - lo)[i] for i in range(3)) / 2)
    else:
        pu.KOPF = (Vector((0, 0.18, 0)), 0.13)
    INFO['kopf_kugel'] = {'mitte': [round(x, 3) for x in pu.KOPF[0]], 'r': round(pu.KOPF[1], 3)}
    VERSTECK = [b for b in ('schild_ruecken', 'schwert_griff') if b in sk.data.bones]   # geruest.py: im Kampf in der Hand
    AUS = set()
    if NETZ:
        vg = [NETZ.vertex_groups[b].index for b in VERSTECK if b in NETZ.vertex_groups]
        AUS = {v.index for v in NETZ.data.vertices if any(e.group in vg and e.weight > 0.5 for e in v.groups)}

    def lies(act, f):
        ad.action = act; ad.use_nla = False
        if hasattr(ad, 'action_slot') and act.slots: ad.action_slot = act.slots[0]
        scn.frame_set(f); P = pu.merke(); ad.action = None
        return P

    def schreibe(name, frames, schleife=False):
        act = bpy.data.actions.new(name); act.use_fake_user = True
        ad.action = act; ad.use_nla = False
        for f, P in enumerate(frames):
            for b in REIHE:
                pb = pu.PB[b]; q, l = P[b]
                pb.rotation_quaternion = q; pb.location = l
                pb.keyframe_insert('rotation_quaternion', frame=f); pb.keyframe_insert('location', frame=f)
        for b in VERSTECK:    # Rueckenschild und Griff in der Scheide: im Kampf weg (Waffe und Schild in der Hand)
            pb = pu.PB[b]; pb.scale = (0.001, 0.001, 0.001)
            for f in (0, len(frames) - 1): pb.keyframe_insert('scale', frame=f)
            pb.scale = (1, 1, 1)
        tr = ad.nla_tracks.new(); tr.name = name; tr.strips.new(name, 0, act)
        ad.action = None; ad.use_nla = True
        for t in ad.nla_tracks: t.mute = False
        return act

    for pb in pu.PB: pb.rotation_mode = 'QUATERNION'
    for t in ad.nla_tracks: t.mute = True
    st_act = bpy.data.actions[stehen]
    n_st = int(round(st_act.frame_range[1] - st_act.frame_range[0]))
    S0 = lies(st_act, 0)
    pu.stelle(S0)
    KOPF0 = {b: pu.W(b).to_3x3() for b in ('neck_01', 'Head')}
    FUSS0 = {s: pu.W('foot_' + s) for s in 'lr'}

    def blick(stark=1.0):     # Hals und Kopf halten den Blick wie in Stehen (der Rumpf dreht darunter)
        for b, k in (('neck_01', 0.5), ('Head', 1.0)):
            R = pu.W(b).to_3x3(); q = R.to_quaternion().slerp(KOPF0[b].to_quaternion(), k * stark)
            pu.setze(b, q.to_matrix())

    def fuesse(ziel=None):    # Fuesse an ihren Ort (Welt) und flach wie in Stehen; Knie nach vorn
        for s in 'lr':
            T = (ziel or {}).get(s, FUSS0[s].translation)
            pu.zwei('thigh_' + s, 'calf_' + s, T, Vector((0.15 if s == 'l' else -0.15, -1.0, 0.0)))
            pu.setze('foot_' + s, FUSS0[s].to_3x3())

    def rumpf(dreh=0.0, vor=0.0, seit=0.0):    # + dreh: rechte Schulter vor; + vor: nach vorn; + seit: nach links
        for b in ('spine_01', 'spine_02', 'spine_03'):
            pu.drehe(b, 'Z', dreh / 3); pu.drehe(b, 'X', vor / 3); pu.drehe(b, 'Y', -seit / 3)

    def becken(d=(0, 0, 0), dreh=0.0, vor=0.0, seit=0.0):
        pu.schiebe('pelvis', d)
        if dreh: pu.drehe('pelvis', 'Z', dreh)
        if vor: pu.drehe('pelvis', 'X', vor)
        if seit: pu.drehe('pelvis', 'Y', -seit)

    KN = {}
    def arm(sd, achse, hand, pol, ziel, name, kegel=24, spiel=90, leise=False):
        """Arm sd: Hand an hand, Achse nach ziel; das Gelenk (Ellbogen) um die Linie Schulter-Hand bis 90 Grad von pol weg, wo Knick
        und Verdrehung im Handgelenk am kleinsten sind (jedes Grad Abweichung zaehlt POL_KOSTEN), nie in den Rumpf"""
        P0 = pu.merke(); S_ = pu.W('upperarm_' + sd).translation.copy(); u = (Vector(hand) - S_).normalized()
        best = None
        for dl in range(-spiel, spiel + 1, 10):
            pu.stelle(P0)
            pol_ = Matrix.Rotation(math.radians(dl), 3, u) @ Vector(pol)
            rest = pu.zwei('upperarm_' + sd, 'lowerarm_' + sd, hand, pol_)
            E = pu.W('lowerarm_' + sd).translation
            c, kn, tw = pu.faust(sd, achse, ziel, nur_kosten=True, kegel=kegel)
            # Ellbogen nicht im Rumpf: Abstand zur Achse Becken-Brust unter 16 cm kostet
            B, C = pu.W('spine_01').translation, pu.W('neck_01').translation; ax = (C - B).normalized()
            q = E - B; dr = (q - ax * q.dot(ax)).length
            c += POL_KOSTEN * abs(dl) + max(0.0, 0.16 - dr) * 1000
            if best is None or c < best[0]: best = (c, dl, pol_)
        pu.stelle(P0)
        rest = pu.zwei('upperarm_' + sd, 'lowerarm_' + sd, hand, best[2])
        kn, tw = pu.faust(sd, achse, ziel, kegel=kegel)
        ab = math.degrees((pu.W('hand_' + sd).to_3x3() @ achse).angle(Vector(ziel)))
        KN[name] = (round(kn), round(tw), best[1], round(ab), round(rest, 3))
        if not leise and (kn > KNICK_MAX or abs(tw) > VERDREH_MAX or rest > 0.01):
            log('KAMPF Warnung %s Knick %d Grad, Verdrehung %d, Ellbogen %d Grad von pol, Hand verfehlt %.3f m' % (name, kn, tw, best[1], rest))

    def schwertarm(hand, pol, klinge, schulter=0.0, name='', spiel=90, wahl=(), kegel=24):
        """wahl: weitere Klingenrichtungen; genommen wird die, bei der das Handgelenk am wenigsten knickt und verdreht"""
        if schulter: pu.drehe('clavicle_r', 'Y', schulter)
        if wahl:
            P0 = pu.merke(); best = None
            for k_ in (klinge,) + tuple(wahl):
                pu.stelle(P0); arm('r', A, hand, pol, Vector(k_).normalized(), name, spiel=spiel, leise=True, kegel=kegel)
                c = KN[name][0] + VERDREH * abs(KN[name][1]) + 5 * max(0, KN[name][0] - KNICK_MAX)
                if best is None or c < best[0]: best = (c, k_)
            pu.stelle(P0); klinge = best[1]; log('KAMPF %s Klinge %s' % (name, tuple(round(x, 2) for x in klinge)))
        arm('r', A, hand, pol, Vector(klinge).normalized(), name, spiel=spiel, kegel=kegel)

    def schildarm(hand, pol, vorn, name=''):
        arm('l', N, hand, pol, vorn, name + ' Schild')

    # ------------------------------------------------------------ Kampfstehen: Stehen, Schwertarm in Bereitschaft
    BEREIT = dict(hand=(-0.25, -0.20, 1.06), pol=(-0.5, 0.6, -0.3), klinge=(-0.20, -0.45, 0.85))
    pu.stelle(S0); schwertarm(name='Bereit', **BEREIT)
    ARM_R = ('clavicle_r', 'upperarm_r', 'lowerarm_r', 'hand_r')
    B0 = pu.merke(); ARM = {b: B0[b] for b in ARM_R}
    kampfstehen = []
    for f in range(n_st + 1):
        P = lies(st_act, f); P.update(ARM); kampfstehen.append(P)
    schreibe('Kampfstehen', kampfstehen, True)
    K0 = kampfstehen[0]

    # ------------------------------------------------------------ Schluesselbilder
    def pose(fn):
        pu.stelle(K0); fn(); return pu.merke()

    def ausgeholt(stark=1.0):     # Schwert ueber der rechten Schulter, Klinge nach hinten unten, Rumpf rechts zurueck
        # Runde 2 (Pruefer: Klinge durch den Kopf statt ueber die rechte Schulter): Faust 10 cm weiter rechts, Klinge nach rechts hinten
        becken((0, 0.03 * stark, -0.03 * stark), dreh=-8 * stark)
        rumpf(dreh=-18 * stark, vor=-4 * stark)
        fuesse()
        schwertarm((-0.32, 0.04, 1.64), (-0.6, 0.3, 0.3), (-0.30, 0.78, -0.55), schulter=10 * stark, name='Ausgeholt')
        blick()

    def ausfall(vor_cm=22, tief=0.07):   # linker Fuss vor, Becken vor und tief
        becken((0, -0.10 * vor_cm / 22, -tief), dreh=6)
        fl = FUSS0['l'].translation + Vector((0.0, -vor_cm / 100.0, 0.0))
        fuesse({'l': fl})

    def hieb_mitte():
        ausfall(14, 0.04); rumpf(dreh=-2, vor=4)
        schwertarm((-0.24, -0.20, 1.62), (-0.8, 0.2, 0.2), (-0.15, -0.55, 0.82), schulter=6, name='Hieb Mitte')
        blick()

    def aufschlag():    # schraeg von rechts oben nach links unten, Faust vor der linken Huefte, Spitze links unten zum Boden
        # Runde 2 (Pruefer: Faust im Schritt, Klinge waagerecht vor der Huefte): Faust 13 cm weiter links, Klinge steil nach unten
        ausfall(); rumpf(dreh=16, vor=10)
        schwertarm((0.08, -0.42, 1.04), (-0.6, 0.0, -0.8), (0.40, -0.50, -0.77), name='Aufschlag')
        blick()

    # Runde 2 (Pruefer: Stich mit dem Ellbogen hoch): Ellbogen nach unten aussen, hoechstens 30 Grad davon weg (sonst waehlte der Bau
    # 60 und 90 Grad, weil die Faust so weniger knickt); Stoss: Faust auf Brusthoehe, Klinge aus der wahl (tiefer stand sie waagerecht
    # vor dem Bauch, hoeher verdrehte der Unterarm ueber 120 Grad)
    def stich_zurueck():   # Faust an die rechte Brustseite zurueck, Klinge nach vorn, leicht gehoben
        becken((0, 0.04, -0.03), dreh=-10); rumpf(dreh=-16)
        fuesse()
        schwertarm((-0.26, 0.10, 1.18), (-0.3, 0.5, -1.0), (0.08, -0.97, 0.20), name='Stich zurueck', spiel=30)
        blick()

    def stoss():           # Faust vor, Klinge auf Brusthoehe nach vorn
        ausfall(24, 0.08); rumpf(dreh=14, vor=8)
        schwertarm((-0.20, -0.46, 1.22), (-0.5, 0.2, -1.0), (0.25, -0.96, 0.10), name='Stoss', spiel=30, kegel=8,
                   wahl=[(x_, -1.0, z_) for x_ in (0.0, 0.25, 0.5, 0.75) for z_ in (-0.15, 0.0, 0.15)])
        blick()

    # Runde 2 (Pruefer: Treffer und Ausweichen zu schwach): etwa doppelt so weit
    def getroffen():       # Ruck nach hinten: Becken und Brust zurueck, Kopf mit, Schwertarm faellt ab
        becken((0, 0.12, -0.04), vor=-6); rumpf(dreh=-10, vor=-24, seit=6)
        fuesse()
        schwertarm((-0.34, 0.0, 0.98), (-0.6, 0.6, -0.3), (-0.45, -0.45, 0.77), name='Treffer')
        blick(0.2); pu.drehe('Head', 'X', -18)

    def ausweichen():      # Schritt nach links weg, Knie gebeugt, Oberkoerper seitlich; Schwert aussen rechts, nicht vor dem Gesicht
        becken((0.26, 0.10, -0.12), dreh=-14, seit=8); rumpf(dreh=-14, vor=-8, seit=16)
        fuesse({'l': FUSS0['l'].translation + Vector((0.32, 0.06, 0.0)), 'r': FUSS0['r'].translation + Vector((0.12, 0.04, 0.0))})
        schwertarm((-0.30, -0.04, 1.08), (-0.6, 0.6, -0.3), (-0.50, -0.25, 0.83), name='Ausweichen')
        blick(0.7)

    def abwehr():          # Schild vor die Brust, Vorderseite nach vorn; Schwert rechts hinten hochgenommen, Knie etwas gebeugt
        # Runde 2 (Pruefer: Klinge vor dem Gesicht): Klinge nach rechts hinten oben statt senkrecht vor der Schulter
        becken((0, 0.03, -0.05), dreh=8); rumpf(dreh=6, vor=4)
        fuesse()
        schildarm((0.06, -0.30, 1.14), (1.0, -0.2, -0.4), (-0.15, -0.95, 0.25), name='Abwehr')
        schwertarm((-0.32, 0.06, 1.12), (-0.6, 0.6, -0.3), (-0.35, 0.40, 0.85), name='Abwehr')
        blick()

    def hoch():            # Rueckweg vom Aufschlag: Faust hoch vor den Bauch, Klinge links aufgerichtet
        ausfall(7, 0.02); rumpf(dreh=8, vor=4)
        schwertarm((0.0, -0.40, 1.14), (-0.6, 0.0, -0.8), (0.90, -0.10, 0.35), name='Hieb hoch')
        blick()

    P = {n: pose(fn) for n, fn in (('aus', ausgeholt), ('hoch', hoch), 
                                    ('auf', aufschlag), ('szur', stich_zurueck), ('stoss', stoss), ('treffer', getroffen),
                                    ('ausw', ausweichen), ('abwehr', abwehr))}
    P['k0'] = K0
    # Hieb ueber den Kopf (Pruefung: die Klinge streifte den Kopf mit 1 cm Luft): Mitte aus der Mischung, die Hand 8 cm hoeher und 6 cm
    # weiter rechts, Klinge und Ellbogen wie dort
    pu.stelle(mische(P['aus'], P['auf'], 0.5))
    H_, E_ = pu.W('hand_r').translation.copy(), pu.W('lowerarm_r').translation.copy(); kl_ = pu.klinge()
    S_ = pu.W('upperarm_r').translation; u_ = (H_ - S_).normalized(); pol_ = (E_ - S_) - u_ * (E_ - S_).dot(u_)
    arm('r', A, H_ + Vector((-0.06, 0.0, 0.08)), pol_, kl_, 'Hieb Mitte', kegel=0)
    P['mitte'] = pu.merke()

    ARME = [b + s for s in ('_r', '_l') for b in ('clavicle', 'upperarm', 'lowerarm', 'hand')]
    BEINE = [b + s for s in ('_r', '_l') for b in ('thigh', 'calf', 'foot', 'ball')]

    def netz_tief():      # tiefster Punkt des Netzes ohne die ausgeblendeten Teile (m)
        if not NETZ: return None
        dg = bpy.context.evaluated_depsgraph_get(); ev = NETZ.evaluated_get(dg); me = ev.to_mesh()
        z = [v.co.z for i, v in enumerate(me.vertices) if i not in AUS]
        ev.to_mesh_clear()
        return min(z)

    def tod_liegen(frames):
        nt = len(frames) - 1
        W = lambda b: pu.W(b).translation
        ad.action = None; ad.use_nla = False
        zb = []
        for P_ in frames:
            pu.stelle(P_); zb.append((W('pelvis').z, W('spine_03').z))
        f0 = next(f for f in range(nt + 1) if zb[f][0] < 0.6)                 # Becken sinkt: das Fallen beginnt
        f1 = next(f for f in range(f0, nt + 1) if zb[f][1] < 0.25)            # Brust am Boden
        pu.stelle(frames[-1])
        lang = W('Head') - W('pelvis'); lang.z = 0; lang.normalize()             # zum Kopf
        rechts = (pu.W('pelvis').to_3x3() @ sk.data.bones['pelvis'].matrix_local.to_3x3().inverted()) @ Vector((-1, 0, 0))
        rechts.z = 0; rechts.normalize()
        Sr, Sl = W('upperarm_r').copy(), W('upperarm_l').copy()
        hr = Sr + rechts * 0.40 - lang * 0.15; hr.z = 0.05
        # Klinge flach am Boden: die Richtung (um die Hochachse), in der das Handgelenk am wenigsten knickt und verdreht
        P0 = pu.merke(); best = None
        for w_ in range(-80, 81, 20):    # nur nach aussen: nach innen stach die Klinge im Fallen durch den Rumpf
            kl_ = (Matrix.Rotation(math.radians(w_), 3, 'Z') @ rechts); kl_.z = -0.04; kl_.normalize()
            pu.stelle(P0); arm('r', A, hr, rechts + Vector((0, 0, -0.3)), kl_, 'Tod', kegel=0, leise=True)
            kn_, tw_ = KN['Tod'][:2]; sp_ = pu.W('hand_r').translation + pu.klinge() * KLINGE_M
            c = kn_ + VERDREH * abs(tw_) + 500 * max(0.0, 0.25 - _strecke(pu.W('spine_03').translation, hr, sp_))
            if best is None or c < best[0]: best = (c, w_, pu.merke())
        pu.stelle(best[2]); log('KAMPF Tod Klinge %d Grad von rechts, Knick und Verdrehung %s' % (best[1], KN['Tod'][:2]))
        hl = Sl - rechts * 0.36 - lang * 0.10; hl.z = 0.06
        arm('l', N, hl, -rechts + Vector((0, 0, -0.3)), Vector((0, 0, 1)), 'Tod Schild')
        E = pu.merke()
        out = []
        for f, P_ in enumerate(frames):
            P_ = dict(P_)
            ka = ease(max(0.0, min(1.0, (f - f0) / max(1, f1 + 2 - f0))), 'weich')
            kb = 0.8 * ease(max(0.0, min(1.0, (f - f1 + 2) / 6.0)), 'weich') if f < nt - 6 else 1.0
            for b in ARME: P_[b] = mische({b: P_[b]}, {b: E[b]}, ka)[b]
            for b in BEINE: P_[b] = mische({b: P_[b]}, {b: frames[-1][b]}, kb)[b]
            pu.stelle(P_)
            if f >= f0:
                z = netz_tief()
                if z is not None: pu.schiebe('pelvis', (0, 0, -z))
            out.append(pu.merke())
        log('KAMPF Tod: Fallen ab Bild %d, liegt ab %d, Boden %s' % (f0, f1, 'Netz' if NETZ else '-'))
        return out

    def folge(name, keys, schleife=False):
        """keys: (Zeit s, Pose, Verlauf bis zum naechsten)"""
        n = int(round(keys[-1][0] * FPS)); out = []
        for i in range(n + 1):
            t = i / FPS
            j = max(j for j in range(len(keys) - 1) if keys[j][0] <= t + 1e-9) if t < keys[-1][0] else len(keys) - 2
            (t0, p0, v0), (t1, p1, _) = keys[j], keys[j + 1]
            s = ease(min(1.0, (t - t0) / (t1 - t0)), v0)
            out.append(mische(P[p0], P[p1], s))
        schreibe(name, out, schleife)
        INFO.setdefault('bewegungen', {})[name] = {'quelle': 'eigen (kampf.py)', 'bilder': n}
        return out

    # Ausholen 0,4 s, dann gehalten (figur.gd: Zauber und Fernkampf, 0,6 s, dann Ruhe)
    folge('Ausholen', [(0.0, 'k0', 'weich'), (0.40, 'aus', 'weich')])
    # Hieb 0,8 s: ausholen bis 0,18, Halt bis 0,22, Schlag 0,14 s bis 0,36 (ueber den Kopf: Mitte als eigener Schluessel drehte den Unterarm
    # 137 Grad), Halt am Aufschlag bis 0,46, zurueck bis 0,80
    folge('Hieb', [(0.0, 'k0', 'weich'), (0.18, 'aus', 'linear'), (0.22, 'aus', 'an'), (0.29, 'mitte', 'linear'), (0.36, 'auf', 'linear'),
                   (0.46, 'auf', 'weich'), (0.62, 'hoch', 'weich'), (0.80, 'k0', 'weich')])
    # Stich 0,6 s: zurueck bis 0,18, Stoss bis 0,28, Halt bis 0,36, zurueck bis 0,60
    folge('Stich', [(0.0, 'k0', 'weich'), (0.18, 'szur', 'an'), (0.28, 'stoss', 'linear'), (0.36, 'stoss', 'weich'),
                    (0.60, 'k0', 'weich')])
    # Treffer 0,45 s (figur.gd ruht nach 0,45 s): Ruck 0,08 s, zurueck
    folge('Treffer', [(0.0, 'k0', 'aus'), (0.08, 'treffer', 'linear'), (0.14, 'treffer', 'weich'), (0.45, 'k0', 'weich')])
    # Ausweichen 0,45 s: weg 0,14 s, Halt, zurueck
    folge('Ausweichen', [(0.0, 'k0', 'aus'), (0.14, 'ausw', 'linear'), (0.22, 'ausw', 'weich'), (0.45, 'k0', 'weich')])
    # Abwehr 0,25 s hinein, dann gehalten
    folge('Abwehr', [(0.0, 'k0', 'aus'), (0.25, 'abwehr', 'weich')])
    # Tod: Death01 (geruest.py) beginnt in Stehen; die ersten 0,25 s aus Kampfstehen hinein
    if tod in bpy.data.actions:
        ta = bpy.data.actions[tod]; nt = int(round(ta.frame_range[1] - ta.frame_range[0]))
        frames = [lies(ta, f) for f in range(nt + 1)]
        m = 8
        for f in range(min(m, nt) + 1):
            frames[f] = mische(K0, frames[f], ease(f / m, 'weich'))
        # Unterarm und Hand bleiben wie in Kampfstehen gegen den Oberarm (Pruefung: mit der haengenden Hand der Quelle stach die
        # Klinge 14 cm in den Rumpf)
        for f in range(nt + 1):
            for b in ('lowerarm_r', 'hand_r'): frames[f][b] = K0[b]
        # Runde 2 (Pruefer: Sitz in der Luft, Beine hoch, Schwert senkrecht, Schild im Boden): liegend die Arme in eine Endlage am Boden
        # (Schwert flach neben der rechten Hand, Schild flach auf dem linken Unterarm), die Beine nach dem Aufschlag zur Endlage hin
        # gedaempft, je Bild der tiefste Punkt des Netzes auf den Boden (der Rueckenschild ist im Kampf weg)
        frames = tod_liegen(frames)
        for t in list(ad.nla_tracks):
            if t.name == tod: ad.nla_tracks.remove(t)
        bpy.data.actions.remove(ta)
        schreibe(tod, frames)
    INFO['kampf_knick'] = KN
    INFO['kampf_pruefung'] = pruefen(pu, lies, ['Kampfstehen', 'Ausholen', 'Hieb', 'Stich', 'Treffer', 'Ausweichen', 'Abwehr', tod], log)
    pu.stelle({b: (Quaternion(), Vector()) for b in REIHE})
    for t in ad.nla_tracks: t.mute = False
    log('KAMPF', KN)
    return pu


if __name__ == '__main__' and len(sys.argv) > 2 and sys.argv[-2].endswith('.blend'):
    import json
    bpy.ops.wm.open_mainfile(filepath=sys.argv[-2])
    out = sys.argv[-1]
    sk = bpy.data.objects['Held_Skelett']; held = bpy.data.objects['Held_Netz']
    INFO = json.load(open(os.path.join(os.path.dirname(sys.argv[-2]), 'held-info.json')))
    bauen(sk, INFO)
    json.dump(INFO, open(out.replace('.glb', '-info.json'), 'w'), indent=1, ensure_ascii=False)
    bpy.ops.object.select_all(action='DESELECT'); sk.select_set(True); held.select_set(True)
    bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True, export_animations=True,
                              export_skins=True, export_vertex_color='ACTIVE', export_animation_mode='NLA_TRACKS',
                              export_yup=True, export_apply=False)
    bpy.ops.wm.save_as_mainfile(filepath=out.replace('.glb', '.blend'))
    print('GLB OK', os.path.getsize(out))
