# 415 r4: E3 auch am Schirm (Kamera orthogonal: Blick parallel), F6 ebenso (strahlprobe._auge).
# 415 r3 (Tor 461a, Lauf 172: F6 alle Strahlen aus Hals und Schulter des Magiers; E3 der graue Wolf im Feuerstrom; F2 ein Bild Laser in
# den Himmel): misst die Strahlenprobe (kampf/strahlprobe.gd) ohne Bild, so wie der Film sie zeigt (Spielkamera, 540 × 1170), je Bild
# mit sichtbarem Strahl:
#   F6  liegt die Stabspitze von der Kamera aus hinter dem Körper des Magiers (Kapseln, figur.gd kapseln) oder in ihm; Abstand der
#       Spitze zum Umriss des Körpers am Schirm (px, positiv = frei)
#   E3  wie tief die Strecke Spitze–Ende in einer Figur liegt, an der der Strahl nicht endet
#   F2  Winkel zwischen der Richtung der Mündung und der Richtung zum Ende
# je Drehung des Magiers über das Ziel hinaus (0°, +35°, −35°), damit die Wahl für den Film auf Zahlen steht.
# Aufruf: godot headless --fixed-fps 30 -s res://tests/strahl_mess_415.gd (ohne Paket oder Kauf: Meldung, Ende 0). Meldet, hält nicht an.
extends SceneTree

const Strahlprobe = preload("res://kampf/strahlprobe.gd")
const DREHUNGEN := [0.0, 35.0, -35.0]
const HOECHST_S := 45.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(540, 1170))
	root.size = Vector2i(540, 1170)
	await process_frame
	if not Strahlprobe.da():
		print("Strahl 415: ohne Paket (godot/addons/reeboo_beams), nichts zu messen")
		quit(0)
		return
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("Strahl 415: ohne Kauf, nichts zu messen")
		quit(0)
		return
	for dreh in DREHUNGEN:
		var s := Strahlprobe.new()
		s.film = true
		s.dreh_grad = dreh
		root.add_child(s)
		var t := 0.0
		while s.kf == null and t < 10.0:
			await process_frame
			t += 1.0 / 30.0
		if s.kf == null:
			print("Strahl 415 FEHLER: kein Kampfort")
			quit(0)
			return
		var m := {}     # Strahl -> Werte
		t = 0.0
		while not s.fertig and t < HOECHST_S:
			await process_frame
			t += 1.0 / 30.0
			if not s.sichtbar or s.held == null or s.muendung == null:
				continue
			var e: Dictionary = m.get(s.jetzt, {"bilder": 0, "verdeckt": 0, "innen": 0, "tief": -INF, "px": [], "e3": -INF, "e3wo": "", "f2": 0.0, "e3s": -INF, "e3swo": ""})
			e.bilder += 1
			var cam: Camera3D = root.get_camera_3d()
			var tip: Vector3 = s.muendung.global_position
			var kap: Array = s.held.kapseln()
			# F6: Strecke Kamera–Spitze durch den Körper vor der Spitze, Spitze im Körper
			var verdeckt := false
			for c in kap:
				var q := Geometry3D.get_closest_points_between_segments(s._auge(cam, tip), tip, c[0], c[1])
				var d: float = (q[0] as Vector3).distance_to(q[1]) - float(c[2])
				if d < 0.0 and (q[0] as Vector3).distance_to(tip) > 0.03:
					verdeckt = true
					e.tief = maxf(e.tief, -d)
				if tip.distance_to(Geometry3D.get_closest_point_to_segment(tip, c[0], c[1])) < float(c[2]):
					e.innen += 1
			if verdeckt:
				e.verdeckt += 1
			# Abstand der Spitze zum Umriss am Schirm (Kapsel projiziert: Halbmesser am Ort der Kapsel)
			var sp: Vector2 = cam.unproject_position(tip)
			var frei := INF
			for c in kap:
				var a2: Vector2 = cam.unproject_position(c[0])
				var b2: Vector2 = cam.unproject_position(c[1])
				var mitte: Vector3 = (c[0] + c[1]) * 0.5
				var r2: float = cam.unproject_position(mitte).distance_to(cam.unproject_position(mitte + cam.global_transform.basis.x * float(c[2])))
				frei = minf(frei, sp.distance_to(Geometry2D.get_closest_point_to_segment(sp, a2, b2)) - r2)
			(e.px as Array).append(frei)
			# E3: Strecke Spitze–Ende in einer anderen Figur als der getroffenen
			var ende: Vector3 = s.ziel.global_position
			for id in s.kf.figures:
				var f = s.kf.figures[id]
				if f == s.held or f == s.getroffen or f.down or not f.visible:
					continue
				for c in f.kapseln():
					var q2 := Geometry3D.get_closest_points_between_segments(tip, ende, c[0], c[1])
					var d2: float = float(c[2]) - (q2[0] as Vector3).distance_to(q2[1])
					if d2 > e.e3:
						e.e3 = d2
						e.e3wo = "%s %.1f s" % [id, t]
			# r4 (Lauf 181: im Raum 0,4–1,1 m frei, am Schirm über dem grauen Wolf): E3 am Schirm, was die Kamera vor dem Strahl sieht,
			# mit seiner halben Breite: Strecke Kamera–Strahlpunkt gegen jede Kapsel einer anderen Figur (positiv = davor)
			var n := int(tip.distance_to(ende) / 0.04) + 1
			for i in range(1, n + 1):
				var qs := tip.lerp(ende, float(i) / n)
				for id in s.kf.figures:
					var f = s.kf.figures[id]
					if f == s.held or f == s.getroffen or f.down or not f.visible:
						continue
					for c in f.kapseln():
						var pp := Geometry3D.get_closest_points_between_segments(s._auge(cam, qs), qs, c[0], c[1])
						var d3: float = float(c[2]) + s.halb - (pp[0] as Vector3).distance_to(pp[1])
						if d3 > e.e3s:
							e.e3s = d3
							e.e3swo = "%s %.1f s" % [id, t]
			# F2
			var vor: Vector3 = -s.muendung.global_transform.basis.z
			if tip.distance_to(ende) > 0.1:
				e.f2 = maxf(e.f2, rad_to_deg(vor.angle_to(ende - tip)))
			m[s.jetzt] = e
		for k in m:
			var e: Dictionary = m[k]
			var px: Array = e.px
			px.sort()
			print("Strahl 415 Drehung %+.0f° %s: %d Bilder, Spitze hinter dem Körper %d, im Körper %d (tiefste %.3f m), am Schirm frei vom Umriss kleinste %.0f px, Mitte %.0f px; E3 tiefste %.3f m (%s), am Schirm %.3f m (%s); F2 größte %.1f°; abgebrochen %d" % [dreh, k, e.bilder, e.verdeckt, e.innen, e.tief, px[0], px[px.size() / 2], e.e3, e.e3wo, e.e3s, e.e3swo, e.f2, s.abgebrochen])
		print("Strahl 415 Drehung %+.0f°: %s nach %.1f s" % [dreh, "fertig" if s.fertig else "abgebrochen", t])
		if is_instance_valid(s.kf):
			s.kf.queue_free()
		s.queue_free()
		for i in 4:
			await process_frame
	print("STRAHL 415 gemessen")
	quit(0)
