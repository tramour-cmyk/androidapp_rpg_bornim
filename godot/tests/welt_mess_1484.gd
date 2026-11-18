extends SceneTree
# 1484 (Tablet 17.11., 21:29–21:31: Wald 11/19 22 Bilder/s, Flüsterwald 10 Bilder/s, keiner der vier Schalter hilft): am Rechner je Ort
# die Grafikzeit (GPU) je Baustein wie „Kampf messen“ (806), aber in der Welt: alles an, ohne Tusche, ohne Schatten, 3D 70 %, je Stoff
# des großen Netzes billig (unbeleuchtet), Netz aus, Gras aus, Bildschirm (2D) aus. Lavapipe rechnet auf dem Prozessor: nur das
# Verhältnis zählt, nicht die Zahl. Ohne Bild. Aufruf im Ordner godot (Fenster nötig, Renderer des Handys):
#   xvfb-run … godot --rendering-driver vulkan --rendering-method mobile --path . --resolution 540x1170 -s res://tests/welt_mess_1484.gd -- --ort1484=forest:9:12

var spiel
var vp: Viewport


func _initialize() -> void: _lauf.call_deferred()


func _mess(s: float) -> float:
	for i in 10: await process_frame
	var g := 0.0
	var n := 0
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < s * 1000.0:
		await process_frame
		g += RenderingServer.viewport_get_measured_render_time_gpu(vp.get_viewport_rid())
		n += 1
	return g / maxf(n, 1)


func _lauf() -> void:
	var ort := "forest:9:12"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ort1484="): ort = a.get_slice("=", 1)
	var o := ort.split(":")
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete(o[0], Vector2i(int(o[1]), int(o[2])), "DOWN")
	await create_timer(2.0).timeout
	for i in 80:
		if not spiel.ui.spricht() and spiel.szene.is_empty(): break
		spiel.ui.naechste()
		await process_frame
	Herde.beachten_nicht = true
	vp = root.get_viewport()
	RenderingServer.viewport_set_measure_render_time(vp.get_viewport_rid(), true)
	await _warte(2.0)
	var basis := await _mess(3.0)
	var zeilen := ["MESS1484 %s alles an: %.1f ms GPU, %d Aufrufe, %dk Dreiecke" % [ort, basis,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000]]
	var schritt := func(name: String, aus: Callable, an: Callable) -> void:
		aus.call()
		var w: float = await _mess(2.0)
		an.call()
		zeilen.append("MESS1484 %s %s: %.1f ms (%+.1f)" % [ort, name, w, w - basis])
	await schritt.call("ohne Tusche", func(): Testmodus.ohne_tusche = true; Testmodus.leistung_anwenden(self),
		func(): Testmodus.ohne_tusche = false; Testmodus.leistung_anwenden(self))
	await schritt.call("ohne Schatten", func(): Testmodus.ohne_schatten = true; Testmodus.leistung_anwenden(self),
		func(): Testmodus.ohne_schatten = false; Testmodus.leistung_anwenden(self))
	var skala := vp.scaling_3d_scale
	await schritt.call("3D 70 %%", func(): vp.scaling_3d_scale = skala * 0.7, func(): vp.scaling_3d_scale = skala)
	await schritt.call("3D 50 %%", func(): vp.scaling_3d_scale = skala * 0.5, func(): vp.scaling_3d_scale = skala)   # 1484a: Füllrate gegen Dreiecke
	# große Netze (über 20k Dreiecke): je Stoff billig, dann ganz aus
	var billig := StandardMaterial3D.new()
	billig.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for m in root.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree(): continue
		var dr := 0
		for s in mi.mesh.get_surface_count():
			var arr := mi.mesh.surface_get_arrays(s)
			var idx = arr[Mesh.ARRAY_INDEX]
			dr += (idx.size() if idx != null else (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
		if dr < 20000: continue
		zeilen.append("MESS1484 %s Netz %s: %dk Dreiecke, %d Stoffe" % [ort, mi.name, dr / 1000, mi.mesh.get_surface_count()])
		# Durchsicht (gebiet.gd durchsicht: TIEFE und DURCH als next_pass an Laub und Rinde, über die ganze Karte)
		var ketten := {}
		for s in mi.mesh.get_surface_count():
			var sm := mi.get_active_material(s) as ShaderMaterial
			if sm and sm.next_pass: ketten[sm] = sm.next_pass
		if not ketten.is_empty():
			await schritt.call("ohne Durchsicht-Durchgänge %s (%d Stoffe)" % [mi.name, ketten.size()],
				func(): for k in ketten: k.next_pass = null, func(): for k in ketten: k.next_pass = ketten[k])
		if "--nur_durchsicht" in OS.get_cmdline_user_args(): continue
		for s in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(s)
			var nm := "%s/%d %s" % [mi.name, s, (mat.resource_name if mat and mat.resource_name != "" else (mat.get_class() if mat else "-"))]
			var alt := mi.get_surface_override_material(s)
			await schritt.call("Stoff billig " + nm, func(): mi.set_surface_override_material(s, billig), func(): mi.set_surface_override_material(s, alt))
		await schritt.call("Netz aus " + mi.name, func(): mi.visible = false, func(): mi.visible = true)
	var mm: Array = root.find_children("*", "MultiMeshInstance3D", true, false).filter(func(x): return x.is_visible_in_tree())
	await schritt.call("ohne Gras und Vielfache (%d)" % mm.size(), func(): for x in mm: x.visible = false, func(): for x in mm: x.visible = true)
	var gp: Array = root.find_children("*", "GPUParticles3D", true, false).filter(func(x): return x.is_visible_in_tree())
	await schritt.call("ohne Teilchen (%d)" % gp.size(), func(): for x in gp: x.visible = false, func(): for x in gp: x.visible = true)
	var cl: Array = root.find_children("*", "CanvasLayer", true, false).filter(func(x): return x.visible)
	await schritt.call("ohne Bildschirm 2D (%d)" % cl.size(), func(): for x in cl: x.visible = false, func(): for x in cl: x.visible = true)
	for z in zeilen: print(z)
	quit()


func _warte(s: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < s * 1000.0:
		await process_frame
