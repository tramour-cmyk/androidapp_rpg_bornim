# 1284 (Chef 15.11., 12:07, Test Build 286, Wald: „Riesenratte Biss, aber die macht gar keinen Biss … klappt es nur, wenn sie
# trifft“): Probekampf gegen Ratten ohne Bild, Autopilot. Je Angriff einer Ratte auf Held oder Söldner: Ausgang (Treffer, verfehlt,
# abgewehrt), welche Bewegungen die Ratte vom Ansagen bis daheim spielt, ob „Biss“ dabei war, und wie nah ihr Kopf dem Ziel kam.
# Richtig: jeder Angriff zeigt die Bissbewegung, bei jedem Ausgang; daneben schnappen die Zähne knapp vor Körper oder Schild zu. Zeilen „BISS1284 …“; Exit 1, wenn ein Angriff ohne Biss blieb oder in die Luft biss.
# Aufruf im Ordner godot: --headless --fixed-fps 30 -s res://tests/biss_1284.gd  (GEGNER=RATS, KLASSEN=FIGHTER,CLERIC, SEED=7)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 150

const LUECKE_DANEBEN := 0.25     # daneben: Zähne höchstens so weit vor Körper oder Schild (Figur.BISS_DANEBEN 0,12, der Held weicht aus)
const LUECKE_TIEF := -0.05       # daneben: nicht tiefer im Körper (sonst sähe es aus wie ein Treffer)
const KOPF := ["Head", "Jaw", "Tongue", "kopf", "Mouth", "mouth", "Fang", "fang"]
var befund := 0
var angriffe := 0
var lauf := {}     # Ratte -> {"anims": [], "ziel": id, "nah": float, "seit": Bild}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "RATS").split(",")
	var klassen := (OS.get_environment("KLASSEN") if OS.get_environment("KLASSEN") != "" else "FIGHTER,CLERIC").split(",")
	for g in gegner:
		for k in klassen:
			var sd := int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
			seed(sd)
			var p = Probe.new()
			p.hero_cls = k
			p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
			p.foe = g
			root.add_child(p)
			await process_frame
			p._start(sd)
			for i in 4:
				await process_frame
			var kf = p.fight
			if kf == null:
				print("BISS1284 kein Kampf %s/%s" % [g, k])
				befund += 1
				p.queue_free()
				continue
			if kf.mars.find("merc") != null:
				kf.mars.find("merc").auto = true
			kf.mars.set_autopilot(true)
			if not kf.busy:
				kf.go_on()
			lauf.clear()
			var n := 0
			var shown_vor = null
			while n < DAUER_BILDER:
				await process_frame
				n += 1
				var e: Dictionary = kf.shown
				if e != shown_vor and not e.is_empty():
					shown_vor = e
					_meldung(kf, e, n, "%s/%s" % [g, k])
				_bild(kf, n)
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
				_ende(id, "%s/%s" % [g, k])
			print("BISS1284 Kampf %s/%s: %s nach %d Bildern" % [g, k, kf.mars.outcome, n])
			kf.queue_free()
			p.queue_free()
			await process_frame
	print("BISS1284 %d Angriffe, %d Fehler" % [angriffe, befund])
	quit(1 if befund > 0 else 0)


## eine neue Meldung: greift eine Ratte an, beginnt ihr Lauf (der alte endet)
func _meldung(kf, e: Dictionary, n: int, kampf: String) -> void:
	var actor = e.get("actor")
	if actor == null or not kf.figures.has(actor) or kf.figures[actor].fighter.monster == null:
		return
	var roll = e.get("roll")
	var ausgang := "?"
	if roll != null and roll is Array and roll.size() > 4:
		ausgang = "Treffer" if roll[4] else "daneben"
	var txt := str(e.get("text", e.get("cue", "")))
	if OS.get_environment("ALLE") != "":
		print("BISS1284 Bild %d %s Meldung %s: %s roll %s" % [n, kampf, actor, txt, str(roll)])
	if txt.contains(": Biss!") or txt.contains(": Sprungbiss!"):
		if lauf.has(actor):
			_ende(actor, kampf)
		lauf[actor] = {"anims": [], "ziel": "", "nah": INF, "seit": n, "ausgang": "?", "text": txt}
	elif lauf.has(actor) and lauf[actor]["ausgang"] == "?":
		lauf[actor]["ausgang"] = ausgang if roll != null else "Treffer"
		lauf[actor]["text"] = txt
		lauf[actor]["ziel"] = str(e.get("target")) if e.get("target") != null else ""


