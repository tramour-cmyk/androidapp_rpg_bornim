extends RefCounted
# 512b (Chef 04.11.: „512b ja“): alle Menueschirme der neuen Fassung samt dem, was sie oeffnen (Fenster, Rueckfragen, Wechsellisten),
# Zustand fuer Zustand, mit denselben Namen wie die alte Fassung (tools/preview MENUE512B=1, Menue512b.kt), fuer die Vergleichsblaetter
# (tools/menues_512b_blatt.py). Beispielheld beider Seiten: Thora, Mensch Kaempfer, Stufe 3, Tag 3, 137 Gold, gemischte Tasche,
# Hauptauftrag begonnen, ein Aushang angenommen, einer erledigt.
# Baut die Zustaende nacheinander und ruft je Zustand host.knips(name) (ein Bild: menues_512b.gd; ohne Bild: menues_512b_test.gd)
# und host.fehlt(name, grund), wo es den Schirm neu nicht gibt. Getippt wird wie im Spiel: Knoepfe ueber ihre Aufschrift (pressed),
# Zeilen ueber gui_input (Menue.tippbar); wo kein Knopf hinfuehrt, ruft es die Funktion, die der Knopf ruft.

var tree: SceneTree
var host
var buehne: CanvasLayer
var ui: Steuerung
var gesichert := []                    # die Spielstaende des Rechners vorher, am Ende zurueck
var dateien_vorher := []

func _init(t: SceneTree, h) -> void:
	tree = t; host = h

func root() -> Window: return tree.root

func frames(n: int) -> void:
	for i in n: await tree.process_frame

# ---------------------------------------------------------------- Werkzeuge

# alle sichtbaren Knoepfe unter n, deren Aufschrift (ohne Gross/klein, ß wie SS) mit t beginnt; der letzte liegt oben
func knoepfe(n: Node, t: String) -> Array:
	var u := t.to_upper().replace("ß", "SS")
	var aus := []
	for b in n.find_children("*", "Button", true, false):
		if (b as Button).is_visible_in_tree() and not (b as Button).disabled and (b as Button).text.to_upper().replace("ß", "SS").begins_with(u): aus.append(b)
	return aus

# das oberste Fenster (Schleier) unter n, sonst n
func oben(n: Node) -> Node:
	var s: Node = null
	for c in n.find_children("*", "ColorRect", true, false):
		if (c as ColorRect).is_visible_in_tree() and absf((c as ColorRect).color.a - 0.82) < 0.01 and not c.is_queued_for_deletion(): s = c
	return s if s else n

func druecke(n: Node, t: String) -> bool:
	var k := knoepfe(oben(n), t)
	if k.is_empty():
		# 584: seit 630 (549a) sind Knoepfe und Wahlfelder tippbare Zeilen (Spielstaende.knopf, Erschaffung.wahlfeld) statt Button:
		# die letzte sichtbare Aufschrift, die (ohne ‹ › ×, gross, ß wie SS) mit t beginnt, antippen wie tippe_text
		var u := t.to_upper().replace("ß", "SS")
		var ziel: Control = null
		for l in oben(n).find_children("*", "Label", true, false):
			var x := (l as Label).text.to_upper().replace("ß", "SS").replace("‹", "").replace("›", "").replace("×", "").strip_edges()
			if (l as Label).is_visible_in_tree() and x.begins_with(u): ziel = l
		var c: Control = ziel
		while c and c.get_signal_connection_list("gui_input").is_empty(): c = c.get_parent() as Control
		if c == null:
			push_error("512b: Knopf „%s“ fehlt" % t)
			return false
		for p in [true, false]:
			var e := InputEventMouseButton.new()
			e.button_index = MOUSE_BUTTON_LEFT; e.pressed = p; e.position = Vector2(10, 10)
			c.gui_input.emit(e)
		await frames(3)
		return true
	(k[-1] as Button).pressed.emit()
	await frames(3)
	return true

