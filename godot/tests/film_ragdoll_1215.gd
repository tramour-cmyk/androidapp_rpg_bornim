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


## Netze des Kampforts (ohne Figuren), deren Kasten den Punkt enthält
func _in_netz(q: Vector3) -> Array:
	var r := []
	for m in root.find_children("*", "MeshInstance3D", true, false):
		var bb: AABB = (m as MeshInstance3D).global_transform * (m as MeshInstance3D).get_aabb()
		if bb.has_point(q) and bb.size.length() < 200.0:
			r.append("%s %s" % [m.name, bb.size])
	return r


## Probe 2 (23:56): 5 m quer zum Blick stand die Kamera im Söldner (gob1) und hinter dem Helden (gob2). Jetzt reihum Richtungen um
## den Goblin, 4,5 m weit, 1,3 m hoch; genommen wird die erste, deren Sichtlinie keiner anderen Figur näher als 0,9 m kommt
func _kamera_platz(kf, fig) -> Vector3:
	var ziel: Vector3 = fig.global_position + Vector3.UP * 0.4
	var zu_held: Vector3 = ((kf.figures["hero"].global_position - fig.global_position) * Vector3(1, 0, 1)).normalized()
	for grad in [90.0, -90.0, 135.0, -135.0, 180.0, 60.0, -60.0]:
		var q: Vector3 = fig.global_position + zu_held.rotated(Vector3.UP, deg_to_rad(grad)) * 4.5 + Vector3.UP * 1.3
		var frei := true
		for o in kf.figures.values():
			if o == fig:
				continue
			var p: Vector3 = o.global_position + Vector3.UP * 0.6
			var t := clampf((p - q).dot(ziel - q) / (ziel - q).length_squared(), 0.0, 1.0)
			if (q + (ziel - q) * t).distance_to(p) < 0.9:
				frei = false
				break
		if frei and _in_netz(q).filter(func(n): return not (String(n).begins_with("Rahmen") or String(n).begins_with("Wald"))).is_empty():
			print("FILM1215 %s Kamera aus %+.0f°" % [fig.fighter.id, grad])
			return q
	print("FILM1215 %s OHNE freie Sicht" % fig.fighter.id)
	return fig.global_position + zu_held.rotated(Vector3.UP, PI / 2) * 4.5 + Vector3.UP * 1.3


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
		cam.global_position = _kamera_platz(kf, fig)
		cam.look_at(fig.global_position + Vector3.UP * 0.4, Vector3.UP)
		print("FILM1215 %s im Bild: %s, Kamera in: %s" % [fig.fighter.id, cam.is_position_in_frustum(fig.global_position + Vector3.UP * 0.4), _in_netz(cam.global_position)])
		var rechts: Vector3 = (cam.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
		await _bilder(int(FPS * 0.8))
		if OS.get_environment("STANDBILD") != "":     # Sokrates 15.11., 00:24: je Goblin erst ein Standbild ansehen (Büsche, Netze)
			root.get_texture().get_image().save_png(OS.get_environment("STANDBILD").replace(".png", "-%s.png" % fig.fighter.id))
			if k == 1:
				quit(0)
				return
			continue
		schild.text = ("mit Physik am Ende" if physik else "nur Schlüsselbilder") + (" · Schlag von links" if k == 0 else " · Schlag von rechts")
		fig.tod_stoss = rechts * (1.4 if k == 0 else -1.4)
		seed(3 + k)
		fig.die()
		await _bilder(int(FPS * 4.0))
	print("FILM1215 fertig, Physik %s" % physik)
	quit(0)
