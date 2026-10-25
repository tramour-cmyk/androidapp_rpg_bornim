# 348.7: Oberfläche des Kampforts nach SkirmishScreen.kt: unten in schwarzem Rahmen der Kampfbericht (fünf Zeilen, die
# neueste hell, Schaden golden, Tippen öffnet den ganzen Bericht), je Mitglied ein Kasten (Name, Balken, LP, ZP) und zwei
# Knopfzeilen (Angriff, Können, Tasche, Wechsel / Abwehr, Decken, Söldner, Held); über der Szene Namen mit Balken,
# die angesagten Absichten der Gegner mit Zielmarke, die Zugleiste, der Ring zum Antippen und sein Ergebnis.
extends CanvasLayer

const Mars = preload("res://regeln/mars.gd")

const GOLD := Color(0.86, 0.68, 0.30)
const RIM := Color(0.55, 0.42, 0.18)
const DIM := Color(0.62, 0.60, 0.55)
const BRIGHT := Color(0.96, 0.93, 0.85)
const WARN := Color(0.90, 0.36, 0.25)
const FRIEND_COLORS := [Color(0.50, 0.71, 0.91), Color(0.80, 0.61, 0.89), Color(0.44, 0.81, 0.75)]
const LOG_LINES := 5

var kampfort
var lang := 0
var root: Control
var overlay: Control
var panel: PanelContainer
var log_box: RichTextLabel
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
var roll_until := 0
var font_px := 38


func t(de: String, en: String) -> String:
	return de if lang == 0 else en


func _ready() -> void:
	var vs: Vector2 = get_viewport().get_visible_rect().size
	font_px = int(vs.x / 412.0 * 15.0)
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var th := Theme.new()
	th.default_font_size = font_px
	root.theme = th
	add_child(root)
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.draw.connect(_draw_overlay)
	overlay.gui_input.connect(func(ev):
		if (ev is InputEventMouseButton and ev.pressed) or (ev is InputEventScreenTouch and ev.pressed):
			kampfort.tap())
	root.add_child(overlay)
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.add_theme_stylebox_override("panel", _box(Color.BLACK, RIM, 10))
	root.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", int(font_px * 0.4))
	panel.add_child(col)
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.fit_content = false
	log_box.scroll_following = true
	log_box.custom_minimum_size = Vector2(0, font_px * 1.25 * LOG_LINES)
	log_box.mouse_filter = Control.MOUSE_FILTER_STOP
	log_box.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			_show_full_log(true))
	col.add_child(log_box)
	party_row = HBoxContainer.new()
	party_row.add_theme_constant_override("separation", int(font_px * 0.5))
	col.add_child(party_row)
	orders = VBoxContainer.new()
	orders.add_theme_constant_override("separation", int(font_px * 0.4))
	orders.custom_minimum_size = Vector2(0, font_px * 2.0 * 2 + font_px * 0.4)
	col.add_child(orders)
	tip = Label.new()
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.visible = false
	tip.add_theme_stylebox_override("normal", _box(Color.BLACK, GOLD, 8))
	root.add_child(tip)
	verdict = Label.new()
	verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verdict.add_theme_font_size_override("font_size", int(font_px * 1.3))
	verdict.add_theme_color_override("font_color", GOLD)
	verdict.visible = false
	root.add_child(verdict)
	full_log = PanelContainer.new()
	full_log.set_anchors_preset(Control.PRESET_FULL_RECT)
	full_log.add_theme_stylebox_override("panel", _box(Color.BLACK, GOLD, 10))
	full_log.visible = false
	root.add_child(full_log)
	if not kampfort.mars.lead().hero.get("seen_rows", false):
		log_line(t("Nahkampf erreicht nur die vordere Reihe.", "Melee reaches only the front row."))


func _box(bg: Color, border: Color, pad: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_content_margin_all(pad * font_px / 38.0 * 2.0)
	return s


func panel_height() -> float:
	return panel.size.y if panel and panel.size.y > 0 else get_viewport().get_visible_rect().size.y * 0.33


func _process(_dt: float) -> void:
	overlay.queue_redraw()


# ---------------------------------------------------------------- the log
func log_line(text: String) -> void:
	lines.append(text)
	while lines.size() > 300:
		lines.pop_front()
	_render_log()


func _render_log() -> void:
	var out := []
	var from := maxi(0, lines.size() - 40)
	for i in range(from, lines.size()):
		var s: String = lines[i].replace("[", "[lb]")
		var re := RegEx.create_from_string("(\\d+ (Schaden|damage))")
		s = re.sub(s, "[color=#%s]$1[/color]" % GOLD.to_html(false), true)
		var c := BRIGHT if i == lines.size() - 1 else DIM
		out.append("[color=#%s]%s[/color]" % [c.to_html(false), s])
	log_box.text = "\n".join(out)


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
	v.add_child(h)
	var r := RichTextLabel.new()
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.scroll_following = true
	r.text = "\n".join(lines)
	v.add_child(r)
	var close := Label.new()
	close.text = t("Tippen schließt", "Tap to close")
	close.add_theme_color_override("font_color", DIM)
	v.add_child(close)
	full_log.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			_show_full_log(false), CONNECT_ONE_SHOT)


