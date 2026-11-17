extends SceneTree
# 653: Werkzeug und Gegenprobe zum Halt je Modell (skripte/halt.gd).
#  1. misst jeden Gegenstand des Katalogs mit Modell (Waffen, Schilde): Griff, Achse, vorn, Spitze, Länge, Kanten -> Zeilen „HALT“;
#     mit --aus=<datei> als JSON {id: halt} (regeln/halt.json); ohne --aus: abgelegte Maße gegen das Modell (veraltet = Fehler)
#  2. legt jeden Gegenstand an jeden Körpertyp (Kaufkörper je Tracht und Geschlecht) an seinen Platz (Waffe rechte Faust, Schild
#     linker Unterarm), in der Haltung „Stehen“, und prüft nach festen Maßen: Griff in der Faust (Abstand Griff–Halterung 0), Schaft
#     verlässt die Faust zum Daumen, Schild mit der Vorderseite nach außen, nichts im Rumpf (Abstand zur nächsten Rumpfecke).
# Aufruf im Ordner godot: --headless -s res://tests/halt_653.gd [-- --aus=<datei>] -> „HALT653 n Fehler, k Paare“

var fehler := 0
var paare := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func arg(n: String) -> String:
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--%s=" % n): return x.substr(n.length() + 3)
	return ""

