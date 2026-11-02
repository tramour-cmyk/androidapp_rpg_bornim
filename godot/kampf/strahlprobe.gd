# 415 (Chef 31.10., 20:3x, Archiv 414/415 „415 jetzt“; ausführen erlaubt 02.11., 10:53, „415 jetzt“ 10:55): Handyprobe Beams Free
# Sample (reeboolabs, gratis, Lizenz: im Spiel erlaubt, Dateien nie weitergeben, darum nur im privaten Repo bornim-kaufmodelle und
# beim Bau nach godot/addons/reeboo_beams kopiert, in .gitignore). Im Kampfort wie im Spiel (Probe: Magier gegen das Wolfsrudel,
# Toon-Licht, Tusche, Schatten): aus der Stabspitze des Magiers nacheinander die drei Strahlen der Probe auf den nächsten Wolf,
# je STRAHL_S Sekunden, dazwischen Pause. Oben Name des Strahls, Bilder je Sekunde (jetzt und Mittel je Strahl) und Renderer.
# „Renderer wechseln“ schreibt user://renderer_415.cfg (project.godot application/config/project_settings_override), wirkt nach
# Neustart der App; „Zurück“ lädt das Spiel neu (Hauptmenü). Kein Kampf: MARS bleibt stehen, die Figuren atmen.
# Aufruf im Spiel: Testmenü „Strahlen“; als Film: tests/film_415.gd (setzt film = true: ohne Knöpfe, Spielkamera).
extends Node

const Probe = preload("res://kampf/probe.gd")
const STRAHLEN := [["laser_blue", "Blauer Laser"], ["fire_stream", "Feuerstrom"], ["lightning_arc", "Blitzbogen"]]
const PFAD := "res://addons/reeboo_beams/beams_3d/%s.tscn"
const STRAHL_S := 4.0
const PAUSE_S := 1.2
const RENDERER_CFG := "user://renderer_415.cfg"

var film := false
var fertig := false     # film: alle Strahlen einmal durch
var probe
var kf
var held
var ziel: Node3D
var muendung: Node3D
var strahl: Node
var lb: Label
var mittel := {}     # Strahl -> [Summe fps, Bilder]
var jetzt := ""


static func da() -> bool:
	return ResourceLoader.exists(PFAD % "laser_blue")


func _ready() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	probe = Probe.new()
	probe.hero_cls = "WIZARD"
	probe.merc_cls = "FIGHTER"
	probe.foe = "WOLVES"
	add_child(probe)
	await get_tree().process_frame
	probe._start(7)
	for i in 6:
		await get_tree().process_frame
	kf = probe.fight
	_oberflaeche()
	if kf == null:
		lb.text = "Kampfort fehlt"
		return
	if kf.ui != null:
		kf.ui.visible = false
	held = kf.figures.get("hero")
	if not da():
		lb.text = "Strahlen fehlen: Paket nicht im Build (bornim-kaufmodelle, anhang/beams)"
		return
	ziel = Node3D.new()
	kf.add_child(ziel)
	muendung = Node3D.new()
	kf.add_child(muendung)
	# Prüfer Film 415 r1 (Lauf 171): Magier und Söldner nie im Bild (eigene Kamera im Hochformat zu eng), Strahl durch einen Wolf auf
	# einen zweiten außerhalb (Ziel gewählt, als das Rudel noch einlief). Jetzt die Spielkamera wie im Kampf (alle im Bild) und das Ziel
	# erst, wenn alle Figuren 1 s still stehen (höchstens 10 s)
	await _bis_still()
	while true:
		for s in STRAHLEN:
			await _feuer(s[0], s[1])
			await get_tree().create_timer(PAUSE_S).timeout
		if film:
			fertig = true
			return


## der nächste stehende Wolf, Ziel auf Brusthöhe
func _wolf():
	var best = null
	var d := INF
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster == null or f.down or not f.visible:
			continue
		var e: float = f.global_position.distance_to(held.global_position)
		if e < d:
			d = e
			best = f
	return best


