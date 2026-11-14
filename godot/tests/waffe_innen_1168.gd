extends SceneTree
# 1168 (410, Chef 31.10., 21:17: Waffen „innen ausgeblendet“): in Schenke, Laden, Haus und Tempel traegt die Figur des Helden keine
# Waffe (Haupthand, Dolch der Nebenhand), Schild bleibt; draussen ist sie wieder da; die Ausruestung im Spielstand bleibt.
# Massgeblich ist die Zeile WAFFEINNEN1168.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func haende(spiel) -> Array:
	var aus: Dictionary = spiel.figur_wahl().get("ausruestung", {})
	var h = aus.get("MAIN_HAND"); var n = aus.get("OFF_HAND")
	return [String(h["base"]) if h is Dictionary else "", String(n["base"]) if n is Dictionary else ""]

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var hw = spiel.held_werte()
	Testmodus.waffe(hw, spiel.zustand, "shortsword")
	Testmodus.waffe(hw, spiel.zustand, "dagger", true)
	spiel.betrete("village", Vector2i(17, 10), "DOWN")
	for i in 3: await process_frame
	var draussen := haende(spiel)
	print("1168 Dorf ", draussen)
	pruefe(draussen == ["shortsword", "dagger"], "draußen Kurzschwert und Dolch an der Figur")
	for ort in ["inn", "shop", "elder", "temple"]:
		spiel.betrete(ort, Vector2i(3, 3), "DOWN")
		for i in 3: await process_frame
		var innen := haende(spiel)
		pruefe(innen == ["", ""], "%s: keine Waffe an der Figur (%s)" % [ort, innen])
	pruefe(hw.ding("MAIN_HAND") != null and String(hw.ding("MAIN_HAND")["base"]) == "shortsword" and hw.ding("OFF_HAND") != null,
		"innen bleibt die Ausrüstung im Spielstand")
	Testmodus.waffe(hw, spiel.zustand, "shield", true)
	pruefe(haende(spiel) == ["", "shield"], "innen: Schild bleibt an der Figur (%s)" % [haende(spiel)])
	spiel.betrete("village", Vector2i(17, 10), "DOWN")
	for i in 3: await process_frame
	pruefe(haende(spiel) == ["shortsword", "shield"], "wieder draußen: Waffe und Schild da (%s)" % [haende(spiel)])
	print("WAFFEINNEN1168 " + ("gut" if fehler == 0 else "FEHLER %d" % fehler))
	quit(1 if fehler else 0)
