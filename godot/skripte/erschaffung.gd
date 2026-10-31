class_name Erschaffung
extends Control
# 399.1 Erschaffung wie im alten Spiel (Chef 28.10., 14:38: „Einfach mal das alte Spiel nehmen … so soll es im neuen halt auch schon“;
# 14:39 „an die Designvorgaben halten“): eine Seite wie CreateScreen.kt im schwarzen Look (LocalVeil): oben fest der Held, der sich
# dreht, daneben Name, Volk, Klasse, TP, RK, ZP und die sechs Werte; darunter rollend Name, Volk mit Beschreibung, Bonus und Merkmal,
# Klasse mit Beschreibung, Trefferwuerfel, Hauptattribut, Ruestung und den Faehigkeiten der Stufe 1, dann der Punktekauf mit
# Vorschlag; unten fest Zurueck und Abenteuer beginnen. Masse in dp/sp wie alt (Theme.kt Txt, VeilHead, Panel, PixelButton).
# 376.1 Aussehen wie alt nach dem Volk: Haut und Haar als Farbtoene des Volks (Appearance.kt), dazu Gesicht, Frisur, Bart des
# Kaufkopfs (HeldFigur); der Held im Drehteller zeigt seine Klasse mit Grundausruestung. Noch nicht wie alt: Geschlecht, Statur.
# Ende: Signal fertig({"name", "volk", "klasse", "werte", "aussehen", "platz"}) oder zurueck.

signal fertig(wahl: Dictionary)
signal zurueck

const VOELKER := ["HUMAN", "ELF", "DWARF", "HALFLING", "HALF_ORC"]
const KLASSEN := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]
const DP := AktionsKnopf.DP

var name_ := ""
var volk := "HUMAN"
var klasse := "FIGHTER"
var ziel := 0                         # Platz aus den Spielstaenden („Neues Spiel“ bei einem leeren), sonst der erste freie
var gekauft := {}                     # Punktekauf vor dem Volksbonus (Hero.suggestedScores, dann + und −)
var rolle: ScrollContainer
var inhalt: VBoxContainer
var kopf: VBoxContainer               # Zusammenfassung neben dem Helden
var aussehen := HeldFigur.vorgabe("FIGHTER")   # 376.1; Beispielkopf der Klasse (Chef 28.10., 23:0x), bis der Spieler selbst waehlt
var aussehen_eigen := false
var teller: Drehteller
var teller_wahl := ""                 # zuletzt gezeigte Wahl (Punktekauf baut die Seite neu, den Helden nicht)

func _init() -> void:
	name = "Erschaffung"

func _process(dt: float) -> void: Messung.bild(dt, "Erschaffung")   # 416.1: laengste Bildpause auch hier

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	name_ = Sprache.u("defaultName")
	gekauft = Heldwerte.vorschlag(klasse)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(12 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(10 * DP))
	rand.add_child(spalte)
	# oben fest: der Held und was er ist
	var oben := HBoxContainer.new()
	oben.add_theme_constant_override("separation", int(12 * DP))
	oben.alignment = BoxContainer.ALIGNMENT_BEGIN
	spalte.add_child(kasten(oben))
	oben.add_child(vorschau())
	kopf = VBoxContainer.new()
	kopf.add_theme_constant_override("separation", 0)
	kopf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kopf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	oben.add_child(kopf)
	# Mitte rollt
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER   # wie alt ohne Balken (Helfer: grauer Balken klebte am Goldrand)
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	inhalt = VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", int(10 * DP))
	rolle.add_child(inhalt)
	# unten fest: Zurueck (1) und Abenteuer beginnen (2)
	var unten := HBoxContainer.new()
	unten.add_theme_constant_override("separation", int(10 * DP))
	spalte.add_child(unten)
	var z := knopf(Sprache.u("back"), func(): zurueck.emit())
	z.size_flags_stretch_ratio = 1.0
	unten.add_child(z)
	var los := knopf(Sprache.u("start"), beginne)
	los.size_flags_stretch_ratio = 2.0
	unten.add_child(los)
	baue()

# ---------------------------------------------------------------- Aufbau

