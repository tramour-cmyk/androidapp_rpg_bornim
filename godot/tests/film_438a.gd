# 438a (Chef 01.11., 11:47 „nicht beurteilen, wenn ich es nicht gesehen habe“; 11:49 „unsere viel zitierten 3 Varianten … bevor wir
# wieder Geld ausgeben und selbst entwickeln“): Sichtungsfilm Hinfallen und Aufstehen des Kaufhelden (Kämpfer mit Schwert und Schild)
# im Kampfort, im Spiellicht (Toon, Tusche nach Licht, Schatten), Spielkamera herangezogen. Je Kandidat aus dem Bestand: Kampfstehen,
# Hinfallen, liegen bleiben, Aufstehen, Kampfstehen; Nummer und Quelle oben. Die Regeln laufen nicht.
# Quellen: UAL Pro (UAL1.glb), die Protofactor-Sätze (Zauberer, Schwert & Schild, Einhand, Verletzt; zauber385.py je Bewegung eine .glb
# auf dem Gerüst der UAL), unsere Bewegung „Tod“ (kampf.py).
# Aufruf: B438A=<ordner mit den .glb> UAL_PRO=<UAL1.glb> PROBE=438a xvfb-run godot --path godot --rendering-driver opengl3
#   --resolution 1080x2340 --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_438a.gd
# MESS=1: ohne Film nur messen (Länge, Aufschlag, Lage des Beckens am Ende, welches Aufstehen zu welchem Liegen passt)
# SPIEL=1 (438a Runde 2, ohne B438A): Hinfallen 1 und Aufstehen 1 so, wie das Spiel sie spielt, Kämpfer und Kleriker, vorn und Seite
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const HeldFigur = preload("res://skripte/heldfigur.gd")
const Gebiet = preload("res://skripte/gebiet.gd")
const Signatur = preload("res://kampf/signatur.gd")

# Bewegungen aus den Protofactor-Sätzen (Datei = Name)
const PROTO := ["GetHitHeavyFrontSS", "DeathBackSS", "DeathFrontSS", "GetBackUpBackSS", "GetBackUpFrontSS", "DeathBack1hMelee",
	"GetBackUpBack", "GetBackUpFront", "GetHitFrontHeavyWizard", "GetHitBackHeavyWizard", "DeathBackWizard", "GetBackUpBackWizard",
	"GoToKneelInjuredA", "GoToKneelInjuredB", "GoToKneelInjuredC", "GoToKneelInjuredD", "GoToKneelInjuredE", "GoToKneelInjuredF",
	"GoToKneelInjuredG", "IdleKneelInjuredA", "GoToSitInjuredA", "GoToSitInjuredB", "GoToSitInjuredC", "GoToSitInjuredD",
	"GoToSitInjuredE", "GoToSitInjuredF", "GoToSitInjuredG", "SitToIdleInjuredA", "SitToIdleInjuredB", "SitToIdleInjuredC",
	"SitToIdleInjuredD", "SitToIdleInjuredE", "SitToIdleInjuredF", "SitToIdleInjuredG", "IdleSitInjuredA"]
const UAL := ["Death01", "Death02", "Crawl_Enter", "Crawl_Exit", "GroundSit_Enter", "GroundSit_Exit", "Hit_Chest"]

