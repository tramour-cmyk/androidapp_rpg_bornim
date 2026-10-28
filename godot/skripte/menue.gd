class_name Menue
extends Control
# 399.1 Menue wie im alten Spiel (MenuScreen.kt MenuBody; Test 132, Chef 16:09: „Gold … Trefferpunkte … Taschen … weiß ich alles
# nicht … es gibt ja kein Menü und nichts“): oben gross der Name des Reiters in gesperrten Goldversalien, darunter die Reiter, im
# Kasten der Inhalt, unten „Schließen“. Die Leiste (Tasche) oeffnet es, das Spiel steht so lange. Reiter wie alt:
# - Held (HeroTab): der Held auf dem Drehteller, Name, Volk · Klasse, Stufe und Gold; TP, ZP, EP als Balken; RK, Angriff, Schaden,
#   Uebungsbonus mit Waffe, Zauberangriff und SG; die Attribute mit dem Anteil der Ausruestung (blau, * ueber dem Kapiteldeckel) und
#   Modifikator; freie Punkte mit − und +, Zuruecksetzen und Uebernehmen (mit Rueckfrage); Faehigkeiten mit Volksmerkmal.
# - Tasche (BagTab): Vorraete mit Gold zuerst, Dinge mit Anzahl; Ausruestung in der Tasche nach Seltenheit.
#   Antippen (BagTab): Traenke, Essen, Ausdauertrank und Leuchtfunke benutzen (Game.useItemOutside), Ausruestung anlegen, in die
#   Nebenhand, wegwerfen (mit Rueckfrage und Haendlerpreis).
# - Ausruestung (GearTab): Plaetze links und rechts des Helden (PaperDoll), Antippen legt ab, wechselt oder waehlt aus der Tasche,
#   was passt (die Nebenhand nimmt auch Einhandwaffen); darunter die Kampfwerte.
# - System (SystemSigns), soweit es die Welt schon kann: Speichern, Sprache, Hauptmenue; Rückfragen, Bedienung; Lautstaerke (399.3.1),
#   Schritte, Helligkeit; Siege, Geraet.
# - Karte (MapTab, 62): kartenreiter.gd.
# - Test (TestTab, nur im Testmodus, 399.1): testmodus.gd.
# - Chronik (ChronicleTab): Hauptauftrag in Gold, Auftraege der Geschichte, Nebenauftraege vom Brett, Erledigt zum Aufklappen, „Bisher geschehen“.
# Noch nicht wie alt: in der Chronik Ankunft und Morgenandacht ansehen; im System Blut, Tempo, Kampftext, MARS-Probe (Jerry); Bilder der Dinge;
# Fackel im Dunkeln.

signal zu
signal speichern                   # 399.1 System: die Welt haelt den Stand fest (spiel.gd speichere)
signal sprache                     # die Welt wechselt die Sprache (spiel.gd sprache_wechseln)
signal hauptmenue                  # speichern und zum Hauptmenue (spiel.gd)
signal ueber                       # 399.1 „Über“: wie hauptmenue, dort gleich „Über das Spiel“
signal ankunft                     # 399.1 Chronik: die Ankunft (Intro) noch einmal ansehen (spiel.gd zwischenbild)
signal test(was: String, mit: Array)   # 399.1 Reiter „Test“: teleport, kapitelende, kampf, probe (spiel.gd test_tat)

const DP := AktionsKnopf.DP
const BLAU := Color("82aaf2")      # gearBlue auf Schwarz (Veil.of rare)
const GRUEN := Color("86c46e")     # Veil.good: geplante Werte
const SELTEN := {"COMMON": "bdb6a8", "UNCOMMON": "86c46e", "RARE": "82aaf2", "VERY_RARE": "bc8ef2", "EPIC": "f29e50", "DIVINE": "eac650"}

var hw: Heldwerte
var z: Zustand
var reiter := "held"
var ort := {}                      # 399.1 Karte: wo der Held steht (spiel.gd platz)
var geplant := {}                  # Attribut -> geplante Punkte (pending)
var kopf: Label
var leiste: HBoxContainer
var inhalt: VBoxContainer
var rolle: ScrollContainer
var bisher := false               # Chronik: „Bisher geschehen“ statt Auftraege
var erledigt_auf := false
var meldung_: Label                # 399.1: was Benutzen, Anlegen, Wegwerfen sagt (alt vm.toast), drei Sekunden
var wuerfel := func(n: int, w: int) -> int:
	var t := 0
	for i in n: t += randi_range(1, w)
	return t

func _init(h: Heldwerte, zu_: Zustand) -> void:
	hw = h; z = zu_
	name = "Menue"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(10 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(8 * DP))
	rand.add_child(spalte)
	kopf = Stil.zeile("", 20, Stil.BRIGHT, 5.0)   # 326: Name des Reiters gross wie der Titel des Hauptmenues
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spalte.add_child(kopf)
	leiste = HBoxContainer.new()
	leiste.add_theme_constant_override("separation", int(6 * DP))
	spalte.add_child(leiste)
	meldung_ = Erschaffung.txt("", 15, Stil.BRIGHT)
	meldung_.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	meldung_.visible = false
	spalte.add_child(meldung_)
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var k := Erschaffung.kasten(rolle)
	k.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(k)
	inhalt = VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", 0)
	rolle.add_child(inhalt)
	spalte.add_child(Erschaffung.knopf(Sprache.u("close"), func(): zu.emit()))
	baue()

func baue() -> void:
	var y := rolle.scroll_vertical
	kopf.text = wort(reiter).to_upper()
	for c in leiste.get_children():
		leiste.remove_child(c)
		c.queue_free()
	# 399.1: Reiter als Zeichen wie alt (TabSign, 60j); Woerter passten zu viert nicht in die Breite
	for r in ["held", "tasche", "ausruestung", "karte", "chronik", "system"] + (["test"] if Testmodus.ist_an() else []):   # 399.1 wie alt Tab.TEST
		var stern: bool = (r == "held" and hw.offen > 0) or (r == "chronik" and reiter != "chronik" and Chronik.frisch(z))
		leiste.add_child(Reiterzeichen.knopf(r, wort(r), func(): reiter = r; geplant.clear(); baue(), r == reiter, stern))
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	match reiter:
		"held": held()
		"tasche": tasche()
		"ausruestung": ausruestung()
		"chronik": chronik()
		"karte": inhalt.add_child(Kartenreiter.new(z, ort, rolle.size.y, func(): reiter = "chronik"; baue()))
		"test": Testmodus.reiter(self)
		_: system()
	# die Karte schiebt und zoomt selbst, der Kasten rollt dann nicht
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if reiter == "karte" else ScrollContainer.SCROLL_MODE_SHOW_NEVER
	await get_tree().process_frame
	rolle.scroll_vertical = y

const CHRONIK := {"de": "Chronik", "en": "Chronicle"}   # MenuScreen.kt labels
const KARTE := {"de": "Karte", "en": "Map"}
const WORT := {"held": "hero", "tasche": "bag", "ausruestung": "equipment", "system": "system"}

func wort(r: String) -> String:
	if r == "chronik": return Sprache.t(CHRONIK)
	if r == "karte": return Sprache.t(KARTE)
	if r == "test": return "Test"
	return Sprache.u(WORT[r])

func meldung(t: String) -> void:
	if t == "": return
	meldung_.text = t
	meldung_.visible = true
	var mein := t
	get_tree().create_timer(3.0, true).timeout.connect(func(): if is_instance_valid(meldung_) and meldung_.text == mein: meldung_.visible = false)

func zeile(t: String, sp: float, farbe := Stil.TEXT) -> Label:
	var l := Erschaffung.txt(t, sp, farbe)
	inhalt.add_child(l)
	return l

func luecke(dp: float) -> void: inhalt.add_child(Erschaffung.luecke(dp))

