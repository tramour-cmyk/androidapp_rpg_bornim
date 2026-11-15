extends SceneTree
# 785.8 (Fund t286.6, Chef 15.11., 11:21: „Am Brett steht nur Felle für den Winter, Hauer für den Schmied und Gift gegen Gift“): der
# Aushang „Feuer am Steinkreis“ war im Spielstand des Chefs erledigt und der Wald erkundet, die Marken auf der Karte so nicht prüfbar.
# Lage „station=Grak auftrag=stones unerkundet=forest“: Jorins Aushang angenommen und offen (auch aus einem Stand, in dem er erledigt
# war und der Fetzen in der Tasche lag), der Wald ohne Erkundetes. Aufruf: im Ordner godot -s res://tests/lage_785_8.gd
# -> „LAGE7858 n Fehler“ (Exit 0 bei 0)

const LAGE := {"station": "Grak", "auftrag": "stones", "unerkundet": "forest"}

var fehler := 0
var spiel

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)
	else:
		print("gut ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	pruefe(Testmodus.lage_fehler(LAGE).is_empty(), "Lage herstellbar: %s" % [Testmodus.lage_fehler(LAGE)])
	pruefe(not Testmodus.lage_fehler({"auftrag": "gibtsnicht"}).is_empty(), "unbekannter Auftrag abgelehnt")
	pruefe(not Testmodus.lage_fehler({"unerkundet": "gibtsnicht"}).is_empty(), "unbekannte Karte abgelehnt")
	pruefe(Testmodus.lage_text(LAGE, true).contains("Auftrag angenommen stones"), "lage_text: " + Testmodus.lage_text(LAGE, true))
	Testmodus.an = true
	Testmodus.geladen = true
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	while spiel.ui.spricht():
		spiel.ui.naechste()
		await process_frame
	var z: Zustand = spiel.zustand
	# Spielstand wie beim Chef: Aushang erledigt, Fetzen noch da, Wald erkundet
	z.setze("job_stones"); z.setze("job_stones_done"); z.dazu(Auftraege.RAG)
	z.erkundet["forest"] = "ff"
	var fertig := [false]
	var lauf := func():
		await spiel.lage_herstellen(LAGE)
		fertig[0] = true
	lauf.call()
	for i in 900:
		if fertig[0]: break
		await process_frame
	pruefe(fertig[0], "Lage herstellen endet")
	var j := Auftraege.von("stones")
	pruefe(Auftraege.angenommen(z, j), "Aushang angenommen und offen")
	pruefe(z.anzahl(Auftraege.RAG) == 0, "Fetzen nicht in der Tasche (sonst findet der Held am Steinkreis nichts)")
	pruefe(not z.erkundet.has("forest"), "Wald ohne Erkundetes")
	pruefe(not Auftraege.fund_bei(z, Auftraege.RAG_MAP, Auftraege.MENHIR).is_empty(), "am Steinkreis liegt der Fetzen")
	print("LAGE7858 %d Fehler" % fehler)
	quit(1 if fehler else 0)
