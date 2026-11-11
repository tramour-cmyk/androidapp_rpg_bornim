# 453.1: Held und Söldner atmen im Kampfort als eigene Schicht (atem.gd). Ohne Bild gemessen, je Figur:
#  - Ruhe: Atemzug 3,0–4,2 s (17 je Minute, Feld 2 „einen Tick schneller“ als 4,3 s; vorher Idle_Loop 1,25 s), Schulter hebt sich
#    0,6–1,6 cm, Kopf neigt sich höchstens 1,5°
#  - eigener Takt: die beiden Atemzüge unterscheiden sich um mindestens 5 %, die Einatmungen fallen nicht zusammen (Gleichtakt)
#  - nach Anstrengung schneller (in den ersten 3 s mindestens 1,6-mal so viele Atemzüge wie in Ruhe) und sichtbar tiefer (Schulter
#    mindestens 1,8-mal so hoch wie in Ruhe; Feld 2 „steigert sich … und dann wieder normalisiert“), nach 8 s wieder fast Ruhe
#  - die Ruhebewegung selbst atmet nicht mehr (Kampfstehen ein Schlüssel je Spur)
#  - der fernere Held atmet so viel tiefer, wie er im Bild kleiner ist (höchstens 1,6; Chef 19:5x „etwas deutlicher“), Maße oben im Bild
#  - der Kampf läuft auf Autopilot zu Ende ohne Skriptfehler
# Ohne Kaufdateien „ohne Kauf“ und Ende 0.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/atem_4531.gd   (exit code 0 = alles richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


class Spur:
	var fig
	var sk: Skeleton3D
	var schulter: Array = []     # Höhe des linken Schultergelenks (m), nur in Ruhe
	var kopf: Array = []         # Kopfneigung (Grad) gegen den Mittelwert, nur in Ruhe
	var tiefe: Array = []        # je Bild Einatmung
	var zuege: Array = []        # [Zeit s, Dauer s, Anstrengung] je vollendetem Atemzug
	var letzte_phase := 0.0
	var start_s := -1.0
	var zug_a := 0.0             # größte Anstrengung im laufenden Atemzug
	var sch_y := 0.0             # nach den Schichten (skeleton_updated): die Pose, die man sieht
	var kopf_g := 0.0

	func nach_schichten() -> void:
		var sch := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("upperarm_l"))
		sch_y = sch.origin.y
		var k := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head"))
		kopf_g = rad_to_deg(k.basis.y.normalized().angle_to(Vector3.UP))


func _spur(fig) -> Spur:
	var s := Spur.new()
	s.fig = fig
	s.sk = fig._find(fig.model, "Skeleton3D") as Skeleton3D
	s.letzte_phase = fig.atem.phase
	s.sk.skeleton_updated.connect(s.nach_schichten)
	return s


func _messe(s: Spur, t: float, ruhe: bool) -> void:
	var a = s.fig.atem
	s.tiefe.append(a.tiefe)
	s.zug_a = maxf(s.zug_a, a.anstrengung)
	if a.phase < s.letzte_phase:     # neuer Atemzug
		if s.start_s >= 0.0:
			s.zuege.append([t, t - s.start_s, s.zug_a])
		s.start_s = t
		s.zug_a = a.anstrengung
	s.letzte_phase = a.phase
	# Ruhe: daheim in der Ruhebewegung und ausgeschnauft (die Wölfe greifen schon vor dem ersten Zug des Helden an)
	if ruhe and a.anstrengung < 0.02 and s.fig.anim.current_animation in ["Kampfstehen", "Stehen", "SS_IdleCombat"] and not (s.fig.tween and s.fig.tween.is_running()):
		s.schulter.append(s.sch_y)
		s.kopf.append(s.kopf_g)


func _kamera_abstand(s: Spur) -> float:
	return s.sk.get_viewport().get_camera_3d().global_position.distance_to(s.sk.global_position)


static func _spanne(v: Array) -> float:
	return (v.max() - v.min()) if not v.is_empty() else 0.0


