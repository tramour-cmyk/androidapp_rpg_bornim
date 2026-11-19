extends SceneTree
# 522 (Chef 04.11., 11:55, t257 251.6: „von Schwert und Schild auf … Streitkolben und Dolch. Fakt ist, die alte Bewaffnung und Ausrüstung
# war weg, aber die neue ist nicht sichtbar gewesen“): jede Waffe, die waffen.py bauen kann, hat ein Modell fuer den Helden; ein Dolch in
# der Nebenhand haengt nicht als Schild auf dem Ruecken. Die Waffen ohne Modell (458.3) nennt der Test; die Staffel (458.3) prüft er
# je Form (Länge, Griff, Farbe). Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/waffen_522.gd -> „WAFFEN522 gut“ oder „n Fehler“
const MIT_MODELL := ["longsword", "shortsword", "quarterstaff", "dagger", "scimitar", "handaxe", "shortbow", "longbow", "shield", "round_shield", "wand", "staff"]   # 1587

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	for b in MIT_MODELL:
		pruefe(FileAccess.file_exists("res://daten/waffen/%s.bin" % b), "%s: Modell fuer den Helden" % b)
	var ohne: Array = []
	for b in Beute.d_()["grundformen"]:
		var g: Dictionary = Beute.grundform(b)
		if String(g["slot"]) in ["MAIN_HAND", "OFF_HAND"] and Staffel.schluessel({"base": b}) == "": ohne.append(b)
	print("bekannt, noch ohne Modell (458.3): ", ohne)
	# 458.3 Staffel: jede Waffenart mit Spalte formen hat in jeder Stufe ein Modell; jede Form mit Griff im Ursprung, Schaft +Y, Länge
	# wie gebaut (staffel.json), Farbe nach Seltenheit (toenung je Klasse). Ohne staffel.json (Bau ohne Kaufmodelle) nur der Hinweis
	var st: Dictionary = Staffel.daten()
	if st.is_empty(): print("bekannt: ohne staffel.json (Bau ohne Kaufmodelle)")
	var formen: Dictionary = st.get("formen", {})
	for art in (st.get("waffen", {}) as Dictionary):
		for stufe in [1, 5, 8, 11, 15, 20]:
			pruefe(Staffel.schluessel({"base": art, "ilvl": stufe}) != "", "%s Stufe %d: Staffelform" % [art, stufe])
		for f in st["waffen"][art]:
			var d := String(f["datei"])
			var info: Dictionary = {}
			for k in formen:
				if String(formen[k].get("spiel", "")) == d: info = formen[k]
			var h := Halt.gegenstand(d + "#RARE")
			if h.is_empty():
				pruefe(false, "%s: Modell da" % d); continue
			var lang := float(info.get("laenge_cm", 0.0)) / 100.0
			var ganz := (h["hoehe"] as Vector2).y - (h["hoehe"] as Vector2).x
			pruefe(absf(ganz - lang) < 0.05 * lang + 0.01, "%s: Länge %.2f m (gebaut %.2f)" % [d, ganz, lang])
			pruefe(absf((h["hoehe"] as Vector2).x + float(info.get("griff_ab_unten_cm", 0.0)) / 100.0) < 0.02, "%s: Griff %.2f m über dem unteren Ende" % [d, -(h["hoehe"] as Vector2).x])
	if not st.is_empty():
		var schl := Staffel.schluessel({"base": "mace", "ilvl": 1, "rarity": "EPIC"})
		var w := Staffel.lade(schl)
		var t := Vector3.ONE
		if w:
			Gebiet.male(w, null, 2, [])
			for mi in w.find_children("*", "MeshInstance3D", true, false) + ([w] if w is MeshInstance3D else []):
				var sm := (mi as MeshInstance3D).get_surface_override_material(0) as ShaderMaterial
				if sm: t = sm.get_shader_parameter("toenung")
			w.free()
		pruefe(t != Vector3.ONE, "%s: Farbe der Seltenheit gesetzt (%s)" % [schl, t])
	if FileAccess.file_exists("res://daten/held.bin") and FileAccess.file_exists("res://daten/waffen/dagger.bin"):
		var m := Gebiet.lade_glb("res://daten/held.bin")
		root.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		HeldFigur.bewaffne(m, sk, {"MAIN_HAND": {"base": "longsword"}, "OFF_HAND": {"base": "dagger"}})
		pruefe(sk.find_children("RueckenSchild", "", true, false).is_empty(), "Dolch in der Nebenhand haengt nicht als Schild auf dem Ruecken")
		HeldFigur.bewaffne(m, sk, {"MAIN_HAND": {"base": "longsword"}, "OFF_HAND": {"base": "shield"}})
		pruefe(not sk.find_children("RueckenSchild", "", true, false).is_empty(), "Schild in der Nebenhand haengt auf dem Ruecken")
	print("WAFFEN522 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
