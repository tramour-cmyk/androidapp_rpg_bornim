extends SceneTree
# 416.4 Messung ohne Bild (kein Probelauf, 390a) am echten Held (held.gd _process, Kaufkoerper wie im Spiel, Dorf „village“):
#   tippen: Rennen zum angetippten Ziel (Pruefer Film 4611: „stockt je Kachel“, nachgerechnet: an jedem Wegpunkt ein Bild ohne Schritt,
#           Tempo auf 0, nie ueber 3,4 m/s); Fehler: ein Bild ohne Schritt vor dem Ziel oder Hoechsttempo unter 4,2 m/s
#   auslauf: Steuerkreuz, 2,5 s Rennen, dann Gehen (Chef 01.11., 20:3x: „Von Sprint langsam über langsamer über in den Gang gehen“,
#           Abbremsen in Stufen und laenger als Beschleunigen); je Bild Tempo, Bewegung, speed_scale, Neigung Becken–Hals, groesste
#           Knochendrehung gegen das Bild davor, Standfuss gegen den Boden. Fehler: Abbremsen nicht 0,8–1,2 s oder nicht laenger als das
#           Beschleunigen; Neigung springt in einem Bild ueber 3 Grad; groesste Drehung ueber 1,5-fach der reinen Schleifen; Standfuss
#           gleitet im Median ueber 10 % des Tempos
#   atem: Rennen zum Ziel, unterwegs aus (laeuft falsch), dann Halt am Ziel; Fehler: aus dem Gehen zurueck ins Rennen
# Aufruf im Ordner godot (daten/karten.json, held_FIGHTER.bin, bewegungen.bin, held-klassen.json; tom-probe-4164.yml):
#   godot --headless --path . -s res://tests/rennen_auslauf_4164.gd

const DT := 1.0 / 30.0
var fehler := 0

func _initialize() -> void: _lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _held(k: Karte) -> Held:
	var z := Zustand.new()
	var w := HeldFigur.wahl(Heldwerte.erschaffe("Probe", "HUMAN", "FIGHTER", {}, z.neue_uid), z)
	w["ausruestung"] = {}
	var h := Held.new(k, w)
	root.add_child(h)
	h.anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	h.set_process(false)
	return h

func _bild(h: Held) -> void:
	h._process(DT)
	h.anim.advance(DT)

func _neigung(sk: Skeleton3D) -> float:
	var b := sk.find_bone("pelvis"); var n := sk.find_bone("neck_01")
	if n < 0: n = sk.find_bone("spine_03")
	return rad_to_deg((sk.get_bone_global_pose(n).origin - sk.get_bone_global_pose(b).origin).angle_to(Vector3.UP))

func _drehung(sk: Skeleton3D, vorher: Dictionary) -> Array:
	var g := 0.0; var wer := ""
	for i in sk.get_bone_count():
		var q := sk.get_bone_pose_rotation(i)
		if vorher.has(i):
			var d := rad_to_deg((vorher[i] as Quaternion).angle_to(q))
			if d > g: g = d; wer = sk.get_bone_name(i)
		vorher[i] = q
	return [g, wer]

func _ballen(sk: Skeleton3D, s: String) -> Vector3:
	var b := sk.find_bone("ball_" + s)
	if b < 0: b = sk.find_bone("foot_" + s)
	return (sk.global_transform * sk.get_bone_global_pose(b)).origin

# groesste Drehung je Bild in der reinen Schleife bei Tempo ohne Gleiten
func _schleife(h: Held, n: String) -> float:
	var sk := Gebiet.finde(h.modell, "Skeleton3D") as Skeleton3D
	var a := h.anim.get_animation(n)
	h.anim.play(n, 0.0); h.anim.seek(0.0, true); h.anim.speed_scale = 1.0
	var v := {}; var g := 0.0
	for i in int(a.length / DT) + 1:
		h.anim.advance(DT)
		var d: Array = _drehung(sk, v)
		if i > 0: g = maxf(g, float(d[0]))
	h.anim.play("Stehen", 0.0)
	return g

