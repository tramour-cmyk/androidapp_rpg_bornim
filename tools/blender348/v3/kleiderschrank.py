# 431 Stufe 1 (Chef 15.11., 12:43 „431g A“; 11:58: „Das kann ja nicht sein, dass wir für jeden Körper alles immer anpassen müssen“):
# Kleiderschrank. Ein Stueck unserer Tracht wird einmal angepasst und von hier auf jeden Volkskoerper aus voelker.py uebertragen
# (kauf_kleid.py mit KOERPER_DATEI, der Koerper bleibt ganz). Erstes Stueck: der Umhang der Wache. Er haengt nicht mehr an Armen und
# Beinen (861: Beule unter dem Schlagarm), sondern an einer eigenen Knochenkette am Ruecken (umhang_<spalte>_<n> unter spine_03), links
# und rechts gespiegelt gewichtet; Godot laesst die Kette federn (umhang.gd, SpringBoneSimulator3D mit Kapseln an Rumpf und Beinen,
# Schild, Rueckenwaffe).
# Aufruf: VOELKER=<ordner mit voelker.json> OUT=<ordner mit tex/, karten.json> ZIEL=<ordner> Q=<cc0> [KAUF=..] [STUECK=umhang]
#         [NUR=mensch_mann,ork_frau] bl/bin/python -I kleiderschrank.py
#   -> <ZIEL>/<stueck>_<volk>_<mann|frau>.glb (Koerper, Stueck, Geruest mit Kette), <ZIEL>/kleiderschrank.json (Messung je Koerper)
# Messung je Koerper (Zeilen SCHRANK): Kette links gegen rechts gespiegelt (cm), Gewichte links gegen rechts (groesster Unterschied),
# Abstand des Stuecks zum Koerper (kleinster, Mittel), Anteil der Ecken an Armen und Beinen (soll 0).
import bpy, bmesh, os, sys, json, subprocess, math
import numpy as np
from mathutils import Vector
from mathutils.kdtree import KDTree
from mathutils.bvhtree import BVHTree

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
VOELKER = os.environ.get('VOELKER', '/tmp/voelker')
OUT = os.environ.get('OUT', '/home/user/rt/out')
ZIEL = os.environ.get('ZIEL', '/tmp/schrank')
STUECK = os.environ.get('STUECK', 'umhang')
NUR = [s for s in os.environ.get('NUR', '').split(',') if s]
os.makedirs(ZIEL, exist_ok=True)

# Stueck -> (Tracht in trachten.json oder „held“, Teile aus teile.json, die mitgehen)
STUECKE = {'umhang': ('held', ['cloak', 'clasp'])}
# Kette: Spalten als Anteil der halben Breite des Umhangs (gespiegelt), Glieder von der Hoehe der Schulterblaetter bis zum Saum
SPALTEN = [('l2', -0.78), ('l1', -0.40), ('m', 0.0), ('r1', 0.40), ('r2', 0.78)]
GLIEDER = int(os.environ.get('GLIEDER', '4'))
OBEN_UNTER = float(os.environ.get('KETTE_OBEN', '0.10'))   # Kettenanfang so weit unter den Schultergelenken (m)
BAND = float(os.environ.get('KETTE_BAND', '0.08'))         # darueber bis so weit unter dem Anfang: Uebergang von den alten Gewichten
GLIED_TIEFE = 0.008                                         # Kette so weit innen unter der Aussenseite des Umhangs (m)


def tracht(figur, sex):
    # wie held_klassen.py held3_tracht: held3.py und rig.py ohne Abbau, Umhang als Gitter
    o = os.path.join(ZIEL, 'roh_%s_%s' % (figur, sex)); os.makedirs(o, exist_ok=True)
    if os.path.exists(os.path.join(o, 'held3-rig.blend')): return o
    if not os.path.exists(os.path.join(o, 'tex')): os.symlink(os.path.join(OUT, 'tex'), os.path.join(o, 'tex'))
    env = dict(os.environ, OUT=o, FIGUR=figur, LEUTE=os.path.join(HIER, 'trachten.json'), SEX=sex, FIGUREN='keine')
    env.setdefault('DREIECKE', '0'); env.setdefault('GITTER', 'cloak,robe,tabard')
    env.setdefault('KARTEN', os.path.join(OUT, 'karten.json'))
    for s in ('held3', 'rig'):
        r = subprocess.run([sys.executable, '-I', os.path.join(HIER, s + '.py')], env=env, capture_output=True, text=True)
        if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('%s.py %s %d' % (s, figur, r.returncode))
    return o


def uebertragen(e, quelle, teile, kennung):
    roh = os.path.join(ZIEL, 'roh'); os.makedirs(roh, exist_ok=True)
    alle = json.load(open(os.path.join(quelle, 'teile.json')))
    ohne = [t for t in alle if t not in teile]
    env = dict(os.environ, OUT=quelle, ZIEL=roh, KENNUNG=kennung, KOERPER_DATEI=os.path.join(VOELKER, e['datei']), KOERPER=e['koerper'],
               KOPF='', HAAR='', BART='', FARBE='keine', STOPPELN='0', HAUT='mittel', FORM='', OHNE_TEIL=','.join(ohne),
               KOERPER_BLEIBT='1', FIGUREN='keine')
    r = subprocess.run([sys.executable, '-I', os.path.join(HIER, 'kauf_kleid.py')], env=env, capture_output=True, text=True)
    print('\n'.join(l for l in r.stdout.splitlines() if l.startswith(('KAUFKLEID OK', 'UMHANG', 'OHNE', 'LAGEN'))))
    if r.returncode: print(r.stdout[-3000:], r.stderr[-3000:]); raise SystemExit('kauf_kleid.py %s %d' % (kennung, r.returncode))
    return os.path.join(roh, kennung + '.blend')


def welt(o):
    co = np.empty(len(o.data.vertices) * 3); o.data.vertices.foreach_get('co', co)
    M = np.array(o.matrix_world)
    return co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]


def dicht(o, namen):
    W = np.zeros((len(o.data.vertices), len(namen))); gi = {g.index: namen.index(g.name) for g in o.vertex_groups if g.name in namen}
    for v in o.data.vertices:
        for g in v.groups:
            j = gi.get(g.group)
            if j is not None: W[v.index, j] += g.weight
    return W


