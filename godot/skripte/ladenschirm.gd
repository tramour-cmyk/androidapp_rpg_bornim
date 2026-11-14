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

func _init(h: BrsHeld, zu_: Zustand, l: Laden) -> void:
	super(h, zu_)
	laden = l
	name = "Laden"

# 557 (Chef 04.11., 13:44, Gruppe 557: „Brauen 525“ im Stil B, 549a): nur Entwurf, im Spiel weiter „“. B: Kopf ohne Kasten (Name in
# gesperrten Versalien, Gold rechts, Zierlinie), die Seiten als Woerter mit goldenem Strich unter der gewaehlten, die Liste frei auf
# Schwarz; Rezepte als Zeilen zwischen feinen Goldlinien, ueber die ganze Breite antippbar, rechts „Reicht für n×“ und „›“; was nicht
# reicht, matt mit „Fehlt: …“ in Warnfarbe. Der Mengenkasten behaelt seinen Rahmen (549a (3), dort wird entschieden), innen Linien,
# „BRAUEN ×n ›“ als Hauptwahl; Abbrechen ueber Zurueck oder Tippen daneben (526). Unten „‹ SCHLIESSEN“ als Nebenwahl.
static var entwurf_b := "B"   # 557 eingeschaltet (Archiv 05.11., 08:18: „557 wie gebaut“; Runde 5 Vorlage 2 mit Mängelton, Chef 04.11., 19:54)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	Zurueck.melde(self, func(): zu.emit())   # 416.1
	if entwurf_b == "B":
		_ready_b()
		return
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
	spalte.add_child(Stil.rahmen(reihe))
	leiste = HBoxContainer.new()
	leiste.add_theme_constant_override("separation", int(8 * DP))
	spalte.add_child(leiste)
	meldung_ = Stil.txt("", 15, Stil.BRIGHT)   # Menue.meldung (drei Sekunden) bleibt ungenutzt; die Notiz unten bleibt stehen wie alt
	meldung_.visible = false
	spalte.add_child(meldung_)
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var k := Stil.rahmen(rolle)
	k.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(k)
	inhalt = VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", int(4 * DP))
	rolle.add_child(inhalt)
	notiz = Stil.txt("", 15)
	var nk := Stil.rahmen(notiz)
	nk.visible = false
	notiz.set_meta("kasten", nk)
	spalte.add_child(nk)
	spalte.add_child(Stil.knopf(Sprache.u("back"), func(): zu.emit()))   # 618 „Zurück für alles“
	baue()

func sage(t: String) -> void:
	notiz.text = t
	(notiz.get_meta("kasten") as Control).visible = t != ""

func baue() -> void:
	var y := rolle.scroll_vertical
	var de := de_()
	kopf.text = (Sprache.t(Laden.HUETTE) if laden.brauen else Sprache.u("shop")).to_upper()
	gold_.text = "%d %s" % [z.gold, Sprache.u("gold")]   # 557 (Chef 19:54): Gold überall „23 Gold“
	for c in leiste.get_children():
		leiste.remove_child(c)
		c.queue_free()
	var seiten := [["kaufen", Sprache.u("buy")]] if laden.nur_vorraete else [["kaufen", Sprache.u("buy")], ["verkaufen", Sprache.u("sell")]]   # 842 Osric
	if laden.brauen: seiten.append(["brauen", "Brauen" if de else "Brew"])
	for s in seiten:
		var w: String = s[0]
		if entwurf_b == "B": leiste.add_child(_seite_b(String(s[1]), w == seite, func(): seite = w; baue()))
		else: leiste.add_child(Stil.knopf(String(s[1]), func(): seite = w; baue(), w == seite))
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	match seite:
		"brauen": brauen_b() if entwurf_b == "B" else brauen()
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
	for u in unter: sp.add_child(Stil.txt(String(u), 12, Stil.DIM))
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
		var unter := LadenSchirm.kurz(id)   # 582: Kurzangabe wie alt (ShopScreen.kt 244), der Langtext erst im Kasten
		if z.anzahl(id) > 0: unter.append(("Im Besitz: " if de else "Owned: ") + str(z.anzahl(id)))
		reihe(Menue.vorrat_bild(id), Laden.name(id), farbe_ding(id) if z.gold >= p else Stil.DIM, unter, preis_text(p), func(): menge(id, true, 1))
	if laden.brauen or laden.nur_vorraete: return   # Morwen handelt nur mit Kraeutern und Traenken, Osric nur mit Verbänden (842)
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
	# 416.9 (Chef 31.10., 22:20: nicht tragbare extra ausweisen): wie alt das Zeichen (NoEntry) vor der Ueberschrift und auf jedem Bild
	var k := HBoxContainer.new()
	k.add_theme_constant_override("separation", int(6 * DP))
	var zk := LadenSchirm.kein_zeichen(14)
	zk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	k.add_child(zk)
	inhalt.add_child(k)
	var l := zeile(("%s (%d)" % [Sprache.t(Laden.NICHT_TRAGBAR), nicht.size()]).to_upper(), 14, Stil.GOLD)
	l.add_theme_font_override("font", Stil.variante(3.0))
	inhalt.remove_child(l)
	k.add_child(l)
	for g in nicht: stueck_reihe(g, kauf, true)

# 416.9: ShopScreen.NoEntry, ein Ring mit Balken in Warnfarbe auf dunklem Grund, gezeichnet (kein Schriftzeichen)
static func kein_zeichen(dp: float) -> Control:
	var c := Control.new()
	c.set_meta("kein_zeichen", true)   # fuer laden_4169
	c.custom_minimum_size = Vector2(dp, dp) * DP
	c.size = c.custom_minimum_size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func():
		var d := minf(c.size.x, c.size.y)
		var w := d * 0.14
		var m := c.size / 2.0
		c.draw_circle(m, d / 2.0, Color(0, 0, 0, 0.6))
		c.draw_arc(m, d / 2.0 - w / 2.0, 0.0, TAU, 32, Stil.WARN, w, true)
		var o := (d / 2.0 - w) * 0.7071
		c.draw_line(m - Vector2(o, o), m + Vector2(o, o), Stil.WARN, w, true))
	return c

