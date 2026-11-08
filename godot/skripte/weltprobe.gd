class_name WeltProbe
extends RefCounted
# 623.6 (Chef 07.11., 623 B1, D; „jetzt“ 08.11., 13:48): Probe Welt mit den REEBOO-Gratisproben gegen unsere Fassung, vor dem Kauf.
# Die Kits liegen nur im Bau unter res://addons/ (godot.yml „REEBOO-Gratisproben“, Lizenz: nie ins Repo); fehlt eines, bleibt die
# Variante unsere. Je Ort aus Sicht des Helden (Spielkamera) mehrere Fassungen nebeneinander:
#   Dorfbach (Dorf 15/24):        unser Wasser | Water Kit „pond_toon“ | Water Kit „pond_clear“ | Water Kit und Regen (Weather FX)
#   Flüsterwald, Wiese (5/7):     unser Gras | Grass & Wind „Frühling“ | „Sommer“ | Gras und dichter Nebel (Weather FX)
#   Flüsterwald, Teich (6/15):    unser Wasser | Water Kit „pond_toon“
#   Flüsterwald, Ankunft (9/29):  ohne | Oberflächen: Runen (glut, grün), Schnee, Eis, Lava auf Felsen am Weg
# Je Fassung die Zeichenzeit (Mittel über 2 s, CPU und GPU des Bildschirms) und Aufrufe im Protokoll („WELT623 …“), am Bauserver nur
# zum Vergleich der Fassungen untereinander (Lavapipe, kein Handy).
# Aufruf: godot --path godot --resolution 540x1170 -- --welt623=<ordner>   (Probebild: je Ort ein Streifen <ort>.png)
#         mit --welt623film: dieselben Orte als Film (--write-movie), je Fassung 4 s, der Held geht ein Stück

const GRAS := "res://addons/grass_wind_kit/"
const WASSER := "res://addons/water_kit/"
const WETTER := "res://addons/weather_fx/"
const FLAECHE := "res://addons/reeboo_surfaces/"
const ORTE := {"dorfbach": "Dorfbach", "wiese": "Flüsterwald, Wiese", "teich": "Flüsterwald, Teich", "flaechen": "Flüsterwald, Weg"}

var sp: Node
var dir := ""
var film := false
var unser_gras: Array[MultiMeshInstance3D] = []
var zusatz: Array[Node] = []
var schild: Label

static func lauf(s: Node) -> void:
	var w := WeltProbe.new()
	w.sp = s
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--welt623="): w.dir = a.substr(10)
		if a == "--welt623film": w.film = true
	if w.dir == "": return
	await w.alle()

func alle() -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	sp.ui.mess.visible = false
	sp.ui.oben.visible = false
	sp.zustand.minuten = 11 * 60
	print("WELT623 Kits: Gras %s, Wasser %s, Wetter %s, Oberflächen %s" % [DirAccess.dir_exists_absolute(GRAS), DirAccess.dir_exists_absolute(WASSER),
		DirAccess.dir_exists_absolute(WETTER), DirAccess.dir_exists_absolute(FLAECHE)])
	var ebene := CanvasLayer.new(); ebene.layer = 50
	sp.add_child(ebene)
	schild = Label.new()
	schild.position = Vector2(16, 40)
	schild.add_theme_font_size_override("font_size", 24)
	schild.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42))
	schild.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	schild.add_theme_constant_override("outline_size", 6)
	ebene.add_child(schild)
	RenderingServer.viewport_set_measure_render_time(sp.get_viewport().get_viewport_rid(), true)
	await ort("village", Vector2i(15, 24), "UP", "dorfbach", [["unser Wasser", []], ["Water Kit · Teich Toon", ["wasser:pond_toon"]],
		["Water Kit · Teich klar", ["wasser:pond_clear"]], ["Water Kit · Regen", ["wasser:pond_toon", "wetter:rain"]]])
	await ort("forest", Vector2i(5, 7), "LEFT", "wiese", [["unser Gras", []], ["Grass & Wind · Frühling", ["gras:grass_spring"]],
		["Grass & Wind · Sommer", ["gras:grass_summer"]], ["Gras · dichter Nebel", ["gras:grass_spring", "wetter:dense_fog"]]])
	await ort("forest", Vector2i(6, 15), "LEFT", "teich", [["unser Wasser", []], ["Water Kit · Teich Toon", ["wasser:pond_toon"]]])
	await ort("forest", Vector2i(9, 29), "UP", "flaechen", [["ohne", []], ["Oberflächen · Runen, Schnee, Eis, Lava", ["flaeche"]]])
	print("WELT623 fertig")
	sp.get_tree().quit()