func baue() -> void:
	var y := rolle.scroll_vertical
	var t0 := Time.get_ticks_usec()   # 416.1 (Chef: Tasten reagieren schlecht): Dauer des Neuaufbaus je Tipp, unter „Gerät“ (Ladezeit)
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	var d := Heldwerte.lade()
	kopf_neu()
	inhalt.add_child(kopfzeile(Sprache.u("yourName")))
	inhalt.add_child(namensfeld())
	inhalt.add_child(kopfzeile(Sprache.u("chooseRace")))
	inhalt.add_child(wahl(VOELKER, volk, func(v): return Sprache.t(d["voelker"][v]["name"]), func(v): volk = v; aussehen["haut"] = int(HeldFigur.vorgabe(klasse)["haut"]); aussehen["haarfarbe"] = int(HeldFigur.vorgabe(klasse)["haarfarbe"]); baue()))
	var vk := VBoxContainer.new()
	vk.add_theme_constant_override("separation", 0)
	var vd: Dictionary = d["voelker"][volk]
	vk.add_child(txt(Sprache.t(vd["text"]), 15))
	vk.add_child(luecke(4))
	var bon := []
	for a in Heldwerte.ATTRIBUTE:
		if vd["bonus"].has(a): bon.append("%s %s" % [kurz(a), vorzeichen(int(vd["bonus"][a]))])
	vk.add_child(txt("  ".join(PackedStringArray(bon)), 15))
	vk.add_child(txt(Sprache.t(vd["merkmal"]), 15, Stil.GOLD))
	inhalt.add_child(kasten(vk))
	if HeldFigur.da(klasse): aussehen_wahl()
	inhalt.add_child(kopfzeile(Sprache.u("chooseClass")))
	inhalt.add_child(wahl(KLASSEN, klasse, func(k): return Sprache.t(d["klassen"][k]["name"]), klasse_waehlen))
	var kk := VBoxContainer.new()
	kk.add_theme_constant_override("separation", 0)
	var kd: Dictionary = d["klassen"][klasse]
	kk.add_child(txt(Sprache.t(kd["text"]), 15))
	kk.add_child(luecke(4))
	kk.add_child(txt("%s: %s%d · %s: %s" % [Sprache.u("hitDie"), "W" if Sprache.aktiv() == "de" else "d", int(kd["trefferwuerfel"]), Sprache.u("primary"),
		Sprache.t(d["attribute"][String(kd["haupt"])]["name"])], 15))
	var ru: Array = (kd["ruestung"] as Array).map(func(r): return Sprache.t(d["ruestungsarten"][String(r)]))
	kk.add_child(txt("%s: %s%s" % [Sprache.u("armorProf"), "—" if ru.is_empty() else ", ".join(PackedStringArray(ru)),
		(" + " + Sprache.t(Heldwerte.grundform("shield"))) if bool(kd["schilde"]) else ""], 15))
	kk.add_child(luecke(6))
	for f in d["faehigkeiten"]:
		var fd: Dictionary = d["faehigkeiten"][f]
		if String(fd["klasse"]) != klasse or int(fd["stufe"]) != 1 or bool(fd.get("mars", false)): continue
		kk.add_child(txt("• " + Sprache.t(fd["name"]), 15))
		kk.add_child(txt(Sprache.t(fd["text"]), 14, Stil.DIM))
	inhalt.add_child(kasten(kk))
	punktekauf()
	zeige_held()
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	Messung.geladen("Erschaffung Tipp", maxf(ms, float(Messung.laden.get("Erschaffung Tipp", 0.0))))
	# die Rolle bleibt, wo sie war (sonst springt sie bei jeder Wahl nach oben)
	await get_tree().process_frame
	rolle.scroll_vertical = y

# Abenteuer beginnen: in den gewaehlten oder den ersten freien Platz; sind alle belegt, waehlt der Spieler, wen der Neue ersetzt (alt)
func beginne(p: int = 0) -> void:
	if p == 0: p = ziel if ziel > 0 else Spielstand.frei()
	if p == 0:
		platzwahl()
		return
	fertig.emit({"name": name_.strip_edges() if name_.strip_edges() != "" else Sprache.u("defaultName"),
		"volk": volk, "klasse": klasse, "werte": gekauft.duplicate(), "aussehen": aussehen.duplicate(), "platz": p})

# SlotChooser: alle Plaetze belegt; der gewaehlte Spielstand geht verloren
func platzwahl() -> void:
	var de := Sprache.aktiv() == "de"
	var schleier := ColorRect.new()
	schleier.color = Color(0, 0, 0, 0.82)
	schleier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: schleier.queue_free())
	add_child(schleier)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(16 * DP))
	rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schleier.add_child(rand)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	var k := kasten(v)
	k.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rand.add_child(k)
	v.add_child(txt("Alle Spielstand-Plätze sind belegt" if de else "All save slots are taken", 19))
	v.add_child(txt("Welchen Helden soll der neue ersetzen? Der gewählte Spielstand geht dabei verloren." if de
		else "Which hero should the new one replace? That saved game will be lost.", 14, Stil.WARN))
	for d in Spielstand.liste():
		if d.is_empty(): continue
		var n := int(d["platz"])
		var karte := Spielstaende.karte(d)   # antippen waehlt
		karte.mouse_filter = Control.MOUSE_FILTER_STOP
		karte.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: schleier.queue_free(); beginne(n))
		v.add_child(karte)
	v.add_child(knopf("Abbrechen" if de else "Cancel", func(): schleier.queue_free()))

