extends SceneTree
# 1569 (Chef 17.11., 16:12/16:16, t297.18, Bild t297-18-umhang-fehlt.webp): der angelegte Umhang des Jaegerkinds war in der Welt nie zu
# sehen, auch nach Ablegen und Anlegen. Ursache: heldfigur.gd kleide (431h Stufe 2) blendete das eigene Teil eines Platzes aus, sobald das
# Stueck nicht in „eigen“ der Tracht stand, und ein Umhang hat kein Schrankteil (gegenstaende.json „teil“ leer) – der Platz blieb leer.
# Ohne Kaufdaten: Tracht als Attrappe (HeldFigur.info), Netze als leere MeshInstance3D. Prueft: (1) fremder Umhang (cloak, Einzelstueck
# cloak_protection, mantle) zeigt das Umhangteil der Tracht; (2) Platz leer: Umhang weg; (3) fremdes Stueck mit gebautem Schrankteil
# blendet das eigene Teil weiter aus (Stufe 2 bleibt); (4) fremdes Stueck mit Teil, dessen Datei nicht gebaut ist: eigenes Teil bleibt.
# godot --headless --path godot -s res://tests/umhang_1569.gd   -> „UMHANG1569 0 Fehler“, Ende 0/1

var falsch := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		falsch += 1
		print("FEHLER ", was)

func figur() -> Node3D:
	var m := Node3D.new()
	for n in ["Umhang", "Brust", "Leib_BRUST"]:
		var mi := MeshInstance3D.new()
		mi.name = n
		m.add_child(mi)
	return m

func sichtbar(m: Node3D, n: String) -> bool: return (m.get_node(n) as MeshInstance3D).visible

func _init() -> void:
	var alt := HeldFigur.info
	HeldFigur.info = {"trachten": {"T_M": {"geschlecht": "M", "eigen": ["leather"],
			"teile": {"CLOAK": ["Umhang"], "CHEST": ["Brust"]}, "leib": {"Leib_BRUST": ["CHEST"]}}},
		"schrank": {"M": {"KETTE": {"netze": [], "leib": []}}}}
	for b in ["cloak", "cloak_protection", "mantle"]:
		var m := figur()
		HeldFigur.kleide(m, {"ausruestung": {"CLOAK": {"base": b}}}, "T_M")
		pruefe(sichtbar(m, "Umhang"), "%s angelegt: Umhang nicht zu sehen" % b)
		m.free()
	var m := figur()
	HeldFigur.kleide(m, {"ausruestung": {"CHEST": {"base": "leather"}}}, "T_M")
	pruefe(not sichtbar(m, "Umhang"), "kein Umhang angelegt: Umhang zu sehen")
	pruefe(sichtbar(m, "Brust") and not sichtbar(m, "Leib_BRUST"), "eigenes Stueck: Brust fehlt oder Leib zu sehen")
	m.free()
	# chain_shirt: Teil KETTE steht im Schrank -> eigenes Brustteil weg (die Datei fehlt hier, schrank_an laedt dann nichts)
	m = figur()
	HeldFigur.kleide(m, {"ausruestung": {"CHEST": {"base": "chain_shirt"}}}, "T_M")
	pruefe(not sichtbar(m, "Brust"), "Kettenhemd mit Schrankteil: eigenes Brustteil noch zu sehen")
	m.free()
	# Teil nicht im Schrank (nicht gebaut): eigenes Teil bleibt statt eines leeren Platzes
	HeldFigur.info["schrank"] = {"M": {}}
	m = figur()
	HeldFigur.kleide(m, {"ausruestung": {"CHEST": {"base": "chain_shirt"}}}, "T_M")
	pruefe(sichtbar(m, "Brust"), "Kettenhemd ohne gebautes Teil: Platz leer")
	m.free()
	pruefe(Array(Katalog.eintrag("chain_shirt").get("teil", [])).has("KETTE"), "chain_shirt ohne Teil KETTE (Annahme des Tests)")
	HeldFigur.info = alt
	print("UMHANG1569 %d Fehler" % falsch)
	quit(1 if falsch > 0 else 0)
