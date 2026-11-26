extends "res://tests/drehteller_film_499.gd"
# 1632 (Chef 18.11., 09:00, Rollenspiegel Diogenes; aus 1619 „Held stakst“): Gangprüfung im Bau. Je Waffe mit Heldmodell und je
# Gangart (Gehen, Rennen, mit und ohne Waffe) nach dem Umtakten (416.4) am Skelett dieser Figur gemessen (stand_tempo, Standfuß am
# Ballen): Fußgleiten = Abweichung des Tempos ohne Gleiten vom Spieltempo (TAKT_GEHEN, TAKT_RENNEN), höchstens GLEITEN_MAX;
# Schritte je Sekunde nicht über der Grenze der Gangart (kein Trippeln: vor 1619 ging das Einhandpaket 4,1 Schritte je s).
# Ohne Kaufmodelle (daten/held.bin fehlt) übersprungen. Aufruf: godot --headless --path godot -s res://tests/gang_1632.gd -> „GANG1632 0 Fehler“

const WAFFEN := ["", "longsword", "shortsword", "dagger", "scimitar", "handaxe", "quarterstaff", "staff", "shortbow", "longbow"]
const GLEITEN_MAX := 0.10
const SCHRITTE_MAX := {"Gehen": 3.4, "Rennen": 3.0}   # Messung 18.11.: Gehen 3,08, Rennen 2,40 je Gangart

func _lauf() -> void:
	Sprache.lade()
	if OS.get_environment("WAFFEN_GEHEN") != "": HeldFigur.waffen_gehen = OS.get_environment("WAFFEN_GEHEN")   # Gegenprobe: paket = vor 1619
	if not FileAccess.file_exists("res://daten/held.bin"):
		print("GANG1632 ohne Kaufmodelle übersprungen")
		quit(0)
		return
	baue_welt()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	var aus: Dictionary = (w.get("ausruestung", {}) as Dictionary).duplicate()
	aus.erase("OFF_HAND")
	var geprueft := 0
	for base in WAFFEN:
		if base == "": aus.erase("MAIN_HAND")
		else: aus["MAIN_HAND"] = {"base": base, "ilvl": 1, "rarity": "COMMON"}
		w["ausruestung"] = aus
		var modell := HeldFigur.baue(w, [])
		if modell == null:
			fehler += 1; print("FEHLER kein Held mit ", base); continue
		welt.add_child(modell)
		var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
		var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
		var gang := String(modell.get_meta("gang", ""))
		var namen := ["Gehen", "Rennen"] if base == "" else []
		for art in ["Gehen", "Rennen"]:
			if gang != "" and anim.has_animation(art + "_" + gang): namen.append(art + "_" + gang)
		if base != "" and namen.is_empty(): print("GANG1632 %-12s ohne eigene Gangart (Gang „%s“)" % [base, gang])
		for n in namen:
			var an := anim.get_animation(n)
			var art := "Rennen" if n.begins_with("Rennen") else "Gehen"
			var ziel: float = HeldFigur.TAKT_RENNEN if art == "Rennen" else HeldFigur.TAKT_GEHEN
			var v := HeldFigur.stand_tempo(an, sk, HeldFigur.im_raum(modell, sk))
			var sps := 2.0 / an.length
			var gl := (v - ziel) / ziel
			var ok_g := absf(gl) <= GLEITEN_MAX
			var ok_s := sps <= float(SCHRITTE_MAX[art])
			geprueft += 1
			print("GANG1632 %-12s %-16s %.2f m/s (Spiel %.2f): Gleiten %+.0f %%  %.2f Schritte/s  Schritt %.2f m%s" % [
				base if base != "" else "(ohne)", n, v, ziel, 100.0 * gl, sps, v / sps, "" if ok_g and ok_s else "  <- FEHLER"])
			if not ok_g: fehler += 1; print("FEHLER %s %s: Fuß gleitet %+.0f %% (höchstens %.0f %%)" % [base, n, 100.0 * gl, 100.0 * GLEITEN_MAX])
			if not ok_s: fehler += 1; print("FEHLER %s %s: %.2f Schritte/s, trippelt (höchstens %.1f)" % [base, n, sps, SCHRITTE_MAX[art]])
		modell.queue_free()
		await process_frame
	if geprueft == 0: fehler += 1; print("FEHLER keine Gangart gemessen")
	print("GANG1632 %d Fehler (%d Gangarten)" % [fehler, geprueft])
	quit(1 if fehler else 0)
