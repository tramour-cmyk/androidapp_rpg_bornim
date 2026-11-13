# 562 (Chef 04.11., 17:02: „Der Angriff der Helden auf die Wölfe ist auch völlig im Schlaf-Tabletten-Modus“; 07.11., t268.19: „Held geht
# nicht sonderlich zügig zum Angriff“): Messung ohne Bild am echten Kampfort gegen die Wölfe, Autopilot, je Bild (--fixed-fps 30).
# Je Gang eines Helden oder Söldners zum Angriff und zurück (gleiche Bewegung, Rumpf bewegt sich): Dauer, Weg, Tempo (m/s), Tempo der
# Bewegung (speed_scale), Schritte je Sekunde (Wechsel des tieferen Fußes) und wie schnell der stehende Fuß über den Boden rutscht.
# Grenzen: hin mindestens SOLL_HIN m/s (Gehen auf der Karte, HeldFigur.TAKT_GEHEN), stehender Fuß im Mittel unter RUTSCH_ANTEIL des Tempos.
# 824 (Lauf 42707518605: Held ohne Schild (Probe ROGUE) rückwärts heim in „Gehen“ 3,4–3,8 m/s, Bewegung bis 1,78-fach, Füße rutschen): hält
# nur noch an, wenn ein Held ohne Schild rückwärts in „Gehen“ schneller als GEHEN_MAX mal sein Gehtempo geht oder die Bewegung mehr
# als GEHEN_MAX-fach läuft; die übrigen Grenzen aus 562 (Rutschen beim Rennen, hin mit Schild) melden nur (Maß unzuverlässig, 824).
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/angriff_824.gd   (Exit 0 = Grenzen gehalten; ohne Kauf 0)
# KLASSEN=FIGHTER,CLERIC,ROGUE (Vorgabe ROGUE: ohne Schild)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 60
## Rutschen im Verhältnis zum Tempo des Gangs: Lauf 272 (07.11.) maß bei 1,34 m/s (Stand t268, Chef sah kein Rutschen) 0,55 m/s = 0,41,
## bei 2,13 m/s 1,01 m/s = 0,47, zurück 0,40/1,56 = 0,26; der tiefere Fuß wandert also immer im selben Anteil (Messung über den Fußwechsel),
## eine feste Grenze in m/s strafte nur das Tempo. Grenze: Anteil höchstens RUTSCH_ANTEIL
const RUTSCH_ANTEIL := 0.5
const GEHEN_MAX := 1.15
const GAENGE := ["SS_WalkForward", "SS_WalkBackwards", "SS_RunForward", "Gehen", "Rennen"]

var fehler := 0
var lauf := {}        # id -> {anim, bilder, weg, speed, wechsel, tief, rutsch, n_rutsch, start}
var vor := {}         # id -> Ort
var fuss_vor := {}    # id -> [l, r]
var gehen := {}      # "Klasse id" -> Gehtempo am Fuß (m/s)
var gaenge := []      # [Klasse, id, anim, s, m, m/s, speed, Schritte/s, Rutsch m/s, Rücken?]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da():
		print("ANGRIFF824 ohne Kauf, nichts zu messen")
		quit(0)
		return
	var klassen := OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["ROGUE"])
	for k in klassen:
		seed(7)
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "CLERIC" if k == "FIGHTER" else "FIGHTER"
		p.foe = OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
		root.add_child(p)
		await process_frame
		p._start(7)
		for i in 4:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("ANGRIFF824 kein Kampf")
			quit(1)
			return
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		lauf.clear(); vor.clear(); fuss_vor.clear()
		var n := 0
		while n < DAUER_BILDER:
			await process_frame
			n += 1
			_bild(kf, k)
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		for id in lauf.keys():
			_ende(k, id)
		for f in kf.figures.values():
			if f.fighter.monster == null and f.anim:
				gehen[k + " " + String(f.fighter.id)] = f._held_mps("Gehen")
				var zeile := "ANGRIFF824 %s %s: Tempo am Fuß" % [k, f.fighter.id]
				for g in GAENGE:
					if f.anim.has_animation(g):
						zeile += " %s %.2f m/s (Länge %.2f s)" % [g, f._held_mps(g), f.anim.get_animation(g).length]
				print(zeile)
		print("ANGRIFF824 Kampf %s: %s nach %d Bildern" % [k, kf.mars.outcome, n])
		kf.queue_free()
		p.queue_free()
		await process_frame
	_bilanz()
	quit(1 if fehler > 0 else 0)


