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
# Wetter: der WeatherController3D schreibt in Umgebung und Sonne und laesst sie beim Freigeben so (Lauf 298: Nebel blieb an);
# darum bekommt er eine Kopie der Umgebung, und die Sonne und neue Kinder der Kamera werden zurueckgesetzt
var umwelt_alt: Dictionary = {}
var sonne_alt: Dictionary = {}
var kamera_kinder: Array[Node] = []
var kamera_gemerkt := false

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
	for z in zusatz:
		if is_instance_valid(z) and z.has_method("clear"): z.call("clear")
		if is_instance_valid(z): z.set_process(false)
	for z in zusatz: if is_instance_valid(z): z.queue_free()
	zusatz.clear()
	for we in umwelt_alt: if is_instance_valid(we): (we as WorldEnvironment).environment = umwelt_alt[we]
	umwelt_alt.clear()
	for su in sonne_alt:
		if not is_instance_valid(su): continue
		for k in sonne_alt[su]: (su as Node).set(k, sonne_alt[su][k])
	sonne_alt.clear()
	var kam := sp.get_viewport().get_camera_3d()
	if kam and kamera_gemerkt:   # 623.6 Probe-APK: nur was das Wetter an die Kamera haengte, nie die Tusche des Spiels
		for k in kam.get_children(): if not kamera_kinder.has(k): k.queue_free()
	kamera_gemerkt = false
	var g: Gebiet = sp.gebiet
	for m in unser_gras: if is_instance_valid(m): m.visible = true
	unser_gras.clear()
	if g and g.wasser:
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
	if not we.is_empty():
		var w0 := we[0] as WorldEnvironment
		if not umwelt_alt.has(w0): umwelt_alt[w0] = w0.environment
		if w0.environment: w0.environment = w0.environment.duplicate(true)
		c.set("world_environment", w0)
	var su := sp.find_children("*", "DirectionalLight3D", true, false)
	if not su.is_empty():
		var s0 := su[0] as DirectionalLight3D
		if not sonne_alt.has(s0):
			sonne_alt[s0] = {}
			for k in ["light_color", "light_energy", "rotation", "shadow_enabled", "visible"]: sonne_alt[s0][k] = s0.get(k)
		c.set("sun", s0)
	var kam := sp.get_viewport().get_camera_3d()
	kamera_kinder.clear()
	if kam: kamera_kinder.assign(kam.get_children())
	kamera_gemerkt = true
	sp.add_child(c)
	zusatz.append(c)
	if c.has_method("set_weather"): c.call("set_weather", pr)
	print("WELT623 Wetter %s (Umgebung %d, Sonne %d)" % [was, we.size(), su.size()])

# Stylized Surface Shaders: Felsen des Demos am Weg mit Runen (Glut, gruen), Schnee, Eis, Lava, vor dem Helden,
# je knapp 1 m gross auf dem Boden in Hoehe der Fuesse des Helden (Lauf 298: 0,6 m, schwebend auf Hoehe 0 des Gebiets)
func flaechen() -> void:
	var mats := ["arcane_energy/runes_ember", "arcane_energy/runes_verdant", "ice/snow_moonlit", "ice/ice_lake", "fire/lava_cooling"]
	var netze := ["stone_block", "rock_a", "rock_b", "rock_a", "rock_b"]
	var vor: Vector3 = sp.held.global_position
	for i in mats.size():
		var mp := FLAECHE + "materials/%s.tres" % mats[i]
		var np := FLAECHE + "demo_meshes/%s.obj" % netze[i]
		if not ResourceLoader.exists(mp) or not ResourceLoader.exists(np): print("WELT623 FEHLT ", mp, " ", np); continue
		var mi := MeshInstance3D.new()
		mi.mesh = load(np)
		mi.material_override = load(mp)
		var w := deg_to_rad(-60.0 + 30.0 * i)
		var a := mi.mesh.get_aabb()
		var s := 0.9 / maxf(0.01, maxf(a.size.x, maxf(a.size.y, a.size.z)))
		mi.scale = Vector3.ONE * s
		sp.gebiet.add_child(mi)
		zusatz.append(mi)
		mi.global_position = vor + Vector3(sin(w), 0, -cos(w)) * 2.4
		mi.global_position.y = vor.y - a.position.y * s
	print("WELT623 Oberflaechen gesetzt")

