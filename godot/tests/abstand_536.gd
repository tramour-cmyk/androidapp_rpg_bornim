# 536 t268.20 (Chef 07.11.: „Grds. passt, aber Aktion der Jungwölfe dann sehr weit von Wolf weg“): am echten Kampfort im Hochformat,
# Probe Wolf mit Jungwölfen und Wolfsrudel, Autopilot, je Bild (--fixed-fps 30). Je Bild, in dem ein Wolf seine Ansage trägt: Abstand
# der Ansage (Unterkante) zum Kopf seines Wolfs, ohne und mit Namen (wie nach langem Drücken, names_until). Ausgabe: Mittel und Größtes
# je Lage in dp. Exit 0 = mit Namen im Mittel höchstens GRENZE_DP über dem Kopf.
# Aufruf: im Ordner godot mit --fixed-fps 30 -s res://tests/abstand_536.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 40
const GRENZE_DP := 60.0

var mass := {"ohne": [], "mit": []}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var faktor := float(OS.get_environment("SCHRIFT")) if OS.get_environment("SCHRIFT") != "" else 1.0
	Stil.schriftfaktor = faktor     # 544: Schriftgröße des Handys (t268.20: vorher größer stellen)
	print("ABSTAND536 Schriftgröße %.2f" % faktor)
	for foe in ["RUDEL", "WOLVES"]:
		for s in [3, 7]:
			seed(s)
			var p = Probe.new()
			p.hero_cls = "FIGHTER"
			p.merc_cls = "CLERIC"
			p.foe = foe
			root.add_child(p)
			await process_frame
			p._start(s)
			for i in 4:
				await process_frame
			var kf = p.fight
			kf.mars.find("merc").auto = true
			kf.mars.set_autopilot(true)
			if not kf.busy:
				kf.go_on()
			var n := 0
			while n < DAUER_BILDER and kf.mars.outcome == "ONGOING":
				# abwechselnd je 2 s ohne und mit Namen
				var mit := (n / 60) % 2 == 1
				kf.ui.names_until = Time.get_ticks_msec() + 3000 if mit else 0
				await process_frame
				n += 1
				if n % 60 > 10:     # nach dem Umschalten erst gleiten lassen
					_bild(kf, "mit" if mit else "ohne")
				if not kf.busy and not kf.playing and kf.beats.is_empty() and not kf.ring_open:
					if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
						kf.go_on()
			kf.queue_free()
			p.queue_free()
			await process_frame
	var fehler := 0
	for lage in ["ohne", "mit"]:
		var a: Array = mass[lage]
		var sum := 0.0
		var top := 0.0
		for v in a:
			sum += v
			top = maxf(top, v)
		var mittel := sum / maxf(1.0, a.size())
		print("ABSTAND536 %s Namen: %d Ansagen, über dem Kopf im Mittel %.0f dp, höchstens %.0f dp" % [lage, a.size(), mittel, top])
		if lage == "mit" and mittel > GRENZE_DP:
			print("FEHLER mit Namen im Mittel %.0f dp über dem Kopf (Grenze %.0f)" % [mittel, GRENZE_DP])
			fehler += 1
	quit(1 if fehler > 0 else 0)


func _bild(kf, lage: String) -> void:
	var ui = kf.ui
	for id in ui.sign_of:
		var f = kf.figures.get(id)
		if f == null or not kf.mars.wolfig(f.fighter.monster) or f.down:
			continue
		var r: Rect2 = ui.sign_of[id]
		var head: float = ui._foot(f).y - ui._tall(f)
		if r.position.y > head:     # unter den Pfoten: nicht gemessen
			continue
		mass[lage].append((head - r.end.y) / ui.dp)
