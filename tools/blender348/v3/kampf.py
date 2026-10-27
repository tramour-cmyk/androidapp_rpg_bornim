# 348.6 Kampfbewegungen des Helden (von Jerry 27.10.; Vorrang Perikles 338.1): Kampfstehen, Ausholen, Hieb, Stich, Treffer,
# Ausweichen, Abwehr und Tod aus eigenen Schluesselbildern auf unserem Skelett (Tod bis Runde 2 aus Death01, geruest.py HELD). Die Bibliothek hat dafuer nichts Brauchbares (Sword_Attack ist ein Stoss von hinter dem Kopf, Jerry Runde 4;
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
import bpy, math, os, sys, json
import numpy as np
from mathutils import Vector, Matrix, Quaternion

FPS = 30
KNICK_MAX = 50.0     # Grad: Handgelenk gegen den Unterarm, darueber meldet der Bau
VERDREH_MAX = 100.0  # Grad: Unterarm um seine Achse gegen die Ruhelage (Stoss mit der Handflaeche nach unten: um 90)
VERDREH = 0.4        # Gewicht der Verdrehung gegen den Knick bei der Wahl der Handdrehung
POL_KOSTEN = 0.15    # je Grad, das der Ellbogen von der gewuenschten Seite abweicht
KEGEL_KOSTEN = 0.5   # je Grad, das die Klinge (der Schild) von der gewuenschten Richtung abweicht
OBEN_KOSTEN = 0.8    # je Grad, das die Oberkante des Schilds von oben abweicht (Runde 3)


def _upd():
    bpy.context.view_layer.update()


class Puppe:
    def __init__(self, sk, achse_r, schild_n):
        self.sk = sk; self.PB = sk.pose.bones
        self.A = achse_r          # Faustloch rechts im Raum des Handknochens
        self.N = schild_n         # Vorderseite des Schilds im Raum des linken Handknochens
        self.O = sk.data.bones['hand_l'].matrix_local.to_3x3().inverted() @ Vector((0, 0, 1))   # Oberkante des Schilds dort
        self.REIHE = [b.name for b in sk.data.bones]

    def stelle(self, P):    # Groesse immer 1 (Runde 3: ueber viele Zuweisungen von pb.matrix wuchs die Hand bis auf 80fach)
        for b, (q, l) in P.items():
            self.PB[b].rotation_quaternion = q; self.PB[b].location = l; self.PB[b].scale = (1, 1, 1)
        _upd()

    def merke(self):
        return {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in self.PB}

    def W(self, b):
        return self.PB[b].matrix.copy()

    def setze(self, b, R3, kopf=None):
        pb = self.PB[b]; h = pb.matrix.translation.copy() if kopf is None else kopf
        pb.matrix = Matrix.Translation(h) @ R3.to_quaternion().to_matrix().to_4x4(); pb.scale = (1, 1, 1); _upd()

    def drehe(self, b, achse, grad):     # Knochen b um eine Weltachse an seinem Kopf
        pb = self.PB[b]; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(grad), 4, achse) @ Matrix.Translation(-h) @ pb.matrix
        pb.scale = (1, 1, 1); _upd()

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

    def faust(self, s, achse, ziel_dir, nur_kosten=False, kegel=0, oben=None):
        """Hand s so drehen, dass ihre achse (lokal) nach ziel_dir zeigt; um diese Richtung so gedreht, dass Knick gegen den
        Unterarm und Verdrehung um ihn zusammen am kleinsten sind (Verdrehung zaehlt VERDREH-fach); die Verdrehung uebernimmt der
        Unterarm (sonst verwringt das Handgelenk). oben: (lokale Achse, Weltrichtung) soll moeglichst dorthin zeigen (Schild
        aufrecht, Runde 3), jedes Grad kostet OBEN_KOSTEN. Gibt Knick und Verdrehung (Grad)."""
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
            if oben: c += OBEN_KOSTEN * math.degrees((R @ oben[0]).angle(oben[1]))
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

    def schild_oben(self):   # Oberkante des Schilds (figur.gd _hold: in der Ruhelage der Hand +Z)
        return (self.W('hand_l').to_3x3() @ self.O).normalized()


KLINGE_M = 0.75      # Langschwert: Griffpunkt bis Spitze (longsword.glb 0,753 m)
# Schild wie figur.gd _hold (kampfblatt.py): in der Ruhelage der linken Hand Breite laengs -Y, Hoehe +Z, Vorderseite +X; Griff 0,35 der
# Handknochenlaenge (15,7 cm), 4 cm nach aussen; Umriss aus shield.glb (Breite 0,56, oben 0,30, Spitze unten 0,42)
SCHILD_UMRISS = [(-0.28, 0.30), (0.28, 0.30), (-0.28, 0.0), (0.28, 0.0), (0.0, -0.42), (-0.2, -0.25), (0.2, -0.25)]
# Ansichten fuer „Klinge vor dem Gesicht“: Kontaktblatt vorn links und vorn rechts (15 Grad), Spielkamera schraeg (45 Grad)
SICHTEN = [('vorn links', 35, 15), ('vorn rechts', -35, 15), ('vorn', 0, 45)]
GESICHT_ANTEIL = 0.10   # Runde 3: so viel des sichtbaren Gesichts darf die Klinge in einem Bild verdecken


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


def klinge_im_schild(pu, g0, sp):
    """Runde 4: schneidet die Klinge die Schildflaeche (Ellipse 0,56 x 0,72 m um die Mitte des Umrisses, Platte 4 cm dick)"""
    pts = schild_punkte(pu); c = sum(pts, Vector()) / len(pts)
    n = pu.schild(); o = pu.schild_oben(); o = (o - n * o.dot(n)).normalized(); q = n.cross(o)
    for i in range(13):
        p = g0 + (sp - g0) * (i / 12) - c
        if abs(p.dot(n)) < 0.02 and (p.dot(q) / 0.28) ** 2 + (p.dot(o) / 0.36) ** 2 < 1.0: return True
    a, b = (g0 - c).dot(n), (sp - c).dot(n)
    if a * b < 0:     # Klinge geht durch die Ebene: Schnittpunkt
        p = g0 + (sp - g0) * (a / (a - b)) - c
        return (p.dot(q) / 0.28) ** 2 + (p.dot(o) / 0.36) ** 2 < 1.0
    return False


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


def _bildachsen(d):    # zwei Bildachsen zur Blickrichtung d (zur Kamera hin)
    e1 = d.cross(Vector((0, 0, 1))).normalized(); e2 = e1.cross(d).normalized()
    return np.array(e1), np.array(e2), np.array(d)


def _abstand_strecke(Q, A, B):
    """Abstand der Punkte Q (n x k) zu den Strecken A-B (m x k): (n x m) Abstaende und Lage t auf der Strecke"""
    AB = B - A; t = np.clip(((Q[:, None, :] - A[None]) * AB[None]).sum(-1) / np.maximum((AB * AB).sum(-1), 1e-12)[None], 0, 1)
    C = A[None] + t[..., None] * AB[None]
    return np.linalg.norm(Q[:, None, :] - C, axis=-1), t