# LabeledBar: Wort 36 dp, Balken, Wert 96 dp
func balken(wort: String, wert: int, hoechst: int, farbe: Color, text := "") -> void:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	var w := Erschaffung.txt(wort, 14)
	w.size_flags_horizontal = Control.SIZE_FILL
	w.custom_minimum_size.x = 36 * DP
	r.add_child(w)
	var b := Leiste.Balken.new()
	b.custom_minimum_size = Vector2(0, 10 * DP)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.anteil = float(wert) / maxf(1.0, float(hoechst)); b.farbe = farbe
	r.add_child(b)
	var v := Erschaffung.txt(text if text != "" else "%d / %d" % [wert, hoechst], 14)
	v.size_flags_horizontal = Control.SIZE_FILL
	v.custom_minimum_size.x = 96 * DP
	r.add_child(v)
	inhalt.add_child(r)

# ---------------------------------------------------------------- Held (HeroTab)
func held() -> void:
	var de := Sprache.aktiv() == "de"
	var d := Heldwerte.lade()
	var oben := HBoxContainer.new()
	oben.add_theme_constant_override("separation", int(10 * DP))
	oben.add_child(Drehteller.new(HeldFigur.wahl(hw, z)))
	var wer := VBoxContainer.new()
	wer.add_theme_constant_override("separation", 0)
	wer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wer.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	wer.add_child(Stil.zeile(hw.name.to_upper(), 14, Stil.GOLD, 3.0))   # MenuHead
	wer.add_child(Erschaffung.txt("%s · %s" % [Sprache.t(d["voelker"][hw.volk]["name"]), Sprache.t(d["klassen"][hw.klasse]["name"])], 15))
	wer.add_child(Erschaffung.txt("%s %d   %s: %d" % [Sprache.u("level"), hw.stufe, Sprache.u("gold"), z.gold], 15))
	oben.add_child(wer)
	inhalt.add_child(oben)
	luecke(8)
	var anteil := float(hw.tp) / maxf(1.0, float(hw.max_tp()))
	balken(Sprache.u("hp"), hw.tp, hw.max_tp(), Leiste.HP_GRUEN if anteil > 0.5 else (Leiste.HP_GELB if anteil > 0.2 else Leiste.ROT))
	if hw.max_zp() > 0: balken(Sprache.u("sp"), hw.zp, hw.max_zp(), Leiste.BLAU)
	var tab: Array = Heldwerte.regel("ep_fuer_stufe")
	if hw.stufe < int(Heldwerte.regel("max_stufe")):
		var von := int(tab[hw.stufe]); var bis := int(tab[hw.stufe + 1])
		balken(Sprache.u("xp"), hw.ep - von, bis - von, Leiste.GOLD_HELL, "%d / %d" % [hw.ep, bis])
	luecke(8)
	var s := hw.schaden()
	zeile("%s %d   %s %s   %s %s" % [Sprache.u("ac"), hw.rk(), Sprache.u("attack"), Erschaffung.vorzeichen(hw.angriff()), Sprache.u("damage"), Beute.wuerfel_text(s, 0, de)], 15)
	zeile("%s %s" % [Sprache.u("proficiency"), Erschaffung.vorzeichen(hw.uebung())] + (" · " + Beute.name(hw.waffe()) if hw.waffe() != null else ""), 14, Stil.DIM)
	if bool(hw.klassendaten()["zauberer"]):
		zeile(("Zauberangriff " if de else "Spell attack ") + Erschaffung.vorzeichen(hw.zauberangriff()) + ("   Zauber-SG " if de else "   Spell save DC ") + str(hw.zauber_sg()), 14, Stil.DIM)
	luecke(10)
	var verplant := 0
	for a in geplant: verplant += int(geplant[a])
	if hw.offen > 0: zeile(Sprache.u("points", [hw.offen - verplant]), 15, Stil.WARN)
	zeile("Tippe auf ein Attribut, um zu sehen, was es bringt." if de else "Tap an ability to see what it does.", 12, Stil.DIM)
	var blau := false
	for a in Heldwerte.ATTRIBUTE:
		var plus := int(geplant.get(a, 0))
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 0)
		var n := Erschaffung.txt(Sprache.t(d["attribute"][a]["name"]), 14 if hw.offen > 0 else 16)
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(n)
		tippbar(n, func(): erklaere(a))
		var w := hw.wert(a) + plus
		var aus := hw.ausruestungs_bonus(a)
		if aus != 0: blau = true
		for spalte in [["%d→%d" % [hw.wert(a), w] if plus > 0 else str(w), 16, GRUEN if plus > 0 else Stil.TEXT, 56],
				[(Erschaffung.vorzeichen(aus) + ("*" if hw.ausruestung_gedeckelt(a) else "")) if aus != 0 else "", 14, BLAU, 30],
				["(%s)" % Erschaffung.vorzeichen(Heldwerte.mod_von(w)), 15, Stil.DIM, 44]]:
			var l := Erschaffung.txt(spalte[0], spalte[1], spalte[2])
			l.autowrap_mode = TextServer.AUTOWRAP_OFF
			l.size_flags_horizontal = Control.SIZE_FILL
			l.custom_minimum_size.x = spalte[3] * DP
			l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			r.add_child(l)
		if hw.offen > 0:
			var weg := Erschaffung.knopf("−", func():
				if plus <= 1: geplant.erase(a)
				else: geplant[a] = plus - 1
				baue())
			weg.size_flags_horizontal = Control.SIZE_FILL
			weg.custom_minimum_size = Vector2(44, 36) * DP
			weg.disabled = plus <= 0
			r.add_child(weg)
			r.add_child(Erschaffung.luecke(0, 4))
			var dazu := Erschaffung.knopf("+", func(): geplant[a] = plus + 1; baue())
			dazu.size_flags_horizontal = Control.SIZE_FILL
			dazu.custom_minimum_size = Vector2(44, 36) * DP
			dazu.add_theme_color_override("font_color", Stil.GOLD)
			dazu.disabled = not hw.kann_steigern(a, verplant) or int(hw.basis[a]) + plus >= int(Heldwerte.regel("max_wert"))
			r.add_child(dazu)
		inhalt.add_child(r)
	if blau:
		zeile("Blau: Bonus durch Ausrüstung (im Wert enthalten)" if de else "Blue: bonus from gear (included in the score)", 12, BLAU)
		var k := hw.kapitel
		zeile(("In Kapitel %d gibt Ausrüstung insgesamt höchstens +%d je Attribut, auf Angriff, Zauberangriff und RK sowie +%d Schaden. * = Deine Ausrüstung könnte mehr." if de
			else "In chapter %d, all gear together adds at most +%d to each ability, attack, spell attack and AC, and +%d damage. * = your gear could give more.") % [k, k, k + 1], 12, Stil.DIM)
	if verplant > 0:
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", int(8 * DP))
		r.add_child(Erschaffung.knopf("Zurücksetzen" if de else "Reset", func(): geplant.clear(); baue()))
		r.add_child(Erschaffung.knopf("Übernehmen" if de else "Apply", frage_verteilen))
		luecke(6)
		inhalt.add_child(r)
	luecke(10)
	zeile(Sprache.u("skills").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))   # MenuHead
	zeile(Sprache.t(d["voelker"][hw.volk]["merkmal"]), 14, Stil.GOLD)
	for f in d["faehigkeiten"]:
		var fd: Dictionary = d["faehigkeiten"][f]
		if String(fd["klasse"]) != hw.klasse or bool(fd.get("mars", false)): continue
		var hat := hw.hat(f)
		var tag := ("  (%s)" % Sprache.u("fromLevel", [int(fd["stufe"])])) if not hat else (("  (%s)" % Sprache.u("passive")) if String(fd.get("kosten", "")) == "PASSIVE" else "")
		zeile(Sprache.t(fd["name"]) + tag, 15, Stil.TEXT if hat else Stil.DIM)
		zeile(Sprache.t(fd["text"]), 13, Stil.DIM)

# ConfirmDialog „Punkte verteilen?“: je Attribut alt → neu, „Das kann nicht rückgängig gemacht werden.“
# Perks.describe (Ausfuhr held.json „erklaerung“): Wert und Modifikator, die Zeile der Klasse, dann was der Modifikator bringt
static func erklaerung(h: Heldwerte, a: String) -> Array:
	var de := Sprache.aktiv() == "de"
	var d := Heldwerte.lade()
	var m := clampi(h.mod(a), -5, 10)
	var l := "de" if de else "en"
	var out := [("Wert %d, Modifikator %s" if de else "Score %d, modifier %s") % [h.wert(a), Erschaffung.vorzeichen(h.mod(a))]]
	out.append_array(d.get("erklaerung_klasse", {}).get("%s:%s" % [h.klasse, a], {}).get(l, []))
	out.append_array(d.get("erklaerung", {}).get(a, {}).get(str(m), {}).get(l, []))
	return out

