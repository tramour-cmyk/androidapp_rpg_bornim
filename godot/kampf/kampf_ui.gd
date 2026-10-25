# 348.7: Oberfläche des Kampforts nach SkirmishScreen.kt (schwarzer Stil, Theme.kt Veil): unten ein schwarzer Kasten mit
# dünnem Goldrand: Kampfbericht (nur ganze Zeilen, die neueste hell, Schaden hervorgehoben, „▴ ganzer Bericht“), je
# Mitglied ein Kasten (Farbmarke, Name, Balken in Lebensfarbe, „14/14“, ZP), zwei Knopfzeilen in Großbuchstaben. In der
# Szene: Zugleiste oben links mit ▶, Lebensbalken nur über Gegnern, gerahmte Ansagen „! Anspringen“ ohne Überlappen,
# Ring am Boden unter dem, der dran ist, Dreiecke vor den Füßen der Angezielten, Würfelkasten, Schalter Würfel und Raster.
# Maße in dp (Breite / 412), Schrift Alegreya wie im alten Spiel.
extends CanvasLayer

const Mars = preload("res://regeln/mars.gd")

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

var kampfort
var lang := 0
var root: Control
var overlay: Control
var panel: PanelContainer
var log_area: Control
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
var dp := 2.6
var font: Font
var font_px := 38
var dice_on := true
var grid_on := false
var dice_rect := Rect2()
var grid_rect := Rect2()


func t(de: String, en: String) -> String:
	return de if lang == 0 else en


## Schriftgröße wie Theme.kt im schwarzen Stil: sp × 0,95 × 1,04, mindestens 13,7 sp.
func sp(v: float) -> int:
	return int(maxf(v * 0.95 * 1.04, 13.7) * dp)


static func hp_color(frac: float) -> Color:
	return Color("#48C858") if frac > 0.5 else (Color("#F0C030") if frac > 0.2 else Color("#E04030"))


func _ready() -> void:
	var vs: Vector2 = get_viewport().get_visible_rect().size
	dp = vs.x / 412.0
	font_px = sp(15)
	var ff := FontFile.new()
	if ff.load_dynamic_font("res://kampf/schrift/alegreya_regular.ttf") == OK:
		font = ff
	else:
		font = ThemeDB.fallback_font
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
	# SkirmishScreen: full width, only clear of the screen's rounded corners (a third of their radius, 335); Godot does
	# not know the radius, so on the phone the A56's (about 13 dp), at the desk none
	var m := (13.0 * 0.3 + 2.0) * dp if OS.get_name() == "Android" else 0.0
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
	panel.resized.connect(func():
		var vs2: Vector2 = get_viewport().get_visible_rect().size
		backdrop.position = Vector2(0, vs2.y - panel_height())
		backdrop.size = Vector2(vs2.x, panel_height())
		if absf(panel.size.y - fitted_h) > 1.0:
			fitted_h = panel.size.y
			kampfort._fit_camera())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", int(6 * dp))
	panel.add_child(col)
	var log_box := PanelContainer.new()
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
	full_log.add_theme_stylebox_override("panel", _box(Color.BLACK, GOLD, 10, 10, 1.0))
	full_log.visible = false
	root.add_child(full_log)
	if not kampfort.mars.lead().hero.get("seen_rows", false):
		log_line(t("Nahkampf erreicht nur die vordere Reihe.", "Melee reaches only the front row."))


func _pressed(ev) -> bool:
	return (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and ev.pressed)


func _scene_input(ev) -> void:
	if not _pressed(ev):
		return
	var p: Vector2 = ev.position
	if dice_rect.has_point(p):
		dice_on = not dice_on
	elif grid_rect.has_point(p):
		grid_on = not grid_on
	else:
		kampfort.tap()


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


func _process(_dt: float) -> void:
	overlay.queue_redraw()


# ---------------------------------------------------------------- the log: only whole lines, newest at the bottom
func log_line(text: String) -> void:
	lines.append(text)
	while lines.size() > 300:
		lines.pop_front()
	if log_area:
		log_area.queue_redraw()


## Words of a line with their colours: the newest line in text, older ones dim, "n Schaden" bright or gold.
func _words(s: String, newest: bool) -> Array:
	var out := []
	var base := TEXT if newest else DIM
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


