# 348.7 (Jerry): Goblin aus dem Mensch-Grundmodell (Modellregel 4, Arbeitsteilung 2): v3/held3.py baut Körper, Hände und
# Gelenke (schlank, kahl, Haut der Art), dieses Skript macht daraus den Goblin wie Doll.kt (108 cm, 4,2 Köpfe, Beine 0,42,
# Arme 1,16, Hände und Füße 1,3, Kopf nach Doll.goblinHead/goblinFace, barfuß, Lendentuch), legt die Ausrüstung der drei
# Kits aus MonsterKit.kt an (Wams, Fell, Kappe, Helm; Waffen als eigene .glb, Modellregel 4) und lässt v3/rig.py Skelett,
# Gewichte und Bewegungen machen.
# Aufruf: OUT=<ordner> [ART=goblin|goblin_archer] [KIT=…] python -I goblin.py  ->  <OUT>/<art>-<kit>.glb, <art>-info.json
# (Goblin-Späher: ART=goblin_archer, Kits kapuze|kappe|fell nach LISTE-FIGUREN „Goblin-Späher“, Kurzbogen links)
# (python = Blender als Modul wie im Workflow; held3.py und rig.py laufen je Kit in <OUT>/_goblin-<kit>/ mit eigener leute.json)
import os, sys, json, shutil, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
V3 = os.path.join(HERE, 'v3')
OUT = os.environ.get('OUT', os.path.join(HERE, 'out'))

# Kits wie MonsterKits "goblin" (Saat 0, 4, 8: Kit = Saat mod 3, Haut = Saat / 3 mod 4, Größe MonsterKits.size 0,91–1,09)
KITS = {
    # Krummsäbel, Rundschild, Lederwams, Fell (crude, pelt)
    # Runde 6 (Prüfer Runde 5: Schild-Goblin steht aufrecht; Diogenes: Helm-Goblin 110–115 % statt höchstens 109 %; der zweite
    # grünlicher als die anderen): vor = Rumpf weiter vorgebeugt (Grad), Helm-Goblin kleiner, Haut des zweiten weniger grün
    # Runde 2 (Prüfer Runde 1: heller und gelber als alt, alle drei gleich): dunkler, weniger gelb, deutlicher verschieden
    # Runde 5c (Prüfer 5b: mittleres Oliv, nicht dunkel; der zweite zu grün): alle dunkler, Abstand im Farbton kleiner
    # Runde 5 (Prüfer Runde 4: Farben einheitlicher als alt, das Dunkelgrün des zweiten fehlt; Liste 348.11 b: schlank, mittel,
    # kräftig): Haut im Farbton verschieden wie Doll 0x5E6838/0x4E5C32/0x6C683C, aber dunkler (Leitbild: nie heller als alt)
    'leder': dict(haut=0x363E24, wams=True, fell=True, kopf=None, groesse=1.0, statur='mittel', vor=14, waffen=['scimitar-rost', 'round_shield-grob']),
    # Handbeil, Lederwams, Lederkappe, Fell
    'kappe': dict(haut=0x363A26, wams=True, fell=True, kopf='kappe', groesse=0.95, statur='schlank', vor=8, waffen=['handaxe-rost']),
    # Krummsäbel und Dolch, Helm, nackter Oberkörper
    'helm': dict(haut=0x423E26, wams=False, fell=False, kopf='helm', groesse=1.01, statur='kraeftig', vor=8, arm_l='(78, 55, 20)', waffen=['scimitar-rost', 'dagger-rost']),
}
# 348.7 Goblin-Späher (MonsterKits goblin_archer, Liste „Goblin-Späher“): Körper und Kopf wie der Goblin, drei Kits am Umriss
# verschieden: Lederwams und Kapuze; Lederkappe und Fellumhang; Lederwams und Fellumhang; Kurzbogen in der linken Hand
SPAEHER = {
    'kapuze': dict(haut=0x3A4026, wams=True, fell=False, kopf='kapuze', groesse=0.97, statur='schlank', waffen=['', 'shortbow'], wams_rgb=0x4A3626),
    # Runde 3c (Diogenes 3a, 3b: Gesichtshaut der Mitte 27–39 % satter als alt): stumpfer
    'kappe': dict(haut=0x363A2C, wams=False, fell=True, kopf='kappe', groesse=1.0, statur='mittel', waffen=['', 'shortbow']),
    'fell': dict(haut=0x3E3C26, wams=True, fell=True, kopf=None, groesse=1.04, statur='kraeftig', waffen=['', 'shortbow'], wams_rgb=0x4A3626),
}
# 348.7 Goblin-Schamane (MonsterKits goblin_shaman, Liste „Goblin-Schamane“): Körper und Kopf wie der Goblin, gehörnter
# Tierschädel als Kappe, Gesicht wie ein Totenschädel bemalt (Augenhöhlen rußschwarz, Blutstreifen über die Nase), Knochenkette,
# Augen grün glühend; drei Kits am Umriss verschieden: rußschwarze Robe; Fellumhang; beides. Stab mit Schädel in der rechten Hand
SCHAMANE = {
    # Runde 2 (aufrecht, Tierschädel mit Hörnern bis 127 cm, Liste 98–118): kleiner, mit den Hörnern 108–116 cm
    # Runde 1b (Prüfer 1a: Robe dunkelbraungrau, nicht rußschwarz): schwärzer
    'robe': dict(haut=0x363E24, wams=True, fell=False, robe=True, kopf='schaedel', groesse=0.88, statur='schlank', waffen=['staff-schamane', ''], wams_rgb=0x120E0C),
    'fell': dict(haut=0x323C24, wams=False, fell=True, robe=False, kopf='schaedel', groesse=0.92, statur='mittel', waffen=['staff-schamane', '']),
    'beides': dict(haut=0x423E26, wams=True, fell=True, robe=True, kopf='schaedel', groesse=0.94, statur='kraeftig', waffen=['staff-schamane', ''], wams_rgb=0x120E0C),
}
ART = os.environ.get('ART', 'goblin')
ARTEN = {'goblin': KITS, 'goblin_archer': SPAEHER, 'goblin_shaman': SCHAMANE}
H_GOB = 108.0          # Doll: goblin -> 108 cm
HEADS = 4.2            # Kopflängen wie Doll (Runde 4, Chef 21:12: Kopf 1:1 nach der Vorlage; Runde 2/3 hatten 3,6)
# Gang (rig.py): flink, geduckt, die langen Arme schwingen (FoeArt: „stooped and springing“)
GANG = dict(takt=24, schritt=1.0, knie=1.3, arm=1.3, vor=10)


# Lauer (in rig.py eingesetzt; dort: PB, rot_world, rot_world2, X, Y, Zx). Vorbeugen = +X am Rumpf, Bein und Arm nach vorn = −X,
# Y: + nach rechts (rechts ist x < 0). Der Rumpf neigt 40° (Runde 3, Prüfer Runde 2: „kaum vorgebeugt“), die Arme gleichen das
# aus und heben die Unterarme vor die Brust (freie Hand nicht mehr auf Schritthöhe).
LAUER = '''
def pose_lauer(ph):
    br = math.sin(2 * math.pi * ph)
    for s, sd in (('R', 1), ('L', -1)):
        PB['hip%s-thigh%s' % (s, s)].rotation_quaternion = rot_world2('hip%s-thigh%s' % (s, s), [(X, -(40 + 1.5 * br)), (Y, sd * 9)])
        PB['knee%s-calf%s' % (s, s)].rotation_quaternion = rot_world('knee%s-calf%s' % (s, s), X, 68 + 3 * br)
        for b in ('ankle%s-heel%s' % (s, s), 'ankle%s-ball%s' % (s, s)):
            PB[b].rotation_quaternion = rot_world(b, X, -(28 + 1.5 * br))
        up, el, sp = (75, 85, 14) if s == 'R' else ARM_L
        PB['sh%s-up%s' % (s, s)].rotation_quaternion = rot_world2('sh%s-up%s' % (s, s), [(X, -(up + 2 * br)), (Y, sd * sp)])
        PB['el%s-fo%s' % (s, s)].rotation_quaternion = rot_world('el%s-fo%s' % (s, s), X, -el)
    PB['pelvis-waist'].rotation_quaternion = rot_world('pelvis-waist', X, 28 + VOR + 0.6 * br)
    PB['belly-chest'].rotation_quaternion = rot_world('belly-chest', X, 12 + 1.2 * br)
    PB['chestTop-neck'].rotation_quaternion = rot_world('chestTop-neck', X, -16)
    PB['neck-neckTop'].rotation_quaternion = rot_world2('neck-neckTop', [(X, -20 - 0.8 * br), (Zx, 4 * math.sin(2 * math.pi * ph))])
'''