# eine Zeile antippen wie Menue.tippbar: das erste Elternteil mit gui_input bekommt Druecken und Loslassen an derselben Stelle;
# art "=" ganzer Text, "<" Anfang, "~" enthalten (vor Namen im Laden steht ▲ oder ▼)
func tippe_text(n: Node, t: String, art := "<") -> bool:
	var ziel: Control = null
	for l in oben(n).find_children("*", "Label", true, false):
		var x := (l as Label).text
		var passt := x == t if art == "=" else (x.contains(t) if art == "~" else x.begins_with(t))
		if (l as Label).is_visible_in_tree() and passt: ziel = l; break
	if ziel == null:
		push_error("512b: Zeile „%s“ fehlt" % t)
		return false
	var c: Control = ziel
	while c and c.get_signal_connection_list("gui_input").is_empty(): c = c.get_parent() as Control
	if c == null:
		push_error("512b: Zeile „%s“ nicht antippbar" % t)
		return false
	for p in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = p; e.position = Vector2(10, 10)
		c.gui_input.emit(e)
	await frames(3)
	return true

func schliesse_fenster(n: Node) -> void:
	var weg := false
	for c in n.find_children("*", "ColorRect", true, false):
		if absf((c as ColorRect).color.a - 0.82) < 0.01: c.queue_free(); weg = true
	# 584: die Fenster und Schirme nach 549a sind ganz deckend (kein Schleier 0,82); sie schliesst ihr „Zurück“ (Zurueck.melde),
	# nicht aber das Menue selbst (sonst blieb ab 41 das Fenster „Amulett“ in jedem weiteren Bild stehen)
	if not weg:
		var oben: Node = null
		for k in n.get_tree().get_nodes_in_group(Zurueck.GRUPPE):
			if k.is_queued_for_deletion() or not k.is_inside_tree(): continue
			if k is CanvasItem and not (k as CanvasItem).is_visible_in_tree(): continue
			if oben == null or oben.is_ancestor_of(k) or Zurueck._spaeter(k, oben): oben = k
		if oben != null and oben != n and not oben.is_ancestor_of(n) and n.is_ancestor_of(oben):
			(oben.get_meta("zurueck") as Callable).call()
	await frames(2)

func rolle_von(n: Node) -> ScrollContainer:
	var r := n.find_children("*", "ScrollContainer", true, false)
	var best: ScrollContainer = null
	for s in r:
		if (s as ScrollContainer).is_visible_in_tree() and (best == null or s.size.y > best.size.y): best = s
	return best

func ganz_unten(r: ScrollContainer) -> void:
	await frames(3)
	r.scroll_vertical = int(r.get_v_scroll_bar().max_value)
	await frames(2)

# rollt so, dass das Label mit Text t oben im Kasten steht
func rolle_zu(r: ScrollContainer, t: String) -> void:
	await frames(3)
	for l in r.find_children("*", "", true, false):
		if not (l is Label or l is Button) or not (l as Control).is_visible_in_tree(): continue
		var x: String = l.text.to_upper().replace("ß", "SS")
		if x.begins_with(t.to_upper().replace("ß", "SS")):
			r.scroll_vertical = int(r.scroll_vertical + (l as Control).global_position.y - r.global_position.y - 8)
			break
	await frames(2)

func leeren() -> void:
	for c in buehne.get_children(): c.queue_free()
	if ui.waehlt(): ui.schliesse_wahl()
	await frames(3)

func stueck(z: Zustand, base: String, rar: String, rolls: Array) -> Dictionary:
	return z.ausruestung_dazu({"uid": 0, "base": base, "rarity": rar, "ilvl": 3, "plus": 0, "rolls": rolls, "unique": null, "name_seed": 0})

# Thora wie Menue512b.kt held512
func held(name_ := "Thora", volk := "Mensch", klasse := "Wachsoldat") -> Array:
	var z := Zustand.new()
	z.name = name_
	var hw := BrsHeld.fuer_spiel(name_, volk, klasse, z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 3)
	z.setze(Geschichte.INTRO_DONE)
	z.taschen.clear()
	for p in [["potion", 3], ["greater_potion", 1], ["herbs", 2], ["wolf_pelt", 2]]: z.dazu(p[0], p[1])
	z.beutel.clear()
	stueck(z, "hood", "COMMON", [])
	stueck(z, "greatsword", "UNCOMMON", [["STR", 1]])
	stueck(z, "ring", "RARE", [["DEX", 1], ["CON", 1]])
	z.gold = 137; z.tag = 3; z.minuten = 14 * 60 + 20
	for f in [Geschichte.QUEST_STARTED, Geschichte.BARRIER_OPEN, Geschichte.KROGG_HINT, "job_tusks", "job_tusks_done"]: z.setze(f)
	Auftraege.nimm(z, Auftraege.von("pelts"))
	hw.voll(); hw.mana = hw.max_mana()
	return [hw, z]

