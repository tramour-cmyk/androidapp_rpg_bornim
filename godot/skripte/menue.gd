class_name Menue
extends Control
# 399.1 Menue wie im alten Spiel (MenuScreen.kt MenuBody; Test 132, Chef 16:09: „Gold … Trefferpunkte … Taschen … weiß ich alles
# nicht … es gibt ja kein Menü und nichts“): oben gross der Name des Reiters in gesperrten Goldversalien, darunter die Reiter, im
# Kasten der Inhalt, unten „Schließen“. Die Leiste (Tasche) oeffnet es, das Spiel steht so lange. Reiter wie alt:
# - Held (HeroTab): der Held auf dem Drehteller, Name, Volk · Klasse, Stufe und Gold; TP, ZP, EP als Balken; RK, Angriff, Schaden,
#   Uebungsbonus mit Waffe, Zauberangriff und SG; die Attribute mit dem Anteil der Ausruestung (blau, * ueber dem Kapiteldeckel) und
#   Modifikator; freie Punkte mit − und +, Zuruecksetzen und Uebernehmen (mit Rueckfrage); Faehigkeiten mit Volksmerkmal.
# - Tasche (BagTab): Vorraete mit Gold zuerst, Dinge mit Anzahl; Ausruestung in der Tasche nach Seltenheit.
# Noch nicht wie alt: Ausruestung, Karte, Chronik, System; Dinge benutzen, anlegen, wegwerfen; Bilder der Dinge; Erklaerung der
# Attribute beim Antippen (Perks).

signal zu

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
	kopf.text = Sprache.u("hero" if reiter == "held" else "bag").to_upper()
	for c in leiste.get_children():
		leiste.remove_child(c)
		c.queue_free()
	for r in ["held", "tasche"]:
		var stern := " ★" if r == "held" and hw.offen > 0 else ""
		leiste.add_child(Erschaffung.knopf(Sprache.u("hero" if r == "held" else "bag") + stern, func(): reiter = r; geplant.clear(); baue(), r == reiter))
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	if reiter == "held": held()
	else: tasche()
	await get_tree().process_frame
	rolle.scroll_vertical = y

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
	r.add_child(w)
	return r