func held() -> Heldwerte:
	return Heldwerte.erschaffe(name_ if name_.strip_edges() != "" else "?", volk, klasse, gekauft)

# HeroSummary: Name, Volk · Klasse · Stufe, TP RK ZP, die sechs Werte zu zweit
func kopf_neu() -> void:
	for c in kopf.get_children():
		kopf.remove_child(c)
		c.queue_free()
	var h := held()
	var d := Heldwerte.lade()
	var n := Stil.zeile((name_ if name_.strip_edges() != "" else "?").to_upper(), 14, Stil.GOLD, 3.0)   # MenuHead
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	kopf.add_child(n)
	kopf.add_child(txt("%s · %s · %s %d" % [Sprache.t(d["voelker"][volk]["name"]), Sprache.t(d["klassen"][klasse]["name"]), Sprache.u("level"), h.stufe], 14))
	var w := "%s %d   %s %d" % [Sprache.u("hp"), h.max_tp(), Sprache.u("ac"), h.rk()]
	if h.max_zp() > 0: w += "   %s %d" % [Sprache.u("sp"), h.max_zp()]
	kopf.add_child(txt(w, 15))
	kopf.add_child(luecke(4))
	for i in range(0, 6, 2):
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 0)
		for a in Heldwerte.ATTRIBUTE.slice(i, i + 2):
			var l := txt("%s %d (%s)" % [kurz(a), h.wert(a), vorzeichen(h.mod(a))], 13)
			l.autowrap_mode = TextServer.AUTOWRAP_OFF
			l.custom_minimum_size.x = 104 * DP
			r.add_child(l)
		kopf.add_child(r)

func namensfeld() -> Control:
	var e := LineEdit.new()
	e.text = name_
	e.max_length = 12
	e.add_theme_font_override("font", Stil.variante(0.5))
	e.add_theme_font_size_override("font_size", int(round(24 * Stil.SP)))
	e.add_theme_color_override("font_color", Stil.TEXT)
	e.add_theme_color_override("caret_color", Stil.GOLD)
	var s := Stil.kasten(Stil.RAISED, Stil.RIM, 1.0)
	s.set_content_margin_all(12 * DP)
	for z in ["normal", "focus"]: e.add_theme_stylebox_override(z, s)
	e.text_changed.connect(func(t): name_ = t; kopf_neu())
	e.text_submitted.connect(func(_t): e.release_focus())
	return e

# Choices: je Zeile drei Knoepfe gleicher Breite, der gewaehlte hervorgehoben
func wahl(was: Array, gewaehlt: String, wort: Callable, nimm: Callable) -> Control:
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", int(6 * DP))
	g.add_theme_constant_override("v_separation", int(6 * DP))
	for w in was:
		var b := knopf(String(wort.call(w)), func(): nimm.call(w), w == gewaehlt)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_child(b)
	return g