func erklaere(a: String) -> void:
	var z_ := []
	for i in erklaerung(hw, a).size():
		var t := Erschaffung.txt(erklaerung(hw, a)[i], 15 if i == 0 else 14)
		z_.append(t)
	dialog(Sprache.t(Heldwerte.lade()["attribute"][a]["name"]), Stil.GOLD, z_, [["OK", func(): pass]])

func frage_verteilen() -> void:
	var de := Sprache.aktiv() == "de"
	var d := Heldwerte.lade()
	var schleier := ColorRect.new()
	schleier.color = Color(0, 0, 0, 0.82)
	schleier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schleier)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Erschaffung.kasten(v))
	v.add_child(Stil.zeile(("Punkte verteilen?" if de else "Spend points?").to_upper(), 14, Stil.GOLD, 3.0))
	for a in geplant:
		v.add_child(Erschaffung.txt("%s: %d → %d" % [Sprache.t(d["attribute"][a]["name"]), hw.wert(a), hw.wert(a) + int(geplant[a])], 17))
	v.add_child(Erschaffung.txt("Das kann nicht rückgängig gemacht werden." if de else "This can't be undone.", 14, Stil.DIM))
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	r.add_child(Erschaffung.knopf("Nein" if de else "No", func(): schleier.queue_free()))
	r.add_child(Erschaffung.knopf("Ja, verteilen" if de else "Yes, spend", func():
		for a in geplant:
			for i in int(geplant[a]): hw.steigern(a)   # Hero.applyPoints
		geplant.clear()
		schleier.queue_free()
		baue()))
	v.add_child(r)

# ---------------------------------------------------------------- Tasche (BagTab)
func tasche() -> void:
	var de := Sprache.aktiv() == "de"
	zeile(("Vorräte" if de else "Supplies").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	inhalt.add_child(posten(Sprache.u("gold"), str(z.gold), Stil.BRIGHT, Menue.vorrat_bild("gold")))   # 171: Gold zuerst, eine Zeile fuer sich
	if z.taschen.is_empty(): zeile(Sprache.u("nothing"), 16, Stil.DIM)
	for id in z.taschen:
		var dd := Laden.ding(String(id))
		var p := posten(Laden.name(String(id)), "×%d" % int(z.taschen[id]), Color(SELTEN.get(String(dd.get("seltenheit", "COMMON")), "e6ddcb")), Menue.vorrat_bild(String(id)))
		var info := Sprache.t(dd.get("info", ""))
		if info != "":
			var spalte: VBoxContainer = p.get_child(1)   # nach dem Bild
			spalte.add_child(Erschaffung.txt(info, 13, Stil.DIM))
		inhalt.add_child(p)
		tippbar(p, func(): frage_ding(String(id)))
	luecke(10)
	var dinge: Array = z.beutel.duplicate()
	dinge.sort_custom(vor)
	var k := zeile((("Ausrüstung" if de else "Equipment") + " (%d)" % dinge.size()).to_upper(), 14, Stil.GOLD)
	k.add_theme_font_override("font", Stil.variante(3.0))
	if dinge.is_empty():
		zeile("Besiege Monster und öffne Truhen, um Ausrüstung zu finden." if de else "Defeat monsters and open chests to find equipment.", 14, Stil.DIM)
	for g in dinge:
		# ▲ besser in allem, ▼ schlechter; nichts, wenn gemischt oder gleich (GearUi.kt upgradeVerdict)
		var u = Vergleich.von(hw, g).urteil() if hw.kann_tragen(g) else null
		var pfeil := "▲ " if u == 1 else ("▼ " if u == -1 else "")
		var p := posten(Beute.name(g), pfeil + Beute.kennwert(g), Color(SELTEN.get(String(g["rarity"]), "e6ddcb")), Menue.stueck_rahmen(g, 42))
		inhalt.add_child(p)
		tippbar(p, func(): frage_stueck(g))

# nach Seltenheit, dann Gegenstandsstufe, absteigend (alt: rarity, slot, ilvl)
const REIHE := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
static func vor(a: Dictionary, b: Dictionary) -> bool:
	var ra := REIHE.find(String(a["rarity"])); var rb := REIHE.find(String(b["rarity"]))
	return ra > rb or (ra == rb and int(a["ilvl"]) > int(b["ilvl"]))

# ItemRow, GearRow: Bild, Name (in der Farbe der Seltenheit), rechts die Anzahl oder der Kennwert
func posten(n: String, rechts: String, farbe: Color, bild: Control = null) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	if bild: r.add_child(bild)
	var s := VBoxContainer.new()
	s.add_theme_constant_override("separation", 0)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.add_child(Erschaffung.txt(n, 16, farbe))
	r.add_child(s)
	var w := Erschaffung.txt(rechts, 15)
	w.size_flags_horizontal = Control.SIZE_FILL
	w.autowrap_mode = TextServer.AUTOWRAP_OFF
	w.size_flags_vertical = Control.SIZE_SHRINK_BEGIN   # Helfer: „×2“ stand auf Hoehe der Beschreibung statt des Namens
	r.add_child(w)
	return r

# 399.1: eine Zeile antippen (Modifier.tap); verschoben zum Rollen loest nichts aus
func tippbar(c: Control, was: Callable) -> void:
	c.mouse_filter = Control.MOUSE_FILTER_PASS
	var da := {"p": Vector2.INF}
	c.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed: da["p"] = e.position
			elif da["p"] != Vector2.INF and e.position.distance_to(da["p"]) < 12 * DP:
				da["p"] = Vector2.INF
				was.call())

# DialogSpec: Titel in der Farbe des Dings, Zeilen, Knoepfe [Text, Tat, an]; jeder Knopf schliesst erst den Kasten
func dialog(titel: String, farbe: Color, zeilen: Array, knoepfe: Array) -> Control:
	var schleier := ColorRect.new()
	schleier.color = Color(0, 0, 0, 0.82)
	schleier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schleier)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Erschaffung.kasten(v))
	v.add_child(Stil.zeile(titel.to_upper(), 14, farbe, 3.0))
	for c in zeilen: v.add_child(c)
	for k in knoepfe:
		var tat: Callable = k[1]
		var b := Erschaffung.knopf(String(k[0]), func(): schleier.queue_free(); tat.call())
		if k.size() > 2: b.disabled = not bool(k[2])
		v.add_child(b)
	return schleier

const ABBRECHEN := {"de": "Abbrechen", "en": "Cancel"}
func abbrechen() -> String: return Sprache.t(ABBRECHEN)

# ---------------------------------------------------------------- Dinge benutzen (Game.useItemOutside)
# Leuchtfunke, Ausdauertrank, Essen, Heiltrank und Kraeutertrank ausserhalb des Kampfes; Antwort wie alt (Light, Resting, Msgs, Ui)
static func benutze(z: Zustand, hw: Heldwerte, id: String, wuerfel_: Callable) -> String:
	var dd := Laden.ding(id)
	var art := String(dd.get("art", ""))
	var b: Dictionary = Sprache.texte.get("benutzen", {})
	var sag := func(k: String, werte: Array = []) -> String:
		var s := Sprache.t(b.get(k, k))
		for i in werte.size(): s = s.replace("{%d}" % i, str(werte[i]))
		return s
	if z.anzahl(id) <= 0: return Sprache.u("cannotUseHere")
	if id == "spark_potion":
		if z.funke: return sag.call("sparkAlready")
		z.weg(id); z.funke = true
		return sag.call("sparkDrunk")
	if art == "TONIC":
		if z.ausdauer_trank: return Sprache.r("staminaAlready")
		z.weg(id); z.ausdauer_trank = true
		return Sprache.r("staminaDrunk", [hw.name])
	var h: Array = dd.get("heilt", [])
	if art == "FOOD" and not h.is_empty():
		if z.satt and hw.tp >= hw.max_tp(): return sag.call("alreadyFed", [hw.name])
		z.weg(id)
		var vor := hw.tp
		hw.tp = mini(hw.max_tp(), hw.tp + int(wuerfel_.call(int(h[0]), int(h[1]))) + int(h[2]) + Laden.TALENTE.meal_bonus(hw))   # Perks.mealBonus
		z.satt = true
		return sag.call("ate", [hw.name, Laden.name(id), hw.tp - vor])
	if art != "POTION" or h.is_empty(): return Sprache.u("cannotUseHere")
	var heilt := bool(dd.get("heilt_leiden", false)) and not z.leiden.is_empty()
	if hw.tp >= hw.max_tp() and not heilt: return Sprache.u("alreadyFull")
	z.weg(id)
	var vor := hw.tp
	hw.tp = mini(hw.max_tp(), hw.tp + int(wuerfel_.call(int(h[0]), int(h[1]))) + int(h[2]))
	if heilt: z.leiden.clear()
	var geheilt: String = sag.call("healed", [hw.name, hw.tp - vor])
	return (sag.call("cured", [hw.name]) + " " + geheilt) if heilt else geheilt

