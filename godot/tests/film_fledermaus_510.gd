# 510 (Chef 03.11., 10:28–10:57, aus 494): die freie Fledermaus (OGA „Vampire Bat (Animated)“, rubberduck, CC0;
# tools/blender348/oga_fledermaus.py) neben unserer eigenen (fledermaus.py, abgenommen 348.7), beide mit unseren Fellen, Toon,
# Tusche nach Licht und Schatten wie im Kampf (signatur.gd). Chef 10:57: „einen kurzen Film oder mehrere Ansichten … Wie soll ich denn
# die Idle-Bewegung beurteilen?“: je vorhandene Bewegung ein Abschnitt, beide drehen sich darin einmal ganz (alle Seiten); erst alle
# Bewegungen im braunen Fell, dann Ruhe im schwarzen und grauen. Links unsere, rechts die freie. Bewegungen nur, wie vorhanden (10:45);
# was einer fehlt, steht als „fehlt“ im Bild.
# Aufruf (Bild, Probelauf nach 389): PROBE=510 xvfb-run godot --path godot --resolution 1920x1080 --write-movie <datei>.avi --fixed-fps 30
#   -s res://tests/film_fledermaus_510.gd        MESS=1 ohne Bild: lädt beide, nennt Bewegungen und Maße (kein Probelauf)
extends SceneTree

const Figur = preload("res://kampf/figur.gd")
const Signatur = preload("res://kampf/signatur.gd")
const D := "res://kampf/daten/"
const ABSTAND := 2.3          # m zwischen den beiden
const ABSCHNITT_S := 6.0      # je Bewegung, eine ganze Drehung
const FELL_S := 4.0           # Ruhe in den anderen Fellen
const BLENDE_BILDER := 8
# Abschnitte: Titel, unsere Bewegung, Suchwörter für die freie (Namen aus bat_v5.blend, im Log „AKTION“)
const PAARE := [["Ruhe (Schweben)", "Stehen", ["idle"]], ["Fliegen", "Gehen", ["fly"]], ["Biss", "Biss", ["attack", "bite"]],
	["Treffer", "Treffer", ["hit", "hurt", "damage"]], ["Tod", "Tod", ["die", "death", "dead"]]]

var mess := OS.get_environment("MESS") != ""
var schwarz: ColorRect
var lt: Label
var ll: Label
var lr: Label
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _lade(p: String) -> Node3D:
	if not FileAccess.file_exists(p):
		print("FEHLER 510: %s fehlt" % p)
		fehler += 1
		return null
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) != OK:
		print("FEHLER 510: %s nicht lesbar" % p)
		fehler += 1
		return null
	return doc.generate_scene(st) as Node3D