def zelt(x, punkte):
    # lineare Anteile von x zwischen benachbarten Stuetzstellen (aussen ganz an der letzten)
    w = np.zeros(len(punkte))
    if x <= punkte[0]: w[0] = 1.0; return w
    if x >= punkte[-1]: w[-1] = 1.0; return w
    k = int(np.searchsorted(punkte, x)) - 1
    t = (x - punkte[k]) / (punkte[k + 1] - punkte[k]); w[k] = 1 - t; w[k + 1] = t
    return w


def smooth(a):
    return a * a * (3 - 2 * a)


# 431 Tuch (Chef 15.11., 16:57: „ein Stück Stoff … mit einem Saum. Und das hänge ich mir über die Schultern“; Weg von Sokrates 17:29
# gebilligt): der Umhang aus held3.py kam über kauf_kleid.py verzogen auf jeden Körper, die Ränder rissen (Lauf 11). Jetzt wird er je
# Körper neu gelegt, in derselben Gitterordnung (NZ Reihen, NT Spalten, zwei Lagen wie held3.py grid_obj mit SOLIDIFY), damit Farben,
# Bildkoordinaten und Kennung des Kleids bleiben: Kragen über die Schultern (TUCH_KRAGEN m über der Haut), darunter ein Trapez bis zur
# Kniekehle, Saum waagerecht, Ränder in fester Richtung; Halbmesser je Spalte links und rechts gleich (spiegelgleich), nach unten nie
# kleiner (fällt frei). Strahlen nur gegen Rumpf, Kopf, Beine und die Schulterkappe (Arm bis TUCH_ARM_KAPPE vom Schultergelenk); der
# übrige Arm (T-Pose) liegt in Godot vor dem Umhang
NZ, NT = int(os.environ.get("TUCH_NZ", "36")), int(os.environ.get("TUCH_NT", "25"))
KRAGEN = float(os.environ.get('TUCH_KRAGEN', '0.022'))    # Abstand zur Haut am Kragen (m, Sokrates: höchstens 3 cm)
LUFT = float(os.environ.get('TUCH_LUFT', '0.015'))        # darunter (m)
DICKE = 0.006
WINKEL_OBEN = float(os.environ.get('TUCH_OBEN', '112'))   # Grad von hinten: so weit reicht der Kragen über die Schultern nach vorn
WINKEL_UNTEN = float(os.environ.get('TUCH_UNTEN', '78'))  # Ränder unterhalb der Achsel (hinter den Armen)
WEITE = float(os.environ.get('TUCH_WEITE', '1.22'))       # halbe Breite am Saum gegen die an den Schultern (Trapez)
ARM_KAPPE = float(os.environ.get('TUCH_ARM_KAPPE', '0.07'))
OBERARM = float(os.environ.get('TUCH_OBERARM', '0.65'))
TUCH = os.environ.get('TUCH', '1') == '1'
STRAHL = os.environ.get('TUCH_STRAHL', 'voll')
def _ual():
    if os.environ.get('UAL'): return os.environ['UAL']
    import glob
    for w in (os.environ.get('KAUF', ''), os.environ.get('Q', ''), os.path.expanduser('~/cc0')):
        f = sorted(glob.glob(os.path.join(w, '**', 'Unreal-Godot', 'UAL1*.glb'), recursive=True)) if w else []
        if f: return f[0]
    raise SystemExit('TUCH: keine UAL1.glb (UAL=…)')
UAL = _ual() if TUCH else None   # 0: Umhang wie bisher aus kauf_kleid.py


