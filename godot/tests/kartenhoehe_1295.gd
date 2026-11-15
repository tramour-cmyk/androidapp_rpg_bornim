extends SceneTree
# 1295 ohne Bild (Chef 15.11., 13:41, Build 286): über den Kartenknopf der Leiste (spiel.gd oeffne_menue("karte")) entsteht der
# Reiter Karte, bevor der Rollkasten des Menüs eine Höhe hat; das Blatt war dann nur 300 dp hoch, darunter schwarz. Soll: das
# Blatt füllt den Rollkasten, auch beim Öffnen über den Knopf, und der Anfangsblick liegt auf dem Helden. Maßgeblich ist die
# Zeile KARTENHOEHE1295.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _oeffne(z: Zustand, hw, ort: Dictionary, ueber_knopf: bool) -> Menue:
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	m.ort = ort
	if ueber_knopf: m.reiter = "karte"   # wie oeffne_menue("karte"): Reiter vor dem Einhängen
	ebene.add_child(m)
	if not ueber_knopf:
		await process_frame
		m.reiter = "karte"
		m.baue()
	for i in 6: await process_frame
	return m

func _lauf() -> void:
	root.size = Vector2i(540, 1170)
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	z.name = "Thora"
	z.setze("besucht:cave")
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	for ort in [{"karte": "cave", "x": 10, "y": 6, "blick": "UP"}, {"karte": "village", "x": 10, "y": 10, "blick": "DOWN"}]:
		var hoehen := []
		for knopf in [false, true]:
			var m: Menue = await _oeffne(z, hw, ort, knopf)
			var r: Kartenreiter = m.find_children("*", "Kartenreiter", true, false)[0] if not m.find_children("*", "Kartenreiter", true, false).is_empty() else null
			var fl = r.flaeche if r else null
			var h: float = fl.size.y if fl else 0.0
			var roll: float = m.rolle.size.y
			hoehen.append(h)
			pruefe(fl != null and h > roll * 0.7, "%s, %s: Blatt %d von %d Bildpunkten Höhe" % [ort["karte"], "Kartenknopf" if knopf else "Reiter", int(h), int(roll)])
			if fl and ort["karte"] == "cave":
				var held: Vector2 = fl.versatz + Vector2(fl.cx(int(ort["x"])), fl.cy(int(ort["y"]))) * fl.mass
				pruefe(Rect2(fl.size * 0.25, fl.size * 0.5).has_point(held), "%s: Held im Blick (%s bei Fläche %s)" % ["Kartenknopf" if knopf else "Reiter", str(held), str(fl.size)])
			m.get_parent().queue_free()
			await process_frame
		pruefe(absf(hoehen[0] - hoehen[1]) < 1.0, "%s: Knopf und Reiter gleich hoch (%d, %d)" % [ort["karte"], int(hoehen[0]), int(hoehen[1])])
	print("KARTENHOEHE1295 %d Fehler" % fehler)
	quit(1 if fehler else 0)
