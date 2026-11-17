extends SceneTree
# 1094 (Chef 13.11., Test 281: „der bleibt nicht mehr stehen, der läuft durch, wenn ich drücke … er sagt dann zwar, dass ich perfekt
# gedrückt habe, aber er lief durch“): nach dem Tippen zeichnet der Kampfort den Ring noch 0,3 s (kampfort.gd _play_ring), und seit
# 1039 läuft der große Ring über den kleinen hinaus weiter. Prüft ohne Bild mit gestellter Uhr: bis zum Tippen läuft die Zeit des
# Rings, nach dem Tippen (perfekt, gut, verpasst nach Ablauf) steht sie; ein neuer Ring läuft wieder.
# Aufruf: im Ordner godot --headless -s res://tests/ring_halt_1094.gd. Exit 0 = richtig.

var jetzt := 10000

func _initialize() -> void:
	var fehler := 0
	var ui = load("res://kampf/kampf_ui.gd").new()
	ui.uhr = func(): return jetzt
	for fall in [[1100, "perfekt"], [1000, "gut"], [1500, "verpasst"]]:
		ui.ring_open("wolf_1", {})
		jetzt += 400
		if absf(ui.ring_ms_bild() - 400.0) > 0.5:
			print("FEHLER %s: Ring läuft vor dem Tippen nicht (%.0f ms statt 400)" % [fall[1], ui.ring_ms_bild()]); fehler += 1
		jetzt += int(fall[0]) - 400
		ui.ring_halt()
		var beim_tippen: float = ui.ring_ms_bild()
		jetzt += 300     # so lange zeichnet _play_ring nach der Antwort weiter
		if absf(ui.ring_ms_bild() - beim_tippen) > 0.5:
			print("FEHLER %s: Ring läuft nach dem Tippen weiter (%.0f ms, beim Tippen %.0f)" % [fall[1], ui.ring_ms_bild(), beim_tippen]); fehler += 1
		ui.ring_close()
		jetzt += 1000
	print("RINGHALT1094 %d Fehler" % fehler)
	ui.free()
	quit(1 if fehler else 0)