# PointBuy: Kopf mit Vorschlag, darunter Punkte uebrig, Hinweis, je Attribut Wert mit Bonus, Modifikator, − und +
func punktekauf() -> void:
	var de := Sprache.aktiv() == "de"
	var summe := 0
	for a in Heldwerte.ATTRIBUTE: summe += Heldwerte.punktkosten(int(gekauft[a]))
	var alle := int(Heldwerte.regel("punktkauf"))
	var uebrig := alle - summe
	var kopfz := HBoxContainer.new()
	var k := kopfzeile("Attribute verteilen" if de else "Assign ability scores")
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	k.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	kopfz.add_child(k)
	var vor := knopf("Vorschlag" if de else "Suggest", func(): gekauft = Heldwerte.vorschlag(klasse); baue())
	vor.custom_minimum_size = Vector2(0, 36 * DP)
	vor.size_flags_horizontal = Control.SIZE_SHRINK_END
	vor.clip_text = false
	kopfz.add_child(vor)
	inhalt.add_child(kopfz)
	var p := VBoxContainer.new()
	p.add_theme_constant_override("separation", int(4 * DP))
	p.add_child(txt(("Punkte übrig: " if de else "Points left: ") + "%d / %d" % [uebrig, alle], 15, Stil.WARN if uebrig > 0 else Stil.TEXT))
	p.add_child(txt("Werte 8–15 vor Volksbonus. Höhere Werte kosten mehr (14: 7 Punkte, 15: 9 Punkte)." if de
		else "Scores 8–15 before racial bonus. Higher scores cost more (14: 7 points, 15: 9 points).", 12, Stil.DIM))
	var d := Heldwerte.lade()
	var lo := int(Heldwerte.regel("punktkauf_min"))
	var hi := int(Heldwerte.regel("punktkauf_max"))
	for a in Heldwerte.ATTRIBUTE:
		var v := int(gekauft[a])
		var bon := int(d["voelker"][volk]["bonus"].get(a, 0))
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 0)
		var n := txt(Sprache.t(d["attribute"][a]["name"]) + (" ★" if a == String(d["klassen"][klasse]["haupt"]) else ""), 14)
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(n)
		for z in [[str(v + bon), 16, Stil.TEXT, 30], ["+%d" % bon if bon > 0 else "", 12, Stil.GOLD, 30], ["(%s)" % vorzeichen(Heldwerte.mod_von(v + bon)), 13, Stil.DIM, 40]]:
			var l := txt(z[0], z[1], z[2])
			l.autowrap_mode = TextServer.AUTOWRAP_OFF
			l.custom_minimum_size.x = z[3] * DP
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER   # Helfer: „Charisma10“ klebte am Namen
			l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			r.add_child(l)
		var weg := knopf("−", func(): gekauft[a] = v - 1; baue())
		weg.custom_minimum_size = Vector2(44, 36) * DP
		weg.disabled = v <= lo
		r.add_child(weg)
		r.add_child(luecke(0, 6))
		var dazu := knopf("+", func(): gekauft[a] = v + 1; baue())
		dazu.custom_minimum_size = Vector2(44, 36) * DP
		dazu.disabled = not (v < hi and Heldwerte.punktkosten(v + 1) - Heldwerte.punktkosten(v) <= uebrig)
		r.add_child(dazu)
		p.add_child(r)
	inhalt.add_child(kasten(p))

# HeroTurntable (drehteller.gd); 376.1 mit Klasse, Aussehen und Grundausruestung
func vorschau() -> Control:
	teller = Drehteller.new(wahl_jetzt(), 0.9)
	teller_wahl = str(wahl_jetzt())
	return teller

func klasse_waehlen(k: String) -> void:
	klasse = k
	gekauft = Heldwerte.vorschlag(k)
	if not aussehen_eigen: aussehen = HeldFigur.vorgabe(k)   # Beispielkopf der Klasse, solange der Spieler nichts gewaehlt hat
	baue()

func wahl_jetzt() -> Dictionary:
	return {"klasse": klasse, "volk": volk, "aussehen": aussehen.duplicate(), "ausruestung": held().ausruestung}

func zeige_held() -> void:
	var w := wahl_jetzt()
	if teller == null or str(w) == teller_wahl: return
	teller_wahl = str(w)
	teller.zeige(w)

# 376.1 Aussehen (CreateScreen.kt „Aussehen“): Haut und Haar als Farbfelder des Volks wie alt (ToneChoices), Gesicht, Frisur, Bart als Knoepfe
func aussehen_wahl() -> void:
	var de := Sprache.aktiv() == "de"
	inhalt.add_child(kopfzeile("Aussehen" if de else "Appearance"))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	v.add_child(toene("Haut" if de else "Skin", HeldFigur.toene_liste(volk, "haut"), "haut"))
	v.add_child(toene("Haar" if de else "Hair", HeldFigur.toene_liste(volk, "haar"), "haarfarbe"))
	inhalt.add_child(v)
	for teil in [["form", HeldFigur.formen()], ["frisur", HeldFigur.frisuren()], ["bart", HeldFigur.baerte()]]:
		inhalt.add_child(txt(HeldFigur.wort(teil[0]), 14))
		inhalt.add_child(wahl(teil[1], String(aussehen.get(teil[0], "")), func(x): return HeldFigur.wort(teil[0] + ":" + x),
			func(x): aussehen[teil[0]] = x; aussehen_eigen = true; baue()))

