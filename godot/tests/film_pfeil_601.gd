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
## Einzelbilder für den Ersteller (783 W1, PROBEBILD=601 …, kein Film): OUT=<Ordner> legt je Schuss Zielen, Flug und Stecken ab
var out := OS.get_environment("OUT")
var _geknipst := {}
var schwarz: ColorRect
var fehler := 0
var cam: Camera3D
var p_cam: Camera3D     # Kamera des Kampforts


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
	# der Kampf soll nicht enden, bevor der Späher dreimal geschossen hat: beide Seiten mit viel Leben (nur für den Film)
	for f in m.all:
		f.max_hp = 999
		f.hp = 999
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
	p_cam = kf.cam
	cam = Camera3D.new()
	cam.fov = 50.0
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
		if out != "":
			for tz in [0.3, 0.6, 0.75, 0.95, 1.1]:
				if an and spaeher.schuss.t > tz:
					_knips("t%03d-%d" % [int(tz * 100), schuesse])
			for pf in kf.ui.pfeile:
				if is_instance_valid(pf) and pf.phase == "flug" and pf.t - pf.los_s > pf.flug_s * 0.5:
					_knips("flug-%d" % schuesse)
				if is_instance_valid(pf) and pf.phase == "steckt":
					_knips("steckt-%d" % schuesse)
		# kommt als Nächstes ein Schuss des Spähers: Züge kurz anhalten (messpause, 806), Echtzeit, Kamera von der Seite auf ihn und den
		# nächsten Helden, aufblenden, dann weiter
		if not im_schuss and not kf.playing and not kf.beats.is_empty():
			var b0: Dictionary = kf.beats[0]
			if b0.has("say") and str(b0.say.get("actor", "")) == str(spaeher.fighter.id) and b0.say.get("roll") != null:
				kf.messpause = true
				im_schuss = true
				nach = 0
				Engine.time_scale = 1.0
				_stelle_kamera(spaeher, _naechster_held(kf, spaeher))
				cam.make_current()
				_schirm(kf, false)     # Ring und Zeilen sind auf die Spielkamera gerechnet; im Film nur der Schuss
				await _blende(0.0)
				await create_timer(0.3).timeout
				kf.messpause = false
		if im_schuss and not an and not fliegt and not kf.messpause:
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


## schräg hinter dem Späher von der Seite (drei Viertel): der Späher groß vorn links, das Ziel hinten, die Bahn des Pfeils dazwischen
## (G4: der Schuss gut zu sehen; im Hochformat passte die reine Seitenansicht nur mit 14 m Abstand); beide ganz im Bild (G1), die
## Figuren über dem Kampfschirm (unteres Drittel)
func _stelle_kamera(by, on) -> void:
	var a: Vector3 = by.global_position
	var b: Vector3 = on.global_position
	var linie := (b - a) * Vector3(1, 0, 1)
	var weit := maxf(linie.length(), 1.0)
	var vor := linie.normalized()
	var quer := Vector3(-vor.z, 0, vor.x)
	# die Seite, auf der die Kamera des Kampforts steht (dort ist die Lichtung frei)
	if p_cam != null and quer.dot(p_cam.global_position - a) < 0.0:
		quer = -quer
	var hoch: float = maxf(by.head().y - by.position.y, 0.6)
	var mitte := (a + b) * 0.5
	var zur_kamera := (quer * cos(deg_to_rad(30.0)) - vor * sin(deg_to_rad(30.0))).normalized()
	var vs: Vector2 = root.get_visible_rect().size
	var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov) / 2.0) * vs.x / maxf(vs.y, 1.0))
	var d := (weit * 0.5 * cos(deg_to_rad(30.0)) + 0.5) / tan(hfov / 2.0)
	cam.global_position = mitte + zur_kamera * d + Vector3.UP * (hoch * 0.9 + d * 0.08)
	cam.look_at(mitte.lerp(a, 0.2) + Vector3.UP * hoch * 0.5)
	cam.rotate_object_local(Vector3.RIGHT, -deg_to_rad(cam.fov) / 6.0)


func _naechster_held(kf, by):
	var best = null
	for id in kf.figures:
		var o = kf.figures[id]
		if o.fighter.monster == null and (best == null or o.position.distance_to(by.position) < best.position.distance_to(by.position)):
			best = o
	return best


func _knips(name: String) -> void:
	if _geknipst.has(name):
		return
	_geknipst[name] = true
	root.get_texture().get_image().save_png("%s/601-%s.png" % [out, name])
	print("BILD 601 %s" % name)


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