# das Bild mit dem Zeichen unten rechts darueber (alt: 16 dp, versetzt um 28 dp bei 42 dp)
static func mit_zeichen(bild: Control, dp: float) -> Control:
	var h := Control.new()
	h.custom_minimum_size = Vector2(dp, dp) * DP
	h.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bild.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.add_child(bild)
	var zk := kein_zeichen(dp * 16.0 / 42.0)
	zk.position = Vector2(dp, dp) * DP * (28.0 / 42.0)
	h.add_child(zk)
	return h

# 582 (alt GearUi.kt 128–150): unter dem Namen die Listenzeile mit dem Platz („Kopf · RK 1“, Gear.listLine); ▲ gruen, ▼ rot als
# eigenes Zeichen vor dem Preis, nicht in der Farbe des Namens
const AUF := Color("2a8a3a")
func stueck_reihe(g: Dictionary, kauf: bool, matt: bool) -> void:
	var p := Laden.kaufpreis_von(hw, g) if kauf else Laden.verkaufspreis_von(hw, g)
	var u = Vergleich.von(hw, g).urteil() if hw.kann_tragen(g) else null
	var bild := Menue.stueck_rahmen(g, 42)
	if not hw.kann_tragen(g): bild = LadenSchirm.mit_zeichen(bild, 42)
	reihe(bild, Beute.name(g), farbe_von(g), [Beute.listen_zeile(g)], preis_text(p), func(): stueck(g, kauf), matt)
	if u == 1 or u == -1:
		var r := inhalt.get_child(inhalt.get_child_count() - 1) as HBoxContainer
		var pf := Stil.zeile("▲" if u == 1 else "▼", 18, AUF if u == 1 else Stil.WARN)
		pf.name = "Urteil"
		pf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(pf)
		r.move_child(pf, r.get_child_count() - 2)

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
			# 416.9 (Chef 31.10., 22:28: auch die leeren Plaetze): ein leerer Platz ist ein leerer Rahmen wie GearIcon(null), nicht nichts
			var b := Menue.stueck_rahmen(g, 34) if g is Dictionary else LadenSchirm.leer_rahmen(34)
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
			# 525: wie alt (ShopScreen.kt 219) in der Farbe der Seltenheit, ohne Gold matt
			var farbe := (farbe_von(g) if g is Dictionary else farbe_ding(String(s.get("ding", "")))) if z.gold >= p else Stil.DIM
			reihe(bild, Laden.verkauft_name(s), farbe, [], preis_text(p), func(): sage(laden.zurueck(z, nr)); baue())
		luecke(8)
	kopfzeile(Sprache.t(Laden.VORRAETE))
	var verk := z.taschen.keys().filter(func(id): return Laden.verkaeuflich(String(id)))
	if verk.is_empty(): zeile(Sprache.u("nothing"), 14, Stil.DIM)
	for id_ in verk:
		var id := String(id_)
		reihe(Menue.vorrat_bild(id), "%s  ×%d" % [Laden.name(id), z.anzahl(id)], farbe_ding(id), LadenSchirm.kurz(id),
			preis_text(Laden.verkaufspreis(hw, id)), func(): menge(id, false, 1))
	# 491: bei Morwen fehlt nur das Kaufen von Ausruestung; verkaufen geht wie alt (ShopScreen.kt 252 `!(brewing && buying)`)
	luecke(8)
	# 458.2a: Einzelstuecke (Preis 0 im Katalog) erscheinen nicht, wie Handlungsgegenstaende
	var dinge: Array = z.beutel.filter(func(g): return Laden.ausruestung_verkaeuflich(g))
	dinge.sort_custom(func(a, b):   # ShopScreen: Seltenheit absteigend, dann Platz
		var ra := Beute.stufe_von(String(a["rarity"])); var rb := Beute.stufe_von(String(b["rarity"]))
		if ra != rb: return ra > rb
		return Beute.PLAETZE.find(String(Beute.grundform(String(a["base"]))["slot"])) < Beute.PLAETZE.find(String(Beute.grundform(String(b["base"]))["slot"])))
	kopfzeile("%s (%d)" % [Sprache.t(Laden.AUSRUESTUNG), dinge.size()])
	var gew := dinge.filter(func(g): return String(g["rarity"]) == "COMMON")
	if not gew.is_empty():
		var b := Stil.knopf(Sprache.t(Laden.GEWOEHNLICHE), func(): alle_gewoehnlichen(gew))
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		b.clip_text = false   # 503 (Chef 03.11., 07:40): mit clip_text und SHRINK war der Knopf 0 breit, ohne Text
		b.custom_minimum_size.y = 36 * DP
		inhalt.add_child(b)
	if dinge.is_empty(): zeile(Sprache.u("nothing"), 14, Stil.DIM)
	ware_liste(dinge, false)

# GearIcon ohne Stueck: dunkler Grund, Rand Veil.dim zu 35 %
static func leer_rahmen(dp: float) -> Control:
	var p := PanelContainer.new()
	p.set_meta("leer", true)   # fuer laden_4169
	var st := Stil.kasten(Color("0e0c0a"), Color(Stil.DIM, 0.35), 1.0)
	st.set_corner_radius_all(int(3 * DP))
	p.add_theme_stylebox_override("panel", st)
	p.custom_minimum_size = Vector2(dp, dp) * DP
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p

