class_name LadenSchirm
extends Menue
# 416.3 (Chef 31.10., Build 143: Laden nur etwa drei Viertel des Schirms; „bildschirmfüllend, Design mit der alten Fassung abgleichen
# … das war wirklich ganz toll“): der Laden wie ShopScreen.kt im schwarzen Look des Menues, ganzer Schirm. Oben im Kasten der Name
# (Laden oder Morwens Hütte) und rechts das Gold; darunter Kaufen, Verkaufen (und bei Morwen Brauen); beim Verkaufen die neun
# angelegten Stuecke als Leiste; im Kasten Zurueckkaufen, Vorraete (Bild, Name, Werte, Preis rechts), Ausruestung (tragbar zuerst,
# „Nicht tragbar“ matt darunter), „Gewöhnliche verkaufen“; unten die letzte Meldung und „Schließen“. Antippen oeffnet die Kaesten
# wie alt: Menge (−, +, ×1, ×5, Alle), Stueck (Werte, Gold vorher → nachher), Rueckfragen (59e). Regeln in laden.gd.

var laden: Laden
var seite := "kaufen"              # kaufen, verkaufen, brauen
var gold_: Label
var notiz: Label

func _init(h: Heldwerte, zu_: Zustand, l: Laden) -> void:
	super(h, zu_)
	laden = l
	name = "Laden"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	Zurueck.melde(self, func(): zu.emit())   # 416.1
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
	# Panel: Name links (VeilHead), Gold rechts (20 sp, Veil.gold)
	var reihe := HBoxContainer.new()
	kopf = Stil.zeile("", 17, Stil.GOLD, 3.0)
	kopf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reihe.add_child(kopf)
	gold_ = Stil.zeile("", 20, Stil.GOLD)
	reihe.add_child(gold_)
	spalte.add_child(Erschaffung.kasten(reihe))
	leiste = HBoxContainer.new()
	leiste.add_theme_constant_override("separation", int(8 * DP))
	spalte.add_child(leiste)
	meldung_ = Erschaffung.txt("", 15, Stil.BRIGHT)   # Menue.meldung (drei Sekunden) bleibt ungenutzt; die Notiz unten bleibt stehen wie alt
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
	inhalt.add_theme_constant_override("separation", int(4 * DP))
	rolle.add_child(inhalt)
	notiz = Erschaffung.txt("", 15)
	var nk := Erschaffung.kasten(notiz)
	nk.visible = false
	notiz.set_meta("kasten", nk)
	spalte.add_child(nk)
	spalte.add_child(Erschaffung.knopf(Sprache.u("close"), func(): zu.emit()))
	baue()

func sage(t: String) -> void:
	notiz.text = t
	(notiz.get_meta("kasten") as Control).visible = t != ""

func baue() -> void:
	var y := rolle.scroll_vertical
	var de := de_()
	kopf.text = (Sprache.t(Laden.HUETTE) if laden.brauen else Sprache.u("shop")).to_upper()
	gold_.text = "%d G" % z.gold
	for c in leiste.get_children():
		leiste.remove_child(c)
		c.queue_free()
	var seiten := [["kaufen", Sprache.u("buy")], ["verkaufen", Sprache.u("sell")]]
	if laden.brauen: seiten.append(["brauen", "Brauen" if de else "Brew"])
	for s in seiten:
		var w: String = s[0]
		leiste.add_child(Erschaffung.knopf(String(s[1]), func(): seite = w; baue(), w == seite))
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	match seite:
		"brauen": brauen()
		"verkaufen": verkaufen()
		_: kaufen()
	await get_tree().process_frame
	if is_instance_valid(rolle): rolle.scroll_vertical = y

func kopfzeile(t: String) -> void:
	var l := zeile(t.to_upper(), 14, Stil.GOLD)
	l.add_theme_font_override("font", Stil.variante(3.0))

func preis_text(p: int) -> String: return Sprache.u("price", [p])

# eine Zeile: Bild, Name (Farbe), darunter matt, rechts der Preis; antippen
func reihe(bild: Control, name_: String, farbe: Color, unter: Array, rechts: String, tat: Callable, matt := false) -> void:
	var p := posten(name_, rechts, farbe, bild)
	var sp: VBoxContainer = p.get_child(1 if bild else 0)
	for u in unter: sp.add_child(Erschaffung.txt(String(u), 12, Stil.DIM))
	if matt: p.modulate.a = 0.5
	inhalt.add_child(p)
	tippbar(p, tat)

