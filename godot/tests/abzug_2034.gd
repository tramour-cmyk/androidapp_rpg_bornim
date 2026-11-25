extends SceneTree
# 2034 Teil 0 (Chef 25.11., 17:27; Sokrates 17:29): Abzug der MakeHuman-Stuecke in unserer Signatur, je Stueck ein Einzelbild.
# Jedes Stueck (.glb aus tools/blender348/v3/abzug_mh.py) mit dem Spiel-Shader wie der Held: toon.gdshader (Schablone 2, fill 0,42,
# kein Glanz: metall 0), Tusche nach Licht und Sonne mit Schatten wie im Kampfort (kampf/signatur.gd, 2034-Ue14), die Quelle als
# warme Lampe oben auf der Seite der Sonne (DESIGN-STIL Signatur 1), Umgebung kaltes Blauschwarz, Grund mit Lichthof (Chef 20:04: bleibt). Kamera orthogonal wie im Dorf, Stueck fuellt die Hoehe.
#   <nr>_vorn.png, <nr>_seite.png (2048x924): mit Tusche; Seite = Stueck 90 Grad gedreht, Blick nach rechts
#   SIGNATUR=1 dazu: <nr>_vorn_ohne.png (ohne Tusche), <nr>_vorn_weiss.png (Bild weiss, ohne Tusche: Lichtstufen),
#     <nr>_vorn_maske.png (Hintergrund durchsichtig, ohne Tusche: Umriss), ebenso _seite_*
#   MARKE <nr> <ansicht> px_je_m <wert>: Bildpunkte je Meter (Massstab im Rand, tools/godot/abzug_2034.sh)
#   LICHT <nr> <ansicht> x y: Richtung zur Sonne im Bild (Lichtseite fuer abzug_2034_signatur.py); TUSCHE: Werte der Linie im Lauf
# Aufruf: LISTE=<liste.json> GLB=<ordner> AUS=<ordner> [NUR=M29-04,...] [SIGNATUR=1] godot --path . --rendering-method mobile -s res://tests/abzug_2034.gd
# 2034-Ue14 (5): je Ansicht 2048 breit gerendert; tools/godot/abzug_2034.sh schneidet nach der Breite des Stuecks zu und teilt die
# 2048 Bildpunkte nach Bedarf auf (breites Stueck mehr Platz), damit auch breite Stuecke die Hoehe fuellen
const B := 2048
const H := 924
const GRUND := Color(0.035, 0.045, 0.075)        # kaltes Blauschwarz
const UMGEBUNG := Color(0.32, 0.36, 0.48)         # kaltes Streulicht im Schatten
# 2034-Ue14 (Chef 20:04: „beim Licht duenner, abgewandt dicker“; Planer Vera 20:07, DESIGN-STIL A2): Sonne und Tusche wie im Kampfort,
# gelesen aus kampf/signatur.gd (sonne_wie_kampf: SONNE_LICHT -45, 55, schraeg von der Seite; tusche_licht: Gruppe Schablone 2 mit
# px 0,8, dick 1,5, umriss_dick 1,3 = „Linienstaerke 1,3“ aus A2 / Chef 28.10. r9). Nicht abgeschrieben: aendert sich der Kampfort, folgt der Abzug.
const Sig := preload("res://kampf/signatur.gd")
# Paare (Stiefel, Handschuhe): in der Seitenansicht nur ein Stueck (Ruecklaeufer 2034-Ue14 (5), Pruefer 19:59 (3)); vorn beide
const PAARE := ["Stiefel", "Handschuhe"]
# 2034-Ue6 (Pruefer 18:42): dunkle Stuecke (Robe, Stiefel, Helligkeit 0,09-0,16) lagen auf GRUND, die Tusche war unsichtbar. Hinter dem
# Stueck eine kalte, unbeleuchtete Wand mit Lichthof: in der Mitte HOF (kaltes Graublau), nach aussen weich bis GRUND; das Stueck selbst
# bleibt unveraendert (nicht aufgehellt), die Tusche liegt am Umriss zwischen Stueck und hellerem Grund
const HOF := Color(0.25, 0.28, 0.36)
const HOF_INNEN := 0.45    # Halbmesser voll hell, Anteil der Bildhoehe
const HOF_AUSSEN := 0.95   # bis hier GRUND
const WAND := "shader_type spatial;\nrender_mode unshaded, cull_disabled, fog_disabled, shadows_disabled;\nuniform vec3 hof : source_color;\nuniform vec3 grund : source_color;\nuniform vec2 mitte;\nuniform float r0;\nuniform float r1;\nvarying vec3 w;\nvoid vertex() { w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }\nvoid fragment() { float d = length(w.xy - mitte); ALBEDO = mix(hof, grund, smoothstep(r0, r1, d)); }\n"
var aus := OS.get_environment("AUS")
var toon2: Shader
var weiss: ImageTexture

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var liste: Array = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("LISTE")))
	var glb := OS.get_environment("GLB")
	var nur := OS.get_environment("NUR").split(",", false)
	var probe := OS.get_environment("SIGNATUR") == "1"
	DirAccess.make_dir_recursive_absolute(aus)
	var t: Shader = load("res://shader/toon.gdshader")
	toon2 = Shader.new()
	toon2.code = t.code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, 2;")
	var wi := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	wi.fill(Color(1, 1, 1, 1))
	weiss = ImageTexture.create_from_image(wi)
	var n := 0
	for e in liste:
		var nr := String(e["nummer"])
		if nur.size() > 0 and nr not in nur: continue
		if String(e.get("glb", "")) == "" or not String(e["glb"]).ends_with(".glb"): continue
		var paar: bool = String(e.get("art", "")) in PAARE
		var gr := _groessen(glb.path_join(String(e["glb"])), paar, probe)
		for ansicht in ["vorn", "seite"]:
			var eins: bool = ansicht == "seite" and paar
			await _bild(glb.path_join(String(e["glb"])), nr, ansicht, "", true, false, false, eins, gr[ansicht])
			if probe:
				await _bild(glb.path_join(String(e["glb"])), nr, ansicht, "_ohne", false, false, false, eins, gr[ansicht])
				await _bild(glb.path_join(String(e["glb"])), nr, ansicht, "_weiss", false, true, false, eins, gr[ansicht])
				await _bild(glb.path_join(String(e["glb"])), nr, ansicht, "_maske", false, false, true, eins, gr[ansicht])
		n += 1
	print("ABZUG2034 fertig ", n)
	quit(0)

