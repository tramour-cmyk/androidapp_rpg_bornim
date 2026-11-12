# 348.7: Oberfläche des Kampforts nach SkirmishScreen.kt (schwarzer Stil, Theme.kt Veil): unten ein schwarzer Kasten mit
# dünnem Goldrand: Kampfbericht (nur ganze Zeilen, die neueste hell, Schaden hervorgehoben, „▴ ganzer Bericht“), je
# Mitglied ein Kasten (Farbmarke, Name, Balken in Lebensfarbe, „14/14“, ZP), zwei Knopfzeilen in Großbuchstaben. In der
# Szene: Zugleiste oben links mit ▶, Lebensbalken nur über Gegnern, gerahmte Ansagen „! Anspringen“ ohne Überlappen,
# Ring am Boden unter dem, der dran ist, Dreiecke vor den Füßen der Angezielten, Würfelkasten, Schalter Würfel und Raster.
# Maße in dp (Breite / 412), Schrift Alegreya wie im alten Spiel.
extends CanvasLayer

const Mars = preload("res://regeln/mars.gd")
const Figur = preload("res://kampf/figur.gd")     # 494: Figur.vier
const Zauber = preload("res://kampf/zauber.gd")
const Tafel = preload("res://kampf/tafel.gd")
const Tips = preload("res://kampf/marstips.gd")     # 536: Texte für langes Drücken (MarsTips.kt)
const HINWEIS_REIHE := "kampf_hinweis_reihe"     # 836: Flagge im Spielstand, der Reihenhinweis ist gezeigt

# Theme.kt, Veil
const TEXT := Color("#E6DDCB")
const DIM := Color("#948A78")
const GOLD := Color("#B59A6A")
const BRIGHT := Color("#D9BC82")
const RIM := Color(0.710, 0.604, 0.416, 0.67)
const LINE := Color("#9A8155")
const WARN := Color("#D9785A")
const RAISED := Color("#17140F")
const FRIEND_COLORS := [Color("#7FB6E8"), Color("#CB9BE3"), Color("#6FCFC0")]
const ROLL_MS := 2500
const ROLL_FADE_MS := 400
## 249 (BattleBlood.kt Gore): was aus einem Getroffenen kommt, dunkel und hell; Untote sickern oder splittern, die Gallerte spritzt Schleim
const GORE := {
	"BLOOD": [Color("#6E0C12"), Color("#A4161E")], "ICHOR": [Color("#2E2416"), Color("#5A4A2A")],
	"BONE": [Color("#B8AE9C"), Color("#E8E0D0")], "SLIME": [Color("#9A7020"), Color("#D8A83A")],
}

var kampfort
var lang := 0
var root: Control
var overlay: Control
var panel: PanelContainer
var log_area: Control
var log_box: PanelContainer     # 532: weicht der rollbaren Tasche, solange sie offen ist
var party_row: HBoxContainer
var orders: VBoxContainer
var full_log: PanelContainer
var tip: Label
var verdict: Label
var lines: Array = []
var pick := "main"
var pick_arg = null
var ring_target := ""
var ring_t0 := 0
var roll_shown = null
var roll_at := 0
var sign_rects := []      # Ansagen dieses Bildes, damit der Würfelkasten ihnen ausweicht
var sign_of := {}         # Ansage je Gegner in diesem Bild; Lebensbalken und Zustände hängen an ihr
var balken_of := {}       # 438: Messung (tests/wolf_mess_438.gd): Ort der Lebensleiste je Gegner in diesem Bild
var sign_wahl := {}       # 438: Platz der Ansage im letzten Bild je Gegner [Platz, mit Strich, Höhe]
var glatt := {}           # 438: gezeigter Ort je Ansage und Balken [Ort, Zeit]
var bar_unten := {}       # 438: Balken unter den Pfoten [ja, seit wann der andere Platz besser wäre]
const GLATT_MS := 120.0
const GLATT_DP_MS := 1.0      # 438: höchstens 33 dp je Bild bei 30 Bildern/s (Messung: Sprung ab 40 dp)
var dp := 2.6
var font: Font
var font_px := 38
var dice_on := true
## 249: das Blut des letzten Treffers {by, on, crit, hurt, gore, seed, t0}; ein neuer Treffer ersetzt es wie im alten MARS
var bleeding := {}
## 348.7 (Rest aus 249): laufende Zauber und Pfeile {kind, by, on, crit, missed, seed, t0}, je Treffer einer (BattleFxLayer)
var spells: Array = []
var zauber := Zauber.new()
var tafel     # 348.7a: Pinsel in der 3D-Szene (tafel.gd), beim ersten Zauber
## Leistung (Probe-Log „Tafeln“): Ecken und Mikrosekunden des letzten Bilds mit Zaubern
var tafel_ecken := 0
var tafel_us := 0
var spell_seed := 0
var grid_on := false
var dice_rect := Rect2()
var grid_rect := Rect2()
var tempo_rect := Rect2()      # 600: Tempo (im Spiel), links neben den Würfeln
var win_rect := Rect2()        # 272 (Testmodus): Haken gewinnt, Kreuz verliert sofort
var lose_rect := Rect2()


func t(de: String, en: String) -> String:
	return de if lang == 0 else en


## 551: Halbmesser der unteren Bildschirmecken in dp wie alt DeviceInfo.cornerDp() (Display.getRoundedCorner, unten links
## und rechts, das größere), über das Plugin AndroidRuntime; ohne Gerät, vor Android 12 oder ohne Antwort 13 dp wie bisher.
static var ecke := -1.0
static func ecke_dp(_vp: Viewport) -> float:
	if ecke >= 0.0:
		return ecke
	ecke = 13.0
	if OS.get_name() != "Android" or not Engine.has_singleton("AndroidRuntime"):
		return ecke
	var act = Engine.get_singleton("AndroidRuntime").getActivity()
	var d = act.getDisplay() if act != null else null
	if d == null:
		return ecke
	var px := 0
	for pos in [3, 2]:     # RoundedCorner.POSITION_BOTTOM_LEFT, POSITION_BOTTOM_RIGHT
		var rc = d.getRoundedCorner(pos)
		if rc != null:
			px = maxi(px, int(rc.getRadius()))
	var w := DisplayServer.window_get_size()
	if w.x > 0:
		ecke = float(px) * 412.0 / float(w.x)     # dp wie dp = Breite / 412 (Gerät ohne runde Ecken: 0 wie alt)
	print("551: Bildschirmecke unten %d px, %.1f dp" % [px, ecke])
	return ecke


## 552 (Chef 04.11., 00:22, Build 249: „MARS Zugreihenfolge oben fehlt“; oben nur ein schwarzer Streifen): die Welt legt über
## alles ein schwarzes Band, so hoch wie die Kamera des Handys (Rand, 399.4, Ebene 119 über dem Kampf); der Kampf kannte es nicht
## und zeichnete die Zugleiste darunter. Dieselbe Höhe wie das Band (beim Start der Welt), sonst die sichere Fläche jetzt.
var turns_top := 0.0     # Oberkante der Zugleiste (Test zugleiste_552)
func rand_oben() -> float:
	return Rand.beim_start if Rand.beim_start >= 0.0 else Rand.oben(get_viewport())


## Schriftgröße wie Theme.kt im schwarzen Stil: sp × 0,95 × 1,04, mindestens 13,7 sp. 544 (Chef 04.11., 16:58: „relativ klein,
## aber die Schriftart müsste passen“): wie alt und wie die übrigen Schirme seit 498 mit der Schriftgröße des Handys (Compose sp =
## dp × fontScale; Stil.schriftfaktor), der Kampf rechnete fest mit 1
func sp(v: float) -> int:
	return int(maxf(v * 0.95 * 1.04, 13.7) * dp * Stil.schriftfaktor)


static func hp_color(frac: float) -> Color:
	return Color("#48C858") if frac > 0.5 else (Color("#F0C030") if frac > 0.2 else Color("#E04030"))


func _ready() -> void:
	var vs: Vector2 = get_viewport().get_visible_rect().size
	dp = vs.x / 412.0
	font_px = sp(15)
	# 544 (Chef 03.11., 23:49 „Stimmt die Schrift?“): load_dynamic_font liest die rohe .ttf, die im APK fehlt (dort steht nur die
	# importierte .fontdata, export_presets include_filter); der Kampf zeigte die Ersatzschrift. Jetzt über den Import wie stil.gd
	var ff = load("res://kampf/schrift/alegreya_regular.ttf")
	font = ff if ff is Font else ThemeDB.fallback_font
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var th := Theme.new()
	th.default_font = font
	th.default_font_size = font_px
	root.theme = th
	add_child(root)
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.draw.connect(_draw_overlay)
	overlay.gui_input.connect(_scene_input)
	root.add_child(overlay)
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# SkirmishScreen: full width, only clear of the screen's rounded corners (a third of their radius, 335); 551 (Chef 04.11.,
	# 00:21, Build 249: „MARS Kasten links und rechts unten wird unterbrochen angezeigt“, wie alt 335 am 23.10.): Godot nahm
	# geschätzte 13 dp, alt fragte DeviceInfo.cornerDp() das Gerät; jetzt ebenso über AndroidRuntime, am Rechner keine Ecke
	var m := (ecke_dp(get_viewport()) * 0.3 + 2.0) * dp if OS.get_name() == "Android" else 0.0
	panel.offset_left = m
	panel.offset_right = -m
	panel.offset_bottom = -m
	panel.add_theme_stylebox_override("panel", _box(Color.BLACK, RIM, 10, 10, 1.0))
	# below the scene the screen is black (SkirmishScreen: the box stands under the scene, not over it)
	backdrop = ColorRect.new()
	backdrop.color = Color.BLACK
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(backdrop)
	root.add_child(panel)
	# the scene ends above the box: when the box takes its real height, the camera fits again (Lauf 11: Helden verdeckt)
	panel.resized.connect(panel_passt)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", int(6 * dp))
	panel.add_child(col)
	log_box = PanelContainer.new()
	log_box.add_theme_stylebox_override("panel", _box(Color.BLACK, Color(RIM, RIM.a * 0.35), 6, 2, 1.0))
	log_box.custom_minimum_size = Vector2(0, 116 * dp)
	log_box.mouse_filter = Control.MOUSE_FILTER_STOP
	log_box.gui_input.connect(func(ev):
		if _pressed(ev):
			_show_full_log(true))
	col.add_child(log_box)
	log_area = Control.new()
	log_area.clip_contents = true
	log_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	log_area.draw.connect(_draw_log)
	log_box.add_child(log_area)
	party_row = HBoxContainer.new()
	party_row.add_theme_constant_override("separation", int(8 * dp))
	col.add_child(party_row)
	orders = VBoxContainer.new()
	orders.add_theme_constant_override("separation", int(6 * dp))
	orders.custom_minimum_size = Vector2(0, 106 * dp)
	col.add_child(orders)
	tip = Label.new()
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.visible = false
	tip.add_theme_color_override("font_color", TEXT)
	tip.add_theme_font_size_override("font_size", sp(14))
	tip.add_theme_stylebox_override("normal", _box(Color.BLACK, GOLD, 8, 6, 1.0))
	root.add_child(tip)
	verdict = Label.new()
	verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verdict.add_theme_font_size_override("font_size", sp(20))
	verdict.add_theme_color_override("font_color", BRIGHT)
	verdict.add_theme_color_override("font_outline_color", Color.BLACK)
	verdict.add_theme_constant_override("outline_size", int(4 * dp))
	verdict.visible = false
	root.add_child(verdict)
	full_log = PanelContainer.new()
	full_log.set_anchors_preset(Control.PRESET_FULL_RECT)
	full_log.offset_top = rand_oben()     # 552: der ganze Bericht beginnt unter dem Band über der Kamera
	full_log.add_theme_stylebox_override("panel", _box(Color.BLACK, GOLD, 10, 10, 1.0))
	full_log.visible = false
	full_log.mouse_filter = Control.MOUSE_FILTER_STOP
	full_log.gui_input.connect(_full_log_input)
	root.add_child(full_log)
	# 836 (Homer 830): einmal je Spielstand, nicht in jedem Kampf (seen_rows setzte niemand); Proben ohne Spielstand je Kampf
	if not kampfort.flaggen.has(HINWEIS_REIHE):
		log_line(t("Nahkampf erreicht nur die vordere Reihe.", "Melee reaches only the front row."))
		kampfort.flaggen[HINWEIS_REIHE] = true


## 399.2 (Test 133, Chef 16:4x: Schalter Position und Schaden „gehen nicht“): ein Tippen kommt als Berührung und als
## nachgebildete Maus (am Rechner umgekehrt, emulate_touch_from_mouse); beide zählten, der Schalter sprang hin und zurück.
## Nur das echte Ereignis zählt, das nachgebildete trägt DEVICE_ID_EMULATION.
func _pressed(ev) -> bool:
	if ev.device == InputEvent.DEVICE_ID_EMULATION:
		return false
	return (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and ev.pressed)


func _scene_input(ev) -> void:
	if (ev is InputEventScreenTouch or ev is InputEventMouseButton) and ev.device != InputEvent.DEVICE_ID_EMULATION and not ev.pressed:
		druck_t0 = 0     # 536: losgelassen vor der halben Sekunde: kein Hinweis
	if not _pressed(ev):
		return
	var p: Vector2 = ev.position
	if dice_rect.has_point(p):
		dice_on = not dice_on
	elif grid_rect.has_point(p):
		grid_on = not grid_on
	elif tempo_rect.has_point(p):
		kampfort.tempo_wechseln()
	elif lose_rect.has_point(p):
		kampfort.test_end(false)
	elif win_rect.has_point(p):
		kampfort.test_end(true)
	elif not kampfort.ring_open and _status_tip(p) != "":
		show_tip(_status_tip(p))     # 536: ein Tipp auf ein Zustandsschild erklärt es
	else:
		kampfort.tap()
		druck_t0 = Time.get_ticks_msec()     # 536: lange gedrückt auf eine Ansage oder einen Gegner sagt, was er vorhat
		druck_pos = p


