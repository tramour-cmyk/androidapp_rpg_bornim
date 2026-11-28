# 431 (Chef 12.11., 17:37 „431 jetzt“; Deckel 24.11., 10:26 „1a“): der Held auf dem Koerper seines Volkes. Je Tracht und Geschlecht
# des Menschen (held_klassen.py: held_<TRACHT>_<G>.glb) ein Modell je Volk held_<VOLK>_<TRACHT>_<G>.glb, wie 455.2 (volk_tracht.py):
# ein Netz je Stueck fuer alle Voelker, ueber die Knochen mitgewachsen (voelker.py knochen_formen, Masse voelker.ZIELE, abgenommen
# 01.11. „431 Koerper passt“), Ohren und Hauer (merkmale.py, abgenommen 02.11.), Ork auf dem Superhelden (Archiv 455.2).
# Anders als die Probe 455.2: Formschluessel (Kopfformen, Statur, unter_<PLATZ>) bleiben und wachsen mit; die Leibstuecke (431h,
# Leib_<STUECK>) bleiben, beim Ork aus dem Superhelden neu geschnitten, damit heldfigur.gd kleide wie beim Menschen zeigt und verbirgt.
# Kleiderschrank und Haare: keine eigenen Dateien je Volk. Je Volk, Geschlecht und Knochen die Abbildung G (Raum des Menschen ->
# Raum des Volkes, 3x4, Godot-Achsen) in held-klassen.json „voelker“; heldfigur.gd bindet Schrankteile und Haare damit an den
# Volkskoerper (Bindung = Ruhelage des Volkes invers mal G mal Ruhelage des Menschen mal alte Bindung).
# Benutzt von held_klassen.py (VOELKER=elf,zwerg,huegel,ork; leer: ohne), hk = das Modul held_klassen.
import os, json
import bpy, mathutils
import numpy as np
import volk_tracht as VT
import voelker as VO
import merkmale as MK
import kopf as KO
import quaternius as QT

KENNUNG = {'elf': 'ELF', 'zwerg': 'DWARF', 'huegel': 'HALFLING', 'ork': 'HALF_ORC'}   # wie HeldFigur.VOLK_MODELL
MENSCH_MAT = set()   # Materialnamen des geladenen Menschenmodells
PROBE_S = 0.01   # m: Probepunkte je Knochen (Kopf des Knochens und +x, +y, +z), daraus G


def koerper_netz(o):
    # Koerper nach dem Namen (Kaufkopf, Superheld, Leibstuecke 431h); nicht nach dem Material wie volk_tracht.ist_koerper: die Arme der
    # Kauftrachten tragen die Haut der Haende (MI_Regular) und gingen beim Ork sonst mit dem Koerper weg
    n = o.name.lower()
    return 'regular' in n or 'superhero' in n or o.name.startswith('Leib_')   # Kopf „RegularMale“, Superhero_…_FullBody


VT.ist_koerper = koerper_netz


def _probe(arm):
    # je Knochen vier Ecken mit Gewicht 1 an ihm; sie gehen alle Schritte mit (Superheld, Knochenlaengen, Groesse), daraus G
    kn = [b for b in arm.data.bones if b.name != 'root']
    V = []
    for b in kn:
        h = b.head_local
        V += [h.copy(), h + mathutils.Vector((PROBE_S, 0, 0)), h + mathutils.Vector((0, PROBE_S, 0)), h + mathutils.Vector((0, 0, PROBE_S))]
    me = bpy.data.meshes.new('VolkProbe'); me.from_pydata([tuple(v) for v in V], [], []); me.update()
    o = bpy.data.objects.new('VolkProbe', me)
    bpy.context.scene.collection.objects.link(o)
    for i, b in enumerate(kn):
        g = o.vertex_groups.new(name=b.name); g.add(list(range(4 * i, 4 * i + 4)), 1.0, 'REPLACE')
    mo = o.modifiers.new('Armature', 'ARMATURE'); mo.object = arm
    return o, [b.name for b in kn]


