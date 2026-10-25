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
## the hero's name on the comparison picture (MarsShot: "Mira")
var still_name := ""


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
		elif a.begins_with("--bild="):     # Vergleichsbild alt/neu: wie MarsShot (Kleriker, Söldner Kämpfer, Wölfe)
			_still(a.substr(7))


func _still(path: String) -> void:
	hero_cls = "CLERIC"
	still_name = "Mira"
	merc_cls = "FIGHTER"
	foe = "WOLVES"
	_start.call_deferred(7)
	await get_tree().create_timer(2.5).timeout
	# wie im alten Bild: der Held ist dran, die Knöpfe stehen (höchstens 10 s warten)
	# im Zeitraffer bis zum Zug der Gruppe (die Gegner sind oft zuerst dran; Schritte sonst rund eine Minute)
	Engine.time_scale = 8.0
	var until := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < until and fight and (fight.busy or fight.playing or fight.mars.current().side != "PARTY"):
		await get_tree().process_frame
	Engine.time_scale = 1.0
	if fight:
		print("Dran %s, beschäftigt %s, spielt %s, %d ms" % [fight.mars.current().id, fight.busy, fight.playing, Time.get_ticks_msec()])
	await get_tree().create_timer(0.6).timeout
	# Würfelzeile ganz oder gar nicht (Prüfer Runde 4: „halb ausgeblendet“): beginnt gleich das Ausblenden, abwarten
	var ui = fight.ui
	if ui.roll_shown != null:
		var age: int = Time.get_ticks_msec() - ui.roll_at
		if age > ui.ROLL_MS - 300 and age < ui.ROLL_MS + ui.ROLL_FADE_MS:
			await get_tree().create_timer((ui.ROLL_MS + ui.ROLL_FADE_MS - age + 50) / 1000.0).timeout
	# 296.2: ZUSTAND=1 legt Zustände auf Held und ersten Wolf, um ihre Zeichen zu zeigen
	if OS.get_environment("ZUSTAND") != "":
		var fs: Array = fight.mars.fighters()
		fs[0].status = {"POISON": 2, "BLEED": 3}
		for f in fs:
			if f.side == "FOES" and f.standing():
				f.status = {"STUN": 1, "WEAK": 2}
				break
		fight.shown["status"] = fight.mars._statuses()
		await get_tree().create_timer(0.2).timeout
	# 296.2: SIEG=1 beendet den Kampf als Sieg und zeigt den Endschirm mit dem Lohn
	if OS.get_environment("SIEG") != "":
		fight.test_end(true)
		var stop := Time.get_ticks_msec() + 20000
		while Time.get_ticks_msec() < stop and (fight.busy or fight.playing or not fight.beats.is_empty()):
			await get_tree().process_frame
		await get_tree().create_timer(1.5).timeout
		print("Lohn ", fight.reward.get("lines", []))
	# 348.7: HALTUNG=Lefzen:0.5 hält alle Wölfe in dieser Bewegung an dieser Stelle (Sekunden), für Standbilder der Ruhebewegungen
	var hal := OS.get_environment("HALTUNG")
	if hal != "":
		for id in fight.figures:
			var fg = fight.figures[id]
			var hn: String = fg.scharren_name() if hal.get_slice(":", 0) == "Scharren" and fg.has_method("scharren_name") else hal.get_slice(":", 0)
			if fg.anim and fg.anim.has_animation(hn):
				fg.anim.play(hn, 0.0)
				fg.anim.seek(float(hal.get_slice(":", 1)), true)
				fg.anim.pause()
				fg.set_process(false)     # Runde 15: sonst zappelt der Wolf nach 4–9 s (Lefzen/Scharren) oder wechselt in die Hocke
				fg.fidget_at = 0
		await get_tree().create_timer(0.2).timeout
		for id in fight.figures:
			for sk in fight.figures[id].find_children("*", "Skeleton3D", true, false):
				var i: int = sk.find_bone("vpfoteL")
				if i >= 0:
					print("Pfote %s: %s, Kiefer %s" % [id, sk.get_bone_global_pose(i).origin.snapped(Vector3.ONE * 0.01), sk.get_bone_pose_rotation(sk.find_bone("kiefer")).get_euler().snapped(Vector3.ONE * 0.01)])
			for ps in fight.figures[id].find_children("Pfotenschatten", "MeshInstance3D", true, false):
				print("Pfotenschatten %s: %s sichtbar %s, Figur y %.3f" % [id, ps.global_position.snapped(Vector3.ONE * 0.01), ps.is_visible_in_tree(), fight.figures[id].global_position.y])
		await get_tree().create_timer(0.2).timeout
	if hal != "":     # Runde 15: unmittelbar vor dem Bild noch einmal an die Stelle (Kampfablauf kann umgeschaltet haben)
		for id in fight.figures:
			var fg = fight.figures[id]
			var hn: String = fg.scharren_name() if hal.get_slice(":", 0) == "Scharren" and fg.has_method("scharren_name") else hal.get_slice(":", 0)
			if fg.anim and fg.anim.has_animation(hn):
				fg.anim.play(hn, 0.0)
				fg.anim.seek(float(hal.get_slice(":", 1)), true)
				fg.anim.pause()
				if not fg.paws.is_empty():
					fg._paw_shadow_update()
				print("Haltung fest %s: %s" % [id, hn])
	_report_facing()
	for id in fight.figures:
		var fg = fight.figures[id]
		print("Haltung %s: %s, Ansage %s" % [id, fg.anim.current_animation if fg.anim else "-", fight.shown.intents.get(id, [{}])[0].get("effect", "")])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("Bild ", path)
	get_tree().quit()


