extends SceneTree
# 1694 (Auftrag 19.11.: „Prüfung über alle Figurenarten mal alle gehaltenen Gegenstände“): jeder Körper mit Fingern (Held je Tracht, Leute,
# Kaufmonster mit Menschengerüst) mal jeder gehaltene Gegenstand (daten/waffen, ohne Schilde und Köcher): angelegt mit der einen
# Anlegefunktion (Halt.anlegen, rechte Faust) und dem einen Griff (GriffHand, skripte/griff.gd), gemessen am gezeichneten Netz
# (NetzMess.griff, Prüfung NetzMess.griff_gut). Körper ohne Finger (Goblin, Kobold: Faust im Netz) und mit fremdem Gerüst (Skelett,
# Ghul) werden genannt, nicht geprüft.
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_alle_1694.gd   (Exit 1 bei Fehler; NUR=<Körperteil>,
#   DING=<id>, BILDER=<ordner>: Prüfbilder je Paar; 23.11.: gut = Netz gut und im Bild (NetzMess.sicht) höchstens 10 % des Schafts sichtbar)

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
	# 1694 (23.11.): Prüfung nach dem Bild (NetzMess.sicht) in einem kleinen Bild derselben Welt, neben der Netzmessung
	var sv := SubViewport.new()
	sv.size = Vector2i(200, 200); sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sv)
	var kam := Camera3D.new(); kam.fov = 30.0; sv.add_child(kam); kam.make_current()
	var bilder := OS.get_environment("BILDER")
	for kf in koerper:
		var m := Gebiet.lade_glb(kf)
		if m == null: continue
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		if sk == null or not Griff.hat_hand(sk, "r") or Griff.netz_finger(sk, "r").is_empty():
			# 1694 (19.11., 10:49): ohne Fingerknochen oder ohne Haut an den Fingern (Faust im Netz: daten/held.bin, daten/leute/*.bin,
			# Ersatz ohne Kaufmodelle; Goblin, Kobold)
			if sk != null and sk.get_bone_count() > 20: ohne.append(kf.get_file())
			m.free(); continue
		root.add_child(m)
		Gebiet.male(m, null, 2, [])
		for id in dinge:
			if OS.get_environment("DING") != "" and id != OS.get_environment("DING"): continue
			var h := Halt.gegenstand(id)
			var d := Halt.anlegen(sk, "faust_r", id, "Gehalten1694")
			if d == null: continue
			Gebiet.male(d, null, 2, [])
			var g := GriffHand.an(sk, d, "r", h, GriffHand.art_von(id))
			if g == null: print("ALLE1694 %s %s: kein Griff (Halter nicht am Handknochen)" % [kf.get_file(), id]); fehler += 1; continue
			var werte := []
			var pk := {}
			var cb := func():
				werte.append(NetzMess.griff(sk, "r", d, h))
				pk.merge(NetzMess.hand_punkte(sk, "r"), true)
			for f in 2: await process_frame
			sk.skeleton_updated.connect(cb)
			for f in 3: await process_frame
			sk.skeleton_updated.disconnect(cb)
			var gueltig := werte.filter(func(e): return e.ecken > 0)
			var waffen_netze := d.find_children("*", "MeshInstance3D", true, false) + ([d] if d is MeshInstance3D else [])
			var koerper_netze := sk.find_children("*", "MeshInstance3D", true, false).filter(func(x): return not x in waffen_netze)
			var si := {}
			if not pk.is_empty():
				si = await NetzMess.sicht(pk, d, h, sv, kam, koerper_netze, ("%s/%s-%s" % [bilder, kf.get_file().get_basename(), id]) if bilder != "" else "")
			paare += 1
			if gueltig.is_empty():
				print("ALLE1694 FEHLER %s %s: kein Netz (xvfb?)" % [kf.get_file(), id]); fehler += 1
			else:
				var w: Dictionary = NetzMess.median(gueltig)
				var netz_gut: bool = not gueltig[0].has("leer") and NetzMess.griff_gut(w)
				var sicht_gut: bool = not si.is_empty() and NetzMess.sicht_gut(si)
				var gut := netz_gut and sicht_gut
				if not gut or OS.get_environment("ALLE") != "":
					print("ALLE1694 %s %-28s %s Spalt %.1f, Umschlingung %d°, Glieder %.1f, Kuppen %.1f cm; sichtbar innen %d%%, außen %d%%%s" % [kf.get_file(), id, GriffHand.art_von(id),
						w.get("kontakt", 0.0), int(w.get("umschl", 0.0)), w.get("tief", 0.0), w.get("kuppe", 0.0),
						int(100.0 * float(si.get("innen", 1.0))), int(100.0 * float(si.get("aussen", 1.0))),
						"" if gut else ("  FEHLER" + (" (nicht in der Hand)" if gueltig[0].has("leer") else "") + ("" if netz_gut else " Netz") + ("" if sicht_gut else " Bild"))])
				fehler += 0 if gut else 1
			g.free()
			for n in sk.get_children(): if String(n.name) == "Gehalten1694": n.free()
		m.queue_free()
		await process_frame
	print("ALLE1694 ohne Finger oder fremdes Gerüst, nicht geprüft: %s" % ", ".join(ohne))
	print("ALLE1694 %d Paare, %d Fehler" % [paare, fehler])
	quit(1 if fehler > 0 else 0)
