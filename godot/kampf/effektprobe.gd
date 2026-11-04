# 572 (Chef 04.11., 20:27, „ganz flott“): Effektprobe vor dem Kauf (415d.1). Die sechs Effekte der zwei Gratisstücke von REEBOO
# (Stylized VFX Free Sample: Hit Spark, Slash, Pickup Sparkle; Stylized Status Effects Free Sample: armor_up, poisoned, buff_gain)
# an unserem Helden (Kleriker) im Kampfort wie im Spiel: Toon-Licht, Tusche, Spielkamera. Die Pakete liegen nur im privaten Repo
# bornim-kaufmodelle (Lizenz: Weitergabe der Dateien verboten), der Ablauf effektprobe-572.yml kopiert sie in den Bau
# (godot/addons/reeboo_vfx und die Effektordner, .gitignore) und schreibt die Liste der Szenen nach res://daten/vfx572.txt.
# Kein Einbau ins Spiel: der Kampf ruht (MARS steht), der Held schlägt nur für Slash und Hit Spark zu und geht bei den Zuständen.
# Folge: Slash beim Angriff, Hit Spark am getroffenen Wolf, Pickup Sparkle, buff_gain, armor_up, poisoned (am Fußpunkt, mitlaufend),
# erst ohne, dann mit Glow; am Ende poisoned in Grün und in Blau (Farbton aller farbigen Werte gesetzt) als Farbvariante.
# Kopfzeile: Effekt, Glow, Bilder/s, Zeichenaufrufe, Dreiecke; darunter die einstellbaren Werte der Effektszene (Export).
# Aufruf: godot --path godot res://kampf/effektprobe.tscn [--write-movie …]; EFFEKT_BILDER=<ordner>: je Abschnitt ein Standbild
# in der Mitte (Probebild, 511), ohne Glow-Durchgang, dann Ende.
extends Node

const Probe = preload("res://kampf/probe.gd")
const LISTE := "res://daten/vfx572.txt"
## Abschnitt: Titel, Suchwörter im Dateinamen (das erste, das trifft), Ort (angriff, treffer, fuss), Sekunden
const FOLGE := [
	["Slash beim Angriff", ["slash"], "angriff", 0.0],
	["Hit Spark am Gegner", ["hit_spark", "hitspark", "hit"], "treffer", 0.0],
	["Pickup Sparkle", ["pickup", "sparkle"], "fuss", 3.5],
	["buff_gain", ["buff_gain", "buff"], "fuss", 4.5],
	["armor_up", ["armor_up", "armor"], "fuss", 4.5],
	["poisoned", ["poisoned", "poison"], "fuss", 4.5],
]
const BRUST := 0.45          # Trefferhöhe über dem Boden des Wolfs, m
const NEU_S := 1.2           # einmalige Effekte so oft neu

var probe
var kf
var held
var wolf
var umwelt: Environment
var lb: Label
var lb2: Label
var szenen := {}             # Titel -> Pfad
var jetzt := ""
var glow := false
var bilder_ordner := OS.get_environment("EFFEKT_BILDER")
var nr := 0


func _ready() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	probe = Probe.new()
	probe.hero_cls = "CLERIC"
	probe.merc_cls = "FIGHTER"
	probe.foe = "WOLVES"
	add_child(probe)
	await get_tree().process_frame
	probe._start(7)
	for i in 6:
		await get_tree().process_frame
	kf = probe.fight
	_oberflaeche()
	if kf == null:
		lb.text = "Kampfort fehlt"
		return
	if kf.ui != null:
		kf.ui.visible = false
	held = kf.figures.get("hero")
	for w in kf.find_children("*", "WorldEnvironment", true, false):
		umwelt = (w as WorldEnvironment).environment
	_szenen()
	await _kampf_ruht()
	wolf = _wolf()
	print("572 Held %.2f m hoch (Kopf), Wolf %s" % [held.head().y - held.global_position.y, wolf.name if wolf else "fehlt"])
	var gaenge := [false] if bilder_ordner != "" else [false, true]
	for g in gaenge:
		_glow(g)
		for z in FOLGE:
			await _abschnitt(z)
	_glow(true)
	for v in [["Grün", 0.33], ["Blau", 0.6]]:
		await _abschnitt(["poisoned " + v[0], ["poisoned", "poison"], "fuss", 4.0], v[1])
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


