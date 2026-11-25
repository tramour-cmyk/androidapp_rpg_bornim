# 1589.4 (Auftrag 25.11., Prüfart): Film der Wege im Probekampf von der Seite, ohne Eingriff (Autopilot), Kamera seitlich zur Achse
# Helden–Gegner auf Hüfthöhe, oben beschriftet mit FILM_TEXT (Figur und Commit) und der Spielzeit. Je Bild eine Zeile WEGEFILM mit
# Zeit, Figur, Gang und Bewegung, damit sich der Moment im Film finden lässt.
# Aufruf: FOE=RATS HELD=FIGHTER MERC=ROGUE FILM_TEXT="…" BIS=25 PROBE=1589.4 xvfb-run -a godot --path godot --rendering-driver opengl3
#   --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_wege_15894.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

var p
var kf
var cam: Camera3D
var lb: Label
var bild := 0
var bis := 25.0
var text := ""
var roll_vor = null


func _initialize() -> void:
	bis = float(OS.get_environment("BIS")) if OS.get_environment("BIS") != "" else 25.0
	text = OS.get_environment("FILM_TEXT")
	_lauf.call_deferred()


func _lauf() -> void:
	p = Probe.new()
	p.hero_cls = OS.get_environment("HELD") if OS.get_environment("HELD") != "" else "FIGHTER"
	p.merc_cls = OS.get_environment("MERC") if OS.get_environment("MERC") != "" else "CLERIC"
	p.foe = OS.get_environment("FOE") if OS.get_environment("FOE") != "" else "RATS"
	root.add_child(p)
	await process_frame
	p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
	for i in 6:
		await process_frame
	kf = p.fight
	cam = Camera3D.new()
	cam.keep_aspect = Camera3D.KEEP_WIDTH     # Hochformat des Spiels: die Breite zeigt die Szene, der Film schneidet die Mitte aus
	cam.fov = 55.0
	root.add_child(cam)
	var cl := CanvasLayer.new()
	cl.layer = 100
	root.add_child(cl)
	lb = Label.new()
	lb.position = Vector2(24, 900)
	lb.add_theme_font_size_override("font_size", 40)
	lb.add_theme_color_override("font_color", Color.WHITE)
	lb.add_theme_color_override("font_outline_color", Color.BLACK)
	lb.add_theme_constant_override("outline_size", 6)
	cl.add_child(lb)
	for i in 15:
		await process_frame
	var mars = kf.mars
	for f in mars.fighters():
		if f.side == "PARTY":
			f.auto = true
	mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var mitte0 := _mitte()
	while bild < int(bis * 30.0) and mars.outcome == "ONGOING":
		await process_frame
		bild += 1
		for f in mars.fighters():     # wie wege_15894: es geht nur um Wege
			if f.side == "PARTY" and f.hp > 0:
				f.hp = maxi(f.hp, f.max_hp)
		_kamera(mitte0)
		for c in kf.find_children("*", "CanvasLayer", true, false):     # nur die Szene, ohne Oberfläche
			c.visible = false
		lb.text = "%s   %.1f s" % [text, bild / 30.0]
		if kf.ui.roll_at != roll_vor:     # Kampfzeile mit Spielzeit (Beleg je Fehlwurf: Abwehr oder Ausweichen, FEHLWURF aus kampfort)
			roll_vor = kf.ui.roll_at
			print("KAMPFZEILE %.1f %s" % [bild / 30.0, String(kf.shown.get("text", ""))])
		for o in kf.figures.values():
			if o.visible and not o.down:
				print("WEGEFILM %.1f %s %s %s (%.2f, %.2f)" % [bild / 30.0, o.fighter.id, o.gang, String(o.anim.current_animation) if o.anim else "", o.position.x, o.position.z])
	quit(0)


## Mitte und Achse beim Start: [Mitte, Richtung Helden → Gegner]
func _mitte() -> Array:
	var h := Vector3.ZERO
	var g := Vector3.ZERO
	var nh := 0
	var ng := 0
	for o in kf.figures.values():
		if o.fighter.side == "PARTY":
			h += o.position
			nh += 1
		else:
			g += o.position
			ng += 1
	h /= maxf(nh, 1)
	g /= maxf(ng, 1)
	var achse := g - h
	achse.y = 0.0
	return [(h + g) * 0.5, achse.normalized()]


func _kamera(m: Array) -> void:
	var mitte: Vector3 = m[0]
	var achse: Vector3 = m[1]
	var seite := achse.cross(Vector3.UP).normalized()
	cam.position = mitte - seite * 6.5 + Vector3.UP * 2.6
	cam.look_at(mitte + Vector3.UP * 0.5, Vector3.UP)
	cam.current = true