def tuch(arm, kleid, netze, teilnamen, koerper_glb):
    tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
    ui = np.where(tl == teilnamen.index('cloak'))[0]
    # Gelegt wird im Stehen (Idle_Loop, Bild 0, so wie Godot es zeigt: haltung.py), sonst steht der Kragen über der Schulterkappe der
    # T-Pose und im Spiel als Kante über dem gesenkten Arm ab (Bild 17:46). Gebaut in einem Rahmen am Rumpf (x zur Seite l, y nach
    # hinten, z senkrecht; der Umhang fällt im Stehen senkrecht), zurück in die Ruhelage über die Gewichte (starr)
    import haltung
    D = haltung.verformung(koerper_glb, UAL, 'Idle_Loop')
    DM = {n: np.array(M) for n, M in D.items()}
    B0 = {b.name: arm.matrix_world @ b.head_local for b in arm.data.bones}
    Bp = {n: (DM[n] @ np.append(np.array(v), 1.0))[:3] if n in DM else np.array(v) for n, v in B0.items()}
    ez = np.array([0.0, 0.0, 1.0])
    ex = Bp['upperarm_l'] - Bp['upperarm_r']; ex[2] = 0; ex /= np.linalg.norm(ex)
    ey = np.cross(ez, ex)
    hinten = DM['spine_03'][:3, :3] @ np.array([0.0, 1.0, 0.0])   # Ruhelage: +y hinten
    if ey @ hinten < 0: ey = -ey
    RF = np.stack([ex, ey, ez], 1)
    o = np.array([Bp['spine_03'][0], Bp['spine_03'][1], 0.0])
    lok = lambda P: (np.asarray(P) - o) @ RF          # Welt (Stehen) -> Rahmen
    welt_ = lambda L: o + np.asarray(L) @ RF.T        # Rahmen -> Welt (Stehen)
    Bl = {n: lok(v) for n, v in Bp.items()}
    zeichen = 1.0; mx = 0.0; cy = 0.0
    xs = 0.5 * abs(Bl['upperarm_l'][0] - Bl['upperarm_r'][0])
    zs = 0.5 * (Bl['upperarm_l'][2] + Bl['upperarm_r'][2])
    zh = Bl['neck_01'][2] if 'neck_01' in Bl else zs + 0.06
    zk = 0.5 * (Bl['calf_l'][2] + Bl['calf_r'][2])
    # Körper im Stehen (Haut nach den Gewichten), als Strahlziel ohne Arm jenseits der Schulterkappe
    ecken, flaechen, voll = [], [], []
    hautw = []   # je Ecke der Haut: Gewichte der Knochen, denen das Tuch folgen darf
    armk = ('upperarm', 'lowerarm', 'hand', 'thumb', 'index', 'middle', 'ring', 'pinky')
    for ob in netze:
        if ob is kleid: continue
        me = ob.data
        P = welt(ob)
        gnamen = [g.name for g in ob.vertex_groups]
        Wb = dicht(ob, gnamen); sw = Wb.sum(1)
        Pp = np.zeros_like(P)
        for j, n in enumerate(gnamen):
            if n not in DM: continue
            sel = Wb[:, j] > 0
            if sel.any(): Pp[sel] += Wb[sel, j:j + 1] * (np.c_[P[sel], np.ones(sel.sum())] @ DM[n].T)[:, :3]
        rest = 1.0 - np.array([sum(Wb[i, j] for j, n in enumerate(gnamen) if n in DM) for i in range(len(P))])
        Pp += np.clip(rest, 0, 1)[:, None] * P
        gn = {g.index: g.name for g in ob.vertex_groups}
        weg = np.zeros(len(P), bool)
        for v in me.vertices:
            if not v.groups: continue
            g = max(v.groups, key=lambda g: g.weight)
            n = gn.get(g.group, '')
            if n.startswith(armk):
                sd = 'upperarm' + n[-2:] if n[-2:] in ('_l', '_r') else None
                d = (Vector(P[v.index]) - B0[sd]).length if sd in B0 else 1.0
                weg[v.index] = d > ARM_KAPPE
        off = len(ecken)
        for i in range(len(P)):
            d_ = {}
            for j, n in enumerate(gnamen):
                if Wb[i, j] > 0 and n in FOLGT: d_[n] = d_.get(n, 0.0) + Wb[i, j]
            hautw.append(d_)
        ecken += [Vector(q) for q in lok(Pp)]
        flaechen += [tuple(off + i for i in pg.vertices) for pg in me.polygons if not weg[list(pg.vertices)].any()]
        voll += [tuple(off + i for i in pg.vertices) for pg in me.polygons]
    bv = BVHTree.FromPolygons(ecken, flaechen)
    bvv = BVHTree.FromPolygons(ecken, voll)
    zt = zs + 0.75 * (zh - zs)
    # Kragen dichter (Schulterschräge vom Hals zur Schulter, sonst schneidet die Gerade zwischen zwei Reihen in den Nacken)
    nk = NZ // 3; zm = zs - 0.04
    zz = np.concatenate([np.linspace(zt, zm, nk, endpoint=False), np.linspace(zm, zk, NZ - nk)])
    tt = np.linspace(-1, 1, NT)
    zu = zs - 0.10 * (zs - zk)    # bis hierhin gehen die Ränder von WINKEL_OBEN auf WINKEL_UNTEN
    R = np.zeros((NZ, NT)); TH = np.zeros((NZ, NT))
    for i, z in enumerate(zz):
        a = smooth(float(np.clip((zt - z) / max(zt - zu, 1e-3), 0, 1)))
        tm = np.radians(WINKEL_OBEN + (WINKEL_UNTEN - WINKEL_OBEN) * a)
        for k, t in enumerate(tt):
            th = t * tm; TH[i, k] = th
            d = Vector((zeichen * math.sin(th), math.cos(th), 0.0))
            c = Vector((mx, cy, z))
            # im Stehen hängen die Arme an der Seite: Strahl auch gegen sie (TUCH_STRAHL=rumpf: ohne Arme), sonst laufen die Ränder
            # unterhalb des Kragens durch den Oberarm (Messung 18:04: 3,5 cm)
            h = (bv if STRAHL == 'rumpf' else bvv).ray_cast(c + d * 1.5, -d, 1.5)
            R[i, k] = (h[0] - c).length if h[0] is not None else 0.0
    R = np.maximum(R, R[:, ::-1])                       # spiegelgleich
    gap = np.where(zz[:, None] >= zs - 0.03, KRAGEN, LUFT)
    unten = np.maximum.accumulate(np.where(zz[:, None] < zs, R, 0), axis=0)
    rmin = R + gap
    rmin = np.where(zz[:, None] < zs, np.maximum(rmin, unten + LUFT), rmin)
    # Trapez: unter den Schultern nach unten weiter
    f = np.clip((zs - zz) / max(zs - zk, 1e-3), 0, 1)[:, None]
    ziel = rmin.copy()
    base = rmin[np.argmin(np.abs(zz - zs))]
    ziel = np.where(zz[:, None] < zs, np.maximum(ziel, base * (1 + (WEITE - 1) * f)), ziel)
    # glätten (Halbmesser, Winkel und Höhe bleiben: Saum gerade, Ränder glatt), nie unter rmin
    r = ziel.copy()
    for _ in range(30):
        q = r.copy()
        q[1:-1, :] = 0.25 * r[:-2, :] + 0.5 * r[1:-1, :] + 0.25 * r[2:, :]
        q[:, 1:-1] = 0.25 * q[:, :-2] + 0.5 * q[:, 1:-1] + 0.25 * q[:, 2:]
        r = np.maximum(q, rmin)
    r = np.maximum(r, r[:, ::-1])
    falte = 0.008 * np.clip((zs - zz) / 0.3, 0, 1)[:, None] * np.cos(tt * 7 * math.pi)[None, :]
    r = r + np.maximum(falte, 0) * 1.0 + np.minimum(falte, 0) * 0.5
    G = np.zeros((NZ, NT, 3))
    G[..., 0] = mx + zeichen * r * np.sin(TH); G[..., 1] = cy + r * np.cos(TH); G[..., 2] = zz[:, None]
    # Kragen liegt auf: oben je Ecke KRAGEN über der nächsten Hautstelle (längs ihrer Normale), nach unten bis zm ausgeblendet; dann
    # glätten und spiegeln, dreimal
    wz = smooth(np.clip((zz - (zm - 0.05)) / 0.05, 0, 1))
    for _ in range(8):
        for i in range(NZ):
            if wz[i] <= 0: continue
            for k in range(NT):
                h = bvv.find_nearest(Vector(G[i, k]), 0.5)
                if h[0] is None: continue
                n = h[1] if (Vector(G[i, k]) - h[0]).dot(h[1]) >= 0 or h[3] < 1e-4 else h[1]
                G[i, k] = (1 - wz[i]) * G[i, k] + wz[i] * np.array(h[0] + n.normalized() * KRAGEN)
        S = G.copy(); S[1:-1, 1:-1] = 0.5 * G[1:-1, 1:-1] + 0.125 * (G[:-2, 1:-1] + G[2:, 1:-1] + G[1:-1, :-2] + G[1:-1, 2:])
        # Ränder längs glätten (Bild 17:48: vorn am Kragen Zacken, wo Nachbarecken auf Brust und Schulterkappe fielen)
        for kk in (0, NT - 1): S[1:-1, kk] = 0.5 * G[1:-1, kk] + 0.25 * (G[:-2, kk] + G[2:, kk])
        S[0, 1:-1] = 0.5 * G[0, 1:-1] + 0.25 * (G[0, :-2] + G[0, 2:])
        G = np.where(wz[:, None, None] > 0, S, G)
        # nicht spiegeln: im Stehen liegen die Schultern ungleich (Idle_Loop: Oberarm l 72, r 77 Grad), gespiegelt drückte der Kragen auf
        # einer Seite 2,6 cm in den Rücken (Messung 18:06); spiegelgleich bleibt der hängende Teil (Strahlen, Halbmesser gespiegelt)
    # zuletzt überall Abstand: keine Ecke näher als TUCH_MIN an der Haut (im Stehen, mit Armen)
    amin = float(os.environ.get('TUCH_MIN', '0.012'))
    for i in range(NZ):
        for k in range(NT):
            h = bvv.find_nearest(Vector(G[i, k]), 0.3)
            if h[0] is None: continue
            dvec = Vector(G[i, k]) - h[0]
            if dvec.dot(h[1]) < 0 or dvec.length < amin:
                G[i, k] = np.array(h[0] + h[1].normalized() * amin)
    # Normale nach außen
    du = np.gradient(G, axis=1); dv = np.gradient(G, axis=0)
    N = np.cross(du, dv); N /= np.maximum(np.linalg.norm(N, axis=2, keepdims=True), 1e-9)
    rad = np.stack([np.sin(TH) * zeichen, np.cos(TH), np.zeros_like(TH)], 2)
    N *= np.sign((N * rad).sum(2, keepdims=True) + 1e-12)
    A2 = G - N * DICKE / 2; B2 = G + N * DICKE / 2   # innen, aussen (im Stehen, Rahmen)
    # Gewichte je Ecke (Stehen) und zurück in die Ruhelage: v_ruhe = (Summe w D)^-1 v_stehen
    global TUCH_W
    TUCH_W = []
    kdh = KDTree(len(ecken))
    for i_, q_ in enumerate(ecken): kdh.insert(q_, i_)
    kdh.balance()
    def zurueck(L):
        R_ = np.zeros_like(L)
        for i in range(NZ):
            for k in range(NT):
                w = gewicht_haut(L[i, k], bvv, voll, hautw, zs, kdh)
                TUCH_W.append(w)
                Mx = sum(DM[n] * g for n, g in w.items())
                R_[i, k] = (np.linalg.inv(Mx) @ np.append(welt_(L[i, k]), 1.0))[:3]
        return R_
    A_r = zurueck(A2); B_r = zurueck(B2)
    global TUCH_RUHE
    TUCH_RUHE = np.concatenate([A_r.reshape(-1, 3), B_r.reshape(-1, 3)])
    spange(kleid, teilnamen, A_r, B_r)
    netz_ersetzen(kleid, ui, A_r, B_r, teilnamen.index('cloak'))
    s = 1.0
    # Messung (im Stehen, Rahmen): Saum gerade, Ränder unter der Schulter spiegelgleich, Kragen liegt auf
    m = {'saum_spanne_cm': round(float(np.ptp(G[-1, :, 2])) * 100, 2)}
    sp = 0.0
    for i in range(NZ):
        if zz[i] > zs - 0.10: continue
        a, b = G[i, 0], G[i, -1]
        sp = max(sp, float(np.linalg.norm(np.array([2 * mx - b[0], b[1], b[2]]) - a)))
    m['kante_spiegel_cm'] = round(sp * 100, 2)
    bvg = bvv
    kr = []; tief = 0.0; wo_t = wo_k = None
    inner = (A2 if s > 0 else B2)
    for i in range(NZ):
        for k in range(NT):
            p = Vector(inner[i, k]); h = bvg.find_nearest(p, 0.3)
            if h[0] is None: continue
            if (p - h[0]).dot(h[1]) < 0 and h[3] > tief: tief = h[3]; wo_t = (i, k)
            if zz[i] >= zs - 0.03 and abs(G[i, k, 0] - mx) > 0.5 * xs:
                kr.append(h[3])
                if h[3] >= max(kr): wo_k = (i, k)
    m['kragen_abstand_max_cm'] = round(max(kr) * 100, 1) if kr else None
    m['tuch_in_haut_cm'] = round(tief * 100, 2)   # im Stehen, Arme gesenkt, gegen den ganzen Körper
    m['wo'] = {'haut': wo_t, 'kragen': wo_k, 'reihe_schulter': int(np.argmin(np.abs(zz - zs)))}
    m['saum_hoehe_m'] = round(float(zk), 3)
    return m


