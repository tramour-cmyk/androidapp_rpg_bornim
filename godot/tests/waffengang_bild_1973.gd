extends SceneTree
# 1973: Prüfbild Zweihänder unterwegs in der Spielkamera (Handy 540x1170, Spielshader, Tusche, Schatten wie im Spiel): Wachsoldat geht
# im Dorf mit greatsword (Gehen_axt), Kamera des Spiels nah, rechte Seite zur Kamera. Gibt die Bildstellen beider Fäuste aus
# (FAUST1973 r|l x y) und, ob ein Modell getragen wird (GETRAGEN1973 <Schlüssel> <ja|nein>); Markieren und alt gegen neu macht der Aufrufer.
# Nach umhang_bild_1570.gd (Welt), ohne Umhang. Aufruf: PROBE=1973 xvfb-run -a godot --path godot --rendering-driver opengl3
#   --resolution 540x1170 --fixed-fps 30 -s res://tests/waffengang_bild_1973.gd -- --aus=<datei.png>
var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_welt.call_deferred()

func _bilder(n: int) -> void:
	for i in n: await process_frame

func _knochen(sk: Skeleton3D, n: String) -> Vector3:
	return sk.global_transform * sk.get_bone_global_pose(sk.find_bone(n)).origin

func _welt() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await _bilder(5)
	spiel.zustand.minuten = 12 * 60
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)
	var w := BrsHeld.fuer_spiel("Test", "Mensch", "Wachsoldat")
	spiel.werte = w
	w.ausruestung["MAIN_HAND"] = {"base": "greatsword"}
	w.ausruestung.erase("OFF_HAND")
	spiel.held_figur_neu("")
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	if spiel.herde:
		spiel.herde.aus = true
		spiel.herde.process_mode = Node.PROCESS_MODE_DISABLED
	var h = spiel.held
	print("GANG1973 vorher %s" % h.waffengang)
	# ohne Modell setzt der Held keinen Waffengang; für dieselbe Pose alt wie neu der Zweihändergang (tragen.gd GANG_ZWEI -> „axt“)
	if h.waffengang == "" and h.anim and h.anim.has_animation("Gehen_axt"):
		h.waffengang = "axt"; h.gang_w = HeldFigur.TAKT_GEHEN; h.renn_w = HeldFigur.TAKT_RENNEN
	h.setze(Vector2i(19, 15), "DOWN")
	spiel.kamera.nah = true
	spiel.kamera.zoom = spiel.kamera.NAH
	spiel.kamera.springe()
	await _bilder(20)
	h.geh_zu(h.global_position + Vector3(3.0, 0.0, -3.0))   # nach Nordosten: rechte Seite zur Kamera
	await _bilder(26)
	spiel.kamera.springe()
	await _bilder(1)
	var ap := Gebiet.finde(h, "AnimationPlayer") as AnimationPlayer
	if ap: ap.pause()
	h.halt()
	await _bilder(2)
	var sk := Gebiet.finde(h, "Skeleton3D") as Skeleton3D
	var cam := root.get_camera_3d()
	var schl := HeldFigur._modell({"base": "greatsword"})
	print("GETRAGEN1973 %s %s" % [schl if schl != "" else "-", "ja" if h.find_child("Getragen", true, false) != null else "nein"])
	print("BEWEGUNG1973 %s" % (ap.current_animation if ap else "?"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus)
	for s in ["r", "l"]:
		var q := cam.unproject_position(_knochen(sk, "hand_" + s))
		print("FAUST1973 %s %d %d" % [s, int(q.x), int(q.y)])
	print("BILD ", aus)
	quit(0)
