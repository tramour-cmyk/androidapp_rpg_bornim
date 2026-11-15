extends SceneTree
# 1215 (Bedingung Tom 15.11., 01:09 vor Jolt auf main): die Durchblende (gebiet.gd baue_gruppen, _physics_process) nutzt als
# einziges auf main Physik: StaticBody3D mit Trimesh je „Gruppe_*“, neun Strahlen Held -> Kamera mit exclude. Kein Test mass
# die Strahlen (glas_608 setzt ziel von Hand). Hier: Held hinter dem groessten Haus -> ziel DURCH_A, davor -> 1.0, nach einigen
# Physikschritten. Mit Dorfmodell (godot/daten/dorf.bin wie im Bau) das echte Dorf, sonst ein Haus aus einem Kasten.
# Dazu LADEN: Zeit fuer add_child des Gebiets (Trimesh-Bau und Einfuegen in den Raum) und die Physik-Engine.
# Vergleich vorher/nachher: einmal so (Jolt, project.godot), einmal mit override.cfg „3d/physics_engine=GodotPhysics3D“.
# Aufruf: im Ordner godot mit -s res://tests/durchblick_1215.gd -> „DURCHBLICK1215 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

# ohne Dorfmodell: Gebiet ohne _ready (das laedt dorf.bin), Gruppen von Hand
class GebietOhne extends Gebiet:
	func _ready() -> void: pass

func _initialize() -> void: _lauf.call_deferred()

func kasten_haus() -> Node3D:
	var netz := Node3D.new()
	var mi := MeshInstance3D.new()
	mi.name = "Gruppe_Haus"
	var bm := BoxMesh.new()
	bm.size = Vector3(6, 5, 6)
	mi.mesh = bm
	mi.position = Vector3(20, 2.5, 20)
	var m := ShaderMaterial.new()
	m.shader = load("res://shader/toon.gdshader")
	mi.set_surface_override_material(0, m)
	netz.add_child(mi)
	return netz

func physik(n: int) -> void:
	for i in n: await physics_frame

func _lauf() -> void:
	if Gebiet.toon == null: Gebiet.toon = load("res://shader/toon.gdshader")
	var engine := String(ProjectSettings.get_setting("physics/3d/physics_engine", "DEFAULT"))
	var echt := FileAccess.file_exists("res://daten/dorf.bin")
	var k := Karte.lade("village", {})
	var g: Gebiet = Gebiet.new(k) if echt else GebietOhne.new(k)
	var t0 := Time.get_ticks_usec()
	root.add_child(g)
	if not echt:
		var netz := kasten_haus()
		g.add_child(netz)
		g.baue_gruppen(netz)
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	print("LADEN %s %.0f ms (%s, %d Gruppen)" % [engine, ms, "Dorf" if echt else "Kasten", g.gruppen.size()])
	await physik(2)
	# groesstes Haus: Gruppe mit dem groessten Koerper
	var haus: MeshInstance3D = null
	var gross := 0.0
	for mi in g.find_children("Gruppe_*", "MeshInstance3D", true, false):
		if String(mi.name).ends_with("_Glas") or not String(mi.name).to_lower().begins_with("gruppe_haus"): continue
		var bb: AABB = mi.global_transform * mi.get_aabb()
		if bb.size.x * bb.size.z > gross: gross = bb.size.x * bb.size.z; haus = mi
	pruefe(haus != null, "ein Haus (Gruppe_haus_*) im Gebiet")
	if haus == null: return ende(g)
	var key := String(haus.name).trim_suffix("_Glas")
	var bb: AABB = haus.global_transform * haus.get_aabb()
	var c := bb.get_center()
	# Blick quer zur schmalen Seite, Neigung 30 Grad wie kamera.gd; der Held 0,4 m hinter der Rueckwand (Lauf 484: schraeg, 38 Grad
	# und 0,8 m hinter der Ecke stiegen die Strahlen ueber das 5 m hohe Haus)
	var richt := Vector3(0, 0, 1) if bb.size.z <= bb.size.x else Vector3(1, 0, 0)
	var halb := minf(bb.size.x, bb.size.z) / 2.0
	var kam := Camera3D.new()
	root.add_child(kam)
	kam.global_position = c + richt * 20.0 * cos(deg_to_rad(30.0)) + Vector3(0, 20.0 * sin(deg_to_rad(30.0)), 0)
	kam.look_at(c, Vector3.UP)
	var held := Node3D.new()
	root.add_child(held)
	g.held = held
	g.kamera = kam
	var boden := bb.position.y
	held.global_position = Vector3(c.x, boden, c.z) - richt * (halb + 0.4)
	await physik(5)
	pruefe(absf(float(g.gruppen[key]["ziel"]) - Gebiet.DURCH_A) < 0.001, "Held hinter %s: ziel %.2f, soll %.2f" % [key, g.gruppen[key]["ziel"], Gebiet.DURCH_A])
	held.global_position = Vector3(c.x, boden, c.z) + richt * (halb + 1.5)
	await physik(5)
	pruefe(absf(float(g.gruppen[key]["ziel"]) - 1.0) < 0.001, "Held vor %s: ziel %.2f, soll 1.0" % [key, g.gruppen[key]["ziel"]])
	held.global_position = Vector3(c.x, boden, c.z) - richt * (halb + 0.4)
	await physik(5)
	pruefe(absf(float(g.gruppen[key]["ziel"]) - Gebiet.DURCH_A) < 0.001, "wieder dahinter: ziel %.2f" % g.gruppen[key]["ziel"])
	ende(g)

func ende(g: Gebiet) -> void:
	g.queue_free()
	print("DURCHBLICK1215 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