func im_beutel(z: Zustand, base: String) -> Dictionary:
	for g in z.beutel:
		if String(g["base"]) == base: return g
	return {}

func speichere(n: int, hw: BrsHeld, z: Zustand, karte := "inn") -> void:
	Spielstand.platz = n
	Spielstand.speichere(z, hw, {"karte": karte, "x": 4, "y": 6, "blick": "UP"})

func alle_plaetze_leer() -> void:
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)

func vier_plaetze() -> void:
	var t := held()
	speichere(1, t[0], t[1])
	var i := 2
	for h in [["Mira", "Elf", "Zauberlehrling"], ["Borin", "Zwerg", "Klosterschüler"], ["Ilse", "Hügelvolk", "Herumtreiber"]]:
		var z := Zustand.new(); z.name = h[0]
		var hw := BrsHeld.fuer_spiel(h[0], h[1], h[2], z.neue_uid)
		speichere(i, hw, z)
		i += 1
	Spielstand.platz = 1

# ---------------------------------------------------------------- Ablauf

func lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	Bedienung.lade()
	Testmodus.geladen = true; Testmodus.an = false   # nichts nach user://test.cfg
	Hauptmenue.vorspann_gezeigt = true
	var d := DirAccess.open("user://")
	if d: dateien_vorher = Array(d.get_files())
	for n in range(1, Spielstand.PLAETZE + 1):
		gesichert.append(FileAccess.get_file_as_string(Spielstand.datei(n)) if FileAccess.file_exists(Spielstand.datei(n)) else "")
	if root().get_node_or_null("Klang") == null:   # mit -s gibt es den Autoload nicht; ohne ihn fehlen Regler, „Schritte“ und die Klangzeichen
		var kl = load("res://klang/klang.gd").new()
		kl.name = "Klang"
		root().add_child(kl)
	var grund := ColorRect.new()   # graugruen wie die leere Welt hinter Rast und Textkasten (oberflaeche_bild.gd)
	grund.color = Color(0.45, 0.5, 0.42)
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root().add_child(grund)
	ui = Steuerung.new()
	root().add_child(ui)
	buehne = CanvasLayer.new()
	buehne.layer = 50
	root().add_child(buehne)
	await frames(3)
	await hauptmenue()
	await spielstaende()
	await erschaffung()
	await spielermenue()
	await laden()
	await rast()
	await brett()
	await text()
	host.fehlt("76_kapitelende", "neu kein Schirm: Befehl „kapitelende“ endet in spiel.gd _ (szene.clear()), Geschichte.CHAPTER_END_TEXT ungenutzt")
	await leeren()
	# aufraeumen: Spielstaende wie vorher, neue Dateien (Bedienung, Klang) weg
	alle_plaetze_leer()
	for n in range(1, Spielstand.PLAETZE + 1):
		if gesichert[n - 1] != "":
			var f := FileAccess.open(Spielstand.datei(n), FileAccess.WRITE); f.store_string(gesichert[n - 1]); f.close()
	var d2 := DirAccess.open("user://")
	if d2:
		for f in d2.get_files():
			if not dateien_vorher.has(f) and f.ends_with(".cfg"): d2.remove(f)

func hauptmenue() -> void:
	alle_plaetze_leer()
	var m := Hauptmenue.new(ui)
	buehne.add_child(m)
	await frames(3)
	await host.knips("01_hauptmenue_leer")
	m.queue_free(); await frames(2)
	var t := held()
	speichere(1, t[0], t[1])
	m = Hauptmenue.new(ui)
	buehne.add_child(m)
	await frames(3)
	await host.knips("02_hauptmenue_stand")
	Testmodus.an = true
	m.titel()
	await frames(3)
	await host.knips("03_hauptmenue_testmodus")
	Testmodus.an = false
	m.titel()
	m.ueber()
	await frames(3)
	await host.knips("04_ueber_oben")
	var seite: Node = m.get_child(m.get_child_count() - 1)
	await ganz_unten(rolle_von(seite))
	await host.knips("05_ueber_unten")
	await druecke(seite, "Lizenzen")
	await frames(3)
	var r := rolle_von(seite)
	await rolle_zu(r, "Lizenzen")
	await host.knips("06_ueber_lizenzen")
	await ganz_unten(r)
	await host.knips("06b_ueber_lizenzen_ende")
	await leeren()

