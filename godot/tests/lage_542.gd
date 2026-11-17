extends SceneTree
# 542 (Fund t284.4, Chef 13.11., 20:44: Station „Krogg“ lag vor Jorins Aushang, „Krogg besiegen“ und „alle annehmen“ standen nicht
# da): der Weg der Prüfzeilen für Build 285 so, wie der Chef ihn geht. Lage „station=Grak ort=village:4:8:UP uhr=10:00 ruhig“
# (Krogg besiegt, der Held vor dem Anschlagbrett, Tag, Monster beachten nicht); am Brett hängen Jorins und Gwennas Aushang, beide annehmen; der Fetzen am Steinkreis
# (Flüsterwald, nur mit Karte), Gwennas Ring aus der Truhe cave_3 (Höhle, nur mit Karte; sonst in die Tasche gelegt); Jorin und
# Gwenna nehmen ab; Lage „station=Kapitelende“: Aldric gibt den Ring des Ältesten als Einzelstück. Aufruf: im Ordner godot mit
# -s res://tests/lage_542.gd -> „LAGE542 n Fehler“ (Exit 0 bei 0)

const LAGE := {"station": "Grak", "ort": "village:4:8:UP", "uhr": "10:00", "ruhig": ""}

var fehler := 0
var spiel

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)
	else:
		print("gut ", was)

func _initialize() -> void: _lauf.call_deferred()

func lies() -> Array:
	var gelesen := []
	for i in 60:
		if not spiel.ui.spricht(): break
		gelesen.append(String(spiel.ui.text.text))
		spiel.ui.naechste()
		await process_frame
	return gelesen

func tat(f: Callable) -> void:
	var fertig := [false]
	var lauf := func():
		await f.call()
		fertig[0] = true
	lauf.call()
	for i in 900:
		if fertig[0]: break
		await process_frame
	pruefe(fertig[0], "Schritt endet")

# den Helden vor [person] stellen, ansprechen, alles lesen
func sprich_mit(person: String) -> Array:
	var ziel := Testmodus.vor_person("village", person)
	if ziel.is_empty():
		pruefe(false, "kein Feld vor " + person)
		return []
	await tat(func(): await spiel.test_tat("teleport", ["village", ziel[0].x, ziel[0].y, ziel[1]]))
	await lies()
	await rede(person)
	return await lies()

# ansprechen wie spiel.sprich; ohne gebaute Figur (am Rechner ohne daten/leute) dasselbe ohne Figur: Abgabe vor dem Gespräch
func rede(person: String) -> void:
	var wer = null
	for l in spiel.leute_liste():
		if String(l.daten["id"]) == person: wer = l
	if wer == null and not FileAccess.file_exists("res://daten/leute/%s.bin" % person):
		print("LAGE542 ohne Figur %s: Gespräch ohne Figur (am Rechner ohne Bau)" % person)
		var abgabe := Auftraege.abgabe(spiel.zustand, person)
		spiel.spiele(abgabe if not abgabe.is_empty() else Geschichte.gespraech(person, spiel.zustand))
	else:
		pruefe(wer != null, person + " steht da (10 Uhr)")
		if wer == null: return
		spiel.sprich(wer)
	await process_frame

