extends SceneTree
# 417 ohne Bild: Stab (Magier), Kriegsaxt (Kaempfer), Bogen (Schurke) in der Hand (tragen.gd) im Gehen und Rennen; je Bild eines
# Umlaufs (nach zwei Umlaeufen Vorlauf) der Abstand der Waffe zum verformten Koerper ohne die tragende Hand, die Faust am Ziel,
# der Stabfuss am Boden. Braucht daten/held_*.bin (held_klassen.py) und daten/waffen/*.bin (waffen.py).
# godot --headless --path godot -s res://tests/tragen_417.gd   -> „TRAGEN gut“ oder „FEHLER …“, Ende 0/1
const FIGUREN := [["WIZARD", "quarterstaff"], ["FIGHTER", "greataxe"], ["ROGUE", "shortbow"]]
const FPS := 30.0
const INNEN_ERLAUBT := 0.01     # m: tiefer darf kein Punkt der Waffe im Koerper stecken
const FAUST_ERLAUBT := 0.04     # m: so weit darf die Faust neben ihrem Ziel liegen (die Waffe folgt der echten Faust; mehr hiesse: Arm ueberstreckt)

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
	var liste: Array = FIGUREN.slice(0, 1 if OS.get_cmdline_user_args().has("--knie") else 3)
	if OS.get_cmdline_user_args().has("--fassungen"): liste.append(["FIGHTER", "greataxe", 0.0])   # 417 Runde 3: Fassung B (tragprobe.gd)
	for e in liste:
		if not HeldFigur.da(e[0]) or not FileAccess.file_exists("res://daten/waffen/%s.bin" % e[1]):
			print("TRAGEN ohne %s oder %s" % [e[0], e[1]])
			continue
		var w := Node3D.new()
		welt.add_child(w)
		var m := HeldFigur.baue({"klasse": e[0], "volk": "HUMAN", "aussehen": HeldFigur.vorgabe(e[0]),
			"ausruestung": {"MAIN_HAND": {"base": e[1]}}}, [])
		w.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var tl := sk.find_children("Tragen", "", false, false)
		pruefe(tl.size() == 1, "%s %s: keine Tragart" % [e[0], e[1]])
		if tl.is_empty(): continue
		var tr := tl[0] as Tragen
		tr.merken = true
		if e.size() > 2:
			tr.axt_griff = e[2]
			print("FASSUNG Griff %.2f" % e[2])
		pruefe(sk.find_children("Ruecken*", "", false, false).is_empty(), "%s: Waffe zusaetzlich auf dem Ruecken" % e[0])
		# vor dem ersten Bild zwei Bilder laufen lassen: vorher wendet der AnimationPlayer nichts an (Probe 1: die Messung lief in
		# der Ruhelage, Knie in jedem Bild gleich)
		ap.play("Stehen")
		await process_frame
		await process_frame
		var pkt := TragProbe.proben(tr.waffe)
		var ohne := TragProbe.hand_knochen(sk, tr.seite)
		var netze := TragProbe.netze_von(m)
		for bew in ["Gehen", "Rennen"]:
			ap.play(bew)
			await process_frame   # eine neue Bewegung muss ein Bild lang laufen; sofort angehalten blieb die alte Pose stehen
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
			var knie0 := Vector3.ZERO
			var weite_min := 9.0
			var weite_max := 0.0
			var blatt_y := -9.0     # Axt (417 Runde 3, Chef 01.11., 11:32 „der Axtkopf muss nach unten“): hoechste Richtung des Blatts
			var kopf_hoch := -9.0   # Axt: Mitte des Blatts ueber dem Schultergelenk, m
			var kopf_hinten := 0.0
			for f in 3 * n:
				var t := f / FPS
				ap.pause()   # erst anhalten, dann springen (umgekehrt wirkt seek nicht, die Figur stand)
				ap.seek(fmod(t, lang), true)
				w.position = Vector3(0, 0, 1) * v * t
				# angehalten wendet seek die Bewegung erst im naechsten Bild an; gelesen wird im Bild danach waehrend der Aktualisierung
				# des Skeletts (dann gelten die Posen samt tragen.gd)
				await process_frame   # tragen.gd merkt sich dabei die Posen samt Arm (tr.posen)
				if OS.get_cmdline_user_args().has("--knie") and f < 4: print("KNIE ", e[0], " ", bew, " ", f, " ", tr.posen[sk.find_bone("calf_l")].origin, " pos ", ap.current_animation_position, " ", ap.assigned_animation, " spielt ", ap.is_playing(), " faust ", sk.global_transform * (tr.posen[sk.find_bone("hand_r")] * tr.griff), " soll ", tr.faust_welt)
				if f < 2 * n: continue
				if f == 2 * n: knie0 = tr.posen[sk.find_bone("calf_l")].origin
				elif f == 2 * n + n / 2: pruefe(knie0.distance_to(tr.posen[sk.find_bone("calf_l")].origin) > 0.05, "%s %s: Bewegung steht (Knie in einem halben Umlauf nicht bewegt)" % [e[0], bew])
				var r := TragProbe.abstand(netze, sk, ohne, tr.waffe, pkt, tr.posen)
				for teil in r["teile"]: tief[teil] = minf(float(tief.get(teil, 9.0)), float(r["teile"][teil]))
				if float(r["min"]) < -INNEN_ERLAUBT: innen_bilder += 1
				if float(r["min"]) < tiefst: tiefst = float(r["min"]); tiefst_bild = "%.2f s %s" % [fmod(t, lang), r["schlimm"] if OS.get_cmdline_user_args().has("--genau") else ""]
				faust = maxf(faust, tr.fehl)
				weite_min = minf(weite_min, tr.faust_weite); weite_max = maxf(weite_max, tr.faust_weite)
				if tr.art == "schulter":
					var wb := tr.waffe.global_transform
					blatt_y = maxf(blatt_y, wb.basis.x.normalized().y)
					var schulter := sk.global_transform * tr.posen[sk.find_bone("upperarm_r")].origin
					var kopf := wb * Vector3(0.12, 0.80, 0.0)   # waffen.py build_greataxe: Blatt bei 80 cm, bis 23 cm nach +X
					kopf_hoch = maxf(kopf_hoch, kopf.y - schulter.y)
					kopf_hinten = maxf(kopf_hinten, -(kopf - schulter).dot((m.global_basis * Vector3.BACK).normalized()))
				if tr.art == "stab" and tr.stab_fuss != Vector3.INF:
					if tr.stab_t >= 1.0: fuss_hoch = maxf(fuss_hoch, absf(tr.stab_fuss.y - w.global_position.y))
					if tr.stab_t < 1.0 and war_t >= 1.0: setzen += 1
					war_t = tr.stab_t
			var teile := tief.keys()
			teile.sort_custom(func(a, b): return tief[a] < tief[b])
			var s := PackedStringArray()
			for teil in teile.slice(0, 4): s.append("%s %.1f" % [teil, tief[teil] * 100.0])
			print("MESS %s %s %s: naechste Teile (cm) %s; tiefster Punkt %.1f cm bei %s; Bilder im Koerper %d von %d; Faust neben Ziel %.1f cm, Faust weit %.1f bis %.1f cm%s" % [
				e[0], e[1], bew, ", ".join(s), tiefst * 100.0, tiefst_bild, innen_bilder, n, faust * 100.0, weite_min * 100.0, weite_max * 100.0,
				(("; Stab umgesetzt %d mal, Fuss stehend hoechstens %.1f cm ueber dem Boden" % [setzen, fuss_hoch * 100.0]) if tr.art == "stab" and bew == "Gehen" else "")
				+ (("; Blatt hoechstens %.2f nach oben, Blattmitte hoechstens %.0f cm ueber, %.0f cm hinter der Schulter" % [blatt_y, kopf_hoch * 100.0, kopf_hinten * 100.0]) if tr.art == "schulter" else "")])
			if tr.art == "schulter" and tr.axt_haengt: pruefe(blatt_y < 0.0, "%s %s: Axtblatt zeigt nach oben (%.2f)" % [e[0], bew, blatt_y])
			pruefe(innen_bilder == 0, "%s %s %s: Waffe in %d Bildern tiefer als %.0f cm im Koerper" % [e[0], e[1], bew, innen_bilder, INNEN_ERLAUBT * 100.0])
			pruefe(weite_min > 0.025 and weite_max < 0.06, "%s %s: Faust %.1f bis %.1f cm weit (um den Schaft 2,5 bis 6)" % [e[0], bew, weite_min * 100.0, weite_max * 100.0])
			pruefe(faust <= FAUST_ERLAUBT, "%s %s: Faust %.1f cm neben dem Ziel" % [e[0], bew, faust * 100.0])
			if tr.art == "stab" and bew == "Gehen":
				pruefe(setzen >= 1, "%s: Stab im Gehen nie umgesetzt" % e[0])
				pruefe(fuss_hoch < 0.01, "%s: Stabfuss steht %.1f cm ueber dem Boden" % [e[0], fuss_hoch * 100.0])
	# Sprung: nach einem Ortswechsel steht der Stabfuss wieder unter der Faust (Pruefer 417 Runde 2: im Film fehlte der Stab)
	for e in FIGUREN.slice(0, 1):
		var w := welt.get_child(0) as Node3D
		var m := w.get_child(0) as Node3D
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var tr := sk.find_children("Tragen", "", false, false)[0] as Tragen
		ap.play("Gehen")
		await process_frame
		w.position += Vector3(7, 0, -9)
		for f in 3:
			ap.pause()
			ap.seek(f / FPS, true)
			await process_frame
		var abst := Vector2(tr.stab_fuss.x - tr.faust_welt.x, tr.stab_fuss.z - tr.faust_welt.z).length()
		pruefe(abst < 0.4, "%s: nach einem Sprung von 11 m steht der Stabfuss %.2f m von der Faust" % [e[0], abst])
	print("TRAGEN gut" if fehler == 0 else "TRAGEN %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
