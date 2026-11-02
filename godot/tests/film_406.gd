# 406 (Chef 01.11., 13:0x, Archiv 406: „haben wir da jetzt nicht extra Animationen eingekauft? … 406 nochmal neu vorlegen“; 13:1x
# zum Film 454: „Sein Schild hängt drunter. Dann wird er vom Wolf angeknabbert und reißt dann das Schild hoch“): Film der Kaufschilde
# 15 (Kämpfer, rund) und 2 (Kleriker, Drachenschild) mit dem gekauften Satz „Sword & Shield“ (held_kampf.py, figur.gd _ss), im
# Spiellicht (Signatur 457), die Kamera auf der Gegnerseite (Prüferbefund 01.11., 12:0x: vorher nur die Innenseite im Bild).
#   Teil 1, Sichtung: beide Helden nebeneinander von vorn; Kampfhaltung, Gehen und Rennen mit Schild, Abwehr leicht, mittel, schwer,
#     Paraden, Schildstoß, Treffer mit Schild, Schwerthiebe, dann eine Drehung (Schild von allen Seiten). Name je Bewegung oben.
#   Teil 2, Kampf: je Held gegen das Wolfsrudel auf Autopilot (Echtzeit), Kamera hinter den Wölfen: Abwehr vor dem Biss, Treffer mit
#     erhobenem Schild, Gehen und Rennen mit Schild.
# Aufruf (Bild, Probelauf nach 389): PROBE=406 xvfb-run godot --path godot --resolution 1080x2340 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_406.gd     TEIL=sichtung|kampf nur einen Teil; DAUER_MS je Held im Kampf (16000), SEED (7)
# MESS=1 (ohne Bild, --headless): Bildausschnitt (wer im Bild steht) und im Kampf je Angriff auf den Helden: Abwehr beginnt vor
#   dem Aufschlag, Schild steht beim Aufschlag (Zeit Kontakt gegen Aufschlag), Treffer nur mit erhobenem Schild
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const DAUER_MS := 26000
const FORMAT := Vector2(1080, 2340)     # Hochformat wie das Handy; Kamera und Messung rechnen damit (ohne Fenster ist der Schirm anders)
const KLASSEN := ["FIGHTER", "CLERIC"]
const SEEDS := {"FIGHTER": 2, "CLERIC": 7}
const NAMEN := {"FIGHTER": "Kämpfer · Schild 15 (rund)", "CLERIC": "Kleriker · Schild 2 (Drachenschild)"}

## Sichtung: [Bewegung, Name im Bild]; „gehen“, „rennen“, „drehen“ sind Wege
const FOLGE := [
	["SS_IdleCombat", "Kampfhaltung, Schild oben"], ["gehen", "Gehen mit Schild, vor und zurück"],
	["rennen", "Rennen mit Schild"], ["SS_BlockLight", "Abwehr leicht"], ["SS_BlockMedium1", "Abwehr mittel 1"],
	["SS_BlockMedium2", "Abwehr mittel 2"], ["SS_BlockHeavy1", "Abwehr schwer 1"], ["SS_BlockHeavy2", "Abwehr schwer 2"],
	["SS_ParryHigh1", "Parade hoch 1"], ["SS_ParryHigh2", "Parade hoch 2"], ["SS_ParryLow", "Parade tief"],
	["SS_ParryLeft", "Parade links"], ["SS_ParryRight", "Parade rechts"], ["SS_ShieldAttack1", "Schildstoß 1"],
	["SS_ShieldAttack2", "Schildstoß 2"], ["SS_ShieldAttack3", "Schildstoß 3"], ["SS_GetHitLightFront", "Treffer leicht, Schild oben"],
	["SS_GetHitHeavyFront", "Treffer schwer, Schild oben"], ["SS_SwordAttack1", "Schwerthieb 1"], ["SS_SwordAttack2", "Schwerthieb 2"],
	["SS_SwordAttack3", "Schwerthieb 3"], ["drehen", "Drehung: Schild von allen Seiten"]]

