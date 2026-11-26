extends "res://tests/drehteller_film_499.gd"
# 1619 (Chef 18.11., 07:29 zu Film 458.3: „warum der Held gar so stakst … sah gar nicht mehr so nach Gehen aus. Vielleicht lag das an
# Tempo“): Nachstellung ohne Bild. Je Waffe wie im Film 458.3 (HeldFigur.bewaffne): welche Gehbewegung, Takt (Umtakten 416.4),
# Schritte je Sekunde, Schrittlänge, Tempo ohne Gleiten am Skelett (stand_tempo) gegen das Tempo, mit dem der Film (1,08 m/s) und das
# Spiel (karte.gehen × TS auf Gras) den Helden schieben; Gleiten = Anteil, um den der Standfuß über den Boden rutscht.
# WAFFEN_GEHEN=paket: wie vor 1619 (Paket ganz). Aufruf: godot --headless --path godot -s res://tests/gang_mess_1619.gd

const WAFFEN := [["", 0, ""], ["longsword", 1, "COMMON"], ["mace", 1, "COMMON"], ["greataxe", 1, "COMMON"], ["halberd", 1, "COMMON"],
	["spear", 11, "RARE"]]
const FILM_V := 1.08          # staffel_film_4583.gd: fest
const SPIEL_V := 1.84 * 1.16  # karte.gd gehen × Karte.TS, Gras

func _lauf() -> void:
	Sprache.lade()
	if OS.get_environment("WAFFEN_GEHEN") != "": HeldFigur.waffen_gehen = OS.get_environment("WAFFEN_GEHEN")
	print("GANG1619 waffen_gehen ", HeldFigur.waffen_gehen)
	baue_welt()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	var aus: Dictionary = (w.get("ausruestung", {}) as Dictionary).duplicate()
	aus.erase("OFF_HAND")
	for e in WAFFEN:
		if e[0] == "": aus.erase("MAIN_HAND")
		else: aus["MAIN_HAND"] = {"base": e[0], "ilvl": e[1], "rarity": e[2]}
		w["ausruestung"] = aus
		var mats := []
		var modell := HeldFigur.baue(w, mats)
		if modell == null: fehler += 1; print("FEHLER kein Held"); continue
		welt.add_child(modell)
		var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
		var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
		var gang := String(modell.get_meta("gang", ""))
		var namen := ["Gehen"]
		if gang != "" and anim.has_animation("Gehen_" + gang): namen.append("Gehen_" + gang)
		for n in namen:
			var an := anim.get_animation(n)
			var v := HeldFigur.stand_tempo(an, sk, HeldFigur.im_raum(modell, sk))
			var sps := 2.0 / an.length
			print("GANG1619 %-12s %-16s Länge %.3f s  Takt %.3f  v_quelle %.2f  v_figur %.2f  ohne Gleiten jetzt %.2f m/s  %.2f Schritte/s  Schritt %.2f m  Film %.2f m/s: Gleiten %+.0f %%  Spiel %.2f m/s: %+.0f %%" % [
				e[0] if e[0] != "" else "(ohne)", n, an.length, float(an.get_meta("takt", 1.0)), float(an.get_meta("v_quelle", 0.0)),
				float(an.get_meta("v_figur", 0.0)), v, sps, v / sps, FILM_V, 100.0 * (v - FILM_V) / FILM_V, SPIEL_V, 100.0 * (v - SPIEL_V) / SPIEL_V])
		modell.queue_free()
		await process_frame
	print("GANG1619 %d Fehler" % fehler)
	quit(1 if fehler else 0)
