extends SceneTree
# 1694 (Auftrag 19.11.: „Prüfung über alle Figurenarten mal alle gehaltenen Gegenstände“): jeder Körper mit Fingern (Held je Tracht, Leute,
# Kaufmonster mit Menschengerüst) mal jeder gehaltene Gegenstand (daten/waffen, ohne Schilde und Köcher): angelegt mit der einen
# Anlegefunktion (Halt.anlegen, rechte Faust) und dem einen Griff (GriffHand, skripte/griff.gd), gemessen am gezeichneten Netz
# (NetzMess.griff, Prüfung NetzMess.griff_gut). Körper ohne Finger (Goblin, Kobold: Faust im Netz) und mit fremdem Gerüst (Skelett,
# Ghul) werden genannt, nicht geprüft.
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_alle_1694.gd   (Exit 1 bei Fehler; NUR=<Körperteil>)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var koerper := []
	for d in ["res://daten/", "res://daten/leute/", "res://kampf/daten/"]:
		for f in DirAccess.get_files_at(d):
			if not f.ends_with(".bin") or f.begins_with("schrank_") or f.contains("bewegungen") or f.begins_with("menue-"): continue
			if d == "res://daten/" and not f.begins_with("held"): continue
			if OS.get_environment("NUR") != "" and not f.contains(OS.get_environment("NUR")): continue
			koerper.append(d + f)
	var dinge := []
	for f in DirAccess.get_files_at("res://daten/waffen/"):
		if f.ends_with(".bin") and not f.begins_with("quiver") and not f.contains("shield"): dinge.append(f.get_basename())
	var paare := 0; var fehler := 0; var ohne := []
	for kf in koerper:
		var m := Gebiet.lade_glb(kf)
		if m == null: continue
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		if sk == null or not Griff.hat_hand(sk, "r"):
			if sk != null and sk.get_bone_count() > 20: ohne.append(kf.get_file())
			m.free(); continue
		root.add_child(m)
		Gebiet.male(m, null, 2, [])
		for id in dinge:
			var h := Halt.gegenstand(id)
			var d := Halt.anlegen(sk, "faust_r", id, "Gehalten1694")
			if d == null: continue
			Gebiet.male(d, null, 2, [])
			var g := GriffHand.an(sk, d, "r", h, GriffHand.art_von(id))
			if g == null: print("ALLE1694 %s %s: kein Griff (Halter nicht am Handknochen)" % [kf.get_file(), id]); fehler += 1; continue
			var werte := []
			var cb := func(): werte.append(NetzMess.griff(sk, "r", d, h))
			for f in 2: await process_frame
			sk.skeleton_updated.connect(cb)
			for f in 3: await process_frame
			sk.skeleton_updated.disconnect(cb)
			var gueltig := werte.filter(func(e): return e.ecken > 0)
			paare += 1
			if gueltig.is_empty():
				print("ALLE1694 FEHLER %s %s: kein Netz (xvfb?)" % [kf.get_file(), id]); fehler += 1
			else:
				var w: Dictionary = NetzMess.median(gueltig)
				var gut: bool = not gueltig[0].has("leer") and NetzMess.griff_gut(w)
				if not gut or OS.get_environment("ALLE") != "":
					print("ALLE1694 %s %-28s %s Spalt %.1f, Umschlingung %d°, Glieder %.1f, Kuppen %.1f cm%s" % [kf.get_file(), id, GriffHand.art_von(id),
						w.get("kontakt", 0.0), int(w.get("umschl", 0.0)), w.get("tief", 0.0), w.get("kuppe", 0.0), "" if gut else ("  FEHLER" + (" (nicht in der Hand)" if gueltig[0].has("leer") else ""))])
				fehler += 0 if gut else 1
			g.free()
			for n in sk.get_children(): if String(n.name) == "Gehalten1694": n.free()
		m.queue_free()
		await process_frame
	print("ALLE1694 ohne Finger oder fremdes Gerüst, nicht geprüft: %s" % ", ".join(ohne))
	print("ALLE1694 %d Paare, %d Fehler" % [paare, fehler])
	quit(1 if fehler > 0 else 0)
