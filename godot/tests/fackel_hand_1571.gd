extends SceneTree
# 1571 Messung (Tom 18.11.): in welcher Hand haelt der Held der Ausruestung die Fackel der Nebenhand? Seite der Fackel gegen Blickrichtung
# der Figur und gegen die Knochen hand_l/hand_r, je Herkunft. Kein Bild. MESS=1571 godot --headless --path . -s res://tests/fackel_hand_1571.gd
func _initialize() -> void:
	_l.call_deferred()

func _l() -> void:
	var fehler := 0
	for h in ["Zauberlehrling", "Jägerkind", "Klosterschüler", "Kräutersammler"]:
		for g in ["m", "w"]:
			var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
			var a: Dictionary = hw.ausruestung.duplicate()
			a["OFF_HAND"] = {"base": "torch"}
			var w := {"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": a, "fackel_zeigen": true}
			var m: Node3D = HeldFigur.baue(w, [])
			if m == null: print("FACKEL1571 ", h, " ", g, " kein Modell"); continue
			root.add_child(m)
			var ap: AnimationPlayer = m.find_children("*", "AnimationPlayer", true, false)[0] if not m.find_children("*", "AnimationPlayer", true, false).is_empty() else null
			var st := String(m.get_meta("stehen", "Stehen"))
			if ap: Gebiet.bewegungen(ap, ["Stehen", st])
			if ap: print("FACKEL1571 Bewegungen ", ap.get_animation_list())
			if ap and ap.has_animation(st): ap.play(st); ap.seek(0.5, true)
			await process_frame
			await process_frame
			var sk: Skeleton3D = m.find_children("*", "Skeleton3D", true, false)[0]
			var fk: Array = m.find_children("*", "Fackel", true, false)
			var bl := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_l"))
			var br := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_r"))
			var kopf := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("head"))
			var fu := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("foot_l"))
			var ba := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("ball_l"))
			var vorn := signf(ba.origin.z - fu.origin.z)   # Zehen zeigen nach vorn
			var fx := "keine"
			if not fk.is_empty():
				var p: Vector3 = (fk[0] as Node3D).global_position
				fx = "links" if p.distance_to(bl.origin) < p.distance_to(br.origin) else "rechts"
			# Blickrichtung der Figur: Modell schaut nach +z (Kamera); anatomisch links = +x, wenn nicht gespiegelt
			print("FACKEL1571 ", h, " ", g, " Fackel naeher an hand_", "l" if fx == "links" else "r", " (", fx, ")  hand_l x %.2f hand_r x %.2f" % [bl.origin.x, br.origin.x],
				"  Modell basis det %.2f" % m.global_transform.basis.determinant(), " Achse z des Modells ", m.global_transform.basis.z,
				" Zehen nach z %+.0f" % vorn, " anatomisch ", ("links" if (bl.origin.x * vorn) > 0 else "rechts"), " Bewegung ", st, " da ", ap != null and ap.has_animation(st), " Fackel bei %s" % (str((fk[0] as Node3D).global_position) if not fk.is_empty() else "-"), " Fackeln ", fk.size(), " gehalten ", m.find_children("Gehalten*", "", true, false).size())
			m.free()
	print("FACKEL1571 fertig")
	quit(fehler)
