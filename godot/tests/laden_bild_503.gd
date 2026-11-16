extends SceneTree
# 503 Probe mit Bild am Rechner (nicht im Bau): Laden, Verkaufen, Knopf „Gewöhnliche verkaufen“ unter „Ausrüstung“ und seine
# Rueckfrage, zum Vergleich mit ShopScreen.kt 258–276. Held und Ware wie laden_bild_4169.
# PNG nach OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 640
	for id in ["potion", "remedy", "wolf_pelt", "boar_tusk", "herbs"]: z.dazu(id, 3)
	var hw := BrsHeld.fuer_spiel("Thora", "Elf", "Zauberlehrling", z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 9)
	for i in 8: z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(40 + i), z.neue_uid, 9, ["COMMON", "UNCOMMON", "RARE", "VERY_RARE"][i % 4], "WIZARD" if i % 3 else ""))
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var waren := ["potion", "greater_potion", "superior_potion", "remedy", "stamina_potion", "spark_potion", "alchemist_fire", "holy_water"]
	var l := LadenSchirm.new(hw, z, Laden.new(waren, false))
	ebene.add_child(l)
	await process_frame
	Bedienung.rueckfragen = true
	l.seite = "verkaufen"; l.baue()
	for i in 4: await process_frame
	var knopf: Button = null
	for b in _knoepfe(l.inhalt, []):
		if (b as Button).text == "GEWÖHNLICHE VERKAUFEN": knopf = b
	if knopf == null:
		print("FEHLER Knopf fehlt"); quit(1); return
	l.rolle.ensure_control_visible(knopf)
	await _bild("503_knopf")
	knopf.pressed.emit()
	await _bild("503_rueckfrage")
	quit(0)

func _knoepfe(n: Node, aus: Array) -> Array:
	if n is Button: aus.append(n)
	for c in n.get_children(): _knoepfe(c, aus)
	return aus
