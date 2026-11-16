extends SceneTree
# 416.9 Probe mit Bild am Rechner (nicht im Bau): Laden, Verkaufen mit allen neun Plaetzen (leere als Rahmen) und dem Zeichen auf
# nicht Tragbarem; ein Stueck angetippt (Vergleichswerte); Kasten Menge mit Bild. Held und Ware wie laden_bild_4163.
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
	l.seite = "verkaufen"; l.baue()
	await _bild("4169_verkaufen")
	l.rolle.scroll_vertical = 100000
	await _bild("4169_verkaufen_unten")
	for g in z.beutel:
		if hw.kann_tragen(g) and not Vergleich.von(hw, g).zeilen.is_empty():
			l.stueck(g, false)
			break
	await _bild("4169_stueck")
	for c in l.get_children():
		if c is ColorRect and (c as ColorRect).color.a < 1.0: c.queue_free()
	l.seite = "kaufen"; l.baue()
	l.menge("potion", true, 2)
	await _bild("4169_menge")
	quit(0)