def lbs(ob, DM, ersatz=None):
    # Haut nach den Gewichten (wie Godot, Vergleich 18:10: Haut 6 mm, Tuch 6 mm); ersatz: Knochen ohne Lage -> anderer Knochen
    P = welt(ob); namen = [g.name for g in ob.vertex_groups]
    W = dicht(ob, namen); W /= np.maximum(W.sum(1, keepdims=True), 1e-9)
    Pp = np.zeros_like(P); P1 = np.c_[P, np.ones(len(P))]
    for j, n in enumerate(namen):
        n2 = ersatz(n) if ersatz else n
        D_ = DM.get(n2, np.eye(4)); sel = W[:, j] > 0
        if sel.any(): Pp[sel] += W[sel, j:j + 1] * (P1[sel] @ D_.T)[:, :3]
    return Pp


def posen_messen(kleid, netze, teilnamen, koerper_glb):
    # 431 Tuch (Sokrates 17:29, Bedingung 2): Tuch gegen Haut in Stehen, Gehen und Schwerthieb (Arm gehoben), je Bild der Bewegung,
    # ohne Feder (die Kette folgt spine_03; die Feder schiebt das Tuch nur weiter weg); Abstand längs der Flächennormale der Haut
    import haltung
    tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
    um = tl == teilnamen.index('cloak')
    gi = {g.index for g in kleid.vertex_groups if g.name.startswith('umhang_')}
    an_kette = np.array([any(g.group in gi and g.weight > 0.05 for g in v.groups) for v in kleid.data.vertices])[um]
    aus = {}
    for bew, zeiten in (('Idle_Loop', [0.0, 1.0, 2.0]), ('Walk_Loop', [0.0, 0.25, 0.5, 0.75]), ('Sword_Attack', [0.2, 0.4, 0.6, 0.8, 1.0])):
        tief_max = 0.0; n_tief = 0; tief_starr = 0.0; wo = None
        for z_ in zeiten:
            DM = {n: np.array(M) for n, M in haltung.verformung(koerper_glb, UAL, bew, z_).items()}
            ecken, fl, ecken_namen = [], [], []
            for ob in netze:
                if ob is kleid: continue
                off = len(ecken)
                ecken += [Vector(q) for q in lbs(ob, DM)]
                fl += [tuple(off + i for i in pg.vertices) for pg in ob.data.polygons]
                gn = {g.index: g.name for g in ob.vertex_groups}
                ecken_namen += [gn.get(max(ob.data.vertices[pg.vertices[0]].groups, key=lambda g: g.weight).group, '?') if ob.data.vertices[pg.vertices[0]].groups else '?' for pg in ob.data.polygons]
            bvh_ = BVHTree.FromPolygons(ecken, fl)
            T = lbs(kleid, DM, lambda n: 'spine_03' if n.startswith('umhang_') else n)[um]
            for qi, q in enumerate(T):
                h = bvh_.find_nearest(Vector(q), 0.1)
                if h[0] is None: continue
                if (Vector(q) - h[0]).dot(h[1]) < 0:
                    tief_max = max(tief_max, h[3])
                    if not an_kette[qi] and h[3] > tief_starr:
                        tief_starr = h[3]; vi = np.where(um)[0][qi]
                        wo = (z_, [round(float(x), 3) for x in welt(kleid)[vi]], [(kleid.vertex_groups[g.group].name, round(g.weight, 2)) for g in kleid.data.vertices[vi].groups], ecken_namen[h[2]] if ecken_namen else None)
                    if h[3] > 0.01: n_tief += 1
        # starr: ohne Kette (Kragen, oberer Rücken), dort hilft keine Feder
        aus[bew] = {'in_haut_cm': round(tief_max * 100, 1), 'ecken_ueber_1cm': n_tief, 'starr_cm': round(tief_starr * 100, 1), 'wo_starr': wo}
    return aus


