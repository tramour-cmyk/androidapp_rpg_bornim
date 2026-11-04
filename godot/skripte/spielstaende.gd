class_name Spielstaende
extends Control
# 399.1 Spielstaende wie im alten Spiel (SlotsScreen.kt, Chef 28.10., 14:38 „Einfach mal das alte Spiel nehmen“): oben der Kopf
# „Spielstaende“, darunter rollend die vier Plaetze: belegt mit Name, Volk, Klasse, Stufe, Ort, Tag und Uhrzeit, wann gespeichert,
# „Loeschen“ (mit Rueckfrage) und „Laden“; leer mit „Neues Spiel“ in diesen Platz; unten „Zurueck“. 529: links das Bild des Helden
# (HeroStill: seine Figur mit Aussehen und Ausruestung, stehend) und unten die Spielzeit (PlayClock.played).

signal zurueck
signal laden(platz: int)
signal neu(platz: int)

const DP := AktionsKnopf.DP

# 557 (Chef 04.11., 11:15: „am Beispiel der Spielstände einen Entwurf … in dem neuen Stil“; Chefsache 549a „ohne Kasten“): nur Entwurf,
# im Spiel weiter „“ (die Karten wie alt), bis der Chef entscheidet. B: Titel ohne Rahmen, je Platz eine Zeile zwischen feinen Goldlinien,
# antippbar ueber die ganze Breite (mindestens 48 dp, dunkel beim Antippen), links ein Zeichen (das Bild des Helden), rechts goldenes „›“;
# Laden ist die Hauptwahl, Loeschen leise grau darunter, mit Rueckfrage (der einzige Rahmen). [mit]: Vorschlaege zum Zuschalten (11:17)
static var entwurf := ""
static var mit := {"weiter": false, "ziel": false, "werte": false}

var liste: VBoxContainer

func _init() -> void:
	name = "Spielstaende"

func _ready() -> void:
	Zurueck.melde(self, func(): zurueck.emit())   # 416.1: Android-Zurück wie „Zurück“
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if entwurf == "B":
		_ready_b()
		return
	var de := Sprache.aktiv() == "de"
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
	var kopf := Stil.zeile(("Spielstände" if de else "Saved games").to_upper(), 12, Stil.BRIGHT, 3.0)   # VeilHead in Veil.bright
	spalte.add_child(Erschaffung.kasten(kopf))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", int(10 * DP))
	rolle.add_child(liste)
	spalte.add_child(Erschaffung.knopf(Sprache.u("back"), func(): zurueck.emit()))   # BackRow
	baue()

func baue() -> void:
	var de := Sprache.aktiv() == "de"
	for c in liste.get_children():
		liste.remove_child(c)
		c.queue_free()
	if entwurf == "B":
		_baue_b(de)
		return
	for d in Spielstand.liste():
		var n: int = liste.get_child_count() + 1
		if d.is_empty():
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 0)
			v.add_child(Erschaffung.txt(("Platz %d · leer" if de else "Slot %d · empty") % n, 17, Stil.DIM))
			v.add_child(Erschaffung.luecke(8))
			v.add_child(Erschaffung.knopf(Sprache.u("newGame"), func(): neu.emit(n)))
			liste.add_child(Erschaffung.kasten(v))
			continue
		var k := karte(d)
		var knoepfe := HBoxContainer.new()
		knoepfe.add_theme_constant_override("separation", int(8 * DP))
		var weg := Erschaffung.knopf("Löschen" if de else "Delete", func(): frage_loeschen(d))
		var los := Erschaffung.knopf("Laden" if de else "Load", func(): laden.emit(n))
		los.size_flags_stretch_ratio = 2.0
		knoepfe.add_child(weg)
		knoepfe.add_child(los)
		var innen: VBoxContainer = k.get_child(0)   # 529: aussen (Bild und Zeilen), darunter die Knoepfe
		innen.add_child(Erschaffung.luecke(8))
		innen.add_child(knoepfe)
		liste.add_child(k)

# SlotCard: Bild, Platz und Name, Volk · Klasse · Stufe, Ort · Tag · Uhrzeit, gespeichert am, gespielt
static func karte(d: Dictionary) -> PanelContainer:
	var de := Sprache.aktiv() == "de"
	var h: Dictionary = d.get("held", {})
	var z: Dictionary = d.get("zustand", {})
	var hd := Heldwerte.lade()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	var n := Stil.zeile((("Platz %d · " if de else "Slot %d · ") % int(d["platz"]) + String(h.get("name", ""))).to_upper(), 14, Stil.GOLD, 3.0)   # MenuHead
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(n)
	var volk := String(h.get("volk", "HUMAN"))
	var klasse := String(h.get("klasse", "FIGHTER"))
	v.add_child(Erschaffung.txt("%s · %s · %s %d" % [Sprache.t(hd["voelker"][volk]["name"]) if hd["voelker"].has(volk) else volk,
		Sprache.t(hd["klassen"][klasse]["name"]) if hd["klassen"].has(klasse) else klasse, Sprache.u("level"), int(h.get("stufe", 1))], 14))
	var ort := String(d.get("ort", {}).get("karte", ""))
	var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json")) if FileAccess.file_exists("res://daten/karten.json") else null
	if alle is Dictionary and alle["karten"].has(ort): ort = Sprache.t(alle["karten"][ort]["name"])
	var m := int(z.get("minuten", 0))
	v.add_child(Erschaffung.txt("%s · %s %d · %02d:%02d" % [ort, "Tag" if de else "Day", int(z.get("tag", 1)), m / 60, m % 60], 13, Stil.DIM))
	var t := gespeichert_um(d)
	if not t.is_empty():
		var s := ("%02d.%02d.%04d, %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]) if de else ("%04d-%02d-%02d, %02d:%02d" % [t.year, t.month, t.day, t.hour, t.minute])
		v.add_child(Erschaffung.txt(("Gespeichert: " if de else "Saved: ") + s, 12, Stil.DIM))
	var g := gespielt(int(z.get("gespielt_ms", 0)), de)
	var gl := Erschaffung.txt(g, 12, Stil.DIM)
	gl.name = "Gespielt"
	v.add_child(gl)
	# HeroStill links neben den Zeilen (alt 10 dp Abstand); die Knoepfe haengt baue() unter beides
	var aussen := VBoxContainer.new()
	aussen.add_theme_constant_override("separation", 0)
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", int(10 * DP))
	var bild := Drehteller.new(heldbild(d), 0.4, false)
	bild.name = "Heldbild"
	bild.mouse_filter = Control.MOUSE_FILTER_IGNORE   # Antippen gehoert der Karte (Erschaffung: Platz waehlen)
	reihe.add_child(bild)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reihe.add_child(v)
	aussen.add_child(reihe)
	return Erschaffung.kasten(aussen)

# HeldFigur.wahl aus dem gespeicherten Helden; {} wenn der Spielstand nichts hergibt (dann der Grundheld)
static func heldbild(d: Dictionary) -> Dictionary:
	if not (d.get("held") is Dictionary and d.get("zustand") is Dictionary): return {}
	return HeldFigur.wahl(Heldwerte.aus_daten(d["held"]), Zustand.aus_daten(d["zustand"]))

# 529: Ortszeit beim Speichern (seit 529 mitgespeichert); aeltere Spielstaende rechnen aus der Unix-Zeit mit dem heutigen Abstand zu UTC
# (der Fehler, den Sokrates vermutete: nach einer Zeitumstellung eine Stunde daneben)
static func gespeichert_um(d: Dictionary) -> Dictionary:
	var o = d.get("gespeichert_ortszeit")
	if o is Dictionary and o.has("year"): return {"year": int(o["year"]), "month": int(o["month"]), "day": int(o["day"]), "hour": int(o["hour"]), "minute": int(o["minute"])}
	var wann := int(d.get("gespeichert", 0))
	if wann <= 0: return {}
	return Time.get_datetime_dict_from_unix_time(wann / 1000 + int(Time.get_time_zone_from_system().get("bias", 0)) * 60)

# PlayClock.played: „Gespielt: 2 Std. 14 Min.“
static func gespielt(ms: int, de: bool) -> String:
	var mi := maxi(0, ms / 60000)
	var h := mi / 60
	var m := mi % 60
	var zeit := ("%d Min." % m if de else "%d min" % m) if h == 0 else ("%d Std. %d Min." % [h, m] if de else "%d h %d min" % [h, m])
	return ("Gespielt: " if de else "Played: ") + zeit

# ConfirmDialog: „Spielstand löschen?“, wer wird geloescht, Abbrechen und Loeschen
func frage_loeschen(d: Dictionary) -> void:
	var de := Sprache.aktiv() == "de"
	var h: Dictionary = d.get("held", {})
	var schleier := Rueckfrage.schleier(self)   # 526: Tippen daneben und Android-Zurück wie „Abbrechen“ (alt SlotsScreen BackHandler)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - (68 if entwurf == "B" else 48) * DP   # 557: schmaler als die Liste (Helfer 11:28)
	var k := Rueckfrage.halte(Erschaffung.kasten(v))
	mitte.add_child(k)
	v.add_child(Stil.zeile(("Spielstand löschen?" if de else "Delete saved game?").to_upper(), 14, Stil.GOLD, 3.0))
	var t := Erschaffung.txt(("%s (Stufe %d) wird endgültig gelöscht." if de else "%s (level %d) will be deleted for good.") % [String(h.get("name", "")), int(h.get("stufe", 1))], 15)
	v.add_child(t)
	var knoepfe := HBoxContainer.new()
	knoepfe.add_theme_constant_override("separation", int(8 * DP))
	knoepfe.add_child(Erschaffung.knopf("Abbrechen" if de else "Cancel", func(): schleier.queue_free()))
	var weg := Erschaffung.knopf("Löschen" if de else "Delete", func():
		Spielstand.loesche(int(d["platz"]))
		schleier.queue_free()
		baue())
	if entwurf == "B":   # 557 (Helfer 11:28: beide Knoepfe gleich): die gefaehrliche Wahl in Warnfarbe
		for f in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]: weg.add_theme_color_override(f, Stil.WARN)
	knoepfe.add_child(weg)
	v.add_child(knoepfe)

