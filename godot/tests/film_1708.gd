extends SceneTree
# 1708 Beleg (Chef 25.11., 16:03: „das Blut muss da anfangen, wo jemand getroffen wird“): echter Kampfort mit Spielkamera im
# Handyformat, erst Wolfsrudel (Biss Wolf an Held, Klinge Held an Wolf), dann Krogg (Prankenhieb, Mars.test_gegnerzug „paw“).
# Je erstem Treffer mit Blut dieser Art schreibt es „FILM1708 <Art> Bild <n>“ (Bild des Aufschlags, Engine.get_frames_drawn) und
# markiert 0,8 s lang den Berührungspunkt Angriffsteil–Körper (wie tests/blut_1708.gd, geht mit dem Knochen des Getroffenen) mit
# einem weißen Kreuz; oben steht FILM_TEXT (Stand, Commit) und die Art des Treffers. Schnitt: godot.yml oder von Hand mit ffmpeg.
# Aufruf im Ordner godot: --rendering-driver opengl3 --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30
#   -s res://tests/film_1708.gd   (SEED=7, FILM_TEXT=„neu abc1234“)

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Bedienung = preload("res://skripte/bedienung.gd")
const FPS := 30.0
const BISS := ["head", "jaw", "tongue", "kopf", "fang", "mouth", "maul", "schnauze", "beak"]
const PRANKE := ["hand_l", "index_", "middle_", "pinky_", "ring_", "thumb_"]

var kf = null
var marke := {}           # {on, knochen, aus, bis} solange das Kreuz steht
var titel: Label
var art_text: Label
var zeichner: Control


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	seed(int(OS.get_environment("SEED")) if OS.has_environment("SEED") else 7)
	Bedienung.lade()
	var deck := CanvasLayer.new()
	deck.layer = 100
	root.add_child(deck)
	zeichner = Control.new()
	zeichner.set_anchors_preset(Control.PRESET_FULL_RECT)
	zeichner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zeichner.draw.connect(_kreuz)
	deck.add_child(zeichner)
	titel = Label.new()
	titel.position = Vector2(16, 60)
	titel.add_theme_font_size_override("font_size", 26)
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 6)
	titel.text = OS.get_environment("FILM_TEXT")
	deck.add_child(titel)
	art_text = Label.new()
	art_text.position = Vector2(16, 96)
	art_text.add_theme_font_size_override("font_size", 24)
	art_text.add_theme_color_override("font_outline_color", Color.BLACK)
	art_text.add_theme_constant_override("outline_size", 6)
	deck.add_child(art_text)
	await _kampf("WOLVES", ["Biss", "Klinge"], "")
	await _kampf("KROGG", ["Pranke"], "paw")
	print("FILM1708 Ende Bild %d" % Engine.get_frames_drawn())
	quit(0)


