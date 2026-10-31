# 403: der Held je Klasse auf dem Kaufkörper im Kampfort (figur.gd _kaufheld, _arm_kauf). Ohne Bild: je Klasse kommt der
# Kaufheld (nicht held.bin), hat Stehen, Gehen und die Kampfbewegungen, die Waffe sitzt im Faustloch der rechten Hand, der Schild an
# der linken; der Kampf läuft auf Autopilot zu Ende ohne Skriptfehler. Ohne Kaufdateien (daten/held_<KLASSE>.bin,
# kampf-bewegungen.bin) meldet er „ohne Kauf“ und endet mit 0.
# Run: godot --headless --path godot -s res://tests/held_kampf_403.gd   (exit code 0 = alles richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const KLASSEN := ["FIGHTER", "CLERIC", "ROGUE", "WIZARD"]
const BEWEGUNGEN := ["Stehen", "Gehen", "Ausholen", "Hieb", "Stich", "Treffer", "Ausweichen", "Abwehr", "Tod"]

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _run() -> void:
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da("FIGHTER"):
		print("Held 403: ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	Engine.time_scale = 20.0
	for k in KLASSEN:
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start()
		for i in 4:
			await process_frame
		var fig = p.fight.figures.get("hero")
		_check(fig != null and fig.kauf, "%s: Held auf dem Kaufkörper" % k)
		if fig == null:
			continue
		var fehlt: Array = BEWEGUNGEN.filter(func(n): return not fig.anim.has_animation(n))
		_check(fehlt.is_empty(), "%s: Bewegungen da (fehlt: %s)" % [k, ", ".join(fehlt)])
		var sk := fig._find(fig.model, "Skeleton3D") as Skeleton3D
		var waffe := fig.model.find_child("Waffe", true, false) as Node3D
		var hat_waffe: bool = fig.fighter.hero.has("main") and not fig.fighter.hero.main.ranged
		if hat_waffe:
			var fr := HeldFigur.faust(sk, "r")
			var hand := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_r"))
			var soll: Vector3 = hand * (fr["griff"] as Vector3)
			var d := waffe.global_position.distance_to(soll) if waffe else 9.0
			_check(d < 0.005, "%s: %s im Faustloch (%.3f m daneben)" % [k, fig.fighter.hero.main.id, d])
			if String(fig.fighter.hero.main.id) in ["quarterstaff", "staff"]:     # Prüfer Film 403: Stab waagerecht auf den Nachbarn
				var oben: float = (waffe.global_transform.basis.y.normalized()).dot(Vector3.UP)
				_check(absf(oben) > 0.8, "%s: Stab in Ruhe senkrecht (%.2f)" % [k, oben])
		var schild: Node = fig.model.find_child("Schild", true, false)
		_check((schild != null) == (k in ["FIGHTER", "CLERIC"]), "%s: Schild nur bei Kämpfer und Kleriker (%s)" % [k, "da" if schild else "keiner"])
		# kein zweiter Schild oder Waffe auf dem Rücken (Unterwegs-Ausrüstung von HeldFigur.bewaffne; Chef 29.10.: Fehler)
		var teile: Array = fig.model.find_children("*", "BoneAttachment3D", true, false).filter(func(n): return not String(n.name).begins_with("Haar_"))
		_check(teile.size() == (1 if hat_waffe else 0) + (1 if schild else 0), "%s: nur Hand und Arm tragen (%d Anhänge)" % [k, teile.size()])
		# Kampf zu Ende auf Autopilot
		var kf = p.fight
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 60000:
			await process_frame
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:     # wie kampfort_lauf.gd: ohne Autopilot schlägt der Held das erste Ziel, das er erreicht
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		_check(kf.mars.outcome != "ONGOING", "%s: Kampf endet (%s)" % [k, kf.mars.outcome])
		kf.queue_free()
		p.queue_free()
		await process_frame
	print("Held 403: %d Fehler" % fails)
	quit(1 if fails > 0 else 0)