# ---------------------------------------------------------------- Kaufen
func kaufen() -> void:
	var de := de_()
	kopfzeile(Sprache.t(Laden.VORRAETE))
	if laden.waren.is_empty(): zeile(Sprache.u("nothing"), 14, Stil.DIM)
	for id_ in laden.waren:
		var id := String(id_)
		var p := Laden.kaufpreis(hw, id)
		var unter := [Sprache.t(Laden.ding(id).get("info", ""))]
		if z.anzahl(id) > 0: unter.append(("Im Besitz: " if de else "Owned: ") + str(z.anzahl(id)))
		reihe(Menue.vorrat_bild(id), Laden.name(id), farbe_ding(id) if z.gold >= p else Stil.DIM, unter, preis_text(p), func(): menge(id, true, 1))
	if laden.brauen: return   # Morwen handelt nur mit Kraeutern und Traenken
	luecke(8)
	var ware := Laden.ware(z, hw)
	kopfzeile("%s (%d)" % [Sprache.t(Laden.AUSRUESTUNG), ware.size()])
	zeile(Sprache.t(Laden.NEUE_WARE), 12, Stil.DIM)
	if ware.is_empty(): zeile(Sprache.u("nothing"), 14, Stil.DIM)
	ware_liste(ware, true)

# 59.2: was der Held tragen kann zuerst, der Rest darunter matt unter „Nicht tragbar“
func ware_liste(liste: Array, kauf: bool) -> void:
	var nicht := liste.filter(func(g): return not hw.kann_tragen(g))
	for g in liste.filter(func(g): return hw.kann_tragen(g)): stueck_reihe(g, kauf, false)
	if nicht.is_empty(): return
	luecke(6)
	kopfzeile("⊘ %s (%d)" % [Sprache.t(Laden.NICHT_TRAGBAR), nicht.size()])
	for g in nicht: stueck_reihe(g, kauf, true)

func stueck_reihe(g: Dictionary, kauf: bool, matt: bool) -> void:
	var p := Laden.kaufpreis_von(hw, g) if kauf else Laden.verkaufspreis_von(hw, g)
	var u = Vergleich.von(hw, g).urteil() if hw.kann_tragen(g) else null
	var pfeil := "▲ " if u == 1 else ("▼ " if u == -1 else "")
	reihe(Menue.stueck_rahmen(g, 42), pfeil + Beute.name(g), farbe_von(g), [Beute.kennwert(g)], preis_text(p), func(): stueck(g, kauf), matt)

# ---------------------------------------------------------------- Verkaufen
const ANGELEGT := ["HEAD", "CLOAK", "CHEST", "ARMS", "LEGS", "AMULET", "RING", "MAIN_HAND", "OFF_HAND"]

