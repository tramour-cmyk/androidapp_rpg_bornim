extends SceneTree
# 1156 (Vorlage 1020 D Stufe 2): Knopf „Lage herstellen“ je Zeile der Prüfliste. Prüft: jede Lage der Prüfliste im Bau ist herstellbar
# (Station, Gegner, Werte bekannt; am Rechner ohne daten/pruefliste.json übersprungen); falsche Lagen werden erkannt; die Wahl des
# Probekampfs folgt der Lage; im Spiel stellt die Lage Uhr, Stufe, Vorräte, Ort und Geschichte her; die aufgeklappte Zeile zeigt den
# Knopf. Aufruf: im Ordner godot mit -s res://tests/lage_1156.gd -> „LAGE1156 0 Fehler“ (Exit 0)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func knoepfe(n: Node, text: String) -> int:
	var k := 0
	for l in n.find_children("*", "Label", true, false):
		if (l as Label).text.to_lower() == text.to_lower(): k += 1
	return k

func _lauf() -> void:
	var platz1_vorher := FileAccess.file_exists(Spielstand.datei(1))
	# (1) die Lagen der Prüfliste im Bau
	if FileAccess.file_exists(Pruefliste.DATEI):
		var n := 0
		for z in Pruefliste.zeilen():
			if z.get("lage", {}) is Dictionary and not z.get("lage", {}).is_empty():
				n += 1
				for f in Testmodus.lage_fehler(z["lage"]): pruefe(false, "Lage %s: %s" % [z["nr"], f])
		print("LAGE1156 im Bau: %d Zeilen mit Lage" % n)
	else:
		print("LAGE1156 keine daten/pruefliste.json (am Rechner ohne Bau)")
	# (2) falsche Lagen
	pruefe(Testmodus.lage_fehler({"uhr": "20:30", "stufe": "3", "vorraete": "", "merker": "+intro_done,-barrier_open"}).is_empty(),
		"gute Lage abgelehnt: %s" % [Testmodus.lage_fehler({"uhr": "20:30", "stufe": "3", "vorraete": "", "merker": "+intro_done,-barrier_open"})])
	for schlecht in [{"station": "Nirgendwo"}, {"uhr": "25:00"}, {"uhr": "abends"}, {"merker": "+gibtsnicht"}, {"stufe": "drei"},
			{"quatsch": "1"}, {"ort": "village:x:7"}, {"ort": "village:11:7:OBEN"}, {"tasche": "groß"}, {"zug": "tanz"}]:
		pruefe(not Testmodus.lage_fehler(schlecht).is_empty(), "falsche Lage nicht erkannt: %s" % [schlecht])
	pruefe(Testmodus.lage_uhr("20:30") == 1230 and Testmodus.lage_uhr("8") == 480 and Testmodus.lage_uhr("24:00") == -1, "lage_uhr")
	# (3) Wahl des Probekampfs
	var fs := Testmodus.feinde(true)
	if not fs.is_empty():
		var g := String(fs.keys()[0])
		var l := {"probe": g, "held": "test", "herkunft": "Zauberlehrling", "pstufe": "5", "waffe": "", "tasche": "voll", "leben": "knapp",
			"zeit": "nacht", "zug": "flucht", "ausweichen": "", "eroeffnung": "HERO_FIRST"}
		pruefe(Testmodus.lage_fehler(l).is_empty(), "Probe-Lage abgelehnt: %s" % [Testmodus.lage_fehler(l)])
		var pr := Testmodus.lage_probe(l)
		pruefe(pr == [g, "Zauberlehrling", 5, true, "test"], "lage_probe gibt %s" % [pr])
		pruefe(Testmodus.probe_tasche == "voll" and Testmodus.probe_leben == "knapp" and Testmodus.probe_zeit == "nacht" and Testmodus.probe_zug == "flucht"
			and Testmodus.probe_ausweichen and Testmodus.probe_waffe == "" and Testmodus.eroeffnung == "HERO_FIRST", "Wahl des Probekampfs nicht gesetzt")
		Testmodus.lage_probe({"probe": g})   # Rest wieder wie vorgegeben
		pruefe(Testmodus.probe_tasche == "zwei" and Testmodus.probe_zug == "" and not Testmodus.probe_ausweichen and Testmodus.probe_waffe == "*", "Vorgaben nicht zurück")
		Testmodus.eroeffnung = "NORMAL"
		# 964 (Fund t284.5): Zauberlehrling im Kettenhemd über die Lage; Metall sperrt dann Evokation, Illusion, Beschwörung
		var lr := {"probe": g, "held": "test", "herkunft": "Zauberlehrling", "ruestung": "chain_shirt"}
		pruefe(Testmodus.lage_fehler(lr).is_empty(), "Lage mit ruestung abgelehnt: %s" % [Testmodus.lage_fehler(lr)])
		pruefe(not Testmodus.lage_fehler({"probe": g, "ruestung": "longsword"}).is_empty(), "ruestung=longsword angenommen")
		Testmodus.lage_probe(lr)
		var hr: BrsHeld = Testmodus.probe_aufbau("Zauberlehrling", 3)["held"]
		var br = hr.ding("CHEST")
		pruefe(br is Dictionary and String(br["base"]) == "chain_shirt" and BrsHeld.metall("chain_shirt"), "Lage ruestung: Brust %s" % [br])
		Testmodus.lage_probe({"probe": g})
		pruefe(Testmodus.probe_ruestung == "*", "ruestung nicht zurück")
		pruefe(Testmodus.lage_text({"station": "Garrick", "uhr": "20:30", "probe": g}, true) == "Station Garrick · 20:30 Uhr · Probekampf " + String(fs[g]),
			"lage_text: %s" % Testmodus.lage_text({"station": "Garrick", "uhr": "20:30", "probe": g}, true))
	pruefe(Testmodus.lage_probe({"uhr": "10:00"}).is_empty(), "lage_probe ohne probe nicht leer")
	# (4) im Spiel: Uhr, Stufe, Vorräte, Geschichte, Ort
	Testmodus.an = true
	Testmodus.geladen = true
	var szene: PackedScene = load("res://spiel.tscn")
	var spiel = szene.instantiate() if szene else null
	if spiel != null:
		root.add_child(spiel)
		for i in 10: await process_frame
		var fertig := [false]
		var lauf := func():
			await spiel.lage_herstellen({"ort": "village:11:7:DOWN", "uhr": "20:30", "stufe": "4", "vorraete": "", "merker": "+barrier_open,-hunter_met"})
			fertig[0] = true
		lauf.call()
		for i in 600:
			if fertig[0]: break
			await process_frame
		pruefe(fertig[0], "lage_herstellen endet nicht")
		pruefe(spiel.karte.id == "village" and spiel.held.kachel == Vector2i(11, 7), "Ort: %s %s" % [spiel.karte.id, spiel.held.kachel])
		var uhr: int = spiel.zustand.minuten
		pruefe(uhr >= 20 * 60 + 30 and uhr <= 20 * 60 + 40, "Uhr: %d" % uhr)   # die Spieluhr läuft weiter
		pruefe(spiel.werte.stufe == 4, "Stufe: %d" % spiel.werte.stufe)
		pruefe(spiel.zustand.anzahl(Geschichte.SMOKE_BUNDLE) >= 1, "Vorräte nicht aufgefüllt")
		pruefe(spiel.zustand.has("barrier_open") and not spiel.zustand.has("hunter_met"), "Merker nicht gesetzt")
		# falsche Lage: nichts geändert
		fertig[0] = false
		var lauf2 := func():
			await spiel.lage_herstellen({"uhr": "99:00", "stufe": "2"})
			fertig[0] = true
		lauf2.call()
		for i in 60:
			if fertig[0]: break
			await process_frame
		pruefe(spiel.werte.stufe == 4 and spiel.zustand.minuten >= uhr and spiel.zustand.minuten <= uhr + 10, "falsche Lage hat etwas geändert")
		# Station, wo es die Karte gibt (im Bau)
		if Testmodus.da("forest"):
			fertig[0] = false
			var lauf3 := func():
				await spiel.lage_herstellen({"station": "Garrick", "uhr": "10:00"})
				fertig[0] = true
			lauf3.call()
			for i in 900:
				if fertig[0]: break
				await process_frame
			pruefe(spiel.karte.id == "forest" and spiel.zustand.minuten >= 600 and spiel.zustand.minuten <= 610 and spiel.zustand.has("barrier_open") and not spiel.zustand.has("hunter_met"),
				"Station Garrick: %s %d" % [spiel.karte.id, spiel.zustand.minuten])
		else:
			print("LAGE1156 ohne Karte forest: Station nicht geprüft (am Rechner ohne Bau)")
		# (5) die aufgeklappte Zeile zeigt den Knopf
		Pruefliste._liste = {"build": 9998, "titel": "Probe", "kopf": [], "abschnitte": [{"titel": "", "zeilen": [
			{"nr": "9998.1", "team": "Tom", "vorgang": "1156", "wo": "a", "richtig": "r", "falsch": "f", "lage": {"uhr": "10:00"}},
			{"nr": "9998.2", "team": "Tom", "vorgang": "1156", "wo": "b", "richtig": "r", "falsch": "f"}]}]}
		Pruefliste.zu = false
		for nr in ["9998.1", "9998.2"]:
			Pruefliste.offen = nr
			spiel.oeffne_menue("test")
			for i in 5: await process_frame
			var ms := root.find_children("*", "Menue", true, false)
			pruefe(not ms.is_empty(), "kein Menü offen")
			if not ms.is_empty():
				var k := knoepfe(ms[0], "Lage herstellen") + knoepfe(ms[0], "Set up")
				pruefe(k == (1 if nr == "9998.1" else 0), "Zeile %s: %d Knöpfe „Lage herstellen“" % [nr, k])
				(ms[0] as Menue).zu.emit()
				for i in 5: await process_frame
	if not platz1_vorher: Spielstand.loesche(1)
	print("LAGE1156 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
