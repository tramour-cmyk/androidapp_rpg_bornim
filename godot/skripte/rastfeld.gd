class_name Rastfeld
extends Control
# 549 (Chef 04.11., 00:07: „Rastscreen wirkt sehr klein und viele Kästen …“, 00:08: „Kein schönes Design.“; 23:26 „besser machen“):
# das Rastfenster am Feuer, an der Theke und im Zimmer neu nach der Signatur (schwarz, dünner Goldrand, gedämpftes Gold, Alegreya,
# Zeichen statt Textwände; DESIGN-STIL „Oberfläche“, „Zeichen“) statt der allgemeinen Wahl (steuerung.gd zeige_wahl: Text in rohen
# Pixeln, je Wahl ein Kasten). Zwei Entwürfe zur Wahl des Chefs:
#   A „Tafel“: eine Tafel unten, darin Kopf mit Flamme, die Wahlen als Zeichen nebeneinander (Name, Dauer, was es bringt), „Weiter“ als Schrift
#   B „Ohne Kasten“: kein Kasten, die Welt dunkler, Flamme gross, die Wahlen als Zeilen zwischen feinen Goldlinien
# wahlen: [{id, name, dauer, tut, an, zeichen}]; Antippen sendet gewaehlt(id), „Weiter“ gewaehlt("")

signal gewaehlt(id: String)

const DP := AktionsKnopf.DP

var entwurf := "A"
var kopf_zeichen := "REST"

# [kopf]: das grosse Zeichen oben (REST: Flamme am Lagerfeuer; SCHENKE: Wirtshausschild an der Theke, Pruefer 17:12)
static func neu(entwurf_: String, titel: String, unter: String, wahlen: Array, weiter_text: String, notiz := "", zeilen: Array = [], kopf := "REST") -> Rastfeld:
	var r := Rastfeld.new()
	r.entwurf = entwurf_
	r.kopf_zeichen = kopf
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_STOP   # die Welt dahinter ist nicht zu erreichen (wie alt .tap {})
	var dunkel := ColorRect.new()
	# 557 (Chef 04.11., 19:38/19:54: Rast 7, 8 „diesen Halo … mit dem Dunkelverlauf … das muss noch weg“): B rein schwarz wie alle Schirme
	dunkel.color = Color(0, 0, 0, 0.6) if entwurf_ == "A" else Color(0, 0, 0, 1.0)   # alt 0x99000000
	dunkel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dunkel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_child(dunkel)
	if entwurf_ == "A": r._tafel(titel, unter, wahlen, weiter_text, notiz, zeilen)
	else: r._ohne_kasten(titel, unter, wahlen, weiter_text, notiz, zeilen)
	return r

# ---------------------------------------------------------------- A: eine Tafel unten
func _tafel(titel: String, unter: String, wahlen: Array, weiter_text: String, notiz: String, zeilen: Array) -> void:
	var tafel := PanelContainer.new()
	var k := Stil.kasten(Color(0, 0, 0, 0.94), Stil.GOLD, 1.0)
	for s in [SIDE_LEFT, SIDE_RIGHT]: k.set_content_margin(s, 20 * DP)
	k.content_margin_top = 18 * DP; k.content_margin_bottom = 10 * DP
	tafel.add_theme_stylebox_override("panel", k)
	tafel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tafel.offset_left = 12 * DP; tafel.offset_right = -12 * DP; tafel.offset_bottom = -20 * DP
	tafel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(tafel)
	var sp := VBoxContainer.new()
	sp.add_theme_constant_override("separation", int(10 * DP))
	tafel.add_child(sp)
	var kopf := HBoxContainer.new()
	kopf.add_theme_constant_override("separation", int(12 * DP))
	kopf.add_child(Rastzeichen.neu(kopf_zeichen, 34, Stil.BRIGHT))
	var kt := VBoxContainer.new()
	kt.add_theme_constant_override("separation", 0)
	kt.add_child(Stil.zeile(titel.to_upper(), 22, Stil.GOLD, 2.0))
	if unter != "": kt.add_child(Stil.zeile(unter, 14, Stil.DIM))
	kopf.add_child(kt)
	sp.add_child(kopf)
	for z in zeilen: sp.add_child(_satz(String(z), 15, Stil.TEXT))
	sp.add_child(_linie(Stil.RIM))
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", 0)
	for i in wahlen.size():
		if i > 0: reihe.add_child(_senkrecht())
		reihe.add_child(_wahl_spalte(wahlen[i]))
	sp.add_child(reihe)
	if notiz != "": sp.add_child(_satz(notiz, 15, Stil.TEXT))
	sp.add_child(_linie(Stil.RIM))
	sp.add_child(_weiter(weiter_text))