func spielstaende() -> void:
	alle_plaetze_leer()
	var t := held()
	speichere(1, t[0], t[1])
	var m := Hauptmenue.new(ui)
	buehne.add_child(m)
	await frames(2)
	m.spielstaende()
	await frames(3)
	await host.knips("07_spielstaende_eins")
	var s: Node = m.get_node("Spielstaende")
	await druecke(s, "Löschen")
	await host.knips("09_spielstaende_loeschen")
	await leeren()
	vier_plaetze()
	m = Hauptmenue.new(ui)
	buehne.add_child(m)
	await frames(2)
	m.spielstaende()
	await frames(3)
	await host.knips("08_spielstaende_voll")
	await leeren()

func erschaffung() -> void:
	alle_plaetze_leer()
	var d := BrsHeld.daten()
	var m := Hauptmenue.new(ui)
	buehne.add_child(m)
	await frames(2)
	await druecke(m, Sprache.u("newGame"))
	await frames(3)
	var e: ErschaffungBrs = m.get_node("Erschaffung")   # 470: Seite „Neues Spiel“ nach BRS
	await host.knips("10_erschaffung_oben")
	var i := 1
	for v in [["Elf", "Elf"], ["Zwerg", "Zwerg"], ["Hügelvolk", "Hügelvolk"], ["Orkblütiger", "Orkblütiger"]]:
		await druecke(e, ErschaffungBrs.tx(ErschaffungBrs.VOLK[v[0]]))
		await frames(3)
		e.rolle.scroll_vertical = 0
		await frames(2)
		await host.knips("1%d_erschaffung_volk_%s" % [i, String(v[1]).to_lower()])
		i += 1
	await druecke(e, ErschaffungBrs.tx(ErschaffungBrs.VOLK["Mensch"]))
	# Aussehen: Weiblich, Kraeftig (am Rechner ohne 3D-Daten zeigt die Seite den Teil nicht: HeldFigur.da)
	e.geschlecht_waehlen("w")
	e.aussehen["statur"] = "kraeftig"
	e.baue()
	await frames(3)
	await rolle_zu(e.rolle, "Aussehen" if HeldFigur.da(e.b.herkunft, "w") else ErschaffungBrs.tx(ErschaffungBrs.T["volk"]))
	await host.knips("15_erschaffung_aussehen")
	i = 6
	for k in ["Zauberlehrling", "Herumtreiber", "Klosterschüler"]:
		await druecke(e, ErschaffungBrs.tx(ErschaffungBrs.HERKUNFT[k]))
		await frames(3)
		await rolle_zu(e.rolle, ErschaffungBrs.tx(ErschaffungBrs.T["herkunft"]))
		await host.knips("1%d_erschaffung_herkunft_%s" % [i, k.to_lower()])
		i += 1
	await druecke(e, ErschaffungBrs.tx(ErschaffungBrs.HERKUNFT["Wachsoldat"]))
	await frames(3)
	await rolle_zu(e.rolle, ErschaffungBrs.tx(ErschaffungBrs.T["werte"]))
	await host.knips("19_erschaffung_punkte")
	await ganz_unten(e.rolle)
	await host.knips("20_erschaffung_unten")
	await leeren()
	vier_plaetze()
	m = Hauptmenue.new(ui)
	buehne.add_child(m)
	await frames(2)
	await druecke(m, Sprache.u("newGame"))
	await frames(3)
	e = m.get_node("Erschaffung")
	await druecke(e, Sprache.u("start"))
	await frames(3)
	await host.knips("21_erschaffung_platzwahl")
	await leeren()
	alle_plaetze_leer()

func menue_mit(hw: BrsHeld, z: Zustand) -> Menue:
	var m := Menue.new(hw, z)
	m.ort = {"karte": "village", "x": 17, "y": 13, "blick": "UP"}
	buehne.add_child(m)
	await frames(3)
	return m