## A black box with a thin rim; padding in dp (across, up and down), rim width in dp.
func _box(bg: Color, border: Color, pad_x: float, pad_y: float, rim_dp: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(maxi(1, int(round(rim_dp * dp))))
	s.content_margin_left = pad_x * dp
	s.content_margin_right = pad_x * dp
	s.content_margin_top = pad_y * dp
	s.content_margin_bottom = pad_y * dp
	return s


var fitted_h := -1.0
var backdrop: ColorRect

func panel_height() -> float:
	# the scene ends above the box and its outer margin (SkirmishScreen: weight 1 above, box below)
	return panel.size.y - panel.offset_bottom if panel and panel.size.y > 0 else get_viewport().get_visible_rect().size.y * 0.33


var druck_t0 := 0
var druck_pos := Vector2.ZERO


func _process(_dt: float) -> void:
	if druck_t0 > 0 and Time.get_ticks_msec() - druck_t0 >= int(LANG_S * 1000.0):
		druck_t0 = 0
		var was := scene_tip(druck_pos)
		if was != "":
			show_tip(was)
			names_until = Time.get_ticks_msec() + NAMES_MS     # 536: wie alt (SkirmishScreen namesUntil) zeigen dann alle ihre Namen
	overlay.queue_redraw()


# ---------------------------------------------------------------- the log: only whole lines, newest at the bottom
## 840 (210 B: „eigene Farbe oder kursiv“): Zeilen, die eine Eingebung des Helden sind, in Gold (EINGEBUNG_FARBE)
var eingebungen := {}
const EINGEBUNG_FARBE := Color("#C9A86A")
func log_line(text: String, eingebung := false) -> void:
	if eingebung:
		eingebungen[text] = true
	lines.append(text)
	while lines.size() > 300:
		lines.pop_front()
	if log_area:
		log_area.queue_redraw()


## Words of a line with their colours: the newest line in text, older ones dim, "n Schaden" bright or gold.
func _words(s: String, newest: bool) -> Array:
	var out := []
	var base := TEXT if newest else DIM
	if eingebungen.has(s):     # 840
		base = EINGEBUNG_FARBE if newest else EINGEBUNG_FARBE.darkened(0.3)
	var hi := BRIGHT if newest else GOLD
	var ws := s.split(" ", false)
	for i in ws.size():
		var w: String = ws[i]
		var c := base
		if w.is_valid_int() and i + 1 < ws.size() and (ws[i + 1].begins_with("Schaden") or ws[i + 1].begins_with("damage")):
			c = hi
		elif i > 0 and ws[i - 1].is_valid_int() and (w.begins_with("Schaden") or w.begins_with("damage")):
			c = hi
		out.append([w, c])
	return out


func _wrap(words: Array, width: float, fs: int) -> Array:
	var rows := [[]]
	var x := 0.0
	var space := font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	for w in words:
		var ww := font.get_string_size(w[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if x > 0 and x + space + ww > width:
			rows.append([])
			x = 0.0
		rows[-1].append([w[0], w[1], x + (space if x > 0 else 0.0)])
		x += (space if x > 0 else 0.0) + ww
	return rows


func _draw_log() -> void:
	var fs := sp(15 * 0.95)
	var lh := 19.5 * dp
	var w := log_area.size.x
	var h := log_area.size.y
	var more := lines.size() > 3
	var fs2 := sp(11)
	var rows_all := []
	# like SkirmishScreen: the lines above, „▴ ganzer Bericht“ under them on the right
	var y := h - (fs2 * 1.3 if more else 0.0)
	for i in range(lines.size() - 1, -1, -1):
		var rows := _wrap(_words(lines[i], i == lines.size() - 1), w, fs)
		if y - rows.size() * lh < 0:
			break
		y -= rows.size() * lh
		rows_all.push_front([y, rows])
	# the shown lines stand from the top, no gap above them (Prüfer Stand 7, Lauf 14: „Lücke unter einer Zeile“)
	if not rows_all.is_empty():
		var lift: float = rows_all[0][0]
		for block in rows_all:
			block[0] -= lift
	for block in rows_all:
		var yy: float = block[0]
		for row in block[1]:
			for word in row:
				log_area.draw_string(font, Vector2(word[2], yy + lh * 0.78), word[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, word[1])
			yy += lh
	if more:
		var label := t("▴ ganzer Bericht", "▴ whole log")
		var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2).x
		log_area.draw_string(font, Vector2(w - lw, h - fs2 * 0.3), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2, GOLD)


## 416.5 (Chef 31.10., Build 143: „nicht mehr schließbar“): der Text fing jeden Tipp ab, und die einmalige Verbindung
## löste schon die erste Fingerbewegung. Jetzt schließt ein Tipp überall (Loslassen nah am Druck), Wischen blättert.
var full_log_opened_ms := 0
var full_log_press := Vector2.INF


func _show_full_log(on: bool) -> void:
	for c in full_log.get_children():
		c.queue_free()
	full_log.visible = on
	full_log_press = Vector2.INF
	if not on:
		return
	full_log_opened_ms = Time.get_ticks_msec()
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_PASS
	full_log.add_child(v)
	var h := Label.new()
	h.text = t("Kampfbericht", "Battle log")
	h.add_theme_color_override("font_color", GOLD)
	h.add_theme_font_size_override("font_size", sp(16))
	v.add_child(h)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.mouse_filter = Control.MOUSE_FILTER_PASS
	v.add_child(sc)
	var r := RichTextLabel.new()
	r.fit_content = true
	r.scroll_active = false
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.mouse_filter = Control.MOUSE_FILTER_PASS
	r.add_theme_color_override("default_color", TEXT)
	r.add_theme_font_override("normal_font", font)
	r.add_theme_font_size_override("normal_font_size", sp(15 * 0.95))
	r.text = "\n".join(lines)
	sc.add_child(r)
	var close := Label.new()
	close.text = t("Tippen schließt", "Tap to close")
	close.add_theme_color_override("font_color", DIM)
	close.add_theme_font_size_override("font_size", sp(13))
	v.add_child(close)
	# newest at the bottom, as in the small log
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(sc):
		sc.scroll_vertical = int(sc.get_v_scroll_bar().max_value)


## Druck merken, beim Loslassen nah am Druck schließen; Maus und Finger kommen am Handy doppelt (emulate_mouse_from_touch),
## darum zählt der Druck, der den Bericht geöffnet hat, nicht als Schließen (250 ms).
func _full_log_input(ev) -> void:
	if not full_log.visible:
		return
	var down: bool = _pressed(ev)
	var up: bool = (ev is InputEventMouseButton and not ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and not ev.pressed)
	if down:
		if Time.get_ticks_msec() - full_log_opened_ms >= 250:
			full_log_press = ev.position
	elif up and full_log_press != Vector2.INF:
		var far: bool = ev.position.distance_to(full_log_press) > 12.0 * dp
		full_log_press = Vector2.INF
		if not far:
			_show_full_log(false)


# ---------------------------------------------------------------- party boxes and orders
func _friend_color(f) -> Color:
	var i := 0
	for o in kampfort.mars.fighters():
		if o.side == "PARTY":
			if o == f:
				return FRIEND_COLORS[i % FRIEND_COLORS.size()]
			i += 1
	return TEXT


func refresh() -> void:
	if not is_inside_tree():
		return
	var m = kampfort.mars
	# 988 (wolf_mess_438, Build 277: Wolf 3,6 m in einem Bild, Ansagen bis 156 dp): nur queue_free ließ die alten Kästen und Knöpfe bis
	# zum Ende des Bilds stehen, der Kasten war mit alten und neuen ein Bild lang 1207 statt 849 px hoch, die Kamera passte neu und alle
	# rückten mit dem Boden; seit 945 baut jeder Zug im Kampf die matten Knöpfe neu. Jetzt gleich heraus, dann frei
	for c in party_row.get_children():
		party_row.remove_child(c)
		c.queue_free()
	for f in m.fighters():
		if f.side != "PARTY":
			continue
		party_row.add_child(_party_box(f))
	_build_orders()
	if log_area:
		log_area.queue_redraw()


## 565 (Chef 04.11., 17:10: „unten sehe ich gar nicht, welcher von den beiden es ist“), nur Vorschlag, aus: "" wie alt (alle Kästen
## gleich), "A" der Kasten dessen, der am Zug ist, wie sein Feld in der Zugleiste (▶ vor dem Namen, erhaben, Goldrand 1,5 dp, Name
## hell), "B" dazu die übrigen der Gruppe mit gedämpftem Rand. Am Zug ist, wer in der Zugleiste das ▶ trägt; ist es ein Gegner, bleiben
## alle Kästen wie alt.
## 565 A (Chef 08.11., 13:11: „565 A“): A ist die Vorgabe; AMZUG565 (auch leer: wie alt) bleibt für Vergleichsbilder
var am_zug_565 := OS.get_environment("AMZUG565") if OS.has_environment("AMZUG565") else "A"

func _vorn():
	for id in kampfort.shown.get("queue", []):
		var o = kampfort.mars.find(id)
		if o != null and kampfort.shown.hp.get(id, o.hp) > 0:
			return o
	return null

func _am_zug(f) -> bool:
	return _vorn() == f


func _party_box_dran(f) -> bool:
	return am_zug_565 != "" and laeuft() and _am_zug(f)


## 751 A (Chef 09.11., 21:18, t272: keine Knöpfe, keine Zugreihenfolge, „weil ich dann im dritten Zug des Wolfes … tot war …
## das ist schon alles berechnet“): MARS rechnet den Kampf voraus; für den Spieler läuft er, bis alles gezeigt ist (679)
func laeuft() -> bool:
	return kampfort.mars.outcome == "ONGOING" or kampfort.busy


## PartyBox: Farbmarke, Name; Balken in Lebensfarbe und „hp/max“, bei Zauberern „ZP sp/max“ (ohne „LP“).
func _party_box(f) -> Control:
	var box := PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dran: bool = _party_box_dran(f)
	if dran:
		box.add_theme_stylebox_override("panel", _box(RAISED, GOLD, 6, 3, 1.5))
	elif am_zug_565 == "B" and laeuft() and _vorn() != null and _vorn().side == "PARTY":
		box.add_theme_stylebox_override("panel", _box(Color.BLACK, Color(RIM, 0.3), 6, 3, 1.0))
	else:
		box.add_theme_stylebox_override("panel", _box(Color.BLACK, RIM, 6, 3, 1.0))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(2 * dp))
	box.add_child(v)
	var hp: int = maxi(0, kampfort.shown.hp.get(f.id, f.hp))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", int(5 * dp))
	var mark := ColorRect.new()
	mark.color = _friend_color(f)
	mark.custom_minimum_size = Vector2(8, 8) * dp
	mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(mark)
	var n := Label.new()
	n.text = ("▶ " if dran else "") + f.name(lang)
	n.add_theme_font_size_override("font_size", sp(13))
	n.add_theme_color_override("font_color", WARN if hp <= 0 else (BRIGHT if dran else TEXT))
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n.clip_text = true
	top.add_child(n)
	v.add_child(top)
	var low := HBoxContainer.new()
	low.add_theme_constant_override("separation", int(6 * dp))
	var bar := ProgressBar.new()
	bar.max_value = f.max_hp
	bar.value = hp
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 4 * dp)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var track := StyleBoxFlat.new()
	track.bg_color = Color(1, 1, 1, 0.12)
	bar.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = hp_color(float(hp) / maxf(1.0, f.max_hp))
	bar.add_theme_stylebox_override("fill", fill)
	low.add_child(bar)
	var l := Label.new()
	var spv: int = kampfort.shown.sp.get(f.id, f.sp)
	l.text = "%d/%d" % [hp, f.max_hp] + ((t("  Mana %d/%d", "  Mana %d/%d") % [spv, f.max_sp]) if f.hero != null and not f.zauber.is_empty() else "")     # [870.14.kopf.mana]
	l.add_theme_font_size_override("font_size", sp(13))
	l.add_theme_color_override("font_color", TEXT)
	low.add_child(l)
	v.add_child(low)
	return box


## PixelButton im schwarzen Stil: eckig, Rahmen 1 dp, Großbuchstaben mit Laufweite; an: erhaben mit hellem Rahmen.
## 536 (SkirmishScreen detectTapGestures onLongPress): so lange gedrückt (s, Spielzeit egal), dann sagt der Knopf, was er tut
const LANG_S := 0.5


func _button(label: String, enabled := true, go: Callable = Callable(), selected := false, small := false, tip := []) -> Button:
	var b := Button.new()
	b.text = label.to_upper()
	b.disabled = not enabled
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, (48 if small else 52) * dp)
	var fv := FontVariation.new()
	fv.base_font = font
	fv.spacing_glyph = int(1.2 * dp)
	b.add_theme_font_override("font", fv)
	b.add_theme_font_size_override("font_size", sp(13))
	var n := _box(RAISED if selected else Color.BLACK, BRIGHT if selected else LINE, 6, 0, 1.5 if selected else 1.0)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", n)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("pressed", _box(RAISED, BRIGHT, 6, 0, 1.5))
	b.add_theme_stylebox_override("disabled", _box(Color.BLACK, Color(DIM, 0.4), 6, 0, 1.0))
	b.add_theme_color_override("font_color", BRIGHT if selected else TEXT)
	b.add_theme_color_override("font_hover_color", BRIGHT if selected else TEXT)
	b.add_theme_color_override("font_pressed_color", BRIGHT)
	b.add_theme_color_override("font_disabled_color", Color(DIM, 0.6))
	if not tip.is_empty():     # 536: langes Drücken zeigt, was der Knopf tut; losgelassen danach tut er nichts
		# 564 (Chef 04.11., 17:06: „Lambda capture at index 0 was freed“): ein kurzer Druck baut die Knöpfe neu, bevor der Zeitgeber
		# abläuft; der Zeitgeber hält den Knopf darum nur schwach (weakref), ein freigegebener Knopf ist dann einfach null
		b.button_down.connect(func():
			var t0 := Time.get_ticks_msec()
			b.set_meta("unten", t0)
			var schwach: WeakRef = weakref(b)
			get_tree().create_timer(LANG_S, true, false, true).timeout.connect(func():
				var bb = schwach.get_ref()
				if bb != null and bb.is_pressed() and int(bb.get_meta("unten", -1)) == t0:
					bb.set_meta("lang", true)
					show_tip(str(tip[lang]))))
	if go.is_valid():
		b.pressed.connect(func():
			if b.get_meta("lang", false):
				b.set_meta("lang", false)
				return
			go.call())
	return b


## Eine Knopfzeile; Wörter werden nie getrennt; lange Aufschriften bekommen mehr Breite, erst dann wird der Text kleiner,
## eine Größe für alle (Prüfer Lauf 14: „SÖLDNER SELBST“, „HELD SELBST“ kleiner als die übrigen Knöpfe).
func _row(items: Array, fs_cap := 0, even := false) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * dp))
	var fs := mini(_row_size(items), fs_cap) if fs_cap > 0 else _row_size(items)
	var ws := _text_widths(items, fs)
	for i in items.size():
		var b: Button = items[i]
		b.add_theme_font_size_override("font_size", fs)
		b.size_flags_stretch_ratio = 1.0 if even else maxf(ws[i], 1.0)
		r.add_child(b)
	return r


func _text_widths(items: Array, fs: int) -> Array:
	var ws := []
	for b in items:
		var fnt: Font = b.get_theme_font("font")
		ws.append(fnt.get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + b.text.length() * 1.2 * dp + 14 * dp)
	return ws


## Die größte Schrift (höchstens 13 sp), mit der alle Aufschriften der Zeile passen, wenn jeder Knopf nach seiner Aufschrift breit ist.
func _row_size(items: Array) -> int:
	var inner := get_viewport().get_visible_rect().size.x - 2 * (8 + 10) * dp - 6 * dp * (items.size() - 1)
	var fs := sp(13)
	while fs > int(9 * dp):
		var sum := 0.0
		for w in _text_widths(items, fs):
			sum += w
		if sum <= inner:
			break
		fs -= 1
	return fs


## Choices in rows: two side by side, three when there are more than four (SkirmishScreen.Choices), 48 dp high.
func _choices(items: Array) -> void:
	var per := 3 if items.size() > 4 else 2
	var i := 0
	while i < items.size():
		for b in items.slice(i, i + per):
			b.custom_minimum_size.y = 48 * dp
		orders.add_child(_row(items.slice(i, i + per)))
		i += per


## 751 A: wer aus der Gruppe als Nächster wählt, nach der gezeigten Zugleiste (nicht nach MARS, das schon weiter ist); sonst der Held.
func _naechster_eigener():
	var k = kampfort
	for id in k.shown.get("queue", []):
		var o = k.mars.find(id)
		if o != null and o.side == "PARTY" and k.shown.hp.get(id, o.hp) > 0:
			return o
	return k.mars.lead()


## 751 A: „<Name> ist dran“ über den Knöpfen, wer in der Zugleiste das ▶ trägt; Gruppe golden, Gegner rot wie dort.
func _dran_zeile() -> Label:
	var l := Label.new()
	var wer = _vorn()
	l.text = t("%s ist dran", "%s's turn") % wer.name(lang) if wer != null else " "
	l.add_theme_font_size_override("font_size", sp(14))
	l.add_theme_color_override("font_color", (GOLD if wer.side == "PARTY" else WARN) if wer != null else DIM)
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.clip_text = true
	return l


func _target_label(f) -> String:
	var hp: int = kampfort.shown.hp.get(f.id, f.hp)
	return "%s  %d/%d" % [f.name(lang), maxi(0, hp), f.max_hp]


func _spot_name(s: Vector2i) -> String:
	return t("vorn", "front") if s.x == Mars.FRONT else t("hinten", "back")


