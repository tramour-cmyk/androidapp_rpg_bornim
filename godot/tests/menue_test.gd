extends SceneTree
# 399.1 ohne Bild: Leiste (TP, ZP, EP, Tag und Uhr, Zustaende, freie Punkte) und Menue (Held, Tasche, Punkte verteilen) wie im
# alten Spiel. Aufruf: im Ordner godot mit -s res://tests/menue_test.gd

func _initialize() -> void: _lauf.call_deferred()

func texte(n: Node) -> String:
	return " | ".join(PackedStringArray(n.find_children("*", "Label", true, false).map(func(l): return l.text)))

func _lauf() -> void:
	var fehler := 0
	Sprache.lade()
	var z := Zustand.new()
	z.gold = 37; z.dazu("potion", 2); z.tag = 3; z.minuten = 21 * 60 + 5
	z.leiden["POISON"] = 2
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	hw.ep_dazu(int(Heldwerte.regel("ep_fuer_stufe")[4]))   # Stufe 4: zwei freie Attributspunkte
	hw.tp = 5
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(42), z.neue_uid, 3, "RARE", "WIZARD"))
	var l := Leiste.new()
	root.add_child(l)
	l.zeige(hw, z, true)
	await process_frame
	var t := texte(l)
	print("Leiste: ", t)
	for soll in ["5/%d" % hw.max_tp(), "Tag 3 · 21:05" if Sprache.aktiv() == "de" else "Day 3 · 21:05", "★ +%d" % hw.offen]:
		if not t.contains(soll): fehler += 1; print("FEHLER Leiste ohne ", soll)
	if l.zeichen.art != "mond": fehler += 1; print("FEHLER Leiste: nachts kein Mond")
	if hw.offen <= 0: fehler += 1; print("FEHLER keine freien Punkte bei Stufe %d" % hw.stufe)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	t = texte(m)
	for soll in ["MIRA", ": 37", "%d / %d" % [5, hw.max_tp()]]:
		if not t.contains(soll): fehler += 1; print("FEHLER Held ohne ", soll)
	# Punkte verteilen: + bei Intelligenz, Uebernehmen, Ja
	var int_vor := hw.wert("INT")
	var plus: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text == "+")
	plus[3].pressed.emit()   # STR, DEX, CON, INT
	await process_frame; await process_frame
	var ueb: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text in ["ÜBERNEHMEN", "APPLY"])
	if ueb.is_empty(): fehler += 1; print("FEHLER kein Übernehmen")
	else:
		ueb[0].pressed.emit()
		await process_frame
		var ja: Array = m.find_children("*", "Button", true, false).filter(func(b): return b.text in ["JA, VERTEILEN", "YES, SPEND"])
		ja[0].pressed.emit()
		await process_frame; await process_frame
		if hw.wert("INT") != int_vor + 1: fehler += 1; print("FEHLER INT %d -> %d" % [int_vor, hw.wert("INT")])
	# Tasche
	var reiter: Array = m.leiste.find_children("*", "Button", true, false)
	reiter[1].pressed.emit()
	await process_frame; await process_frame
	t = texte(m)
	print("Tasche: ", t.substr(0, 300))
	for soll in [Laden.name("potion"), "×2", "37", Beute.name(z.beutel[0])]:
		if not t.contains(soll): fehler += 1; print("FEHLER Tasche ohne ", soll)
	# 399.1 Benutzen (Game.useItemOutside): Heiltrank mit festen Wuerfeln, Kraeutertrank heilt das Gift, voll heisst voll
	var vier := func(n: int, w: int) -> int: return n * 3
	var tp_vor := hw.tp
	var s1 := Menue.benutze(z, hw, "potion", vier)
	if hw.tp != mini(hw.max_tp(), tp_vor + 8) or z.anzahl("potion") != 1 or not s1.contains(str(hw.tp - tp_vor)): fehler += 1; print("FEHLER Heiltrank: ", s1, " TP ", hw.tp)
	z.dazu("remedy")
	var s2 := Menue.benutze(z, hw, "remedy", vier)
	if not z.leiden.is_empty() or z.anzahl("remedy") != 0: fehler += 1; print("FEHLER Kräutertrank: ", s2)
	hw.tp = hw.max_tp()
	var s3 := Menue.benutze(z, hw, "potion", vier)
	if z.anzahl("potion") != 1 or s3 != Sprache.u("alreadyFull"): fehler += 1; print("FEHLER voll: ", s3)
	z.dazu("spark_potion")
	Menue.benutze(z, hw, "spark_potion", vier)
	if not z.funke or z.anzahl("spark_potion") != 0: fehler += 1; print("FEHLER Leuchtfunke")
	print("Benutzen: ", s1, " | ", s2, " | ", s3)
	# Tasche: Antippen des Heiltranks zeigt den Kasten mit Benutzen
	var zeilen_: Array = m.inhalt.get_children().filter(func(c): return c is HBoxContainer and texte(c).contains(Laden.name("potion")))
	if zeilen_.is_empty(): fehler += 1; print("FEHLER Heiltrank-Zeile fehlt")
	else:
		var los := InputEventMouseButton.new(); los.button_index = MOUSE_BUTTON_LEFT; los.pressed = true
		zeilen_[0].gui_input.emit(los)
		var hoch := InputEventMouseButton.new(); hoch.button_index = MOUSE_BUTTON_LEFT; hoch.pressed = false
		zeilen_[0].gui_input.emit(hoch)
		await process_frame
		var knoepfe: Array = m.find_children("*", "Button", true, false).map(func(b): return b.text)
		if Sprache.u("use").to_upper() not in knoepfe: fehler += 1; print("FEHLER kein Benutzen-Knopf: ", knoepfe)
		for c in m.get_children(): if c is ColorRect and c.color.a < 0.9: c.queue_free()
		await process_frame
	# Ausruestung: anlegen aus der Tasche, Platz zeigt es, ablegen bringt es zurueck
	var g: Dictionary = z.beutel[0]
	var platz := String(Beute.grundform(String(g["base"]))["slot"])
	var meld := m.lege_an(g)
	if hw.ding(platz) == null or int(hw.ding(platz)["uid"]) != int(g["uid"]) or m.im_beutel(g) >= 0: fehler += 1; print("FEHLER anlegen: ", meld)
	m.reiter = "ausruestung"; m.baue()
	await process_frame; await process_frame
	t = texte(m)
	print("Ausrüstung: ", t.substr(0, 400))
	for soll in [Beute.name(g), m.platzname("HEAD"), m.platzname("OFF_HAND"), Sprache.u("attack")]:
		if not t.contains(soll): fehler += 1; print("FEHLER Ausrüstung ohne ", soll)
	m.lege_ab(platz)
	if hw.ding(platz) != null or m.im_beutel(g) < 0: fehler += 1; print("FEHLER ablegen")
	if m.passend(platz).is_empty(): fehler += 1; print("FEHLER passend leer fuer ", platz)
	# System (425): Zeichen wie alt (SystemSigns): Speichern meldet sich, die Zeichen senden; Gedrueckthalten erklaert
	var gesendet := []
	m.speichern.connect(func(): gesendet.append("speichern"))
	m.hauptmenue.connect(func(): gesendet.append("hauptmenue"))
	Bedienung.lade(); Bedienung.zeichen_gesehen = false
	m.reiter = "system"; m.baue()
	await process_frame; await process_frame
	if not m.meldung_.visible or m.meldung_.text != Sprache.t(Menue.HINWEIS): fehler += 1; print("FEHLER kein Hinweis Gedrückthalten")
	var zk: Array = m.inhalt.find_children("*", "Zeichenknopf", true, false)
	var namen: Array = zk.map(func(b): return b.wort)
	print("System: ", namen)
	var de_ := Sprache.aktiv() == "de"
	var soll_ := (["Speichern", "Sprache", "Hauptmenü", "Anleitung", "Über", "Blut", "Tempo", "Kampftext", "Rückfragen", "Steuerung"] if de_ else
		["Save", "Language", "Main menu", "Guide", "About", "Blood", "Pace", "Battle text", "Confirmations", "Controls"])
	if namen.slice(0, soll_.size()) != soll_: fehler += 1; print("FEHLER System Zeichen ", namen)
	var bedienung := (2 if Bedienung.klassisch else 4) + 2   # Steuerung, (Joystick, Rennen,) Aktion; Karte, Rütteln
	if zk.size() != 5 + 4 + bedienung + (1 if root.has_node("Klang") else 0): fehler += 1; print("FEHLER System: %d Zeichen" % zk.size())
	# keine Saetze mehr im Menue: nur Name und Wert unter den Zeichen (426 „Zeichen statt Textwände“)
	for b in zk:
		if texte(b).length() > 30: fehler += 1; print("FEHLER Zeichen mit Text: ", texte(b))
	var lang_ := zk.filter(func(b): return b.wort == ("Blut" if de_ else "Blood"))[0] as Zeichenknopf
	lang_.lang.call(lang_.wort, lang_.erklaerung)
	await process_frame
	if not is_instance_valid(m.erklaer_fenster) or not texte(m.erklaer_fenster).contains(lang_.erklaerung) or Zeichenknopf.offen != lang_.wort:
		fehler += 1; print("FEHLER Gedrückthalten erklärt nicht")
	m.schliesse_erklaerung()
	await process_frame
	if Zeichenknopf.offen != "": fehler += 1; print("FEHLER Erklärung bleibt offen")
	# 352 Anleitung: Absaetze der eigenen Klasse, fette Eroeffnung als Ueberschrift, keine Sternchen
	var teile := Menue.anleitung_teile("WIZARD")
	var alle: Array = Sprache.texte["anleitung"]["teile"]
	if teile.size() != alle.filter(func(p): return not p.has("nur") or p["nur"] == "WIZARD").size() or teile.size() < 10: fehler += 1; print("FEHLER Anleitung %d Absätze" % teile.size())
	var ueber_ := [0]
	m.ueber.connect(func(): ueber_[0] += 1)
	for b in zk:
		if b.wort in ["Über", "About", "Anleitung", "Guide"]: b.tat.call()
	await process_frame
	if ueber_[0] != 1: fehler += 1; print("FEHLER Über sendet nicht")
	var rts: Array = m.find_children("*", "RichTextLabel", true, false)
	if rts.size() != teile.size() or rts.any(func(r): return r.get_parsed_text().contains("**")): fehler += 1; print("FEHLER Anleitung zeigt %d Absätze" % rts.size())
	else: print("Anleitung: ", rts[1].get_parsed_text().substr(0, 80))
	for c in m.get_children():
		if c.find_children("*", "RichTextLabel", true, false).size() > 0: c.free()
	if not Menue.geraeteangaben().contains("Version:"): fehler += 1; print("FEHLER Geräteangaben")
	else:
		m.reiter = "system"; m.baue()
		await process_frame
		zk = m.inhalt.find_children("*", "Zeichenknopf", true, false)
		zk[0].tat.call(); zk[2].tat.call()
		if gesendet != ["speichern", "hauptmenue"] or not m.meldung_.visible: fehler += 1; print("FEHLER System sendet ", gesendet)
	if m.leiste.get_child_count() != 6: fehler += 1; print("FEHLER %d Reiter" % m.leiste.get_child_count())
	# 399.3.1 Lautstaerke: drei Regler, Antippen in der Mitte stellt Musik auf 50 % (Klang.stelle)
	var kl: Node = root.get_node_or_null("Klang")   # der Autoload, gibt es ihn mit -s nicht, ein eigener
	var eigener := kl == null
	if eigener:
		kl = load("res://klang/klang.gd").new()
		kl.name = "Klang"
		root.add_child(kl)
	m.reiter = "system"; m.baue()
	await process_frame; await process_frame
	var regler: Array = m.inhalt.find_children("*", "", true, false).filter(func(n): return n is Menue.Regler)
	if regler.size() != 4: fehler += 1; print("FEHLER %d Regler" % regler.size())   # Gesamt, Musik, Effekte, Dunkle Töne
	else:
		var tipp := InputEventScreenTouch.new()
		tipp.position = Vector2(regler[1].linie.size.x * 0.5, 10); tipp.pressed = true
		regler[1]._eingabe(tipp)
		if int(kl.lautstaerke["music"]) != 50 or regler[1].zahl.text != "50 %": fehler += 1; print("FEHLER Musik ", kl.lautstaerke["music"], " ", regler[1].zahl.text)
		kl.stelle("music", 100)
		var hell := Helligkeit.lade()
		var t2 := InputEventScreenTouch.new()
		t2.position = Vector2(regler[3].linie.size.x * 0.5, 10); t2.pressed = true
		regler[3]._eingabe(t2)
		if Helligkeit.lade() != 50 or not is_equal_approx(Helligkeit.hebung(50), 0.05): fehler += 1; print("FEHLER Helligkeit ", Helligkeit.lade())
		Helligkeit.setze(hell)
		var schritte: Array = m.inhalt.find_children("*", "Zeichenknopf", true, false).filter(func(b): return b.wort in ["Schritte", "Steps"])
		if schritte.is_empty(): fehler += 1; print("FEHLER kein Schalter Schritte")
		else:
			schritte[0].tat.call()
			if kl.schritte_an: fehler += 1; print("FEHLER Schritte bleiben an")
			kl.schritte_an = true; kl.stelle("all", 100)
	if eigener: kl.queue_free()
	await process_frame
	# Chronik: Hauptauftrag, Auftrag der Geschichte, Bisher geschehen (das Neueste oben), Stern bis zum Lesen
	z.setze(Geschichte.QUEST_STARTED); z.setze(Geschichte.KROGG_HINT)
	m.reiter = "held"; m.baue()
	await process_frame
	if not Chronik.frisch(z): fehler += 1; print("FEHLER Chronik nicht frisch")
	m.reiter = "chronik"; m.baue()
	await process_frame; await process_frame
	t = texte(m)
	print("Chronik: ", t.substr(0, 300))
	for soll in [Sprache.t(Geschichte.ziel(z)), Sprache.t(Chronik.auftraege()[0]["titel"])]:
		if not t.contains(soll): fehler += 1; print("FEHLER Chronik ohne ", soll)
	if Chronik.frisch(z): fehler += 1; print("FEHLER Chronik nach dem Lesen noch frisch")
	m.bisher = true; m.baue()
	await process_frame; await process_frame
	t = texte(m)
	var e: Array = Chronik.eintraege()
	if not t.contains(Sprache.t(e[1]["titel"])) or t.find(Sprache.t(e[1]["titel"])) > t.find(Sprache.t(e[0]["titel"])) or t.contains("{name}"):
		fehler += 1; print("FEHLER Bisher: ", t.substr(0, 300))
	# 399.1 Karte (MapTab): das Dorf mit dem Helden, Schalter, Zeichen nach dem, was er kennt; Haus oeffnet den Grundriss, der
	# Knopf oben geht zur Gebietskarte, dann zur Landkarte
	if Kartenreiter.blatt().is_empty(): fehler += 1; print("FEHLER kartenblatt.json fehlt (exportMapSheets)")
	else:
		z.setze("met_rowena"); z.setze("besucht:inn")
		m.ort = {"karte": "village", "x": 15, "y": 12, "blick": "UP"}
		m.reiter = "karte"; m.baue()
		await process_frame; await process_frame
		var kr: Kartenreiter = m.inhalt.get_child(0)
		t = texte(m)
		print("Karte: ", t.substr(0, 200))
		if not t.contains("Bornim"): fehler += 1; print("FEHLER Karte ohne Bornim")
		var bl: Kartenreiter.Kartenblatt = kr.flaeche
		if bl.tex == null or not bl.hier: fehler += 1; print("FEHLER Dorfblatt fehlt oder ohne Held")
		var arten := bl.marken.map(func(x): return x["art"])
		for soll in ["GIVER", "PERSON", "INN", "SHOP", "TEMPLE"]:
			if not soll in arten: fehler += 1; print("FEHLER Karte ohne Zeichen ", soll, " ", arten)
		if bl.haus.size() < 1: fehler += 1; print("FEHLER kein bekanntes Haus")
		var schenke: Dictionary = bl.haus.filter(func(h): return h["innen"] == "inn")[0]
		bl.tippe(bl.an(int(schenke["x"]), int(schenke["y"]) - 2))
		await process_frame; await process_frame
		kr = m.inhalt.get_child(0)
		if kr.gezeigt != "inn" or not (kr.flaeche is Kartenreiter.Kartenblatt) or (kr.flaeche as Kartenreiter.Kartenblatt).tex == null: fehler += 1; print("FEHLER Grundriss Schenke: ", kr.gezeigt)
		var hoch: Array = kr.find_children("*", "Button", true, false).filter(func(b): return b.text.contains("↑"))
		hoch[0].pressed.emit()
		await process_frame
		if kr.gezeigt != "village": fehler += 1; print("FEHLER nicht zurueck im Dorf")
		hoch = kr.find_children("*", "Button", true, false).filter(func(b): return b.text.contains("↑"))
		hoch[0].pressed.emit()
		await process_frame; await process_frame
		if not kr.uebersicht or (kr.flaeche as Kartenreiter.Landblatt).tex == null: fehler += 1; print("FEHLER Landkarte")
		if (kr.flaeche as Kartenreiter.Landblatt).hier() != "village": fehler += 1; print("FEHLER Landkarte: Held nicht im Dorf")
		var lb: Kartenreiter.Landblatt = kr.flaeche
		var dorf: Dictionary = lb.land["orte"][0]
		lb.tippe(lb.an(float(dorf["x"]), float(dorf["y"])))
		await process_frame; await process_frame
		if kr.uebersicht or kr.gezeigt != "village": fehler += 1; print("FEHLER Landkarte oeffnet das Dorf nicht")
	# 399.1 Vergleich (GearCompare): ein besseres Schwert zeigt ▲, der Held bleibt, wie er ist
	var hw2 := Heldwerte.erschaffe("Vera", "HUMAN", "FIGHTER", {}, z.neue_uid)
	var rk_vor := hw2.rk()
	var stueck: Dictionary = Beute.erzeuge_mit_uid(KotlinZufall.new(7), z.neue_uid, 5, "EPIC", "FIGHTER")
	var vg := Vergleich.von(hw2, stueck)
	print("Vergleich: ", vg.satz(), " ", vg.zeilen.map(func(r): return "%s %s→%s" % [r["wort"], r["vorher"], r["nachher"]]))
	if vg.zeilen.is_empty() or vg.urteil() == null: fehler += 1; print("FEHLER Vergleich leer bei ", Beute.name(stueck))
	if hw2.rk() != rk_vor or hw2.ausruestung.values().has(stueck): fehler += 1; print("FEHLER Vergleich aendert den Helden")
	# 399.1 Antippen eines Attributs (Perks.describe): bei der Magierin INT mit der Zeile der Klasse
	var erk := Menue.erklaerung(hw, "INT")
	print("Erklärung INT: ", erk)
	if erk.size() < 4 or not (erk[1].contains("Magier") or erk[1].contains("Wizard")): fehler += 1; print("FEHLER Erklärung INT")
	# 399.1 (Test 139: Anleitung rollt nicht): in der Anleitung haelt kein Text das Wischen fest, nur Knoepfe nehmen es (wie im System)
	m.anleitung()
	await process_frame
	var seite: Node = m.get_child(m.get_child_count() - 1)
	var rollen := seite.find_children("*", "ScrollContainer", true, false)
	if rollen.is_empty(): fehler += 1; print("FEHLER Anleitung ohne Rolle")
	for r in rollen:
		var haelt := r.find_children("*", "Control", true, false).filter(func(c): return c.is_visible_in_tree() and c.mouse_filter == Control.MOUSE_FILTER_STOP and not c is BaseButton)
		print("Anleitung: %d Teile, %d halten das Wischen" % [r.find_children("*", "Control", true, false).size(), haelt.size()])
		if not haelt.is_empty(): fehler += 1; print("FEHLER Anleitung rollt nicht: ", haelt.map(func(c): return c.get_class()))
	seite.queue_free()
	# Satt wird gespeichert
	z.satt = true
	if not Zustand.aus_daten(z.als_daten()).satt: fehler += 1; print("FEHLER satt nicht gespeichert")
	print("MENUE %d Fehler" % fehler)
	quit(1 if fehler else 0)
