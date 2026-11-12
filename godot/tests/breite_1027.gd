extends SceneTree
# 1027 (Chef 12.11., 11:42, Build 279: „leider passt es nicht auf den Bildschirm“): jeder Reiter des Menüs bleibt innerhalb des Schirms.
# Schirm wie am Handy 1080 × 2340, Testmodus an (acht Reiter mit „Test“), die Prüfliste des Builds geladen, falls vorhanden; je Reiter
# die Mindestbreite des Inhalts gegen die Breite innerhalb des Rands. Ausgabe „BREITE1027 <n> Fehler“.
#   ~/godot/godot --headless --path . -s res://tests/breite_1027.gd

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	Testmodus.an = true
	Testmodus.geladen = true
	spiel.oeffne_menue("test")
	await create_timer(0.5).timeout
	var m: Menue = root.find_children("*", "Menue", true, false)[0]
	var frei := m.get_viewport_rect().size.x - 48 * Menue.DP   # wie Menue.innen_breite (Seitenrand 24 dp)
	print("BREITE1027 Schirm %s, frei %.0f" % [m.get_viewport_rect().size, frei])
	if m.get_viewport_rect().size.x > 1200:
		print("BREITE1027 Schirm nicht auf Handybreite, nichts zu pruefen"); print("BREITE1027 0 Fehler"); quit(0); return
	for r in ["held", "fertigkeiten", "tasche", "ausruestung", "chronik", "system", "test"]:
		m.reiter = r
		m.baue()
		await process_frame
		await process_frame
		var w := maxf(m.inhalt.get_combined_minimum_size().x, m.leiste.get_combined_minimum_size().x)
		var ok := w <= frei + 0.5
		print("%s %s: Inhalt mindestens %.0f, frei %.0f" % ["ok     " if ok else "FALSCH ", r, w, frei])
		if not ok: fehler += 1
	print("BREITE1027 %d Fehler" % fehler)
	quit(1 if fehler else 0)
