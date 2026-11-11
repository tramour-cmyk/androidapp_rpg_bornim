# 682 (Chef 08.11., 16:22–16:24: „so Stück gerade, dann diagonal … dann drehen sie halt wieder auf der Stelle“; t270 20:50:
# „Schienenbahnen“): Messung ohne Bild am Kampfort, Autopilot, je Bild (--fixed-fps 30), je Gegner: Zeit, in der er auf der Stelle
# dreht (Gier über 2° je Bild, Rumpf unter 5 mm), und Knicke (Laufrichtung springt zwischen zwei Bildern um mehr als 20°, beide
# Bilder in Bewegung). Mit GLATT682=0 der alte Weg zum Vergleich. Nur Maß, Exit 0.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/kurven_682.gd   (GEGNER=WOLVES|RATS|…, KLASSEN, BILDER)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

var vor := {}       # id -> [Ort, Gier, Richtung oder null]
var dreh := {}      # id -> Bilder auf der Stelle drehend
var knick := {}     # id -> Knicke
var lauf := {}      # id -> Bilder in Bewegung
var epi := {}       # id -> laufende Drehung am Ort [Bild, Bilder, Grad, Art, Abstand zum Platz]
var ruecken := {}   # 717: id -> Bilder in Bewegung mit dem Rücken zum Helden
var ruecken_art := {}
var dreh_art := {}  # Teil des Schlags/Bewegung -> Bilder auf der Stelle gedreht (wo die Drehung herkommt)


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("KURVEN682 ohne Kaufmodelle, nichts zu messen")
		quit(0)
		return
	for k in (OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC"])):
		var saat := int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
		seed(saat)
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
		root.add_child(p)
		await process_frame
		p._start(saat)
		for i in 4:
			await process_frame
		var kf = p.fight
		if OS.get_environment("GLATT682") == "0":
			for f in kf.figures.values():
				f.set_meta("glatt_aus", true)
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		vor.clear()
		var n := 0
		while n < (int(OS.get_environment("BILDER")) if OS.get_environment("BILDER") != "" else 30 * 90):
			await process_frame
			n += 1
			_bild(kf)
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		var sd := 0
		var sk := 0
		var sl := 0
		var sr := 0
		for id in ruecken:
			sr += ruecken[id]
		for id in lauf:
			print("  %s %s: %d Bilder in Bewegung, %d Bilder auf der Stelle gedreht, %d Knicke" % [k, id, lauf[id], dreh.get(id, 0), knick.get(id, 0)])
			sd += dreh.get(id, 0)
			sk += knick.get(id, 0)
			sl += lauf[id]
		print("KURVEN682 %s %s: %d Bilder in Bewegung, auf der Stelle gedreht %d (%.1f s), Knicke %d, Rücken zum Helden %d Bilder (%.1f s) %s" % [k, "alt" if OS.get_environment("GLATT682") == "0" else "neu", sl, sd, sd / 30.0, sk, sr, sr / 30.0, ruecken_art])
		var arten := dreh_art.keys()
		arten.sort_custom(func(a, b): return dreh_art[a] > dreh_art[b])
		for a in arten:
			print("    gedreht bei %s: %d Bilder" % [a, dreh_art[a]])
		dreh.clear(); knick.clear(); lauf.clear(); dreh_art.clear(); ruecken.clear(); ruecken_art.clear()
		p.queue_free()
		for i in 5:
			await process_frame
	quit(0)


func _bild(kf) -> void:
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster == null or not f.visible or f.down:
			continue
		var p: Vector3 = f.position
		var g: float = f.rotation.y
		if vor.has(id):
			var d := Vector2(p.x - vor[id][0].x, p.z - vor[id][0].z)
			var dg := absf(rad_to_deg(wrapf(g - vor[id][1], -PI, PI)))
			var r = null
			if d.length() > 0.005:
				r = d.normalized()
				lauf[id] = int(lauf.get(id, 0)) + 1
				# 717 (F7): Rücken zum Helden in Bewegung (Blick über 100° vom Helden weg), außer auf der Flucht
				var h = kf.figures.get("hero")
				if h != null and not f.flieht:
					var zu_h := Vector2(h.position.x - p.x, h.position.z - p.z).normalized()
					var blick := Vector2(sin(g), cos(g))
					if blick.dot(zu_h) < cos(deg_to_rad(100.0)):
						ruecken[id] = int(ruecken.get(id, 0)) + 1
						var art2 := "%s/%s" % [f.gang if f.gang != "" else "-", f.anim.current_animation if f.anim else "?"]
						ruecken_art[art2] = int(ruecken_art.get(art2, 0)) + 1
						if OS.get_environment("EPISODEN") != "":
							print("    RUECKEN %s Bild %d %s %.2f m vom Platz" % [id, Engine.get_process_frames(), art2, f.position.distance_to(f.home)])
				if vor[id][2] != null and rad_to_deg(absf(r.angle_to(vor[id][2]))) > 20.0:
					knick[id] = int(knick.get(id, 0)) + 1
					if OS.get_environment("EPISODEN") != "":
						print("    KNICK %s Bild %d: %.0f°, %s/%s, %.2f m vom Platz" % [id, Engine.get_process_frames(), rad_to_deg(absf(r.angle_to(vor[id][2]))), f.gang, f.anim.current_animation if f.anim else "?", f.position.distance_to(f.home)])
			elif dg > 2.0:
				dreh[id] = int(dreh.get(id, 0)) + 1
				var art := "%s/%s" % [f.gang if f.gang != "" else "-", f.anim.current_animation if f.anim else "?"]
				dreh_art[art] = int(dreh_art.get(art, 0)) + 1
				if not epi.has(id):
					epi[id] = [Engine.get_process_frames(), 0, 0.0, art, f.position.distance_to(f.home)]
				epi[id][1] += 1
				epi[id][2] += dg
			elif epi.has(id):
				if OS.get_environment("EPISODEN") != "":
					print("    DREH %s ab Bild %d: %d Bilder, %.0f°, %s, %.2f m vom Platz" % [id, epi[id][0], epi[id][1], epi[id][2], epi[id][3], epi[id][4]])
				epi.erase(id)
			vor[id] = [p, g, r]
		else:
			vor[id] = [p, g, null]