func alle_gewoehnlichen(gew: Array) -> void:
	var de := de_()
	var tu := func():
		sage(Laden.gewoehnliche_text(laden.verkaufe_gewoehnliches(z, hw)))
		baue()
	if not Bedienung.rueckfragen:
		tu.call()
		return
	var summe := 0
	for g in gew: summe += Laden.verkaufspreis_von(hw, g)
	dialog("Alle gewöhnlichen verkaufen?" if de else "Sell all common items?", Stil.GOLD,
		[Stil.zeile(Laden.anzahl_gegenstaende(gew.size(), de).to_upper(), 14, Stil.GOLD, 3.0), Stil.txt(", ".join(PackedStringArray(gew.map(func(g): return Beute.name(g)))), 14, Stil.DIM),
		Stil.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold + summe], 15, Stil.DIM)],   # 525 (Helfer): Gold vorher → nachher
		[[("Verkaufen · " if de else "Sell · ") + preis_text(summe), tu], [abbrechen(), func(): pass]])

# ---------------------------------------------------------------- Brauen (Morwen)
# 525 (Chef 04.11., 00:31: „Kann kenntlich gemacht werden, was für einen Trank fehlt oder sonstige sinnvolle Verbesserungen?“):
# wie alt BrewList (ShopScreen.kt 384–408) je Zutat Bild und „hat/braucht“, Fehlendes und zu wenig Gold in Warnfarbe; dazu
# Nicht-Brauares matt mit „Fehlt: …“, der Bestand des Tranks und wie oft es reicht; der Kraeuterhinweis wie alt unter der Ueberschrift.
func brauen() -> void:
	kopfzeile(Sprache.t(Laden.REZEPTE))
	zeile(Sprache.t(Laden.KRAEUTER), 12, Stil.DIM)
	var rz := Laden.rezepte()
	for i in rz.size():
		var r: Dictionary = rz[i]
		var aus := String(r["ergebnis"])
		var oft := Laden.wie_oft(z, r)
		var rechts := Sprache.t(Laden.REICHT) % oft if oft > 0 else ""
		var p := posten(Laden.name(aus), rechts, farbe_ding(aus) if oft > 0 else Stil.DIM, Menue.vorrat_bild(aus))
		var sp: VBoxContainer = p.get_child(1)
		sp.add_child(zutaten_reihe(r, 18, 12))
		if z.anzahl(aus) > 0: sp.add_child(Stil.txt(Sprache.t(Laden.BESITZ) + str(z.anzahl(aus)), 12, Stil.DIM))
		if oft < 1:
			sp.add_child(Stil.txt(Sprache.t(Laden.FEHLT) + Laden.fehlt(z, r), 12, Spielstaende.mangel()))
			(p.get_child(0) as CanvasItem).modulate.a = 0.5   # Bild matt; der Name ist schon Veil.dim (Helfer 01:28: doppelt gedaempft kaum lesbar)
		p.set_meta("rezept", aus)   # fuer brauen_525
		inhalt.add_child(p)
		tippbar(p, func(): braukasten(r, 1))

# je Zutat Bild und „hat/braucht“, dann das Gold; was fehlt, in Warnfarbe (BrewList)
func zutaten_reihe(r: Dictionary, bild_dp: float, sp: float) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(4 * DP))
	for id_ in r["zutaten"]:
		var id := String(id_)
		var hat := z.anzahl(id)
		var braucht := int(r["zutaten"][id])
		h.add_child(Menue.bild_feld("ding-" + id, bild_dp))
		# 557 (Chef 19:54, Pruefer 19:47: „7/2“ ohne Erklaerung): erst was der Trank braucht, dahinter was da ist („2× (7 da)“)
		var l := Stil.zeile(("%d× (%d da)" if de_() else "%d× (%d owned)") % [braucht, hat], sp, Stil.TEXT if hat >= braucht else Spielstaende.mangel())
		l.set_meta("zutat", id)
		h.add_child(l)
		h.add_child(Stil.luecke(0, 6))
	if int(r["gold"]) > 0:
		var g := Stil.zeile("%d %s" % [int(r["gold"]), Sprache.u("gold")], sp, Stil.TEXT if z.gold >= int(r["gold"]) else Spielstaende.mangel())
		g.set_meta("zutat", "gold")
		h.add_child(g)
	return h

# 525: der Kasten wie alt (Bild, Wirkung, Zutaten) und dazu die Menge wie beim Kaufen: −, Zahl, +, ×1, ×5, „Alle“ (so oft es reicht);
# Bestand und Gold vorher → nachher; „Brauen ×n“
func braukasten(r: Dictionary, n_: int, alle := false) -> void:
	var de := de_()
	var aus := String(r["ergebnis"])
	var oft := Laden.wie_oft(z, r)
	var n := clampi(n_, 1, maxi(1, oft))
	if Spielstaende.vorlage2:   # 630: ohne Kasten wie im Brauen-Schirm (557, braukasten_c)
		braukasten_c(r, n, alle)
		return
	var halter := {}   # der Kasten entsteht erst unten (wie menge)
	var bild := Menue.bild_feld("ding-" + aus, 48)
	bild.name = "DingBild"
	bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var zl: Array = [bild] + LadenSchirm.details(aus) + [
		Stil.txt(("Zutaten je Trank:" if de else "Ingredients per potion:"), 15, Stil.DIM), zutaten_reihe(r, 24, 15)]
	if oft < 1:
		zl.append(Stil.txt(Sprache.t(Laden.FEHLT) + Laden.fehlt(z, r), 15, Spielstaende.mangel()))
	else:
		zl.append(Stil.txt("%s: %d" % [Sprache.t(Laden.MENGE), n], 16))
		var reihe_ := HBoxContainer.new()
		reihe_.add_theme_constant_override("separation", int(6 * DP))
		for k in [["−", n - 1, n > 1, false, false], ["+", n + 1, n < oft, false, false], ["×1", 1, true, not alle and n == 1, false],
				["×5", 5, oft >= 5, not alle and n == 5, false], [Sprache.t(Laden.ALLE), oft, true, alle, true]]:
			var nn: int = k[1]
			var ist_alle: bool = k[4]
			var b := Stil.knopf(String(k[0]), func(): (halter["kasten"] as Node).queue_free(); braukasten(r, nn, ist_alle), bool(k[3]))
			b.disabled = not bool(k[2])
			reihe_.add_child(b)
		zl.append(reihe_)
		zl.append(Stil.txt(Sprache.t(Laden.REICHT) % oft, 15, Stil.DIM))
		zl.append(Stil.txt(Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(aus), z.anzahl(aus) + n], 15, Stil.DIM))
		if int(r["gold"]) > 0:
			zl.append(Stil.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - int(r["gold"]) * n], 15, Stil.DIM))
	var brau := ("Brauen" if de else "Brew") + (" ×%d" % n if n > 1 else "")
	halter["kasten"] = dialog(Laden.name(aus), farbe_ding(aus), zl, [[brau, func(): sage(laden.braue_mehr(z, hw, r, n)); baue(), oft >= 1], [abbrechen(), func(): pass]])

