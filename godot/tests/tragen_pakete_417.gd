extends SceneTree
# 417 Runde 5 ohne Bild: Waffen der Paketbewegungen (tragen.gd _paket, _schildarm; Lage aus den Unity-Prefabs, griff417b.py) je Bild
# eines Umlaufs von Gehen_<gang> und Rennen_<gang>: Abstand von Waffe und Schild zum verformten Koerper ohne die tragende Hand, beim
# Zweihaender die linke Faust an der Schaftlinie (die Pakete fassen ihn mit beiden Haenden). Figuren wie tragprobe.gd PAKET_FIGUREN.
# godot --headless --path godot -s res://tests/tragen_pakete_417.gd   -> „PAKETE gut“ oder „FEHLER …“, Ende 0/1
const FPS := 30.0
const INNEN_ERLAUBT := 0.01     # m, wie tragen_417.gd
const LINKS_ERLAUBT := 0.05     # m: linke Faust neben der Schaftlinie des Zweihaenders
# Runde 6 (Lauf 41324326151): Zweihaender in Fassungen [Anteil der Drehung zur linken Faust, Verschieben zur Spitze in m]; Fehler zaehlt
# nur die Fassung, die tragen.gd gerade nimmt, die uebrigen stehen als FASSUNG daneben
# Schild (Lauf 41350556171: Gehen 5 von 15 Bildern bis 5 cm im Koerper): Schildarm um so viele Grad nach aussen (tragen.gd schild_abspreiz)
const SCHILD_FASSUNGEN := [0.0, 5.0, 8.0, 12.0, 16.0]
# Schwert mit Schild (Lauf 41356789633: Rennen 1 von 15 Bildern 4,9 cm im rechten Oberschenkel): rechter Oberarm so viele Grad nach aussen
const SCHWERT_FASSUNGEN := [9.0, 12.0, 15.0, 18.0]
const AXT_FASSUNGEN := [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.15], [0.5, 0.15], [1.0, 0.15], [0.5, 0.25], [1.0, 0.25], [1.0, 0.30]]

const GLEIT_ERLAUBT := 5.0      # %: Standfuss gegen den Boden (Pruefer 00:53: 17-28 %)
var fehler := 0

