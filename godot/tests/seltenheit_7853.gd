extends SceneTree
# 785.3 (Dialogs.kt 116 ItemDetails): das Vorratsfenster der Tasche nennt die Seltenheit als Wort in ihrer Farbe, wie alt; je
# Seltenheit, die unter den Vorraeten vorkommt, ein Stueck.
# Aufruf: im Ordner godot mit -s res://tests/seltenheit_7853.gd -> „SELTENHEIT7853 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var je := {}
	var dinge: Dictionary = Sprache.texte.get("dinge", {})
	for id in dinge:
		var sk := String((dinge[id] as Dictionary).get("seltenheit", "COMMON"))
		if not je.has(sk): je[sk] = String(id)
	pruefe(not je.is_empty(), "keine Vorraete")
	var namen: Dictionary = BrsHeld.daten()["seltenheiten"]
	for sk in je:
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		var m := Menue.new(hw, z)
		ebene.add_child(m)
		await process_frame
		m.frage_ding(je[sk])
		await process_frame
		var l := m.find_child("Seltenheit", true, false) as Label
		pruefe(l != null, "%s (%s): Zeile Seltenheit fehlt" % [je[sk], sk])
		if l:
			var soll := Testmodus.gross_anfang(Sprache.t(namen.get(sk, {}).get("name", sk)))
			pruefe(l.text == soll, "%s: '%s' statt '%s'" % [je[sk], l.text, soll])
			pruefe(l.get_theme_color("font_color") == Color(Menue.SELTEN.get(sk, "e6ddcb")), "%s: Farbe nicht die der Seltenheit" % je[sk])
		m.free()
	print("SELTENHEIT7853 %d Fehler (%s)" % [fehler, ", ".join(je.keys())])
	quit(1 if fehler else 0)
