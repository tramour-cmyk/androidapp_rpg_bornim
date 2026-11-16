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
# Chef 12:38 („557 B, mit 2, Löschen wie Sokrates“): Zeile Kapitel und Hauptauftrag immer; Vorschlaege 1 (Weiter steht im Hauptmenue,
# 12:35) und 3 entfallen. Schaltflaechen in drei Stufen (549a Punkt 4): Hauptwahl „LADEN ›“ hell golden, Nebenwahl gleich gesetzt
# (Versalien, gesperrt), kleiner, gedaempftes Gold, eigenes Zeichen („× LÖSCHEN“, „‹ ZURÜCK“), Gefahr in Warnfarbe erst in der Rueckfrage
static var entwurf := "B"   # 557 eingeschaltet (Archiv 05.11., 08:18: „557 wie gebaut“; Runde 5 Vorlage 2 mit Mängelton, Chef 04.11., 19:54)
# 557 Vorlage 2 (Chef 04.11., 14:21–14:26, Zu 557): zuschaltbar neben B, damit jedes Bild heute (B) neben neu zeigt: Rueckfragen
# und Mengenkasten ohne Rahmen, sichtbares „‹ ABBRECHEN“ links in jedem Fenster mit einer Wahl, der Knopf unten folgt dem Inhalt,
# solange alles auf einen Schirm passt (fest unten nur, wenn die Liste rollt; Votum Perikles 14:2x)
static var vorlage2 := true   # 557: Vorlage 2 ist die abgenommene (Mängelton nur dort)
static var mit := {"ziel": true}
# 557 (Chef 16:42, 16:51; Zu 557 (8)): kleine Angaben (Reicht für, Im Besitz, Gold, Stufe, Händler zahlt, Angelegt) mindestens 13 sp
# und deutlich heller als Veil.dim (948a78), aber unter dem Text (e6ddcb)
const ANGABE := Color("cfc3ab")
# 557 Runde 5 (Chef 19:19, Prüfer 18:21: dieselbe Warnfarbe stand auch bei „Schlechter“, „Fehlt“, „nicht tragen“): die Warnfarbe nur
# für das, was etwas zerstört (× WEGWERFEN, × LÖSCHEN); Mängel und Fehlendes in einem stillen, grauen Rot
const MANGEL := Color("b08a80")
static func mangel() -> Color: return MANGEL if vorlage2 else Stil.WARN
# 557 Runde 5 (Prüfer 18:21, Bilder 3, 4: einzelne Wörter allein in der zweiten Zeile): die letzten zwei Wörter fest verbunden, so bricht
# nie ein Wort allein um (nur bei mehr als drei Wörtern, sonst bliebe eine kurze Zeile ganz stehen)
static func ohne_waise(t: String) -> String:
	if not vorlage2 or t.count(" ") < 3: return t
	var i := t.rfind(" ")
	return t.substr(0, i) + "\u00a0" + t.substr(i + 1)

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
	spalte.add_child(Stil.rahmen(kopf))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", int(10 * DP))
	rolle.add_child(liste)
	spalte.add_child(Stil.knopf(Sprache.u("back"), func(): zurueck.emit()))   # BackRow
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
			v.add_child(Stil.txt(("Platz %d · leer" if de else "Slot %d · empty") % n, 17, Stil.DIM))
			v.add_child(Stil.luecke(8))
			v.add_child(Stil.knopf(Sprache.u("newGame"), func(): neu.emit(n)))
			liste.add_child(Stil.rahmen(v))
			continue
		var k := karte(d)
		var knoepfe := HBoxContainer.new()
		knoepfe.add_theme_constant_override("separation", int(8 * DP))
		var weg := Stil.knopf("Löschen" if de else "Delete", func(): frage_loeschen(d))
		knoepfe.add_child(weg)
		if not Spielstand.alt(d):   # 870.8: alte nur loeschen
			var los := Stil.knopf("Laden" if de else "Load", func(): laden.emit(n))
			los.size_flags_stretch_ratio = 2.0
			knoepfe.add_child(los)
		var innen: VBoxContainer = k.get_child(0)   # 529: aussen (Bild und Zeilen), darunter die Knoepfe
		innen.add_child(Stil.luecke(8))
		innen.add_child(knoepfe)
		liste.add_child(k)

