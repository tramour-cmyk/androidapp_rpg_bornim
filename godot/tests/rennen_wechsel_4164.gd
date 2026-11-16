extends SceneTree
# 416.4 Prüferbefund 15:1x (Film 15:02): „Rennen → Gehen springt in einem Bild in die aufrechte Haltung“, auch im Feld „vorher“.
# Ursache nachstellen statt raten: Messung ohne Bild am Kaufkoerper, wie er im Spiel laeuft (HeldFigur.baue, Rennen heute und A),
# Ablauf wie held.gd und rennen_film_4164.gd (Tempo, Held.ueberblendung, seek in den selben Schritt, speed_scale). Je Bild: Neigung
# Becken–Hals gegen senkrecht, Kopfhoehe, groesste Drehung eines Knochens gegen das Bild davor (mit Name). Dazu Neigung reines Gehen
# und reines Rennen ueber eine Schleife. Fehler: ein Bild nach einem Wechsel aendert die Neigung um mehr als 3 Grad.
# Aufruf im Ordner godot (braucht daten/held_FIGHTER.bin, bewegungen.bin, held-klassen.json; tom-probe-4164.yml film=nein)

const GEHEN := 1.84 * Karte.TS
const RENNEN := 3.68 * Karte.TS
const BESCHL := 5.0
const DT := 1.0 / 30.0
const FOLGE := [[0.5, 0.0], [1.7, 1.0], [3.7, 2.0], [5.5, 1.0]]   # bis Sekunde, 0 Stehen, 1 Gehen, 2 Rennen

func _initialize() -> void: _lauf.call_deferred()

func _knochen(sk: Skeleton3D, namen: Array) -> int:
	for n in namen:
		var i := sk.find_bone(n)
		if i >= 0: return i
	return -1

func _neigung(sk: Skeleton3D, b: int, h: int) -> float:
	var v := sk.get_bone_global_pose(h).origin - sk.get_bone_global_pose(b).origin
	return rad_to_deg(v.angle_to(Vector3.UP))

func _lauf() -> void:
	if not HeldFigur.da("FIGHTER"): print("FEHLER Kaufkoerper fehlt"); quit(1); return
	var fehler := 0
	for art in ["heute", "A"]:
		var z := Zustand.new()
		var w := HeldFigur.wahl(BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat", z.neue_uid), z)
		w["rennen"] = art
		w["ausruestung"] = {}
		var m := HeldFigur.baue(w, [])
		root.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var sk := m.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
		var b := _knochen(sk, ["pelvis"]); var h := _knochen(sk, ["neck_01", "neck", "spine_03"]); var k := _knochen(sk, ["Head", "head"])
		var gang := float(m.get_meta("gehen_m_je_s")); var renn := float(m.get_meta("rennen_m_je_s"))
		print("WECHSEL %s: Knochen %s %s %s, Gehen %.2f s (Tritte %s), Rennen %.2f s (Tritte %s), gehen_m_je_s %.2f, rennen_m_je_s %.2f" % [art,
			sk.get_bone_name(b), sk.get_bone_name(h), sk.get_bone_name(k), ap.get_animation("Gehen").length, ap.get_animation("Gehen").get_meta("tritt", "-"),
			ap.get_animation("Rennen").length, ap.get_animation("Rennen").get_meta("tritt", "-"), gang, renn])
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		# reine Schleifen: Neigung je Bild
		for n in ["Gehen", "Rennen"]:
			ap.play(n, 0.0); ap.seek(0.0, true)
			var ns := PackedFloat32Array()
			var a := ap.get_animation(n)
			for i in int(a.length / DT):
				ap.seek(i * DT, true); ns.append(_neigung(sk, b, h))
			var s := ""
			for i in range(0, ns.size(), 2): s += "%.0f " % ns[i]
			print("SCHLEIFE %s %s: Neigung %.1f bis %.1f Grad, je 2 Bilder: %s" % [art, n, Array(ns).min(), Array(ns).max(), s])
		# Ablauf wie im Film
		ap.play("Stehen", 0.0); ap.seek(0.0, true)
		var t := 0.0; var tempo := 0.0
		var vorher := {}   # Knochen -> Drehung im Bild davor
		var n0 := _neigung(sk, b, h)
		var seit := 99
		while t < FOLGE[-1][0]:
			t += DT
			var soll := 0.0
			for e in FOLGE:
				if t < e[0]: soll = [0.0, GEHEN, RENNEN][int(e[1])]; break
			tempo = Held.tempo_schritt(tempo, soll, GEHEN, DT)
			var moving := soll > 0.0
			var rennt := moving and tempo > GEHEN * 1.45
			var want := ("Rennen" if rennt else "Gehen") if moving else "Stehen"
			var cur := ap.current_animation
			var wechsel := ""
			var v := renn if rennt else gang
			var sp := (tempo / v) if moving else 1.0
			if cur != want:
				var ph := Held.schritt_phase(ap.get_animation(cur), ap.current_animation_position) if cur != "" else 0.0
				var vorher_t := ap.current_animation_position
				Held.wechsel(ap, want, moving, sp)
				wechsel = "%s->%s Phase %.2f (bei %.2f s) -> %.2f s" % [cur, want, ph, vorher_t, ap.current_animation_position]
				seit = 0
			ap.speed_scale = Held.takt(ap, tempo, v, DT) if moving else 1.0
			ap.advance(DT)
			var n1 := _neigung(sk, b, h)
			var groesst := 0.0; var wer := ""
			for i in sk.get_bone_count():
				var q := sk.get_bone_pose_rotation(i)
				if vorher.has(i):
					var d := rad_to_deg((vorher[i] as Quaternion).angle_to(q))
					if d > groesst: groesst = d; wer = sk.get_bone_name(i)
				vorher[i] = q
			if seit <= 16:
				print("BILD %s t=%.2f %s tempo %.2f sp %.2f Neigung %.1f (%+.1f) Kopf %.3f groesste Drehung %.1f %s %s" % [art, t, want, tempo,
					ap.speed_scale, n1, n1 - n0, sk.get_bone_global_pose(k).origin.y, groesst, wer, wechsel])
				if seit >= 1 and seit <= 3 and absf(n1 - n0) > 3.0:
					fehler += 1; print("FEHLER %s t=%.2f: Neigung springt %+.1f Grad im Bild %d nach dem Wechsel" % [art, t, n1 - n0, seit])
			seit += 1
			n0 = n1
		m.free()
	print("WECHSEL4164 ", "gut" if fehler == 0 else "%d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