# ---------------------------------------------------------------- 623.6 Probe-APK (Chef 08.11., 17:05: „Ja, Probe-APK für Welt und
# Effekte zusammen.“): im Spiel umschaltbar (Testmenü, Gruppe „Welt“, Reihe „Proben 623.6“), wirkt am Ort des Helden und nach jedem
# Ortswechsel neu; ohne Kits im Bau bleibt alles unsere Fassung. Aus dem Urteil zu Lauf 301 (Chef 16:56, 17:02): Wasser nur „klar“
# (Toon ausgeschlossen), Regen nur das Regenmodul ohne Nebel, mit Blitz und Donner; Gras mit den Fassungen der Gratisprobe.
const WASSER_WAHL := ["", "pond_clear"]
const GRAS_WAHL := ["", "grass_spring", "grass_summer"]
const REGEN_SCHICHTEN := ["rain", "splash", "ripples"]   # layers_3d der Gratisprobe ohne fog, mist, sky
static var wasser_wahl := ""
static var gras_wahl := ""
static var regen_an := false
static var flaechen_an := false
static var im_spiel: WeltProbe
var blitz: Timer

static func kits_da() -> bool:
	return DirAccess.dir_exists_absolute(GRAS) or DirAccess.dir_exists_absolute(WASSER) or DirAccess.dir_exists_absolute(WETTER) or DirAccess.dir_exists_absolute(FLAECHE)

static func probe_an() -> bool:
	return wasser_wahl != "" or gras_wahl != "" or regen_an or flaechen_an

## nach dem Betreten eines Orts und nach jedem Umschalten im Testmenü (spiel.gd betrete, test_tat „welt623“)
static func im_spiel_neu(s: Node) -> void:
	if not kits_da() and not probe_an(): return
	if im_spiel == null or im_spiel.sp != s:
		im_spiel = WeltProbe.new()
		im_spiel.sp = s
	if s.gebiet == null: return
	im_spiel.zuruecksetzen()
	if wasser_wahl != "": im_spiel.wasser(wasser_wahl)
	if gras_wahl != "": im_spiel.gras(gras_wahl)
	if flaechen_an: im_spiel.flaechen()
	if regen_an: im_spiel.regen()
	else: s.klang("schleife_stellen", ["probe_regen", "rain", 0.0])

## nächste Fassung („wasser“, „gras“) oder an/aus („regen“, „flaechen“)
static func schalte(was: String) -> void:
	match was:
		"wasser": wasser_wahl = WASSER_WAHL[(WASSER_WAHL.find(wasser_wahl) + 1) % WASSER_WAHL.size()]
		"gras": gras_wahl = GRAS_WAHL[(GRAS_WAHL.find(gras_wahl) + 1) % GRAS_WAHL.size()]
		"regen": regen_an = not regen_an
		"flaechen": flaechen_an = not flaechen_an

static func name_von(was: String, de: bool) -> String:
	match was:
		"wasser": return ("unser" if de else "ours") if wasser_wahl == "" else ("Paket klar" if de else "pack clear")
		"gras":
			if gras_wahl == "": return "unser" if de else "ours"
			return ("Paket Frühling" if de else "pack spring") if gras_wahl == "grass_spring" else ("Paket Sommer" if de else "pack summer")
		"regen": return ("an" if de else "on") if regen_an else ("aus" if de else "off")
		"flaechen": return ("an" if de else "on") if flaechen_an else ("aus" if de else "off")
	return ""