def _G(probe, namen):
    # Blender (Z oben) -> Godot (Y oben): C = (x, z, -y); G_godot = C G C^-1
    C = mathutils.Matrix(((1, 0, 0, 0), (0, 0, 1, 0), (0, -1, 0, 0), (0, 0, 0, 1)))
    V = [v.co.copy() for v in probe.data.vertices]
    aus = {}
    for i, n in enumerate(namen):
        q0, qx, qy, qz = V[4 * i:4 * i + 4]
        p0 = mathutils.Vector(probe['alt'][3 * i:3 * i + 3])
        L = mathutils.Matrix(((0, 0, 0), (0, 0, 0), (0, 0, 0)))
        for j, q in enumerate((qx, qy, qz)):
            d = (q - q0) / PROBE_S
            for r in range(3): L[r][j] = d[r]
        G = L.to_4x4(); G.translation = q0 - L @ p0
        Gg = C @ G @ C.inverted()
        aus[n] = [round(Gg[r][c], 5) for r in range(3) for c in range(4)]
    return aus


def _ohren_mit_schluesseln(haut, augen, art):
    # merkmale.ohren formt nur die Basis; die Formschluessel (Kopfformen, Statur) tragen die Verschiebung mit, sonst springt das Ohr zurueck
    W0 = KO._welt(haut)
    r = MK.ohren(haut, augen, art)
    D = KO._welt(haut) - W0
    if haut.data.shape_keys:
        Mi = np.array(haut.matrix_world.inverted())[:3, :3]
        Dl = D @ Mi.T
        for kb in haut.data.shape_keys.key_blocks:
            B = np.empty(len(haut.data.vertices) * 3); kb.data.foreach_get('co', B)
            kb.data.foreach_set('co', (B.reshape(-1, 3) + Dl).ravel())
    return r


# Umhang (lose, haengt frei hinter dem Koerper): waechst mit den Knochenlaengen; die Dicke (VO.mass quer) schiebt ihn hoechstens so weit
# hinaus, wie der Koerper waechst (LOSE_R: Radius von Rumpf und Gliedern), nicht im Verhaeltnis seines Abstands vom Knochen. Ohne das
# trug der Zwerg (dick 1,35) den Umhang als Wulst an Huefte und Ruecken: in der Ruhelage haengen die Seiten 35 cm neben der Wirbelsaeule
# und wanderten 12 cm hinaus (Probebild am Rechner 24.11., 10:51; Messung 10:57: Umhang 13 cm seitlich ueber dem Leib, Mensch 2 cm)
LOSE = ('CLOAK',)
LOSE_R = 0.15   # m


def lose_merken(arm, netze):
    R = {b.name: b.matrix_local.copy() for b in arm.data.bones}
    alt = {}
    for o in netze:
        if not any(x in o.name for x in LOSE) or '_unter_' in o.name: continue
        keys = list(o.data.shape_keys.key_blocks) if o.data.shape_keys else []
        alt[o.name] = ([v.co.copy() for v in o.data.vertices], [[d.co.copy() for d in kb.data] for kb in keys])
    return R, alt


def lose_nachziehen(arm, netze, e, R, alt):
    # nach VO.knochen_formen: je Ecke voll (D_n = neue Ruhelage * diag(q, el, q) * alte^-1) und duenn (q = 1); die Dicke traegt hoechstens
    # (q - 1) * LOSE_R bei (q der Ecke nach Gewicht)
    Df, Dd, Q = {}, {}, {}
    for b in arm.data.bones:
        if b.name not in R: continue
        el, q = VO.mass(b.name, e)
        Df[b.name] = b.matrix_local @ mathutils.Matrix.Diagonal((q, el, q, 1)) @ R[b.name].inverted()
        Dd[b.name] = b.matrix_local @ mathutils.Matrix.Diagonal((1, el, 1, 1)) @ R[b.name].inverted()
        Q[b.name] = q
    null = mathutils.Matrix(((0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)))
    for o in netze:
        if o.name not in alt: continue
        co, kco = alt[o.name]
        gname = {g.index: g.name for g in o.vertex_groups}
        keys = list(o.data.shape_keys.key_blocks) if o.data.shape_keys else []
        n_cap = 0
        for v in o.data.vertices:
            af, ad = null.copy(), null.copy(); w = 0.0; qv = 0.0
            for g in v.groups:
                n = gname.get(g.group)
                if n in Df and g.weight > 0: af += Df[n] * g.weight; ad += Dd[n] * g.weight; qv += Q[n] * g.weight; w += g.weight
            if w <= 0: continue
            Mf = af * (1.0 / w); Md = ad * (1.0 / w)
            cap = abs(qv / w - 1.0) * LOSE_R
            d = Mf @ co[v.index] - Md @ co[v.index]
            f = min(1.0, cap / d.length) if d.length > 1e-6 else 1.0
            if f < 1.0: n_cap += 1
            v.co = Md @ co[v.index] + d * f
            for kb, kc in zip(keys, kco): kb.data[v.index].co = Md @ kc[v.index] + (Mf @ kc[v.index] - Md @ kc[v.index]) * f
        print('LOSE %s: %d von %d Ecken auf die Dicke des Koerpers begrenzt' % (o.name, n_cap, len(o.data.vertices)))


