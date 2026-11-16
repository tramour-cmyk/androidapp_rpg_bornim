# 935 (Fund t277.10, Chef 11.11., 20:34: „kein Wurf … Keine Parabel, die geworfen wurde, sondern ein nach vorne gerichteter
# Schubser“): Film durch die echte Oberfläche, Spielkamera, Echtzeit. Teil 1 Wölfe: der Held wirft Alchemistenfeuer, sobald er am
# Zug ist (Söldner und Gegner nach Autopilot); Teil 2 Skelette: Weihwasser. Nach dem Wurf noch 4 s, dann Ende des Teils.
# Aufruf (Bild, Probelauf nach 389): PROBE=935 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_wurf_935.gd       MESS=1 ohne Bild: nur die Abläufe (Wurf geworfen, Art der Flasche)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const BLENDE_BILDER := 8

var mess := OS.get_environment("MESS") != ""
var schwarz: ColorRect
var lb: Label
var lz: Label
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not mess:
		var deck := CanvasLayer.new()
		deck.layer = 128
		schwarz = ColorRect.new()
		schwarz.color = Color.BLACK
		schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
		schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
		deck.add_child(schwarz)
		root.add_child(deck)
		var cl := CanvasLayer.new()
		cl.layer = 120
		root.add_child(cl)
		var vs: Vector2 = root.get_visible_rect().size
		lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.16), int(vs.x / 19.0), Color(0.95, 0.82, 0.45))
		lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.205), int(vs.x / 28.0), Color(0.92, 0.88, 0.80))
	await _teil("WOLVES", "alchemist_fire", 1, "Alchemistenfeuer auf die Wölfe")
	await _teil("SKELETONS", "holy_water", 1, "Weihwasser auf die Skelette")
	print("Film 935 %s" % ("Messung: %d Befunde" % fehler if mess else "fertig"))
	quit(1 if fehler > 0 else 0)


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(fs / 6, 3))
	cl.add_child(l)
	return l


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


func _teil(g: String, ding: String, wuerfe: int, titel: String) -> void:
	seed(5)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = g
	root.add_child(p)
	await process_frame
	p._start(5)
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 935: kein Kampfort für %s" % g)
		fehler += 1
		return
	var m = kf.mars
	m.find("merc").auto = true
	m.potions[ding] = wuerfe
	if not mess and not Signatur.wache(kf, self, "Film 935 " + g):
		return
	if lb:
		lb.text = "935 · " + titel
		lz.text = "Spielkamera, Echtzeit"
	await _blende(0.0)
	if not kf.busy:
		kf.go_on()
	var geworfen := 0
	var arten := []
	var nach := -1     # Bilder seit dem letzten Wurf
	var n := 0
	while n < 30 * 60 and (m.outcome == "ONGOING" or (nach >= 0 and nach < 30 * 4)):     # nach dem letzten Wurf: Flug und Einschlag zu Ende
		await process_frame
		n += 1
		for sp in kf.ui.spells:
			if String(sp.by) == "hero" and not arten.has(String(sp.kind) + str(sp.seed)):
				arten.append(String(sp.kind) + str(sp.seed))
				print("Film 935 %s: fliegt %s" % [g, sp.kind])
				if not String(sp.kind).begins_with("BOMB_"):
					fehler += 1
		if nach >= 0:
			nach += 1
		if geworfen >= wuerfe and nach > 30 * 4:
			break
		if geworfen >= wuerfe or m.outcome != "ONGOING":
			continue
		if kf.busy or kf.playing or not kf.beats.is_empty():
			continue
		if m.pilot_next():
			kf.go_on()
			continue
		var c = m.current()
		if c == null or c.id != "hero":
			continue
		var ziele: Array = m.throw_targets(ding)
		if geworfen < wuerfe and ziele.is_empty():
			print("Film 935 %s: Held am Zug, kein Ziel für %s (in der Tasche: %s, untot: %s)" % [g, ding, m.items.has(ding),
				m.all.filter(func(x): return x.monster != null).map(func(x): return bool(x.monster.get("undead", false)))])
		if geworfen < wuerfe and not ziele.is_empty():
			geworfen += 1
			if lz:
				lz.text = "Wurf %d von %d" % [geworfen, wuerfe]
			kf.order(["throw", ding, ziele[0].id])
			print("Film 935 %s: Wurf %d auf %s nach %.1f s" % [g, geworfen, ziele[0].id, n / 30.0])
			nach = 0
		else:
			var ts: Array = m.targets(c)
			kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	print("Film 935 %s: %d von %d Würfen nach %.1f s" % [g, geworfen, wuerfe, n / 30.0])
	if geworfen < wuerfe:
		fehler += 1
	await create_timer(1.0).timeout
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame
