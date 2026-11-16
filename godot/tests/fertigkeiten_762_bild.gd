extends SceneTree
# 762 Probe mit Bild am Rechner (nicht im Bau): Heldenreiter eines Wachsoldaten nach BRS, oben und beim Abschnitt Fertigkeiten,
# dann der Reiter „Fertigkeiten“ oben und unten, Gruppen wie ohne Umklappen (Chef 21:33), zuletzt mit aufgeklapptem „Schatten“.
# Vorher ohne Bild: tests/fertigkeiten_762.gd. Bildlauf nur mit PROBE=762.
# Aufruf: im Ordner godot: PROBE=762 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . --resolution 1080x2340 -s res://tests/fertigkeiten_762_bild.gd -- --ordner=<dir>

var ordner := "/tmp/fertigkeiten762"

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ordner="): ordner = a.substr(9)
	DirAccess.make_dir_recursive_absolute(ordner)
	_lauf.call_deferred()

func knips(n: String) -> void:
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s.png" % [ordner, n])
	print("BILD ", n)

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	var gemerkt: Dictionary = Bedienung.fert_gruppen.duplicate()
	Bedienung.fert_gruppen = {}
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	z.brs = BrsHeld.neu("Mensch", "Wachsoldat").als_daten()
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "held"; m.baue()
	await knips("762_held_oben")
	for l in m.inhalt.find_children("*", "Label", true, false):
		if (l as Label).text == "FERTIGKEITEN":
			m.rolle.scroll_vertical = int((l as Label).position.y - 40 * Menue.DP)
	await knips("762_held_fertigkeiten")
	m.tippe_reiter("fertigkeiten")
	await knips("762_reiter_oben")
	m.rolle.scroll_vertical = 100000
	await knips("762_reiter_unten")
	m.klappe_gruppe("Schatten", false)
	for i in 3: await process_frame   # baue() setzt die alte Stelle erst nach einem Bild
	m.rolle.scroll_vertical = 0
	await knips("762_reiter_schatten_offen")
	Bedienung.fert_gruppen = gemerkt
	Bedienung.speichere()
	quit(0)