func _lade(p: String) -> Node3D:
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_file(p, st) != OK: return null
	return doc.generate_scene(st) as Node3D

func _male(n: Node, licht: Vector3, mit_weiss: bool) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i) as BaseMaterial3D
			var m := ShaderMaterial.new()
			m.shader = toon2
			var tex: Texture2D = src.albedo_texture if src else null
			var schnitt := src != null and src.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			if schnitt: m.set_shader_parameter("schnitt", src.alpha_scissor_threshold)
			if mit_weiss: tex = _weiss_wie(tex) if schnitt and tex else weiss   # Lichtstufen: Bild weiss, Alpha der Karten bleibt
			m.set_shader_parameter("tex", tex if tex else weiss)
			m.set_shader_parameter("fill", 0.42)       # wie der Held (klasse_figur)
			m.set_shader_parameter("metall", 0.0)      # Signatur 3: nur Gold glaenzt
			m.set_shader_parameter("licht_dir", licht)
			mi.set_surface_override_material(i, m)
	for c in n.get_children(): _male(c, licht, mit_weiss)

func _weiss_wie(t: Texture2D) -> Texture2D:
	var im := t.get_image()
	if im.is_compressed(): im.decompress()
	im.convert(Image.FORMAT_RGBA8)
	for y in im.get_height():
		for x in im.get_width(): im.set_pixel(x, y, Color(1, 1, 1, im.get_pixel(x, y).a))
	return ImageTexture.create_from_image(im)

# Paar: nur das rechte Stueck (Dreiecke mit Mitte x > 0; abzug_mh.py schiebt die Teile bis 2 cm Luft um x = 0 zusammen)
func _nur_eins(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var neu := ArrayMesh.new()
		for i in mi.mesh.get_surface_count():
			var ar: Array = mi.mesh.surface_get_arrays(i)
			var v: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var idx: PackedInt32Array = ar[Mesh.ARRAY_INDEX]
			if idx.is_empty():
				idx = PackedInt32Array(range(v.size()))
			var bleibt := PackedInt32Array()
			for t in range(0, idx.size(), 3):
				if (v[idx[t]].x + v[idx[t + 1]].x + v[idx[t + 2]].x) > 0.0:
					bleibt.append_array([idx[t], idx[t + 1], idx[t + 2]])
			ar[Mesh.ARRAY_INDEX] = bleibt
			neu.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, ar)
			neu.surface_set_material(i, mi.mesh.surface_get_material(i))
		mi.mesh = neu
	for c in n.get_children(): _nur_eins(c)