func _build_orders() -> void:
	# 532: Bericht und Befehle zusammen, so hoch wie jetzt; die Tasche nimmt beides ein, damit der Kasten (und die Kamera) nicht springt
	var ganz_h: float = (log_box.size.y + 6 * dp if log_box.visible else 0.0) + orders.size.y
	log_box.visible = true
	for c in orders.get_children():     # 988: gleich heraus (refresh), sonst ein Bild lang doppelt so hoch
		orders.remove_child(c)
		c.queue_free()
	var k = kampfort
	var m = k.mars
	if m.outcome != "ONGOING" and not k.busy:
		var won: bool = m.outcome == "WON"
		var fled: bool = m.outcome == "FLED"
		var l := Label.new()
		# [296.2.flucht]
		l.text = t("Du bist entkommen.", "You got away.") if fled else (t("Sieg.", "Victory.") if won else t("Der Kampf ist verloren.", "The fight is lost."))
		l.add_theme_font_size_override("font_size", sp(18))
		l.add_theme_color_override("font_color", TEXT if won or fled else WARN)
		orders.add_child(l)
		# 296.2: der Lohn wie im alten Kampf (EP, Gold, Beute, Stufe), eng untereinander, Luft zu den Knöpfen (Prüfer Runde 1)
		var lines: Array = k.reward.get("lines", [])
		if not lines.is_empty():
			l.add_theme_font_size_override("font_size", sp(22))
			var r := Label.new()
			r.text = "\n".join(lines)
			r.add_theme_font_size_override("font_size", sp(14))
			r.add_theme_constant_override("line_spacing", 0)
			r.add_theme_color_override("font_color", TEXT)
			r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			orders.add_child(r)
			var gap := Control.new()
			gap.custom_minimum_size.y = 6 * dp
			orders.add_child(gap)
		if m.knockouts > 0:
			var ko := Label.new()
			ko.text = t("Söldner bewusstlos: ", "Mercenaries knocked out: ") + str(m.knockouts)
			orders.add_child(ko)
		# SkirmishScreen: beide gleich breit (Prüfer: „Nochmal“ breiter als „Zurück“)
		# 399.2: aus dem Spiel (aufruf.gd) gibt es kein „Nochmal“, nur zurück in die Welt
		if k.again_fn.is_valid():
			orders.add_child(_row([_button(t("Nochmal", "Again"), true, func(): k.again()), _button(t("Zurück", "Back"), true, func(): k.finish())], 0, true))
		else:
			orders.add_child(_row([_button(t("Zurück", "Back"), true, func(): k.finish())], 0, true))
		return
	# 751 A (Chef 09.11., 17:46; t271–t273: „überhaupt keine Knöpfe mehr“, statt dessen „…“) und 833 A (10.11., 10:07: „Man kann es
	# ja auch ausgrauen“): solange ein anderer zieht (der Kampfort spielt, busy), stehen die Befehlsknöpfe matt an ihrem Platz, darüber
	# „<Name> ist dran“ nach der gezeigten Zugleiste, nie nach dem, was MARS schon vorausgerechnet hat. Die Zeile steht auch im eigenen
	# Zug, so bleibt der Kasten gleich hoch (709: sonst passt die Kamera neu). Gefragt wird MARS dabei nicht: der Regelfaden rechnet
	# gerade weiter. Söldner und Held Auto bleiben schaltbar, sie gelten ab der nächsten Wahl (mit dem Autopiloten ist der Kampfort
	# sonst immer beschäftigt, und er ließe sich nie mehr abschalten).
	var matt: bool = k.busy
	var f = _naechster_eigener() if matt else m.current()
	if f == null:
		return
	var back := _button(t("Zurück", "Back"), true, func(): _set_pick("main"))
	match "main" if matt else pick:
		"main":
			orders.add_child(_dran_zeile())
			var reach: Array = [] if matt else m.targets(f)
			var top := [
				_button(t("Angriff", "Attack"), not reach.is_empty(), func():
					if reach.size() == 1:
						k.order(["attack", reach[0].id])
					else:
						_set_pick("target"), false, false, Tips.ATTACK),
				_button(t("Können", "Abilities"),     # [870.14.knopf.koennen]
						 not matt and not m.moves(f).is_empty(), func(): _set_pick("skills"), false, false, Tips.SKILLS),
				_button(t("Tasche", "Bag"), not matt and not m.bag().is_empty(), func(): _set_pick("bag"), false, false, Tips.BAG),
				_button(t("Wechsel", "Switch"), not matt and (m.can_swap(f) or m.can_draw(f)), func(): _set_pick("place"), false, false, Tips.PLACE),
			]
			var low := [_button(t("Abwehr", "Defend"), not matt, func(): k.order(["wait"]), false, true, Tips.DEFEND)]
			# 296.2: fliehen wie im klassischen Kampf, nie vor einem Boss
			if not m.all.any(func(x): return x.side == "FOES" and x.boss()):
				low.append(_button(t("Flucht", "Run"), not matt and m.can_flee(f), func(): k.order(["flee"]), false, true))
			if f.hero != null and String(f.hero.get("cls", "")) == "FIGHTER":     # 870.4: der Held nach BRS hat keine Klasse
				low.append(_button(t("Decken", "Cover"), not matt and not m.guardable(f).is_empty(), func(): k.order(["guard"]), false, true, Tips.COVER))
			var merc = m.find("merc")
			if merc != null:
				low.append(_button(t("Söldner ", "Mercenary ") + (t("Auto", "auto") if merc.auto else t("selbst", "manual")), true, func():
					merc.auto = not merc.auto
					if merc.auto and m.current() == merc:
						k.go_on()
					refresh(), merc.auto, true, Tips.MERC))
			low.append(_button(t("Held ", "Hero ") + (t("Auto", "auto") if m.autopilot else t("selbst", "manual")), true, func():
				if m.autopilot:
					m.set_autopilot(false)
				else:
					var lead = m.lead()
					var why = m.autopilot_blocked(k.shown.hp.get(lead.id, lead.hp))
					if why != null:
						show_tip(why[lang])
					elif m.set_autopilot(true, k.shown.hp.get(lead.id, lead.hp)) and m.pilot_next():
						k.go_on()
				refresh(), m.autopilot, true, Tips.AUTOPILOT))
			# beide Zeilen in einer Schriftgröße
			var fs := mini(_row_size(top), _row_size(low))
			orders.add_child(_row(top, fs))
			orders.add_child(_row(low, fs))
		"target":
			var items := []
			for tg in m.targets(f):
				var id: String = tg.id
				items.append(_button(_target_label(tg), true, func(): k.order(["attack", id])))
			items.append(back)
			_choices(items)
		"place":
			var items := []
			var spare = f.spare() if m.can_draw(f) else null
			for s in Mars.SPOTS:
				if s.x == f.place.x:
					continue
				var who = null
				for o in m.fighters():
					if o.side == f.side and o.place == s and o.standing():
						who = o
				if who == null:
					var first_free = null
					for s2 in Mars.SPOTS:
						if s2.x == s.x and not m.fighters().any(func(o): return o.side == f.side and o.place == s2 and o.standing()):
							first_free = s2
							break
					if first_free != s:
						continue
				var label: String = _spot_name(s) + ((" ⇄ " + who.name(lang)) if who != null else t(" (frei)", " (free)"))
				var spot: Vector2i = s
				items.append(_button(label, m.can_swap(f), func(): k.order(["swap", spot, false])))
				if spare != null:
					items.append(_button(label + " + " + spare[["de", "en"][lang]], m.can_swap(f), func(): k.order(["swap", spot, true])))
			if spare != null:
				items.append(_button(t("Waffe: ", "Weapon: ") + spare[["de", "en"][lang]], true, func(): k.order(["draw"])))
			items.append(back)
			_choices(items)
		"skills":
			var items := []
			for s in m.moves(f):
				var sk: Dictionary = m.skills[s]
				var extra := ""
				if sk.cost == "SPELL_POINTS":
					extra = " %d" % int(sk.amount)
				elif sk.cost == "PER_BATTLE" or sk.cost == "PER_REST":
					extra = " ×%d" % f.uses.get(s, 0)
				var skill: String = s
				items.append(_button([sk.de, sk.en][lang] + extra, m.blocked(f, s) == null, func():
					var reach: Array = m.aim_at(f, skill)
					if Mars.ziel_von(skill) == "SELF":
						k.order(["use", skill, f.id])
					elif reach.size() == 1:
						k.order(["use", skill, reach[0].id])
					else:
						_set_pick("skill_at", skill)))
			items.append(back)
			_choices(items)
		"skill_at":
			var items := []
			for tg in m.aim_at(f, pick_arg):
				var row := ""
				if Mars.ziel_von(pick_arg) == "ROW":
					row = t("Reihe vorn: ", "Front row: ") if tg.place.x == Mars.FRONT else t("Reihe hinten: ", "Back row: ")
				var id: String = tg.id
				var skill: String = pick_arg
				items.append(_button(row + _target_label(tg), true, func(): k.order(["use", skill, id])))
			items.append(back)
			_choices(items)
		"bag":
			# 532 (t273.13, Chef: „Früher gab es da so eine Scroll-Liste“; alt BattleScreen.BagMenu): je Ding eine Zeile über die
			# ganze Breite, Bild links, Name und Anzahl, rollbar an der Stelle des Berichts; „Zurück“ fest darunter. Vorher drei Kästen
			# je Zeile, nach ihrer Aufschrift breit: mit „×10“ liefen sie rechts aus dem Schirm, „Zurück“ abgeschnitten
			var liste := VBoxContainer.new()
			liste.add_theme_constant_override("separation", int(6 * dp))
			liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for id in m.bag():
				var it: Dictionary = m.items[id]
				var item: String = id
				var zeile := HBoxContainer.new()
				zeile.add_theme_constant_override("separation", int(8 * dp))
				var bild := TextureRect.new()
				bild.texture = Kartenreiter.bild("ding-" + id)
				bild.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				bild.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				bild.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				bild.custom_minimum_size = Vector2(32, 32) * dp
				bild.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				zeile.add_child(bild)
				var wurf := String(it.get("kind", "")) == "BOMB"     # 935: Wurfmittel wirft man auf einen Gegner
				var b := _button("%s ×%d" % [[it.de, it.en][lang], int(m.potions[id])], true, func(): _set_pick("throw_at" if wurf else "drink_at", item), false, true)
				b.alignment = HORIZONTAL_ALIGNMENT_LEFT
				b.clip_text = true
				b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
				zeile.add_child(b)
				liste.add_child(zeile)
			var rolle := ScrollContainer.new()
			rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
			rolle.add_child(liste)
			log_box.visible = false
			back.custom_minimum_size.y = 48 * dp
			rolle.custom_minimum_size.y = maxf(ganz_h - 48 * dp - 6 * dp, 54 * dp)
			orders.add_child(rolle)
			orders.add_child(_row([back]))
		"drink_at":
			var items := []
			for tg in m.fighters():
				if tg.side == f.side and tg.standing():
					var id: String = tg.id
					var item: String = pick_arg
					# 532 (alt ALREADY_FULL): wem der Trank nichts bringt (volles Leben, beim Kräutertrank auch keine Zustände), der ist nicht wählbar
					items.append(_button("%s  %d/%d" % [tg.name(lang), tg.hp, tg.max_hp], m.drink_helps(item, tg), func(): k.order(["drink", item, id])))
			items.append(back)
			_choices(items)
		"throw_at":
			var items := []
			for tg in m.throw_targets(pick_arg):
				var id: String = tg.id
				var item: String = pick_arg
				items.append(_button(_target_label(tg), true, func(): k.order(["throw", item, id])))
			items.append(back)
			_choices(items)


func _set_pick(p: String, arg = null) -> void:
	pick = p
	pick_arg = arg
	_build_orders()


func show_tip(text: String) -> void:
	# 536 (Chef 04.11., 16:56: „Das erste Fenster … war riesig … Die anderen waren dann okay“; namen_536: erstes 6445 px hoch,
	# zweites 175 px): der Text kam, solange das Fenster noch 0 breit war, und brach nach jedem Wort um; erst die Breite, dann der Text
	var vs: Vector2 = get_viewport().get_visible_rect().size
	tip.size = Vector2(vs.x - 16 * dp, 0)
	tip.text = text
	tip.visible = true
	tip.position = Vector2(8 * dp, kampfort.scene_rect().size.y - 70 * dp)
	tip.size = Vector2(vs.x - 16 * dp, 0)
	tip_nr += 1
	var nr := tip_nr     # die Uhr eines früheren Fensters schließt nicht das neue
	get_tree().create_timer(6.0).timeout.connect(func(): if nr == tip_nr: tip.visible = false)
var tip_nr := 0


# ---------------------------------------------------------------- ring, rolls, verdict
func ring_open(target_id: String, _intent: Dictionary) -> void:
	ring_target = target_id
	ring_t0 = Time.get_ticks_msec()
	pick = "main"


func ring_close() -> void:
	ring_target = ""


func ring_verdict(r: String) -> void:
	verdict.text = {"PERFECT": t("Perfekt: ausgewichen", "Perfect: dodged"), "GOOD": t("Gut: halber Schaden", "Good: half damage"),
		"NONE": t("Verpasst", "Missed")}[r]
	verdict.visible = true
	var vs: Vector2 = get_viewport().get_visible_rect().size
	verdict.position = Vector2(0, kampfort.scene_rect().size.y * 0.18)
	verdict.size = Vector2(vs.x, 40 * dp)
	get_tree().create_timer(2.2 if r == "PERFECT" else 1.2).timeout.connect(func(): verdict.visible = false)


func show_roll(e: Dictionary) -> void:
	if e.roll != null and e.target != null:
		roll_shown = [e.target, e.roll, e.actor]
		roll_at = Time.get_ticks_msec()


# ---------------------------------------------------------------- drawing over the scene
## 536: was langes Drücken an [p] in der Szene sagt: auf einer Ansage, was sie heißt und was hilft (MarsTips intent, 210T);
## auf einem Gegner sein Name, seine Absicht und ihr Ziel (SkirmishScreen whoIs); sonst nichts.
## 536 (Chef 04.11., 17:02: „Auch kein Hilfetext, wenn ich den Status-Text oder Status-Effekt anklicke.“): das Zustandsschild unter
## [p] erklärt sich mit Namen und Wirkung (Status.kt title und desc, wortgetreu in Mars.STATUS_DESC); sonst „“
func _status_tip(p: Vector2) -> String:
	for e in status_rects:
		if (e[0] as Rect2).grow(4 * dp).has_point(p):
			var st: String = e[1]
			return "%s: %s" % [Mars.STATUS[st][0][lang], Mars.STATUS_DESC.get(st, ["", ""])[lang]]
	return ""


func scene_tip(p: Vector2) -> String:
	var k = kampfort
	if _status_tip(p) != "":
		return _status_tip(p)
	for id in sign_of:
		if (sign_of[id] as Rect2).grow(6 * dp).has_point(p) and k.shown.intents.has(id):
			var tx = Tips.INTENTS.get(String(k.shown.intents[id][0].id))
			if tx != null:
				return str(tx[lang])
	for id in k.figures:
		var fig = k.figures[id]
		var f = k.mars.find(id)
		if f == null or f.side != "FOES" or not fig.visible or fig.down:
			continue
		var h := _tall(fig)
		var ft := _foot(fig)
		if Rect2(ft.x - h * 0.5, ft.y - h * 1.1, h, h * 1.2).has_point(p):
			var s: String = f.name(lang)
			if k.shown.intents.has(id):
				var plan: Array = k.shown.intents[id]
				s += ": " + str(plan[0].name[lang])
				if plan.size() > 1 and not (plan[1] as Array).is_empty() and k.mars.find(plan[1][0]) != null:
					s += " → " + k.mars.find(plan[1][0]).name(lang)
			var w: String = k.mars.wissen(f, lang)     # 960: Schwächen ab Verstand 6 (870d)
			return s + ("\n" + w if w != "" else "")
	return ""


## 567: die Plätze links und rechts neben dem Kopf (spots 1 und 2 in _draw_intents)
static func _seitlich(qi: int) -> bool:
	return qi == 1 or qi == 2


## Foot point and height on the screen of a figure.
func _foot(fig) -> Vector2:
	return kampfort.screen_of(fig.position)


func _tall(fig) -> float:
	return maxf(20 * dp, _foot(fig).y - kampfort.screen_of(fig.head()).y)


## A circle on the ground round [p] (world), as the camera sees it. 561 (Chef 04.11., 16:56: „der Zuganzeiger, der goldene Kreis,
## wieder nicht dreidimensional richtig unterbrochen ist durch die Figur, die drin steht. Das war auch alles in der alten Fassung“;
## 17:00 ebenso die Zielringe): nicht mehr über alles gemalt, sondern als flaches Band am Boden in der Welt (_ringe_bauen), so
## verdecken Beine und Körper davor den Ring wie in BattleScene (CamRing); Breite [w] in Bildpunkten wie bisher, mit dunklem Rand
var _ring_liste := []
func _ground_ring(p: Vector3, r: float, c: Color, w: float) -> void:
	_ring_liste.append([p, r, c, w])