## Szenen aus der Liste des Ablaufs, je Abschnitt die mit dem kürzesten Namen, der das erste passende Suchwort enthält
func _szenen() -> void:
	var f := FileAccess.open(LISTE, FileAccess.READ)
	var alle := PackedStringArray()
	if f:
		alle = f.get_as_text().strip_edges().split("\n")
	print("572 Szenen im Bau: %d" % alle.size())
	for z in FOLGE:
		for wort in z[1]:
			var best := ""
			for p in alle:
				var n := p.get_file().get_basename().to_lower().replace(" ", "_").replace("-", "_")
				if n.contains(wort) and not (z[0].begins_with("Hit") and n.contains("sparkle")) and (best == "" or p.get_file().length() < best.get_file().length()):
					best = p
			if best != "":
				szenen[z[0]] = best
				break
		print("572 %s -> %s" % [z[0], szenen.get(z[0], "FEHLT")])


func _glow(an: bool) -> void:
	glow = an
	if umwelt:
		umwelt.glow_enabled = an
		# wie in der Demo des Pakets (README: Stärke 0,7, HDR-Schwelle 1,0, Screen, Stufen 2 bis 5)
		umwelt.glow_intensity = 0.7
		umwelt.glow_bloom = 0.0
		umwelt.glow_hdr_threshold = 1.0
		umwelt.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
		var stufen := [0.0, 1.0, 1.0, 0.7, 0.3, 0.0, 0.0]
		for i in 7:
			umwelt.set_glow_level(i, stufen[i])


func _abschnitt(z: Array, farbton := -1.0) -> void:
	jetzt = z[0]
	var pfad: String = szenen.get(z[0], szenen.get("poisoned", "")) if farbton >= 0.0 else szenen.get(z[0], "")
	if pfad == "" or not ResourceLoader.exists(pfad):
		jetzt = z[0] + ": Szene fehlt"
		print("572 FEHLT %s" % z[0])
		await get_tree().create_timer(1.0).timeout
		return
	var ps := load(pfad) as PackedScene
	lb2.text = _einstellbar(ps)
	match z[2]:
		"angriff", "treffer":
			for i in 2:
				await _schlag(ps, z[2] == "treffer", i == 0)
		_:
			var fx := _neu(ps, farbton)
			held.add_child(fx)
			fx.scale = Vector3.ONE / held.scale
			_spielen(fx)
			if farbton >= 0.0:
				await get_tree().process_frame
				print("572 %s: %d Farben gesetzt" % [z[0], _faerben(fx, farbton)])
			var einmal := _einmalig(fx)
			if einmal and "auto_free" in fx:     # das erste bleibt für die Länge, die folgenden geben sich selbst frei
				fx.set("auto_free", false)
			var dauer: float = z[3]
			var t := 0.0
			var neu_t := 0.0
			var gegangen := false
			var heim: Vector3 = held.home
			var gemessen := false
			while t < dauer:
				await get_tree().process_frame
				var dt := get_process_delta_time()
				t += dt
				neu_t += dt
				if einmal and neu_t >= (float(fx.call("get_duration")) + 0.3 if fx.has_method("get_duration") else NEU_S):     # einmalige Effekte (Pickup) neu, am selben Fußpunkt
					neu_t = 0.0
					var f2 := _neu(ps, farbton)
					held.add_child(f2)
					f2.scale = fx.scale
					_spielen(f2)
				if not gegangen and t >= 1.6:     # mitlaufen: der Held geht ein Stück zur Seite und zurück
					gegangen = true
					held.glide_to(heim + _seite() * 1.4)
					get_tree().create_timer(1.6).timeout.connect(func(): held.glide_to(heim))
				if not gemessen and t >= 1.0:
					gemessen = true
					_messen(z[0], fx)
					_bild()
			_ende(fx)
			while held.global_position.distance_to(heim) > 0.05 and t < dauer + 3.0:
				await get_tree().process_frame
				t += get_process_delta_time()
	await get_tree().create_timer(0.6).timeout


