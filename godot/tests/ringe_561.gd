extends SceneTree
# 561 ohne Bild: Zug- und Zielringe liegen als Band am Boden in der Welt (kampf_ui _ringe_bauen), damit die Figur davor sie
# verdeckt; solange der Held am Zug ist, liegt sein Ring da, nach dem Kampf keiner. Aufruf: im Ordner godot mit -s res://tests/ringe_561.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const LIMIT_MS := 60000

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Engine.time_scale = 30.0
	var f := 0
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("FEHLER nicht gestartet"); quit(1); return
	await process_frame
	await process_frame
	var k = a.kampf
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS and (k.busy or k.playing or not k.beats.is_empty() or k.verhuellt):
		await process_frame
	for i in 3:
		await process_frame
	var r = k.get_node_or_null("Ringe")
	var n: int = r.mesh.get_surface_count() if r != null else -1
	var ecken: int = (r.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() if n > 0 else 0
	print("am Zug: Held %s, Ringe da %s, Flächen %d, Ecken %d" % [k.mars.current() == k.mars.lead(), r != null, n, ecken])
	if r == null or n != 1 or ecken != 2 * 40 * 6:
		f += 1
	if r != null and not (r is MeshInstance3D and r.material_override.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED and not r.material_override.no_depth_test):
		f += 1
		print("FEHLER Ringe ohne Tiefentest oder schattiert")
	k.test_end(true)
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS and (k.mars.outcome == "ONGOING" or k.busy or k.playing or not k.beats.is_empty()):
		await process_frame
	for i in 3:
		await process_frame
	var n2: int = r.mesh.get_surface_count() if r != null and is_instance_valid(r) else 0
	print("nach dem Kampf: Flächen %d" % n2)
	if n2 != 0:
		f += 1
	print("RINGE 561 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