func reiter(m: Menue, r: String) -> void:
	m.reiter = r; m.geplant.clear(); m.schliesse_erklaerung(); m.baue()
	await frames(4)

func spielermenue() -> void:
	var t := held()
	var hw: BrsHeld = t[0]
	var z: Zustand = t[1]
	var m: Menue = await menue_mit(hw, z)
	await host.knips("25_held_oben")
	await ganz_unten(m.rolle)
	await host.knips("26_held_unten")
	m.rolle.scroll_vertical = 0
	await tippe_text(m, ErschaffungBrs.tx(ErschaffungBrs.GRUNDWERT["kraft"]), "=")
	await host.knips("27_held_erklaerung")
	await schliesse_fenster(m)
	# 870.4: keine Attributspunkte mehr (28, 29 entfallen)
	await reiter(m, "tasche")
	await host.knips("30_tasche_oben")
	await ganz_unten(m.rolle)
	await host.knips("31_tasche_unten")
	m.rolle.scroll_vertical = 0
	await tippe_text(m, Laden.name("potion"), "=")
	await host.knips("32_tasche_trank")
	await schliesse_fenster(m)
	await tippe_text(m, Laden.name("wolf_pelt"), "=")
	await host.knips("33_tasche_pelz")
	await schliesse_fenster(m)
	var schwert := im_beutel(z, "greatsword")
	await tippe_text(m, Beute.name(schwert), "~")
	await host.knips("34_tasche_stueck")
	await druecke(m, "Wegwerfen")
	await host.knips("35_tasche_wegwerfen")
	await schliesse_fenster(m)
	await leeren()
	var leer := held()
	(leer[1] as Zustand).taschen.clear(); (leer[1] as Zustand).beutel.clear()
	m = await menue_mit(leer[0], leer[1])
	await reiter(m, "tasche")
	await host.knips("36_tasche_leer")
	await leeren()
	m = await menue_mit(hw, z)
	await reiter(m, "ausruestung")
	await host.knips("37_ausruestung")
	await tippe_text(m, Beute.name(hw.ding("MAIN_HAND")), "=")
	await host.knips("38_ausruestung_fach")
	await druecke(m, "Wechseln")
	await host.knips("39_ausruestung_wechsel")
	await tippe_text(m, Beute.name(schwert), "~")
	await host.knips("40_ausruestung_wechsel_stueck")
	await schliesse_fenster(m)
	await tippe_text(m, Sprache.t(BrsHeld.daten()["plaetze"]["AMULET"]), "=")
	await host.knips("41_ausruestung_leerplatz")
	await schliesse_fenster(m)
	await reiter(m, "karte")
	await frames(4)
	await host.knips("42_karte")
	await reiter(m, "chronik")
	await host.knips("43_chronik")
	await druecke(m, "Erledigt")
	await frames(3)
	await host.knips("44_chronik_erledigt")
	await druecke(m, "Bisher geschehen")
	await frames(3)
	await host.knips("45_chronik_bisher")
	m.bisher = false
	Bedienung.zeichen_gesehen = false   # wie alt beim ersten Oeffnen: der Hinweis zum Gedrueckthalten
	await reiter(m, "system")
	await host.knips("46_system_oben")
	await ganz_unten(m.rolle)
	await host.knips("47_system_unten")
	m.rolle.scroll_vertical = 0
	await frames(2)
	for zk in m.inhalt.find_children("*", "Zeichenknopf", true, false):
		if (zk as Zeichenknopf).wort == "Tempo": (zk as Zeichenknopf).lang.call(zk.wort, zk.erklaerung)
	await frames(3)
	await host.knips("48_system_erklaerung")
	m.schliesse_erklaerung()
	m.anleitung()
	await frames(4)
	await host.knips("49_system_anleitung")
	await leeren()
	Testmodus.an = true
	m = await menue_mit(hw, z)
	await reiter(m, "test")
	await host.knips("50_test_oben")
	await ganz_unten(m.rolle)
	await host.knips("51_test_unten")
	Testmodus.an = false
	await leeren()

