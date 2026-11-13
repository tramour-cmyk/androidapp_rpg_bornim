extends SceneTree
# 1021 ohne Bild und ohne godot/daten: „Letztes Ende der App“ im Reiter Test wie alt (CrashLog.exitReason): Grund laut System mit Zeit
# und Speicher beim Ende; ohne Bericht (Rechner, vor Android 11) „–“. Aufruf: im Ordner godot mit -s res://tests/ende_1021.gd

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var jetzt := int(Time.get_unix_time_from_system() * 1000.0)
	var faelle := [
		[{"grund": 3, "zeit": jetzt, "pss_mb": 812, "rss_mb": 900, "wichtigkeit": 400, "beschreibung": ""}, ["Speicher knapp", "PSS 812 MB"]],
		[{"grund": 2, "zeit": jetzt, "pss_mb": 700, "rss_mb": 760, "wichtigkeit": 400, "signal": 9, "beschreibung": "freezer"}, ["vom System beendet (Signal 9)", "\nfreezer"]],
		[{"grund": 10, "zeit": jetzt, "pss_mb": 1, "rss_mb": 1, "wichtigkeit": 100, "beschreibung": "remove task"}, ["vom Nutzer beendet"]],
		[{"grund": 99, "zeit": jetzt, "pss_mb": 1, "rss_mb": 1, "wichtigkeit": 100, "beschreibung": ""}, ["anderer Grund (99)"]],
	]
	for fa in faelle:
		var t := Messung.ende_text(fa[0])
		print("Zeile: ", t.replace("\n", " | "))
		for w in fa[1]:
			if not t.contains(w): fehler += 1; print("FEHLER 1021 „%s“ fehlt" % w)
	if not Messung.ende_text(fa_en(), false).contains("low memory"): fehler += 1; print("FEHLER 1021 englisch")
	if Messung.ende_text({}) != "–": fehler += 1; print("FEHLER 1021 ohne Bericht")
	if not Messung.letztes_ende().is_empty(): fehler += 1; print("FEHLER 1021 am Rechner ein Ende laut System")
	print("ENDE1021 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func fa_en() -> Dictionary: return {"grund": 3, "zeit": 0, "pss_mb": 1, "rss_mb": 1, "wichtigkeit": 1}
