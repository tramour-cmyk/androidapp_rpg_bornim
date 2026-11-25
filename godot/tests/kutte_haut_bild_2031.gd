extends SceneTree
# 2031 Beleg: Kutte und Haeute alt gegen neu, Renderer wie am Handy (mobile), Bildschirm 540x1170 (wie kopfteil_bild_2029.gd).
#   <fall>_spiel.png: die echte Erschaffung (ErschaffungBrs), Klosterschueler bzw. Wachsoldat, Held angehalten (Drehung 25 Grad, „Stehen“ 0,4 s)
#   <fall>_vorn.png, _seite.png, _hieb.png: Ganzfigur (Spielfigur, Toon-Licht, Tusche, Schatten); _gesicht.png: Gesicht vorn;
#   _gesicht_ork.png: dieselbe Wahl als Orkbluetiger (Sokrates 22:57)
#   MARKE-Zeilen: Mitte des Stuecks im Bildschirm (Pfeil neben der Figur, kutte_haut_bild_2031.sh), DREIECKE-Zeilen: sichtbare Dreiecke
# kutte: Mensch Mann Klosterschueler; alt1 Novizenkutte (wie main), alt2 Robe (Gegenstand robe, Schrankteil ROBE), neu MH_KUTTE (Schalter)
# haut_m / haut_w: Mensch Mann / Frau Wachsoldat; alt Kaufhaut, neu drei MakeHuman-Haeute (Schalter HeldFigur.mh_haut)
# Aufruf: AUS=<ordner> [NUR=kutte|haut] godot --path . --rendering-method mobile --resolution 540x1170 -s res://tests/kutte_haut_bild_2031.gd
const DREH := 25.0
const ZEIT := 0.4
const Pruef = preload("res://tests/kutte_haut_2031.gd")
var aus := OS.get_environment("AUS")

func _initialize() -> void: _lauf.call_deferred()

func faelle() -> Array:
	var l := []
	var nur := OS.get_environment("NUR")
	if nur in ["", "kutte"]:
		for wie in [["alt1", {}, ""], ["alt2", {}, "robe"], ["neu", {"novice_habit": "MH_KUTTE"}, ""]]:
			l.append({"name": "kutte_" + wie[0], "volk": "Mensch", "g": "m", "herkunft": "Klosterschüler", "mh": wie[1], "brust": wie[2],
				"ansichten": ["vorn", "seite", "hieb"], "marke": "spine_02"})
	if nur in ["", "haut"]:
		for g in ["m", "w"]:
			for h in ["alt"] + Array(HeldFigur.MH_HAUT_WAHL.get(g.to_upper(), [])):
				l.append({"name": "haut_%s_%s" % [g, h], "volk": "Mensch", "g": g, "herkunft": "Wachsoldat", "haut": "" if h == "alt" else h,
					"ansichten": ["vorn", "gesicht", "gesicht_ork"], "marke": "Head"})
	return l

func _lauf() -> void:
	if aus == "" or not HeldFigur.da():
		print("KHBILD2031 ohne AUS oder ohne Kaufmodelle"); quit(0); return
	DirAccess.make_dir_recursive_absolute(aus)
	Sprache.lang = "de"
	for f in faelle():
		_schalter(f)
		var e := ErschaffungBrs.new()
		root.add_child(e)
		await process_frame
		e.volk_waehlen(String(f["volk"]))
		e.herkunft_waehlen(String(f["herkunft"]))
		e.geschlecht_waehlen(String(f["g"]))
		for i in 2: await process_frame
		var w := _wahl(e.wahl_jetzt(), f)
		e.teller.zeige(w)
		for i in 3: await process_frame
		var t := e.teller
		t.dreht = false
		t.teller.rotation.y = deg_to_rad(DREH)
		_pose(t.teller)
		for i in 4: await process_frame
		await RenderingServer.frame_post_draw
		var p := aus.path_join("%s_spiel.png" % f["name"])
		root.get_texture().get_image().save_png(p)
		var held := t.teller.get_child(0) as Node3D
		_marke(p, t, String(f["marke"]))
		print("BILD ", p, " Modell ", held.get_meta("tracht", "-"), " Teile ", _teile(held))
		print("DREIECKE %s %d" % [f["name"], _dreiecke(held)])
		e.queue_free()
		await process_frame
		for ansicht in f["ansichten"]:
			await _ausschnitt(w, f, ansicht)
		HeldFigur.mh_probe = {}
		HeldFigur.mh_haut = ""
	print("KHBILD2031 fertig")
	quit(0)

func _schalter(f: Dictionary) -> void:
	HeldFigur.mh_probe = f.get("mh", {})
	HeldFigur.mh_haut = String(f.get("haut", ""))

func _wahl(w: Dictionary, f: Dictionary) -> Dictionary:
	w = w.duplicate(true)
	if String(f.get("brust", "")) != "":
		var st: Dictionary = (w["ausruestung"].get("CHEST", {}) as Dictionary).duplicate()
		st["base"] = f["brust"]
		w["ausruestung"]["CHEST"] = st
	return w

