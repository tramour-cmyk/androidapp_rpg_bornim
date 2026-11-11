extends SceneTree
# 521, 523 Vorlage: Reiter Tasche und Wechselschirm (Platz Kopf, Haupthand) mit der neuen Ausrüstungszeile; Magier mit gemischter Tasche.
# Bildlauf: nur mit PROBE=521 (389). Aufruf: im Ordner godot: xvfb-run godot --path . --resolution 1080x1920 -s res://tests/tasche_bild_521.gd -- --ordner=<dir>

var dir := "/tmp/tasche521"

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ordner="): dir = a.substr(9)
	DirAccess.make_dir_recursive_absolute(dir)
	_lauf.call_deferred()

func knips(n: String) -> void:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, n])
	print("BILD ", n)

func ding(z: Zustand, base: String, rar := "COMMON", ilvl := 1) -> Dictionary:
	return z.ausruestung_dazu({"uid": 0, "base": base, "rarity": rar, "ilvl": ilvl, "plus": 0, "rolls": [], "unique": null, "name_seed": 0})

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Zauberlehrling", z.neue_uid)
	for d in [["longsword", "COMMON"], ["greatsword", "UNCOMMON"], ["dagger", "RARE"], ["leather_cap", "UNCOMMON"], ["hood", "COMMON"],
			["ring", "UNCOMMON"], ["quarterstaff", "UNCOMMON"], ["shield", "COMMON"]]:
		if Beute.grundform(d[0]) != null: ding(z, d[0], d[1], 2)
	z.dazu("potion"); z.dazu("potion"); z.dazu("herbs")
	z.funke = true
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "tasche"
	m.baue()
	await knips("1_tasche")
	m.reiter = "ausruestung"
	m.baue()
	await process_frame
	m.waehle("HEAD")
	await knips("2_wechsel_kopf")
	m.reiter = "ausruestung"
	m.baue()
	await process_frame
	m.waehle("MAIN_HAND")
	await knips("3_wechsel_hand")
	print("TASCHEBILD fertig")
	quit()