class Netz:
    """Runde 3: das verformte Netz je Bild als numpy, mit den Teilen aus rig.py (Attribut teil, teile.json) und dem staerksten Knochen
    je Ecke; ohne die im Kampf ausgeblendeten Teile"""
    def __init__(self, ob, tn, aus):
        self.ob = ob; me = ob.data; n = len(me.vertices)
        t = np.zeros(n, np.int32)
        if 'teil' in me.attributes: me.attributes['teil'].data.foreach_get('value', t)
        name = np.array([tn[i] if i < len(tn) else '?' for i in t])
        gi = {g.index: g.name for g in ob.vertex_groups}
        kn = np.array([gi[max(v.groups, key=lambda e: e.weight).group] if len(v.groups) else '-' for v in me.vertices])
        self.aus = np.zeros(n, bool); self.aus[list(aus)] = True
        da = ~self.aus
        nr = np.zeros(n * 3); me.vertices.foreach_get('normal', nr); nr = nr.reshape(-1, 3)
        # Gesicht: Kopfhaut, deren Normale in der Ruhelage nach vorn zeigt
        self.gesicht = da & (name == 'head') & (nr[:, 1] < -0.4)
        self.umhang = da & (name == 'cloak')
        # Rumpf zum Aufliegen: Becken bis Kopf und Oberschenkel, ohne Arme, Umhang, Scheide
        self.rumpf = da & np.isin(kn, ('pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head', 'thigh_l', 'thigh_r')) & \
            ~np.isin(name, ('cloak', 'Cylinder', 'Sphere', 'shield', 'boss'))
        self.beine = da & np.isin(kn, ('calf_l', 'calf_r', 'foot_l', 'foot_r', 'ball_l', 'ball_r'))
        self.seite = {s: np.array([k.endswith('_' + s) for k in kn]) for s in 'lr'}
        self.arme = da & np.array([k.startswith(('upperarm', 'lowerarm', 'hand')) for k in kn])
        self.unterarme = da & np.array([k.startswith(('lowerarm', 'hand')) for k in kn])
        self.scheide = da & np.isin(name, ('Cylinder', 'Sphere'))
        # Runde 4: unterer Umhang am Knochen umhang (geruest.py), klappt im Tod nach hinten
        gu = ob.vertex_groups['umhang'].index if 'umhang' in ob.vertex_groups else -1
        self.umhang_u = self.umhang & np.array([any(e.group == gu and e.weight > 0.3 for e in v.groups) for v in me.vertices])
        self.alle = da

    def lies(self):
        dg = bpy.context.evaluated_depsgraph_get(); ev = self.ob.evaluated_get(dg); m = ev.to_mesh()
        n = len(m.vertices); P = np.zeros(n * 3); N = np.zeros(n * 3)
        m.vertices.foreach_get('co', P); m.vertices.foreach_get('normal', N); ev.to_mesh_clear()
        M = np.array(self.ob.matrix_world); P = P.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]; N = N.reshape(-1, 3) @ M[:3, :3].T
        self.P, self.N = P, N
        return P

    def tief(self, maske):
        self.lies(); return float(self.P[maske, 2].min()) if maske.any() else 9.0

    def gesicht_deckung(self, g0, sp):
        """je Ansicht der Anteil der sichtbaren Gesichtsecken, vor denen im Bild die Klinge (Parierstange bis Spitze, 2,5 cm um
        die Mitte) naeher an der Kamera liegt"""
        out = {}
        F, Fn = self.P[self.gesicht], self.N[self.gesicht]
        S = np.array([g0 + (sp - g0) * (i / 12) for i in range(13)])
        for nm, az, el in SICHTEN:
            a, e = math.radians(az), math.radians(el)
            d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
            e1, e2, dd = _bildachsen(d)
            sicht = Fn @ dd > 0.1
            if sicht.sum() < 5: continue
            f = F[sicht]; Q = np.stack([f @ e1, f @ e2], 1); fz = f @ dd
            s2 = np.stack([S @ e1, S @ e2], 1); sz = S @ dd
            ab, t = _abstand_strecke(Q, s2[:-1], s2[1:])
            zc = sz[:-1][None] + t * (sz[1:] - sz[:-1])[None]
            out[nm] = float(((ab < 0.025) & (zc > fz[:, None] + 0.01)).any(1).mean())
        return out

    def nah(self, maske, g0, sp, r=0.02):   # Ecken von maske naeher als r an der Klinge (3D)
        Q = self.P[maske]
        if not len(Q): return 0
        S = np.array([g0 + (sp - g0) * (i / 12) for i in range(13)])
        ab, _ = _abstand_strecke(Q, S[:-1], S[1:])
        return int((ab.min(1) < r).sum())


