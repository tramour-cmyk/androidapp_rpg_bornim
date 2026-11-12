extends SceneTree
# 842 (807 A, 807a A; Texte STORY-K1-FERTIGKEITEN.md, Werte 1037): Pim heimschicken mit Probe auf Ueberreden, Knopf im Gespraech
# (auch Osrics „Kaufen“), Dank der Mutter einmal, Pim geht heim; Verband aus der Tasche heilt nach Heilkunde und uebt sie; Osric
# verkauft nur Verbaende, Thessa auch. Aufruf: -s res://tests/pim_verband_842.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func knopf_in(bef: Array) -> Dictionary:
	for c in bef:
		if String(c["art"]) == "knopf": return c
	return {}

func texte(bef: Array) -> Array:
	var r: Array = []
	for c in bef:
		if String(c["art"]) == "sagen": r.append(String(c["text"]["de"]))
	return r

func _lauf() -> void:
	Sprache.setze("de")
	# Chance aus werte.json „proben“: 35 + 1 je Punkt Ueberreden, Pim 0, begrenzt 5–95
	# Zahlen aus werte.json „proben“ (1037, 1051 A; Werte Jerry), nicht fest im Test
	var pw: Dictionary = BrsHeld.lade().get("proben", {})
	for w in [0, 10, 24]:
		var soll := clampi(roundi(float(pw.get("ueberreden_basis", 0)) + float(pw.get("ueberreden_je_punkt", 0)) * w), int(pw.get("min", 5)), int(pw.get("max", 95)))
		pruefe(Geschichte.probe_chance("Überreden", w, "Pim") == soll, "Chance Überreden %d: %d (%d)" % [w, soll, Geschichte.probe_chance("Überreden", w, "Pim")])
	pruefe(Geschichte.probe_chance("Überreden", 1000, "Pim") == int(pw.get("max", 95)), "Chance gedeckelt")
	# 1084: mit „ueberreden_stufe“ (Pim 1, werte.json auf claude/tuffy-1084) 5 je Stufe des Helden ueber 1; ohne Eintrag kein Stufenteil
	var pr: Dictionary = BrsHeld.lade().get("proben", {})
	if (pr.get("ueberreden_stufe", {}) as Dictionary).has("Pim"):
		var d := Geschichte.probe_chance("Überreden", 10, "Pim", 3) - Geschichte.probe_chance("Überreden", 10, "Pim", 1)
		pruefe(d == roundi(2 * float(pr.get("je_stufe", 0))), "Stufe 3 gegen Pim (Stufe 1): +%d" % d)
	else:
		pruefe(Geschichte.probe_chance("Überreden", 10, "Pim", 3) == Geschichte.probe_chance("Überreden", 10, "Pim", 1), "ohne ueberreden_stufe kein Stufenteil")

	# tagsueber: nach [504.pim.vor] der Knopf mit der Fertigkeit; nachts, nach Versuch oder Erfolg heute keiner
	var z := Zustand.new()
	z.tag = 3
	z.minuten = 10 * 60
	var bef := Geschichte.gespraech("pim", z)
	var kn := knopf_in(bef)
	pruefe(not kn.is_empty() and String(kn["knopf"]["de"]) == "Schick Pim heim (Überreden)" and String(kn["knopf"]["en"]) == "Send Pim home (Persuasion)", "Knopf [807.pim.wahl]: %s" % [kn.get("knopf", {})])
	pruefe(kn.has("probe") and String(kn["probe"]["fert"]) == "Überreden" and String(kn["probe"]["gegen"]) == "Pim", "Probe auf Überreden gegen Pim")
	var i_vor := -1; var i_kn := -1
	for i in bef.size():
		if String(bef[i]["art"]) == "sagen" and i_kn < 0: i_vor = i
		if String(bef[i]["art"]) == "knopf": i_kn = i
	pruefe(i_vor >= 0 and i_kn > i_vor, "Knopf nach der Zeile [504.pim.vor]")
	var ja: Array = kn["probe"]["ja"]; var nein: Array = kn["probe"]["nein"]
	var ja_fl := ja.filter(func(c): return String(c["art"]) == "flagge").map(func(c): return String(c["flagge"]))
	pruefe(ja_fl.has("pim_home_3") and ja_fl.has(Geschichte.PIM_HEIM), "gelingt: heute heim und einmal gelungen (%s)" % [ja_fl])
	pruefe(texte(ja)[0] == "Na gut. Aber nur, weil du es bist." and texte(ja)[1] == "Pim trottet heim, mit einem letzten Blick zum Schlagbaum.", "gelingt, Wortlaut 1: %s" % [texte(ja)])
	var erz := ja.filter(func(c): return String(c["art"]) == "sagen")
	pruefe(erz[0].has("wer") and not erz[1].has("wer"), "Pim spricht, dann erzählt ohne Namen")
	pruefe(nein.any(func(c): return String(c["art"]) == "flagge" and String(c["flagge"]) == "pim_tried_3") and texte(nein)[0] == "Ich bin doch schon groß! Und Jorin hält eh Wache.", "misslingt: heute versucht, [807.pim.nein]")
	# alle drei Wortlaute je Marke, nie derselbe zweimal hintereinander
	var gesehen := {}
	var zz := Zustand.new(); zz.minuten = 10 * 60
	for n in 12:
		zz.tag = 10 + n
		var j: Array = knopf_in(Geschichte.gespraech("pim", zz))["probe"]["ja"]
		for c in j:
			if String(c["art"]) == "variante":
				var vv: Array = zz.varianten.get("807.pim.ja", [0, -1])
				zz.varianten["807.pim.ja"] = [int(vv[0]) + 1, int(c["wahl"])]
		gesehen[texte(j)[0]] = true
	pruefe(gesehen.size() == 3, "drei Wortlaute [807.pim.ja]: %s" % [gesehen.keys()])
	z.minuten = 23 * 60
	pruefe(knopf_in(Geschichte.gespraech("pim", z)).is_empty(), "nachts kein Knopf")
	z.minuten = 10 * 60
	z.setze("pim_tried_3")
	pruefe(knopf_in(Geschichte.gespraech("pim", z)).is_empty(), "nach dem Fehlschlag heute kein Knopf")
	z.tag = 4
	pruefe(not knopf_in(Geschichte.gespraech("pim", z)).is_empty(), "am nächsten Tag wieder")
	z.setze("chapter1_done")
	pruefe(knopf_in(Geschichte.gespraech("pim", z)).is_empty(), "nach Kapitel 1 kein Knopf")

	# Pim geht heim und bleibt drinnen, nur heute
	var w := Zustand.new(); w.tag = 5; w.minuten = 10 * 60
	var dorf := Karte.lade("village")
	Leute.uhr = func(): return w.minuten
	Leute.frueh_heim = func(id: String) -> bool: return Geschichte.frueh_heim(id, w)
	var h3 := Node3D.new()
	var pim := Leute.new(dorf, {"id": "pim", "x": 15, "y": 14, "streifen": 3}, h3)
	pruefe(not bool(pim.plan_jetzt()[4]), "vorher draußen: %s" % [pim.plan_jetzt()])
	w.setze("pim_home_5")
	pruefe(bool(pim.plan_jetzt()[4]) and Vector2i(int(pim.plan_jetzt()[1]), int(pim.plan_jetzt()[2])) == Vector2i(13, 23), "heimgeschickt: an seiner Tür hinein %s" % [pim.plan_jetzt()])
	w.tag = 6
	pruefe(not bool(pim.plan_jetzt()[4]), "am nächsten Tag wieder draußen")
	pim.free(); h3.free()
	Leute.uhr = Callable(); Leute.frueh_heim = Callable()

	# die Mutter dankt einmal, nur am Tag, statt [504.tuer.pim]
	var m := Zustand.new(); m.minuten = 11 * 60
	pruefe(Geschichte.klopfen("village", Vector2i(13, 22), m).is_empty(), "vor dem Erfolg sagt die Mutter das Übliche")
	m.setze(Geschichte.PIM_HEIM)
	var d := Geschichte.klopfen("village", Vector2i(13, 22), m)
	var sp := Geschichte.klopf_sprecher("village", Vector2i(13, 22), [{"text": d}])
	pruefe(String(sp[0]["text"]["de"]) == "Pim kam heim, ganz zahm. Was du ihm auch gesagt hast: danke, {name}." and String(sp[0]["wer"]["de"]) == "Pims Mutter", "Dank [807.pim.dank] von Pims Mutter: %s" % [sp])
	m.minuten = 2 * 60
	pruefe(Geschichte.klopfen("village", Vector2i(13, 22), m).is_empty(), "nachts kein Dank")
	m.minuten = 11 * 60
	m.setze(Geschichte.PIM_DANK)
	pruefe(Geschichte.klopfen("village", Vector2i(13, 22), m).is_empty(), "danach nicht noch einmal")

	# Osric: „Kaufen“ als Knopf unter der Heilung, oeffnet nur Verbaende
	var o := Geschichte.gespraech("osric", Zustand.new())
	var ok := knopf_in(o)
	pruefe(not ok.is_empty() and String(ok["knopf"]["de"]) == "Kaufen" and String(ok["dann"][0]["art"]) == "laden" and Array(ok["dann"][0]["waren"]) == ["bandage"] and bool(ok["dann"][0]["nur_vorraete"]), "Osric: Knopf „Kaufen“ öffnet nur Verbände")
	pruefe(Geschichte.SHOP_STOCK.has("bandage"), "Thessa führt Verbände")
	pruefe(Katalog.preis("bandage") == 8, "Preis aus dem Katalog 8 (%d)" % Katalog.preis("bandage"))
	pruefe(Laden.name("bandage") == "Verband", "Name Verband")

	# Verband: voll -> nichts verbraucht; verletzt -> 5 + 0,2 je Punkt Heilkunde, uebt Heilkunde
	var v := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", BrsHeld.WANDERER, v.neue_uid)
	v.brs = hw.als_daten()
	v.dazu("bandage", 2)
	var t1 := Menue.benutze(v, hw, "bandage", func(a, b): return 1)
	pruefe(t1 == "Du bist unverletzt." and v.anzahl("bandage") == 2, "voll: [807.verband.voll], nichts verbraucht (%s)" % t1)
	var hk := hw.fertigkeit("Heilkunde")
	var soll := roundi(5 + 0.2 * hk)
	hw.leben = 1
	var ueb_vor := float(v.fertigkeiten_stand()["uebung"].get("Heilkunde", 0.0)) + BrsFertigkeit.wert(v.fertigkeiten_stand(), "Heilkunde") * 1000.0
	var t2 := Menue.benutze(v, hw, "bandage", func(a, b): return 1)
	var ueb_nach := float(v.fertigkeiten_stand()["uebung"].get("Heilkunde", 0.0)) + BrsFertigkeit.wert(v.fertigkeiten_stand(), "Heilkunde") * 1000.0
	pruefe(hw.leben == 1 + soll and v.anzahl("bandage") == 1, "verletzt: +%d Leben bei Heilkunde %d, einer weniger (Leben %d)" % [soll, hk, hw.leben])
	pruefe(t2.begins_with("Du ziehst den Verband fest. +%d TP." % soll), "Wortlaut 1 [807.verband.an]: %s" % t2)
	pruefe(ueb_nach > ueb_vor, "Anlegen übt Heilkunde (%.2f -> %.2f)" % [ueb_vor, ueb_nach])
	hw.geuebt["Heilkunde"] = 100
	pruefe(Menue.verband_heilung(hw) == 25, "Großmeister heilt 25 (%d)" % Menue.verband_heilung(hw))
	hw.geuebt.erase("Heilkunde")

	# 1038 A, 1047: Verband stillt Blutung; volles Leben und Blutung -> verbraucht, Blutung weg, ohne „ +0 TP“
	pruefe(String(Laden.ding("bandage").get("info", {}).get("de", "")) == "Saubere Leinenstreifen, fest gerollt. Stillt Blutung; wer Heilkunde versteht, holt mehr heraus. Nur außerhalb des Kampfs.", "Beschreibung [807.verband.text]")
	hw.leben = hw.max_leben()
	v.leiden["BLEED"] = 3
	v.leiden["POISON"] = 2
	var t3 := Menue.benutze(v, hw, "bandage", func(a, b): return 1)
	pruefe(not v.leiden.has("BLEED") and v.leiden.has("POISON") and v.anzahl("bandage") == 0, "Blutung gestillt, Gift bleibt, Verband verbraucht (%s)" % str(v.leiden))
	pruefe(t3.begins_with("Ein fester Knoten, und das Blut steht.") and not t3.contains("TP"), "Wortlaut 1 [807.verband.blut] ohne „ +0 TP“: %s" % t3)
	# verletzt und blutend: Blutung weg, volle Heilung (nicht halbiert), zweiter Wortlaut [807.verband.blut]
	v.dazu("bandage", 1)
	hw.leben = 1
	v.leiden["BLEED"] = 2
	var t4 := Menue.benutze(v, hw, "bandage", func(a, b): return 1)
	var soll4 := roundi(5 + 0.2 * hw.fertigkeit("Heilkunde"))
	pruefe(hw.leben == 1 + soll4 and not v.leiden.has("BLEED"), "blutend: Blutung weg, +%d Leben ungeteilt (Leben %d)" % [soll4, hw.leben])
	pruefe(t4.begins_with("Du presst den Verband auf die Wunde. Sie blutet nicht mehr. +%d TP." % soll4) or t4.begins_with("Lage um Lage, straff gewickelt. Die Blutung hört auf. +%d TP." % soll4), "Wortlaut 2 oder 3 [807.verband.blut]: %s" % t4)
	# ohne Blutung, volles Leben: „Du bist unverletzt.“, bleibt in der Tasche
	v.dazu("bandage", 1)
	hw.leben = hw.max_leben()
	var t5 := Menue.benutze(v, hw, "bandage", func(a, b): return 1)
	pruefe(t5 == "Du bist unverletzt." and v.anzahl("bandage") == 1, "voll ohne Blutung: [807.verband.voll], bleibt (%s)" % t5)

	# Textkasten: der Knopf steht unter der Zeile, erst nach dem Schreiben tippbar, und schliesst die Zeile
	root.size = Vector2i(1080, 2340)   # Handy hochkant wie am Geraet (842: Wahl und Nicht jetzt muessen hineinpassen)
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	var gewaehlt := [0]
	ui.knopf_im_text.connect(func(_nr): gewaehlt[0] += 1)
	ui.sage([{"wer": "Pim", "text": "Papa sagt, Goblins haben Angst vor Feuer! Stimmt das?", "knopf": "Schick Pim heim (Überreden)"}])
	await process_frame
	pruefe(ui.text_knopf.visible and ui.text_knopf.get_child_count() == 1 and not ui.knopf_bereit(), "Knopf da, während des Schreibens nicht tippbar")
	ui.weiter()   # Text ganz
	await process_frame
	pruefe(ui.knopf_bereit() and ui.text_knopf.modulate.a == 1.0, "Knopf steht, wenn die Zeile ganz steht")
	# 842 zurueck (Chef 20:31/20:33): neben der Wahl rechts „Nicht jetzt“ links (Homer [1074.zweit]); Tippen auf den Text schaltet nicht weiter
	var auf := ui.text_knopf.find_children("Text", "Label", true, false).map(func(l): return (l as Label).text)
	auf.sort()
	pruefe(auf == ["NICHT JETZT", "SCHICK PIM HEIM (ÜBERREDEN)"], "Aufschriften in Versalien, Nicht jetzt links, Wahl rechts: %s" % str(auf))
	var aus_ := [0]
	ui.knopf_aus.connect(func(): aus_[0] += 1)
	ui.weiter()
	await process_frame
	pruefe(ui.textfeld.visible and ui.knopf_bereit() and gewaehlt[0] == 0, "Weitertippen bei Wahl und Nicht jetzt: Zeile bleibt")
	var links_ := ui.text_knopf.find_children("*", "PanelContainer", true, false).filter(func(k): return k.has_meta("links") and bool(k.get_meta("links")))
	pruefe(links_.size() == 1 and (links_[0] as Control).find_child("Text", true, false).text == "NICHT JETZT", "Nicht jetzt steht links mit ‹")
	var kasten := ui.textfeld.get_global_rect()
	var sicht := ui.textfeld.get_viewport().get_visible_rect()
	pruefe(sicht.encloses(kasten), "Textkasten mit beiden Knöpfen bleibt im Bild: %s in %s" % [kasten, sicht])
	var gel := [0]
	ui.gelesen.connect(func(): gel[0] += 1)
	ui.schliesse_text()
	pruefe(not ui.textfeld.visible and gel[0] == 1, "nach der Wahl Zeile zu, Szene geht weiter")
	ui.sage([{"text": "Ohne Knopf."}])
	await process_frame
	pruefe(not ui.text_knopf.visible, "Zeile ohne Knopf zeigt keinen")
	ui.queue_free()

	# Osrics Laden: nur Kaufen, keine Ausruestung
	var lz := Zustand.new(); lz.gold = 50
	var lhw := BrsHeld.fuer_spiel("Mira", "Mensch", BrsHeld.WANDERER, lz.neue_uid)
	var la := Laden.new(["bandage"], false)
	la.nur_vorraete = true
	var ls := LadenSchirm.new(lhw, lz, la)
	root.add_child(ls)
	await process_frame
	await process_frame
	pruefe(ls.leiste.get_child_count() == 1, "Osric: ein Reiter (Kaufen), %d" % ls.leiste.get_child_count())
	var alles := ""
	for c in ls.inhalt.find_children("*", "Label", true, false): alles += (c as Label).text + "|"
	pruefe(alles.contains("Verband") and not alles.to_upper().contains("AUSRÜSTUNG"), "nur Verband, keine Ausrüstung: %s" % alles.left(160))
	ls.queue_free()

	# durch das Spiel (spiel.gd): Knopf unter Pims Zeile, Wurf gelingt -> Flaggen, Pims Zeile [807.pim.ja], Ueberreden geuebt
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var sz: Zustand = spiel.zustand
	sz.minuten = 10 * 60
	sz.brs = BrsHeld.fuer_spiel("Mira", "Mensch", BrsHeld.WANDERER, sz.neue_uid).als_daten()
	var vor_u := float(sz.fertigkeiten_stand()["uebung"].get("Überreden", 0.0)) + BrsFertigkeit.wert(sz.fertigkeiten_stand(), "Überreden") * 1000.0
	spiel.spiele(Geschichte.gespraech("pim", sz))
	var n := 0
	while not spiel.ui.knopf_bereit() and spiel.ui.spricht() and n < 6:
		spiel.ui.weiter(); await process_frame
		if not spiel.ui.knopf_bereit(): spiel.ui.weiter(); await process_frame
		n += 1
	pruefe(spiel.ui.knopf_bereit() and not spiel.knopf_offen.is_empty(), "Spiel: Knopf unter Pims letzter Zeile")
	spiel.probe_wurf = func(): return 0.0
	spiel.ui.knopf_im_text.emit(0)
	await process_frame
	pruefe(sz.has("pim_home_%d" % sz.tag) and sz.has(Geschichte.PIM_HEIM), "Spiel: gelungen, Pim geht heute heim")
	pruefe(spiel.ui.spricht() and ["Na gut. Aber nur, weil du es bist.", "Mama schimpft bestimmt …", "Wenn du es sagst, Mira."].has(spiel.ui.text.text), "Spiel: Pims Antwort %s" % spiel.ui.text.text)
	var nach_u := float(sz.fertigkeiten_stand()["uebung"].get("Überreden", 0.0)) + BrsFertigkeit.wert(sz.fertigkeiten_stand(), "Überreden") * 1000.0
	pruefe(nach_u > vor_u, "Spiel: Versuch übt Überreden")
	# „Nicht jetzt“ laesst die Wahl aus (842 zurueck, Homer [1074.zweit]); das Gespraech laeuft weiter wie frueher beim Weitertippen
	spiel.ui.schliesse_text(); await process_frame
	while spiel.ui.spricht(): spiel.ui.weiter(); spiel.ui.weiter(); await process_frame
	sz.tag += 1
	spiel.spiele(Geschichte.gespraech("pim", sz))
	n = 0
	var nicht_jetzt := 0
	while spiel.ui.spricht() and n < 10:
		spiel.ui.weiter(); await process_frame
		if spiel.ui.knopf_bereit():
			spiel.ui.knopf_aus.emit(); nicht_jetzt += 1
		else: spiel.ui.weiter()
		await process_frame
		n += 1
	pruefe(nicht_jetzt == 1 and not spiel.ui.spricht() and not sz.has("pim_home_%d" % sz.tag) and not sz.has("pim_tried_%d" % sz.tag), "Spiel: Nicht jetzt, keine Probe (%d)" % nicht_jetzt)
	# 1086 (Homer 1085): mit 5 Gold eine zweite Wahl „Gib Pim 5 Gold“ unter Ueberreden; gelingt immer, kostet 5 Gold, uebt nichts
	for gold in [12, 3]:
		sz.tag += 1
		sz.gold = gold
		spiel.spiele(Geschichte.gespraech("pim", sz))
		n = 0
		while not spiel.ui.knopf_bereit() and spiel.ui.spricht() and n < 6:
			spiel.ui.weiter(); await process_frame
			if not spiel.ui.knopf_bereit(): spiel.ui.weiter(); await process_frame
			n += 1
		var aufs: Array = spiel.ui.text_knopf.find_children("Text", "Label", true, false).map(func(l): return (l as Label).text)
		if gold < Geschichte.PIM_GOLD_PREIS:
			pruefe(spiel.knopf_offen.size() == 1 and not aufs.has("GIB PIM 5 GOLD"), "Gold %d: ohne Gold-Knopf %s" % [gold, str(aufs)])
			spiel.ui.knopf_aus.emit(); await process_frame
			while spiel.ui.spricht(): spiel.ui.weiter(); spiel.ui.weiter(); await process_frame
			continue
		pruefe(spiel.knopf_offen.size() == 2 and aufs == ["SCHICK PIM HEIM (ÜBERREDEN)", "GIB PIM 5 GOLD", "NICHT JETZT"], "Gold %d: Überreden, Gold, Nicht jetzt %s" % [gold, str(aufs)])
		var u0 := float(sz.fertigkeiten_stand()["uebung"].get("Überreden", 0.0)) + BrsFertigkeit.wert(sz.fertigkeiten_stand(), "Überreden") * 1000.0
		spiel.ui.knopf_im_text.emit(1)
		await process_frame
		var u1 := float(sz.fertigkeiten_stand()["uebung"].get("Überreden", 0.0)) + BrsFertigkeit.wert(sz.fertigkeiten_stand(), "Überreden") * 1000.0
		pruefe(sz.gold == gold - 5 and sz.has("pim_home_%d" % sz.tag) and sz.has(Geschichte.PIM_GOLD_HEIM) and u1 == u0, "Gold: 5 weg (%d), Pim heim, keine Übung" % sz.gold)
		pruefe(["Echtes Gold? Für mich?", "Dafür geh ich heim. Aber morgen komm ich wieder!", "Davon spar ich auf eine Brandflasche!"].has(spiel.ui.text.text), "Gold: Pims Zeile %s" % spiel.ui.text.text)
		while spiel.ui.spricht(): spiel.ui.weiter(); spiel.ui.weiter(); await process_frame
	sz.setze(Geschichte.PIM_DANK)
	pruefe(Geschichte.pim_gold_dankt(sz), "Mutter dankt nach Gold einmal ([1085.pim.dank])")
	sz.setze(Geschichte.PIM_GOLD_DANK)
	pruefe(not Geschichte.pim_gold_dankt(sz), "Mutter dankt nur einmal für Gold")
	spiel.queue_free()
	await process_frame

	print("PIM842 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
