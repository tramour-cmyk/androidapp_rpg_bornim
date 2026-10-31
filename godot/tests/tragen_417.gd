extends SceneTree
# 417 ohne Bild: Stab (Magier), Kriegsaxt (Kaempfer), Bogen (Schurke) in der Hand (tragen.gd) im Gehen und Rennen; je Bild eines
# Umlaufs (nach zwei Umlaeufen Vorlauf) der Abstand der Waffe zum verformten Koerper ohne die tragende Hand, die Faust am Ziel,
# der Stabfuss am Boden. Braucht daten/held_*.bin (held_klassen.py) und daten/waffen/*.bin (waffen.py).
# godot --headless --path godot -s res://tests/tragen_417.gd   -> „TRAGEN gut“ oder „FEHLER …“, Ende 0/1
const FIGUREN := [["WIZARD", "quarterstaff"], ["FIGHTER", "greataxe"], ["ROGUE", "shortbow"]]
const FPS := 30.0
const INNEN_ERLAUBT := 0.01     # m: tiefer darf kein Punkt der Waffe im Koerper stecken
const FAUST_ERLAUBT := 0.03     # m: so weit darf die Faust neben ihrem Ziel liegen

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	if HeldFigur.lade_info().is_empty():
		print("TRAGEN ohne Daten (held-klassen.json fehlt)")
		quit(0)
		return
	var welt := Node3D.new()
	root.add_child(welt)
	for e in FIGUREN:
		if not HeldFigur.da(e[0]) or not FileAccess.file_exists("res://daten/waffen/%s.bin" % e[1]):
			print("TRAGEN ohne %s oder %s" % e)
			continue
		var w := Node3D.new()
		welt.add_child(w)
		var m := HeldFigur.baue({"klasse": e[0], "volk": "HUMAN", "aussehen": HeldFigur.vorgabe(e[0]),
			"ausruestung": {"MAIN_HAND": {"base": e[1]}}}, [])
		w.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var tl := sk.find_children("Tragen", "", false, false)
		pruefe(tl.size() == 1, "%s %s: keine Tragart" % e)
		if tl.is_empty(): continue
		var tr := tl[0] as Tragen
		pruefe(sk.find_children("Ruecken*", "", false, false).is_empty(), "%s: Waffe zusaetzlich auf dem Ruecken" % e[0])
		var pkt := TragProbe.proben(tr.waffe)
		var ohne := TragProbe.hand_knochen(sk, tr.seite)
		var netze := TragProbe.netze_von(m)
		for bew in ["Gehen", "Rennen"]:
			ap.play(bew)
			var lang := ap.get_animation(bew).length
			var v: float = m.get_meta("gehen_m_je_s" if bew == "Gehen" else "rennen_m_je_s")
			var n := int(round(lang * FPS))
			var tief := {}
			var innen_bilder := 0
			var faust := 0.0
			var fuss_hoch := 0.0
			var setzen := 0
			var war_t := 1.0
			var tiefst := 9.0
			var tiefst_bild := ""
			for f in 3 * n:
				var t := f / FPS
				ap.seek(fmod(t, lang), true)
				ap.pause()
				w.position = Vector3(0, 0, 1) * v * t
				await sk.skeleton_updated   # erst danach gelten die Posen samt tragen.gd (nach process_frame steht wieder die Ruhe da)
				if f < 2 * n: continue
				var r := TragProbe.abstand(netze, sk, ohne, tr.waffe, pkt)
				for teil in r["teile"]: tief[teil] = minf(float(tief.get(teil, 9.0)), float(r["teile"][teil]))
				if float(r["min"]) < -INNEN_ERLAUBT: innen_bilder += 1
				if float(r["min"]) < tiefst: tiefst = float(r["min"]); tiefst_bild = "%.2f s %s" % [fmod(t, lang), r["schlimm"] if OS.get_cmdline_user_args().has("--genau") else ""]
				faust = maxf(faust, tr.fehl)
				if tr.art == "stab" and tr.stab_fuss != Vector3.INF:
					if tr.stab_t >= 1.0: fuss_hoch = maxf(fuss_hoch, absf(tr.stab_fuss.y - w.global_position.y))
					if tr.stab_t < 1.0 and war_t >= 1.0: setzen += 1
					war_t = tr.stab_t
			var teile := tief.keys()
			teile.sort_custom(func(a, b): return tief[a] < tief[b])
			var s := PackedStringArray()
			for teil in teile.slice(0, 4): s.append("%s %.1f" % [teil, tief[teil] * 100.0])
			print("MESS %s %s %s: naechste Teile (cm) %s; tiefster Punkt %.1f cm bei %s; Bilder im Koerper %d von %d; Faust neben Ziel %.1f cm%s" % [
				e[0], e[1], bew, ", ".join(s), tiefst * 100.0, tiefst_bild, innen_bilder, n, faust * 100.0,
				("; Stab umgesetzt %d mal, Fuss stehend hoechstens %.1f cm ueber dem Boden" % [setzen, fuss_hoch * 100.0]) if tr.art == "stab" and bew == "Gehen" else ""])
			pruefe(innen_bilder == 0, "%s %s %s: Waffe in %d Bildern tiefer als %.0f cm im Koerper" % [e[0], e[1], bew, innen_bilder, INNEN_ERLAUBT * 100.0])
			pruefe(faust <= FAUST_ERLAUBT, "%s %s: Faust %.1f cm neben dem Ziel" % [e[0], bew, faust * 100.0])
			if tr.art == "stab" and bew == "Gehen":
				pruefe(setzen >= 1, "%s: Stab im Gehen nie umgesetzt" % e[0])
				pruefe(fuss_hoch < 0.01, "%s: Stabfuss steht %.1f cm ueber dem Boden" % [e[0], fuss_hoch * 100.0])
	print("TRAGEN gut" if fehler == 0 else "TRAGEN %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
