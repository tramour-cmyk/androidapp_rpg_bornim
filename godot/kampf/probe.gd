# 348.7: Probekampf wie im Systemmenü des alten Spiels (Skirmish.probe): Held und Söldner der gewählten Klassen auf
# Stufe 3, zwei Heiltränke, gegen das Wolfsrudel (oder Grak, Spinne, Späher). Erste Szene des Prüf-APKs, bis Toms
# Projekt den Kampf aus der Welt aufruft (Kampfort.setup).
extends Control

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const CLASSES := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]
const NAMES := {"FIGHTER": "Kämpfer", "WIZARD": "Magier", "ROGUE": "Schurke", "CLERIC": "Kleriker"}
const FOES := {"WOLVES": "Wolfsrudel", "GRAK": "Grak", "SPIDER": "Spinne", "SCOUT": "Späher"}

var tables: Dictionary
var hero_cls := "FIGHTER"
var merc_cls := "WIZARD"
var foe := "WOLVES"
var box: VBoxContainer
var fight: Node


func _ready() -> void:
	tables = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var vs := get_viewport().get_visible_rect().size
	var th := Theme.new()
	th.default_font_size = int(vs.x / 412.0 * 16.0)
	theme = th
	box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = vs.x * 0.06
	box.offset_right = -vs.x * 0.06
	box.offset_top = vs.y * 0.08
	box.add_theme_constant_override("separation", int(vs.y * 0.012))
	add_child(box)
	_menu()
	for a in OS.get_cmdline_user_args():
		if a == "--kampf":
			_start()


func _menu() -> void:
	for c in box.get_children():
		c.queue_free()
	_title("Probekampf (MARS, Godot)")
	_title("Held")
	box.add_child(_pick_row(CLASSES, NAMES, hero_cls, func(v): hero_cls = v; _menu()))
	_title("Söldner")
	box.add_child(_pick_row(CLASSES, NAMES, merc_cls, func(v): merc_cls = v; _menu()))
	_title("Gegner")
	box.add_child(_pick_row(FOES.keys(), FOES, foe, func(v): foe = v; _menu()))
	var go := Button.new()
	go.text = "Kämpfen"
	go.custom_minimum_size = Vector2(0, get_viewport().get_visible_rect().size.y * 0.06)
	go.pressed.connect(_start)
	box.add_child(go)


func _title(s: String) -> void:
	var l := Label.new()
	l.text = s
	l.add_theme_color_override("font_color", Color(0.86, 0.68, 0.30))
	box.add_child(l)


func _pick_row(keys: Array, names: Dictionary, now: String, set_it: Callable) -> HBoxContainer:
	var r := HBoxContainer.new()
	for k in keys:
		var b := Button.new()
		b.text = names[k]
		b.toggle_mode = true
		b.button_pressed = k == now
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, get_viewport().get_visible_rect().size.y * 0.05)
		var key: String = k
		b.pressed.connect(func(): set_it.call(key))
		r.add_child(b)
	return r


func _start() -> void:
	var dice = Wuerfel.new()
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var hs: Dictionary = tables.probe[hero_cls].hero
	var ms: Dictionary = tables.probe[merc_cls].merc
	var merc_back: bool = ms.hero.main.ranged or merc_cls == "WIZARD" or merc_cls == "CLERIC"
	var party := [
		Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs.hero, int(hs.hp), hs.hero.second, skills),
		Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 0) if merc_back else Vector2i(Mars.FRONT, 1), ms.hero, int(ms.hp), ms.hero.second, skills),
	]
	var foes := []
	var lineup: Array = {
		"WOLVES": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		"GRAK": [["grak", Mars.GRAK, Vector2i(0, 0)]],
		"SPIDER": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["spider", Mars.SPIDER, Vector2i(1, 0)]],
		"SCOUT": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["scout", Mars.SCOUT, Vector2i(1, 0)]],
	}[foe]
	for e in lineup:
		var m: Dictionary = monsters[e[1]]
		foes.append(Mars.monster_fighter(e[0], e[2], m, dice.roll_expr(m.hp)))
	visible = false
	fight = Kampfort.new()
	fight.setup(party, foes, tables, {"potion": 2}, func(_outcome): visible = true)
	fight.again_fn = _start
	get_tree().root.add_child.call_deferred(fight)
