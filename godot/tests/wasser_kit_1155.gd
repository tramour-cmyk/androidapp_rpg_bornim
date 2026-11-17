extends SceneTree
# 1155: das Wasser des Kits (R10 „Teich klar“) auf jeder Wasserflaeche, wenn das Kit im Bau liegt (godot.yml „Wasser R10“); ohne Kit
# unser Wasser. Mit Kit: Schablone 1 (keine Tusche auf dem Wasser), Kartenrand und Nachtlicht aus shader/wasser_kit.gdshaderinc, die
# Werte der Vorgabe pond_clear; in der Hoehle dunkel und mit Eigenlicht. Aufruf: im Ordner godot mit -s res://tests/wasser_kit_1155.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FEHLER ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var kit := ResourceLoader.exists(Gebiet.KIT_SHADER) and ResourceLoader.exists(Gebiet.KIT_VORGABE)
	var sh := Gebiet.kit_wasser()
	print("WASSER1155 Kit ", "da" if kit else "nicht da")
	pruefe("Kit genau dann, wenn im Bau", sh != null, kit)
	var inc := FileAccess.get_file_as_string("res://shader/wasser_kit.gdshaderinc")
	for u in ["night", "maske", "inseln", "rand_karte", "kit_selbst", "kit_rand", "kit_nacht"]: pruefe("Zusatz hat " + u, inc.contains(u), true)
	if sh != null:
		var c := sh.code
		pruefe("Schablone 1", c.contains("stencil_mode write, compare_always, 1;"), true)
		pruefe("Zusatz eingehaengt", c.contains('#include "res://shader/wasser_kit.gdshaderinc"'), true)
		pruefe("gemeinsame Datei mit Pfad", c.contains('#include "res://addons/water_kit/shaders/water_common.gdshaderinc"'), true)
		pruefe("Rand und Nacht am Ende", c.contains("kit_rand(v_world") and c.contains("kit_nacht(v_world"), true)
		var v := load(Gebiet.KIT_VORGABE) as ShaderMaterial
		pruefe("Vorgabe pond_clear", v.get_shader_parameter("clarity"), 2.2)
	print("WASSER1155 %d Fehler" % fehler)
	quit(1 if fehler else 0)
