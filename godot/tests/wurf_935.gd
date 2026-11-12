# 935 (Fund t277.10, Chef 11.11., 20:34: „kein Wurf … Keine Parabel, die geworfen wurde, sondern ein
# nach vorne gerichteter Schubser“): am echten Kampfort wirft der Held Alchemistenfeuer auf einen Wolf. Geprüft: die Regeln melden
# den Wurf als Flasche (BOMB_FIRE, nicht FIRE_BOLT), der Held holt mit dem Hieb aus und lässt erst danach los, die Flasche fliegt im
# Bogen (Scheitel deutlich über der Geraden von der Hand zum Ziel, mitten im Flug am höchsten) und kommt am Ziel an.
# Regeln: Weihwasser findet Skelette als Ziel (untot nach „kennungen“ „gruppe“), die Wirkung wächst mit der Alchemie des Werfers
# (werte.json „kampftraenke“ wirkung_je_alchemie, wie sim.py).
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/wurf_935.gd   (Exit 0 = gut)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Zauber = preload("res://kampf/zauber.gd")
const Mars = preload("res://regeln/mars.gd")
const AufrufS = preload("res://kampf/aufruf.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_run.call_deferred()


func _regeln() -> void:
	var tab = Tabellen.lade()
	var skills := {}
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	var a = AufrufS.new()
	a.tabellen = tab
	var schaden := func(foe: String, ding: String, alchemie: int) -> int:
		var held = a._kaempfer("hero", tab.probe.FIGHTER.hero.hero, int(tab.probe.FIGHTER.hero.hp), Vector2i(Mars.FRONT, 0), skills)
		var foes = AufrufS.gegner(foe, monsters, Wuerfel.new(11))
		var m = Mars.new([held], foes, tab, Wuerfel.new(10), Wuerfel.new(289), 0, false, "HERO_FIRST")
		var fert: Dictionary = held.b.get("fert", {})     # Kampfblatt nach BRS, das Mars beim Einrichten setzt
		fert["Alchemie"] = alchemie
		held.b["fert"] = fert
		m.potions[ding] = 1
		m.start(func(_t, _x): return "NONE")
		if m.outcome != "ONGOING" or m.current() != held or m.throw_targets(ding).is_empty():
			return -1
		var t = m.throw_targets(ding)[0]
		t.max_hp = 500
		t.hp = 500
		var log: Array = m.act(["throw", ding, t.id], func(_t, _x): return "NONE")
		print("  %s %s Alchemie %d: %s" % [foe, ding, alchemie, " | ".join(PackedStringArray(log.map(func(e): return String(e.text)).slice(0, 3)))])
		return 500 - t.hp
	pruefe(monsters.has("skeleton") and bool(monsters["skeleton"].get("undead", false)), "Skelett ist untot")
	pruefe(monsters.has("wolf") and not bool(monsters["wolf"].get("undead", true)), "Wolf ist nicht untot")
	var weih: int = schaden.call("SKELETONS", "holy_water", 10)
	pruefe(weih > 0, "Weihwasser trifft ein Skelett (%d Schaden)" % weih)
	var f0: int = schaden.call("RATTE", "alchemist_fire", 0)
	var f20: int = schaden.call("RATTE", "alchemist_fire", 20)
	pruefe(f0 >= 0 and f20 > f0, "Alchemistenfeuer nach Alchemie: 0 → %d, 20 → %d Schaden" % [f0, f20])


func _run() -> void:
	_regeln()
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
	var ziel_da := Transform3D()     # wo das Ziel stand, als die Flasche ankam; danach zieht es weiter (Zug der Wölfe, Sterben)
	var ziel_box := AABB()
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
				var zf = kf.figures.get(ziel_id)
				if zf:
					ziel_da = zf.global_transform
					ziel_box = zf.footprint()
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
		# Lauf 360 (mit Kaufmodellen) maß gegen den Ort des Wolfs am Ende der Probe, nach seinem eigenen Zug: 1,78 m „daneben“, im
		# Film Treffer. Gemessen wird jetzt gegen sein Umriss in dem Bild, in dem die Flasche ankam (eine Handbreit darum)
		var tz = kf.figures.get(ziel_id)
		if tz and ziel_box.size != Vector3.ZERO:
			var lok: Vector3 = ziel_da.affine_inverse() * b
			var box := ziel_box.grow(0.25)
			var dx := maxf(0.0, maxf(box.position.x - lok.x, lok.x - box.end.x))
			var dz := maxf(0.0, maxf(box.position.z - lok.z, lok.z - box.end.z))
			var weg := Vector2(tz.global_position.x - ziel_da.origin.x, tz.global_position.z - ziel_da.origin.z).length()
			print("  Ziel zog nach der Ankunft noch %.2f m weiter; Umriss %.2f × %.2f m" % [weg, ziel_box.size.x, ziel_box.size.z])
			pruefe(Vector2(dx, dz).length() < 0.01, "kommt am Ziel an (%.2f m neben dem Umriss beim Aufschlag)" % Vector2(dx, dz).length())
	print("WURF935 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