func verkaufen() -> void:
	var de := de_()
	# 59.2: die neun angelegten Stuecke als Leiste, um auf einen Blick zu sehen, was besser ist
	if not laden.brauen:
		kopfzeile("Angelegt" if de else "Equipped")
		var r := HBoxContainer.new()
		r.alignment = BoxContainer.ALIGNMENT_CENTER
		r.add_theme_constant_override("separation", int(2 * DP))
		var waffe = hw.ding("MAIN_HAND")
		for platz in ANGELEGT:
			var zwei: bool = platz == "OFF_HAND" and waffe is Dictionary and zweihaendig(waffe)
			var g = waffe if zwei else hw.ding(platz)
			var b := Menue.stueck_rahmen(g, 34) if g is Dictionary else Menue.bild_feld("", 34)   # leerer Platz: leeres Feld
			if zwei: b.modulate.a = 0.5
			if g is Dictionary:
				var gg: Dictionary = g
				b.mouse_filter = Control.MOUSE_FILTER_PASS
				tippbar(b, func(): dialog(Beute.name(gg), farbe_von(gg), stueck_zeilen(gg), [["OK", func(): pass]]))
			r.add_child(b)
		inhalt.add_child(r)
		luecke(8)
	# 59.4: zurueckkaufen, was bei diesem Besuch verkauft wurde, zum Erloes
	if not laden.rueckkauf.is_empty():
		kopfzeile(Sprache.t(Laden.ZURUECK))
		for i in laden.rueckkauf.size():
			var s: Dictionary = laden.rueckkauf[i]
			var p := int(s["preis"])
			var g = s.get("ausruestung")
			var bild := Menue.stueck_rahmen(g, 42) if g is Dictionary else Menue.vorrat_bild(String(s.get("ding", "")))
			var nr := i
			reihe(bild, Laden.verkauft_name(s), Color.WHITE if z.gold >= p else Stil.DIM, [], preis_text(p), func(): sage(laden.zurueck(z, nr)); baue())
		luecke(8)
	kopfzeile(Sprache.t(Laden.VORRAETE))
	var verk := z.taschen.keys().filter(func(id): return Laden.verkaeuflich(String(id)))
	if verk.is_empty(): zeile(Sprache.u("nothing"), 14, Stil.DIM)
	for id_ in verk:
		var id := String(id_)
		reihe(Menue.vorrat_bild(id), "%s  ×%d" % [Laden.name(id), z.anzahl(id)], farbe_ding(id), [Sprache.t(Laden.ding(id).get("info", ""))],
			preis_text(Laden.verkaufspreis(hw, id)), func(): menge(id, false, 1))
	if laden.brauen: return
	luecke(8)
	var dinge: Array = z.beutel.duplicate()
	dinge.sort_custom(func(a, b):   # ShopScreen: Seltenheit absteigend, dann Platz
		var ra := Beute.stufe_von(String(a["rarity"])); var rb := Beute.stufe_von(String(b["rarity"]))
		if ra != rb: return ra > rb
		return Beute.PLAETZE.find(String(Beute.grundform(String(a["base"]))["slot"])) < Beute.PLAETZE.find(String(Beute.grundform(String(b["base"]))["slot"])))
	kopfzeile("%s (%d)" % [Sprache.t(Laden.AUSRUESTUNG), dinge.size()])
	var gew := dinge.filter(func(g): return String(g["rarity"]) == "COMMON")
	if not gew.is_empty():
		var b := Erschaffung.knopf(Sprache.t(Laden.GEWOEHNLICHE), func(): alle_gewoehnlichen(gew))
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		b.custom_minimum_size.y = 36 * DP
		inhalt.add_child(b)
	if dinge.is_empty(): zeile(Sprache.u("nothing"), 14, Stil.DIM)
	ware_liste(dinge, false)

func alle_gewoehnlichen(gew: Array) -> void:
	var de := de_()
	var tu := func():
		sage(Sprache.t(Laden.GEWOEHNLICHE_WEG) % laden.verkaufe_gewoehnliches(z, hw))
		baue()
	if not Bedienung.rueckfragen:
		tu.call()
		return
	var summe := 0
	for g in gew: summe += Laden.verkaufspreis_von(hw, g)
	dialog("Alle gewöhnlichen verkaufen?" if de else "Sell all common items?", Stil.GOLD,
		[Erschaffung.txt(("%d Gegenstände:" if de else "%d items:") % gew.size(), 15), Erschaffung.txt(", ".join(PackedStringArray(gew.map(func(g): return Beute.name(g)))), 14, Stil.DIM)],
		[[("Verkaufen · " if de else "Sell · ") + preis_text(summe), tu], [abbrechen(), func(): pass]])

# ---------------------------------------------------------------- Brauen (Morwen)
func brauen() -> void:
	kopfzeile(Sprache.t(Laden.REZEPTE))
	var rz := Laden.rezepte()
	for i in rz.size():
		var r: Dictionary = rz[i]
		var aus := String(r["ergebnis"])
		var ok := Laden.bezahlbar(z, r)
		reihe(Menue.vorrat_bild(aus), Laden.name(aus), farbe_ding(aus) if ok else Stil.DIM, [Laden.kosten(r)], "", func():
			dialog(Laden.name(aus), farbe_ding(aus), [Erschaffung.txt(Sprache.t(Laden.ding(aus).get("info", "")), 15),
				Erschaffung.txt(("Zutaten: " if de_() else "Ingredients: ") + Laden.kosten(r), 15, Stil.DIM if ok else Stil.WARN)],
				[["Brauen" if de_() else "Brew", func(): sage(laden.braue(z, hw, r)); baue(), ok], [abbrechen(), func(): pass]]))

