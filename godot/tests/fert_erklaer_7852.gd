extends SceneTree
# 785.2 (alt MenuScreen.kt 692): im Reiter „Fertigkeiten“ und im Heldenreiter erklaert Antippen einer Fertigkeit, was sie tut: das
# Erklaerfenster mit dem Namen als Kopf und demselben Satz wie in der Erschaffung (ErschaffungBrs.erklaerung „fert“), auch bei den
# matten, noch nicht geuebten; wo sie noch nicht wirkt, mit dem Satz [954.1.spaeter].
# Aufruf: im Ordner godot mit -s res://tests/fert_erklaer_7852.gd -> „FERTERKLAER7852 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func tippe(c: Control) -> void:
	var p := c.get_global_rect().get_center()
	for an in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = an
		e.position = p - c.get_global_rect().position
		c.gui_input.emit(e)

func texte(n: Node) -> String:
	var t := []
	for l in n.find_children("*", "Label", true, false): t.append((l as Label).text.replace(char(0xA0), " "))
	return "\n".join(t)

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	var gemerkt: Dictionary = Bedienung.fert_gruppen.duplicate()
	Bedienung.fert_gruppen = {"Schatten": true}
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	z.brs = BrsHeld.neu("Mensch", "Wachsoldat").als_daten()
	var m := Menue.new(hw, z)
	root.add_child(m)
	for reiter in ["held", "fertigkeiten"]:
		m.reiter = reiter; m.baue()
		for i in 6: await process_frame
		var proben: Array = (z.brs["fertigkeiten"] as Dictionary).keys().slice(0, 1)
		if reiter == "fertigkeiten": proben.append("Schleichen")   # matt, ungeuebt, ohne Wirkung
		for f in proben:
			var c := m.inhalt.find_child("Fert_" + String(f), true, false) as Control
			pruefe(c != null, "%s: Feld Fert_%s fehlt" % [reiter, f])
			if c == null: continue
			tippe(c)
			await process_frame
			pruefe(is_instance_valid(m.erklaer_fenster), "%s: Antippen %s oeffnet kein Fenster" % [reiter, f])
			if not is_instance_valid(m.erklaer_fenster): continue
			var t := texte(m.erklaer_fenster)
			var satz := ErschaffungBrs.erklaerung("fert", String(f)).replace(char(0xA0), " ")
			pruefe(satz != "" and t.contains(satz), "%s: Satz zu %s fehlt: %s" % [reiter, f, t.left(160)])
			pruefe(t.to_upper().contains(ErschaffungBrs.fert_name(String(f)).to_upper()), "%s: Kopf %s fehlt" % [reiter, f])
			if f == "Schleichen": pruefe(t.contains(ErschaffungBrs.tx(ErschaffungBrs.SPAETER).replace(char(0xA0), " ")), "Schleichen ohne Satz spaeter")
			m.schliesse_erklaerung()
			await process_frame
	Bedienung.fert_gruppen = gemerkt
	Bedienung.speichere()
	print("FERTERKLAER7852 %d Fehler" % fehler)
	quit(1 if fehler else 0)
