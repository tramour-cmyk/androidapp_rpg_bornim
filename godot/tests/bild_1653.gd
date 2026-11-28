extends SceneTree
# 1653 (Silke): Beleg Thessa Kragen, Spielkamera (spiel.tscn, Spielshader, Tusche) in Handygröße, nächster Fingerzoom (Kamera.NAH).
# Thessa im Laden hinter dem Tresen, Held unsichtbar; Ruhebewegung „Ruhe_Greifen“ (dort stachen die Spangen am meisten, 34 Ecken)
# steht je Bild der Durchstechprüfung (6 Bilder je Bewegung wie durchstich_1631) und je Blickrichtung; Bilder nach --aus=<Ordner>.
# Nur mit Fenster, im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 1080x2340 -s res://tests/bild_1653.gd -- --aus=<Ordner>

const BEW := "Ruhe_Greifen"
const BILDER := 6

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var aus := "user://bild_1653"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	DirAccess.make_dir_recursive_absolute(aus)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("shop", Vector2i(1, 1), "DOWN")
	for i in 10: await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	var wer: Leute = null
	for l in spiel.leute_liste():
		if String(l.daten.get("id", "")) == "thessa": wer = l
	if wer == null:
		print("BILD1653 FEHLER Thessa fehlt")
		quit(1)
		return
	spiel.held.setze(wer.kachel + Vector2i(0, 2), "UP")
	spiel.held.visible = false
	wer.set_process(false)
	wer.set_physics_process(false)
	var ap := wer.anim
	if ap == null or not ap.has_animation(BEW):
		print("BILD1653 FEHLER keine Bewegung %s" % BEW)
		quit(1)
		return
	ap.speed_scale = 0.0
	var k: Kamera = spiel.kamera
	k.ziel = wer
	k.nah = true
	k.zoom = Kamera.NAH
	var vorn := -wer.global_basis.z
	print("BILD1653 Thessa %s Blick %s" % [wer.global_position, vorn])
	for g in [Kamera.NORD, 0.0, -Kamera.NORD]:
		k.gieren_ziel = g
		k.springe()
		for b in BILDER:
			var an := ap.get_animation(BEW)
			ap.play(BEW, 0.0)
			ap.seek(an.length * float(b) / float(BILDER), true)
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			var bild := root.get_texture().get_image()
			var kopf := wer.global_position + Vector3(0, 1.45, 0)
			var p := k.unproject_position(kopf)
			var f := "%s/g%d_b%d.png" % [aus, int(g), b]
			bild.save_png(f)
			var fuss := k.unproject_position(wer.global_position)
			var scheitel := k.unproject_position(wer.global_position + Vector3(0, 1.8, 0))
			print("BILD1653 %s Kragen %d %d Fuss %d %d Scheitel %d %d" % [f, int(p.x), int(p.y), int(fuss.x), int(fuss.y), int(scheitel.x), int(scheitel.y)])
	print("BILD1653 fertig")
	quit(0)
