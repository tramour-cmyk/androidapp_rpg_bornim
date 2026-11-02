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
# r3 (Tor 461a, Lauf 172: F6 alle Strahlen aus Hals und Schulter, der Magier stand ohne Zauberbewegung; F2 ein Bild Laser in den
# Himmel; E3 der graue Wolf lief in den Feuerstrom, der Strahl ging durch ihn): erst Zauberbewegung (Ausholen, wie im Kampf strike),
# der Strahl ab AUSHOLEN_S und erst sichtbar, wenn die Mündung ausgerichtet ist; er endet am ersten Körper zwischen Stab und Ziel
const AUSHOLEN_S := 0.45
const SICHTBAR_NACH := 2     # Bilder nach play(), bis der Strahl sichtbar wird (ausgerichtet)
const BRUST := 0.45          # Zielhöhe über dem Boden des Wolfs, m

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
var dreh_grad := 0.0     # Messung strahl_mess_415: der Magier dreht sich so viel weiter als zum Ziel (Stabspitze frei vom Körper)
var wolf_jetzt = null    # Messung: Ziel des laufenden Strahls
var sichtbar := false    # Messung: Strahl sichtbar
var getroffen = null     # Messung: Figur, an der der Strahl endet (Ziel oder Körper dazwischen)


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


## der nächste stehende Wolf mit freier Linie von der Stabspitze, sonst der nächste; Ziel auf Brusthöhe
func _wolf():
	var liste := []
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster == null or f.down or not f.visible:
			continue
		liste.append([f.global_position.distance_to(held.global_position), f])
	liste.sort_custom(func(a, b): return a[0] < b[0])
	var p = held.cast_point()
	var von: Vector3 = p if p is Vector3 else held.global_position + Vector3(0, 1.4, 0)
	for e in liste:
		if _erster_koerper(von, e[1].global_position + Vector3(0, BRUST, 0), e[1])[0] == null:
			return e[1]
	return liste[0][1] if not liste.is_empty() else null


## erste Figur (außer Magier und [ziel]) auf der Strecke von [a] nach [b], mit dem Punkt, an dem der Strahl sie trifft: [Figur, Punkt]
## oder [null, b]. Körper aus den Kapseln (figur.gd kapseln), in Schritten von 2 cm
func _erster_koerper(a: Vector3, b: Vector3, ziel_) -> Array:
	var kaps := []
	for id in kf.figures:
		var f = kf.figures[id]
		if f == held or f == ziel_ or f.down or not f.visible:
			continue
		for c in f.kapseln():
			kaps.append([f, c[0], c[1], float(c[2])])
	var l := a.distance_to(b)
	var n := int(l / 0.02) + 1
	for i in range(1, n + 1):
		var q := a.lerp(b, float(i) / n)
		for k in kaps:
			if q.distance_to(Geometry3D.get_closest_point_to_segment(q, k[1], k[2])) < k[3]:
				return [k[0], q]
	return [null, b]


func _feuer(art: String, name_: String) -> void:
	var w = _wolf()
	if w == null or held == null:
		return
	jetzt = name_
	wolf_jetzt = w
	# Zauberbewegung wie im Kampf (figur.gd strike: Ausholen), zum Ziel gedreht; der Strahl erst danach
	var lang := AUSHOLEN_S + STRAHL_S + 0.3
	held.busy_ms = maxi(held.busy_ms, int(lang * 1000.0))
	_drehen((w.global_position - held.global_position).rotated(Vector3.UP, deg_to_rad(dreh_grad)))
	held._play("Ausholen")
	await get_tree().create_timer(AUSHOLEN_S).timeout
	strahl = (load(PFAD % art) as PackedScene).instantiate()
	strahl.auto_raycast = false
	strahl.target = ziel
	if strahl is Node3D:
		(strahl as Node3D).visible = false
	muendung.add_child(strahl)
	_richten(w)
	strahl.play()
	var t := 0.0
	var bilder := 0
	while t < STRAHL_S:
		await get_tree().process_frame
		t += get_process_delta_time()
		_richten(w)
		bilder += 1
		if bilder == SICHTBAR_NACH and strahl is Node3D:
			(strahl as Node3D).visible = true
			sichtbar = true
	strahl.stop()
	sichtbar = false
	await get_tree().create_timer(0.8).timeout
	strahl.queue_free()
	strahl = null
	jetzt = ""
	wolf_jetzt = null
	_drehen(Vector3.ZERO)
	held._idle()


## weich zur Richtung [dir] (null: Grundrichtung) in 0,3 s, nicht in einem Bild (D1)
func _drehen(dir: Vector3) -> void:
	var r0: float = held.rotation.y
	held._face(dir)
	var r1: float = r0 + wrapf(held.rotation.y - r0, -PI, PI)
	held.rotation.y = r0
	if absf(r1 - r0) > 0.01:
		held.create_tween().tween_property(held, "rotation:y", r1, 0.3).set_trans(Tween.TRANS_SINE)


func _richten(w) -> void:
	var p = held.cast_point()
	muendung.global_position = p if p is Vector3 else held.global_position + Vector3(0, 1.4, 0)
	# endet am ersten Körper zwischen Stab und Ziel (E3)
	var e := _erster_koerper(muendung.global_position, w.global_position + Vector3(0, BRUST, 0), w)
	getroffen = e[0] if e[0] != null else w
	ziel.global_position = e[1]
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
