# 1589.4 C (Chef 26.11., 15:12, Film 14:00: „das Drehen ist immer noch ein bisschen komisch“; Prüfer Zeno 14:03: „dreht in etwa
# 0,3 s auf der Stelle um rund 90°“; Fritz 09:08: „in etwa 0,25 s … um rund 180° (hart, nicht weich)“): Drehen am Ort weich, ohne
# Bild, an jedem Vierbeiner (figur.vier) aller Probekämpfe Kapitel 1 und am Wolfsrudel des Films (Seed 6, Kämpfer und Kleriker).
# Grenze aus 1040.1 (leute.gd drehe_stehend): die Wende am Ort ist die gemessene Turn90 der UAL Pro (90° in 61 Bildern bei
# 30 Bildern/s, geruest.py 08.11.), höchstens doppelt so schnell gespielt (speed_scale bis 2,0), also 90° in 1,0 s, mit weichem
# Anfang und Ende. Bei weicher Kurve (smoothstep) liegt die Spitze beim 1,5-fachen des Mittels: 135°/s, in DREH_FENSTER (1/3 s)
# also höchstens DREH_GRAD. Gezählt wird nur am Ort: die Mitte geht im Fenster langsamer als GEHT_MPS (wie wege_15894).
# Aufruf: godot --headless --path godot --fixed-fps 30 -s res://tests/drehen_15894.gd (Exit 0 = gut); DREH=WOLVES,RATS nur diese
# (FILM = Seed 6 des Films); DREH_LOG=1 je Verstoß eine Zeile.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")

const KAEMPFE := ["FILM", "RATS", "WOLVES", "RUDEL", "GRIMM", "SPIDER", "BOARS", "CENTIPEDES", "LEECHES", "SLUGS", "BATS", "GRABHUNDE"]
const SPIEL_S := 40.0
const FENSTER := 10            # Bilder (bei --fixed-fps 30: 1/3 s)
const DREH_GRAD := 45.0        # 135°/s · 1/3 s (oben)
const GEHT_MPS := 0.25

var fehler := 0
var log_an := OS.get_environment("DREH_LOG") != ""
var tiere := {}
var max_ges := 0.0
var spur_von := int(OS.get_environment("DREH_SPUR").get_slice("-", 0)) if OS.get_environment("DREH_SPUR") != "" else -1     # Bild von-bis
var spur_bis := int(OS.get_environment("DREH_SPUR").get_slice("-", 1)) if OS.get_environment("DREH_SPUR") != "" else -1


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var nur := OS.get_environment("DREH")
	for k in KAEMPFE:
		if nur != "" and not k in nur.split(","):
			continue
		await _kampf(k)
	print("DREHEN15894 %d Vierbeiner, größte Drehung am Ort %.0f° je %d Bilder (Grenze %.0f°), %s" % [tiere.size(), max_ges, FENSTER, DREH_GRAD, "0 Fehler" if fehler == 0 else "%d FEHLER" % fehler])
	quit(1 if fehler > 0 else 0)


func _kampf(k: String) -> void:
	var film := k == "FILM"
	if film:
		seed(6)     # wie wolf_mess_438 SEED=6 (Film 26-1400)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES" if film else k
	root.add_child(p)
	await process_frame
	p._start(6 if film else 7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf == null:
		fehler += 1
		print("FEHLER %s: kein Kampfort" % k)
		return
	for f in kf.mars.fighters():
		if f.side == "PARTY":
			f.auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var spur := {}     # id -> Array [rotation.y, Vector2 Punkt] je Bild
	var gemeldet := {} # id -> letztes gemeldetes Bild
	var n := 0
	var bilder := int(SPIEL_S * 30.0)
	var max_k := 0.0
	while n < bilder and kf.mars.outcome == "ONGOING":
		await process_frame
		n += 1
		for f in kf.mars.fighters():
			if f.side == "PARTY" and f.hp > 0:
				f.hp = maxi(f.hp, f.max_hp)
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
				kf.go_on()
		for o in kf.figures.values():
			if not Figur.vier(o.fighter):
				continue
			var id: String = o.fighter.id
			if not o.visible or o.down or o.dead_at >= 0 or o.falling():
				spur.erase(id)
				continue
			tiere[k + ":" + id] = true
			if spur_von >= 0 and n >= spur_von and n <= spur_bis:
				print("SPUR %d %.2f %s rot %.0f auf (%.2f,%.2f) %s gang %s" % [n, n / 30.0, id, rad_to_deg(o.rotation.y), o.position.x, o.position.z, String(o.anim.current_animation) if o.anim else "", o.gang])
			var s: Array = spur.get(id, [])
			s.append([o.rotation.y, Vector2(o.position.x, o.position.z)])
			if s.size() > FENSTER + 1:
				s.pop_front()
			spur[id] = s
			if s.size() < FENSTER + 1:
				continue
			var weg: float = (s[-1][1] as Vector2).distance_to(s[0][1])
			if weg * 30.0 / FENSTER >= GEHT_MPS:
				continue
			var dreh := 0.0     # Summe der Drehung im Fenster (eine Richtung zählt, Pendeln hebt sich auf)
			for i in range(1, s.size()):
				dreh += wrapf(float(s[i][0]) - float(s[i - 1][0]), -PI, PI)
			var g := absf(rad_to_deg(dreh))
			max_k = maxf(max_k, g)
			if g > DREH_GRAD:
				if gemeldet.get(id, -100) < n - FENSTER:
					fehler += 1
					if log_an:
						print("  %s %5.2f s %s dreht am Ort %.0f° in %d Bildern (%.0f°/s), Bewegung %s, gang %s" % [k, n / 30.0, id, g, FENSTER, g * 30.0 / FENSTER,
							String(o.anim.current_animation) if o.anim else "", o.gang])
				gemeldet[id] = n
	max_ges = maxf(max_ges, max_k)
	print("  %s: größte Drehung am Ort %.0f° je %d Bilder" % [k, max_k, FENSTER])
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame
