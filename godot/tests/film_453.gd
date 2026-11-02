# 453 r2: Film der Wölfe im Kampfort (Kaufwolf, Kämpfer und Kleriker) in drei Teilen mit Titel oben: RUHE_MS Ruhe aus der
# Kampfkamera (keiner zieht: Atmen, Gesten), NAH_MS Ruhe nah (Kamera aus Richtung der Kampfkamera NAHE m vor der Mitte des Rudels,
# Brusthöhe des Wolfs), dann DAUER_MS Kampf im Autopilot aus der Kampfkamera (nach dem Biss schneller atmen, Hocke ↔ Stehen). Nur mit --write-movie und Fenster (xvfb-run), Probelauf nach 389:
# PROBE=453 xvfb-run godot --path godot --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_453.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")


func _env(n: String, d: int) -> int:
	return int(OS.get_environment(n)) if OS.get_environment(n) != "" else d


func _run() -> void:
	var k := OS.get_environment("KLASSE") if OS.get_environment("KLASSE") != "" else "FIGHTER"
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(_env("SEED", 7))
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("Film 453: kein Kampf")
		quit(1)
		return
	var titel := Label.new()
	titel.add_theme_font_size_override("font_size", 44)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 10)
	titel.position = Vector2(40, 60)
	var ebene := CanvasLayer.new()
	ebene.layer = 100
	ebene.add_child(titel)
	kf.add_child(ebene)
	if not Signatur.wache(kf, self, "Film 453"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
		return
	titel.text = "453 r3 · Ruhe, Kampfkamera"
	for i in _env("RUHE_MS", 8000) * 30 / 1000:
		await process_frame
	var nah := Camera3D.new()
	kf.add_child(nah)
	nah.fov = kf.cam.fov
	_nah(kf, nah)
	nah.make_current()
	var ui_war: bool = kf.ui.visible if kf.ui != null else false
	if kf.ui != null:
		kf.ui.visible = false
	titel.text = "453 r3 · Ruhe, nah"
	if not Signatur.wache(kf, self, "Film 453 nah"):     # 457.2: die Nahkamera zeichnet mit breiter Linie
		return
	for i in _env("NAH_MS", 10000) * 30 / 1000:
		await process_frame
		_nah(kf, nah)
	kf.cam.make_current()
	if kf.ui != null:
		kf.ui.visible = ui_war
	titel.text = "453 r3 · Kampf, Kampfkamera"
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var n := 0
	while n < _env("DAUER_MS", 16000) * 30 / 1000:
		await process_frame
		n += 1
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			kf.go_on()
	print("Film 453 %s: %s nach %d Bildern Kampf" % [k, kf.mars.outcome, n])
	quit(0)


## Mitte der lebenden Wölfe daheim (ihr Platz, nicht der Sprung), weich nachgeführt
var _mitte := Vector3.INF

## Tangens des halben Blickwinkels quer (fov gilt in der Höhe, der Schirm steht hochkant)
func _halb_quer(kf, cam: Camera3D) -> float:
	var g: Vector2 = Vector2(kf.get_viewport().get_visible_rect().size)
	return tan(deg_to_rad(cam.fov) * 0.5) * g.x / maxf(g.y, 1.0)


func _nah(kf, cam: Camera3D) -> void:
	var s := Vector3.ZERO
	var z := 0
	for f in kf.figures.values():
		if f != null and is_instance_valid(f) and f.fighter != null and f.fighter.monster != null and not f.down:
			s += f.home
			z += 1
	if z == 0:
		return
	# 453 r3 (Prüfer Film r2: Kopf des schwarzen Wolfs füllt das halbe Bild, meist nur ein Wolf; gemessen: wer angreift, läuft auf die
	# Kamera zu): von der Seite, quer zur Richtung Wölfe → Helden, so weit, dass das ganze Rudel ins Bild passt; fest, ohne Nachführen
	if _mitte != Vector3.INF:
		return
	_mitte = s / z + Vector3(0, 0.6, 0)
	var zu: Vector3 = kf.cam.global_position - _mitte
	zu.y = 0.0
	var seite: Vector3 = zu.normalized().cross(Vector3.UP)
	# aus der Richtung, in der das Rudel schmaler im Bild steht (seitlich oder schräg von vorn, über den Helden hinweg)
	var beste := Vector3.ZERO
	var beste_weit := INF
	for r in [seite, (seite + zu.normalized()).normalized(), (zu.normalized() - seite).normalized(), -seite]:
		var quer: Vector3 = r.cross(Vector3.UP)
		var breit := 0.0
		for f in kf.figures.values():
			if f != null and is_instance_valid(f) and f.fighter != null and f.fighter.monster != null and not f.down:
				breit = maxf(breit, absf((f.home - _mitte).dot(quer)))
		# 453a (Prüfer Film Lauf 174, G1: schwarzer Wolf am rechten Rand, Kopf des braunen draußen): Wölfe stehen mit Gesten und Rute
		# bis 1,7 m lang um ihren Platz, 0,8 m Rand reichte nicht
		var w: float = (breit + 1.6) / _halb_quer(kf, cam)
		if w < beste_weit:
			beste_weit = w
			beste = r
	var weit: float = float(OS.get_environment("NAHE")) if OS.get_environment("NAHE") != "" else maxf(3.2, beste_weit)
	cam.position = _mitte + beste * weit + Vector3(0, 0.5, 0)
	cam.look_at(_mitte)


func _initialize() -> void:
	_run.call_deferred()