var _ringe: MeshInstance3D
var _ring_mesh: ImmediateMesh
const RING_HOCH := 0.02
func _ringe_bauen() -> void:
	if _ringe == null or not is_instance_valid(_ringe):
		_ring_mesh = ImmediateMesh.new()
		_ringe = MeshInstance3D.new()
		_ringe.name = "Ringe"
		_ringe.mesh = _ring_mesh
		_ringe.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.vertex_color_use_as_albedo = true
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_ringe.material_override = mat
		kampfort.add_child(_ringe)
	_ring_mesh.clear_surfaces()
	if _ring_liste.is_empty():
		return
	_ring_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for e in _ring_liste:
		var mdp: float = kampfort.m_per_dp(e[0])
		var w: float = float(e[3]) / dp * mdp
		_band(e[0], float(e[1]), w + 2.0 * mdp, Color(0, 0, 0, 0.5), RING_HOCH)
		_band(e[0], float(e[1]), w, e[2], RING_HOCH + 0.002)
	_ring_mesh.surface_end()
	_ring_liste.clear()


func _band(p: Vector3, r: float, w: float, c: Color, hoch: float) -> void:
	var innen := maxf(r - w * 0.5, 0.0)
	var aussen := r + w * 0.5
	for i in 40:
		var a0 := TAU * i / 40.0
		var a1 := TAU * (i + 1) / 40.0
		var d0 := Vector3(cos(a0), 0.0, sin(a0))
		var d1 := Vector3(cos(a1), 0.0, sin(a1))
		var y := Vector3(0, hoch, 0)
		for q in [d0 * innen, d0 * aussen, d1 * aussen, d0 * innen, d1 * aussen, d1 * innen]:
			_ring_mesh.surface_set_color(c)
			_ring_mesh.surface_add_vertex(p + y + q)


func _chip(rect: Rect2, bg: Color, border: Color, rim_dp: float) -> void:
	overlay.draw_rect(rect, bg)
	overlay.draw_rect(rect, border, false, maxf(1.0, rim_dp * dp))


func _draw_overlay() -> void:
	var k = kampfort
	var m = k.mars
	var sr: Rect2 = k.scene_rect()
	# SkirmishScreen: nach dem Ende kein Ring, keine Zugleiste, keine Schalter (Prüfer: nach dem Sieg noch Pfeil und Würfel).
	# 679 (Chef 08.11., 16:11, Build 269: „die Wölfe haben einen Lauf und ich habe keine Zusatzfunktionen mehr“): MARS rechnet im
	# Hintergrund voraus, der Ausgang steht fest, während die letzten Züge noch spielen; zu Ende ist es erst, wenn alles gezeigt ist
	var ended: bool = m.outcome != "ONGOING" and not k.busy
	var current = m.current() if not k.busy and not ended else null
	# under the figures: the ring under the one whose turn it is, chosen targets (CamRing)
	for id in k.figures:
		var fig = k.figures[id]
		if not fig.visible or k.shown.hp.get(id, fig.fighter.hp) <= 0:
			continue
		var beast: bool = Figur.vier(fig.fighter)
		if fig.fighter == current:
			_ground_ring(fig.position, 0.75 if beast else 0.55, BRIGHT, 2.5 * dp)
		elif pick == "target" and current != null and m.targets(current).has(fig.fighter):
			_ground_ring(fig.position, 0.75 if beast else 0.55, TEXT, 2.0 * dp)
	# the grid: the two places of each row on both sides
	if grid_on:
		for side in ["PARTY", "FOES"]:
			for row in [Mars.FRONT, Mars.BACK]:
				for slot in [0, 1]:
					var ab: Vector2 = k._stand(side == "FOES", row == Mars.BACK, slot, false)
					_ground_ring(k._ground(ab.x, ab.y), 0.45, Color(GOLD, 0.5), 1.5 * dp)
	_ringe_bauen()     # 561
	# triangles before the feet of those a foe aims at (CamAim)
	var aimed_at := {}
	for id in k.shown.intents:
		for aimed in k.shown.intents[id][1]:
			aimed_at[aimed] = true
	var away := Vector3(0, 0, -1)
	var across := Vector3(1, 0, 0)
	for id in aimed_at:
		if not k.figures.has(id):
			continue
		var fig = k.figures[id]
		if fig.fighter.side != "PARTY" or not fig.visible:
			continue
		var tri := PackedVector2Array()
		var welt: Array = []
		for q in [Vector2(0, -0.22), Vector2(-0.2, -0.5), Vector2(0.2, -0.5)]:
			welt.append(fig.position + across * q.x + away * q.y + Vector3(0, 0.02, 0))
			tri.append(k.screen_of(welt[welt.size() - 1]))
		if _hidden_by_front(fig, tri, welt):     # 348.7b r3 (Chef 10:43: „das Dreieck … müsste dann halt ebenentechnisch weg sein“)
			continue
		overlay.draw_colored_polygon(tri, _friend_color(fig.fighter))
		tri.append(tri[0])
		overlay.draw_polyline(tri, Color(0, 0, 0, 0.8), maxf(1.0, dp), true)
	# names only while choosing a target (NameTag); 536 (Chef 04.11., 16:56: „In der alten Fassung war es so, dass die Bezeichnungen
	# der Gegner eingeblendet wurden, auch wenn man länger drückt“; 17:00: „Ein Wolfsname steht da, die anderen stehen nicht da“):
	# wie alt jeder Wählbare und nach langem Drücken alle drei Sekunden lang (sanft aus, SOFT_MS); die Ansage steigt dann über den
	# Namen (_draw_intents named), vorher lag sie auf ihm
	named.clear()
	name_rects.clear()
	var weich := clampf(float(names_until - Time.get_ticks_msec()) / SOFT_MS, 0.0, 1.0)
	var waehlbar: Array = m.targets(current) if pick == "target" and current != null else []
	for id in k.figures:
		var fig = k.figures[id]
		var f = fig.fighter
		if not fig.visible or fig.down or k.shown.hp.get(id, f.hp) <= 0:
			continue
		var a: float = 1.0 if waehlbar.has(f) else weich
		if a > 0.0:
			named[id] = true
			name_rects[id] = _name_tag(_foot(fig), _tall(fig), f.name(lang), f == current, a, f.side == "FOES")
	_draw_spells()
	# 249: Blut unter den Ansagen (Prüfer 26.10.: Tropfen lagen auf dem Text)
	_draw_blood()
	if zustand_563 != "":
		# 563: nur die Leisten dieses Bilds (Zustände weichen ihnen aus); die des letzten Bilds meiden die Ansagen
		balken_vor = balken_of.duplicate()
		balken_of.clear()
	_draw_intents(sr)
	# life bars only over foes (MarsLabels.barsOnlyFoes); wer eine Ansage hat, trägt ihn unter ihr (_draw_intents)
	for id in k.figures:
		var fig = k.figures[id]
		var f = fig.fighter
		var hp: int = k.shown.hp.get(id, f.hp)
		if f.side != "FOES" or not fig.visible or (hp <= 0 and not fig.falling()) or sign_of.has(id):
			continue
		var p := _foot(fig)
		var top := p.y - _tall(fig) - 8 * dp
		var w := 44 * dp
		var r := Rect2(p.x - w / 2, top, w, 4 * dp)
		# Prüfer Runde 27: über dem Kopf des vorderen Wolfs lag der Balken auf den Pfoten des hinteren und las sich als dessen;
		# dann unter die eigenen Pfoten
		var unten := false
		var below := p.y + 4 * dp + _tall(fig) * 0.1
		for oid in k.figures:
			var o = k.figures[oid]
			if oid != id and o.visible and k.shown.hp.get(oid, o.fighter.hp) > 0:
				var of := _foot(o)
				var ot := _tall(o)
				var half: float = ot * (0.8 if Figur.vier(o.fighter) else 0.45)
				if r.grow(3 * dp).intersects(Rect2(of.x - half, of.y - ot, half * 2.0, ot + 6 * dp)):
					unten = below + r.size.y <= sr.size.y - 4 * dp
					break
		# 563 (Chef 04.11., 17:02: die grüne Leiste lief durch die Schrift der Ansage): auch nie auf der Ansage eines anderen
		if zustand_563 != "" and not unten:
			for o in sign_rects:
				if r.grow(2 * dp).intersects(o):
					unten = below + r.size.y <= sr.size.y - 4 * dp
					break
		# 438 (Prüfer Film r2: Leisten springen über und unter, 18,6 s, 33,0 s): der Platz wechselt erst, wenn der andere 0,8 s lang
		# besser ist (vorher 0,3 s: 9 Wechsel in 48 s), und gleitet dann hin
		var bu = bar_unten.get(id, [unten, -1.0])
		if unten != bu[0]:
			if bu[1] < 0.0:
				bu[1] = k.clock_ms
			elif k.clock_ms - bu[1] >= 800.0:
				bu = [unten, -1.0]
		else:
			bu[1] = -1.0
		bar_unten[id] = bu
		if bu[0] and below + r.size.y <= sr.size.y - 4 * dp:
			r.position.y = below
		r.position = p + _gleiten("balken:" + String(id), r.position - p)
		balken_of[id] = r.position
		overlay.draw_rect(r.grow(1), Color(0, 0, 0, 0.7))
		overlay.draw_rect(Rect2(r.position, Vector2(w * clampf(float(hp) / f.max_hp, 0, 1), r.size.y)), hp_color(float(hp) / f.max_hp))
	if zustand_563 != "":
		_paint_signs()
	_draw_statuses(sr)
	if ended:
		grid_rect = Rect2()
		dice_rect = Rect2()
		tempo_rect = Rect2()
		win_rect = Rect2()
		lose_rect = Rect2()
	else:
		_draw_turns(sr)
		_draw_switches(sr)
	# the roll over the one struck (RollTag)
	var age := Time.get_ticks_msec() - roll_at
	if dice_on and roll_shown != null and age < ROLL_MS + ROLL_FADE_MS and k.figures.has(roll_shown[0]):
		_roll_tag(sr, k.figures[roll_shown[0]], roll_shown[1], roll_shown[2], 1.0 - clampf(float(age - ROLL_MS) / ROLL_FADE_MS, 0, 1))
	# the ring: a large ring closing on a small one round the one attacked (RingAround)
	if ring_target != "" and k.figures.has(ring_target):
		var fig = k.figures[ring_target]
		var h := _tall(fig)
		var c2 := _foot(fig) - Vector2(0, h * 0.45)
		var p3 := clampf(float(Time.get_ticks_msec() - ring_t0) / k.RING_MS, 0.0, 1.3)
		var r0 := h * 0.55
		overlay.draw_arc(c2, r0, 0, TAU, 48, Color(GOLD, 0.55), 1.5 * dp, true)
		overlay.draw_arc(c2, r0 * (1.0 + 1.6 * maxf(0.0, 1.0 - p3)), 0, TAU, 64, BRIGHT, 4.0 * dp, true)
		var hint := t("Tippen, wenn der große Ring auf dem kleinen liegt", "Tap when the large ring lies on the small one")
		overlay.draw_string(font, Vector2(0, sr.size.y - 12 * dp), hint, HORIZONTAL_ALIGNMENT_CENTER, sr.size.x, sp(14), DIM)


## 249: ein Treffer, der blutet: [by] schlug [on]; [hurt] wie schwer der Getroffene danach verwundet ist (0..1).
func bleed(by: String, on: String, crit: bool, hurt: float, monster_id: String) -> void:
	var gore: String = {"skeleton": "BONE", "zombie": "ICHOR", "ghoul": "ICHOR", "ochre_jelly": "SLIME"}.get(monster_id, "BLOOD")
	bleeding = {"by": by, "on": on, "crit": crit, "hurt": clampf(hurt, 0.0, 1.0), "gore": gore,
		"seed": int(bleeding.get("seed", 0)) + 1, "t0": kampfort.clock_ms}


var _in_row := {}     # Wirkender und Art -> [Start ms, Nummer in Folge]

## 348.7: ein Zauber oder Pfeil von by nach on, ab after_ms; kommt nach Zauber.arrives am Ziel an. 348.7b: steht ein eigener
## Mann in der Linie, tritt der Wirkende erst zur Seite; gibt zurück, um wie viele ms der Zauber darum später losgeht
func cast(kind: String, by: String, on: String, crit: bool, missed: bool, after_ms := 0.0) -> float:
	spell_seed += 1
	var k = kampfort
	var step_ms := 0.0
	# 993: der Arkanpfeil aus R2 fliegt gerade wie Funkenpfeil und Pfeil, darum mit Seitenschritt (348.7b (1)); die Ausnahme (5) galt
	# den gefächerten Geschossen
	var r2: bool = kind == "MISSILES" and by != on and arkan_r2() != null and k.figures.has(by) and k.figures.has(on)
	if (kind in STEP_KINDS or r2) and by != on and k.figures.has(by) and k.figures.has(on):
		step_ms = _step_aside(kind, k.figures[by], k.figures[on], after_ms, Zauber.arrives(kind))
	after_ms += step_ms
	if r2:
		_arkan_flug(k.figures[by], k.figures[on], missed, after_ms)
		return step_ms
	# 348.7a Runde 5 (Prüfer r4: „drei Strahlen eine Bahn“): der wievielte Strahl dieses Wirkenden in Folge
	var t: float = k.clock_ms + after_ms
	var last: Array = _in_row.get(by + kind, [-INF, -1])
	var nr: int = last[1] + 1 if t - float(last[0]) < 3000.0 else 0
	_in_row[by + kind] = [t, nr]
	spells.append({"kind": kind, "by": by, "on": on, "crit": crit, "missed": missed, "seed": spell_seed * 7919,
		"t0": k.clock_ms + after_ms, "nr": nr})
	# Feuer wirft Licht auf Gegner und Boden (Helfer Lauf 126: „Feuer ohne Licht“; DESIGN-STIL Signatur: Licht aus Quellen)
	if kind in ["FIRE_BOLT", "RAYS", "FIREBALL", "BURNING_HANDS"]:
		k.fire_light(on, after_ms + Zauber.arrives(kind), Zauber.duration(kind) - Zauber.arrives(kind), kind == "FIREBALL")
	return step_ms


## 993 (Chef 11.11., 20:47, Test 277, Probekampf Zauberlehrling: Arkanpfeil „sieht überhaupt nicht gut aus“): ein Pfeil aus R2
## Stylized Projectiles, Element arcane (LISTE-EFFEKTE: R2 arcane; gekauft 623, Chef 08.11., 19:42 zu den Proben:
## „die Effekte sind besser als unsere eigenen“), statt der drei gemalten Splitter aus dem alten Spiel (BRS: ein Pfeil).
## Von der Stabspitze zur Brust des Ziels, daneben auf den freien Fleck am Boden (_miss_point); er kommt nach Zauber.arrives an wie
## bisher, dann zeigt der Kampfort den Treffer. Aufruf des Pakets wie in der Probe 623.5 (effektprobe.gd _projektil, 163f07e84).
## Fehlt das Paket (am Rechner, in den Tests ohne Kaufrepo), malt zauber.gd wie bisher.
const ARKAN_R2 := "res://addons/reeboo_projectiles/elements/arcane/arcane_projectile.tscn"
static var _arkan_szene = null     # PackedScene, false: nicht da
## 993, für den Test arkan_993: je Flug [Knoten, Start, Ziel, Ankunft in ms Uhrzeit]
var arkan_fluege: Array = []

static func arkan_r2() -> PackedScene:
	if _arkan_szene == null:
		_arkan_szene = load(ARKAN_R2) if ResourceLoader.exists(ARKAN_R2) else false
	return _arkan_szene if _arkan_szene is PackedScene else null


func _arkan_flug(by, on, missed: bool, after_ms: float) -> void:
	if after_ms > 0.0:
		get_tree().create_timer(after_ms / 1000.0).timeout.connect(func(): _arkan_los(by, on, missed))
	else:
		_arkan_los(by, on, missed)