const WAREN := ["potion", "greater_potion", "superior_potion", "remedy", "stamina_potion", "spark_potion", "alchemist_fire", "holy_water"]
const KRAEUTERFRAU := ["potion", "greater_potion", "remedy", "stamina_potion", "holy_water"]

func laden_mit(waren: Array, brauen: bool) -> Array:
	var t := held()
	var l := LadenSchirm.new(t[0], t[1], Laden.new(waren, brauen))
	buehne.add_child(l)
	await frames(4)
	return [l, t[0], t[1]]

func seite(l: LadenSchirm, s: String) -> void:
	l.seite = s; l.baue()
	await frames(4)

func laden() -> void:
	Bedienung.rueckfragen = true
	var a: Array = await laden_mit(WAREN, false)
	var l: LadenSchirm = a[0]
	var hw: BrsHeld = a[1]
	var z: Zustand = a[2]
	await host.knips("52_laden_kaufen")
	await ganz_unten(l.rolle)
	await host.knips("53_laden_kaufen_unten")
	l.rolle.scroll_vertical = 0
	await tippe_text(l, Laden.name("potion"), "=")
	await host.knips("54_laden_menge_kauf")
	await schliesse_fenster(l)
	var ware := Laden.ware(z, hw).filter(func(g): return hw.kann_tragen(g))
	await tippe_text(l, Beute.name(ware[0]), "~")
	await host.knips("55_laden_stueck_kauf")
	await schliesse_fenster(l)
	await seite(l, "verkaufen")
	await host.knips("56_laden_verkaufen")
	await ganz_unten(l.rolle)
	await host.knips("57_laden_verkaufen_unten")
	l.rolle.scroll_vertical = 0
	await tippe_text(l, Laden.name("wolf_pelt"))
	await host.knips("58_laden_menge_verkauf")
	await druecke(l, Sprache.t(Laden.ALLE))
	await druecke(l, Sprache.u("sell"))
	await host.knips("59_laden_alle_verkaufen_frage")
	await schliesse_fenster(l)
	await druecke(l, Sprache.t(Laden.GEWOEHNLICHE))
	await host.knips("60_laden_gewoehnliche_frage")
	await schliesse_fenster(l)
	await tippe_text(l, Beute.name(im_beutel(z, "ring")), "~")
	await druecke(l, Sprache.u("sell") + " ·")
	await host.knips("61_laden_verkauf_selten_frage")
	await schliesse_fenster(l)
	await leeren()
	a = await laden_mit(WAREN, false)
	l = a[0]; hw = a[1]; z = a[2]
	l.laden.verkaufe(z, hw, "wolf_pelt", 1)
	l.laden.verkaufe_ausruestung(z, hw, z.beutel.find(im_beutel(z, "hood")))
	await seite(l, "verkaufen")
	await host.knips("62_laden_zurueckkaufen")
	await leeren()
	a = await laden_mit(KRAEUTERFRAU, true)
	l = a[0]
	await host.knips("63_morwen_kaufen")
	await seite(l, "brauen")
	await host.knips("64_morwen_brauen")
	await tippe_text(l, Laden.name(String(Laden.rezepte()[0]["ergebnis"])), "=")
	await host.knips("65_morwen_brauen_fenster")
	await leeren()

# spiel.gd zeige_rast, Wort fuer Wort (die Welt dahinter ist hier das graugruene Feld)
func zeige_rast(ort: String, z: Zustand, hw: BrsHeld, notiz := "", zweites := false) -> void:
	var lang_ok := Rast.lange_erlaubt(z)
	var titel := Sprache.r({"feuer": "ask", "schenke": "tavern", "zimmer": "room"}[ort])
	var zeilen_: Array = []
	if ort != "feuer": zeilen_.append("%s: %d" % [Sprache.u("gold"), z.gold])
	if ort == "schenke": zeilen_.append(Rast.rowena_sagt(z, hw.name, zweites))
	var k: Array = []
	if ort == "feuer":
		k.append({"text": Sprache.r("short"), "info": Sprache.r("shortDoes"), "id": "kurz"})
		k.append({"text": Sprache.r("long"), "info": Sprache.r("longDoes" if lang_ok else "longDone"), "an": lang_ok, "id": "lang"})
	else:
		if ort == "schenke" and not z.betrunken():
			var preis := Rast.met_preis(z)
			k.append({"text": Sprache.r("meadBuy", [preis]), "info": Sprache.r("meadDoes"), "an": z.gold >= preis, "id": "met"})
		k.append({"text": Sprache.r("roomBuy", [Rast.ZIMMER_PREIS]), "info": Sprache.r("roomDoes" if lang_ok else "longDone"),
			"an": lang_ok and z.gold >= Rast.ZIMMER_PREIS, "id": "lang"})
	ui.zeige_wahl(titel, zeilen_, k, Sprache.r("leave"), notiz)
	await frames(4)