func _show_full_log(on: bool) -> void:
	for c in full_log.get_children():
		c.queue_free()
	full_log.visible = on
	if not on:
		return
	var v := VBoxContainer.new()
	full_log.add_child(v)
	var h := Label.new()
	h.text = t("Kampfbericht", "Battle log")
	h.add_theme_color_override("font_color", GOLD)
	h.add_theme_font_size_override("font_size", sp(16))
	v.add_child(h)
	var r := RichTextLabel.new()
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.scroll_following = true
	r.add_theme_color_override("default_color", TEXT)
	r.add_theme_font_override("normal_font", font)
	r.add_theme_font_size_override("normal_font_size", sp(15 * 0.95))
	r.text = "\n".join(lines)
	v.add_child(r)
	var close := Label.new()
	close.text = t("Tippen schließt", "Tap to close")
	close.add_theme_color_override("font_color", DIM)
	close.add_theme_font_size_override("font_size", sp(13))
	v.add_child(close)
	full_log.gui_input.connect(func(ev):
		if _pressed(ev):
			_show_full_log(false), CONNECT_ONE_SHOT)


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
	for c in party_row.get_children():
		c.queue_free()
	for f in m.fighters():
		if f.side != "PARTY":
			continue
		party_row.add_child(_party_box(f))
	_build_orders()
	if log_area:
		log_area.queue_redraw()


## PartyBox: Farbmarke, Name; Balken in Lebensfarbe und „hp/max“, bei Zauberern „ZP sp/max“ (ohne „LP“).
func _party_box(f) -> Control:
	var box := PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	n.text = f.name(lang)
	n.add_theme_font_size_override("font_size", sp(13))
	n.add_theme_color_override("font_color", WARN if hp <= 0 else TEXT)
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
	l.text = "%d/%d" % [hp, f.max_hp] + ((t("  ZP %d/%d", "  SP %d/%d") % [spv, int(f.hero.sp)]) if f.hero != null and int(f.hero.sp) > 0 else "")
	l.add_theme_font_size_override("font_size", sp(13))
	l.add_theme_color_override("font_color", TEXT)
	low.add_child(l)
	v.add_child(low)
	return box


## PixelButton im schwarzen Stil: eckig, Rahmen 1 dp, Großbuchstaben mit Laufweite; an: erhaben mit hellem Rahmen.
func _button(label: String, enabled := true, go: Callable = Callable(), selected := false, small := false) -> Button:
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
	if go.is_valid():
		b.pressed.connect(go)
	return b


## Eine Knopfzeile; Wörter werden nie getrennt; lange Aufschriften bekommen mehr Breite, erst dann wird der Text kleiner,
## eine Größe für alle (Prüfer Lauf 14: „SÖLDNER SELBST“, „HELD SELBST“ kleiner als die übrigen Knöpfe).
func _row(items: Array, fs_cap := 0) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * dp))
	var fs := mini(_row_size(items), fs_cap) if fs_cap > 0 else _row_size(items)
	var ws := _text_widths(items, fs)
	for i in items.size():
		var b: Button = items[i]
		b.add_theme_font_size_override("font_size", fs)
		b.size_flags_stretch_ratio = maxf(ws[i], 1.0)
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


func _target_label(f) -> String:
	var hp: int = kampfort.shown.hp.get(f.id, f.hp)
	return "%s  %d/%d" % [f.name(lang), maxi(0, hp), f.max_hp]


func _spot_name(s: Vector2i) -> String:
	return t("vorn", "front") if s.x == Mars.FRONT else t("hinten", "back")