# ToneChoices: Beschriftung, dann je Ton ein Feld mit Namen darunter; das gewaehlte mit Goldrand
func toene(wort: String, liste: Array, schluessel: String) -> Control:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * DP))
	var l := txt(wort, 14)
	l.size_flags_horizontal = Control.SIZE_FILL
	l.custom_minimum_size.x = 52 * DP
	r.add_child(l)
	var gewaehlt := clampi(int(aussehen.get(schluessel, 0)), 0, maxi(0, liste.size() - 1))
	for i in liste.size():
		var t: Dictionary = liste[i]
		var sp := VBoxContainer.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sp.add_theme_constant_override("separation", int(2 * DP))
		sp.alignment = BoxContainer.ALIGNMENT_CENTER
		var feld := Panel.new()
		feld.custom_minimum_size = Vector2(34, 34) * DP
		feld.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		feld.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 416.1: ein Panel faengt das Tippen sonst selbst ab (nur der Name darunter wirkte)
		var sb := Stil.kasten(Color.html(String(t["rgb"])), Stil.GOLD if i == gewaehlt else Stil.RIM, 3.0 if i == gewaehlt else 1.0)
		sb.set_corner_radius_all(int(6 * DP))
		feld.add_theme_stylebox_override("panel", sb)
		sp.add_child(feld)
		var n := Stil.zeile(Sprache.t(t["name"]), 11, Stil.GOLD if i == gewaehlt else Stil.DIM, 0.0)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n.clip_text = true
		sp.add_child(n)
		var nr := i
		sp.mouse_filter = Control.MOUSE_FILTER_STOP
		sp.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: aussehen[schluessel] = nr; aussehen_eigen = true; baue())
		r.add_child(sp)
	return r

# ---------------------------------------------------------------- Bausteine wie Theme.kt im schwarzen Look

static func kurz(a: String) -> String: return Sprache.t(Heldwerte.lade()["attribute"][a]["kurz"])
static func vorzeichen(n: int) -> String: return "+%d" % n if n >= 0 else str(n)

# Txt auf Schwarz: Alegreya, 0,95 der Groesse, nie kleiner als 13,7 sp, leicht gesperrt
static func txt(t: String, groesse_sp: float, farbe := Stil.TEXT) -> Label:
	var l := Stil.zeile(t, maxf(groesse_sp, 13.7) * 0.95, farbe, 0.2)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

# VeilHead: klein, gesperrte Versalien in Gold
static func kopfzeile(t: String) -> Label:
	return Stil.zeile(t.to_upper(), 12, Stil.GOLD, 3.0)

static func luecke(hoch_dp: float, breit_dp := 0.0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(breit_dp, hoch_dp) * DP
	return c

# Panel auf Schwarz: Rand 1 dp Veil.line, innen 14 dp seitlich, 10 dp oben und unten
static func kasten(innen: Control) -> PanelContainer:
	var p := PanelContainer.new()
	var s := Stil.kasten(Color.BLACK, Stil.LINE, 1.0)
	s.content_margin_left = 14 * DP; s.content_margin_right = 14 * DP
	s.content_margin_top = 10 * DP; s.content_margin_bottom = 10 * DP
	p.add_theme_stylebox_override("panel", s)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(innen)
	return p

# PixelButton auf Schwarz: 48 dp, Versalien 13 sp gesperrt 1,2 sp; gewaehlt Veil.raised mit 1,5 dp Veil.bright; gesperrt blass
static func knopf(t: String, was: Callable, gewaehlt := false) -> Button:
	var b := Button.new()
	b.text = t.to_upper().replace("ß", "SS")   # Helfer 17:24: „SCHLIEßEN“; Compose schrieb „SCHLIESSEN“
	b.custom_minimum_size = Vector2(0, 48 * DP)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_text = true
	b.add_theme_font_override("font", Stil.variante(1.2))
	b.add_theme_font_size_override("font_size", int(round(13 * Stil.SP)))
	var farbe := Stil.BRIGHT if gewaehlt else Stil.TEXT
	for z in ["font_color", "font_hover_color", "font_focus_color", "font_hover_pressed_color"]: b.add_theme_color_override(z, farbe)
	b.add_theme_color_override("font_pressed_color", Stil.BRIGHT)
	b.add_theme_color_override("font_disabled_color", Color(Stil.DIM, 0.6))
	var normal := Stil.kasten(Stil.RAISED, Stil.BRIGHT, 1.5) if gewaehlt else Stil.kasten(Color.BLACK, Stil.LINE, 1.0)
	var gedrueckt := Stil.kasten(Stil.RAISED, Stil.BRIGHT, 1.5)
	var blass := Stil.kasten(Color.BLACK, Color(Stil.DIM, 0.4), 1.0)
	for s in [normal, gedrueckt, blass]:
		s.content_margin_left = 6 * DP; s.content_margin_right = 6 * DP
	for z in ["normal", "hover", "focus"]: b.add_theme_stylebox_override(z, normal)
	b.add_theme_stylebox_override("pressed", gedrueckt)
	b.add_theme_stylebox_override("disabled", blass)
	b.pressed.connect(was)
	return b
