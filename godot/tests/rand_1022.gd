extends SceneTree
# 1022 ohne Bild (Chef 12.11., 08:26: „der Wald ist außenrum nicht dicht oder abgedunkelt … 1000 Wege weg“; alt 27m): der Rand jeder
# Gebietskarte (Dorf, Flüsterwald, Tiefer Wald). Je Seite und je Kachel des Randes (Gasse) aus dorf.py (info rand):
#  1. Wald dicht: jede trockene Gasse hat hinter dem Rand einen Baum oder Busch (Wasser laeuft ins Dunkel weiter, MapEdge);
#  2. kein Weg ins Offene: jede Gasse, in der ein begehbarer Rand liegt (Weg, Wiese, Ausgang), hat in ihr oder daneben einen Baum
#     5 bis 6 Kacheln draussen, wo der Wald zugeht (MapEdge.CLOSE, RING);
#  3. jede Seite traegt den ganzen Ring (ein Baum 6 Kacheln draussen; vorher fehlten im Norden und Westen die Reihen 5 und 6);
#  4. ins Dunkel: jedes Netz des Gebiets laeuft hinter dem Rand aus (rand_karte an, toon, boden, wasser mit rand_licht).
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/rand_1022.gd; massgeblich ist die Zeile RAND1022.

const CLOSE := 5   # MapEdge.CLOSE
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok: print("FEHLER " + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	for sh in ["toon", "boden", "wasser"]:
		pruefe((load("res://shader/%s.gdshader" % sh) as Shader).code.contains("rand_licht("), "%s.gdshader dunkelt hinter dem Rand ab" % sh)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for ziel in [["village", Vector2i(19, 13)], ["forest", Vector2i(9, 3)], ["deep_forest", Vector2i(28, 12)]]:
		spiel.betrete(ziel[0], ziel[1], "UP")
		for i in 3: await process_frame
		pruefe(spiel.karte.id == ziel[0], "Karte %s betreten" % ziel[0])
		karte_pruefen(spiel)
	print("RAND1022 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func karte_pruefen(spiel) -> void:
	var id: String = spiel.karte.id
	var info: Dictionary = spiel.gebiet.info
	var rd: Dictionary = info.get("rand", {})
	pruefe(not rd.is_empty(), "%s: dorf.py hat den Rand gemeldet (info rand)" % id)
	if rd.is_empty(): return
	var ring := int(rd["ring"])
	var baum := {}
	var etwas := {}
	for p in rd["baeume"]: baum[Vector2i(int(p[0]), int(p[1]))] = true; etwas[Vector2i(int(p[0]), int(p[1]))] = true
	for p in rd["niedrig"]: etwas[Vector2i(int(p[0]), int(p[1]))] = true
	var w: int = spiel.karte.breite; var h: int = spiel.karte.hoehe
	var offen := 0; var gassen := 0
	# je Seite: Name, Gassen (Kachel am Rand), Schritt nach aussen
	for seite in [["Norden", Vector2i(0, 1), Vector2i(0, -1), 0, w], ["Sueden", Vector2i(0, 1), Vector2i(0, 1), h - 1, w],
				  ["Westen", Vector2i(1, 0), Vector2i(-1, 0), 0, h], ["Osten", Vector2i(1, 0), Vector2i(1, 0), w - 1, h]]:
		var aus: Vector2i = seite[2]
		var voll := false
		for i in int(seite[4]):
			var rand_k := Vector2i(i, int(seite[3])) if aus.y != 0 else Vector2i(int(seite[3]), i)
			var z := String(spiel.karte.zeichen(rand_k))
			if z == "~" or z == "h": continue          # Wasser und Bruecke laufen ins Dunkel weiter (MapEdge wet)
			gassen += 1
			var dicht := false
			for d in range(1, ring + 1):
				if etwas.has(rand_k + aus * d): dicht = true
				if d == ring and baum.has(rand_k + aus * d): voll = true
			if not dicht:
				offen += 1
				print("  %s %s: Gasse %s ohne Baum oder Busch bis %d Kacheln" % [id, seite[0], rand_k, ring])
			if spiel.karte.begehbar(rand_k):
				var zu := false
				for d in range(CLOSE, ring + 1):
					for q in [-1, 0, 1]:
						var quer := Vector2i(q, 0) if aus.y != 0 else Vector2i(0, q)
						if baum.has(rand_k + quer + aus * d): zu = true
				pruefe(zu, "%s %s: Weg am Rand %s endet im Wald (Baum %d bis %d Kacheln draussen)" % [id, seite[0], rand_k, CLOSE, ring])
		pruefe(voll, "%s %s: ganzer Ring (ein Baum %d Kacheln draussen)" % [id, seite[0], ring])
	pruefe(offen == 0, "%s: Wald dicht, %d von %d Gassen offen" % [id, offen, gassen])
	# ins Dunkel
	var ohne := 0; var mit := 0
	for mi in spiel.gebiet.find_children("*", "MeshInstance3D", true, false):
		var nm := String(mi.name)
		if not (nm.begins_with("Dorf_") or nm.begins_with("Gruppe_") or nm.begins_with("Schlagbaum")): continue   # nur das Netz aus dorf.py
		for k in (mi as MeshInstance3D).get_surface_override_material_count():
			var m := (mi as MeshInstance3D).get_surface_override_material(k) as ShaderMaterial
			if m == null: continue
			var x = m.get_shader_parameter("rand_karte")
			if x is Vector3 and is_equal_approx(x.x, w * Karte.TS) and is_equal_approx(x.y, h * Karte.TS) and x.z > 0.5: mit += 1
			else: ohne += 1
	var boden = spiel.gebiet.boden
	pruefe(boden != null and boden.get_shader_parameter("rand_karte") is Vector3, "%s: Boden laeuft ins Dunkel" % id)
	pruefe(mit > 0 and ohne == 0, "%s: alle Netze laufen ins Dunkel (%d mit, %d ohne)" % [id, mit, ohne])
	print("%s: %d Gassen, %d Baeume und %d niedrige hinter dem Rand, %d Materialien mit Rand" % [id, gassen, rd["baeume"].size(), rd["niedrig"].size(), mit])
