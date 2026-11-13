class_name Pruefliste
extends RefCounted
# 1020.1 (Chef 12.11., 08:09, „jetzt“; Vorlage 1020 D Stufe 1): die Prüfliste des Builds im Reiter „Test“. Der Bau legt sie als
# daten/pruefliste.json ins Spiel (tools/pruefliste.py, godot.yml). Je Zeile: Wo und wie, Richtig, Falsch; ✓ oder ✗ mit einem Wort,
# bleibt über einen Neustart gespeichert (user://pruefliste.cfg, je Build); „Ergebnis kopieren“ legt den Text in die Zwischenablage
# im Format der Prüfliste („## Ergebnis“: „- n.k ✓“, „- n.k ✗ <Wort>“, LISTE-CHECK-BUILD-TEST.md 11).

const DATEI := "res://daten/pruefliste.json"
const ERGEBNIS := "user://pruefliste.cfg"
const DP := AktionsKnopf.DP

static var _liste = null          # Dictionary, {} wenn keine im Bau
static var offen := ""            # Nummer der aufgeklappten Zeile
static var kopf_auf := false
# 1030 (Chef 12.11., 13:53, Build 280: „muss ich ewig scrollen, das kann ich ja nicht einklappen“): Kopf „Prüfliste · Build n“
# antippen klappt die Liste ein (nur Kopf und Zähler) und wieder auf; der Zustand bleibt über einen Neustart (user://pruefliste.cfg)
static var zu = null               # null: noch nicht geladen
# 1030 („wenn ich jetzt Bildrate schalte, dann bin ich wieder ganz oben“): nur eine gerade aufgeklappte Zeile rollt ins Bild,
# nicht jede, die beim Neuaufbau des Reiters nach einem Schalter offen steht
static var _neu_offen := false

static func eingeklappt() -> bool:
	if zu == null:
		var c := ConfigFile.new()
		zu = c.load(ERGEBNIS) == OK and bool(c.get_value("anzeige", "zu", false))
	return bool(zu)

static func klappe() -> void:
	zu = not eingeklappt()
	var c := ConfigFile.new()
	c.load(ERGEBNIS)
	c.set_value("anzeige", "zu", zu)
	c.save(ERGEBNIS)

static func _oeffne(nr: String) -> void:
	offen = nr
	_neu_offen = nr != ""

static func liste() -> Dictionary:
	if _liste == null:
		_liste = {}
		if FileAccess.file_exists(DATEI):
			var d = JSON.parse_string(FileAccess.get_file_as_string(DATEI))
			if d is Dictionary: _liste = d
	return _liste

static func zeilen() -> Array:
	var aus := []
	for a in liste().get("abschnitte", []):
		for z in a.get("zeilen", []): aus.append(z)
	return aus

static func _sektion() -> String: return "t%d" % int(liste().get("build", 0))

## „✓“, „✗ Wort“ oder ""
static func ergebnis(nr: String) -> String:
	var c := ConfigFile.new()
	if c.load(ERGEBNIS) != OK: return ""
	return String(c.get_value(_sektion(), nr, ""))

static func setze(nr: String, wert: String) -> void:
	var c := ConfigFile.new()
	c.load(ERGEBNIS)
	if wert == "":
		if c.has_section_key(_sektion(), nr): c.erase_section_key(_sektion(), nr)
	else:
		c.set_value(_sektion(), nr, wert)
	c.save(ERGEBNIS)

static func wort(nr: String) -> String:
	var e := ergebnis(nr)
	return e.substr(2).strip_edges() if e.begins_with("✗") else ""

static func naechste_offene(nach := "") -> String:
	var alle := zeilen()
	var ab := 0
	for i in alle.size():
		if String(alle[i]["nr"]) == nach: ab = i + 1
	for k in alle.size():
		var z = alle[(ab + k) % alle.size()]
		if ergebnis(String(z["nr"])) == "": return String(z["nr"])
	return ""

## Text für die Zwischenablage, wie der Abschnitt „## Ergebnis“ der Prüfliste
static func ergebnis_text() -> String:
	var t := ["Build %d · Ergebnis" % int(liste().get("build", 0))]
	var offene := []
	for z in zeilen():
		var nr := String(z["nr"])
		var e := ergebnis(nr)
		if e == "": offene.append(nr)
		else: t.append("- %s %s" % [nr, e])
	if not offene.is_empty(): t.append("- offen: " + ", ".join(offene))
	return "\n".join(t)