func _bild(kf, n: int) -> void:
	for id in lauf.keys():
		var f = kf.figures.get(id)
		if f == null:
			continue
		var a: String = String(f.anim.current_animation) if f.anim else ""
		var l: Array = lauf[id]["anims"]
		if l.is_empty() or l[l.size() - 1] != a:
			l.append(a)
		# Lücke der Zähne (Kopf, Kiefer) zu Körper oder Schild jedes Helden, solange sie beißt
		if a == "Biss" or a == "Sprungbiss" or a == "Bisskette":
			for z in kf.figures.values():
				if z.fighter.monster == null and z.visible and not z.down:
					var lu: Array = _luecke(f, z)
					var g: Dictionary = lauf[id].get("gap", {})
					g[z.fighter.id] = minf(float(g.get(z.fighter.id, INF)), minf(lu[0], lu[1]))
					lauf[id]["gap"] = g
					var gk: Dictionary = lauf[id].get("gapk", {})
					gk[z.fighter.id] = Vector2(minf(float(gk.get(z.fighter.id, Vector2.INF).x), lu[0]), minf(float(gk.get(z.fighter.id, Vector2.INF).y), lu[1]))
					lauf[id]["gapk"] = gk


func _ende(id: String, kampf: String) -> void:
	var r: Dictionary = lauf[id]
	lauf.erase(id)
	if r["ziel"] != "":
		angriffe += 1
	var gap: float = float(r.get("gap", {}).get(r["ziel"], INF))
	var biss: bool = r["anims"].has("Biss") or r["anims"].has("Sprungbiss") or r["anims"].has("Bisskette")
	if r["ziel"] == "":
		return     # nur Ansage, kein Angriff
	# richtig: Biss gespielt; daneben schnappen die Zähne vor dem Körper zu, nicht weiter als LUECKE_DANEBEN und nicht tiefer als
	# LUECKE_TIEF darin (der Schild darf sie abfangen); beim Treffer nur Auskunft (wie tief er sitzt, prüft treffen_709, 709)
	var koerper: float = float(r.get("gapk", {}).get(r["ziel"], Vector2.INF).x)
	var gut: bool = biss and (r["ausgang"] != "daneben" or (gap <= LUECKE_DANEBEN and koerper >= LUECKE_TIEF))
	if not gut:
		befund += 1
	print("BISS1284 %s %s %s an %s, %s (Bild %d): %s, Lücke der Zähne %.2f m (Körper %.2f, Schild %.2f), Bewegungen %s – %s" % ["gut" if gut else "FEHLER", kampf, id, r["ziel"], r["ausgang"], r["seit"], "Biss" if biss else "OHNE BISS", gap, r.get("gapk", {}).get(r["ziel"], Vector2.INF).x, r.get("gapk", {}).get(r["ziel"], Vector2.INF).y, r["anims"], r["text"]])


## Zähne: Kapseln von Kopf und Kiefer der Ratte (wie treffen_709 _waffe ohne Waffe)
func _zaehne(f) -> Array:
	var out: Array = []
	for c in f.kapseln():
		if c.size() > 3:
			for w in KOPF:
				if String(c[3]).contains(w):
					out.append(c)
					break
	return out


## [Lücke zum Körper, Lücke zum Schild] wie treffen_709 _luecke
func _luecke(a, b) -> Array:
	var best := INF
	var schild := INF
	var ws: Array = _zaehne(a)
	for w in ws:
		for c in b.koerper():
			var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
			best = minf(best, pq[0].distance_to(pq[1]) - float(w[2]) - float(c[2]))
	for g in b.traegt():
		if not String(g[2]).to_lower().contains("shield"):
			continue
		var inv: Transform3D = (g[0] as Transform3D).affine_inverse()
		var box: AABB = g[1]
		var sc: float = absf((g[0] as Transform3D).basis.get_scale().x)
		for w in ws:
			for j in 9:
				var q: Vector3 = inv * (w[0] as Vector3).lerp(w[1], j / 8.0)
				var dx := maxf(box.position.x - q.x, q.x - box.end.x)
				var dy := maxf(box.position.y - q.y, q.y - box.end.y)
				var dz := maxf(box.position.z - q.z, q.z - box.end.z)
				var d: float = (maxf(dx, maxf(dy, dz)) if dx <= 0 and dy <= 0 and dz <= 0 else Vector3(maxf(dx, 0), maxf(dy, 0), maxf(dz, 0)).length()) * sc
				schild = minf(schild, d - float(w[2]))
	return [best, schild]
