# 601.1 (Chef 15.11., 11:02, Film 601 Späher: „trifft dann unten eher in der Fußspitze, aber er zuckt oben zurück“): wo ein
# treffendes Geschoss am Schirm einschlägt, gemessen gegen den Rumpf des Getroffenen (dort zuckt er: SS_GetHitLightFront,
# „Treffer“). Ohne Bild: Probekampf Goblin-Späher (GEGNER=SCOUTS), Held Kämpfer, Söldner Magier; Pfeil vom Späher auf Held und
# Söldner, Feuerpfeil und Strahlen vom Magier auf den Späher, je 12 Würfe (Zufall des Einschlags wie zauber.gd treff_bild).
# Gemessen je Wurf: Abstand des Einschlags am Schirm zum Rumpf (Kapseln Becken bis Hals, beim Tier Rücken, Brust, Hals; je als
# Strecke am Schirm mit ihrem Halbmesser), in Teilen der Figurenhöhe am Schirm; dazu die Höhe über dem Fuß (0 Fuß, 1 Namensbalken).
# „vorher“ ist die alte Rechnung (Balkenhöhe × 0,55 vor dem Umriss, Streuung ± 7 u, Pfeil 9 u tiefer), „jetzt“ die gebaute.
# Befund: ein Wurf „jetzt“ mehr als 0,03 Figurenhöhe neben dem Rumpf. Ohne Gerüst (am Rechner ohne Kaufmodelle) nur Auskunft.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/einschlag_6011.gd     Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Zauber = preload("res://kampf/zauber.gd")

const WUERFE := 12
const GRENZE := 0.03


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	seed(5)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "WIZARD"
	p.foe = "SCOUTS"
	root.add_child(p)
	await process_frame
	p._start(5)
	for i in 30:
		await process_frame
	var kf = p.fight
	var ui = kf.ui
	var held = null
	var magier = null
	var spaeher = null
	for f in kf.mars.fighters():
		if not f.standing():
			continue
		if f.side == "PARTY" and f.hero != null and f.hero.cls == "WIZARD":
			magier = kf.figures[f.id]
		elif f.side == "PARTY" and held == null:
			held = kf.figures[f.id]
		elif f.side == "FOES" and spaeher == null:
			spaeher = kf.figures[f.id]
	if held == null or magier == null or spaeher == null:
		print("FEHLER: Held, Magier oder Späher fehlt im Probekampf")
		quit(1)
		return
	var befunde := 0
	var ohne_geruest := 0
	for fall in [["ARROW", spaeher, held], ["ARROW", spaeher, magier], ["FIRE_BOLT", magier, spaeher], ["RAYS", magier, spaeher]]:
		var kind: String = fall[0]
		var by = fall[1]
		var on = fall[2]
		var rumpf := _rumpf(on)
		var dir: Vector3 = (on.position - by.position) * Vector3(1, 0, 1)
		dir = dir.normalized() if dir.length() > 0.01 else Vector3.ZERO
		var hand = by.cast_point()
		var von: Vector3 = hand if hand != null else by.position + Vector3.UP * (by.head().y - by.position.y) * ui.START_UP + dir * (ui._girth(by) + 0.1)
		var fuss: Vector2 = kf.screen_of(on.position)
		var tall: float = ui._tall(on)
		var u := tall / 40.0
		var alt3: Vector3 = on.position + Vector3.UP * (on.head().y - on.position.y) * 0.55 - dir * ui._girth(on)
		var neu3: Vector3 = ui._aim_point(on, dir, von)
		var genau: bool = ui._aim_genau
		if not genau:
			ohne_geruest += 1
		var zeile := {"vorher": [], "jetzt": []}
		for art in ["vorher", "jetzt"]:
			var weit := 0.0
			var hoch_min := INF
			var hoch_max := -INF
			for w in WUERFE:
				Zauber.ziel_genau = genau and art == "jetzt"
				var ziel: Vector2 = kf.screen_of(alt3 if art == "vorher" else neu3)
				var hit: Vector2 = ui.zauber.treff_bild(kind, 7919 * (w + 1), ziel, u)
				var ab := _abstand(kf, rumpf, hit) / maxf(tall, 1.0)
				var hoch := (fuss.y - hit.y) / maxf(tall, 1.0)
				weit = maxf(weit, ab)
				hoch_min = minf(hoch_min, hoch)
				hoch_max = maxf(hoch_max, hoch)
			zeile[art] = [weit, hoch_min, hoch_max]
		Zauber.ziel_genau = false
		var v: Array = zeile["vorher"]
		var j: Array = zeile["jetzt"]
		var schlecht: bool = genau and float(j[0]) > GRENZE
		if schlecht:
			befunde += 1
		print("EINSCHLAG6011 %s %s → %s: vorher neben dem Rumpf bis %.2f, Höhe %.2f–%.2f | jetzt bis %.2f, Höhe %.2f–%.2f%s%s" % [
			"FALSCH" if schlecht else "ok", kind, on.fighter.id, v[0], v[1], v[2], j[0], j[1], j[2],
			"" if genau else " (ohne Gerüst, geschätzt)", "" if not rumpf.is_empty() else " (kein Rumpf)"])
	if ohne_geruest > 0:
		print("EINSCHLAG6011 Auskunft: %d Ziele ohne Gerüst (am Rechner ohne Kaufmodelle)" % ohne_geruest)
	print("EINSCHLAG6011 %s" % ("gut" if befunde == 0 else "FALSCH %d" % befunde))
	quit(1 if befunde else 0)


## Rumpf als Kapseln [a, b, r] (Welt): Mensch Becken bis Hals, Tier nach Namen (wie Figur.RUMPF_TEILE)
func _rumpf(on) -> Array:
	var out: Array = []
	if on.fighter.monster == null:
		for c in on.kapseln():
			if float(c[2]) >= 0.13:
				out.append(c)
		return out
	for c in on.koerper():
		var nm := String(c[3]).to_lower() if c.size() > 3 else ""
		for w in ["spine", "chest", "belly", "waist", "body", "torso", "abdomen", "thorax", "neck", "hals", "root", "pelvis"]:
			if nm.contains(w):
				out.append(c)
				break
	return out


## Abstand (px) des Schirmpunkts q zur nächsten Rumpfkapsel am Schirm (0 innen); ohne Rumpf INF
func _abstand(kf, rumpf: Array, q: Vector2) -> float:
	var best := INF
	for c in rumpf:
		var a: Vector2 = kf.screen_of(c[0])
		var b: Vector2 = kf.screen_of(c[1])
		var r: float = (kf.screen_of(c[0]) - kf.screen_of(c[0] + kf.cam.global_transform.basis.x * float(c[2]))).length()
		var nah: Vector2 = Geometry2D.get_closest_point_to_segment(q, a, b)
		best = minf(best, maxf(0.0, q.distance_to(nah) - r))
	return best
