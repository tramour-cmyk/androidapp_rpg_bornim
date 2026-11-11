# 935 (Fund t277.10, Chef 11.11., 20:34: „kein Wurf … Keine Parabel, die geworfen wurde, sondern ein
# nach vorne gerichteter Schubser“): am echten Kampfort wirft der Held Alchemistenfeuer auf einen Wolf. Geprüft: die Regeln melden
# den Wurf als Flasche (BOMB_FIRE, nicht FIRE_BOLT), der Held holt mit dem Hieb aus und lässt erst danach los, die Flasche fliegt im
# Bogen (Scheitel deutlich über der Geraden von der Hand zum Ziel, mitten im Flug am höchsten) und kommt am Ziel an.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/wurf_935.gd   (Exit 0 = gut)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Zauber = preload("res://kampf/zauber.gd")

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1080, 2340)
	await process_frame
	seed(3)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(3)
	for i in 4:
		await process_frame
	var kf = p.fight
	pruefe(kf != null, "Kampfort steht")
	if kf == null:
		quit(1)
		return
	var m = kf.mars
	if m.find("merc") != null:
		m.find("merc").auto = true
	m.potions["alchemist_fire"] = 3
	Zauber.pruef = true
	if not kf.busy:
		kf.go_on()
	var n := 0
	var geworfen := false
	var befehl_ms := 0.0
	var spur: Array = []        # Bahnpunkte der Flasche im Raum, je Bild einer
	var art := ""
	var los_ms := -1.0
	var hieb := false
	var ziel_id := ""
	while n < 30 * 90:
		await process_frame
		n += 1
		if geworfen:
			for sp in kf.ui.spells:
				if String(sp.by) == "hero" and art == "":
					art = String(sp.kind)
					los_ms = float(sp.t0) - befehl_ms
			var held = kf.figures.get("hero")
			if held and held.anim and held.anim.current_animation == "Hieb":
				hieb = true
			if Zauber.bahn.size() > 0 and art != "":
				spur.append(Zauber.bahn[-1])
			if n > 30 * 4 and not kf.busy and not kf.playing:
				break
			continue
		if m.outcome != "ONGOING":
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty():
			if m.pilot_next():
				kf.go_on()
				continue
			var c = m.current()
			if c != null and c.id == "hero" and not m.throw_targets("alchemist_fire").is_empty():
				ziel_id = String(m.throw_targets("alchemist_fire")[0].id)
				befehl_ms = kf.clock_ms
				kf.order(["throw", "alchemist_fire", ziel_id])
				geworfen = true
				n = 0
			else:
				var ts: Array = m.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	pruefe(geworfen, "Held wirft Alchemistenfeuer auf %s" % ziel_id)
	pruefe(art == "BOMB_FIRE", "fliegt als Flasche (%s)" % art)
	var hf = kf.figures.get("hero")
	if hf and hf.anim and hf.anim.has_animation("Hieb"):
		pruefe(hieb, "Held holt mit dem Hieb aus")
	else:
		print("  Held ohne Bewegung „Hieb“ (am Rechner ohne Modelle): Ausholen nicht geprüft")
	pruefe(los_ms >= 200.0, "Flasche fliegt erst nach dem Ausholen los (%.0f ms nach dem Befehl)" % los_ms)
	pruefe(spur.size() >= 6, "Bahn hat %d Punkte" % spur.size())
	if spur.size() >= 6:
		var a: Vector3 = spur[0]
		var b: Vector3 = spur[-1]
		var hoechst := 0
		var ueber := 0.0
		for i in spur.size():
			var q: Vector3 = spur[i]
			var t := float(i) / (spur.size() - 1)
			var gerade := lerpf(a.y, b.y, t)
			if q.y - gerade > ueber:
				ueber = q.y - gerade
				hoechst = i
		var weite := Vector2(b.x - a.x, b.z - a.z).length()
		print("  Weite %.1f m, Scheitel %.2f m über der Geraden bei Punkt %d von %d, Start %.2f m hoch, Ende %.2f m" % [weite, ueber, hoechst, spur.size(), a.y, b.y])
		pruefe(ueber >= 0.2 * weite, "im Bogen: Scheitel %.2f m bei %.1f m Weite" % [ueber, weite])
		pruefe(hoechst > spur.size() * 0.25 and hoechst < spur.size() * 0.75, "Scheitel mitten im Flug")
		var tz = kf.figures.get(ziel_id)
		if tz:
			var dz := Vector2(b.x - tz.global_position.x, b.z - tz.global_position.z).length()
			pruefe(dz < 1.5, "kommt am Ziel an (%.2f m daneben)" % dz)
	print("WURF935 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