# SlotCard: Bild, Platz und Name, Volk · Herkunft · Heldenstufe (870.4), Ort · Tag · Uhrzeit, gespeichert am, gespielt
# [rahmen] = false (700, 549a): ohne Kasten, als Inhalt einer antippbaren Zeile (Platzwahl der Erschaffung)
static func karte(d: Dictionary, rahmen := true) -> PanelContainer:
	var de := Sprache.aktiv() == "de"
	var h: Dictionary = d.get("held", {})
	var z: Dictionary = d.get("zustand", {})
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	var n := Stil.zeile((("Platz %d · " if de else "Slot %d · ") % int(d["platz"]) + String(h.get("name", ""))).to_upper(), 14, Stil.GOLD, 3.0)   # MenuHead
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(n)
	if Spielstand.alt(d): v.add_child(Stil.txt(alt_satz(de), 14, Stil.WARN))   # 870.8
	else: v.add_child(Stil.txt(ErschaffungBrs.wer(String(h.get("volk", "Mensch")), String(h.get("herkunft", BrsHeld.WANDERER)), int(h.get("stufe", 1))), 14))   # 870.4
	var ort := String(d.get("ort", {}).get("karte", ""))
	var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json")) if FileAccess.file_exists("res://daten/karten.json") else null
	if alle is Dictionary and alle["karten"].has(ort): ort = Sprache.t(alle["karten"][ort]["name"])
	var m := int(z.get("minuten", 0))
	v.add_child(Stil.txt("%s · %s %d · %02d:%02d" % [ort, "Tag" if de else "Day", int(z.get("tag", 1)), m / 60, m % 60], 13, Stil.DIM))
	var t := gespeichert_um(d)
	if not t.is_empty():
		var s := ("%02d.%02d.%04d, %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]) if de else ("%04d-%02d-%02d, %02d:%02d" % [t.year, t.month, t.day, t.hour, t.minute])
		v.add_child(Stil.txt(("Gespeichert: " if de else "Saved: ") + s, 12, Stil.DIM))
	var g := gespielt(int(z.get("gespielt_ms", 0)), de)
	var gl := Stil.txt(g, 12, Stil.DIM)
	gl.name = "Gespielt"
	v.add_child(gl)
	# HeroStill links neben den Zeilen (alt 10 dp Abstand); die Knoepfe haengt baue() unter beides
	var aussen := VBoxContainer.new()
	aussen.add_theme_constant_override("separation", 0)
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", int(10 * DP))
	if not Spielstand.alt(d):   # 870.8: der alte Held laesst sich nach BRS nicht zeichnen
		var bild := Drehteller.new(heldbild(d), 0.4, false)
		bild.name = "Heldbild"
		bild.mouse_filter = Control.MOUSE_FILTER_IGNORE   # Antippen gehoert der Karte (Erschaffung: Platz waehlen)
		reihe.add_child(bild)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reihe.add_child(v)
	aussen.add_child(reihe)
	if not rahmen:
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p.add_child(aussen)
		return p
	return Stil.rahmen(aussen)

# 870.8 (870a 1, DESIGN-BRS 11): Hinweis an einem Spielstand der Version 1
static func alt_satz(de: bool) -> String:
	return "Aus der alten Regelfassung, nicht mehr spielbar" if de else "From the old rules version, no longer playable"

# HeldFigur.wahl aus dem gespeicherten Helden; {} wenn der Spielstand nichts hergibt (dann der Grundheld)
static func heldbild(d: Dictionary) -> Dictionary:
	if not (d.get("held") is Dictionary and d.get("zustand") is Dictionary): return {}
	return HeldFigur.wahl(BrsHeld.aus_spiel_daten(d["held"]), Zustand.aus_daten(d["zustand"]))

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
	if entwurf == "B" and vorlage2:   # Chef 14:21: „Warum ist der Löschdialog dann wieder so kastelig?“
		var f := Spielstaende.frage(self, ("Spielstand löschen?" if de else "Delete saved game?"),
			[Stil.txt(("%s (Stufe %d) wird endgültig gelöscht." if de else "%s (level %d) will be deleted for good.") % [String(h.get("name", "")), int(h.get("stufe", 1))], 15)],
			"KREUZ", "Löschen" if de else "Delete", Stil.WARN, func():
				Spielstand.loesche(int(d["platz"]))
				baue())
		liste.modulate.a = 0.0
		f.tree_exited.connect(func(): if is_instance_valid(liste): liste.modulate.a = 1.0)
		return
	var schleier := Rueckfrage.schleier(self)   # 526: Tippen daneben und Android-Zurück wie „Abbrechen“ (alt SlotsScreen BackHandler)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(10 * DP))
	# 557: schmaler als die Liste (Helfer 11:28; 11:36: so breit wie die Liste, ihr Rand schnitt „Platz 3 · leer“): B deutlich schmaler
	v.custom_minimum_size.x = get_viewport_rect().size.x - (110 if entwurf == "B" else 48) * DP
	var k := Rueckfrage.halte(Stil.rahmen(v))
	mitte.add_child(k)
	if entwurf == "B":   # Helfer 13:04: „Neues Spiel“ schien am Rand durch; 13:07 bei 93 % noch lesbar: deckend, die Liste wird ausgeblendet
		schleier.color = Color(0, 0, 0, 0.97)
		liste.modulate.a = 0.0
		schleier.tree_exited.connect(func(): if is_instance_valid(liste): liste.modulate.a = 1.0)
	v.add_child(Stil.zeile(("Spielstand löschen?" if de else "Delete saved game?").to_upper(), 14, Stil.GOLD, 3.0))
	var t := Stil.txt(("%s (Stufe %d) wird endgültig gelöscht." if de else "%s (level %d) will be deleted for good.") % [String(h.get("name", "")), int(h.get("stufe", 1))], 15)
	v.add_child(t)
	var knoepfe := HBoxContainer.new()
	knoepfe.add_theme_constant_override("separation", int(8 * DP))
	knoepfe.add_child(Stil.knopf("Abbrechen" if de else "Cancel", func(): schleier.queue_free()))
	var weg := Stil.knopf("Löschen" if de else "Delete", func():
		Spielstand.loesche(int(d["platz"]))
		schleier.queue_free()
		baue())
	if entwurf == "B":   # 557 (Helfer 11:28: beide Knoepfe gleich; 11:36: nur die Schrift abgehoben): Gefahr in Warnfarbe mit Rand und Zeichen,
		# Abbrechen als Nebenwahl in gedaempftem Gold (549a Punkt 4)
		weg.text = "×  " + weg.text
		for f in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]: weg.add_theme_color_override(f, Stil.WARN)
		for st in ["normal", "hover", "focus"]: weg.add_theme_stylebox_override(st, Stil.kasten(Color.BLACK, Stil.WARN, 1.5))
		var ab: Button = knoepfe.get_child(0)
		for f in ["font_color", "font_hover_color", "font_focus_color", "font_hover_pressed_color"]: ab.add_theme_color_override(f, Stil.GOLD)
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
	spalte.add_child(Stil.luecke(6))
	spalte.add_child(zier())
	spalte.add_child(Stil.luecke(10))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", 0)
	rolle.add_child(liste)
	spalte.add_child(linie())
	if vorlage2:   # 557 Runde 4 (Chef 17:40, 549a (9)): „‹ ZURÜCK“ links, nicht mittig, so gross wie jeder Knopf
		spalte.add_child(knopfzeile(knopf("neben", Sprache.u("back"), func(): zurueck.emit(), true), null))
		folge_inhalt(spalte, rolle, liste)   # 557a B (Chef 20:52 zu Bild 12): „Zurück“ fest unten nur, wenn die Liste rollt
		baue()
		return
	var z := HBoxContainer.new()
	z.custom_minimum_size.y = 52 * DP
	z.alignment = BoxContainer.ALIGNMENT_CENTER
	z.mouse_filter = Control.MOUSE_FILTER_IGNORE
	z.add_child(Stil.zeile("‹  " + Sprache.u("back").to_upper(), 14, Stil.GOLD, 2.0))   # Nebenwahl (549a Punkt 4)
	spalte.add_child(tippbar(z, func(): zurueck.emit()))
	baue()