## der Held schlägt den Wolf (figur.gd strike wie im Kampf); im Aufschlag Slash vor ihm oder Hit Spark am Wolf
func _schlag(ps: PackedScene, treffer: bool, bild: bool) -> void:
	if wolf == null:
		return
	var ms: int = held.strike(wolf, {"spell": null})
	var auf: float
	if held.hieb.size() >= 3:
		auf = held.anlauf_ms / 1000.0 + float(held.hieb[1])
	else:
		auf = float(held.get_script().get_script_constant_map().get("BLOW_MS", 500)) * 0.42 / 1000.0
	await get_tree().create_timer(auf).timeout
	var zu: Vector3 = wolf.global_position - held.global_position
	zu.y = 0.0
	var punkt: Vector3 = wolf.global_position + Vector3(0, BRUST, 0) - zu.normalized() * wolf.body_r() * 0.8
	var fx := _neu(ps)
	kf.add_child(fx)
	if treffer:     # Ursprung des Funkens in seiner Mitte (Demo: 1 m über dem Boden)
		fx.global_position = punkt
		wolf.hurt(0, false)
	else:     # Ursprung des Hiebs am Boden, Bogen in der Ebene quer zur Blickrichtung (Demo): vor dem Helden, zu ihm gedreht
		var b: Basis = held.global_transform.basis.orthonormalized()
		fx.global_transform = Transform3D(b, held.global_position + b.z * 0.45)
	_spielen(fx)
	if bild:
		await get_tree().create_timer(0.12).timeout
		_messen(jetzt, fx)
		_bild()
	var rest := maxf(held.busy_ms / 1000.0 - auf, 0.0) + 0.5
	await get_tree().create_timer(maxf(rest, ms / 1000.0 - auf + 0.4)).timeout


func _neu(ps: PackedScene, farbton := -1.0) -> Node3D:
	var n := ps.instantiate()
	if farbton >= 0.0:     # exportierte Farben vor _ready (falls der Effekt sie selbst auf die Stoffe legt)
		for p in n.get_property_list():
			if p.type == TYPE_COLOR and p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				n.set(p.name, _ton(n.get(p.name), farbton))
	if n is Node3D:
		return n
	var h := Node3D.new()
	h.add_child(n)
	return h


## VFXEffect (vfx_effect.gd) startet selbst (autoplay, je Schicht mit ihrer Verzögerung); sonst alle Partikel von vorn
func _spielen(fx: Node) -> void:
	if "autoplay" in fx and fx.get("autoplay"):
		return
	for p in fx.find_children("*", "GPUParticles3D", true, false):
		p.emitting = true
		p.restart()


## Schleifen enden wie im Spiel (stop: die Teilchen laufen aus, dann gibt sich der Knoten frei), einmalige geben sich selbst frei
func _ende(fx: Node) -> void:
	if not is_instance_valid(fx):
		return
	if fx.has_method("stop") and fx.get("auto_free"):
		fx.call("stop")
	else:
		fx.queue_free()


func _einmalig(fx: Node) -> bool:
	for p in fx.find_children("*", "GPUParticles3D", true, false) + fx.find_children("*", "CPUParticles3D", true, false):
		if p.one_shot:
			return true
	return false


