# 864 (Chef 10.11., 13:26, t274.16 Fledermäuse; 11.11., 07:08, t275 Grabhunde: „als ich an der Reihe war, gab es wieder diesen
# kleinen Beam-Schritt … in die Ausgangsgegnerlage zurück“): Messung ohne Bild am echten Kampfort. Der Held zieht von Hand (wie im
# Spiel: Knöpfe im Kasten), die Gegner und der Söldner nach Autopilot. Solange der Held am Zug ist (nichts läuft), darf keine lebende
# Figur gegenüber dem Boden springen (weiter als SPRUNG_M in einem Bild); rückt der Boden, weil die Kamera neu passt (der Kasten wächst
# von „…“ zu den Knöpfen), zählt nur, was darüber hinausgeht. Ursache vorher: kampfort._fit_camera setzte jeden auf seinen Platz.
# Run: GEGNER=BATS,GRABHUNDE godot --headless --path godot --fixed-fps 30 -s res://tests/beam_864.gd
# Exit 0 = kein Sprung, 1 sonst; BEAM_LOG=1 druckt auch Sprünge in den Zügen (ohne Kaufmodelle am Rechner nicht aussagekräftig).
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const SPRUNG_M := 0.12     # in einem Bild (1/30 s); wer am Zug des Helden steht, bewegt sich nicht
const DAUER_BILDER := 30 * 120
const WARTE_BILDER := 20   # so lange steht der Held am Zug, bevor er befiehlt (der Spieler schaut erst)

var log_an := OS.get_environment("BEAM_LOG") != ""
var spruenge := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "BATS,GRABHUNDE").split(",")
	for g in gegner:
		var sd := int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
		seed(sd)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(sd)
		for i in 4:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("BEAM864 kein Kampf %s" % g)
			spruenge += 1
			p.queue_free()
			continue
		if kf.mars.find("merc") != null:
			kf.mars.find("merc").auto = true
		if not kf.busy:
			kf.go_on()
		var vor := {}
		var boden: Vector3 = kf._ground(0, 0)
		var n := 0
		var warte := 0
		var hier := 0
		var am_zug := 0
		while n < DAUER_BILDER:
			await process_frame
			n += 1
			var b: Vector3 = kf._ground(0, 0)
			var rueck := b - boden
			boden = b
			var held_dran: bool = not kf.busy and kf.zuege > 0
			if held_dran:
				am_zug += 1
			for id in kf.figures:
				var fig = kf.figures[id]
				if fig.dead_at >= 0 or not fig.visible:
					vor.erase(id)
					continue
				var pos: Vector3 = fig.position
				if vor.has(id):
					var d := Vector2(pos.x - vor[id].x - rueck.x, pos.z - vor[id].z - rueck.z).length()
					if d > SPRUNG_M and (held_dran or log_an):
						if held_dran:
							hier += 1
						print("  Sprung %s Bild %d: %s %.2f m, Zug %d%s" % [g, n, id, d, kf.zuege, ", Held am Zug" if held_dran else ""])
				vor[id] = pos
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next():
					kf.go_on()
					continue
				warte += 1
				if warte < WARTE_BILDER:
					continue
				warte = 0
				var c = kf.mars.current()
				var ts: Array = kf.mars.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		print("Kampf %s: %s nach %d Bildern, %d Bilder Held am Zug, %d Spruenge dabei" % [g, kf.mars.outcome, n, am_zug, hier])
		if am_zug == 0:
			print("BEAM864 %s: der Held kam nie an den Zug" % g)
			spruenge += 1
		spruenge += hier
		kf.queue_free()
		p.queue_free()
		await process_frame
	print("BEAM864 %s" % ("gut" if spruenge == 0 else "%d Spruenge" % spruenge))
	quit(1 if spruenge > 0 else 0)