func _baue_b(de: bool) -> void:
	var plaetze := []   # [Nummer, Spielstand oder {}]
	for d in Spielstand.liste(): plaetze.append([plaetze.size() + 1, d])
	for p in plaetze:
		if liste.get_child_count() > 0: liste.add_child(linie())
		var d: Dictionary = p[1]
		liste.add_child(_leer_zeile(int(p[0]), de) if d.is_empty() else _voll_zeile(d, de))

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

func _voll_zeile(d: Dictionary, de: bool) -> Control:
	var h: Dictionary = d.get("held", {})
	var z: Dictionary = d.get("zustand", {})
	var platz := int(d["platz"])
	var aussen := VBoxContainer.new()
	aussen.add_theme_constant_override("separation", 0)
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(14 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var alt := Spielstand.alt(d)   # 870.8: ohne Bild, Ziel und Laden, nur Hinweis und Loeschen
	if not alt:
		var bild := Drehteller.new(heldbild(d), 0.4, false)
		bild.name = "Heldbild"
		bild.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.add_child(bild)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(2 * DP))
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var kopf := Stil.zeile((("Platz %d · " if de else "Slot %d · ") % platz + String(h.get("name", ""))).to_upper(), 14, Stil.GOLD, 2.5)
	kopf.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(kopf)
	if alt: v.add_child(_satz(alt_satz(de), 16, Stil.WARN))
	else: v.add_child(_satz(ErschaffungBrs.wer(String(h.get("volk", "Mensch")), String(h.get("herkunft", BrsHeld.WANDERER)), int(h.get("stufe", 1))), 16, Stil.TEXT))   # 870.4
	if mit["ziel"] and not alt:   # Vorschlag 2 (Chef 12:38 „mit 2“): wo man steht, damit man nach Tagen weiss, was zu tun ist (Hauptauftrag der Chronik)
		var zs := Zustand.aus_daten(z)
		# Helfer 11:28, 11:36: in BRIGHT, dann gedaempftem Weiss noch so hell wie die Wahl und zog den Blick; 13:07 bei 62 % Weiss kaum als
		# gedaempft zu erkennen: in gedaempftem Gold (eigene Farbe, nicht die der Angaben), schraeg, mit Abstand davor und danach
		v.add_child(Stil.luecke(3))
		v.add_child(_satz(("Kapitel %d · " if de else "Chapter %d · ") % Geschichte.kapitel(zs) + Sprache.t(Geschichte.ziel(zs)), 14, Stil.GOLD, true))
		v.add_child(Stil.luecke(3))
	var ort := String(d.get("ort", {}).get("karte", ""))
	var karten = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json")) if FileAccess.file_exists("res://daten/karten.json") else null
	if karten is Dictionary and karten["karten"].has(ort): ort = Sprache.t(karten["karten"][ort]["name"])
	var m := int(z.get("minuten", 0))
	# Helfer 11:28: „Tag 1 · 09:40“ brach hinter dem Ort um, die Uhr stand allein: Tag und Uhr bleiben zusammen (geschuetzte Leerzeichen)
	var tag_uhr := ("%s %d · %02d:%02d" % ["Tag" if de else "Day", int(z.get("tag", 1)), m / 60, m % 60]).replace(" ", "\u00a0")
	# Helfer 11:36: „Zum Schlafenden Greif ·“ endete mit dem Punkt; 13:04 mit festem Punkt brach der Name selbst um: Ort und Tag je eine Zeile
	v.add_child(_satz(ort, 14, Stil.DIM))
	v.add_child(_satz(tag_uhr, 13, Stil.DIM))
	var t := gespeichert_um(d)
	if not t.is_empty():
		var s := ("%02d.%02d.%04d, %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]) if de else ("%04d-%02d-%02d, %02d:%02d" % [t.year, t.month, t.day, t.hour, t.minute])
		v.add_child(_satz(("Gespeichert: " if de else "Saved: ") + s, 13, Stil.DIM))
	var g := _satz(gespielt(int(z.get("gespielt_ms", 0)), de), 13, Stil.DIM)
	g.name = "Gespielt"
	v.add_child(g)
	r.add_child(v)
	if not alt: r.add_child(_wahl("Laden" if de else "Load"))
	var rand := MarginContainer.new()
	rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rand.add_theme_constant_override("margin_top", int(12 * DP)); rand.add_theme_constant_override("margin_bottom", int(4 * DP))
	rand.add_child(r)
	aussen.add_child(rand if alt else tippbar(rand, func(): laden.emit(platz)))
	# Loeschen leise darunter, rechts unter „Laden“ (Helfer 13:07: stand links unter den Angaben), mit eigener Flaeche von 48 dp und
	# Abstand nach oben, damit es kein Fehlgriff wird; mit Rueckfrage
	if vorlage2:   # 557 Runde 4 (Chef 17:43): „× LÖSCHEN“ wie Wegwerfen in Warnfarbe, gleich gross wie jeder Knopf, rechts unter „LADEN ›“
		aussen.add_child(knopfzeile(null, knopf("gefahr", "Löschen" if de else "Delete", func(): frage_loeschen(d))))
		return aussen
	var weg := nebenwahl("KREUZ", "Löschen" if de else "Delete", func(): frage_loeschen(d))
	weg.size_flags_horizontal = Control.SIZE_SHRINK_END
	aussen.add_child(weg)
	return aussen

# 557 Vorlage 2: Fenster ohne Rahmen (Chef 14:21, 14:25): fast schwarzer Grund, Titel in Gold zwischen Zierlinie und Linie, Zeilen,
# Linie, unten „‹ ABBRECHEN“ links (Nebenwahl), die Wahl rechts (Gefahr in Warnfarbe mit Zeichen); Zurueck und Tippen daneben
# schliessen wie Abbrechen (526). Gibt den Schleier zurueck; [tat] laeuft nach dem Schliessen
# 557a B (Chef 04.11., 20:55, Archiv): auf jedem Fenster und Schirm beginnt der Inhalt oben, der Kopf (Titel, Bild und Name, Zeichen)
# in derselben Hoehe wie der Titel jedes Schirms (Rand oben 36 dp), die Knoepfe direkt unter dem Inhalt; statt CenterContainer
const OBEN_DP := 36.0

static func oben() -> MarginContainer:
	var m := MarginContainer.new()
	m.name = "Oben"
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_top", int(OBEN_DP * DP))
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.child_entered_tree.connect(func(k: Node):
		if k is Control:
			(k as Control).size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			(k as Control).size_flags_horizontal = Control.SIZE_SHRINK_CENTER)
	return m

# 630 (549a „Schirm“): ganzer Bildschirm rein schwarz, Seitenrand 24 dp, oben der Titel (22 sp Versalien gesperrt, Gold, mittig) in
# derselben Hoehe wie jeder Schirm (OBEN_DP), genau eine Zierlinie, dann der Inhalt (rollt, wenn er nicht passt), eine schlichte Linie
# und unten links „‹ ZURÜCK“. Gibt {seite, spalte, inhalt, rolle} zurueck; „‹ ZURÜCK“ und Android-Zurück schliessen ihn, dann [zurueck]
static func schirm(eltern: Node, titel: String, zurueck: Callable, abstand_dp := 10.0) -> Dictionary:
	var seite := Control.new()
	seite.name = "Schirm"
	seite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	eltern.add_child(seite)
	var zu := func(): seite.queue_free(); zurueck.call()
	Zurueck.melde(seite, zu)   # 526
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	seite.add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right"]: rand.add_theme_constant_override("margin_" + s, int(24 * DP))
	rand.add_theme_constant_override("margin_top", int(OBEN_DP * DP)); rand.add_theme_constant_override("margin_bottom", int(12 * DP))
	seite.add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.name = "Spalte"
	spalte.add_theme_constant_override("separation", int(10 * DP))
	rand.add_child(spalte)
	var t := Stil.zeile(titel.to_upper().replace("ß", "SS"), 22, Stil.GOLD, 3.0)
	t.name = "Titel"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(t)
	spalte.add_child(zier())
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	spalte.add_child(rolle)
	var inhalt := VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", int(abstand_dp * DP))
	rolle.add_child(inhalt)
	spalte.add_child(linie())
	spalte.add_child(knopfzeile(knopf("neben", Sprache.u("back"), zu, true), null))
	folge_inhalt(spalte, rolle, inhalt)
	return {"seite": seite, "spalte": spalte, "inhalt": inhalt, "rolle": rolle}

static func frage(eltern: Control, titel: String, zeilen: Array, zeichen: String, wahl: String, farbe: Color, tat: Callable, an := true) -> ColorRect:
	var de := Sprache.aktiv() == "de"
	var schleier := Rueckfrage.schleier(eltern)
	schleier.color = Color.BLACK   # Pruefer 16:40: bei 0,97 schien die Liste (Werte, Rezepte) durch und ueberlappte den Text
	var mitte := oben()   # 557a B
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = eltern.get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Rueckfrage.halte(v))
	# Chef 16:51 (549a (8): „für jedes Fenster gleich“): oben der Titel, darunter genau eine Zierlinie mit Raute, keine Linie darueber
	# und keine zweite schlichte darunter; dann Inhalt, schlichte Linie, Knoepfe
	var t := Stil.zeile(titel.to_upper().replace("ß", "SS"), Stil.TITEL_SP, Stil.GOLD, 3.0)   # 586a: so gross wie die Titel der Schirme
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(t)
	v.add_child(zier())
	for z in zeilen:
		v.add_child(z)
		# 557 Runde 5 (Chef 19:23: „zentrieren“): Rückfragen mittig wie der Titel, Text bis drei Zeilen; mehr linksbündig
		if z is Label:
			var l := z as Label
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.resized.connect(func(): l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if l.get_line_count() <= 3 else HORIZONTAL_ALIGNMENT_LEFT)
	v.add_child(linie())
	v.add_child(fuss(func(): schleier.queue_free(), zeichen, wahl, farbe, func(): schleier.queue_free(); tat.call(), an))
	return schleier