func frage_ding(id: String) -> void:
	var dd := Laden.ding(id)
	var art := String(dd.get("art", ""))
	var de := Sprache.aktiv() == "de"
	var trinkbar := art in ["POTION", "FOOD", "TONIC"]
	var zeilen: Array = []
	var bild := Menue.bild_feld("ding-" + id, 48)   # Dialogs.kt: SupplyPicture 48 dp
	bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	zeilen.append(bild)
	var info := Sprache.t(dd.get("info", ""))
	if info != "": zeilen.append(Erschaffung.txt(info, 15))
	var h: Array = dd.get("heilt", [])
	if not h.is_empty(): zeilen.append(Erschaffung.txt(("heilt " if de else "heals ") + Beute.wuerfel_text(h, 0, de), 14, Stil.DIM))
	var farbe := Color(SELTEN.get(String(dd.get("seltenheit", "COMMON")), "e6ddcb"))
	if trinkbar:
		var wort := ("Essen" if de else "Eat") if art == "FOOD" else Sprache.u("use")
		dialog(Laden.name(id), farbe, zeilen, [[wort, func(): meldung(Menue.benutze(z, hw, id, wuerfel)); baue()], [abbrechen(), func(): pass]])
	else:
		dialog(Laden.name(id), farbe, zeilen, [["OK", func(): pass]])

# ---------------------------------------------------------------- Ausruestung anlegen, ablegen, wegwerfen
func farbe_von(g: Dictionary) -> Color: return Color(SELTEN.get(String(g["rarity"]), "e6ddcb"))
func zweihaendig(g) -> bool: return g != null and bool(Beute.grundform(String(g["base"]))["zweihaendig"])
func einhandwaffe(g: Dictionary) -> bool: return Beute.ist_waffe(Beute.grundform(String(g["base"]))) and not zweihaendig(g)

# GearDetails, soweit ohne Vergleich: was und wo, Stufe, Gewicht; die Grundzahl; jede Eigenschaft (Affix.line)
func stueck_zeilen(g: Dictionary) -> Array: return Menue.stueck_zeilen_von(hw, g)

# GearDetails fuer Tasche, Ausruestung und Laden (399.1: auch spiel.gd zeige_stueck)
static func stueck_zeilen_von(hw: Heldwerte, g: Dictionary) -> Array:
	var de := Sprache.aktiv() == "de"
	var farbe_von := func(x: Dictionary) -> Color: return Color(SELTEN.get(String(x["rarity"]), "e6ddcb"))
	var zweihaendig := func(x) -> bool: return x != null and bool(Beute.grundform(String(x["base"]))["zweihaendig"])
	var b := Beute.grundform(String(g["base"]))
	var d := Heldwerte.lade()
	var z_: Array = []
	var bild := Menue.bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], 48)   # Dialogs.kt: GearPicture 48 dp
	bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	z_.append(bild)
	var zeile_ := Beute.listen_zeile(g)
	if zeile_ != "": z_.append(Erschaffung.txt(zeile_, 14, farbe_von.call(g)))
	var wo := ("Stufe " if de else "Level ") + str(int(g["ilvl"]))
	if zweihaendig.call(g): wo = ("Beide Hände · " if de else "Both hands · ") + wo
	z_.append(Erschaffung.txt(wo, 13, Stil.WARN if zweihaendig.call(g) else Stil.DIM))
	for r in g["rolls"]:
		var a := String(r[0]); var w := int(r[1])
		var ad: Dictionary = d["affixdaten"][a]
		var t := ("Kritisch ab %d" % (20 - w) if de else "Critical on %d–20" % (20 - w)) if a == "CRIT" else \
			"+%d%s %s" % [w, "%" if bool(ad["prozent"]) else "", Sprache.t(ad["name"])]
		z_.append(Erschaffung.txt(t, 15))
	if not hw.kann_tragen(g):
		z_.append(Erschaffung.txt(("Als %s kannst du das nicht tragen." if de else "As a %s you cannot wear this.") % Sprache.t(d["klassen"][hw.klasse]["name"]), 13, Stil.DIM))
	elif not hw.ausruestung.values().has(g):
		# GearDetails: was dafuer abgelegt wird, das Urteil gleich sichtbar, darunter warum (GearCompare)
		var v := Vergleich.von(hw, g)
		if not v.ersetzt.is_empty():
			var anderer := v.ersetzt.any(func(x): return String(Beute.grundform(String(x["base"]))["slot"]) != String(b["slot"]))
			z_.append(Erschaffung.txt(("Ersetzt: " if de else "Replaces: ") + ", ".join(PackedStringArray(v.ersetzt.map(func(x): return Beute.name(x)))), 13, Stil.WARN if anderer else Stil.DIM))
		z_.append(Erschaffung.txt(v.satz(), 14, {1: GRUEN, -1: Stil.WARN}.get(v.urteil(), Stil.TEXT)))
		for r in v.zeilen:
			z_.append(Erschaffung.txt("%s: %s → %s" % [r["wort"], r["vorher"], r["nachher"]], 13, {1: GRUEN, -1: Stil.WARN}.get(r["besser"], Stil.DIM)))
	return z_

func im_beutel(g: Dictionary) -> int:
	for i in z.beutel.size():
		if int(z.beutel[i]["uid"]) == int(g["uid"]): return i
	return -1

# GameState.equipFromBag: was dafuer herunter muss, kommt in die Tasche
func lege_an(g: Dictionary, neben := false) -> String:
	var i := im_beutel(g)
	if i < 0 or not hw.kann_tragen(g): return ""
	var war := Menue.fackel(hw)
	z.beutel.remove_at(i)
	for x in (hw.anlegen_nebenhand(g) if neben else hw.anlegen(g)): z.beutel.append(x)
	var f := fackel_satz(war)
	return f if f != "" else "%s: %s" % [Beute.name(g), Sprache.u("equipped")]

func lege_ab(platz: String) -> void:
	var war := Menue.fackel(hw)
	var g = hw.ablegen(platz)
	if g != null: z.beutel.append(g)
	meldung(fackel_satz(war))

# 399.1 Light.torch: eine Fackel in der Nebenhand; torchChange: nur im Dunkeln (nachts draussen, in der Hoehle) sagt es etwas
var dunkel := false
static func fackel(h: Heldwerte) -> bool:
	var g = h.ding("OFF_HAND")
	return g != null and String(Beute.grundform(String(g["base"]))["art"]) == "LIGHT"

func fackel_satz(war: bool) -> String:
	if not dunkel or Menue.fackel(hw) == war: return ""
	return Sprache.t(Sprache.texte.get("benutzen", {}).get("torchLit" if Menue.fackel(hw) else "torchSnuffed", ""))

func frage_stueck(g: Dictionary) -> void:
	var de := Sprache.aktiv() == "de"
	var ok := hw.kann_tragen(g)
	var k: Array = [[Sprache.u("equip"), func(): meldung(lege_an(g)); baue(), ok]]
	if ok and einhandwaffe(g): k.append(["Nebenhand" if de else "Off hand", func(): meldung(lege_an(g, true)); baue()])
	k.append(["Wegwerfen" if de else "Discard", func(): frage_wegwerfen(g)])
	k.append([abbrechen(), func(): pass])
	dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), k)

