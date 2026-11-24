extends SceneTree
# 1589.3 (Perikles 1600, DESIGN-GEGNER.md 5 und 11.2, Tom 17.11.): ohne Bild. Jede Menschengestalt auf dem Kaufkoerper (jede Herkunft
# Mann und Frau wie Held, Gefaehrten, Soeldner; jede Person des Dorfs) hat die fuenf Bewegungen Rueckwaerts, Rueckwaerts_L/R,
# Seitschritt_L/R aus der UAL2 als Schleife, mit Tempo und Richtung an der Figur gemessen (Standfuss, HeldFigur.stand_vektor), und
# HeldFigur.gang_wahl liefert je acht Richtungen das Richtige: vorn und schraeg vorn Gehen (dreht), sonst die Bewegung, deren
# gemessene Richtung im Achtel liegt. Ohne Kaufbewegung: Gehen, rueckwaerts abgespielt wie bisher.
# Braucht daten/held_*.bin, bewegungen.bin (held_klassen.py). Aufruf im Ordner godot:
#   godot --headless -s res://tests/gang_wahl_1589.gd   -> „GANGWAHL n Faelle, m Fehler“, Ende 0/1

const SOLL := {"Rueckwaerts": 180.0, "Rueckwaerts_L": 135.0, "Rueckwaerts_R": -135.0, "Seitschritt_L": 90.0, "Seitschritt_R": -90.0}
var fehler := 0
var faelle := 0

func pruefe(ok: bool, was: String) -> void:
	faelle += 1
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _init() -> void:
	var info := HeldFigur.lade_info()
	if info.is_empty() or not FileAccess.file_exists("res://daten/bewegungen.bin"):
		print("GANGWAHL ohne Daten (held-klassen.json, bewegungen.bin fehlen)")
		quit(1)
		return
	var figuren := []   # [Titel, Figur]
	for k in info.get("herkuenfte", {}):
		for g in ["m", "w"]:
			var w := {"herkunft": String(k), "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": {}}
			figuren.append(["%s %s" % [k, g], HeldFigur.baue(w, [])])
	var leute: Variant = JSON.parse_string(FileAccess.get_file_as_string(HeldFigur.LEUTE_LISTE)) if FileAccess.file_exists(HeldFigur.LEUTE_LISTE) else {}
	for id in (leute if leute is Dictionary else {}):
		if String(id).begins_with("_") or HeldFigur.person_modell(String(id)) == "": continue
		figuren.append(["Person " + String(id), HeldFigur.person(String(id), [])])
	for e in figuren:
		var t: String = e[0]
		var m: Node3D = e[1]
		pruefe(m != null, t + ": keine Figur")
		if m == null: continue
		root.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var zeile := []
		for n in SOLL:
			var da := ap != null and ap.has_animation(n)
			pruefe(da, "%s: %s fehlt" % [t, n])
			if not da: continue
			var an := ap.get_animation(n)
			var v := float(an.get_meta("m_je_s", 0.0))
			var gr := float(an.get_meta("grad", 0.0))
			pruefe(an.loop_mode == Animation.LOOP_LINEAR, "%s: %s keine Schleife" % [t, n])
			pruefe(v > 0.3 and v < 3.0, "%s: %s Tempo %.2f m/s" % [t, n, v])
			pruefe(absf(angle_difference(deg_to_rad(gr), deg_to_rad(SOLL[n]))) < deg_to_rad(15.0), "%s: %s Richtung %.0f statt %.0f Grad" % [t, n, gr, SOLL[n]])
			zeile.append("%s %.2f m/s %.0f°" % [n, v, gr])
		for i in 8:
			var w := deg_to_rad(45.0 * i - 135.0)
			var r: Dictionary = HeldFigur.gang_wahl(ap, w)
			var gw := rad_to_deg(w)
			if absf(gw) < 50.0:
				pruefe(r["name"] == "Gehen" and r["dreht"], "%s: %.0f Grad -> %s statt Gehen" % [t, gw, r["name"]])
			else:
				var gr := float(ap.get_animation(r["name"]).get_meta("grad", 999.0)) if r["name"] != "Gehen" else 999.0
				pruefe(absf(angle_difference(deg_to_rad(gr), w)) < deg_to_rad(22.5) and not r["dreht"] and not r["rueck"],
					"%s: %.0f Grad -> %s (%.0f Grad)" % [t, gw, r["name"], gr])
		print("GANGWAHL ", t, ": ", ", ".join(zeile))
		m.queue_free()
	# ohne Kaufbewegung (nur Gehen): wie bisher
	var ap0 := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	lib.add_animation("Gehen", Animation.new())
	ap0.add_animation_library("", lib)
	for i in 8:
		var w := deg_to_rad(45.0 * i - 135.0)
		var r: Dictionary = HeldFigur.gang_wahl(ap0, w)
		pruefe(r["name"] == "Gehen" and r["rueck"] == (absf(w) > deg_to_rad(100.0)), "ohne Kauf %.0f Grad: %s" % [rad_to_deg(w), r])
	ap0.free()
	print("GANGWAHL %d Figuren, %d Faelle, %d Fehler" % [figuren.size(), faelle, fehler])
	quit(1 if fehler else 0)