# unten in einem Fenster: „‹ ABBRECHEN“ links, die Wahl rechts (Chef 14:26: „vor allem fehlt bei Bild 8 das Abbrechen“).
# 557 Runde 4 (Chef 17:40–17:44, 549a (4), (9)): alle Knoepfe gleich gross (knopf, knopfzeile); [oben]: weitere Knoepfe (Gegenstands-
# fenster: „× WEGWERFEN“ links, „NEBENHAND ›“ rechts) stehen als eigene Reihe darueber, denn drei passen auf 360 dp nicht in eine
# Zeile (je Knopf etwa 130–145 dp, Fenster 312 dp); die Wahl in Warnfarbe mit „×“, wenn [farbe] die Warnfarbe ist
static func fuss(abbrechen: Callable, _zeichen: String, wahl: String, farbe: Color, tat: Callable, an := true, oben: Array = []) -> Control:
	var de := Sprache.aktiv() == "de"
	var unten := knopfzeile(knopf("neben", "Abbrechen" if de else "Cancel", abbrechen, true),
		knopf("gefahr" if farbe == Stil.WARN else "haupt", wahl, tat, false, an))
	if oben.is_empty(): return unten
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l: Array = oben.filter(func(k): return bool(k.get_meta("links", false)))
	var r: Array = oben.filter(func(k): return not bool(k.get_meta("links", false)))
	v.add_child(knopfzeile(l[0] if not l.is_empty() else null, r[0] if not r.is_empty() else null))
	v.add_child(unten)
	return v

