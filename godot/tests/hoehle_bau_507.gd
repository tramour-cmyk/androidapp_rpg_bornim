extends SceneTree
# 507: der Kampfort in der Höhle baut sich je Ort (kampfort.gd _build_cave): Netz aus kampfort-hoehle-<ort>.bin, Lampen aus
# hoehle-info-<ort>.json als Punktlichter (Fackel und Feuer flackern), leuchtende Stoffe, kein Gras; unbekannter Ort wird Halle.
# Ohne Bild; ohne die gebauten Daten (kampf/daten) nur der Hinweis. Aufruf: im Ordner godot mit -s res://tests/hoehle_bau_507.gd;
# massgeblich ist die Zeile HOEHLEBAU507.

const KampfortS = preload("res://kampf/kampfort.gd")

var fehler := 0

func _initialize() -> void:
	_alles.call_deferred()

func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut: fehler += 1

func _alles() -> void:
	if not FileAccess.file_exists("res://kampf/daten/kampfort-hoehle-halle.bin"):
		print("HOEHLEBAU507 ohne Daten (kampf/daten fehlt), nichts geprüft")
		quit(0)
		return
	for o in KampfortS.HOEHLENPLAETZE + ["unbekannt"]:
		var k = KampfortS.new()
		k.ort = "hoehle"
		k.platz = o
		root.add_child(k)     # ohne Kampf: _ready gibt ohne MARS gleich auf, gebaut wird hier von Hand
		k._build_cave()
		var ziel: String = o if o in KampfortS.HOEHLENPLAETZE else "halle"
		_pruef("%s: Ort %s" % [o, ziel], k.platz == ziel)
		var info = JSON.parse_string(FileAccess.get_file_as_string("res://kampf/daten/hoehle-info-%s.json" % ziel))
		var lampen: Array = k.forest.find_children("*", "OmniLight3D", true, false)
		_pruef("%s: Lampen wie in der Info" % o, lampen.size() == info.lampen.size() and lampen.size() >= 2, "%d" % lampen.size())
		var flackernd := 0
		for l in info.lampen:
			if String(l.art) in ["fackel", "feuer"]: flackernd += 1
		_pruef("%s: Fackel und Feuer flackern" % o, k._flackern.size() == flackernd and (flackernd > 0 or ziel == "teich"), "%d" % flackernd)
		var netze: Array = k.forest.find_children("*", "MeshInstance3D", true, false)
		_pruef("%s: Netz da, ohne Gras" % o, netze.size() >= 1 and k.halm_mat == null)
		var leuchtet := 0
		var schatten := 0
		for mi in netze:
			if mi.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: schatten += 1
			for i in mi.mesh.get_surface_count():
				var m = mi.get_surface_override_material(i)
				var g = m.get_shader_parameter("glow") if m is ShaderMaterial else null
				if g != null and float(g) > 0.5: leuchtet += 1
		_pruef("%s: etwas leuchtet (Flamme, Himmel oder Pilz)" % o, leuchtet >= 1, "%d Stoffe" % leuchtet)
		_pruef("%s: Wand und Decke ohne Schlagschatten" % o, schatten == 0)
		for l in lampen:
			_pruef("%s: Lampe in der Höhle (über dem Boden, höchstens 30 m weit)" % o, l.position.y > 0.2 and l.position.length() < 30.0, "%s" % l.position)
		k.queue_free()
		await process_frame
	print("HOEHLEBAU507 %s, %d Fehler" % ["gut" if fehler == 0 else "FEHLER", fehler])
	quit(1 if fehler else 0)