var mess := OS.get_environment("MESS") != ""
# 406 d (Prüfer Film 406, 01.11., 16:4x: an den Schnitten fremde Bilder, Spielansicht, graues Bild, Testmenü; Grundstand G2): schwarz
# über allem wie film_403 (699c3a035), bis der Kampfort steht; am Ende jedes Teils abblenden, erst dann abbauen
const BLENDE_BILDER := 8     # 0,27 s bei 30 Bildern
const RUHIG_BILDER := 6
var schwarz: ColorRect
# 406 a (Chef 01.11., 20:2x: „der Hälfte des Videos völlig parallele Bewegungsabläufe“): in der Sichtung beginnt der rechte Held
# jede Bewegung VERSATZ s später, im Gehen und in der Kampfhaltung eine halbe Bewegung versetzt
const VERSATZ := 0.4
# 406 d (Prüfer: von der Wolfsseite stehen Kämpfer und Kleriker hintereinander „wie eine Figur mit zwei Köpfen“): Kamera um SCHRAEG
# Grad um die Mitte gedreht
const SCHRAEG := 40.0
var lb: Label
var lz: Label
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	if ziel < 0.5:
		schwarz.color.a = 1.0
		for i in RUHIG_BILDER:
			await process_frame
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


func _run() -> void:
	if not mess:
		var deck := CanvasLayer.new()
		deck.layer = 128
		schwarz = ColorRect.new()
		schwarz.color = Color.BLACK
		schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
		schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
		deck.add_child(schwarz)
		root.add_child(deck)
	var teil := OS.get_environment("TEIL")
	if teil != "kampf":
		await _sichtung()
	if teil != "sichtung":
		for k in KLASSEN:
			await _kampf(k)
	print("Film 406 %s" % ("Messung: %d Befunde" % fehler if mess else "fertig"))
	quit(1 if mess and fehler > 0 else 0)


func _start(k: String, merc: String):
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = merc
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	# Würfel je Klasse (SEED_FIGHTER, SEED_CLERIC), sonst SEED, sonst gewählt nach Messung: in 26 s Abwehr, Treffer und eigener Hieb
	var sd := OS.get_environment("SEED_" + k) if OS.get_environment("SEED_" + k) != "" else OS.get_environment("SEED")
	p._start(int(sd) if sd != "" else SEEDS.get(k, 7))
	for i in 4:
		await process_frame
	return p


func _labels() -> void:
	if lb != null:
		return
	var vs: Vector2 = root.get_visible_rect().size
	var cl := CanvasLayer.new()
	cl.layer = 10
	root.add_child(cl)
	lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 19.0), Color(0.95, 0.82, 0.45))
	lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.075), int(vs.x / 28.0), Color(0.92, 0.88, 0.80))


## Kamera mit Blick auf [ziel] aus Richtung [von] (waagerecht), [hoch] m über dem Boden, so weit weg, dass [breite] m quer ins Bild passen
func _kamera(kf, ziel: Vector3, von: Vector3, hoch: float, breite: float) -> Camera3D:
	var vs := FORMAT
	var c := Camera3D.new()
	kf.add_child(c)
	c.fov = 30.0     # senkrecht (KEEP_HEIGHT)
	var hfov := 2.0 * atan(tan(deg_to_rad(c.fov) / 2.0) * vs.x / vs.y)
	var d := breite / 2.0 / tan(hfov / 2.0)
	c.position = ziel + von.normalized() * d + Vector3(0, hoch - ziel.y, 0)
	c.look_at(ziel)
	c.make_current()
	kf.ink_ziel = ziel     # Tusche nach Licht nach dieser Kamera (kampfort.gd _ink_licht)
	return c