# ---------------------------------------------------------------- Kaesten
# 59.5 supplyDialog: Werte, Menge, Besitz vorher → nachher, Gold vorher → nachher; −, +, ×1, ×5, beim Verkauf Alle; der Preis folgt
func menge(id: String, kauf: bool, n_: int, alle := false) -> void:
	var stueck_ := Laden.kaufpreis(hw, id) if kauf else Laden.verkaufspreis(hw, id)
	var most := Laden.kann_kaufen(z, hw, id) if kauf else z.anzahl(id)
	var n := clampi(n_, 1, maxi(1, most))
	var preis := stueck_ * n
	if Spielstaende.vorlage2:   # 630 (549a Mengenkasten, abgenommen 557 Bild 4): ohne Kasten wie braukasten_c
		menge_c(id, kauf, n, most, alle)
		return
	# 416.9 (Chef 31.10., 22:20): das Bild des Dings im Kasten wie alt (DialogSpec supply, 48 dp), wie beim Stueck ueber den Zeilen
	var bild := Menue.bild_feld("ding-" + id, 48)
	bild.name = "DingBild"
	bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var zl: Array = [bild] + LadenSchirm.details(id) + [
		Stil.txt("%s: %d" % [Sprache.t(Laden.MENGE), n], 16),
		Stil.txt(Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(id), z.anzahl(id) + (n if kauf else -n)], 15, Stil.DIM),
		Stil.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - preis if kauf else z.gold + preis], 15, Stil.DIM if most >= 1 else Spielstaende.mangel())]
	if most < 1: zl.append(Stil.txt(Sprache.u("notEnoughGold") if kauf else Sprache.u("nothing"), 15, Spielstaende.mangel()))
	var reihe_ := HBoxContainer.new()
	reihe_.add_theme_constant_override("separation", int(6 * DP))
	# 525 (ShopScreen.kt 347–349): die gewaehlte Schnellwahl bleibt markiert, „Alle“ als solche, auch wenn es 1 oder 5 sind
	var knoepfe := [["−", n - 1, n > 1, false], ["+", n + 1, n < most, false], ["×1", 1, most >= 1, not alle and n == 1], ["×5", 5, most >= 5, not alle and n == 5]]
	if not kauf: knoepfe.append([Sprache.t(Laden.ALLE), most, most >= 1, alle])
	var halter := {}   # der Kasten entsteht erst unten; Lambdas fassen Werte beim Anlegen, ein Dictionary aber als Verweis
	for k in knoepfe:
		var nn: int = k[1]
		var ist_alle: bool = String(k[0]) == Sprache.t(Laden.ALLE)
		var b := Stil.knopf(String(k[0]), func(): (halter["kasten"] as Node).queue_free(); menge(id, kauf, nn, ist_alle), bool(k[3]))
		b.disabled = not bool(k[2])
		reihe_.add_child(b)
	zl.append(reihe_)
	var tu := func():
		if alle and not kauf and n >= 2 and Bedienung.rueckfragen:   # 59e: alles von einem Ding verkaufen fragt noch einmal
			dialog("Alle verkaufen?" if de_() else "Sell all?", farbe_ding(id), [Menue.bild_feld("ding-" + id, 48), Stil.txt("%s ×%d" % [Laden.name(id), n], 16)],
				[["%s ×%d · %s" % [Sprache.u("sell"), n, preis_text(preis)], func(): sage(laden.verkaufe(z, hw, id, n)); baue()], [abbrechen(), func(): pass]])
			return
		sage(laden.kaufe(z, hw, id, n) if kauf else laden.verkaufe(z, hw, id, n))
		baue()
	halter["kasten"] = dialog(Laden.name(id), farbe_ding(id), zl, [
		["%s%s · %s" % [Sprache.u("buy") if kauf else Sprache.u("sell"), " ×%d" % n if n > 1 else "", preis_text(preis)], tu, most >= 1],
		[abbrechen(), func(): pass]])