# ---------------------------------------------------------------- party boxes and orders
func _friend_color(f) -> Color:
	var i := 0
	for o in kampfort.mars.fighters():
		if o.side == "PARTY":
			if o == f:
				return FRIEND_COLORS[i % FRIEND_COLORS.size()]
			i += 1
	return BRIGHT


func refresh() -> void:
	if not is_inside_tree():
		return
	var m = kampfort.mars
	for c in party_row.get_children():
		c.queue_free()
	for f in m.fighters():
		if f.side != "PARTY":
			continue
		var box := PanelContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_stylebox_override("panel", _box(Color.BLACK, RIM.darkened(0.3), 4))
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 2)
		box.add_child(v)
		var n := Label.new()
		n.text = f.name(lang)
		n.add_theme_color_override("font_color", _friend_color(f))
		v.add_child(n)
		var hp: int = kampfort.shown.hp.get(f.id, f.hp)
		var bar := ProgressBar.new()
		bar.max_value = f.max_hp
		bar.value = maxi(0, hp)
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, font_px * 0.35)
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.75, 0.15, 0.1) if hp * 3 < f.max_hp else Color(0.62, 0.20, 0.14)
		bar.add_theme_stylebox_override("fill", fill)
		v.add_child(bar)
		var l := Label.new()
		var sp: int = kampfort.shown.sp.get(f.id, f.sp)
		l.text = t("LP %d/%d", "HP %d/%d") % [maxi(0, hp), f.max_hp] + ((t("  ZP %d", "  SP %d") % sp) if int(f.hero.sp) > 0 else "")
		l.add_theme_font_size_override("font_size", int(font_px * 0.8))
		v.add_child(l)
		party_row.add_child(box)
	_build_orders()


func _button(label: String, enabled := true, go: Callable = Callable(), selected := false, small := false) -> Button:
	var b := Button.new()
	b.text = label
	b.disabled = not enabled
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, font_px * (1.75 if small else 1.9))
	b.clip_text = true
	if small:
		b.add_theme_font_size_override("font_size", int(font_px * 0.9))
	var n := _box(Color(0.08, 0.07, 0.05), GOLD if selected else RIM, 2)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", n)
	b.add_theme_stylebox_override("pressed", _box(Color(0.2, 0.15, 0.06), GOLD, 2))
	b.add_theme_stylebox_override("disabled", _box(Color(0.05, 0.05, 0.05), Color(0.25, 0.22, 0.18), 2))
	b.add_theme_color_override("font_color", BRIGHT)
	b.add_theme_color_override("font_disabled_color", Color(0.35, 0.33, 0.3))
	if go.is_valid():
		b.pressed.connect(go)
	return b


func _row(items: Array) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(font_px * 0.3))
	for b in items:
		r.add_child(b)
	return r


## Choices in rows: two side by side, three when there are more than four (SkirmishScreen.Choices).
func _choices(items: Array) -> void:
	var per := 3 if items.size() > 4 else 2
	var i := 0
	while i < items.size():
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
		var l := Label.new()
		l.text = t("Sieg.", "Victory.") if won else t("Der Kampf ist verloren.", "The fight is lost.")
		l.add_theme_font_size_override("font_size", int(font_px * 1.2))
		l.add_theme_color_override("font_color", BRIGHT if won else WARN)
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
		orders.add_child(w)
		return
	var f = m.current()
	var back := _button(t("Zurück", "Back"), true, func(): _set_pick("main"))
	match pick:
		"main":
			var reach: Array = m.targets(f)
			orders.add_child(_row([
				_button(t("Angriff", "Attack"), not reach.is_empty(), func():
					if reach.size() == 1:
						k.order(["attack", reach[0].id])
					else:
						_set_pick("target")),
				_button(t("Können", "Skills"), not m.moves(f).is_empty(), func(): _set_pick("skills")),
				_button(t("Tasche", "Bag"), not m.drinkable().is_empty(), func(): _set_pick("bag")),
				_button(t("Wechsel", "Switch"), m.can_swap(f) or m.can_draw(f), func(): _set_pick("place")),
			]))
			var low := [_button(t("Abwehr", "Defend"), true, func(): k.order(["wait"]), false, true)]
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
			orders.add_child(_row(low))
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
				var label := _spot_name(s) + ((" ⇄ " + who.name(lang)) if who != null else t(" (frei)", " (free)"))
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
	tip.position = Vector2(font_px * 0.4, kampfort.scene_rect().size.y - font_px * 3.5)
	tip.size = Vector2(vs.x - font_px * 0.8, 0)
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
	verdict.size = Vector2(vs.x, font_px * 2)
	get_tree().create_timer(2.2 if r == "PERFECT" else 1.2).timeout.connect(func(): verdict.visible = false)


