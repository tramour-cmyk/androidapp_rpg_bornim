# 1460 (975a A, Chef 11.11., 17:04): die Fertigkeit „Lederarbeit“ heißt Schneidern, EN Tailoring. Prüft Namen in Erschaffung und Daten
# (grundwert_von, material_fertigkeit, Meisterschaften) und dass ein Spielstand mit „Lederarbeit“ den Wert unter dem neuen Namen behält.
# Aufruf: im Ordner godot mit --headless -s res://tests/schneidern_1460.gd   (Exit 0 = alles richtig)
extends SceneTree

var falsch := 0


func _initialize() -> void:
	_pruefe("Erschaffung: Schneidern heißt EN Tailoring", ErschaffungBrs.FERT.get("Schneidern", ""), "Tailoring")
	_pruefe("Erschaffung: keine Lederarbeit mehr", ErschaffungBrs.FERT.has("Lederarbeit"), false)
	var text := FileAccess.get_file_as_string("res://daten/werte.json")
	_pruefe("werte.json: keine Lederarbeit mehr", text.contains("Lederarbeit"), false)
	var w: Dictionary = JSON.parse_string(text)
	_pruefe("werte.json: Schneidern zählt zur Gewandtheit", _suche(w, "grundwert_von").get("Schneidern", ""), "gewandtheit")
	var mf: Dictionary = _suche(w, "material_fertigkeit")
	_pruefe("werte.json: Leder und Stoff übt Schneidern", [mf.get("Leder", ""), mf.get("Stoff", "")], ["Schneidern", "Schneidern"])
	_pruefe("werte.json: Meisterschaft Schneidern", (_suche(w, "Meisterschaften", []) as Array).has("Schneidern"), true)
	# Spielstand mit dem alten Namen
	var stand := {"brs": {"volk": "Mensch", "herkunft": "Wanderer", "verteilt": {}, "mensch_frei": "", "wahl": ["Lederarbeit", "Spähen"]},
		"fert": {"werte": {"Lederarbeit": 12, "Spähen": 5}, "uebung": {"Lederarbeit": 2.5}, "decke": {"Lederarbeit": 24}, "probe": {},
			"bekannt": ["Lederarbeit", "Spähen"]}}
	var z := Zustand.aus_daten(stand)
	_pruefe("alter Stand: Wert unter dem neuen Namen", BrsFertigkeit.wert(z.fert, "Schneidern"), 12)
	_pruefe("alter Stand: Übung mitgenommen", float(z.fert["uebung"].get("Schneidern", 0.0)), 2.5)
	_pruefe("alter Stand: alter Name weg", (z.fert["werte"] as Dictionary).has("Lederarbeit") or (z.fert["bekannt"] as Array).has("Lederarbeit"), false)
	_pruefe("alter Stand: Wahl umbenannt", (z.brs.get("wahl", []) as Array).has("Schneidern"), true)
	print("SCHNEIDERN1460 %d falsch" % falsch)
	quit(1 if falsch > 0 else 0)


## erster Schlüssel [k] irgendwo in [d] (werte.json ist verschachtelt)
func _suche(d: Variant, k: String, sonst: Variant = {}) -> Variant:
	if d is Dictionary:
		if (d as Dictionary).has(k): return d[k]
		for v in (d as Dictionary).values():
			var r = _suche(v, k, null)
			if r != null: return r
	return sonst


func _pruefe(was: String, ist, soll) -> void:
	var ok: bool = ist == soll
	print(("gut    " if ok else "FALSCH ") + "%s: %s" % [was, str(ist)])
	if not ok: falsch += 1