# 630 (549a „Ausnahme Mengenkasten“, 557 Bild 4; supplyDialog alt): Kopf mit Bild und Name, Zierlinie, Seltenheit, Kurzangabe und Text;
# die Menge gross in der Mitte „−  3  +“, darunter ×1 · ×5 (beim Verkauf · ALLE) als Woerter, die gewaehlte hell mit Goldstrich;
# Besitz und Gold vorher → nachher als kleine Angaben; unten „‹ ABBRECHEN“ links, „KAUFEN ×3 · 36 GOLD ›“ rechts
func menge_c(id: String, kauf: bool, n: int, most: int, alle := false) -> void:
	var de := de_()
	var preis := (Laden.kaufpreis(hw, id) if kauf else Laden.verkaufspreis(hw, id)) * n
	var schleier := Rueckfrage.schleier(self)
	schleier.color = Color.BLACK
	var mitte := Spielstaende.oben()
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.name = "Fenster"
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Rueckfrage.halte(v))
	var kopf_ := HBoxContainer.new()
	kopf_.add_theme_constant_override("separation", int(12 * DP))
	var bild := Menue.bild_feld("ding-" + id, 48)
	bild.name = "DingBild"
	kopf_.add_child(bild)
	var nm := Stil.zeile(Laden.name(id), 16, farbe_ding(id))
	nm.name = "Titel"
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kopf_.add_child(nm)
	v.add_child(kopf_)
	v.add_child(Spielstaende.zier())
	for c in LadenSchirm.details(id): v.add_child(c)
	if most < 1:
		v.add_child(Stil.txt(Sprache.u("notEnoughGold") if kauf else Sprache.u("nothing"), 15, Spielstaende.mangel()))
	else:
		var neu_ := func(nn: int, ist_alle: bool): schleier.queue_free(); menge(id, kauf, nn, ist_alle)
		var mr := HBoxContainer.new()
		mr.alignment = BoxContainer.ALIGNMENT_CENTER
		mr.add_theme_constant_override("separation", int(10 * DP))
		mr.add_child(_zahl_knopf("−", func(): neu_.call(n - 1, false), n > 1))
		var zahl := Stil.zeile(str(n), 34, Stil.BRIGHT)
		zahl.name = "Menge"
		zahl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		zahl.custom_minimum_size.x = 64 * DP
		zahl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mr.add_child(zahl)
		mr.add_child(_zahl_knopf("+", func(): neu_.call(n + 1, false), n < most))
		v.add_child(mr)
		var wahl := [["×1", 1, not alle and n == 1, true, false], ["×5", 5, not alle and n == 5, most >= 5, false]]
		if not kauf: wahl.append([Sprache.t(Laden.ALLE), most, alle, true, true])   # 525: „Alle“ bleibt markiert, auch bei 1 oder 5
		var wr := HBoxContainer.new()
		wr.add_theme_constant_override("separation", 0)
		for k in wahl:
			var nn: int = k[1]
			var ia: bool = k[4]
			wr.add_child(_seite_b(String(k[0]), bool(k[2]), (func(): neu_.call(nn, ia)) if bool(k[3]) else func(): pass, bool(k[3])))
		v.add_child(wr)
		v.add_child(Stil.txt(Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(id), z.anzahl(id) + (n if kauf else -n)], 14, Spielstaende.ANGABE))
		v.add_child(Stil.txt("%d %s → %d %s" % [z.gold, Sprache.u("gold"), z.gold - preis if kauf else z.gold + preis, Sprache.u("gold")], 14, Spielstaende.ANGABE))
	v.add_child(Spielstaende.linie())
	var tu := func():
		if alle and not kauf and n >= 2 and Bedienung.rueckfragen:   # 59e: alles von einem Ding verkaufen fragt noch einmal
			dialog("Alle verkaufen?" if de else "Sell all?", farbe_ding(id), [Menue.bild_feld("ding-" + id, 48), Stil.txt("%s ×%d" % [Laden.name(id), n], 16)],
				[["%s ×%d · %s" % [Sprache.u("sell"), n, preis_text(preis)], func(): sage(laden.verkaufe(z, hw, id, n)); baue()], [abbrechen(), func(): pass]])
			return
		sage(laden.kaufe(z, hw, id, n) if kauf else laden.verkaufe(z, hw, id, n))
		baue()
	var wort := "%s%s · %s" % [Sprache.u("buy") if kauf else Sprache.u("sell"), " ×%d" % n if n > 1 else "", preis_text(preis)]
	var fuss := Spielstaende.fuss(func(): schleier.queue_free(), "", wort, Stil.BRIGHT, func(): schleier.queue_free(); tu.call(), most >= 1)
	for p in fuss.find_children("Text", "Label", true, false):
		Menue.passe_knopf(p.get_parent().get_parent() as Control, (v.custom_minimum_size.x - 8 * DP) / 2.0)
	v.add_child(fuss)