func ruhig() -> void:   # Lauf 310: ein Wolf am Stein machte den Knopf zu „FIGHT“
	if spiel.herde != null:
		spiel.herde.aus = true
		for s in spiel.herde.liste: s.queue_free()
		spiel.herde.liste.clear()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var platz1_vorher := FileAccess.file_exists(Spielstand.datei(1))
	# (1) die Lagen
	pruefe(Testmodus.lage_fehler(LAGE).is_empty(), "Lage herstellbar: %s" % [Testmodus.lage_fehler(LAGE)])
	pruefe(Testmodus.lage_fehler({"station": "Kapitelende"}).is_empty(), "Lage Kapitelende herstellbar")
	pruefe(not Testmodus.lage_fehler({"station": "Kapitelende", "ort": "village:4:8:UP"}).is_empty(), "Kapitelende mit ort= abgelehnt")
	pruefe(Testmodus.lage_text(LAGE, true) == "Station Grak · village · 10:00 Uhr · Monster beachten nicht", "lage_text: " + Testmodus.lage_text(LAGE, true))
	Testmodus.an = true
	Testmodus.geladen = true
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	await lies()
	var z: Zustand = spiel.zustand
	# (2) Lage herstellen: Stand nach Krogg, der Held vor dem Brett
	await tat(func(): await spiel.lage_herstellen(LAGE))
	await lies()
	pruefe(spiel.karte.id == "village" and spiel.held.kachel == Vector2i(4, 8), "Ort: %s %s" % [spiel.karte.id, spiel.held.kachel])
	pruefe(z.has(Geschichte.KROGG_DEFEATED) and not z.has(Geschichte.GRAK_DEFEATED), "Stand: Krogg besiegt, Grak nicht")
	pruefe(z.minuten >= 600 and z.minuten <= 615, "Uhr: %d" % z.minuten)
	pruefe(Herde.beachten_nicht, "Monster beachten nicht")
	# (3) Anschlagbrett: Jorins und Gwennas Aushang hängen, beide annehmen
	spiel.held.rotation.y = PI
	pruefe(spiel.angebot(spiel.held.kachel)[0] == "READ", "Knopf am Brett: %s" % [spiel.angebot(spiel.held.kachel)])
	spiel._aktion()
	await process_frame
	pruefe(spiel.brett_offen, "Brett offen")
	var ids: Array = Auftraege.am_brett(z).map(func(j): return String(j["id"]))
	pruefe(ids.has("stones") and ids.has("ring"), "am Brett: %s" % [ids])
	for id in ["stones", "ring"]: spiel._brett_wahl("nimm:" + id)
	spiel._brett_wahl("zurueck")
	await process_frame
	pruefe(Auftraege.angenommen(z, Auftraege.von("stones")) and Auftraege.angenommen(z, Auftraege.von("ring")), "beide angenommen")
	# (4) Fetzen am Steinkreis: aus dem Dorf nach Norden, im Wald östlich des Wegs
	if Testmodus.da("forest"):
		await tat(func(): await spiel.test_tat("teleport", ["forest", 10, 30, "UP"]))
		await lies()
		ruhig()
		var k: Karte = spiel.karte
		var vor := Vector2i(-1, -1)
		for y in k.hoehe:
			for x in k.breite:
				if vor.x < 0 and k.zeichen(Vector2i(x, y)) == "I" and k.begehbar(Vector2i(x, y + 1)): vor = Vector2i(x, y + 1)
		pruefe(vor.x >= 0, "Stein mit freiem Feld davor")
		if vor.x >= 0:
			spiel.held.setze(vor, "UP")
			spiel.held.rotation.y = PI
			pruefe(spiel.angebot(vor)[0] == "LOOK", "Knopf am Stein: %s" % [spiel.angebot(vor)])
			spiel._aktion()
			await process_frame
			var t: Array = await lies()
			pruefe(t.size() > 0 and t[0].begins_with("Zwischen den Steinen"), "Fundtext am Stein")
		pruefe(z.anzahl(Auftraege.RAG) == 1, "Fetzen in der Tasche")
	else:
		print("LAGE542 ohne Karte forest: Fetzen in die Tasche gelegt (am Rechner ohne Bau)")
		z.dazu(Auftraege.RAG)
	# (5) Gwennas Ring in der Truhe links vom Höhleneingang
	if Testmodus.da("cave"):
		await tat(func(): await spiel.test_tat("teleport", ["cave", 10, 18, "UP"]))
		await lies()
		spiel.oeffne_kiste({"id": Auftraege.RING_CHEST})
		await process_frame
		var t: Array = await lies()
		pruefe(t.size() > 0 and t[0].begins_with("Unter Lumpen und Knochen"), "Fundtext in der Truhe")
		pruefe(z.anzahl(Auftraege.RING) == 1, "Gwennas Ring in der Tasche")
	else:
		print("LAGE542 ohne Karte cave: Ring in die Tasche gelegt (am Rechner ohne Bau)")
		z.dazu(Auftraege.RING)
	# (6) abgeben bei Jorin am Schlagbaum und Gwenna am Fluss
	var t_j: Array = await sprich_mit("jorin")
	pruefe(Auftraege.erledigt(z, Auftraege.von("stones")) and z.anzahl(Auftraege.RAG) == 0, "Jorin nimmt den Fetzen: %s" % [t_j.slice(0, 2)])
	var t_g: Array = await sprich_mit("gwenna")
	pruefe(Auftraege.erledigt(z, Auftraege.von("ring")) and z.anzahl(Auftraege.RING) == 0, "Gwenna nimmt den Ring: %s" % [t_g.slice(0, 2)])
	# (7) Aldrics Ring: Lage Kapitelende, Aldric ansprechen
	await tat(func(): await spiel.lage_herstellen({"station": "Kapitelende"}))
	await lies()
	pruefe(spiel.karte.id == "elder", "bei Aldric in seinem Haus: " + spiel.karte.id)
	if true:
		await rede("aldric")
		var t: Array = []
		for i in 6:   # Kapitelende-Schirm und Tempelmorgen dazwischen
			t.append_array(await lies())
			for j in 30: await process_frame
		var ring = null
		for g in z.beutel:
			if g.get("unique") == "ring_protection": ring = g
		pruefe(ring != null and String(ring["base"]) == "ring" and String(ring["rarity"]) == "RARE", "Aldrics Ring als Einzelstück in der Tasche")
		pruefe(z.anzahl("ring_protection") == 0, "nicht als Ding")
		pruefe(t.any(func(s): return String(s).contains("Ring des Ältesten")), "Fundzeile nennt den Ring des Ältesten")
	if not platz1_vorher: Spielstand.loesche(1)
	print("LAGE542 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
