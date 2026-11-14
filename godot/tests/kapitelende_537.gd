extends SceneTree
# 537 (Abgleich Build 249: „nach Aldric kein ‚ENDE VON KAPITEL 1‘, keine Tempelszene, keine Nacht, kein Morgen im Tempel“): ohne
# Bild; Hoehle geschafft, Lyra frei, Amulett in der Tasche, Abend, Funke brennt; Aldric bis zum Ende angehoert: Kapitelende-Schirm
# (Titel, Text mit „ENDE VON KAPITEL 1“, Zeile des Helden, „Weiter“, das Spiel steht), dann die Tempelszene (uebersprungen), dann
# der Morgen im Tempel (Game.kt Cmd.Morning: naechster Tag 6:30, geheilt, Wiederkehrort Tempel, lange Rast verbraucht, Funke aus)
# und erst dort die Zeilen: Funke erloschen, Lyras drei Saetze, TEMPLE_SEEN und CAMP_TOLD. Die Chronik bietet danach „Die
# Morgenandacht ansehen“. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/kapitelende_537.gd
# -> „KAPITELENDE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func finde(klasse) -> Node:
	for n in root.find_children("*", "", true, false):
		if is_instance_of(n, klasse) and not n.is_queued_for_deletion(): return n
	return null

func texte(n: Node) -> String:
	return " | ".join(PackedStringArray(n.find_children("*", "Label", true, false).map(func(l): return l.text.replace("\u00a0", " "))))   # 557: fest verbundene Wörter

# Zeilen lesen, bis kein Text mehr offen ist; zurueck die gelesenen
func lies(spiel) -> Array:
	var gelesen := []
	for i in 60:
		if not spiel.ui.spricht(): break
		gelesen.append(String(spiel.ui.text.text))
		spiel.ui.naechste()
		await process_frame
	return gelesen

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	await lies(spiel)   # Rowena beim Erwachen
	var z: Zustand = spiel.zustand
	for f in [Geschichte.INTRO_DONE, Geschichte.QUEST_STARTED, Geschichte.BARRIER_OPEN, Geschichte.KROGG_DEFEATED, Geschichte.GRAK_DEFEATED,
			Geschichte.LYRA_RESCUED, Geschichte.LYRA_GONE]:
		z.setze(f)
	if z.anzahl("sun_amulet") == 0: z.dazu("sun_amulet")
	z.minuten = 20 * 60
	var tag := z.tag
	z.funke = true
	z.lange_rast_tag = 0
	var hw: BrsHeld = spiel.held_werte()
	hw.leben = 1
	var ziel := Testmodus.vor_aldric()
	spiel.betrete("elder", ziel[0], ziel[1])
	for i in 3: await process_frame
	await lies(spiel)
	var gold := z.gold
	spiel.spiele(Geschichte.gespraech("aldric", z))
	await process_frame
	var aldric: Array = await lies(spiel)
	pruefe("Aldric bis zum Morgen-Satz", aldric.any(func(t): return t.begins_with("Morgen bei Sonnenaufgang")), true)
	pruefe("Kapitel 1 vorbei", z.has(Geschichte.CHAPTER1_DONE), true)
	pruefe("200 Gold", z.gold - gold, 200)
	# Kapitelende-Schirm
	var ks = finde(KapitelSchirm)
	pruefe("Kapitelende-Schirm da", ks != null, true)
	if ks == null:
		print("KAPITELENDE %d Fehler" % fehler); quit(1); return
	var t := texte(ks)
	pruefe("Titel", t.to_upper().contains(Sprache.u("title").to_upper()), true)   # 557 B: Titel in Versalien
	pruefe("ENDE VON KAPITEL 1", t.contains("ENDE VON KAPITEL 1"), true)
	pruefe("Zeile des Helden", t.containsn(hw.name) and t.contains(ErschaffungBrs.heldenstufe(hw.stufe)), true)   # 557 B: Name eigene Zeile in Versalien; 870.4 „Heldenstufe n“
	pruefe("Spiel steht", paused, true)
	pruefe("Welt dahinter schwarz", spiel.blende.color.a, 1.0)
	pruefe("noch kein Morgen", [spiel.karte.id, z.minuten], ["elder", 20 * 60])
	# 557 Stil B: „WEITER ›“ ist ein Knopf aus Spielstaende.knopf (PanelContainer mit Label „Text“), Tippen ueber gui_input
	var weiter: Control = ks.find_child("Weiter", true, false)
	var wt: Label = weiter.find_child("Text", true, false) if weiter else null
	pruefe("Weiter-Knopf", wt != null and wt.text == Sprache.u("next").to_upper(), true)
	for an in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an; e.position = weiter.size * 0.5
		weiter.gui_input.emit(e)
	for i in 3: await process_frame
	pruefe("Schirm zu", finde(KapitelSchirm) == null, true)
	# Tempelszene
	var zb = finde(Zwischenbild)
	pruefe("Tempelszene laeuft", zb != null and zb.art == "tempel", true)
	pruefe("Tempelszene hat Saetze und Bilder", zb != null and zb.saetze.size() > 0 and zb.bilder.size() > 0, true)
	pruefe("Spiel steht in der Tempelszene", paused, true)
	pruefe("noch nicht im Tempel", spiel.karte.id, "elder")
	if zb: zb.beende()
	for i in 3: await process_frame
	await create_timer(1.5).timeout   # Aufblenden (abblenden 0,35 s)
	# Morgen im Tempel
	pruefe("Morgen: im Tempel", [spiel.karte.id, spiel.held.kachel], ["temple", Vector2i(4, 3)])
	pruefe("Morgen: naechster Tag 6:30", [z.tag, z.minuten >= 6 * 60 + 30 and z.minuten < 6 * 60 + 40], [tag + 1, true])   # die Uhr laeuft beim Aufblenden weiter
	pruefe("Morgen: geheilt", hw.leben, hw.max_leben())
	pruefe("Morgen: Funke aus", z.funke, false)
	pruefe("Morgen: Wiederkehrort Tempel", String(z.wiederkehr.get("karte", "")), "temple")
	pruefe("Morgen: lange Rast verbraucht", z.lange_rast_tag, z.tag)
	pruefe("Spiel laeuft wieder", paused, false)
	pruefe("aufgeblendet", spiel.blende.color.a, 0.0)
	var morgen: Array = await lies(spiel)
	pruefe("erste Zeile: Funke erloschen", morgen.size() > 0 and morgen[0] == Sprache.r("sparkFaded"), true)
	pruefe("Lyras drei Saetze", morgen.size() >= 4 and morgen[1].begins_with("Ich verdanke dir mein Leben") and morgen[2].begins_with("Graks Leute")
		and morgen[3].begins_with("Ich weiß nicht"), true)
	pruefe("TEMPLE_SEEN, CAMP_TOLD", [z.has(Geschichte.TEMPLE_SEEN), z.has(Geschichte.CAMP_TOLD)], [true, true])
	# Chronik: die Morgenandacht noch einmal
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "chronik"
	m.bisher = true
	m.baue()
	await process_frame
	# 860: Zeile mit „›“ ohne Kasten (Spielstaende.zeile_mit_pfeil, tippbar) statt Knopf in Versalien
	var b: Label = null
	for k in m.find_children("*", "Label", true, false):
		if String(k.text) == "Die Morgenandacht ansehen": b = k
	pruefe("Chronik: Morgenandacht ansehen", b != null and b.get_parent().get_parent() is PanelContainer, true)
	m.queue_free()
	print("KAPITELENDE %d Fehler" % fehler)
	quit(1 if fehler else 0)