# ---------------------------------------------------------------- Kaesten
# 59.5 supplyDialog: Werte, Menge, Besitz vorher → nachher, Gold vorher → nachher; −, +, ×1, ×5, beim Verkauf Alle; der Preis folgt
func menge(id: String, kauf: bool, n_: int, alle := false) -> void:
	var stueck_ := Laden.kaufpreis(hw, id) if kauf else Laden.verkaufspreis(hw, id)
	var most := Laden.kann_kaufen(z, hw, id) if kauf else z.anzahl(id)
	var n := clampi(n_, 1, maxi(1, most))
	var preis := stueck_ * n
	var zl: Array = [Erschaffung.txt(Sprache.t(Laden.ding(id).get("info", "")), 14, Stil.DIM),
		Erschaffung.txt("%s: %d" % [Sprache.t(Laden.MENGE), n], 16),
		Erschaffung.txt(Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(id), z.anzahl(id) + (n if kauf else -n)], 15, Stil.DIM),
		Erschaffung.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - preis if kauf else z.gold + preis], 15, Stil.DIM if most >= 1 else Stil.WARN)]
	if most < 1: zl.append(Erschaffung.txt(Sprache.u("notEnoughGold") if kauf else Sprache.u("nothing"), 15, Stil.WARN))
	var reihe_ := HBoxContainer.new()
	reihe_.add_theme_constant_override("separation", int(6 * DP))
	var knoepfe := [["−", n - 1, n > 1], ["+", n + 1, n < most], ["×1", 1, most >= 1], ["×5", 5, most >= 5]]
	if not kauf: knoepfe.append([Sprache.t(Laden.ALLE), most, most >= 1])
	var halter := {}   # der Kasten entsteht erst unten; Lambdas fassen Werte beim Anlegen, ein Dictionary aber als Verweis
	for k in knoepfe:
		var nn: int = k[1]
		var ist_alle: bool = String(k[0]) == Sprache.t(Laden.ALLE)
		var b := Erschaffung.knopf(String(k[0]), func(): (halter["kasten"] as Node).queue_free(); menge(id, kauf, nn, ist_alle))
		b.disabled = not bool(k[2])
		reihe_.add_child(b)
	zl.append(reihe_)
	var tu := func():
		if alle and not kauf and n >= 2 and Bedienung.rueckfragen:   # 59e: alles von einem Ding verkaufen fragt noch einmal
			dialog("Alle verkaufen?" if de_() else "Sell all?", farbe_ding(id), [Erschaffung.txt("%s ×%d" % [Laden.name(id), n], 16)],
				[["%s ×%d · %s" % [Sprache.u("sell"), n, preis_text(preis)], func(): sage(laden.verkaufe(z, hw, id, n)); baue()], [abbrechen(), func(): pass]])
			return
		sage(laden.kaufe(z, hw, id, n) if kauf else laden.verkaufe(z, hw, id, n))
		baue()
	halter["kasten"] = dialog(Laden.name(id), farbe_ding(id), zl, [
		["%s%s · %s" % [Sprache.u("buy") if kauf else Sprache.u("sell"), " ×%d" % n if n > 1 else "", preis_text(preis)], tu, most >= 1],
		[abbrechen(), func(): pass]])

# gearDialog: Name, Werte, Gold vorher → nachher, „Kaufen · Preis“ (ohne Gold matt) oder „Verkaufen · Preis“; Seltenes fragt noch einmal
func stueck(g: Dictionary, kauf: bool) -> void:
	var de := de_()
	var p := Laden.kaufpreis_von(hw, g) if kauf else Laden.verkaufspreis_von(hw, g)
	var ok := not kauf or z.gold >= p
	var zl: Array = stueck_zeilen(g)
	zl.append(Erschaffung.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - p if kauf else z.gold + p], 15, Stil.DIM if ok else Stil.WARN))
	if not ok: zl.append(Erschaffung.txt(Sprache.u("notEnoughGold"), 15, Stil.WARN))
	var tu := func():
		if kauf: sage(laden.kaufe_ausruestung(z, hw, g))
		else:
			var i := im_beutel(g)
			if i >= 0: sage(laden.verkaufe_ausruestung(z, hw, i))
		baue()
	var frage := func():
		if kauf or not Bedienung.rueckfragen or Beute.stufe_von(String(g["rarity"])) < Beute.stufe_von("RARE"):
			tu.call()
			return
		dialog("Wirklich verkaufen?" if de else "Really sell?", farbe_von(g),
			[Erschaffung.txt("%s (%s)" % [Beute.name(g), Sprache.t(Heldwerte.lade()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"]))], 15, farbe_von(g))],
			[["%s · %s" % [Sprache.u("sell"), preis_text(p)], tu], [abbrechen(), func(): pass]])
	dialog(Beute.name(g), farbe_von(g), zl, [["%s · %s" % [Sprache.u("buy") if kauf else Sprache.u("sell"), preis_text(p)], frage, ok], [abbrechen(), func(): pass]])

func farbe_ding(id: String) -> Color:
	return Color(SELTEN.get(String(Laden.ding(id).get("seltenheit", "COMMON")), "e6ddcb"))
