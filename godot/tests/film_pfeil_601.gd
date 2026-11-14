# 601 (Chef 05.11., Build 266, t266.5: „Goblinspäher Schussanimation nicht vorhanden und Pfeil passt nicht // Bei Fehlschuss mit
# Bogen ist gar kein Pfeil zu sehen“): Film durch die echte Oberfläche, Echtzeit. Lage „Goblin-Späher und Goblin“: nur die Schüsse
# des Spähers (G4), je Schuss von der Seite auf Brusthöhe, Späher und Ziel ganz im Bild (G1): heben, Sehne ziehen, zielen, lösen,
# der Pfeil (Kaufmodell, Spur R3 gedämpft) fliegt und steckt im Ziel oder daneben im Boden. Zwischen den Schüssen schwarz und
# achtfach schnell; nach SCHUESSE Schüssen (mindestens ein Treffer und ein Fehlschuss, wenn sie in 40 Runden kommen) Ende.
# Aufruf (Bild, Probelauf nach 621 A): PROBE=601 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_pfeil_601.gd       MESS=1 ohne Bild: nur der Ablauf (Schüsse, Treffer, daneben)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const SCHUESSE := 3
const SCHNELL := 8.0
const BLENDE_BILDER := 6

var mess := OS.get_environment("MESS") != ""
var schwarz: ColorRect
var fehler := 0
var cam: Camera3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var deck := CanvasLayer.new()
	deck.layer = 128
	schwarz = ColorRect.new()
	schwarz.color = Color.BLACK
	schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
	schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deck.add_child(schwarz)
	root.add_child(deck)
	seed(7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "SCOUT"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 601: kein Kampfort")
		quit(1)
		return
	var m = kf.mars
	m.find("merc").auto = true
	m.find("hero").auto = true
	if not mess and not Signatur.wache(kf, self, "Film 601"):
		return
	var spaeher = null
	for id in kf.figures:
		if kf.figures[id].schuss != null:
			spaeher = kf.figures[id]
	if spaeher == null:
		print("FEHLER 601: kein Späher mit Schussbewegung (schuss.gd)")
		quit(1)
		return
	cam = Camera3D.new()
	cam.fov = 40.0
	kf.add_child(cam)
	var schuesse := 0
	var treffer := 0
	var daneben := 0
	var gesehen := {}
	var n := 0
	var im_schuss := false
	var nach := 0
	Engine.time_scale = SCHNELL
	while n < 30 * 400:
		await process_frame
		n += 1
		var an: bool = spaeher.schuss.an() and not spaeher.schuss._wartet
		var fliegt := false
		for pf in kf.ui.pfeile:
			if is_instance_valid(pf) and pf.phase in ["sehne", "flug"]:
				fliegt = true
			if is_instance_valid(pf) and not gesehen.has(pf.get_instance_id()):
				gesehen[pf.get_instance_id()] = true
				schuesse += 1
				if pf.missed:
					daneben += 1
				else:
					treffer += 1
				print("Film 601: Schuss %d nach %.1f s, %s, Pfeil %s, Spur %s" % [schuesse, n / 30.0, "daneben" if pf.missed else "Treffer",
					pf.koerper.get_meta("quelle"), "R3" if pf.spur != null else "ohne"])
				_stelle_kamera(spaeher, pf.on)
		if (an or fliegt) and not im_schuss:
			im_schuss = true
			nach = 0
			Engine.time_scale = 1.0
			cam.make_current()
			_schirm(kf, false)     # Ring und Zeilen sind auf die Spielkamera gerechnet; im Film nur der Schuss
			await _blende(0.0)
		elif im_schuss and not an and not fliegt:
			nach += 1
			if nach > 24:     # 0,8 s: der Pfeil steckt noch
				im_schuss = false
				await _blende(1.0)
				kf.cam.make_current()
				_schirm(kf, true)
				Engine.time_scale = SCHNELL
				if schuesse >= SCHUESSE and (treffer > 0 and daneben > 0 or schuesse >= SCHUESSE + 2):
					break
		if m.outcome != "ONGOING":
			break
		if kf.busy or kf.playing or not kf.beats.is_empty():
			continue
		kf.go_on()
	Engine.time_scale = 1.0
	if schuesse == 0:
		print("FEHLER 601: kein Schuss")
		fehler += 1
	print("Film 601 %s: %d Schüsse, %d Treffer, %d daneben, nach %.1f s" % ["Messung" if mess else "fertig", schuesse, treffer, daneben, n / 30.0])
	quit(1 if fehler > 0 else 0)


## von der Seite der Schusslinie, auf Brusthöhe, leicht von oben; Späher und Ziel ganz im Bild (G1), der Späher links
func _stelle_kamera(by, on) -> void:
	var a: Vector3 = by.position
	var b: Vector3 = on.position
	var mitte := (a + b) * 0.5
	var linie := (b - a) * Vector3(1, 0, 1)
	var weit := maxf(linie.length(), 1.0)
	var quer := Vector3(-linie.z, 0, linie.x).normalized()
	var vs: Vector2 = root.get_visible_rect().size
	var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov) / 2.0) * vs.x / maxf(vs.y, 1.0))
	var d := (weit * 0.5 + 1.2) / tan(hfov / 2.0)
	var hoch: float = maxf(by.head().y - by.position.y, 1.0) * 0.8
	cam.position = mitte + quer * d + Vector3.UP * (hoch + d * 0.12)
	cam.look_at(mitte + Vector3.UP * hoch * 0.8)


func _schirm(kf, an: bool) -> void:
	if kf.ui != null and "overlay" in kf.ui and kf.ui.overlay != null:
		kf.ui.overlay.visible = an


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)