var fg: Node3D
var anim: AnimationPlayer
var sk: Skeleton3D
var lb: Label
var lz: Label


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf.ui != null:
		kf.ui.visible = false
	var bis := Time.get_ticks_msec() + 15000
	while kf.playing and Time.get_ticks_msec() < bis:
		await process_frame
	kf.playing = true     # keine Meldungen der Regeln mehr; _process des Kampforts läuft weiter (Tusche nach Licht)
	var kleriker = null
	for id in kf.figures:
		var f = kf.figures[id]
		f.set_process(false)
		if f.fighter.monster == null and fg == null and f.fighter.id != "merc":
			fg = f
		else:
			if f.fighter.id == "merc":
				kleriker = f
			f.visible = false
	anim = fg.anim
	sk = _find(fg, "Skeleton3D") as Skeleton3D
	if not fg.kauf:
		print("FEHLER: kein Kaufheld (daten/kampf-bewegungen.bin, held_FIGHTER.bin)")
		quit(1)
		return
	var ordner := OS.get_environment("B438A")
	for n in PROTO:
		_dazu(ordner.path_join(n + ".glb"), [n])
	if OS.get_environment("UAL_PRO") != "":
		_dazu(OS.get_environment("UAL_PRO"), UAL)
	var mitte: Vector3 = kf._ground(0, 0)
	var cam: Camera3D = kf.cam
	var vorn: Vector3 = cam.global_position - mitte
	vorn.y = 0.0
	vorn = vorn.normalized()
	fg.position = mitte
	fg.rotation = Vector3(0, atan2(vorn.x, vorn.z) + deg_to_rad(float(OS.get_environment("DREH")) if OS.get_environment("DREH") != "" else 40.0), 0)
	if OS.get_environment("MESS") != "":
		_messen()
		quit(0)
		return
	# Spielkamera (waagerecht, Linse verschoben) herangezogen: Held mittig, stehend etwa 40 % der Bildhöhe
	var vs: Vector2 = root.get_visible_rect().size
	_spiel("Kampfstehen", 0.0)
	await process_frame
	var fuss := cam.unproject_position(mitte)
	var kopf := cam.unproject_position(mitte + Vector3(0, 1.85 * fg.scale.y, 0))
	var z := clampf(vs.y * 0.40 / maxf(fuss.y - kopf.y, 1.0), 1.0, 6.0)
	var c := Vector2(fuss.x, (fuss.y + kopf.y) * 0.5 + (fuss.y - kopf.y) * 0.12)
	var per: float = kf.base_size / vs.y
	cam.size = kf.base_size / z
	cam.frustum_offset = Vector2(kf.base_off.x + (c.x - vs.x / 2.0) * per, kf.base_off.y - (c.y - vs.y / 2.0) * per)
	kf.base_size = cam.size
	kf.base_off = cam.frustum_offset
	if not Signatur.wache(kf, self, "Film 438a"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
		return
	var cl := CanvasLayer.new()
	root.add_child(cl)
	lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 17.0), Color(0.95, 0.82, 0.45))
	lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.085), int(vs.x / 30.0), Color(0.92, 0.88, 0.80))
	lz.size = Vector2(vs.x * 0.92, vs.y * 0.1)
	lz.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	print("Film Start Bild %d" % Engine.get_frames_drawn())
	if OS.get_environment("SPIEL") != "":
		# 438a Runde 2: Hinfallen 1 und Aufstehen 1 so, wie das Spiel sie spielt (knocked_down, rise), Waffe und Schild nach dem Paket,
		# aus Boden und Körper gehalten (figur.gd _boden_schutz, bodenhalt.gd); Kämpfer und Kleriker, je von vorn und von der Seite
		var wer := [[fg, "Kämpfer"], [kleriker, "Kleriker"]]
		for w in wer:
			if w[0] == null:
				continue
			for seite in [[40.0, "schräg von vorn"], [130.0, "von der Seite"]]:
				for x in wer:
					if x[0] != null:
						x[0].visible = x[0] == w[0]
				var f = w[0]
				f.position = mitte
				f.rotation = Vector3(0, atan2(vorn.x, vorn.z) + deg_to_rad(seite[0]), 0)
				lb.text = "%s · %s" % [w[1], seite[1]]
				lz.text = "Hinfallen 1 und Aufstehen 1 (Schwert & Schild), Waffe und Schild nach dem Paket, frei von Boden und Körper"
				f.anim.play("SS_IdleCombat", 0.2)
				await _warte(0.8)
				f.knocked_down()
				await _warte(f.anim.get_animation("SS_DeathBack").length + 0.6)
				f.rise()
				await _warte(f.anim.get_animation("SS_GetBackUpBack").length + 0.8)
		lb.text = ""
		lz.text = ""
		await create_timer(0.3).timeout
		quit(0)
		return
	for k in _kandidaten():
		lb.text = k[0]
		lz.text = k[1]
		for s in k[2]:
			await _stueck(s)
	lb.text = ""
	lz.text = ""
	await create_timer(0.3).timeout
	quit(0)