func _wahl_spalte(w: Dictionary) -> Control:
	var an := bool(w.get("an", true))
	var s := VBoxContainer.new()
	s.add_theme_constant_override("separation", int(2 * DP))
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.alignment = BoxContainer.ALIGNMENT_BEGIN
	var z := Rastzeichen.neu(String(w.get("zeichen", "REST")), 40, Stil.BRIGHT if an else Stil.DIM)
	z.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	s.add_child(Stil.luecke(6))
	s.add_child(z)
	s.add_child(Stil.luecke(4))
	for t in [[String(w["name"]), 18, Stil.TEXT if an else Stil.DIM], [String(w.get("dauer", "")), 15, Stil.GOLD if an else Stil.DIM], [String(w.get("tut", "")), 13, Stil.DIM]]:
		if String(t[0]) == "": continue
		var l := _satz(String(t[0]), t[1], t[2])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		s.add_child(l)
	s.add_child(Stil.luecke(8))
	var b := _tippbar(s, String(w["id"]), an)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return b

# ---------------------------------------------------------------- B: ohne Kasten
func _ohne_kasten(titel: String, unter: String, wahlen: Array, weiter_text: String, notiz: String, zeilen: Array) -> void:
	var sp := VBoxContainer.new()
	sp.add_theme_constant_override("separation", int(10 * DP))
	if Spielstaende.vorlage2:   # 557a B (Chef 20:52: „Sieben und acht sind unten ausgerichtet“): oben wie jeder Schirm, Kopf in derselben Hoehe
		sp.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		sp.offset_left = 28 * DP; sp.offset_right = -28 * DP; sp.offset_top = Spielstaende.OBEN_DP * DP
		sp.grow_vertical = Control.GROW_DIRECTION_END
	else:
		sp.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		sp.offset_left = 28 * DP; sp.offset_right = -28 * DP; sp.offset_bottom = -40 * DP
		sp.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(sp)
	var t := Stil.zeile(titel.to_upper(), 22 if Spielstaende.vorlage2 else 26, Stil.GOLD, 3.0)   # 557 Runde 5 (549a ja, 19:28): Titel eines Schirms 22 sp
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if Spielstaende.vorlage2:   # 557b B (Chef 05.11., 08:18, Archiv 557): Titel auf derselben Hoehe wie jeder Schirm, das Zeichen links daneben
		var kopf := HBoxContainer.new()
		kopf.alignment = BoxContainer.ALIGNMENT_CENTER
		kopf.add_theme_constant_override("separation", int(12 * DP))
		kopf.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fz := Rastzeichen.neu(kopf_zeichen, 40, Stil.BRIGHT)
		fz.name = "Kopfzeichen"
		fz.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		kopf.add_child(fz)
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		kopf.add_child(t)
		sp.add_child(kopf)
	else:
		var fl := Rastzeichen.neu(kopf_zeichen, 64, Stil.BRIGHT)
		fl.name = "Kopfzeichen"
		fl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		sp.add_child(fl)
		sp.add_child(t)
	# 557 (Chef 16:51, 549a (8): „für jedes Fenster gleich“): Kopf zuerst, gleich darunter die Zierlinie, dann der Inhalt
	if Spielstaende.vorlage2: sp.add_child(_zier())
	if unter != "":
		var u := Stil.zeile(unter, 14, Spielstaende.ANGABE if Spielstaende.vorlage2 else Stil.DIM)   # 557 (8) kleine Angaben heller
		u.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sp.add_child(u)
	for z in zeilen:
		var l := _satz(String(z), 15, Stil.TEXT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sp.add_child(l)
	if not Spielstaende.vorlage2: sp.add_child(_zier())
	for w in wahlen:
		sp.add_child(_wahl_zeile(w))
		sp.add_child(_linie(Stil.RIM))
	if notiz != "":
		var n := _satz(notiz, 15, Stil.TEXT)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sp.add_child(n)
	sp.add_child(Stil.luecke(6))
	if Spielstaende.vorlage2:   # 557/549 (Chef 16:37: „mit denselben Bausteinen“): die Nebenwahl links wie Abbrechen;
		# 557 Runde 4 (Chef 17:40: „sinnvoller wäre ein Zurück oder ein Abbrechen“): „‹ ZURÜCK“ statt „‹ WEITERGEHEN“, so gross wie jeder Knopf
		var neben := Spielstaende.knopf("neben", Sprache.u("back"), func(): gewaehlt.emit(""), true)
		neben.set_meta("id", "")
		sp.add_child(Spielstaende.knopfzeile(neben, null))
	else:
		sp.add_child(_weiter(weiter_text))

func _wahl_zeile(w: Dictionary) -> Control:
	var an := bool(w.get("an", true))
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(14 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var z := Rastzeichen.neu(String(w.get("zeichen", "REST")), 36, Stil.BRIGHT if an else Stil.DIM)
	z.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.add_child(z)
	var mitte := VBoxContainer.new()
	mitte.add_theme_constant_override("separation", 0)
	mitte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mitte.add_child(_satz(String(w["name"]), 20, Stil.TEXT if an else Stil.DIM))
	if String(w.get("tut", "")) != "": mitte.add_child(_satz(String(w["tut"]), 14, Stil.DIM))
	r.add_child(mitte)
	if String(w.get("dauer", "")) != "":
		var d := Stil.zeile(String(w["dauer"]), 17, Stil.GOLD if an else Stil.DIM)
		d.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(d)
	if Spielstaende.vorlage2: r.add_child(Spielstaende.wahl_b("", Stil.BRIGHT if an else Color(Stil.DIM, 0.6)))   # „›“ wie jede Zeile zum Antippen
	var rand := MarginContainer.new()
	rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rand.add_theme_constant_override("margin_top", int(12 * DP)); rand.add_theme_constant_override("margin_bottom", int(12 * DP))
	rand.add_child(r)
	return _tippbar(rand, String(w["id"]), an)

# ---------------------------------------------------------------- gemeinsam
# eine Flaeche zum Antippen, so gross wie ihr Inhalt (Container: die umbrechenden Zeilen bestimmen die Hoehe); gedrueckt der erhabene Grund
func _tippbar(inhalt: Control, id: String, an: bool) -> PanelContainer:
	var p := PanelContainer.new()
	var leer := StyleBoxEmpty.new()
	var gedrueckt := Stil.kasten(Stil.RAISED, Color(0, 0, 0, 0), 0.0)
	p.add_theme_stylebox_override("panel", leer)
	p.mouse_filter = Control.MOUSE_FILTER_STOP if an else Control.MOUSE_FILTER_IGNORE
	p.add_child(inhalt)
	p.set_meta("id", id)
	var ab := [Vector2.INF]
	p.gui_input.connect(func(e: InputEvent):
		if not Spielstaende.tipp(e): return   # 605: sonst jeder Tipp zweimal (Beruehrung und nachgebildete Maus)
		if e.pressed:
			p.add_theme_stylebox_override("panel", gedrueckt)
			ab[0] = e.global_position
		else:
			p.add_theme_stylebox_override("panel", leer)
			var gewischt: bool = ab[0] == Vector2.INF or (e.global_position as Vector2).distance_to(ab[0]) > Spielstaende.WISCH * DP   # 617
			ab[0] = Vector2.INF
			if not gewischt and Rect2(Vector2.ZERO, p.size).has_point(e.position): gewaehlt.emit(id))
	return p

func _weiter(text: String) -> Control:
	var r := HBoxContainer.new()
	r.custom_minimum_size.y = 48 * DP
	r.alignment = BoxContainer.ALIGNMENT_CENTER
	r.add_theme_constant_override("separation", int(8 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_child(Stil.zeile(text.to_upper(), 16, Stil.GOLD, 2.0))
	var n := Rastzeichen.neu("NEXT", 18, Stil.GOLD)
	n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.add_child(n)
	return _tippbar(r, "", true)

func _satz(t: String, sp_: float, farbe: Color) -> Label:
	var l := Stil.zeile(Spielstaende.ohne_waise(t), sp_, farbe)   # 557 Runde 5 (Prüfer 19:47: „zurück“ allein)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 60 * DP
	return l

func _linie(farbe: Color) -> Control:
	var c := ColorRect.new()
	c.color = farbe
	c.custom_minimum_size = Vector2(0, maxf(1.0, round(DP * 0.6)))
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

func _senkrecht() -> Control:
	var c := ColorRect.new()
	c.color = Stil.RIM
	c.custom_minimum_size = Vector2(maxf(1.0, round(DP * 0.6)), 0)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

# feine Goldlinie mit einer Raute in der Mitte (B)
func _zier() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 14 * DP)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func():
		var m := c.size / 2
		var w := 1.0 * DP
		c.draw_line(Vector2(c.size.x * 0.12, m.y), Vector2(m.x - 9 * DP, m.y), Stil.RIM, w, true)
		c.draw_line(Vector2(m.x + 9 * DP, m.y), Vector2(c.size.x * 0.88, m.y), Stil.RIM, w, true)
		var r := 4.5 * DP
		c.draw_polyline(PackedVector2Array([m + Vector2(0, -r), m + Vector2(r, 0), m + Vector2(0, r), m + Vector2(-r, 0), m + Vector2(0, -r)]), Stil.GOLD, w, true))
	return c