# 557 Runde 4 (Chef 17:44: „dass wir die Knöpfe gleich groß machen“; 17:40: „ein Weiter, wenn dann rechts und ein Zurück auf der
# linken Seite“; 17:43: Wegwerfen in Bild 2 rot, in Bild 5 nicht): eine Schaltflaeche fuer jedes Fenster, alle gleich gross: 15 sp in
# gesperrten Versalien, Flaeche 48 dp, in der Reihe je die halbe Breite (knopfzeile); Unterschied nur Farbe und Seite. [art]: "haupt"
# Gold mit „›“; "neben" gedaempftes Gold, mit „‹“ vorn, wenn [links] (zurueck, abbrechen, schliessen), sonst mit „›“; "gefahr" (was
# etwas zerstoert: Wegwerfen, Loeschen) ueberall in Warnfarbe mit „×“. [links]: steht links, Inhalt buendig links; sonst rechts,
# buendig rechts; nie mittig
static func knopf(art: String, text: String, tat: Callable, links := false, an := true) -> PanelContainer:
	var farbe: Color = {"haupt": Stil.BRIGHT, "neben": Stil.GOLD, "gefahr": Stil.WARN}.get(art, Stil.GOLD)
	if not an: farbe = Color(Stil.DIM, 0.75)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(6 * DP))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.custom_minimum_size.y = 48 * DP
	h.alignment = BoxContainer.ALIGNMENT_BEGIN if links else BoxContainer.ALIGNMENT_END
	# ohne Innenrand: das Zeichen steht buendig mit dem Text darueber, und „× WEGWERFEN“ passt auf 360 dp in die halbe Breite
	if art == "gefahr":
		var kr := Rastzeichen.neu("KREUZ", 15, farbe)
		kr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(kr)
	elif links: h.add_child(pfeil(farbe, true))
	var l := Stil.zeile(text.trim_prefix("‹").strip_edges().to_upper().replace("ß", "SS"), 15, farbe, 2.0)   # Helfer 14:18: „SCHLIEßEN“
	l.name = "Text"
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(l)
	if art != "gefahr" and not links: h.add_child(pfeil(farbe, false))
	var p := tippbar(h, tat if an else func(): pass)
	p.set_meta("knopf", art)
	p.set_meta("links", links)
	p.set_meta("an", an)   # 630: Tests erkennen gesperrte Knoepfe
	return p

