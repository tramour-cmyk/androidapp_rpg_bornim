extends SceneTree
# 1655 (Läufe frei 18.11., 20:31): Morwen mit Kapuze wie der Chef sie sieht, Flüsterwald bei Tag, Spielkamera ohne Oberfläche.
# Ruhebewegung Stehen, zwei Zeitpunkte; je Zeitpunkt Grundansicht (FERN) und nächster Fingerzoom des Spielers (NAH).
# Alt gegen neu in einem Lauf: erst mit dem held_L_morwen_W.bin des Stands, dann mit --neu=<glb> (ersetzt die Datei, betritt die
# Karte neu). Kartenrand der Kamera aus (rand_weit 0), sonst verkleinert er den Ausschnitt, weil Morwen weit vom Helden steht.
# Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1655 MODELLSPEICHER=0 xvfb-run -a godot --path . --resolution 1280x600 -s res://tests/spielbild_1655.gd -- --aus=<ordner> --neu=<glb>

var aus := ""
var neu := ""
var spiel


func knips(n: String) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD1655 ", aus + "/" + n + ".png")


func _runde(tag: String) -> bool:
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("deep_forest", Vector2i(23, 31), "RIGHT")
	await create_timer(1.5).timeout
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	var p = null
	for l in spiel.leute.get_children():
		if String(l.get("daten").get("id", "")) == "morwen": p = l
	if p == null:
		print("BILD1655 keine Morwen im Flüsterwald"); return false
	p.ziel = Vector2i(-1, -1)
	p.weg.clear()
	p.warte = 999.0
	var ap := Gebiet.finde(p, "AnimationPlayer") as AnimationPlayer
	if ap == null or not ap.has_animation("Stehen"):
		print("BILD1655 Morwen ohne Stehen"); return false
	var L := ap.get_animation("Stehen").length
	spiel.kamera.ziel = p
	spiel.kamera.rand_weit = 0.0
	for b in 2:
		ap.play("Stehen", 0.0); ap.seek(L * (0.15 + 0.5 * b), true); ap.speed_scale = 0.0
		for z in [[Kamera.FERN, "fern"], [Kamera.NAH, "nah"]]:
			spiel.kamera.zoom = z[0]
			spiel.kamera.nah = z[1] == "nah"
			spiel.kamera.springe()
			await create_timer(0.3).timeout
			await knips("%s_%d_%s" % [tag, b, z[1]])
	return true


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
	var ziel := ProjectSettings.globalize_path("res://daten/held_L_morwen_W.bin")
	DirAccess.copy_absolute(ziel, ziel + ".alt1655")
	if DirAccess.copy_absolute(neu, ziel) != OK:
		print("BILD1655 neu nicht kopiert: ", neu); quit(1); return
	var ok: bool = await _runde("neu")
	DirAccess.copy_absolute(ziel + ".alt1655", ziel)
	DirAccess.remove_absolute(ziel + ".alt1655")
	quit(0 if ok else 1)


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--neu="): neu = a.substr(6)
	_lauf.call_deferred()