def spange(kleid, teilnamen, A_r, B_r):
    # die Spangen (clasp) sassen an den Ecken des alten Umhangs (Bild 17:48: auf den Schultern neben dem Hals); jetzt je Seite auf die
    # vordere Spitze des Kragens (Reihe 2, äußerste Spalte), 4 mm vor dem Stoff (Ruhelage)
    if 'clasp' not in teilnamen: return
    me = kleid.data
    tl = np.zeros(len(me.vertices), dtype=int); me.attributes['teil'].data.foreach_get('value', tl)
    ci = np.where(tl == teilnamen.index('clasp'))[0]
    if not len(ci): return
    V = welt(kleid); inv = np.array(kleid.matrix_world.inverted())
    co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co); co = co.reshape(-1, 3)
    ziele = []
    for kk in (0, B_r.shape[1] - 1):
        n = B_r[2, kk] - A_r[2, kk]; n /= max(np.linalg.norm(n), 1e-9)
        ziele.append(B_r[2, kk] + n * 0.004)
    gruppen = [ci[np.linalg.norm(V[ci] - z_, axis=1) <= np.linalg.norm(V[ci] - ziele[1 - j], axis=1)] for j, z_ in enumerate(ziele)]
    for z_, sel in zip(ziele, gruppen):
        if not len(sel): continue
        co[sel] = (V[sel] + (z_ - V[sel].mean(0))) @ inv[:3, :3].T + inv[:3, 3]
    me.vertices.foreach_set('co', co.ravel()); me.update()


def netz_ersetzen(kleid, ui, A2, B2, teil):
    # alter Umhang (aus rig.py, ausgedünnt) weg, neuer als Gitter mit zwei Lagen und geschlossenem Rand hinein; Bildkoordinaten und
    # Farbe (albedo) vom nächsten Punkt des alten Umhangs (gleiche Stelle am Körper, gleicher Stoff im Atlas)
    me = kleid.data; M = kleid.matrix_world; inv = M.inverted()
    alt_v = [M @ v.co for v in me.vertices]
    alb = me.attributes['albedo']; uvl = me.uv_layers.active.data
    ALB = np.array([alb.data[i].color[:] for i in range(len(me.vertices))])
    us = set(int(i) for i in ui)
    altf = [p for p in me.polygons if p.vertices[0] in us]
    # nur die größte Insel im Atlas (Lauf am Rechner 17:45: Bildkoordinaten über Inselgrenzen gemischt gaben Muster wie eine Platine)
    kante = {}
    for f in altf:
        n = len(f.vertices)
        for j in range(n):
            a, b = f.vertices[j], f.vertices[(j + 1) % n]
            ua, ub = tuple(np.round(uvl[f.loop_indices[j]].uv, 5)), tuple(np.round(uvl[f.loop_indices[(j + 1) % n]].uv, 5))
            key = (min(a, b), max(a, b)); kante.setdefault(key, []).append((f.index, {a: ua, b: ub}))
    nach = {f.index: [] for f in altf}
    for lst in kante.values():
        for x in range(len(lst)):
            for y in range(x + 1, len(lst)):
                if lst[x][1] == lst[y][1]: nach[lst[x][0]].append(lst[y][0]); nach[lst[y][0]].append(lst[x][0])
    insel = {}; inseln = []
    for f in altf:
        if f.index in insel: continue
        st = [f.index]; insel[f.index] = len(inseln); grp = []
        while st:
            x = st.pop(); grp.append(x)
            for y in nach[x]:
                if y not in insel: insel[y] = len(inseln); st.append(y)
        inseln.append(grp)
    gross = set(max(inseln, key=lambda g: sum(me.polygons[i].area for i in g)))
    altf = [f for f in altf if f.index in gross]
    print('TUCH Inseln', len(inseln), 'groesste', len(gross), 'Flaechen')
    bv = BVHTree.FromPolygons(alt_v, [tuple(p.vertices) for p in altf])
    def probe(p):
        h = bv.find_nearest(Vector(p))
        f = altf[h[2]]; q = h[0]
        pts = [alt_v[i] for i in f.vertices]
        from mathutils.geometry import barycentric_transform
        uvs = [Vector(tuple(uvl[li].uv) + (0.0,)) for li in f.loop_indices]
        # Dreieck (bei Vierecken die Hälfte, in der q liegt)
        tri = [0, 1, 2]
        if len(pts) == 4:
            from mathutils.geometry import intersect_point_tri
            if intersect_point_tri(q, pts[0], pts[1], pts[2]) is None: tri = [0, 2, 3]
        a, b, c = tri
        uv = barycentric_transform(q, pts[a], pts[b], pts[c], uvs[a], uvs[b], uvs[c])
        col = ALB[list(f.vertices)].mean(0)
        return Vector((uv.x, uv.y)), col
    bm = bmesh.new(); bm.from_mesh(me)
    bm.verts.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[bm.verts[int(i)] for i in ui], context='VERTS')
    lt = bm.verts.layers.int['teil']; lc = bm.verts.layers.float_color['albedo']; lu = bm.loops.layers.uv.active
    nz, nt = A2.shape[:2]
    lagen = []
    for L in (A2, B2):
        g = [[bm.verts.new(inv @ Vector(L[i, k])) for k in range(nt)] for i in range(nz)]
        lagen.append(g)
    probe_v = {}
    for L, g in zip((A2, B2), lagen):
        for i in range(nz):
            for k in range(nt):
                uv, col = probe(L[i, k]); v = g[i][k]
                v[lt] = teil; v[lc] = tuple(col); probe_v[v] = uv
    neu_f = []
    def flaeche(vs):
        f = bm.faces.new(vs); f.material_index = 0; neu_f.append(f)
        for l in f.loops: l[lu].uv = probe_v[l.vert]
    a, b = lagen
    for i in range(nz - 1):
        for k in range(nt - 1):
            flaeche([b[i][k], b[i][k + 1], b[i + 1][k + 1], b[i + 1][k]])     # aussen
            flaeche([a[i][k], a[i + 1][k], a[i + 1][k + 1], a[i][k + 1]])     # innen
    rand = [(i, 0) for i in range(nz)] + [(nz - 1, k) for k in range(1, nt)] + [(i, nt - 1) for i in range(nz - 2, -1, -1)] + [(0, k) for k in range(nt - 2, 0, -1)]
    for j in range(len(rand)):
        p, q = rand[j], rand[(j + 1) % len(rand)]
        try: flaeche([a[p[0]][p[1]], a[q[0]][q[1]], b[q[0]][q[1]], b[p[0]][p[1]]])
        except ValueError: pass
    bmesh.ops.recalc_face_normals(bm, faces=neu_f)
    bm.to_mesh(me); bm.free(); me.update()