# eine Reihe Knoepfe: [links] links, [rechts] rechts (null: frei), jeder die halbe Breite, damit alle Knoepfe eines Fensters gleich
# gross sind, auch einer allein (Brauen „‹ SCHLIESSEN“, Kapitelende „WEITER ›“)
static func knopfzeile(links: Control, rechts: Control) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for k in [links, rechts]:
		var c: Control = k
		if c == null:
			c = Control.new()
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.size_flags_stretch_ratio = 1.0
		r.add_child(c)
	return r

# 557 Vorlage 2 (Votum Perikles 14:2x, Chef 14:21 zu Bild 6 und 7): der Teil unter der Liste folgt dem Inhalt, solange alles passt;
# rollt die Liste, steht er fest unten. [rolle] liegt in [spalte]; dahinter kommt ein dehnbarer Rest, der die Luecke unten nimmt
static func folge_inhalt(spalte: VBoxContainer, rolle: ScrollContainer, innen: Control) -> void:
	rolle.size_flags_vertical = Control.SIZE_FILL
	var rest := Control.new()
	rest.name = "Rest"
	rest.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spalte.add_child(rest)
	var passe := func():
		var andere := 0.0
		for c in spalte.get_children():
			if c != rolle and c != rest and c is Control and (c as Control).visible: andere += (c as Control).get_combined_minimum_size().y
		# 603 (Laden mit voller Tasche, Test wischen_571): die Spalte waechst mit der Liste ueber den Schirm, dann ist spalte.size kein
		# Mass mehr (die Liste blieb 4000 px hoch auf 2400, nichts rollte); frei ist, was der Rand (MarginContainer) vom Schirm laesst
		var hoehe := spalte.size.y
		var rand := spalte.get_parent()
		if rand is MarginContainer and not (rand.get_parent() is Container):
			hoehe = (rand as Control).get_parent_area_size().y - rand.get_theme_constant("margin_top") - rand.get_theme_constant("margin_bottom")
		var frei := hoehe - andere - spalte.get_theme_constant("separation") * maxi(0, spalte.get_child_count() - 1)
		var h := minf(innen.get_combined_minimum_size().y, maxf(0.0, frei))
		if absf(rolle.custom_minimum_size.y - h) > 0.5: rolle.custom_minimum_size.y = h
	innen.minimum_size_changed.connect(passe)
	spalte.resized.connect(passe)
	passe.call_deferred()

