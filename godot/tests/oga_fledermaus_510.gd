extends SceneTree
# 510 (Lauf 235: die freie Fledermaus kam als leere Datei, 132 Byte, im Film fehlte sie): die gebauten oga_bat-<fell>.bin laden,
# Netz mit Gerüst, die vorhandenen Bewegungen (Bat_Idle, Bat_Flying, Bat_Attack, Bat_Die) und eine Größe wie unsere Fledermaus.
# Ohne Bild; ohne gebaute Daten (kampf/daten) nur der Hinweis. Aufruf: im Ordner godot mit -s res://tests/oga_fledermaus_510.gd;
# massgeblich ist die Zeile OGA510.

var fehler := 0

func _initialize() -> void:
	_alles.call_deferred()

func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut: fehler += 1

func _alles() -> void:
	if not FileAccess.file_exists("res://kampf/daten/oga_bat-braun.bin"):
		print("OGA510 ohne Daten (kampf/daten fehlt), nichts geprüft")
		quit(0)
		return
	for fell in ["braun", "schwarz", "grau"]:
		var p := "res://kampf/daten/oga_bat-%s.bin" % fell
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		var ok := doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) == OK
		_pruef("%s: lesbar" % fell, ok)
		if not ok: continue
		var n := doc.generate_scene(st) as Node3D
		root.add_child(n)
		var netze := n.find_children("*", "MeshInstance3D", true, false)
		var skel := n.find_children("*", "Skeleton3D", true, false)
		_pruef("%s: Netz und Gerüst" % fell, netze.size() >= 1 and skel.size() == 1, "%d Netze, %d Gerüste" % [netze.size(), skel.size()])
		var ap := n.find_children("*", "AnimationPlayer", true, false)
		var namen: Array = []
		if ap.size() > 0:
			namen = Array((ap[0] as AnimationPlayer).get_animation_list())
		var fehlt: Array = []
		for b in ["Bat_Idle", "Bat_Flying", "Bat_Attack", "Bat_Die"]:
			if not b in namen: fehlt.append(b)
		_pruef("%s: Bewegungen" % fell, fehlt.is_empty(), "%s, fehlt %s" % [namen, fehlt])
		# Größe nach den Knochen im Flug (die Hülle des Netzes ist bei gehäuteten Netzen die ungeformte, ohne den Maßstab des Gerüsts)
		var sk := skel[0] as Skeleton3D
		var ap0 := ap[0] as AnimationPlayer
		ap0.play("Bat_Flying")
		var weit := 0.0
		for t in [0.0, 0.08, 0.16, 0.24, 0.32]:
			ap0.seek(t, true)
			var lo := Vector3(1e9, 1e9, 1e9)
			var hi := -lo
			for i in sk.get_bone_count():
				var q: Vector3 = sk.global_transform * sk.get_bone_global_pose(i).origin
				lo = lo.min(q)
				hi = hi.max(q)
			weit = maxf(weit, maxf(hi.x - lo.x, hi.z - lo.z))
		_pruef("%s: Spannweite der Knochen im Flug 0,6 bis 3 m" % fell, weit > 0.6 and weit < 3.0, "%.2f m, Gerüst-Maßstab %.3f" % [weit, sk.global_transform.basis.get_scale().x])
		n.queue_free()
	await process_frame
	print("OGA510 %s, %d Fehler" % ["gut" if fehler == 0 else "FEHLER", fehler])
	quit(1 if fehler else 0)