func _lauf() -> void:
	if not HeldFigur.da("FIGHTER") or not FileAccess.file_exists("res://daten/karten.json"):
		print("AUSLAUF FEHLER Daten fehlen"); quit(1); return
	var k := Karte.lade("village")
	var h := _held(k)
	var sk := Gebiet.finde(h.modell, "Skeleton3D") as Skeleton3D
	print("AUSLAUF Bewegungen: %s" % [Array(h.anim.get_animation_list()).filter(func(n): return n.begins_with("Rennen") or n.begins_with("Gehen"))])
	for n in ["Gehen", "Rennen", "RennenAus"]:
		if h.anim.has_animation(n):
			var a := h.anim.get_animation(n)
			print("AUSLAUF %s Laenge %.3f s, Tritte %s, aus_k %s" % [n, a.length, a.get_meta("tritt", "-"), a.get_meta("aus_k", "-")])
	pruefe(h.anim.has_animation("RennenAus"), "RennenAus fehlt")
	var g_gehen := _schleife(h, "Gehen"); var g_rennen := _schleife(h, "Rennen")
	print("AUSLAUF Schleifen: groesste Drehung je Bild Gehen %.1f, Rennen %.1f Grad (bei Tempo ohne Gleiten)" % [g_gehen, g_rennen])

	# --- tippen
	h.setze(Vector2i(4, 10), "RIGHT")
	h.laeuft = true
	pruefe(h.geh_zu(k.kachel_pos(Vector2i(24, 10))), "tippen: kein Weg")
	var halte := 0; var vmax := 0.0; var bilder := 0; var stehen := 0; var vsoll := 0.0
	var zeile := ""
	while h.geht() and bilder < 600:
		_bild(h); bilder += 1
		vmax = maxf(vmax, h.tempo_jetzt)
		vsoll = maxf(vsoll, k.laufen * Karte.TS / k.schritt(h.kachel))
		if h.geht() and h.tempo_jetzt <= 0.0: halte += 1
		if h.geht() and h.anim.current_animation.begins_with("Stehen"): stehen += 1
		if bilder % 3 == 0: zeile += "%.2f " % h.tempo_jetzt
	print("AUSLAUF tippen: %d Bilder bis %s, Bilder ohne Schritt vor dem Ziel %d, in Stehen %d, hoechstes Tempo %.2f m/s; Tempo je 0,1 s: %s" % [
		bilder, h.kachel, halte, stehen, vmax, zeile])
	pruefe(halte == 0 and stehen == 0, "tippen: %d Bilder ohne Schritt, %d in Stehen vor dem Ziel" % [halte, stehen])
	pruefe(vmax > vsoll - 0.1, "tippen: hoechstes Tempo %.2f statt %.2f" % [vmax, vsoll])
	for i in 30: _bild(h)

	# --- auslauf (Steuerkreuz)
	h.setze(Vector2i(4, 10), "RIGHT")
	for i in 15: _bild(h)
	h.richtung = Vector3(1, 0, 0)
	var v := {}
	var t := 0.0
	var prot := []
	h.laeuft = true
	while t < 6.0:
		if t >= 3.0: h.laeuft = false
		_bild(h); t += DT
		var d: Array = _drehung(sk, v)
		prot.append({"t": t, "tempo": h.tempo_jetzt, "anim": h.anim.current_animation, "sp": h.anim.speed_scale, "neig": _neigung(sk),
			"dreh": d[0], "wer": d[1], "l": _ballen(sk, "l"), "r": _ballen(sk, "r"), "pos": h.position,
			"geh": k.gehen * Karte.TS / k.schritt(h.kachel), "renn": k.laufen * Karte.TS / k.schritt(h.kachel)})
	h.richtung = Vector3.ZERO
	for i in 20: _bild(h)
	# Beschleunigen: ab 0,5 s (Rennen gewollt ab Start) bis volles Tempo; Abbremsen: ab 3,0 s bis Gehtempo
	var an0 := -1.0; var an1 := -1.0; var ab1 := -1.0
	for e in prot:
		if an0 < 0.0 and e["tempo"] > e["geh"] + 0.01: an0 = e["t"]
		if an1 < 0.0 and e["tempo"] >= e["renn"] - 0.01: an1 = e["t"]
		if e["t"] > 3.0 and ab1 < 0.0 and e["tempo"] <= e["geh"] + 0.01: ab1 = e["t"]
	var anlauf := an1 - an0; var abbrems := ab1 - 3.0
	print("AUSLAUF Beschleunigen Gehen->Rennen %.2f s, Abbremsen Rennen->Gehen %.2f s" % [anlauf, abbrems])
	pruefe(abbrems >= 0.8 and abbrems <= 1.2, "auslauf: Abbremsen %.2f s statt 0,8–1,2" % abbrems)
	pruefe(abbrems > anlauf, "auslauf: Abbremsen %.2f s nicht laenger als Beschleunigen %.2f s" % [abbrems, anlauf])
	var g_aus := 0.0; var wer_aus := ""; var neig_max := 0.0; var gleit := []
	for i in range(1, prot.size()):
		var e: Dictionary = prot[i]; var p: Dictionary = prot[i - 1]
		var im: bool = e["t"] > 2.95 and e["t"] < 3.0 + abbrems + 0.7
		if im:
			if e["dreh"] > g_aus: g_aus = e["dreh"]; wer_aus = e["wer"]
			neig_max = maxf(neig_max, absf(e["neig"] - p["neig"]))
			# Standfuss: der tiefere Ballen, hoechstens 2 cm ueber dem Tiefsten der letzten 0,7 s
			var s := "l" if (e["l"] as Vector3).y < (e["r"] as Vector3).y else "r"
			var tief := INF
			for j in range(maxi(0, i - 21), i + 1): tief = minf(tief, minf((prot[j]["l"] as Vector3).y, (prot[j]["r"] as Vector3).y))
			if (e[s] as Vector3).y < tief + 0.02 and (p[s] as Vector3).y < tief + 0.02 and e["tempo"] > 0.5:
				var dv := Vector2((e[s] as Vector3).x - (p[s] as Vector3).x, (e[s] as Vector3).z - (p[s] as Vector3).z).length() / DT
				gleit.append(100.0 * dv / float(e["tempo"]))
		if e["t"] > 2.6 and e["t"] < 3.0 + abbrems + 0.8 and int(round(e["t"] / DT)) % 2 == 0:
			print("AUSLAUF BILD t=%.2f %s tempo %.2f sp %.2f Neigung %.1f groesste Drehung %.1f %s" % [e["t"], e["anim"], e["tempo"], e["sp"],
				e["neig"], e["dreh"], e["wer"]])
	gleit.sort()
	var med: float = gleit[gleit.size() / 2] if gleit.size() > 0 else -1.0
	var p90: float = gleit[int(gleit.size() * 0.9)] if gleit.size() > 0 else -1.0
	print("AUSLAUF Abbremsen: groesste Drehung je Bild %.1f Grad (%s; Schleifen %.1f / %.1f), Neigung je Bild hoechstens %.1f Grad, Standfuss gleitet Median %.0f %%, 90 %% bis %.0f %% (%d Proben)" % [
		g_aus, wer_aus, g_gehen, g_rennen, neig_max, med, p90, gleit.size()])
	pruefe(neig_max <= 3.0, "auslauf: Neigung springt %.1f Grad in einem Bild" % neig_max)
	pruefe(g_aus <= 1.5 * maxf(g_gehen, g_rennen), "auslauf: Drehung %.1f Grad (%s) je Bild, Schleifen hoechstens %.1f" % [g_aus, wer_aus, maxf(g_gehen, g_rennen)])
	pruefe(gleit.size() >= 4 and med <= 10.0, "auslauf: Standfuss gleitet Median %.0f %%" % med)

	# --- atem: Rennen zum Ziel, unterwegs aus, Halt am Ziel
	h.setze(Vector2i(4, 10), "RIGHT")
	for i in 15: _bild(h)
	h.laeuft = true
	h.geh_zu(k.kachel_pos(Vector2i(22, 10)))
	var folge := []; t = 0.0
	var zurueck := 0
	while h.geht() and t < 15.0:
		if t >= 2.0: h.laeuft = false
		_bild(h); t += DT
		var a := h.anim.current_animation
		if folge.is_empty() or folge[-1][0] != a:
			folge.append([a, snappedf(t, 0.01)])
			if t > 2.0 and a.begins_with("Rennen") and folge.size() > 1 and String(folge[-2][0]).begins_with("Gehen"): zurueck += 1
	print("AUSLAUF atem: Folge %s" % [folge])
	pruefe(zurueck == 0, "atem: %d mal zurueck ins Rennen" % zurueck)
	h.free()
	print("AUSLAUF4164 ", "gut" if fehler == 0 else "%d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
