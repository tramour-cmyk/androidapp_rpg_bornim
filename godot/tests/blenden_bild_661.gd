extends SceneTree
# 661 Probe mit Bild am Rechner (nicht im Bau): alle Blenden in einem Aufbau, je ein PNG: Ort beim ersten Besuch (Thessas Kramladen),
# Ort nur mit Namen, Rast, Kampf normal (Wolf), Hinterhalt (Wolf), Boss (Krogg), dazu ein Schirm ohne Kasten (Rueckfrage) zum
# Vergleich der Groesse; die Worte voll sichtbar. Laeuft auch auf dem alten Stand (Vergleich vorher/nachher). PNG nach
# OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340; braucht daten/texte.json, intro.json

const SpielSkript = preload("res://skripte/spiel.gd")

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _kampf(eroeffnung: String, l: Dictionary) -> Control:
	var z := RandomNumberGenerator.new()
	z.seed = 661
	Kampfblende.gesehen = {}
	var k := Kampfblende.new(eroeffnung, l, z)
	k.set_process(false)
	root.add_child(k)
	k.ms = float(k.art["ein_ms"]) + 1.0
	k._stelle()
	return k

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var laden: Array = Ortsblende.daten().get("orte", {}).get("shop", [])
	var faelle := ["ort", "name", "rast", "kampf", "hinterhalt", "boss", "schirm"]
	for f in faelle:
		var teil: Control
		match f:
			"ort", "name":
				var o := Ortsblende.new("FULL" if f == "ort" else "NAME", "Thessas Kramladen", laden[0] if f == "ort" else null)
				o.set_process(false)
				root.add_child(o)
				o.ms = float(o.art["ein_ms"]) + 1.0
				o._stelle()
				teil = o
			"rast":
				var grund := Ortsblende.schwarz()
				var mitte := CenterContainer.new()
				mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				grund.add_child(mitte)
				var w := Ortsblende.worte_spalte(String(SpielSkript.rast_name("lang", "feuer")), Sprache.r("hoursGone"))
				w.custom_minimum_size.x = 1080 - 2 * 36 * AktionsKnopf.DP
				mitte.add_child(w)
				root.add_child(grund)
				teil = grund
			"kampf": teil = _kampf("NORMAL", {"id": "wolf", "name": "Wolf", "boss": false, "rudel": false})
			"hinterhalt": teil = _kampf("AMBUSHED", {"id": "wolf", "name": "Wolf", "boss": false, "rudel": false})
			"boss": teil = _kampf("NORMAL", {"id": "bugbear", "name": "Krogg", "boss": true, "rudel": false})
			"schirm":
				var grund := Control.new()
				grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				root.add_child(grund)
				Spielstaende.frage(grund, "Spielstand löschen?", [Stil.txt("Alrik (Stufe 2) wird endgültig gelöscht.", 15)],
					"KREUZ", "Löschen", Stil.WARN, func(): pass)
				teil = grund
		await _bild("661_%s" % f)
		teil.free()
		await process_frame
	print("BLENDEN661 gut")
	quit(0)
