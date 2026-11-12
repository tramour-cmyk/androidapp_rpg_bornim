# 872 (Chef 10.11., 12:33: „Griff- und Spitzenpunkte je Gegenstand so ablegen, dass Jerry sie übernimmt statt je Gegner zu messen;
# Fertiges bei Jerry bleibt“): die Klinge im Kampf (Hiebplan 709) läuft vom Griff zur Spitze nach Halt.gegenstand statt längs des
# Netzkastens. Gegenprobe je Figur und Klinge: die Spitze liegt im Netz der Waffe (Kasten, 2 cm Luft), die Strecke ist 40–105 % der
# längsten Kante. Ohne Kampfmodelle (am Rechner ohne Bau) nichts zu prüfen, Exit 0.
# Run: godot --headless --path godot -s res://tests/halt_872.gd   (Exit 0 = alle Klingen stimmig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_all.call_deferred()


func _all() -> void:
	if not FileAccess.file_exists("res://kampf/daten/longsword.bin"):
		print("HALT872 ohne Kampfmodelle, nichts zu prüfen")
		quit(0)
		return
	var fehler := 0
	var klingen := 0
	for foe in ["GOBLINS", "KOBOLDS", "GRAK", "KROGG"]:
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = foe
		root.add_child(p)
		await process_frame
		p._start(1)
		for i in 10: await process_frame
		var k = p.fight
		for id in k.figures:
			var fig = k.figures[id]
			for at in fig.find_children("*", "BoneAttachment3D", true, false):
				var hm: Dictionary = fig.klinge_halt(at)
				if hm.is_empty():
					continue
				klingen += 1
				var w := at.get_child(0) as Node3D
				var a: Vector3 = w.global_transform * (hm["griff"] as Vector3)
				var b: Vector3 = w.global_transform * (hm["spitze"] as Vector3)
				var drin := false
				var kante := 0.0
				for mm in at.find_children("*", "MeshInstance3D", true, false):
					var bb: AABB = (mm as MeshInstance3D).get_aabb()
					var sc: Vector3 = (mm as MeshInstance3D).global_transform.basis.get_scale()
					kante = maxf(kante, (bb.size * sc)[bb.get_longest_axis_index()])
					if bb.grow(0.02 / maxf(sc.x, 0.001)).has_point((mm as MeshInstance3D).global_transform.affine_inverse() * b):
						drin = true
				var anteil: float = a.distance_to(b) / maxf(kante, 0.001)
				var gut: bool = drin and anteil >= 0.4 and anteil <= 1.05
				if not gut:
					fehler += 1
				print("%s %s %s %s: Griff bis Spitze %.2f m, längste Kante %.2f m (%.0f %%), Spitze im Netz %s" % ["gut" if gut else "FALSCH", foe, id, String(at.get_meta("was")), a.distance_to(b), kante, anteil * 100.0, drin])
		p.queue_free()
		await process_frame
	print("HALT872 %d Klingen, %d Fehler" % [klingen, fehler])
	quit(1 if fehler > 0 or klingen == 0 else 0)