func _aabb(n: Node, a: AABB, erst: bool) -> Array:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var b := mi.global_transform * mi.get_aabb()
		a = b if erst else a.merge(b)
		erst = false
	for c in n.get_children():
		var r := _aabb(c, a, erst)
		a = r[0]; erst = r[1]
	return [a, erst]

# Kamerahoehe (m) je Ansicht: Stueck fuellt die Hoehe (Rand 4 %), wenn die Breite es zulaesst; die beiden Zuschnitte (Breite des
# Stuecks + 8 % der Bildhoehe) teilen sich 2048 Bildpunkte; passen sie nicht, werden beide Ansichten gleich verkleinert.
# Probe: links und rechts dieselbe Ansicht vorn (mit, ohne Tusche), dazu das Abzugsbild vorn|Seite aus denselben Bildern.
func _groessen(p: String, paar: bool, probe: bool) -> Dictionary:
	var g := {}
	var w := {}
	for ansicht in ["vorn", "seite"]:
		var m := _lade(p)
		if m == null: return {"vorn": 1.0, "seite": 1.0}
		if ansicht == "seite" and paar: _nur_eins(m)
		root.add_child(m)
		if ansicht == "seite": m.rotation.y = PI / 2.0
		var a: AABB = _aabb(m, AABB(), true)[0]
		m.queue_free()
		g[ansicht] = maxf(a.size.y, a.size.x * float(H) / float(B)) * 1.08
		w[ansicht] = a.size.x * float(H) / g[ansicht] + 0.08 * H
	var summe: float = w["vorn"] + w["seite"]
	if probe: summe = maxf(summe, w["vorn"] * 2.0)   # Probe: dieselben Bilder fuer vorn|vorn ohne und vorn|Seite
	var k := minf(1.0, float(B) / summe)
	for ansicht in g: g[ansicht] /= k
	return g

