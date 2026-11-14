extends SceneTree
# 1215 (Chef 13.11., 16:25): Film Schlüsselbilder allein gegen Schlüsselbilder mit Physik am Ende. Probekampf gegen Goblins,
# Kamera flach von der Seite auf zwei Goblins; der erste stirbt nach einem Schlag von links, der zweite nach einem von rechts.
# PHYSIK=1: mit ragdoll.gd, sonst die gebackene Bewegung allein (gleicher Seed, gleiche Sterbebewegung). Oben steht, was läuft.
# Aufruf: im Ordner godot mit Bild und --write-movie … --fixed-fps 30 -s res://tests/film_ragdoll_1215.gd (braucht kampf/daten)

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
const FPS := 30.0


func _initialize() -> void:
	_run.call_deferred()


func _bilder(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	var physik := OS.get_environment("PHYSIK") == "1"
	Figur.ragdoll_probe = physik
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "GOBLINS"
	root.add_child(p)
	await process_frame
	p._start(5)
	await _bilder(12)
	var kf = p.fight
	while kf.verhuellt:
		await process_frame
	var feinde: Array = kf.figures.values().filter(func(f): return f.fighter.monster != null)
	if feinde.size() < 2:
		print("FILM1215 OHNE zwei Goblins")
		quit(1)
		return
	# Oberfläche des Kampforts aus dem Bild (nur die Figuren zählen hier)
	if kf.ui != null:
		kf.ui.visible = false
	var a = feinde[0]
	var b = feinde[1]
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 50.0
	cam.make_current()
	var schild := Label.new()
	schild.text = "mit Physik am Ende" if physik else "nur Schlüsselbilder"
	schild.add_theme_font_size_override("font_size", 30)
	schild.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	schild.position = Vector2(20, 30)
	var ebene := CanvasLayer.new()
	ebene.layer = 100
	ebene.add_child(schild)
	root.add_child(ebene)
	# je Goblin die Kamera flach von der Seite (quer zu seinem Blick, 5 m), dann der Schlag von links (schiebt nach rechts im
	# Bild), beim zweiten von rechts
	for k in 2:
		var fig = a if k == 0 else b
		var blick: Vector3 = ((kf.figures["hero"].global_position - fig.global_position) * Vector3(1, 0, 1)).normalized()
		cam.global_position = fig.global_position + blick * 5.0 + Vector3.UP * 1.3
		cam.look_at(fig.global_position + Vector3.UP * 0.4, Vector3.UP)
		print("FILM1215 %s im Bild: %s" % [fig.fighter.id, cam.is_position_in_frustum(fig.global_position + Vector3.UP * 0.4)])
		var rechts: Vector3 = (cam.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
		await _bilder(int(FPS * 0.8))
		schild.text = ("mit Physik am Ende" if physik else "nur Schlüsselbilder") + (" · Schlag von links" if k == 0 else " · Schlag von rechts")
		fig.tod_stoss = rechts * (1.4 if k == 0 else -1.4)
		seed(3 + k)
		fig.die()
		await _bilder(int(FPS * 4.0))
	print("FILM1215 fertig, Physik %s" % physik)
	quit(0)
