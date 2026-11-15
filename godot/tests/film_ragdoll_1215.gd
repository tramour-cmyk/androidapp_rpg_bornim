extends SceneTree
# 1215 (Chef 13.11., 16:25; Sokrates 15.11., 11:21): Film physikalisches Sterben gegen die gebackene Bewegung, in einem Bild:
# zwei gleiche Gegner nebeneinander, derselbe Treffer zur selben Zeit; der linke stirbt mit der gebackenen Bewegung allein, der
# rechte mit Physik (ragdoll.gd). Je Fall ein neuer Probekampf; alle anderen Figuren sind aus dem Bild.
# GEGNER=GOBLINS (SCOUTS, SHAMANS, KOBOLDS), FAELLE=0,1,2 … (Nummern aus FAELLE unten, ohne Angabe alle); mehrere Arten: PLAN.
# Aufruf: im Ordner godot mit Bild und --write-movie … --fixed-fps 30 -s res://tests/film_ragdoll_1215.gd (braucht kampf/daten).
# Der Filmmodus schreibt in der Fenstergröße des Projekts (1080×2340, hoch), --resolution gilt dort nicht: für den Film eine
# override.cfg mit [display] window/size/viewport_width=1280, viewport_height=720 anlegen und danach löschen (Lauf 15.11., 13:04:
# Figuren außerhalb des Bilds). Die letzten zwei Bilder je Fall zeigen schon den Abbau: beim Schneiden weglassen.
# Je Fall meldet das Protokoll „FILM1215 Fall … Bild a bis b“ (zum Schneiden); STANDBILD=<pfad>: je Fall Bilder in acht
# Augenblicken als PNG (zum eigenen Ansehen, ohne Film)

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
const FPS := 30.0
## Name im Bild, Art, woher im Bild (links, rechts, vorn = von der Kamera her, hinten), kritisch
const FAELLE := [
	["Schlag von links", "nah", "links", false], ["Schlag von rechts", "nah", "rechts", false],
	["Schlag von vorn: Sturz nach hinten", "nah", "vorn", false], ["Schlag von hinten: Sturz nach vorn", "nah", "hinten", false],
	["Pfeil von links", "pfeil", "links", false], ["kritischer Treffer von rechts", "nah", "rechts", true],
	["Zauber von vorn", "zauber", "vorn", false], ["Gift: kein Stoß", "still", "", false],
]
const DAUER_S := 2.1
## Kamera um so viel Grad um die Figuren gedreht (freie Sicht: bei Grak steht sonst ein Baum davor); DREH=<Grad> ersetzt es
const DREH := {"GRAK": 50.0}

var bild := 0


func _initialize() -> void:
	_run.call_deferred()


func _bilder(n: int) -> void:
	for i in n:
		await process_frame
		bild += 1