TUCH_W = None
TUCH_RUHE = None


# 431 Tuch: Gewichte des Tuchs von der Haut darunter (Messung 18:17, Gehen: mit eigenen Gewichten wölbte sich die Haut am Schulterblatt
# 3 cm durch das Tuch); alle Knochen außer Unterarm, Hand, Bein, Kopf (auch Drehknochen wie upperarm_twist); unter der Schulter allmählich nur noch spine_03 (dort hängt die Kette)
NICHT = ('lowerarm', 'hand', 'thumb', 'index', 'middle', 'ring', 'pinky', 'thigh', 'calf', 'foot', 'ball', 'head', 'umhang', 'ik_', 'root')


class _Folgt:
    def __contains__(self, n): return not n.startswith(NICHT)


FOLGT = _Folgt()


HAUT_R = float(os.environ.get('TUCH_HAUT_R', '0'))   # Umkreis für gemittelte Hautgewichte (m); 0: nächste Fläche (Messung 18:19: 6 cm hob Gehen 2,3 -> 3,9 cm)


def gewicht_haut(p, bvv, flaechen, hautw, zs, kd=None):
    h = bvv.find_nearest(Vector(p), 0.5)
    w = {}
    if h[0] is not None and kd is not None and HAUT_R > 0:
        for (_, vi, d) in kd.find_range(h[0], HAUT_R):
            g_ = math.exp(-(d / (0.5 * HAUT_R)) ** 2)
            for n, g in hautw[vi].items(): w[n] = w.get(n, 0.0) + g * g_
    elif h[0] is not None:
        for vi in flaechen[h[2]]:
            for n, g in hautw[vi].items(): w[n] = w.get(n, 0.0) + g
    t = smooth(float(np.clip((p[2] - (zs - 0.14)) / 0.08, 0, 1)))
    s_ = sum(w.values())
    w = {n: g / s_ * t for n, g in w.items()} if s_ > 0 else {}
    w['spine_03'] = w.get('spine_03', 0.0) + (1.0 - (t if s_ > 0 else 0.0))
    return w


def gewicht_tuch(p, mx, xs, zs, zeichen):
    # -> (Rücken, Schlüsselbein, Oberarm, Seite +1 l / -1 r)
    f = (p[0] - mx) / xs * zeichen
    # Schlüsselbein nur oben über der Schulter, nicht hinten auf dem Schulterblatt (Messung 18:17, Gehen: dort folgte das Tuch mit 0,67
    # dem Schlüsselbein, die Haut dem Rücken, 2,7 cm in der Haut); Winkel von hinten (0) zur Seite (90)
    th = math.degrees(math.atan2(abs(p[0] - mx), p[1]))
    c = smooth(float(np.clip((abs(f) - 0.35) / 0.55, 0, 1))) * 0.8 * smooth(float(np.clip((th - 50.0) / 35.0, 0, 1)))
    # unter der Schulter nur Rücken: dort übernimmt die Kette (unter spine_03); mit Schlüsselbein gelegt und mit Kette gezeichnet lag das
    # Tuch in Godot 2-3 cm im Rücken (Vergleich 18:10)
    c *= smooth(float(np.clip((p[2] - (zs - 0.14)) / 0.08, 0, 1)))
    # Kragen über der Schulterkappe folgt ihr zum Teil (sonst steht er über dem gesenkten Oberarm ab, Bild 17:45)
    u = OBERARM * smooth(float(np.clip((abs(f) - 0.7) / 0.4, 0, 1))) * smooth(float(np.clip((p[2] - (zs - 0.07)) / 0.04, 0, 1)))
    return ((1 - c) * (1 - u), c * (1 - u), u, 1.0 if f > 0 else -1.0)


def starr(kleid, arm, kn, um, V):
    if TUCH_W is not None and len(TUCH_W) == int(um.sum()):
        W = np.zeros((len(V), len(kn)))
        js = kn.index('spine_03')
        # Zuordnung über die Lage (bm.to_mesh legt die neuen Ecken in umgekehrter Folge ab, Fehlersuche 18:15: alle Gewichte vertauscht)
        kd = KDTree(len(TUCH_RUHE))
        for j, q in enumerate(TUCH_RUHE): kd.insert(Vector(q), j)
        kd.balance()
        ui_ = np.where(um)[0]
        for i in ui_:
            _, j, d = kd.find(Vector(V[i]))
            if d > 1e-4: raise SystemExit('TUCH: Ecke %d ohne Gegenstück (%.4f m)' % (i, d))
            for n, g in TUCH_W[j].items(): W[i, kn.index(n)] += g
        return W
    raise SystemExit('TUCH: Gewichte fehlen')


