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
# - System (SystemSigns), soweit es die Welt schon kann: Speichern, Sprache, Hauptmenue; Siege.
# - Chronik (ChronicleTab): Hauptauftrag in Gold, Auftraege der Geschichte, Erledigt zum Aufklappen, „Bisher geschehen“.
# Noch nicht wie alt: Karte; in der Chronik Nebenauftraege (Anschlagbrett), Ankunft und Morgenandacht ansehen; im System Kampf, Bedienung, Klang und Licht, Version, Geraeteangaben; Bilder der Dinge; Vergleich mit dem Getragenen (GearCompare); Fackel im Dunkeln;
# Erklaerung der Attribute beim Antippen (Perks).

signal zu
signal speichern                   # 399.1 System: die Welt haelt den Stand fest (spiel.gd speichere)
signal sprache                     # die Welt wechselt die Sprache (spiel.gd sprache_wechseln)
signal hauptmenue                  # speichern und zum Hauptmenue (spiel.gd)

const DP := AktionsKnopf.DP
const BLAU := Color("82aaf2")      # gearBlue auf Schwarz (Veil.of rare)
const GRUEN := Color("86c46e")     # Veil.good: geplante Werte
const SELTEN := {"COMMON": "bdb6a8", "UNCOMMON": "86c46e", "RARE": "82aaf2", "VERY_RARE": "bc8ef2", "EPIC": "f29e50", "DIVINE": "eac650"}

var hw: Heldwerte
var z: Zustand
var reiter := "held"
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
	kopf.text = (Sprache.t(CHRONIK) if reiter == "chronik" else Sprache.u(WORT[reiter])).to_upper()
	for c in leiste.get_children():
		leiste.remove_child(c)
		c.queue_free()
	# 399.1: Reiter als Zeichen wie alt (TabSign, 60j); Woerter passten zu viert nicht in die Breite
	for r in ["held", "tasche", "ausruestung", "chronik", "system"]:
		var stern: bool = (r == "held" and hw.offen > 0) or (r == "chronik" and reiter != "chronik" and Chronik.frisch(z))
		leiste.add_child(Reiterzeichen.knopf(r, Sprache.t(CHRONIK) if r == "chronik" else Sprache.u(WORT[r]), func(): reiter = r; geplant.clear(); baue(), r == reiter, stern))
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	match reiter:
		"held": held()
		"tasche": tasche()
		"ausruestung": ausruestung()
		"chronik": chronik()
		_: system()
	await get_tree().process_frame
	rolle.scroll_vertical = y

const CHRONIK := {"de": "Chronik", "en": "Chronicle"}   # MenuScreen.kt labels
const WORT := {"held": "hero", "tasche": "bag", "ausruestung": "equipment", "system": "system"}

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
	oben.add_child(Drehteller.new())
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
	inhalt.add_child(posten(Sprache.u("gold"), str(z.gold), Stil.BRIGHT))   # 171: Gold zuerst, eine Zeile fuer sich
	if z.taschen.is_empty(): zeile(Sprache.u("nothing"), 16, Stil.DIM)
	for id in z.taschen:
		var dd := Laden.ding(String(id))
		var p := posten(Laden.name(String(id)), "×%d" % int(z.taschen[id]), Color(SELTEN.get(String(dd.get("seltenheit", "COMMON")), "e6ddcb")))
		var info := Sprache.t(dd.get("info", ""))
		if info != "":
			var spalte: VBoxContainer = p.get_child(0)
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
		var p := posten(Beute.name(g), Beute.kennwert(g), Color(SELTEN.get(String(g["rarity"]), "e6ddcb")))
		inhalt.add_child(p)
		tippbar(p, func(): frage_stueck(g))

# nach Seltenheit, dann Gegenstandsstufe, absteigend (alt: rarity, slot, ilvl)
const REIHE := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
static func vor(a: Dictionary, b: Dictionary) -> bool:
	var ra := REIHE.find(String(a["rarity"])); var rb := REIHE.find(String(b["rarity"]))
	return ra > rb or (ra == rb and int(a["ilvl"]) > int(b["ilvl"]))