func ort(id: String, k: Vector2i, blick: String, name: String, fassungen: Array) -> void:
	sp.betrete(id, k, blick)
	var hd = sp.get("herde")
	if hd: hd.aus = true
	await sp.get_tree().create_timer(1.5).timeout
	var reihe: Array[Image] = []
	for f in fassungen:
		zuruecksetzen()
		for z in f[1]: anwenden(String(z))
		sp.held.setze(k, blick); sp.kamera.springe()
		schild.text = "%s · %s" % [ORTE.get(name, name), f[0]]
		sp.ui.textfeld.visible = false
		if film:
			sp.held.geh_zu(sp.held.position + sp.held.global_basis.z * 2.0)
		await sp.get_tree().create_timer(4.0 if film else 1.5).timeout
		await miss(name, String(f[0]))
		if not film:
			await RenderingServer.frame_post_draw
			var b := sp.get_viewport().get_texture().get_image(); b.convert(Image.FORMAT_RGBA8)
			reihe.append(b)
	zuruecksetzen()
	if not reihe.is_empty():
		var bb := reihe[0].get_width(); var hh := reihe[0].get_height()
		var ges := Image.create(bb * reihe.size(), hh, false, Image.FORMAT_RGBA8)
		for i in reihe.size(): ges.blit_rect(reihe[i], Rect2i(0, 0, bb, hh), Vector2i(bb * i, 0))
		ges.save_png("%s/%s.png" % [dir, name])
		print("BILD %s/%s.png" % [dir, name])

# Zeichenzeit im Mittel ueber 2 s
func miss(ort_: String, fassung: String) -> void:
	var vp := sp.get_viewport().get_viewport_rid()
	var cpu := 0.0; var gpu := 0.0; var n := 0
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 2000:
		await sp.get_tree().process_frame
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp); gpu += RenderingServer.viewport_get_measured_render_time_gpu(vp); n += 1
	print("WELT623 %s · %s: %d Bilder in 2 s, Zeichnen CPU %.2f ms, GPU %.2f ms, %d Aufrufe, %d Dreiecke" % [ort_, fassung, n, cpu / maxi(1, n), gpu / maxi(1, n),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)])

func zuruecksetzen() -> void:
	for z in zusatz: if is_instance_valid(z): z.queue_free()
	zusatz.clear()
	var g: Gebiet = sp.gebiet
	for m in unser_gras: if is_instance_valid(m): m.visible = true
	if g.wasser:
		for mi in g.find_children("*Wasser*", "MeshInstance3D", true, false):
			(mi as MeshInstance3D).material_override = null

func anwenden(z: String) -> void:
	var art := z.get_slice(":", 0); var was := z.get_slice(":", 1)
	match art:
		"wasser": wasser(was)
		"gras": gras(was)
		"wetter": wetter(was)
		"flaeche": flaechen()