func frage_wegwerfen(g: Dictionary) -> void:
	var de := Sprache.aktiv() == "de"
	var preis := Laden.verkaufspreis_von(hw, g)
	if not Bedienung.rueckfragen:   # 399.1 Rückfragen aus (MenuScreen.kt: if (!vm.confirmations) discard())
		wirf_weg(g)
		return
	dialog("Wirklich wegwerfen?" if de else "Really discard?", farbe_von(g), [
		Erschaffung.txt("%s (%s)" % [Beute.name(g), Sprache.t(Heldwerte.lade()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"]))], 16, farbe_von(g)),
		Erschaffung.txt(("Der Gegenstand ist danach verloren. Beim Händler bekämst du dafür %d Gold." if de else "The item will be gone for good. A trader would pay you %d gold for it.") % preis, 15)],
		[["Wegwerfen" if de else "Discard", func(): wirf_weg(g)], [abbrechen(), func(): pass]])

func wirf_weg(g: Dictionary) -> void:
	var i := im_beutel(g)
	if i >= 0: z.beutel.remove_at(i)
	meldung(("%s weggeworfen." if de_() else "%s discarded.") % Beute.name(g))
	baue()

func de_() -> bool: return Sprache.aktiv() == "de"

# 214: was in der Tasche an den Platz passt; die Nebenhand nimmt auch Einhandwaffen; Tragbares zuerst, dann Seltenheit, Stufe
func passend(platz: String) -> Array:
	var l: Array = z.beutel.filter(func(g): return String(Beute.grundform(String(g["base"]))["slot"]) == platz or (platz == "OFF_HAND" and einhandwaffe(g)))
	l.sort_custom(func(a, b):
		if hw.kann_tragen(a) != hw.kann_tragen(b): return hw.kann_tragen(a)
		return Menue.vor(a, b))
	return l

func platzname(platz: String) -> String: return Sprache.t(Heldwerte.lade()["plaetze"][platz])

func waehle(platz: String) -> void:
	var de := Sprache.aktiv() == "de"
	var l := passend(platz)
	var zeilen: Array = []
	if l.is_empty(): zeilen.append(Erschaffung.txt("Nichts Passendes im Beutel." if de else "Nothing in the bag fits.", 15, Stil.DIM))
	var schleier := {}   # 399.1 (Test 139.10): ein Lambda haelt den Wert von damals; die Liste wird erst unten zum Kasten
	for g in l:
		var p := posten(Beute.name(g), Beute.kennwert(g), farbe_von(g))
		if not hw.kann_tragen(g): p.modulate.a = 0.45
		tippbar(p, func():
			schleier["k"].queue_free()
			dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), [[Sprache.u("equip"), func(): meldung(lege_an(g, platz == "OFF_HAND" and String(Beute.grundform(String(g["base"]))["slot"]) != "OFF_HAND")); baue(), hw.kann_tragen(g)],
				[Sprache.u("back"), func(): waehle(platz)]]))
		zeilen.append(p)
	schleier["k"] = dialog(platzname(platz), Stil.GOLD, zeilen, [[Sprache.u("close"), func(): pass]])

# PaperDoll: links Kopf, Umhang, Oberkoerper, Arme, Beine; rechts Amulett, Ring, Haupthand, Nebenhand; der Held dazwischen
func ausruestung() -> void:
	var de := Sprache.aktiv() == "de"
	var puppe := HBoxContainer.new()
	puppe.add_theme_constant_override("separation", int(6 * DP))
	for seite in [["HEAD", "CLOAK", "CHEST", "ARMS", "LEGS"], ["AMULET", "RING", "MAIN_HAND", "OFF_HAND"]]:
		var spalte := VBoxContainer.new()
		spalte.add_theme_constant_override("separation", int(4 * DP))
		spalte.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		for platz in seite: spalte.add_child(fach(platz))
		puppe.add_child(spalte)
		if seite[0] == "HEAD":
			var t := Drehteller.new(HeldFigur.wahl(hw, z))
			t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			puppe.add_child(t)
	inhalt.add_child(puppe)
	luecke(10)
	zeile(("Kampfwerte" if de else "Combat stats").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	wert_zeile("Rüstungsklasse" if de else "Armor Class", str(hw.rk()))
	wert_zeile(Sprache.u("attack"), Erschaffung.vorzeichen(hw.angriff()))
	wert_zeile(Sprache.u("damage"), Beute.wuerfel_text(hw.schaden(), 0, de))
	var n = hw.nebenwaffe()
	if n != null: wert_zeile("Nebenhand" if de else "Off hand", "%s · %s" % [Erschaffung.vorzeichen(hw.angriff_mit(n)), Beute.wuerfel_text(hw.schaden_mit(n, true), 0, de)])
	wert_zeile("Kritisch ab" if de else "Critical on", str(hw.krit_ab()) if de else "%d–20" % hw.krit_ab())
	if bool(hw.klassendaten()["zauberer"]): wert_zeile("Zauberangriff / SG" if de else "Spell attack / DC", "%s / %d" % [Erschaffung.vorzeichen(hw.zauberangriff()), hw.zauber_sg()])
	var ad: Dictionary = Heldwerte.lade()["affixdaten"]
	if hw.lebensraub() > 0: wert_zeile(Sprache.t(ad["LIFESTEAL"]["name"]), "%d%%" % hw.lebensraub())
	if hw.schadensminderung() > 0: wert_zeile(Sprache.t(ad["RESIST"]["name"]), str(hw.schadensminderung()))
	for a in ["MAGIC_FIND", "GOLD_FIND", "XP"]:
		if hw.bonus(a) > 0: wert_zeile(Sprache.t(ad[a]["name"]), "+%d%%" % hw.bonus(a))

func wert_zeile(wort: String, wert: String) -> void:
	var r := HBoxContainer.new()
	r.add_child(Erschaffung.txt(wort, 15))
	var w := Erschaffung.txt(wert, 15, Stil.BRIGHT)
	w.size_flags_horizontal = Control.SIZE_FILL
	w.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.add_child(w)
	inhalt.add_child(r)

# 399.1 Bilder der Dinge wie alt (SupplyPicture 36 dp, GearIcon: dunkler Grund mit einem Hauch der Seltenheit, Rand in ihrer Farbe,
# das Bild auf 78 %), gezeichnet im Bau von core (ThingArtExport: daten/ding-<id>.bild, stueck-<grundform>-<seltenheit>.bild), Pixel scharf
static func bild_feld(name: String, dp: float) -> Control:
	var t := TextureRect.new()
	t.texture = Kartenreiter.bild(name)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.custom_minimum_size = Vector2(dp, dp) * DP
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func vorrat_bild(id: String) -> Control: return bild_feld("ding-" + id, 36)

static func stueck_rahmen(g: Dictionary, dp: float) -> Control:
	var farbe := Color(SELTEN.get(String(g["rarity"]), "e6ddcb"))
	var p := PanelContainer.new()
	var st := Stil.kasten(Color("0e0c0a").lerp(farbe, 0.16), farbe, 2.0 if Beute.stufe_von(String(g["rarity"])) >= Beute.stufe_von("EPIC") else 1.0)
	st.set_corner_radius_all(int(3 * DP))
	p.add_theme_stylebox_override("panel", st)
	p.custom_minimum_size = Vector2(dp, dp) * DP
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c := CenterContainer.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], dp * 0.78))
	p.add_child(c)
	var b := Beute.grundform(String(g["base"]))
	if Beute.ist_waffe(b) and bool(b["zweihaendig"]):   # „2H“ oben rechts, unten sitzen die Steine der Seltenheit
		var t := Stil.zeile("2H", clampf(dp / 5.0, 8.0, 12.0), Stil.GOLD)
		var ts := Stil.kasten(Color(0, 0, 0, 0.88), Color(0, 0, 0, 0), 0.0)
		ts.content_margin_left = 2 * DP; ts.content_margin_right = 2 * DP
		t.add_theme_stylebox_override("normal", ts)
		t.size_flags_horizontal = Control.SIZE_SHRINK_END
		t.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		p.add_child(t)
	return p

