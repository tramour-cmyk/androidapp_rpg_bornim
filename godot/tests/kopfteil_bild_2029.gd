extends SceneTree
# 2029 Beleg: je Art (haar, bart, helm) alt gegen neu, Renderer wie am Handy (mobile), Bildschirm 540x1170.
#   <art>_<alt|neu>_spiel.png: die echte Erschaffung (ErschaffungBrs), Herkunft Wachsoldat, Held angehalten (Drehung 25 Grad, „Stehen“ 0,4 s)
#   <art>_<alt|neu>_vorn.png, _seite.png: Kopfausschnitt vorn und von der Seite (Spielfigur, Toon-Licht, Tusche, wie voelker_bild_431 Reihen)
#   MARKE-Zeilen: Kopf im Bildschirm (fuer den Pfeil neben dem Kopf, kopfteil_bild_2029.sh)
# haar: Elf Mann, alt Hair_Long, neu Haar_MH01; bart: Zwerg Mann, alt Bart_Breit,Hair_Moustache, neu Bart_Wikinger,Hair_Moustache;
# helm: Mensch Mann, alt great_helm (Schrankteil KNIGHT_HELM), neu helmet mit Helm_Templer (aussehen „helm“)
# nacken (2029 Teil 2, ARTEN=nacken): Mensch Mann mit helmet (Helm_Templer), alt (ohne Frisur unter dem Helm wie 685a45298, Schalter
#   HeldFigur.nacken „alt“), A (kurze Frisur darunter, Vorgabe), B (Nackenschirm); Held von hinten schraeg (DREH_NACKEN), Ausschnitte
#   vorn, Seite, hinten; MARKE nacken: Nacken im Bild (Kopfknochen + 3 cm, hinten) fuer den Pfeil
# Aufruf: [ARTEN=haar,bart,helm,nacken] AUS=<ordner> godot --path . --rendering-method mobile --resolution 540x1170 -s res://tests/kopfteil_bild_2029.gd
const DREH := 25.0
const ZEIT := 0.4
const FAELLE := {
	"haar": {"volk": "Elf", "g": "m", "alt": {"frisur": "Hair_Long"}, "neu": {"frisur": "Haar_MH01"}},
	"bart": {"volk": "Zwerg", "g": "m", "alt": {"bart": "Bart_Breit,Hair_Moustache"}, "neu": {"bart": "Bart_Wikinger,Hair_Moustache"}},
	"helm": {"volk": "Mensch", "g": "m", "alt": {"kopf": "great_helm"}, "neu": {"kopf": "helmet", "helm": "Helm_Templer"}},
	"nacken": {"volk": "Mensch", "g": "m", "alt": {"kopf": "helmet", "nacken": "alt"}, "A": {"kopf": "helmet", "nacken": "A"}, "B": {"kopf": "helmet", "nacken": "B"}},
}
const DREH_NACKEN := 150.0
var aus := OS.get_environment("AUS")

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if aus == "" or not HeldFigur.da():
		print("KOPFTEILBILD2029 ohne AUS oder ohne Kaufmodelle"); quit(0); return
	DirAccess.make_dir_recursive_absolute(aus)
	Sprache.lang = "de"
	var arten := OS.get_environment("ARTEN").split(",", false) if OS.get_environment("ARTEN") != "" else PackedStringArray(["haar", "bart", "helm"])
	for art in arten:
		for wie in (["alt", "A", "B"] if art == "nacken" else ["alt", "neu"]):
			var f: Dictionary = FAELLE[art]
			HeldFigur.nacken = String((f[wie] as Dictionary).get("nacken", "A"))
			var e := ErschaffungBrs.new()
			root.add_child(e)
			await process_frame
			e.volk_waehlen(String(f["volk"]))
			e.geschlecht_waehlen(String(f["g"]))
			for i in 2: await process_frame
			var w := wahl(e.wahl_jetzt(), f[wie])
			e.teller.zeige(w)
			for i in 3: await process_frame
			var t := e.teller
			t.dreht = false
			t.teller.rotation.y = deg_to_rad(DREH_NACKEN if art == "nacken" else DREH)
			_pose(t.teller)
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			var p := aus.path_join("%s_%s_spiel.png" % [art, wie])
			root.get_texture().get_image().save_png(p)
			_marke(p, t, art == "nacken")
			print("BILD ", p, " Modell ", t.teller.get_child(0).get_meta("tracht", "-"), " Kopf ", _kopf(t.teller.get_child(0)))
			e.queue_free()
			await process_frame
			for ansicht in (["vorn", "seite", "hinten"] if art == "nacken" else ["vorn", "seite"]):
				await _ausschnitt(w, art, wie, ansicht)
			HeldFigur.nacken = "A"
	print("KOPFTEILBILD2029 fertig")
	quit(0)

