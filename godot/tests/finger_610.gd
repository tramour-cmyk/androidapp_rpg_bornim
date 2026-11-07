extends SceneTree
# 610 (Chef 07.11., t268: „Held im Dorf: Finger am Stab zucken ohne Unterlass (Schild auf dem Rücken)“): der Stab in der Faust
# (tragen.gd „stab“) im Stehen und Gehen, je Bild die Richtung, in die jeder Finger um den Schaft gebeugt wird, und wie weit seine
# Spitze von Bild zu Bild gegen die Hand springt. Ohne Bild. Braucht daten/held.bin und daten/waffen/quarterstaff.bin.
# Aufruf: im Ordner godot mit -s res://tests/finger_610.gd -> „FINGER610 gut“ oder „n Fehler“
const SPRUNG_ERLAUBT := 0.012   # m je Bild bei 30 Bildern/s: mehr ist ein Zucken, kein Mitgehen der Bewegung

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/held.bin") or not FileAccess.file_exists("res://daten/waffen/quarterstaff.bin"):
		print("FINGER610 ohne Daten")
		quit(0)
		return
	var m := Gebiet.lade_glb("res://daten/held.bin")
	root.add_child(m)
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var d := Gebiet.lade_glb("res://daten/waffen/quarterstaff.bin")
	d.top_level = true
	m.add_child(d)
	var t := Tragen.new("stab", d, m, HeldFigur.faust(sk, "r"))
	t.anim = ap
	t.merken = true
	sk.add_child(t)
	var spitzen: Array[int] = []
	for f in Tragen.FINGER:
		var i := sk.find_bone(f + "_03_r")
		if i >= 0: spitzen.append(i)
	var ih := sk.find_bone("hand_r")
	for bew in ["Stehen", "Gehen"]:
		if not ap.has_animation(bew): continue
		ap.play(bew)
		for i in 3: await process_frame
		var vorher := {}
		var groesster := 0.0
		var wechsel_vor := t.wahl_wechsel
		var richtung_vor := t.beuge_wahl.duplicate()
		for n in 150:
			ap.advance(1.0 / 30.0)
			await process_frame
			if t.posen.is_empty(): continue
			var hand := t.posen[ih]   # ausserhalb der Aenderung liefert das Skelett die Pose ohne tragen.gd (merken)
			for i in spitzen:
				var p := hand.affine_inverse() * t.posen[i].origin
				if vorher.has(i): groesster = maxf(groesster, p.distance_to(vorher[i]))
				vorher[i] = p
		pruefe(t.beuge_wahl == richtung_vor or richtung_vor.is_empty(), "%s: jeder Finger beugt sich immer in dieselbe Richtung (%s)" % [bew, t.beuge_wahl])
		print("%s: die Probe je Bild haette %d-mal die Richtung gewechselt" % [bew, t.wahl_wechsel - wechsel_vor])
		pruefe(groesster <= SPRUNG_ERLAUBT, "%s: Fingerspitzen springen gegen die Hand hoechstens %.1f cm je Bild (erlaubt %.1f)" % [bew, groesster * 100, SPRUNG_ERLAUBT * 100])
	# die Finger schliessen sich zur Handflaeche (Daumenseite), nicht nach hinten
	var H: Transform3D = t.posen[ih]
	var mid1: Vector3 = t.posen[sk.find_bone("middle_01_r")].origin
	var lang := (mid1 - H.origin).normalized()
	var fl: Vector3 = t.posen[sk.find_bone("thumb_01_r")].origin - H.origin
	fl = (fl - lang * fl.dot(lang)).normalized()
	var zu := 0.0
	for f in Tragen.FINGER:
		zu += (t.posen[sk.find_bone(f + "_03_r")].origin - t.posen[sk.find_bone(f + "_01_r")].origin).dot(fl) / 4.0
	pruefe(zu > 0.015, "Finger zur Handflaeche geschlossen: Spitzen im Mittel %.1f cm zur Handflaeche hin" % (zu * 100))
	print("FINGER610 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
