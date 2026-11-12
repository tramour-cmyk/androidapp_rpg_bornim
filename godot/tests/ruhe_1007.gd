extends SceneTree
# 1007 (Tom 977): Monster der Karte (streuner.gd) stehen mit Streuner.Stub als Kampfort-Ersatz; dessen Uhr blieb bei 0,
# figur._ruhebewegung wartete darum ewig, im Stehen keine Ruhegeste. Prüft ohne Kaufmodelle: die Uhr des Ersatzes läuft (auch nach
# einer Zuweisung wie in leute.gd), der Ruhelaut ist wie alt nur nah zu hören (MonsterIdle.volume: voll bis 2 Kacheln, still ab 7).
# Mit Kaufmodell des Wolfs: ein Wolf der Karte spielt binnen 14 s eine Ruhegeste, und zeichne() bricht sie nicht ab.
# Aufruf: im Ordner godot mit -s res://tests/ruhe_1007.gd -> „RUHE1007 gut“ oder „RUHE1007 FEHLER …“ (Exit 1)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("RUHE1007 FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var st := Streuner.Stub.new(null)
	var a: float = st.clock_ms
	OS.delay_msec(250)
	var b: float = st.clock_ms
	pruefe(b - a >= 200.0, "Uhr des Kampfort-Ersatzes steht (%.0f -> %.0f ms)" % [a, b])
	st.clock_ms = 5.0                        # leute.gd (977) schreibt die Uhr: darf nichts zurückstellen
	pruefe(st.clock_ms >= b, "Uhr nach Zuweisung zurückgestellt (%.0f ms)" % st.clock_ms)
	pruefe(st.ruhe_pegel(Vector3(50, 0, 50)) == 1.0, "ohne Hörer nicht voll")
	var ts := Karte.TS
	for z in [[0, 1.0], [1, 1.0], [2, 1.0], [4, 0.6], [6, 0.2], [7, 0.0], [12, 0.0]]:
		st.hoerer = Vector3.ZERO
		var p: float = st.ruhe_pegel(Vector3(ts * z[0] * 0.5, 0, ts * z[0] * 0.5))
		pruefe(absf(p - float(z[1])) < 0.01, "Ruhelaut %d Kacheln: %.2f statt %.2f" % [z[0], p, z[1]])

	var s: Streuner = null
	if Streuner.da("wolf"):
		s = Streuner.aus_daten({"art": "wolf", "kachel": Vector2i(10, 10), "heim": Vector2i(10, 10), "blick": Vector2i(0, 1), "nr": 1},
			Karte.lade("deep_forest"))
		root.add_child(s)
		await process_frame
	if s == null or s.figur == null or s.figur.anim == null or not s.figur.anim.has_animation("Lefzen"):
		print("RUHE1007 Wolf übersprungen: ohne Ruhegesten (Bau ohne Kaufmodelle)")
	else:
		var gesehen := ""
		var dauer := 0.0
		var t0 := Time.get_ticks_msec()
		var jetzt := 0
		while Time.get_ticks_msec() - t0 < 14000:
			await process_frame
			jetzt += 16
			s.zeichne(jetzt, 0.016, Vector3(1000, 0, 1000))
			var an := String(s.figur.anim.current_animation)
			if gesehen == "" and an in Streuner.Figur.RUHE_GESTEN:
				gesehen = an
			elif gesehen != "" and an == gesehen:
				dauer += 0.016
			elif gesehen != "":
				break
		pruefe(gesehen != "", "Wolf der Karte binnen 14 s ohne Ruhegeste")
		pruefe(gesehen == "" or dauer > 0.3, "Ruhegeste %s nach %.2f s abgebrochen" % [gesehen, dauer])
		if gesehen != "": print("RUHE1007 Wolf: %s %.1f s" % [gesehen, dauer])
	if fehler == 0: print("RUHE1007 gut")
	quit(1 if fehler > 0 else 0)
