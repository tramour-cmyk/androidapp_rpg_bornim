# 1222 (Chef 13.11., 20:39, t284.4b: Rauchbündel gegen Krogg „ohne sichtbare Wirkung“): Film durch die echte Oberfläche,
# Spielkamera, Echtzeit. Lage Krogg mit Morwens Rauchbündel: der Held wirft es zu Kampfbeginn (zauber.gd _smoke_bundle), es platzt
# an Kroggs Kopf, Kroggs erster Schlag geht ins Leere ([1232.rauch.krogg]); danach noch 3 s, dann Ende.
# Aufruf (Bild, Probelauf nach 621 A): PROBE=1222 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_rauch_1222.gd       MESS=1 ohne Bild: nur der Ablauf (Wurf, Rauch, Zeile)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const Mars = preload("res://regeln/mars.gd")
const BLENDE_BILDER := 8

var mess := OS.get_environment("MESS") != ""
var schwarz: ColorRect
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


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
	seed(5)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "KROGG"
	p.rauch = 1
	root.add_child(p)
	await process_frame
	p._start(5)
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 1222: kein Kampfort")
		quit(1)
		return
	var m = kf.mars
	m.find("merc").auto = true
	m.find("hero").auto = true
	if not mess and not Signatur.wache(kf, self, "Film 1222"):
		return
	await _blende(0.0)
	if not kf.busy:
		kf.go_on()
	var flog := false
	var zeile := -1.0
	var n := 0
	var zeile_de: String = Mars.MSG1232_RAUCH[0].left(20)
	while n < 30 * 40:
		await process_frame
		n += 1
		for sp in kf.ui.spells:
			if String(sp.kind) == "BOMB_SMOKE" and not flog:
				flog = true
				print("Film 1222: Rauchbündel fliegt nach %.1f s" % (n / 30.0))
		if zeile < 0.0 and String(kf.shown.get("text", "")).contains(zeile_de.substr(zeile_de.find(" ") + 1)):
			zeile = n / 30.0
			print("Film 1222: Zeile „%s“ nach %.1f s" % [kf.shown.text, zeile])
		if zeile >= 0.0 and n / 30.0 > zeile + 3.0:
			break
		if m.outcome != "ONGOING":
			break
		if kf.busy or kf.playing or not kf.beats.is_empty():
			continue
		kf.go_on()
	if not flog:
		print("FEHLER 1222: kein Rauchbündel geflogen")
		fehler += 1
	if zeile < 0.0:
		print("FEHLER 1222: keine Rauchzeile")
		fehler += 1
	print("Film 1222 %s nach %.1f s" % ["Messung: %d Befunde" % fehler if mess else "fertig", n / 30.0])
	await _blende(1.0)
	quit(1 if fehler > 0 else 0)


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)