func _fuesse(f) -> Array:
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
	if sk == null or sk.find_bone("foot_l") < 0:
		return []
	var l: Vector3 = sk.global_transform * sk.get_bone_global_pose(sk.find_bone("foot_l")).origin
	var r: Vector3 = sk.global_transform * sk.get_bone_global_pose(sk.find_bone("foot_r")).origin
	return [l, r]


func _bild(kf, k: String) -> void:
	for f in kf.figures.values():
		if f.fighter.monster != null or f.anim == null or f.down:
			continue
		var id := String(f.fighter.id)
		var a := String(f.anim.current_animation)
		var p: Vector3 = f.global_position
		var dp := Vector2(p.x - vor[id].x, p.z - vor[id].z).length() if vor.has(id) else 0.0
		vor[id] = p
		var fu := _fuesse(f)
		var geht := a in GAENGE and dp > 0.002
		if lauf.has(id) and (not geht or lauf[id].anim != a):
			_ende(k, id)
		if geht:
			if not lauf.has(id):
				lauf[id] = {"anim": a, "bilder": 0, "weg": 0.0, "speed": 0.0, "wechsel": 0, "tief": -1, "rutsch": 0.0, "n_rutsch": 0}
			var L: Dictionary = lauf[id]
			L.bilder += 1
			L.weg += dp
			L.speed += absf(f.anim.get_playing_speed())
			if fu.size() == 2 and fuss_vor.has(id) and fuss_vor[id].size() == 2:
				var tief := 0 if fu[0].y < fu[1].y else 1
				if L.tief >= 0 and tief != L.tief:
					L.wechsel += 1
				L.tief = tief
				var s: Vector3 = fu[tief] - fuss_vor[id][tief]
				L.rutsch += Vector2(s.x, s.z).length() * 30.0
				L.n_rutsch += 1
		fuss_vor[id] = fu


func _ende(k: String, id: String) -> void:
	var L: Dictionary = lauf[id]
	lauf.erase(id)
	if L.bilder < 6:
		return
	var s: float = L.bilder / 30.0
	var g := [k, id, L.anim, s, L.weg, L.weg / s, L.speed / L.bilder, L.wechsel / s, L.rutsch / maxf(1.0, L.n_rutsch)]
	gaenge.append(g)
	print("ANGRIFF824 %s %s %-16s %.2f s %.2f m %.2f m/s, Bewegung %.2f-fach, %.1f Schritte/s, stehender Fuß %.2f m/s" % g)


func _bilanz() -> void:
	var soll := float(OS.get_environment("ANGRIFF_MPS")) if OS.get_environment("ANGRIFF_MPS") != "" else HeldFigur.TAKT_GEHEN
	for g in gaenge:
		if g[2] == "SS_WalkForward" and g[4] > 0.8 and g[5] < soll * 0.9:
			print("MASS %s %s hin %.2f m/s, soll %.2f" % [g[0], g[1], g[5], soll])
		if g[8] > RUTSCH_ANTEIL * maxf(0.1, g[5]):
			print("MASS %s %s %s stehender Fuß rutscht %.2f m/s bei %.2f m/s (Anteil %.2f, Grenze %.2f)" % [g[0], g[1], g[2], g[8], g[5], g[8] / maxf(0.1, g[5]), RUTSCH_ANTEIL])
		if g[2] == "Gehen" and g[4] > 0.3 and (g[6] > GEHEN_MAX or g[5] > GEHEN_MAX * float(gehen.get(g[0] + " " + g[1], 2.13))):
			print("FEHLER %s %s Gehen %.2f m/s, Bewegung %.2f-fach (Grenze %.2f-fach, Gehtempo %.2f m/s)" % [g[0], g[1], g[5], g[6], GEHEN_MAX, float(gehen.get(g[0] + " " + g[1], 2.13))]); fehler += 1
	print("ANGRIFF824 %d Gänge, %d Fehler (Ziel hin %.2f m/s)" % [gaenge.size(), fehler, soll])