## Regen (Chef 16:56: „Regen bitte mal einfach ohne Nebel, sondern nur das Regenmodul nehmen … Regen und Blitz und Donner gerne mal
## auch testen, aber vielleicht ohne diese graue Nebelsuppe“): das Preset rain mit nur den Schichten rain, splash, ripples; Nebel der
## Umgebung wie bei uns; Blitz alle 9 bis 22 s (strike des Kits), Donner aus unseren Aufnahmen 0,6 bis 2,5 s danach, Regen als Schleife
func regen() -> void:
	var c_p := WETTER + "weather_controller_3d.gd"
	var pr_p := WETTER + "presets/3d/rain.tres"
	if not ResourceLoader.exists(c_p) or not ResourceLoader.exists(pr_p): print("WELT623 FEHLT Wetter"); return
	var pr: Resource = (load(pr_p) as Resource).duplicate(true)
	var schichten = pr.get("layers")
	if schichten is Dictionary:
		var nur := {}
		for k in schichten:
			if String(k) in REGEN_SCHICHTEN: nur[k] = schichten[k]
		print("WELT623 Regen: Schichten %s, behalten %s" % [schichten.keys(), nur.keys()])
		if not nur.is_empty(): pr.set("layers", nur)
	var c: Node3D = (load(c_p) as GDScript).new()
	c.set("start_weather", pr)
	c.set("transition_time", 0.0)
	var we := sp.find_children("*", "WorldEnvironment", true, false)
	var eigen: Environment = null
	if not we.is_empty():
		var w0 := we[0] as WorldEnvironment
		if not umwelt_alt.has(w0): umwelt_alt[w0] = w0.environment
		eigen = umwelt_alt[w0]
		if w0.environment: w0.environment = w0.environment.duplicate(true)
		c.set("world_environment", w0)
	var su := sp.find_children("*", "DirectionalLight3D", true, false)
	if not su.is_empty():
		var s0 := su[0] as DirectionalLight3D
		if not sonne_alt.has(s0):
			sonne_alt[s0] = {}
			for k in ["light_color", "light_energy", "rotation", "shadow_enabled", "visible"]: sonne_alt[s0][k] = s0.get(k)
		c.set("sun", s0)
	var kam := sp.get_viewport().get_camera_3d()
	kamera_kinder.clear()
	if kam: kamera_kinder.assign(kam.get_children())
	kamera_gemerkt = true
	sp.add_child(c)
	zusatz.append(c)
	if c.has_method("set_weather"): c.call("set_weather", pr)
	sp.klang("schleife_stellen", ["probe_regen", "rain", 0.45])
	# kein Nebel: die Umgebung behaelt unseren Nebel, auch wenn das Kit ihn je Bild schreibt
	blitz = Timer.new()
	blitz.wait_time = 0.5
	blitz.autostart = true
	var naechster := [Time.get_ticks_msec() + randi_range(4000, 9000)]
	var w_ := we[0] as WorldEnvironment if not we.is_empty() else null
	blitz.timeout.connect(func():
		if w_ and w_.environment and eigen:
			w_.environment.fog_enabled = eigen.fog_enabled
			w_.environment.volumetric_fog_enabled = eigen.volumetric_fog_enabled
		if Time.get_ticks_msec() < naechster[0]: return
		naechster[0] = Time.get_ticks_msec() + randi_range(9000, 22000)
		if c.has_method("strike") and _ohne_pflicht(c, "strike"): c.call("strike")
		var nach := randf_range(0.6, 2.5)
		sp.get_tree().create_timer(nach).timeout.connect(func(): if is_instance_valid(sp): sp.klang("effekt", ["thunder", 0.7])))
	sp.add_child(blitz)
	zusatz.append(blitz)
	print("WELT623 Regen mit Blitz und Donner")

## hat die Methode keine Pflichtargumente (strike des Kits ist nicht beschrieben)
static func _ohne_pflicht(o: Object, m: String) -> bool:
	for d in o.get_method_list():
		if String(d["name"]) == m: return (d["args"] as Array).size() <= (d["default_args"] as Array).size()
	return false