def starr_alt(kleid, arm, kn, um, V):
    # 431 Tuch: über dem Kettenanfang Rücken (spine_03) und zu den Seiten das Schlüsselbein; nichts an Arm und Bein
    B = {b.name: arm.matrix_world @ b.head_local for b in arm.data.bones}
    mx = 0.5 * (B['upperarm_l'].x + B['upperarm_r'].x); xs = 0.5 * abs(B['upperarm_l'].x - B['upperarm_r'].x)
    zeichen = 1.0 if B['upperarm_l'].x > B['upperarm_r'].x else -1.0
    W = np.zeros((len(V), len(kn)))
    js = kn.index('spine_03'); jl = kn.index('clavicle_l'); jr = kn.index('clavicle_r')
    zs = 0.5 * (B['upperarm_l'].z + B['upperarm_r'].z)
    ob = float(os.environ.get('TUCH_OBERARM', '0.45'))
    for i in np.where(um)[0]:
        f = (V[i, 0] - mx) / xs * zeichen
        c = smooth(float(np.clip((abs(f) - 0.35) / 0.55, 0, 1))) * 0.8
        # Kragen über der Schulterkappe folgt ihr zum Teil (sonst steht er im Stehen über dem gesenkten Oberarm ab, Bild 17:45)
        u = ob * smooth(float(np.clip((abs(f) - 0.7) / 0.4, 0, 1))) * smooth(float(np.clip((V[i, 2] - (zs - 0.07)) / 0.04, 0, 1)))
        W[i, js] = (1 - c) * (1 - u); W[i, jl if f > 0 else jr] = c * (1 - u)
        if u > 0: W[i, kn.index('upperarm_l' if f > 0 else 'upperarm_r')] = u
    return W


def kette(arm, kleid, teilnamen):
    tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
    V = welt(kleid)
    um = tl == teilnamen.index('cloak')
    C = V[um]
    B = {b.name: arm.matrix_world @ b.head_local for b in arm.data.bones}
    zeichen = 1.0 if B['upperarm_l'].x > B['upperarm_r'].x else -1.0   # Spalten „l“ auf der Seite von upperarm_l
    sz = 0.5 * (B['upperarm_l'].z + B['upperarm_r'].z)
    z1 = float(C[:, 2].min())
    # 431 Tuch: Kette erst ab der Unterkante der Schulterblätter (Anteil der Strecke Schulter–Saum), darüber hängt das Tuch fest am Rücken;
    # mit 10 cm unter der Schulter sank der obere Rücken des Tuchs in Godot 1,8 cm in die Haut (Messung 18:09, Feder sackt)
    z0 = sz - (float(os.environ.get('KETTE_ANTEIL', '0.28')) * (sz - z1) if TUCH else OBEN_UNTER)
    mx = 0.5 * (B['upperarm_l'].x + B['upperarm_r'].x)

    def halb(z):   # halbe Breite des Umhangs auf Hoehe z (gespiegelt gemittelt)
        s = C[np.abs(C[:, 2] - z) < 0.04]
        if not len(s): s = C[np.argsort(np.abs(C[:, 2] - z))[:40]]
        return max(0.5 * ((s[:, 0] - mx).max() - (s[:, 0] - mx).min()), 0.05)

    def hinten(x, z):   # Aussenseite des Umhangs (y am weitesten hinten, +y) an der Stelle x, z
        d = (C[:, 0] - x) ** 2 + (C[:, 2] - z) ** 2
        n = C[np.argsort(d)[:24]]
        return float(n[:, 1].max()) - GLIED_TIEFE

    zs = [z0 + (z1 - z0) * j / GLIEDER for j in range(GLIEDER + 1)]
    gelenke = {}
    for sp, a in SPALTEN:
        pts = []
        for z in zs:
            x = mx + (zeichen if sp.startswith('l') else -zeichen) * abs(a) * halb(z) if a else mx
            pts.append(Vector((x, 0.0, z)))
        gelenke[sp] = pts
    # Spiegeln: Tiefe aus beiden Seiten gemittelt, damit links und rechts gleich liegen
    for sp, a in SPALTEN:
        for p in gelenke[sp]:
            p.y = 0.5 * (hinten(p.x, p.z) + hinten(2 * mx - p.x, p.z)) if sp != 'm' else hinten(p.x, p.z)
    # Knochen anlegen (Ruhelage), erstes Glied unter spine_03
    bpy.context.view_layer.objects.active = arm
    for o in bpy.context.selected_objects: o.select_set(False)
    arm.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    eb = arm.data.edit_bones
    inv = arm.matrix_world.inverted()
    namen = []
    for sp, a in SPALTEN:
        vor = eb['spine_03']
        for j in range(GLIEDER):
            b = eb.new('umhang_%s_%d' % (sp, j + 1))
            b.head = inv @ gelenke[sp][j]; b.tail = inv @ gelenke[sp][j + 1]
            b.roll = 0.0; b.parent = vor; b.use_connect = j > 0; b.use_deform = True
            vor = b; namen.append(b.name)
    bpy.ops.object.mode_set(mode='OBJECT')
    # Gewichte: unter dem Anfang die Kette (quer zwischen den Spalten, laengs zwischen den Gliedern), im Band weich hinueber
    kn = [b.name for b in arm.data.bones]
    W = dicht(kleid, kn)
    alt_arm_bein = float(((W[um][:, [kn.index(n) for n in kn if n.startswith(('upperarm', 'lowerarm', 'hand', 'thigh', 'calf'))]].sum(1)) > 0.01).mean())
    # Chef 15.11., 16:55 (Lauf 11: „der linke und rechte Saum … schaut halt aus, als ob er überall eingerissen wäre“): über dem
    # Kettenanfang und im Band folgten Ecken des Umhangs noch Ober- und Unterarm (Gewichte aus kauf_kleid.py), darunter der Kette; wo
    # beide aneinanderstoßen, riss der Saum auf Achselhöhe auf. Arm und Hand des Umhangs gehen auf das Schlüsselbein derselben Seite
    arm_auf = {}
    for j, n in enumerate(kn):
        if n.startswith(('upperarm', 'lowerarm', 'hand')) and n[-2:] in ('_l', '_r') and 'clavicle' + n[-2:] in kn:
            arm_auf[j] = kn.index('clavicle' + n[-2:])
    for i in np.where(um)[0]:
        for j, k in arm_auf.items():
            if W[i, j] > 0: W[i, k] += W[i, j]; W[i, j] = 0.0
    if TUCH: W[um] = starr(kleid, arm, kn, um, V)[um]
    for i in np.where(um)[0]:
        x, y, z = V[i]
        if z > z0: a = 0.0
        else: a = float(np.clip((z0 - z) / BAND, 0, 1)); a = a * a * (3 - 2 * a)
        if a <= 0: continue
        u = (z0 - z) / max(z0 - z1, 1e-3) * GLIEDER
        lw = zelt(u, [j + 0.5 for j in range(GLIEDER)])
        q = (x - mx) / halb(z) * zeichen   # +: Seite l
        # Stuetzstellen quer: Spalten l bei q > 0
        qs = [(abs(s) if sp.startswith('l') else -abs(s)) for sp, s in SPALTEN]
        ordnung = np.argsort(qs)
        qw = zelt(q, [qs[k] for k in ordnung])
        neu = np.zeros(len(kn))
        for oi, k in enumerate(ordnung):
            if qw[oi] <= 0: continue
            sp = SPALTEN[k][0]
            for j in range(GLIEDER):
                if lw[j] > 0: neu[kn.index('umhang_%s_%d' % (sp, j + 1))] += qw[oi] * lw[j]
        alt = W[i] / max(W[i].sum(), 1e-6)
        W[i] = (1 - a) * alt + a * neu
    W[um] /= np.maximum(W[um].sum(1, keepdims=True), 1e-6)
    # alte Gruppen der Umhangecken ersetzen
    gruppen = {g.name: g for g in kleid.vertex_groups}
    for n in kn:
        if n not in gruppen: gruppen[n] = kleid.vertex_groups.new(name=n)
    idx = [int(i) for i in np.where(um)[0]]
    for g in gruppen.values(): g.remove(idx)
    for j, n in enumerate(kn):
        sel = np.where(um & (W[:, j] > 1e-4))[0]
        for i in sel: gruppen[n].add([int(i)], float(W[i, j]), 'REPLACE')
    # Messung
    m = {'knochen': namen, 'oben_m': round(z0, 3), 'saum_m': round(z1, 3)}
    fehl = 0.0
    for sp, a in SPALTEN:
        if not sp.startswith('l'): continue
        for p, q in zip(gelenke[sp], gelenke['r' + sp[1:]]):
            fehl = max(fehl, (Vector((2 * mx - q.x, q.y, q.z)) - p).length)
    m['kette_spiegel_cm'] = round(fehl * 100, 2)
    kd = KDTree(int(um.sum())); ui = np.where(um)[0]
    for k, i in enumerate(ui): kd.insert(Vector(V[i]), k)
    kd.balance()
    def gegen(n):
        if n.startswith('umhang_l'): return 'umhang_r' + n[8:]
        if n.startswith('umhang_r'): return 'umhang_l' + n[8:]
        if n.endswith('_l'): return n[:-2] + '_r'
        if n.endswith('_r'): return n[:-2] + '_l'
        return n
    perm = [kn.index(gegen(n)) if gegen(n) in kn else j for j, n in enumerate(kn)]
    gw = []
    for k, i in enumerate(ui):
        x, y, z = V[i]
        _, k2, d = kd.find(Vector((2 * mx - x, y, z)))
        if d > 0.01: continue
        gw.append(float(np.abs(W[i] - W[ui[k2]][perm]).max()))
    m['gewicht_spiegel_max'] = round(max(gw), 3) if gw else None
    m['gewicht_spiegel_mittel'] = round(float(np.mean(gw)), 4) if gw else None
    m['gespiegelte_ecken'] = len(gw)
    an = [kn.index(n) for n in kn if n.startswith(('upperarm', 'lowerarm', 'hand', 'thigh', 'calf', 'foot'))]
    m['arm_bein_anteil_vorher'] = round(alt_arm_bein, 3)
    m['arm_bein_anteil'] = round(float((W[um][:, an].sum(1) > 0.01).mean()), 3)
    return m


