extends SceneTree
# 1211 (Prüfauftrag Chef 13.11., 19:10: „Prüfe auch mal, ob wir Rocket Trail nicht als Lichtquelle verwenden können für den Trank“):
# Probe als Film, wie im Spiel (spiel.tscn, Spielkamera, Renderer mobile): der Held geht nachts mit Leuchtfunke durchs Dorf.
# --art1211=heute  Funke wie im Spiel (nach 1211: rocket_trail gedämpft, sonst Kern und Hof)
# --art1211=alt    Kern und Hof wie bis 17.11.
# --art1211=kuehl  R7 rocket_trail statt Kern und Hof: kühl weiß (FUNKE_FARBE), gedämpft, ohne Rauch und ohne eigenes Licht; Licht bleibt funke_licht
# --art1211=r7     R7 rocket_trail unverändert (warm, Rauch, eigenes Licht), nur auf Funkengröße, zum Vergleich
# --mess1211=1     ohne Film: misst Bilder/s, Zeichenaufrufe und Dreiecke beim Gehen (Lavapipe, nur Vergleich untereinander)
# Braucht addons/reeboo_vfx aus dem Kaufrepo (REEBOO_Stylized_VFX_v2.0.zip), nie committen.
# Aufruf im Ordner godot:
#   xvfb-run … godot --rendering-driver vulkan --rendering-method mobile --path . --resolution 540x1170 --write-movie a.avi
#     --fixed-fps 30 -s res://tests/film_funke_1211.gd -- --art1211=kuehl

var spiel
var art := "heute"
var mess := false
var licht := ""     # Chef 17.11., 23:56 („Ja, das wäre hilfreich“): --licht1211=abc: in der Höhle nacheinander A heute, B Abfall 1,0 und 8 m,
                    # C wie B mit Stärke 2,0, dann die Fackel wie heute (Funke aus)
var ort := "dorf"   # Chef 17.11., 21:49: „noch ein Film in Höhle mit alter leuchtkugel und rockettrail kühl, u. Licht und Ausleuchtung zu sehen“


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--art1211="): art = a.get_slice("=", 1)
		if a == "--mess1211=1": mess = true
		if a.begins_with("--ort1211="): ort = a.get_slice("=", 1)
		if a.begins_with("--licht1211="): licht = a.get_slice("=", 1)
	_lauf.call_deferred()


func _warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame


func _durch() -> void:
	for i in 80:
		if not spiel.ui.spricht() and spiel.szene.is_empty(): return
		spiel.ui.naechste()
		await process_frame


func _geh(r: Vector3, s: float) -> void:
	for i in int(s * 30.0):
		spiel.held.richtung = r * 0.6
		await process_frame
	spiel.held.richtung = Vector3.ZERO


func _farbe(t: float, a: float) -> Color:
	var f: Color = Held.FUNKE_FARBE
	return Color(lerpf(1.0, f.r, t), lerpf(1.0, f.g, t), lerpf(1.0, f.b, t), a)


func _verlauf(farben: Array) -> GradientTexture1D:
	var g := Gradient.new()
	var off := PackedFloat32Array()
	var col := PackedColorArray()
	for i in farben.size():
		off.append(float(i) / float(farben.size() - 1))
		col.append(farben[i])
	g.offsets = off
	g.colors = col
	var t := GradientTexture1D.new()
	t.gradient = g
	return t


