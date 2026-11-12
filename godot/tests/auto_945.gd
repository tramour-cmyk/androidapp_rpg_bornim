# 945 (Chef 11.11., 13:29, t276.12; alt 241.2, Kotlin 20.10.): „Held und Söldner auf Automodus geschaltet. Jetzt sind wieder alle
# Schaltflächen weg. Ich kann es auch nicht mehr ausschalten.“ Messung ohne Bild: beide auf Auto, der Kampf läuft von selbst; in
# jedem Bild stehen „Held Auto“ und „Söldner Auto“ bedienbar in der Leiste. Mitten im Lauf beide abschalten: der Kampf hält beim
# nächsten eigenen Zug an, dort sind die Befehlsknöpfe wieder offen.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/auto_945.gd   (GEGNER=WOLVES, SEEDS=1-4)
# Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _schalter(ui, anfang: String):
	for b in ui.orders.find_children("*", "Button", true, false):
		if b.text.begins_with(anfang) and not b.is_queued_for_deletion():
			return b
	return null


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var gegner := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 4
	var befunde := 0
	for s in range(1, bis + 1):
		seed(s)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = gegner
		root.add_child(p)
		await process_frame
		p._start(s)
		for i in 4:
			await process_frame
		var kf = p.fight
		var ui = kf.ui
		var m = kf.mars
		m.find("merc").auto = true
		if m.set_autopilot(true) and not kf.busy:
			kf.go_on()
		var ohne := 0
		var erst := ""
		var gedrueckt := false
		var halt := false
		var offen := false
		for i in 30 * 120:
			await process_frame
			var laeuft: bool = m.outcome == "ONGOING" or kf.busy
			if not laeuft:
				break
			var held = _schalter(ui, "HELD")
			var sold = _schalter(ui, "SÖLDNER")
			if held == null or sold == null or held.disabled or sold.disabled:
				ohne += 1
				if erst == "":
					erst = "bei %.1f s: Held-Schalter %s, Söldner-Schalter %s (busy %s)" % [i / 30.0, "fehlt" if held == null else ("matt" if held.disabled else "da"), "fehlt" if sold == null else ("matt" if sold.disabled else "da"), kf.busy]
			# nach 4 s mitten im Lauf beide abschalten
			if not gedrueckt and i > 30 * 4 and kf.busy and held != null and sold != null and not held.disabled and not sold.disabled:
				held.pressed.emit()
				await process_frame
				sold = _schalter(ui, "SÖLDNER")
				if sold != null and not sold.disabled:
					sold.pressed.emit()
				gedrueckt = true
			if gedrueckt and not kf.busy and not kf.playing and kf.beats.is_empty():
				halt = m.outcome == "ONGOING" and not m.autopilot and not m.find("merc").auto
				var an = _schalter(ui, "ANGRIFF")
				offen = an != null and not an.disabled
				break
		var bad: bool = ohne > 0 or not gedrueckt or not halt or not offen
		if bad:
			befunde += 1
		print("  Seed %d: Schalter fehlten in %d Bildern %s; abgeschaltet %s, hält an %s, Knöpfe offen %s" % [s, ohne, erst, gedrueckt, halt, offen])
		p.queue_free()
		for i in 5:
			await process_frame
	print("AUTO945 %d" % befunde)
	quit(1 if befunde > 0 else 0)
