extends SceneTree
# 557 eingeschaltet (Archiv 05.11., 08:18: „557 wie gebaut“): die Rast im Spiel als Rastfeld B statt der allgemeinen Wahl. Ohne Bild:
# Feuer mit Uhr und Mond, Theke mit Krug, Keule, Bett und Wirtshausschild, Gold als Angabe unter dem Titel, Rowenas Satz;
# die alte Wahl bleibt zu; Zurück schliesst. Aufruf: im Ordner godot mit -s res://tests/rast_557.gd -> „RAST557 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func texte(n: Node) -> String:
	return " | ".join(PackedStringArray(n.find_children("*", "Label", true, false).map(func(l): return (l as Label).text.replace(" ", " "))))

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	pruefe(Spielstaende.entwurf == "B" and Spielstaende.vorlage2, "Stil B mit Vorlage 2 nicht eingeschaltet")
	pruefe(Menue.entwurf == "B" and KapitelSchirm.entwurf == "B" and LadenSchirm.entwurf_b == "B", "Menü, Kapitelende oder Laden nicht in B")
	var spiel = load("res://skripte/spiel.gd").new()
	spiel.ui = Steuerung.new()
	root.add_child(spiel.ui)
	await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	spiel.zustand.gold = 42
	spiel.zustand.dazu("raw_meat", 2)
	for ort in ["feuer", "schenke"]:
		spiel.rast_ort = ort
		spiel.zeige_rast()
		await process_frame
		var f = spiel.rast_feld
		pruefe(f != null and is_instance_valid(f) and f.get_parent() == spiel.ui, "%s: kein Rastfeld" % ort)
		pruefe(not spiel.ui.waehlt(), "%s: die alte Wahl ist offen" % ort)
		if f == null: continue
		var t := texte(f)
		print("RAST557 %s: %s" % [ort, t])
		if ort == "feuer":
			pruefe(t.contains("Kurze Erholung") and t.contains("Langes Ausruhen"), "Feuer ohne Kurze Erholung und Langes Ausruhen (870.4): %s" % t)
		else:
			pruefe(t.contains("42 Gold"), "Theke ohne Gold: %s" % t)
			pruefe(t.contains("Met") and t.contains("Zimmer") and t.contains("Fleisch verkaufen"), "Theke ohne Met, Zimmer, Fleisch: %s" % t)
			pruefe(f.kopf_zeichen == "SCHENKE", "Theke ohne Wirtshausschild")
		pruefe(f.is_in_group(Zurueck.GRUPPE), "%s: Zurück-Taste nicht gemeldet" % ort)
	spiel.rast_feld_zu()
	await process_frame
	pruefe(spiel.rast_feld == null, "Rastfeld bleibt nach dem Schliessen")
	spiel.free()
	print("RAST557 %d Fehler" % fehler)
	quit(1 if fehler else 0)