## For the Prüflauf: which way each figure looks (heel to toe, or its +Z) against the way it should face.
func _report_facing() -> void:
	if fight == null:
		return
	for id in fight.figures:
		var fig = fig_of(id)
		var want: Vector3 = fight.facing(fig.fighter.side == "FOES")
		var got: Vector3 = fig.global_basis.z
		var sk := _skeleton(fig)
		if sk:
			var a := sk.find_bone("ankleR-heelR")
			var b := sk.find_bone("ballR-toeR")
			if a >= 0 and b >= 0:
				got = sk.global_transform * sk.get_bone_global_pose(b).origin - sk.global_transform * sk.get_bone_global_pose(a).origin
		got.y = 0
		if fig.neck:
			print("Hals %s: %.0f° gegen den Rumpf (soll %.0f°)" % [id, fig.neck.turned, fig.neck.want])
			if fig.aim != null:
				var ta: Vector3 = fig.aim.position - fig.position
				print("Ziel %s: %s, %.0f° vom Rumpf" % [id, fig.aim.fighter.id if "id" in fig.aim.fighter else fig.aim.name, rad_to_deg(fig.global_basis.z.signed_angle_to(ta, Vector3.UP))])
		if sk and sk.find_bone("foR-wrR") >= 0:
			var hb := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("foR-wrR"))
			print("Hand %s: Ort %s, x %s, y %s, z %s" % [id, hb.origin, hb.basis.x.normalized(), hb.basis.y.normalized(), hb.basis.z.normalized()])
		for w in fig.find_children("Waffe", "", true, false) + fig.find_children("Schild", "", true, false):
			var gb: Basis = (w as Node3D).global_basis.orthonormalized()
			print("%s %s: Achse (Klinge) %s, Fläche %s, Ort %s" % [w.name, id, gb.y.snapped(Vector3.ONE * 0.01), gb.z.snapped(Vector3.ONE * 0.01), (w as Node3D).global_position.snapped(Vector3.ONE * 0.01)])
		var foot: Vector2 = fight.screen_of(fig.global_position)
		var top: Vector2 = fight.screen_of(fig.head())
		print("Schirm %s: Fuß %d,%d Kopf %d,%d" % [id, foot.x, foot.y, top.x, top.y])
		for oid in fight.figures:
			if fight.figures[oid].fighter.side != fig.fighter.side:
				var to: Vector3 = fight.figures[oid].position - fig.position
				print("  zu %s: %.0f°" % [oid, rad_to_deg(want.signed_angle_to(to, Vector3.UP))])
		print("Blick %s: soll %s, ist %s, Winkel %.0f°" % [id, want.normalized(), got.normalized(), rad_to_deg(want.signed_angle_to(got, Vector3.UP))])


func fig_of(id):
	return fight.figures[id]


func _skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var r := _skeleton(c)
		if r:
			return r
	return null


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


func _start(seed := -1) -> void:
	var dice = Wuerfel.new(null if seed < 0 else seed + 1)
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
	if still_name != "":
		party[0].hero = party[0].hero.duplicate()
		party[0].hero.name = still_name
	for e in lineup:
		var m: Dictionary = monsters[e[1]]
		foes.append(Mars.monster_fighter(e[0], e[2], m, dice.roll_expr(m.hp)))
	visible = false
	fight = Kampfort.new()
	# 296.2: der Held der Probe steht am Anfang seiner Stufe; ohne LP kein Kampf
	var xp := int(tables.xpForLevel[int(hs.hero.level)])
	if not fight.setup(party, foes, tables, {"potion": 2}, func(_outcome): visible = true, seed, {"xp": xp}):
		visible = true
		fight.free()
		fight = null
		return
	fight.again_fn = _start
	get_tree().root.add_child.call_deferred(fight)