# gearDialog: Name, Werte, Gold vorher → nachher, „Kaufen · Preis“ (ohne Gold matt) oder „Verkaufen · Preis“; Seltenes fragt noch einmal
func stueck(g: Dictionary, kauf: bool) -> void:
	var de := de_()
	var p := Laden.kaufpreis_von(hw, g) if kauf else Laden.verkaufspreis_von(hw, g)
	var ok := not kauf or z.gold >= p
	var zl: Array = stueck_zeilen(g)
	zl.append(Stil.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - p if kauf else z.gold + p], 15, Stil.DIM if ok else Spielstaende.mangel()))
	if not ok: zl.append(Stil.txt(Sprache.u("notEnoughGold"), 15, Spielstaende.mangel()))
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
			[Stil.txt("%s (%s)" % [Beute.name(g), Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"]))], 15, farbe_von(g))],
			[["%s · %s" % [Sprache.u("sell"), preis_text(p)], tu], [abbrechen(), func(): pass]])
	dialog(Beute.name(g), farbe_von(g), zl, [["%s · %s" % [Sprache.u("buy") if kauf else Sprache.u("sell"), preis_text(p)], frage, ok], [abbrechen(), func(): pass]])

# 582: Kurzangabe als Unterzeile. 944 (Chef 11.11., 13:22, t276.5): „kurz“ kommt aus ItemDef.stats (core) und ist immer ein
# Würfeltext („heilt 2W4+2“); Texte ohne Würfel, die Wirkung steht in der Meldung (STORY-BRS-OBERFLAECHE „Gegenstände“)
static func kurz(_id: String) -> Array:
	return []

# 582: Dialogs.ItemDetails: Seltenheit in ihrer Farbe, die Wirkung hell, dann der Langtext
static func details(id: String) -> Array:
	var d := Laden.ding(id)
	var s := String(d.get("seltenheit", "COMMON"))
	var sel: Dictionary = BrsHeld.daten()["seltenheiten"].get(s, {})
	var r: Array = [Stil.txt(Sprache.t(sel.get("name", s)), 14, Color(Menue.SELTEN.get(s, "e6ddcb")))]
	# 944: ohne die Kurzangabe aus core (Würfeltext)
	r.append(Stil.txt(Sprache.t(d.get("info", "")), 14, Stil.DIM))
	return r

func farbe_ding(id: String) -> Color:
	return Color(SELTEN.get(String(Laden.ding(id).get("seltenheit", "COMMON")), "e6ddcb"))

# ---------------------------------------------------------------- 557 Entwurf B
func _ready_b() -> void:
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for sd in ["left", "right"]: rand.add_theme_constant_override("margin_" + sd, int(20 * DP))
	rand.add_theme_constant_override("margin_top", int((Spielstaende.OBEN_DP if Spielstaende.vorlage2 else 28.0) * DP)); rand.add_theme_constant_override("margin_bottom", int(12 * DP))   # 557a B: Titel wie jeder Schirm
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	rand.add_child(spalte)
	# 557 (Chef 19:54, Pruefer 19:47: „MORWENS HÜTTE kleiner und linksbündig“): Titel wie die anderen Schirme (Spielstaende: 22 sp,
	# mittig, darunter die Zierlinie); das Gold rechts unter der Linie
	kopf = Stil.zeile("", 22, Stil.GOLD, 3.0)
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spalte.add_child(kopf)
	spalte.add_child(Stil.luecke(6))
	spalte.add_child(Spielstaende.zier())
	gold_ = Stil.zeile("", 15, Stil.BRIGHT)
	gold_.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	spalte.add_child(gold_)
	spalte.add_child(Stil.luecke(4))
	leiste = HBoxContainer.new()
	leiste.add_theme_constant_override("separation", 0)
	spalte.add_child(leiste)
	spalte.add_child(Spielstaende.linie())
	meldung_ = Stil.txt("", 15, Stil.BRIGHT)
	meldung_.visible = false
	spalte.add_child(meldung_)
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	inhalt = VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", 0)
	rolle.add_child(inhalt)
	notiz = Stil.txt("", 15, Stil.BRIGHT)   # die letzte Meldung, ohne Kasten, zwischen Linien
	var nk := VBoxContainer.new()
	nk.add_child(Spielstaende.linie())
	nk.add_child(Stil.luecke(8))
	nk.add_child(notiz)
	nk.add_child(Stil.luecke(8))
	nk.visible = false
	notiz.set_meta("kasten", nk)
	spalte.add_child(nk)
	spalte.add_child(Spielstaende.linie())
	if Spielstaende.vorlage2:   # 557 Runde 4 (Chef 17:40: „Bei 9 steht Schließen, steht aber mittig“): „‹ SCHLIESSEN“ links, gleich gross
		spalte.add_child(Spielstaende.knopfzeile(Spielstaende.knopf("neben", Sprache.u("back"), func(): zu.emit(), true), null))
	else:
		var sch := Spielstaende.nebenwahl("", "‹  " + Sprache.u("back"), func(): zu.emit())   # 618
		sch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spalte.add_child(sch)
	if Spielstaende.vorlage2: Spielstaende.folge_inhalt(spalte, rolle, inhalt)   # 557 Vorlage 2: Schliessen folgt der Liste (Chef 14:21, Bild 7)
	baue()

# eine Seite als Wort; die gewaehlte hell mit goldenem Strich darunter, die anderen gedaempft; Flaeche 48 dp
func _seite_b(t: String, an: bool, tat: Callable, waehlbar := true) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(6 * DP))
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.custom_minimum_size.y = 48 * DP
	v.alignment = BoxContainer.ALIGNMENT_END
	# Zu 557 (8) (Pruefer 16:43: ×1 · ×5 · ALLE kaum lesbar): die nicht gewaehlten in hellerem Gold, die gewaehlte hell mit Strich
	var l := Stil.zeile(t.to_upper(), 14, Stil.BRIGHT if an else (Color("cdb88c") if Spielstaende.vorlage2 else Stil.GOLD), 2.0)
	if not waehlbar: l.add_theme_color_override("font_color", AUS)   # Pruefer 17:12: „×5“ bei 3 Traenken fast unsichtbar
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l)
	var strich := ColorRect.new()
	strich.color = Stil.BRIGHT if an else Color(0, 0, 0, 0)
	strich.custom_minimum_size.y = maxf(2.0, round(2 * DP))
	strich.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(strich)
	var p := Spielstaende.tippbar(v, tat)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.set_meta("gewaehlt", an); p.set_meta("an", waehlbar)   # 630: fuer Tests
	return p