func _arkan_los(by, on, missed: bool) -> void:
	var k = kampfort
	if not is_instance_valid(k) or not is_instance_valid(by) or not is_instance_valid(on):
		return
	var dir: Vector3 = (on.position - by.position) * Vector3(1, 0, 1)
	dir = dir.normalized() if dir.length() > 0.01 else Vector3.ZERO
	var hand = by.cast_point()
	var von: Vector3 = hand if hand != null else by.position + Vector3.UP * (by.head().y - by.position.y) * START_UP + dir * (_girth(by) + 0.1)
	var ziel: Vector3 = _miss_point(by, on, true) if missed else _aim_point(on, dir)
	var s := maxf(Zauber.arrives("MISSILES") / 1000.0, 0.05)
	var p := arkan_r2().instantiate()
	for kv in [["fly_on_ready", false], ["collision_mask", 0], ["impact_on_expire", true],
			["speed", maxf(von.distance_to(ziel), 0.1) / s], ["lifetime", s]]:
		if kv[0] in p:
			p.set(kv[0], kv[1])
	k.add_child(p)
	if p.has_method("launch"):
		p.call("launch", von, ziel - von, -1.0, true)
	arkan_fluege.append([p, von, ziel, Time.get_ticks_msec() + s * 1000.0])


## 348.7b (Chef 27.10., 19:49): wer einen eigenen Mann in der geraden Linie von Hand oder Stabspitze zum Ziel hat, tritt einen
## kleinen Schritt nach links oder rechts (die Seite, auf der das Ziel am Hindernis vorbei liegt; die nähere freie), wirkt dort
## und tritt zurück: nur Darstellung, Gegner ebenso; ein Gegner in der Linie zählt nicht (keine Deckung), das Magische Geschoss
## braucht keinen Schritt. Gibt die Dauer des Schritts zurück (ms, 0: Linie frei)
const STEP_KINDS := ["ARROW", "FIRE_BOLT", "RAYS", "FIREBALL", "BURNING_HANDS"]
# 348.7b r3 b (Chef 28.10., 10:43, Votum Jerry): bis 2 m, damit der Start im Bild neben der eigenen Figur liegt (bei 0,8 m lag er auf
# der Heldin; nach Rechnung r3 etwa 1,7 m); längere Wege mit STEP_V statt fest STEP_S, sonst flöge er
const STEP_M := [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
const STEP_S := 0.22     # je Weg hin und zurück, kürzester
const STEP_V := 4.0      # m/s für längere Schritte
const BH_FLAME := Zauber.BH_FLAME

func _step_aside(kind: String, by, on, after_ms: float, arrives_ms: float) -> float:
	var k = kampfort
	var dir: Vector3 = (on.position - by.home) * Vector3(1, 0, 1)
	if dir.length() < 0.01:
		return 0.0
	dir = dir.normalized()
	var side := Vector3(-dir.z, 0, dir.x)
	var hand = by.cast_point()
	var rel: Vector3 = (hand - by.position) if hand != null else Vector3.UP * (by.head().y - by.position.y) * START_UP
	var b3: Vector3 = _aim_point(on, dir)
	var mates := []
	for id in k.figures:
		var o = k.figures[id]
		if o != by and o != on and o.visible and not o.down and o.fighter.side == by.fighter.side:
			mates.append(o)
	var blocker = _line_blocker(by.home + rel, b3, mates)
	if blocker == null:
		return 0.0
	# zuerst die Seite zur Bildmitte (Prüfer 348.7b r1: zum Rand hin stand Bertram halb außerhalb des Bildes), sonst die, auf der
	# das Ziel neben dem Hindernis liegt; der Fleck muss ganz im Bild liegen
	var vs: Vector2 = overlay.get_viewport_rect().size
	var mid_x: float = vs.x * 0.5
	var first: float = signf(side.dot(on.position - blocker.position))
	if first == 0.0:
		first = 1.0
	var to_mid: float = k.screen_of(by.home + side * 0.5).x - k.screen_of(by.home - side * 0.5).x
	if absf(to_mid) > 1.0:
		first = signf(to_mid) * signf(mid_x - k.screen_of(by.home).x)
	# der kleinste Schritt mit freier Linie und Platz; einer, der aus dem Bild führt, zählt wie 2 m mehr
	var off := Vector3.ZERO
	var best := INF
	for m in STEP_M:
		for sg in [first, -first]:
			var q: Vector3 = by.home + side * (m * sg)
			var room := INF
			for id in k.figures:
				var o = k.figures[id]
				if o != by and o.visible and not o.down:
					room = minf(room, o.clearance(q))
			if room <= 0.15 or _line_blocker(q + rel, b3, mates) != null:
				continue
			var sx: float = k.screen_of(q).x
			var cost: float = m + (0.01 if sg != first else 0.0) + (2.0 if sx < vs.x * 0.1 or sx > vs.x * 0.9 else 0.0)
			if _starts_on_mate(q + rel, b3, mates):     # Prüfer r2: Feuerball über der Schulter der Heldin, „als käme er aus ihr“
				cost += 3.0     # r3 b: lieber jeder längere Schritt (bis 2 m) als ein Start auf dem eigenen Mann
			if cost < best:
				best = cost
				off = side * (m * sg)
	if off == Vector3.ZERO:     # kein freier Fleck: ein halber Meter zur Bildmitte
		off = side * (0.5 * first)
	if OS.get_environment("SCHRITT_DEBUG") != "":
		print("Seitenschritt %s -> %s: %s in der Linie, %+.1f m (Bild %s, Platz x %.0f, Seite zur Mitte %+.0f, Start auf eigenem Mann: %s)" % [by.fighter.id, on.fighter.id, blocker.fighter.id, off.dot(side), vs, k.screen_of(by.home).x, first, _starts_on_mate(by.home + off + rel, b3, mates)])
	var hold := maxf(arrives_ms, 250.0) / 1000.0 + 0.15
	if kind == "BURNING_HANDS":     # Prüfer r1: der Kegel hing am Seitenplatz, als er schon zurücktrat; er bleibt, solange er brennt
		hold = Zauber.duration(kind) * BH_FLAME / 1000.0
	var step_s := maxf(STEP_S, off.length() / STEP_V)
	if after_ms > 0.0:
		get_tree().create_timer(after_ms / 1000.0).timeout.connect(func(): by.side_step(off, hold, step_s))
	else:
		by.side_step(off, hold, step_s)
	return step_s * 1000.0


## 348.7b Prüfer r2 (am Seitenplatz stand Bertram im Bild genau vor der Heldin, Feuerpfeil und Feuerball begannen auf Höhe
## ihrer Brust und Schulter): ob Start oder erstes Viertel der Bahn a → b am Schirm im Umriss eines eigenen Manns liegt
func _starts_on_mate(a: Vector3, b: Vector3, mates: Array) -> bool:
	var k = kampfort
	var sa: Vector2 = k.screen_of(a)
	var sb: Vector2 = k.screen_of(b)
	for o in mates:
		var box: AABB = o.footprint()
		var r := Rect2(k.screen_of(o.global_transform * box.get_endpoint(0)), Vector2.ZERO)
		for i in range(1, 8):
			r = r.expand(k.screen_of(o.global_transform * box.get_endpoint(i)))
		r = r.grow(4 * dp)
		for f in [0.0, 0.08, 0.16, 0.25]:
			if r.has_point(sa.lerp(sb, f)):
				return true
	return false


## 348.7b r3: das Dreieck am Boden liegt im Bild auf einer Figur, die näher an der Kamera steht (Bertram im Seitenschritt vor der
## Heldin); die Überlage malt über alles, darum dann gar nicht
func _hidden_by_front(fig, pts: PackedVector2Array, welt := []) -> bool:
	var k = kampfort
	var cp: Vector3 = k.cam.global_position
	var d: float = cp.distance_to(fig.position)
	for id in k.figures:
		var o = k.figures[id]
		if o == fig or not o.visible or o.down or cp.distance_to(o.position) >= d:
			continue
		# 438 (Prüfer Film r2: Ansgars Dreieck 11 s fort, Bertrams ab 43,2): der Kasten um den Kaufkörper (1,8 m hoch) deckte im Bild
		# weit mehr als der Körper; jetzt der Blick von der Kamera zu jeder Ecke gegen die Kapseln um die Knochen (ein Wolf vor dem
		# Dreieck verdeckt es auch nur, wo sein Körper ist)
		var kap: Array = o.kapseln() if not welt.is_empty() else []
		if not kap.is_empty():
			for q in welt:
				for c in kap:
					var s: PackedVector3Array = Geometry3D.get_closest_points_between_segments(cp, q, c[0], c[1])
					if s[0].distance_to(s[1]) < float(c[2]) + 0.02:
						return true
			continue
		var box: AABB = o.footprint()
		var r := Rect2(k.screen_of(o.global_transform * box.get_endpoint(0)), Vector2.ZERO)
		for i in range(1, 8):
			r = r.expand(k.screen_of(o.global_transform * box.get_endpoint(i)))
		for p in pts:
			if r.has_point(p):
				return true
	return false


## Brust des Ziels, zum Wirkenden hin (Ende der Bahn)
func _aim_point(on, dir: Vector3) -> Vector3:
	return on.position + Vector3.UP * (on.head().y - on.position.y) * 0.55 - dir * _girth(on)


## Die erste der Figuren figs, durch deren Umriss (eine Handbreit darum) die Strecke a → b läuft; sonst null
func _line_blocker(a: Vector3, b: Vector3, figs: Array):
	for o in figs:
		var inv: Transform3D = o.global_transform.affine_inverse()
		var box: AABB = o.footprint().grow(0.05)
		for i in range(1, LANE_STEPS):
			if box.has_point(inv * a.lerp(b, float(i) / LANE_STEPS)):
				return o
	return null


## Wie BattleFxLayer im alten MARS, u = Höhe des Getroffenen / 40, bei kritisch 1,35-fach. 348.7a (Chef 27.10., 09:38): im Raum
## gemalt als Tafeln (tafel.gd), Figuren davor verdecken. 348.7b (Chef 27.10., 19:36 „D“): gerade von Hand oder Stabspitze
## (Figur.cast_point, beim Loslassen festgehalten) zur Brust des Getroffenen, über alles hinweg, was dazwischen steht
func _draw_spells() -> void:
	var k = kampfort
	if spells.is_empty() and tafel == null:
		return
	var t0 := Time.get_ticks_usec()
	if tafel == null:
		tafel = Tafel.new(k, k.cam)
	tafel.begin(overlay.get_viewport_rect().size)
	zauber.ci = tafel
	Zauber.cam = k.cam
	var still := []
	for sp in spells:
		var dur := Zauber.duration(sp.kind)
		var p: float = (k.clock_ms - float(sp.t0)) / dur
		if p >= 1.0 or not k.figures.has(sp.on):
			continue
		still.append(sp)
		if p < 0.0:
			continue
		var on = k.figures[sp.on]
		var by = k.figures.get(sp.by, on)
		var to := _foot(on)
		var tall := _tall(on)
		var flying: bool = by != on and sp.kind in ["ARROW", "FIRE_BOLT", "MISSILES", "FIREBALL", "RAYS", "BURNING_HANDS", "WEB"]
		var dir: Vector3 = (on.position - by.position) * Vector3(1, 0, 1)
		dir = dir.normalized() if dir.length() > 0.01 else Vector3.ZERO
		var h_by: float = by.head().y - by.position.y
		if not sp.has("from"):
			var hand = by.cast_point() if flying else null
			sp["from"] = hand if hand != null else by.position + Vector3.UP * h_by * (START_UP if flying else 0.55) + dir * (_girth(by) + 0.1 if flying else 0.0)
		var a3: Vector3 = sp["from"]
		var b3: Vector3 = _aim_point(on, dir)
		var u := tall / 40.0 * (1.35 if sp.crit else 1.0)
		Zauber.d_to = _depth(b3)
		# 348.7a Prüfer 1b (Feuerpfeil, Feuerball, Heilige Flamme brannten hinter Kopf und Brust des Wolfs): der Einschlag liegt
		# vor der Figur, in der Tiefe ihres der Kamera nächsten Umrisspunkts
		Zauber.d_hit = _front_depth(on)
		Zauber.m_px = (on.head().y - on.position.y) / maxf(tall, 1.0)
		# Prüfer Runde 4d: der Fehlschuss lag auf dem Wolf vor dem Ziel („Treffer am falschen Wolf“); der freieste Fleck, im Raum
		# gewählt (348.7a Prüfer 1b: am Schirm lag die Heilige Flamme im Busch hinten)
		Zauber.miss_at = Vector2.INF
		if sp.missed and (flying or sp.kind == "SACRED_FLAME"):     # die Heilige Flamme fällt neben dem Ziel (leckte am Nachbarn)
			if not sp.has("miss"):
				sp["miss"] = _miss_point(by, on, flying)
			Zauber.miss_at = k.screen_of(sp["miss"])
			Zauber.d_miss = _depth(sp["miss"])
		var from: Vector2 = k.screen_of(a3)
		Zauber.d_from = _depth(a3)
		Zauber.bahn.clear()
		zauber.draw(sp.kind, int(sp.seed), p, from, k.screen_of(b3), u, to.y, sp.missed)
		if Zauber.pruef and flying:
			_bahn_pruef(sp, by, on, p)
	spells = still
	tafel.end()
	if tafel.verts > 0:
		tafel_ecken = tafel.verts
		tafel_us = Time.get_ticks_usec() - t0


var _umriss := {}

## 348.7a Runde 3 (Prüfer r2: Strahl durch Wolf 3 und hinter Bertrams Kopf, Geschoss daneben durch Wolf 3 und 1): je Bild, wie viele
## Bahnpunkte im Umriss einer Figur stecken (im Raum, unter dem Kopf) und wie viele am Schirm hinter ihr liegen (verdeckt)
func _bahn_pruef(sp, by, on, p: float) -> void:
	var k = kampfort
	const C := 12
	var txt := ""
	for id in k.figures:
		var o = k.figures[id]
		if not o.visible or o.down:
			continue
		_cells(id)
		var inside := 0
		var hidden := 0
		var over := 0
		var box: AABB = o.footprint()
		for q in Zauber.bahn:
			var loc: Vector3 = o.global_transform.affine_inverse() * q
			if o != on and box.grow(-0.05).has_point(loc) and q.y < o.head().y:
				inside += 1
			var c := Vector2i(k.screen_of(q) / C)
			if _umriss[id].has(c) and _depth(q) > _umriss[id][c] + 0.15:
				hidden += 1
			elif _umriss[id].has(c) and o != on:
				over += 1
		if inside > 0 or hidden > 0 or over > 0:
			txt += " %s%s: in %d, verdeckt %d, davor %d;" % [id, " (Ziel)" if o == on else (" (wirkt)" if o == by else ""), inside, hidden, over]
	print("Bahn %s %.2f %d Punkte:%s" % [sp.kind, p, Zauber.bahn.size(), txt if txt != "" else " frei"])


## Probe: Zellen (12 px) am Schirm mit der nächsten Tiefe der Figur, aus den Netzen in Ruhelage
func _cells(id: String) -> void:
	if _umriss.has(id):
		return
	var k = kampfort
	var cells := {}
	for mi in k.figures[id].find_children("*", "MeshInstance3D", true, false):
		var m: Mesh = (mi as MeshInstance3D).mesh
		if m == null:
			continue
		for si in m.get_surface_count():
			var vs: PackedVector3Array = m.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
			for i in range(0, vs.size(), 3):
				var w: Vector3 = (mi as MeshInstance3D).global_transform * vs[i]
				var c := Vector2i(k.screen_of(w) / 12)
				cells[c] = minf(cells.get(c, INF), _depth(w))
	_umriss[id] = cells


## 348.7a: Start der Geschosse in Anteilen der Höhe des Wirkenden (Brust bis Schulter)
const START_UP := 0.5     # Runde 5 (Prüfer r4: Start wirkt aus Bertrams Kopf): an der Hand statt vor der Brust


## Tiefe (m vor der Kamera) des der Kamera nächsten Punkts im Umriss der Figur, eine Handbreit davor
func _front_depth(fig) -> float:
	var box: AABB = fig.footprint()
	var best := INF
	for i in 8:
		best = minf(best, _depth(fig.global_transform * box.get_endpoint(i)))
	return maxf(best - 0.1, 0.3)


## 348.7a Prüfer 1b: Fehlschuss am Boden im Raum, neben dem Ziel und etwas davor (Geschosse) oder seitlich (Heilige Flamme), wo
## am meisten Platz zu jeder Figur ist; nicht hinter dem Ziel (dort Busch und Bäume) und im Bild
func _miss_point(by, on, flying: bool) -> Vector3:
	var k = kampfort
	var a: Vector3 = by.position * Vector3(1, 0, 1)
	var b: Vector3 = on.position * Vector3(1, 0, 1)
	var dir := (b - a).normalized() if a.distance_to(b) > 0.01 else Vector3.FORWARD
	var side := Vector3(-dir.z, 0, dir.x)
	var d_on := _depth(b)
	var vs: Vector2 = overlay.get_viewport_rect().size
	var best := b + side
	var best_score := -INF
	var rects := _lane_obs(by, null)     # Runde 5 (Prüfer r4: Feuerpfeil daneben schlug über dem Hinterteil von Wolf 2 ein)
	for back in ([0.4, 0.8, 1.2] if flying else [0.0, 0.3]):
		for lat in [-0.7, 0.7, -1.0, 1.0, -1.4, 1.4]:
			var q: Vector3 = b - dir * back + side * lat
			var sq: Vector2 = k.screen_of(q)
			if sq.x < vs.x * 0.08 or sq.x > vs.x * 0.92:
				continue
			var clear := INF
			for id in k.figures:
				var o = k.figures[id]
				if o.visible and not o.down:
					clear = minf(clear, o.clearance(q))
			var score: float = minf(clear, 0.8) - maxf(_depth(q) - d_on, 0.0) - absf(lat) * 0.1
			for ob in rects:     # am Schirm im Umriss einer Figur: verdeckt oder „auf“ ihr
				# Runde 6 (Prüfer r5: Feuerpfeil daneben deckt 20 px des Hinterteils von Wolf 3): mit dem Funkenkreis des Einschlags
				if ob.rect.grow(24 * dp).has_point(sq):
					score -= 1.0
			if score > best_score:
				best_score = score
				best = q
	return best


## Wie weit eine Figur um ihre Mitte reicht (m): Wölfe sind lang und stehen mit der Brust zur Gruppe
func _girth(fig) -> float:
	var beast: bool = Figur.vier(fig.fighter)
	return (0.4 if beast else 0.25) * (kampfort.foe_scale(fig.fighter) if fig.fighter.monster != null else 1.0)


## Meter vor der Kamera
func _depth(q: Vector3) -> float:
	return -(kampfort.cam.global_transform.affine_inverse() * q).z


## Je stehende Figur: Umkehrung ihrer Lage, Kasten (_lane_box), Umriss am Schirm (Rechteck um den Kasten, etwas eingezogen, der
## Kasten reicht über Schnauze und Rute), Tiefe, ob sie wirkt oder getroffen wird
func _lane_obs(by, on, missed := false) -> Array:
	var k = kampfort
	var obs := []
	for id in k.figures:
		var o = k.figures[id]
		if not o.visible or o.down:
			continue
		var box: AABB = o.footprint()
		var r := Rect2(k.screen_of(o.global_transform * box.get_endpoint(0)), Vector2.ZERO)
		for i in range(1, 8):
			r = r.expand(k.screen_of(o.global_transform * box.get_endpoint(i)))
		# Runde 5 (Prüfer r4: Pfeil daneben über der Brust von Wolf 1): beim Fehlschuss ist das Ziel ein Hindernis wie jede Figur
		obs.append({"inv": o.global_transform.affine_inverse(), "box": _lane_box(o), "by": o == by, "on": o == on and not missed,
			"rect": r.grow_individual(-r.size.x * 0.1, -r.size.y * 0.05, -r.size.x * 0.1, 0.0), "depth": _depth(o.position)})
	return obs


## Kasten einer Figur, dem die Bahn fernbleibt: LANE_GAP ringsum, über Gegnern bis über den Lebensbalken (Prüfer r3: vier
## Zauber liefen durch den Balken von Wolf 3, der am Schirm über allem liegt)
func _lane_box(o) -> AABB:
	var box: AABB = o.footprint().grow(LANE_GAP)
	if o.fighter.side == "FOES":
		box.size.y += BAR_M
	return box


const LANE_STEPS := 24
## Abstand (m), den die Bahn zu jeder Figur hält, die sie nicht wirkt oder trifft (Linie frei, 348.7b)
const LANE_GAP := 0.15
## Runde 4: Höhe des Lebensbalkens über dem Kopf eines Gegners (m, mit Rand), den der Fehlschuss meidet
const BAR_M := 0.35


## 249 (BattleBlood.kt drawBloodSpray): Tropfen von der Brust des Getroffenen, weg vom Schlagenden und etwas aufwärts, die zu
## Boden fallen; mehr bei kritisch und je schwerer verwundet. Maß wie alt: dort steht ein Wolf rund 40 Einheiten hoch.
func _draw_blood() -> void:
	if bleeding.is_empty():
		return
	var k = kampfort
	var level: int = k.blood_level()
	var p: float = (k.clock_ms - bleeding.t0) / (1300.0 if level >= 2 else 750.0)
	if level <= 0 or p >= 1.0 or not k.figures.has(bleeding.on):
		if p >= 1.0:
			bleeding = {}
		return
	var on = k.figures[bleeding.on]
	var to := _foot(on)
	var from := _foot(k.figures[bleeding.by]) if k.figures.has(bleeding.by) else to
	var tall := _tall(on)
	var dx := to.x - from.x
	var dy := (to.y - from.y) * 0.5 - 0.3 * to.distance_to(from)
	var base := -25.0 if dx == 0.0 and dy == 0.0 else rad_to_deg(atan2(dy, dx))
	var unit := tall / 40.0
	var origin := Vector2(to.x, to.y - tall * 0.55)
	var ground := to.y
	var cols: Array = GORE[bleeding.gore]
	var rnd := RandomNumberGenerator.new()
	rnd.seed = int(bleeding.seed) * 31
	var count := maxi(int(((15 if level >= 2 else 6) + ((8 if level >= 2 else 3) if bleeding.crit else 0)) * (0.55 + 1.1 * bleeding.hurt)), 2)
	var flight := 0.55 if level >= 2 else 1.0
	for i in count:
		var ang := deg_to_rad(base + rnd.randf_range(-70.0, 55.0))
		var speed := unit * ((rnd.randf() * 70.0 + 40.0) if level >= 2 else (rnd.randf() * 45.0 + 25.0))
		var size := unit * ((rnd.randf() * 2.2 + 1.6) if level >= 2 else (rnd.randf() * 1.4 + 1.1))
		var delay := rnd.randf() * 0.12
		var light := rnd.randi_range(0, 2) == 0
		var t := clampf((p - delay) / flight, 0.0, 1.0)
		if t <= 0.0:
			continue
		var x := origin.x + cos(ang) * speed * t
		var y := origin.y + sin(ang) * speed * t + 160.0 * unit * t * t
		var landed := y >= ground
		if landed:
			y = ground
		var fade := (1.0 - clampf((p - 0.55) / 0.45, 0.0, 1.0)) if level >= 2 else (1.0 - clampf((t - 0.6) / 0.4, 0.0, 1.0))
		if fade <= 0.0:
			continue
		var c: Color = cols[1] if light else cols[0]
		if landed and level >= 2:
			# ein kleiner Fleck am Boden, flach in der Schräge
			var r := Rect2(x - size * 1.6, y - size * 0.4, size * 3.2, size * 0.9)
			overlay.draw_set_transform(r.get_center(), 0.0, Vector2(1.0, r.size.y / r.size.x))
			overlay.draw_circle(Vector2.ZERO, r.size.x / 2.0, Color(c, 0.85 * fade))
			overlay.draw_set_transform(Vector2.ZERO)
		elif not landed:
			# ein runder Tropfen mit kurzer Spur dahinter
			overlay.draw_circle(Vector2(x, y), size * 0.55, Color(c, fade))
			overlay.draw_circle(Vector2(x - cos(ang) * size * 0.9, y - sin(ang) * size * 0.9 - 2.0 * unit * t), size * 0.35, Color(c, fade * 0.5))


var placed_status := []
var placed_status_of := []     # 563: wem die Zeile gehört (Messung tests/zustaende_563.gd)
var status_rects := []     # 536: [Rect2, Zustand] je gezeichnetes Schild
## 563 (Chef 04.11., 17:02: „die Statuseffekte sind ja gruselig“); 563 A (Chef 08.11., 13:09: „563 A mit hellerem Rot“) ist die
## Vorgabe, ZUSTAND563 (auch leer: wie vorher) bleibt für Vergleichsbilder
var zustand_563 := OS.get_environment("ZUSTAND563") if OS.has_environment("ZUSTAND563") else "A"
const ROT_HELLER_563 := 0.3     # Blut (C8283A) um so viel heller, auf Schwarz lesbar
var balken_vor := {}    # 563: Leisten des letzten Bilds


## Whether status signs at [r] would lie on another figure, an intent sign or signs placed before.
func _status_clash(r: Rect2, own: String) -> bool:
	var k = kampfort
	for o in sign_rects + placed_status:
		if r.intersects(o.grow(2 * dp)):
			return true
	# 563: auch nie auf einer Lebensleiste
	if zustand_563 != "":
		for bid in balken_of:
			if r.intersects(Rect2(balken_of[bid], Vector2(44 * dp, 4 * dp)).grow(2 * dp)):
				return true
	for id in k.figures:
		var o = k.figures[id]
		if id == own or not o.visible or k.shown.hp.get(id, o.fighter.hp) <= 0:
			continue
		var of := _foot(o)
		var ot := _tall(o)
		var half: float = ot * (0.8 if Figur.vier(o.fighter) else 0.45)
		if r.intersects(Rect2(of.x - half, of.y - ot - 8 * dp, half * 2.0, ot + 12 * dp)):
			return true
	return false


## 563: die Schilder der Zustände von [id]: [[Text, Breite, Farbe, Zustand], …], Gesamtbreite, Höhe; leer ohne Zustand
func _status_chips(id) -> Array:
	var k = kampfort
	var st_of: Dictionary = k.shown.get("status", {})
	if not st_of.has(id) or (st_of[id] as Dictionary).is_empty():
		return []
	var fs := sp(11)
	var gap := 4 * dp
	var chips := []
	var width := -gap
	for st in st_of[id]:
		var left: int = st_of[id][st]
		var label: String = Mars.STATUS[st][1][lang] + ("" if left >= Mars.LASTING else " %d" % left)
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 10 * dp
		chips.append([label, w, Mars.STATUS[st][2], st])
		width += w + gap
	return [chips, width, fs * 1.3 + 2 * dp]


## 296.2: the statuses with the turns left, as in the old fight (StatusChips), under the feet of each who has any;
## lower still where an intent sign lies there.
## 563 (Vorschlag, aus): "A" im Stil der Ansage (schwarz, Rand und Schrift in der Farbe des Zustands), weicht auch den Lebensleisten
## aus; die Leisten weichen den Ansagen, die Ansagen den Leisten
func _draw_statuses(sr: Rect2) -> void:
	var k = kampfort
	var fs := sp(11)
	var gap := 4 * dp
	placed_status.clear()
	placed_status_of.clear()
	status_rects.clear()
	for id in k.shown.get("status", {}):
		if not k.figures.has(id):
			continue
		var fig = k.figures[id]
		if not fig.visible or k.shown.hp.get(id, fig.fighter.hp) <= 0:
			continue
		var zs := _status_chips(id)
		if zs.is_empty():
			continue
		var chips: Array = zs[0]
		var width: float = zs[1]
		var h: float = zs[2]
		var foot := _foot(fig)
		var x := clampf(foot.x - width / 2, 4 * dp, sr.size.x - width - 4 * dp)
		var y := foot.y + 8 * dp + _tall(fig) * 0.12
		# Prüfer: unter dem grauen Wolf lagen sie auf dem schwarzen davor; dann seitlich am eigenen Rumpf, sonst über dem Kopf
		var half: float = _tall(fig) * (0.8 if Figur.vier(fig.fighter) else 0.45)
		var mid := foot.y - _tall(fig) * 0.5 - h / 2
		# Prüfer Runde 2: seitlich lag „Betäubt“ noch auf dem eigenen Hinterteil; weiter weg, und nie an den Rand gedrückt
		var spots := [Vector2(x, y), Vector2(foot.x + half * 1.15 + gap, mid), Vector2(foot.x - half * 1.15 - gap - width, mid),
			Vector2(x, foot.y - _tall(fig) - 12 * dp - h)]
		# Runde 16: wer eine Ansage hat, trägt die Zustände gleich darüber (schwebten ohne Bezug über der Ansage des grauen Wolfs)
		if sign_of.has(id):
			var sg: Rect2 = sign_of[id]
			# unter den Pfoten darunter, sonst lägen sie zwischen Wolf und Ansage auf Strich und Balken
			var under: bool = sg.position.y > foot.y
			spots.push_front(Vector2(sg.get_center().x - width / 2, sg.end.y + gap if under else sg.position.y - gap - h))
		# Prüfer Runde 3: ging nichts davon, fiel es auf die Lage unter den Füßen zurück; dann höher über den Kopf, bis frei
		var row := Rect2(clampf(x, 4 * dp, sr.size.x - width - 4 * dp), spots[3].y, width, h)
		while _status_clash(row, id) and row.position.y - 26 * dp >= 34 * dp:
			row.position.y -= 26 * dp
		for q in spots:
			var r := Rect2(clampf(q.x, 4 * dp, sr.size.x - width - 4 * dp), q.y, width, h)
			var squeezed: bool = q != spots[0] and q != spots[spots.size() - 1] and not (sign_of.has(id) and q == spots[1]) and (absf(r.position.x - q.x) > 0.5 or r.position.x < 12 * dp or r.end.x > sr.size.x - 12 * dp)
			if not squeezed and r.end.y <= sr.size.y - 4 * dp and not _status_clash(r, id):
				row = r
				break
		placed_status.append(row)
		placed_status_of.append(id)
		_status_row(row, chips, h, fs, gap)


## die Schilder einer Zeile ab [row]; 563 A, B im Stil der Ansage
func _status_row(row: Rect2, chips: Array, h: float, fs: int, gap: float) -> void:
	for c in chips:
		var r := Rect2(row.position.x, row.position.y, c[1], h)
		status_rects.append([r, c[3]])
		if zustand_563 != "":
			# wie die Ansage (_draw_intents): schwarz, Rand in der Farbe, Schrift etwas heller, damit Dunkelrot auf Schwarz lesbar bleibt
			var c2: Color = c[2]
			if c[3] == "BLEED":
				c2 = c2.lightened(ROT_HELLER_563)     # 563 A (Chef 08.11., 13:09: „mit hellerem Rot“)
			_chip(r, Color(0, 0, 0, 0.85), c2, 1.0)
			overlay.draw_string(font, Vector2(r.position.x + 5 * dp, r.position.y + h * 0.76), c[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c2.lerp(Color.WHITE, 0.3))
		else:
			overlay.draw_rect(r, c[2])
			overlay.draw_rect(r, Color(0, 0, 0, 0.8), false, maxf(1.0, dp))
			# Prüfer: Weiß auf Gelb und hellem Grün zu schwach; auf hellen Farben schwarz
			var ink: Color = Color.BLACK if c[2].get_luminance() > 0.45 else Color.WHITE
			overlay.draw_string(font, Vector2(r.position.x + 5 * dp, r.position.y + h * 0.76), c[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
		row.position.x += c[1] + gap


const NAMES_MS := 3000     # SkirmishScreen NAMES_MS
const SOFT_MS := 400.0     # SkirmishScreen SOFT_MS
var names_until := 0
var named := {}     # 536: wer gerade seinen Namen trägt (die Ansage steigt darüber)
var name_rects := {}     # 536 t270.10: wo die Namen dieses Bilds stehen; keine Ansage legt sich darauf

func _name_h() -> float:
	return sp(12) * 1.35 + 2 * dp

## 536 t268.20 (Chef 07.11.: „Aktion der Jungwölfe dann sehr weit von Wolf weg“): Oberkante wie alt (SkirmishScreen NameTag:
## y - tall - 28 dp mit Leiste, sonst 24 dp); vorher lag hier die Unterkante, Name und Ansage standen 18 dp zu hoch
func _name_top(foot: Vector2, tall: float, bar: bool) -> float:
	return foot.y - tall - (28.0 if bar else 24.0) * dp

func _name_tag(foot: Vector2, tall: float, nm: String, now: bool, alpha := 1.0, bar := true) -> Rect2:
	var fs := sp(12)
	var w := font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 12 * dp
	var h := _name_h()
	var r := Rect2(foot.x - w / 2, _name_top(foot, tall, bar), w, h)
	var rim: Color = GOLD if now else RIM
	_chip(r, Color(0, 0, 0, alpha), Color(rim, rim.a * alpha), 1.0)
	var tc: Color = BRIGHT if now else TEXT
	overlay.draw_string(font, Vector2(r.position.x + 6 * dp, r.position.y + h * 0.76), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(tc, tc.a * alpha))
	return r


## Ansagen (IntentSign): „! Anspringen“ im Rahmen, Farbe des Angezielten; von unten nach oben ohne Überlappen (layOut).
func _draw_intents(sr: Rect2) -> void:
	var k = kampfort
	var m = k.mars
	var fs := sp(14)
	var signs := []
	for id in k.shown.intents:
		# 348.7 (Helfer Lauf 126): wer fällt, sagt nichts mehr an (die Ansage zeigte bis zur Meldung „fällt“ auf leeren Boden)
		if not k.figures.has(id) or not k.figures[id].visible or k.figures[id].down:
			continue
		var fig = k.figures[id]
		var plan: Array = k.shown.intents[id]
		var intent: Dictionary = plan[0]
		var mark := "!"
		match intent.kind:
			"STRIKE":
				mark = "!!" if intent.strong else "!"
			"CALL":
				mark = "»"
			"GATHER":
				mark = "!" if intent.get("effect") == "CIRCLE" else "+"
			"WAIT":
				mark = "…"     # 399.2b: Jungwolf knurrt nur, kein Angriff
		var tg = m.find(plan[1][0]) if not plan[1].is_empty() else null
		var fc: Color = _friend_color(tg) if tg != null else GOLD
		var border: Color = WARN if intent.strong else fc
		var bw := (2.0 if tg != null else 1.0) if intent.strong else 1.0
		var tc: Color = fc if tg != null else (WARN if intent.strong else BRIGHT)
		var ring: bool = intent.kind == "STRIKE" and intent.get("ring", false)
		var label: String = intent.name[lang]
		var w := font.get_string_size(mark + " " + label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 12 * dp + (18 * dp if ring else 0.0)
		# Runde 16: der Lebensbalken hängt unter der Ansage (lag beim vorderen Wolf allein unter den Pfoten, ohne Bezug)
		var ch := fs * 1.35 + 4 * dp
		var h := ch + 10 * dp     # 6 dp Abstand, 4 dp Balken (Prüfer: mit 3 dp „Unterstrich“ der Ansage)
		var foot := _foot(fig)
		# über dem Kopf des Ansagenden, mittig (Prüfer Stand 7: „! Anspringen“ schwebte links daneben ohne Bezug)
		var head_y := foot.y - _tall(fig) - 10 * dp
		var want_y := head_y - 6 * dp - h
		if named.has(id):     # 536 wie alt (242: „over the name while names show“)
			want_y = _name_top(foot, _tall(fig), true) - 4 * dp - h
		var x := clampf(foot.x - w / 2, 4 * dp, sr.size.x - w - 4 * dp)
		# Prüfer Stand 9: Ansagen der vorderen Wölfe lagen auf dem hinteren; daneben am eigenen Kopf, wenn darüber ein anderer steht
		var side := _tall(fig) * (0.8 if Figur.vier(fig.fighter) else 0.42) + 4 * dp
		var head_mid := head_y + 10 * dp - h
		signs.append({"x": x, "y": want_y, "w": w, "h": h, "ch": ch, "mark": mark, "label": label, "border": border, "bw": bw, "tc": tc, "ring": ring,
			"fx": foot.x, "head": head_y, "top": foot.y - _tall(fig) * (1.0 if _bat(fig) else 0.88), "hx": kampfort.screen_of(fig.head()).x, "id": id, "alts": [
				Vector2(clampf(foot.x - side - w, 4 * dp, sr.size.x - w - 4 * dp), head_mid),
				Vector2(clampf(foot.x + side, 4 * dp, sr.size.x - w - 4 * dp), head_mid),
				# unter den Pfoten, wenn darüber und daneben andere stehen (Prüfer Runde 6: Schild ohne Strich über dem falschen Wolf)
				# Runde 24: knapp unter dem Ursprung ragte es in die Läufe (die vorderen Pfoten stehen im Bild tiefer)
				Vector2(x, foot.y + 10 * dp + _tall(fig) * 0.2)], "foot": foot.y, "paw": foot.y + _tall(fig) * 0.12})
	signs.sort_custom(func(a, b): return a.y > b.y)
	# Körper aller Figuren (Rumpf ohne Kopfraum), damit keine Ansage auf einem anderen liegt
	var bodies := {}
	for id in k.figures:
		var o = k.figures[id]
		# 348.7 (Prüfer 26.10.: beim tödlichen Treffer sprang die Ansage des Nachbarn über den Sterbenden): wer fällt, steht noch im Bild
		if o.visible and not o.lunging() and (k.shown.hp.get(id, o.fighter.hp) > 0 or o.falling()):
			var of := _foot(o)
			var ot := _tall(o)
			# ein Wolf ist länger als hoch: im Bild etwa 1,6 mal so breit (Prüfer: Ansage lag auf dem Hinterteil des grauen)
			var half: float = ot * (0.8 if Figur.vier(o.fighter) else 0.45)
			bodies[id] = Rect2(of.x - half, of.y - ot - 12 * dp, half * 2.0, ot + 12 * dp)
	var placed := []
	var step := 26 * dp
	for s in signs:
		# Prüfstufe: 2 frei von fremden Körpern samt Strich, 1 nur der Schild frei von Körpern, 0 wie alt (SkirmishScreen layOut):
		# nur nie auf einer anderen Ansage, einem Namen oder einer Leiste
		var clash := func(r: Rect2, mode: int) -> bool:
			for o in placed:
				if r.intersects(Rect2(o.x, o.y, o.w, o.h).grow(2 * dp)):
					return true
			# 536 t270.10 (Chef 08.11., 20:54: beim rechten Jungwolf verdeckte die Ansage den Namen): nie auf einem Namen, auch dem eigenen
			for nid in name_rects:
				if r.intersects((name_rects[nid] as Rect2).grow(1 * dp)):
					return true
			# 563: nie auf der Lebensleiste eines anderen (die grüne Leiste lief durch die Schrift)
			for bid in balken_vor:
				if bid != s.id and r.intersects(Rect2(balken_vor[bid], Vector2(44 * dp, 4 * dp)).grow(2 * dp)):
					return true
			if mode == 0:
				return false
			# auch der Strich zum eigenen Kopf darf durch keinen anderen laufen (Prüfer Runde 4: durch das Hinterteil des grauen)
			var a := _stroke_from(r, s.fx, s.head)
			var e := _stroke_to(r, s)
			for id in bodies:
				if id != s.id and (r.intersects(bodies[id]) or (mode == 2 and _seg_hits(a, e, bodies[id].grow(-2 * dp)))):
					return true
			return false
		var spots: Array = [Vector2(s.x, s.y)] + s.alts
		var frei := func(q: Vector2, mode: int) -> bool:
			return q.y >= 34 * dp and q.y + s.h <= sr.size.y - 4 * dp and not clash.call(Rect2(q.x, q.y, s.w, s.h), mode)
		# 536 t270.10 (Chef 08.11., 20:54, Foto Wolfsrudel: „Klappt wohl nicht so, oder????“, wiederholt nach t268.20): die Ansagen
		# hingen seitlich mit langer Linie statt dicht über dem Kopf (Messung ansage_536: mit Namen jede zweite). Wie alt zuerst über
		# dem eigenen Kopf (über dem Namen), auch wenn dahinter ein anderer steht; deckt sie eine andere Ansage, einen Namen oder eine
		# Leiste, eine Zeile höher (höchstens drei); erst danach die Plätze neben dem Kopf und unter den Pfoten
		var wege: Array = [[0, 2, 0.0], [0, 0, 0.0]]
		for i in range(1, 4):
			wege.append([-1, 0, -step * i])
		wege += [[1, 2, 0.0], [2, 2, 0.0], [3, 2, 0.0], [3, 1, 0.0]]
		var y: float = s.y
		var x: float = s.x
		var done := false
		s.stroke = true
		# 438 (Prüfer Film r2: Ansagen springen über und unter, 21,6–25 s): der Platz vom letzten Bild bleibt, solange er frei ist und
		# kein besserer frei wird (536: vorher blieb eine Ansage seitlich, auch wenn über dem Kopf längst Platz war)
		var alt = sign_wahl.get(s.id)
		var bester := -1
		for wi in wege.size():
			var w0: Array = wege[wi]
			var q: Vector2 = spots[w0[0]] if w0[0] >= 0 else Vector2(s.x, s.y + w0[2])
			if frei.call(q, w0[1]):
				bester = wi
				break
		if alt != null and alt.size() == 3 and alt[0] < spots.size():
			var q: Vector2 = spots[alt[0]] if alt[0] >= 0 else Vector2(s.x, s.y + alt[2])
			var rang := wege.find(alt)
			if rang < 0:
				rang = wege.size()
			# 567: ohne Strich nie neben dem Kopf
			if not (alt[1] != 2 and _seitlich(alt[0])) and (bester < 0 or rang <= bester) and frei.call(q, alt[1]):
				x = q.x
				y = q.y
				done = true
				s.stroke = alt[1] != 1
		if not done and bester >= 0:
			var w1: Array = wege[bester]
			var q: Vector2 = spots[w1[0]] if w1[0] >= 0 else Vector2(s.x, s.y + w1[2])
			x = q.x
			y = q.y
			done = true
			s.stroke = w1[1] != 1     # geht der Strich durch einen anderen, lieber keiner (Prüfer Runde 5)
			sign_wahl[s.id] = w1.duplicate()
		if not done:
			# höher über dem eigenen Kopf, bis frei
			var yy: float = s.y
			while clash.call(Rect2(s.x, yy, s.w, s.h), 0) and yy - step >= 34 * dp:
				yy -= step
			x = s.x
			y = yy
			sign_wahl[s.id] = [-1, 0, yy - s.y]
		# 438: ein neuer Platz wird angefahren (gut 0,1 s), nicht gesprungen
		var fuss := Vector2(s.fx, s.foot)
		var ziel := fuss + _gleiten("ansage:" + String(s.id), Vector2(x, y) - fuss)     # am eigenen Fußpunkt, sonst hinkt es dem Laufenden nach
		s.x = ziel.x
		s.y = ziel.y
		placed.append(s)
	sign_rects.clear()
	sign_of.clear()
	for s in placed:
		sign_rects.append(Rect2(s.x, s.y, s.w, s.h))
		sign_of[s.id] = Rect2(s.x, s.y, s.w, s.h)
	signs_placed = placed
	# 563 A: gemalt erst nach den Lebensleisten (_draw_overlay), damit keine fremde Leiste durch die Schrift läuft (Chef 04.11., 17:02,
	# Bild: die grüne Leiste eines anderen Wolfs über „pringen“ von „! Anspringen“)
	if zustand_563 == "":
		_paint_signs()


var signs_placed := []     # 563: die Ansagen dieses Bilds, gesetzt, noch nicht gemalt

## die gesetzten Ansagen malen: Strich zum Ansagenden, eigene Leiste, Schild mit Zeichen und Namen
func _paint_signs() -> void:
	var k = kampfort
	var m = k.mars
	var fs := sp(14)
	for s in signs_placed:
		var r := Rect2(s.x, s.y, s.w, s.h)
		# a thin stroke down to the one who announces it, so a sign pushed up still belongs to someone
		var a := _stroke_from(r, s.fx, s.head)
		var e := _stroke_to(r, s)
		# 536: über dem eigenen Namen endet der Strich an ihm (lief sonst senkrecht durch die Schrift)
		if name_rects.has(s.id) and r.end.y <= (name_rects[s.id] as Rect2).position.y + 1:
			e.y = minf(e.y, (name_rects[s.id] as Rect2).position.y)
		if s.stroke and a.distance_to(e) > 2 * dp and (r.position.y > s.foot or s.head - r.end.y > 2 * dp or s.fx < r.position.x or s.fx > r.end.x):
			overlay.draw_line(a, e, Color(s.border, 0.7), maxf(1.0, dp), true)
		var f = m.find(s.id)
		var hp: int = k.shown.hp.get(s.id, f.hp) if f != null else 0
		# Balken 44 dp wie über dem Kopf, auf der Seite zum Wolf und auf dem Strich (Prüfer: in Schildbreite „Sockel des Schilds“)
		var below: bool = r.position.y > s.head + 20 * dp
		if f != null and hp > 0:
			var bw := 44 * dp
			var bar := Rect2(clampf(s.fx, r.position.x + bw / 2, r.end.x - bw / 2) - bw / 2, r.position.y if below else r.end.y - 4 * dp, bw, 4 * dp)
			overlay.draw_rect(bar.grow(1), Color(0, 0, 0, 0.7))
			overlay.draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(float(hp) / f.max_hp, 0, 1), bar.size.y)), hp_color(float(hp) / f.max_hp))
		if below:
			r.position.y = r.end.y - s.ch
		r.size.y = s.ch
		_chip(r, Color.BLACK, s.border, s.bw)
		var x: float = r.position.x + 6 * dp
		var base: float = r.position.y + s.ch * 0.74
		overlay.draw_string(font, Vector2(x, base), s.mark, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, s.tc)
		x += font.get_string_size(s.mark + " ", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if s.ring:
			overlay.draw_arc(Vector2(x + 6.5 * dp, r.position.y + s.ch / 2), 6.5 * dp, 0, TAU, 24, GOLD, 1.5 * dp, true)
			x += 18 * dp
		overlay.draw_string(font, Vector2(x, base), s.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, s.tc)


## 438 (Prüfer Film r2: Leisten und Ansagen springen über und unter): der gezeigte Ort folgt [ziel] in etwa GLATT_MS;
## war [key] eine Weile nicht zu sehen, steht er gleich dort
func _gleiten(key: String, ziel: Vector2) -> Vector2:
	var now: float = kampfort.clock_ms
	var g = glatt.get(key)
	if g == null or now - g[1] > 250.0:
		glatt[key] = [ziel, now]
		return ziel
	var p: Vector2 = (g[0] as Vector2).lerp(ziel, 1.0 - exp(-(now - g[1]) / GLATT_MS))
	# 438 (wolf_mess_438, Lauf 153: Ansage von Wolf 3 wechselte von oben links nach unten rechts, gut 200 dp; ein Viertel davon
	# im ersten Bild sind 47 dp): ein weiter Weg wird mit höchstens GLATT_DP_MS je ms gefahren, nie gesprungen
	var cap: float = GLATT_DP_MS * dp * maxf(now - g[1], 0.0)
	if p.distance_to(g[0]) > cap:
		p = (g[0] as Vector2) + ((p - g[0]) as Vector2).normalized() * cap
	glatt[key] = [p, now]
	return p


## Der Hintergrund des Kastens folgt seiner Höhe; ändert sie sich, passt die Kamera neu. 709 (treffen_709, Grimmzahn: stand im Zug
## eines anderen „…“ statt der Knöpfe, wurde der Kasten niedriger, die Kamera passte neu und alle rückten mit dem Boden 0,65 m,
## nur der Weg des Helden, der gerade zum Hieb ging, nicht: die Klinge schlug 0,45 m vor dem Wolf in die Luft): während eines
## Zugs nie, erst wenn er vorbei ist (kampfort._done)
var _passt_warte := 0
func panel_passt() -> void:
	var vs2: Vector2 = get_viewport().get_visible_rect().size
	backdrop.position = Vector2(0, vs2.y - panel_height())
	backdrop.size = Vector2(vs2.x, panel_height())
	if kampfort.busy and kampfort.zuege > 0:     # beim Aufbau (vor dem ersten Zug) gleich, wie bisher
		return
	# 992 (kamera_992: nach dem letzten Treffer wuchs der Kasten um eine Zeile, 849 → 881 px, die Kamera passte neu, der Boden rückte
	# 0,32 m, 47 px in einem Bild): ist der Kampf aus, bleibt die Kamera, wo sie ist
	if kampfort.mars != null and kampfort.mars.outcome != "ONGOING" and fitted_h > 0.0:
		return
	if absf(panel.size.y - fitted_h) > 1.0:
		# 864 (beam_864, Wölfe): wer gerade noch geht, folgt einer festen Bahn; rückte der Boden dabei, sprang er danach 0,65 m. Darum
		# erst, wenn alle stehen (höchstens 2 s warten)
		if kampfort.zuege > 0 and _passt_warte < 20:
			for fig in kampfort.figures.values():
				if fig.dead_at < 0 and fig.tween != null and fig.tween.is_running():
					_passt_warte += 1
					get_tree().create_timer(0.1).timeout.connect(panel_passt)
					return
		_passt_warte = 0
		fitted_h = panel.size.y
		kampfort._fit_camera()


## Zugleiste (TurnBar) oben links: „▶ “ vor dem, der dran ist, dann alle in Zugfolge, „|“ und der Erste der nächsten Runde.
func _draw_turns(sr: Rect2) -> void:
	var k = kampfort
	var m = k.mars
	var fs := sp(13)
	var x := 6 * dp
	var y := 6 * dp + rand_oben()     # 552: unter dem schwarzen Band über der Kamera des Handys (Rand, 399.4)
	turns_top = y
	var h := fs * 1.35 + 4 * dp
	var q: Array = []
	for id in k.shown.get("queue", []):
		var f = m.find(id)
		if f != null and k.shown.hp.get(id, f.hp) > 0:
			q.append(f)
	var items := []
	for i in q.size():
		items.append([q[i], i == 0, false])
	if not q.is_empty():
		items.append(["|", false, false])
		items.append([q[0], false, true])
	for it in items:
		if typeof(it[0]) == TYPE_STRING:
			var bw := font.get_string_size("|", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 4 * dp
			overlay.draw_string(font, Vector2(x + 2 * dp, y + h * 0.74), "|", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, DIM)
			x += bw + 3 * dp
			continue
		var f = it[0]
		var now: bool = it[1]
		var next: bool = it[2]
		var hero: bool = f.side == "PARTY"
		var label: String = ("▶ " if now else "") + f.name(lang) + (" …" if next else "")
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 14 * dp
		if x + w > sr.size.x - 6 * dp:
			x = 6 * dp
			y += h + 3 * dp
		var r := Rect2(x, y, w, h)
		if now:
			_chip(r, RAISED, GOLD if hero else WARN, 1.5)
		elif next:
			_chip(r, Color.BLACK, Color(DIM, 0.4), 1.0)
		else:
			_chip(r, Color.BLACK, RIM if hero else Color(WARN, 0.67), 1.0)
		var tc: Color = BRIGHT if now else (DIM if next else (TEXT if hero else WARN))
		overlay.draw_string(font, Vector2(x + 7 * dp, y + h * 0.74), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, tc)
		x += w + 3 * dp


## Schalter unten rechts in der Szene: Raster (3×3-Gitter) und Würfel (fünf Augen), je 40 dp.
func _draw_switches(sr: Rect2) -> void:
	# 1001 (alt 229.1, 260, SkirmishScreen.kt 1330: „away while the ring wants a tap anywhere or a tip is shown“): Raster, Würfel, Tempo
	# und die Prüfknöpfe sind weg, solange der Ring auf ein Tippen wartet, ein Hinweis oder das Urteil des Rings steht
	if kampfort.ring_open or ring_target != "" or tip.visible or verdict.visible:
		grid_rect = Rect2()
		dice_rect = Rect2()
		tempo_rect = Rect2()
		win_rect = Rect2()
		lose_rect = Rect2()
		return
	var s := 40 * dp
	var y := sr.size.y - 4 * dp - 44 * dp
	grid_rect = Rect2(sr.size.x - 4 * dp - 44 * dp, y, 48 * dp, 48 * dp)
	dice_rect = Rect2(sr.size.x - 52 * dp - 48 * dp, y, 48 * dp, 48 * dp)
	var g := Rect2(grid_rect.position + Vector2(4, 4) * dp, Vector2(s, s))
	_chip(g, Color.BLACK, GOLD if grid_on else RIM, 1.0)
	var gc := Color(GOLD, 0.9 if grid_on else 0.5)
	var in_ := g.grow(-9 * dp)
	for i in 4:
		var f := i / 3.0
		overlay.draw_line(Vector2(in_.position.x + in_.size.x * f, in_.position.y), Vector2(in_.position.x + in_.size.x * f, in_.end.y), gc, 1.5 * dp)
		overlay.draw_line(Vector2(in_.position.x, in_.position.y + in_.size.y * f), Vector2(in_.end.x, in_.position.y + in_.size.y * f), gc, 1.5 * dp)
	var d := Rect2(dice_rect.position + Vector2(4, 4) * dp, Vector2(s, s))
	_chip(d, Color.BLACK, GOLD if dice_on else RIM, 1.0)
	var dc := Color(GOLD, 0.9 if dice_on else 0.5)
	var sq := d.grow(-9 * dp)
	overlay.draw_rect(sq, dc, false, 1.5 * dp)
	var c := sq.get_center()
	var o := sq.size.x * 0.27
	for e in [Vector2.ZERO, Vector2(-o, -o), Vector2(o, -o), Vector2(-o, o), Vector2(o, o)]:
		overlay.draw_circle(c + e, 1.8 * dp, dc)
	# 600: Tempo wie Würfel und Raster, ein bis drei Spitzen für Ruhig, Normal, Schnell. t268.22 (Chef 07.11.: „Stufe 1 und 3 heller,
	# Stufe 2 dunkler?“): kein Schalter mit an und aus, sondern ein Wert; jede Stufe gleich hell, nur die Zahl der Spitzen wechselt
	tempo_rect = Rect2()
	var links := sr.size.x - 100 * dp
	if kampfort.tempo_knopf:
		tempo_rect = Rect2(links - 48 * dp, y, 48 * dp, 48 * dp)
		links -= 48 * dp
		var stufe: int = Bedienung.tempo
		var tr := Rect2(tempo_rect.position + Vector2(4, 4) * dp, Vector2(s, s))
		_chip(tr, Color.BLACK, RIM, 1.0)
		var tcol := Color(GOLD, 0.9)
		var mitte := tr.get_center()
		var hoch := tr.size.y * 0.2
		var breit := tr.size.x * 0.13
		for i in stufe + 1:
			var x0 := mitte.x + (i - stufe * 0.5) * breit * 1.1 - breit * 0.5
			overlay.draw_polyline(PackedVector2Array([Vector2(x0, mitte.y - hoch), Vector2(x0 + breit, mitte.y), Vector2(x0, mitte.y + hoch)]), tcol, 1.8 * dp, true)
	# 272 (Chef 20.10., nur im Testmodus, TestEndUi.kt): links neben den Würfeln Kreuz (verlieren) und Haken (gewinnen), solange
	# der Kampf läuft und kein Ring offen ist; das angetippte leuchtet, bis es gilt
	win_rect = Rect2()
	lose_rect = Rect2()
	if not Testmodus.ist_an() or not laeuft() or kampfort.ring_open:
		return
	win_rect = Rect2(links - 48 * dp, y, 48 * dp, 48 * dp)
	lose_rect = Rect2(links - 96 * dp, y, 48 * dp, 48 * dp)
	for win in [false, true]:
		var r: Rect2 = win_rect if win else lose_rect
		var on: bool = kampfort.end_asked != null and bool(kampfort.end_asked) == win
		var b := Rect2(r.position + Vector2(4, 4) * dp, Vector2(s, s))
		# 545 (Chef 04.11., 17:15: „die waren halt so ausgegraut“): wie Würfel und Raster, schwarz und deckend mit Rand, Zeichen
		# kräftig; angetippt goldener Rand
		_chip(b, Color.BLACK, GOLD if on else RIM, 1.0)
		var col := Color(GOLD if win else WARN, 1.0 if on else 0.9)
		var q := b.grow(-10 * dp)
		if win:
			overlay.draw_line(q.position + Vector2(0, q.size.y * 0.55), q.position + Vector2(q.size.x * 0.38, q.size.y * 0.9), col, 2 * dp, true)
			overlay.draw_line(q.position + Vector2(q.size.x * 0.38, q.size.y * 0.9), q.position + Vector2(q.size.x, q.size.y * 0.1), col, 2 * dp, true)
		else:
			overlay.draw_line(q.position, q.end, col, 2 * dp, true)
			overlay.draw_line(Vector2(q.end.x, q.position.y), Vector2(q.position.x, q.end.y), col, 2 * dp, true)


## Where the stroke from a sign to its own head starts: from below when the sign is above, else from the near edge.
func _stroke_from(r: Rect2, fx: float, head: float) -> Vector2:
	if r.position.y > head + 20 * dp:     # unter den Pfoten: von oben
		return Vector2(clampf(fx, r.position.x + 4 * dp, r.end.x - 4 * dp), r.position.y)
	if head - r.end.y > 2 * dp:
		return Vector2(clampf(fx, r.position.x + 4 * dp, r.end.x - 4 * dp), r.end.y)
	return Vector2(r.position.x if fx < r.position.x else r.end.x, r.get_center().y)


## Fledermaus Runde 4c (Prüfer 4b: der Strich endete im Gesicht und deckte Maul und Augen): sie hängt aufrecht, das Gesicht liegt
## knapp unter den Ohrspitzen; der Strich endet darum an den Ohrspitzen
func _bat(fig) -> bool:
	return Figur.vier(fig.fighter) and fig._mein_ersatz() == "giant_bat"     # 494: auch die Fledermaus mit eigenen Regeln (giant_bat)


func _stroke_to(r: Rect2, s: Dictionary) -> Vector2:
	# Runde 16: von unten bis knapp unter die Pfoten (die vorderen stehen im Bild tiefer als der Ursprung; der Strich lief in den Bauch)
	# von oben bis an die Kopfmarke (Prüfer: endete am alten Platz des Balkens 60 px über den Ohren, „Stummel“)
	# Prüfer Runde 3: oben bis an die Ohren über dem Kopf (die Kopfmarke liegt über den Ohrspitzen, der Kopf eines Wolfs vorn)
	return Vector2(s.fx, minf(s.paw, r.position.y)) if r.position.y > s.head + 20 * dp else Vector2(s.hx, maxf(s.head, s.top))


func _seg_hits(a: Vector2, b: Vector2, box: Rect2) -> bool:
	for i in 13:
		if box.has_point(a.lerp(b, i / 12.0)):
			return true
	return false


## Würfelkasten (RollTag) über dem Getroffenen: „12 + 5 = 17 gegen RK 16 · Treffer“, Gold, wenn es der Gruppe hilft.
func _roll_tag(sr: Rect2, fig, r: Array, actor_id, alpha: float) -> void:
	var fs := sp(13)
	var hit: bool = r[4]
	var by = kampfort.mars.find(actor_id) if actor_id != null else null
	# gold, wenn es der Gruppe hilft: ihr Angriff trifft; gegen sie umgekehrt
	var helps: bool = hit if by == null or by.side == "PARTY" else not hit
	# 868 (870.14 Kasten): nur Ergebnis und Trefferchance, kein Wurf; Gunst oder Ungunst dahinter
	var res := t("kritisch", "Critical") if (hit and r.size() > 7 and r[7]) else (t("Treffer", "Hit") if hit else t("daneben", "Miss"))
	var gunst := t(" mit Gunst", " with favor") if int(r[5]) > 0 else (t(" mit Ungunst", " at disfavor") if int(r[5]) < 0 else "")
	if hit and r.size() > 8:     # 870.5: Schwäche oder Stärke ([870.14.kasten.schwach], [870.14.kasten.stark])
		res += t(" · verwundbar", " · vulnerable") if float(r[8]) > 1.0 else t(" · widersteht", " · resists")
	var txt: String = res + (" · %d %%" if lang == 0 else " · %d%%") % int(r[3]) + gunst
	var w := minf(340 * dp, sr.size.x - 8 * dp)
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 16 * dp
	w = minf(w, tw)
	var h := fs * 1.35 + 6 * dp
	var foot := _foot(fig)
	var x := clampf(foot.x - w / 2, 4 * dp, sr.size.x - w - 4 * dp)
	# über dem Getroffenen, aber nicht auf einer anderen Figur oder Ansage (Prüfer Lauf 14: „Wurfzeile über Wolf“):
	# erst über dem Kopf, sonst höher, sonst unter den Füßen
	var block := sign_rects.duplicate()
	for id in kampfort.figures:
		var o = kampfort.figures[id]
		if o == fig or not o.visible:
			continue
		var of := _foot(o)
		var ot := _tall(o)
		var half: float = ot * (0.8 if Figur.vier(o.fighter) else 0.4)   # Wolf breiter als hoch
		block.append(Rect2(of.x - half, of.y - ot, half * 2.0, ot))
	var top := foot.y - _tall(fig) - 12 * dp - h
	var bodies := block.slice(sign_rects.size())
	var tries := [Vector2(x, top)]
	# daneben in Kopfhöhe vor dem Ausweichen nach oben (Prüfer Runde 5: langer Strich durch den Kopf des braunen Wolfs)
	var side := _tall(fig) * 0.45 + 6 * dp
	var mid := foot.y - _tall(fig) * 0.8
	tries.append(Vector2(clampf(foot.x - side - w, 4 * dp, sr.size.x - w - 4 * dp), mid))
	tries.append(Vector2(clampf(foot.x + side, 4 * dp, sr.size.x - w - 4 * dp), mid))
	# nie unter die Füße: dort liegen Ring und Zieldreieck (Prüfer Stand 9: Würfelzeile auf Bertrams Ring)
	for k in range(1, 10):
		tries.append(Vector2(x, top - k * (h + 4 * dp)))
	var y := maxf(4 * dp, top)
	for q in tries:
		if q.y < 4 * dp or q.y + h > sr.size.y - 4 * dp:
			continue
		var free := true
		for b in block:
			if b.intersects(Rect2(q.x, q.y, w, h)):
				free = false
				break
		if free:
			x = q.x
			y = q.y
			break
	var rr := Rect2(x, y, w, h)
	# Strich zum Getroffenen (Prüfer Stand 9: Würfelzeile ohne erkennbaren Bezug), nie durch einen anderen
	var hy := foot.y - _tall(fig) - 6 * dp
	var a: Vector2
	var b2: Vector2
	if rr.end.y < hy:
		a = Vector2(clampf(foot.x, rr.position.x + 4 * dp, rr.end.x - 4 * dp), rr.end.y)
		b2 = Vector2(foot.x, hy)
	elif rr.end.x < foot.x or rr.position.x > foot.x:
		a = Vector2(rr.end.x if rr.end.x < foot.x else rr.position.x, rr.get_center().y)
		b2 = Vector2(foot.x, rr.get_center().y)
	else:
		a = Vector2(foot.x, rr.end.y)
		b2 = a
	var crosses := false
	for bb in bodies:
		if _seg_hits(a, b2, bb.grow(-2 * dp)):
			crosses = true
	if not crosses and a.distance_to(b2) > 2 * dp:
		overlay.draw_line(a, b2, Color(GOLD if helps else TEXT, alpha * 0.7), maxf(1.0, dp), true)
	overlay.draw_rect(rr, Color(0, 0, 0, alpha))
	overlay.draw_rect(rr, Color(GOLD if helps else RIM, alpha * (1.0 if helps else RIM.a)), false, maxf(1.0, dp))
	overlay.draw_string(font, Vector2(x + 8 * dp, y + h * 0.74), txt, HORIZONTAL_ALIGNMENT_LEFT, w - 16 * dp, fs, Color(TEXT, alpha))