def _ohne_bilder(objs, namen):
    # 431 App-Groesse: Materialien des Menschen ohne Bilder (je Modell 3-6 MB); heldfigur.gd nimmt die Bilder aus dem Modell des Menschen
    # (Feld „bilder_von“). Eigene Materialien (Superheld, Leinen des Superhelden, Hauer) behalten ihre Bilder
    n = 0
    for m in {m for o in objs if o.type == 'MESH' for m in o.data.materials if m and m.name in namen and m.node_tree}:
        for nd in [nd for nd in m.node_tree.nodes if nd.type == 'TEX_IMAGE']:
            m.node_tree.nodes.remove(nd); n += 1
    return n


def _vorbereiten(volk, p, frau, hk):
    arm, netze, alle = VT.laden(p)
    MENSCH_MAT.clear(); MENSCH_MAT.update(m.name for o in alle for m in o.data.materials if m)
    VT.starr(netze)
    probe, namen = _probe(arm)
    probe['alt'] = [c for v in list(probe.data.vertices)[::4] for c in v.co]
    mk = VO.MERKMALE.get(volk, {})
    if mk.get('ohr') and volk != 'ork':   # wie voelker.py: am Kaufkopf vor dem Formen (Ork: am Superhelden, danach)
        haut, augen, _ = hk.kopfnetze(netze)
        _ohren_mit_schluesseln(haut, augen, mk['ohr'])
    probe = [probe]
    netze = netze + probe; alle = alle + probe
    if VO.ZIELE[volk]['koerper'] == 'Superhero':
        netze, alle = VT.auf_superheld(arm, netze, alle, frau)
    return arm, [o for o in netze if o not in probe], alle, probe, namen