func brauen_b() -> void:
	var de := de_()
	inhalt.add_child(Stil.luecke(12))
	var h := Stil.zeile(Sprache.t(Laden.REZEPTE).to_upper(), 14 if Spielstaende.vorlage2 else 13, Stil.GOLD, 3.0 if Spielstaende.vorlage2 else 2.5)   # 557 Runde 5: Zwischenüberschrift 14 sp (549a)
	inhalt.add_child(h)
	inhalt.add_child(Stil.luecke(4))
	var kr := Stil.txt(Sprache.t(Laden.KRAEUTER), 13, Stil.DIM)
	kr.add_theme_font_override("font", Stil.variante(0.0, true))
	inhalt.add_child(kr)
	inhalt.add_child(Stil.luecke(10))
	var rz := Laden.rezepte()
	for i in rz.size():
		var r: Dictionary = rz[i]
		inhalt.add_child(Spielstaende.linie())
		var aus := String(r["ergebnis"])
		var oft := Laden.wie_oft(z, r)
		var zeile_ := HBoxContainer.new()
		zeile_.add_theme_constant_override("separation", int(12 * DP))
		zeile_.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bild := Menue.vorrat_bild(aus)
		if oft < 1: bild.modulate.a = 0.5
		zeile_.add_child(bild)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", int(3 * DP))
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(Stil.zeile(Laden.name(aus), 16, farbe_ding(aus) if oft > 0 else Stil.DIM))
		v.add_child(zutaten_reihe(r, 20, 13))
		if z.anzahl(aus) > 0: v.add_child(Stil.zeile(Sprache.t(Laden.BESITZ) + str(z.anzahl(aus)), 13.5 if Spielstaende.vorlage2 else 13.0, Spielstaende.ANGABE if Spielstaende.vorlage2 else Stil.DIM))   # Zu 557 (8)
		if oft < 1:
			var f := Stil.txt(Sprache.t(Laden.FEHLT) + Laden.fehlt(z, r), 13, Spielstaende.mangel())
			f.custom_minimum_size.x = 60 * DP
			v.add_child(f)
		# 557 Runde 5 (Prüfer 18:21, Bild 9: Zeilen verschieden hoch): jede Rezeptzeile hat die dritte Zeile, ohne „Im Besitz“ und
		# „Fehlt“ leer, so stehen alle gleich hoch
		if Spielstaende.vorlage2 and z.anzahl(aus) <= 0 and oft >= 1:
			var leer := Stil.zeile(" ", 13.5, Color(0, 0, 0, 0))
			v.add_child(leer)
		zeile_.add_child(v)
		if oft > 0:
			var re := Stil.zeile(Sprache.t(Laden.REICHT) % oft, 13.5 if Spielstaende.vorlage2 else 13.0, Stil.BRIGHT if Spielstaende.vorlage2 else Stil.GOLD)   # Zu 557 (8)
			re.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			zeile_.add_child(re)
		var pf := Spielstaende.wahl_b("", Stil.BRIGHT if oft > 0 else Color(Stil.DIM, 0.6))
		zeile_.add_child(pf)
		var rand := MarginContainer.new()
		rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rand.add_theme_constant_override("margin_top", int(10 * DP)); rand.add_theme_constant_override("margin_bottom", int(10 * DP))
		rand.add_child(zeile_)
		var t := Spielstaende.tippbar(rand, func(): braukasten_b(r, 1))
		t.set_meta("rezept", aus)
		inhalt.add_child(t)
	if not Spielstaende.vorlage2: inhalt.add_child(Spielstaende.linie())   # Pruefer 16:40: mit dem Knopf am Inhalt lagen zwei Linien aufeinander

