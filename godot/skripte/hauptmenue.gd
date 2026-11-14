class_name Hauptmenue
extends Control
# 399 (Chef 28.10., 12:34: spielbar zuerst): Hauptmenue (292) und Erschaffung. Fortsetzen, wenn ein Spielstand liegt; Neues Spiel fuehrt
# in die Erschaffung (erschaffung_brs.gd, 470), „Spielstände“ zu den vier Plaetzen (spielstaende.gd). Ende: Signal fertig({"laden": true,
# "platz"}) oder fertig({"name", "brs", "aussehen", "platz"}) (870.4).
# 399.1 (Test 130, Chef 14:38: „Einfach mal das alte Spiel nehmen … so soll es im neuen halt auch schon“; 14:39 „an die
# Designvorgaben halten“): Aussehen wie App.kt MainMenuColumn (292.3, Entwurf A): schwarz, Titel gross in gesperrten Versalien, Zier,
# Kapitelzeile, das Bild der vier im warmen Lichtkegel (assets/menu/hauptmenue.jpg, im Bau kopiert), Hauptweg golden umrandet,
# Knoepfe schwarz mit duennem Rand, Sprache als kleines rundes Zeichen, Firmenzeichen und Versionszeile unten; Masse in dp wie alt.
# Liegt ueber allem (eigene Ebene), ohne die Probeknoepfe des Dorfs. Beim Kaltstart vorher der Vorspann (292), dann die Titelmusik.

signal fertig(wahl: Dictionary)

const DP := AktionsKnopf.DP
const BILD := "res://daten/hauptmenue.bild"   # JPEG (einst app/src/main/assets/menu), eingecheckt (870.9)
const LOGO := "res://bilder/logo-quer.svg"
const LOGO_SVG := "res://daten/logo.bild"       # 292 Vorspann: dasselbe SVG roh, im Bau kopiert
var st: Steuerung
var box: VBoxContainer

# Zier unter dem Titel wie alt: Linie 80 dp aus dem Nichts zum Rand, Raute 7 dp mit Goldrand, Linie zurueck ins Nichts
class Zier extends Control:
	func _init() -> void: custom_minimum_size = Vector2((80 + 8 + 7 + 8 + 80) * DP, 10 * DP)
	func _draw() -> void:
		var y := size.y * 0.5
		var l := 80 * DP
		var cx := size.x * 0.5
		draw_polyline_colors(PackedVector2Array([Vector2(cx - l - 11.5 * DP, y), Vector2(cx - 11.5 * DP, y)]), PackedColorArray([Color(Stil.RIM, 0.0), Stil.RIM]), DP)
		draw_polyline_colors(PackedVector2Array([Vector2(cx + 11.5 * DP, y), Vector2(cx + l + 11.5 * DP, y)]), PackedColorArray([Stil.RIM, Color(Stil.RIM, 0.0)]), DP)
		var r := 3.5 * DP * sqrt(2.0)
		draw_polyline(PackedVector2Array([Vector2(cx, y - r), Vector2(cx + r, y), Vector2(cx, y + r), Vector2(cx - r, y), Vector2(cx, y - r)]), Stil.GOLD, DP)

func _init(s: Steuerung) -> void:
	st = s
	name = "Hauptmenue"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	# Mitte wie alt (Column fillMaxSize, Arrangement.Center, Rand 24 dp); rollt, wenn es nicht passt (t69)
	var rolle := ScrollContainer.new()
	rolle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(rolle)
	var mitte := CenterContainer.new()
	mitte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mitte.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vs := get_viewport().get_visible_rect().size
	mitte.custom_minimum_size = vs - Vector2(0, Rand.oben(get_viewport()))   # 399.4: ohne den Rand oben
	rolle.add_child(mitte)
	box = VBoxContainer.new()
	box.custom_minimum_size.x = vs.x - 48 * DP
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	mitte.add_child(box)
	titel()
	if not vorspann_gezeigt: starte_vorspann()
	else: spiele_titel()
	if ueber_zuerst:   # 399.1 System „Über“ wie alt (vm.toMenu, Screen.ABOUT): speichern, ins Hauptmenue, gleich die Seite
		ueber_zuerst = false
		ueber()

static var ueber_zuerst := false

# ---------------------------------------------------------------- 292 Vorspann (Prelude.kt, App.kt MainMenuScreen)
# beim Kaltstart einmal: das Firmenzeichen mit „präsentiert“ und dem Klanglogo (292.1, nur mit Musik), dann schwarz und still
# (eine hoerbare Pause), dann der Name mit der Titelmusik, um den das Menue waechst; Tippen ueberspringt. Zeiten aus intro.json.
static var vorspann_gezeigt := false
var vorspann := {}
var vorspann_ms := 0.0
var name_bis := 0                                # Kinder von box, die mit dem Namen kommen (Titel, Zier, Kapitelzeile)
var firma: Control
var titelmusik := false