# Film 02:2x (tragprobe FILMGLEIT: Rennen 10-22 % Betrag, einzeln abgespielt 0-4 %): der Ablauf des Films ohne Bild (FILM_FOLGE, Held.tempo_schritt,
# wechsel, takt, advance), je Abschnitt ab 0,8 s der Standfuss im Raum mit Vorzeichen (+ = gleitet vorwaerts mit der Figur, - = rueckwaerts),
# Median und Betrag, dazu speed_scale und Tempo; zeigt, ob das Rutschen im Abspielen steckt und wo
func film_nach(m: Node3D, sk: Skeleton3D, ap: AnimationPlayer, gang: String, wer: String) -> void:
	var g := "_" + gang
	var w := m.get_parent() as Node3D
	var p := Vector3.ZERO
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	ap.play("Stehen"); ap.advance(0.0)
	var tempo := 0.0
	var gehen := TragProbe.SPIEL_GEHEN
	for ai in TragProbe.FILM_FOLGE.size():
		var b0: String = TragProbe.FILM_FOLGE[ai][0]
		var nf := int(round(float(TragProbe.FILM_FOLGE[ai][1]) * FPS))
		var halt: bool = ai + 1 < TragProbe.FILM_FOLGE.size() and TragProbe.FILM_FOLGE[ai + 1][0] == "Stehen"
		var z := []
		for f in nf:
			var moving := b0 != "Stehen"
			var soll := 0.0 if not moving else (gehen if b0 == "Gehen" else TragProbe.SPIEL_RENNEN)
			if moving and halt: soll = Held.bremse(soll, float(nf - f) / FPS * gehen * Held.ANLAUF * 2.0, gehen)
			tempo = Held.tempo_schritt(tempo, soll, gehen, 1.0 / FPS)
			var want := b0
			if moving and ap.has_animation(b0 + g): want = b0 + g
			var vb := 1.0
			if moving: vb = float(m.get_meta(("gang_" if want != b0 else "") + ("gehen" if b0 == "Gehen" else "rennen") + "_m_je_s", 1.0))
			if ap.current_animation != want: Held.wechsel(ap, want, moving, tempo / maxf(0.01, vb) if moving else 1.0)
			ap.speed_scale = Held.takt(ap, tempo, vb, 1.0 / FPS) if moving else 1.0
			ap.advance(1.0 / FPS)
			p += Vector3(0, 0, 1) * tempo / FPS
			w.position = p
			await process_frame
			if f >= int(0.8 * FPS) and moving:
				z.append([(sk.global_transform * sk.get_bone_global_pose(sk.find_bone("ball_l"))).origin,
					(sk.global_transform * sk.get_bone_global_pose(sk.find_bone("ball_r"))).origin, tempo, ap.speed_scale, ap.current_animation])
		if z.size() < 4: continue
		var vs := []
		var tm := 0.0; var sp := 0.0
		for x in z: tm += float(x[2]) / z.size(); sp += float(x[3]) / z.size()
		for s in [0, 1]:
			var tief := INF
			for x in z: tief = minf(tief, (x[s] as Vector3).y)
			for j in z.size() - 1:
				var a: Vector3 = z[j][s]; var b: Vector3 = z[j + 1][s]
				if a.y < tief + 0.02 and b.y < tief + 0.02: vs.append((b.z - a.z) * FPS)
		if vs.is_empty(): continue
		vs.sort()
		var ab := vs.map(func(v): return absf(v)); ab.sort()
		print("FILMNACH %s %s (Abschnitt %d, %s): Standfuss %+.2f m/s (Median mit Vorzeichen), Betrag %.2f, Figur %.2f m/s, speed_scale %.2f, %d Proben" % [wer, b0, ai,
			z[-1][4], vs[vs.size() / 2], ab[ab.size() / 2], tm, sp, vs.size()])
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	w.position = Vector3.ZERO
	ap.speed_scale = 1.0

