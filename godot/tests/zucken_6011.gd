# 601.1 (Chef 16.11., 12:24, t291.8: „zucken tut der Held definitiv nicht“): Probekampf Goblin-Späher, schreibt je Bild jeden
# Wechsel der Bewegung von Held und Söldner mit der Zeile dazu; Treffer eines Pfeils: welche Bewegung ab dem Aufschlag wie lange läuft.
# Befund: ein Zucken („Treffer“/„SS_GetHit…“), das vor ZUCK_ANTEIL seiner Länge abbricht (vorher brach das Ende der Abwehr es ab).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/zucken_6011.gd   (SEED, SOELDNER=CLERIC, KLASSE=FIGHTER)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const ZUCK_ANTEIL := 0.8


func _initialize() -> void:
	_lauf.call_deferred()


func _env(n: String, d: String) -> String:
	return OS.get_environment(n) if OS.get_environment(n) != "" else d


func _lauf() -> void:
	var s := int(_env("SEED", "7"))
	seed(s)
	var p = Probe.new()
	p.hero_cls = _env("KLASSE", "FIGHTER")
	p.merc_cls = _env("SOELDNER", "CLERIC")
	p.foe = "SCOUTS"
	root.add_child(p)
	await process_frame
	p._start(s)
	for i in 4:
		await process_frame
	var kf = p.fight
	kf.mars.find("merc").auto = true
	while kf.verhuellt:
		await process_frame
	for id in kf.figures:
		var fa = kf.figures[id]
		if fa.fighter.side == "PARTY" and fa.anim:
			for nm in ["Treffer", "SS_GetHitLightFront", "SS_GetHitHeavyFront", "SS_BlockMedium1", "SS_BlockMedium2", "SS_ParryHigh1"]:
				if fa.anim.has_animation(nm):
					print("Länge %s %s %.2f s" % [id, nm, fa.anim.get_animation(nm).length])
	var letzt := {}
	var treffer := []     # [id, Bild des Aufschlags]
	var hit_anim := {}    # id -> [Start, Name] laufendes Zucken
	var gezuckt := []
	var text := ""
	var befunde := 0
	var n := 0
	var hp_vor := {}
	while n < 30 * 120:
		await process_frame
		n += 1
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if kf.ring_open:
			kf._answer_ring("GOOD")
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		var t := String(kf.shown.get("text", "")) if kf.shown is Dictionary else ""
		if t != text:
			text = t
			print("%6.2f Zeile: %s" % [n / 30.0, t])
		for id in kf.figures:
			var f = kf.figures[id]
			if f.fighter.side != "PARTY" or f.anim == null:
				continue
			var a := String(f.anim.current_animation)
			var hp: int = kf.shown.hp.get(id, f.fighter.hp) if kf.shown is Dictionary and kf.shown.has("hp") else f.fighter.hp
			if hp_vor.has(id) and hp < hp_vor[id]:
				print("%6.2f %s Leben %d -> %d (Anzeige)" % [n / 30.0, id, hp_vor[id], hp])
			hp_vor[id] = hp
			if a != letzt.get(id, ""):
				print("%6.2f %s Bewegung %s -> %s" % [n / 30.0, id, letzt.get(id, ""), a])
				if hit_anim.has(id):
					var dauer: float = (n - hit_anim[id][0]) / 30.0
					print("        %s zuckte %.2f s (%s)" % [id, dauer, hit_anim[id][1]])
					gezuckt.append([id, dauer])
					if dauer < float(hit_anim[id][2]) * ZUCK_ANTEIL:
						befunde += 1
					hit_anim.erase(id)
				if a == "Treffer" or a.begins_with("SS_GetHit"):
					hit_anim[id] = [n, a, f.anim.get_animation(a).length]
				letzt[id] = a
	print("ZUCKEN6011 %d Zuckungen, %d Befunde (abgebrochen vor %.0f %% der Länge)" % [gezuckt.size(), befunde, ZUCK_ANTEIL * 100])
	quit(befunde)