def _ork_koerper(arm, netze, alle, k, g, hk):
    """Superheld (ein Netz mit Kopf) wie der Kaufkoerper des Menschen: Kopf mit Formschluesseln, Leib_<STUECK>, Ohren, Hauer, Statur,
    unter_<PLATZ> (431h); Namen wie beim Menschen, damit held-klassen.json (teile, leib, unter) gilt."""
    import bmesh
    sh = [o for o in netze if VT.ist_koerper(o)]
    koerper = max(sh, key=lambda o: len(o.data.vertices))
    hk.waesche_leinen(koerper)
    kopf = koerper.copy(); kopf.data = koerper.data.copy(); bpy.context.scene.collection.objects.link(kopf)
    hk.nur_kopf_flaechen(kopf)
    kopf.name = 'Regular_%s_OnlyHead_Ork' % ('Female' if g == 'W' else 'Male')   # „Regular“: Haut nach toene, kopfnetze
    fk = hk.flaechen_knochen(koerper)
    leiber = []
    for teil, kn_ in hk.LEIB_KNOCHEN.items():
        c = koerper.copy(); c.data = koerper.data.copy(); c.name = 'Leib_' + teil; bpy.context.scene.collection.objects.link(c)
        bm = bmesh.new(); bm.from_mesh(c.data); bm.faces.ensure_lookup_table()
        weg = [bm.faces[i] for i, s_ in enumerate(fk) if s_ in QT.KOPF_KNOCHEN or not s_.lower().startswith(kn_)]
        bmesh.ops.delete(bm, geom=weg, context='FACES'); bm.to_mesh(c.data); bm.free(); c.data.update()
        if len(c.data.vertices): leiber.append(c)
        else: bpy.data.objects.remove(c)
    for o in sh: netze.remove(o); alle.remove(o); bpy.data.objects.remove(o)
    augen = next((o for o in netze if o.name.startswith('Eyes')), None)
    brauen = [o for o in netze if o.name.startswith('Eyebrows')]
    mk = VO.MERKMALE['ork']
    MK.ohren(kopf, augen, mk['ohr'])
    hauer, _ = MK.hauer(kopf, augen, mk['hauer'], arm)
    p = KO.merkpunkte(kopf, augen)
    hk.schluessel([kopf, augen] + brauen if augen else [kopf] + brauen, p, augen)
    neu = [kopf] + leiber
    for o in neu:   # Materialien des Superhelden mit dem Namen eines Menschenmaterials (Leinen) behalten ihr Bild (_ohne_bilder)
        for i, m in enumerate(o.data.materials):
            if m and m.name in MENSCH_MAT:
                m2 = m.copy(); m2.name = m.name + '_Ork'; o.data.materials[i] = m2
    hk.statur(arm, neu)
    sch = hk.SCHRANK_INFO.get(k)
    if sch:
        hk.unter_schluessel(leiber, netze, sch['teile'], sch['leib'])
    netze += neu + [hauer]; alle += neu + [hauer]
    try:   # Bezug der Hauttoenung aus dem Bild des Superhelden (wie voelker.py, VoelkerProbe._eigene_haut)
        hb = VO.haut_bild([kopf] + ([augen] if augen else []))
    except Exception as x:
        print('HAUTBILD FEHLER', k, repr(x)); hb = None
    print('ORK KOERPER', k, [o.name for o in neu], 'Hauer, Hautbild', hb)
    return netze, alle, hb