func _bild(p: String, nr: String, ansicht: String, art: String, tusche: bool, mit_weiss := false, maske := false, eins := false, groesse := 0.0) -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(B, H)
	sv.own_world_3d = true
	sv.msaa_3d = Viewport.MSAA_4X
	sv.transparent_bg = maske
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sv)
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.background_mode = Environment.BG_COLOR
	welt.environment.background_color = GRUND
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = UMGEBUNG
	welt.environment.ambient_light_energy = 0.5
	sv.add_child(welt)
	var sonne := DirectionalLight3D.new()
	Sig.sonne_wie_kampf(sonne, true)
	sv.add_child(sonne)
	var licht := Basis.from_euler(sonne.rotation).z   # zur Sonne wie Licht.richtung
	var m := _lade(p)
	if m == null:
		print("FEHLT ", p); sv.queue_free(); return
	if eins: _nur_eins(m)
	_male(m, licht, mit_weiss)
	sv.add_child(m)
	if ansicht == "seite": m.rotation.y = PI / 2.0   # Blick nach rechts im Bild
	await process_frame
	var a: AABB = _aabb(m, AABB(), true)[0]
	var kam := Camera3D.new()
	kam.projection = Camera3D.PROJECTION_ORTHOGONAL
	kam.keep_aspect = Camera3D.KEEP_HEIGHT
	kam.size = groesse if groesse > 0.0 else maxf(a.size.y, a.size.x * float(H) / float(B)) * 1.08   # _groessen
	var c := a.get_center()
	kam.position = Vector3(c.x, c.y, a.end.z + 2.0)
	kam.near = 0.05
	kam.far = a.size.z + 6.0
	sonne.directional_shadow_max_distance = kam.far   # Buehne 2-3 m statt Lichtung 40 m: Schattenkarte fein genug fuer kleine Stuecke
	sv.add_child(kam)
	# 2034-Ue14 nach Probe 3 (d0ed0dc33: Toon-Stufen 1 statt 3, weisses Stueck 0,98): Buehne ganz wie der Kampfort ueber
	# Sig.einrichten (Sonne, Tonwerte Filmic/Saettigung/Kontrast, Tusche nach Licht, Nachfuehren je Bild); nur die Linie der
	# Gruppe (Schablone 2) bleibt sichtbar, Welt (0) und Gegner (3) haben hier nichts
	var buehne := Node3D.new()
	sv.add_child(buehne)
	var sg = Sig.einrichten(buehne, kam, c, welt.environment, sonne, true)
	sonne.directional_shadow_max_distance = kam.far
	var ms: Array[ShaderMaterial] = sg.mats
	for q in kam.get_children():
		if q is MeshInstance3D and (not tusche or (q as MeshInstance3D).material_override != ms[1]): q.queue_free()
	if tusche:
		Sig.nachfuehren(ms, kam, sonne, c, Vector2(B, H), true)
		ms[1].render_priority = 126
		print("TUSCHE %s %s px %.2f dick %.2f umriss_dick %.2f sonne %s tonemap %d" % [nr, ansicht, ms[1].get_shader_parameter("px"), ms[1].get_shader_parameter("dick"), ms[1].get_shader_parameter("umriss_dick"), sonne.rotation_degrees, welt.environment.tonemap_mode])
	if not maske:   # 2034-Ue6: Wand mit Lichthof hinter dem Stueck (und hinter der Lampe)
		var wd := MeshInstance3D.new()
		var wq := QuadMesh.new(); wq.size = Vector2(kam.size * 4.0, kam.size * 4.0)
		wd.mesh = wq
		wd.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var wm := ShaderMaterial.new()
		var ws := Shader.new(); ws.code = WAND
		wm.shader = ws
		wm.set_shader_parameter("hof", HOF)
		wm.set_shader_parameter("grund", GRUND)
		wm.set_shader_parameter("mitte", Vector2(c.x, c.y))
		wm.set_shader_parameter("r0", kam.size * HOF_INNEN)
		wm.set_shader_parameter("r1", kam.size * HOF_AUSSEN)
		wd.material_override = wm
		wd.position = Vector3(c.x, c.y, a.position.z - 2.0)
		sv.add_child(wd)
	if not maske:   # sichtbare Quelle: warme Lampe oben links, hinter dem Stueck (verdeckt nie etwas)
		var la := MeshInstance3D.new()
		var sp := SphereMesh.new(); sp.radius = kam.size * 0.022; sp.height = kam.size * 0.044
		var lm := StandardMaterial3D.new()
		lm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		lm.albedo_color = Color(1.0, 0.78, 0.42)
		sp.material = lm
		la.mesh = sp
		la.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var seite_x := signf(licht.x) if absf(licht.x) > 0.05 else -1.0   # Lampe an der oberen Ecke des Stuecks auf der Seite der Sonne
		la.position = Vector3(c.x + seite_x * a.size.x / 2.0, c.y + minf(a.size.y / 2.0, kam.size * 0.46), a.position.z - 1.0)   # bleibt im Zuschnitt
		sv.add_child(la)
		var hof := MeshInstance3D.new()   # Schein um die Lampe
		var hs := SphereMesh.new(); hs.radius = kam.size * 0.05; hs.height = kam.size * 0.1
		var hm := StandardMaterial3D.new()
		hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		hm.albedo_color = Color(1.0, 0.62, 0.25, 0.25)
		hs.material = hm
		hof.mesh = hs
		hof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hof.position = la.position + Vector3(0, 0, -0.2)
		sv.add_child(hof)
	for k in 6: await process_frame
	await RenderingServer.frame_post_draw
	var ziel := aus.path_join("%s_%s%s.png" % [nr, ansicht, art])
	sv.get_texture().get_image().save_png(ziel)
	if art == "": print("LICHT %s %s %.4f %.4f" % [nr, ansicht, licht.x, licht.y])   # zur Sonne im Bild (x rechts, y oben)
	if art == "": print("MARKE %s %s px_je_m %.1f hoehe_m %.3f breite_m %.3f fuellt %.3f zuschnitt %d" % [nr, ansicht, float(H) / kam.size, a.size.y, a.size.x, a.size.y / kam.size, int(ceil(a.size.x * float(H) / kam.size + 0.08 * H))])
	print("BILD ", ziel)
	sv.queue_free()
	await process_frame