# ein Platz: Rahmen mit Bild und Namen des Getragenen in seiner Farbe, darunter der Platz; eine Zweihandwaffe
# fuellt auch die Nebenhand
func fach(platz: String) -> Control:
	var zwei := platz == "OFF_HAND" and zweihaendig(hw.waffe())
	var g = hw.waffe() if zwei else hw.ding(platz)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.custom_minimum_size.x = 96 * DP
	var rahmen := PanelContainer.new()
	rahmen.add_theme_stylebox_override("panel", Stil.kasten(Color.BLACK, Stil.LINE if g == null else farbe_von(g), 1.0))
	rahmen.custom_minimum_size = Vector2(96, 56) * DP
	rahmen.size_flags_horizontal = Control.SIZE_FILL
	rahmen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Helfer an der Probe 17:11: lange Namen („Arkanes Heiligensymbol des Gelehrten“) stiessen an den Rahmen und brachen ab:
	# 96 dp breit, 13 sp (DESIGN-STIL „Oberfläche“: mindestens 13 sp), bis drei Zeilen, sonst mit Auslassung
	var n := Stil.zeile(Beute.name(g) if g != null else "–", 13.0, farbe_von(g) if g != null else Stil.DIM, 0.0)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD   # Helfer 17:24: WORD_SMART trennte „Heiligensymb/ol“ mitten im Wort
	n.custom_minimum_size.x = 90 * DP
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	n.max_lines_visible = 3
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if zwei: n.modulate.a = 0.5
	if g != null:   # 399.1: das Bild ueber dem Namen
		var sp := VBoxContainer.new()
		sp.add_theme_constant_override("separation", 0)
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var b := Menue.bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], 40)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if zwei: b.modulate.a = 0.5
		sp.add_child(b)
		n.max_lines_visible = 2
		sp.add_child(n)
		rahmen.add_child(sp)
	else: rahmen.add_child(n)
	v.add_child(rahmen)
	var p := Erschaffung.txt(platzname(platz), 11, Stil.DIM)
	p.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(p)
	tippbar(v, func(): tippe_fach("MAIN_HAND" if zwei else platz))
	return v

func tippe_fach(platz: String) -> void:
	var de := Sprache.aktiv() == "de"
	var g = hw.ding(platz)
	if g == null: waehle(platz); return
	var k: Array = [[Sprache.u("unequip"), func(): lege_ab(platz); baue()]]
	if not passend(platz).is_empty(): k.append(["Wechseln" if de else "Swap", func(): waehle(platz)])
	k.append([Sprache.u("close"), func(): pass])
	dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), k)

# ---------------------------------------------------------------- System (SystemSigns), Teil „Spiel“
func system() -> void:
	var de := Sprache.aktiv() == "de"
	zeile(("Spiel" if de else "Game").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	luecke(6)
	for k in [["Speichern" if de else "Save", "Hält deinen Stand jetzt fest. Beim Verlassen des Spiels und auf dem Weg ins Hauptmenü speichert es ohnehin." if de
			else "Saves your progress now. The game also saves when you leave it or go to the main menu.", func(): speichern.emit(); meldung(Sprache.u("saved"))],
		[("Sprache" if de else "Language") + " · " + Sprache.aktiv().to_upper(), "Wechselt zwischen Deutsch und Englisch." if de else "Switches between German and English.", func(): sprache.emit(); baue()],
		["Hauptmenü" if de else "Main menu", "Speichert und kehrt zum Hauptmenü zurück." if de else "Saves and returns to the main menu.", func(): hauptmenue.emit()]]:
		inhalt.add_child(Erschaffung.knopf(String(k[0]), k[2]))
		zeile(String(k[1]), 13, Stil.DIM)
		luecke(8)
	# 352: die Anleitung; „Über“ (Wer das Spiel macht …); die MARS-Probe folgt mit dem Kampfort (Jerry)
	var a: Dictionary = Sprache.texte.get("anleitung", {})
	for k in [[Sprache.t(a.get("zeichen", {"de": "Anleitung", "en": "Guide"})), Sprache.t(a.get("hinweis", "")), anleitung],
		["Über" if de else "About", "Wer das Spiel macht und worauf seine Regeln beruhen." if de else "Who makes the game and what its rules are based on.", func(): ueber.emit()]]:
		inhalt.add_child(Erschaffung.knopf(String(k[0]), k[2]))
		zeile(String(k[1]), 13, Stil.DIM)
		luecke(8)
	bedienung()
	# 399.3.1 Lautstaerke wie alt (SoundSettings.kt SoundAndLight, 40): Gesamt, Musik, Effekte und Ortsklang, in Schritten zu 5 (Mix.STEP);
	# Loslassen bei Gesamt und Effekten klickt einmal, so hoert man, wie laut es nun ist (40a)
	var k := get_node_or_null("/root/Klang")   # ueber den Knoten wie spiel.gd klang(): mit -s gibt es den Autoload nicht
	if k:
		zeile("Lautstärke" if de else "Volume", 15, Stil.TEXT)
		for r in [["all", "Gesamt" if de else "Overall", true], ["music", "Musik" if de else "Music", false], ["fx", "Effekte und Ortsklang" if de else "Effects and ambience", true]]:
			var an: bool = k.musik_an if r[0] == "music" else (k.effekte_an if r[0] == "fx" else true)
			inhalt.add_child(Regler.new(String(r[1]), int(k.lautstaerke[r[0]]) if an else 0, "Aus" if de else "Off",
				func(v: int): k.stelle(r[0], v), (func(): k.effekt("click", 0.35)) if r[2] else Callable()))
		luecke(8)
		# Schritte an oder aus wie alt (MenuSigns.kt Sign „Schritte“, vm.toggleSteps); gespeichert mit den Reglern
		inhalt.add_child(Erschaffung.knopf(("Schritte" if de else "Steps") + " · " + (("An" if de else "On") if k.schritte_an else ("Aus" if de else "Off")),
			func(): k.schritte_an = not k.schritte_an; k.stelle("all", int(k.lautstaerke["all"])); baue(), k.schritte_an))
		zeile("Die Schritte deines Helden hörbar oder still; alle anderen Geräusche bleiben." if de else "Your hero's footsteps audible or silent; all other sounds stay.", 13, Stil.DIM)
		luecke(8)
	# Helligkeit wie alt (SoundAndLight, 13e.6): „Dunkle Töne“ hebt das Schwarz, das Probezeichen liegt mit unter der Hebung
	zeile("Helligkeit" if de else "Brightness", 15, Stil.TEXT)
	inhalt.add_child(Regler.new("Dunkle Töne" if de else "Shadows", Helligkeit.lade(), "Aus" if de else "Off", func(v: int): Helligkeit.setze(v), Callable()))
	var zeichen := Probezeichen.new()
	inhalt.add_child(zeichen)
	zeile("So einstellen, dass das Zeichen gerade noch zu sehen ist. Die Höhle bleibt dunkel." if de else "Adjust until the sign is barely visible. The cave stays dark.", 13, Stil.DIM)
	luecke(8)
	luecke(8)
	zeile(("Schritte: %d · Siege: %d" if de else "Steps: %d · Victories: %d") % [z.schritte, z.siege], 13, Stil.DIM)
	# 388 (DeviceBox, Chef 27.10., 21:58): Geraeteangaben zum Kopieren, damit Tester sie schicken koennen, wenn das Spiel ruckelt
	luecke(10)
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", int(6 * DP))
	reihe.add_child(Erschaffung.knopf(("Gerät schließen" if de else "Hide device info") if geraet_auf else ("Gerät zeigen …" if de else "Show device…"), func(): geraet_auf = not geraet_auf; baue()))
	if geraet_auf:
		var b := Erschaffung.knopf("Kopieren" if de else "Copy", func(): DisplayServer.clipboard_set(geraeteangaben()); meldung("Geräteangaben kopiert." if de else "Device details copied."))
		b.size_flags_stretch_ratio = 0.5
		reihe.add_child(b)
	inhalt.add_child(reihe)
	if geraet_auf: zeile(geraeteangaben(), 11, Stil.TEXT)

var geraet_auf := false

# 352 GuideScreen wie alt: schwarz, ein Kasten, oben der Titel, je Absatz die fette Eroeffnung als Ueberschrift in Gold (16 sp),
# der Rest 15 sp, fette Woerter (Knoepfe) halbfett in Gold; nur die Faehigkeiten der eigenen Klasse; unten „Zurück“
static func anleitung_teile(klasse: String) -> Array:
	var r := []
	for p in Sprache.texte.get("anleitung", {}).get("teile", []):
		if not p.has("nur") or String(p["nur"]) == klasse: r.append(Sprache.t(p))
	return r

# (Text, fett) der Reihe nach, wie Guide.pieces
static func stuecke(t: String) -> Array:
	var r := []
	var s := t.split("**")
	for i in s.size():
		if s[i] != "": r.append([s[i], i % 2 == 1])
	return r

func anleitung() -> void:
	var seite := Control.new()
	seite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(seite)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	seite.add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for r in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + r, int(16 * DP))
	seite.add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(12 * DP))
	rand.add_child(spalte)
	var rolle_ := ScrollContainer.new()
	rolle_.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle_.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var k := Erschaffung.kasten(rolle_)
	k.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(k)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", int(10 * DP))
	rolle_.add_child(v)
	v.add_child(Stil.zeile(Sprache.t(Sprache.texte.get("anleitung", {}).get("titel", "")).to_upper(), 12, Stil.BRIGHT, 3.0))
	var halbfett := FontVariation.new()
	halbfett.base_font = Stil.schrift()
	halbfett.variation_embolden = 0.5   # nur der gerade Schnitt; Compose setzt SemiBold kuenstlich
	halbfett.spacing_glyph = int(round(0.2 * Stil.SP))
	var gerade := Stil.variante(0.2)
	for t in anleitung_teile(hw.klasse):
		var st := stuecke(t)
		var absatz := VBoxContainer.new()
		absatz.add_theme_constant_override("separation", 0)
		if not st.is_empty() and st[0][1]:
			var h := Stil.zeile(String(st[0][0]).strip_edges(), 16, Stil.GOLD)
			h.add_theme_font_override("font", halbfett)
			absatz.add_child(h)
			st = st.slice(1)
		var rt := RichTextLabel.new()
		rt.bbcode_enabled = true
		rt.fit_content = true
		rt.scroll_active = false
		rt.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 399.1 (Test 139: „Anleitung. Kann man nicht scrollen“): sonst schluckt der Text das Wischen
		rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rt.add_theme_font_override("normal_font", gerade)
		rt.add_theme_font_override("bold_font", halbfett)
		rt.add_theme_font_size_override("normal_font_size", int(round(15 * 0.95 * Stil.SP)))
		rt.add_theme_font_size_override("bold_font_size", int(round(15 * 0.95 * Stil.SP)))
		rt.add_theme_constant_override("line_separation", int(round(15 * 0.35 * Stil.SP)))
		rt.add_theme_color_override("default_color", Stil.TEXT)
		var b := ""
		for i in st.size():
			var s := String(st[i][0])
			if i == 0: s = s.lstrip(" ")
			s = s.replace("[", "[lb]")
			b += ("[b][color=#%s]%s[/color][/b]" % [Stil.GOLD.to_html(false), s]) if st[i][1] else s
		rt.text = b
		absatz.add_child(rt)
		v.add_child(absatz)
	spalte.add_child(Erschaffung.knopf(Sprache.u("back"), func(): seite.queue_free()))