func klang() -> Node: return get_node_or_null("/root/Klang")

func spiele_titel() -> void:
	if titelmusik: return
	titelmusik = true
	if klang(): klang().spiele_szene("TITLE")   # 399.3 (Jerry): Titelmusik wie alt

func starte_vorspann() -> void:
	vorspann_gezeigt = true
	if not Zwischenbild.da():
		spiele_titel()
		return
	vorspann = Zwischenbild.daten().get("vorspann", {})
	firma = Control.new()
	firma.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	firma.mouse_filter = Control.MOUSE_FILTER_STOP   # das Menue darunter nimmt kein Tippen, bis es da ist
	firma.gui_input.connect(func(e: InputEvent):
		if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed): ende_vorspann())
	add_child(firma)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	firma.add_child(mitte)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", int(18 * DP))
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mitte.add_child(v)
	var tex := logo(240 * DP)
	if tex:
		var r := TextureRect.new()
		r.texture = tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.custom_minimum_size = Vector2(240, 240.0 * tex.get_height() / tex.get_width()) * DP
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(r)
	var p := Stil.zeile(Sprache.t(vorspann.get("praesentiert", {})), 15, Stil.DIM, 1.2)
	p.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(p)
	if klang() and klang().musik_an: klang().effekt("brand", 1.0)   # 292.1: das Klanglogo, mit dem Firmenzeichen; still ohne Musik
	stelle_vorspann()

# das Firmenzeichen [breite] Pixel breit, scharf aus dem SVG (daten/logo.bild, godot.yml); sonst das eingelesene (444 px)
static func logo(breite: float) -> Texture2D:
	var img := Image.new()
	if FileAccess.file_exists(LOGO_SVG) and img.load_svg_from_buffer(FileAccess.get_file_as_bytes(LOGO_SVG), breite / 444.0) == OK:
		return ImageTexture.create_from_image(img)
	return load(LOGO) if ResourceLoader.exists(LOGO) else null

static func rampe(t: float, von: float, bis: float) -> float: return clampf((t - von) / (bis - von), 0.0, 1.0)

# Prelude.firm, name, menu: wie viel Firmenzeichen, Name und uebriges Menue gerade zu sehen sind
func vorspann_bei(t: float) -> Array:
	var ein := float(vorspann["ein_ms"]); var steht := ein + float(vorspann["firma_ms"])
	var f := rampe(t, 0, ein) if t < ein else (1.0 if t < steht else 1.0 - rampe(t, steht, float(vorspann["firma_ende_ms"])))
	var n := float(vorspann["name_ms"])
	return [f, rampe(t, n, n + ein), rampe(t, float(vorspann["menue_ms"]), float(vorspann["ende_ms"]))]

func stelle_vorspann() -> void:
	var a := vorspann_bei(vorspann_ms) if not vorspann.is_empty() else [0.0, 1.0, 1.0]
	if firma: firma.modulate.a = a[0]
	for i in box.get_child_count():
		(box.get_child(i) as CanvasItem).modulate.a = a[1] if i < name_bis else a[2]

func _process(dt: float) -> void:
	if vorspann.is_empty(): return
	vorspann_ms += dt * 1000.0
	if vorspann_ms >= float(vorspann["name_ms"]): spiele_titel()
	if vorspann_ms >= float(vorspann["ende_ms"]): ende_vorspann()
	else: stelle_vorspann()

func ende_vorspann() -> void:
	vorspann = {}
	if firma: firma.queue_free(); firma = null
	stelle_vorspann()
	spiele_titel()

func leer() -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()

func abstand(dp: float) -> void:
	var c := Control.new()
	c.custom_minimum_size.y = dp * DP
	box.add_child(c)

func mittig(c: Control) -> Control:
	c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(c)
	return c

func zeile(t: String, groesse_sp: float, farbe: Color, sperrung_sp := 0.0) -> Label:
	var l := Stil.zeile(t, groesse_sp, farbe, sperrung_sp)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD   # nie mitten im Wort (Test 130: „Chronike / n“)
	box.add_child(l)
	return l

# 585 (Abgleich 512b): passt der Text nicht in eine Zeile, bricht er an dem Wortzwischenraum um, der beide Zeilen am gleichsten lang macht
# (wie die alte Fassung: Compose brach den Titel „CHRONIKEN / VON BORNIM“), statt so spaet wie moeglich („CHRONIKEN VON / BORNIM“)
static func ausgewogen(l: Label, breite: float) -> void:
	var f := l.get_theme_font("font")
	var g := l.get_theme_font_size("font_size")
	var w := l.text.split(" ", false)
	if f == null or w.size() < 2 or f.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x <= breite: return
	var best := ""
	var best_w := INF
	for i in range(1, w.size()):
		var a := " ".join(w.slice(0, i))
		var b := " ".join(w.slice(i))
		var m := maxf(f.get_string_size(a, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x, f.get_string_size(b, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x)
		if m <= breite and m < best_w: best_w = m; best = a + "\n" + b
	if best != "": l.text = best

# PixelButton im schwarzen Look: 48 dp hoch, schwarz, Rand 1 dp Veil.line, Versalien in gebrochenem Weiss, 13 sp, gesperrt 1,2 sp
func knopf(t: String, was: Callable, breite_dp := 280.0) -> Button:
	var b := Button.new()
	b.text = t.to_upper()
	b.custom_minimum_size = Vector2(breite_dp * DP, 48 * DP)
	b.add_theme_font_override("font", Stil.variante(1.2))
	b.add_theme_font_size_override("font_size", int(round(13 * Stil.SP)))
	b.add_theme_color_override("font_color", Stil.TEXT)
	b.add_theme_color_override("font_pressed_color", Stil.BRIGHT)
	b.add_theme_color_override("font_hover_color", Stil.TEXT)
	b.add_theme_color_override("font_focus_color", Stil.TEXT)
	for z in ["normal", "hover", "focus"]: b.add_theme_stylebox_override(z, Stil.kasten(Color.BLACK, Stil.LINE, 1.0))
	b.add_theme_stylebox_override("pressed", Stil.kasten(Stil.RAISED, Stil.BRIGHT, 1.5))
	b.pressed.connect(was)
	mittig(b)
	return b

# MainButton: der Hauptweg, Grund Veil.raised, Rand 1,5 dp Veil.bright, Wort in gesperrten Versalien, darunter klein wer und wo
func hauptknopf(t: String, unter: String, was: Callable) -> void:
	var b := Button.new()
	b.custom_minimum_size = Vector2(280 * DP, 62 * DP)
	for z in ["normal", "hover", "focus"]: b.add_theme_stylebox_override(z, Stil.kasten(Stil.RAISED, Stil.BRIGHT, 1.5))
	b.add_theme_stylebox_override("pressed", Stil.kasten(Color.BLACK, Stil.BRIGHT, 1.5))
	var sp := VBoxContainer.new()
	sp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sp.alignment = BoxContainer.ALIGNMENT_CENTER
	sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(sp)
	for z in [[t.to_upper(), 17, Stil.BRIGHT, 3.0], [unter, 13, Stil.DIM, 0.8]]:
		var l := Stil.zeile(z[0], z[1], z[2], z[3])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sp.add_child(l)
	b.pressed.connect(was)
	mittig(b)

# RoundSign: rundes Zeichen 46 dp mit duennem Goldrand; mit [glyphe] (Zeichenknopf.glyphe, Raster 22) statt Text ein Zeichen 22 dp,
# durchgestrichen und matt, wenn [an] falsch ist (App.kt SignGlyph)
func rundzeichen(t: String, was: Callable, glyphe := "", an := true) -> Button:
	var b := Button.new()
	b.text = t
	if glyphe != "":
		var z := Control.new()
		z.mouse_filter = Control.MOUSE_FILTER_IGNORE
		z.set_anchors_preset(Control.PRESET_FULL_RECT)
		z.draw.connect(func():
			var s := 22 * DP
			Zeichenknopf.glyphe(z, glyphe, (z.size - Vector2(s, s)) / 2, s / 22.0, Stil.TEXT if an else Stil.DIM, an))
		b.add_child(z)
	b.custom_minimum_size = Vector2(46, 46) * DP
	b.add_theme_font_override("font", Stil.variante(1.0))
	b.add_theme_font_size_override("font_size", int(round(14 * Stil.SP)))
	for z in ["font_color", "font_pressed_color", "font_hover_color", "font_focus_color"]: b.add_theme_color_override(z, Stil.TEXT)
	var s := Stil.kasten(Color.BLACK, Stil.RIM, 1.0)
	s.set_corner_radius_all(int(23 * DP))
	for z in ["normal", "hover", "focus", "pressed"]: b.add_theme_stylebox_override(z, s)
	b.pressed.connect(was)
	return b

func bild(pfad: String, breite_dp: float) -> TextureRect:
	var tex: Texture2D = null
	if pfad.ends_with(".bild"):   # roh wie Gebiet.bild, nicht eingelesen
		var img := Image.new()
		if FileAccess.file_exists(pfad) and img.load_jpg_from_buffer(FileAccess.get_file_as_bytes(pfad)) == OK: tex = ImageTexture.create_from_image(img)
	elif ResourceLoader.exists(pfad):
		tex = load(pfad)
	if tex == null: return null
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(breite_dp, breite_dp * tex.get_height() / tex.get_width()) * DP
	mittig(r)
	return r

func titel() -> void:
	leer()
	var tl := zeile(Sprache.u("title").to_upper(), 33, Stil.BRIGHT, 6.0)
	tl.add_theme_constant_override("line_spacing", int(4 * Stil.SP))
	ausgewogen(tl, box.custom_minimum_size.x)   # 585: „CHRONIKEN / VON BORNIM“ wie alt statt „CHRONIKEN VON / BORNIM“
	abstand(12)
	mittig(Zier.new())
	abstand(12)
	zeile(Sprache.u("subtitle").replace(": ", " · "), 15, Stil.DIM, 1.0)
	name_bis = box.get_child_count()
	abstand(18)
	# 867 (Vorentscheid Sokrates 13.11., 03:14, Vorlage 6 passt): die vier Helden des Spiels statt des alten Bilds der Kotlin-Figuren;
	# ohne gekaufte Figuren (am Rechner) das alte Bild
	if HauptmenueHelden.da(): mittig(HauptmenueHelden.new(330.0))
	else: bild(BILD, 330)
	abstand(22)
	var stand := Spielstand.lade()   # 399.1: der zuletzt gespeicherte der vier Plaetze
	if not stand.is_empty():
		var h: Dictionary = stand.get("held", {})
		var ort := String(stand.get("ort", {}).get("karte", ""))
		var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
		if alle is Dictionary and alle["karten"].has(ort): ort = Sprache.t(alle["karten"][ort]["name"])
		var p := int(stand["platz"])
		hauptknopf("Weiter" if Sprache.aktiv() == "de" else "Continue", "%s · %s %d · %s" % [h.get("name", ""), Sprache.u("level"), int(h.get("stufe", 1)), ort],
			func(): fertig.emit({"laden": true, "platz": p}))
		abstand(12)
	# wie alt: „Neues Spiel“ und, wenn es einen Spielstand gibt, „Spielstände“ nebeneinander, 280 dp breit
	var reihe := HBoxContainer.new()
	reihe.custom_minimum_size.x = 280 * DP
	reihe.add_theme_constant_override("separation", int(10 * DP))
	reihe.add_child(Stil.knopf(Sprache.u("newGame"), erschaffung))
	if Spielstand.gibt_es(): reihe.add_child(Stil.knopf("Spielstände" if Sprache.aktiv() == "de" else "Saved games", spielstaende))   # 870.8: auch, wenn nur alte da sind (Loeschen)
	mittig(reihe)
	abstand(12)
	# 1020.1 A (Chef 12.11., 08:09): im Testmodus ein neues Spiel ohne Intro und Erschaffung, nie auf einem der vier Plaetze
	if Testmodus.ist_an():
		var sn := Stil.knopf("Schnellstart · " + ErschaffungBrs.herkunft_name(Testmodus.schnell_herkunft) if Sprache.aktiv() == "de"
			else "Quick start · " + ErschaffungBrs.herkunft_name(Testmodus.schnell_herkunft),
			func(): fertig.emit(Testmodus.schnellstart()))
		sn.custom_minimum_size.x = 280 * DP
		mittig(sn)
		abstand(12)
	var ue := Stil.knopf(Sprache.u("about"), ueber)   # wie alt: „Über das Spiel“ unter der Reihe, 280 dp
	ue.custom_minimum_size.x = 280 * DP
	mittig(ue)
	abstand(18)
	# 489 (Chef 03.11., 07:07): wie alt (App.kt) Sprache, Musik und Effekte als drei kleine Zeichen, 22 dp Abstand; Musik und Effekte
	# schalten stumm (Klang.schalte), die Regler im Spielmenü bleiben
	var zeichen := HBoxContainer.new()
	zeichen.add_theme_constant_override("separation", int(22 * DP))
	zeichen.add_child(rundzeichen("DE" if Sprache.aktiv() == "de" else "EN", func(): Sprache.wechsle(); titel()))
	var k := klang()
	if k:
		zeichen.add_child(rundzeichen("", func(): k.schalte("music"); titel(), "MUSIC", k.musik_an))
		zeichen.add_child(rundzeichen("", func(): k.schalte("fx"); titel(), "SOUND", k.effekte_an))
	mittig(zeichen)
	abstand(22)
	var lg := bild(LOGO, 130)
	abstand(6)
	var v := String(ProjectSettings.get_setting("application/config/version", ""))
	var vz := zeile(("v%s · " % v if v != "" else "") + "SRD 5.1 · CC BY 4.0", 12, Color(Stil.DIM, 0.75), 0.5)
	vz.autowrap_mode = TextServer.AUTOWRAP_OFF
	# 399.1 wie alt (App.kt secretTaps): siebenmal auf das Firmenzeichen oder die Zeile darunter schaltet den Testmodus (Testmodus.gd)
	for c in [lg, vz]:
		if c: c.mouse_filter = Control.MOUSE_FILTER_STOP; c.gui_input.connect(_geheim)
	if Testmodus.ist_an(): zeile("Testmodus aktiv" if Sprache.aktiv() == "de" else "Test mode on", 12, Stil.WARN)

var geheim := 0

func _geheim(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed): return
	geheim += 1
	if geheim < Testmodus.TIPPEN: return
	geheim = 0
	Testmodus.umschalten()
	var de := Sprache.aktiv() == "de"
	titel()
	hinweis(("Testmodus aktiviert" if de else "Test mode enabled") if Testmodus.an else ("Testmodus deaktiviert" if de else "Test mode disabled"))

# vm.toast: eine kurze Zeile unten auf dunklem Grund, drei Sekunden
func hinweis(t: String) -> void:
	var l := Stil.zeile(t, 14, Stil.TEXT, 0.3)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.85); sb.border_color = Stil.LINE; sb.set_border_width_all(int(DP))
	sb.set_content_margin_all(8 * DP)
	l.add_theme_stylebox_override("normal", sb)
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
	l.grow_horizontal = Control.GROW_DIRECTION_BOTH
	l.offset_bottom = -48 * DP; l.offset_top = l.offset_bottom - l.get_combined_minimum_size().y
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	# 574: der Zeitgeber haelt die Zeile nur schwach; schliesst der Schirm vorher, ist sie einfach weg („Lambda capture … was freed“)
	var schwach: WeakRef = weakref(l)
	get_tree().create_timer(3.0).timeout.connect(func():
		var ll = schwach.get_ref()
		if ll != null: ll.queue_free())

# 399.1 Erschaffung: eine Seite ueber dem Menue; Zurueck fuehrt ins Hauptmenue. ziel: Platz aus den Spielstaenden, sonst der erste
# freie. 470 (Chef 10.11., 12:58): die Erschaffung nach BRS (erschaffung_brs.gd) statt der alten Klassenwahl
func erschaffung(ziel: int = 0) -> void:
	var e := ErschaffungBrs.new()
	e.ziel = ziel
	add_child(e)
	e.zurueck.connect(func(): e.queue_free(); titel())
	e.fertig.connect(func(w): fertig.emit(w))

# 399.1 Spielstaende wie alt (spielstaende.gd)
func spielstaende() -> void:
	var s := Spielstaende.new()
	add_child(s)
	s.zurueck.connect(func(): s.queue_free(); titel())
	s.laden.connect(func(p): fertig.emit({"laden": true, "platz": p}))
	s.neu.connect(func(p): s.queue_free(); erschaffung(p))

# 399.1 Ueber das Spiel wie alt (App.kt AboutScreen): ein Kasten mit Titel, Text ([312.ueber], [312.srd], [312.eigen]), Schrift,
# Firmenzeichen, Jahr und Version; unten Zurueck. Schriften: nur noch Alegreya (DESIGN-STIL.md „Oberfläche“)
# 497: Lizenztext der Engine, je Drittteil Name, Urheber und Lizenz, dann die Lizenztexte (Engine.get_license_text,
# get_copyright_info, get_license_info), klein und matt; der Wortlaut bleibt englisch wie geliefert
# 497 (Chef 03.11., 23:43: „nicht saubere Umbrüche“): die Texte sind fuer 80 Spalten fest umbrochen; am Handy bricht das Label
# davor schon um, es entstehen Zeilenstummel. Darum: Zeilen eines Absatzes zusammenziehen, Absatz bei Leerzeile; eigene Zeile
# fuer Aufzaehlung („1.“, „1.1.“, „(a)“, „a.“, „iv.“, „o“, „-“), „Copyright …“, „License: …“ und kurze Ueberschrift in Versalien; Unterstreichungen
# (----, ====) und der Sternrahmen der MPL fallen weg; doppelte Leerzeichen einfach; „Â©“ (Kodierfehler der Engine) wird „©“.
const AUFZAEHLUNG := "^(\\d+(\\.\\d+)*\\.|\\([a-zA-Z0-9]{1,4}\\)|[a-zA-Z]\\.|[ivx]{1,4}\\.|[o*•-])\\s|^(Copyright|©|License:)"

static func umbrechen(t: String) -> String:
	var punkt := RegEx.create_from_string(AUFZAEHLUNG)
	var strich := RegEx.create_from_string("^[-=*_~]{3,}$")
	var leer := RegEx.create_from_string("\\s+")
	var absaetze: Array[String] = []
	var zeilen: Array[String] = []
	var schliessen := func() -> void:   # Arrays sind Verweise, das Lambda sieht dieselben
		if not zeilen.is_empty(): absaetze.append("\n".join(zeilen))
		zeilen.clear()
	for roh in t.replace("Â©", "©").replace("\r", "").split("\n"):
		var z := roh.strip_edges()
		if z.length() >= 3 and z.begins_with("*") and z.ends_with("*"): z = z.substr(1, z.length() - 2).strip_edges()
		z = leer.sub(z, " ", true)
		if z == "" or strich.search(z):
			schliessen.call()
			continue
		var kopf := zeilen.is_empty() and z.length() <= 60 and z == z.to_upper() and z != z.to_lower() and not z.ends_with(".")
		if zeilen.is_empty() or punkt.search(z) or kopf:
			zeilen.append(z)
		else:
			zeilen[zeilen.size() - 1] += " " + z
		if kopf: schliessen.call()
	schliessen.call()
	return "\n\n".join(absaetze)

# 781 (aus 623.1, Sokrates): die REEBOO-Pakete Grass & Wind, Water, Surface enthalten die Hashfunktionen „Hash without Sine“
# von David Hoskins unter MIT; MIT verlangt Urheberzeile und Lizenztext in jeder Kopie, darum wie Godot (497) hier
const HOSKINS_ZEILE := "Hash without Sine – David Hoskins – MIT License"
const HOSKINS_COPYRIGHT := "Copyright (c) 2014 David Hoskins"
const MIT_TEXT := """Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."""

static func lizenz_texte(box: VBoxContainer, de: bool) -> void:
	var kopf := func(t: String) -> void:
		box.add_child(Stil.luecke(8))
		box.add_child(Stil.zeile(t.to_upper(), 14, Stil.GOLD, 3.0))   # 630 (549a): Zwischenueberschrift 14 sp
	var klein := func(t: String) -> void: box.add_child(Stil.txt(umbrechen(t), 13, Spielstaende.ANGABE))   # 549a: nie unter 13 sp
	kopf.call("Godot Engine")
	klein.call(("Dieses Spiel nutzt die Godot Engine unter folgender Lizenz:" if de else "This game uses Godot Engine, available under the following license:"))
	klein.call(Engine.get_license_text().strip_edges())
	kopf.call("Drittteile der Engine" if de else "Engine third-party components")
	for c in Engine.get_copyright_info():
		var zeilen := PackedStringArray([String(c["name"])])
		for teil in c["parts"]:
			for cr in teil["copyright"]: zeilen.append("© " + String(cr))
			zeilen.append("License: " + String(teil["license"]))
		klein.call("\n".join(zeilen))
	# 804 (Grass & Wind Kit, Hoskins MIT): der Hinweis steht einmal fuer alle REEBOO-Pakete unten (781)
	kopf.call("Lizenztexte" if de else "License texts")
	var li := Engine.get_license_info()
	for k in li:
		klein.call(String(k))
		klein.call(String(li[k]).strip_edges())
	kopf.call("Hashfunktionen der Effekte" if de else "Hash functions in visual effects")   # 781
	klein.call("Hash without Sine\n" + HOSKINS_COPYRIGHT + "\nLicense: MIT")
	klein.call(MIT_TEXT)

# 623.7 (Chef 07.11., 623 F; Homer [623.dank.*] in STORY-SPIEL.md): „Mit Dank an“ unter „Lizenzen der Engine“, ueber dem Logo, nie im
# Spielgeschehen; Schreibung der Haendlernamen wie auf RenderHub (Game-Ready Studios, Wernerkurt; 08.11. nachgesehen)
const DANK_KOPF := {"de": "Mit Dank an", "en": "With thanks to"}
const DANK_SATZ := {"de": "Diese Chronik entstand nicht allein. Dank allen, deren Werk sie trägt: in Bild und Bewegung, Licht und Klang, Musik und Schrift.", "en": "This chronicle was not made alone. Our thanks to everyone whose work carries it: in image and motion, light and sound, music and type."}
const DANK := [
	[{"de": "Effekte", "en": "Visual effects"}, {"de": "REEBOO Labs", "en": "REEBOO Labs"}],
	[{"de": "Figuren, Tiere und Bewegung", "en": "Characters, creatures and motion"}, {"de": "Animated3D, Game-Ready Studios, Janpec, MadeCG, Protofactor, Quaternius, rubberduck, Wernerkurt, yughues", "en": "Animated3D, Game-Ready Studios, Janpec, MadeCG, Protofactor, Quaternius, rubberduck, Wernerkurt, yughues"}],
	[{"de": "Dinge und Waffen", "en": "Props and weapons"}, {"de": "Anker's Assets, Avramania, MagicCGIStudios, Omie's Assets, PolyMech, Quaternius", "en": "Anker's Assets, Avramania, MagicCGIStudios, Omie's Assets, PolyMech, Quaternius"}],
	[{"de": "Klang", "en": "Sound"}, {"de": "AlanCat, antumdeluge, arcadeparty, artisticdude, bart, bashar3a, betchkal, blukotek, bonebrah, Borgory, Breviceps, congusbongus, craigsmith, Defelozedd94, esperar, EZduzziteh, Gerent, haeldb, jaegrover, jaggedstone, jmehlferber, Joseph Sardin, Kenney, kingsrow, legit-audio, LilMati, magicjoshua, musicbrain, ondrosik, onehugeeye, owlishmedia, Paresh, Patrick_Corra, pauliuw, Pierre, qubodup, RandomMind, rubberduck, Sahand.Zangeneh, Sam Gossner, SkyRaeVoicing, syncopika, themightyglider, thimras, ValentinPetiteau, vehicle, vinrax, ZoshP – und allen, die ihre Aufnahmen bei BigSoundBank, Freesound und OpenGameArt teilen.", "en": "AlanCat, antumdeluge, arcadeparty, artisticdude, bart, bashar3a, betchkal, blukotek, bonebrah, Borgory, Breviceps, congusbongus, craigsmith, Defelozedd94, esperar, EZduzziteh, Gerent, haeldb, jaegrover, jaggedstone, jmehlferber, Joseph Sardin, Kenney, kingsrow, legit-audio, LilMati, magicjoshua, musicbrain, ondrosik, onehugeeye, owlishmedia, Paresh, Patrick_Corra, pauliuw, Pierre, qubodup, RandomMind, rubberduck, Sahand.Zangeneh, Sam Gossner, SkyRaeVoicing, syncopika, themightyglider, thimras, ValentinPetiteau, vehicle, vinrax, ZoshP – and everyone who shares their work on BigSoundBank, Freesound and OpenGameArt."}],
	[{"de": "Musik", "en": "Music"}, {"de": "beardalaxy, carrieedick, cesisco, cleytonkauffman, cynicmusic, ElanHickler, eldritch-grim, emmama, Fission9, Flamiffer, jaggedstone, Kaiser (the-oracle), kindland, Kinoton, Magmi.Soundtracks, nene, nihilocrat, Paul Wortmann, RandomMind, rhayn, RutgerMuller, tinyworlds, trex0n, umplix, vitalezzz, yd", "en": "beardalaxy, carrieedick, cesisco, cleytonkauffman, cynicmusic, ElanHickler, eldritch-grim, emmama, Fission9, Flamiffer, jaggedstone, Kaiser (the-oracle), kindland, Kinoton, Magmi.Soundtracks, nene, nihilocrat, Paul Wortmann, RandomMind, rhayn, RutgerMuller, tinyworlds, trex0n, umplix, vitalezzz, yd"}],
	[{"de": "Schriften", "en": "Typefaces"}, {"de": "Juan Pablo del Peral und Huerta Tipográfica (Alegreya), Brian J. Bonislawsky (Astigmatic, Fondamento)", "en": "Juan Pablo del Peral and Huerta Tipográfica (Alegreya), Brian J. Bonislawsky (Astigmatic, Fondamento)"}],
	[{"de": "Engine", "en": "Engine"}, {"de": "Godot Engine – Juan Linietsky, Ariel Manzur und alle Mitwirkenden", "en": "Godot Engine – Juan Linietsky, Ariel Manzur and all contributors"}],
]

func ueber() -> void:
	# 630 (549a „Schirm“): ohne Kasten; Titel 22 sp mit Zierlinie, Abschnitte durch schlichte Linien, unten „‹ ZURÜCK“
	var d := Spielstaende.schirm(self, Sprache.u("title"), func(): pass, 0.0)   # 526: Android-Zurück wie „Zurück“ (Spielstaende.schirm)
	var v: VBoxContainer = d["inhalt"]
	v.add_child(Stil.txt(Sprache.u("aboutText"), 16))
	v.add_child(Stil.luecke(12))
	var de := Sprache.aktiv() == "de"
	# 497 (Chef 03.11., 07:09): beide mitgelieferten Schriften (Fondamento fuer die Ortsnamen der Karte, kartenreiter.gd)
	v.add_child(Stil.txt(("Schriften" if de else "Fonts") + ": Alegreya, Fondamento – SIL Open Font License 1.1", 13.5, Spielstaende.ANGABE))
	# 497: Godot Engine (MIT) mit Drittteilen, Wortlaut aus der Engine selbst (Godot-Doku „Complying with licenses“); erst auf Tippen
	v.add_child(Stil.luecke(6))
	v.add_child(Stil.txt("Godot Engine – MIT License · godotengine.org/license", 13.5, Spielstaende.ANGABE))
	v.add_child(Stil.luecke(6))
	v.add_child(Stil.txt(HOSKINS_ZEILE, 13.5, Spielstaende.ANGABE))   # 781
	v.add_child(Stil.luecke(6))
	var lizenzen := VBoxContainer.new()
	lizenzen.add_theme_constant_override("separation", int(4 * DP))
	lizenzen.visible = false
	var zl := HBoxContainer.new()
	zl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zl.custom_minimum_size.y = 48 * DP
	var lt := Stil.zeile("Lizenzen" if de else "Licences", 15, Stil.TEXT)
	lt.name = "Text"
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	zl.add_child(lt)
	var pf := Spielstaende.pfeil(Stil.GOLD, false)
	pf.resized.connect(func(): pf.pivot_offset = pf.size / 2)
	zl.add_child(pf)
	# 585 (Abgleich 512b: „aufgeklappt ohne Hinweis zum Zuklappen“): offen zeigt der Winkel nach unten, am Ende der Texte steht dieselbe
	# Zeile mit dem Winkel nach oben und klappt wieder zu (sonst muss man durch alle Lizenzen zurueckrollen)
	var umschalten := func():
		if lizenzen.get_child_count() == 0:
			lizenz_texte(lizenzen, de)
			var zz := HBoxContainer.new()
			zz.mouse_filter = Control.MOUSE_FILTER_IGNORE
			zz.custom_minimum_size.y = 48 * DP
			var zt := Stil.zeile("Lizenzen" if de else "Licences", 15, Stil.TEXT)
			zt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			zt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			zz.add_child(zt)
			var zp := Spielstaende.pfeil(Stil.GOLD, false)
			zp.resized.connect(func(): zp.pivot_offset = zp.size / 2)
			zp.rotation = -PI / 2
			zz.add_child(zp)
			lizenzen.add_child(Stil.luecke(8))
			var zu := Spielstaende.tippbar(zz, func(): lizenzen.visible = false; pf.rotation = 0.0)
			zu.name = "LizenzenZu"
			lizenzen.add_child(zu)
		lizenzen.visible = not lizenzen.visible
		pf.rotation = PI / 2 if lizenzen.visible else 0.0
	var auf := Spielstaende.tippbar(zl, umschalten)
	auf.name = "Lizenzen"
	v.add_child(auf)
	v.add_child(lizenzen)
	v.add_child(Stil.luecke(12))
	v.add_child(Spielstaende.linie())
	v.add_child(Stil.luecke(12))
	v.add_child(Stil.zeile(String(DANK_KOPF["de" if de else "en"]).to_upper().replace("ß", "SS"), 14, Stil.GOLD, 3.0))   # 623.7
	v.add_child(Stil.luecke(8))
	v.add_child(Stil.txt(String(DANK_SATZ["de" if de else "en"]), 15))
	for e in DANK:
		v.add_child(Stil.luecke(6))
		v.add_child(Stil.txt(String(e[0]["de" if de else "en"]) + ": " + String(e[1]["de" if de else "en"]), 13.5, Spielstaende.ANGABE))
	v.add_child(Stil.luecke(18))
	var tex: Texture2D = load(LOGO) if ResourceLoader.exists(LOGO) else null
	if tex:
		var r := TextureRect.new()
		r.texture = tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.custom_minimum_size = Vector2(130, 130.0 * tex.get_height() / tex.get_width()) * DP
		r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(r)
	v.add_child(Stil.luecke(6))
	var ver := String(ProjectSettings.get_setting("application/config/version", ""))
	var z := Stil.txt("© 2026 · " + ("v%s · " % ver if ver != "" else "") + "SRD 5.1 · CC BY 4.0", 13.5, Spielstaende.ANGABE)
	z.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(z)