## Kandidaten: [Titel, Zeile, Folge]; Folge aus [Bewegung, von, bis, rückwärts] (bis -1 = Ende, -2 = Aufschlag) und ["halt", s]
func _kandidaten() -> Array:
	var r := []
	var st := ["Kampfstehen", 0, 0.6, false]
	r.append(["1 · Schwert & Schild", "schwerer Treffer, rücklings hin; Aufstehen aus der Rückenlage",
		[st, ["GetHitHeavyFrontSS", 0, 0.5, false], ["DeathBackSS", 0, -1, false], ["halt", 0.5], ["GetBackUpBackSS", 0, -1, false], st]])
	r.append(["2 · Schwert & Schild", "vornüber hin; Aufstehen aus der Bauchlage",
		[st, ["DeathFrontSS", 0, -1, false], ["halt", 0.5], ["GetBackUpFrontSS", 0, -1, false], st]])
	r.append(["3 · Einhandwaffe", "rücklings hin; Aufstehen aus der Rückenlage",
		[st, ["DeathBack1hMelee", 0, -1, false], ["halt", 0.5], ["GetBackUpBack", 0, -1, false], st]])
	r.append(["4 · Zauberer-Satz", "GetHit Heavy, Death Back, GetBackUp",
		[st, ["GetHitFrontHeavyWizard", 0, 0.5, false], ["DeathBackWizard", 0, -1, false], ["halt", 0.5], ["GetBackUpBackWizard", 0, -1, false], st]])
	r.append(["5 · UAL Pro Death01", "bis zum Aufschlag; dieselbe Bewegung rückwärts als Aufstehen",
		[st, ["Death01", 0, -2, false], ["halt", 0.6], ["Death01", 0, -2, true], st]])
	r.append(["6 · UAL Pro Death02", "Anfang: in die Knie; rückwärts als Aufstehen",
		[st, ["Death02", 0, 0.6, false], ["halt", 0.6], ["Death02", 0, 0.6, true], st]])
	r.append(["7 · eigene Bewegung (kampf.py)", "Anfang von „Tod“: in die Knie, Sitzen; rückwärts als Aufstehen",
		[st, ["Tod", 0, 0.6, false], ["halt", 0.6], ["Tod", 0, 0.6, true], st]])
	r.append(["8 · UAL Pro Kriechen", "Crawl_Enter, Crawl_Exit",
		[st, ["Crawl_Enter", 0, -1, false], ["halt", 0.4], ["Crawl_Exit", 0, -1, false], st]])
	r.append(["9 · UAL Pro Bodensitz", "GroundSit_Enter, GroundSit_Exit",
		[st, ["GroundSit_Enter", 0, -1, false], ["halt", 0.4], ["GroundSit_Exit", 0, -1, false], st]])
	r.append(["10 · Verletzt A", "in die Knie, hinsetzen, aufstehen (GoToKneel, GoToSit, SitToIdle)",
		[st, ["GoToKneelInjuredA", 0, -1, false], ["GoToSitInjuredA", 0, -1, false], ["halt", 0.4], ["SitToIdleInjuredA", 0, -1, false], st]])
	for v in ["B", "C", "D", "E", "F", "G"]:
		r.append(["11%s · Verletzt %s: in die Knie" % [v, v], "GoToKneelInjured%s (Aufstehen dazu unter 12%s)" % [v, v],
			[["Kampfstehen", 0, 0.4, false, 0.0], ["GoToKneelInjured" + v, 0, -1, false]]])
	for v in ["B", "C", "D", "E", "F", "G"]:
		r.append(["12%s · Verletzt %s: vom Sitzen aufstehen" % [v, v], "SitToIdleInjured%s" % v,
			[["IdleSitInjuredA", 0, 0.3, false, 0.0], ["SitToIdleInjured" + v, 0, -1, false], ["Kampfstehen", 0, 0.4, false]]])
	r.append(["13 · Taumeln ohne Sturz", "schwere Treffer: Schwert & Schild, Zauberer-Satz, UAL Pro Hit_Chest",
		[["Kampfstehen", 0, 0.4, false], ["GetHitHeavyFrontSS", 0, -1, false], ["Kampfstehen", 0, 0.4, false],
		 ["GetHitFrontHeavyWizard", 0, -1, false], ["Kampfstehen", 0, 0.4, false], ["Hit_Chest", 0, -1, false], st]])
	return r