# 399.1 wie alt (SystemSigns): „Kampf“ mit Rückfragen (Blut, Tempo, Kampftext folgen mit dem Kampfort, Jerry), dann „Bedienung“:
# Steuerung, Joystick und Rennen nur beim Wischen, Aktion, Karte, Rütteln; Antippen wechselt, gespeichert in Bedienung.gd
func bedienung() -> void:
	var de := Sprache.aktiv() == "de"
	Bedienung.lade()
	var an := func(b: bool) -> String: return ("An" if de else "On") if b else ("Aus" if de else "Off")
	var eintrag := func(name_: String, wert: String, hinweis: String, an_: bool, tut: Callable) -> void:
		inhalt.add_child(Erschaffung.knopf(name_ + " · " + wert, func(): tut.call(); Bedienung.speichere(); baue(), an_))
		zeile(hinweis, 13, Stil.DIM)
		luecke(8)
	luecke(4)
	zeile(("Kampf" if de else "Combat").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	luecke(6)
	eintrag.call("Rückfragen" if de else "Confirmations", an.call(Bedienung.rueckfragen), Sprache.u("confirmHint"), Bedienung.rueckfragen,
		func(): Bedienung.rueckfragen = not Bedienung.rueckfragen)
	luecke(4)
	zeile(("Bedienung" if de else "Input").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))   # Homer [326.abschnitt.bedienung]
	luecke(6)
	eintrag.call("Steuerung" if de else "Controls", ("Klassisch" if de else "Classic") if Bedienung.klassisch else ("Wischen" if de else "Swipe"),
		"Wischen: Finger ziehen zum Laufen, weit ziehen zum Rennen, tippen zum Hinlaufen. Klassisch: Steuerkreuz und ein großer Knopf zum Handeln." if de
		else "Swipe: drag to walk, drag far to run, tap to walk there. Classic: a D-pad and a big button to act.", false,
		func(): Bedienung.klassisch = not Bedienung.klassisch)
	if not Bedienung.klassisch:   # 86.4, 131: Joystick und Renntaste nur beim Wischen
		var gefuehl := ["Fein", "Normal", "Ruhig"] if de else ["Fine", "Normal", "Calm"]
		eintrag.call("Joystick", gefuehl[Bedienung.ring], "Im Kreis geht man, über den Ring hinaus rennt man. Fein: kleiner Ring. Ruhig: großer Ring." if de
			else "Inside the ring you walk; beyond it you run. Fine: small ring. Calm: large ring.", false, func(): Bedienung.ring = (Bedienung.ring + 1) % 3)
		eintrag.call("Rennen" if de else "Run", ("Taste" if de else "Button") if Bedienung.lauf_taste else "Ring",
			"Wie du rennst. Ring: über den Ring des Joysticks hinausziehen. Taste: dazu ein eigener Knopf zum Rennen." if de
			else "How you run. Ring: push past the joystick's ring. Button: adds a separate run button.", false, func(): Bedienung.lauf_taste = not Bedienung.lauf_taste)
	eintrag.call("Aktion" if de else "Action", ("Links" if de else "Left") if Bedienung.links else ("Rechts" if de else "Right"),
		"Auf welcher Seite der Aktionsknopf steht: rechts, oder links für Linkshänder." if de else "Which side the action button sits on: right, or left for left-handed players.",
		false, func(): Bedienung.links = not Bedienung.links)
	eintrag.call("Karte" if de else "Map", ("Näher" if de else "Close") if Bedienung.karte_nah else "Normal",
		"Wie nah die Karte ist. Näher zeigt weniger Umgebung, dafür größer." if de else "Map zoom. Close shows less of your surroundings, but larger.",
		false, func(): Bedienung.karte_nah = not Bedienung.karte_nah)
	eintrag.call("Rütteln" if de else "Haptics", an.call(Bedienung.ruetteln),
		"Das Handy zittert kurz, wenn vor dir etwas zu tun ist oder ein Weg nicht geht." if de else "The phone buzzes briefly when there is something to do ahead of you or a path is blocked.",
		Bedienung.ruetteln, func(): Bedienung.ruetteln = not Bedienung.ruetteln)

# DeviceInfo.lines: was Geraet, System und Grafik sind, dazu die Messwerte des Spiels
static func geraeteangaben() -> String:
	var gr := DisplayServer.screen_get_size()
	var z_ := [
		"Version: %s" % String(ProjectSettings.get_setting("application/config/version", "")),
		"Gerät: %s" % OS.get_model_name(),
		"System: %s %s" % [OS.get_name(), OS.get_version()],
		"Grafik: %s (%s), %s" % [RenderingServer.get_video_adapter_name(), RenderingServer.get_video_adapter_vendor(), String(ProjectSettings.get_setting("rendering/renderer/rendering_method", ""))],
		"Bildschirm: %d × %d, %d dpi" % [gr.x, gr.y, DisplayServer.screen_get_dpi()],
		"Speicher: %d MB" % int(OS.get_static_memory_usage() / 1048576),
		"Prozessorkerne: %d" % OS.get_processor_count(),
	]
	var ml := Engine.get_main_loop()
	z_.append_array(Messung.zeilen(ml.root if ml is SceneTree else null))   # 399.1 Messwerte wie alt (deviceReadings)
	return "\n".join(PackedStringArray(z_))

