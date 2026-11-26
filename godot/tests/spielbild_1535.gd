extends SceneTree
# 1535 (Bildlauf frei Sokrates 18.11., 23:30): Garrick (Flüsterwald) und Bram im Kittel (Dorf) wie der Chef sie sieht, Spielkamera ohne
# Oberfläche, Ruhebewegung mit gehobenem Arm (Ruhe_Trinken, bei Garrick auch Stehen_2), je einige Zeitpunkte, Grundansicht (FERN) und
# nächster Fingerzoom (NAH). Alt gegen neu in einem Lauf: erst mit den held_L_<id>_M.bin des Stands, dann mit --neu=<ordner>
# (darin held_L_garrick_M.glb, held_L_bram_M.glb; ersetzt die Dateien, betritt die Karte neu). Kartenrand der Kamera aus.
# Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1535 MODELLSPEICHER=0 xvfb-run -a godot --path . --resolution 1280x600 -s res://tests/spielbild_1535.gd -- --aus=<ordner> --neu=<ordner>

var aus := ""
var neu := ""
var spiel
const WER := [["garrick", "forest", Vector2i(3, 9), "RIGHT", ["Ruhe_Trinken", "Stehen_2"]],
	["bram", "village", Vector2i(13, 29), "RIGHT", ["Ruhe_Trinken"]]]


func knips(n: String) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD1535 ", aus + "/" + n + ".png")


func _person(tag: String, w: Array) -> bool:
	spiel.zustand.minuten = 12 * 60
	spiel.betrete(w[1], w[2], w[3])
	await create_timer(1.5).timeout
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	var p = null
	for l in spiel.leute.get_children():
		if String(l.get("daten").get("id", "")) == w[0]: p = l
	if p == null:
		print("BILD1535 fehlt ", w[0]); return false
	p.ziel = Vector2i(-1, -1)
	p.weg.clear()
	p.warte = 999.0
	var ap := Gebiet.finde(p, "AnimationPlayer") as AnimationPlayer
	if ap == null:
		print("BILD1535 ohne AnimationPlayer ", w[0]); return false
	# leute.gd _process spielt sonst seine Pause weiter und dreht die Person zum Helden: Blick zur Kamera (DOWN), Pause = Bewegung
	p.blick = 0.0; p.blick_vorher = 0.0; p.rotation.y = 0.0; p.ruhe_bis = 1.0e9
	# Kamera.ziel nimmt position (Raum des Helden): ein Punkt in spiel an der Stelle der Person
	var z := Node3D.new()
	spiel.add_child(z)
	z.global_position = p.global_position
	spiel.kamera.ziel = z
	spiel.kamera.rand_weit = 0.0
	for bew in w[4]:
		if not ap.has_animation(bew):
			print("BILD1535 ", w[0], " ohne ", bew); continue
		var L := ap.get_animation(bew).length
		for b in 8:
			p.pause = bew
			ap.play(bew, 0.0); ap.seek(L * float(b) / 8.0, true); ap.speed_scale = 0.0
			p.rotation.y = 0.0
			for k in [[Kamera.FERN, "fern"], [Kamera.NAH, "nah"]]:
				spiel.kamera.zoom = k[0]
				spiel.kamera.nah = k[1] == "nah"
				spiel.kamera.springe()
				await create_timer(0.3).timeout
				await knips("%s_%s_%s_%d_%s" % [tag, w[0], bew, b, k[1]])
	z.queue_free()
	return true


func _runde(tag: String) -> bool:
	var ok := true
	for w in WER:
		ok = (await _person(tag, w)) and ok
	return ok


func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	Testmodus.alles_sichtbar = true
	if not await _runde("alt"):
		quit(1); return
	if neu == "":
		quit(0); return
	var ersetzt := []
	for w in WER:
		var ziel := ProjectSettings.globalize_path("res://daten/held_L_%s_M.bin" % w[0])
		DirAccess.copy_absolute(ziel, ziel + ".alt1535")
		if DirAccess.copy_absolute(neu + "/held_L_%s_M.glb" % w[0], ziel) != OK:
			print("BILD1535 neu nicht kopiert: ", w[0]); quit(1); return
		ersetzt.append(ziel)
	var ok: bool = await _runde("neu")
	for ziel in ersetzt:
		DirAccess.copy_absolute(ziel + ".alt1535", ziel)
		DirAccess.remove_absolute(ziel + ".alt1535")
	quit(0 if ok else 1)


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--neu="): neu = a.substr(6)
	_lauf.call_deferred()