func _stueck(s: Array) -> void:
	if s[0] == "halt":
		anim.speed_scale = 0.0
		await _warte(float(s[1]))
		anim.speed_scale = 1.0
		return
	var n: String = s[0]
	if not anim.has_animation(n):
		print("fehlt: %s" % n)
		return
	var lang := anim.get_animation(n).length
	var von: float = s[1]
	var bis: float = s[2]
	if bis == -1.0:
		bis = lang
	elif bis == -2.0:
		bis = _aufschlag(n)
	elif bis == -3.0:
		bis = _sitzen(n)
	elif n == "Kampfstehen":
		pass
	else:
		bis = minf(bis, lang)
	var rueck: bool = s[3]
	var blend: float = s[4] if s.size() > 4 else 0.15     # 0: harter Schnitt (neuer Kandidat beginnt im Knien oder Sitzen)
	if n == "Kampfstehen":
		_spiel(n, s[4] if s.size() > 4 else 0.25)
		await _warte(bis)
		return
	anim.play(n, blend, -1.0 if rueck else 1.0, false)
	anim.seek(bis if rueck else von, true)
	var t := 0.0
	while t < bis - von:
		await process_frame
		_schatten()
		t += 1.0 / 30.0     # Bilder bei --fixed-fps 30
	print("Stück %s %s %.2f–%.2f s" % [n, "rückwärts" if rueck else "", von, bis])


func _spiel(n: String, blend: float) -> void:
	if anim.has_animation(n):
		anim.play(n, blend)


func _warte(s: float) -> void:
	var t := 0.0
	while t < s:
		await process_frame
		_schatten()
		t += 1.0 / 30.0


## der weiche Bodenschatten folgt dem Becken am Boden (sonst bliebe er am Standort, wenn der Held 0,7 m nach hinten fällt)
var _sh0 = null

func _schatten() -> void:
	var sh := fg.get_node_or_null("Bodenschatten") as Node3D
	if sh == null:
		return
	if _sh0 == null:
		_sh0 = sh.position
	var b := sk.find_bone("pelvis")
	var p: Vector3 = fg.global_transform.affine_inverse() * (sk.global_transform * sk.get_bone_global_pose(b).origin)
	sh.position = Vector3(_sh0.x + p.x / fg.scale.x, _sh0.y, _sh0.z + p.z / fg.scale.z)


