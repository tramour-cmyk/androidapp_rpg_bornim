extends SceneTree
# 431h Stufe 2, Messung (Vorlage: „Modellgroesse und Ladezeit nicht schlechter als 20 %“): Ladezeit Held, Kleiderschrank, Held mit
# fremden Stuecken (erstes und zweites Mal). godot --headless --path godot -s res://tests/mess_schrank_431.gd
func _init() -> void:
	for d in ["res://daten/held_WACHE_M.bin", "res://daten/schrank_M_RANGER_BODY.bin", "res://daten/schrank_M_KNIGHT_ARMS.bin"]:
		var t := Time.get_ticks_msec()
		var s := Gebiet.lade_glb(d)
		print("MESS431 laden %s %d ms, %.1f MB" % [d, Time.get_ticks_msec() - t, FileAccess.get_file_as_bytes(d).size() / 1e6])
		s.free()
	var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Wachsoldat")
	for f in ["start", "fremd", "fremd2"]:
		var aus := hw.ausruestung.duplicate()
		if f != "start": aus["CHEST"] = {"base": "leather"}; aus["ARMS"] = {"base": "gauntlets_ogre"}
		var t := Time.get_ticks_msec()
		var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": "HUMAN", "aussehen": {"geschlecht": "m"}, "ausruestung": aus}, [])
		var dr := 0
		for mi in m.find_children("*", "MeshInstance3D", true, false):
			if (mi as MeshInstance3D).visible and (mi as MeshInstance3D).is_visible_in_tree(): dr += (mi as MeshInstance3D).mesh.get_faces().size() / 3
		print("MESS431 baue %s %d ms, %d sichtbare Dreiecke" % [f, Time.get_ticks_msec() - t, dr])
		m.free()
	quit(0)
