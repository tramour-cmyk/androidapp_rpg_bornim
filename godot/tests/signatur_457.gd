# 457.2: Signatur in den Proben (signatur.gd), ohne Bild. Prüft: (1) der Kampfort setzt die Tusche wie vor dem Umbau (Tiefe d0,
# Bildbreite aus base_size, auch im Schlagzoom); (2) die Wache findet im Kampfort Toon, Tusche nach Licht, Schatten; (3) eine Bühne
# ohne Toon, Tusche, Schatten fällt durch; (4) einrichten() gibt einer eigenen Bühne die Signatur; (5) eine Nahaufnahme mit eigener
# Kamera (probe.gd NAH) bekommt Tiefe und Bildbreite ihrer Kamera.
# Aufruf: godot --headless --path godot -s res://tests/signatur_457.gd   (Exit 0 = alles richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, was: String) -> void:
	print(("ok     " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _nah(a: float, b: float) -> bool:
	return absf(a - b) < 0.0005 * maxf(1.0, absf(b))


## Werte wie kampfort.gd _ink_licht vor 457.2
func _alt(kf) -> Dictionary:
	var bm: float = kf.get_viewport().get_visible_rect().size.x / (120.0 * kf.scene_rect().size.x / 412.0 / 1.75) * kf.cam.size / kf.base_size
	return {"breite_m": bm, "nah_bis": kf.d0 + 5.0, "nah_ab": kf.d0 - 6.0,
		"hinten_ab": lerpf(0.05, 0.25, clampf((bm - 3.4) / (9.0 - 3.4), 0.0, 1.0))}


func _vergleich(kf, wann: String) -> void:
	kf._ink_licht()
	var a := _alt(kf)
	var ms: Array = kf._ink_mats
	_check(ms.size() == 3, "%s: drei Tuschen (Welt, Gruppe, Gegner): %d" % [wann, ms.size()])
	for i in ms.size():
		for k in ["breite_m", "nah_bis", "nah_ab"]:
			var v: float = ms[i].get_shader_parameter(k)
			_check(_nah(v, a[k]), "%s: Tusche %d %s %.4f wie vorher %.4f" % [wann, i, k, v, a[k]])
		if i > 0:
			var h: float = ms[i].get_shader_parameter("hinten_ab")
			_check(_nah(h, a.hinten_ab), "%s: Tusche %d hinten_ab %.4f wie vorher %.4f" % [wann, i, h, a.hinten_ab])
		_check(_nah(ms[i].get_shader_parameter("umriss_dick"), 1.3), "%s: Tusche %d umriss_dick 1,3" % [wann, i])
	_check(_nah(ms[0].get_shader_parameter("px"), 1.3) and _nah(ms[0].get_shader_parameter("dick"), 1.7), "%s: Welttusche 1,3 / 1,7" % wann)
	_check(_nah(ms[1].get_shader_parameter("px"), 0.8) and _nah(ms[2].get_shader_parameter("dick"), 1.5), "%s: Gruppe, Gegner 0,8 / 1,5" % wann)


func _run() -> void:
	# (1), (2) Kampfort
	var p = Probe.new()
	p.hero_cls = "CLERIC"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 6:
		await process_frame
	var kf = p.fight
	_check(kf._sun.shadow_enabled, "Kampfort: Sonne mit Schatten")
	_check(kf._sun.rotation_degrees.is_equal_approx(Vector3(-45, 55, 0)), "Kampfort: Sonne −45, 55: %s" % kf._sun.rotation_degrees)
	_check(_nah(kf._sun.shadow_opacity, 0.7) and _nah(kf._sun.light_energy, 1.3), "Kampfort: Schatten 0,7, Licht 1,3")
	_vergleich(kf, "Kampfort")
	kf.cam.size = kf.base_size / 1.25     # Schlagzoom (_hit_camera)
	_vergleich(kf, "Kampfort im Zoom")
	kf.cam.size = kf.base_size
	var f := Signatur.pruefen(kf)
	_check(f == "", "Kampfort: Wache findet die Signatur (%s)" % f)
	# (5) Nahaufnahme mit eigener Kamera
	var ziel: Vector3 = kf.to_global(kf._ground(0, 0)) + Vector3(0, 1.5, 0)
	var nah := Camera3D.new()
	kf.add_child(nah)
	nah.fov = 20.0
	nah.position = ziel + Vector3(0, 0, 1.4)
	nah.look_at(ziel)
	nah.make_current()
	kf.ink_ziel = ziel
	kf._ink_licht()
	var vs: Vector2 = kf.get_viewport().get_visible_rect().size
	var b_soll := 2.0 * 1.4 * tan(deg_to_rad(10.0)) * vs.x / vs.y
	var m0: ShaderMaterial = kf._ink_mats[0]
	_check(_nah(m0.get_shader_parameter("nah_ab"), 1.4 - 6.0), "Nah: breite Linie ab %.2f m (Kamera 1,4 m vor dem Ziel)" % m0.get_shader_parameter("nah_ab"))
	_check(_nah(m0.get_shader_parameter("breite_m"), b_soll), "Nah: Bildbreite %.3f m, soll %.3f" % [m0.get_shader_parameter("breite_m"), b_soll])
	kf.queue_free()
	p.queue_free()
	await process_frame
	# (3) Bühne ohne Signatur
	var welt := Node3D.new()
	root.add_child(welt)
	var box := MeshInstance3D.new()
	box.mesh = BoxMesh.new()
	box.material_override = StandardMaterial3D.new()
	welt.add_child(box)
	var cam := Camera3D.new()
	welt.add_child(cam)
	cam.position = Vector3(0, 0, 4)
	cam.current = true
	f = Signatur.pruefen(welt)
	_check(f.contains("ohne Toon") and f.contains("keine Tusche") and f.contains("keine Sonne"), "Bühne ohne Signatur fällt durch: %s" % f)
	# (4) einrichten() mit Toon
	var tm := ShaderMaterial.new()
	tm.shader = load("res://kampf/toon.gdshader")
	box.material_override = tm
	var env := Environment.new()
	var s = Signatur.einrichten(welt, cam, Vector3.ZERO, env, null, true)
	await process_frame
	await process_frame
	f = Signatur.pruefen(welt)
	_check(f == "", "Eigene Bühne mit einrichten(): Signatur da (%s)" % f)
	_check(env.tonemap_mode == Environment.TONE_MAPPER_FILMIC and env.adjustment_enabled, "Eigene Bühne: Tonwerte wie im Kampf")
	var ms: Array = s.mats
	_check(ms.size() == 3 and _nah(ms[0].get_shader_parameter("nah_ab"), 4.0 - 6.0), "Eigene Bühne: Tiefe 4 m nachgeführt")
	_check(_nah(ms[0].get_shader_parameter("hoch_bis"), 1000.0), "Eigene Bühne, schwebend: breite Linie in jeder Höhe")
	welt.queue_free()
	await process_frame
	print("Signatur 457: %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