def baue(volk, k, g, e, hk, ziel):
    """held_<k>.glb -> held_<VOLK>_<k>.glb; e: Einstellung der Knochen (None: wie volk_tracht.baue einmessen). Gibt (Eintrag, e) zurueck."""
    z = VO.ZIELE[volk]
    frau = g == 'W'
    p = os.path.join(ziel, 'held_%s.glb' % k)
    h_soll = z['h'] * (VO.FRAU if frau else 1.0)
    arm, netze, alle, probe, namen = _vorbereiten('mensch', p, frau, hk)
    mensch = VT.messen(arm, netze)
    runden = 7 if e is None else 1
    e = dict(e) if e else VO.einstellung_start(z)
    beste = None
    for runde in range(runden):
        arm, netze, alle, probe, namen = _vorbereiten(volk, p, frau, hk)
        Rl, alt = lose_merken(arm, netze + probe)
        VO.knochen_formen(arm, netze + probe, e)
        if volk != 'ork': lose_nachziehen(arm, netze + probe, e, Rl, alt)
        m = VT.messen(arm, netze)
        if runden == 1: break
        f = h_soll / m['h']
        abw = []
        if 'kopf' in z: abw.append(abs(m['kopf'] / z['kopf'] - 1))
        if 'bein' in z: abw.append(abs(m['bein'] / z['bein'] - 1))
        s_ziel = None
        if 'schulter' in z:
            art, kf = z['schulter']
            s_ziel = mensch['schulter'] * kf if art == 'abs' else mensch['schulter_rel'] * kf * h_soll
            abw.append(abs(m['schulter'] * f / s_ziel - 1))
        print('RUNDE %s %s %d: Kopf 1/%.2f Bein %.3f Schulter %.3f Abweichung %s' % (volk, k, runde, 1 / m['kopf'], m['bein'],
              m['schulter'] * f, ['%.3f' % a for a in abw]))
        if abw and (beste is None or max(abw) < beste[0]): beste = (max(abw), dict(e))
        if not abw or max(abw) < 0.015: break
        if runde == runden - 1:
            e = beste[1]
            arm, netze, alle, probe, namen = _vorbereiten(volk, p, frau, hk)
            Rl, alt = lose_merken(arm, netze + probe)
            VO.knochen_formen(arm, netze + probe, e)
            if volk != 'ork': lose_nachziehen(arm, netze + probe, e, Rl, alt)
            m = VT.messen(arm, netze)
            break
        if 'kopf' in z: e['kopf'] = min(max(e['kopf'] * (z['kopf'] / max(m['kopf'], 1e-3)) ** 1.15, 0.6), 2.2)
        if 'bein' in z: e['bein'] = min(max(e['bein'] * (z['bein'] / max(m['bein'], 1e-3)) ** 1.6, 0.3), 1.6)
        if s_ziel: e['schulter'] = min(max(e['schulter'] * (s_ziel / (m['schulter'] * f)), 0.5), 2.2)
    VO.auf_groesse(arm, alle, m['h'], m['sohle_figur'], h_soll)
    G = _G(probe[0], namen)
    for x in probe: alle.remove(x); bpy.data.objects.remove(x)
    m2 = VT.messen(arm, netze)
    n_sitz = VT.sitz(netze, volk == 'ork')
    hb = None
    if volk == 'ork':
        netze, alle, hb = _ork_koerper(arm, netze, alle, k, g, hk)
    alle = [o for o in alle if o.name in bpy.data.objects]
    for o in alle:
        mw = o.matrix_world.copy(); o.parent = arm; o.matrix_world = mw
    name = 'held_%s_%s' % (KENNUNG[volk], k)
    print('OHNE BILDER', name, _ohne_bilder(alle, MENSCH_MAT), 'Bildknoten')
    for me in [me for me in bpy.data.meshes if me.users == 0]: bpy.data.meshes.remove(me)   # sonst Leib_UNTERARM.001 (Godot: Name der Daten)
    hk.exportiere(os.path.join(ziel, name + '.glb'), [arm] + alle)
    r = {'groesse_m': round(m2['h'], 3), 'ziel_m': round(h_soll, 3), 'kopf_1_durch': round(1 / m2['kopf'], 2),
         'bein_anteil': round(m2['bein'], 3), 'schulter_m': round(m2['schulter'], 3), 'sitz_ecken': n_sitz,
         'kopf': hk.godot(QT.kopf_pos(arm)), 'dreiecke': hk.dreiecke([o for o in alle if o.type == 'MESH']),
         'netze': sorted(o.name for o in alle if o.type == 'MESH'), 'bilder_von': k}
    if hb: r['haut_bild'] = hb
    print('HELDVOLK', name, json.dumps({x: r[x] for x in ('groesse_m', 'ziel_m', 'kopf_1_durch', 'bein_anteil', 'schulter_m', 'dreiecke')}))
    return r, e, G


def alle_voelker(info, hk, ziel, voelker):
    """Fuer jede gebaute Tracht (info['trachten']) jedes Volk; traegt die Volksmodelle in info['trachten'] ein (wie die Tracht des
    Menschen, dazu 'volk') und G je Volk und Geschlecht in info['voelker']."""
    aus = {}
    menschen = [k for k in list(info['trachten']) if k.count('_') == 1]
    for volk in voelker:
        kv = KENNUNG[volk]
        for g in ('M', 'W'):
            e = None
            for k in [x for x in menschen if x.endswith('_' + g)]:
                try:
                    r, e, G = baue(volk, k, g, e, hk, ziel)
                except Exception as x:   # ein Volk scheitert: der Held dieses Volkes bleibt auf dem Menschenkoerper (heldfigur.gd)
                    import traceback; traceback.print_exc()
                    print('HELDVOLK FEHLER', volk, k, repr(x)); continue
                t = dict(info['trachten'][k]); t.update(r); t['volk'] = kv
                info['trachten']['%s_%s' % (kv, k)] = t
                aus.setdefault(kv, {})[g] = {'G': G, 'einstellung': {a: round(b, 3) for a, b in e.items()}}
    info['voelker'] = aus
    print('HELDVOLK OK', sorted(k for k in info['trachten'] if k.count('_') > 1))