func _kampf(foe: String, arten: Array, zug: String) -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(int(OS.get_environment("SEED")) if OS.has_environment("SEED") else 7)
	for i in 4:
		await process_frame
	kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	while kf.verhuellt:
		await process_frame
	Mars.test_gegnerzug = zug
	var offen: Array = arten.duplicate()
	var t0 := int(kf.ui.bleeding.get("t0", -1)) if not kf.ui.bleeding.is_empty() else -1
	var ring_seit := -1
	var n := 0
	var nach := -1
	while n < int(FPS * 150):
		await process_frame
		n += 1
		if zug != "" and Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = zug
		var bl: Dictionary = kf.ui.bleeding
		if not bl.is_empty() and int(bl.t0) != t0 and kf.figures.has(bl.by) and kf.figures.has(bl.on):
			t0 = int(bl.t0)
			var by = kf.figures[bl.by]
			var on = kf.figures[bl.on]
			var a := _art(by)
			if a in offen:
				offen.erase(a)
				# gemessen, wie zu sehen: im nächsten Stellen des Gerüsts des Getroffenen (mit den Modifiern)
				var sk0 := on._find(on.model, "Skeleton3D") as Skeleton3D if on.model != null else null
				if sk0 != null:
					sk0.skeleton_updated.connect(func() -> void: _setze(by, on), CONNECT_ONE_SHOT)
				var wer := "%s an %s" % [_name(by), _name(on)]
				art_text.text = "%s: %s" % [a, wer]
				print("FILM1708 %s Bild %d (%s)" % [a, Engine.get_frames_drawn(), wer])
				if offen.is_empty():
					nach = n + int(FPS * 1.5)
		if nach > 0 and n >= nach:
			break
		zeichner.queue_redraw()
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if kf.ring_open:
			ring_seit = n if ring_seit < 0 else ring_seit
			if n - ring_seit >= int(kf.RING_MS * kf.ring_faktor / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	if not offen.is_empty():
		print("FILM1708 %s: ohne %s" % [foe, offen])
	Mars.test_gegnerzug = ""
	marke = {}
	p.queue_free()
	await process_frame


func _name(f) -> String:
	return {"hero": "Held", "merc": "Kleriker"}.get(f.fighter.id, String(f.fighter.id).capitalize())


func _art(by) -> String:
	if by.anim != null and String(by.anim.current_animation) == "Prankenhieb":
		return "Pranke"
	return "Klinge" if by.fighter.monster == null else "Biss"


## Berührungspunkt Angriffsteil–Körper (wie tests/blut_1708.gd), gemerkt im Raum des nächsten Knochens des Getroffenen
func _setze(by, on) -> void:
	var sk := on._find(on.model, "Skeleton3D") as Skeleton3D if on.model != null else null
	var bsk := by._find(by.model, "Skeleton3D") as Skeleton3D if by.model != null else null
	if sk == null or bsk == null:
		return
	var ws: Array = []
	if String(by.anim.current_animation) == "Prankenhieb":
		for c in by.kapseln():
			var nm := String(c[3]) if c.size() > 3 else ""
			if nm == "hand_l" or nm.ends_with("_l") and PRANKE.any(func(w): return nm.begins_with(w)):
				ws.append(c)
	else:
		for at in by.find_children("*", "BoneAttachment3D", true, false):
			var was := String(at.get_meta("was", ""))
			if was == "" or was.contains("shield"):
				continue
			var kn: Transform3D = bsk.global_transform * bsk.get_bone_global_pose(at.bone_idx)
			var hm: Dictionary = by.klinge_halt(at)
			if not hm.is_empty():
				var tr: Transform3D = kn * (at.global_transform.affine_inverse() * (at.get_child(0) as Node3D).global_transform)
				ws.append([tr * (hm.griff as Vector3), tr * (hm.spitze as Vector3), 0.0])
		if ws.is_empty():
			for c in by.kapseln():
				var nm := String(c[3]).to_lower() if c.size() > 3 else ""
				if BISS.any(func(w): return nm.contains(w)):
					ws.append(c)
	var punkt := Vector3.INF
	var bd := INF
	for w in ws:
		for c in on.koerper():
			var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
			var d: Vector3 = pq[0] - pq[1]
			if d.length() < bd:
				bd = d.length()
				punkt = pq[1] + (d.normalized() * float(c[2]) if d.length() > float(c[2]) else d)
	if punkt == Vector3.INF:
		return
	var best := -1
	var nah := INF
	for i in sk.get_bone_count():
		var nm := sk.get_bone_name(i).to_lower()
		if nm.begins_with("ik_") or nm == "root":
			continue
		var pa := sk.get_bone_parent(i)
		var a: Vector3 = sk.global_transform * sk.get_bone_global_pose(i).origin
		var b: Vector3 = a if pa < 0 else sk.global_transform * sk.get_bone_global_pose(pa).origin
		var d := Geometry3D.get_closest_point_to_segment(punkt, a, b).distance_to(punkt)
		if d < nah:
			nah = d
			best = pa if pa >= 0 else i
	var tr: Transform3D = sk.global_transform * sk.get_bone_global_pose(best)
	marke = {"on": on, "sk": sk, "knochen": best, "aus": tr.affine_inverse() * punkt, "bis": Engine.get_process_frames() + int(FPS * 0.8), "q": punkt}
	var folge := func() -> void:
		if not marke.is_empty() and marke.sk == sk:
			marke.q = sk.global_transform * sk.get_bone_global_pose(best) * (marke.aus as Vector3)
	sk.skeleton_updated.connect(folge)
	create_timer(1.0).timeout.connect(func() -> void: if is_instance_valid(sk) and sk.skeleton_updated.is_connected(folge): sk.skeleton_updated.disconnect(folge))


func _kreuz() -> void:
	if marke.is_empty() or Engine.get_process_frames() > int(marke.bis) or not is_instance_valid(marke.on) or kf == null:
		return
	var q: Vector3 = marke.q
	var s: Vector2 = kf.screen_of(kf.to_local(q))
	for c in [[Color.BLACK, 5.0], [Color.WHITE, 2.0]]:
		zeichner.draw_line(s + Vector2(-14, 0), s + Vector2(14, 0), c[0], c[1])
		zeichner.draw_line(s + Vector2(0, -14), s + Vector2(0, 14), c[0], c[1])
	zeichner.draw_arc(s, 9.0, 0.0, TAU, 24, Color.WHITE, 1.5)