# Water Kit: das Material des Kits (presets/lake, ShaderMaterial) auf unsere Wasserflaeche (Form und Tiefe bleiben unsere)
func wasser(was: String) -> void:
	var p := WASSER + "presets/lake/%s.tres" % was
	if not ResourceLoader.exists(p): print("WELT623 FEHLT ", p); return
	var mat := load(p) as Material
	var n := 0
	for mi in sp.gebiet.find_children("*Wasser*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).material_override = mat; n += 1
	print("WELT623 Wasser %s auf %d Flaechen" % [was, n])

# Grass & Wind: Buescheln des Kits an den Stellen unserer Halme (je vierter), unser Gras aus; der Held schiebt das Gras (WindPusher3D)
func gras(was: String) -> void:
	var mesh_p := GRAS + "meshes/grass_clump_medium.res"
	var mat_p := GRAS + "presets/%s.tres" % was
	if not ResourceLoader.exists(mesh_p) or not ResourceLoader.exists(mat_p): print("WELT623 FEHLT Gras"); return
	var mat := load(mat_p) as Material   # ShaderMaterial; braucht die globalen gw_* (godot.yml traegt sie bei welt=… ins Projekt ein)
	unser_gras.clear()
	var xf: Array[Transform3D] = []
	for mmi in sp.gebiet.find_children("*", "MultiMeshInstance3D", true, false):
		var m := mmi as MultiMeshInstance3D
		if m.material_override is ShaderMaterial and (m.material_override as ShaderMaterial).shader and String((m.material_override as ShaderMaterial).shader.resource_path).ends_with("halm.gdshader"):
			unser_gras.append(m)
			for i in range(0, m.multimesh.instance_count, 4): xf.append(m.global_transform * m.multimesh.get_instance_transform(i))
	for m in unser_gras: m.visible = false
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = load(mesh_p)
	mm.instance_count = xf.size()
	for i in xf.size():
		var t := xf[i]
		mm.set_instance_transform(i, Transform3D(Basis(Vector3.UP, fmod(i * 2.39996, TAU)), t.origin))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	if mat: mmi.material_override = mat
	sp.gebiet.add_child(mmi)
	zusatz.append(mmi)
	var pusher_p := GRAS + "wind/wind_pusher_3d.gd"
	if ResourceLoader.exists(pusher_p):
		var pu: Node3D = (load(pusher_p) as GDScript).new()
		sp.held.add_child(pu)
		zusatz.append(pu)
	print("WELT623 Gras %s: %d Bueschel, Material %s" % [was, xf.size(), mat.get_class() if mat else "aus dem Netz"])

# Weather FX: WeatherController3D mit einem Preset (WFXPreset), an unserer Umgebung und Sonne, die Kamera nimmt er selbst
func wetter(was: String) -> void:
	var c_p := WETTER + "weather_controller_3d.gd"
	var pr_p := WETTER + "presets/3d/%s.tres" % was
	if not ResourceLoader.exists(c_p) or not ResourceLoader.exists(pr_p): print("WELT623 FEHLT Wetter"); return
	var c: Node3D = (load(c_p) as GDScript).new()
	var pr = load(pr_p)
	c.set("start_weather", pr)
	c.set("transition_time", 0.0)
	var we := sp.find_children("*", "WorldEnvironment", true, false)
	if not we.is_empty(): c.set("world_environment", we[0])
	var su := sp.find_children("*", "DirectionalLight3D", true, false)
	if not su.is_empty(): c.set("sun", su[0])
	sp.add_child(c)
	zusatz.append(c)
	if c.has_method("set_weather"): c.call("set_weather", pr)
	print("WELT623 Wetter %s (Umgebung %d, Sonne %d)" % [was, we.size(), su.size()])

# Stylized Surface Shaders: Felsen des Demos am Weg mit Runen (Glut, gruen), Schnee, Eis, Lava, vor dem Helden
func flaechen() -> void:
	var mats := ["arcane_energy/runes_ember", "arcane_energy/runes_verdant", "ice/snow_moonlit", "ice/ice_lake", "fire/lava_cooling"]
	var netze := ["stone_block", "rock_a", "rock_b", "rock_a", "rock_b"]
	var vor: Vector3 = sp.held.position
	for i in mats.size():
		var mp := FLAECHE + "materials/%s.tres" % mats[i]
		var np := FLAECHE + "demo_meshes/%s.obj" % netze[i]
		if not ResourceLoader.exists(mp) or not ResourceLoader.exists(np): print("WELT623 FEHLT ", mp, " ", np); continue
		var mi := MeshInstance3D.new()
		mi.mesh = load(np)
		mi.material_override = load(mp)
		var w := deg_to_rad(-60.0 + 30.0 * i)
		mi.position = vor + Vector3(sin(w), 0, -cos(w)) * 2.2
		var a := mi.mesh.get_aabb()
		var s := 0.6 / maxf(0.01, maxf(a.size.x, maxf(a.size.y, a.size.z)))
		mi.scale = Vector3.ONE * s
		mi.position.y = -a.position.y * s
		sp.gebiet.add_child(mi)
		zusatz.append(mi)
	print("WELT623 Oberflaechen gesetzt")
