extends SceneTree
# 557 (Chef 04.11., 11:15: „am Beispiel der Spielstände einen Entwurf … Spieldauer … in dem neuen Stil. Einmal bitte ein Bild basteln“):
# Bilder des Entwurfs B „ohne Kasten“ (Spielstaende.entwurf = "B") am Rechner, mit Fenster (xvfb-run), 1080 × 2340:
#   557_b_eins       ein voller Platz, drei leere
#   557_b_zwei       zwei volle Plaetze (1 und 3), zwei leere
#   557_wechsel_jetzt, 557_wechsel_b  Chef 12:38 („noch eine andere Stelle im Spiel im neuen Design … vorher-nachher“): Wechselliste
#                    „Oberkörper“ eines Magiers mit epischer Robe an, im Beutel drei Roben (besser, schlechter, gemischt) und ein Plattenpanzer
#   557_b_loeschen   die Rueckfrage zum Loeschen (der einzige Rahmen)
#   557_jetzt_zwei   der Stand von heute (Karten wie alt, 529) mit denselben zwei Plaetzen, zum Vergleich
# Vorlage 2 (Chef 14:21–14:26, Zu 557): dazu je „_b2“: Rueckfragen ohne Kasten (Loeschen, Wegwerfen), sichtbares „‹ ABBRECHEN“ im
#   Gegenstandsfenster und Mengenkasten, Mengenkasten neu, Weiter und Schliessen folgen dem Inhalt (Kapitelende, Brauen)
# Gruppe 557 (Chef 04.11., 13:32, 13:42, 13:44), je heute und B:
#   557_fenster_ring_jetzt/_b, 557_fenster_panzer_jetzt/_b   Gegenstandsfenster 524.1 (Ring, Kettenpanzer wie Bild 524.1)
#   557_kapitel_jetzt/_b     Schirm „Ende von Kapitel 1“ (537)
#   557_brauen_jetzt/_b, 557_braukasten_jetzt/_b   Morwens Hütte, Brauen und Mengenkasten nach „Alle“ (525)
# PNG nach BILD557_AUS (Vorgabe user://). Die Spielstaende des Rechners werden gesichert und danach wiederhergestellt.

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 30: await process_frame   # die Drehteller zeichnen ihre Figur in eigene Viewports
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD557_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _speichere(n: int, name_: String, volk: String, klasse: String, stufe: int, karte: String, tag: int, minuten: int, gespielt_ms: int, flaggen: Array, gold: int) -> void:
	var z := Zustand.new()
	z.name = name_; z.gold = gold; z.tag = tag; z.minuten = minuten; z.gespielt_ms = gespielt_ms
	for f in flaggen: z.setze(f)
	var hw := BrsHeld.fuer_spiel(name_, volk, klasse, z.neue_uid)
	if stufe > 1: Testmodus.stufe_setzen(hw, z, stufe)
	hw.leben = maxi(1, hw.max_leben() - 5)
	Spielstand.platz = n
	Spielstand.speichere(z, hw, {"karte": karte, "x": 4, "y": 6, "blick": "UP"})

func _zeige(entwurf: String, n: String, loeschen := false) -> void:
	Spielstaende.vorlage2 = entwurf == "B2"
	Spielstaende.entwurf = "B" if entwurf == "B2" else entwurf
	var s := Spielstaende.new()
	root.add_child(s)
	if loeschen:
		await process_frame
		s.frage_loeschen(Spielstand.liste()[0])
	await _bild(n)
	s.queue_free()
	await process_frame

func _ding(z: Zustand, base: String, rar: String, ilvl: int, rolls: Array, seed_: int) -> Dictionary:
	return z.ausruestung_dazu({"uid": 0, "base": base, "rarity": rar, "ilvl": ilvl, "plus": 0, "rolls": rolls, "unique": null, "name_seed": seed_})