def abstand(koerper, kleid, teilnamen):
    tl = np.zeros(len(kleid.data.vertices), dtype=int); kleid.data.attributes['teil'].data.foreach_get('value', tl)
    V = welt(kleid)[tl == teilnamen.index('cloak')]
    dg = bpy.context.evaluated_depsgraph_get()
    bv = BVHTree.FromObject(koerper, dg)
    mw = koerper.matrix_world.inverted()
    d = []
    for v in V[::3]:
        h = bv.find_nearest(mw @ Vector(v), 0.5)
        if h[0] is not None: d.append(h[3])
    d = np.array(d)
    return {'abstand_min_cm': round(float(d.min()) * 100, 1), 'abstand_mittel_cm': round(float(d.mean()) * 100, 1)}


figur, teile = STUECKE[STUECK]
liste = json.load(open(os.path.join(VOELKER, 'voelker.json')))['voelker']
aus = []
for e in liste:
    name = e['datei'][len('volk_'):-4]
    if NUR and name not in NUR: continue
    quelle = tracht(figur, 'w' if e['frau'] else 'm')
    kennung = '%s_%s' % (STUECK, name)
    blend = uebertragen(e, quelle, teile, kennung)
    bpy.ops.wm.open_mainfile(filepath=blend)
    arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
    arm.data.pose_position = 'REST'
    kleid = bpy.data.objects['Kleid']
    tn = json.load(open(os.path.join(quelle, 'teile.json')))
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    koerper = max([o for o in netze if o is not kleid], key=lambda o: len(o.data.vertices))
    mt = tuch(arm, kleid, netze, tn, os.path.join(VOELKER, e['datei'])) if TUCH else {}
    m = kette(arm, kleid, tn)
    m.update(mt)
    if TUCH: m['posen'] = posen_messen(kleid, netze, tn, os.path.join(VOELKER, e['datei']))
    m.update(abstand(koerper, kleid, tn))
    m.update({'volk': e['volk'], 'frau': e['frau'], 'datei': kennung + '.glb', 'groesse_m': e['groesse_m']})
    print('SCHRANK', json.dumps(m, ensure_ascii=False))
    for o in netze: o.data.name = o.name
    bpy.ops.object.select_all(action='DESELECT')
    for o in [arm] + netze: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, kennung + '.glb'), export_format='GLB', use_selection=True, export_animations=False,
                              export_apply=False, export_skins=True, export_vertex_color='ACTIVE')
    aus.append(m)
json.dump({'stueck': STUECK, 'koerper': aus}, open(os.path.join(ZIEL, 'kleiderschrank.json'), 'w'), indent=1, ensure_ascii=False)
print('SCHRANK OK', STUECK, len(aus))