# BrightnessSign: ein Ring mit Flammenstrich in 10 von 255 auf reinem Schwarz, so dunkel wie der Umriss einer Hoehle
class Probezeichen extends Control:
	func _init() -> void:
		custom_minimum_size = Vector2(0, 96 * AktionsKnopf.DP)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
	func _draw() -> void:
		var dp := AktionsKnopf.DP
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
		draw_rect(Rect2(Vector2.ZERO, size), Stil.RIM, false, dp)
		var c := Color(Helligkeit.ZEICHEN, Helligkeit.ZEICHEN, Helligkeit.ZEICHEN)
		var m := size / 2
		var r := 28 * dp
		draw_arc(m, r, 0, TAU, 48, c, 5 * dp, true)
		draw_line(m - Vector2(0, r * 0.6), m + Vector2(0, r * 0.6), c, 6 * dp)

# GoldSlider (SoundSettings.kt): Name und Wert darueber, eine Goldlinie darunter; Antippen oder Ziehen, in Schritten zu 5
class Regler extends VBoxContainer:
	var wert := 0
	var aus := ""
	var aendert: Callable
	var fertig: Callable
	var zahl: Label
	var linie: Control

	func _init(name_: String, w: int, aus_: String, aendert_: Callable, fertig_: Callable) -> void:
		wert = w; aus = aus_; aendert = aendert_; fertig = fertig_
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var kopf := HBoxContainer.new()
		add_child(kopf)
		var n := Erschaffung.txt(name_, 14)
		kopf.add_child(n)
		zahl = Stil.zeile("", 14 * 0.95, Stil.BRIGHT, 0.2)
		kopf.add_child(zahl)
		linie = Control.new()
		linie.custom_minimum_size = Vector2(0, 36 * AktionsKnopf.DP)
		linie.mouse_filter = Control.MOUSE_FILTER_STOP
		linie.draw.connect(_zeichne)
		linie.gui_input.connect(_eingabe)
		add_child(linie)
		zeige()

	func zeige() -> void:
		zahl.text = aus if wert == 0 else "%d %%" % wert
		linie.queue_redraw()

	static func stufe(p: int) -> int: return ((clampi(p, 0, 100) + 2) / 5) * 5   # Mix.clamp

	func _eingabe(e: InputEvent) -> void:
		var x := -1.0
		if e is InputEventScreenTouch or e is InputEventScreenDrag: x = e.position.x
		elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.device != InputEvent.DEVICE_ID_EMULATION: x = e.position.x
		if x < 0: return
		var neu := stufe(roundi(x / linie.size.x * 100))
		if neu != wert:
			wert = neu
			aendert.call(wert)
			zeige()
		if e is InputEventScreenTouch and not e.pressed and fertig.is_valid(): fertig.call()
		linie.accept_event()

	func _zeichne() -> void:
		var dp := AktionsKnopf.DP
		var y := linie.size.y / 2
		var knopf := 7 * dp
		var x := knopf + (linie.size.x - 2 * knopf) * wert / 100.0
		linie.draw_line(Vector2(knopf, y), Vector2(linie.size.x - knopf, y), Stil.RIM, 2 * dp)
		linie.draw_line(Vector2(knopf, y), Vector2(x, y), Stil.GOLD, 3 * dp)
		var r := Rect2(x - knopf, y - knopf * 1.6, knopf * 2, knopf * 3.2)
		linie.draw_rect(r, Color.BLACK)
		linie.draw_rect(r, Stil.BRIGHT, false, 1.5 * dp)

# ---------------------------------------------------------------- Chronik (ChronicleTab)
func kaestchen(zeilen: Array) -> void:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	for c in zeilen: v.add_child(c)
	var p := PanelContainer.new()
	var st := Stil.kasten(Color.BLACK, Stil.RIM, 1.0)
	st.content_margin_left = 12 * DP; st.content_margin_right = 12 * DP; st.content_margin_top = 8 * DP; st.content_margin_bottom = 8 * DP
	p.add_theme_stylebox_override("panel", st)
	p.add_child(v)
	inhalt.add_child(p)

func chronik() -> void:
	var de := Sprache.aktiv() == "de"
	Chronik.gelesen(z)
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * DP))
	r.add_child(Erschaffung.knopf("Aufträge" if de else "Quests", func(): bisher = false; baue(), not bisher))
	r.add_child(Erschaffung.knopf("Bisher geschehen" if de else "Story so far", func(): bisher = true; baue(), bisher))
	inhalt.add_child(r)
	luecke(10)
	if bisher:
		var l := Chronik.bisher(z)
		for i in l.size():
			if i > 0: luecke(12)
			zeile(Sprache.t(l[i]["titel"]), 17, Stil.BRIGHT if i == 0 else Stil.GOLD)
			zeile(Sprache.t(l[i]["text"]).replace("{name}", hw.name), 15, Stil.TEXT if i == 0 else Stil.DIM)
		# 69d: die Ankunft bei Nacht gehoert vor den ersten Eintrag; man kann sie wieder ansehen (ChronicleTab onIntro)
		if Zwischenbild.da():
			luecke(12)
			var b := Erschaffung.knopf("Die Ankunft ansehen" if de else "Watch the arrival", func(): ankunft.emit())
			b.custom_minimum_size.y = 36 * DP
			b.add_theme_font_size_override("font_size", int(round(14 * Stil.SP)))
			inhalt.add_child(b)
		return
	kaestchen([Erschaffung.txt("Hauptauftrag" if de else "Main quest", 13, Stil.GOLD), Erschaffung.txt(Sprache.t(Geschichte.ziel(z)), 16, Stil.BRIGHT)])
	for t in Chronik.offen(z):
		luecke(8)
		kaestchen([Erschaffung.txt(Sprache.t(t["titel"]), 16), Erschaffung.txt(Sprache.t(t["text"]).replace("{name}", hw.name), 14)])
	# 399.1 Nebenauftraege vom Anschlagbrett (ChronicleTab): Titel, von wem, Aushang, Stand oder „Bereit zur Abgabe“, Lohn
	var getragen := Auftraege.getragen(z)
	if not getragen.is_empty():
		luecke(12)
		zeile("Nebenaufträge" if de else "Side quests", 15, Stil.GOLD)
	for j in getragen:
		luecke(8)
		var hat := Auftraege.stand(z, j)
		var bereit := hat >= int(j["anzahl"])
		var wer := Sprache.t(j["geber_name"])
		kaestchen([Erschaffung.txt(Sprache.t(j["titel"]), 16), Erschaffung.txt(("von " if de else "from ") + wer, 13, Stil.DIM),
			Erschaffung.txt(Sprache.t(j["aushang"]), 14),
			Erschaffung.txt((("Bereit zur Abgabe – bei %s" if de else "Ready to turn in to %s") % wer) if bereit
				else "%d %s %d · %s" % [hat, "von" if de else "of", int(j["anzahl"]), Laden.name(String(j["ding"]))], 14, GRUEN if bereit else Stil.GOLD),
			Erschaffung.txt(("Lohn: " if de else "Reward: ") + Sprache.t(j["lohn"]), 13, Stil.DIM)])
	var fertig := Chronik.fertig(z)
	var fertig_j := Auftraege.alle().filter(func(j): return Auftraege.erledigt(z, j))
	if not fertig.is_empty() or not fertig_j.is_empty():
		luecke(12)
		inhalt.add_child(Erschaffung.knopf(("Erledigt (%d)" if de else "Done (%d)") % (fertig.size() + fertig_j.size()) + (" ▴" if erledigt_auf else " ▾"), func(): erledigt_auf = not erledigt_auf; baue()))
		if erledigt_auf:
			for t in fertig: zeile("✓ " + Sprache.t(t["titel"]), 14, Stil.DIM)
			for j in fertig_j: zeile("✓ " + Sprache.t(j["titel"]) + " · " + Sprache.t(j["geber_name"]), 14, Stil.DIM)