func _wechsel() -> void:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid)
	var ad: Dictionary = BrsHeld.daten()["affixdaten"]
	var a := func(n: String, w: int) -> Array: return [n, w]
	var roll := func(xs: Array) -> Array: return xs.filter(func(r): return ad.has(String(r[0])))
	var an := _ding(z, "robe", "EPIC", 4, roll.call([a.call("DEX", 2), a.call("AC", 2), a.call("RESIST", 2), a.call("STR", 2)]), 7)
	z.beutel.erase(an)
	for x in hw.anlegen(an): z.beutel.append(x)
	_ding(z, "robe", "VERY_RARE", 6, roll.call([a.call("DEX", 3), a.call("AC", 3), a.call("RESIST", 3), a.call("STR", 3), a.call("CON", 2)]), 3)
	_ding(z, "robe", "UNCOMMON", 2, roll.call([a.call("AC", 1)]), 11)
	_ding(z, "robe", "RARE", 3, roll.call([a.call("TENACITY", 18)]), 5)
	_ding(z, "plate", "COMMON", 2, [], 2)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "ausruestung"
	m.baue()
	await process_frame
	for entwurf in ["", "B", "B2"]:   # B2: 557 Runde 4 („‹ ZURÜCK“ links)
		Menue.entwurf = "B" if entwurf == "B2" else entwurf
		Spielstaende.vorlage2 = entwurf == "B2"
		m.baue()
		await process_frame
		m.waehle("CHEST")
		await _bild("557_wechsel_" + {"": "jetzt", "B": "b", "B2": "b2"}[entwurf])
		for c in m.get_children():
			if c is ColorRect: c.queue_free()
		await process_frame
	Menue.entwurf = ""
	Spielstaende.vorlage2 = false
	m.queue_free()
	await process_frame

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var gesichert := Spielstand.liste()
	var alt_platz := Spielstand.platz
	for n in range(1, gesichert.size() + 1): Spielstand.loesche(n)
	_speichere(1, "Mira", "Elf", "Zauberlehrling", 4, "deep_forest", 3, 21 * 60 + 5, (2 * 60 + 14) * 60000, [Geschichte.QUEST_STARTED, Geschichte.BARRIER_OPEN], 37)
	await _zeige("B", "557_b_eins")
	await _zeige("B", "557_b_loeschen", true)
	await _zeige("B2", "557_b2_loeschen", true)   # Vorlage 2 (Chef 14:21): Rueckfrage ohne Kasten
	_speichere(3, "Borin", "Zwerg", "Wachsoldat", 2, "inn", 1, 9 * 60 + 40, 38 * 60000, [Geschichte.QUEST_STARTED], 12)
	await _zeige("B", "557_b_zwei")
	await _zeige("B2", "557_b2_zwei")   # 557 Runde 4: „× LÖSCHEN“ in Warnfarbe, „‹ ZURÜCK“ links
	await _zeige("", "557_jetzt_zwei")
	Spielstaende.entwurf = ""
	Spielstaende.vorlage2 = false
	await _wechsel()
	await _fenster()
	await _kapitel()
	await _brauen()
	for n in range(1, gesichert.size() + 1):
		Spielstand.loesche(n)
		if not gesichert[n - 1].is_empty():
			var f := FileAccess.open(Spielstand.datei(n), FileAccess.WRITE); f.store_string(JSON.stringify(gesichert[n - 1])); f.close()
	Spielstand.platz = alt_platz
	quit(0)

func _ring(z: Zustand, saat: int, rolls: Array) -> Dictionary:
	return {"uid": z.neue_uid.call(), "base": "ring", "rarity": "DIVINE", "ilvl": 9, "plus": 0, "rolls": rolls, "unique": null, "name_seed": saat}

