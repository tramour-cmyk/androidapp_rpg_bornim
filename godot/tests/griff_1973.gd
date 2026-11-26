extends SceneTree
# 1973 Rückläufer (Chef 26.11., 11:29: „keine der beiden Hände hält das Schwert … das Ende des Schwerts an der oberen Hand aufgesetzt“):
# Wachsoldat geht mit greatsword (Gehen_axt) wie waffengang_bild_1973.gd, ohne Bild. Misst je Bild, wo die Fäuste längs der Klinge
# liegen, im Raum des Modells (y: 0 = Ursprung = Griffpunkt laut Halt, Griff reicht bis hoehe.x = unteres Ende; negativ = unter dem
# Knauf) und wie weit quer zur Achse (cm). Faust rechts: Tragen.faust_welt; links: Handrahmen · ZWEI_LINKS (wie tragen.gd _paket).
# Aufruf: im Ordner godot mit --headless -s res://tests/griff_1973.gd -> Zeilen „GRIFF1973 …“
func _initialize() -> void: _lauf.call_deferred()

func _bilder(n: int) -> void:
	for i in n: await process_frame

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await _bilder(5)
	var w := BrsHeld.fuer_spiel("Test", "Mensch", "Wachsoldat")
	spiel.werte = w
	w.ausruestung["MAIN_HAND"] = {"base": "greatsword"}
	w.ausruestung.erase("OFF_HAND")
	spiel.held_figur_neu("")
	if spiel.herde:
		spiel.herde.aus = true
		spiel.herde.process_mode = Node.PROCESS_MODE_DISABLED
	var h = spiel.held
	var t: Node = h.find_child("Tragen", true, false)
	var waffe: Node3D = h.find_child("Getragen", true, false)
	if t == null or waffe == null:
		print("GRIFF1973 kein Modell in der Hand (Tragen %s, Getragen %s)" % [t != null, waffe != null]); quit(1); return
	var schl := HeldFigur._modell({"base": "greatsword"})
	var m: Dictionary = Halt.gegenstand(schl)
	print("GRIFF1973 Modell %s: Griffpunkt %s, unteres Ende %.1f cm, Spitze %.1f cm, zwei_schieben %.2f m" % [schl, m["griff"],
		100.0 * (m["hoehe"] as Vector2).x, 100.0 * (m["hoehe"] as Vector2).y, float(t.get("zwei_schieben"))])
	h.setze(Vector2i(4, 8), "DOWN")
	await _bilder(20)
	h.geh_zu(h.global_position + Vector3(3, 0, 0))
	var sk := Gebiet.finde(h, "Skeleton3D") as Skeleton3D
	for i in 8:
		await _bilder(3)
		var inv := waffe.global_transform.affine_inverse()
		var RL: Transform3D = Tragen.hand_rahmen(sk, "l")
		var fl := sk.global_transform * (RL * Tragen.ZWEI_LINKS)
		var z := []
		for p in [t.get("faust_welt"), fl]:
			var q: Vector3 = inv * (p as Vector3)
			z.append("y %.1f cm, quer %.1f cm" % [100.0 * q.y, 100.0 * Vector2(q.x, q.z).length()])
		var ap := Gebiet.finde(h, "AnimationPlayer") as AnimationPlayer
		print("GRIFF1973 Bild %d %s: Faust rechts %s; Faust links %s" % [i, ap.current_animation if ap else "?", z[0], z[1]])
	quit(0)