func _build_orders() -> void:
	for c in orders.get_children():
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
		if m.knockouts > 0:
			var ko := Label.new()
			ko.text = t("Söldner bewusstlos: ", "Mercenaries knocked out: ") + str(m.knockouts)
			orders.add_child(ko)
		orders.add_child(_row([_button(t("Nochmal", "Again"), true, func(): k.again()), _button(t("Zurück", "Back"), true, func(): k.finish())]))
		return
	if k.busy:
		var w := Label.new()
		w.text = "…"
		w.add_theme_color_override("font_color", DIM)
		w.add_theme_font_size_override("font_size", sp(14))
		orders.add_child(w)
		return
	var f = m.current()
	var back := _button(t("Zurück", "Back"), true, func(): _set_pick("main"))
	match pick:
		"main":
			var reach: Array = m.targets(f)
			var top := [
				_button(t("Angriff", "Attack"), not reach.is_empty(), func():
					if reach.size() == 1:
						k.order(["attack", reach[0].id])
					else:
						_set_pick("target")),
				_button(t("Können", "Skills"), not m.moves(f).is_empty(), func(): _set_pick("skills")),
				_button(t("Tasche", "Bag"), not m.drinkable().is_empty(), func(): _set_pick("bag")),
				_button(t("Wechsel", "Switch"), m.can_swap(f) or m.can_draw(f), func(): _set_pick("place")),
			]
			var low := [_button(t("Abwehr", "Defend"), true, func(): k.order(["wait"]), false, true)]
			# 296.2: fliehen wie im klassischen Kampf, nie vor einem Boss
			if not m.all.any(func(x): return x.side == "FOES" and x.boss()):
				low.append(_button(t("Flucht", "Run"), m.can_flee(f), func(): k.order(["flee"]), false, true))
			if f.hero != null and f.hero.cls == "FIGHTER":
				low.append(_button(t("Decken", "Cover"), not m.guardable(f).is_empty(), func(): k.order(["guard"]), false, true))
			var merc = m.find("merc")
			if merc != null:
				low.append(_button(t("Söldner ", "Mercenary ") + (t("Auto", "auto") if merc.auto else t("selbst", "manual")), true, func():
					merc.auto = not merc.auto
					if merc.auto and m.current() == merc:
						k.go_on()
					refresh(), merc.auto, true))
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
				refresh(), m.autopilot, true))
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
					if Mars.AIM[skill] == "SELF":
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
				if Mars.AIM[pick_arg] == "ROW":
					row = t("Reihe vorn: ", "Front row: ") if tg.place.x == Mars.FRONT else t("Reihe hinten: ", "Back row: ")
				var id: String = tg.id
				var skill: String = pick_arg
				items.append(_button(row + _target_label(tg), true, func(): k.order(["use", skill, id])))
			items.append(back)
			_choices(items)
		"bag":
			var items := []
			for id in m.drinkable():
				var it: Dictionary = m.items[id]
				var item: String = id
				items.append(_button("%s ×%d" % [[it.de, it.en][lang], int(m.potions[id])], true, func(): _set_pick("drink_at", item)))
			items.append(back)
			_choices(items)
		"drink_at":
			var items := []
			for tg in m.fighters():
				if tg.side == f.side and tg.standing():
					var id: String = tg.id
					var item: String = pick_arg
					items.append(_button("%s  %d/%d" % [tg.name(lang), tg.hp, tg.max_hp], true, func(): k.order(["drink", item, id])))
			items.append(back)
			_choices(items)


func _set_pick(p: String, arg = null) -> void:
	pick = p
	pick_arg = arg
	_build_orders()


func show_tip(text: String) -> void:
	tip.text = text
	tip.visible = true
	var vs: Vector2 = get_viewport().get_visible_rect().size
	tip.position = Vector2(8 * dp, kampfort.scene_rect().size.y - 70 * dp)
	tip.size = Vector2(vs.x - 16 * dp, 0)
	get_tree().create_timer(6.0).timeout.connect(func(): tip.visible = false)


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
## Foot point and height on the screen of a figure.
func _foot(fig) -> Vector2:
	return kampfort.screen_of(fig.position)


func _tall(fig) -> float:
	return maxf(20 * dp, _foot(fig).y - kampfort.screen_of(fig.head()).y)


## A circle on the ground round [p] (world), as the camera sees it.
func _ground_ring(p: Vector3, r: float, c: Color, w: float) -> void:
	var pts := PackedVector2Array()
	for i in 41:
		var a := TAU * i / 40.0
		pts.append(kampfort.screen_of(p + Vector3(cos(a) * r, 0.02, sin(a) * r)))
	overlay.draw_polyline(pts, Color(0, 0, 0, 0.5), w + 2 * dp, true)
	overlay.draw_polyline(pts, c, w, true)


