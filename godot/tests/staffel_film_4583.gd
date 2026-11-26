extends "res://tests/drehteller_film_499.gd"
# 458.3 (Chef 01.11., 19:5x „Staffel nach Stufe“, Vorlage „Film Stufe 1–20“; 02.11., 11:28 Modelle und Staffel passen): die Staffel im
# Spiel. Der Kämpfer geht über die Wiese wie im Drehteller 499, die Kamera kreist; alle REIHE_S Sekunden legt er die nächste Waffe an
# (HeldFigur.bewaffne wie im Spiel: Form nach Stufe des Gegenstands, Farbe nach Seltenheit, Griff in der Faust nach Halt).
# REIHE=einhand (Schwert, Streitkolben, Morgenstern, Axt) oder zweihand (Großaxt, Hellebarde, Speer), Standard einhand.
# Film:      REIHE=einhand xvfb-run godot --path godot --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 -s res://tests/staffel_film_4583.gd
# Ohne Bild (headless): legt jede Waffe an und prüft, dass ein Modell in der Hand oder auf dem Rücken hängt

const REIHEN := {
	"einhand": [["longsword", 1, "COMMON"], ["longsword", 5, "UNCOMMON"], ["longsword", 11, "RARE"], ["mace", 1, "COMMON"],
		["mace", 8, "RARE"], ["morningstar", 11, "EPIC"]],
	"zweihand": [["greataxe", 1, "COMMON"], ["greataxe", 5, "UNCOMMON"], ["greataxe", 11, "RARE"], ["halberd", 1, "COMMON"],
		["halberd", 11, "EPIC"], ["spear", 11, "RARE"]],
}
const REIHE_S := 2.4
const SEL_DE := {"COMMON": "gewöhnlich", "UNCOMMON": "ungewöhnlich", "RARE": "selten", "VERY_RARE": "sehr selten", "EPIC": "episch",
	"DIVINE": "göttlich"}

func _lauf() -> void:
	Sprache.lade()
	var reihe: Array = REIHEN.get(OS.get_environment("REIHE"), REIHEN["einhand"])
	baue_welt()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	var aus: Dictionary = (w.get("ausruestung", {}) as Dictionary).duplicate()
	aus.erase("OFF_HAND")
	aus["MAIN_HAND"] = {"base": reihe[0][0], "ilvl": reihe[0][1], "rarity": reihe[0][2]}
	w["ausruestung"] = aus
	var mats := []
	var modell := HeldFigur.baue(w, mats)
	if modell == null: print("STAFFEL4583 kein Held"); quit(1); return
	welt.add_child(modell)
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(m as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
	var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	Gebiet.bewegungen(anim, ["Gehen", "Stehen"])
	var t := 0.0
	var v := 1.08
	for i in reihe.size():
		var e: Array = reihe[i]
		var g := {"base": e[0], "ilvl": e[1], "rarity": e[2]}
		if i > 0:
			aus["MAIN_HAND"] = g
			HeldFigur.bewaffne(modell, sk, aus)
		var schl := Staffel.schluessel(g)
		var haengt := not modell.find_children("Getragen*", "", false, false).is_empty() or not sk.find_children("Ruecken*", "", false, false).is_empty()
		pruefe(schl.contains("#") and haengt, "%s Stufe %d %s: %s am Helden" % [e[0], e[1], e[2], schl])
		var gang := String(modell.get_meta("gang", ""))
		var bew := "Gehen_" + gang if gang != "" and anim.has_animation("Gehen_" + gang) else "Gehen"
		if anim.current_animation != bew: anim.play(bew, 0.2)
		schrift.text = "%s · Stufe %d · %s" % [String(Katalog.eintrag(String(e[0])).get("name", {}).get("de", e[0])), e[1], SEL_DE[e[2]]]
		var t0 := t
		while t < t0 + REIHE_S:
			modell.position = Vector3(0, 0, t * v)
			stelle_kamera(modell.position + Vector3(0, 0.9, 0), 45.0 + 360.0 * t / (REIHE_S * reihe.size()))
			await process_frame
			t += DT
	print("STAFFEL4583 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
