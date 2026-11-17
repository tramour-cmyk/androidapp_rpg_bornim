# 751 (Chef 09.11., 14:00, Build 271: „manchmal verschwindet das einfach alles“, unter Alriks Leiste nur „…“, keine Knöpfe; Bild
# Wolfsrudel nach „Wolf 2 prallt gegen Alrik“): Messung ohne Bild am Kampfort, Autopilot für beide Seiten, je Seed ein Kampf; meldet,
# wenn der Kampfort länger als HAENGT_S steht: eine Meldung spielt und kommt nicht zum Ende (playing), oder er ist beschäftigt (busy),
# ohne dass eine Meldung wartet oder spielt (der Regelfaden hängt). Dazu je Kampf die längste und die mittlere Zeit, in der die
# Knopfleiste „…“ zeigt (busy), und die längste Wartezeit einer einzelnen Meldung. Exit 0 = kein Hänger.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/haenger_751.gd   (GEGNER=WOLVES, SEEDS=1-12, KLASSEN)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const HAENGT_S := 30.0     # so lange ohne Fortgang gilt als Hänger

func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var gegner := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 12
	var klassen := OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC"])
	var haenger := 0
	for k in klassen:
		for s in range(1, bis + 1):
			seed(s)
			var p = Probe.new()
			p.hero_cls = k
			p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
			p.foe = gegner
			root.add_child(p)
			await process_frame
			p._start(s)
			for i in 4:
				await process_frame
			var kf = p.fight
			kf.mars.find("merc").auto = true     # der Held wählt selbst (Angriff aufs erste Ziel), so zählt „…“ wie beim Spieler
			if not kf.busy:
				kf.go_on()
			var steht := 0
			var letzte := ""
			var n := 0
			var span := 0
			var spans: Array = []
			while n < 30 * 240:
				await process_frame
				n += 1
				if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
					break
				if kf.busy:
					span += 1
				elif span > 0:
					spans.append(span / 30.0)
					span = 0
				var haengt: bool = kf.playing or (kf.busy and kf.beats.is_empty())
				if haengt:
					steht += 1
				else:
					steht = 0
				var zl: String = kf.shown.get("text", "") if kf.shown is Dictionary else ""
				if zl != "":
					letzte = zl
				if steht > 30 * HAENGT_S:
					print("HAENGER %s Seed %d nach %.1f s: playing %s busy %s Meldungen %d ring %s verhuellt %s letzte Zeile „%s“" % [k, s, n / 30.0, kf.playing, kf.busy, kf.beats.size(), kf.ring_open, kf.verhuellt, letzte])
					haenger += 1
					break
				if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
					if kf.mars.pilot_next():
						kf.go_on()
					else:
						var c = kf.mars.current()
						var ts: Array = kf.mars.targets(c)
						kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
			var lang := 0.0
			var summe := 0.0
			for x in spans:
				lang = maxf(lang, x)
				summe += x
			print("  %s Seed %d: %s nach %.1f s, „…“ längstens %.1f s, im Mittel %.1f s (%d Mal)" % [k, s, kf.mars.outcome, n / 30.0, lang, summe / maxf(spans.size(), 1), spans.size()])
			p.queue_free()
			for i in 5:
				await process_frame
	print("HAENGER751 %d" % haenger)
	quit(1 if haenger > 0 else 0)