# ItemRow ohne Bild: Name (in der Farbe der Seltenheit), rechts die Anzahl oder der Kennwert
func posten(n: String, rechts: String, farbe: Color) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
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
func stueck_zeilen(g: Dictionary) -> Array:
	var de := Sprache.aktiv() == "de"
	var b := Beute.grundform(String(g["base"]))
	var d := Heldwerte.lade()
	var z_: Array = []
	var zeile_ := Beute.listen_zeile(g)
	if zeile_ != "": z_.append(Erschaffung.txt(zeile_, 14, farbe_von(g)))
	var wo := ("Stufe " if de else "Level ") + str(int(g["ilvl"]))
	if zweihaendig(g): wo = ("Beide Hände · " if de else "Both hands · ") + wo
	z_.append(Erschaffung.txt(wo, 13, Stil.WARN if zweihaendig(g) else Stil.DIM))
	for r in g["rolls"]:
		var a := String(r[0]); var w := int(r[1])
		var ad: Dictionary = d["affixdaten"][a]
		var t := ("Kritisch ab %d" % (20 - w) if de else "Critical on %d–20" % (20 - w)) if a == "CRIT" else \
			"+%d%s %s" % [w, "%" if bool(ad["prozent"]) else "", Sprache.t(ad["name"])]
		z_.append(Erschaffung.txt(t, 15))
	if not hw.kann_tragen(g):
		z_.append(Erschaffung.txt(("Als %s kannst du das nicht tragen." if de else "As a %s you cannot wear this.") % Sprache.t(d["klassen"][hw.klasse]["name"]), 13, Stil.DIM))
	return z_

func im_beutel(g: Dictionary) -> int:
	for i in z.beutel.size():
		if int(z.beutel[i]["uid"]) == int(g["uid"]): return i
	return -1

# GameState.equipFromBag: was dafuer herunter muss, kommt in die Tasche
func lege_an(g: Dictionary, neben := false) -> String:
	var i := im_beutel(g)
	if i < 0 or not hw.kann_tragen(g): return ""
	z.beutel.remove_at(i)
	for x in (hw.anlegen_nebenhand(g) if neben else hw.anlegen(g)): z.beutel.append(x)
	return "%s: %s" % [Beute.name(g), Sprache.u("equipped")]

func lege_ab(platz: String) -> void:
	var g = hw.ablegen(platz)
	if g != null: z.beutel.append(g)

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
	dialog("Wirklich wegwerfen?" if de else "Really discard?", farbe_von(g), [
		Erschaffung.txt("%s (%s)" % [Beute.name(g), Sprache.t(Heldwerte.lade()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"]))], 16, farbe_von(g)),
		Erschaffung.txt(("Der Gegenstand ist danach verloren. Beim Händler bekämst du dafür %d Gold." if de else "The item will be gone for good. A trader would pay you %d gold for it.") % preis, 15)],
		[["Wegwerfen" if de else "Discard", func():
			var i := im_beutel(g)
			if i >= 0: z.beutel.remove_at(i)
			meldung(("%s weggeworfen." if de else "%s discarded.") % Beute.name(g))
			baue()], [abbrechen(), func(): pass]])

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
	var schleier: Control
	for g in l:
		var p := posten(Beute.name(g), Beute.kennwert(g), farbe_von(g))
		if not hw.kann_tragen(g): p.modulate.a = 0.45
		tippbar(p, func():
			schleier.queue_free()
			dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), [[Sprache.u("equip"), func(): meldung(lege_an(g, platz == "OFF_HAND" and String(Beute.grundform(String(g["base"]))["slot"]) != "OFF_HAND")); baue(), hw.kann_tragen(g)],
				[Sprache.u("back"), func(): waehle(platz)]]))
		zeilen.append(p)
	schleier = dialog(platzname(platz), Stil.GOLD, zeilen, [[Sprache.u("close"), func(): pass]])

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
			var t := Drehteller.new()
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

# ein Platz: Rahmen mit dem Namen des Getragenen in seiner Farbe (Bilder der Dinge folgen), darunter der Platz; eine Zweihandwaffe
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
	rahmen.add_child(n)
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
	luecke(8)
	zeile(("Siege: " if de else "Victories: ") + str(z.siege), 13, Stil.DIM)

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
		return
	kaestchen([Erschaffung.txt("Hauptauftrag" if de else "Main quest", 13, Stil.GOLD), Erschaffung.txt(Sprache.t(Geschichte.ziel(z)), 16, Stil.BRIGHT)])
	for t in Chronik.offen(z):
		luecke(8)
		kaestchen([Erschaffung.txt(Sprache.t(t["titel"]), 16), Erschaffung.txt(Sprache.t(t["text"]).replace("{name}", hw.name), 14)])
	var fertig := Chronik.fertig(z)
	if not fertig.is_empty():
		luecke(12)
		inhalt.add_child(Erschaffung.knopf(("Erledigt (%d)" if de else "Done (%d)") % fertig.size() + (" ▴" if erledigt_auf else " ▾"), func(): erledigt_auf = not erledigt_auf; baue()))
		if erledigt_auf:
			for t in fertig: zeile("✓ " + Sprache.t(t["titel"]), 14, Stil.DIM)
