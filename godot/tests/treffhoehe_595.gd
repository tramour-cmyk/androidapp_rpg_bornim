# 595 (Chef 11.11., 20:09, Film Lauf 356, wiederholt: „der eine … kein Schild … der steckt ja immer oben drüber … der Typ mit Schwert
# und Schild schlägt manchmal von oben nach unten … aber manchmal schlägt er auch einfach drüber“): Messung ohne Bild am echten
# Kampfort. Je Held (Schwert und Schild; Kurzschwert ohne Schild) und je Angriff gegen jedes Ziel der Gruppe, wie _held_schlag plant
# (Treffer und Fehlschlag): Stand, Aufschlag, Höhe der Klinge beim Aufschlag (Spitze und Mitte), ihre Senkrechte je s, und wie hoch
# das Ziel ist. „von oben“ = die Klinge kommt beim Aufschlag von oben (sinkt schneller als SINKT_MPS) und ihr tiefster Punkt liegt
# höchstens UEBER_M über dem Rücken des Ziels.
# Run: GEGNER=LEECHES,SLUGS,RATS godot --headless --path godot -s res://tests/treffhoehe_595.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const SINKT_MPS := 0.8
const UEBER_M := 0.05
const ANGRIFFE := ["SS_SwordAttack1", "SS_SwordAttack2", "SS_SwordAttack3", "Hieb", "Stich"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "LEECHES,SLUGS,RATS").split(",")
	for g in gegner:
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "ROGUE"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(5)
		for i in 12:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("TREFF595 %s: kein Kampf" % g)
			continue
		var helden := []
		var ziele := []
		for id in kf.figures:
			var f = kf.figures[id]
			(ziele if f.fighter.monster != null else helden).append(f)
		for t in ziele.slice(0, 1):
			var ziel: Array = t.koerper_ruhe()
			var oben := -INF
			for c in ziel:
				oben = maxf(oben, maxf((c[0] as Vector3).y, (c[1] as Vector3).y) + float(c[2]))
			oben -= t.position.y
			print("TREFF595 %s: Ziel %s, Rücken %.2f m über dem Boden" % [g, t.fighter.monster.de, oben])
			for h in helden:
				for hn in ANGRIFFE:
					if h.anim == null or not h.anim.has_animation(hn):
						continue
					var bahn: Array = h._hieb_bahn(hn)
					if bahn.is_empty():
						continue
					for soll in [-0.02, 0.3]:
						var d := Vector3(t.position.x - h.position.x, 0.0, t.position.z - h.position.z).normalized()
						var plan: Array = h.hieb_plan(bahn, ziel, t.position, d, soll, h.HIEB_KOERPER_LUFT)
						var tk: float = plan[1]
						# Klinge zur Zeit des Aufschlags und ein Bild davor (im eigenen Raum, y über dem Boden der Figur)
						var jetzt: Array = []
						var davor: Array = []
						for s in bahn:
							if absf(float(s[0]) - tk) < 0.017:
								jetzt = s[1]
							if absf(float(s[0]) - (tk - 1.0 / 30.0)) < 0.017:
								davor = s[1]
						var tief := INF
						var mitte := 0.0
						for w in jetzt:
							tief = minf(tief, minf((w[0] as Vector3).y, (w[1] as Vector3).y))
							mitte = ((w[0] as Vector3).y + (w[1] as Vector3).y) * 0.5
						var tief_vor := INF
						for w in davor:
							tief_vor = minf(tief_vor, minf((w[0] as Vector3).y, (w[1] as Vector3).y))
						var sinkt: float = (tief_vor - tief) * 30.0 if tief_vor < INF else 0.0
						var tiefst := INF
						for s in bahn:
							for w in s[1]:
								tiefst = minf(tiefst, minf((w[0] as Vector3).y, (w[1] as Vector3).y))
						var von_oben: bool = sinkt > SINKT_MPS and tief <= oben + UEBER_M
						print("TREFF595 %s %s %-15s %s: Stand %.2f m, Aufschlag %.2f s, Klinge unten %.2f m (Mitte %.2f), sinkt %.1f m/s, tiefster Punkt im Hieb %.2f m, Lücke %.2f → %s" % [
							g, "SS " if h._ss() else "ohne", hn, "Treffer" if soll < 0.0 else "Fehl", plan[0], tk, tief, mitte, sinkt,
							tiefst, plan[2], "von oben" if von_oben else "DRÜBER/seitlich"])
		kf.queue_free()
		p.queue_free()
		await process_frame
	quit(0)
