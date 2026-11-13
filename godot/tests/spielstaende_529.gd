extends SceneTree
# 529 (Abgleich 512): Spielstaende wie alt (SlotsScreen.kt SlotCard 97–108): Figur des Helden links, „Gespielt: …“ (PlayClock.played),
# „Gespeichert:“ in der Ortszeit des Speicherns (stimmt auch nach einer Zeitumstellung). Ohne Aufnahme.
# Aufruf: im Ordner godot mit -s res://tests/spielstaende_529.gd -> „SPIELSTAENDE529 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func texte(n: Node) -> PackedStringArray:
	return PackedStringArray(n.find_children("*", "Label", true, false).map(func(x): return (x as Label).text.replace("\u00a0", " ")))

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	pruefe(Spielstaende.gespielt(0, true) == "Gespielt: 0 Min.", "0 ms: %s" % Spielstaende.gespielt(0, true))
	pruefe(Spielstaende.gespielt(59 * 60000 + 59000, true) == "Gespielt: 59 Min.", "59 Min.")
	pruefe(Spielstaende.gespielt((2 * 60 + 14) * 60000, true) == "Gespielt: 2 Std. 14 Min.", "2 Std. 14 Min.: %s" % Spielstaende.gespielt((2 * 60 + 14) * 60000, true))
	pruefe(Spielstaende.gespielt(75 * 60000, false) == "Played: 1 h 15 min", "englisch")

	var z := Zustand.new()
	z.name = "Thora"
	z.gespielt_ms = (2 * 60 + 14) * 60000 + 5000
	var hw := BrsHeld.fuer_spiel("Thora", "Zwerg", "Klosterschüler", z.neue_uid)
	pruefe(Zustand.aus_daten(z.als_daten()).gespielt_ms == z.gespielt_ms, "gespielte Zeit geht beim Speichern verloren")
	# Sommerzeit gespeichert (Ortszeit 14:05), heute Winter: die Karte zeigt 14:05, nicht aus der Unix-Zeit gerechnet
	var d := {"version": Spielstand.VERSION, "platz": 2, "zustand": z.als_daten(), "held": hw.spiel_daten(), "ort": {"karte": "village"},
		"gespeichert": 1, "gespeichert_ortszeit": {"year": 2026, "month": 10, "day": 24, "hour": 14, "minute": 5, "second": 0}}
	var k := Spielstaende.karte(d)
	root.add_child(k)
	await process_frame
	var t := texte(k)
	pruefe("Gespeichert: 24.10.2026, 14:05" in t, "Gespeichert nicht in der Ortszeit: %s" % [t])
	pruefe("Gespielt: 2 Std. 14 Min." in t, "Spielzeit fehlt: %s" % [t])
	var b := k.find_child("Heldbild", true, false)
	pruefe(b is Drehteller and not (b as Drehteller).dreht, "Figur des Helden fehlt oder dreht sich")
	pruefe(b != null and (b as Control).mouse_filter == Control.MOUSE_FILTER_IGNORE, "Figur faengt das Antippen der Karte")
	pruefe(b != null and (b as Drehteller).wahl.get("volk", "") == "DWARF" and (b as Drehteller).wahl.get("herkunft", "") == "Klosterschüler", "nicht der gespeicherte Held: %s" % [(b as Drehteller).wahl if b else {}])
	# aeltere Spielstaende ohne Ortszeit: aus der Unix-Zeit, ohne Absturz; ohne Held: Grundfigur
	var alt := Spielstaende.gespeichert_um({"gespeichert": 1700000000000})
	pruefe(alt.has("hour") and int(alt["year"]) == 2023, "alter Spielstand ohne Ortszeit: %s" % [alt])
	pruefe(Spielstaende.heldbild({}).is_empty(), "ohne Held nicht die Grundfigur")
	print("SPIELSTAENDE529 %d Fehler" % fehler)
	quit(1 if fehler else 0)