## was die Effektszene zum Einstellen anbietet (exportierte Werte des Skripts an der Wurzel), mit Wert
func _einstellbar(ps: PackedScene) -> String:
	var n := ps.instantiate()
	var z := PackedStringArray()
	for p in n.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and p.usage & PROPERTY_USAGE_EDITOR:
			var v = n.get(p.name)
			z.append("%s=%s" % [p.name, ("%.2f" % v) if v is float else str(v).left(18)])
	var tl := n.find_children("*", "GPUParticles3D", true, false).size() + n.find_children("*", "CPUParticles3D", true, false).size()
	n.free()
	print("572 einstellbar %s: %s; Partikelsysteme %d" % [ps.resource_path.get_file(), ", ".join(z), tl])
	return ("Einstellbar: " + ", ".join(z) if not z.is_empty() else "Einstellbar: nur Stoffe/Partikel") + " · %d Partikelsysteme" % tl


## Größe am Schirm: Ausdehnung aller sichtbaren Teile (m) gegen den Helden (1,8 m)
func _messen(name_: String, fx: Node) -> void:
	var box := AABB()
	var erst := true
	for g in fx.find_children("*", "VisualInstance3D", true, false) + ([fx] if fx is VisualInstance3D else []):
		var a: AABB = (g as VisualInstance3D).global_transform * (g as VisualInstance3D).get_aabb()
		box = a if erst else box.merge(a)
		erst = false
	print("572 Größe %s: %.2f x %.2f x %.2f m (Held 1,8 m), Mitte %.2f m über Boden" % [name_, box.size.x, box.size.y, box.size.z, box.get_center().y - held.global_position.y])


## setzt den Farbton aller farbigen Werte (Sättigung über 0,15) auf [ton]; gibt die Zahl der gesetzten zurück
func _faerben(fx: Node, ton: float) -> int:
	var n := 0
	for g in fx.find_children("*", "VisualInstance3D", true, false):
		if g is GeometryInstance3D and g.material_override:
			var r := _stoff(g.material_override, ton)
			g.material_override = r[0]
			n += r[1]
		if g is MeshInstance3D and g.mesh:
			for i in g.mesh.get_surface_count():
				var m: Material = g.get_active_material(i)
				if m:
					var r := _stoff(m, ton)
					g.set_surface_override_material(i, r[0])
					n += r[1]
		if g is GPUParticles3D:
			if g.process_material:
				var r := _stoff(g.process_material, ton)
				g.process_material = r[0]
				n += r[1]
			for i in g.draw_passes:
				var me: Mesh = g.get("draw_pass_%d" % (i + 1))
				if me:
					me = me.duplicate()
					for s in me.get_surface_count():
						var m := me.surface_get_material(s)
						if m:
							var r := _stoff(m, ton)
							me.surface_set_material(s, r[0])
							n += r[1]
					g.set("draw_pass_%d" % (i + 1), me)
		if g is Light3D:
			g.light_color = _ton(g.light_color, ton)
			n += 1
		if g is CPUParticles3D:
			g.color = _ton(g.color, ton)
			n += 1
			if g.color_ramp:
				g.color_ramp = _verlauf(g.color_ramp, ton)
				n += 1
	return n


func _stoff(m: Material, ton: float) -> Array:
	m = m.duplicate(true)
	var n := 0
	if m is BaseMaterial3D:
		m.albedo_color = _ton(m.albedo_color, ton)
		m.emission = _ton(m.emission, ton)
		n += 2
	elif m is ParticleProcessMaterial:
		m.color = _ton(m.color, ton)
		n += 1
		for k in ["color_ramp", "color_initial_ramp"]:
			var t = m.get(k)
			if t is GradientTexture1D and t.gradient:
				t.gradient = _verlauf(t.gradient, ton)
				n += 1
	elif m is ShaderMaterial and m.shader:
		for u in m.shader.get_shader_uniform_list():
			var v = m.get_shader_parameter(u.name)
			if v is Color:
				m.set_shader_parameter(u.name, _ton(v, ton))
				n += 1
			elif v is GradientTexture1D or v is GradientTexture2D:
				var t = v.duplicate()
				t.gradient = _verlauf(t.gradient, ton)
				m.set_shader_parameter(u.name, t)
				n += 1
	if m.next_pass:
		var r := _stoff(m.next_pass, ton)
		m.next_pass = r[0]
		n += r[1]
	return [m, n]