def treiber():
    py = sys.executable
    KITS = ARTEN[ART]
    os.makedirs(OUT, exist_ok=True)
    kits = [os.environ['KIT']] if os.environ.get('KIT') else list(KITS)
    info = {}
    for kit in kits:
        k = KITS[kit]
        T = os.path.join(OUT, '_%s-%s' % (ART, kit))
        shutil.rmtree(T, ignore_errors=True); os.makedirs(T)
        for f in ('held3.py', 'rig.py'):
            shutil.copy(os.path.join(V3, f), T)
        # Runde 2 (Prüfer Runde 1: „steif aufrecht, Arme hängen“): Stehen als Lauer wie FoeArt (Goblin: lean +0,35, crouch +4,
        # Kopf gehoben), die Waffen vor dem Körper wie HeroFigure.READY; rig.py bleibt Toms, die Kopie im Arbeitsordner bekommt sie
        rp = os.path.join(T, 'rig.py'); src = open(rp).read()
        alt = "bake_action('Stehen', 90, pose_idle)"
        assert src.count(alt) == 1, 'rig.py: Stehen nicht gefunden'
        # Späher: der Bogenarm hängt schräg vor dem Körper, der Unterarm nach vorn (Bogen in Ruhe, Dress.bow: aufrecht, oben zum Gegner)
        # Runde 1b (Prüfer 1a: Bogen ein Strich vor dem Bein): Arm weiter zur Seite, Unterarm höher, der Bogen steht neben dem Bein
        # Runde 1c (Prüfer 1b: Arm angewinkelt an der Hüfte, Bogen weiter über dem Bein): Arm gestreckt schräg nach außen unten
        # Runde 2 (Prüfer 1: Faust im unteren Drittel, Bogen bis auf Fußhöhe): Unterarm angehoben, die Faust auf Hüfthöhe
        # Runde 3 (Sokrates statt Chef, 362; Prüfer 2: der Bogen hängt vor dem Bein): der Arm weiter zur Seite
        # Runde 3b (Prüfer 3a: die Faust 38 cm vor dem Körper, der Bogen vor dem Bein): der Arm hängt seitlich, der Unterarm
        # nur wenig vor, die Faust neben der Hüfte
        arm_l = '(18, 40, 40)' if ART == 'goblin_archer' else k.get('arm_l', '(70, 95, 14)')
        # Runde 6b (Prüfer 6a: der Dolch liegt quer über der Brust, Spitze zur eigenen Schulter): Dolcharm gestreckter vor
        # Runde 6c (Prüfer 6b: (40, 50, 30) hing der Dolch am Bein): Oberarm vor, Unterarm weniger angewinkelt
        arm_r = '(75, 85, 14)'
        if ART == 'goblin_shaman':
            # Schamane: die freie linke Hand zum Gegner vorgestreckt, der Arm fast gestreckt; die rechte hält den Stab seitlich vor
            # dem Körper aufgestellt (Unterarm nach vorn, die Faust neben der Hüfte, der Stab steht neben dem Bein)
            # Runde 1b (Prüfer 1a: freie Hand hängt vor dem Schritt; Faust am Stab „wie Antippen“): Arm über die Waagerechte, Hand
            # auf Brusthöhe zum Gegner; Stabhand höher und näher am Körper
            # Runde 1c (Prüfer 1b: Hand noch auf Bauchhöhe, Faust am Stab auf Hüfthöhe nicht lesbar): Arm schräg nach oben gestreckt,
            # Stabhand auf Brusthöhe
            # Runde 2 (Sokrates statt Chef, 362; Diogenes 1: stark gebückt, alt aufrecht; freie Hand am Körper): aufrecht, Knie nur
            # leicht gebeugt; der Arm hebt die Hand bis in Kopfhöhe (die Winkel zählen am Rumpf, der jetzt kaum noch vorneigt)
            # Runde 2b (Prüfer 2a: die Hand klebt am Kopf und liest sich als Ohr oder Horn): Arm nach vorn zum Gegner gestreckt,
            # die Hand vor dem Kopf
            # Runde 2c (Prüfer 2b: liest sich als verschränkter Arm vor der Brust; nach vorn verkürzt der Arm im Bild): schräg
            # nach vorn oben und zur Seite (über der Waagerechten dreht die Spreizung nach innen, darum negativ), die Hand vor und
            # neben dem Kopf, so steht sie im Umriss
            arm_l, arm_r = '(115, 20, -25)', '(40, 92, 24)'
        lauer = LAUER
        if ART == 'goblin_shaman':
            # Runde 2c (Prüfer 2a, 2b: die Beine stoßen vorn durch die Robe): Knie fast gestreckt
            for a_, b_ in (('-(40 + 1.5 * br)', '-(7 + 1.5 * br)'), ('68 + 3 * br', '12 + 3 * br'), ('-(28 + 1.5 * br)', '-(5 + 1.5 * br)'),
                           ('28 + VOR + 0.6 * br', '6 + VOR + 0.6 * br'), ('12 + 1.2 * br', '4 + 1.2 * br'), ("X, -16)", "X, -4)"),
                           ('-20 - 0.8 * br', '-8 - 0.8 * br')):
                assert lauer.count(a_) == 1, a_; lauer = lauer.replace(a_, b_)
        src = src.replace(alt, lauer.replace('ARM_L', arm_l).replace('(75, 85, 14)', arm_r).replace('VOR', str(k.get('vor', 0))) + "bake_action('Stehen', 90, pose_lauer)")
        # Schamane: Augen glühen grün (Eckfarbe mit Alpha 0, toon.gdshader glut); rig.py setzt die Eckfarben sonst alle auf Weiß
        a3 = "    c = np.ones(len(me.vertices) * 4, np.float32); ca.data.foreach_set('color', c)\n"
        assert src.count(a3) == 1, 'rig.py: Eckfarben geändert'
        a4 = "elif n.startswith(('clasp', 'sun')):"
        assert src.count(a4) == 1, 'rig.py: Gewichte geändert'
        # Schamane: die Kette hängt fest an der Brust. Späher Runde 2 (Prüfer 1: schwarze Fransen schweben an Hand und Hüfte):
        # die Zotten am Saum nahmen das nächste Gelenk, oft den Oberarm, und flogen mit dem Arm mit; jetzt fest an der Brust wie
        # Köcher und Fellkragen
        # Späher Runde 2b (Prüfer 2a: am vorgestreckten Arm ragt ein gestreiftes Gebilde ins Leere): das Fell nahm am Arm den
        # Oberarm und zog sich mit ihm in die Länge; beim Späher hängt es fest an der Brust
        # Schamane Runde 2c (Prüfer 2a, 2b: Striche links am Stab, Fleck an der Hüfte): das Fell nahm den Oberarm und zog sich mit
        # der erhobenen Hand; fest an der Brust wie beim Späher
        fest = "'clasp', 'sun', 'kette', 'fell_zotte', 'koecher', 'fellkragen'" + (", 'fell'" if ART in ('goblin_archer', 'goblin_shaman') else '')
        src = src.replace(a4, "elif n.startswith((%s)):" % fest)
        if ART in ('goblin_archer', 'goblin_shaman'):
            # Späher Runde 3b, Schamane Runde 2b (Prüfer: an der freien Hand ragt ein schwarz gestreifter Kamm ins Leere, an der
            # Stabhand Striche über den Stab, an der Hüfte ein losgelöster Fleck): in der Ruhelage hängen die Unterarme neben der
            # Hüfte, Lendentuch, Gürtel, Robe und Wams nahmen dort Unterarm-Gewichte und zogen sich mit der Hand in die Länge;
            # sie folgen jetzt nur Rumpf und Beinen (das Wams am Oberarm weiter dem Oberarm)
            a7 = "    D = np.stack([seg_dist(V, *b.split('-')) for b in BONES], 1)\n    b0 = np.argmin(D, 1)\n"
            assert src.count(a7) == 1, 'rig.py: Gewichte geändert'
            src = src.replace(a7, "    D = np.stack([seg_dist(V, *b.split('-')) for b in BONES], 1)\n"
                              "    if o.name.startswith(('loin', 'belt', 'robe', 'tabard', 'chain')):\n"
                              "        D[:, [i_ for i_, b_ in enumerate(BONES) if b_.startswith(('el', 'fo') if o.name.startswith('chain') else ('up', 'el', 'fo'))]] = 1e9\n"
                              "    b0 = np.argmin(D, 1)\n")
        if ART == 'goblin_shaman':
            # Runde 1c (Prüfer 1a, 1b: Robe „steht als eckige Pappplatte ab“): in der Lauer folgte sie zu 60 % den vorgestreckten
            # Oberschenkeln; jetzt hängt sie mehr
            # Runde 2 (Prüfer, Diogenes 1: Robe vorn offen, eckige Stufe): aufrecht hängt sie fast frei
            a5 = "'robe': 0.6,"
            assert src.count(a5) == 1, 'rig.py: CLOTH geändert'
            # Runde 2b (Prüfer 2a: die Beine stoßen vorn durch die Robe): wieder etwas mehr mit den Oberschenkeln
            src = src.replace(a5, "'robe': 0.4,")
        if ART == 'goblin_shaman':
            src = src.replace(a3, a3 + "    if o.name.startswith('eye'):\n"
                              "        g_ = [0.10, 0.75, 0.04, 0.0] if o.name.startswith('eye_pupille') else [0.04, 0.5, 0.02, 0.0]\n"
                              "        ca.data.foreach_set('color', np.tile(np.array(g_, np.float32), len(me.vertices)))\n")
        # Bild 1 jeder späteren Bewegung trug die Haltung von Gehen (ground() wertet die Spur Gehen aus, solange die neue Bewegung
        # noch keinen Schlüssel hat; in Godot: Stehen zuckt alle 3 s); beim Backen die fertigen Spuren stumm, danach wieder an
        a2 = "    rig.animation_data_create(); rig.animation_data.action = act\n"
        b2 = "    tr = rig.animation_data.nla_tracks.new(); tr.name = name; tr.strips.new(name, 1, act)\n"
        assert src.count(a2) == 1 and src.count(b2) == 1, 'rig.py: bake_action geändert'
        src = src.replace(a2, a2 + "    for t_ in rig.animation_data.nla_tracks: t_.mute = True\n")
        src = src.replace(b2, "    for t_ in rig.animation_data.nla_tracks: t_.mute = False\n" + b2)
        open(rp, 'w').write(src)
        if ART in ('goblin_shaman', 'goblin_archer'):
            # Runde 2 (Prüfer 1: keine gekrümmten Finger, keine Faust um den Stab): rechts (Stab) eine Faust, links eine Kralle
            # Späher Runde 3 (Sokrates statt Chef, 362; Prüfer 2: an der freien Hand ragt ein gestreiftes Gebilde ins Leere, die
            # gespreizten Finger): beide Hände als Faust, die linke um den Bogen
            # Runde 3c (Diogenes 3b: an der erhobenen Faust ein stachliger Rand): Finger enger eingerollt
            cu = "{1: (55, 70, 55), -1: (30, 42, 38)}" if ART == 'goblin_shaman' else "{1: (74, 90, 72), -1: (62, 78, 60)}"
            hp = os.path.join(T, 'held3.py'); h3 = open(hp).read()
            a6 = "((L * 0.46, 10), (L * 0.30, 20), (L * 0.24, 16))"
            assert h3.count(a6) == 1, 'held3.py: Finger geändert'
            h3 = h3.replace(a6, "((L * 0.46, CU[sg][0]), (L * 0.30, CU[sg][1]), (L * 0.24, CU[sg][2]))")
            h3 = h3.replace("def hand(wrist, fore, sg):", "CU = " + cu + "\ndef hand(wrist, fore, sg):", 1)
            open(hp, 'w').write(h3)
        fig = ART + '_' + kit
        # held3.py: Abweichung vom Helden (Felder wie leute.json); Kleidung entfernt nachher dieses Skript
        json.dump({fig: dict(sex='m', statur=k['statur'], haut='%06X' % k['haut'], haar='24201C', kopf='glatze', hemd='kittel',
                             rock='robe' if k.get('robe') else 'keiner', tabard='6A4A32', sleeve='4E4232', pants='4E4232', groesse=1.0, beine=0.82,
                             gebeugt=4 if ART == 'goblin_shaman' else 16, gang=GANG)},
                  open(os.path.join(T, 'leute.json'), 'w'))
        env = dict(os.environ, OUT=T, FIGUR=fig, GOBLIN=kit, ATLAS='1024')   # Modellregel 6: höchstens 1024 px
        for step in ([os.path.join(T, 'held3.py')], [os.path.abspath(__file__), '--nach'], [os.path.join(T, 'rig.py')]):
            r = subprocess.run([py, '-I'] + step, env=env, capture_output=True, text=True)
            log = r.stdout + r.stderr
            open(os.path.join(T, os.path.basename(step[0]) + '.log'), 'w').write(log)
            if r.returncode != 0 or ('rig.py' in step[0] and 'GLB OK' not in log):
                print(log[-4000:]); sys.exit('%s %s: %s fehlgeschlagen' % (ART, kit, os.path.basename(step[0])))
            for line in log.splitlines():
                if line.startswith(('GOBLIN', 'DREIECKE', 'NETZ', 'ANIM', 'GLB')): print(kit, line)
        shutil.copy(os.path.join(T, 'held.glb'), os.path.join(OUT, '%s-%s.glb' % (ART, kit)))
        hi = json.load(open(os.path.join(T, 'held-info.json')))
        gi = json.load(open(os.path.join(T, 'goblin-masse.json')))
        info[kit] = dict(hi, **gi, waffen=k['waffen'])
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ART), 'w'), indent=1)
    print('GOBLIN FERTIG', ART, list(info))