func _chip(rect: Rect2, bg: Color, border: Color, rim_dp: float) -> void:
	overlay.draw_rect(rect, bg)
	overlay.draw_rect(rect, border, false, maxf(1.0, rim_dp * dp))


func _draw_overlay() -> void:
	var k = kampfort
	var m = k.mars
	var sr: Rect2 = k.scene_rect()
	var current = m.current() if not k.busy else null
	# under the figures: the ring under the one whose turn it is, chosen targets (CamRing)
	for id in k.figures:
		var fig = k.figures[id]
		if not fig.visible or k.shown.hp.get(id, fig.fighter.hp) <= 0:
			continue
		var beast: bool = fig.fighter.monster != null and fig.fighter.monster.id == Mars.WOLF
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
		for q in [Vector2(0, -0.22), Vector2(-0.2, -0.5), Vector2(0.2, -0.5)]:
			tri.append(k.screen_of(fig.position + across * q.x + away * q.y + Vector3(0, 0.02, 0)))
		overlay.draw_colored_polygon(tri, _friend_color(fig.fighter))
		tri.append(tri[0])
		overlay.draw_polyline(tri, Color(0, 0, 0, 0.8), maxf(1.0, dp), true)
	# life bars only over foes (MarsLabels.barsOnlyFoes)
	for id in k.figures:
		var fig = k.figures[id]
		var f = fig.fighter
		var hp: int = k.shown.hp.get(id, f.hp)
		if f.side != "FOES" or not fig.visible or (hp <= 0 and not fig.falling()):
			continue
		var p := _foot(fig)
		var top := p.y - _tall(fig) - 8 * dp
		var w := 44 * dp
		var r := Rect2(p.x - w / 2, top, w, 4 * dp)
		# Prüfer Runde 27: über dem Kopf des vorderen Wolfs lag der Balken auf den Pfoten des hinteren und las sich als dessen;
		# dann unter die eigenen Pfoten
		for oid in k.figures:
			var o = k.figures[oid]
			if oid != id and o.visible and k.shown.hp.get(oid, o.fighter.hp) > 0:
				var of := _foot(o)
				var ot := _tall(o)
				var half: float = ot * (0.8 if o.fighter.monster != null and o.fighter.monster.id == Mars.WOLF else 0.45)
				if r.grow(3 * dp).intersects(Rect2(of.x - half, of.y - ot, half * 2.0, ot + 6 * dp)):
					r.position.y = p.y + 4 * dp + _tall(fig) * 0.1
					break
		overlay.draw_rect(r.grow(1), Color(0, 0, 0, 0.7))
		overlay.draw_rect(Rect2(r.position, Vector2(w * clampf(float(hp) / f.max_hp, 0, 1), r.size.y)), hp_color(float(hp) / f.max_hp))
	# names only while choosing a target (NameTag)
	if pick == "target" and current != null:
		for tg in m.targets(current):
			if k.figures.has(tg.id):
				var fig = k.figures[tg.id]
				_name_tag(_foot(fig), _tall(fig), tg.name(lang), false)
	_draw_intents(sr)
	_draw_statuses(sr)
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


var placed_status := []


## Whether status signs at [r] would lie on another figure, an intent sign or signs placed before.
func _status_clash(r: Rect2, own: String) -> bool:
	var k = kampfort
	for o in sign_rects + placed_status:
		if r.intersects(o.grow(2 * dp)):
			return true
	for id in k.figures:
		var o = k.figures[id]
		if id == own or not o.visible or k.shown.hp.get(id, o.fighter.hp) <= 0:
			continue
		var of := _foot(o)
		var ot := _tall(o)
		var half: float = ot * (0.8 if o.fighter.monster != null and o.fighter.monster.id == Mars.WOLF else 0.45)
		if r.intersects(Rect2(of.x - half, of.y - ot - 8 * dp, half * 2.0, ot + 12 * dp)):
			return true
	return false