static func zaehle() -> Array:   # [geprüft, davon ✗, alle]
	var n := 0; var x := 0; var alle := zeilen()
	for z in alle:
		var e := ergebnis(String(z["nr"]))
		if e != "": n += 1
		if e.begins_with("✗"): x += 1
	return [n, x, alle.size()]

## im Reiter „Test“ (testmodus.gd reiter): Kopf, Zähler, Kopieren, dann je Abschnitt die Zeilen; eine aufgeklappt
static func zeige(m: Menue, t: Callable) -> void:
	var l := liste()
	if zeilen().is_empty():
		m.gruppe(t.call("Prüfliste", "Checklist"))
		m.zeile(t.call("Keine Prüfliste im Bau.", "No checklist in this build."), 15, Stil.DIM)
		m.luecke(8)
		return
	var z3 := zaehle()
	var auf := not eingeklappt()
	m.inhalt.add_child(_kopf(m, t.call("Prüfliste · Build %d", "Checklist · build %d") % int(l.get("build", 0)), auf))
	m.luecke(10)
	m.zeile(t.call("%d von %d geprüft, %d nicht in Ordnung", "%d of %d checked, %d not right") % [z3[0], z3[2], z3[1]], 15, Stil.TEXT)
	m.luecke(6)
	if not auf:
		m.luecke(4)
		return
	var kopf: Array = l.get("kopf", [])
	if not kopf.is_empty():
		m.inhalt.add_child(_zeilenknopf(m, t.call("Weg und Bekanntes", "Route and known issues"), "", kopf_auf, func(): kopf_auf = not kopf_auf))
		if kopf_auf:
			for s in kopf: m.zeile(String(s), 14, Stil.DIM)
			m.luecke(6)
	m.inhalt.add_child(Spielstaende.knopfzeile(
		Spielstaende.knopf("haupt", t.call("Ergebnis kopieren", "Copy result"), func():
			DisplayServer.clipboard_set(ergebnis_text())
			m.meldung(t.call("Ergebnis in der Zwischenablage.", "Result copied.")), true),
		Spielstaende.knopf("neben", t.call("Nächste", "Next"), func(): m._tue(func(): _oeffne(naechste_offene(offen))))))
	for a in l.get("abschnitte", []):
		if String(a.get("titel", "")) != "":
			m.luecke(8)
			m.zeile(String(a["titel"]), 14, Stil.GOLD)
		for z in a.get("zeilen", []):
			m.inhalt.add_child(Spielstaende.linie())
			_zeile(m, t, z)
	m.inhalt.add_child(Spielstaende.linie())
	m.luecke(10)

## eine antippbare Zeile über die ganze Breite (549a: links Text, rechts das Ergebnis als Zeichen und Wort, dann „›“)
## [ergebnis] wie ergebnis(): „✓“, „✗ Wort“ oder ""; die Schrift hat kein ✓ und ✗, darum gezeichnet (Rastzeichen HAKEN, KREUZ)
static func _zeilenknopf(m: Menue, links: String, ergebnis_: String, auf: bool, tat: Callable) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(8 * DP))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.custom_minimum_size.y = 48 * DP
	var a := Stil.txt(links, 15, Stil.BRIGHT if auf else Stil.TEXT)
	a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(a)
	if ergebnis_ != "":
		var falsch := ergebnis_.begins_with("✗")
		var w := ergebnis_.substr(2).strip_edges() if falsch else ""
		if w != "":
			var b := Stil.txt(w if w.length() <= 16 else w.left(15) + "…", 14, Stil.WARN)
			b.autowrap_mode = TextServer.AUTOWRAP_OFF     # sonst bricht das Wort Zeichen für Zeichen um
			b.size_flags_horizontal = Control.SIZE_SHRINK_END
			b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			h.add_child(b)
		var z := Rastzeichen.neu("KREUZ" if falsch else "HAKEN", 20, Stil.WARN if falsch else Stil.BRIGHT)
		z.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(z)
	var p := Spielstaende.pfeil(Stil.GOLD, false)
	p.rotation = PI / 2 if auf else 0.0
	h.add_child(p)
	return Spielstaende.tippbar(h, func(): m._tue(tat))

