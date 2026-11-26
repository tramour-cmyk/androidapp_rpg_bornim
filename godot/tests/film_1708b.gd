extends SceneTree
# 1708 B Beleg Teil Schild (Chef 25.11., 19:22: „irgendein Wolfsbiss sah mal wieder aus, als ob er ins Schild geht und dann Blut
# spritzt“; Sokrates 1708-Ü12 23:22: Film Wolfsbiss am Schild alt gegen neu): Wolfsrudel wie tests/blut_1708.gd (Probe, Held Kämpfer,
# Kleriker, Würfel 1708, Ring gut), echter Kampfort, Spielkamera, Handyformat. Je Bild jeder Biss eines Wolfs an einer Figur mit
# Schild: liegt das Gebiss am Schild (höchstens 0,05 Körperhöhen) und ist der Schild näher als der Körper, der den Biss nicht berührt,
# steht „BISS AM SCHILD“ und ein weißes Kreuz am Schild; kommt Blut, steht „BLUT“. Oben FILM_TEXT (Stand, Commit), unten Bildnummer.
# Ausgabe „FILM1708B Schild Bild n …“ und „FILM1708B Blut Bild n …“ (Engine.get_process_frames, wie blut_1708 „Bild“).
# Aufruf im Ordner godot: --rendering-driver opengl3 --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30
#   -s res://tests/film_1708b.gd   (FILM_TEXT=„neu abc1234“, BIS=Bild zum Schluss)

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Bedienung = preload("res://skripte/bedienung.gd")
const FPS := 30.0
const AM := 0.05

var kf = null
var sichtbar := {}         # Figur -> {teile, koerper, schild} der Haltung, wie sie zu sehen war (skeleton_updated, mit Modifiern)
var punkt := Vector3.INF
var schild_bis := -1
var blut_bis := -1
var oben: Label
var mitte: Label
var unten: Label
var zeichner: Control


func _initialize() -> void:
	_lauf.call_deferred()


func _label(y: float, groesse: int) -> Label:
	var l := Label.new()
	l.position = Vector2(16, y)
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	return l


func _lauf() -> void:
	Bedienung.lade()
	var deck := CanvasLayer.new()
	deck.layer = 100
	root.add_child(deck)
	zeichner = Control.new()
	zeichner.set_anchors_preset(Control.PRESET_FULL_RECT)
	zeichner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zeichner.draw.connect(_kreuz)
	deck.add_child(zeichner)
	oben = _label(60, 26)
	oben.text = OS.get_environment("FILM_TEXT")
	deck.add_child(oben)
	mitte = _label(100, 30)
	deck.add_child(mitte)
	unten = _label(1100, 22)
	deck.add_child(unten)
	var bis := int(OS.get_environment("BIS")) if OS.get_environment("BIS") != "" else 1500
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(1708)
	for i in 4:
		await process_frame
	kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	while kf.verhuellt:
		await process_frame
	Mars.test_gegnerzug = ""
	for f in kf.figures.values():
		var fsk := f._find(f.model, "Skeleton3D") as Skeleton3D if f.model != null else null
		if fsk != null:
			fsk.skeleton_updated.connect(func() -> void:
				sichtbar[f] = {"teile": f.angriffs_kapseln(), "koerper": f.koerper(), "schild": f.schild_kapseln()})
	var t0 := int(kf.ui.bleeding.get("t0", -1)) if not kf.ui.bleeding.is_empty() else -1
	var ring_seit := -1
	var n := 0
	while Engine.get_process_frames() < bis:
		await process_frame
		n += 1
		var bild := Engine.get_process_frames()
		_schild(bild)
		var bl: Dictionary = kf.ui.bleeding
		if not bl.is_empty() and int(bl.t0) != t0:
			t0 = int(bl.t0)
			blut_bis = bild + int(FPS * 0.8)
			print("FILM1708B Blut Bild %d (%s an %s)" % [bild, bl.by, bl.on])
		var t := []
		if bild <= schild_bis:
			t.append("BISS AM SCHILD")
		if bild <= blut_bis:
			t.append("BLUT")
		mitte.text = "  ".join(t)
		mitte.add_theme_color_override("font_color", Color(1, 0.3, 0.3) if bild <= blut_bis else Color.WHITE)
		unten.text = "Bild %d   %.2f s" % [bild, bild / FPS]
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
	print("FILM1708B Ende Bild %d" % Engine.get_process_frames())
	quit(0)


## je Wolf im Biss: Gebiss am Schild einer Figur, Körper nicht berührt, Schild näher (wie Figur.endet_am_schild, blut_1708 _biss_ende)
func _schild(bild: int) -> void:
	for f in kf.figures.values():
		if f.fighter.side != "FOES" or f.anim == null or not String(f.anim.current_animation).to_lower().contains("biss") or not sichtbar.has(f):
			continue
		var teile: Array = sichtbar[f].teile
		for o in kf.figures.values():
			if o.fighter.side == "FOES" or o.down or not sichtbar.has(o):
				continue
			var sch: Array = sichtbar[o].schild
			var ks: Array = sichtbar[o].koerper
			if sch.is_empty() or ks.is_empty() or teile.is_empty():
				continue
			var h := _hoehe(ks)
			var dk: float = float(_abstand(teile, ks)[0]) / h
			var s: Array = _abstand(teile, sch)
			var ds: float = s[0] / h
			if ds <= AM and ds < dk and dk > AM:
				if bild > schild_bis:
					print("FILM1708B Schild Bild %d %s an %s: Schild %.2f, Körper %.2f Körperhöhen" % [bild, f.fighter.id, o.fighter.id, ds, dk])
				schild_bis = bild + int(FPS * 0.5)
				punkt = s[1]


func _hoehe(ks: Array) -> float:
	var lo := INF
	var hi := -INF
	for c in ks:
		lo = minf(lo, minf((c[0] as Vector3).y, (c[1] as Vector3).y) - float(c[2]))
		hi = maxf(hi, maxf((c[0] as Vector3).y, (c[1] as Vector3).y) + float(c[2]))
	return maxf(hi - lo, 0.1)


## [kleinster Abstand (m) der Strecken [teile] zur Oberfläche der Kapseln [ks], Punkt auf der Oberfläche]
func _abstand(teile: Array, ks: Array) -> Array:
	var best := INF
	var q := Vector3.INF
	for w in teile:
		for c in ks:
			var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
			var d: float = pq[0].distance_to(pq[1]) - float(c[2]) - float(w[2])
			if d < best:
				best = d
				q = pq[1] + (pq[0] - pq[1]).normalized() * float(c[2])
	return [best, q]


func _kreuz() -> void:
	if kf == null or punkt == Vector3.INF or Engine.get_process_frames() > schild_bis:
		return
	var s: Vector2 = kf.screen_of(kf.to_local(punkt))
	for c in [[Color.BLACK, 5.0], [Color.WHITE, 2.0]]:
		zeichner.draw_line(s + Vector2(-14, 0), s + Vector2(14, 0), c[0], c[1])
		zeichner.draw_line(s + Vector2(0, -14), s + Vector2(0, 14), c[0], c[1])
	zeichner.draw_arc(s, 9.0, 0.0, TAU, 24, Color.WHITE, 1.5)