func show_roll(e: Dictionary) -> void:
	if e.roll != null and e.target != null:
		roll_shown = [e.target, e.roll]
		roll_until = Time.get_ticks_msec() + 2500


func _draw_overlay() -> void:
	var k = kampfort
	var m = k.mars
	var font := ThemeDB.fallback_font
	var fs := int(font_px * 0.75)
	var sr: Rect2 = k.scene_rect()
	# the line of turns, top left (72.10a.4)
	var q: Array = k.shown.get("queue", [])
	var x := font_px * 0.4
	for id in q:
		var f = m.find(id)
		if f == null:
			continue
		var nm: String = f.name(lang)
		var c: Color = _friend_color(f) if f.side == "PARTY" else Color(0.85, 0.45, 0.35)
		overlay.draw_string(font, Vector2(x, font_px * 1.2), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c if x > font_px else GOLD)
		x += font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + font_px * 0.6
		if x > sr.size.x - font_px * 3:
			break
	# names and bars over the figures, the intents over the foes
	for id in k.figures:
		var fig = k.figures[id]
		if not fig.visible:
			continue
		var f = fig.fighter
		var hp: int = k.shown.hp.get(id, f.hp)
		if hp <= 0 and not fig.falling():
			continue
		var p: Vector2 = k.screen_of(fig.head())
		var w := font_px * 2.6
		var nm: String = f.name(lang)
		var nc: Color = _friend_color(f) if f.side == "PARTY" else BRIGHT
		if f == m.current() and not k.busy:
			nc = GOLD
		overlay.draw_string(font, p + Vector2(-w / 2, -font_px * 0.5), nm, HORIZONTAL_ALIGNMENT_CENTER, w, fs, nc)
		overlay.draw_rect(Rect2(p + Vector2(-w / 2, -font_px * 0.35), Vector2(w, font_px * 0.22)), Color(0.1, 0.05, 0.04))
		overlay.draw_rect(Rect2(p + Vector2(-w / 2, -font_px * 0.35), Vector2(w * clampf(float(hp) / f.max_hp, 0, 1), font_px * 0.22)), Color(0.7, 0.16, 0.1))
		if k.shown.intents.has(id):
			var plan: Array = k.shown.intents[id]
			var intent: Dictionary = plan[0]
			var aim := ""
			var ac := GOLD
			if not plan[1].is_empty():
				var tg = m.find(plan[1][0])
				if tg != null:
					aim = " › " + tg.name(lang)
					ac = _friend_color(tg)
			overlay.draw_string(font, p + Vector2(-w, -font_px * 1.15), intent.name[lang] + aim, HORIZONTAL_ALIGNMENT_CENTER, w * 2, fs,
				WARN if intent.strong else ac)
			for aimed in plan[1]:
				if k.figures.has(aimed):
					_aim_mark(k.screen_of(k.figures[aimed].position), ac)
	# the roll over the one struck (72.10a.10)
	if roll_shown != null and Time.get_ticks_msec() < roll_until and k.figures.has(roll_shown[0]):
		var r: Array = roll_shown[1]
		var p2: Vector2 = k.screen_of(k.figures[roll_shown[0]].head()) + Vector2(0, -font_px * 1.9)
		var txt := "W20 %d %+d = %d / %d" % [int(r[1]), int(r[2]), int(r[1]) + int(r[2]), int(r[3])]
		overlay.draw_string(font, p2 - Vector2(font_px * 3, 0), txt, HORIZONTAL_ALIGNMENT_CENTER, font_px * 6, fs, GOLD if r[4] else DIM)
	# the ring: a large ring closing on a small one round the one attacked (72.11)
	if ring_target != "" and k.figures.has(ring_target):
		var c2: Vector2 = k.screen_of(k.figures[ring_target].position + Vector3(0, 0.9, 0))
		var p3 := clampf(float(Time.get_ticks_msec() - ring_t0) / k.RING_MS, 0.0, 1.3)
		var r0 := font_px * 1.6
		overlay.draw_arc(c2, r0, 0, TAU, 48, GOLD, 3.0)
		overlay.draw_arc(c2, r0 * (1.0 + 2.2 * maxf(0.0, 1.0 - p3)), 0, TAU, 64, BRIGHT, 4.0)
		overlay.draw_string(font, Vector2(0, sr.size.y - font_px * 0.6), t("Tippen, wenn der große Ring auf dem kleinen liegt", "Tap when the large ring lies on the small one"),
			HORIZONTAL_ALIGNMENT_CENTER, sr.size.x, fs, DIM)


func _aim_mark(p: Vector2, c: Color) -> void:
	var r := font_px * 0.9
	overlay.draw_arc(p, r, 0, TAU, 40, c, 2.0)