func _baue_r7(kuehl: bool) -> void:
	var h = spiel.held
	var fx: Node3D = load("res://addons/reeboo_vfx/effects/rocket_trail.tscn").instantiate()
	fx.auto_free = false
	fx.scale = Vector3.ONE * 0.5          # Funke ist klein (Kern 0,6–1,0), R7 ist für eine Rakete gebaut
	if kuehl:
		for n in ["Light", "Smoke"]:          # Licht bleibt funke_licht (kühl, Tusche nach Licht); ein Lichtfunke raucht nicht
			var weg := fx.get_node(n)
			fx.remove_child(weg)
			weg.free()
		var kern: GPUParticles3D = fx.get_node("Core")
		(kern.process_material as ParticleProcessMaterial).color_ramp = _verlauf([_farbe(0.3, 0.9), _farbe(1.0, 0.9)])
		(kern.material_override as ShaderMaterial).set_shader_parameter("emission_energy", 0.8)
		var glanz: GPUParticles3D = fx.get_node("Flare")
		(glanz.process_material as ParticleProcessMaterial).color_ramp = _verlauf([_farbe(0.5, 0.6), _farbe(1.0, 0.0)])
		(glanz.material_override as ShaderMaterial).set_shader_parameter("emission_energy", 1.0)
		var schweif: GPUParticles3D = fx.get_node("Flames")
		schweif.amount = 24
		(schweif.process_material as ParticleProcessMaterial).color_ramp = _verlauf([_farbe(0.2, 0.9), _farbe(1.0, 0.7), Color(0.55, 0.62, 0.8, 0.35), Color(0.3, 0.35, 0.5, 0.0)])
		var sm := schweif.material_override as ShaderMaterial
		sm.set_shader_parameter("emission_energy", 0.9)
		sm.set_shader_parameter("edge_color", Color(0.45, 0.55, 0.9, 1))
		var funken: GPUParticles3D = fx.get_node("Sparks")
		funken.amount = 8
		var fp := funken.process_material as ParticleProcessMaterial
		fp.initial_velocity_min = 0.4
		fp.initial_velocity_max = 1.2
		fp.color_ramp = _verlauf([_farbe(0.0, 1.0), _farbe(1.0, 0.8), Color(0.5, 0.6, 0.9, 0.0)])
		(funken.material_override as ShaderMaterial).set_shader_parameter("emission_energy", 2.0)
		h.funke_kern.visible = false
		h.funke_hof.visible = false
	else:
		h.funke_kern.visible = false
		h.funke_hof.visible = false
	h.funke.add_child(fx)


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5:
		await process_frame
	spiel.zustand.minuten = 23 * 60
	if ort == "hoehle": spiel.betrete("cave", Vector2i(11, 15), "UP")   # Mittelgang der Blutzahnhöhle: Wände dicht, kein Feuer in der Nähe
	else: spiel.betrete("village", Vector2i(19, 13), "RIGHT")
	await create_timer(1.5).timeout
	await _durch()
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	Herde.beachten_nicht = true
	if ort == "hoehle": Testmodus.alles_sichtbar = true   # Prüfgegenstand ist das Licht, nicht der Nebel
	spiel.zustand.funke = true
	for i in 5:
		await process_frame
	if art == "alt" and spiel.held.funke_r7:   # nach 1211: alt = Kern und Hof wie bis 17.11., neu = wie im Spiel (rocket_trail gedämpft)
		spiel.held.funke_r7.queue_free(); spiel.held.funke_r7 = null
		spiel.held.funke_kern.visible = true; spiel.held.funke_hof.visible = true
	elif art in ["kuehl", "r7"]:
		if spiel.held.funke_r7: spiel.held.funke_r7.queue_free(); spiel.held.funke_r7 = null
		_baue_r7(art == "kuehl")
	if art == "r7":   # funke_licht aus, R7 bringt eigenes Licht; richte_funke setzt es sonst jedes Bild wieder an
		spiel.held.funke_licht.light_color = Color.BLACK
	spiel.kamera.zoom = 6.0
	spiel.kamera.springe()
	print("FILM1211 Art %s, Funke %s, Uhr %d" % [art, spiel.held.funke_an, spiel.zustand.minuten])
	await _warte(1.0)
	var t0 := Time.get_ticks_usec()
	var b0 := Engine.get_frames_drawn()
	var zeichen := 0
	var dreiecke := 0
	var n := 0
	if licht == "abc":
		await _abc()
		quit()
		return
	var rs := [Vector3.RIGHT, Vector3.BACK, Vector3.LEFT, Vector3.FORWARD]
	if ort == "hoehle": rs = [Vector3.FORWARD, Vector3.FORWARD, Vector3.BACK, Vector3.BACK]   # durch den Gang hinauf und zurück
	for r in rs:
		for i in int(1.6 * 30.0):
			spiel.held.richtung = r * 0.6
			await process_frame
			zeichen += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			dreiecke += RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
			n += 1
		spiel.held.richtung = Vector3.ZERO
		await _warte(0.6)
	var dt := (Time.get_ticks_usec() - t0) / 1e6
	print("FILM1211 MESS %s: %.1f Bilder/s, %d Zeichenaufrufe, %d Dreiecke je Bild" % [art, (Engine.get_frames_drawn() - b0) / dt, zeichen / n, dreiecke / n])
	await _warte(1.0)
	quit()


# 1211 Film A/B/C: je Fassung den Gang hinauf und zurück (je 3,4 s), Schrift oben links
func _abc() -> void:
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	var titel := Label.new()
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	ebene.add_child(titel)
	var h = spiel.held
	var fassungen := [["A · Leuchtfunke heute", 2.2 * 1.05 / 1.35, 8.0 * 5.2 / 6.2, 2.0, false],
		["B · Abfall 1,0, Reichweite 8 m", 2.2 * 1.05 / 1.35, 8.0, 1.0, false],
		["C · wie B, Stärke 2,0", 2.0, 8.0, 1.0, false], ["Fackel wie heute", 0.0, 0.0, 0.0, true]]
	for f in fassungen:
		titel.text = String(f[0])
		var fackel: bool = f[4]
		spiel.zustand.funke = not fackel
		h.funke_neu(not fackel)
		if not fackel:
			h.funke_grund = float(f[1]); h.funke_licht.omni_range = float(f[2]); h.funke_licht.omni_attenuation = float(f[3])
		h.fackel_neu(fackel, false, true)
		print("FILM1211 ABC %s: Funke %s, Fackel %s" % [f[0], not fackel, fackel])
		for r in [Vector3.FORWARD, Vector3.BACK]:
			for i in int(1.7 * 30.0):
				h.richtung = r * 0.6
				await process_frame
		h.richtung = Vector3.ZERO
