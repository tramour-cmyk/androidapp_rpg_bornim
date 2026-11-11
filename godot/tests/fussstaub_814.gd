extends SceneTree
# 814 Fund t277.5 (Chef 11.11., 20:21: „Ich finde das Staubwölkchen einfach nicht“) und t277.12 („Bis auf den Fußstaub“), dazu
# 16:14 („der Held steht direkt beim Hühnchen. Da passiert halt einfach wieder nichts“): Ursache nachstellen, ohne Bild. Der Held geht
# und rennt auf dem Erdweg vor dem Schlagbaum, am Tag (10:00) und am Abend (20:30); je Bild: Bewegung, Tempo, Schrittphase, Erde unter
# ihm; je Fussstaub: wo, und ob seine Teilchen ausstossen (emitting, one_shot, Menge, Lebenszeit, Groesse, Farbe nach daempfe); die
# Federn ebenso. Dazu, was das Skript der Vorlage an Schaltern hat (autoplay, play). Ausgabe „FUSS814 …“, Ende 0 (nur Messung).
# Ohne Pakete (kein KAUF_TOKEN): „ohne Pakete“ und Ende 0.
#   ~/godot/godot --headless --path . -s res://tests/fussstaub_814.gd

var spiel

func _initialize() -> void:
	_lauf.call_deferred()

func warte(n: int) -> void:
	for i in n: await process_frame

func _lauf() -> void:
	if not DorfEffekte.da():
		print("FUSS814 ohne Pakete, nichts zu messen")
		quit(0)
		return
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(5)
	for uhr in [10 * 60, 20 * 60 + 30]:
		spiel.zustand.minuten = uhr
		spiel.betrete("village", Vector2i(17, 5), "UP")
		await warte(10)
		if uhr > 12 * 60:
			spiel.licht.ziel = 0.75
			spiel.licht.stelle(0.75)
		var g: Gebiet = spiel.gebiet
		var fx: DorfEffekte = g.effekte
		if fx == null:
			print("FUSS814 %02d:%02d keine Effekte" % [uhr / 60, uhr % 60])
			continue
		print("FUSS814 %02d:%02d nacht_k %.2f, Kamera size %.2f" % [uhr / 60, uhr % 60, fx.nacht_k, spiel.kamera.get_viewport().get_camera_3d().size if spiel.kamera.get_viewport().get_camera_3d() else -1.0])
		for rennen in [false, true]:
			spiel.held.setze(Vector2i(17, 5), "UP")
			await warte(3)
			spiel.laufen_will = rennen
			var vor := _staub(fx).size()
			spiel.held.richtung = Vector3(0, 0, -1)
			var gezeigt := false
			for i in 75:
				await process_frame
				var jetzt := _staub(fx)
				if not gezeigt and jetzt.size() > vor:
					gezeigt = true
					print("FUSS814   erster Fussstaub im Bild %d" % i)
					_teilchen("Fussstaub (gleich)", jetzt[vor])
				var h: Held = spiel.held
				var cur: String = h.anim.current_animation if h.anim else ""
				if i % 5 == 0:
					print("FUSS814   Bild %d: %s, tempo_jetzt %.2f, Phase %.2f, tritt_ph %.2f, Erde %s, Kachel %s" % [i, cur, h.tempo_jetzt,
						Held.schritt_phase(h.anim.get_animation(cur), h.anim.current_animation_position) if h.anim and cur != "" else -1.0,
						fx.tritt_ph, fx.erde(h.global_position), h.kachel])
			spiel.held.richtung = Vector3.ZERO
			spiel.laufen_will = false
			await warte(5)
			var neu := _staub(fx).slice(vor)
			print("FUSS814 %s: %d Fussstaub in 2,5 s" % ["Rennen" if rennen else "Gehen", neu.size()])
			if not neu.is_empty():
				_teilchen("Fussstaub (danach)", neu[0])
		# Spike 22:16: die Vorlage roh, ohne DorfEffekte.einmal (Start und Aufräumen), zum Vergleich: stösst sie von selbst aus?
		var roh := fx.setze("effects/footstep_dust.tscn", g.karte.kachel_pos(Vector2i(17, 6)), DorfEffekte.STAUB_K)
		if roh:
			_teilchen("Fussstaub roh (gleich)", roh)
			await warte(3)
			_teilchen("Fussstaub roh (3 Bilder)", roh)
			roh.queue_free()
		# Federn wie beim Huhn
		var vorf := fx.get_child_count()
		fx.federn(g.karte.kachel_pos(Vector2i(10, 28)))
		if fx.get_child_count() > vorf:
			_teilchen("Federn (gleich)", fx.get_child(fx.get_child_count() - 1))
			await warte(3)
			_teilchen("Federn (3 Bilder)", fx.get_child(fx.get_child_count() - 1))
	print("FUSS814 fertig")
	quit(0)

func _staub(fx: DorfEffekte) -> Array:
	return fx.get_children().filter(func(c): return String(c.scene_file_path).ends_with("footstep_dust.tscn"))

func _teilchen(was: String, n: Node) -> void:
	var sk: Script = n.get_script()
	var schalter := []
	if sk:
		for p in n.get_property_list():
			if p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
				schalter.append("%s=%s" % [p["name"], str(n.get(p["name"]))])
	print("FUSS814 %s %s bei %s, Skript %s: %s; Methoden play %s, emit %s, restart %s" % [was, n.name, (n as Node3D).global_position,
		sk.resource_path if sk else "-", ", ".join(schalter), n.has_method("play"), n.has_method("emit"), n.has_method("restart")])
	for p in n.find_children("*", "GPUParticles3D", true, false):
		var gp := p as GPUParticles3D
		var pm := gp.process_material as ParticleProcessMaterial
		var farbe := ""
		if pm and pm.color_ramp is GradientTexture1D and (pm.color_ramp as GradientTexture1D).gradient:
			var gr := (pm.color_ramp as GradientTexture1D).gradient
			var t := []
			for i in gr.get_point_count():
				t.append("%.2f:%s" % [gr.get_offset(i), gr.get_color(i).to_html()])
			farbe = " ".join(t)
		var quad := ""
		if gp.draw_pass_1 is QuadMesh:
			quad = str((gp.draw_pass_1 as QuadMesh).size)
		print("FUSS814   %s: emitting %s, one_shot %s, Menge %d, Lebenszeit %.2f, sichtbar %s, Groesse %.3f-%.3f, Quad %s, Farbe %s" % [gp.name,
			gp.emitting, gp.one_shot, gp.amount, gp.lifetime, gp.is_visible_in_tree(), pm.scale_min if pm else -1.0, pm.scale_max if pm else -1.0,
			quad, farbe])
