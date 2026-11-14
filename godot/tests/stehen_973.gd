# 973 (930a A, Chef 11.11., 16:09; F3 in DESIGN-KAMPF.md): nach einem Tod bleiben die übrigen stehen, keine Neuformation; eine
# Figur bewegt sich nur aus Angriff, Platztausch oder Flucht im eigenen Zug, Ausweichen vor einem Angriff oder Weichen beim Tausch.
# Messung ohne Bild am echten Kampfort, Autopilot: nach dem ersten Tod darf sich der Heimatplatz (home, gegen den Boden gerechnet,
# weil die Kamera den Boden mitnimmt) keines Überlebenden ändern, außer einmal nach einem Wechsel seines Platzes nach den Regeln
# (shown.places).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/stehen_973.gd   (GEGNER=WOLVES,GOBLINS SEEDS=1-4)
# Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var liste := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES,GOBLINS"
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 4
	var befunde := 0
	var tode := 0
	for gegner in liste.split(","):
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
			var m = kf.mars
			m.find("merc").auto = true
			if m.set_autopilot(true) and not kf.busy:
				kf.go_on()
			var heim := {}
			var platz := {}
			var offen := {}     # Platz gewechselt, die neue Stelle noch nicht angefahren (wer Platz macht, geht erst nach dem Biss)
			var tot := false
			var falsch := 0
			var erst := ""
			for i in 30 * 120:
				await process_frame
				if m.outcome != "ONGOING" and not kf.busy:
					break
				var boden: Vector3 = kf._ground(0, 0)
				for id in kf.figures:
					var f = kf.figures[id]
					if f.dead_at >= 0 or f.down:
						if f.dead_at >= 0:
							tot = true
						continue
					var rel: Vector3 = f.home - boden
					var pl = kf.shown.places.get(id)
					if platz.has(id) and platz[id] != pl:
						offen[id] = true
					var rueckt: bool = heim.has(id) and rel.distance_to(heim[id]) > 0.05
					if rueckt and offen.get(id, false):
						offen[id] = false
					elif tot and rueckt and not f.fighter.fled:
						falsch += 1
						if erst == "":
							erst = "bei %.1f s: %s rückt %.2f m ohne neuen Platz (%s), Meldung %s von %s: %s" % [i / 30.0, id, rel.distance_to(heim[id]), str(pl), kf.shown.get("cue"), kf.shown.get("actor"), kf.shown.get("text", "")]
					heim[id] = rel
					platz[id] = pl
			if tot:
				tode += 1
			if falsch > 0:
				befunde += 1
			print("  %s Seed %d: Tod %s, %d Bilder mit Bewegung ohne Grund %s" % [gegner, s, "ja" if tot else "nein", falsch, erst])
			p.queue_free()
			for i in 5:
				await process_frame
	if tode == 0:
		print("  kein Tod gemessen")
		befunde += 1
	print("STEHEN973 %d" % befunde)
	quit(1 if befunde > 0 else 0)