func _lauf() -> void:
	# Einheit: Maße aus Ecken nach Modellregel 4
	var probe := Halt.mass_aus(PackedVector3Array([Vector3(0, -0.1, 0), Vector3(0.02, 0.9, 0.0), Vector3(-0.02, 0.9, 0.0), Vector3(0.3, 0.2, -0.04)]))
	pruefe(is_equal_approx(probe["laenge"], 0.9) and is_equal_approx(probe["unten"], 0.1) and is_equal_approx(probe["rand_hinten"], 0.04), "mass_aus %s" % probe)
	var rt := Halt.griff_rahmen(probe)
	pruefe(rt.basis.y.is_equal_approx(Vector3.UP) and rt.basis.z.is_equal_approx(Vector3.BACK), "griff_rahmen %s" % rt)
	pruefe(Halt.aus_feld(Halt.als_feld(probe))["spitze"].is_equal_approx(probe["spitze"]), "Feld hin und zurück")

	# 1. Gegenstände
	var ids: Array = []
	var feld := {}
	for id in Katalog.lade():
		var e: Dictionary = Katalog.eintrag(id)
		if not String(e.get("art", "")) in ["waffe", "schild"]: continue
		if Halt.datei(id) == "":
			print("OHNE MODELL ", id)
			continue
		var m := Halt.messen(id)
		if m.is_empty():
			pruefe(false, "%s: Modell ohne Ecken" % id)
			continue
		ids.append(id)
		feld[id] = Halt.als_feld(m)
		print("HALT %s %s laenge %.2f unten %.2f hoehe %.2f..%.2f rand_hinten %.3f spitze %s" % [id, Halt.datei(id).get_file(), m["laenge"], m["unten"],
			m["hoehe"].x, m["hoehe"].y, m["rand_hinten"], m["spitze"]])
		pruefe(m["laenge"] > 0.05, "%s: Spitze am Griff (Länge %.3f)" % [id, m["laenge"]])
		var ab = Halt.feld().get(id)
		if arg("aus") == "":
			pruefe(ab is Dictionary and JSON.stringify(ab) == JSON.stringify(Halt.als_feld(m)), "%s: regeln/halt.json fehlt oder veraltet (--aus=regeln/halt.json)" % id)
	var aus := arg("aus")
	if aus != "":
		var f := FileAccess.open(aus, FileAccess.WRITE)
		f.store_string(JSON.stringify(feld, " ", true))
		f.close()
		print("HALT geschrieben ", aus, " (", feld.size(), ")")

	# 2. Körper × Gegenstand
	var trachten: Array = HeldFigur.lade_info().get("trachten", {}).keys()
	for tr in trachten:
		var t := String(tr)
		if not FileAccess.file_exists("res://daten/held_%s.bin" % t): continue
		var g := t.right(1).to_lower()
		var m := HeldFigur.baue({"klasse": "", "modell": t, "aussehen": {"geschlecht": g}, "volk": "HUMAN"}, [])
		if m == null:
			print("OHNE KOERPER ", t)
			continue
		root.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var lagen := HeldFigur.haltung_lagen(m, sk, "Stehen")
		if lagen.is_empty():
			print("OHNE STEHEN ", t)
			m.free()
			continue
		var ks := HeldFigur.im_raum(m, sk)
		var rumpf := HeldFigur.haut_punkte(m, sk, true, null, lagen)
		var ganz := HeldFigur.haut_punkte(m, sk, true, null, lagen, INF)   # mit den Armen (Schild am Unterarm)
		for id in ids:
			var schild := String(Katalog.eintrag(id).get("art", "")) == "schild"
			var platz := "unterarm_l" if schild else "faust_r"
			var hl := Halt.halterung(sk, platz, t)   # 967: mit der Korrektur des Körpertyps
			if hl.is_empty():
				pruefe(false, "%s: kein Platz %s" % [t, platz])
				continue
			paare += 1
			var mass := Halt.gegenstand(id)
			var kn := sk.find_bone(hl["knochen"])
			var welt: Transform3D = ks * (lagen[kn] as Transform3D) * Halt.lage(hl, mass)
			var griff := welt * (mass["griff"] as Vector3)
			var soll := ks * (lagen[kn] as Transform3D) * (hl["lage"] as Transform3D).origin
			pruefe(griff.distance_to(soll) < 0.002, "%s %s: Griff %.1f cm neben der Halterung" % [t, id, griff.distance_to(soll) * 100.0])
			var achse := (welt.basis * (mass["achse"] as Vector3)).normalized()
			var hand := ks * (lagen[kn] as Transform3D)
			var daumen := (hand.basis * (hl["lage"] as Transform3D).basis.y).normalized()
			pruefe(achse.dot(daumen) > 0.99, "%s %s: Achse nicht zum Daumen (%.2f)" % [t, id, achse.dot(daumen)])
			# nächste Rumpfecke zu Punkten längs des Gegenstands (Schild: Fläche aus Kanten), ohne die haltende Hand (10 cm um den Griff)
			var naechst := INF
			var punkte := []
			if schild:
				var hh: Vector2 = mass["hoehe"]
				for y in [hh.x, 0.0, hh.y]:
					for x in [-0.2, 0.0, 0.2]: punkte.append(Vector3(x, y, 0.0))
			else:
				for i in range(1, 9): punkte.append((mass["spitze"] as Vector3) * (i / 8.0))
			for p in punkte:
				var w: Vector3 = welt * (p as Vector3)
				if w.distance_to(griff) < 0.10: continue
				for q in rumpf: naechst = minf(naechst, w.distance_to(q))
			print("PAAR %s %s %s Rumpf %.1f cm" % [t, id, platz, naechst * 100.0])
			if schild:
				# Chef 10.11., 13:39 („im Seitprofil der Unterarm durch das Schild“): Ecken des Körpers (mit Arm und Hand) vor der Rückseite
				# des Bretts und innerhalb seines Umrisses; am Rand (12 % der Breite) liegt die Wölbung, dort nicht
				var kb: AABB = mass["kasten"]
				var inv := welt.affine_inverse()
				var durch := 0
				var tief := 0.0
				for q in ganz:
					var l: Vector3 = inv * q
					if absf(l.x - kb.get_center().x) > kb.size.x * 0.38 or l.y < kb.position.y + kb.size.y * 0.12 or l.y > kb.end.y - kb.size.y * 0.12: continue
					if l.z > -0.005 and l.z < kb.end.z:
						durch += 1; tief = maxf(tief, l.z + 0.005)
						if OS.get_environment("DURCH_DBG") != "":
							var bn := ""; var bd := INF
							for b in sk.get_bone_count():
								var o: Vector3 = ks * (lagen[b] as Transform3D).origin
								if o.distance_to(q) < bd: bd = o.distance_to(q); bn = sk.get_bone_name(b)
							print("  DURCH_DBG %s %s Ecke im Schild %s, Welt %s, nächster Knochen %s (%.1f cm)" % [t, id, l, q, bn, bd * 100.0])
				print("DURCH %s %s %d Ecken, bis %.1f cm" % [t, id, durch, tief * 100.0])
				pruefe(durch == 0, "%s %s: %d Ecken des Körpers im Schild (bis %.1f cm)" % [t, id, durch, tief * 100.0])
				var vorn := (welt.basis * (mass["vorn"] as Vector3)).normalized()
				var seite := (ks.basis * Vector3.RIGHT).normalized()   # Figur blickt nach +Z, ihre Linke ist +X
				pruefe(vorn.dot(seite) > 0.0, "%s %s: Vorderseite zum Körper (%.2f)" % [t, id, vorn.dot(seite)])
		m.free()
	print("HALT653 %d Fehler, %d Paare" % [fehler, paare])
	quit(1 if fehler > 0 else 0)
