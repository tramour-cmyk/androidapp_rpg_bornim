# 1036 (Chef 12.11., 14:48, Build 280: „da sieht man kein Brennen. Das hatten wir alles schon unter Kotlin, die ganzen Effekte,
# die sichtbaren“): die Zustände an den Figuren im Probekampf (Kämpfer, Söldner Kleriker, Wölfe). Je Zustand trägt ihn der Held
# und ein Wolf PHASE_MS lang (nur gezeigt, nicht gerechnet), dann flackert je Schadenszustand einmal der Schaden der Runde auf.
# Ohne Bild (Test im Bau): je Zustand zeichnet die Tafel etwas (Ecken > 0; Bluten nur mit Blut an), der betäubte Wolf schwankt
# und steht nach dem Ende wieder an seinem Platz, das Aufflackern kommt; Exit = Zahl der Fehler. Mit Bild (Film, kampf=1036 in
# godot.yml): dieselbe Folge, oben der Name des Zustands.
# Aufruf: im Ordner godot --headless --fixed-fps 30 -s res://tests/zustand_1036.gd (braucht daten/ und kampf/daten/ wie im Bau)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Signatur = preload("res://kampf/signatur.gd")
const ZUST := ["BURN", "POISON", "BLEED", "STUN", "SLOW", "WEAK", "BLIND", "DRUNK"]
const FPS := 30.0

var kf
var fehler := 0
var schild: Label


func _initialize() -> void:
	_lauf.call_deferred()


func _env(n: String, d: String) -> String:
	return OS.get_environment(n) if OS.get_environment(n) != "" else d


func _bilder(n: int) -> void:
	for i in n:
		await process_frame


func _fehler(was: String) -> void:
	fehler += 1
	print("FEHLER ", was)


func _lauf() -> void:
	var film := DisplayServer.get_name() != "headless"
	var phase := int(int(_env("PHASE_MS", "2600" if film else "300")) / 1000.0 * FPS)
	seed(7)
	var p = Probe.new()
	p.hero_cls = _env("KLASSE", "FIGHTER")
	p.merc_cls = _env("SOELDNER", "CLERIC")
	p.foe = _env("GEGNER", "WOLVES")
	root.add_child(p)
	await process_frame
	p._start(7)
	await _bilder(4)
	kf = p.fight
	if film:
		if not Signatur.wache(kf, self, "Zustände 1036"):
			quit(1)
			return
		_schild_anlegen()
	while kf.verhuellt:
		await process_frame
	var n := 0
	while (kf.busy or kf.playing or not kf.beats.is_empty()) and n < int(FPS) * 60:
		await process_frame
		n += 1
	var ui = kf.ui
	var wolf := ""
	for f in kf.mars.fighters():
		if f.side == "FOES" and f.standing() and kf.figures.has(f.id):
			wolf = String(f.id)
			break
	if wolf == "" or not kf.figures.has("hero"):
		_fehler("kein Wolf oder kein Held im Probekampf")
		quit(fehler)
		return
	var fig_w = kf.figures[wolf]
	var platz: Vector3 = fig_w.model.position
	var blut: int = kf.blood_level()
	var max_us := 0
	for st in ZUST:
		kf.shown["status"] = {wolf: {st: 3}, "hero": {st: 3}}
		if schild:
			schild.text = String(Mars.STATUS[st][0][0])
		var ecken := 0
		var schwankt := 0.0
		for i in phase:
			await process_frame
			if ui.tafel != null:
				ecken = maxi(ecken, int(ui.tafel.verts))
				max_us = maxi(max_us, int(ui.tafel_us))
			schwankt = maxf(schwankt, fig_w.taumel_off.length())
		var soll := not (st == "BLEED" and blut <= 0)
		print("Zustand %s: Ecken %d, Schwanken %.3f m" % [st, ecken, schwankt])
		if soll and ecken == 0:
			_fehler("%s zeichnet nichts" % st)
		if st == "STUN" and schwankt < 0.005:
			_fehler("der betäubte Wolf schwankt nicht (%.3f m)" % schwankt)
	kf.shown["status"] = {}
	if schild:
		schild.text = ""
	await _bilder(int(FPS))
	if fig_w.model.position.distance_to(platz) > 0.001:
		_fehler("der Wolf steht nach dem Betäuben nicht an seinem Platz (%.3f m)" % fig_w.model.position.distance_to(platz))
	# je Schadenszustand einmal das Aufflackern der Runde (mars.gd _tick: ohne Täter, Zeile nach ST_HURTS)
	for st in ["BURN", "POISON", "BLEED"]:
		var f = kf.mars.find(wolf)
		var e: Dictionary = kf.shown.duplicate()
		e["actor"] = null
		e["target"] = wolf
		e["damage"] = 2
		e["text"] = String(Mars.ST_HURTS[st][ui.lang]).format([f.name(ui.lang)])
		e["status"] = {wolf: {st: 2}}
		kf.shown = e
		if schild:
			schild.text = String(Mars.STATUS[st][0][0]) + ": Schaden der Runde"
		await _bilder(2)
		var da := false
		for fl in ui.flares:
			if String(fl.on) == wolf and String(fl.st) == st:
				da = true
		print("Aufflackern %s: %s" % [st, "ja" if da else "nein"])
		if not da:
			_fehler("kein Aufflackern bei %s" % st)
		await _bilder(int(FPS * 1.5) if film else 20)
	print("Tafel höchstens %d µs je Bild" % max_us)
	print("ZUSTAND1036 %d Fehler" % fehler)
	quit(fehler)


func _schild_anlegen() -> void:
	var deck := CanvasLayer.new()
	deck.layer = 100
	schild = Label.new()
	schild.position = Vector2(24, 150)
	schild.add_theme_font_size_override("font_size", 34)
	schild.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	schild.add_theme_color_override("font_outline_color", Color.BLACK)
	schild.add_theme_constant_override("outline_size", 8)
	deck.add_child(schild)
	root.add_child(deck)
