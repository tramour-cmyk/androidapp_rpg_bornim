extends SceneTree
# 999.1 (wie alt 268): Standbild Kampfort bei Nacht, der Held (Kämpfer, Langschwert) hält die Fackel in der linken Faust, ihr Licht
# fällt auf ihn und den Boden. Kampfkamera wie im Spiel, Oberfläche wie im Spiel. Mit Bild: BILD=<pfad.png>; ohne Bild meldet es nur,
# ob die Fackel da ist und leuchtet.
# Aufruf: FACKEL=1 TAGESZEIT=nacht godot --path godot --resolution 540x1170 -s res://tests/bild_fackel_9991.gd -- (mit Bild)

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var film := DisplayServer.get_name() != "headless"
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if film and not Signatur.wache(kf, self, "Fackel 999.1"):
		quit(1)
		return
	var n := 0
	while (kf.verhuellt or kf.busy) and n < 30 * 40:
		await process_frame
		n += 1
	for i in 30:
		await process_frame
	var fig = kf.figures["hero"]
	var f = fig.fackel
	print("BILD9991 Fackel: %s, Licht %s, Kraft %.1f, Tageszeit %s, Kaufheld %s" % [f != null, f != null and f.licht.visible,
		f.kraft if f != null else 0.0, kf.tageszeit, fig.kauf])
	if film and OS.get_environment("BILD") != "":
		var img: Image = root.get_texture().get_image()
		img.save_png(OS.get_environment("BILD"))
		# Ausschnitt um den Helden (Einzelheit), dreifach
		var sp: Vector2 = kf.cam.unproject_position(fig.global_position + Vector3.UP * 0.9) * (Vector2(img.get_size()) / root.get_visible_rect().size)
		var r := Rect2i(Vector2i(sp) - Vector2i(90, 130), Vector2i(180, 260)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		var aus := img.get_region(r)
		aus.resize(r.size.x * 3, r.size.y * 3, Image.INTERPOLATE_LANCZOS)
		aus.save_png(OS.get_environment("BILD").replace(".png", "-held.png"))
	quit(0 if f != null else 1)