# ---------------------------------------------------------------- 557 Entwurf B „ohne Kasten“
func _ready_b() -> void:
	var de := Sprache.aktiv() == "de"
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right"]: rand.add_theme_constant_override("margin_" + s, int(20 * DP))
	rand.add_theme_constant_override("margin_top", int(36 * DP)); rand.add_theme_constant_override("margin_bottom", int(16 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	rand.add_child(spalte)
	var kopf := Stil.zeile(("Spielstände" if de else "Saved games").to_upper(), 22, Stil.GOLD, 3.0)
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spalte.add_child(kopf)
	spalte.add_child(Erschaffung.luecke(6))
	spalte.add_child(_zier())
	spalte.add_child(Erschaffung.luecke(10))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", 0)
	rolle.add_child(liste)
	spalte.add_child(_linie())
	var z := HBoxContainer.new()
	z.custom_minimum_size.y = 52 * DP
	z.alignment = BoxContainer.ALIGNMENT_CENTER
	z.mouse_filter = Control.MOUSE_FILTER_IGNORE
	z.add_child(Stil.zeile("‹  " + Sprache.u("back").to_upper(), 16, Stil.GOLD, 2.0))
	spalte.add_child(tippbar(z, func(): zurueck.emit()))
	baue()

func _baue_b(de: bool) -> void:
	var plaetze := []   # [Nummer, Spielstand oder {}]
	for d in Spielstand.liste(): plaetze.append([plaetze.size() + 1, d])
	var zuletzt := Spielstand.letzter() if mit["weiter"] else 0
	if zuletzt > 0:   # Vorschlag 1: der zuletzt gespielte Platz oben, Hauptwahl „Weiter“
		var p0 = plaetze[zuletzt - 1]
		plaetze.remove_at(zuletzt - 1)
		plaetze.push_front(p0)
	for p in plaetze:
		if liste.get_child_count() > 0: liste.add_child(_linie())
		var d: Dictionary = p[1]
		liste.add_child(_leer_zeile(int(p[0]), de) if d.is_empty() else _voll_zeile(d, de, int(p[0]) == zuletzt))

func _leer_zeile(platz: int, de: bool) -> Control:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(14 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.custom_minimum_size.y = 64 * DP
	var zeichen := Rastzeichen.neu("PLUS", 28, Stil.GOLD)
	zeichen.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var links := CenterContainer.new()
	links.custom_minimum_size.x = 60 * DP
	links.mouse_filter = Control.MOUSE_FILTER_IGNORE
	links.add_child(zeichen)
	r.add_child(links)
	var t := Stil.zeile(("Platz %d · leer" if de else "Slot %d · empty") % platz, 16, Stil.DIM)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.add_child(t)
	r.add_child(_wahl(Sprache.u("newGame")))
	return tippbar(r, func(): neu.emit(platz))

func _voll_zeile(d: Dictionary, de: bool, weiter: bool) -> Control:
	var h: Dictionary = d.get("held", {})
	var z: Dictionary = d.get("zustand", {})
	var hd := Heldwerte.lade()
	var platz := int(d["platz"])
	var aussen := VBoxContainer.new()
	aussen.add_theme_constant_override("separation", 0)
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(14 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bild := Drehteller.new(heldbild(d), 0.4, false)
	bild.name = "Heldbild"
	bild.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_child(bild)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(2 * DP))
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var kopf := Stil.zeile((("Platz %d · " if de else "Slot %d · ") % platz + String(h.get("name", ""))).to_upper(), 14, Stil.BRIGHT if weiter else Stil.GOLD, 2.5)
	kopf.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(kopf)
	var volk := String(h.get("volk", "HUMAN"))
	var klasse := String(h.get("klasse", "FIGHTER"))
	v.add_child(_satz("%s · %s · %s %d" % [Sprache.t(hd["voelker"][volk]["name"]) if hd["voelker"].has(volk) else volk,
		Sprache.t(hd["klassen"][klasse]["name"]) if hd["klassen"].has(klasse) else klasse, Sprache.u("level"), int(h.get("stufe", 1))], 16, Stil.TEXT))
	if mit["ziel"]:   # Vorschlag 2: wo man steht, damit man nach Tagen weiss, was zu tun ist (Hauptauftrag der Chronik)
		var zs := Zustand.aus_daten(z)
		# Helfer 11:28: in BRIGHT heller als „Laden“ und zog den Blick weg; gebrochenes Weiss, gedaempft
		v.add_child(_satz(("Kapitel %d · " if de else "Chapter %d · ") % Geschichte.kapitel(zs) + Sprache.t(Geschichte.ziel(zs)), 14, Color(Stil.TEXT, 0.72)))
	var ort := String(d.get("ort", {}).get("karte", ""))
	var karten = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json")) if FileAccess.file_exists("res://daten/karten.json") else null
	if karten is Dictionary and karten["karten"].has(ort): ort = Sprache.t(karten["karten"][ort]["name"])
	var m := int(z.get("minuten", 0))
	# Helfer 11:28: „Tag 1 · 09:40“ brach hinter dem Ort um, die Uhr stand allein: Tag und Uhr bleiben zusammen (geschuetzte Leerzeichen)
	var tag_uhr := ("%s %d · %02d:%02d" % ["Tag" if de else "Day", int(z.get("tag", 1)), m / 60, m % 60]).replace(" ", "\u00a0")
	v.add_child(_satz(ort + " · " + tag_uhr, 14, Stil.DIM))
	if mit["werte"]:   # Vorschlag 3: Gold und Trefferpunkte klein
		var hw := Heldwerte.aus_daten(h)
		v.add_child(_satz("%d %s · %s %d/%d" % [int(z.get("gold", 0)), "Gold", "TP" if de else "HP", hw.tp, hw.max_tp()], 14, Stil.DIM))
	var t := gespeichert_um(d)
	if not t.is_empty():
		var s := ("%02d.%02d.%04d, %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]) if de else ("%04d-%02d-%02d, %02d:%02d" % [t.year, t.month, t.day, t.hour, t.minute])
		v.add_child(_satz(("Gespeichert: " if de else "Saved: ") + s, 13, Stil.DIM))
	var g := _satz(gespielt(int(z.get("gespielt_ms", 0)), de), 13, Stil.DIM)
	g.name = "Gespielt"
	v.add_child(g)
	r.add_child(v)
	r.add_child(_wahl(("Weiter" if de else "Continue") if weiter else ("Laden" if de else "Load")))
	var rand := MarginContainer.new()
	rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rand.add_theme_constant_override("margin_top", int(12 * DP)); rand.add_theme_constant_override("margin_bottom", int(4 * DP))
	rand.add_child(r)
	aussen.add_child(tippbar(rand, func(): laden.emit(platz)))
	# Loeschen leise darunter, eingerueckt unter die Zeilen (weit weg von „Laden“), eigene Flaeche von 48 dp, mit Rueckfrage
	var lz := HBoxContainer.new()
	lz.add_theme_constant_override("separation", int(6 * DP))
	lz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lz.custom_minimum_size.y = 48 * DP
	lz.add_child(Erschaffung.luecke(0, 150 * 0.4 + 14 - 6))
	var kr := Rastzeichen.neu("KREUZ", 16, Stil.DIM)
	kr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lz.add_child(kr)
	var lt := Stil.zeile("Löschen" if de else "Delete", 14, Stil.DIM)
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lz.add_child(lt)
	var weg := tippbar(lz, func(): frage_loeschen(d))
	weg.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	aussen.add_child(weg)
	return aussen

# rechts die Wahl in Gold mit „›“ (Hauptwahl)
func _wahl(text: String) -> Control:
	var l := Stil.zeile(text.to_upper() + "  ›", 15, Stil.GOLD, 2.0)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l

func _satz(t: String, sp_: float, farbe: Color) -> Label:
	var l := Stil.zeile(t, sp_, farbe)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 60 * DP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _linie() -> Control:
	var c := ColorRect.new()
	c.color = Stil.RIM
	c.custom_minimum_size = Vector2(0, maxf(1.0, round(DP * 0.6)))
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

# feine Goldlinie mit einer Raute in der Mitte (wie 549 B)
func _zier() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 14 * DP)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func():
		var mi := c.size / 2
		var w := 1.0 * DP
		c.draw_line(Vector2(c.size.x * 0.12, mi.y), Vector2(mi.x - 9 * DP, mi.y), Stil.RIM, w, true)
		c.draw_line(Vector2(mi.x + 9 * DP, mi.y), Vector2(c.size.x * 0.88, mi.y), Stil.RIM, w, true)
		var r := 4.5 * DP
		c.draw_polyline(PackedVector2Array([mi + Vector2(0, -r), mi + Vector2(r, 0), mi + Vector2(0, r), mi + Vector2(-r, 0), mi + Vector2(0, -r)]), Stil.GOLD, w, true))
	return c

# eine Flaeche zum Antippen ueber die ganze Breite (wie Rastfeld._tippbar): gedrueckt der erhabene Grund, ausgeloest beim Loslassen darauf
static func tippbar(inhalt: Control, was: Callable) -> PanelContainer:
	var p := PanelContainer.new()
	var leer := StyleBoxEmpty.new()
	var gedrueckt := Stil.kasten(Stil.RAISED, Color(0, 0, 0, 0), 0.0)
	p.add_theme_stylebox_override("panel", leer)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(inhalt)
	p.gui_input.connect(func(e: InputEvent):
		if not (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT) and not e is InputEventScreenTouch: return
		if e.pressed: p.add_theme_stylebox_override("panel", gedrueckt)
		else:
			p.add_theme_stylebox_override("panel", leer)
			if Rect2(Vector2.ZERO, p.size).has_point(e.position): was.call())
	return p