# Nebenwahl (549a Punkt 4): Versalien gesperrt wie die Hauptwahl, kleiner, gedaempftes Gold, eigenes Zeichen, Flaeche 48 dp
static func nebenwahl(zeichen: String, text: String, tat: Callable, an := true) -> PanelContainer:
	# nur noch Entwurf B ohne Vorlage 2; mit Vorlage 2 gilt knopf (557 Runde 4: alle Knoepfe gleich gross, keine leise Stufe)
	var lz := HBoxContainer.new()
	lz.add_theme_constant_override("separation", int(6 * DP))
	lz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lz.custom_minimum_size.y = 48 * DP
	lz.alignment = BoxContainer.ALIGNMENT_CENTER
	lz.add_child(Stil.luecke(0, 8))
	var f := Stil.GOLD if an else Color(Stil.DIM, 0.6)
	if zeichen != "":
		var kr := Rastzeichen.neu(zeichen, 14, f)
		kr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lz.add_child(kr)
	var lt := Stil.zeile(text.to_upper().replace("ß", "SS"), 12.5, f, 2.0)   # Helfer 14:18: „SCHLIEßEN“
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lz.add_child(lt)
	lz.add_child(Stil.luecke(0, 8))
	var p := tippbar(lz, tat if an else func(): pass)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return p

# Hauptwahl als eigene Flaeche (48 dp), hell golden mit „›“; aus: matt ohne Wirkung
static func hauptwahl(text: String, tat: Callable, an := true) -> PanelContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(8 * DP))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.custom_minimum_size.y = 48 * DP
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_child(Stil.luecke(0, 8))
	h.add_child(wahl_b(text, Stil.BRIGHT if an else Color(Stil.DIM, 0.6)))
	h.add_child(Stil.luecke(0, 8))
	var p := tippbar(h, tat if an else func(): pass)
	p.size_flags_horizontal = Control.SIZE_SHRINK_END
	return p

# rechts die Hauptwahl hell golden mit „›“; Helfer 11:36: „›“ klein und etwas tief, darum eigenes Zeichen, groesser, mittig zur Schrift
func _wahl(text: String) -> Control: return wahl_b(text, Stil.BRIGHT)

static func wahl_b(text: String, farbe: Color) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(8 * DP))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var l := Stil.zeile(text.to_upper().replace("ß", "SS"), 15, farbe, 2.0)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(l)
	h.add_child(pfeil(farbe, false))
	return h

