extends SceneTree
# 522 (Chef 03.11., 23:33, Build 249: „im Testmenü … Schild gegeben, aber im Spiel kein Schild“; Magier hielt weiter den Stab statt
# des Langschwerts): ohne Bild. Im Dorf Waffe und Schild wie im Testmenue wechseln, das Menue schliesst (spiel.gd held_figur_neu);
# gemessen: neue Figur, ihre Wahl traegt das Neue; mit Kaufkoerper haengt der Schild am Ruecken; Ort und Blick bleiben; ohne Aenderung kein Neubau.
# Aufruf: im Ordner godot mit -s res://tests/ausruestung_522.gd -> „AUSRUESTUNG522 n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Probe", "Mensch", "Zauberlehrling")
	spiel.betrete("village", Vector2i(20, 12), "LEFT")
	for i in 5: await process_frame
	var hw: BrsHeld = spiel.held_werte()
	var z: Zustand = spiel.zustand
	var vorher := JSON.stringify(HeldFigur.wahl(hw, z))
	var alt: Node3D = spiel.held.modell
	var ort: Vector3 = spiel.held.position
	var blick: float = spiel.held.rotation.y
	spiel.held_figur_neu(vorher)
	pruefe(spiel.held.modell == alt, "ohne Aenderung bleibt die Figur")
	Testmodus.waffe(hw, z, "longsword")
	Testmodus.waffe(hw, z, "shield", true)
	spiel.held_figur_neu(vorher)
	await process_frame
	var neu: Node3D = spiel.held.modell
	pruefe(neu != alt and is_instance_valid(neu), "nach dem Wechsel eine neue Figur")
	var aus: Dictionary = spiel.held.wahl.get("ausruestung", {})
	pruefe(String(aus.get("MAIN_HAND", {}).get("base", "")) == "longsword", "Wahl der Figur: Langschwert in der Hand")
	pruefe(String(aus.get("OFF_HAND", {}).get("base", "")) == "shield", "Wahl der Figur: Schild")
	pruefe(spiel.held.position == ort and is_equal_approx(spiel.held.rotation.y, blick), "Ort und Blick bleiben")
	pruefe(spiel.held.anim != null and spiel.held.anim.is_playing(), "Bewegung laeuft weiter")
	if neu.has_meta("tracht"):
		var sk := Gebiet.finde(neu, "Skeleton3D")
		pruefe(sk != null and not sk.find_children("RueckenSchild*", "", false, false).is_empty(), "Kaufkoerper: Schild am Ruecken")
	else: print("ohne Kaufkoerper (daten/held_*.bin): Schildteil nur auf dem Bauserver")
	print("AUSRUESTUNG522 %d Fehler" % fehler)
	quit(1 if fehler else 0)