# wie tests/fenster_bild_519.gd (Bild 524.1): Krieger Thora, angelegt ein Ring mit +2 GES, +2 STÄ; im Beutel ein Ring und ein Kettenpanzer
func _fenster() -> void:
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var saat := 0
	for s_ in 200:
		if Beute.name(_ring(z, s_, [])).ends_with("Eisernen Richters"): saat = s_; break
	hw.anlegen(_ring(z, saat + 1, [["DEX", 2], ["STR", 2]]))
	var neu := _ring(z, saat, [["ALL_STATS", 1], ["DEX", 2], ["CHA", 2]])
	z.beutel.append(neu)
	var panzer := Beute.erzeuge_mit_uid(KotlinZufall.new(5), z.neue_uid, 9, "DIVINE", "Wachsoldat")
	z.beutel.append(panzer)
	# Zu 557 (4) (Chef 16:42; Pruefer 16:43: „Nebenhand fehlt im Bild“): eine Einhandwaffe, damit „Nebenhand“ in der Zeile unten steht
	var schwert := {"uid": z.neue_uid.call(), "base": "shortsword", "rarity": "RARE", "ilvl": 5, "plus": 0, "rolls": [["STR", 1]], "unique": null, "name_seed": 3}
	z.beutel.append(schwert)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	for entwurf in ["", "B", "B2"]:
		Menue.entwurf = "B" if entwurf == "B2" else entwurf
		Spielstaende.vorlage2 = entwurf == "B2"
		for paar in [["ring", neu], ["panzer", panzer]] + ([["schwert", schwert]] if entwurf == "B2" else []):
			m.frage_stueck(paar[1])
			await _bild("557_fenster_%s_%s" % [paar[0], _endung(entwurf)])
			m.get_child(m.get_child_count() - 1).free()
		if entwurf != "":   # Vorlage 2: auch die Rueckfrage zum Wegwerfen, heute B (Kasten) neben ohne Kasten
			m.frage_wegwerfen(neu)
			await _bild("557_wegwerfen_" + _endung(entwurf))
			m.get_child(m.get_child_count() - 1).free()
	Menue.entwurf = ""
	Spielstaende.vorlage2 = false
	ebene.queue_free()
	await process_frame

func _kapitel() -> void:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Elf", "Zauberlehrling", z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 5)
	for entwurf in ["", "B", "B2"]:
		KapitelSchirm.entwurf = "B" if entwurf == "B2" else entwurf
		Spielstaende.vorlage2 = entwurf == "B2"
		var ebene := CanvasLayer.new()
		root.add_child(ebene)
		ebene.add_child(KapitelSchirm.new(hw, Geschichte.CHAPTER_END_TEXT))
		await _bild("557_kapitel_" + _endung(entwurf))
		ebene.queue_free()
		await process_frame
	KapitelSchirm.entwurf = ""
	Spielstaende.vorlage2 = false

# wie tests/laden_bild_525.gd: 23 Gold, 7 Kräuter, 2 Heiltränke
func _brauen() -> void:
	for entwurf in ["", "B", "B2"]:
		LadenSchirm.entwurf_b = "B" if entwurf == "B2" else entwurf
		Spielstaende.vorlage2 = entwurf == "B2"
		var z := Zustand.new()
		z.name = "Thora"; z.gold = 23
		z.dazu("herbs", 7)
		z.dazu("potion", 2)
		z.dazu("bat_wing", 0)
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		var ebene := CanvasLayer.new()
		root.add_child(ebene)
		var l := LadenSchirm.new(hw, z, Laden.new(["herbs", "potion", "remedy"], true))
		ebene.add_child(l)
		await process_frame
		l.seite = "brauen"; l.baue()
		var e := _endung(entwurf)
		await _bild("557_brauen_" + e)
		var heil: Dictionary = Laden.rezepte().filter(func(r): return String(r["ergebnis"]) == "potion")[0]
		if entwurf != "": l.braukasten_b(heil, 3, true)
		else: l.braukasten(heil, 3, true)
		await _bild("557_braukasten_" + e)
		ebene.queue_free()
		await process_frame
	LadenSchirm.entwurf_b = ""
	Spielstaende.vorlage2 = false

# Vorlage 2: heute „jetzt“, Entwurf B (Vorlage 14:15) „b“, B mit den Punkten von 14:21–14:26 „b2“
func _endung(entwurf: String) -> String: return {"": "jetzt", "B": "b", "B2": "b2"}[entwurf]