# Rueckwaertstempo des Standfusses (Ballen, Blick +Z) beim Abspielen, 60 Proben je Umlauf, Median wie HeldFigur.stand_tempo
func stand_abspielen(ap: AnimationPlayer, sk: Skeleton3D, bew: String, lang: float) -> float:
	var n := 60
	var vs := []
	var d := {"l": [], "r": []}; var h := {"l": [], "r": []}
	ap.play(bew)
	for j in n + 1:
		ap.pause()
		ap.seek(lang * j / n, true)
		await process_frame
		for s in ["l", "r"]:
			var o := (sk.global_transform * sk.get_bone_global_pose(sk.find_bone("ball_" + s))).origin
			d[s].append(o.z); h[s].append(o.y)
	for s in ["l", "r"]:
		var tief: float = h[s].min()
		for j in n:
			if h[s][j] < tief + 0.02 and h[s][j + 1] < tief + 0.02: vs.append((d[s][j] - d[s][j + 1]) * n / lang)
	ap.play(bew)
	if vs.is_empty(): return 0.0
	vs.sort()
	return float(vs[vs.size() / 2])

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	if HeldFigur.lade_info().is_empty():
		print("PAKETE ohne Daten (held-klassen.json fehlt)")
		quit(0)
		return
	var welt := Node3D.new()
	root.add_child(welt)
	for e in TragProbe.PAKET_FIGUREN:
		var gang: String = e[0]
		if not HeldFigur.da(e[1]):
			print("PAKETE ohne ", e[1]); continue
		var w := Node3D.new()
		welt.add_child(w)
		var m := HeldFigur.baue({"klasse": e[1], "volk": "HUMAN", "aussehen": HeldFigur.vorgabe(e[1]), "ausruestung": e[2]}, [])
		w.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		pruefe(String(m.get_meta("gang", "")) == gang, "%s: Gang %s statt %s" % [e[1], m.get_meta("gang", ""), gang])
		await film_nach(m, sk, ap, gang, String(e[1]))
		# Lauf 41315361680 und 41320044677: der Schild wurde nie gemessen; Godot benennt den zweiten Knoten „@Tragen@…“ um, darum nach Typ
		var tl: Array = sk.get_children().filter(func(c): return c is Tragen)
		pruefe(tl.size() == (2 if gang == "schild" else 1), "%s %s: %d Tragen-Knoten" % [e[1], gang, tl.size()])
		if tl.is_empty(): continue
		for t in tl: (t as Tragen).merken = true
		ap.play("Stehen")
		await process_frame
		await process_frame
		var netze := TragProbe.netze_von(m)
		for b0 in ["Gehen", "Rennen"]:
			var bew: String = b0 + "_" + gang
			if not ap.has_animation(bew):
				pruefe(false, "%s: Bewegung %s fehlt" % [e[1], bew]); continue
			ap.play(bew)
			await process_frame
			var lang := ap.get_animation(bew).length
			var n := int(round(lang * FPS))
			# Pruefer Film 00:53 („Rennen: Fuss 17-28 % langsamer als der Boden, rutscht“): der Standfuss im echten Abspielen (speed_scale 1 =
			# Spieltempo gang_*_m_je_s) gegen das Tempo, mit dem die Figur vorankommt; dazu das Tempo der Quelle (vorher) gegen das an der Figur
			var vsoll := float(m.get_meta("gang_gehen_m_je_s" if b0 == "Gehen" else "gang_rennen_m_je_s", 0.0))
			var vst: float = await stand_abspielen(ap, sk, bew, lang)
			var an0 := ap.get_animation(bew)
			var vq := float(an0.get_meta("v_quelle", 0.0)); var vf := float(an0.get_meta("v_figur", 0.0))
			var gl := 100.0 * (vst - vsoll) / maxf(0.01, vsoll)
			print("GLEIT %s %s: Standfuss %.2f m/s, Figur kommt %.2f m/s voran, Fuss %+.0f %% gegen den Boden; Quelle %.2f, an der Figur %.2f m/s (vorher %+.0f %%)" % [e[1], bew,
				vst, vsoll, gl, vq, vf, 100.0 * (vf / maxf(0.01, vq) - 1.0)])
			pruefe(absf(gl) <= GLEIT_ERLAUBT, "%s %s: Standfuss %+.0f %% gegen den Boden" % [e[1], bew, gl])
			var laeufe := []
			for t in tl:
				if gang == "axt":
					for fa in AXT_FASSUNGEN: laeufe.append([t, fa])
				if (t as Tragen).gang == "schildarm":
					for g in SCHILD_FASSUNGEN: laeufe.append([t, [g]])
				if (t as Tragen).gang == "schild":
					for g in SCHWERT_FASSUNGEN: laeufe.append([t, [g]])
				laeufe.append([t, null])
			for lf in laeufe:
				var tr := lf[0] as Tragen
				var fa = lf[1]
				var a0 := tr.zwei_anteil; var s0 := tr.zwei_schieben; var g0 := tr.schild_abspreiz; var w0 := tr.schwert_abspreiz
				if fa != null and fa.size() == 1:
					if tr.gang == "schild": tr.schwert_abspreiz = fa[0]
					else: tr.schild_abspreiz = fa[0]
				elif fa != null:
					tr.zwei_anteil = fa[0]; tr.zwei_schieben = fa[1]
				var pkt := TragProbe.proben(tr.waffe)
				var ohne := TragProbe.hand_knochen(sk, tr.seite)
				if tr.gang == "schildarm": ohne.append("lowerarm_l")   # der Schild liegt am Unterarm an (Riemen)
				if gang == "axt": ohne.append_array(TragProbe.hand_knochen(sk, "l"))   # Zweihaender: die linke Faust fasst den Schaft (eigene Pruefung unten)
				var tief := {}
				var innen := 0
				var tiefst := 9.0
				var links := 0.0
				var zw := 0.0
				var tiefbild := {}
				var iy := Vector2(INF, -INF)
				for f in 2 * n:
					ap.pause()
					ap.seek(fmod(f / FPS, lang), true)
					await process_frame
					if f < n: continue
					var r := TragProbe.abstand(netze, sk, ohne, tr.waffe, pkt, tr.posen)
					for teil in r["teile"]: tief[teil] = minf(float(tief.get(teil, 9.0)), float(r["teile"][teil]))
					if float(r["min"]) < -INNEN_ERLAUBT: innen += 1
					var ry: Vector2 = r["innen_y"]
					iy = Vector2(minf(iy.x, ry.x), maxf(iy.y, ry.y))
					if float(r["min"]) < tiefst and not r["schlimm"].is_empty():
						tiefbild = {"t": fmod(f / FPS, lang), "teil": r["schlimm"]["teil"], "waffe": r["schlimm"]["waffe"]}
					tiefst = minf(tiefst, float(r["min"]))
					if gang == "axt":
						var R := Tragen.hand_rahmen(sk, "l")
						var fl := sk.global_transform * (R * Tragen.ZWEI_LINKS)   # Runde 6: die Stelle, durch die tragen.gd den Schaft legt (innen in der Faust)
						zw = maxf(zw, tr.zwei_winkel)
						var o := tr.waffe.global_position; var a := tr.waffe.global_basis.y.normalized()
						var q := fl - o
						links = maxf(links, (q - a * q.dot(a)).length())
				var teile := tief.keys()
				teile.sort_custom(func(x, y): return tief[x] < tief[y])
				var s := PackedStringArray()
				for teil in teile.slice(0, 4): s.append("%s %.1f" % [teil, tief[teil] * 100.0])
				var was := "Schild" if tr.gang == "schildarm" else String(e[2]["MAIN_HAND"]["base"])
				if fa != null and fa.size() == 1:
					print("FASSUNG %s %s %.0f Grad aussen: Bilder im Koerper %d von %d, tiefster Punkt %.1f cm (%s)" % [bew, "Schwertarm" if tr.gang == "schild" else "Schildarm",
						fa[0], innen, n, tiefst * 100.0, ", ".join(s)])
					tr.schild_abspreiz = g0; tr.schwert_abspreiz = w0
					continue
				if fa != null:
					print("FASSUNG %s Anteil %.1f, verschoben %.2f m: Bilder im Koerper %d von %d, tiefster Punkt %.1f cm (%s), linke Faust %.1f cm, gedreht %.1f Grad" % [bew,
						fa[0], fa[1], innen, n, tiefst * 100.0, ", ".join(s), links * 100.0, zw])
					tr.zwei_anteil = a0; tr.zwei_schieben = s0
					continue
				print("MESS %s %s %s: naechste Teile (cm) %s; tiefster Punkt %.1f cm; Bilder im Koerper %d von %d%s" % [e[1], was, bew,
					", ".join(s), tiefst * 100.0, innen, n, ("; linke Faust hoechstens %.1f cm neben dem Schaft, Schaft bis %.1f Grad gegen die rechte Hand gedreht" % [links * 100.0, zw]) if gang == "axt" else ""])
				# wo an der Waffe (Waffenraum, m; Laenge laeuft auf y) und wann: Klinge, Parierstange, Knauf oder Wurfarm?
				if not tiefbild.is_empty() and tiefst < 0.0:
					var wp: Vector3 = tiefbild["waffe"]
					print("ORT %s %s %s: tiefster Punkt bei %.2f s an %s, Waffe (%.2f, %.2f, %.2f) m; tiefer als 1 cm laengs der Waffe y %.2f bis %.2f m" % [e[1], was, bew, tiefbild["t"],
						tiefbild["teil"], wp.x, wp.y, wp.z, iy.x, iy.y])
				pruefe(innen == 0, "%s %s %s: in %d Bildern tiefer als %.0f cm im Koerper" % [e[1], was, bew, innen, INNEN_ERLAUBT * 100.0])
				if gang == "axt": pruefe(links < LINKS_ERLAUBT, "%s %s: linke Faust %.1f cm neben dem Schaft" % [e[1], bew, links * 100.0])
		w.queue_free()
		await process_frame
	print("PAKETE gut" if fehler == 0 else "PAKETE %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
