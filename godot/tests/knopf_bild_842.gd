extends SceneTree
# 842 Probe mit Bild am Rechner (nicht im Bau): Wahl und „Nicht jetzt“ im Gespraech unter Pims Zeile und unter Osrics Heilung, Verband in der Tasche
# und in Thessas Laden; die Welt dahinter fehlt am Rechner (ohne Dorfmodelle), Grund wie oberflaeche_bild.gd.
# Aufruf: im Ordner godot, mit Fenster (xvfb-run), -s res://tests/knopf_bild_842.gd --resolution 1080x2340; Bilder nach KNOPF842_AUS

func _initialize() -> void: _lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("KNOPF842_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var grund := ColorRect.new()
	grund.color = Color(0.45, 0.5, 0.42)
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(grund)
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	# 842 zurueck (Chef 20:48): die Zeilen und Knoepfe aus den echten Gespraechen (Geschichte.gespraech), die Wahl rechts, „Nicht jetzt“
	# links (Homer [1074.zweit]); Pim tagsueber, Osric vor Lyras Rettung
	var zp := Zustand.new()
	zp.minuten = 10 * 60
	zp.gold = 37   # 1086: mit Gold auch „Gib Pim 5 Gold“
	ui.sage([zeile_mit_knopf(Geschichte.gespraech("pim", zp))])
	ui.weiter()
	await _bild("1_pim")
	ui.sage([zeile_mit_knopf(Geschichte.gespraech("osric", zp))])
	ui.weiter()
	await _bild("2_osric")
	ui.schliesse_text()
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 37; z.dazu("bandage", 3); z.dazu("potion", 2)
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	z.brs = hw.als_daten()
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.frage_ding("bandage")
	await _bild("3_tasche")
	m.queue_free()
	var ls := LadenSchirm.new(hw, z, Laden.new(Geschichte.SHOP_STOCK, false))
	ebene.add_child(ls)
	await _bild("4_thessa")
	quit(0)


## die Zeile vor dem ersten Knopf eines Gespraechs mit diesem Knopf, wie spiel.gd weiter/_knopf_danach sie zeigt
func zeile_mit_knopf(bef: Array) -> Dictionary:
	var letzte := {}
	for c in bef:
		match String(c["art"]):
			"sagen":
				if letzte.has("knopf"): return letzte
				letzte = {"text": Sprache.t(c["text"]).replace("{name}", "Mira")}
				if c.has("wer"): letzte["wer"] = Sprache.t(c["wer"])
			"variante": pass
			"knopf":   # 1086: alle Knoepfe hintereinander
				var k: Array = letzte.get("knopf", [])
				k.append(Sprache.t(c["knopf"]))
				letzte["knopf"] = k
			_:
				if letzte.has("knopf"): return letzte
	return letzte