# der Mengenkasten: Rahmen bleibt (Entscheidung), innen Bild und Name, Wirkung, Zutaten, Menge mit −, +, ×1, ×5, Alle; vorher → nachher;
# unten „BRAUEN ×n ›“ als Hauptwahl
func braukasten_b(r: Dictionary, n_: int, alle := false) -> void:
	var de := de_()
	var aus := String(r["ergebnis"])
	var oft := Laden.wie_oft(z, r)
	var n := clampi(n_, 1, maxi(1, oft))
	if Spielstaende.vorlage2:
		braukasten_c(r, n, alle)
		return
	var schleier := Rueckfrage.schleier(self)
	schleier.color = Color(0, 0, 0, 0.86)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 2 * 16 * DP - 2 * 14 * DP
	mitte.add_child(Rueckfrage.halte(Stil.rahmen(v)))
	var kopf_ := HBoxContainer.new()
	kopf_.add_theme_constant_override("separation", int(12 * DP))
	var bild := Menue.bild_feld("ding-" + aus, 48)
	bild.name = "DingBild"
	kopf_.add_child(bild)
	var nm := Stil.zeile(Laden.name(aus), 19, farbe_ding(aus))
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kopf_.add_child(nm)
	v.add_child(kopf_)
	v.add_child(Stil.txt(Sprache.t(Laden.ding(aus).get("info", "")), 15 if Spielstaende.vorlage2 else 14, Stil.TEXT if Spielstaende.vorlage2 else Stil.DIM))   # 557 Runde 5: Fließtext 15 sp
	v.add_child(Spielstaende.linie())
	v.add_child(Stil.zeile(("Zutaten je Trank" if de else "Ingredients per potion").to_upper(), 14 if Spielstaende.vorlage2 else 13, Stil.GOLD, 3.0 if Spielstaende.vorlage2 else 2.0))
	v.add_child(zutaten_reihe(r, 24, 15))
	v.add_child(Spielstaende.linie())
	if oft < 1:
		v.add_child(Stil.txt(Sprache.t(Laden.FEHLT) + Laden.fehlt(z, r), 15, Spielstaende.mangel()))
	else:
		var mr := HBoxContainer.new()
		mr.add_theme_constant_override("separation", int(6 * DP))
		var ml := Stil.zeile(("%s  %d" % [Sprache.t(Laden.MENGE).to_upper(), n]), 15, Stil.TEXT, 2.0)
		ml.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ml.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mr.add_child(ml)
		mr.add_child(Stil.zeile(Sprache.t(Laden.REICHT) % oft, 13, Stil.GOLD))
		v.add_child(mr)
		var reihe_ := HBoxContainer.new()
		reihe_.add_theme_constant_override("separation", int(6 * DP))
		for k in [["−", n - 1, n > 1, false, false], ["+", n + 1, n < oft, false, false], ["×1", 1, true, not alle and n == 1, false],
				["×5", 5, oft >= 5, not alle and n == 5, false], [Sprache.t(Laden.ALLE), oft, true, alle, true]]:
			var nn: int = k[1]
			var ist_alle: bool = k[4]
			var b := Stil.knopf(String(k[0]), func(): schleier.queue_free(); braukasten_b(r, nn, ist_alle), bool(k[3]))
			b.disabled = not bool(k[2])
			reihe_.add_child(b)
		v.add_child(reihe_)
		v.add_child(Stil.txt(Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(aus), z.anzahl(aus) + n], 14, Stil.DIM))
		if int(r["gold"]) > 0:
			v.add_child(Stil.txt("%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - int(r["gold"]) * n], 14, Stil.DIM))
	v.add_child(Spielstaende.linie())
	var brau := ("Brauen" if de else "Brew") + (" ×%d" % n if n > 1 else "")
	var hw_ := Spielstaende.hauptwahl(brau, func(): schleier.queue_free(); sage(laden.braue_mehr(z, hw, r, n)); baue(), oft >= 1)
	v.add_child(hw_)

# 557 Vorlage 2 (Chef 14:25–14:26, Bild 8: „designtechnisch komisch … vor allem fehlt … das Abbrechen“; Sokrates (2)): der Mengenkasten
# ohne Rahmen wie die Rueckfrage: fast schwarzer Grund, Kopf mit Bild und Name zwischen zwei Goldlinien; die Menge gross in der Mitte
# „−  3  +“ mit grossen Tippflaechen ohne eigene Rahmen; darunter ×1 · ×5 · ALLE als Woerter, die gewaehlte hell mit Goldstrich wie die
# Seiten; Bestand und Gold vorher → nachher als zwei Zeilen; unten „‹ ABBRECHEN“ links, „BRAUEN ×3 ›“ rechts
func braukasten_c(r: Dictionary, n: int, alle := false) -> void:
	var de := de_()
	var aus := String(r["ergebnis"])
	var oft := Laden.wie_oft(z, r)
	var schleier := Rueckfrage.schleier(self)
	schleier.color = Color.BLACK   # Pruefer 16:40: die Rezepte schienen durch
	var mitte := Spielstaende.oben()   # 557a B: oben wie jeder Schirm
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Rueckfrage.halte(v))
	var kopf_ := HBoxContainer.new()
	kopf_.add_theme_constant_override("separation", int(12 * DP))
	var bild := Menue.bild_feld("ding-" + aus, 48)
	bild.name = "DingBild"
	kopf_.add_child(bild)
	var nv := VBoxContainer.new()
	nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var nm := Stil.zeile(Laden.name(aus), 19, farbe_ding(aus))
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nv.add_child(nm)
	nv.add_child(Stil.txt(Sprache.t(Laden.ding(aus).get("info", "")), 13, Stil.DIM))
	kopf_.add_child(nv)
	v.add_child(kopf_)
	v.add_child(Spielstaende.zier())   # Chef 16:51 (549a (8)): Kopf zuerst, darunter genau eine Zierlinie, keine zweite schlichte
	v.add_child(Stil.zeile(("Zutaten je Trank" if de else "Ingredients per potion").to_upper(), 14 if Spielstaende.vorlage2 else 13, Stil.GOLD, 3.0 if Spielstaende.vorlage2 else 2.0))   # Pruefer 16:40: „7/2“ ohne Ueberschrift
	v.add_child(zutaten_reihe(r, 24, 15))
	if oft < 1:
		v.add_child(Stil.txt(Sprache.t(Laden.FEHLT) + Laden.fehlt(z, r), 15, Spielstaende.mangel()))
	else:
		var neu_ := func(nn: int, ist_alle: bool): schleier.queue_free(); braukasten_c(r, clampi(nn, 1, oft), ist_alle)
		var mr := HBoxContainer.new()
		mr.alignment = BoxContainer.ALIGNMENT_CENTER
		mr.add_theme_constant_override("separation", int(10 * DP))
		mr.add_child(_zahl_knopf("−", func(): neu_.call(n - 1, false), n > 1))
		var zahl := Stil.zeile(str(n), 34, Stil.BRIGHT)
		zahl.name = "Menge"
		zahl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		zahl.custom_minimum_size.x = 64 * DP
		zahl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mr.add_child(zahl)
		mr.add_child(_zahl_knopf("+", func(): neu_.call(n + 1, false), n < oft))
		v.add_child(mr)
		var wr := HBoxContainer.new()
		wr.add_theme_constant_override("separation", 0)
		for k in [["×1", 1, not alle and n == 1, true, false], ["×5", 5, not alle and n == 5, oft >= 5, false], [Sprache.t(Laden.ALLE), oft, alle, true, true]]:
			var nn: int = k[1]
			var ia: bool = k[4]
			wr.add_child(_seite_b(String(k[0]), bool(k[2]), (func(): neu_.call(nn, ia)) if bool(k[3]) else func(): pass, bool(k[3])))
		v.add_child(wr)
		v.add_child(Stil.zeile(Sprache.t(Laden.REICHT) % oft, 13.5, Stil.BRIGHT))   # Zu 557 (8): kleine Angaben heller
		v.add_child(Stil.txt(Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(aus), z.anzahl(aus) + n], 14, Spielstaende.ANGABE))
		if int(r["gold"]) > 0:
			v.add_child(Stil.txt("%d %s → %d %s" % [z.gold, Sprache.u("gold"), z.gold - int(r["gold"]) * n, Sprache.u("gold")], 14, Spielstaende.ANGABE))
	v.add_child(Spielstaende.linie())
	var brau := ("Brauen" if de else "Brew") + (" ×%d" % n if n > 1 else "")
	v.add_child(Spielstaende.fuss(func(): schleier.queue_free(), "", brau, Stil.BRIGHT, func(): schleier.queue_free(); sage(laden.braue_mehr(z, hw, r, n)); baue(), oft >= 1))

# 557 Runde 4 (Pruefer 17:12): was gerade nicht zu waehlen ist (×5 bei 3 Traenken, „+“ am Hoechstwert), lesbar gedaempft in Veil.dim
# ohne Durchsicht statt fast unsichtbar; was zu waehlen ist, gleich hell („−“ und „+“ beide hell)
const AUS := Stil.DIM

# grosse Tippflaeche fuer − und + ohne eigenen Rahmen (56 dp), aus: gedaempft (AUS)
func _zahl_knopf(t: String, tat: Callable, an: bool) -> Control:
	var l := Stil.zeile(t, 30, Stil.BRIGHT if an else AUS)   # Zu 557 (8) (Pruefer 16:43: „+“ kaum zu sehen; 17:12: am Hoechstwert blasser als „−“)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(56, 56) * DP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := Spielstaende.tippbar(l, tat if an else func(): pass)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.set_meta("an", an)   # 630: fuer Tests
	return p
