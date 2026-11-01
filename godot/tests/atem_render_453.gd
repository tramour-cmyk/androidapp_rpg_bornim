# 453 r3 (Prüfer Film r3, 01.11., 23:2x: Rücken im Film links 0,3–0,5 px Kampfkamera, 1,5 px nah; atem_bild_453 rechnet ohne Bild
# 2,5–5 px): kommt die Atemschicht im gezeichneten Bild an? Am Kampfort wie film_453, die Zeit fast angehalten (Bewegungen stehen),
# je Kamera (Kampfkamera, nah wie film_453) drei Bilder: alle Atemschichten aus, alle bei voller Einatmung, wieder aus. Die Bilder
# gehen nach BILDER (PNG); verglichen wird mit tools/atem_render_453.py (Ausschlag je Wolf im Bild, Pixel), nicht im Gespräch.
# Run: PROBE=453 BILDER=<ordner> xvfb-run -a -s "-screen 0 1080x2340x24" godot --rendering-driver opengl3 --path godot
#      --resolution 1080x2340 -s res://tests/atem_render_453.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

var aus := ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	aus = OS.get_environment("BILDER")
	if aus == "":
		aus = "/tmp"
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("ATEMRENDER ohne Kaufwolf")
		quit(0)
		return
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 60:
		await process_frame
	var kf = p.fight
	var atem := []
	for f in kf.figures.values():
		if f.atem != null:
			atem.append(f)
	print("ATEMRENDER Figuren mit Atemschicht: %d" % atem.size())
	Engine.time_scale = 0.0001
	await _drei(kf, atem, kf.cam, "kampf")
	var nah := Camera3D.new()
	kf.add_child(nah)
	nah.fov = kf.cam.fov
	_nah(kf, nah)
	nah.make_current()
	await _drei(kf, atem, nah, "nah")
	quit(0)


func _drei(kf, atem: Array, cam: Camera3D, name: String) -> void:
	for schritt in [["aus1", false], ["ein", true], ["aus2", false]]:
		for f in atem:
			f.atem.active = schritt[1]
			f.atem.anstrengung = 0.0
			f.atem.phase = f.atem.EIN_ANTEIL     # volle Einatmung (welle = 1)
		for i in 6:
			await process_frame
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image()
		img.save_png("%s/%s-%s.png" % [aus, name, schritt[0]])
		var l := []
		for f in atem:
			var sk: Skeleton3D = f._find(f.model, "Skeleton3D")
			var s := cam.unproject_position(f.global_position + Vector3(0, 0.6, 0))
			l.append("%s %s tiefe %.2f bei %d,%d" % [f.fighter.id, "Wolf" if f.fighter.monster != null else "Mensch", f.atem.tiefe, s.x, s.y])
		print("ATEMRENDER %s %s %dx%d: %s" % [name, schritt[0], img.get_width(), img.get_height(), "; ".join(l)])


## wie atem_bild_453 _nah (film_453): seitlich, das ganze Rudel im Bild
func _nah(kf, cam: Camera3D) -> void:
	var s := Vector3.ZERO
	var z := 0
	for f in kf.figures.values():
		if f != null and is_instance_valid(f) and f.fighter != null and f.fighter.monster != null and not f.down:
			s += f.home
			z += 1
	if z == 0:
		return
	var mitte: Vector3 = s / z + Vector3(0, 0.6, 0)
	var zu: Vector3 = kf.cam.global_position - mitte
	zu.y = 0.0
	var seite: Vector3 = zu.normalized().cross(Vector3.UP)
	var g: Vector2 = Vector2(kf.get_viewport().get_visible_rect().size)
	var halb: float = tan(deg_to_rad(cam.fov) * 0.5) * g.x / maxf(g.y, 1.0)
	var beste := Vector3.ZERO
	var beste_weit := INF
	for r in [seite, (seite + zu.normalized()).normalized(), (zu.normalized() - seite).normalized(), -seite]:
		var quer: Vector3 = r.cross(Vector3.UP)
		var breit := 0.0
		for f in kf.figures.values():
			if f != null and is_instance_valid(f) and f.fighter != null and f.fighter.monster != null and not f.down:
				breit = maxf(breit, absf((f.home - mitte).dot(quer)))
		var w: float = (breit + 0.8) / halb
		if w < beste_weit:
			beste_weit = w
			beste = r
	cam.position = mitte + beste * maxf(3.2, beste_weit) + Vector3(0, 0.5, 0)
	cam.look_at(mitte)