static func _zeile(m: Menue, t: Callable, z: Dictionary) -> void:
	var nr := String(z["nr"])
	var e := ergebnis(nr)
	var auf := offen == nr
	var wo := String(z.get("wo", ""))
	var kurz := wo if wo.length() <= 44 or auf else wo.left(42).strip_edges() + " …"
	m.inhalt.add_child(_zeilenknopf(m, "%s  %s" % [nr, kurz], e, auf, func(): _oeffne("" if auf else nr)))
	if not auf: return
	var kopf := []
	if String(z.get("team", "")) != "": kopf.append(String(z["team"]))
	if String(z.get("vorgang", "")) != "": kopf.append(t.call("Vorgang ", "Item ") + String(z["vorgang"]))
	if not kopf.is_empty(): m.zeile(" · ".join(kopf), 13, Stil.DIM)
	# 1030 (Chef 14:20: „Es gibt ja kein richtig, sondern passt“): wie der Knopf
	m.zeile(t.call("Passt: ", "Right: ") + String(z.get("richtig", "")), 15, Stil.TEXT)
	m.zeile(t.call("Falsch: ", "Wrong: ") + String(z.get("falsch", "")), 15, Stil.DIM)
	m.luecke(6)
	# „Passt“ springt zur nächsten offenen Zeile; „Falsch“ bleibt hier und öffnet das Feld für ein Wort
	m.inhalt.add_child(Spielstaende.knopfzeile(
		Spielstaende.knopf("haupt" if e == "✓" else "neben", t.call("Passt", "Right"), func():
			setze(nr, "✓")
			m._tue(func(): _oeffne(naechste_offene(nr))), true),
		Spielstaende.knopf("gefahr", t.call("Falsch", "Wrong"), func():
			setze(nr, ("✗ " + wort(nr)).strip_edges())
			m._tue(func(): pass))))
	if e.begins_with("✗"):
		var f := LineEdit.new()
		f.text = wort(nr)
		f.placeholder_text = t.call("ein Wort, was nicht passt", "a word on what is wrong")
		f.max_length = 80
		f.add_theme_font_override("font", Stil.variante(0.2))
		f.add_theme_font_size_override("font_size", int(round(16 * Stil.SP)))
		f.add_theme_color_override("font_color", Stil.TEXT)
		f.add_theme_color_override("font_placeholder_color", Color(Stil.DIM, 0.8))
		f.add_theme_color_override("caret_color", Stil.GOLD)
		var s := Stil.kasten(Stil.RAISED, Stil.RIM, 1.0)
		s.set_content_margin_all(10 * DP)
		for k in ["normal", "focus"]: f.add_theme_stylebox_override(k, s)
		f.custom_minimum_size.y = 48 * DP
		f.text_changed.connect(func(w): setze(nr, ("✗ " + String(w).strip_edges()).strip_edges()))
		f.text_submitted.connect(func(_w): f.release_focus())
		m.inhalt.add_child(f)
	var ende := Stil.luecke(8)
	m.inhalt.add_child(ende)
	if _neu_offen:
		_neu_offen = false
		_ins_bild(m, ende)

## Kopf der Prüfliste wie m.gruppe (Goldversalien), antippbar über die ganze Breite, rechts „›“ (offen nach unten gedreht)
static func _kopf(m: Menue, w: String, auf: bool) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(8 * DP))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.custom_minimum_size.y = 40 * DP
	var a := Stil.txt(w.to_upper(), 14, Stil.GOLD)
	a.add_theme_font_override("font", Stil.variante(3.0))
	a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(a)
	var p := Spielstaende.pfeil(Stil.GOLD, false)
	p.rotation = PI / 2 if auf else 0.0
	h.add_child(p)
	return Spielstaende.tippbar(h, func(): m._tue(klappe))

## die aufgeklappte Zeile ganz ins Bild rollen (baue() stellt erst die alte Stelle wieder her)
static func _ins_bild(m: Menue, c: Control) -> void:
	await m.get_tree().process_frame
	await m.get_tree().process_frame
	if is_instance_valid(c) and c.is_inside_tree(): m.rolle.ensure_control_visible(c)