func _run() -> void:
	Figur.ragdoll_probe = true
	preload("res://kampf/ragdoll.gd").bildrate_pruefen = false     # der Film rechnet langsamer als das Spiel
	# PLAN="GOBLINS:0,1,2;SHAMANS:0,2" (Gegnerart: Fälle; …) oder GEGNER und FAELLE für eine Art
	var plan := []
	if OS.get_environment("PLAN") != "":
		for teil in OS.get_environment("PLAN").split(";", false):
			for x in teil.get_slice(":", 1).split(",", false):
				plan.append([teil.get_slice(":", 0), int(x)])
	else:
		var eine := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "GOBLINS"
		for x in (Array(OS.get_environment("FAELLE").split(",", false)) if OS.get_environment("FAELLE") != "" else range(FAELLE.size())):
			plan.append([eine, int(x)])
	var stand := OS.get_environment("STANDBILD")
	var schild := Label.new()
	schild.add_theme_font_size_override("font_size", int(root.get_visible_rect().size.y * 0.05))
	schild.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	schild.add_theme_color_override("font_outline_color", Color.BLACK)
	schild.add_theme_constant_override("outline_size", int(root.get_visible_rect().size.y * 0.012))
	schild.position = Vector2(24, 20)
	var seiten := Label.new()
	seiten.add_theme_font_size_override("font_size", int(root.get_visible_rect().size.y * 0.045))
	seiten.add_theme_color_override("font_color", Color(0.93, 0.9, 0.82))
	seiten.add_theme_color_override("font_outline_color", Color.BLACK)
	seiten.add_theme_constant_override("outline_size", int(root.get_visible_rect().size.y * 0.012))
	seiten.text = "gebackene Bewegung"
	var seiten2: Label = seiten.duplicate()
	seiten2.text = "mit Physik"
	var ebene := CanvasLayer.new()
	ebene.layer = 100
	ebene.add_child(schild)
	ebene.add_child(seiten)
	ebene.add_child(seiten2)
	root.add_child(ebene)
	for eintrag in plan:
		var art: String = eintrag[0]
		var nr: int = eintrag[1]
		var f: Array = FAELLE[nr]
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = art
		root.add_child(p)
		ebene.visible = false
		await _bilder(1)
		p._start(5)
		await _bilder(12)
		var kf = p.fight
		while kf.verhuellt:
			await _bilder(1)
		var feinde: Array = kf.figures.values().filter(func(x): return x.fighter.monster != null)
		if kf.ui != null:
			kf.ui.visible = false
		var a = feinde[0]
		var b = feinde[1] if feinde.size() > 1 else null
		for o in kf.figures.values():
			if o != a and o != b:
				o.visible = false
		# beide nebeneinander, gleiche Blickrichtung; Kamera schräg von vorn, so dass beide ganz im Bild sind (G1), auch liegend
		var dreh: float = float(OS.get_environment("DREH")) if OS.get_environment("DREH") != "" else float(DREH.get(art, 0.0))
		var vorn: Vector3 = (a.global_transform.basis.z * Vector3(1, 0, 1)).normalized().rotated(Vector3.UP, deg_to_rad(dreh))
		var quer: Vector3 = Vector3.UP.cross(vorn).normalized()     # im Bild nach rechts (die Kamera steht vor ihnen)
		var gross: float = maxf(a.head().y - a.position.y, 0.8)
		var mitte: Vector3 = a.global_position
		var ab := 2.7 * gross     # Platz für den Fall zur Seite: jeder fällt bis 1,2 Körperlängen weit
		if b != null:
			mitte = (a.global_position + b.global_position) * 0.5
			a.global_position = mitte - quer * ab * 0.5
			b.global_transform = Transform3D(a.global_transform.basis, mitte + quer * ab * 0.5)
		else:
			gross *= 0.62     # ein Einzelner: näher heran
		a.ragdoll_nie = b != null     # ein einzelner Gegner (Grak): nur mit Physik, ohne Vergleich
		seiten.visible = b != null
		seiten2.visible = b != null
		var cam := Camera3D.new()
		kf.add_child(cam)
		cam.fov = 36.0
		cam.global_position = mitte + vorn * (4.1 * gross + 0.6) + Vector3.UP * (2.0 * gross + 0.3)
		cam.look_at(mitte + Vector3.UP * 0.25 * gross, Vector3.UP)
		cam.make_current()
		var rechts: Vector3 = (cam.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
		var zur_kamera: Vector3 = ((cam.global_position - mitte) * Vector3(1, 0, 1)).normalized()
		var von := {"links": -rechts, "rechts": rechts, "vorn": zur_kamera, "hinten": -zur_kamera}
		ebene.visible = true
		schild.text = "%s" % f[0]
		var sicht: Vector2 = root.get_visible_rect().size
		seiten.position = Vector2(24, sicht.y - seiten.get_minimum_size().y - 16)
		seiten2.position = Vector2(sicht.x - seiten2.get_minimum_size().x - 24, sicht.y - seiten2.get_minimum_size().y - 16)
		var von_bild := bild
		await _bilder(int(FPS * 0.4))
		for fig in [a, b]:
			if fig == null:
				continue
			fig.tod_treffer = {"art": f[1], "anteil": 0.6, "kritisch": f[3]}
			if f[2] != "":
				fig.tod_treffer.von = fig.global_position + (von[f[2]] as Vector3) * 1.3
			seed(11 + nr)
			fig.die()
		if stand != "":
			var t0 := 0.0
			for t in [0.15, 0.3, 0.45, 0.6, 0.8, 1.0, 1.3, 2.6]:
				await _bilder(int(FPS * (t - t0)))
				t0 = t
				root.get_texture().get_image().save_png(stand.replace(".png", "-%s-%d-%03d.png" % [art, nr, int(t * 100)]))
		else:
			await _bilder(int(FPS * DAUER_S))
		print("FILM1215 Fall %d %s %s: Bild %d bis %d, Physik %s" % [nr, art, f[0], von_bild, bild, "ja" if (b if b != null else a).ragdoll != null else "NEIN"])
		kf.queue_free()     # der Kampfort hängt an der Wurzel, nicht am Probekampf (sonst leuchten im nächsten Fall zwei Sonnen)
		p.queue_free()
		await _bilder(2)
	print("FILM1215 fertig")
	quit(0)
