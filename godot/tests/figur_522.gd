extends SceneTree
# 522 (Chef 03.11., 23:33: im Testmenü einen Schild gegeben, im Spiel kein Schild; 23:46 „Langschwert und Schild nach Mapwechsel da“):
# die Kartenfigur wurde nur beim Kartenwechsel gebaut. Jetzt merkt sich der Held eine Abschrift seiner Wahl (Held.kleide), spiel.gd
# figur_neu vergleicht nach Menue und Testmenue und kleidet neu ein. Prueft: (1) eine Aenderung der Ausruestung ist erkennbar (vorher
# zeigte held.wahl auf dieselbe Ausruestung und sah nie einen Unterschied), (2) mit Modellen (im Lauf) ist danach ein neues Modell da.
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/figur_522.gd -> „FIGUR522 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var z := Zustand.new()
	z.name = "Mira"
	var hw := Heldwerte.erschaffe("Mira", "HUMAN", "WIZARD", {}, z.neue_uid)
	var k := Karte.lade("village", z.flaggen)
	var held := Held.new(k, HeldFigur.wahl(hw, z))
	var modelle := FileAccess.file_exists("res://daten/held.bin")
	if modelle: root.add_child(held)
	else: held.wahl = HeldFigur.wahl(hw, z).duplicate(true)   # am Rechner ohne Modelle: nur die Abschrift wie Held.kleide
	await process_frame
	pruefe(HeldFigur.wahl(hw, z) == held.wahl, "gleiche Ausrüstung gilt als geändert (Figur würde ständig neu gebaut)")
	var vorher = held.modell
	Testmodus.waffe(hw, z, "longsword")
	Testmodus.waffe(hw, z, "shield", true)
	pruefe(HeldFigur.wahl(hw, z) != held.wahl, "Langschwert und Schild nicht als Änderung erkannt")
	var sp := FileAccess.get_file_as_string("res://skripte/spiel.gd")
	var i := sp.find("func fackel_neu()")
	pruefe(i >= 0 and sp.substr(i, 80).contains("figur_neu()"), "fackel_neu (nach Menue, Testmenue) ruft figur_neu nicht")
	if modelle:
		held.kleide(HeldFigur.wahl(hw, z))
		await process_frame
		pruefe(held.modell != null and held.modell != vorher and is_instance_valid(held.modell), "kein neues Modell nach kleide")
		pruefe(HeldFigur.wahl(hw, z) == held.wahl, "nach kleide weiter als geändert erkannt")
		pruefe(held.get_children().filter(func(c): return c is Node3D and c.find_children("*", "Skeleton3D", true, false).size() > 0).size() == 1, "altes Modell hängt noch am Helden")
	else:
		print("ohne daten/held.bin: Modellteil übersprungen (im Lauf geprüft)")
	print("FIGUR522 %d Fehler" % fehler)
	quit(1 if fehler else 0)