func _teile(m: Node) -> String:
	var l := []
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		if (mi as MeshInstance3D).is_visible_in_tree(): l.append(String(mi.name))
	return ",".join(l)

# sichtbare Dreiecke der Figur (alle sichtbaren Netze)
static func _dreiecke(m: Node) -> int:
	var n := 0
	for x in m.find_children("*", "MeshInstance3D", true, false):
		var mi := x as MeshInstance3D
		if not mi.is_visible_in_tree() or mi.mesh == null: continue
		for s in mi.mesh.get_surface_count():
			var a := mi.mesh.surface_get_arrays(s)
			n += (a[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3 if a[Mesh.ARRAY_INDEX] != null else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return n

func _marke(p: String, t: Drehteller, knochen: String) -> void:
	var held := t.teller.get_child(0) as Node3D
	var sk := Gebiet.finde(held, "Skeleton3D") as Skeleton3D
	var vp := t.get_child(0) as SubViewport
	var cam := vp.get_camera_3d()
	var tf := t.get_viewport().get_final_transform() * t.get_global_transform_with_canvas()
	var f := t.size / Vector2(vp.size)
	var o := (sk.global_transform * sk.get_bone_global_pose(sk.find_bone(knochen))).origin
	var k := tf * (cam.unproject_position(o) * f)
	print("MARKE %s %d %d" % [p.get_file(), k.x, k.y])

func _pose(n: Node) -> void:
	for ap in n.find_children("*", "AnimationPlayer", true, false):
		var a := ap as AnimationPlayer
		if a.current_animation == "": continue
		a.seek(ZEIT, true)
		a.pause()

# Ganzfigur bzw. Gesicht: Spielfigur mit Toon-Licht, Tusche und Schatten am Boden (wie kopfteil_bild_2029 _ausschnitt)
func _ausschnitt(w: Dictionary, f: Dictionary, ansicht: String) -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(400, 600) if not ansicht.begins_with("gesicht") else Vector2i(400, 400)
	sv.own_world_3d = true
	sv.msaa_3d = Viewport.MSAA_4X
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sv)
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.background_mode = Environment.BG_COLOR
	welt.environment.background_color = Color(0.05, 0.045, 0.04)
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	sv.add_child(welt)
	var sonne := DirectionalLight3D.new()
	sonne.light_color = Color(1.0, 0.92, 0.8)
	sonne.rotation_degrees = Vector3(-40, -30 + (60.0 if ansicht == "seite" else 0.0), 0)
	sonne.shadow_enabled = true
	sv.add_child(sonne)
	var boden := MeshInstance3D.new()   # Schatten unter dem Koerper
	var pm := PlaneMesh.new(); pm.size = Vector2(4, 4)
	boden.mesh = pm
	var bm := StandardMaterial3D.new(); bm.albedo_color = Color(0.22, 0.2, 0.17)
	boden.material_override = bm
	sv.add_child(boden)
	_schalter(f)
	if ansicht == "gesicht_ork":   # Sokrates 22:57: Zeile „Gesicht Orkbluetiger“, sonst gleiche Wahl
		w = w.duplicate(true)
		w["volk"] = "HALF_ORC"
	var mats := []
	var m := HeldFigur.baue(w, mats)
	for x in mats:
		(x as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(x as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var hieb := ansicht == "hieb"
	if hieb: Pruef.hieb_dazu(m)
	if ap:
		if hieb and ap.has_animation("Hieb"): ap.play("Hieb")
		elif ap.has_animation("Stehen"): ap.play("Stehen")
	sv.add_child(m)
	if ansicht == "seite": m.rotation.y = PI / 2.0   # Blick nach rechts im Bild
	if hieb: m.rotation.y = deg_to_rad(35.0)
	for k in 3: await process_frame
	if hieb and ap and ap.has_animation("Hieb"):
		ap.seek(ap.get_animation("Hieb").length * 0.999, true)
		ap.pause()
	else: _pose(sv)
	for k in 3: await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var kam := Camera3D.new()
	if ansicht.begins_with("gesicht"):
		var kopf := (sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head"))).origin + Vector3(0, 0.07, 0)
		kam.fov = 22.0
		kam.position = kopf + Vector3(0, 0.02, 1.1)
		sv.add_child(kam)
		kam.look_at(kopf, Vector3.UP)
	else:
		var mitte := Vector3(0, 0.88, 0)
		kam.fov = 30.0
		kam.position = mitte + Vector3(0, 0.25, 4.2)
		sv.add_child(kam)
		kam.look_at(mitte, Vector3.UP)
	for k in 4: await process_frame
	await RenderingServer.frame_post_draw
	var p := aus.path_join("%s_%s.png" % [f["name"], ansicht])
	sv.get_texture().get_image().save_png(p)
	print("BILD ", p)
	HeldFigur.mh_probe = {}
	HeldFigur.mh_haut = ""
	sv.queue_free()
	await process_frame