func _sichtung() -> void:
	var p = await _start("FIGHTER", "CLERIC")
	var kf = p.fight
	if kf.ui != null:
		kf.ui.visible = false
	var bis := Time.get_ticks_msec() + 15000
	while kf.playing and Time.get_ticks_msec() < bis:
		await process_frame
	kf.playing = true     # die Regeln ruhen; _process des Kampforts läuft weiter (Tusche nach Licht)
	var helden := []
	for id in kf.figures:
		var f = kf.figures[id]
		if f.tween:
			f.tween.kill()
		f.set_process(false)
		if f.fighter.monster == null:
			helden.append(f)
		else:
			f.visible = false
	helden.sort_custom(func(a, b): return String(a.fighter.id) == "hero")     # Kämpfer links, Kleriker rechts
	for f in helden:
		if not f._ss():
			print("FEHLER: %s ohne Sword & Shield (daten/kampf-bewegungen.bin mit SS_, Schild): kauf %s, SS %s, Schild %s, Stab %s, Klasse %s" % [f.fighter.id, f.kauf, f.anim.has_animation("SS_IdleCombat") if f.anim else false, f._schild(), f._stab(), f.fighter.hero.get("cls", "")])
			quit(1)
			return
	var mitte: Vector3 = kf._ground(0, 0)
	var vorn: Vector3 = kf.cam.global_position - mitte     # aus Richtung der Spielkamera: dort ist die Lichtung frei
	vorn.y = 0.0
	vorn = vorn.normalized()
	var quer := vorn.cross(Vector3.UP).normalized()     # im Bild nach links
	var plaetze := []
	for i in helden.size():
		var f = helden[i]
		plaetze.append(mitte + quer * (0.62 if i == 0 else -0.62))
		f.position = plaetze[i]
		f.rotation = Vector3(0, atan2(vorn.x, vorn.z) + deg_to_rad(18.0), 0)     # etwas zur eigenen Rechten: Schild halb von der Seite
		f.anim.play("SS_IdleCombat", 0.0)
	var cam := _kamera(kf, mitte + Vector3(0, 1.05, 0), vorn, 2.1, 2.3)
	await process_frame
	if mess:
		_ausschnitt(cam, helden, "Sichtung")
		kf.queue_free()
		p.queue_free()
		await process_frame
		return
	if not Signatur.wache(kf, self, "Film 406 Sichtung"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
		return
	_labels()
	lb.text = "Sichtung · Sword & Shield"
	helden[1].anim.seek(helden[1].anim.current_animation_length * 0.5, true)
	await _blende(0.0)
	for e in FOLGE:
		lz.text = "%s\nlinks Kämpfer, Schild 15 · rechts Kleriker, Schild 2" % e[1]
		match e[0]:
			"gehen", "rennen":
				var nm: String = "SS_WalkForward" if e[0] == "gehen" else "SS_RunForward"
				var s_ := 1.6 if e[0] == "gehen" else 0.9
				await _weg(helden, plaetze.map(func(q): return q + vorn * helden[0]._held_mps(nm) * s_), nm)
				await _weg(helden, plaetze, "SS_WalkBackwards")
			"drehen":
				for f in helden:
					f.anim.play("SS_IdleCombat", 0.2)
				helden[1].anim.seek(helden[1].anim.current_animation_length * 0.5)
				var t := 0.0
				var r0: float = helden[0].rotation.y
				while t < 8.0:
					await process_frame
					t += 1.0 / 30.0
					for f in helden:
						f.rotation.y = r0 + TAU * t / 8.0
			_:
				var lang := 0.0
				for f in helden:
					lang = maxf(lang, f.anim.get_animation(e[0]).length)
				if e[0] == "SS_IdleCombat":
					await create_timer(2.5).timeout
				else:
					helden[0].anim.play(e[0], 0.15)
					await create_timer(VERSATZ).timeout
					helden[1].anim.play(e[0], 0.15)
					await create_timer(lang - VERSATZ).timeout
					helden[0].anim.play("SS_IdleCombat", 0.2)
					await create_timer(VERSATZ).timeout
					helden[1].anim.play("SS_IdleCombat", 0.2)
					await create_timer(0.35).timeout
	await _blende(1.0)
	lb.text = ""
	lz.text = ""
	kf.queue_free()
	p.queue_free()
	await process_frame


## Weg zu [ziele] im Tempo der Schritte (figur.gd _held_mps, am Fuß gemessen), dann Kampfhaltung
func _weg(helden: Array, ziele: Array, nm: String) -> void:
	var von := []
	for f in helden:
		f.anim.play(nm, 0.15)
		von.append(f.position)
	helden[1].anim.seek(helden[1].anim.current_animation_length * 0.5)
	var s: float = von[0].distance_to(ziele[0]) / helden[0]._held_mps(nm)
	var t := 0.0
	while t < s:
		await process_frame
		t = minf(t + 1.0 / 30.0, s)
		for i in helden.size():
			helden[i].position = (von[i] as Vector3).lerp(ziele[i], t / s)
	for f in helden:
		f.anim.play("SS_IdleCombat", 0.15)


func _kampf(k: String) -> void:
	var p = await _start(k, "FIGHTER" if k != "FIGHTER" else "CLERIC")
	var kf = p.fight
	var held = kf.figures["hero"]
	if not held._ss():
		print("FEHLER: %s ohne Sword & Shield" % k)
		fehler += 1
	# Kamera hinter den Wölfen: gespiegelt zur Spielkamera über die Mitte zwischen Helden und Wölfen, gleiche Höhe
	var hm := Vector3.ZERO
	var wm := Vector3.ZERO
	var nh := 0
	var nw := 0
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster == null:
			hm += f.home
			nh += 1
		else:
			wm += f.home
			nw += 1
	hm /= maxf(nh, 1)
	wm /= maxf(nw, 1)
	var ziel: Vector3 = hm.lerp(wm, 0.35) + Vector3(0, 0.9, 0)
	var von: Vector3 = wm - hm
	von.y = 0.0
	# zur Seite, auf der die Helden im Bild am weitesten auseinander stehen
	var hs := []
	for id in kf.figures:
		if kf.figures[id].fighter.monster == null:
			hs.append(kf.figures[id].home)
	var best_v := von
	var best_a := -1.0
	for sg in [1.0, -1.0]:
		var v := von.rotated(Vector3.UP, deg_to_rad(SCHRAEG) * sg)
		var quer := v.cross(Vector3.UP).normalized()
		var a := absf((hs[0] - hs[-1]).dot(quer)) if hs.size() > 1 else 0.0
		if a > best_a:
			best_a = a
			best_v = v
	von = best_v
	var cam := _kamera(kf, ziel, von, 3.2, 4.2)
	if kf.ui != null:
		kf.ui.visible = false
	await process_frame
	if mess:
		_ausschnitt(cam, kf.figures.values(), "Kampf " + k)
	elif not Signatur.wache(kf, self, "Film 406 Kampf " + k):
		return
	_labels()
	lb.text = "Kampf · " + NAMEN[k]
	lz.text = "Kamera auf der Seite der Wölfe; Autopilot, Echtzeit"
	await _blende(0.0)
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var n := 0
	var dauer := int(OS.get_environment("DAUER_MS")) if OS.get_environment("DAUER_MS") != "" else DAUER_MS
	var alt_anim := ""
	while n < dauer * 30 / 1000:     # Bilder bei --fixed-fps 30
		await process_frame
		n += 1
		if mess:
			var jetzt := ""
			for id in kf.figures:
				var f = kf.figures[id]
				if f.anim != null:
					jetzt += "%s:%s " % [id, f.anim.current_animation]
			if jetzt != alt_anim:
				alt_anim = jetzt
				print("  %5.2f s %s" % [n / 30.0, jetzt])
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
				kf.go_on()
			else:
				var c = kf.mars.current()
				var ts: Array = kf.mars.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	print("Film 406 Kampf %s: %s nach %d Bildern" % [k, kf.mars.outcome, n])
	await _blende(1.0)
	lb.text = ""
	lz.text = ""
	kf.queue_free()
	p.queue_free()
	await process_frame


## MESS: steht jede Figur ganz im Bild (Füße und Kopf, mit Rand), wie groß der Held
func _ausschnitt(cam: Camera3D, figuren: Array, was: String) -> void:
	var vs := FORMAT
	var schirm := func(w: Vector3) -> Vector2:     # wie Camera3D.unproject_position im Format des Films (KEEP_HEIGHT)
		var q: Vector3 = cam.global_transform.affine_inverse() * w
		var t := tan(deg_to_rad(cam.fov) / 2.0) * -q.z
		return Vector2((q.x / (t * vs.x / vs.y) + 1.0) * vs.x / 2.0, (1.0 - q.y / t) * vs.y / 2.0).round()
	for f in figuren:
		if not f.visible:
			continue
		var fuss: Vector2 = schirm.call(f.position)
		var kopf: Vector2 = schirm.call(f.position + Vector3(0, (1.85 if f.fighter.monster == null else 0.9) * f.scale.y, 0))
		var drin := fuss.x > 0.04 * vs.x and fuss.x < 0.96 * vs.x and kopf.y > 0.13 * vs.y and fuss.y < 0.97 * vs.y
		print("BILD %s %s: Fuß %s, Kopf %s, Höhe %.0f %% %s" % [was, f.fighter.id, fuss, kopf, 100.0 * (fuss.y - kopf.y) / vs.y,
			"" if drin else "AUSSERHALB"])
		if not drin:
			fehler += 1


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(4, fs / 6))
	l.add_theme_font_size_override("font_size", fs)
	cl.add_child(l)
	return l