## 296.2: the statuses with the turns left, as in the old fight (StatusChips), under the feet of each who has any;
## lower still where an intent sign lies there.
func _draw_statuses(sr: Rect2) -> void:
	var k = kampfort
	var fs := sp(11)
	var gap := 4 * dp
	placed_status.clear()
	for id in k.shown.get("status", {}):
		if not k.figures.has(id):
			continue
		var fig = k.figures[id]
		if not fig.visible or k.shown.hp.get(id, fig.fighter.hp) <= 0:
			continue
		var chips := []
		var width := -gap
		for st in k.shown.status[id]:
			var left: int = k.shown.status[id][st]
			var label: String = Mars.STATUS[st][1][lang] + ("" if left >= Mars.LASTING else " %d" % left)
			var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 10 * dp
			chips.append([label, w, Mars.STATUS[st][2]])
			width += w + gap
		var h := fs * 1.3 + 2 * dp
		var foot := _foot(fig)
		var x := clampf(foot.x - width / 2, 4 * dp, sr.size.x - width - 4 * dp)
		var y := foot.y + 8 * dp + _tall(fig) * 0.12
		# Prüfer: unter dem grauen Wolf lagen sie auf dem schwarzen davor; dann seitlich am eigenen Rumpf, sonst über dem Kopf
		var half: float = _tall(fig) * (0.8 if fig.fighter.monster != null and fig.fighter.monster.id == Mars.WOLF else 0.45)
		var mid := foot.y - _tall(fig) * 0.5 - h / 2
		var spots := [Vector2(x, y), Vector2(foot.x + half + gap, mid), Vector2(foot.x - half - gap - width, mid),
			Vector2(x, foot.y - _tall(fig) - 12 * dp - h)]
		var row := Rect2(x, y, width, h)
		for q in spots:
			var r := Rect2(clampf(q.x, 4 * dp, sr.size.x - width - 4 * dp), q.y, width, h)
			if not _status_clash(r, id):
				row = r
				break
		placed_status.append(row)
		for c in chips:
			var r := Rect2(row.position.x, row.position.y, c[1], h)
			overlay.draw_rect(r, c[2])
			overlay.draw_rect(r, Color(0, 0, 0, 0.8), false, maxf(1.0, dp))
			# Prüfer: Weiß auf Gelb und hellem Grün zu schwach; auf hellen Farben schwarz
			var ink: Color = Color.BLACK if c[2].get_luminance() > 0.45 else Color.WHITE
			overlay.draw_string(font, Vector2(r.position.x + 5 * dp, r.position.y + h * 0.76), c[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
			row.position.x += c[1] + gap


func _name_tag(foot: Vector2, tall: float, nm: String, now: bool) -> void:
	var fs := sp(12)
	var w := font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 12 * dp
	var h := fs * 1.35 + 2 * dp
	var r := Rect2(foot.x - w / 2, foot.y - tall - 28 * dp - h, w, h)
	_chip(r, Color.BLACK, GOLD if now else RIM, 1.0)
	overlay.draw_string(font, Vector2(r.position.x + 6 * dp, r.position.y + h * 0.76), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, BRIGHT if now else TEXT)


## Ansagen (IntentSign): „! Anspringen“ im Rahmen, Farbe des Angezielten; von unten nach oben ohne Überlappen (layOut).
func _draw_intents(sr: Rect2) -> void:
	var k = kampfort
	var m = k.mars
	var fs := sp(14)
	var signs := []
	for id in k.shown.intents:
		if not k.figures.has(id) or not k.figures[id].visible:
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
		var tg = m.find(plan[1][0]) if not plan[1].is_empty() else null
		var fc: Color = _friend_color(tg) if tg != null else GOLD
		var border: Color = WARN if intent.strong else fc
		var bw := (2.0 if tg != null else 1.0) if intent.strong else 1.0
		var tc: Color = fc if tg != null else (WARN if intent.strong else BRIGHT)
		var ring: bool = intent.kind == "STRIKE" and intent.get("ring", false)
		var label: String = intent.name[lang]
		var w := font.get_string_size(mark + " " + label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 12 * dp + (18 * dp if ring else 0.0)
		var h := fs * 1.35 + 4 * dp
		var foot := _foot(fig)
		# über dem Kopf des Ansagenden, mittig (Prüfer Stand 7: „! Anspringen“ schwebte links daneben ohne Bezug)
		var head_y := foot.y - _tall(fig) - 10 * dp
		var want_y := head_y - 6 * dp - h
		var x := clampf(foot.x - w / 2, 4 * dp, sr.size.x - w - 4 * dp)
		# Prüfer Stand 9: Ansagen der vorderen Wölfe lagen auf dem hinteren; daneben am eigenen Kopf, wenn darüber ein anderer steht
		var side := _tall(fig) * (0.8 if fig.fighter.monster != null and fig.fighter.monster.id == Mars.WOLF else 0.42) + 4 * dp
		var head_mid := head_y + 10 * dp - h
		signs.append({"x": x, "y": want_y, "w": w, "h": h, "mark": mark, "label": label, "border": border, "bw": bw, "tc": tc, "ring": ring,
			"fx": foot.x, "head": head_y, "id": id, "alts": [
				Vector2(clampf(foot.x - side - w, 4 * dp, sr.size.x - w - 4 * dp), head_mid),
				Vector2(clampf(foot.x + side, 4 * dp, sr.size.x - w - 4 * dp), head_mid),
				# unter den Pfoten, wenn darüber und daneben andere stehen (Prüfer Runde 6: Schild ohne Strich über dem falschen Wolf)
				# Runde 24: knapp unter dem Ursprung ragte es in die Läufe (die vorderen Pfoten stehen im Bild tiefer)
				Vector2(x, foot.y + 10 * dp + _tall(fig) * 0.2)], "foot": foot.y})
	signs.sort_custom(func(a, b): return a.y > b.y)
	# Körper aller Figuren (Rumpf ohne Kopfraum), damit keine Ansage auf einem anderen liegt
	var bodies := {}
	for id in k.figures:
		var o = k.figures[id]
		if o.visible and k.shown.hp.get(id, o.fighter.hp) > 0:
			var of := _foot(o)
			var ot := _tall(o)
			# ein Wolf ist länger als hoch: im Bild etwa 1,6 mal so breit (Prüfer: Ansage lag auf dem Hinterteil des grauen)
			var half: float = ot * (0.8 if o.fighter.monster != null and o.fighter.monster.id == Mars.WOLF else 0.45)
			bodies[id] = Rect2(of.x - half, of.y - ot - 12 * dp, half * 2.0, ot + 12 * dp)
	var placed := []
	var step := 26 * dp
	for s in signs:
		var clash := func(r: Rect2, strict: bool) -> bool:
			for o in placed:
				if r.intersects(Rect2(o.x, o.y, o.w, o.h).grow(2 * dp)):
					return true
			# auch der Strich zum eigenen Kopf darf durch keinen anderen laufen (Prüfer Runde 4: durch das Hinterteil des grauen)
			var a := _stroke_from(r, s.fx, s.head)
			var e := _stroke_to(r, s)
			for id in bodies:
				if id != s.id and (r.intersects(bodies[id]) or (strict and _seg_hits(a, e, bodies[id].grow(-2 * dp)))):
					return true
			return false
		var spots: Array = [Vector2(s.x, s.y)] + s.alts
		var y: float = s.y
		var x: float = s.x
		var done := false
		s.stroke = true
		# erst mit freiem Strich; geht das nirgends, lieber ohne Strich als auf einem anderen (Prüfer Runde 5: Schild auf dem grauen)
		for strict in [true, false]:
			for q in spots:
				if q.y >= 34 * dp and not clash.call(Rect2(q.x, q.y, s.w, s.h), strict):
					x = q.x
					y = q.y
					done = true
					break
			if not done:
				# höher über dem eigenen Kopf, bis frei
				var yy: float = s.y
				while clash.call(Rect2(s.x, yy, s.w, s.h), strict) and yy - step >= 34 * dp:
					yy -= step
				if not clash.call(Rect2(s.x, yy, s.w, s.h), strict):
					x = s.x
					y = yy
					done = true
			if done:
				s.stroke = strict
				break
		s.x = x
		s.y = y
		placed.append(s)
	sign_rects.clear()
	for s in placed:
		sign_rects.append(Rect2(s.x, s.y, s.w, s.h))
		var r := Rect2(s.x, s.y, s.w, s.h)
		# a thin stroke down to the one who announces it, so a sign pushed up still belongs to someone
		var a := _stroke_from(r, s.fx, s.head)
		var e := _stroke_to(r, s)
		if s.stroke and a.distance_to(e) > 2 * dp and (r.position.y > s.foot or s.head - r.end.y > 2 * dp or s.fx < r.position.x or s.fx > r.end.x):
			overlay.draw_line(a, e, Color(s.border, 0.7), maxf(1.0, dp), true)
		_chip(r, Color.BLACK, s.border, s.bw)
		var x: float = r.position.x + 6 * dp
		var base: float = r.position.y + s.h * 0.74
		overlay.draw_string(font, Vector2(x, base), s.mark, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, s.tc)
		x += font.get_string_size(s.mark + " ", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if s.ring:
			overlay.draw_arc(Vector2(x + 6.5 * dp, r.position.y + s.h / 2), 6.5 * dp, 0, TAU, 24, GOLD, 1.5 * dp, true)
			x += 18 * dp
		overlay.draw_string(font, Vector2(x, base), s.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, s.tc)


## Zugleiste (TurnBar) oben links: „▶ “ vor dem, der dran ist, dann alle in Zugfolge, „|“ und der Erste der nächsten Runde.
func _draw_turns(sr: Rect2) -> void:
	var k = kampfort
	var m = k.mars
	var fs := sp(13)
	var x := 6 * dp
	var y := 6 * dp
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


## Where the stroke from a sign to its own head starts: from below when the sign is above, else from the near edge.
func _stroke_from(r: Rect2, fx: float, head: float) -> Vector2:
	if r.position.y > head + 20 * dp:     # unter den Pfoten: von oben
		return Vector2(clampf(fx, r.position.x + 4 * dp, r.end.x - 4 * dp), r.position.y)
	if head - r.end.y > 2 * dp:
		return Vector2(clampf(fx, r.position.x + 4 * dp, r.end.x - 4 * dp), r.end.y)
	return Vector2(r.position.x if fx < r.position.x else r.end.x, r.get_center().y)


func _stroke_to(r: Rect2, s: Dictionary) -> Vector2:
	return Vector2(s.fx, s.foot) if r.position.y > s.head + 20 * dp else Vector2(s.fx, s.head)


func _seg_hits(a: Vector2, b: Vector2, box: Rect2) -> bool:
	for i in 13:
		if box.has_point(a.lerp(b, i / 12.0)):
			return true
	return false


## Würfelkasten (RollTag) über dem Getroffenen: „12 + 5 = 17 gegen RK 16 · Treffer“, Gold, wenn es der Gruppe hilft.
func _roll_tag(sr: Rect2, fig, r: Array, actor_id, alpha: float) -> void:
	var fs := sp(13)
	var total := int(r[1]) + int(r[2])
	var hit: bool = r[4]
	var by = kampfort.mars.find(actor_id) if actor_id != null else null
	# gold, wenn es der Gruppe hilft: ihr Angriff trifft, ihr Ziel scheitert am Rettungswurf; gegen sie umgekehrt
	var works: bool = hit if r[0] == "ATTACK" else not hit
	var helps: bool = works if by == null or by.side == "PARTY" else not works
	# Wortlaut wie RollTag (SkirmishScreen.kt): Vorteil/Nachteil, kritisch, daneben; Rettungswurf „RW … gegen SG … · geschafft“
	var bonus := ("− %d" % -int(r[2])) if int(r[2]) < 0 else ("+ %d" % int(r[2]))
	var txt: String
	if r[0] == "ATTACK":
		var mode := ""
		if int(r[5]) > 0:
			mode = t(" (Vorteil)", " (advantage)")
		elif int(r[5]) < 0:
			mode = t(" (Nachteil)", " (disadvantage)")
		var res := t("kritisch", "critical") if int(r[1]) == 20 else (t("Treffer", "hit") if hit else t("daneben", "miss"))
		txt = "%d%s %s = %d %s %d · %s" % [int(r[1]), mode, bonus, total, t("gegen RK", "vs AC"), int(r[3]), res]
	else:
		txt = "%s %d %s = %d %s %d · %s" % [t("RW", "Save"), int(r[1]), bonus, total, t("gegen SG", "vs DC"), int(r[3]),
			t("geschafft", "success") if hit else t("misslungen", "failure")]
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
		var half: float = ot * (0.8 if o.fighter.monster != null and o.fighter.monster.id == Mars.WOLF else 0.4)   # Wolf breiter als hoch
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