func _male(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var m := ShaderMaterial.new()
			m.shader = Figur.toon_gegner()     # Gegner: Schablone 3 wie im Kampf (348.13a)
			var tex: Texture2D = null
			var c := Color.WHITE
			if src is BaseMaterial3D:
				tex = (src as BaseMaterial3D).albedo_texture
				c = (src as BaseMaterial3D).albedo_color
			if tex == null:
				var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
				img.fill(c)
				tex = ImageTexture.create_from_image(img)
			m.set_shader_parameter("tex", tex)
			mi.set_surface_override_material(i, m)
	for k in n.get_children():
		_male(k)


func _aabb(n: Node3D) -> AABB:
	var a := AABB()
	var erst := true
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var b: AABB = (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb()
		a = b if erst else a.merge(b)
		erst = false
	return a


func _ap(n: Node) -> AnimationPlayer:
	var r := n.find_children("*", "AnimationPlayer", true, false)
	return r[0] as AnimationPlayer if r.size() > 0 else null


func _name(ap: AnimationPlayer, woerter: Array) -> String:
	if ap == null:
		return ""
	for a in ap.get_animation_list():
		for w in woerter:
			if String(a).to_lower().contains(w):
				return a
	return ""


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


func _spiele(ap: AnimationPlayer, nm: String, t: float) -> void:
	# schleifend, was schleift (Stehen, Gehen, Idle, Fly); Einmaliges nach 0,6 s Pause von vorn (Biss, Tod)
	if ap == null or nm == "":
		return
	var a := ap.get_animation(nm)
	var lang := a.length
	var schleife := a.loop_mode != Animation.LOOP_NONE or nm in ["Stehen", "Gehen"] or nm.to_lower().contains("idle") or nm.to_lower().contains("fly")
	var pos := fmod(t, lang) if schleife else minf(fmod(t, lang + 0.6), lang)
	if ap.current_animation != nm:
		ap.play(nm, 0.0)
	ap.seek(pos, true)


func _run() -> void:
	var welt := Node3D.new()
	root.add_child(welt)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.06, 0.055, 0.05)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.55, 0.52, 0.48)
	env.environment.ambient_light_energy = 0.6
	welt.add_child(env)
	var sonne := DirectionalLight3D.new()
	welt.add_child(sonne)
	# Boden wie Waldboden, Toon, damit der Schlagschatten unter dem Körper liegt (A4)
	var boden := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(14, 10)
	boden.mesh = pm
	var bm := ShaderMaterial.new()
	bm.shader = load("res://kampf/toon.gdshader")
	var bi := Image.create(4, 4, false, Image.FORMAT_RGB8)
	bi.fill(Color(0.24, 0.21, 0.16))
	bm.set_shader_parameter("tex", ImageTexture.create_from_image(bi))
	boden.material_override = bm
	welt.add_child(boden)
	var felle := ["braun", "schwarz", "grau"]
	var paare := {}     # fell -> [unsere, freie] (je ein Dreher mit Modell)
	var info := {}
	for fell in felle:
		var reihe := []
		for k in 2:
			var p := D + ("giant_bat-%s.bin" if k == 0 else "oga_bat-%s.bin") % fell
			var m := _lade(p)
			var dreher := Node3D.new()
			dreher.position = Vector3((-0.5 if k == 0 else 0.5) * ABSTAND, 0, 0)
			welt.add_child(dreher)
			if m != null:
				_male(m)
				dreher.add_child(m)
			dreher.visible = false
			reihe.append(dreher)
		paare[fell] = reihe
	await process_frame
	# Höhe: die freie so hoch wie unsere (Mitte der Hülle); unsere schwebt wie im Kampf (fledermaus.py KOPF)
	for fell in felle:
		var u: Node3D = paare[fell][0]
		var f: Node3D = paare[fell][1]
		if u.get_child_count() == 0 or f.get_child_count() == 0:
			continue
		var au := _aabb(u)
		var af := _aabb(f)
		var m: Node3D = f.get_child(0)
		m.position.y += (au.position.y + au.size.y * 0.5) - (af.position.y + af.size.y * 0.5)
		af = _aabb(f)
		info[fell] = "unsere %.2f m breit, %.2f m hoch, %.2f–%.2f m über dem Boden; freie %.2f m breit, %.2f m hoch, %.2f–%.2f m" % [
			maxf(au.size.x, au.size.z), au.size.y, au.position.y, au.end.y, maxf(af.size.x, af.size.z), af.size.y, af.position.y, af.end.y]
		print("MASS %s %s" % [fell, info[fell]])
	var apu := _ap(paare["braun"][0])
	var apf := _ap(paare["braun"][1])
	print("BEWEGUNGEN unsere %s" % (apu.get_animation_list() if apu else "keine"))
	print("BEWEGUNGEN freie %s" % (apf.get_animation_list() if apf else "keine"))
	var abschnitte := []     # [titel, fell, unsere, freie, dauer]
	var gezeigt := []
	for p in PAARE:
		var u := String(p[1]) if apu and apu.has_animation(p[1]) else ""
		var f := _name(apf, p[2])
		if f != "":
			gezeigt.append(f)
		if u == "" and f == "":
			continue
		abschnitte.append([p[0], "braun", u, f, ABSCHNITT_S])
	if apf:
		for a in apf.get_animation_list():     # was die freie sonst noch hat
			if not String(a) in gezeigt and not String(a).to_lower().begins_with("reset"):
				abschnitte.append([String(a), "braun", "", String(a), ABSCHNITT_S])
	for fell in ["schwarz", "grau"]:
		abschnitte.append(["Ruhe (Schweben)", fell, "Stehen", _name(_ap(paare[fell][1]), ["idle"]), FELL_S])
	for a in abschnitte:
		print("ABSCHNITT %s · %s · unsere %s · freie %s" % [a[0], a[1], a[2] if a[2] != "" else "fehlt", a[3] if a[3] != "" else "fehlt"])
	if mess:
		print("Film 510 Messung: %d Befunde" % fehler)
		quit(1 if fehler > 0 else 0)
		return
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 2.7
	var mitte := Vector3(0, 0.75, 0)
	cam.look_at_from_position(mitte + Vector3(0, 1.2, 3.0).normalized() * 8.0, mitte)     # etwa 22° von oben
	welt.add_child(cam)
	cam.current = true
	Signatur.einrichten(welt, cam, mitte, env.environment, sonne, false)
	var deck := CanvasLayer.new()
	deck.layer = 128
	schwarz = ColorRect.new()
	schwarz.color = Color.BLACK
	schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
	schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deck.add_child(schwarz)
	root.add_child(deck)
	var cl := CanvasLayer.new()
	cl.layer = 10
	root.add_child(cl)
	var vs: Vector2 = root.get_visible_rect().size
	lt = _label(cl, Vector2(vs.x * 0.03, vs.y * 0.03), int(vs.y / 18.0), Color(0.95, 0.82, 0.45))
	ll = _label(cl, Vector2(vs.x * 0.06, vs.y * 0.86), int(vs.y / 30.0), Color(0.92, 0.88, 0.80))
	lr = _label(cl, Vector2(vs.x * 0.56, vs.y * 0.86), int(vs.y / 30.0), Color(0.92, 0.88, 0.80))
	await process_frame
	if not Signatur.wache(welt, self, "Fledermaus-Film 510"):
		return
	var bilder := 0
	for a in abschnitte:
		var fell: String = a[1]
		for f in felle:
			for d in paare[f]:
				d.visible = f == fell
		var u: Node3D = paare[fell][0]
		var fr: Node3D = paare[fell][1]
		lt.text = "%s · Fell %s" % [a[0], fell]
		ll.text = "unsere: %s" % (a[2] if a[2] != "" else "fehlt")
		lr.text = "frei (OGA, CC0): %s" % (a[3] if a[3] != "" else "fehlt")
		var n := int(float(a[4]) * 30.0)
		for i in n:
			var t := float(i) / 30.0
			var w := TAU * float(i) / n
			u.rotation.y = w
			fr.rotation.y = w
			_spiele(_ap(u), a[2], t)
			_spiele(_ap(fr), a[3], t)
			if i == 0:
				await _blende(0.0)
			elif i == n - BLENDE_BILDER:
				await _blende(1.0)
				break
			else:
				await process_frame
			bilder += 1
	print("Film 510 fertig: %d Abschnitte, %d Bilder" % [abschnitte.size(), bilder])
	quit(0)