func _run() -> void:
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da("FIGHTER"):
		print("Atem 453.1: ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start()
	for i in 4:
		await process_frame
	var kf = p.fight
	var held = kf.figures.get("hero")
	var sold = kf.figures.get("merc")
	_check(held != null and held.atem != null and sold != null and sold.atem != null, "Held und Söldner haben die Atemschicht")
	if fails > 0:
		quit(1)
		return
	# 406: mit Schild ruht der Held in der Kampfhaltung des Satzes (SS_IdleCombat); auch sie atmet nicht selbst
	for rn in ["Kampfstehen", "SS_IdleCombat"]:
		if not held.anim.has_animation(rn):
			continue
		var ks: Animation = held.anim.get_animation(rn)
		var mehr := 0
		for t in ks.get_track_count():
			if ks.track_get_key_count(t) > 1:
				mehr += 1
		_check(mehr == 0, "%s atmet nicht selbst (%d Spuren mit mehr als einem Schlüssel)" % [rn, mehr])
	# erst eine Sekunde einschwingen (Waffe und Haltung kommen ein Bild nach dem Einhängen, _arm_kauf)
	for i in 30:
		await process_frame
	var sh := _spur(held)
	var ss := _spur(sold)
	# 1) Ruhe: 20 s ohne Kampfzug (Bilder zu 1/30 s)
	var t := 0.0
	for i in 600:
		await process_frame
		t += 1.0 / 30.0
		_messe(sh, t, true)
		_messe(ss, t, true)
	for s in [sh, ss]:
		var n: String = "Held" if s == sh else "Söldner"
		var d: Array = s.zuege.filter(func(z): return z[2] < 0.02).map(func(z): return z[1])
		var mittel: float = d.reduce(func(a, b): return a + b, 0.0) / maxf(1.0, d.size())
		if OS.get_environment("ATEM_REIHE") != "":
			print("%s Schulter %s" % [n, " ".join(s.schulter.slice(0, 600, 10).map(func(x): return "%.3f" % x))])
			print("%s Kopf %s" % [n, " ".join(s.kopf.slice(0, 600, 10).map(func(x): return "%.2f" % x))])
			print("%s Züge %s" % [n, str(s.zuege)])
		print("%s: Atemzug in Ruhe %.2f s (%d Züge), Takt %.2f s, Schulter %.1f cm, Kopf %.2f°" % [n, mittel, d.size(), s.fig.atem.takt, _spanne(s.schulter) * 100.0, _spanne(s.kopf)])
		_check(mittel >= 3.0 and mittel <= 4.2, "%s: Atemzug in Ruhe 3,0–4,2 s (%.2f)" % [n, mittel])
		# 453.1 Urteil 19:5x („etwas deutlicher“ beim vorderen): Maße im Bild, also geteilt durch den Ausgleich nach Kameraabstand
		var si: float = s.fig.atem.sicht
		print("%s: Ausgleich nach Kameraabstand %.2f, Abstand %.2f m" % [n, si, _kamera_abstand(s)])
		_check(_spanne(s.schulter) / si >= 0.006 and _spanne(s.schulter) / si <= 0.016, "%s: Schulter hebt sich 0,6–1,6 cm im Bild (%.2f / %.2f)" % [n, _spanne(s.schulter) * 100.0, si])
		_check(_spanne(s.kopf) / si <= 1.5, "%s: Kopf neigt sich höchstens 1,5° im Bild (%.2f / %.2f)" % [n, _spanne(s.kopf), si])
	# 453.1: der weiter von der Kamera atmet um so viel tiefer, wie er im Bild kleiner ist (höchstens 1,6), der nähere wie bisher
	var fern := sh if _kamera_abstand(sh) >= _kamera_abstand(ss) else ss
	var nah := ss if fern == sh else sh
	var soll: float = clampf(_kamera_abstand(fern) / _kamera_abstand(nah), 1.0, 1.6)
	_check(absf(nah.fig.atem.sicht - 1.0) < 0.03, "der Kamera nähere Held atmet wie bisher (%.2f)" % nah.fig.atem.sicht)
	_check(absf(fern.fig.atem.sicht - soll) < 0.05, "der fernere Held atmet tiefer nach Abstand (%.2f, soll %.2f)" % [fern.fig.atem.sicht, soll])
	var r: float = sh.fig.atem.takt / ss.fig.atem.takt
	_check(absf(r - 1.0) >= 0.05, "eigener Takt: Held %.2f s, Söldner %.2f s" % [sh.fig.atem.takt, ss.fig.atem.takt])
	# Gleichtakt: Anteil der Bilder, in denen beide zugleich über halb eingeatmet haben, gegen den Zufall (etwa ein Viertel)
	var beide := 0
	for i in sh.tiefe.size():
		if sh.tiefe[i] > 0.5 and ss.tiefe[i] > 0.5:
			beide += 1
	var gleich: float = float(beide) / sh.tiefe.size()
	_check(gleich < 0.45, "kein Gleichtakt: beide zugleich eingeatmet in %.0f %% der Bilder" % (gleich * 100.0))
	var ruhe_sch := _spanne(sh.schulter)
	# 2) nach Anstrengung: wie ein Hieb (der Held bleibt in der Ruhebewegung, damit die Schulter nur den Atem zeigt), dann 13 s messen
	# (Lauf 214: in 10 s endete der letzte Atemzug bei 7,8 s, der nächste nach 8 s erst bei etwa 10,9 s; das Fenster muss mindestens
	# 8 s plus einen Ruheatemzug mit Spielraum fassen, 8 + 1,15 · 4,2 s)
	held.atem.anstrengen(1.0)
	var t0 := t
	sh.zuege.clear()
	var weit := 0.0     # Atemzüge in den ersten 3 s (Phase ohne Umbruch)
	var sch_an: Array = []     # Schulterhöhe in den ersten 4 s
	for i in 390:
		var p0: float = held.atem.phase
		await process_frame
		t += 1.0 / 30.0
		_messe(sh, t, false)
		if i < 90:
			weit += fposmod(held.atem.phase - p0, 1.0)
		if i < 120:
			sch_an.append(sh.sch_y)
	var steig: float = _spanne(sch_an) / maxf(ruhe_sch, 0.0001)
	print("nach Anstrengung: Schulter %.1f cm (Ruhe %.1f cm), %.2f-mal" % [_spanne(sch_an) * 100.0, ruhe_sch * 100.0, steig])
	_check(steig >= 1.8, "Steigerung sichtbar: Schulter in den ersten 4 s %.2f-mal so hoch wie in Ruhe" % steig)
	var ruhe_s: float = held.atem.takt
	var spaete: Array = sh.zuege.filter(func(z): return z[0] - t0 >= 8.0).map(func(z): return z[1])
	print("nach Anstrengung: Atemzüge %s s (Ruhe %.2f)" % [", ".join(sh.zuege.map(func(z): return "%.2f@%.1f" % [z[1], z[0] - t0])), ruhe_s])
	var mal: float = weit / (3.0 / ruhe_s)
	_check(mal >= 1.6, "in den ersten 3 s nach Anstrengung %.2f-mal so schnell wie in Ruhe" % mal)
	_check(not spaete.is_empty() and spaete.max() < 1.15 * ruhe_s and spaete.max() > 0.85 * ruhe_s, "nach 8 s wieder fast Ruhe (%s)" % str(spaete))
	# 3) Kampf zu Ende auf Autopilot; der Hieb strengt an
	var vorher_a: float = 0.0
	var hieb_a := 0.0
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var w0 := Time.get_ticks_msec()
	var bilder := 0
	var hoch := 0
	while Time.get_ticks_msec() - w0 < 120000:
		await process_frame
		hieb_a = maxf(hieb_a, held.atem.anstrengung - vorher_a)
		vorher_a = held.atem.anstrengung
		if held.atem.active:
			bilder += 1
			if held.atem.anstrengung > 0.5:
				hoch += 1
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
				kf.go_on()
			else:
				var c = kf.mars.current()
				var ts: Array = kf.mars.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	_check(hieb_a > 0.3, "Kampfzüge strengen an (größter Sprung %.2f)" % hieb_a)
	print("im Kampf: Held über halb angestrengt in %.0f %% der Bilder" % (100.0 * hoch / maxf(1, bilder)))
	_check(kf.mars.outcome != "ONGOING", "Kampf endet (%s)" % kf.mars.outcome)
	# 910 (Lauf 338): ein Wolf sprang den Helden in der Ruhemessung an, Sturz ohne Anstrengung, die Bilder danach galten als Ruhe
	held.atem.anstrengung = 0.0
	held.knocked_down()
	_check(held.atem.anstrengung > 0.5, "Sturz strengt an (%.2f)" % held.atem.anstrengung)
	print("Atem 453.1: %d Fehler" % fails)
	quit(1 if fails > 0 else 0)