# ---------------------------------------------------------------- Nachbearbeitung in Blender (aus dem Treiber mit --nach)
def nach():
    import bpy, bmesh, math
    import numpy as np
    from mathutils import Vector, Matrix
    from mathutils import noise
    T = os.environ['OUT']; kit = os.environ['GOBLIN']; K = ARTEN[ART][kit]
    bpy.ops.wm.open_mainfile(filepath=T + '/held3.blend')
    G = json.load(open(T + '/gelenke.json'))
    J = {k: [Vector(v[0]), list(v[1])] for k, v in G['J'].items()}
    E = [tuple(e) for e in G['E']]
    scn = bpy.context.scene
    root = next(o for o in bpy.data.objects if o.type == 'EMPTY')
    meshes = lambda: [o for o in bpy.data.objects if o.type == 'MESH']

    def hx(c): return ((c >> 16) & 255, (c >> 8) & 255, c & 255)
    def lin(c, k=1.0):
        def f(v):
            v = min(1.0, v / 255.0 * k)
            return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
        r, g, b = hx(c); return (f(r), f(g), f(b), 1.0)
    def mixh(a, b, t):
        A, B = hx(a), hx(b); r = [int(round(A[i] + (B[i] - A[i]) * t)) for i in range(3)]
        return (r[0] << 16) | (r[1] << 8) | r[2]

    # ---- Material wie held3.make_mat, soweit rig.py es braucht: Emission „M_albedo“ an „M_out“ (gebacken), Körnung, Flecken
    def mat(name, rgb, grain=0.15, blot=0.3, ink=False, scar=None, streak=None, rust=None, glanz=None, kalk=None):
        m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
        out = nt.nodes.new('ShaderNodeOutputMaterial'); out.name = 'M_out'
        em = nt.nodes.new('ShaderNodeEmission'); em.name = 'M_albedo'
        def noise_(scale, src='Object', detail=3.0):
            n = nt.nodes.new('ShaderNodeTexNoise')
            n.inputs['Scale'].default_value = scale; n.inputs['Detail'].default_value = detail
            if src == 'World':
                g = nt.nodes.new('ShaderNodeNewGeometry'); nt.links.new(g.outputs['Position'], n.inputs['Vector'])
            else:
                tc = nt.nodes.new('ShaderNodeTexCoord'); nt.links.new(tc.outputs[src], n.inputs['Vector'])
            return n.outputs['Fac']
        def mul_col(col, fac_socket, lo, hi):
            mr = nt.nodes.new('ShaderNodeMapRange'); mr.inputs['To Min'].default_value = lo; mr.inputs['To Max'].default_value = hi
            nt.links.new(fac_socket, mr.inputs['Value'])
            vm = nt.nodes.new('ShaderNodeVectorMath'); vm.operation = 'SCALE'
            nt.links.new(col, vm.inputs[0]); nt.links.new(mr.outputs[0], vm.inputs['Scale']); return vm.outputs[0]
        c = nt.nodes.new('ShaderNodeRGB'); c.outputs[0].default_value = lin(rgb); col = c.outputs[0]
        if grain: col = mul_col(col, noise_(0.55, detail=4.0), 1 - 0.8 * grain, 1 + 0.8 * grain)
        if blot: col = mul_col(col, noise_(0.06, 'World', 2.0), 1 - 0.5 * blot, 1 + 0.5 * blot)
        if streak:   # Fell: Strähnen längs (hell und dunkel wie Dress.furMantle)
            tc = nt.nodes.new('ShaderNodeTexCoord'); w = nt.nodes.new('ShaderNodeTexWave'); w.wave_type = 'BANDS'
            w.bands_direction = 'Z'; w.inputs['Scale'].default_value = streak; w.inputs['Distortion'].default_value = 8.0
            w.inputs['Detail'].default_value = 4.0; nt.links.new(tc.outputs['Object'], w.inputs['Vector'])
            col = mul_col(col, w.outputs['Fac'], 0.7, 1.45)
        rgba_ = lambda socks, n: next(x for x in socks if x.name == n and x.type == 'RGBA')
        if rust:   # Runde 6 (Helm): Rostflecken (Farbe, Anteil) in einer zweiten Farbe, harte Ränder wie abgeplatzt
            mr = nt.nodes.new('ShaderNodeMapRange'); mr.inputs['From Min'].default_value = 0.62 - 0.2 * rust[1]
            mr.inputs['From Max'].default_value = 0.68 - 0.2 * rust[1]
            nt.links.new(noise_(0.6, 'World', 5.0), mr.inputs['Value'])
            mx = nt.nodes.new('ShaderNodeMix'); mx.data_type = 'RGBA'
            nt.links.new(mr.outputs[0], mx.inputs['Factor']); nt.links.new(col, rgba_(mx.inputs, 'A'))
            rgba_(mx.inputs, 'B').default_value = lin(rust[0]); col = rgba_(mx.outputs, 'Result')
        if glanz:   # Runde 6 (Helm „wie eine Mütze“): Glanz oben, wo die Sonne steht (Normale nach oben), als helle Kappe gebacken
            g = nt.nodes.new('ShaderNodeNewGeometry'); sp = nt.nodes.new('ShaderNodeSeparateXYZ')
            nt.links.new(g.outputs['Normal'], sp.inputs[0])
            mr = nt.nodes.new('ShaderNodeMapRange'); mr.inputs['From Min'].default_value = 0.55; mr.inputs['From Max'].default_value = 0.9
            mr.inputs['To Max'].default_value = 0.45; nt.links.new(sp.outputs['Z'], mr.inputs['Value'])
            mx = nt.nodes.new('ShaderNodeMix'); mx.data_type = 'RGBA'
            nt.links.new(mr.outputs[0], mx.inputs['Factor']); nt.links.new(col, rgba_(mx.inputs, 'A'))
            rgba_(mx.inputs, 'B').default_value = lin(glanz); col = rgba_(mx.outputs, 'Result')
        if kalk:   # Schamane: Gesicht mit Asche und Kalk bemalt (Attribut „kalk“), unter dem Blut
            a = nt.nodes.new('ShaderNodeAttribute'); a.attribute_name = 'kalk'
            mx = nt.nodes.new('ShaderNodeMix'); mx.data_type = 'RGBA'
            rgba = lambda socks, n: next(x for x in socks if x.name == n and x.type == 'RGBA')
            nt.links.new(a.outputs['Fac'], mx.inputs['Factor']); nt.links.new(col, rgba(mx.inputs, 'A'))
            rgba(mx.inputs, 'B').default_value = lin(kalk); col = rgba(mx.outputs, 'Result')
        if scar:   # Narbe (Attribut „narbe“): blasser
            a = nt.nodes.new('ShaderNodeAttribute'); a.attribute_name = 'narbe'
            mx = nt.nodes.new('ShaderNodeMix'); mx.data_type = 'RGBA'
            rgba = lambda socks, n: next(x for x in socks if x.name == n and x.type == 'RGBA')
            nt.links.new(a.outputs['Fac'], mx.inputs['Factor']); nt.links.new(col, rgba(mx.inputs, 'A'))
            rgba(mx.inputs, 'B').default_value = lin(scar); col = rgba(mx.outputs, 'Result')
        nt.links.new(col, em.inputs['Color'])
        if ink:   # rig.py dunkelt mit dem Attribut „ink“ ab (Mundlinie, Augenhöhle)
            a = nt.nodes.new('ShaderNodeAttribute'); a.attribute_name = 'ink'
        nt.links.new(em.outputs[0], out.inputs['Surface'])
        return m

    SKIN = K['haut']
    M = {
        'haut': bpy.data.materials['skin'],
        # Schamane: statt der Narbe ein Streifen altes Blut von der Stirn über die Nase (Doll.shamanPaint 0x5A1410)
        # Schamane Runde 2 (Prüfer, Diogenes 1: Gesicht grün, nicht als Totenschädel bemalt): Kalk und Asche, gedämpft (nie heller als alt)
        'gesicht': mat('gface', SKIN, grain=0.14, blot=0.35, ink=True, scar=0x5A1410 if ART == 'goblin_shaman' else mixh(SKIN, 0x8A7060, 0.5),
                       kalk=mixh(SKIN, 0x9A9282, 0.6) if ART == 'goblin_shaman' else None),   # Runde 6 (Diogenes r5: Narbe unsichtbar): blasser
        # Schamane: Augen brennen grün (Dress.glowColour 0x9CE85A, shamanPaint 0x9CF050, Kern 0xF0FFD0)
        'auge': mat('geye', 0x7CD040 if ART == 'goblin_shaman' else 0xE8B828, grain=0, blot=0),
        'pupille': mat('gpupil', 0xD8FFA8 if ART == 'goblin_shaman' else 0x1A0C04, grain=0, blot=0),
        'zahn': mat('gzahn', 0xA89450, grain=0.25, blot=0.3),    # Runde 4: „Zähne weiß“, gelber wie Doll 0x9A8A58/0xC8B880
        'haar': mat('ghaar', 0x24201C, grain=0.22, blot=0.2),
        'lappen': mat('glappen', 0x4E4232, grain=0.25, blot=0.5),
        'fell': mat('gfell', 0x2E2620, grain=0.7, blot=0.3, streak=0.9),
        'leder': mat('gleder', 0x6A4A32, grain=0.07, blot=0.6),
        # Runde 2 (Prüfer Runde 1: Kappe hautfarben, Helm wie Stoff): Kappe dunkles Leder, Helm Eisengrau mit Rostflecken
        'kappe': mat('gkappe', 0x3E2A1C, grain=0.1, blot=0.5),
        # Runde 5 (Prüfer Runde 4: Helm grau statt braun wie alt): altes Eisen braun und fleckig wie Dress.metal rusty 0x6A5444
        # Runde 5b (Prüfer 5a: braunrosa, nicht mehr Metall, gleicht der Kappe): dunkles Eisen mit braunen Rostflecken
        # Runde 5c (Prüfer 5b: Rand rosa wie ein Pilzsaum): Rand dunkles Rostbraun
        # Runde 6 (Prüfer Runde 5: Helm mittelgrau wie eine Mütze, Rand wie eine Naht): dunkleres Eisen mit Glanz oben und
        # abgeplatzten Rostflecken, Rand und Nieten in Rost
        # Runde 6b (Prüfer 6a: Helm fast weiß, der hellste Fleck): Glanz schwächer, Eisen dunkler
        # Runde 6c (Prüfer 6b: Rostflecken „wie Tarnmuster“): weniger und kleiner
        'rost': mat('grost', 0x201E1C, grain=0.35, blot=0.8, rust=(0x4A3020, 0.2), glanz=0x4A4640),
        'rostrand': mat('grostrand', 0x4A2E1C, grain=0.5, blot=0.9, rust=(0x2A2420, 0.4)),
    }
    # Wams: der Kittel aus held3 (Material „tabard“) wird Leder, roh
    # Späher Runde 1c (Prüfer 1b: Schultern rosa-beige, heller als alt): Wams dunkler
    for nm, rgb in (('tabard', K.get('wams_rgb', 0x6A4A32)),):
        if nm in bpy.data.materials:
            for n in bpy.data.materials[nm].node_tree.nodes:
                if n.type == 'RGB': n.outputs[0].default_value = lin(rgb)

    def world_apply(objs, fn):
        """fn(Nx3 Weltpunkte) -> Nx3; auf die Ecken der Objekte anwenden (wie held3.deform)."""
        bpy.context.view_layer.update()
        for o in objs:
            mw = np.array(o.matrix_world); me = o.data
            co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co); co = co.reshape(-1, 3)
            W = co @ mw[:3, :3].T + mw[:3, 3]; W = fn(W)
            co = (W - mw[:3, 3]) @ np.linalg.inv(mw[:3, :3]).T
            me.vertices.foreach_set('co', co.ravel()); me.update()

    def seg_dist(V, a, b):
        A, ra = np.array(J[a][0]), J[a][1][0]; B, rb = np.array(J[b][0]), J[b][1][0]
        ab = B - A; t = np.clip(((V - A) @ ab) / max(ab @ ab, 1e-9), 0, 1)
        return np.linalg.norm(V - (A + t[:, None] * ab), axis=1) - (ra + (rb - ra) * t)

    # ---- 1. Menschliches weg: Kopf, Augen, Lider, Ohren, Haar, Ärmel, Hose, Stiefel, Gürtel (der Goblin geht barfuß, halb nackt)
    for o in list(meshes()):
        if o.name.startswith(('head', 'eye', 'lid', 'ear', 'hair', 'helm', 'nasal', 'beard', 'sleeves', 'pants', 'boots', 'cuff', 'buckle')):
            # Schamane Runde 2 (Diogenes 1: alt reicht die Robe bis zu den Füßen, mit Gürtel und Schnalle): Schnalle bleibt
            if o.name.startswith('buckle') and K.get('robe'):
                # Runde 2c (Prüfer 2a, 2b: blauweiße Schnalle, eine fremde Farbe): Knochen statt Metall
                o.data.materials.clear(); o.data.materials.append(mat('gschnalle', 0x6A6252, grain=0.4, blot=0.6)); continue
            bpy.data.objects.remove(o)
    if not K['wams'] and 'chain' in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects['chain'])
    body = bpy.data.objects['body']
    for p in body.data.polygons: p.material_index = 0       # Haut überall (held3: unter der Kleidung dunkles Tuch)

    # ---- 2. Maße wie Doll (goblin): Arme 1,16, Hände 1,3, Füße 1,3; Ziel in Zentimetern, am Ende auf H_GOB skaliert
    ARM = 1.16
    # Runde 6 (Prüfer Runde 5: Hände und Füße nicht groß): 1,5 statt 1,3 wie Doll
    HAND = FUSS = 1.75   # Runde 6b (Prüfer 6a: mit 1,5 noch gleich): 1,75
    for s in 'RL':
        sh = J['sh' + s][0].copy()
        arm_bones = [('sh' + s, 'up' + s), ('up' + s, 'el' + s), ('el' + s, 'fo' + s), ('fo' + s, 'wr' + s)]
        all_b = [(a, b) for a, b in E if a != 'chestTop' or b in ('shR', 'shL')]
        def arm_fn(V, sh=sh, arm_bones=arm_bones, all_b=all_b):
            D = np.stack([seg_dist(V, a, b) for a, b in all_b], 1)
            near = np.argmin(D, 1)
            isarm = np.isin(near, [all_b.index(b) for b in arm_bones])
            # weich ab der Schulter: unter der Schulter wächst der Abstand nach unten um ARM
            dz = np.clip(sh.z - V[:, 2], 0, None)
            V = V.copy(); V[isarm, 2] = V[isarm, 2] - dz[isarm] * (ARM - 1)
            return V
        objs = [o for o in meshes() if o.name in ('body', 'chain')]
        world_apply(objs, arm_fn)
        wr_old = J['wr' + s][0].copy()
        for k_ in ('up', 'el', 'fo', 'wr'):
            p = J[k_ + s][0]; J[k_ + s][0] = Vector((p.x, p.y, p.z - max(0.0, sh.z - p.z) * (ARM - 1)))
        d = J['wr' + s][0] - wr_old
        hand = bpy.data.objects['hand' + s]
        HK = HAND / 1.15                                    # held3 macht Leute-Hände 1,15
        w_ = J['wr' + s][0]
        world_apply([hand], lambda V, d=d, w_=w_: (V + np.array(d) - np.array(w_)) * HK + np.array(w_))
        # Füße: länger und breiter um 1,3 (um das Fußgelenk), Zehen mit
        an = J['ankle' + s][0].copy()
        foot_b = [('ankle' + s, 'heel' + s), ('ankle' + s, 'ball' + s), ('ball' + s, 'toe' + s)]
        def foot_fn(V, an=an, foot_b=foot_b):
            D = np.stack([seg_dist(V, a, b) for a, b in E], 1); near = np.argmin(D, 1)
            isf = np.isin(near, [E.index(b) for b in foot_b]) & (V[:, 2] < an.z + 3)
            V = V.copy(); A = np.array(an)
            V[isf, :2] = A[:2] + (V[isf, :2] - A[:2]) * FUSS
            return V
        world_apply([body], foot_fn)
        for k_ in ('heel', 'ball', 'toe'):
            p = J[k_ + s][0]; J[k_ + s][0] = Vector((an.x + (p.x - an.x) * FUSS, an.y + (p.y - an.y) * FUSS, p.z))

    # ---- 3. Maßstab: Schulter des Goblins bei 0,734 der Größe (Doll: chinY − 0,033 H), Kopf 1/4,2 der Größe
    Hg = H_GOB * K['groesse']
    sh_z = J['shR'][0].z
    F = 0.734 * Hg / sh_z                    # Zentimeter je Einheit jetzt → Goblin
    k = Hg / HEADS / F                       # Kopflänge in heutigen Einheiten
    nt_ = J['neckTop'][0]
    C = Vector((nt_.x, nt_.y - 0.1 * k, nt_.z + 0.40 * k))     # Kopfmitte (Doll headC), etwas vor dem Hals
    def D(x, y, z):   # Doll-Kopfraum (rechts, hoch, vorn) in Vielfachen von k -> Blender (der Goblin blickt nach −Y)
        return C + Vector((-x * k, -z * k, y * k))

    # ---- 4. Kopf nach Doll.goblinHead: breiter flacher Schädel, vorgeschobener Kiefer, tiefe Braue, lange Hakennase
    parts = []
    def ell(c, r):
        bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=4, radius=1.0)
        for v in bm.verts: v.co = D(c[0] + v.co.x * r[0], c[1] + v.co.z * r[1], c[2] - v.co.y * r[2])
        me = bpy.data.meshes.new('gk'); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new('gk', me); scn.collection.objects.link(o); parts.append(o)
    def cone(a, b, ra, rb, n=8):
        for i in range(n + 1):
            t = i / n; c = [a[j] + (b[j] - a[j]) * t for j in range(3)]; r = ra + (rb - ra) * t
            ell(c, (r, r, r))
    # Runde 5 (Chef 23:33: kein Klon der Vorlage, düster und erwachsen; Prüfer Runde 4: hohe glatte Kuppel „wie Dobbi“, kein
    # Brauenwulst, Kiefer schmal ohne Unterbiss): Schädel flach und nach vorn geschoben, schwerer Wulst, breiter Unterkiefer vor
    ell((0.0, 0.02, 0.0), (0.4, 0.3, 0.42))            # Schädel flach, hinten tief
    ell((0.0, -0.18, 0.12), (0.38, 0.24, 0.32))        # Wangen und breiter Kiefer
    ell((0.0, -0.32, 0.26), (0.32, 0.13, 0.22))        # Unterkiefer vor dem Oberkiefer (Unterbiss)
    ell((0.0, 0.09, 0.34), (0.36, 0.09, 0.14))         # Brauenwulst, steht über den Augen vor
    # Runde 4 (Chef 21:12, Vorlage Doll.goblinHead 1:1; Runde 2/3 lasen sich als Rüssel): lange Nase, an der Spitze nach unten
    # Runde 5 (Prüfer Runde 4: Nase ohne Haken): Rücken gerade vor, dann deutlich nach unten zum Haken über der Lippe
    cone((0.0, 0.04, 0.42), (0.0, -0.1, 0.68), 0.085, 0.06)
    cone((0.0, -0.1, 0.68), (0.0, -0.17, 0.7), 0.06, 0.05, n=4)
    cone((0.0, -0.17, 0.7), (0.0, -0.25, 0.6), 0.05, 0.025)
    bpy.ops.object.select_all(action='DESELECT')
    for o in parts: o.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]; bpy.ops.object.join()
    head = bpy.context.active_object; head.name = 'head'
    rm = head.modifiers.new('vox', 'REMESH'); rm.mode = 'VOXEL'; rm.voxel_size = 0.012 * k
    # Runde 4 (Prüfer: kein Brauenwulst, Nase ohne Absatz ins Kinn, Kiefer spitz): weniger glätten, sonst verschwimmen die Teile
    sm = head.modifiers.new('glatt', 'SMOOTH'); sm.factor = 0.5; sm.iterations = 2
    bpy.ops.object.modifier_apply(modifier='vox'); bpy.ops.object.modifier_apply(modifier='glatt')
    # Haut: Runzeln und Warzen (Höhe entlang der Normale), Mund als Kerbe
    hv = head.data
    bm = bmesh.new(); bm.from_mesh(hv); bm.normal_update()
    inv = lambda p: ((-(p.x - C.x)) / k, (p.z - C.z) / k, (-(p.y - C.y)) / k)     # Blender -> Doll-Kopfraum
    INK = []; SCAR = []; KALK = []
    for v in bm.verts:
        x, y, z = inv(v.co)
        front = max(0.0, min(1.0, (z - 0.15) / 0.12))
        # Runzeln quer über die Stirn, Warzen
        wr = 0.006 * math.sin(y * 60.0) * max(0.0, min(1.0, (y - 0.12) / 0.05)) * front
        wart = 0.012 * max(0.0, noise.noise(v.co * (6.0 / k)) - 0.45) * 4.0
        # Mund: breite grimmige Kerbe (Doll goblinFace: Linie bei y −0,28, Breite ±0,2)
        # Runde 6 (Sokrates 00:5x: Maul als Fratze, die in Spielgröße liest; Prüfer Runde 5: gefletschtes Maul nicht lesbar):
        # offen und breiter, die Winkel tief nach unten gezogen, tiefer eingekerbt; darin zwei Reihen Zähne
        # Runde 6b (Prüfer 6a: in Spielgröße ein Fleck von 3–5 Bildpunkten): noch breiter und höher
        yc = -0.285 - 0.08 * (x / 0.26) ** 2
        mouth = math.exp(-((y - yc) / 0.05) ** 4) * max(0.0, 1 - (abs(x) / 0.28) ** 4) * front
        v.co = v.co + v.normal * (k * (wr + wart - 0.06 * mouth))
        # Tusche: Mundlinie, Schatten der tiefen Augenhöhlen unter der Braue
        sock = sum(math.exp(-(((x - sd * 0.17) / 0.1) ** 2 + ((y - 0.01) / 0.06) ** 2)) for sd in (-1, 1)) * front
        if ART == 'goblin_shaman':
            # Totenschädel (Doll.shamanPaint): Augenhöhlen rußschwarz, weit und am Rand zerfranst, ein Lauf über die Wange hinab;
            # der Blutstreifen von der Braue über den Nasenrücken
            for sd in (-1, 1):
                rag = 1.0 + 0.2 * math.sin(x * 40.0 + y * 23.0 + sd)
                # Runde 1b (Prüfer 1a: Gesicht unbemalt): größer und satt schwarz
                sock = max(sock, min(1.0, math.exp(-(((x - sd * 0.16) / 0.15) ** 2 + ((y + 0.01) / 0.11) ** 2) * rag ** -2) * 2.2))
                sock = max(sock, math.exp(-((x - sd * 0.19) / 0.028) ** 2) * max(0.0, min(1.0, (y + 0.24) / 0.05)) * (1 if y < 0 else 0) * 1.2)
            sock *= front
            # Runde 1b (Prüfer 1a: „wie eine herausgestreckte Zunge“): nur von der Stirn bis zum Nasenrücken, nicht über die Hakenspitze
            blood = math.exp(-(x / 0.035) ** 2) * max(0.0, min(1.0, (0.24 - y) / 0.03)) * max(0.0, min(1.0, (y + 0.02) / 0.03)) * front
            # Runde 2: das Gesicht von der Stirn bis unters Kinn hell bemalt, am Rand zerfranst; über dem Mund senkrechte Striche
            # wie Zähne eines Totenschädels
            rag2 = 1.0 + 0.12 * math.sin(x * 31.0 + y * 17.0)
            KALK.append(front * max(0.0, min(1.0, (1.0 - ((x / 0.3) ** 2 + ((y + 0.06) / 0.36) ** 2) * rag2 ** -2) * 4.0)))
            teeth = math.exp(-((y - yc) / 0.07) ** 2) * (1.0 if math.sin(x * 62.0) > 0.55 else 0.0) * max(0.0, 1 - (abs(x) / 0.22) ** 2) * front
            mouth = max(mouth, 0.8 * teeth)
        INK.append(min(1.0, 1.2 * mouth + (1.0 if ART == 'goblin_shaman' else 0.8) * sock))   # Runde 5: Augen im Schatten der Braue (Prüfer Runde 4)
        if ART == 'goblin_shaman':
            SCAR.append(min(1.0, 1.4 * blood)); continue
        # alte Narbe schräg über das linke Auge (Doll: von (−0,2; 0,16) nach (−0,1; −0,12))
        ax, ay, bx, by = -0.2, 0.16, -0.1, -0.12
        t = max(0.0, min(1.0, ((x - ax) * (bx - ax) + (y - ay) * (by - ay)) / ((bx - ax) ** 2 + (by - ay) ** 2)))
        dd = math.hypot(x - (ax + t * (bx - ax)), y - (ay + t * (by - ay)))
        SCAR.append(math.exp(-(dd / 0.018) ** 2) * front)
    bm.to_mesh(hv); bm.free()
    for nm, vals in (('ink', INK), ('narbe', SCAR)) + ((('kalk', KALK),) if KALK else ()):
        a = hv.attributes.new(nm, 'FLOAT', 'POINT'); a.data.foreach_set('value', vals)
    hv.materials.append(M['gesicht'])
    for p in hv.polygons: p.use_smooth = True
    head.parent = root; head.matrix_parent_inverse = root.matrix_world.inverted()

    def mesh_from(name, verts, faces, m, parent=True):
        me = bpy.data.meshes.new(name); me.from_pydata([tuple(v) for v in verts], [], faces); me.update()
        o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
        for p in me.polygons: p.use_smooth = True
        if parent: o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        return o

    # Ohren: weit zur Seite und nach oben hinten zur Spitze (Doll), flach wie ein Blatt, zum Gesicht hin gewölbt
    # (rund wie bei Doll lasen sie sich in 3D als Hörner: Ratte, Prüfer Runde 6)
    # Runde 2 (Prüfer Runde 1: „dünn wie Hörner mit dunklen Spitzen“): breite Lappen wie ein Blatt, fast waagerecht, die Spitze
    # hängt etwas, stumpf statt nadelspitz (die Tusche machte die dünne Spitze schwarz), Kerben oben und unten
    # Runde 4 (Chef 21:12, Vorlage 1:1; Runde 2/3 hängend „wie Dobbi“): Mittellinie und Breite wie Doll, seitlich hoch und
    # spitz nach hinten: Ansatz (0,36; −0,02; −0,04), Knick (0,62; 0,12; −0,12), Spitze (0,98; 0,32; −0,22), halbe Breite 0,12 → 0,07 → 0,012
    for sd in (-1, 1):
        # Runde 5 (Prüfer Runde 4: stabdünn, ohne Blattfläche, hinteres wie ein Fühler; Diogenes: waagerecht): breites Blatt,
        # steiler hoch und weiter nach hinten
        # Runde 5b (Prüfer 5a: „wie Hörner oder Fühler“, steil nach oben): flacher zur Seite, Spitze nach hinten
        # Runde 6 (Prüfer Runde 5: das ferne Ohr steht steil, beide wie Fühler): fast waagerecht zur Seite, Spitze kaum höher
        # Runde 6b (Prüfer 6a: das ferne Ohr steht in der Aufsicht weiter steil): die Spitze hängt etwas
        P0, P1, P2 = (0.36, -0.04, -0.06), (0.66, -0.01, -0.2), (1.0, -0.04, -0.34)
        n_u, n_v = 14, 7
        V_ = []; F_ = []
        for i in range(n_u + 1):
            t = i / n_u
            if t <= 0.42:
                u = t / 0.42; A_, B_, ra, rb = P0, P1, 0.17, 0.13
            else:
                u = (t - 0.42) / 0.58; A_, B_, ra, rb = P1, P2, 0.13, 0.015
            cx = sd * (A_[0] + (B_[0] - A_[0]) * u); cy = A_[1] + (B_[1] - A_[1]) * u; cz = A_[2] + (B_[2] - A_[2]) * u
            w = ra + (rb - ra) * u
            for j in range(n_v + 1):
                s_ = j / n_v * 2 - 1                       # über die Breite: unten (−1) bis oben (+1)
                cup = 0.04 * (1 - s_ * s_) * (1 - 0.7 * t)   # Mulde zur Vorderseite
                nick = 0.02 * (1 if (i == 9 and s_ < -0.6) else 0)   # eine Kerbe unten
                V_.append(D(cx, cy + s_ * w * 0.85 + nick, cz + s_ * w * 0.35 + cup))
        for i in range(n_u):
            for j in range(n_v):
                a = i * (n_v + 1) + j; F_.append((a, a + 1, a + n_v + 2, a + n_v + 1) if sd > 0 else (a, a + n_v + 1, a + n_v + 2, a + 1))
        e = mesh_from('ear', V_, F_, M['haut'])
        so = e.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.05 * k; so.offset = 0
        sb = e.modifiers.new('sb', 'SUBSURF'); sb.levels = 1
        bpy.context.view_layer.objects.active = e
        for md in list(e.modifiers): bpy.ops.object.modifier_apply(modifier=md.name)
    # zwei untere Hauer über der Oberlippe, eine Reihe schiefer gelber Zähne im Mundspalt
    def tooth(a, b, ra, rb, name='head_zahn'):
        bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=ra * k, radius2=rb * k, depth=1.0)
        A, B = D(*a), D(*b); d = B - A
        q = d.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
        M4 = Matrix.Translation((A + B) / 2) @ q @ Matrix.Diagonal((1, 1, d.length, 1))
        for v in bm.verts: v.co = M4 @ v.co
        me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(M['zahn'])
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
    for sd in (-1, 1):
        # Doll: zwei untere Hauer über der Oberlippe; dort (z 0,33–0,37) lägen sie im 3D-Kiefer, darum vor die Lippe gesetzt
        # Runde 5 (Prüfer Runde 4: nur einer sichtbar und zu klein): zwei kräftige Hauer aus dem vorgeschobenen Unterkiefer,
        # leicht nach außen, über die Oberlippe bis neben die Nase
        # Runde 5b (Prüfer 5a: nur einer am Kinn sichtbar): der Unterkiefer reicht bis z 0,48, darum davor
        tooth((sd * 0.16, -0.38, 0.5), (sd * 0.22, -0.08, 0.55), 0.06, 0.014)
    # Runde 6 (Fratze): untere Reihe länger und dicker, dazu eine obere Reihe nach unten, schief und lückig
    for t_ in range(-3, 4):
        if t_ in (-3, 3): continue
        yc_ = -0.285 - 0.08 * (t_ * 0.06 / 0.26) ** 2
        tooth((t_ * 0.06, yc_ - 0.055, 0.46), (t_ * 0.06 + 0.008 * t_, yc_ + 0.01, 0.5), 0.04, 0.014)
    for t_ in (-2.5, -1.4, -0.5, 0.6, 1.5, 2.4):
        yc_ = -0.285 - 0.08 * (t_ * 0.06 / 0.26) ** 2
        tooth((t_ * 0.06, yc_ + 0.05, 0.47), (t_ * 0.06 - 0.006 * t_, yc_ - 0.01 - 0.006 * (abs(t_) % 1), 0.5), 0.034, 0.012)
    # Augen: schmal, gelb, tief unter der Braue, mit dunklem Schlitz (Doll goblinFace: Strich von (0,1; −0,01) nach (0,22; 0),
    # außen etwas höher; Runde 4: Runde 2/3 hatten runde Punktaugen, „drollig“)
    for sd in (-1, 1):
        bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=10, radius=1.0)
        for v in bm.verts: v.co = D(sd * 0.16 + v.co.x * 0.065, -0.01 + v.co.z * 0.016 + 0.083 * 0.065 * v.co.x * sd, 0.36 - v.co.y * 0.035)
        me = bpy.data.meshes.new('eye'); bm.to_mesh(me); bm.free()
        eo = bpy.data.objects.new('eye', me); scn.collection.objects.link(eo); me.materials.append(M['auge'])
        eo.parent = root; eo.matrix_parent_inverse = root.matrix_world.inverted()
        for p in me.polygons: p.use_smooth = True
        bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=1.0)
        for v in bm.verts: v.co = D(sd * 0.15 + v.co.x * 0.012, -0.011 + v.co.z * 0.015, 0.387 - v.co.y * 0.012)
        me = bpy.data.meshes.new('eye_pupille'); bm.to_mesh(me); bm.free()
        po = bpy.data.objects.new('eye_pupille', me); scn.collection.objects.link(po); me.materials.append(M['pupille'])
        po.parent = root; po.matrix_parent_inverse = root.matrix_world.inverted()
    # ein paar strähnige Haare oben auf dem Schädel (Doll: „a few lank strands“)
    # Runde 5c (Prüfer 5b: Strähne sticht durch die Kappe): nur ohne Kopfbedeckung
    for i, (ox, oz) in enumerate(((0.0, -0.1), (0.07, -0.05), (-0.06, -0.14)) if not K['kopf'] else ()):
        # Runde 5b (Prüfer 5a: schwebte über dem flachen Schädel): auf die Kopfhaut, Oberkante y 0,32, hinten abfallend
        pts = [D(ox + 0.02 * t, 0.315 - 0.14 * t * t, oz - 0.3 * t) for t in (0.0, 0.25, 0.5, 0.75, 1.0)]
        V_ = []; F_ = []
        for j, p in enumerate(pts):
            w = 0.028 * k * (1 - 0.8 * j / 4)
            V_ += [p + Vector((w, 0, 0)), p + Vector((-w, 0, 0))]
        for j in range(len(pts) - 1): F_.append((2 * j, 2 * j + 1, 2 * j + 3, 2 * j + 2))
        hs = mesh_from('hair_straehne', V_, F_, M['haar'])
        so = hs.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.012 * k; so.offset = 0
        bpy.context.view_layer.objects.active = hs; bpy.ops.object.modifier_apply(modifier='so')

    # Kopfbedeckung: Schale über dem Schädel (Doll: leather_cap 0,05 k, helmet 0,07 k mit Nasal und Rand)
    def kalotte(name, off, edge_y, tilt, m, thick):
        bm = bmesh.new(); bm.from_mesh(hv)
        kill = [f for f in bm.faces if not all(inv(v.co)[1] > edge_y + tilt * inv(v.co)[2] for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.normal_update()
        for v in bm.verts: v.co = v.co + v.normal * off * k
        me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
        for a in list(me.attributes):
            if a.name in ('ink', 'narbe'): me.attributes.remove(a)
        o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        for p in me.polygons: p.use_smooth = True
        so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = thick * k; so.offset = -1
        bpy.context.view_layer.objects.active = o; bpy.ops.object.modifier_apply(modifier='so')
        return o
    # Runde 5b: der Schädel ist flacher (Oberkante 0,32 statt 0,48), die Ränder tiefer; der Helm reicht weiter herab als die
    # Kappe und steht dicker ab wie Doll (0,07 k, Rand 0,1 k), sonst glichen sich beide (Prüfer 5a)
    if K['kopf'] == 'kapuze':
        # Späher (Dress hood): Stoffschale 0,09 k über dem Schädel, vorn offen ums Gesicht (Braue und Augen im Schatten der Kante),
        # Ohren durch Schlitze, ein weicher Zipfel hinten (Umriss: Kapuze, nicht Kappe) und ein Kragen bis auf die Schultern
        # Runde 1b (Prüfer 1a: „enge Haube“, Kragen rosa-beige heller als alt): weiter, vorn tiefer übers Gesicht, dunkler
        M['kapuze'] = mat('gkapuze', 0x3A3028, grain=0.12, blot=0.5)
        bm = bmesh.new(); bm.from_mesh(hv)
        kill = [f for f in bm.faces if not all((inv(v.co)[2] < 0.16 or inv(v.co)[1] > 0.16) and inv(v.co)[1] > -0.34 for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.normal_update()
        for v in bm.verts:
            x_, y_, z_ = inv(v.co)
            # weit wie Stoff, oben vorn als Rand über der Braue vorgezogen
            v.co = v.co + v.normal * 0.14 * k + D(0, 0, 0.08 * max(0.0, min(1.0, (y_ - 0.1) / 0.15)) * max(0.0, z_)) - D(0, 0, 0)
        # Runde 2 (Prüfer 1: die Ohren stechen durch die Kapuze): Schlitze, wo die Ohren den Stoff kreuzen
        bpy.context.view_layer.update()
        EV = np.array([o.matrix_world @ v.co for o in bpy.data.objects if o.name.startswith('ear') for v in o.data.vertices])
        HV = np.array([v.co for v in bm.verts]); bm.verts.ensure_lookup_table()
        dmin = np.array([np.min(np.linalg.norm(EV - h, axis=1)) for h in HV])
        kill = list({f for v in bm.verts if dmin[v.index] < 0.05 * k for f in v.link_faces})
        n_f = len(bm.faces)
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.normal_update()
        print('GOBLIN Kapuze: Schlitze %d von %d Flächen' % (len(kill), n_f))
        me = bpy.data.meshes.new('hood'); bm.to_mesh(me); bm.free()
        for a in list(me.attributes):
            if a.name in ('ink', 'narbe'): me.attributes.remove(a)
        o = bpy.data.objects.new('hood', me); scn.collection.objects.link(o); me.materials.append(M['kapuze'])
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        for p in me.polygons: p.use_smooth = True
        so = o.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.035 * k; so.offset = -1
        bpy.context.view_layer.objects.active = o; bpy.ops.object.modifier_apply(modifier='so')
        # Zipfel: vom Hinterkopf schräg nach unten hinten
        bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=10, radius1=0.3 * k, radius2=0.05 * k, depth=1.0)
        A, B = D(0.0, 0.14, -0.38), D(0.0, -0.45, -0.8); dv = B - A
        q = dv.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
        M4 = Matrix.Translation((A + B) / 2) @ q @ Matrix.Diagonal((1, 1, dv.length, 1))
        for v in bm.verts: v.co = M4 @ v.co
        me = bpy.data.meshes.new('hood_zipfel'); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new('hood_zipfel', me); scn.collection.objects.link(o); me.materials.append(M['kapuze'])
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        for p in me.polygons: p.use_smooth = True
        # Kragen: Schlauch vom Hals unter der Kapuze bis über die Schultern, vorn unter dem Kinn tiefer ausgeschnitten
        shm = (J['shR'][0] + J['shL'][0]) / 2
        rxb = abs(J['shR'][0].x - J['shL'][0].x) / 2 * 1.08; ryb = J['chestTop'][1][1] * 1.35
        n_a, n_t = 20, 6; V_ = []; F_ = []
        for i in range(n_t + 1):
            t = i / n_t
            for j in range(n_a):
                a = 2 * math.pi * j / n_a; fr = max(0.0, math.sin(a))         # fr = 1 vorn
                top = D(0.36 * math.cos(a), -0.3 - 0.2 * fr, -0.05 + 0.34 * math.sin(a))
                bot = Vector((shm.x - rxb * math.cos(a), shm.y - ryb * math.sin(a), shm.z - 0.04 * k - 0.12 * k * fr))
                p = top.lerp(bot, t)
                V_.append(p)
        ctr = [sum((V_[i * n_a + j] for j in range(n_a)), Vector()) / n_a for i in range(n_t + 1)]
        for i in range(n_t + 1):
            bulge = 1.0 + 0.1 * math.sin(math.pi * i / n_t)
            for j in range(n_a):
                V_[i * n_a + j] = ctr[i] + (V_[i * n_a + j] - ctr[i]) * bulge
        for i in range(n_t):
            for j in range(n_a):
                a0 = i * n_a + j; a1 = i * n_a + (j + 1) % n_a
                F_.append((a0, a1, a1 + n_a, a0 + n_a))
        kr = mesh_from('kragen', V_, F_, M['kapuze'])
        so = kr.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.03 * k; so.offset = 0
        bpy.context.view_layer.objects.active = kr; bpy.ops.object.modifier_apply(modifier='so')
    elif K['kopf'] == 'kappe':
        kalotte('helm_kappe', 0.035, 0.05, 0.35, M['kappe'], 0.03)
    elif K['kopf'] == 'helm':
        kalotte('helm', 0.07, -0.03, 0.3, M['rost'], 0.04)
        kalotte('helm_rand', 0.115, -0.03, 0.3, M['rostrand'], 0.045).data  # Rand: ein Ring (Runde 6: breiter, steht weiter ab)
        rnd = bpy.data.objects['helm_rand']
        bm = bmesh.new(); bm.from_mesh(rnd.data)
        kill = [f for f in bm.faces if not all(inv(v.co)[1] < -0.03 + 0.3 * inv(v.co)[2] + 0.09 for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.to_mesh(rnd.data)
        # Runde 6: Nieten rundum auf dem Rand, je die äußerste Ecke in 14 Winkeln
        RV = [(Vector(v.co), inv(v.co)) for v in bm.verts]; bm.free()
        for i in range(14):
            a0 = -math.pi + 2 * math.pi * i / 14
            sel = [(p, q) for p, q in RV if a0 <= math.atan2(q[0], q[2]) < a0 + 2 * math.pi / 14]
            if not sel: continue
            p, q = max(sel, key=lambda pq: pq[1][0] ** 2 + pq[1][2] ** 2)
            bmn = bmesh.new(); bmesh.ops.create_icosphere(bmn, subdivisions=1, radius=0.03 * k)
            for v in bmn.verts: v.co += p
            me = bpy.data.meshes.new('helm_niete'); bmn.to_mesh(me); bmn.free()
            o = bpy.data.objects.new('helm_niete', me); scn.collection.objects.link(o); me.materials.append(M['rostrand'])
            o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        # Nasal
        bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts: v.co = D(v.co.x * 0.07, -0.02 + v.co.z * 0.24, 0.47 + v.co.y * 0.04)
        me = bpy.data.meshes.new('helm_nasal'); bm.to_mesh(me); bm.free()
        o = bpy.data.objects.new('helm_nasal', me); scn.collection.objects.link(o); me.materials.append(M['rostrand'])
        o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()

    if K['kopf'] == 'schaedel':
        # Schamane (Dress.fetishes): Schädel eines gehörnten Tiers als Kappe, die Schnauze über der Braue, Hörner nach außen und
        # hinten geschwungen; die Hirnschale liegt auf dem flachen Goblinschädel (Oberkante 0,32), darum tiefer als bei Doll
        # Runde 1b (Prüfer 1a: „grellweiße Maske, niedliches Kuhschädel-Kostüm“, Gesicht verdeckt): Knochen schmutzig grau, der
        # Schädel weiter hinten und flacher, die Schnauze endet über der Braue, keine Punktaugen; die Hörner tragen den Umriss
        # Runde 1c (Prüfer 1b: „grauer Klumpen oder Mütze“): Schnauze länger, aber höher (über der Braue), mit Zahnreihe und dunkler
        # Nasenöffnung, Augenhöhlen länglich; Hörner dicker; Knochen etwas heller als 1b
        # Runde 2 (Sokrates statt Chef, 362; Prüfer 1: zu weiß, „Halloween-Kuhmaske“; Diogenes 1: nur kleine Kappe, Hörner wie
        # ein zweites Paar Ohren): grau, größer und länger über den ganzen Oberkopf, kleinere Augenhöhlen, Hörner höher wie alt
        # Runde 2b (Prüfer 2a: im Kampfbild weiß, die Hörner wie Hasen- oder Eselsohren; alt geweihartig): Knochen dunkler, die
        # Hörner weiter zur Seite geschwungen, mit einer Sprosse nach oben
        M['knochen'] = mat('gknochen', 0x56524A, grain=0.45, blot=0.9)
        M['horn'] = mat('ghorn', 0x4A4034, grain=0.25, blot=0.4)
        M['hoehle'] = mat('ghoehle', 0x140C0A, grain=0, blot=0)
        def teil(name, c, r, m, seg=(14, 9)):
            bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=seg[0], v_segments=seg[1], radius=1.0)
            for v in bm.verts: v.co = D(c[0] + v.co.x * r[0], c[1] + v.co.z * r[1], c[2] - v.co.y * r[2])
            me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
            o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
            o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
            for p in me.polygons: p.use_smooth = True
        def kegel(name, a, b, ra, rb, m, seg=8):
            bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=ra * k, radius2=rb * k, depth=1.0)
            A, B = D(*a), D(*b); d = B - A
            q = d.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
            M4 = Matrix.Translation((A + B) / 2) @ q @ Matrix.Diagonal((1, 1, d.length, 1))
            for v in bm.verts: v.co = M4 @ v.co
            me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
            o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
            o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
            for p in me.polygons: p.use_smooth = True
        teil('helm_schaedel', (0.0, 0.3, -0.06), (0.46, 0.18, 0.5), M['knochen'], (16, 10))
        kegel('helm_schnauze', (0.0, 0.38, 0.14), (0.0, 0.4, 0.62), 0.16, 0.075, M['knochen'])
        teil('helm_nase', (0.0, 0.44, 0.6), (0.045, 0.022, 0.035), M['hoehle'], (8, 6))
        for sd in (-1, 1):
            teil('helm_hoehle', (sd * 0.14, 0.42, 0.24), (0.04, 0.03, 0.06), M['hoehle'], (8, 6))
            # Runde 2c (Prüfer 2b: Hörner wie Eselsohren, die Sprosse ein Stachelbüschel): gewunden wie beim Widder, erst nach
            # hinten zur Seite, dann neben dem Schädel nach unten und vorn; ohne Sprosse
            kegel('helm_horn', (sd * 0.24, 0.48, -0.04), (sd * 0.62, 0.58, -0.30), 0.13, 0.10, M['horn'])
            kegel('helm_horn', (sd * 0.62, 0.58, -0.30), (sd * 0.82, 0.38, -0.18), 0.10, 0.07, M['horn'])
            kegel('helm_horn', (sd * 0.82, 0.38, -0.18), (sd * 0.80, 0.22, 0.06), 0.07, 0.02, M['horn'])
            for t_ in (0.03, 0.07):   # Zähne an der Schnauze, nach unten
                kegel('helm_zahn', (sd * t_, 0.35, 0.56), (sd * t_, 0.27, 0.57), 0.02, 0.005, M['knochen'], 5)

    # ---- 5. Lendentuch: Band um die Hüfte und zwei zerfranste Lappen vorn und hinten (Doll: „a rag round its loins“)
    bpy.context.view_layer.update()
    BV = np.array([body.matrix_world @ v.co for v in body.data.vertices])
    hipz = J['hipR'][0].z; pel = J['pelvis'][0]
    band = (BV[:, 2] > hipz - 0.10 * k * 0 - 9.0) & (BV[:, 2] < hipz + 6.0)
    near_trunk = np.minimum.reduce([seg_dist(BV, a, b) for a, b in (('pelvis', 'waist'), ('pelvis', 'hipR'), ('pelvis', 'hipL'), ('hipR', 'thighR'), ('hipL', 'thighL'))]) < 3.0
    mask = band & near_trunk & (not K.get('robe'))   # unter der Robe kein Lendentuch (stäche durch den Stoff)
    bm = bmesh.new(); bm.from_mesh(body.data); bm.verts.ensure_lookup_table()
    kill = [f for f in bm.faces if not all(mask[v.index] for v in f.verts)]
    bmesh.ops.delete(bm, geom=kill, context='FACES')
    for v in bm.verts: v.co = v.co + v.normal * 0.8
    me = bpy.data.meshes.new('loin'); bm.to_mesh(me); bm.free()
    lo = bpy.data.objects.new('loin', me); scn.collection.objects.link(lo); me.materials.append(M['lappen'])
    lo.matrix_world = body.matrix_world.copy(); lo.parent = root; lo.matrix_parent_inverse = root.matrix_world.inverted()
    so = lo.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.5; so.offset = -1
    bpy.context.view_layer.objects.active = lo; bpy.ops.object.modifier_apply(modifier='so')
    for p in me.polygons: p.use_smooth = True
    for side, nm in (() if K.get('robe') else ((-1, 'tabard'), (1, 'tabard.001'))):     # rig.py: Stoff folgt den Oberschenkeln (CLOTH)
        # Lappen hängt vom Band bis knapp über die Knie, vorn (−Y) bzw. hinten (+Y), unten zerfranst
        yb = pel.y + side * (J['pelvis'][1][1] + 2.0)
        top = hipz + 4.0; bot = J['kneeR'][0].z + (J['hipR'][0].z - J['kneeR'][0].z) * (0.45 if side < 0 else 0.35)
        n_u, n_v = 6, 8; V_ = []; F_ = []
        for i in range(n_u + 1):
            for jj in range(n_v + 1):
                u = i / n_u * 2 - 1; t = jj / n_v
                hw = (7.5 if side < 0 else 9.0) * (1 - 0.25 * t)
                rag = (2.5 * (0.5 + 0.5 * math.sin(u * 9.0 + side))) * (t ** 6)
                z = top - (top - bot) * t + rag
                y = yb + side * (1.5 * t + 1.2 * (1 - u * u) * t)
                V_.append(Vector((u * hw, y, z)))
        for i in range(n_u):
            for jj in range(n_v):
                a = i * (n_v + 1) + jj; F_.append((a, a + n_v + 1, a + n_v + 2, a + 1))
        fl = mesh_from(nm, V_, F_, M['lappen'])
        so = fl.modifiers.new('so', 'SOLIDIFY'); so.thickness = 0.4; so.offset = 0
        bpy.context.view_layer.objects.active = fl; bpy.ops.object.modifier_apply(modifier='so')

    if K.get('robe'):
        bpy.data.objects.remove(lo)

    # ---- 6. Fell über den Schultern (Dress.furMantle): Schale über Brust und Rücken bis 0,42 des Rumpfs, unten zerfranst
    if K['fell']:
        src = bpy.data.objects['chain'] if 'chain' in bpy.data.objects else body
        SV = np.array([src.matrix_world @ v.co for v in src.data.vertices])
        shz = J['shR'][0].z; trunk = shz - hipz
        ang = np.arctan2(SV[:, 0], SV[:, 1])
        edge = shz - 0.42 * trunk + 2.0 * np.sin(ang * 7.0) + 1.5 * np.sin(ang * 13.0 + 1.0)
        armd = np.minimum.reduce([seg_dist(SV, 'el' + s, 'fo' + s) for s in 'RL'])
        m2 = (SV[:, 2] > edge) & (armd > 2.0) & (SV[:, 2] < J['neckTop'][0].z - 2.0)
        bm = bmesh.new(); bm.from_mesh(src.data); bm.verts.ensure_lookup_table()
        kill = [f for f in bm.faces if not all(m2[v.index] for v in f.verts)]
        bmesh.ops.delete(bm, geom=kill, context='FACES'); bm.normal_update()
        for v in bm.verts:
            v.co = v.co + v.normal * (1.6 + 0.8 * noise.noise(v.co * 0.4))
        me = bpy.data.meshes.new('fell'); bm.to_mesh(me); bm.free()
        fo = bpy.data.objects.new('fell', me); scn.collection.objects.link(fo); me.materials.append(M['fell'])
        fo.matrix_world = src.matrix_world.copy(); fo.parent = root; fo.matrix_parent_inverse = root.matrix_world.inverted()
        so = fo.modifiers.new('so', 'SOLIDIFY'); so.thickness = 1.2; so.offset = -1
        bpy.context.view_layer.objects.active = fo; bpy.ops.object.modifier_apply(modifier='so')
        for p in me.polygons: p.use_smooth = True
        if ART in ('goblin_archer', 'goblin_shaman'):
            # Runde 1b (Prüfer 1a: Fell „wie ein dunkler Pulli“): Zotten am unteren Saum in hellerem Fell (Dress furLight 0x4A3C30)
            M['fellhell'] = mat('gfellhell', 0x4A3C30, grain=0.6, blot=0.3)
            bpy.context.view_layer.update()
            FV = np.array([fo.matrix_world @ v.co for v in fo.data.vertices]); c0 = FV.mean(0)
            ang = np.arctan2(FV[:, 0] - c0[0], FV[:, 1] - c0[1])
            for i in range(26):
                a0 = -math.pi + 2 * math.pi * i / 26; sel = np.where((ang >= a0) & (ang < a0 + 2 * math.pi / 26))[0]
                if len(sel) == 0: continue
                lo = sel[np.argmin(FV[sel, 2])]; P_ = Vector(FV[lo]); out = Vector((P_.x - c0[0], P_.y - c0[1], 0)).normalized()
                L_ = 6.0 + 4.0 * (0.5 + 0.5 * math.sin(i * 2.7))     # Runde 1c (Prüfer 1b: Zotten unsichtbar): länger, breiter
                bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=5, radius1=2.0, radius2=0.3, depth=1.0)
                A_, B_ = P_ + out * 0.4 + Vector((0, 0, 1.0)), P_ + out * 0.9 - Vector((0, 0, L_)); dv = B_ - A_
                q = dv.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
                M4 = Matrix.Translation((A_ + B_) / 2) @ q @ Matrix.Diagonal((1, 1, dv.length, 1))
                for v in bm.verts: v.co = M4 @ v.co
                me = bpy.data.meshes.new('fell_zotte'); bm.to_mesh(me); bm.free()
                o = bpy.data.objects.new('fell_zotte', me); scn.collection.objects.link(o); me.materials.append(M['fellhell'] if i % 2 else M['fell'])
                o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()

    # ---- 6a. Späher Runde 2 (Sokrates statt Chef, 362): Fellumhang mit breitem Kragen über den Schultern, damit das Fell den
    # Umriss ändert (Prüfer 1: „das Fell liest sich als Oberteil“); Köcher mit Pfeilen auf dem Rücken wie alt (Diogenes 1: fehlt)
    if ART == 'goblin_archer':
        shm = (J['shR'][0] + J['shL'][0]) / 2
        rxb = abs(J['shR'][0].x - J['shL'][0].x) / 2; ryb = J['chestTop'][1][1]
        shz = J['shR'][0].z; trunk = shz - hipz
        if K['fell']:
            n_a, n_t = 28, 4; V_ = []; F_ = []
            for i in range(n_t + 1):
                t = i / n_t
                for j in range(n_a):
                    a = 2 * math.pi * j / n_a
                    zack = 1.0 + t * (0.1 * math.sin(a * 7.0) + 0.06 * math.sin(a * 13.0 + 1.0))
                    rx = (0.42 + 1.05 * t) * rxb * zack; ry = (0.55 + 1.0 * t) * ryb * 1.25 * zack
                    z = shz + 0.2 * k - (0.3 * k) * t ** 1.4 + 0.03 * k * math.sin(a * 5.0) * t
                    V_.append(Vector((shm.x + rx * math.cos(a), shm.y + ry * math.sin(a), z)))
            for i in range(n_t):
                for j in range(n_a):
                    a0 = i * n_a + j; a1 = i * n_a + (j + 1) % n_a
                    F_.append((a0, a1, a1 + n_a, a0 + n_a))
            kr = mesh_from('fellkragen', V_, F_, M['fell'])
            so = kr.modifiers.new('so', 'SOLIDIFY'); so.thickness = 1.6; so.offset = 0
            bpy.context.view_layer.objects.active = kr; bpy.ops.object.modifier_apply(modifier='so')
            for j in range(0, n_a, 2):     # Zotten am Rand in hellerem Fell, damit der Kragen nicht als glatte Scheibe liest
                P_ = V_[n_t * n_a + j]; out = Vector((P_.x - shm.x, P_.y - shm.y, 0)).normalized()
                L_ = 3.0 + 2.5 * (0.5 + 0.5 * math.sin(j * 2.3))
                bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=5, radius1=1.6, radius2=0.3, depth=1.0)
                A_, B_ = P_ - out * 1.0, P_ + out * 1.2 - Vector((0, 0, L_)); dv = B_ - A_
                q = dv.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
                M4 = Matrix.Translation((A_ + B_) / 2) @ q @ Matrix.Diagonal((1, 1, dv.length, 1))
                for v in bm.verts: v.co = M4 @ v.co
                me = bpy.data.meshes.new('fellkragen_zotte'); bm.to_mesh(me); bm.free()
                o = bpy.data.objects.new('fellkragen_zotte', me); scn.collection.objects.link(o)
                me.materials.append(M['fellhell'] if (j // 2) % 2 else M['fell'])
                o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        # Köcher: schräg über den Rücken, die Öffnung über der rechten Schulter, darin Pfeile mit Federn
        M['koecher'] = mat('gkoecher', 0x3A2A1E, grain=0.1, blot=0.5)
        M['schaft'] = mat('gschaft', 0x5A4430, grain=0.1, blot=0.2)
        M['feder'] = mat('gfeder', 0x6A3424, grain=0.3, blot=0.3)
        yb = J['chestTop'][0].y + ryb * 1.15
        # Runde 2b (Prüfer 2a: von vorn kein Köcher, die Pfeile ein Stachelkamm hinter dem Kopf): schräger, die Öffnung neben der
        # rechten Schulter, der Boden neben der linken Hüfte, Federn rotbraun
        A_ = Vector((J['shR'][0].x * 1.05, yb + 0.12 * k, shz + 0.38 * k))
        B_ = Vector((J['shL'][0].x * 1.05, yb - 0.02 * k, hipz + 0.15 * trunk))
        def stab(name, a, b, ra, rb, m, seg=10):
            bm = bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=ra, radius2=rb, depth=1.0)
            d = b - a; q = d.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
            M4 = Matrix.Translation((a + b) / 2) @ q @ Matrix.Diagonal((1, 1, d.length, 1))
            for v in bm.verts: v.co = M4 @ v.co
            me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
            o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
            o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
            for p in me.polygons: p.use_smooth = True
        stab('koecher', B_, A_, 0.11 * k, 0.15 * k, M['koecher'], 12)
        ax = (A_ - B_).normalized(); s1 = ax.cross(Vector((0, 1, 0))).normalized(); s2 = ax.cross(s1)
        for i, (u, w) in enumerate(((0.0, 0.0), (0.07, 0.03), (-0.06, 0.04), (0.03, -0.07), (-0.05, -0.05))):
            o_ = (s1 * u + s2 * w) * k; L_ = (0.42 + 0.06 * math.sin(i * 1.9)) * k
            a = A_ + o_ - ax * 0.1 * k; b = A_ + o_ + ax * L_
            stab('koecher_pfeil', a, b, 0.025 * k, 0.025 * k, M['schaft'], 5)
            stab('koecher_feder', b - ax * 0.2 * k, b + ax * 0.02 * k, 0.07 * k, 0.02 * k, M['feder'], 4)

    # ---- 6b. Schamane: Kette aus Knochen und Zähnen an einem Lederband um den Hals, ein kleiner Schädel vorn (Dress.fetishes);
    # auf die Oberfläche von Körper, Wams und Fell gelegt
    if ART == 'goblin_shaman':
        from mathutils.bvhtree import BVHTree
        bpy.context.view_layer.update()
        dg = bpy.context.evaluated_depsgraph_get()
        cov = [o for o in meshes() if o.name in ('body', 'chain', 'fell')]
        bm = bmesh.new()
        for o in cov:
            b2 = bmesh.new(); b2.from_object(o, dg); b2.transform(o.matrix_world)
            me_ = bpy.data.meshes.new('tmp'); b2.to_mesh(me_); b2.free(); bm.from_mesh(me_); bpy.data.meshes.remove(me_)
        tree = BVHTree.FromBMesh(bm); bm.free()
        M['band'] = mat('gband', 0x2A1E16, grain=0.2, blot=0.2)
        M['kn'] = mat('gkette', 0xA89C7C, grain=0.35, blot=0.5)
        shm = (J['shR'][0] + J['shL'][0]) / 2; shx = abs(J['shR'][0].x - J['shL'][0].x) / 2
        nz = shm.z + 0.02 * k
        def auf(x, z):   # Punkt auf der Vorderseite (−Y) bei Höhe z, von vorn eingeschossen
            hit = tree.ray_cast(Vector((x, shm.y - 60, z)), Vector((0, 1, 0)))
            return (hit[0] + hit[1] * 0.35 * 0.06 * k, hit[1]) if hit[0] else (None, None)
        def kugel(name, c, r, m, seg=(6, 4)):
            bm2 = bmesh.new(); bmesh.ops.create_uvsphere(bm2, u_segments=seg[0], v_segments=seg[1], radius=1.0)
            for v in bm2.verts: v.co = c + Vector((v.co.x * r[0], v.co.y * r[1], v.co.z * r[2]))
            me = bpy.data.meshes.new(name); bm2.to_mesh(me); bm2.free()
            o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
            o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        def spitz(name, a, b, ra, m):
            bm2 = bmesh.new(); bmesh.ops.create_cone(bm2, cap_ends=True, segments=5, radius1=ra, radius2=ra * 0.2, depth=1.0)
            d = b - a; q = d.normalized().to_track_quat('Z', 'Y').to_matrix().to_4x4()
            M4 = Matrix.Translation((a + b) / 2) @ q @ Matrix.Diagonal((1, 1, d.length, 1))
            for v in bm2.verts: v.co = M4 @ v.co
            me = bpy.data.meshes.new(name); bm2.to_mesh(me); bm2.free()
            o = bpy.data.objects.new(name, me); scn.collection.objects.link(o); me.materials.append(m)
            o.parent = root; o.matrix_parent_inverse = root.matrix_world.inverted()
        # Runde 2 (Sokrates statt Chef, 362; Prüfer, Diogenes 1: nur ein heller Klecks unter dem Kinn): weniger, größere Knochen
        # mit Lücken dazwischen, abwechselnd Zahn und Röhrenknochen, der Schädel größer
        n_ = 10
        for t in range(n_ + 1):
            a = math.pi * (0.12 + 0.76 * t / n_)
            x = shm.x + math.cos(a) * shx * 0.62; z = nz - 0.32 * k * math.sin(a) ** 1.5
            P_, N_ = auf(x, z)
            if P_ is None: continue
            kugel('kette', P_, (0.035 * k,) * 3, M['band'])
            if 0 < t < n_:   # Knochen und Zähne hängen am Band (Runde 1b, Prüfer 1a: kaum zu sehen): größer
                if t % 2:
                    spitz('kette_zahn', P_ + N_ * 0.04 * k, P_ + N_ * 0.1 * k - Vector((0, 0, 0.3 * k)), 0.06 * k, M['kn'])
                else:   # Röhrenknochen mit Gelenkkopf unten
                    E_ = P_ + N_ * 0.08 * k - Vector((0, 0, 0.26 * k))
                    spitz('kette_zahn', P_ + N_ * 0.05 * k - Vector((0, 0, 0.02 * k)), E_, 0.045 * k, M['kn'])
                    kugel('kette', E_, (0.055 * k, 0.045 * k, 0.045 * k), M['kn'])
        P_, N_ = auf(shm.x, nz - 0.4 * k)
        if P_ is not None:   # der kleine Schädel vorn, zwei dunkle Höhlen
            kugel('kette_schaedel', P_ + N_ * 0.08 * k, (0.15 * k, 0.12 * k, 0.16 * k), M['kn'], (10, 7))
            for sd in (-1, 1):
                kugel('kette_hoehle', P_ + N_ * 0.2 * k + Vector((sd * 0.06 * k, 0, 0.02 * k)), (0.04 * k, 0.02 * k, 0.04 * k), M['band'])

    # ---- 7. Auf Goblingröße (Zentimeter wie held3; rig.py macht Meter daraus)
    bpy.context.view_layer.update()
    S_ = Matrix.Scale(F, 4)
    for o in [o for o in bpy.data.objects if o.parent is None]: o.matrix_world = S_ @ o.matrix_world
    J = {kk: [v[0] * F, [v[1][0] * F, v[1][1] * F]] for kk, v in J.items()}
    bpy.context.view_layer.update()
    top = max(max((o.matrix_world @ v.co).z for v in o.data.vertices) for o in meshes() if not o.name.startswith('ear'))
    json.dump({'J': {kk: [list(v[0]), list(v[1])] for kk, v in J.items()}, 'E': E}, open(T + '/gelenke.json', 'w'))
    # Griff für figur.gd (_hold): vom Unterarmgelenk bis zur Handmitte (held3: 3,6 cm hinter dem Handgelenk, Hände HAND) und
    # die halbe Handdicke nach innen (Held 2,4 cm), in Metern
    grip = ((J['wrR'][0] - J['foR'][0]).length + 3.6 * HAND * F) / 100.0
    json.dump({'groesse_cm': round(top, 1), 'koerper_cm': round(Hg, 1), 'kopf_cm': round(k * F, 1), 'schulter_cm': round(J['shR'][0].z, 1),
               'griff_m': round(grip, 4), 'handflaeche_m': round(2.4 * HAND * F / 100.0, 4)},
              open(T + '/goblin-masse.json', 'w'))
    bpy.ops.wm.save_as_mainfile(filepath=T + '/held3.blend')
    print('GOBLIN', kit, 'Groesse %.1f cm, Kopf %.1f cm, Schulter %.1f cm, Objekte %d' % (top, k * F, J['shR'][0].z, len(meshes())))


if __name__ == '__main__':
    nach() if '--nach' in sys.argv else treiber()