func wahl(w: Dictionary, x: Dictionary) -> Dictionary:
	w = w.duplicate(true)
	for k in x:
		if k == "nacken": continue
		if k == "kopf":
			var st: Dictionary = (w["ausruestung"].get("CHEST", {}) as Dictionary).duplicate()
			st["base"] = x[k]
			w["ausruestung"]["HEAD"] = st
		else: w["aussehen"][k] = x[k]
	return w

func _kopf(m: Node) -> String:
	var l := []
	for ba in m.find_children("Haar_*", "BoneAttachment3D", true, false): l.append(String(ba.name).substr(5))
	for mi in m.find_children("Teil_*", "MeshInstance3D", true, false): if (mi as MeshInstance3D).is_visible_in_tree(): l.append(String(mi.name))
	return ",".join(l)

func _marke(p: String, t: Drehteller, nacken := false) -> void:
	var held := t.teller.get_child(0) as Node3D
	var sk := Gebiet.finde(held, "Skeleton3D") as Skeleton3D
	var vp := t.get_child(0) as SubViewport
	var cam := vp.get_camera_3d()
	var tf := t.get_viewport().get_final_transform() * t.get_global_transform_with_canvas()
	var f := t.size / Vector2(vp.size)
	var kopf := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head"))
	var k := tf * (cam.unproject_position(kopf.origin + Vector3(0, 0.08, 0)) * f)
	print("MARKE %s kopf %d %d" % [p.get_file(), k.x, k.y])
	if nacken:
		var n := tf * (cam.unproject_position(kopf * Vector3(0, 0.03, -0.09)) * f)
		print("MARKE %s nacken %d %d" % [p.get_file(), n.x, n.y])

func _pose(n: Node) -> void:
	for ap in n.find_children("*", "AnimationPlayer", true, false):
		var a := ap as AnimationPlayer
		if a.current_animation == "": continue
		a.seek(ZEIT, true)
		a.pause()

# Kopfausschnitt: Spielfigur mit Toon-Licht und Tusche (wie voelker_bild_431 _reihe), Kamera vor bzw. neben dem Kopf
func _ausschnitt(w: Dictionary, art: String, wie: String, ansicht: String) -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(540, 540)
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
	var mats := []
	var m := HeldFigur.baue(w, mats)
	for x in mats:
		(x as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(x as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	if ap and ap.has_animation("Stehen"): ap.play("Stehen")
	sv.add_child(m)
	if ansicht == "seite": m.rotation.y = PI / 2.0   # Blick nach rechts im Bild
	if ansicht == "hinten": m.rotation.y = PI
	for k in 3: await process_frame
	_pose(sv)
	for k in 3: await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var kopf := (sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head"))).origin + Vector3(0, 0.07, 0)
	if art == "bart": kopf.y -= 0.05
	var kam := Camera3D.new()
	kam.fov = 26.0
	kam.position = kopf + Vector3(0, 0.02, 1.25)
	sv.add_child(kam)
	kam.look_at(kopf, Vector3.UP)
	for k in 4: await process_frame
	await RenderingServer.frame_post_draw
	var p := aus.path_join("%s_%s_%s.png" % [art, wie, ansicht])
	sv.get_texture().get_image().save_png(p)
	print("BILD ", p)
	if art == "nacken":   # Nacken im Ausschnitt (Kopfknochen + 3 cm, hinten)
		var nk := kam.unproject_position(sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head")) * Vector3(0, 0.03, -0.09))
		print("MARKE %s nacken %d %d" % [p.get_file(), nk.x, nk.y])
	sv.queue_free()
	await process_frame
