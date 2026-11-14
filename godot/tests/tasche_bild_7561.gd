extends SceneTree
# 756.1 (Chef 13.11., 16:28 über Sokrates: „das kann ich doch so angucken“; Prüfart Bild statt Handy): Bild der Tasche wie im Spiel nach
# Reiter „Test“ → „Vier Güten“ (Testmodus.vier_gueten: dieselbe Waffe Schlecht, Normal, Gut, Meisterhaft), dazu das Fenster des
# schlechten Stücks. Am Rechner mit Fenster (xvfb-run), 1080 × 2340, PNG nach BILD7561_AUS (Vorgabe user://):
#   7561_tasche    Reiter Tasche mit den vier Stücken
#   7561_fenster   Gegenstandsfenster des schlechten Stücks

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD7561_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.setze("de")
	seed(7561)
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 40
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 2)
	var vier: Array = Testmodus.vier_gueten(z, hw)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.reiter = "tasche"
	m.baue()
	await _bild("7561_tasche")
	m.frage_stueck(vier[0])
	await _bild("7561_fenster")
	quit(0)
