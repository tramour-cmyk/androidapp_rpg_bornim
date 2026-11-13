# 973 (930a A, Chef 11.11., 16:09: „wenn es dann einer ist, der muss dann auch nicht automatisiert wieder in die Mitte rücken …
# unnötige Bewegungen … kann man sich sparen“; DESIGN-KAMPF.md F3): nach einem Tod bleiben die übrigen Gegner, wo sie stehen.
# Messung ohne Bild am echten Kampfort, Wolfsrudel und Goblins, Autopilot: fällt ein Gegner, darf sich der Platz (home) keines
# anderen stehenden Gegners ändern, solange sein Platz nach den Regeln (shown.places) derselbe bleibt.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/nachruecken_973.gd   (SEEDS=1-3). Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 3
	var befunde := 0
	var tode := 0
	for gegner in ["WOLVES", "GOBLINS"]:
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
			var lebt := {}
			var heim := {}
			var platz := {}
			var falsch := 0
			var erst := ""
			for i in 30 * 120:
				await process_frame
				if m.outcome != "ONGOING" and not kf.busy:
					break
				var gefallen := false
				for id in kf.figures:
					var f = kf.figures[id].fighter
					if f.side != "FOES":
						continue
					var hp: int = kf.shown.hp.get(id, f.hp)
					if lebt.get(id, true) and hp <= 0 and not f.fled:
						gefallen = true
					lebt[id] = hp > 0
				if gefallen:
					tode += 1
					heim.clear()
					for id in kf.figures:
						var f = kf.figures[id].fighter
						if f.side == "FOES" and lebt.get(id, false) and kf.shown.places.has(id):
							heim[id] = kf.figures[id].home
							platz[id] = kf.shown.places[id]
				for id in heim.keys():
					if not lebt.get(id, false) or not kf.shown.places.has(id) or kf.shown.places[id] != platz[id]:
						heim.erase(id)     # selbst gefallen, geflohen oder nach den Regeln anderer Platz: Bewegung mit Grund
						continue
					var d: float = Vector2(kf.figures[id].home.x - heim[id].x, kf.figures[id].home.z - heim[id].z).length()
					if d > 0.05:
						falsch += 1
						if erst == "":
							erst = "%s bei %.1f s: Platz um %.2f m verschoben, ohne neuen Platz nach den Regeln" % [id, i / 30.0, d]
						heim.erase(id)
			print("  %s Seed %d: %d Verschiebungen nach einem Tod %s" % [gegner, s, falsch, erst])
			if falsch > 0:
				befunde += 1
			p.queue_free()
			for i in 5:
				await process_frame
	if tode == 0:
		print("  kein Tod gemessen")
		befunde += 1
	print("NACHRUECKEN973 %d (Tode %d)" % [befunde, tode])
	quit(1 if befunde > 0 else 0)
