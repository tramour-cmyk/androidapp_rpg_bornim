# 751 A (Chef 09.11., 17:46; 21:18 t272): Messung ohne Bild: solange der Kampf läuft (gezeigt, nicht vorausberechnet), stehen die
# Befehlsknöpfe (matt, wenn ein anderer dran ist), die Zugleiste hat Einträge, und nichts verrät den vorausberechneten Ausgang
# (Kasten des Helden, Zugleiste, Knopfleiste). Je Bild prüft der Test die Bedingungen, die kampf_ui.gd zum Zeichnen nimmt.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/leiste_751.gd   (GEGNER=WOLVES, SEEDS=1-12, KLASSEN)
# Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var gegner := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 12
	var klassen := OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC", "WIZARD"])
	var befunde := 0
	for kl in klassen:
		for s in range(1, bis + 1):
			seed(s)
			var p = Probe.new()
			p.hero_cls = kl
			p.merc_cls = "FIGHTER" if kl != "FIGHTER" else "CLERIC"
			p.foe = gegner
			root.add_child(p)
			await process_frame
			p._start(s)
			for i in 4:
				await process_frame
			var kf = p.fight
			var ui = kf.ui
			kf.mars.find("merc").auto = true
			if not kf.busy:
				kf.go_on()
			var n := 0
			var leer := 0
			var verraten := 0
			var ohne_knopf := 0
			var erst := ""
			while n < 30 * 240:
				await process_frame
				n += 1
				var m = kf.mars
				if m.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
					break
				var ended: bool = m.outcome != "ONGOING" and not kf.busy
				if not ended:
					var q := 0
					for id in kf.shown.get("queue", []):
						var f = m.find(id)
						if f != null and kf.shown.hp.get(id, f.hp) > 0:
							q += 1
					if q == 0:
						leer += 1
						if erst == "":
							erst = "Zugleiste leer bei %.1f s (busy %s, outcome %s)" % [n / 30.0, kf.busy, m.outcome]
					# Kasten des Helden: hebt er den hervor, der laut Zugleiste dran ist?
					var vorn = ui._vorn()
					if vorn != null and vorn.side == "PARTY" and not ui._party_box_dran(vorn):
						verraten += 1
						if erst == "":
							erst = "Kasten ohne ▶ bei %.1f s (outcome %s)" % [n / 30.0, m.outcome]
					# Knöpfe stehen immer; solange ein anderer zieht, nur Söldner und Held Auto bedienbar; keine Zeile „ist dran“ mehr (1095)
					var knoepfe := 0
					var offen := 0
					for b in ui.orders.find_children("*", "Button", true, false):
						if b.is_queued_for_deletion():
							continue
						knoepfe += 1
						if not b.disabled and not (b.text.begins_with("SÖLDNER") or b.text.begins_with("HELD")):
							offen += 1
					var zeile := ""
					for c in ui.orders.get_children():
						if c is Label and not c.is_queued_for_deletion():
							zeile = c.text
							break
					if knoepfe == 0 or zeile.ends_with(" ist dran") or (kf.busy and offen > 0):
						ohne_knopf += 1
						if erst == "":
							erst = "Leiste bei %.1f s: %d Knöpfe, %d offen, Zeile „%s“ (busy %s)" % [n / 30.0, knoepfe, offen, zeile, kf.busy]
				if not kf.busy and not kf.playing and kf.beats.is_empty() and m.outcome == "ONGOING":
					if m.pilot_next():
						kf.go_on()
					else:
						var c = m.current()
						var ts: Array = m.targets(c)
						kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
			var bad: bool = leer > 0 or verraten > 0 or ohne_knopf > 0
			if bad:
				befunde += 1
			print("  %s Seed %d: %s nach %.1f s; Zugleiste leer %d, Kasten verrät %d, Leiste falsch %d Bilder %s" % [kl, s, kf.mars.outcome, n / 30.0, leer, verraten, ohne_knopf, erst])
			p.queue_free()
			for i in 5:
				await process_frame
	# Autopilot an, mitten im Zug der Gegner (busy) „Held Auto“ antippen: der Kampf hält beim nächsten eigenen Zug an
	seed(1)
	var p2 = Probe.new()
	p2.hero_cls = "FIGHTER"
	p2.merc_cls = "CLERIC"
	p2.foe = gegner
	root.add_child(p2)
	await process_frame
	p2._start(1)
	for i in 4:
		await process_frame
	var k2 = p2.fight
	k2.mars.find("merc").auto = true
	if k2.mars.set_autopilot(true) and not k2.busy:
		k2.go_on()
	var gedrueckt := false
	var halt := false
	for i in 30 * 120:
		await process_frame
		if not gedrueckt and k2.busy and i > 30 * 4:
			for b in k2.ui.orders.find_children("*", "Button", true, false):
				if b.text.begins_with("HELD") and not b.disabled and not b.is_queued_for_deletion():
					b.pressed.emit()
					gedrueckt = true
					break
		if gedrueckt and not k2.busy and not k2.playing and k2.beats.is_empty():
			halt = k2.mars.outcome == "ONGOING" and not k2.mars.autopilot
			break
	print("  Autopilot im Zug der Gegner ab: gedrückt %s, hält an %s" % [gedrueckt, halt])
	if not halt:
		befunde += 1
	p2.queue_free()
	print("LEISTE751 %d" % befunde)
	quit(1 if befunde > 0 else 0)