func _feuer(art: String, name_: String) -> void:
	var w = _wolf()
	if w == null or held == null:
		return
	jetzt = name_
	strahl = (load(PFAD % art) as PackedScene).instantiate()
	strahl.auto_raycast = false
	strahl.target = ziel
	muendung.add_child(strahl)
	_richten(w)
	strahl.play()
	var t := 0.0
	while t < STRAHL_S:
		await get_tree().process_frame
		t += get_process_delta_time()
		_richten(w)
	strahl.stop()
	await get_tree().create_timer(0.8).timeout
	strahl.queue_free()
	strahl = null
	jetzt = ""


func _richten(w) -> void:
	ziel.global_position = w.global_position + Vector3(0, 0.45, 0)
	var p = held.cast_point()
	muendung.global_position = p if p is Vector3 else held.global_position + Vector3(0, 1.4, 0)
	if muendung.global_position.distance_to(ziel.global_position) > 0.05:
		muendung.look_at(ziel.global_position)


func _process(_dt: float) -> void:
	if lb == null:
		return
	var fps := Engine.get_frames_per_second()
	if jetzt != "":
		var m: Array = mittel.get(jetzt, [0.0, 0])
		m[0] += fps
		m[1] += 1
		mittel[jetzt] = m
	var z := PackedStringArray()
	z.append("415 Strahlenprobe · %s" % (jetzt if jetzt != "" else "–"))
	if film:     # im Film zählen die Bilder je Sekunde des Rechners, nicht des Handys
		lb.text = z[0]
		return
	z.append("%d Bilder/s · Renderer %s" % [fps, RenderingServer.get_current_rendering_method()])
	for s in STRAHLEN:
		if mittel.has(s[1]):
			z.append("%s: Mittel %.0f Bilder/s" % [s[1], mittel[s[1]][0] / maxf(mittel[s[1]][1], 1)])
	lb.text = "\n".join(z)


func _oberflaeche() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 100
	add_child(cl)
	var vs := get_viewport().get_visible_rect().size
	lb = Label.new()
	lb.position = Vector2(vs.x * 0.05, vs.y * 0.04)
	lb.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 14.0))
	lb.add_theme_color_override("font_outline_color", Color.BLACK)
	lb.add_theme_constant_override("outline_size", int(vs.x / 412.0 * 4.0))
	cl.add_child(lb)
	if film:
		return
	var reihe := HBoxContainer.new()
	reihe.position = Vector2(vs.x * 0.05, vs.y * 0.86)
	reihe.add_theme_constant_override("separation", int(vs.x * 0.04))
	cl.add_child(reihe)
	var k1 := Button.new()
	k1.text = "Renderer wechseln"
	k1.pressed.connect(_renderer_wechseln)
	reihe.add_child(k1)
	var k2 := Button.new()
	k2.text = "Zurück"
	k2.pressed.connect(func():     # der Kampfort hängt an der Wurzel (Probe._start), nicht unter dieser Szene
		if is_instance_valid(kf):
			kf.queue_free()
		get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene")))
	reihe.add_child(k2)
	for k in [k1, k2]:
		k.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 16.0))
		k.custom_minimum_size = Vector2(vs.x * 0.4, vs.y * 0.06)


## Mobile <-> Kompatibilität (OpenGL); wirkt nach Neustart (Godot liest die Datei vor dem Start des Renderers)
func _renderer_wechseln() -> void:
	var jetzt_r := RenderingServer.get_current_rendering_method()
	var neu := "gl_compatibility" if jetzt_r != "gl_compatibility" else "mobile"
	var cfg := ConfigFile.new()
	cfg.set_value("rendering", "renderer/rendering_method", neu)
	cfg.set_value("rendering", "renderer/rendering_method.mobile", neu)
	cfg.save(RENDERER_CFG)
	lb.text += "\nNach Neustart der App: %s" % neu


## wartet, bis keine Figur sich mehr als 2 cm in 1 s bewegt (Einlauf des Rudels, Aufstellung), höchstens 10 s
func _bis_still() -> void:
	var alt := {}
	var t := 0.0
	var ruhig := 0.0
	while t < 10.0 and ruhig < 1.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var weit := 0.0
		for id in kf.figures:
			var p: Vector3 = kf.figures[id].global_position
			if alt.has(id):
				weit = maxf(weit, p.distance_to(alt[id]))
			alt[id] = p
		ruhig = ruhig + dt if weit < 0.02 * dt else 0.0