func rast() -> void:
	await leeren()
	var t := held()
	var hw: BrsHeld = t[0]
	var z: Zustand = t[1]
	z.minuten = 20 * 60
	ui.leiste.zeige(hw, z, false)   # die Leiste oben wie im Spiel (alt: die Welt mit ihrer Leiste hinter dem Fenster)
	await zeige_rast("feuer", z, hw)
	await host.knips("66_rast_feuer")
	z.lange_rast_tag = z.tag
	await zeige_rast("feuer", z, hw)
	await host.knips("67_rast_feuer_lang_vergeben")
	z.lange_rast_tag = 0
	await zeige_rast("schenke", z, hw)
	await host.knips("68_rast_schenke")
	var notiz := Rast.met_trinken(z, hw.name)
	await zeige_rast("schenke", z, hw, notiz)
	await host.knips("69_rast_schenke_met")
	z.minuten = 21 * 60
	await zeige_rast("zimmer", z, hw)
	await host.knips("70_rast_zimmer")
	ui.schliesse_wahl()
	await frames(2)

func brett() -> void:
	await leeren()
	var t := held()
	var z: Zustand = t[1]
	var b := BrettSchirm.new(z)
	b.wahl.connect(func(id: String):   # spiel.gd _brett_wahl
		if id.begins_with("nimm:"):
			Auftraege.nimm(z, Auftraege.von(id.trim_prefix("nimm:")))
			b.baue())
	buehne.add_child(b)
	await frames(4)
	await host.knips("71_brett")
	await tippe_text(b, "ANNEHMEN", "=")   # 630: Knopf ohne Kasten
	await frames(2)
	await host.knips("72_brett_angenommen")
	await leeren()
	var t2 := held()
	for f in ["job_pelts_done", "job_ring_done", "job_tusks_done"]: (t2[1] as Zustand).setze(f)
	b = BrettSchirm.new(t2[1])
	buehne.add_child(b)
	await frames(4)
	await host.knips("73_brett_leer")
	await leeren()

func text() -> void:
	await leeren()
	var t := held()
	ui.leiste.zeige(t[0], t[1], false)
	ui.sage([{"wer": "Jäger Garrick", "text": "Und ehrlich, Thora: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald, dann reden wir weiter."}])
	await frames(4)
	await host.knips("74_text_sprecher")
	ui.sage([{"text": "Bornim feiert bis tief in die Nacht. Das Sonnenamulett ist zurück in Bornim, und Schwester Lyra ist in Sicherheit."}])
	await frames(4)
	await host.knips("75_text_erzaehlt")
	ui.sage([])
	await frames(2)

# ---------------------------------------------------------------- fuer den Test ohne Bild: was sichtbar ist
func texte() -> Array:
	var aus := []
	for n in root().find_children("*", "", true, false):
		if not (n is Control) or not (n as Control).is_visible_in_tree(): continue
		var t := ""
		if n is Button: t = "[%s]" % (n as Button).text
		elif n is Label: t = (n as Label).text
		elif n is LineEdit: t = "<%s>" % (n as LineEdit).text
		elif n is RichTextLabel: t = (n as RichTextLabel).get_parsed_text().left(80)
		if t.strip_edges() == "": continue
		var p := (n as Control).global_position
		aus.append("%d,%d\t%s" % [int(p.x), int(p.y), t.replace("\n", " ⏎ ")])
	return aus

func fenster_zahl() -> int:
	var n := 0
	for c in root().find_children("*", "ColorRect", true, false):
		if (c as ColorRect).is_visible_in_tree() and absf((c as ColorRect).color.a - 0.82) < 0.01 and not c.is_queued_for_deletion(): n += 1
	return n