func _verlauf(g: Gradient, ton: float) -> Gradient:
	g = g.duplicate()
	for i in g.get_point_count():
		g.set_color(i, _ton(g.get_color(i), ton))
	return g


func _ton(c: Color, ton: float) -> Color:
	if c.s < 0.15:
		return c
	var d := c
	d.h = ton
	return d


func _seite() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	var r: Vector3 = cam.global_transform.basis.x if cam else Vector3.RIGHT
	r.y = 0.0
	return r.normalized()


func _wolf():
	var best = null
	var d := 1e9
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null and not f.down and f.visible and f.global_position.distance_to(held.global_position) < d:
			d = f.global_position.distance_to(held.global_position)
			best = f
	return best


func _bild() -> void:
	if bilder_ordner == "":
		return
	await RenderingServer.frame_post_draw
	nr += 1
	DirAccess.make_dir_recursive_absolute(bilder_ordner)
	var p := "%s/%02d-%s.png" % [bilder_ordner, nr, jetzt.replace(" ", "_")]
	get_viewport().get_texture().get_image().save_png(p)
	print("572 BILD %s" % p)


func _process(_dt: float) -> void:
	if lb == null:
		return
	var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var dr := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	lb.text = "572 Effektprobe · %s · Glow %s\n%d Bilder/s (Bauserver) · %d Zeichenaufrufe · %dk Dreiecke · %s" % [
		jetzt if jetzt != "" else "–", "an" if glow else "aus", Engine.get_frames_per_second(), dc, dr / 1000,
		RenderingServer.get_current_rendering_method()]


func _oberflaeche() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 100
	add_child(cl)
	var vs := get_viewport().get_visible_rect().size
	lb = Label.new()
	lb.position = Vector2(vs.x * 0.04, vs.y * 0.03)
	lb.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 15.0))
	lb.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
	lb.add_theme_color_override("font_outline_color", Color.BLACK)
	lb.add_theme_constant_override("outline_size", int(vs.x / 412.0 * 4.0))
	cl.add_child(lb)
	lb2 = Label.new()
	lb2.position = Vector2(vs.x * 0.04, vs.y * 0.9)
	lb2.size = Vector2(vs.x * 0.92, vs.y * 0.09)
	lb2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb2.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 11.0))
	lb2.add_theme_color_override("font_outline_color", Color.BLACK)
	lb2.add_theme_constant_override("outline_size", int(vs.x / 412.0 * 3.0))
	cl.add_child(lb2)


## wie strahlprobe.gd: wartet, bis der Kampf auf einen Zug der Gruppe wartet (höchstens 20 s), hält ihn an, dann bis alle still stehen
func _kampf_ruht() -> void:
	var t := 0.0
	while t < 20.0:
		if not kf.busy and not kf.playing and kf.beats.is_empty() and (kf.mars.outcome != "ONGOING" or not kf.mars.pilot_next()):
			break
		await get_tree().process_frame
		t += get_process_delta_time()
	kf.busy = true
	var alt := {}
	var ruhig := 0.0
	t = 0.0
	while t < 10.0 and ruhig < 1.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var weit := 0.0
		for id in kf.figures:
			var p: Vector3 = kf.figures[id].global_position
			if alt.has(id):
				weit = maxf(weit, p.distance_to(alt[id]))
			alt[id] = p
		ruhig = ruhig + dt if weit < 0.02 * dt else 0.0
