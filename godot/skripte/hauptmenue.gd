class_name Hauptmenue
extends Control
# 399 (Chef 28.10., 12:34: spielbar zuerst): Hauptmenue (292) und Erschaffung. Fortsetzen, wenn ein Spielstand liegt; Neues Spiel fuehrt
# in die Erschaffung (erschaffung.gd), „Spielstände“ zu den vier Plaetzen (spielstaende.gd). Ende: Signal fertig({"laden": true,
# "platz"}) oder fertig({"name", "volk", "klasse", "werte", "platz"}).
# 399.1 (Test 130, Chef 14:38: „Einfach mal das alte Spiel nehmen … so soll es im neuen halt auch schon“; 14:39 „an die
# Designvorgaben halten“): Aussehen wie App.kt MainMenuColumn (292.3, Entwurf A): schwarz, Titel gross in gesperrten Versalien, Zier,
# Kapitelzeile, das Bild der vier im warmen Lichtkegel (assets/menu/hauptmenue.jpg, im Bau kopiert), Hauptweg golden umrandet,
# Knoepfe schwarz mit duennem Rand, Sprache als kleines rundes Zeichen, Firmenzeichen und Versionszeile unten; Masse in dp wie alt.
# Liegt ueber allem (eigene Ebene), ohne die Probeknoepfe des Dorfs. Noch nicht wie alt: Musik und Klang.

signal fertig(wahl: Dictionary)

const DP := AktionsKnopf.DP
const BILD := "res://daten/hauptmenue.bild"   # JPEG aus app/src/main/assets/menu, im Bau kopiert (godot.yml)
const LOGO := "res://bilder/logo-quer.svg"
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
	mitte.custom_minimum_size = vs
	rolle.add_child(mitte)
	box = VBoxContainer.new()
	box.custom_minimum_size.x = vs.x - 48 * DP
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	mitte.add_child(box)
	titel()
	if ueber_zuerst:   # 399.1 System „Über“ wie alt (vm.toMenu, Screen.ABOUT): speichern, ins Hauptmenue, gleich die Seite
		ueber_zuerst = false
		ueber()

static var ueber_zuerst := false

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

# RoundSign: rundes Zeichen 46 dp mit duennem Goldrand
func rundzeichen(t: String, was: Callable) -> void:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(46, 46) * DP
	b.add_theme_font_override("font", Stil.variante(1.0))
	b.add_theme_font_size_override("font_size", int(round(14 * Stil.SP)))
	for z in ["font_color", "font_pressed_color", "font_hover_color", "font_focus_color"]: b.add_theme_color_override(z, Stil.TEXT)
	var s := Stil.kasten(Color.BLACK, Stil.RIM, 1.0)
	s.set_corner_radius_all(int(23 * DP))
	for z in ["normal", "hover", "focus", "pressed"]: b.add_theme_stylebox_override(z, s)
	b.pressed.connect(was)
	mittig(b)

func bild(pfad: String, breite_dp: float) -> void:
	var tex: Texture2D = null
	if pfad.ends_with(".bild"):   # roh wie Gebiet.bild, nicht eingelesen
		var img := Image.new()
		if FileAccess.file_exists(pfad) and img.load_jpg_from_buffer(FileAccess.get_file_as_bytes(pfad)) == OK: tex = ImageTexture.create_from_image(img)
	elif ResourceLoader.exists(pfad):
		tex = load(pfad)
	if tex == null: return
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(breite_dp, breite_dp * tex.get_height() / tex.get_width()) * DP
	mittig(r)

func titel() -> void:
	leer()
	zeile(Sprache.u("title").to_upper(), 33, Stil.BRIGHT, 6.0).add_theme_constant_override("line_spacing", int(4 * Stil.SP))
	abstand(12)
	mittig(Zier.new())
	abstand(12)
	zeile(Sprache.u("subtitle").replace(": ", " · "), 15, Stil.DIM, 1.0)
	abstand(18)
	bild(BILD, 330)
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
	reihe.add_child(Erschaffung.knopf(Sprache.u("newGame"), erschaffung))
	if not stand.is_empty(): reihe.add_child(Erschaffung.knopf("Spielstände" if Sprache.aktiv() == "de" else "Saved games", spielstaende))
	mittig(reihe)
	abstand(12)
	var ue := Erschaffung.knopf(Sprache.u("about"), ueber)   # wie alt: „Über das Spiel“ unter der Reihe, 280 dp
	ue.custom_minimum_size.x = 280 * DP
	mittig(ue)
	abstand(18)
	rundzeichen("DE" if Sprache.aktiv() == "de" else "EN", func(): Sprache.wechsle(); titel())
	abstand(22)
	bild(LOGO, 130)
	abstand(6)
	var v := String(ProjectSettings.get_setting("application/config/version", ""))
	var vz := zeile(("v%s · " % v if v != "" else "") + "SRD 5.1 · CC BY 4.0", 12, Color(Stil.DIM, 0.75), 0.5)
	vz.autowrap_mode = TextServer.AUTOWRAP_OFF

# 399.1 Erschaffung wie alt (erschaffung.gd): eine Seite ueber dem Menue; Zurueck fuehrt ins Hauptmenue. ziel: Platz aus den
# Spielstaenden, sonst der erste freie
func erschaffung(ziel: int = 0) -> void:
	var e := Erschaffung.new()
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
func ueber() -> void:
	var seite := Control.new()
	seite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(seite)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	seite.add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for r in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + r, int(16 * DP))
	seite.add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(12 * DP))
	rand.add_child(spalte)
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var k := Erschaffung.kasten(rolle)
	k.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(k)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 0)
	rolle.add_child(v)
	v.add_child(Stil.zeile(Sprache.u("title").to_upper(), 12, Stil.BRIGHT, 3.0))
	v.add_child(Erschaffung.luecke(12))
	v.add_child(Erschaffung.txt(Sprache.u("aboutText"), 16))
	v.add_child(Erschaffung.luecke(12))
	v.add_child(Erschaffung.txt(("Schrift" if Sprache.aktiv() == "de" else "Font") + ": Alegreya – SIL Open Font License 1.1", 14, Stil.DIM))
	v.add_child(Erschaffung.luecke(18))
	var tex: Texture2D = load(LOGO) if ResourceLoader.exists(LOGO) else null
	if tex:
		var r := TextureRect.new()
		r.texture = tex
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.custom_minimum_size = Vector2(130, 130.0 * tex.get_height() / tex.get_width()) * DP
		r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(r)
	v.add_child(Erschaffung.luecke(6))
	var ver := String(ProjectSettings.get_setting("application/config/version", ""))
	var z := Erschaffung.txt("© 2026 · " + ("v%s · " % ver if ver != "" else "") + "SRD 5.1 · CC BY 4.0", 12, Stil.DIM)
	z.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(z)
	spalte.add_child(Erschaffung.knopf(Sprache.u("back"), func(): seite.queue_free()))