# „›“ (links: „‹“) als gezeichnetes Zeichen, mittig zur Schrift
static func pfeil(farbe: Color, links: bool) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(9 * DP, 16 * DP)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s := -1.0 if links else 1.0
	c.draw.connect(func():
		var m := c.size / 2
		var a := 4.0 * DP
		c.draw_polyline(PackedVector2Array([m + Vector2(-a * 0.55 * s, -a * 1.5), m + Vector2(a * 0.75 * s, 0), m + Vector2(-a * 0.55 * s, a * 1.5)]), farbe, 1.8 * DP, true))
	return c

func _satz(t: String, sp_: float, farbe: Color, schraeg := false) -> Label:
	var l := Stil.zeile(ohne_waise(t), sp_, farbe, 0.0, schraeg)   # 557 Runde 5 (Prüfer 19:47: „öffnen.“ allein)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 60 * DP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func linie() -> Control:
	var c := ColorRect.new()
	c.color = Stil.RIM
	c.custom_minimum_size = Vector2(0, maxf(1.0, round(DP * 0.6)))
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

# feine Goldlinie mit einer Raute in der Mitte (wie 549 B)
static func zier() -> Control:
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

## 860 (549a: „Gewählte Zeile oder gewählter Wert: Schrift BRIGHT auf RAISED, kein Rahmen“; Chef 10.11., 13:07, t274.10): Umschalter ohne
## Kasten (Chronik „Aufträge“ / „Bisher geschehen“, Filter der Karte); nicht gewählt gedämpftes Gold auf Schwarz, Schrift wie Knöpfe
static func wahl(text: String, tat: Callable, gewaehlt: bool, hoehe_dp := 48.0) -> PanelContainer:
	var l := Stil.zeile(text.to_upper().replace("ß", "SS"), 13, Stil.BRIGHT if gewaehlt else Stil.GOLD, 2.0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size.y = hoehe_dp * DP
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := tippbar(l, tat)
	p.name = "Wahl"
	p.set_meta("gewaehlt", gewaehlt)
	if gewaehlt: p.add_theme_stylebox_override("panel", Stil.kasten(Stil.RAISED, Color(0, 0, 0, 0), 0.0))
	return p

## 860: eine antippbare Zeile über die ganze Breite ohne Kasten (549a): links der Text, rechts das goldene „›“
static func zeile_mit_pfeil(text: String, tat: Callable, farbe := Stil.TEXT) -> PanelContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", int(8 * DP))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.custom_minimum_size.y = 48 * DP
	var l := Stil.txt(text, 15, farbe)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(l)
	h.add_child(pfeil(Stil.GOLD, false))
	return tippbar(h, tat)

# eine Flaeche zum Antippen ueber die ganze Breite (wie Rastfeld._tippbar): gedrueckt der erhabene Grund, ausgeloest beim Loslassen darauf
static func tippbar(inhalt: Control, was: Callable) -> PanelContainer:
	var p := PanelContainer.new()
	var leer := StyleBoxEmpty.new()
	var gedrueckt := Stil.kasten(Stil.RAISED, Color(0, 0, 0, 0), 0.0)
	p.add_theme_stylebox_override("panel", leer)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(inhalt)
	var ab := [Vector2.INF]
	p.gui_input.connect(func(e: InputEvent):
		if not tipp(e): return
		if e.pressed:
			p.add_theme_stylebox_override("panel", gedrueckt)
			ab[0] = e.global_position
		else:
			p.add_theme_stylebox_override("panel", leer)
			var gewischt: bool = ab[0] == Vector2.INF or (e.global_position as Vector2).distance_to(ab[0]) > WISCH * DP
			ab[0] = Vector2.INF
			if not gewischt and Rect2(Vector2.ZERO, p.size).has_point(e.position): was.call())
	return p

# 605 (Chef 07.11., 268.11: „muss 2x ‚Anlegen‘ gedrückt werden, ebenso 2x bei ‚Wegwerfen‘ und ‚Zurück‘“): auf dem Geraet kommt jede
# Beruehrung zweimal, als InputEventScreenTouch und als nachgebildete Maus (emulate_mouse_from_touch), am Rechner umgekehrt
# (emulate_touch_from_mouse); wer auf beide hoert, loest jeden Tipp zweimal aus (zwei Fenster uebereinander, Anlegen doppelt). Nur die
# linke Maustaste zaehlt (doppeltipp_605)
static func tipp(e: InputEvent) -> bool: return e is InputEventMouseButton and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT

# 617 (Chef 07.11., 268.1: „scrollen löst Laden leicht aus“): wer den Finger weiter als 12 dp schiebt, rollt und waehlt nichts (wie
# Zeichenknopf 571, Compose ueber der Beruehrschwelle)
const WISCH := 12.0