def pruefen(pu, lies, namen, log=print, NZ=None):
    """je Bewegung und Bild: Knick im Handgelenk, Drehung des Unterarms, Klinge zu Kopf, Rumpf, Beinen und Schildarm (Luft in m,
    negativ = hinein), Sprung der Klingenspitze je Bild (m), tiefster Punkt der Sohlen und der Spitze (m); Klinge vor dem Gesicht
    (Bilder mit mehr als GESICHT_ANTEIL der sichtbaren Gesichtsecken verdeckt, je Ansicht), durch den Umhang (Bilder), waagerecht vor
    der Huefte, waagerecht zur Seite, senkrecht vor den Beinen (Bilder), Ellbogen ueber der Linie Schulter-Hand (Grad), Schild tiefst
    (m) und Oberkante gegen oben (Grad, groesster Wert stehend); Netz tiefst (m), im Liegen Rumpf hoechstens ueber dem Boden (m)"""
    out = {}
    K0 = lies(bpy.data.actions[namen[0]], 0)
    for nm in namen:
        if nm not in bpy.data.actions: continue
        act = bpy.data.actions[nm]; n = int(round(act.frame_range[1] - act.frame_range[0]))
        P0 = lies(act, 0)     # Runde 4 (Pruefer 3: Tod 0,00 anders als Kampfstehen 0,00): groesste Drehung eines Knochens gegen Kampfstehen
        start = max(math.degrees(P0[b][0].rotation_difference(K0[b][0]).angle) + 100 * (P0[b][1] - K0[b][1]).length for b in K0)
        durch, kopf0, kopf_s, sicht = [], None, 0.0, {}
        kn_, tw_, luft, wo, spr, boden, spitze_z = 0, 0, 9.0, '', 0.0, 9.0, 9.0
        gesicht, waag, seit, senk, umh, ell, schild_z, schild_oben = {}, [], [], [], [], 0.0, 9.0, 0.0
        netz_z, rumpf_hoch, hand_z = 9.0, 0.0, 9.0
        alt = None
        for f in range(n + 1):
            pu.stelle(lies(act, f)); W = lambda b: pu.W(b).translation
            H = W('hand_r'); kl = pu.klinge(); sp = H + kl * KLINGE_M; g0 = H + kl * 0.12   # ab der Parierstange
            d = pu.W('lowerarm_r').col[1].xyz.normalized()
            kn_ = max(kn_, math.degrees(pu.W('hand_r').col[1].xyz.normalized().angle(d)))
            kopf = pu.W('Head') @ pu.KOPF[0]
            steht = W('pelvis').z > 0.6
            vorn = (pu.W('pelvis').to_3x3() @ pu.sk.data.bones['pelvis'].matrix_local.to_3x3().inverted()) @ Vector((0, -1, 0))
            rechts = (pu.W('pelvis').to_3x3() @ pu.sk.data.bones['pelvis'].matrix_local.to_3x3().inverted()) @ Vector((-1, 0, 0))
            if NZ:
                NZ.lies()
                for v, a_ in NZ.gesicht_deckung(g0, sp).items():
                    if a_ > GESICHT_ANTEIL: gesicht.setdefault(v, []).append(f)
                if NZ.nah(NZ.umhang, g0, sp) > 0: umh.append(f)
                netz_z = min(netz_z, float(NZ.P[NZ.alle, 2].min()))
                hand_z = min(hand_z, float(NZ.P[NZ.arme, 2].min()))
                if nm == 'Tod' and f >= n - 30: rumpf_hoch = max(rumpf_hoch, float(NZ.P[NZ.rumpf, 2].min()))
            else:
                for v in gesicht_verdeckt(kopf, pu.KOPF[1] * 0.8, g0, sp): gesicht.setdefault(v, []).append(f)
            neig = math.degrees(math.asin(max(-1.0, min(1.0, kl.z))))
            if abs(neig) < 20 and kl.dot(vorn) > 0.5 and 0.6 < H.z < 1.12 and steht: waag.append(f)
            if abs(neig) < 20 and abs(kl.dot(rechts)) > 0.75 and steht: seit.append(f)
            if neig < -60 and steht and abs((sp - W('pelvis')).dot(rechts)) < 0.25 and (sp - W('pelvis')).dot(vorn) > 0: senk.append(f)
            S_ = W('upperarm_r'); E_ = W('lowerarm_r'); u_ = (H - S_).normalized(); e_ = (E_ - S_) - u_ * (E_ - S_).dot(u_)
            un = Vector((0, 0, -1)) - u_ * (-u_.z)     # Ellbogen als Winkel um die Linie Schulter-Hand: 0 unten, 90 seitlich, 180 oben
            if e_.length > 0.03 and un.length > 0.2 and steht: ell = max(ell, math.degrees(e_.angle(un)))
            schild_z = min(schild_z, min(p.z for p in schild_punkte(pu)))
            if steht: schild_oben = max(schild_oben, math.degrees(pu.schild_oben().angle(Vector((0, 0, 1)))))
            koerper = {'Kopf': (kopf, None, pu.KOPF[1]),
                       'Rumpf': (W('pelvis'), W('neck_01'), 0.15),
                       'Bein links': (W('thigh_l'), W('foot_l'), 0.08), 'Bein rechts': (W('thigh_r'), W('foot_r'), 0.08),
                       'Schildarm': (W('lowerarm_l'), W('hand_l'), 0.06)}
            for k, (a, b, r) in koerper.items():
                l_ = (_strecke(a, g0, sp) if b is None else _strecken(g0, sp, a, b)) - r
                if l_ < luft: luft, wo = l_, '%s Bild %d' % (k, f)
            # Runde 4: Klinge durch den Schild (Pruefer 3: Hieb 0,33-0,57), Kopf zur Seite gegen Bild 0 (Ausweichen wie Ducken),
            # sichtbare Klingenlaenge je Ansicht (Kampfstehen von vorn rechts unsichtbar)
            if klinge_im_schild(pu, g0, sp): durch.append(f)
            if kopf0 is None: kopf0, r0 = kopf.copy(), rechts.copy()
            kopf_s = max(kopf_s, abs((kopf - kopf0).dot(r0)))
            for v_, az_, el_ in SICHTEN[:2]:
                a_, e_ = math.radians(az_), math.radians(el_)
                dv = Vector((math.sin(a_) * math.cos(e_), -math.cos(a_) * math.cos(e_), math.sin(e_)))
                sicht[v_] = min(sicht.get(v_, 1.0), math.sqrt(max(0.0, 1 - kl.dot(dv) ** 2)))
            if alt is not None: spr = max(spr, (sp - alt).length)
            alt = sp
            boden = min(boden, min(pu.W(b_).translation.z for b_ in ('ball_l', 'ball_r', 'Head', 'pelvis', 'spine_03', 'hand_r', 'hand_l')))
            spitze_z = min(spitze_z, sp.z)
        out[nm] = {'knick': round(kn_), 'luft_m': round(luft, 3), 'wo': wo, 'sprung_m': round(spr, 3), 'gelenk_z': round(boden, 3),
                   'spitze_z': round(spitze_z, 2), 'gesicht': {k: len(v) for k, v in gesicht.items()}, 'waagerecht': len(waag),
                   'seitlich': len(seit), 'senkrecht_vor_beinen': len(senk), 'umhang': len(umh),
                   'ellbogen_grad': round(ell), 'schild_z': round(schild_z, 3), 'schild_oben_grad': round(schild_oben),
                   'netz_z': round(netz_z, 3), 'hand_z': round(hand_z, 3), 'rumpf_hoch_m': round(rumpf_hoch, 3),
                   'start_grad': round(start, 1), 'durch_schild': len(durch), 'kopf_seite_m': round(kopf_s, 3),
                   'klinge_sichtbar': {k: round(v, 2) for k, v in sicht.items()}}
        log('PRUEF %-12s Knick %3d  Klinge Luft %+.3f m (%s)  Spitze je Bild bis %.2f m  Gelenk tiefst %+.3f  Spitze tiefst %.2f  '
            'vor Gesicht %s  Umhang %s  waagerecht %s  seitlich %s  senkrecht vor Beinen %s  Ellbogen %3d Grad von unten  Schild tiefst %+.3f'
            '  Schild oben %d Grad  Netz tiefst %+.3f  Hand tiefst %+.3f  Start %.1f  durch Schild %s  Kopf seitlich %.2f m  Klinge sichtbar %s%s' % (
            nm, kn_, luft, wo, spr, boden, spitze_z, gesicht or '-', umh or '-',
            waag or '-', seit or '-', senk or '-', ell, schild_z, schild_oben, netz_z, hand_z, start, durch or '-', kopf_s,
            out[nm]['klinge_sichtbar'],
            '  Rumpf im Liegen bis %+.3f' % rumpf_hoch if nm == 'Tod' else ''))
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
    tn_ = os.path.join(os.environ.get('OUT', os.path.dirname(bpy.data.filepath)), 'teile.json')
    NZ = Netz(NETZ, json.load(open(tn_)), AUS) if NETZ and os.path.exists(tn_) else None
    # Runde 3 (Fremdpruefung 2b: im Tod steht die Scheide wie ein Stuhlbein): Scheide an eigenem Knochen (geruest.py), Ecken in Ruhe
    SCH = None
    if NETZ and 'scheide' in sk.data.bones and 'scheide' in NETZ.vertex_groups:
        gs = NETZ.vertex_groups['scheide'].index
        sv = [NETZ.matrix_world @ v.co for v in NETZ.data.vertices if any(e.group == gs and e.weight > 0.5 for e in v.groups)]
        if sv:
            oben_ = max(sv, key=lambda q: q.z); unten_ = min(sv, key=lambda q: q.z)
            SCH = (sv, oben_, (unten_ - oben_).normalized())

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
        # Runde 4 (Pruefer 3: Tod beginnt nicht wie Kampfstehen): NLA bleibt bis zum Ende stumm, sonst ueberschrieb jedes _upd() die
        # gestellten Knochen im Tod (Unterarm 72 Grad) mit den Spuren
        tr.mute = True; ad.action = None; ad.use_nla = False
        return act

    for pb in pu.PB: pb.rotation_mode = 'QUATERNION'
    for t in ad.nla_tracks: t.mute = True
    st_act = bpy.data.actions[stehen]
    n_st = int(round(st_act.frame_range[1] - st_act.frame_range[0]))
    S0 = lies(st_act, 0)
    pu.stelle(S0)
    KOPF0 = {b: pu.W(b).to_3x3() for b in ('neck_01', 'Head')}
    # Runde 3 (Fremdpruefung 2b: Kampfstehen mit gekreuzten Fuessen auf den Zehen; Stehen hebt die Fersen 3 cm): eigener Stand, Fuesse
    # flach wie in der Ruhelage, linker Fuss vor, schulterbreit (von vorn links lagen sie sonst im Bild uebereinander), rechte Spitze
    # nach aussen
    def fussmatrix(s, d, gier, kipp=0.0):   # gier: + Spitze nach links; kipp: + Spitze nach unten
        R = Matrix.Rotation(math.radians(gier), 3, 'Z') @ Matrix.Rotation(math.radians(kipp), 3, 'X') @ RL('foot_' + s)
        M = R.to_4x4(); M.translation = Vector(d); return M
    zk = sk.data.bones['foot_l'].head_local.z       # Knoechel ueber dem Boden in der Ruhelage
    FUSS0 = {'l': fussmatrix('l', (0.15, -0.09, zk), 10), 'r': fussmatrix('r', (-0.16, 0.15, zk), -28)}

    def blick(stark=1.0):     # Hals und Kopf halten den Blick wie in Stehen (der Rumpf dreht darunter)
        for b, k in (('neck_01', 0.5), ('Head', 1.0)):
            R = pu.W(b).to_3x3(); q = R.to_quaternion().slerp(KOPF0[b].to_quaternion(), k * stark)
            pu.setze(b, q.to_matrix())

    def fuesse(ziel=None, pol=None, rot=None):    # Fuesse an ihren Ort (Welt) und flach wie im Kampfstand; Knie nach vorn (pol)
        for s in 'lr':
            T = (ziel or {}).get(s, FUSS0[s].translation)
            pu.zwei('thigh_' + s, 'calf_' + s, T, Vector(pol or (0.15 if s == 'l' else -0.15, -1.0, 0.0)))
            pu.setze('foot_' + s, (rot or {}).get(s, FUSS0[s].to_3x3()))

    def rumpf(dreh=0.0, vor=0.0, seit=0.0):    # + dreh: rechte Schulter vor; + vor: nach vorn; + seit: nach links
        for b in ('spine_01', 'spine_02', 'spine_03'):
            pu.drehe(b, 'Z', dreh / 3); pu.drehe(b, 'X', vor / 3); pu.drehe(b, 'Y', -seit / 3)

    def becken(d=(0, 0, 0), dreh=0.0, vor=0.0, seit=0.0):
        pu.schiebe('pelvis', d)
        if dreh: pu.drehe('pelvis', 'Z', dreh)
        if vor: pu.drehe('pelvis', 'X', vor)
        if seit: pu.drehe('pelvis', 'Y', -seit)

    KN = {}
    OBEN_L = (pu.O, Vector((0, 0, 1)))    # Schild aufrecht (Runde 3)
    def arm(sd, achse, hand, pol, ziel, name, kegel=24, spiel=90, leise=False, oben=None):
        """Arm sd: Hand an hand, Achse nach ziel; das Gelenk (Ellbogen) um die Linie Schulter-Hand bis 90 Grad von pol weg, wo Knick
        und Verdrehung im Handgelenk am kleinsten sind (jedes Grad Abweichung zaehlt POL_KOSTEN), nie in den Rumpf"""
        P0 = pu.merke(); S_ = pu.W('upperarm_' + sd).translation.copy(); u = (Vector(hand) - S_).normalized()
        best = None
        for dl in range(-spiel, spiel + 1, 10):
            pu.stelle(P0)
            pol_ = Matrix.Rotation(math.radians(dl), 3, u) @ Vector(pol)
            rest = pu.zwei('upperarm_' + sd, 'lowerarm_' + sd, hand, pol_)
            E = pu.W('lowerarm_' + sd).translation
            c, kn, tw = pu.faust(sd, achse, ziel, nur_kosten=True, kegel=kegel, oben=oben)
            # Ellbogen nicht im Rumpf: Abstand zur Achse Becken-Brust unter 16 cm kostet
            B, C = pu.W('spine_01').translation, pu.W('neck_01').translation; ax = (C - B).normalized()
            q = E - B; dr = (q - ax * q.dot(ax)).length
            c += POL_KOSTEN * abs(dl) + max(0.0, 0.16 - dr) * 1000
            if best is None or c < best[0]: best = (c, dl, pol_)
        pu.stelle(P0)
        rest = pu.zwei('upperarm_' + sd, 'lowerarm_' + sd, hand, best[2])
        kn, tw = pu.faust(sd, achse, ziel, kegel=kegel, oben=oben)
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

    def schildarm(hand, pol, vorn, name='', oben=True):
        arm('l', N, hand, pol, vorn, name + ' Schild', oben=OBEN_L if oben else None)

    # ------------------------------------------------------------ Kampfstehen: Kampfstand, Schwertarm in Bereitschaft, Schild vor dem Bauch
    # Runde 3 (Fremdpruefung 2b: von hinten lag der Schild wie auf dem Ruecken): Schildarm vor, Schild nach vorn und aufrecht
    # Runde 3: Klinge weiter nach rechts aussen (von vorn rechts stand sie vor dem Gesicht, Pruefung mit den Gesichtsecken)
    # Runde 4 (Pruefer 3: Klinge im Stand von vorn rechts unsichtbar, sie zeigte fast zur Kamera): steiler, weniger nach vorn
    BEREIT = dict(hand=(-0.25, -0.20, 1.04), pol=(-0.5, 0.6, -0.3), klinge=(-0.55, -0.15, 0.82))
    WACHE = dict(hand=(0.22, -0.26, 1.02), pol=(1.0, 0.3, -0.5), vorn=(0.30, -0.95, 0.05))
    ARM_R = ('clavicle_r', 'upperarm_r', 'lowerarm_r', 'hand_r')
    ARM_L = ('clavicle_l', 'upperarm_l', 'lowerarm_l', 'hand_l')

    def stand():     # Knie gebeugt, linke Seite vor, Fuesse im Kampfstand (Runde 4, Pruefer 3: kaum gebeugt; 4,5 -> 7 cm tiefer)
        becken((0, 0.02, -0.10), dreh=-10); rumpf(dreh=-6, vor=4); fuesse()

    pu.stelle(S0); stand(); blick()
    schwertarm(name='Bereit', **BEREIT); schildarm(name='Wache', **WACHE)
    B0 = pu.merke(); ARM = {b: B0[b] for b in ARM_R + ARM_L}
    kampfstehen = []
    for f in range(n_st + 1):
        pu.stelle(lies(st_act, f)); stand()
        for b in ('neck_01', 'Head'): pu.drehe(b, 'Z', 8)    # Blick nach vorn wie in Stehen
        P_ = pu.merke(); P_.update(ARM); kampfstehen.append(P_)
    schreibe('Kampfstehen', kampfstehen, True)
    K0 = kampfstehen[0]

    # ------------------------------------------------------------ Schluesselbilder
    def pose(fn):
        pu.stelle(K0); fn(); return pu.merke()

    def ausgeholt(stark=1.0):     # Schwert ueber der rechten Schulter, Klinge nach hinten oben, Rumpf rechts zurueck
        # Runde 2 (Pruefer: Klinge durch den Kopf statt ueber die rechte Schulter; dann Faust auf Kopfhoehe, Arm senkrecht, Klinge
        # waagerecht am Helm): Faust vor der rechten Schulter, Ellbogen unten, Klinge ueber die Schulter nach hinten oben
        # Runde 3 (Pruefer: wie Hochrecken): Faust auf Schulterhoehe weiter rechts, Klinge flacher nach hinten, Knie tiefer
        # Runde 4 (Pruefer 3: Ausholen und Hieb 0,20-0,27 wie Hochrecken): Faust tiefer neben dem Ohr, Rumpf staerker eingedreht und
        # vorgebeugt, Knie tiefer; die Klinge liegt schraeg ueber der Schulter
        becken((0, 0.05 * stark, -0.06 * stark), dreh=-8 * stark)
        rumpf(dreh=-24 * stark, vor=6 * stark)
        fuesse()
        schwertarm((-0.32, 0.06, 1.30), (-0.6, 0.4, -0.7), (-0.25, 0.86, 0.45), schulter=2 * stark, name='Ausgeholt', kegel=8)
        blick()

    def ausholen_weg():    # Runde 3 (Pruefer: Klinge vor dem Gesicht von vorn rechts bei 0,13 s): auf dem Weg nach hinten geht die
        # Klinge rechts aussen am Kopf vorbei
        becken((0, 0.02, -0.03), dreh=-3); rumpf(dreh=-8)
        fuesse()
        schwertarm((-0.42, -0.10, 1.22), (-0.6, 0.3, -0.7), (-0.80, -0.05, 0.60), name='Ausholen Weg', kegel=8)
        blick()

    def ausfall(vor_cm=22, tief=0.07):   # linker Fuss vor, Becken vor und tief
        becken((0, -0.10 * vor_cm / 22, -tief), dreh=6)
        fl = FUSS0['l'].translation + Vector((0.0, -vor_cm / 100.0, 0.0))
        fuesse({'l': fl})

    # Runde 3 (Pruefer 2b: Klinge bei 0,27-0,30 vor dem Gesicht von vorn rechts, bei 0,33 waagerecht zur Seite, Ende senkrecht vor den
    # Beinen): oben bleibt die Faust rechts neben dem Kopf, in der Mitte zeigt die Klinge nach vorn, am Ende links aussen am Bein vorbei
    # Runde 4 (Pruefer 3: Klinge 0,33-0,57 durch den Schild): der Schildarm geht im Hieb nach links aussen zurueck
    SEITAB = dict(hand=(0.38, 0.10, 1.00), pol=(1.0, 0.4, -0.4), vorn=(0.85, -0.50, 0.10))
    def hieb_oben():    # Runde 4: Faust nicht ueber Kopfhoehe (sonst Hochrecken), weiter vorn
        ausfall(8, 0.04); rumpf(dreh=-8, vor=6)
        # Pruefer 4: bei 0,27 Arm noch gestreckt, Klinge senkrecht: Faust tiefer und weiter vorn, Klinge nach vorn oben gekippt
        schwertarm((-0.36, -0.30, 1.38), (-0.7, 0.2, -0.6), (-0.25, -0.45, 0.86), schulter=2, name='Hieb oben', kegel=8,
                   wahl=[(x_, y_, 0.86) for x_ in (-0.35, -0.2) for y_ in (-0.55, -0.4)])
        schildarm(name='Hieb oben', **SEITAB)
        blick()

    def hieb_mitte():
        ausfall(16, 0.06); rumpf(dreh=12, vor=8)
        schwertarm((-0.10, -0.48, 1.28), (-0.7, 0.0, -0.7), (0.35, -0.85, -0.10), name='Hieb Mitte', kegel=8,
                   wahl=[(x_, -0.85, z_) for x_ in (0.2, 0.35, 0.5) for z_ in (-0.25, -0.1, 0.05, 0.2, 0.35)])
        schildarm(name='Hieb Mitte', **SEITAB)
        blick()

    def aufschlag():    # schraeg von rechts oben nach links unten, Faust vor der linken Huefte, Klinge links aussen am Bein vorbei
        # Runde 2 (Pruefer: Faust im Schritt, Klinge waagerecht vor der Huefte): Faust 13 cm weiter links, Klinge steil nach unten
        ausfall(); rumpf(dreh=24, vor=10)
        # Pruefer 4: Klinge stand senkrecht vor der Koerpermitte: Faust weiter links, Klinge mehr zur Seite als nach vorn
        schwertarm((0.20, -0.34, 1.04), (-0.6, 0.0, -0.8), (0.85, -0.10, -0.52), name='Aufschlag', kegel=8,
                   wahl=[(x_, y_, z_) for x_ in (0.8, 0.9) for y_ in (-0.2, -0.05) for z_ in (-0.45, -0.6)])   # 30-45 Grad unter waagerecht
        schildarm(name='Aufschlag', **SEITAB)
        blick()

    # Runde 2 (Pruefer: Stich mit dem Ellbogen hoch): Ellbogen nach unten aussen, hoechstens 30 Grad davon weg (sonst waehlte der Bau
    # 60 und 90 Grad, weil die Faust so weniger knickt); Stoss: Faust auf Brusthoehe, Klinge aus der wahl (tiefer stand sie waagerecht
    # vor dem Bauch, hoeher verdrehte der Unterarm ueber 120 Grad)
    # Runde 3 (Pruefer 2b: von vorn rechts unlesbar): weiter zurueck und tiefer, weiter vor, Arm gestreckt, Klinge gerade nach vorn
    # Runde 4 (Pruefer 3: Stich 0,17-0,27 Klinge flach vor der Huefte von vorn rechts): die Faust geht hoch neben die rechte Schulter
    # zurueck, die Spitze zielt leicht abwaerts nach vorn (wie Ochs); der Stoss geht von dort auf Brusthoehe
    def stich_zurueck():
        becken((0, 0.06, -0.06), dreh=-10); rumpf(dreh=-20, vor=4)
        fuesse()
        schwertarm((-0.38, 0.10, 1.30), (-0.4, 0.5, -0.9), (-0.05, -0.97, -0.20), name='Stich zurueck', spiel=40, kegel=8,
                   wahl=[(x_, -0.97, z_) for x_ in (-0.1, 0.0) for z_ in (-0.3, -0.2, -0.1)])   # nicht nach links (Weg vor dem Gesicht)
        blick()

    def stich_weg():       # auf dem Weg zurueck dreht die Spitze rechts aussen nach vorn (sonst links vor dem Gesicht vorbei)
        becken((0, 0.03, -0.03), dreh=-5); rumpf(dreh=-10, vor=2)
        fuesse()
        schwertarm((-0.40, -0.06, 1.18), (-0.5, 0.5, -0.8), (-0.45, -0.75, 0.48), name='Stich Weg', spiel=40, kegel=8)
        blick()

    def stoss():           # Faust vor, Klinge auf Brusthoehe nach vorn
        ausfall(34, 0.11); rumpf(dreh=28, vor=10)
        schwertarm((-0.14, -0.56, 1.28), (-0.5, 0.2, -1.0), (0.10, -0.99, 0.0), name='Stoss', spiel=30, kegel=8,
                   wahl=[(x_, -1.0, z_) for x_ in (0.0, 0.12, 0.25) for z_ in (-0.1, 0.0, 0.1)])
        blick()

    # Runde 2 (Pruefer: Treffer und Ausweichen zu schwach): etwa doppelt so weit
    def getroffen():       # Ruck nach hinten: Becken und Brust zurueck, Kopf mit, Schwertarm faellt ab
        # Runde 2b (Pruefer: nur Oberkoerper und Kopf, von vorn links schwach): rechter Fuss einen halben Schritt zurueck, Rumpf
        # zur Seite gedreht
        becken((-0.03, 0.16, -0.05), vor=-6, dreh=-10); rumpf(dreh=-16, vor=-24, seit=8)
        fuesse({'r': FUSS0['r'].translation + Vector((-0.02, 0.18, 0.0)), 'l': FUSS0['l'].translation + Vector((0.0, 0.06, 0.0))})
        schwertarm((-0.39, 0.16, 0.93), (-0.6, 0.6, -0.3), (-0.45, -0.45, 0.77), name='Treffer')   # wie vorher, mit dem Becken verschoben
        # Runde 4 (Pruefer 3: Kopf in den Nacken, Schildkante am Helm): Kopf 8 statt 18 Grad zurueck, Schild tiefer vor den Bauch
        schildarm((0.26, -0.10, 0.92), (1.0, 0.3, -0.5), (0.35, -0.93, 0.0), name='Treffer')
        blick(0.4); pu.drehe('Head', 'X', -8)

    def ausweichen():      # Schritt nach links weg, Knie gebeugt, Oberkoerper seitlich; Schwert aussen rechts, nicht vor dem Gesicht
        # Runde 2b (Pruefer: kaum seitlich, wirkt wie Ducken; Schwertarm steif seitlich wie ein Wegweiser): ganzer Schritt 40 cm zur
        # Seite, weniger tief; Schwert wie in der Bereitschaft vorn
        # Runde 3 (Pruefer: 40 cm kaum sichtbar): schraeg nach links hinten, tiefer, Oberkoerper staerker zur Seite
        # Runde 4 (Pruefer 3: wie Ducken, Kopf nur 21 cm zur Seite): seit kippte nach rechts (Drehung um +Y, Zeichen falsch), der Kopf
        # blieb hinter dem Becken; jetzt kippt der Oberkoerper nach links mit, Schritt 50 cm, weniger tief
        becken((0.50, 0.14, -0.08), dreh=-12, seit=-6); rumpf(dreh=-8, vor=-4, seit=-16)
        fuesse({'l': FUSS0['l'].translation + Vector((0.58, 0.10, 0.0)), 'r': FUSS0['r'].translation + Vector((0.36, 0.14, 0.0))})
        schwertarm((0.26, -0.08, 1.04), (-0.5, 0.6, -0.4), (-0.55, -0.15, 0.82), name='Ausweichen')   # rechts vor dem verschobenen Becken
        blick(0.7)

    def abwehr():          # Schild vor die Brust, Vorderseite nach vorn; Schwert rechts hochgenommen, Knie etwas gebeugt
        # Runde 2 (Pruefer: Klinge vor dem Gesicht): Klinge nach rechts hinten oben statt senkrecht vor der Schulter
        # Runde 3 (Pruefer: roter Streifen durch den Umhang): Klinge nach rechts aussen oben statt nach hinten
        becken((0, 0.03, -0.05), dreh=8); rumpf(dreh=6, vor=4)
        fuesse()
        schildarm((0.06, -0.30, 1.14), (1.0, -0.2, -0.4), (-0.15, -0.95, 0.25), name='Abwehr')
        schwertarm((-0.36, -0.02, 1.14), (-0.6, 0.5, -0.4), (-0.55, 0.10, 0.83), name='Abwehr')
        blick()

    def hoch():            # Rueckweg vom Aufschlag: Faust vor den Bauch, Spitze nach vorn oben zum Gegner (Runde 4, Pruefer 3: bei 0,57
        # waagerecht vor der Huefte, bei 0,67 vor dem Gesicht von vorn links; die Spitze bleibt unter dem Gesicht)
        ausfall(7, 0.04); rumpf(dreh=8, vor=5)
        schwertarm((-0.04, -0.40, 1.16), (-0.6, 0.0, -0.8), (0.0, -0.85, 0.45), name='Hieb hoch', kegel=8,   # Pruefer 4: sonst steil vor dem Gesicht
                   wahl=[(x_, -0.85, z_) for x_ in (-0.15, 0.0, 0.15) for z_ in (0.35, 0.45)])
        schildarm(name='Hieb hoch', **SEITAB)    # Pruefer 4: Klinge bei 0,53-0,57 im Schild; er kommt erst danach vor
        blick()

    # ------------------------------------------------------------ Tod (Runde 3, Pruefer 2b: bei 0,80 s Sitz auf einem unsichtbaren Stuhl,
    # bei 1,00 Liegestuhl in der Luft, Scheide wie ein Stuhlbein): eigener Fall nach hinten aus Schluesselbildern statt Death01; die Knie
    # geben nach, er faellt aufs Gesaess, dann auf den Ruecken, die Beine gleiten vor; ab dem Sitzen liegt der Rumpf (Becken bis Kopf,
    # Oberschenkel, ohne Arme, Umhang, Scheide) auf dem Boden; die Haende stuetzen nie; die Scheide legt sich flach
    def erde(nach=None, n=3):    # Becken heben oder senken, bis der Rumpf auf dem Boden liegt; danach nach() (Fuesse, Arme neu)
        for _ in range(n):
            if NZ: z = NZ.tief(NZ.rumpf)
            else: z = min(pu.W(b).translation.z for b in ('pelvis', 'spine_03', 'Head')) - 0.10
            if abs(z) < 0.003: break
            pu.schiebe('pelvis', (0, 0, -z))
            if nach: nach()

    def achsen():     # zum Kopf und nach rechts, waagerecht
        W = lambda b: pu.W(b).translation
        lang = W('Head') - W('pelvis'); lang.z = 0; lang.normalize()
        rechts = (pu.W('pelvis').to_3x3() @ sk.data.bones['pelvis'].matrix_local.to_3x3().inverted()) @ Vector((-1, 0, 0))
        rechts.z = 0; rechts.normalize()
        return lang, rechts

    def scheide_flach(k=1.0, senken=True):    # Scheide um ihr oberes Ende waagerecht, tiefster Punkt 1,5 cm ueber dem Boden
        # (senken=False, Runde 4: nur heben, falls sie im Boden steckt; sie bleibt am Guertel)
        if not SCH or k <= 0: return
        sv, o_, a_ = SCH; Rb = sk.data.bones['scheide'].matrix_local; pb = pu.PB['scheide']
        Md = pu.W('scheide') @ Rb.inverted(); o = Md @ o_; a = (Md.to_3x3() @ a_).normalized()
        f = Vector((a.x, a.y, 0.0))
        f = f.normalized() if f.length > 0.2 else -achsen()[0]
        q = Quaternion().slerp(a.rotation_difference(f), k)
        pb.matrix = Matrix.Translation(o) @ q.to_matrix().to_4x4() @ Matrix.Translation(-o) @ pu.W('scheide'); pb.scale = (1, 1, 1); _upd()
        Md = pu.W('scheide') @ Rb.inverted(); z = min((Md @ v).z for v in sv)
        pu.schiebe('scheide', (0, 0, (0.015 - z) * k if senken else max(0.0, 0.015 - z)))

    def umhang_klappen(spiel=None):    # Runde 4 (Pruefer 3: Liegestuhl auf starrem Umhang, 20 cm im Boden): der untere Umhang klappt um
        # die Huefte nach vorn unter Gesaess und Oberschenkel (er sitzt und liegt auf ihm), kleinster Winkel, der ihn aus dem Boden holt;
        # nach hinten haette er im Fallen von 115 Grad (Sitz) auf 180 (Liegen) schwingen muessen. Danach liegt der Rumpf auf dem Umhang
        # (hoechstens 5 cm hoeher).
        # spiel: nur nachbessern (je Bild), hoechstens so weit vom gemischten Winkel, und nur, wenn er mehr als 1,5 cm im Boden steckt
        if not NZ or 'umhang' not in pu.PB or not NZ.umhang_u.any(): return 0
        pb = pu.PB['umhang']; M0 = pu.W('umhang'); h = M0.translation.copy()
        Rp = pu.W('pelvis').to_3x3() @ RL('pelvis').inverted()
        ax = Rp @ Vector((1, 0, 0))
        def stell(w):
            pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(w), 4, ax) @ Matrix.Translation(-h) @ M0; pb.scale = (1, 1, 1); _upd()
            return NZ.tief(NZ.umhang_u)
        if spiel and stell(0) >= -0.015: return 0
        if os.environ.get('UMHANG_DBG'): log('UMHANG DBG', [(w, round(stell(w), 3)) for w in range(-90, 151, 15)])
        best = None
        for w_ in sorted(range(-(spiel or 90), (spiel or 15) + 1, 3), key=abs):
            z_ = stell(w_)
            if z_ >= -0.012: best = (w_, z_); break
            if best is None or z_ > best[1] + 0.002: best = (w_, z_)
        w_ = best[0]; stell(w_)
        return w_

    def auf_umhang():    # der Rumpf liegt auf dem Umhang: so weit hoeher, wie dieser im Boden steckt (bis 1 cm Spiel, hoechstens 5 cm)
        if NZ:
            z = NZ.tief(NZ.umhang)
            if z < -0.01: pu.schiebe('pelvis', (0, 0, min(0.05, -z - 0.008)))

    def tod_zuck():      # Ruck nach hinten, Kopf zurueck, die Arme sinken
        becken((0, 0.07, -0.02), vor=-5); rumpf(vor=-14, dreh=-6)
        fuesse()
        # Runde 4 (Pruefer 3: Klinge 0,17-0,60 flach vor der Huefte): die Klinge haengt steil nach unten aussen
        schwertarm((-0.38, 0.06, 0.98), (-0.6, 0.6, -0.3), (-0.45, 0.10, -0.89), name='Tod zuck',
                   wahl=[(x_, y_, -0.89) for x_ in (-0.3, -0.45, -0.6) for y_ in (-0.1, 0.1, 0.3)])
        schildarm((0.30, -0.06, 0.98), (1.0, 0.2, -0.6), (0.4, -0.9, 0.0), name='Tod zuck')
        blick(0.3); pu.drehe('Head', 'X', -14)

    def tod_knick():     # die Knie geben nach, das Becken sinkt 26 cm ueber den Fuessen, der Oberkoerper sackt vor, die Arme haengen
        # Runde 4 (Pruefer 3: 0,40-0,60 Sitz auf einem unsichtbaren Stuhl, Becken 0,5 m hoch hinter den Fersen): Becken bleibt ueber
        # den Fuessen, danach faellt er schneller nach hinten; die Scheide kippt schon hier nach hinten (stand senkrecht wie ein Stuhlbein)
        becken((0, 0.05, -0.26), vor=14); rumpf(vor=10)
        fuesse()
        schwertarm((-0.36, 0.14, 0.66), (-0.6, 0.6, -0.2), (-0.70, 0.35, -0.62), name='Tod knick',
                   wahl=[(x_, y_, -0.62) for x_ in (-0.55, -0.7) for y_ in (0.2, 0.35, 0.5)])
        schildarm((0.32, 0.08, 0.66), (1.0, 0.3, -0.3), (0.7, -0.6, 0.0), name='Tod knick', oben=False)
        blick(0.2); pu.drehe('Head', 'X', 14)
        scheide_flach(0.5, senken=False)

    KL_TOD = []    # Runde 4 (Pruefer 4: Schwert springt zwischen 0,60 und 0,70 hoch in die Luft): Klinge nahe der vorigen Richtung
    def tod_arme(hoehe, k_aus):    # Arme seitlich zum Boden (hoehe: Hand ueber dem Boden), k_aus: wie weit nach aussen
        lang, rechts = achsen(); W = lambda b: pu.W(b).translation
        Sr, Sl = W('upperarm_r').copy(), W('upperarm_l').copy()
        hr = Sr + rechts * 0.40 * k_aus - lang * 0.15; hr.z = hoehe
        # Klinge flach am Boden: die Richtung (um die Hochachse), in der das Handgelenk am wenigsten knickt und verdreht
        P0 = pu.merke(); best = None
        for w_ in range(-80, 81, 20):    # nur nach aussen: nach innen stach die Klinge im Fallen durch den Rumpf
            kl_ = (Matrix.Rotation(math.radians(w_), 3, 'Z') @ rechts); kl_.z = 0.0; kl_.normalize()
            pu.stelle(P0); arm('r', A, hr, rechts + Vector((0, 0, 0.2)), kl_, 'Tod', kegel=0, leise=True)   # Ellbogen nie unter den Boden
            kn_, tw_ = KN['Tod'][:2]; sp_ = pu.W('hand_r').translation + pu.klinge() * KLINGE_M
            c = kn_ + VERDREH * abs(tw_) + 500 * max(0.0, 0.25 - _strecke(pu.W('spine_03').translation, hr, sp_))
            if KL_TOD: c += 0.3 * math.degrees(kl_.angle(KL_TOD[-1]))
            if best is None or c < best[0]: best = (c, w_, pu.merke())
        pu.stelle(best[2]); KL_TOD.append(pu.klinge())
        hl = Sl - rechts * 0.36 * k_aus - lang * 0.10; hl.z = hoehe
        arm('l', N, hl, -rechts + Vector((0, 0, 0.2)), Vector((0, 0, 1)), 'Tod Schild', kegel=0)   # flach (mit Spielraum lag er schief im Boden)
        return best[1]

    def tod_arme_boden(hoehe, k_aus):   # wie tod_arme, die Haende so hoch, dass kein Arm im Boden liegt
        P0 = pu.merke(); w_ = tod_arme(hoehe, k_aus)
        if NZ:
            for _ in range(2):
                z = NZ.tief(NZ.unterarme)
                if z > -0.005: break
                hoehe -= z; pu.stelle(P0); w_ = tod_arme(hoehe, k_aus)
        return w_

    def tod_sitz():      # Runde 4 (Pruefer 4: bei 0,50 noch Stuhl, 0,60-0,70 Liegestuhl): er plumpst gerade nach unten aufs Gesaess hinter
        # den Fersen, der Oberkoerper noch fast aufrecht (leicht zurueck), Knie hoch; Schwert und Schild schon am Boden (vorher hielt er
        # das Schwert waagerecht in die Luft); danach kippt er schnell auf den Ruecken
        becken((0, 0.20, -0.62), dreh=6, vor=-12); rumpf(vor=-6, dreh=4)
        beine = lambda: fuesse({s: FUSS0[s].translation + Vector((0, -0.10, 0)) for s in 'lr'})
        beine(); erde(beine)
        tod_arme_boden(0.10, 0.7)
        pu.drehe('Head', 'X', 8)
        scheide_flach(1.0); umhang_klappen()

    def tod_ruecken():   # auf dem Ruecken, die Knie noch hoch, die Arme fast am Boden
        becken((0, 0.34, -0.66), dreh=8, vor=-82); rumpf(vor=-4, dreh=4)
        beine = lambda: fuesse({s: FUSS0[s].translation + Vector((0, -0.14, 0)) for s in 'lr'}, pol=(0, -0.4, 1.0))
        beine(); erde(beine)
        tod_arme_boden(0.12, 0.8)
        pu.drehe('Head', 'X', -6)
        scheide_flach(1.0); umhang_klappen()

    LIEG = {}
    def tod_liegen():    # liegt: Beine vorgeglitten, Fussspitzen nach oben aussen, Kopf zur Seite, Schwert und Schild flach
        becken((0, 0.34, -0.68), dreh=10, vor=-90); rumpf(vor=0, dreh=4)
        def beine():
            lang, rechts = achsen()
            z_ = {}; r_ = {}
            for s, sg in (('l', 1), ('r', -1)):
                T = pu.W('thigh_' + s).translation - lang * (0.80 if s == 'l' else 0.74) - rechts * sg * 0.07; T.z = 0.075
                z_[s] = T
                r_[s] = Matrix.Rotation(math.radians(35 * sg), 3, lang) @ Matrix.Rotation(math.radians(-75), 3, 'X') @ RL('foot_' + s)
            fuesse(z_, pol=(0, 0, 1.0), rot=r_)
        beine(); erde(beine)
        LIEG['w'] = tod_arme_boden(0.06, 1.0)
        lang, _ = achsen(); pu.drehe('Head', lang, 22)
        scheide_flach(1.0); umhang_klappen()

    P = {n: pose(fn) for n, fn in (('aus', ausgeholt), ('weg', ausholen_weg), ('hoch', hoch), ('oben', hieb_oben), ('mitte', hieb_mitte),
                                    ('auf', aufschlag), ('szur', stich_zurueck), ('sweg', stich_weg), ('stoss', stoss), ('treffer', getroffen),
                                    ('ausw', ausweichen), ('abwehr', abwehr),
                                    ('t_zuck', tod_zuck), ('t_knick', tod_knick), ('t_sitz', tod_sitz), ('t_ruecken', tod_ruecken),
                                    ('t_liegen', tod_liegen))}
    P['k0'] = K0
    log('KAMPF Tod Klinge %s Grad von rechts' % LIEG.get('w'))

    def folge(name, keys, schleife=False, nach=None):
        """keys: (Zeit s, Pose, Verlauf bis zum naechsten); nach(t): je Bild nach dem Mischen (Tod: auf den Boden)"""
        n = int(round(keys[-1][0] * FPS)); out = []
        for i in range(n + 1):
            t = i / FPS
            j = max(j for j in range(len(keys) - 1) if keys[j][0] <= t + 1e-9) if t < keys[-1][0] else len(keys) - 2
            (t0, p0, v0), (t1, p1, _) = keys[j], keys[j + 1]
            s = ease(min(1.0, (t - t0) / (t1 - t0)), v0)
            Pm = mische(P[p0], P[p1], s)
            if nach: pu.stelle(Pm); nach(t); Pm = pu.merke()
            out.append(Pm)
        schreibe(name, out, schleife)
        INFO.setdefault('bewegungen', {})[name] = {'quelle': 'eigen (kampf.py)', 'bilder': n}
        return out

    # Ausholen 0,4 s, dann gehalten (figur.gd: Zauber und Fernkampf, 0,6 s, dann Ruhe); ueber rechts aussen (Runde 3)
    folge('Ausholen', [(0.0, 'k0', 'weich'), (0.16, 'weg', 'linear'), (0.40, 'aus', 'weich')])
    # Hieb 0,8 s: ausholen bis 0,18 (rechts aussen), Halt bis 0,22, Schlag 0,15 s bis 0,37 (oben rechts neben dem Kopf, Mitte nach vorn,
    # Aufschlag links unten), Halt am Aufschlag bis 0,46, zurueck bis 0,80
    folge('Hieb', [(0.0, 'k0', 'weich'), (0.09, 'weg', 'linear'), (0.18, 'aus', 'linear'), (0.22, 'aus', 'an'), (0.27, 'oben', 'linear'),
                   (0.32, 'mitte', 'linear'), (0.37, 'auf', 'aus'), (0.46, 'auf', 'weich'), (0.58, 'hoch', 'weich'), (0.80, 'k0', 'weich')])
    # Stich 0,6 s: zurueck bis 0,18, Stoss bis 0,28, Halt bis 0,36, zurueck bis 0,60
    folge('Stich', [(0.0, 'k0', 'weich'), (0.09, 'sweg', 'linear'), (0.18, 'szur', 'an'), (0.28, 'stoss', 'linear'), (0.36, 'stoss', 'weich'),
                    (0.60, 'k0', 'weich')])
    # Treffer 0,45 s (figur.gd ruht nach 0,45 s): Ruck 0,08 s, zurueck
    folge('Treffer', [(0.0, 'k0', 'aus'), (0.08, 'treffer', 'linear'), (0.14, 'treffer', 'weich'), (0.45, 'k0', 'weich')])
    # Ausweichen 0,45 s: weg 0,12 s, Halt bis 0,24, zurueck
    folge('Ausweichen', [(0.0, 'k0', 'aus'), (0.12, 'ausw', 'linear'), (0.24, 'ausw', 'weich'), (0.45, 'k0', 'weich')])
    # Abwehr 0,25 s hinein, dann gehalten
    folge('Abwehr', [(0.0, 'k0', 'aus'), (0.25, 'abwehr', 'weich')])

    # Tod 2,4 s (wie Death01): Ruck bis 0,15, Knie geben nach bis 0,38, Fall aufs Gesaess bis 0,58, auf den Ruecken bis 0,76, Beine
    # gleiten vor bis 1,10, liegt
    T_SITZ, UMW = 0.50, []
    def am_boden(t):
        if t < 0.36: return
        if NZ: z = NZ.tief(NZ.rumpf)
        else: return
        if t >= T_SITZ or z < 0: pu.schiebe('pelvis', (0, 0, -z))     # ab dem Sitzen aufliegend, vorher nur nicht hinein
        UMW.append(umhang_klappen(spiel=20))
        if t >= T_SITZ: auf_umhang()
        if SCH and NZ.tief(NZ.scheide) < 0.0:    # die Scheide legt sich, sobald sie den Boden beruehrt
            P_ = pu.merke()
            for k in (0.3, 0.6, 1.0):
                pu.stelle(P_); scheide_flach(k)
                if NZ.tief(NZ.scheide) >= 0.0: break
        for s in 'lr':    # kein Fuss im Boden: Knoechel so weit hoeher, Fuss gedreht wie gemischt
            zb = NZ.tief(NZ.beine & NZ.seite[s])
            if zb < -0.005:
                R = pu.W('foot_' + s).to_3x3(); T = pu.W('foot_' + s).translation + Vector((0, 0, -zb))
                kn = pu.W('calf_' + s).translation; hf = pu.W('thigh_' + s).translation
                pu.zwei('thigh_' + s, 'calf_' + s, T, kn - (hf + T) / 2); pu.setze('foot_' + s, R)
    for t in [t for t in ad.nla_tracks if t.name == tod]: ad.nla_tracks.remove(t)
    if tod in bpy.data.actions: bpy.data.actions.remove(bpy.data.actions[tod])
    # Runde 4 (Pruefer 3, 4): Knick bis 0,36, plumpst aufs Gesaess (0,50), kippt beschleunigt auf den Ruecken (0,70)
    folge(tod, [(0.0, 'k0', 'aus'), (0.15, 't_zuck', 'weich'), (0.36, 't_knick', 'an'), (T_SITZ, 't_sitz', 'linear'), (0.54, 't_sitz', 'an'),
                (0.70, 't_ruecken', 'weich'), (1.05, 't_liegen', 'linear'), (2.40, 't_liegen', 'linear')], nach=am_boden)
    log('KAMPF Tod Umhang geklappt (Grad je Bild ab dem Knick)', UMW)
    INFO['kampf_knick'] = KN
    INFO['kampf_pruefung'] = pruefen(pu, lies, ['Kampfstehen', 'Ausholen', 'Hieb', 'Stich', 'Treffer', 'Ausweichen', 'Abwehr', tod], log, NZ)
    pu.stelle({b: (Quaternion(), Vector()) for b in REIHE})
    for t in ad.nla_tracks: t.mute = False
    ad.action = None; ad.use_nla = True
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