## Bewegungen einer .glb (Gerüst der UAL) dem Kaufhelden geben, wie figur.gd _kaufheld die Kampfbewegungen
func _dazu(pfad: String, namen: Array) -> void:
	if not FileAccess.file_exists(pfad):
		print("fehlt Datei %s" % pfad)
		return
	var sc := Gebiet.lade_glb(pfad)
	var ap := _find(sc, "AnimationPlayer") as AnimationPlayer
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / HeldFigur.bew_becken
	var weg := str(HeldFigur._pfad(fg.model, sk))
	var lib := anim.get_animation_library("")
	for n in namen:
		if ap == null or not ap.has_animation(n):
			print("fehlt Bewegung %s in %s" % [n, pfad.get_file()])
			continue
		var an := ap.get_animation(n).duplicate(true) as Animation
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [weg, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		an.loop_mode = Animation.LOOP_NONE
		if lib.has_animation(n):
			lib.remove_animation(n)
		lib.add_animation(n, an)
	sc.free()


## Zeit, zu der der Kopf zum ersten Mal fast am tiefsten ist (Aufschlag)
func _aufschlag(n: String) -> float:
	var hs := _hoehen(n, "Head")
	var lo := 99.0
	for h in hs: lo = minf(lo, h[1])
	for h in hs:
		if h[1] <= lo + 0.04:
			return h[0]
	return anim.get_animation(n).length


## Zeit, zu der das Becken zum ersten Mal fast am tiefsten ist (Sitzen)
func _sitzen(n: String) -> float:
	var hs := _hoehen(n, "pelvis")
	var lo := 99.0
	for h in hs: lo = minf(lo, h[1])
	for h in hs:
		if h[1] <= lo + 0.03:
			return h[0]
	return anim.get_animation(n).length


var _hoehe_cache := {}

func _hoehen(n: String, knochen: String) -> Array:
	var key := n + "/" + knochen
	if _hoehe_cache.has(key):
		return _hoehe_cache[key]
	var r := []
	var alt := anim.current_animation
	var lang := anim.get_animation(n).length
	anim.play(n, 0.0)
	var b := sk.find_bone(knochen)
	var t := 0.0
	while t <= lang + 0.001:
		anim.seek(t, true)
		r.append([t, (sk.global_transform * sk.get_bone_global_pose(b).origin).y - fg.global_position.y])
		t += 1.0 / 30.0
	if alt != "":
		anim.play(alt, 0.0)
	_hoehe_cache[key] = r
	return r


func _lage(n: String, t: float) -> Dictionary:
	anim.play(n, 0.0)
	anim.seek(t, true)
	var d := {}
	for bn in ["pelvis", "Head", "hand_l", "hand_r", "foot_l", "foot_r", "spine_03", "calf_l", "calf_r"]:
		var b := sk.find_bone(bn)
		if b >= 0:
			d[bn] = fg.global_transform.affine_inverse() * (sk.global_transform * sk.get_bone_global_pose(b).origin)
	return d


func _messen() -> void:
	var faelle := ["DeathBackSS", "DeathFrontSS", "DeathBack1hMelee", "DeathBackWizard", "Death01", "Death02", "Tod", "Crawl_Enter",
		"GroundSit_Enter", "GoToKneelInjuredA", "GoToSitInjuredA"]
	var auf := ["GetBackUpBackSS", "GetBackUpFrontSS", "GetBackUpBack", "GetBackUpFront", "GetBackUpBackWizard", "Crawl_Exit",
		"GroundSit_Exit", "SitToIdleInjuredA"]
	for n in faelle + auf + ["GetHitHeavyFrontSS", "GetHitFrontHeavyWizard", "Hit_Chest", "IdleKneelInjuredA", "IdleSitInjuredA"]:
		if not anim.has_animation(n):
			print("MESS fehlt %s" % n)
			continue
		var lang := anim.get_animation(n).length
		var a := _lage(n, 0.0)
		var e := _lage(n, lang)
		print("MESS %s: %.2f s, Aufschlag %.2f s, Becken %s -> %s, Kopf %s -> %s" % [n, lang, _aufschlag(n), a.pelvis.snapped(Vector3.ONE * 0.01),
			e.pelvis.snapped(Vector3.ONE * 0.01), a.Head.snapped(Vector3.ONE * 0.01), e.Head.snapped(Vector3.ONE * 0.01)])
	# Boden: tiefstes Gelenk (Füße, Hände, Becken, Kopf) über die ganze Bewegung, Füße im ersten und letzten Bild (Knöchel ~0,08 m)
	for n in PROTO + UAL + ["Tod"]:
		if not anim.has_animation(n): continue
		var lang := anim.get_animation(n).length
		var tief := 99.0
		var t := 0.0
		while t <= lang + 0.001:
			var l := _lage(n, t)
			for bn in l: tief = minf(tief, l[bn].y)
			t += 0.1
		var a := _lage(n, 0.0)
		var e := _lage(n, lang)
		print("BODEN %s: tiefstes Gelenk %.2f m, Füße Anfang %.2f/%.2f, Ende %.2f/%.2f, Länge %.2f s" % [n, tief, a.foot_l.y, a.foot_r.y,
			e.foot_l.y, e.foot_r.y, lang])
	for n in ["Tod", "Death01", "Death02"]:
		var hs := _hoehen(n, "pelvis")
		var z := []
		for i in range(0, hs.size(), 3):
			z.append("%.1f:%.2f" % [hs[i][0], hs[i][1]])
		print("REIHE %s Becken %s" % [n, " ".join(z)])
	# welches Aufstehen beginnt, wie ein Fall endet: mittlerer Abstand der Gelenke (Becken abgezogen), m
	for n in faelle:
		if not anim.has_animation(n): continue
		var e := _lage(n, _aufschlag(n) if n != "Tod" else _sitzen(n))
		var zeile := []
		for m in auf:
			if not anim.has_animation(m): continue
			var s := _lage(m, 0.0)
			var sum := 0.0
			for bn in e:
				sum += ((e[bn] - e.pelvis) - (s[bn] - s.pelvis)).length()
			zeile.append("%s %.2f" % [m, sum / e.size()])
		print("PASST %s: %s" % [n, ", ".join(zeile)])


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(4, fs / 6))
	l.add_theme_font_size_override("font_size", fs)
	cl.add_child(l)
	return l


func _find(n: Node, cls: String) -> Node:
	if n.is_class(cls):
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null
